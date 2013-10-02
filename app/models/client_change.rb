require 'andand'

class ClientChange
  include Mongoid::Document
  include Mongoid::Timestamps

  belongs_to :user
  belongs_to :client # for indexing purposes
  belongs_to :new_section, :class_name => 'DocumentTemplateSection'
  belongs_to :old_section, :class_name => 'DocumentTemplateSection'
  has_many :documents, dependent: :delete

  field :type, type: String
  field :client_data, type: Hash
  field :description, type: String

  SQUASH_TIME = 5*60 # 5 minutes

  # Empty values should be treated the same as missing values.
  def self.value_equals(a, b)
    if a.is_a?(Hash)
      a = a.keep_if { |k, v| v }
    end

    if b.is_a?(Hash)
      b = b.keep_if { |k, v| v }
    end

    a_null = !a || a.respond_to?(:empty?) && a.empty?
    b_null = !b || b.respond_to?(:empty?) && b.empty?
    if a_null != b_null
      return false
    elsif a_null
      return true
    else
      return a == b
    end
  end

  def self.collection_diff(new_arr, old_arr, fields)
    old_ids = {}
    old_ids = Hash[old_arr.map { |x| [x['id'], x] }] if old_arr.is_a?(Array)
    new_ids = Hash[new_arr.map { |x| [x['id'], x] }]

    primary_field = Client.expand_fields(fields).andand.find { |f|
      f[:primary] && f[:type][/text|name/]
    }.andand[:id]

    # Merge old array into new array; this way we can see deletions in the change view.
    if old_arr.is_a?(Array)
      old_arr.each do |x|
        if !new_ids[x['id']]
          new_arr << x
        end
      end
      new_arr.sort! { |x, y| x['id'] <=> y['id'] }
    end

    result = new_arr.map do |val|
      old_val = old_ids[val['id']]
      if !new_ids[val['id']]
        {
          :name => primary_field && val[primary_field].andand['value'],
          :type => :deleted
        }
      elsif val != old_val
        ch = get_changed_fields(val, old_val, fields)
        ch.empty? ? nil : {
          :change => ch,
          :name => primary_field && val[primary_field].andand['value'],
          :type => old_val.nil? ? :added : :edited,
        }
      else
        nil
      end
    end

    if result.compact.empty?
      result = nil
    end

    result
  end

  def self.hash_diff(new_hash, old_hash)
    d = new_hash.diff(old_hash)
    Hash[d.keys.map { |k| [k, true] }]
  end

  def self.value_diff(new_val, old_val, field = nil)
    val = new_val || old_val
    type = field.andand[:type]
    if val.is_a?(Array)
      collection_diff(new_val || [], old_val || [], field.andand[:type])
    elsif type == 'units'
      return {
        :qty => value_diff(new_val.andand['qty'], old_val.andand['qty']),
        :unit => value_diff(new_val.andand['unit'], old_val.andand['unit']),
      }
    elsif val.is_a?(Hash)
      hash_diff(new_val || {}, old_val || {})
    elsif type == 'file'
      old_val.to_s
    else
      val = case type
            when 'date'
              old_val.to_i > 0 && Time.at(old_val.to_i).strftime('%F')
            when 'radio'
              field.andand[:options].andand[old_val] || old_val
            else
              old_val = old_val.to_s
              !old_val.empty? && old_val
            end
      'Previous value: ' + (val || '(empty)')
    end
  end

  def self.get_changed_fields(new_client, old_client, fields = Client::FIELDS)
    changed_fields = {}

    field_map = {}
    if fields
      Client.expand_fields(fields).each do |field|
        field_map[field[:id]] = field
      end
    end

    keys = new_client.keys | (old_client.andand.keys || [])

    keys.each do |key|
      if field_map[key].andand[:type].is_a?(Class)
        if !field_map[key][:type].syncable?
          next # Don't check non-syncable classes.
        else
          field_map[key] = field_map[key].dup
          field_map[key][:type] = field_map[key][:type]::FIELDS
        end
      end

      val = new_client[key]
      val = (val.is_a?(Hash) && val['value']) ? val['value'] : nil

      old_val = old_client.andand[key]
      old_val = (old_val.is_a?(Hash) && old_val['value']) ? old_val['value'] : nil

      if !value_equals(val, old_val)
        changed_fields[key] = value_diff(val, old_val, field_map[key])
      end
    end

    changed_fields.keep_if { |k, v| v }
  end

  def self.humanize(str)
    str.underscore.humanize.downcase
  end

  def self.get_change_description(new_client, old_client)
    if old_client.nil?
      return 'Created new client ' + new_client['company_name']['value']
    end

    changed = []
    added = []
    deleted = []
    get_changed_fields(new_client.deep_dup, old_client).sort.each do |field_id, diff|
      if diff.is_a?(Array)
        diff.compact!
        if diff.length > 1
          changed << humanize(field_id)
        else
          diff = diff.first
          name = diff[:name] ? " (#{diff[:name]})" : ''
          field_name = humanize(field_id).singularize
          if diff[:type] == :added
            added << "#{field_name}#{name}"
          elsif diff[:type] == :deleted
            deleted << "#{field_name}#{name}"
          else
            desc = "#{field_name}#{name}"
            if diff[:change].keys.length <= 3
              fields = diff[:change].keys.map { |id| humanize(id) }.join(', ')
              desc = fields + ' of ' + desc
            end
            changed << desc
          end
        end
      else
        changed << humanize(field_id)
      end
    end

    res = []

    if !changed.empty?
      res << 'edited ' + changed.join(', ')
    end
    if !added.empty?
      res << 'added ' + added.join(', ')
    end
    if !deleted.empty?
      res << 'deleted ' + deleted.join(', ')
    end

    if res.empty?
      return nil
    end

    res = res.join(', ')
    res[0] = res[0].capitalize
    res
  end

  def self.update_client(client, user_id)
    changes = ClientChange.where('client_id' => client.id, 'type' => 'client').desc(:updated_at)
    last_change = changes.first
    attrs = client.finalize.serialize_references.to_hash
    if !last_change.nil? && last_change.user_id == user_id && Time.now - last_change.updated_at < SQUASH_TIME
      # Merge into previous if it's within a minute
      if last_change.description = get_change_description(attrs, changes.second && changes.second.client_data)
        last_change.client_data = attrs
        last_change.upsert
      else
        last_change.delete # Changes got reverted
      end
    else
      if desc = get_change_description(attrs, last_change && last_change.client_data)
        ClientChange.new(
          :user_id => user_id,
          :client_id => client.id,
          :type => 'client',
          :client_data => attrs,
          :description => desc,
        ).save
      end
    end
  end
end
