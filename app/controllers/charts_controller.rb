class ChartsController < ApplicationController
  def snapshot
    @movements = current_person.all_organization_and_children.where("importable_type = 'Ccc::MinistryActivity'")
    begin_date = Date.today - 1.year
    end_date = Date.today
    @all_stats = {}
    
    infobase_hash = {
      :begin_date => begin_date,
      :end_date => end_date,
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