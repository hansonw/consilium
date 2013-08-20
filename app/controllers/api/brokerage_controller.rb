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

    filtered_params = @brokerage.update_references(brokerage_params)
    if !filtered_params[:errors].empty?
      render json: filtered_params[:errors], status: :unprocessable_entity
      return
    end
    @brokerage.update(filtered_params[:params])

    if @brokerage.save
      render json: get_json(@brokerage.serialize_references)
    else
      render json: @brokerage.errors, status: :unprocessable_entity
    end
  end

  def brokerage_params
    params.permit Brokerage.generate_permit_params
  end
end
