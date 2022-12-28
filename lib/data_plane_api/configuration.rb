# frozen_string_literal: true

require 'faraday'
require 'logger'

module DataPlaneApi
  # Stores configuration options for the HAProxy Data Plane API.
  class Configuration
    # @return [String, URI::Generic, nil]
    attr_writer :url
    # @return [String, nil] Basic Auth username.
    attr_writer :basic_user
    # @return [String, nil] Basic Auth password.
    attr_writer :basic_password
    # @return [Logger, nil]
    attr_writer :logger
    # @return [Integer, nil]
    attr_writer :timeout
    # @return [Boolean] whether this object is used as a global store of settings
    attr_reader :global

    # @param url [String, nil]
    # @param global [Boolean] whether this object is used as a global store of settings
    # @param basic_user [String, nil] Basic Auth username.
    # @param basic_password [String, nil] Basic Auth password.
    # @param logger [Logger, nil]
    # @param timeout [Integer, nil]
    # @param parent [self, nil]
    def initialize(
      url: nil,
      global: false,
      basic_user: nil,
      basic_password: nil,
      logger: nil,
      timeout: nil,
      parent: nil
    )

      @global = global
      @url = url
      @basic_user = basic_user
      @basic_password = basic_password
      @logger = logger
      @timeout = timeout
      @parent = parent
      @connection = nil

      return unless global

      @logger ||= ::Logger.new($stdout)
      @timeout ||= 10
    end

    # @return [Faraday::Connection]
    def connection
      @connection || build_connection
    end

    # @return [void]
    def freeze
      @connection = build_connection
      super
    end

    # @return [String, URI::Generic, nil]
    def url
      return @url if @global || @url

      parent.url
    end

    # @return [String, nil] Basic Auth username.
    def basic_user
      return @basic_user if @global || @basic_user

      parent.basic_user
    end

    # @return [String, nil] Basic Auth password.
    def basic_password
      return @basic_password if @global || @basic_password

      parent.basic_password
    end

    # @return [Logger, nil]
    def logger
      return @logger if @global || @logger

      parent.logger
    end

    # @return [Integer, nil]
    def timeout
      return @timeout if @global || @timeout

      parent.timeout
    end

    # @return [self, nil]
    def parent
      return if @global

      @parent || CONFIG
    end

    private

    if ::Faraday::VERSION > '2'
      # @return [Faraday::Connection]
      def build_connection
        headers = { 'Content-Type' => 'application/json' }

        ::Faraday.new(url: "#{url}/v2/", headers: headers) do |f|
          f.request :json
          f.response :json
          f.request :authorization, :basic, basic_user, basic_password
        end
      end
    else
      # Faraday 1.x compatibility

      # @return [Faraday::Connection]
      def build_connection
        headers = { 'Content-Type' => 'application/json' }

        ::Faraday.new(url: "#{url}/v2/", headers: headers) do |f|
          f.request :json
          f.response :json
          f.request :basic_auth, basic_user, basic_password
        end
      end
    end

  end
end
