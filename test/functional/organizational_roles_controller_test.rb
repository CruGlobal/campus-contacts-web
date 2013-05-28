require 'test_helper'

class OrganizationalRolesControllerTest < ActionController::TestCase
  context "Updating contacts" do
    setup do
      @user, @org = admin_user_login_with_org

      @org_role = Factory(:organizational_role)
    end

    should "update organizational role" do
      xhr :put, :update, { :id => @org_role.id, :status => "" }
      assert_response :success
      assert_not_nil assigns(:organizational_role)
      assert_equal OrganizationalRole.find(@org_role.id), assigns(:organizational_role)
    end
  end

  context "Moving contacts" do
    setup do
      @user, @org = admin_user_login_with_org

      @person1 = Factory(:person)
      @person2 = Factory(:person)
      @person3 = Factory(:person)

      @another_org = Factory(:organization)
    end

    should "move the people (contact roles) from one org to another org (keep contact)" do
      @org.add_contact(@person1)
      @org.add_contact(@person2)
      @org.add_contact(@person3)

      ids = []
      ids << @person1.id
      ids << @person2.id
      ids << @person3.id

      xhr :post, :move_to, { :from_id => @org.id , :to_id => @another_org.id, :ids => ids.join(','), :keep_contact => "true", :current_admin => @user }
      assert_equal ids, @org.contacts.collect(&:id)
      assert_equal ids, @another_org.contacts.collect(&:id)
    end

    should "move the people (contact roles) from one org to another org (do not keep contact)" do
      @org.add_contact(@person1)
      @org.add_contact(@person2)
      @org.add_contact(@person3)

      ids = []
      ids << @person1.id
      ids << @person2.id
      ids << @person3.id

      xhr :post, :move_to, { :from_id => @org.id , :to_id => @another_org.id, :ids => ids.join(','), :keep_contact => "false", :current_admin => @user }
      assert_equal [], @org.contacts.collect(&:id)
      assert_equal ids, @another_org.contacts.collect(&:id)
    end

    should "move the people (involved roles) from one org to another org (keep contact)" do
      @org.add_contact(@person1)
      @org.add_contact(@person2)
      @org.add_contact(@person3)
      @org.add_involved(@person1)
      @org.add_involved(@person2)
      @org.add_involved(@person3)

      ids = []
      ids << @person1.id
      ids << @person2.id
      ids << @person3.id

      xhr :post, :move_to, { :from_id => @org.id , :to_id => @another_org.id, :ids => ids.join(','), :keep_contact => "true", :current_admin => @user }
      # for MH-448
      assert_equal ids, @org.people.includes(:organizational_labels).where("organizational_labels.label_id" => Label::INVOLVED_ID).collect(&:id)
      assert_equal ids, @another_org.contacts.collect(&:id)
    end

    should "move the people (involved roles) from one org to another org (do not keep contact)" do
      @org.add_involved(@person1)
      @org.add_involved(@person2)
      @org.add_involved(@person3)

      ids = []
      ids << @person1.id
      ids << @person2.id
      ids << @person3.id

      xhr :post, :move_to, { :from_id => @org.id , :to_id => @another_org.id, :ids => ids.join(','), :keep_contact => "false", :current_admin => @user }
      # for MH-448
      assert_equal [], @org.people.includes(:organizational_roles).where("organizational_roles.role_id" => Role.contact.id).collect(&:id)
      assert_equal ids, @another_org.contacts.collect(&:id)
    end

    should "move the people (contact role + other roles) from one org to another org (do not keep contact)" do
      @org.add_involved(@person1)
      @org.add_involved(@person2)
      @org.add_involved(@person3)

      @org.add_contact(@person1)
      @org.add_contact(@person2)
      @org.add_contact(@person3)

      ids = []
      ids << @person1.id
      ids << @person2.id
      ids << @person3.id

      xhr :post, :move_to, { :from_id => @org.id , :to_id => @another_org.id, :ids => ids.join(','), :keep_contact => "false", :current_admin => @user }
      # for MH-448
      assert_equal [], @org.contacts.collect(&:id)
      assert_equal [], @org.people.includes(:organizational_roles).where("organizational_roles.role_id" => Role.missionhub_user.id).collect(&:id)
      assert_equal ids, @another_org.contacts.collect(&:id)
      assert_equal [], @another_org.people.includes(:organizational_roles).where("organizational_roles.role_id" => Role.missionhub_user.id).collect(&:id) # only contact role will be obtained by the transferred person
    end

    should "not be able to move an admin person if he's the only remaining admin in the org" do
      ids = [@user.person.id]

      xhr :post, :move_to, { :from_id => @org.id , :to_id => @another_org.id, :ids => ids.join(','), :keep_contact => "false", :current_admin => @user }

      assert_equal I18n.t('organizational_roles.cannot_delete_self_as_admin_error'), @response.body
      assert_equal ids, @org.admins.collect(&:id)
      assert_equal [], @another_org.contacts.collect(&:id)
    end

    should "be able to move an admin person if there's other admins in the org" do
      @user_2 = Factory(:user_with_auxs)
      ids = [@user_2.person.id]
      @org.add_admin(@user_2.person)

      xhr :post, :move_to, { :from_id => @org.id , :to_id => @another_org.id, :ids => ids.join(','), :keep_contact => "false", :current_admin => @user }

      assert_equal I18n.t('organizational_roles.moving_people_success'), @response.body
      assert_equal [@user.person.id], @org.admins.collect(&:id)
      assert_equal [@user_2.person.id], @another_org.contacts.collect(&:id)
    end

    should "be able to move an leader person" do
      @user_2 = Factory(:user_with_auxs)
      ids = [@user_2.person.id]
      @org.add_leader(@user_2.person, @user.person)
      @contact = Factory(:person)

      assert_difference "ContactAssignment.count", 1 do
        Factory(:contact_assignment, organization: @org, assigned_to: @user_2.person, person: @contact)
        assert_equal 1, @contact.assigned_tos.count
      end

      assert_difference "ContactAssignment.count", -1 do
        xhr :post, :move_to, { :from_id => @org.id , :to_id => @another_org.id, :ids => ids.join(','), :keep_contact => "false", :current_admin => @user }
        assert_equal 0, @contact.assigned_tos.count
      end

      assert_equal I18n.t('organizational_roles.moving_people_success'), @response.body
      assert_equal [], @org.only_missionhub_users.collect(&:id)
      assert_equal [@user_2.person.id], @another_org.contacts.collect(&:id)
    end

    should "completely move an archived person to an org (do not keep contact)" do
      @archived_contact1 = Factory(:person, first_name: "Edmure", last_name: "Tully")
      Factory(:organizational_role, organization: @user.person.organizations.first, person: @archived_contact1, role: Role.contact)
      @archived_contact1.organizational_roles.where(role_id: Role::CONTACT_ID).first.archive #archive his one and only role

      ids = [@archived_contact1.id]

      xhr :post, :move_to, { :from_id => @org.id , :to_id => @another_org.id, :ids => ids.join(','), :keep_contact => "false", :current_admin => @user }
      assert !@org.people.collect(&:id).include?(@archived_contact1.id)
      assert_equal ids, @another_org.contacts.collect(&:id)
    end
  end

  context "deleting a contact" do
    setup do
      @user, @organization = admin_user_login_with_org
      @organizational_role = Factory(:organizational_role, person: @user.person, organization: @organization, :role => Role.contact)
      @contact = Factory(:person)
      @role = Factory(:organizational_role, person: @contact, organization: @organization, :role => Role.contact)
      sign_in @user
    end

    should "make its organizational_role.followup_status = 'do_not_contact'" do
      a = OrganizationalRole.where(:followup_status => 'do_not_contact').count
      xhr :put, :update, {:status => "do_not_contact", :id => @role.id}
      assert_equal a+1, OrganizationalRole.where(:followup_status => 'do_not_contact').count
      assert_equal [@contact], @organization.dnc_contacts
      assert_not_empty @organization.dnc_contacts.where(id: @contact.id)
    end
  end

  context "set_current" do
    setup do
      @user, @organization = admin_user_login_with_org
      @org_child = Factory(:organization, :name => "neilmarion", :parent => @organization)
    end

    should "set_current" do
      assert_equal @organization.id, session[:current_organization_id]
      xhr :get, :set_current, :id => @org_child.id
      assert_equal @org_child.id.to_s, session[:current_organization_id]
    end
  end

  context "set_primary" do
    setup do
      @user, @organization = admin_user_login_with_org
      @org_child = Factory(:organization, :name => "neilmarion", :parent => @organization)
    end

    should "set_primary" do
      assert_equal @organization.id, session[:current_organization_id]
      xhr :get, :set_primary, :id => @org_child.id
      assert_equal @org_child.id.to_s, session[:current_organization_id]
    end
  end
end
