require 'ydocx/document'
require 'tempfile'
require 'andand'

class Document
  include Mongoid::Document
  include Mongoid::Timestamps

  belongs_to :user
  belongs_to :client # for indexing
  belongs_to :client_change
  belongs_to :document_template
  field :description, type: String

  FIELDS = []

  def unwrap(data, fields)
    if data.is_a?(Hash) && data['value']
      return unwrap(data['value'], fields)
    elsif fields.is_a?(Hash) && fields.andand[:type] == 'file'
      f = FileAttachment.where(:id => data).first
      return {
        'name' => f.name,
        'mime_type' => f.mime_type,
        'data' => f.data.to_s,
      }
    elsif data.is_a?(Hash)
      field_map = {}
      if fields.andand.is_a?(Array)
        fields.each do |field|
          field_map[field[:id]] = field
        end
      end
      data.each do |k, v|
        data[k] = unwrap(v, field_map.andand[k])
      end
    elsif data.is_a?(Array)
      return data.map { |d| unwrap(d, fields.andand[:type]) }
    end

    return data
  end

  def abbreviate(str)
    return str && str.split.map { |c| c[0].upcase }.join
  end

  def generate(options = {})
    fields = Client.expand_fields_with_references.dup
    data = unwrap(self.client_change.client_data, fields)

    if brokerage = client.brokerage
      brokerage = brokerage.serialize_references.to_hash
      brokerage_users = brokerage['users'].andand.select { |u|
        u['appear_on_documents'].andand['yes']
      }

      broker_data = {
        'company_short' => abbreviate(data['company_name']),
        'brokerage_short' => abbreviate(brokerage['name']),
        'brokerage_users' => brokerage_users,
        'brokerage' => brokerage,
      }

      data = data.merge(broker_data)
    end

    ydocx_opts = {}
    if options[:section]
      ydocx_opts[:extract_section] = options[:section]
    else
      # Mongoid doesn't have a built in group_by. This is close enough.
      # (map groups by section, reduce selects the latest from each set)

      map = %Q{
        function() {
          emit(this.name, this);
        }
      }

      reduce = %Q{
        function(key, values) {
          var max_time = 0, ret = null;
          values.forEach(function(value) {
            if (value.created_at > max_time) {
              max_time = value.created_at
              ret = value;
            }
          });
          return ret;
        }
      }

      if DocumentTemplateSection.exists?
        sections = DocumentTemplateSection.where({
          :client => self.client_change.client,
          :document_template => self.document_template,
        }).map_reduce(map, reduce).out(inline: true)
      else
        sections = []
      end

      ydocx_opts[:replace_sections] = {}
      sections.each do |section|
        section = section['value']
        tmpfile = Tempfile.new(section['name'])
        File.binwrite(tmpfile.path, section['data'])
        ydocx_opts[:replace_sections][section['name']] = YDocx::Document.extract_document(tmpfile.path)
      end
    end

    tmpfile = Tempfile.new(self.client_change.id.to_s)
    YDocx::Document.fill_template(self.document_template.path, data, fields, tmpfile.path, ydocx_opts)

    File.binread(tmpfile.path)
  end
end
