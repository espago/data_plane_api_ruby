# typed: true
# frozen_string_literal: true

require 'faraday'
require 'logger'

module DataPlaneApi
  # Stores configuration options for the HAProxy Data Plane API.
  class Configuration
    #: String | URI::Generic | nil
    attr_writer :url
    # Basic Auth username.
    #: String?
    attr_writer :basic_user
    # Basic Auth password.
    #: String?
    attr_writer :basic_password
    #: Logger?
    attr_writer :logger
    #: Integer?
    attr_writer :timeout
    # Do not make HTTP requests, just log them
    #
    #: bool
    attr_writer :mock
    # Whether this object is used as a global store of settings
    #
    #: bool
    attr_reader :global

    # @param global: whether this object is used as a global store of settings
    # @param basic_user: Basic Auth username.
    # @param basic_password: Basic Auth password.
    #: (String | URI::Generic | nil, bool, bool, String?, String?, Logger?, Integer?, Configuration?) -> void
    def initialize(
      url: nil,
      global: false,
      mock: false,
      basic_user: nil,
      basic_password: nil,
      logger: nil,
      timeout: nil,
      parent: nil
    )

      @global = global
      @mock = mock
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

    #: -> Faraday::Connection
    def connection
      @connection || build_connection
    end

    #: -> void
    def freeze
      @connection = build_connection
      super
    end

    #: -> (String | URI::Generic | nil)
    def url
      return @url if @global || @url

      parent&.url
    end

    # Basic Auth username.
    #: -> String?
    def basic_user
      return @basic_user if @global || @basic_user

      parent&.basic_user
    end

    # Basic Auth password.
    #: -> String?
    def basic_password
      return @basic_password if @global || @basic_password

      parent&.basic_password
    end

    #: -> Logger?
    def logger
      return @logger if @global || @logger

      parent&.logger
    end

    #: -> Integer?
    def timeout
      return @timeout if @global || @timeout

      parent&.timeout
    end

    #: -> bool?
    def mock
      return @mock if @global || @mock

      parent&.mock
    end

    #: -> bool
    def mock?
      Boolean(mock)
    end

    #: -> Configuration?
    def parent
      return if @global

      @parent || CONFIG
    end

    private

    if ::Faraday::VERSION > '2'
      #: -> Faraday::Connection
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

      #: -> Faraday::Connection
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
