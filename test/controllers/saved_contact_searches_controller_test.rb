require 'test_helper'

class SavedContactSearchesControllerTest < ActionController::TestCase
  setup do
    @user, @org = admin_user_login_with_org
  end

  test 'create' do
    post :create, saved_contact_search: { name: 'Test', full_path: 'localhost:3000', user_id: @user.id }
    assert_response :redirect
    assert_equal 1, SavedContactSearch.count
  end

  context 'update a saved_contact_search' do
    should 'has incomplete parameters' do
      post :create, saved_contact_search: { name: 'Test', full_path: 'localhost:3000', user_id: @user.id }
      assert_equal 1, SavedContactSearch.count
      s = FactoryGirl.create(:saved_contact_search, user_id: @user.id, organization_id: @org.id)
      xhr :post, :update, { saved_contact_search: { name: 'Wat', full_path: 'localhost:3000' }, saved_contact_search_id: s.id }
      assert_response :redirect
      s.reload
      assert_equal 'Wat', s.name
    end

    should 'still be able to update (create) if a person deleted his search and clicked update' do
      xhr :post, :update, { saved_contact_search: { name: 'Test', full_path: 'localhost:3000', user_id: @user.id } }
      assert_response :redirect
      assert_equal 1, SavedContactSearch.count
    end
  end

  test 'destroy' do
    post :create, saved_contact_search: { name: 'Test', full_path: 'localhost:3000', user_id: @user.id }
    assert_response :redirect
    assert_equal 1, SavedContactSearch.count

    s = SavedContactSearch.last

    xhr :post, :destroy, id: s.id
    assert_equal '', response.body
    assert_equal 0, SavedContactSearch.count
  end
end
