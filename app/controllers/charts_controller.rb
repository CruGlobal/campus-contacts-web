class ChartsController < ApplicationController
  def snapshot
    @chart = current_person.charts.where("chart_type = ?", Chart::SNAPSHOT).first
    unless @chart
      @chart = Chart.new
      @chart.person = current_person
      @chart.chart_type = Chart::SNAPSHOT
    end
    
    @movements = current_person.all_organization_and_children.where("importable_type = 'Ccc::MinistryActivity'")
    @chart.update_movements(@movements)
    @chart.save
    
    begin_date = Date.today - @chart.snapshot_evang_range.months
    end_date = Date.today
    semester_date = Date.today - @chart.snapshot_laborers_range.months
    
    @all_stats = {}
    infobase_hash = {
      :begin_date => begin_date,
      :end_date => end_date,
      :semester_date => semester_date,
      :activity_ids => @movements.collect(&:importable_id)
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
  
  def index
    redirect_to snapshot_charts_path
  end
end