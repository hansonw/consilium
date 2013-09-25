require 'andand'

class Api::BrokerageController < Api::ApiController
  def show
    @brokerage = current_user.brokerage
    render json: get_json(@brokerage.serialize_references)
  end

  # POST /api/brokerage.json
  def create
    # Empty arrays are nil
    params[:contacts] ||= []

    if @brokerage = current_user.brokerage
      authorize! :update, @brokerage
    else
      authorize! :create, Brokerage
      current_user.brokerage = @brokerage = Brokerage.new
      @brokerage.save
      current_user.save
    end

    filtered_params = @brokerage.update_with_references(brokerage_params)
    if !filtered_params[:errors].empty?
      render json: filtered_params[:errors], status: :unprocessable_entity
      return
    end

    if @brokerage.save
      render json: get_json(@brokerage.serialize_references)
    else
      render json: @brokerage.errors, status: :unprocessable_entity
    end
  end

  # GET /api/brokerage/stats
  def stats
    @brokerage = current_user.brokerage
    authorize! :manage, @brokerage

    times = {
      :day => 1.day,
      :week => 1.week,
      :month => 1.month,
      :all => Time.now,
    }

    stats = times.map do |name, time|
      since = Time.now - time
      data = {}
      data[:clients_created] = Client.where(:brokerage => @brokerage, :created_at.gt => since).length

      data[:editing_time] = 0
      Client.where(:brokerage => @brokerage).each do |client|
        # Difference in editing time between the last change and the last change before 'since'
        last_change = ClientChange.where(:client => client, :type => 'client').desc(:created_at).first
        prev_change = ClientChange.where(:client => client, :type => 'client', :created_at.lt => since)
                                  .desc(:created_at).first
        data[:editing_time] += (last_change.andand.client_data.andand['editing_time'] || 0) -
                               (prev_change.andand.client_data.andand['editing_time'] || 0)
      end

      docs = Document.where(:created_at.gt => since).to_a
      docs.select! { |d| d.client.andand.brokerage == @brokerage }

      data[:documents_generated] = docs.length
      data[:time_saved] = (docs.map { |d| d.client_change.andand.client_data.andand['editing_time'] || 0 }).reduce(:+) || 0

      [name, data]
    end

    render json: Hash[stats]
  end

  def brokerage_params
    params.permit Brokerage.generate_permit_params
  end
end
