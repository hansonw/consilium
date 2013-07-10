require 'ydocx/document'
require 'tempfile'

class Api::ClientChangesController < Api::ApiController
  before_action :set_client_change, only: [:edit, :destroy]

  respond_to :json

  def get_json(obj, attrs = {})
    ret = {}
    obj.attributes.each do |key, val|
      if key == "_id"
        ret[:id] = val.to_s
      elsif key == "user_id"
        ret[:user_id] = val.to_s
        ret[:user_email] = obj.user ? obj.user.email : 'deleted'
      elsif key == "client_id"
        ret[:client_id] = val.to_s
        ret[:client_name] = obj.client ? obj.client.name['value'] : 'deleted'
      elsif key == "created_at"
        # convert to milliseconds, Javascript's default format
        ret[key] = (val.to_f * 1000).to_i
      else
        ret[key] = val
      end
    end

    ret.merge(attrs)
  end

  # GET /client_changes
  # GET /client_changes.json
  def index
    @client_changes = ClientChange.all
    if params[:client_id]
      @client_changes = @client_changes.where('client_id' => params[:client_id])
    end
    @client_changes = @client_changes.desc(:created_at)

    if params[:short]
      @client_changes = @client_changes.only(:id, :user, :client, :description, :updated_at)
    end

    respond_to do |format|
      format.json { render json: @client_changes.map{ |d| get_json(d) } }
    end
  end

  # GET /client_changes/1
  # GET /client_changes/1.json
  def show
    @client_change = ClientChange.where(:id => params[:id]).first
    if @client_change.nil?
      render json: '', status: :gone
      return
    end

    prev_change = ClientChange.where({
      'client_id' => @client_change.client_id,
      :updated_at.lt => @client_change.updated_at
    }).desc(:created_at).first

    changed_fields = ClientChange.get_changed_fields(
        @client_change.client_data, prev_change && prev_change.client_data)

    changed_sections = changed_fields.map do |field_id|
      section = 'basicInfo'
      Client::FIELDS.each do |field|
        if field[:type].is_a?(Array)
          if field[:id] == field_id
            section = field_id
          elsif !field[:id].ends_with?('s')
            field[:type].each do |subfield|
              if subfield[:id] == field_id
                section = field[:id]
              end
            end
          end
        end
      end
      section
    end

    attrs = {
      :changed_fields => Hash[changed_fields.map {|c| [c, true]}],
      :changed_sections => Hash[changed_sections.map {|c| [c, true]}],
    }

    respond_to do |format|
      format.json { render json: get_json(@client_change, attrs) }
    end
  end

  # DELETE /client_changes/1
  # DELETE /client_changes/1.json
  def destroy
    @client_change.destroy
    render json: ''
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_client_change
      @client_change = ClientChange.find(params[:id])
    end
end
