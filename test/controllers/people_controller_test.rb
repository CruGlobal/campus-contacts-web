require 'test_helper'

class PeopleControllerTest < ActionController::TestCase

  context "Before logging in" do

    should "redirect on update" do
      @person = FactoryGirl.create(:person)
      put :update, id: @person.id
      assert_redirected_to '/users/sign_in'
    end

  end

  context "After logging in a person without orgs" do
    setup do
      @person = FactoryGirl.create(:user_no_org)
      sign_in @person
    end

    should "redirect on edit" do
      get :edit, id: @person.person.id
      assert_redirected_to '/wizard'
    end

    should "redirect on update" do
      put :update, id: @person.id
      assert_redirected_to '/wizard'
    end

  end

  context "After logging in a person" do

    setup do
      @person, @org = admin_user_login_with_org
      sign_in @person
    end

    should "should show person" do
      get :show, id: @person.person.id
      assert_redirected_to "/profile/#{@person.person.id}"
    end

    should "should get edit" do
      get :edit, id: @person.person.id
      assert_response :success
    end

    should "should update person" do
      put :update, id: @person.person.id, person: {first_name: 'David', last_name: 'Ang',  :current_address_attributes => { :address1 => "#41 Sgt. Esguerra Ave", :country => "Philippines"} }
      assert_redirected_to person_path(assigns(:person))
    end

    context "bulk sending" do
      setup do
        @person1 = FactoryGirl.create(:person_without_email)
        @person2 = FactoryGirl.create(:person_without_email)
        p1 = PhoneNumber.new(:number => "123129312", :person_id => @person1.id)
        assert p1.save

        p2 = PhoneNumber.new(:number => "12390900", :person_id => @person2.id, :primary => true)
        assert p2.save
        Twilio::SMS.stubs(:create)
      end

      should "not send bulk email if receiver do not have an email" do
        xhr :post, :bulk_email, { :to => "#{@person1.id},#{@person2.id}", :subject => "functional test", :body => "test email body" }
        assert_response :success
        assert_nil assigns(:message)
      end

      should "send bulk email if receivers have email" do

        email1 = FactoryGirl.create(:email_address, email: "jonsnow1@email.com", person: @person1)
        email2 = FactoryGirl.create(:email_address, email: "jonsnow2@email.com", person: @person2)
        xhr :post, :bulk_email, { :to => "#{@person1.id},#{@person2.id}", :subject => "functional test", :body => "test email body" }
        assert_response :success
        assert_not_nil assigns(:message)
      end

      should "not send bulk email to unknown person" do
        xhr :post, :bulk_email, { :to => "999999", :subject => "functional test", :body => "test email body" }
        assert_response :success
        assert_nil assigns(:message)
      end

      should "update permissions" do
        permissions = []
        (1..3).each { |index| permissions << Permission.create!(name: "member_#{index}", i18n: "member_#{index}") }
        permissions = permissions.collect { |permission| permission.id }.join(',')
        xhr :post, :update_permissions, { :permission_ids => permissions, :some_permission_ids => "", :person_id => @person1.id }
        assert_response :success
      end

      should "update permissions with include_old_permissions as parameter" do
        permissions = []
        (1..3).each { |index| permissions << Permission.create!(name: "member_#{index}", i18n: "member_#{index}") }
        permissions = permissions.collect { |permission| permission.id }.join(',')
        xhr :post, :update_permissions, { :permission_ids => permissions, :some_permission_ids => "", :person_id => @person1.id, :include_old_permissions => "yes" }
        assert_response :success
      end

      should "try to update permissions with duplicate permissions" do
        permissions = []
        (1..3).each { |index| permissions << Permission.create!(name: "member_#{index}", i18n: "member_#{index}") }
        #duplicate the first permission
        permissions << permissions.first
        permissions = permissions.collect { |permission| permission.id }.join(',')
        xhr :post, :update_permissions, { :permission_ids => permissions, :some_permission_ids => "", :person_id => @person1.id, :include_old_permissions => "yes" }
        assert_response :success
      end

    end
  end

  context "When updating permissions" do
    setup do
      @user = FactoryGirl.create(:user_with_auxs)

      @person = FactoryGirl.create(:person)
      @person2 = FactoryGirl.create(:person, email: "person2@email.com")
      @person3 = FactoryGirl.create(:person, email: "person3@email.com")

      @org = FactoryGirl.create(:organization)

      sign_in @user
      @request.session[:current_organization_id] = @org.id

      @permissions = []
      (1..4).each { |index| @permissions << Permission.create!(name: "permission_#{index}", i18n: "permission_#{index}") }

    end

    should "retain old permissions of different users even if users have initially have a different set of permissions" do
      # Illustration:
      # @person2 initially have permissions [3]
      # @person3 initially have permissions [4]
      # Apply permission "2" to both of them
      # @person2 and @person 3 should retain permissions [3] and [4] respectively after PeopleController#update_permissions
      org_permission = OrganizationalPermission.where(person_id: @person2.id,organization_id:  @org.id).first_or_create
      org_permission.update_attributes({
        archive_date: nil,
        added_by_id: @user.person.id,
        deleted_at: nil,
        permission_id: 3
      })

      old_person_2_permissions = @person2.organizational_permissions.where(organization_id: @org.id).collect { |permission| permission.permission_id }
      old_person_3_permissions = @person3.organizational_permissions.where(organization_id: @org.id).collect { |permission| permission.permission_id }

      xhr :post, :update_permissions, { :permission_ids => "#{@permissions[1].id}, #{@permissions[2].id}", :some_permission_ids => "#{@permissions[2].id}, #{@permissions[3].id}", :person_id => @person2.id }
      assert_response :success
      xhr :post, :update_permissions, { :permission_ids => "#{@permissions[1].id}, #{@permissions[3].id}", :some_permission_ids => "#{@permissions[2].id}, #{@permissions[3].id}", :person_id => @person3.id }
      assert_response :success

      new_person_2_permissions = @person2.organizational_permissions.where(organization_id: @org.id).collect { |permission| permission.permission_id }
      new_person_3_permissions = @person3.organizational_permissions.where(organization_id: @org.id).collect { |permission| permission.permission_id }

      assert old_person_2_permissions & new_person_2_permissions # permission 2 still has his old permissions?
      assert old_person_3_permissions & new_person_3_permissions # permission 3 still has his old permissions?

    end

    context "removing an admin permission" do
      setup do
        @last_admin = FactoryGirl.create(:person, email: "person4@email.com")
        @admin2 = FactoryGirl.create(:person, email: "person5@email.com")
        @admin_organizational_permission = FactoryGirl.create(:organizational_permission, organization: @org, person: @last_admin)
        @org.add_admin(@last_admin)
      end

      should "not remove admin permission from the last admin of a root org" do
        assert_no_difference "OrganizationalPermission.count" do
          xhr :post, :update_permissions, { :permission_ids => "", :some_permission_ids => "", :person_id => @last_admin.id }
        end
      end

      should "not remove admin permission from the last admin of an org with parent org with 'show_sub_orgs == false'" do
        org_2 = Organization.create({"parent_id"=> @org.id, "name"=>"Org 2", "terminology"=>"Organization", "show_sub_orgs"=>"0"}) # org with show_sub_orgs == false
        org_3 = Organization.create({"parent_id"=> org_2.id, "name"=>"Org 3", "terminology"=>"Organization", "show_sub_orgs"=>"1"})
        @user_neil = FactoryGirl.create(:user_with_auxs)
        FactoryGirl.create(:email_address, person_id: @user_neil.person.id)
        org_3.add_admin(@user_neil.person, @admin2.id)
        sign_in @user_neil
        @request.session[:current_organization_id] = org_3.id

        assert_no_difference "OrganizationalPermission.count" do
          xhr :post, :update_permissions, { :permission_ids => "", :some_permission_ids => "", :person_id => @user_neil.person.id }
        end
      end

    end
  end

  context "Search" do
    setup do
      @user = FactoryGirl.create(:user_with_auxs)
      sign_in @user

      @unarchived_contact1 = FactoryGirl.create(:person, first_name: "Brynden", last_name: "Tully")
      FactoryGirl.create(:organizational_permission, organization: @user.person.organizations.first, person: @unarchived_contact1, permission: Permission.no_permissions)
      FactoryGirl.create(:email_address, email: "bryndentully@email.com", person: @unarchived_contact1, primary: true)

      @archived_contact1 = FactoryGirl.create(:person, first_name: "Edmure", last_name: "Tully")
      FactoryGirl.create(:organizational_permission, organization: @user.person.organizations.first, person: @archived_contact1, permission: Permission.no_permissions)
      @archived_contact1.organizational_permissions.where(permission_id: Permission::NO_PERMISSIONS_ID).first.archive #archive his one and only permission

      @phone_number = FactoryGirl.create(:phone_number, person: @unarchived_contact1, number: "09167788889", primary: true)
    end

    should "respond success with no parameters" do
      get :index
      assert_response(:success)
    end

    should "respond success with basic search parameter" do
      get :index, :search_type => "basic", :query => "John Doe"
      assert_response(:success)
    end

    should "respond success with advanced search parameters" do
      get :index, :search_type => "advanced", :first_name => "John", :last_name => "Doe", :permission => "1", :gender => "1",
          email: "test@email.com", :phone => "123"
      assert_response(:success)
    end

    should "not be able to search for archived contacts if 'Include Archvied' checkbox is not checked" do
      get :index, {:search_type => "basic", :query => "Edmure Tully"}
      assert_response(:success)
      assert !assigns(:all_people).include?(@archived_contact1)
    end

    should "be able to search for archived contacts if 'Include Archvied' checkbox is checked" do
      get :index, {:search_type => "basic", :include_archived => "true", :query => "Edmure Tully"}
      assert_response(:success)
      assert assigns(:all_people).include?(@archived_contact1)
    end

    should "be able to search by email address" do
      get :index, {:search_type => "basic", :include_archived => "true", :query => "bryndentully@email.com"}
      assert assigns(:people).include?(@unarchived_contact1)
    end

    should "be able to search by wildcard" do
      get :index, {:search_type => "basic", :include_archived => "true", :query => "tully"}
      assert assigns(:people).include?(@archived_contact1), "archived contact not found"
      assert assigns(:people).include?(@unarchived_contact1), "unarchived contact not found"
    end

    should "not be able to search for anything" do
      get :index, {:search_type => "basic", :include_archived => "true", :query => "none"}
      assert_empty assigns(:people)
    end

    should "search by phone number" do
      get :index, :search_type => "advanced", :first_name => "", :last_name => "", :permission => "", :gender => "",
          email: "", :phone => "09167788889"
      assert_equal [@unarchived_contact1], assigns(:people)
      assert_response(:success)
    end

    should "search by phone number wildcard" do
      get :index, :search_type => "advanced", :first_name => "", :last_name => "", :permission => "", :gender => "",
          email: "", :phone => "88889"
      assert_equal [@unarchived_contact1], assigns(:people)
      assert_response(:success)
    end

  end

  context "Searching for Facebook users" do
    setup do
      @user = FactoryGirl.create(:user_with_auxs)  #user with a person object
      sign_in @user
    end


    should "successfully search for facebook users when using '/http://www.facebook.com\//[a-z]' format" do
      stub_request(:get, "https://graph.facebook.com/nmfdelacruz").
        to_return(:body => "{\"id\":\"100000289242843\",\"name\":\"Neil Marion Dela Cruz\",\"first_name\":\"Neil Marion\",\"last_name\":\"Dela Cruz\",\"link\":\"http:\\/\\/www.facebook.com\\/nmfdelacruz\",\"username\":\"nmfdelacruz\",\"gender\":\"male\",\"locale\":\"en_US\"}")
      xhr :get, :facebook_search, { :term =>"http://www.facebook.com/nmfdelacruz"}
      assert_equal(2, assigns(:data).length, "Unsuccessfully searched for a user using Facebook profile url")
    end

    should "successfully search for facebook users when using '/http://www.facebook.com\/profile.php?id=/[0-9]'" do
      stub_request(:get, "https://graph.facebook.com/100000289242843").to_return(:body => "{\"id\":\"100000289242843\",\"name\":\"Neil Marion Dela Cruz\",\"first_name\":\"Neil Marion\",\"last_name\":\"Dela Cruz\",\"link\":\"http:\\/\\/www.facebook.com\\/profile.php?id=100000289242843\",\"username\":\"nmfdelacruz\",\"gender\":\"male\",\"locale\":\"en_US\"}")
      xhr :get, :facebook_search, { :term =>"http://www.facebook.com/profile.php?id=100000289242843"}
      assert_equal(2, assigns(:data).length, "Unsuccessfully searched for a user using Facebook profile url")
    end

    should "unsuccessfully search for facebook users when url does not exist" do
      stub_request(:get, "https://graph.facebook.com/nm34523fdelacruz").to_return(status: 404)
      xhr :get, :facebook_search, { :term =>"http://www.facebook.com/nm34523fdelacruz"}
      assert_equal(1, assigns(:data).length)
    end

