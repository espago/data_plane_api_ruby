# frozen_string_literal: true

require 'test_helper'

class DataPlaneApiTest < ::TestCase
  def test_that_it_has_a_version_number
    refute_nil ::DataPlaneApi::VERSION
  end
end
