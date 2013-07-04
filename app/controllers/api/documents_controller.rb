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
        ret[:user_email] = obj.user.email
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
      @documents = @documents.where('client_id' => Moped::BSON::ObjectId(params[:client_id]))
    end
    @documents = @documents.desc(:created_at)

    respond_to do |format|
      format.json { render json: @documents.map{ |d| get_json(d) } }
    end
  end

  # GET /documents/1
  # GET /documents/1.json
  def show
    @document = Document.where(:id => params[:id]).first
    if @document.nil?
      render json: '', status: :gone
      return
    end

    data = {}
    @document.client_change.client_data.attributes.each do |key, val|
      if val.is_a?(Hash) && !val['value'].nil?
        data[key] = val['value']
      end
    end

    tmpfile = Tempfile.new(@document.id.to_s)
    template_path = Rails.root.join('lib', 'docx_templates', 'default.docx')
    YDocx::Document.fill_template(template_path, data, tmpfile.path)

    send_data(File.binread(tmpfile.path), :filename => @document.description + '.docx')
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
