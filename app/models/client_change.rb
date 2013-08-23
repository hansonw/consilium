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
    if old_arr.is_a?(Array)
      old_ids = Hash[old_arr.map { |x| [x['id'], x] }]
    end

    result = new_arr.map do |val|
      old_val = old_ids[val['id']]
      if val != old_val
        ch = get_changed_fields(val, old_val, fields)
        ch.empty? ? nil : ch
      else
        nil
      end
    end

    if result.compact.empty? && new_arr.length == old_arr.length
      return nil
    else
      return result
    end
  end

  def self.hash_diff(new_hash, old_hash)
    d = new_hash.diff(old_hash)
    Hash[d.keys.map { |k| [k, true] }]
  end

  def self.value_diff(new_val, old_val, field)
    val = new_val || old_val
    if val.is_a?(Array)
      collection_diff(new_val || [], old_val || [], field.andand[:type])
    elsif val.is_a?(Hash)
      hash_diff(new_val || {}, old_val || {})
    else
      type = field.andand[:type]
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

    new_client.each do |key, val|
      if val.is_a?(Hash) && val['value']
        old_val = old_client.andand[key].andand['value']
        if !value_equals(val['value'], old_val)
          changed_fields[key] = value_diff(val['value'], old_val, field_map[key])
        end
      end
    end

    unless old_client.nil?
      old_client.each do |key, val|
        new_val = new_client.andand[key]
        if !new_val.is_a?(Hash) || !new_val['value']
          if val.is_a?(Hash) && val['value']
            changed_fields[key] = value_diff(nil, val['value'], field_map[key])
          end
        end
      end
    end

    changed_fields.keep_if { |k, v| v }
  end

  def self.get_change_description(new_client, old_client)
    if old_client.nil?
      return 'Created new client ' + new_client['company']['value']
    end

    changed_fields = get_changed_fields(new_client, old_client)
    changed_fields = changed_fields.keys.sort.map do |field_id|
      field_id.underscore.humanize.downcase
    end

    if changed_fields.empty?
      return nil
    end

    return 'Edited ' + changed_fields.join(', ')
  end

  def self.update_client(client, user_id)
    changes = ClientChange.where('client_id' => client.id, 'type' => 'client').desc(:updated_at)
    last_change = changes.first
    if !last_change.nil? && last_change.user_id == user_id && Time.now - last_change.updated_at < SQUASH_TIME
      # Merge into previous if it's within a minute
      if last_change.description = get_change_description(client.attributes, changes.second && changes.second.client_data)
        last_change.client_data = client.attributes
        last_change.save
      else
        last_change.delete # Changes got reverted
      end
    else
      if desc = get_change_description(client.attributes, last_change && last_change.client_data)
        ClientChange.new(
          :user_id => user_id,
          :client_id => client.id,
          :type => 'client',
          :client_data => client.attributes,
          :description => desc,
        ).save
      end
    end
  end
end
