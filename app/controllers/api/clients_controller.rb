class Api::ClientsController < Api::ApiController
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

  def valid_value(val)
    return val.is_a?(Hash) && val['updated_at']
  end

  # GET /clients
  # GET /clients.json
  def index
    @clients = Client.any_of(
      {"company.value" => /#{Regexp.escape(params[:query] || '')}/i},
      {"name.value" => /#{Regexp.escape(params[:query] || '')}/i},
      {"emailAddress.value" => /#{Regexp.escape(params[:query] || '')}/i},
    )

    if params[:filter]
      filter = JSON.parse(params[:filter])
      select = {}
      filter.each do |key, val|
        if !val.empty?
          select[key + '.value'] = /#{Regexp.escape(val)}/i
        end
      end
      @clients = @clients.where(select)
    end

    if params[:short]
      @clients = @clients.only(:id, :company, :name, :updated_at, :created_at)
    end

    if order_by = params[:order_by]
      @clients = @clients.to_a.sort do |a, b|
        a_val = a[order_by]
        b_val = b[order_by]
        a_val = (a_val.is_a?(Hash) && a_val['value']) || a_val
        b_val = (b_val.is_a?(Hash) && b_val['value']) || b_val
        ret = a_val.to_s.downcase <=> b_val.to_s.downcase
        if params[:desc] == 'true'
          ret = -ret
        end
        ret
      end
      @clients = @clients[params[:start].to_i || 0, params[:limit].to_i || @clients.length] || []
    else
      @clients = @clients.skip(params[:start] || 0).limit(params[:limit] || 0)
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

  # POST /clients/:id
  def create
     @client = Client.new(client_params)

    # Don't allow client timestamps to exceed the server time
    # (otherwise client can provide an arbitrarily large one to prevent future editing)
    cur_time = (Time.now.to_f * 1000).to_i

    if existing = Client.where(:id => params[:id]).first
      render json: '', status: :conflict
      return
    else
      @client._id = params[:id]
      @client.attributes.each do |key, val|
        if valid_value(val)
          val['updated_at'] = [val['updated_at'], cur_time].min
        end
      end
    end

    respond_to do |format|
      if @client.save
        ClientChange.update_client(@client, @user.id)
        format.json { render json: get_json(@client) }
      else
        format.json { render json: @client.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /clients/:id
  # PUT /clients/:id.json
  def update
    @client = Client.new(client_params)

    # Don't allow client timestamps to exceed the server time
    # (otherwise client can provide an arbitrarily large one to prevent future editing)
    cur_time = (Time.now.to_f * 1000).to_i

    if existing = Client.where(:id => params[:id]).first
      # Sync all fields
      @client.attributes.each do |key, val|
        if valid_value(val) &&
           (!valid_value(existing[key]) || val['updated_at'] > existing[key]['updated_at'])
          existing[key] = val
          existing[key]['updated_at'] = [val['updated_at'], cur_time].min
        end
      end
      @client = existing
    else
      # Must have been deleted by someone else.
      render json: '', status: :gone
      return
    end

    respond_to do |format|
      if @client.save
        # Create a new client change if necessary.
        ClientChange.update_client(@client, @user.id)
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
    render json: ''
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_client
      @client = Client.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def client_params
      params.permit(generate_permit_params(Client::FIELDS))
    end
end
