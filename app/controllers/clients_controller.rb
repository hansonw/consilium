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
    @clients = Client.any_of(
      {"name.value" => /#{Regexp.escape(params[:query] || '')}/i},
      {"company.value" => /#{Regexp.escape(params[:query] || '')}/i},
      {"email.value" => /#{Regexp.escape(params[:query] || '')}/i},
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
    
    # Don't allow client timestamps to exceed the server time
    # (otherwise client can provide an arbitrarily large one to prevent future editing)
    cur_time = (Time.now.to_f * 1000).to_i

    # If an ID is provided, try looking it up first    
    if existing = Client.where(:id => params[:id]).first
      # Sync all fields
      @client.attributes.each do |key, val|
        if defined?(val['updated_at']) &&
           (!defined?(existing[key]['updated_at']) || val['updated_at'] > existing[key]['updated_at'])
          existing[key] = val
          existing[key]['updated_at'] = [val['updated_at'], cur_time].min
        end
      end
      @client = existing
    elsif !params[:id].starts_with?('local')
      # Must have been deleted by someone else.
      render json: '', status: :gone
      return
    else
      @client.attributes.each do |key, val|
        if defined?(val['updated_at'])
          val['updated_at'] = [val['updated_at'], cur_time].min
        end
      end
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
      permitted = {}
      Client::FIELDS.each do |field|
        permitted[field[:id]] = [:updated_at]
        if field[:type].is_a? Array
          values = [field[:type].map { |sf| sf[:id] }]
          permitted[field[:id]] << {:value => values}
        else
          permitted[field[:id]] << :value
        end
      end
      params.permit(permitted)
    end
end
