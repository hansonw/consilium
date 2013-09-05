require 'ydocx/document'
require 'tempfile'

class Document
  include Mongoid::Document
  include Mongoid::Timestamps

  belongs_to :user
  belongs_to :client # for indexing
  belongs_to :client_change
  belongs_to :document_template
  field :description, type: String

  FIELDS = []

  def unwrap(data)
    if data.is_a?(Hash)
      if data['value']
        return unwrap(data['value'])
      else
        data.each do |k, v|
          data[k] = unwrap(v)
        end
      end
    elsif data.is_a?(Array)
      return data.map { |d| unwrap(d) }
    end

    return data
  end

  def abbreviate(str)
    return str.split.map { |c| c[0].upcase }.join
  end

  def generate(options = {})
    data = unwrap(self.client_change.client_data)

    fields = Client::FIELDS.dup

    if brokerage = Brokerage.all.first
      broker_data = {
        'companyShort' => abbreviate(data['companyName']),
        'brokerageShort' => abbreviate(brokerage.name),
        'brokerage' => brokerage.as_document,
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
