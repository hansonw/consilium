class Api::BrokerageController < Api::ApiController
  def show
    @brokerage = Brokerage.all.first
    respond_to do |format|
      format.json { render json: @brokerage }
    end
  end

  def create
    # Empty arrays are nil
    params[:contacts] ||= []

    if @brokerage = Brokerage.all.first
      @brokerage.serialize_references
      puts @brokerage.inspect
      @brokerage.update(brokerage_params)
      @brokerage.deserialize_references
    else
      @brokerage = Brokerage.new(brokerage_params)
    end

    respond_to do |format|
      if @brokerage.save
        format.json { render json: @brokerage }
      else
        format.json { render json: @brokerage.errors, status: :unprocessable_entity }
      end
    end
  end

  def brokerage_params
    params.permit Brokerage.generate_permit_params
  end
end
