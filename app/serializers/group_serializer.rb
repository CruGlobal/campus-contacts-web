class GroupSerializer < ActiveModel::Serializer

  attributes :id, :name, :location, :meets, :meeting_day, :start_time, :end_time, :organization_id,
             :list_publicly, :approve_join_requests, :updated_at, :created_at

  #has_many :contacts
  #has_many :admins
  #has_many :leaders
  #has_many :people
  #has_many :surveys
  #has_many :groups
  #has_many :keywords

  #def include_associations!
    #if scope.is_a? Array
      #include! :contacts if scope.include?('contacts')
      #include! :admins if scope.include?('admins')
      #include! :leaders if scope.include?('leaders')
      #include! :people if scope.include?('people')
      #include! :surveys if scope.include?('surveys')
      #include! :groups if scope.include?('groups')
      #include! :keywords if scope.include?('keywords')
    #end
  #end

end

