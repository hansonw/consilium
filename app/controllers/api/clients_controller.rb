class Api::ClientsController < Api::ApiController
  load_and_authorize_resource :only => [:destroy]

  # GET /clients
  # GET /clients.json
  def index
    if params[:last_synced]
      @clients = Client.unscoped.where(
        "this.updated_at > #{params[:last_synced].to_i * 1000} || " +
        "this.deleted_at > #{params[:last_synced].to_i * 1000}",
      )
    else
      @clients = Client.all
    end

    @clients = @clients.any_of(
      {"company_name.value" => /#{Regexp.escape(params[:query] || '')}/i},
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
      @clients = @clients.only(:id, :brokerage_id, :company_name, :updated_at, :created_at)
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

    @clients.map! { |client| client = client.serialize_references(true) }
    render json: get_json(@clients)
  end

  # GET /clients/1
  # GET /clients/1.json
  def show
    @client = Client.where(:id => params[:id]).first
    if @client.nil?
      render json: '', status: :gone
      return
    end

    authorize! :read, @client

    render json: get_json(@client.serialize_references(true))
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
      @client.editing_time = params[:client][:editing_time].to_i
      # There's no way it takes more than 1 second per byte to enter.
      limit = @client.to_json.length
      if @client.editing_time > limit
        @client.editing_time = limit
      end
      fix_timestamps(@client.attributes)
    end

    @client.brokerage = current_user.brokerage

    filtered_params = @client.update_references(client_params, true)
    if !filtered_params[:errors].empty?
      render json: filtered_params[:errors], status: :unprocessable_entity
      return
    end
    @client.update(filtered_params[:params])

    if @client.save
      ClientChange.update_client(@client, @user.id)
      render json: get_json(@client.serialize_references(true))
    else
      render json: @client.errors, status: :unprocessable_entity
    end
  end

  # PUT /clients/:id
  # PUT /clients/:id.json
  def update
    # XXX: Trust the client to provide accurate updated_at and created_at
    # timestamps for references.
    if @client = Client.where(:id => params[:id]).first
      filtered_params = @client.update_references(client_params, true)
      if !filtered_params[:errors].empty?
        render json: filtered_params[:errors], status: :unprocessable_entity
        return
      end
    end
    @client = Client.new(filtered_params[:params])

    if existing = Client.where(:id => params[:id]).first
      # Sync all fields
      authorize! :update, existing
      result = existing.attributes
      sync_fields(result, @client.attributes, params[:last_synced].to_i)
      @client.assign_attributes(result)
      editing_time = params[:client][:editing_time].to_i
      if !@client.editing_time || editing_time >= @client.editing_time
        diff = editing_time - @client.editing_time
        # Prevent client from tampering too much with this.
        last_change = ClientChange.where('client_id' => @client.id, 'type' => 'client').desc(:updated_at).first
        if last_change
          # Can't possibly be more than the time between now and the previous recorded change.
          last_diff = Time.now.to_i - last_change.updated_at.to_i
          if diff > last_diff
            editing_time = @client.editing_time + last_diff
          end
        end
        @client.editing_time = editing_time
      end
    else
      # Must have been deleted by someone else.
      render json: '', status: :gone
      return
    end

    if @client.upsert
      # Create a new client change if necessary.
      ClientChange.update_client(@client, @user.id)
      render json: get_json(@client.serialize_references(true))
    else
      render json: @client.errors, status: :unprocessable_entity
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
