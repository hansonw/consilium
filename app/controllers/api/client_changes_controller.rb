require 'ydocx/document'
require 'tempfile'
require 'andand'

class Api::ClientChangesController < Api::ApiController
  load_and_authorize_resource
  render_related_fields :user => [:email], :client => [:company_name]

  # GET /client_changes
  # GET /client_changes.json
  def index
    @client_changes = ClientChange.all
    if params[:client_id]
      authorize! :read, Client.find(params[:client_id])
      @client_changes = @client_changes.where('client_id' => params[:client_id])
    end
    if params[:user_id]
      @client_changes = @client_changes.where('user_id' => params[:user_id])
    end
    @client_changes = @client_changes.desc(:created_at)

    if params[:short]
      @client_changes = @client_changes.only(:id, :user, :client, :type, :description, :updated_at)
    end

    @client_changes = current_ability.select(@client_changes)
    if params[:limit]
      @client_changes = @client_changes.take(params[:limit].to_i)
    end

    respond_to do |format|
      format.json { render json: get_json(@client_changes) }
    end
  end

  # GET /client_changes/1
  # GET /client_changes/1.json
  def show
    if @client_change.type == 'template'
      new_section = DocumentTemplateSection.unscoped.find(@client_change.new_section_id)
      attrs = {
        :template => new_section.document_template.file,
        :section_id => new_section.name,
        :section_name => new_section.name.underscore.humanize.titleize,
        :reverted => @client_change.new_section.nil?
      }
      render json: get_json(@client_change, attrs)
      return
    end

    prev_changes = ClientChange.where({
      'client_id' => @client_change.client_id,
      'new_section_id' => nil,
      :id.lt => @client_change.id
    }).desc(:id)

    prev_change = prev_changes.first

    next_change = ClientChange.where({
      'client_id' => @client_change.client_id,
      'new_section_id' => nil,
      :id.gt => @client_change.id
    }).asc(:id).first

    cur_data = @client_change.client_data
    prev_data = prev_change.andand.client_data

    if params.has_key? :location_id
      cur_data = cur_data.andand['locations'].andand['value'].andand[params[:location_id].to_i]
      prev_data = prev_data.andand['locations'].andand['value'].andand[params[:location_id].to_i]
    end

    field_list = Client::FIELDS
    if params.has_key? :location_id
      field_list = field_list.find { |f| f[:id] == 'locations' }[:type]
    end

    changed_fields = ClientChange.get_changed_fields(cur_data, prev_data, field_list)

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
      :change_count => ClientChange.where('client_id' => @client_change.client_id, 'new_section_id' => nil).length,
    }

    respond_to do |format|
      format.json { render json: get_json(@client_change, attrs) }
    end
  end
end
