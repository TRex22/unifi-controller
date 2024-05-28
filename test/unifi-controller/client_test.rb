require "test_helper"

class UnifiControllerTest < Minitest::Test
  def test_that_it_has_a_version_number
    refute_nil UnifiController::VERSION
  end

  def test_that_the_client_has_compatible_api_version
    assert_equal 'v1', UnifiController::Client.compatible_api_version
  end

  def test_that_the_client_has_api_version
    assert_equal 'v1 2024-05-28', UnifiController::Client.api_version
  end
end
