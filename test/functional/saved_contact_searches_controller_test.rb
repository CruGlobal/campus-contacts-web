require 'test_helper'

class SavedContactSearchesControllerTest < ActionController::TestCase
  
  setup do
    @user, @org = admin_user_login_with_org
  end
 
  should "get index" do
    get :index
    assert_response :success
  end
  
  test "create" do
    post :create, { :saved_contact_search => { :name => "Test", :full_path => "localhost:3000", :user_id => @user.id } }
    assert_response :redirect
    assert_equal 1, SavedContactSearch.count
  end
  
  context "updating a saved_contact_search" do
  
    should "update" do
      post :create, { :saved_contact_search => { :name => "Test", :full_path => "localhost:3000", :user_id => @user.id } }
      assert_response :redirect
      assert_equal 1, SavedContactSearch.count
      
      s = SavedContactSearch.last
      
      post :update, { :id => s.id, :saved_contact_search => { :name => "Wat", :full_path => "localhost:3000" } }
      assert_response :redirect
      
      assert_equal "Wat", SavedContactSearch.last.name
    end
    
    should "still be able to update (create) if a person deleted his search and clicked update" do
      post :create, { :saved_contact_search => { :name => "Test", :full_path => "localhost:3000", :user_id => @user.id } }
      assert_response :redirect
      assert_equal 1, SavedContactSearch.count
      
      s = SavedContactSearch.last
      
      xhr :post, :destroy, { :id => s.id }
      assert_equal " ", response.body
      assert_equal 0, SavedContactSearch.count
      
      post :update, { :id => s.id, :saved_contact_search => { :name => "Wat", :full_path => "localhost:3000" } }
      assert_response :redirect
      
      assert_equal "Wat", SavedContactSearch.last.name
    end
  end
  
  
  test "destroy" do
    post :create, { :saved_contact_search => { :name => "Test", :full_path => "localhost:3000", :user_id => @user.id } }
    assert_response :redirect
    assert_equal 1, SavedContactSearch.count
    
    s = SavedContactSearch.last
    
    xhr :post, :destroy, { :id => s.id }
    assert_equal " ", response.body
    assert_equal 0, SavedContactSearch.count
  end
  
end
