require "test_helper"

class MusicsControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get musics_index_url
    assert_response :success
  end

  test "should get new" do
    get musics_new_url
    assert_response :success
  end

  test "should get create" do
    get musics_create_url
    assert_response :success
  end
end
