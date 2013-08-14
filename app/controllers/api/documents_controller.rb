require 'ydocx/document'
require 'tempfile'

class Api::DocumentsController < Api::ApiController
  before_action :set_document, only: [:destroy]

  def get_json(obj)
    ret = {}
    obj.attributes.each do |key, val|
      if key == "_id"
        ret[:id] = val.to_s
      elsif key == "user_id"
        ret[:user_id] = val.to_s
        ret[:user_email] = obj.user ? obj.user.email : 'deleted'
      elsif key == "client_change_id"
        ret[:client_change_id] = val.to_s
      elsif key == "created_at"
        # convert to milliseconds, Javascript's default format
        ret[key] = (val.to_f * 1000).to_i
      else
        ret[key] = val
      end
    end
    ret
  end

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
      format.json { render json: @documents.map{ |d| get_json(d) } }
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

  def gen_document(client_change, name)
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

    tmpfile = Tempfile.new(client_change.id.to_s)
    template_path = Rails.root.join('lib', 'docx_templates', 'default.docx')
    YDocx::Document.fill_template(template_path, data, fields, tmpfile.path)

    send_data(File.binread(tmpfile.path), :filename => name + '.docx')
  end

  # GET /documents/1
  # GET /documents/1.json
  def show
    @document = Document.where(:id => params[:id]).first
    if @document.nil?
      render json: '', status: :gone
      return
    end

    authorize! :read, @document

    gen_document(@document.client_change, @document.description)
  end

  # GET /documents/client/:id
  def client
    @client = Client.find(params[:id])
    last_change = ClientChange.where('client_id' => @client.id).desc(:updated_at).first
    if last_change.nil?
      render json: '', status: :not_found
      return
    end

    gen_document(last_change, @client.company['value'])
  end

  # PUT /documents/:id
  # PUT /documents/:id.json
  # Creates if a non-existent ID is provided.
  def update
    if params[:id]
      @document = Document.find(params[:id])
      success = @document.update_attributes(document_params)
    else
      @document = Document.new(document_params)
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

  # DELETE /documents/1
  # DELETE /documents/1.json
  def destroy
    authorize! :delete, @document
    @document.destroy
    render json: ''
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_document
      @document = Document.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def document_params
      params.permit(:description)
    end
end
