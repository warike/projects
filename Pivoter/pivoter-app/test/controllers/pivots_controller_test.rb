require 'test_helper'

class PivotsControllerTest < ActionController::TestCase
  setup do
    @pivot = pivots(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:pivots)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create pivot" do
    assert_difference('Pivot.count') do
      post :create, pivot: { finish_date: @pivot.finish_date, start_date: @pivot.start_date, startup_id: @pivot.startup_id }
    end

    assert_redirected_to pivot_path(assigns(:pivot))
  end

  test "should show pivot" do
    get :show, id: @pivot
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @pivot
    assert_response :success
  end

  test "should update pivot" do
    patch :update, id: @pivot, pivot: { finish_date: @pivot.finish_date, start_date: @pivot.start_date, startup_id: @pivot.startup_id }
    assert_redirected_to pivot_path(assigns(:pivot))
  end

  test "should destroy pivot" do
    assert_difference('Pivot.count', -1) do
      delete :destroy, id: @pivot
    end

    assert_redirected_to pivots_path
  end
end
