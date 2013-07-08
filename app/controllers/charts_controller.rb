class ChartsController < ApplicationController
  def snapshot
    movements = current_person.all_organization_and_children.where("importable_type = 'Ccc::MinistryActivity'")
    begin_date = Date.today - 6.months
    end_date = Date.today
    @all_stats = empty_stats_hash
    movements.each do |movement|
      begin
        resp = RestClient.get(APP_CONFIG['infobase_url'] + "/api/v1/stats/activity?activity_id=#{movement.importable_id}&begin_date=#{begin_date.to_s(:db)}&end_date=#{end_date.to_s(:db)}", content_type: :json, accept: :json, authorization: "Token token=\"#{APP_CONFIG['infobase_token']}\"")
        json = JSON.parse(resp)
      rescue
        raise resp.inspect
      end
      
      json['statistics'].each do |stat|
        @all_stats = add_weekly_stat(@all_stats, stat)
      end
      
      @all_stats = add_semester_stat(@all_stats, json['statistics'].last) if json['statistics'].last
    end
  end
  
  def index
    redirect_to snapshot_charts_path
  end
  
  protected
  
  def empty_stats_hash
    {
      'spiritual_conversations' => 0,
      'personal_evangelism' => 0,
      'personal_decisions' => 0,
      'holy_spirit_presentations' => 0,
      'graduating_on_mission' => 0,
      'faculty_on_mission' => 0,
      'involved' => 0,
      'engaged_disciples' => 0,
      'leaders' => 0
    }
  end
  
  def add_weekly_stat(all, stat)
    all['spiritual_conversations'] += stat['spiritual_conversations'].to_i
    all['personal_evangelism'] += stat['personal_evangelism'].to_i
    all['personal_decisions'] += stat['personal_decisions'].to_i
    all['holy_spirit_presentations'] += stat['holy_spirit_presentations'].to_i
    all['graduating_on_mission'] += stat['graduating_on_mission'].to_i
    all['faculty_on_mission'] += stat['faculty_on_mission'].to_i
    all
  end
  
  def add_semester_stat(all, stat)
    all['involved'] += stat['students_involved'].to_i
    all['involved'] += stat['faculty_involved'].to_i
    all['engaged_disciples'] += stat['students_engaged'].to_i
    all['engaged_disciples'] += stat['faculty_engaged'].to_i
    all['leaders'] += stat['student_leaders'].to_i
    all['leaders'] += stat['faculty_leaders'].to_i
    all
  end
end