require 'ydocx/document'
require 'tempfile'

class Api::ClientChangesController < Api::ApiController
  before_action :set_client_change, only: [:edit, :destroy]

  respond_to :json

  def get_json(obj)
    ret = {}
    obj.attributes.each do |key, val|
      if key == "_id"
        ret[:id] = val.to_s
      elsif key == "user_id"
        ret[:user_id] = val.to_s
        ret[:user_email] = obj.user.email
      elsif key == "client_id"
        ret[:client_id] = val.to_s
        ret[:client_name] = obj.client.name['value']
      elsif key == "created_at"
        # convert to milliseconds, Javascript's default format
        ret[key] = (val.to_f * 1000).to_i
      else
        ret[key] = val
      end
    end
    ret
  end

  # GET /client_changes
  # GET /client_changes.json
  def index
    @client_changes = ClientChange.all
    if params[:client_id]
      @client_changes = @client_changes.where('client_id' => params[:client_id])
    end
    @client_changes = @client_changes.desc(:created_at)

    if params[:short]
      @client_changes = @client_changes.only(:id, :user, :client, :description, :updated_at)
    end

    respond_to do |format|
      format.json { render json: @client_changes.map{ |d| get_json(d) } }
    end
  end

  # GET /client_changes/1
  # GET /client_changes/1.json
  def show
    @client_change = ClientChange.where(:id => params[:id]).first
    if @client_change.nil?
      render json: '', status: :gone
      return
    end

    respond_to do |format|
      format.json { render json: get_json(@client_change) }
    end
  end

  # DELETE /client_changes/1
  # DELETE /client_changes/1.json
  def destroy
    @client_change.destroy
    render json: ''
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_client_change
      @client_change = ClientChange.find(params[:id])
    end
end
