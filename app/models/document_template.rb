require 'ydocx/document'

class DocumentTemplate
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Paranoia

  has_many :documents
  has_many :document_template_sections

  field :name, type: String
  field :file, type: String
  field :file_timestamp, type: DateTime
  field :sections, type: Array

  def path
    Rails.root.join('lib', 'docx_templates', self.file)
  end

  def self.sync
    # Sync with the templates available in the directory.
    existing_files = {}
    Rails.root.join('lib', 'docx_templates').children.each do |f|
      filename = f.basename.to_s
      if filename.ends_with?('.docx') && !filename['$']
        name = f.basename('.docx').to_s
        existing_files[filename] = true
        templ = DocumentTemplate.unscoped.where('file' => filename).first
        if !templ
          templ = DocumentTemplate.new(:name => name.humanize.titleize, :file => filename)
        elsif templ.deleted_at
          templ.restore
        end
        ts = File.mtime(f)
        if templ.file_timestamp != ts
          templ.file_timestamp = ts
          templ.sections = YDocx::Document.list_sections(f).map do |section|
            {:id => section, :name => section.underscore.humanize.titleize}
          end
          templ.save
        end
      end
    end

    DocumentTemplate.all.each do |template|
      if !existing_files[template.file]
        template.delete
      end
    end
  end
end
