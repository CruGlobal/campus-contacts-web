class ChartsController < ApplicationController
  def index
    redirect_to snapshot_charts_path
  end

  def snapshot
    get_snapshot_chart
    refresh_snapshot_data
    get_movement_stages
    get_changed_lives
  end

  def update_snapshot_movements
    get_snapshot_chart
    @chart.snapshot_all_movements = params[:all]
    @chart.save

    if !@chart.snapshot_all_movements
      @chart.update_movements_displayed(params[:movements])
    end

    refresh_snapshot_data
    get_movement_stages
    get_changed_lives
  end

  def update_snapshot_range
    get_snapshot_chart
    if params[:gospel_exp_range]
      @chart.snapshot_evang_range = params[:gospel_exp_range]
      @chart.save
    elsif params[:laborers_range]
      @chart.snapshot_laborers_range = params[:laborers_range]
      @chart.save
    end

    refresh_snapshot_data
  end

  def goal
    get_goal_chart
    organizations = current_person.all_organization_and_children.where("importable_type = 'Ccc::MinistryActivity'")
    @movements = organizations.collect{|org| [org.name, org.id]}
    if @chart.goal_organization_id.blank?
      @chart.goal_organization_id = @movements.first.id
      @chart.save
    end
    @current_movement = Organization.find(@chart.goal_organization_id)
    if @chart.goal_criteria.blank?
      @chart.goal_criteria = MovementIndicator.all.first
      @chart.save
    end
    @current_criteria = @chart.goal_criteria
  end

  def update_goal_org
    get_goal_chart
    @current_movement = Organization.find(params[:org_id])
    @current_criteria = @chart.goal_criteria
    @chart.goal_organization_id = @current_movement.id
    @chart.save
  end

  def update_goal_criteria
    get_goal_chart
    @current_movement = Organization.find(@chart.goal_organization_id)
    @current_criteria = params[:criteria]
    @chart.goal_criteria = @current_criteria
    @chart.save
    render :update_goal_org
  end

  protected

  def get_snapshot_chart
    get_chart(Chart::SNAPSHOT, true)
  end

  def get_goal_chart
    get_chart(Chart::GOAL)
  end

  def get_chart(type, orgs = false)
    @chart = current_person.charts.where("chart_type = ?", type).first
    unless @chart
      @chart = Chart.new
      @chart.person = current_person
      @chart.chart_type = type
      @chart.save
    end

    if orgs
      @movements = current_person.all_organization_and_children.where("importable_type = 'Ccc::MinistryActivity'")
      @chart.update_movements(@movements)
      @chart.save
    end
  end

  def refresh_snapshot_data
    begin_date = Date.today - @chart.snapshot_evang_range.months
    end_date = Date.today
    semester_date = Date.today - @chart.snapshot_laborers_range.months

    if @chart.snapshot_all_movements
      @displayed_movements = @movements
    else
      org_ids = @chart.chart_organizations.where("snapshot_display = 1").all.collect(&:organization_id)
      @displayed_movements = Organization.where("id IN (?)", org_ids)
    end

    @all_stats = {}
    infobase_hash = {
      :begin_date => begin_date,
      :end_date => end_date,
      :semester_date => semester_date,
      :activity_ids => @displayed_movements.collect(&:importable_id)
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
      :activity_ids => @displayed_movements.collect(&:importable_id)
    }

    begin
      resp = RestClient.post(APP_CONFIG['infobase_url'] + "/api/v1/stats/movement_stages", infobase_hash.to_json, content_type: :json, accept: :json, authorization: "Token token=\"#{APP_CONFIG['infobase_token']}\"")
      json = JSON.parse(resp)
    rescue
      raise resp.inspect
    end

    json["Pioneering"] ||= 0
    json["Key Leader"] ||= 0
    json["Launched"] ||= 0
    json["Multiplying (formerly Transformational)"] ||= 0

    @movement_stages = json
  end

  def get_changed_lives
    org_ids = @movements.collect(&:id)
    interactions = Interaction.where("interaction_type_id = ?", InteractionType::PERSONAL_DECISION).
      where("organization_id IN (?)", org_ids).where("privacy_setting IN ('everyone','organization')").
      order("created_at desc").all
    people = interactions.collect(&:receiver)
    @changed_lives = []
    people.each do |person|
      unless (@changed_lives.size >= 8 || person.blank? || @changed_lives.include?(person))
        @changed_lives << person
      end
    end
  end
end
