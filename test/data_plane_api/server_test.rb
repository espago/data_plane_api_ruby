# typed: true
# frozen_string_literal: true

require 'test_helper'

module DataPlaneApi
  class ServerTest < ::TestCase
    should 'get runtime settings of all servers when backend does not exist' do
      response = http_cassette do
        Server.get_runtime_settings(backend: 'lolo', config: config)
      end

      assert_equal 200, response.status
      assert response.body.is_a?(::Array)
      assert_equal 0, response.body.length
    end

    should 'get runtime settings of all servers' do
      response = http_cassette do
        Server.get_runtime_settings(backend: 'foo_bar', config: config)
      end

      assert_equal 200, response.status
      assert response.body.is_a?(::Array)
      assert_equal 2, response.body.length

      server = response.body.first
      assert_equal 'ready', server['admin_state']
      assert_equal 'up', server['operational_state']
      assert_equal 'foo_bar1', server['name']
      assert_equal '12.0.5.102', server['address']
      assert_equal 4512, server['port']

      server = response.body.last
      assert_equal 'ready', server['admin_state']
      assert_equal 'up', server['operational_state']
      assert_equal 'foo_bar2', server['name']
      assert_equal '12.0.5.103', server['address']
      assert_equal 4512, server['port']
    end

    should 'get runtime settings of one server' do
      response = http_cassette do
        Server.get_runtime_settings(backend: 'foo_bar', name: 'foo_bar1', config: config)
      end

      assert_equal 200, response.status
      assert response.body.is_a?(::Hash)

      server = response.body
      assert_equal 'ready', server['admin_state']
      assert_equal 'up', server['operational_state']
      assert_equal 'foo_bar1', server['name']
      assert_equal '12.0.5.102', server['address']
      assert_equal 4512, server['port']
    end

    should 'get runtime settings of one server which does not exist' do
      response = http_cassette do
        Server.get_runtime_settings(backend: 'foo_bar', name: 'lolo', config: config)
      end

      assert_equal 500, response.status
      assert response.body.is_a?(::Hash)

      body = response.body
      assert_equal 500, body['code']
      assert_equal 'no data for foo_bar/lolo: not found', body['message']
    end

    should 'update admin_state of a server' do
      http_cassette do
        response = Server.get_runtime_settings(backend: 'foo_bar', name: 'foo_bar1', config: config)

        assert_equal 200, response.status
        assert response.body.is_a?(::Hash)

        server = response.body
        assert_equal 'ready', server['admin_state']
        assert_equal 'up', server['operational_state']
        assert_equal 'foo_bar1', server['name']
        assert_equal '12.0.5.102', server['address']
        assert_equal 4512, server['port']

        response =
          Server.update_transient_settings(
            backend:  'foo_bar',
            name:     'foo_bar1',
            settings: { admin_state: :drain },
            config:   config,
          )

        assert_equal 200, response.status
        assert response.body.is_a?(::Hash)

        server = response.body
        assert_equal 'drain', server['admin_state']
        assert_equal 'up', server['operational_state']
        assert_equal 'foo_bar1', server['name']
        assert_equal '12.0.5.102', server['address']
        assert_equal 4512, server['port']
      end
    end

    private

    def config
      Configuration.new(
        url:            'http://example.com',
        basic_user:     '2879fytdsgfhjwdf',
        basic_password: 'piqoewygtf092437r',
      )
    end
  end
end
