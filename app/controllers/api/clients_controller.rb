class Api::ClientsController < Api::ApiController
  load_and_authorize_resource :only => [:destroy]

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

    if params[:last_synced]
      @clients = @clients.where("this.updated_at > #{params[:last_synced].to_i * 1000}")
    else
      @clients = @clients.where('deleted' => nil)
    end

    if params[:short]
      @clients = @clients.only(:id, :brokerage_id, :company, :name, :updated_at, :created_at)
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

    @clients = current_ability.select(@clients)

    respond_to do |format|
      format.json { render json: get_json(@clients) }
    end
  end

  # GET /clients/1
  # GET /clients/1.json
  def show
    @client = Client.where(:id => params[:id], 'deleted' => nil).first
    if @client.nil?
      render json: '', status: :gone
      return
    end

    authorize! :read, @client

    respond_to do |format|
      format.json { render json: get_json(@client) }
    end
  end

  # POST /clients/:id
  def create
    authorize! :create, Client
    @client = Client.new(client_params)

    if existing = Client.where(:id => params[:id]).first
      render json: '', status: :conflict
      return
    else
      @client._id = params[:id]
      fix_timestamps(@client.attributes)
    end

    @client.brokerage = current_user.brokerage

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

    if existing = Client.where(:id => params[:id], 'deleted' => nil).first
      # Sync all fields
      authorize! :update, existing
      result = existing.attributes
      sync_fields(result, @client.attributes, params[:last_synced].to_i)
      @client.assign_attributes(result)
    else
      # Must have been deleted by someone else.
      render json: '', status: :gone
      return
    end

    respond_to do |format|
      if @client.upsert
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
    # Destroy dependencies
    @client.destroy
    render json: ''
  end

  private
    # Never trust parameters from the scary internet, only allow the white list through.
    def client_params
      params.permit Client.generate_permit_params_wrapped
    end

    def valid_value(val)
      return val.is_a?(Hash) && val['updated_at']
    end

    def fix_timestamps(data, mark_new = false)
      if data.is_a?(Hash)
        # Don't allow client timestamps to exceed the server time
        # (otherwise client can provide an arbitrarily large one to prevent future editing)
        cur_time = Time.now.to_i

        if data['updated_at']
          data['updated_at'] = mark_new ? cur_time : [cur_time, data['updated_at'].to_i].min
        end
        if data['created_at']
          data['created_at'] = mark_new ? cur_time : [cur_time, data['created_at'].to_i, data['updated_at'] || 1e99].min
        end
        if data['value']
          fix_timestamps(data['value'])
        end
      elsif data.is_a?(Array)
        data.each do |v|
          fix_timestamps(v)
        end
      end

      return data
    end

    def sync_collection(dst, new_data, last_synced)
      updated = false

      destMap = Hash[ dst.map { |m| [m['id'], m] } ]
      newMap = Hash[ new_data.map { |m| [m['id'], m] } ]

      result = []

      dst.each do |val|
        if !newMap[val['id']] && val['created_at'].to_i > last_synced
          result << val
        else
          updated = true
        end
      end

      new_data.each do |val|
        if !destMap[val['id']] && val['created_at'].to_i < last_synced
          # deleted on server
        elsif destMap[val['id']]
          updated |= sync_fields(destMap[val['id']], val, last_synced)
          result << destMap[val['id']]
        else
          result << fix_timestamps(val, true)
          updated = true
        end
      end

      result.sort! { |x, y| x['id'] <=> y['id'] }
      dst.replace(result)

      return updated
    end

    def sync_fields(dst, new_data, last_synced)
      # Use server timestamps for everything
      cur_time = Time.now.to_i
      updated = false

      new_data.each do |key, val|
        if valid_value(val)
          val_updated = true
          if !valid_value(dst[key])
            dst[key] = fix_timestamps(val, true)
          elsif dst[key]['value'].is_a?(Array) && val['value'].is_a?(Array) &&
                val['value'].first && val['value'].first['id']
            val_updated = sync_collection(dst[key]['value'], val['value'], last_synced)
          elsif val['updated_at'].to_i > dst[key]['updated_at'].to_i
            dst[key] = fix_timestamps(val)
          else
            val_updated = false
          end

          if val_updated
            dst[key]['updated_at'] = cur_time
            dst[key]['created_at'] ||= cur_time
            updated = true
          end
        end
      end

      if updated
        dst['updated_at'] = cur_time
        dst['created_at'] ||= cur_time
      end
    end
end
