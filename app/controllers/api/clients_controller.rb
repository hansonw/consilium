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

  # GET /clients
  # GET /clients.json
  def index
    @clients = Client.any_of(
      {"name.value" => /#{Regexp.escape(params[:query] || '')}/i},
      {"company.value" => /#{Regexp.escape(params[:query] || '')}/i},
      {"email.value" => /#{Regexp.escape(params[:query] || '')}/i},
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

    @clients = @clients.skip(params[:start] || 0).limit(params[:limit] || 0).asc("name.value")

    if params[:short]
      @clients = @clients.only(:id, :name, :company)
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

  def get_description(new_client, old_client)
    if old_client.nil?
      return 'Created new client'
    end

    # Get a list of changed fields
    changed_fields = []
    new_client.each do |key, val|
      if defined?(val['value'])
        if old_client[key] && val['value'] != old_client[key]['value'] ||
           old_client[key].nil?
          changed_fields << key
        end
      end
    end

    old_client.each do |key, val|
      if new_client[key].nil?
        changed_fields << key
      end
    end

    changed_fields = changed_fields.sort.map do |field_id|
      field = Client::FIELDS.select { |field| field[:id] == field_id }.first
      field && field[:name].downcase
    end

    if changed_fields.empty?
      return nil
    end

    num_fields = 3
    return 'Edited ' + changed_fields[0, num_fields].join(', ') +
        (changed_fields.length > num_fields ? '...' : '')
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
      if @client.save
        # Create a new client change if necessary.
        changes = ClientChange.where('client_id' => @client.id).desc(:updated_at)
        last_change = changes.first
        if !last_change.nil? && last_change.user_id == @user.id && Time.now - last_change.updated_at < 60
          # Merge into previous if it's within a minute
          if last_change.description = get_description(@client.attributes, changes.second && changes.second.client_data)
            last_change.client_data = @client.attributes
            last_change.save
          else
            last_change.delete # Changes got reverted
          end
        else
          if desc = get_description(@client.attributes, last_change && last_change.client_data)
            ClientChange.new(
              :user_id => @user.id,
              :client_id => @client.id,
              :client_data => @client.attributes,
              :description => desc,
            ).save
          end
        end
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
      permitted = {}
      Client::FIELDS.each do |field|
        if field[:type].is_a? Array
          if field[:id].ends_with? 's'
            permitted[field[:id]] = [:updated_at]
            values = [field[:type].map { |sf|
              if sf[:type] == 'checkbox'
                {sf[:id] => sf[:options].keys}
              else
                sf[:id]
              end
            }]
            permitted[field[:id]] << {:value => values}
          else
            field[:type].each do |subsection_field|
              permitted[subsection_field[:id]] = [:updated_at,
                if subsection_field[:type] == 'checkbox'
                  {:value => subsection_field[:options].keys}
                else
                  :value
                end
              ]
            end
          end
        else
          permitted[field[:id]] = [:updated_at, :value]
        end
      end
      params.permit(permitted)
    end

end
