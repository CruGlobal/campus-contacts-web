require 'test_helper'

class LabelsControllerTest < ActionController::TestCase
  context "Before logging in" do
    should "redirect on update" do
      user = Factory(:person)
      put :update, id: Label.first.id
      assert_redirected_to '/users/sign_in'
    end
  end

  context "After logging in a person with orgs" do
    setup do
      @user = Factory(:user_with_auxs)
      @organization = @user.person.organizational_permissions.first.organization
      @test_label = Label.create!(:name => 'member', organization_id: @organization.id)
      sign_in @user
    end

    should "show all the system labels for non cru org" do
      @organization.update_attribute('ancestry','2')
      get :index, :id => @organization.id
      system_labels = assigns(:system_labels).collect { |label| label.i18n }
      organizational_labels = assigns(:organizational_labels).collect { |label| label.i18n }
      assert_response :success, @response.body
      assert_equal ["involved", "leader"], system_labels
    end

    should "show all the system labels for cru org" do
      @organization.update_attribute('ancestry','1')
      get :index, :id => @organization.id
      system_labels = assigns(:system_labels).collect { |label| label.i18n }
      organizational_labels = assigns(:organizational_labels).collect { |label| label.i18n }
      assert_response :success, @response.body
      assert_equal ["involved", "engaged_disciple", "leader"], system_labels
    end

    should "should get new" do
      get :new
      assert_response :success
    end

    context ", creating a label" do
      should "create a label" do
        assert_difference('Label.count') do
          post :create, :label => { "name" => "label one", "i18n" => "label one" }
        end
        assert_redirected_to labels_path
      end

      should "not create a label with missing required fields" do
        assert_no_difference('Label.count') do
          post :create
        end
        assert_template "labels/new"
      end

      should "not create a label if it's already created in the organization (same name and org)" do
        label = Factory(:label, organization: @organization)

        assert_no_difference 'Label.count' do
          post :create_now, { :name => label.name }
        end

        assert_equal I18n.t('contacts.index.add_label_exists'), assigns(:msg_alert)

      end

      should "not create a label if name params is absent" do
        assert_no_difference 'Label.count' do
          post :create_now
        end

        assert_equal I18n.t('contacts.index.add_label_empty'), assigns(:msg_alert)

      end
    end

    should "create a label using ajax" do
      assert_difference('Label.count') do
        xhr :post, :create_now, :name => "label one"
      end
    end

    should "create a label" do
      assert_difference('Label.count') do
        post :create, :label => { "name" => "label one", "i18n" => "label one" }
      end
      assert_redirected_to labels_path
    end

    should "should get edit" do
      get :edit, :id => @test_label.id
      assert_response :success
    end

    context ", updating a label" do
      should "update a label" do
        put :update, :id => @test_label.id, :label => { "i18n" => "label two" }
        assert_equal 'label two', assigns(:label).i18n
        assert_redirected_to labels_path
      end

      should "not update a label with missing required fields" do
        put :update, :id => @test_label.id, :label => { "name" => nil }
        assert_template "labels/edit"
      end
    end

    should "destroy a label" do
      assert_difference('Label.count', -1) do
        delete :destroy, :id => @test_label.id
      end
      assert_redirected_to labels_path
    end
  end
end
