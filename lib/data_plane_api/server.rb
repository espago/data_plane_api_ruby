# typed: true
# frozen_string_literal: true

require 'json'

module DataPlaneApi
  # Wraps endpoints regarding HAProxy servers.
  module Server
    ADMIN_STATES = T.let(::Set[:ready, :maint, :drain], T::Set[Symbol])
    OPERATIONAL_STATES = T.let(::Set[:up, :down, :stopping], T::Set[Symbol])

    class << self
      # @param backend: Name of the backend
      # @param name: Name of the server whose settings will be returned.
      #   If `nil` then an array of settings of all servers under the passed `backend`
      #   will be returned.
      #: (String?, String?, Configuration?) -> Faraday::Response
      def get_runtime_settings(backend:, name: nil, config: nil)
        config ||= CONFIG
        if backend.nil? || backend.empty?
          raise ::ArgumentError, "`backend` should be present but was `#{backend.inspect}`"
        end

        path = "services/haproxy/runtime/servers/#{name}".delete_suffix('/')

        send_request(method: :get, path: path, config: config) do |req|
          req.params[:backend] = backend
        end
      end

      # @param backend: Name of the backend
      # @param name: Name of the server whose transient settings should be updated.
      #: (String?, String?, Hash[top, top], Configuration?) -> Faraday::Response
      def update_transient_settings(backend:, name:, settings:, config: nil)
        config ||= CONFIG
        if backend.nil? || backend.empty?
          raise ::ArgumentError, "`backend` should be present but was `#{backend.inspect}`"
        end
        raise ::ArgumentError, "`name` should be present but was `#{name.inspect}`" if name.nil? || name.empty?

        path = "services/haproxy/runtime/servers/#{name}"

        send_request(method: :put, path: path, config: config) do |req|
          req.params[:backend] = backend
          req.body = settings
        end
      end

      private

      #: (Symbol, String | Pathname, Configuration) { (Faraday::Request) -> void } -> Faraday::Response
      def send_request(method:, path:, config:, &block)
        request = T.let(nil, T.nilable(Faraday::Request))
        response = config.connection.public_send(method, path) do |req|
          block.call(req)
          req.options.timeout = config.timeout
          request = req
        end

        log_communication(T.must(request), response, logger: config.logger)

        response
      end

      #: (Faraday::Request, Faraday::Response, Logger?) -> void
      def log_communication(request, response, logger:)
        request_hash = {
          method:  request.http_method,
          url:     response.env.url,
          params:  request.params,
          headers: request.headers,
          body:    request.body,
        }
        response_hash = {
          status:  response.status,
          body:    response.body,
          headers: response.headers,
        }

        logger&.debug <<~REQ
          HAProxy #{request.http_method.to_s.upcase} #{response.env.url}
          -----REQUEST-----
          #{::JSON.pretty_generate request_hash}
          -----RESPONSE-----
          #{::JSON.pretty_generate response_hash}
        REQ
      end
    end
  end
end
