class ClientsController < ApplicationController
  before_action :set_client, only: [:edit, :destroy]

  respond_to :json

  def get_json(obj)
    ret = {}
    obj.attributes.each do |key, val|
      if key == "_id"
        ret[:id] = val.to_s
      else
        ret[key] = val
      end
    end
    ret
  end

  # GET /clients
  # GET /clients.json
  def index
    sleep(2)
    @clients = Client.any_of(
      {"name.value" => /#{Regexp.escape(params[:query] || '')}/},
      {"company.value" => /#{Regexp.escape(params[:query] || '')}/},
      {"email.value" => /#{Regexp.escape(params[:query] || '')}/},
    ).skip(params[:start] || 0).limit(params[:limit] || 0)

    if params[:short]
      @clients.only(:id, :name, :company)
    end

    respond_to do |format|
      format.json { render json: @clients.map{ |c| get_json(c) } }
    end
  end

  # GET /clients/1
  # GET /clients/1.json
  def show
    @client = Client.where(:id => params[:id]).first
    if @client.nil?
      render json: '', status: :gone
      return
    end

    respond_to do |format|
      format.json { render json: get_json(@client) }
    end
  end

  # GET /clients/new
  def new
    @client = Client.new
  end

  # GET /clients/1/edit
  def edit
  end

  # PUT /clients/:id
  # PUT /clients/:id.json
  # Creates if a non-existent ID is provided.
  def update
    @client = Client.new(client_params)

    # If an ID is provided, try looking it up first
    if existing = Client.where(:id => params[:id]).first
      @client._id = existing._id
      # Sync all fields
      existing.attributes.each do |key, val|
        if defined?(val['updated_at']) &&
           (!defined?(@client[key]['updated_at']) || val['updated_at'] > @client[key]['updated_at'])
          @client[key] = val
        end
      end
    elsif !params[:id].starts_with?('local')
      # Must have been deleted by someone else.
      render json: '', status: :gone
      return
    end

    respond_to do |format|
      if @client.upsert
        format.json { render json: get_json(@client) }
      else
        format.json { render json: @client.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /clients/1
  # DELETE /clients/1.json
  def destroy
    @client.destroy
    respond_with head :no_content
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_client
      @client = Client.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def client_params
      params.permit(:name => [:value, :updated_at])
    end
end
