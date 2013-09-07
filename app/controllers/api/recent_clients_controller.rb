class Api::RecentClientsController < Api::ApiController
  # GET /recent_clients
  # GET /recent_clients.json
  def index
    @recent_clients = RecentClients.where(:user_id => @user.id)
    if @recent_clients.empty?
      @recent_clients = RecentClients.new(:user_id => @user.id, :clients => [])
      @recent_clients.save
      @recent_clients = [@recent_clients]
    else
      clean(@recent_clients.first)
    end

    respond_to do |format|
      format.json { render json: get_json(@recent_clients.to_a) }
    end
  end

  # GET /recent_clients/get
  def show
    @recent_clients = RecentClients.where(:user_id => @user.id).first
    if @recent_clients.nil?
      @recent_clients = RecentClients.new(:user_id => @user.id, :clients => [])
      @recent_clients.save
    else
      clean(@recent_clients)
    end

    respond_to do |format|
      format.json { render json: get_json(@recent_clients) }
    end
  end

  # POST /recent_clients/:id
  def create
    update
  end

  # PUT /recent_clients/:id
  def update
    @recent_clients = RecentClients.new(recent_client_params)
    @recent_clients.user_id = @user.id
    if existing = RecentClients.where(:user_id => @user.id).first
      existing.clients = merge_clients(existing.clients || [], @recent_clients.clients || [])
      @recent_clients = existing
    end

    respond_to do |format|
      if @recent_clients.save
        format.json { render json: get_json(@recent_clients) }
      else
        format.json { render json: @recent_clients.errors, status: :unprocessable_entity }
      end
    end
  end

  private
    # Never trust parameters from the scary internet, only allow the white list through.
    def recent_client_params
      params.permit(:clients => [[:id, :company_name, :timestamp]])
    end

    def clean(rc)
      clients = []
      rc.clients.each do |client|
        if !Client.where('id' => client['id']).empty?
          clients << client
        end
      end
      rc.clients = clients
      rc.save
    end

    def merge_clients(a, b)
      merged = a + b
      merged = merged.sort { |x, y|
        y['timestamp'] - x['timestamp']
      }

      limit = 10
      unique = []
      clientIds = {}
      # Prevent excessive timestamp spoofing
      cur_time = (Time.now.to_f * 1000).to_i
      merged.each do |client|
        if !clientIds[client['id']] && unique.length < limit &&
           !Client.where('id' => client['id']).empty?
          clientIds[client['id']] = true
          client['timestamp'] = [client['timestamp'], cur_time].min
          unique << client
        end
      end

      return unique
    end
end
