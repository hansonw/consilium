class Api::BrokerageController < Api::ApiController
  respond_to :json

  def show
    @brokerage = Brokerage.all.first
    respond_to do |format|
      format.json { render json: @brokerage }
    end
  end

  def create
    if @brokerage = Brokerage.all.first
      @brokerage.update(brokerage_params)
    else
      @brokerage = Brokerage.new(brokerage_params)
    end

    respond_to do |format|
      if @brokerage.save
        format.json { render json: @brokerage }
      else
        format.json { render json: @document.errors, status: :unprocessable_entity }
      end
    end
  end

  def brokerage_params
    params.permit :office, :marketer, :producer
  end
end
