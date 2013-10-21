class MovementIndicator
  def self.weekly
    [
      "Personal Evangelism",
      "Personal Evangelism Decisions",
      "Group Evangelism",
      "Group Evangelism Decisions",
      "Media Exposures",
      "Media Exposures Decisions",
      "Spiritual Conversations",
      "Holy Spirit Presentations",
      "Graduating on Mission",
      "Faculty on Mission"
    ]
  end

  def self.semester
    [
      "Students Involved",
      "Faculty Involved",
      "Student Engaged Disciples",
      "Faculty Engaged Disciples",
      "Student Leaders",
      "Faculty Leaders"
    ]
  end

  def self.all
    weekly + semester
  end

  def self.translate
    {
      "Personal Evangelism" => "personal_evangelism",
      "Personal Evangelism Decisions" => "personal_decisions",
      "Group Evangelism" => "group_evangelism",
      "Group Evangelism Decisions" => "group_decisions",
      "Media Exposures" => "media_exposures",
      "Media Exposures Decisions" => "media_decisions",
      "Spiritual Conversations" => "spiritual_conversations",
      "Holy Spirit Presentations" => "holy_spirit_presentations",
      "Graduating on Mission" => "graduating_on_mission",
      "Faculty on Mission" => "faculty_on_mission",
      "Students Involved" => "students_involved",
      "Faculty Involved" => "faculty_involved",
      "Student Engaged Disciples" => "students_engaged",
      "Faculty Engaged Disciples" => "faculty_engaged",
      "Student Leaders" => "student_leaders",
      "Faculty Leaders" => "faculty_leaders"
    }
  end
end