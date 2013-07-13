require 'ydocx/document'
require 'tempfile'

class Api::DocumentsController < Api::ApiController
  before_action :set_document, only: [:edit, :destroy]

  respond_to :json

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
      @documents = @documents.where('client_id' => params[:client_id])
    end
    @documents = @documents.desc(:created_at)

    respond_to do |format|
      format.json { render json: @documents.map{ |d| get_json(d) } }
    end
  end

  def gen_document(client_change, name)
    data = {}
    client_change.client_data.each do |key, val|
      if val.is_a?(Hash) && !val['value'].nil?
        data[key] = val['value']
      end
    end

    if brokerage = Brokerage.all.first
      data['brokerOffice'] = brokerage.office
      data['brokerMarketer'] = brokerage.marketer
      data['brokerProducer'] = brokerage.producer
    end

    fields = Client::FIELDS
    fields << {:id => 'brokerOffice', :type => 'text'}
    fields << {:id => 'brokerMarketer', :type => 'text'}
    fields << {:id => 'brokerProducer', :type => 'text'}

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
