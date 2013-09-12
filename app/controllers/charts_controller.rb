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
    if @movements.blank?
      redirect_to goal_empty_charts_path
      return
    end
    if @chart.goal_organization_id.blank?
      @chart.goal_organization_id = @movements.first[1]
      @chart.save
      @current_movement = Organization.find(@chart.goal_organization_id)
    end
    if @chart.goal_criteria.blank?
      @chart.goal_criteria = MovementIndicator.all.first
      @chart.save
      @current_criteria = @chart.goal_criteria
    end
    get_goal
    refresh_goal_data
  end

  def update_goal_org
    get_goal_chart
    @current_movement = Organization.find(params[:org_id])
    @chart.goal_organization_id = @current_movement.id
    @chart.save
    get_goal
    refresh_goal_data
  end

  def update_goal_criteria
    get_goal_chart
    @current_criteria = params[:criteria]
    @chart.goal_criteria = @current_criteria
    @chart.save
    get_goal
    refresh_goal_data
    render :update_goal_org
  end

  def edit_goal
    get_goal_chart
  end

  def cancel_edit_goal
    get_goal_chart
  end

  def update_goal
    get_goal_chart

    if can? :manage, @current_movement
      attribs = params["organizational_goal"]
      start_date = Date.civil(attribs["start_date(1i)"].to_i, attribs["start_date(2i)"].to_i, attribs["start_date(3i)"].to_i)
      end_date = Date.civil(attribs["end_date(1i)"].to_i, attribs["end_date(2i)"].to_i, attribs["end_date(3i)"].to_i)

      @goal.start_date = start_date
      @goal.end_date = end_date
      @goal.start_value = attribs["start_value"]
      @goal.end_value = attribs["end_value"]
      @goal.organization = @current_movement
      @goal.criteria = @current_criteria

      if @goal.save
        refresh_goal_data
        render :update_goal_org
      else
        refresh_goal_data
        render :edit_goal_error
      end
    else
      redirect_to goal_chart_path
    end
  end

  protected

  def get_snapshot_chart
    get_chart(Chart::SNAPSHOT, true)
  end

  def get_goal_chart
    get_chart(Chart::GOAL)
    @current_movement = Organization.where(id: @chart.goal_organization_id).first
    @current_criteria = @chart.goal_criteria
    get_goal
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

  def get_goal
    @goal = @current_movement.organizational_goal.where(criteria: @current_criteria).first if (@current_movement && @current_criteria)
    @goal ||= OrganizationalGoal.new()
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

  def refresh_goal_data
    begin_date = Date.today - 3.months
    end_date = Date.today

    if @goal.id?
      begin_date = @goal.start_date
      end_date = @goal.end_date
    end

    begin
      resp = RestClient.get(APP_CONFIG['infobase_url'] + "/api/v1/stats/activity?activity_id=#{@current_movement.importable_id}&begin_date=#{begin_date}&end_date=#{end_date}", content_type: :json, accept: :json, authorization: "Token token=\"#{APP_CONFIG['infobase_token']}\"")
      json = JSON.parse(resp)
    rescue
      raise resp.inspect
    end

    @goal_line = {}
    if @goal.id?
      @goal_line[@goal.start_date] = @goal.start_value
      @goal_line[@goal.end_date] = @goal.end_value
    end

    @data_points = {}
    stats = json["statistics"]
    criteria = MovementIndicator.translate[@current_criteria]

    if MovementIndicator.semester.include?(@current_criteria)
      stats.each do |stat|
        @data_points[Date.parse(stat["period_end"])] = stat[criteria]
      end
    elsif MovementIndicator.weekly.include?(@current_criteria)
      total = 0
      stats.each do |stat|
        total += stat[criteria]
        @data_points[Date.parse(stat["period_end"])] = total
      end
    end
  end
end
