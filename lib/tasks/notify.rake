namespace :notify do
  task contact_assignments: :environment do
    puts ""
    assignments_array = Array.new
    contact_assignments = ContactAssignment.where(notified: false)
    org_ids = contact_assignments.collect{|x| x.organization_id}.uniq
    if org_ids.present?
      puts "Contact Assignments - Process Notifications"
      Organization.where(id: org_ids).each do |org|
        org_hash = {id: org.id, name: org.name}
        puts "Notify assignments for Organization - #{org_hash}"
        leader_ids = contact_assignments.where(organization_id: org.id).collect{|x| x.assigned_to_id}.uniq
        Person.where(id: leader_ids).each do |leader|
          leader_hash = {id: leader.id, name: leader.name, email: leader.email}
          puts "-- Leader - #{leader_hash}"
          assignment_array = Array.new
          assignments = contact_assignments.where(organization_id: org.id, assigned_to_id: leader.id)
          assignments.each do |assignment|
            next unless assignment.person.present?
            assigned_by = {id: assignment.assigned_by.id, name: assignment.assigned_by.name} if assignment.assigned_by
            assignment_hash = {id: assignment.id, name: assignment.person.name, assigned_by: assigned_by}
            puts "---- Assignment - #{assignment_hash}"
            assignment_array << assignment_hash
          end
          if assignment_array.present?
            assignment_info = {leader: leader_hash, organization: org_hash, assignments: assignment_array}
            LeaderMailer.delay.assignments(leader, org, assignment_array)
            assignments.update_all(notified: true)
            assignments_array << assignment_info
          end
          assignments
        end
      end
    else
      puts "Contact Assignments - Nothing to notify"
    end
    puts ""
  end
end
