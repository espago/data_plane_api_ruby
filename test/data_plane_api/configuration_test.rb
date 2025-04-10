# typed: true
# frozen_string_literal: true

require 'test_helper'

module DataPlaneApi
  class ConfigurationTest < ::TestCase
    context 'global' do
      should 'have a default logger and timeout' do
        conf = Configuration.new global: true

        assert !conf.instance_variable_get(:@logger).nil?
        assert !conf.logger.nil?
        assert conf.logger.is_a?(::Logger)
        assert conf.logger.equal?(conf.instance_variable_get(:@logger))
        assert_equal ::Logger::DEBUG, conf.logger&.level

        assert_equal 10, conf.timeout
        assert conf.timeout.equal?(conf.instance_variable_get(:@timeout))
      end

      should 'not have a parent' do
        conf = Configuration.new global: true
        assert_nil conf.parent
      end
    end

    context 'local' do
      should 'not have a default logger and timeout' do
        conf = Configuration.new

        assert_nil conf.instance_variable_get(:@logger)
        assert !conf.logger.nil?
        assert_equal CONFIG.logger, conf.logger

        assert_nil conf.instance_variable_get(:@timeout)
        assert !conf.timeout.nil?
        assert_equal CONFIG.timeout, conf.timeout
      end

      should 'get inexistent options from parent' do
        super_parent = Configuration.new timeout: 28
        parent = Configuration.new parent: super_parent, basic_user: 'parent_user', basic_password: 'parent_password'
        child = Configuration.new parent: parent, basic_user: 'child_user'

        assert child.parent.equal?(parent)
        assert parent.parent.equal?(super_parent)
        assert super_parent.parent.equal?(CONFIG)

        assert_nil super_parent.basic_user
        assert_nil super_parent.basic_password
        assert_equal 28, super_parent.timeout

        assert_equal 'parent_user', parent.basic_user
        assert_equal 'parent_password', parent.basic_password
        assert_equal 28, parent.timeout

        assert_equal 'child_user', child.basic_user
        assert_equal 'parent_password', child.basic_password
        assert_equal 28, child.timeout
      end

      should 'have the global config object as parent' do
        conf = Configuration.new
        assert conf.parent.equal?(CONFIG)
      end
    end

  end
end
