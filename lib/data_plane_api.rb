# typed: true
# frozen_string_literal: true

require 'sorbet-runtime'
require_relative 'data_plane_api/version'
require_relative 'data_plane_api/configuration'

# Contains code which implements a subset of the
# HAProxy Data Plane API.
module DataPlaneApi
  class Error < ::StandardError; end

  CONFIG = Configuration.new(global: true)

  class << self
    #: { (Configuration) -> void } -> Configuration
    def configure(&block)
      block.call(CONFIG)
      CONFIG
    end
  end
end

require_relative 'data_plane_api/server'