=begin
    should "successfully search for facebook users when using '/[a-z]/' (name string)  format" do
      stub_request(:get, "https://graph.facebook.com/search?access_token=&limit=24&q=9gag").to_return(:body => "{\"id\":\"100000289242843\",\"name\":\"Neil Marion Dela Cruz\",\"first_name\":\"Neil Marion\",\"last_name\":\"Dela Cruz\",\"link\":\"http:\\/\\/www.facebook.com\\/nmfdelacruz\",\"username\":\"nmfdelacruz\",\"gender\":\"male\",\"locale\":\"en_US\"}")
      get :facebook_search, { :term =>"9gag"}
      assert_equal(1, assigns(:data).length)
    end

    should "unsuccessfully search for facebook users when name does not exist" do
      stub_request(:get, "https://graph.facebook.com/search?access_token=&limit=24&q=dj09345803oifjdlkjdl&type=user").to_return(status: 404)
      get :facebook_search, { :term =>"dj09345803oifjdlkjdl"}
      assert_equal(0, assigns(:data).length)
    end
=end
  end

  context "Assigning a contact to leader" do
    setup do
      @user = FactoryGirl.create(:user_with_auxs)
      @org = FactoryGirl.create(:organization)
      FactoryGirl.create(:organizational_permission, organization: @org, person: @user.person, permission: Permission.admin)

      sign_in @user
      @request.session[:current_organization_id] = @org.id

      @permissions = []
      @permissions << Permission.user
      @permissions = @permissions.collect { |permission| permission.id }.join(',')
    end

    should "update the contact's permission to leader that has a valid email" do
      Sidekiq::Testing.inline! do
        person = FactoryGirl.create(:person, email: "super_duper_unique_email@mail.com")
        assert_difference "OrganizationalPermission.count", 1 do
          xhr :post, :update_permissions, { :permission_ids => Permission::USER_ID, :some_permission_ids => "", :person_id => person.id, :added_by_id => @user.person.id }
        end
        assert_response :success
        assert_equal(person.id, OrganizationalPermission.last.person_id)
        assert_not_nil ActionMailer::Base.deliveries.last
        assert_equal "super_duper_unique_email@mail.com", ActionMailer::Base.deliveries.last.to.first.to_s
      end
    end

    should "not attempt to email if contact doesnt have a valid email" do
      person = FactoryGirl.create(:person)
      mail_count = ActionMailer::Base.deliveries.count
      assert(person.email, "")
      xhr :post, :update_permissions, { :permission_ids => @permissions, :some_permission_ids => "", :person_id => person.id, :added_by_id => @user.person.id }
      assert_response :success
      assert_equal(mail_count, ActionMailer::Base.deliveries.count)
    end

    context "person has existing permissions" do
      setup do
        @existing_permissions = Permission.admin.id
      end

      should "replace permission if the person already has existing permissions" do
        person = FactoryGirl.create(:person, email: 'thisemailisalsounique@mail.com')
        FactoryGirl.create(:organizational_permission, person: person, permission: Permission.no_permissions, organization: @org, :added_by_id => @user.person.id)
        #check the persons permissions
        assert_equal(1, person.permissions.count)
        assert_equal(Permission.no_permissions, person.permission_for_org_id(@org.id))
        Sidekiq::Testing.inline! do
          xhr :post, :update_permissions, { :permission_ids => @existing_permissions, :some_permission_ids => "", :person_id => person, :added_by_id => @user.person.id }
          #assert that the leader permission was not added
          assert_response :success
          assert_equal(1, person.permissions.count)
          assert_equal(Permission.admin, person.permission_for_org_id(@org.id))
          assert_equal(person.id, OrganizationalPermission.last.person_id)
          assert_not_nil ActionMailer::Base.deliveries.last
          assert_equal("thisemailisalsounique@mail.com", ActionMailer::Base.deliveries.last.to.first.to_s)
        end
      end

      should "restore the person previous permission if the person has an invalid email" do
        person = FactoryGirl.create(:person_without_email)
        FactoryGirl.create(:organizational_permission, person: person, permission: Permission.no_permissions, organization: @org, :added_by_id => @user.person.id)
        #check the persons permissions
        assert_equal(1, person.permissions.count)
        assert_equal(Permission.no_permissions, person.permission_for_org_id(@org.id))
        xhr :post, :update_permissions, { :permission_ids => @existing_permissions, :some_permission_ids => "", :person_id => person, :added_by_id => @user.person.id }
        #assert that the leader permission was not added
        assert_response :success
        assert_equal(1, person.organizational_permissions_for_org(@org).count)
        assert_equal(Permission.no_permissions, person.permission_for_org_id(@org.id))
        assert_equal(person.id, OrganizationalPermission.last.person_id)
      end
    end
  end

  context "Merging people" do
    setup do
      @user = FactoryGirl.create(:user_with_auxs)
      @org = FactoryGirl.create(:organization)
      sign_in @user
      @request.session[:current_organization_id] = @org.id
    end

    context "when the logged in user is admin" do
      setup do
        FactoryGirl.create(:organizational_permission, organization: @org, person: @user.person, permission: Permission.admin)
      end

      should "have access to the merge facility" do
        get :merge
        assert_response(:success)
      end

      context "merge people" do
        setup do
          @person1 = FactoryGirl.create(:person, first_name: "Clark", last_name: "Kent")
          @person2 = FactoryGirl.create(:person, first_name: "Bruce", last_name: "Wayne")
          @person3 = FactoryGirl.create(:person, first_name: "Hal", last_name: "Jordan")
          @person4 = FactoryGirl.create(:person, first_name: "Clark", last_name: "Kent")
          @person5 = FactoryGirl.create(:person, first_name: "clark", last_name: "kent")
        end

        should "fail to confirm merge when only one person is selected" do
          post :confirm_merge, { :person1 => @person1.id }
          assert_response :redirect
        end

        should "successfully confirm_merge peeps" do
          post :confirm_merge, { :person1 =>  @person1.id, :person2 => @person4.id }
          assert_response(:success)
        end

        should "successfully confirm_merge peeps with the same name but different casing" do
          post :confirm_merge, { :person1 =>  @person1.id, :person2 => @person5.id }
          assert_response(:success)
        end
      end
    end

    context "when the logged in user is a super admin" do
      setup do
        FactoryGirl.create(:super_admin, user: @user)
      end

      should "have access to the merge facility" do
        get :merge
        assert_response(:success)
      end

      context "merge people" do
        setup do
          @person1 = FactoryGirl.create(:person, first_name: "Tony", last_name: "Stark")
          @person2 = FactoryGirl.create(:person, first_name: "Thor", last_name: "Odinson")
          @person3 = FactoryGirl.create(:person, first_name: "Bruce", last_name: "Banner")
          @person4 = FactoryGirl.create(:person, first_name: "Tony", last_name: "Stark")
        end

        should "successfully confirm_merge peeps" do
          post :confirm_merge, { :person1 =>  @person1.id, :person2 => @person2.id, :person3 => @person3.id, :person4 => @person4.id }
          assert_response(:success)
        end
      end
    end

    context "when the logged in user is a missionhub_user" do
      setup do
        FactoryGirl.create(:organizational_permission, organization: @org, person: @user.person, permission: Permission.user)
      end

      should "not be allowed to use the merge facility" do
        get :merge
        assert_response(:redirect)
        assert_equal(flash[:error], "You are not permitted to access that feature")
      end
    end
  end

  context "merging people" do
    setup do
      @user, @org = admin_user_login_with_org
      @person = @user.person
      @person1 = FactoryGirl.create(:person, first_name: "Clark", last_name: "Kent")
      @person2 = FactoryGirl.create(:person, first_name: "Bruce", last_name: "Wayne")
      @person3 = FactoryGirl.create(:person, first_name: "Hal", last_name: "Jordan")
      @person4 = FactoryGirl.create(:person, first_name: "Clark", last_name: "Kent")
      @person5 = FactoryGirl.create(:person, first_name: "clark", last_name: "kent")
    end

    should "redirect when id = 0" do
      get :merge_preview, { :id => 0 }
      assert_response :success
    end

    should "get merge preview when id != 0" do
      p1 = FactoryGirl.create(:person)
      xhr :get,  :merge_preview, { :id => p1.id }
      assert_not_nil assigns(:person)
    end

    should "try to merge people" do
      p1 = FactoryGirl.create(:person)
      p2 = FactoryGirl.create(:person)
      p3 = FactoryGirl.create(:person)

      ids = []
      ids << p2.id
      ids << p3.id

      post :do_merge, { :keep_id => p1.id, :merge_ids => ids }

      assert_response :redirect
      assert_equal "You've just merged #{ids.length + 1} people", flash[:notice]
    end

    should "not merge people if not an admin in the organization" do
      contact1 = FactoryGirl.create(:person)
      contact2 = FactoryGirl.create(:person)
      leader1 = FactoryGirl.create(:user_with_auxs)
      FactoryGirl.create(:organizational_permission, organization: @org, person: leader1.person, permission: Permission.user)

      @org.add_contact(contact1)
      @org.add_contact(contact2)

      sign_in leader1

      post :do_merge, { :keep_id => contact1.id, :merge_ids => [contact2.id] }
      assert_equal "You are not permitted to access that feature", flash[:error]
      assert_redirected_to "/people"
    end

    should "merge people on a child organization" do
      @org_child = FactoryGirl.create(:organization, :name => "neilmarion", :parent => @user.person.organizations.first)
      contact1 = FactoryGirl.create(:person)
      contact2 = FactoryGirl.create(:person)

      ids = []
      ids << contact1.id
      ids << contact2.id

      @org_child.add_contact(contact1)
      @org_child.add_contact(contact2)

      @request.session[:current_organization_id] = @org_child.id
      assert_difference "Person.all.count", -1 do
        post :do_merge, { :keep_id => contact1.id, :merge_ids => [contact2.id] }
      end
      assert_equal "You've just merged #{ids.length} people", flash[:notice]
    end

    should "merge received interactions" do
      @interaction_type = FactoryGirl.create(:interaction_type, organization_id: 0, i18n: "Comment")
      FactoryGirl.create(:interaction, receiver: @person1, creator: @person, organization: @org, interaction_type_id: @interaction_type.id)
      FactoryGirl.create(:interaction, receiver: @person2, creator: @person, organization: @org, interaction_type_id: @interaction_type.id)
      assert_difference "Person.find(#{@person1.id}).interactions.count", 1 do
        post :do_merge, { :keep_id => @person1.id, :merge_ids => [@person2.id] }
      end
      assert_equal "You've just merged 2 people", flash[:notice]
    end

    should "merge created interactions" do
      @interaction_type = FactoryGirl.create(:interaction_type, organization_id: 0, i18n: "Comment")
      FactoryGirl.create(:interaction, receiver: @person3, creator: @person1, organization: @org, interaction_type_id: @interaction_type.id)
      FactoryGirl.create(:interaction, receiver: @person4, creator: @person2, organization: @org, interaction_type_id: @interaction_type.id)
      assert_difference "Person.find(#{@person1.id}).created_interactions.count", 1 do
        post :do_merge, { :keep_id => @person1.id, :merge_ids => [@person2.id] }
      end
      assert_equal "You've just merged 2 people", flash[:notice]
    end
  end

  context "searching ids" do
    setup do
      @user, @org = admin_user_login_with_org
      @another_org = FactoryGirl.create(:organization)
      c1 = FactoryGirl.create(:person, first_name: "Scott", last_name: "Munroe")
      c2 = FactoryGirl.create(:person, first_name: "Scott", last_name: "Summers")
      c3 = FactoryGirl.create(:person, first_name: "Scott", last_name: "Grey")

      @org.add_contact(c1)
      @org.add_contact(c2)
      @another_org.add_contact(c3)
    end

    should "only search ids within the org if user is not super admin" do
      xhr :get, :search_ids, { :q => "Scott" }
      assert_equal 2, assigns(:people).count
    end

    should "search all people when user is super admin" do
      FactoryGirl.create(:super_admin, user: @user)
      xhr :get, :search_ids, { :q => "Scott" }
      assert_equal 3, assigns(:people).count
    end
  end

  context "creating a person" do
    setup do
      request.env["HTTP_REFERER"] = "localhost:3000"
      @user, @org = admin_user_login_with_org

      FactoryGirl.create(:email_address, email: "robstark@email.com")
    end

    should "create person" do
      post :create, { :person => { :first_name => "Herp", :last_name => "Derp", :email_address => { email: "herp@derp.com" }, :phone_number => { :number => "123918230912"} } }

      assert_not_nil assigns(:person)
      assert_not_nil assigns(:email)
      assert_not_nil assigns(:phone)

      assert_response :redirect
    end

    should "render nothing when user has no name" do
      post :create, { :person => { :first_name => "", :last_name => "Derp", :email_address => { email: "herp@derp.com" }, :phone_number => { :number => "123918230912"} } }
      assert_equal "", @response.body
    end

    should "render not be able to create a person with an email already existing" do
      assert_no_difference "Person.count" do
        post :create, { :person => { :first_name => "", :last_name => "Derp", :email_address => { email: "robstark@email.com" }} }
      end
    end

    should "not create a person with an invalid phone_number" do
      assert_no_difference "Person.count" do
        post :create, { :person => { :first_name => "Hello", :last_name => "Derp", :phone_number => { :number => "asdofhjasdlkfja"} } }
      end
    end

    should "not create a person with an invalid email_address" do
      assert_no_difference "Person.count" do
        post :create, { :person => { :first_name => "Rob", :last_name => "Derp", :email_address => { email: "robstarkemail.com" }} }
      end
    end

    should "not create a person with admin permission without a valid email" do
      assert_no_difference "Person.count" do
        post :create, {:person=> { :first_name =>"Waymar", :last_name =>"Royce", :gender =>"male", :email_address =>{email:"", :primary =>"1"}}, :permissions =>{"1"=> Permission.admin.id}}
      end
    end

    should "not create a person with missionhub_user permission without a valid email" do
      assert_no_difference "Person.count" do
        post :create, {:person=> { :first_name =>"Waymar", :last_name =>"Royce", :gender =>"male", :email_address =>{email:"", :primary =>"1"}}, :permissions =>{"1"=> Permission.user.id}}
      end
    end

    should "create a person with admin permission with a valid email" do
      assert_difference "Person.count", 1 do
        post :create, {:person=> { :first_name =>"Waymar", :last_name =>"Royce", :gender =>"male", :email_address =>{email:"wayarroyce@email.com", :primary =>"1"}}, :permissions =>{"1"=> Permission.admin.id}}
      end
    end

    should "create a person with missionhub_user permission with a valid email" do
      assert_difference "Person.count", 1 do
        post :create, {:person=> { :first_name =>"Waymar", :last_name =>"Royce", :gender =>"male", :email_address =>{email:"wayarroyce@email.com", :primary =>"1"}}, :permissions =>{"1"=> Permission.user.id}}
      end
    end
  end

  should "bulk comment" do
    @user, @org = admin_user_login_with_org
    c1 = FactoryGirl.create(:person)
    c2 = FactoryGirl.create(:person)

    @org.add_contact(c1)
    @org.add_contact(c2)

    xhr :post, :bulk_comment, { :to => "#{c1.id}, #{c2.id}", :body => "WAT!" }

    assert FollowupComment.where(:contact_id => c1.id)
    assert FollowupComment.where(:contact_id => c2.id)
  end


  test "export" do
    @user, @org = admin_user_login_with_org

    3.times do
      p = FactoryGirl.create(:person)
      @org.add_contact(p)
    end

    get :export
    assert_response :success
  end

  #test "involvement" do
    #@user, @org = admin_user_login_with_org
    #get :involvement, { :id => @user.person.id }

    #assert_not_nil assigns(:person)
  #end

  test "destroy" do
    @user, @org = admin_user_login_with_org
    person = FactoryGirl.create(:person)
    @org.add_contact(person)
    post :destroy, { :id => person.id }
    assert_response :success
  end

  context "bulk deleting people" do
    setup do
      @user, @org = admin_user_login_with_org

      @c1 = FactoryGirl.create(:person, first_name: "Genny")
      @c2 = FactoryGirl.create(:person)

      @org.add_contact(@c1)
      @org.add_contact(@c2)
    end

    should "bulk delete" do
      assert_equal 2, @org.contacts.count
      assert_difference "@org.contacts.count", -2 do
        xhr :post, :bulk_delete, { :ids => "#{@c1.id}, #{@c2.id}" }
      end

      assert_equal 0, @org.contacts.count
      assert_equal I18n.t('people.bulk_delete.deleting_people_success'), @response.body
    end

    should "not bulk delete when contact ids in the params aren't existing" do
      assert_no_difference "OrganizationalPermission.where(organization_id: #{@user.person.organizations.first.id}).count" do
        xhr :post, :bulk_delete, { :ids => "#{@c1.id-10}, #{@c2.id+10}" }
      end
    end

    should "not bulk delete all the admins in the org" do
      FactoryGirl.create(:organizational_permission, person: @c1, permission: Permission.admin, organization: @org)
      init_admin_count = @org.admins.count
      assert_no_difference "OrganizationalPermission.where(organization_id: #{@user.person.organizations.first.id}, permission_id: #{Permission.admin.id}).count" do
        xhr :post, :bulk_delete, { :ids => "#{@user.person.id}, #{@c1.id}, #{@c2.id}" }
      end

      assert_equal init_admin_count, @org.admins.count
      assert_equal I18n.t('people.bulk_delete.cannot_delete_admin_error', names: "#{@user.person.name}, #{@c1.name}"), @response.body
    end

    should "not be able to delete logged-in-admin's self as admin" do
      FactoryGirl.create(:organizational_permission, person: @c1, permission: Permission.admin, organization: @org)
      init_admin_count = @org.admins.count
      assert_no_difference "OrganizationalPermission.where(organization_id: #{@user.person.organizations.first.id}, permission_id: #{Permission.admin.id}).count" do
        xhr :post, :bulk_delete, { :ids => "#{@user.person.id}" }
      end
      assert_equal @user.person.organizational_permissions.collect(&:permission_id), [Permission::ADMIN_ID]
      assert_equal @org.admins.count, init_admin_count
    end
  end

  context "bulk archiving people" do
    setup do
      @user, @org = admin_user_login_with_org

      @c1 = FactoryGirl.create(:person, first_name: "Genny")
      @c2 = FactoryGirl.create(:person)

      @org.add_contact(@c1)
      @org.add_contact(@c2)
    end

    should "bulk archive" do
      assert_equal 2, @org.contacts.count
      xhr :post, :bulk_archive, { :ids => "#{@c1.id}, #{@c2.id}" }

      assert_equal 0, @org.contacts.count
      assert_equal I18n.t('people.bulk_archive.archiving_people_success'), @response.body
    end

    should "not bulk archive when contact ids in the params aren't existing" do
      assert_equal 2, @org.contacts.count
      assert_no_difference "OrganizationalPermission.where(organization_id: #{@user.person.organizations.first.id}).where('archive_date IS NOT NULL').count" do
        xhr :post, :bulk_archive, { :ids => "#{@c1.id-10}, #{@c2.id+10}" }
      end
    end

    should "not bulk archive all the admins in the org" do
      FactoryGirl.create(:organizational_permission, person: @c1, permission: Permission.admin, organization: @org)
      init_admin_count = @org.admins.count

      xhr :post, :bulk_archive, { :ids => "#{@user.person.id}, #{@c1.id}, #{@c2.id}" }

      assert_equal init_admin_count, @org.admins.count
      assert_equal I18n.t('people.bulk_archive.cannot_archive_admin_error', names: "#{@user.person.name}, #{@c1.name}"), @response.body
    end

    should "not be able to delete logged-in-admin's self as admin" do
      FactoryGirl.create(:organizational_permission, person: @c1, permission: Permission.admin, organization: @org)
      init_admin_count = @org.admins.count
      xhr :post, :bulk_archive, { :ids => "#{@user.person.id}" }

      assert_equal @user.person.organizational_permissions.collect(&:permission_id), [Permission::ADMIN_ID]
      assert_equal @org.admins.count, init_admin_count
    end

    should "be able to delete bulk a person in a child organization" do
      org_2 = Organization.create(parent: @org, name: "Org 2", terminology: "Organization", show_sub_orgs: 1) # org with show_sub_orgs == false
      @user = FactoryGirl.create(:user_with_auxs)
      org_2.add_admin(@user.person)
      sign_in @user
      @request.session[:current_organization_id] = org_2.id

      contact = FactoryGirl.create(:person)
      FactoryGirl.create(:organizational_permission, permission: Permission.no_permissions, organization: org_2, person: contact)

      assert_difference "Organization.find(#{org_2.id}).contacts.length", -1 do
        xhr :post, :bulk_delete, { :ids => "#{contact.id}" }
      end
    end
  end

  context "Clicking on the label links at '/people'" do
    setup do
      @org0 = FactoryGirl.create(:organization, id: 1)
      @org = FactoryGirl.create(:organization, id: 2, ancestry: "1")
      @user, @org = admin_user_login_with_org
      @request.session[:current_organization_id] = @org.id

      @admin1 = FactoryGirl.create(:user_with_auxs)
      @admin1.person.update_attributes({first_name: "A", last_name: "A"})
      FactoryGirl.create(:organizational_permission, organization: @org, person: @admin1.person, permission: Permission.admin)

      @leader1 = FactoryGirl.create(:user_with_auxs)
      @leader1.person.update_attributes({first_name: "B", last_name: "B"})
      FactoryGirl.create(:organizational_permission, organization: @org, person: @leader1.person, permission: Permission.user)

      @contact1 = FactoryGirl.create(:user_with_auxs)
      @contact1.person.update_attributes({first_name: "C", last_name: "C"})
      FactoryGirl.create(:organizational_permission, organization: @org, person: @contact1.person, permission: Permission.no_permissions)

      @contact2 = FactoryGirl.create(:user_with_auxs)
      @contact2.person.update_attributes({first_name: "D", last_name: "D"})
      FactoryGirl.create(:organizational_permission, organization: @org, person: @contact2.person, permission: Permission.no_permissions)

      @contact3 = FactoryGirl.create(:user_with_auxs)
      @contact3.person.update_attributes({first_name: "E", last_name: "E"})
      FactoryGirl.create(:organizational_permission, organization: @org, person: @contact3.person, permission: Permission.no_permissions)
    end

    should "return admins when Admin link is clicked" do
      xhr :get, :index, { :permission => Permission::ADMIN_ID }
      assert_equal [@admin1.person.id, @user.person.id], assigns(:all_people).collect{|x| x.id}
    end

    should "return leaders when MissionHub Users link is clicked" do
      xhr :get, :index, { :permission => Permission::USER_ID }
      assert_equal [@leader1.person.id], assigns(:all_people).collect{|x| x.id}
    end

    should "return contacts when Contact link is clicked" do
      xhr :get, :index, { :permission => Permission::NO_PERMISSIONS_ID }
      assert_equal [@contact1.person.id, @contact2.person.id, @contact3.person.id].sort { |x, y| x <=> y }, assigns(:all_people).collect{|x| x.id}
    end

    should "return archiveds when Archived link is clicked" do
      @contact1.person.organizational_permissions.where(permission_id: Permission::NO_PERMISSIONS_ID).first.archive
      @contact2.person.organizational_permissions.where(permission_id: Permission::NO_PERMISSIONS_ID).first.archive
      @contact3.person.organizational_permissions.where(permission_id: Permission::NO_PERMISSIONS_ID).first.archive

      xhr :get, :index, { :archived => true }
      assert_equal assigns(:all_people).collect{|x| x.id}, [@contact1.person.id, @contact2.person.id, @contact3.person.id].sort { |x, y| x <=> y }
    end

    should "only return unarchived people when 'Include Archived' checkbox isn't checked'" do
      @contact1.person.organizational_permissions.where(permission_id: Permission::NO_PERMISSIONS_ID).first.archive
      @contact2.person.organizational_permissions.where(permission_id: Permission::NO_PERMISSIONS_ID).first.archive
      @leader1.person.organizational_permissions.where(permission_id: Permission::USER_ID).first.archive

      xhr :get, :index
      assert_equal [@admin1.person.id, @user.person.id, @contact3.person.id], assigns(:all_people).collect{|x| x.id}
    end

    should "return all people (even unarchived ones) when 'Include Archived' checkbox is checked'" do
      @contact1.person.organizational_permissions.where(permission_id: Permission::NO_PERMISSIONS_ID).first.archive
      @contact2.person.organizational_permissions.where(permission_id: Permission::NO_PERMISSIONS_ID).first.archive
      @leader1.person.organizational_permissions.where(permission_id: Permission::USER_ID).first.archive

      xhr :get, :index, { :include_archived => true }
      assert_equal [@admin1.person.id, @leader1.person.id, @contact1.person.id, @contact2.person.id, @user.person.id, @contact3.person.id], assigns(:all_people).collect{|x| x.id}
    end

    should "return all admin even with archived permissions when 'Include ARchived' checkbox is checked" do
      FactoryGirl.create(:organizational_permission, organization: @org, person: @admin1.person, permission: Permission.no_permissions)
      @admin1.person.organizational_permissions.where(permission_id: Permission::NO_PERMISSIONS_ID).first.archive
      xhr :get, :index, { :include_archived => true, :permission => Permission.admin.id }
      assert_equal [@admin1.person.id, @user.person.id], assigns(:all_people).collect{|x| x.id}
    end

    should "return people sorted alphabetically by first_name" do

      xhr :get, :index, {:search=>{:meta_sort=>"first_name desc"}}
      assert_equal [@user.person.name, @contact3.person.name, @contact2.person.name, @contact1.person.name, @leader1.person.name, @admin1.person.name], assigns(:all_people).collect(&:name)

      xhr :get, :index, {:search=>{:meta_sort=>"first_name asc"}}
      assert_equal [@admin1.person.name, @leader1.person.name, @contact1.person.name, @contact2.person.name, @contact3.person.name, @user.person.name], assigns(:all_people).collect(&:name)

      xhr :get, :index, {:search=>{:meta_sort=>"last_name desc"}}
      assert_equal [@contact3.person.name, @user.person.name, @contact2.person.name, @contact1.person.name, @leader1.person.name, @admin1.person.name], assigns(:all_people).collect(&:name)

      xhr :get, :index, {:search=>{:meta_sort=>"last_name asc"}}
      assert_equal [@admin1.person.name, @leader1.person.name, @contact1.person.name, @contact2.person.name, @user.person.name, @contact3.person.name], assigns(:all_people).collect(&:name)
    end
  end

  context "Updating a person" do
    setup do
      @user = FactoryGirl.create(:user_with_auxs)
      @org = FactoryGirl.create(:organization)
      FactoryGirl.create(:organizational_permission, organization: @org, person: @user.person, permission: Permission.admin)
      sign_in @user
      @request.session[:current_organization_id] = @org.id

      @person1 = FactoryGirl.create(:person, first_name: "Jon", last_name: "Snow")
      FactoryGirl.create(:organizational_permission, organization: @org, person: @person1, permission: Permission.no_permissions)
      @email1 = FactoryGirl.create(:email_address, person: @person1, email: "person1@email.com", primary: true)
      @person2 = FactoryGirl.create(:person, first_name: "Jon", last_name: "Snow")
      @email2 = FactoryGirl.create(:email_address, person: @person2, email: "person2@email.com", primary: true)
      FactoryGirl.create(:organizational_permission, organization: @org, person: @person2, permission: Permission.no_permissions)
      @person3 = FactoryGirl.create(:person)
      @email3 = FactoryGirl.create(:email_address, person: @person3, email: "person3@email.com", primary: true)
      FactoryGirl.create(:organizational_permission, organization: @org, person: @person3, permission: Permission.no_permissions)
    end

    should "merge people when there are email duplicates (current email address edited)" do
      assert_difference("Person.count", -1) do
        put :update, {:person => { :email_addresses_attributes =>{"0" => { email: "person2@email.com", :primary => "1", :id => @email1.id}}}, :id => @person1.id}
        assert Person.where(id: @person2.id).blank?
        assert @person1.email_addresses.include? @email2
      end
    end

    should "merge people when there are email duplicates (added new email address)" do

      assert_difference("Person.count", -1) do
        put :update, {:person => {:email_address => {email: "person2@email.com", :primary => 1 }}, :id => @person1.id}
        assert Person.where(id: @person2.id).blank?
        assert @person1.email_addresses.include? @email2
      end
    end
  end

  context "Updating a person" do
    setup do
      @user, @org = admin_user_login_with_org
      @contact1 = FactoryGirl.create(:person, first_name: "Brandon", last_name: "Stark")
      @email_address = FactoryGirl.create(:email_address, person: @contact1, email: "brandonstark@email.com")
      @contact2 = FactoryGirl.create(:person, first_name: "Rickon", last_name: "Stark")
      @user.person.organizations.first.add_contact(@contact1)
      @user.person.organizations.first.add_contact(@contact2)
    end

    should "update a person" do
      put :update, id: @user.person.id, person: {first_name: 'David', last_name: 'Ang',  :current_address_attributes => { :address1 => "#41 Sgt. Esguerra Ave", :country => "Philippines"} }
      assert_redirected_to person_path(assigns(:person))
    end

    should "not be able to update a person" do
      @email_address2 = FactoryGirl.create(:email_address, person: @contact2, email: "rickonstark@email.com")
      put :update, id: @contact2.id, person: {first_name: 'Rickon', last_name: 'Stark', :email_addresses_attributes => {"0" => {email: "brandonstark@email.com", :primary => "1", :id => @email_address2.id}} }
      #assert_redirected_to person_path(assigns(:person))
    end

    #should "not be able to update a person when email is already taken" do
      #put :update, id: @contact2.id, person: {first_name: 'Rickon', last_name: 'Stark', :email_address => {email: "brandonstark@email.com", "primary"=>"1"} }
      #assert_empty @contact2.email_addresses
    #end
  end
end
