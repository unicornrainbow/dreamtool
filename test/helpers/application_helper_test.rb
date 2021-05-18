require 'test_helper'

class ApplicationHelperTest < ActionView::TestCase

  test "secure_sign_in_url" do
    assert_equal "https://test.host/session/new", secure_sign_in_url
  end

end
