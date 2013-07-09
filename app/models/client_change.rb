class ClientChange
  include Mongoid::Document
  include Mongoid::Timestamps

  belongs_to :user
  belongs_to :client # for indexing purposes
  has_many :documents, dependent: :delete
  field :client_data, type: Hash
  field :description, type: String

  def self.get_change_description(new_client, old_client)
    if old_client.nil?
      return 'Created new client ' + new_client['name']['value']
    end

    # Get a list of changed fields
    changed_fields = []
    new_client.each do |key, val|
      if defined?(val['value'])
        if old_client[key] && val['value'] != old_client[key]['value'] ||
           old_client[key].nil?
          changed_fields << key
        end
      end
    end

    old_client.each do |key, val|
      if new_client[key].nil?
        changed_fields << key
      end
    end

    changed_fields = changed_fields.sort.map do |field_id|
      field_id.underscore.humanize.downcase
    end

    if changed_fields.empty?
      return nil
    end

    return 'Edited ' + changed_fields.join(', ')
  end

  def self.update_client(client, user_id)
    changes = ClientChange.where('client_id' => client.id).desc(:updated_at)
    last_change = changes.first
    if !last_change.nil? && last_change.user_id == user_id && Time.now - last_change.updated_at < 60
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
          :client_data => client.attributes,
          :description => desc,
        ).save
      end
    end
  end
end