class ClientsController < ApplicationController
  before_action :set_client, only: [:show, :edit, :destroy]

  respond_to :json

  # GET /clients
  # GET /clients.json
  def index
    @clients = Client.all
  end

  # GET /clients/1
  # GET /clients/1.json
  def show
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
    end
    @client.updated_at = (Time.now.to_f * 1000).to_i

    respond_to do |format|
      if @client.upsert
        format.json { render action: 'show', location: @client }
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
      params[:client].permit(:name)
    end
end
