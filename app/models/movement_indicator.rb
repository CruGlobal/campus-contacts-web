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
end