class ChartsController < ApplicationController
  before_filter :get_chart
  
  def index
    redirect_to snapshot_charts_path
  end

  def snapshot
    refresh_data
    get_movement_stages
    get_changed_lives
  end
  
  def update_snapshot_movements
    @chart.snapshot_all_movements = params[:all]
    @chart.save
    
    if !@chart.snapshot_all_movements
      @chart.update_movements_displayed(params[:movements])
    end
    
    refresh_data
  end
  
  def update_snapshot_range
    if params[:gospel_exp_range]
      @chart.snapshot_evang_range = params[:gospel_exp_range]
      @chart.save
    elsif params[:laborers_range]
      @chart.snapshot_laborers_range = params[:laborers_range]
      @chart.save
    end
    
    refresh_data
  end
  
  protected
  
  def get_chart
    @chart = current_person.charts.where("chart_type = ?", Chart::SNAPSHOT).first
    unless @chart
      @chart = Chart.new
      @chart.person = current_person
      @chart.chart_type = Chart::SNAPSHOT
    end
    
    @movements = current_person.all_organization_and_children.where("importable_type = 'Ccc::MinistryActivity'")
    @chart.update_movements(@movements)
    @chart.save
  end
  
  def refresh_data
    begin_date = Date.today - @chart.snapshot_evang_range.months
    end_date = Date.today
    semester_date = Date.today - @chart.snapshot_laborers_range.months
    
    if @chart.snapshot_all_movements
      movements = @movements
    else
      org_ids = @chart.chart_organizations.where("snapshot_display = 1").all.collect(&:organization_id)
      movements = Organization.where("id IN (?)", org_ids)
    end
    
    @all_stats = {}
    infobase_hash = {
      :begin_date => begin_date,
      :end_date => end_date,
      :semester_date => semester_date,
      :activity_ids => movements.collect(&:importable_id)
    }
    
    begin
      resp = RestClient.post(APP_CONFIG['infobase_url'] + "/api/v1/stats/collate_stats", infobase_hash.to_json, content_type: :json, accept: :json, authorization: "Token token=\"#{APP_CONFIG['infobase_token']}\"")
      json = JSON.parse(resp)
    rescue
      raise resp.inspect
    end
    
    json['involved'] = json['students_involved'].to_i + json['faculty_involved'].to_i
    json['engaged_disciples'] = json['students_engaged'].to_i + json['faculty_engaged'].to_i
    json['leaders'] = json['student_leaders'].to_i + json['faculty_leaders'].to_i

    @all_stats = json
  end
  
  def get_movement_stages
    infobase_hash = {
      :activity_ids => @movements.collect(&:importable_id)
    }

    begin
      resp = RestClient.post(APP_CONFIG['infobase_url'] + "/api/v1/stats/movement_stages", infobase_hash.to_json, content_type: :json, accept: :json, authorization: "Token token=\"#{APP_CONFIG['infobase_token']}\"")
      json = JSON.parse(resp)
    rescue
      raise resp.inspect
    end
    
    @movement_stages = json
  end
  
  def get_changed_lives
    org_ids = @movements.collect(&:id)
    interactions = Interaction.where("interaction_type_id = ?", InteractionType::PERSONAL_DECISION).
      where("organization_id IN (?)", org_ids).where("privacy_setting IN ('everyone','organization')").
      order("created_at").limit(8).all
    @changed_lives = interactions.collect(&:receiver)
  end
end