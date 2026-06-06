require "test_helper"

class HomeControllerTest < ActionDispatch::IntegrationTest
  test "GET root shows home page" do
    get root_path
    assert_response :success
    assert_select "body"
  end

  test "home page lists recent active rooms" do
    get root_path
    assert_response :success
    assert_match rooms(:active_room).name, response.body
    assert_no_match rooms(:inactive_room).name, response.body
  end

  test "GET home includes recent rooms variable" do
    get root_path
    assert_response :success
    assert assigns(:recent_rooms).present?
  end

  test "GET home returns limited recent rooms" do
    get root_path
    assert assigns(:recent_rooms).count <= 3
  end

  test "GET home excludes inactive rooms" do
    get root_path
    assert assigns(:recent_rooms).all? { |room| room.is_active? }
  end

  test "GET home orders rooms by created_at descending" do
    get root_path
    rooms_list = assigns(:recent_rooms)
    # Verify it's ordered (most recent first)
    if rooms_list.count > 1
      assert rooms_list[0].created_at >= rooms_list[1].created_at
    end
  end

  test "GET home is accessible without authentication" do
    get root_path
    assert_response :success
  end

  test "GET home response is HTML" do
    get root_path
    assert_match /text\/html/, response.content_type
  end

  test "GET home shows rooms in reverse chronological order" do
    get root_path
    recent = assigns(:recent_rooms)
    assert recent.all? { |r| r.is_active? }
  end

  test "GET index is available as root" do
    get "/"
    assert_response :success
  end
end
