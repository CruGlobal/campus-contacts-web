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
    organizations = current_person.all_organization_and_children
    @movements = organizations.collect { |org| [org.name, org.id] }
    if @movements.blank?
      redirect_to goal_empty_charts_path
      return
    end
    if @chart.goal_organization_id.blank?
      @chart.goal_organization_id = @movements.first[1]
      @chart.save
      @current_movement = Organization.find(@chart.goal_organization_id)
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
      begin
        start_date = Date.parse(attribs["start_date"]) if attribs["start_date"].present?
      rescue
        start_date = nil
      end

      begin
        end_date = Date.parse(attribs["end_date"]) if attribs["end_date"].present?
      rescue
        end_date = nil
      end

      @goal.start_date = start_date
      @goal.end_date = end_date
      @goal.start_value = attribs["start_value"].blank? ? 0 : attribs["start_value"]
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

  def trend
    get_trend_chart
    refresh_trend_data
  end

  def update_trend_movements
    get_trend_chart
    @chart.trend_all_movements = params[:all]
    @chart.save

    if !@chart.trend_all_movements
      @chart.update_trend_movements_displayed(params[:movements])
    end

    begin
      start_date = Date.parse(params["start_date"]) if params["start_date"].present?
    rescue
      start_date = nil
    end

    begin
      end_date = Date.parse(params["end_date"]) if params["end_date"].present?
    rescue
      end_date = nil
    end

    @chart.trend_start_date = start_date
    @chart.trend_end_date = end_date
    @chart.save

    refresh_trend_data
  end

  def update_trend_field
    get_trend_chart

    @chart.try(params[:changed].to_s + '=', params[:criteria])
    @chart.save

    refresh_trend_data
    render :update_trend_movements
  end

  def update_trend_compare
    get_trend_chart

    @chart.trend_compare_year_ago = params[:compare]
    @chart.save

    refresh_trend_data
    render :update_trend_movements
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

  def get_trend_chart
    get_chart(Chart::TREND, true)
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
    @grouped_criteria_options = get_goal_criteria_options(@current_movement)
    unless @grouped_criteria_options.flatten.include?(@current_criteria)
      @current_criteria = @grouped_criteria_options.first.last.first if @grouped_criteria_options.first
      @chart.goal_criteria = @current_criteria
      @chart.save
    end
  end

  def get_goal_criteria_options(org)
    options = []
    if org
      if org.is_in_infobase?
        options << ["Movement Indicators", MovementIndicator.all]
      end
      labels = org.labels.pluck(:name)
      options << ["Labels", labels] unless labels.empty?
    end
    options
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
      resp = RestClient.post(APP_CONFIG['infobase_url'] + "/statistics/collate_stats", infobase_hash.to_json, content_type: :json, accept: :json, authorization: "Bearer #{APP_CONFIG['infobase_token']}")
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
      resp = RestClient.post(APP_CONFIG['infobase_url'] + "/statistics/movement_stages", infobase_hash.to_json, content_type: :json, accept: :json, authorization: "Bearer #{APP_CONFIG['infobase_token']}")
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

    if @goal.id? && @goal.valid?
      begin_date = @goal.start_date
      end_date = @goal.end_date
    end

    @goal_line = {}
    if @goal.id? && @goal.valid?
      @goal_line[@goal.start_date] = @goal.start_value
      @goal_line[@goal.end_date] = @goal.end_value
    end

    @data_points = {}

    if MovementIndicator.all.include?(@current_criteria)
      begin
        resp = RestClient.get(APP_CONFIG['infobase_url'] + "/statistics/activity?activity_id=#{@current_movement.importable_id}&begin_date=#{begin_date}&end_date=#{end_date}", content_type: :json, accept: :json, authorization: "Bearer #{APP_CONFIG['infobase_token']}")
        json = JSON.parse(resp)
      rescue
        raise resp.inspect
      end

      stats = json["statistics"]
      criteria = MovementIndicator.translate[@current_criteria]

      if MovementIndicator.semester.include?(@current_criteria)
        stats.each do |stat|
          @data_points[Date.parse(stat["period_end"])] = stat[criteria].to_i
        end
      elsif MovementIndicator.weekly.include?(@current_criteria)
        total = 0
        stats.each do |stat|
          total += stat[criteria].to_i
          @data_points[Date.parse(stat["period_end"])] = total
        end
      end
    else
      end_date = Date.today if Date.today < end_date
      label_id = @current_movement.labels.where(name: @current_criteria).pluck(:id)
      begin_date.end_of_week(:sunday).step(end_date.end_of_week(:sunday), 7) do |date|
        value = OrganizationalLabel.where(organization_id: @current_movement.id, label_id: label_id).where("start_date <= ?", date).where("removed_date is null or removed_date >= ?", date).count
        @data_points[date] = value
      end
    end
  end

  def refresh_trend_data
    @begin_date = (Date.today - 3.months).end_of_week(:sunday)
    @end_date = Date.today.end_of_week(:sunday)
    @begin_date = @chart.trend_start_date.end_of_week(:sunday) if @chart.trend_start_date
    @end_date = @chart.trend_end_date.end_of_week(:sunday) if @chart.trend_end_date

    if @chart.trend_all_movements
      @displayed_movements = @movements
    else
      org_ids = @chart.chart_organizations.where("trend_display = 1").all.collect(&:organization_id)
      @displayed_movements = Organization.where("id IN (?)", org_ids)
    end

    max_fields = Chart::TREND_MAX_FIELDS
    semester_stats_needed = false
    interval = @chart.trend_interval

    @fields, @lines = [], {}
    (1..max_fields).each do |number|
      field = @chart["trend_field_#{number}"]
      @fields << MovementIndicator.translate[field] if field.present?
      semester_stats_needed = true if MovementIndicator.semester.include?(field)
      @lines[@fields.last.to_s] = {}
    end

    unless @fields.empty?
      infobase_hash = {
          activity_ids: @displayed_movements.collect(&:importable_id),
          begin_date: @begin_date,
          end_date: @end_date,
          interval: interval,
          semester: semester_stats_needed
      }

      begin
        resp = RestClient.post(APP_CONFIG['infobase_url'] + "/statistics/collate_stats_intervals", infobase_hash.to_json, content_type: :json, accept: :json, authorization: "Bearer #{APP_CONFIG['infobase_token']}")
        json = JSON.parse(resp)
      rescue
        raise resp.inspect
      end

      @begin_date.step(@end_date, 7) do |date| # step through dates 1 week at a time
        @fields.each do |field|
          @lines[field][date] = json[date.to_s][field] if @lines[field] && json[date.to_s]
        end
      end
    end

    @fields_year_ago, @lines_year_ago = [], {}
    if @chart.needs_year_ago_stats?
      @fields_year_ago = @fields.clone
      @fields_year_ago.each do |field|
        @lines_year_ago[field] = {}
      end

      year_ago_begin = (@begin_date - 1.year).end_of_week(:sunday)
      year_ago_end = (@end_date - 1.year).end_of_week(:sunday)

      unless @fields_year_ago.empty?
        infobase_hash = {
            activity_ids: @displayed_movements.collect(&:importable_id),
            begin_date: year_ago_begin,
            end_date: year_ago_end,
            interval: interval,
            semester: semester_stats_needed
        }

        begin
          resp = RestClient.post(APP_CONFIG['infobase_url'] + "/statistics/collate_stats_intervals", infobase_hash.to_json, content_type: :json, accept: :json, authorization: "Bearer #{APP_CONFIG['infobase_token']}")
          json = JSON.parse(resp)
        rescue
          raise resp.inspect
        end

        year_ago_begin.step(year_ago_end, 7) do |date| # step through dates 1 week at a time
          @fields_year_ago.each do |field|
            # add 364 days to the plot point to line it up with the current year and day of the week
            @lines_year_ago[field][date + 364.days] = json[date.to_s][field] if @lines_year_ago[field] && json[date.to_s]
          end
        end
      end
    end
  end
end
