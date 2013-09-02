class Api::DocumentsController < Api::ApiController
  before_action :set_document, only: [:destroy]
  render_related_fields :user => [:email]

  # GET /documents
  # GET /documents.json
  def index
    @documents = Document.all
    if params[:client_id]
      authorize! :read, Client.find(params[:client_id])
      @documents = @documents.where('client_id' => params[:client_id])
    end
    @documents = @documents.desc(:created_at)
    @documents = current_ability.select(@documents)

    respond_to do |format|
      format.json { render json: get_json(@documents) }
    end
  end

  # GET /documents/1
  # GET /documents/1.json
  def show
    @document = Document.where(:id => params[:id]).first
    if @document.nil?
      head :gone
      return
    end

    authorize! :read, @document

    send_data @document.generate, :filename => @document.description + '.docx'
  end

  # GET /documents/client/:id
  def client
    @client = Client.find(params[:id])
    authorize! :read, @client
    authorize! :read, Document

    last_change = ClientChange.where('client_id' => @client.id, 'type' => 'client').desc(:updated_at).first
    if last_change.nil?
      render json: '', status: :not_found
      return
    end

    DocumentTemplate.sync
    template = DocumentTemplate.where(:file => params[:template] || 'default.docx').first
    if template.nil?
      head :bad_request
      return
    end

    doc = Document.new({
      :client_change_id => last_change.id,
      :description => @client.companyName['value'],
      :document_template_id => template.id,
    })

    options = {}
    filename = doc.description + '.docx'
    if params[:version]
      existing = DocumentTemplateSection.find(params[:version])
      if existing
        filename = existing.name.underscore.humanize + ' for ' + doc.description + '.docx'
        send_data existing.data.to_s, :filename => filename
        return
      end
    elsif params[:section]
      section = template.sections

      options[:section] = params[:section]
      filename = (params[:section] ? params[:section].underscore.humanize + ' for ' : '') + doc.description + '.docx'

      # Send the existing replacement section if one already exists.
      if !params[:original]
        existing = DocumentTemplateSection.where({
          :client => @client,
          :document_template_id => template.id,
          :name => params[:section],
        }).desc(:created_at).first

        if existing
          send_data existing.data.to_s, :filename => filename
          return
        end
      end
    end

    send_data doc.generate(options), :filename => filename
  end

  # PUT /documents/:id
  # PUT /documents/:id.json
  # Creates if a non-existent ID is provided.
  def update
    authorize! :manage, Document

    if params[:id]
      @document = Document.find(params[:id])
      success = @document.update_attributes(document_params)
    else
      @document = Document.new(document_params)
      @templates = get_templates
      @document.template = @templates.find { |t| t[:name] == @document.template }[:file]
      @document.user_id = @user.id
      if change = ClientChange.find(params[:client_change_id])
        @document.client_id = change.client_id
        @document.client_change_id = change.id
        success = @document.save!
      else
        success = false
      end
    end

    respond_to do |format|
      if success
        format.json { render json: get_json(@document) }
      else
        format.json { render json: @document.errors, status: :unprocessable_entity }
      end
    end
  end

  def get_templates
    template_path = Rails.root.join('lib', 'docx_templates')
    Dir.glob("#{template_path}/*.docx").map do |f|
      name = File.basename(f, '.docx')
      {:name => name.humanize.titleize, :file => File.basename(f)}
    end
  end

  # GET /documents/templates/:client_id
  def templates
    client = Client.find(params[:client_id])
    authorize! :manage, client
    authorize! :read, Document

    DocumentTemplate.sync
    templates = DocumentTemplate.all.to_a
    templates.each do |template|
      template.sections.each do |section|
        update = DocumentTemplateSection.where({
          :client => client,
          :document_template_id => template.id,
          :name => section['id']
        }).desc(:updated_at).first

        if update
          section['updated_at'] = update.created_at.to_i
          section['updated_by'] = update.user.email
        end
      end
    end
    render json: get_json(templates)
  end

  # POST /documents/templates/:client_id
  def upload_template
    client = Client.find(params[:client_id])
    authorize! :manage, client
    authorize! :create, Document

    template = DocumentTemplate.where(:file => params[:template]).first
    if template.nil?
      head :bad_request
    end

    section = params[:section]
    if template.sections.find { |t| t['id'] == section }.nil?
      head :bad_request
    end

    data = params[:data]

    # data is in data-uri format; format is roughly
    #   data:application/data-type;charset....,<base 64 encoded data>
    data = data.split(',')[1]
    if data.nil? || (data = Base64.decode64(data)).empty?
      head :unprocessable_entity
    end

    prev_templ = DocumentTemplateSection.where({
      :client => client,
      :document_template_id => template.id,
      :name => section
    }).desc(:created_at).first

    templ = DocumentTemplateSection.new({
      :client => client,
      :user => @user,
      :document_template_id => template.id,
      :name => section,
      :data => Moped::BSON::Binary.new(:generic, data),
    })
    templ.save!

    ClientChange.new({
      :client => client,
      :user => @user,
      :type => 'template',
      :new_section => templ,
      :old_section => prev_templ,
      :description => "Edited #{template.name.downcase} template",
    }).save!

    head :no_content
  end

  # DELETE /documents/1
  # DELETE /documents/1.json
  def destroy
    authorize! :delete, @document
    @document.destroy
    head :no_content
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_document
      @document = Document.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def document_params
      params.permit(:description, :template)
    end
end
