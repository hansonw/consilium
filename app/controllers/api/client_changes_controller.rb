require 'ydocx/document'
require 'tempfile'
require 'andand'

class Api::ClientChangesController < Api::ApiController
  before_action :set_client_change, only: [:edit, :destroy]

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

    prev_changes = ClientChange.where({
      'client_id' => @client_change.client_id,
      :id.lt => @client_change.id
    }).desc(:id)

    prev_change = prev_changes.first

    next_change = ClientChange.where({
      'client_id' => @client_change.client_id,
      :id.gt => @client_change.id
    }).asc(:id).first

    cur_data = @client_change.client_data
    prev_data = prev_change.andand.client_data

    if params.has_key? :location_id
      cur_data = cur_data.andand['locations'].andand['value'].andand[params[:location_id].to_i]
      prev_data = prev_data.andand['locations'].andand['value'].andand[params[:location_id].to_i]
    end

    changed_fields = ClientChange.get_changed_fields(cur_data, prev_data)

    field_list = Client::FIELDS
    if params.has_key? :location_id
      field_list = field_list.find { |f| f[:id] == 'locations' }[:type]
    end

    changed_sections = Hash[changed_fields.keys.map { |field_id, val|
      section = 'basicInfo'
      field_list.each do |field|
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
      [section, true]
    }]

    attrs = {
      :changed_fields => changed_fields,
      :changed_sections => changed_sections,
      :prev_change_id => prev_change.andand.id.to_s,
      :next_change_id => next_change.andand.id.to_s,
      :cur_change_num => prev_changes.length + 1,
      :change_count => ClientChange.where('client_id' => @client_change.client_id).length,
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
