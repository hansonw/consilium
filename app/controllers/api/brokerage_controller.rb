class Api::BrokerageController < Api::ApiController
  def show
    @brokerage = Brokerage.all.first
    respond_to do |format|
      format.json { render json: @brokerage.serialize_references }
    end
  end

  def create
    # Empty arrays are nil
    params[:contacts] ||= []

    if @brokerage = Brokerage.all.first
      filtered_params = nil
      begin
        filtered_params = @brokerage.update_references(brokerage_params)
        throw if !filtered_params[:errors].empty?
      rescue
        render json: filtered_params[:errors], status: :unprocessable_entity
        return
      end
      @brokerage.update(filtered_params[:params])
    else
      @brokerage = Brokerage.new(brokerage_params)
    end

    respond_to do |format|
      if @brokerage.save
        render json: @brokerage.serialize_references
      else
        render json: @brokerage.errors, status: :unprocessable_entity
      end
    end
  end

  def brokerage_params
    params.permit Brokerage.generate_permit_params
  end
end
