require 'ydocx/document'
require 'tempfile'

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

  def gen_document(client_change, name, options = {})
    data = unwrap(client_change.client_data)

    fields = Client::FIELDS.dup

    if brokerage = Brokerage.all.first
      broker_data = {
        'companyShort' => abbreviate(data['company']),
        'brokerOffice' => brokerage.name,
        'brokerOfficeShort' => abbreviate(brokerage.name),
        'brokerAddress' => brokerage.address,
        'brokerWebsite' => brokerage.website,
        'brokerPhone' => brokerage.phone,
        'brokerFax' => brokerage.fax,
        'brokerContacts' => brokerage.contacts,
        'primaryBroker' => brokerage.contacts.first && brokerage.contacts.first['name'],
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
          emit(this.section, this);
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

      sections = DocumentTemplate.where({
        :client => client_change.client,
        :template => options[:template],
      }).map_reduce(map, reduce).out(inline: true)

      ydocx_opts[:replace_sections] = {}
      sections.each do |section|
        section = section['value']
        tmpfile = Tempfile.new(section['section'])
        File.binwrite(tmpfile.path, section['data'])
        ydocx_opts[:replace_sections][section['section']] = YDocx::Document.extract_document(tmpfile.path)
      end
    end

    tmpfile = Tempfile.new(client_change.id.to_s)
    template_path = Rails.root.join('lib', 'docx_templates', options[:template] || 'default.docx')
    YDocx::Document.fill_template(template_path, data, fields, tmpfile.path, ydocx_opts)

    send_data File.binread(tmpfile.path), :filename => options[:filename] || (name + '.docx')
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

    gen_document @document.client_change, @document.description, :template => @document.template
  end

  # GET /documents/client/:id
  def client
    @client = Client.find(params[:id])
    authorize! :read, @client
    authorize! :read, Document

    last_change = ClientChange.where('client_id' => @client.id).desc(:updated_at).first
    if last_change.nil?
      render json: '', status: :not_found
      return
    end

    options = {}
    if params[:template]
      if template = get_templates.find { |t| t[:file] == params[:template] }
        options[:template] = params[:template]
        options[:section] = params[:section]
        options[:filename] = (params[:section] ? params[:section].underscore.humanize + ' for ' : '') + @client.company['value'] + '.docx'

        # Send the existing replacement section if one already exists.
        if !params[:original] && params[:section]
          existing = DocumentTemplate.where({
            :client_id => @client.id,
            :template => template[:file],
            :section => params[:section],
          }).desc(:created_at).first

          if existing
            send_data existing.data.to_s, :filename => options[:filename]
            return
          end
        end
      end
    end

    gen_document last_change, @client.company['value'], options
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
    authorize! :read, Document
    templates = get_templates
    templates.each do |template|
      # TODO: actually retrieve from the document
      if template[:file] == 'solar_proposal.docx'
        template[:sections] = [
          {:id => 'executiveSummary', :name => 'Executive Summary'},
          {:id => 'terms', :name => 'General Terms'},
          {:id => 'servicePlan', :name => 'Broker Service Plan'},
          {:id => 'claimsManagement', :name => 'Claims Management'},
        ]
      else
        template[:sections] = []
      end

      template[:sections].each do |section|
        update = DocumentTemplate.where({
          :client_id => params[:client_id],
          :template => template[:file],
          :section => section[:id]
        }).desc(:updated_at).first

        if update
          section[:updated_at] = update.created_at.to_i
          section[:updated_by] = update.user.email
        end
      end
    end
    render json: templates
  end

  # POST /documents/templates/:client_id
  def upload_template
    client = Client.find(params[:client_id])
    authorize! :manage, client
    authorize! :create, Document

    template = params[:template]
    section = params[:section]
    data = params[:data]

    template = get_templates.find { |t| t[:file] == template }
    if template.nil?
      head :bad_request
    end

    # data is in data-uri format; format is roughly
    #   data:application/data-type;charset....,<base 64 encoded data>
    data = data.split(',')[1]
    if data.nil? || (data = Base64.decode64(data)).empty?
      head :unprocessable_entity
    end

    templ = DocumentTemplate.new({
      :client => client,
      :user => @user,
      :template => template[:file],
      :section => section,
      :data => Moped::BSON::Binary.new(:generic, data),
    })

    templ.save!
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
