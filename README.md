# DataPlaneApi Ruby

This gem provides a simple interface for the Community Edition of
the HAProxy Data Plane API.

Currently, it only supports a handful of requests that we needed.
More may be added in the future.

We encourage you to make Pull Requests with more API endpoints.

[HAProxy](https://www.haproxy.com/) is a load balancer.
The [Data Plane API](https://www.haproxy.com/documentation/dataplaneapi/community/)
can be used to manage your HAProxy config,
backends and servers.

## Installation

Install the gem and add to the application's Gemfile by executing:

    $ bundle add data_plane_api

If bundler is not being used to manage dependencies, install the gem by executing:

    $ gem install data_plane_api

## Usage

The main namespace/module of this gem is `DataPlaneApi`.

We used [this documentation](https://www.haproxy.com/documentation/dataplaneapi/community/#get-/services/haproxy/configuration/acls) as the reference for implementing this gem.

Each section of the HAProxy Data Plane API should have its own module under
`DataPlaneApi`. Each endpoint is represented as a singleton method of this module.

eg. `DataPlaneApi::Server.get_runtime_settings`.

### Configuration

In order to make requests, you need to configure
the API URL, user and password.

You can configure the gem globally.

```rb
DataPlaneApi.configure do |c|
    # REQUIRED
    c.url = 'http://example.com'
    c.basic_user = 'api_user'
    c.basic_password = 'api_password'
    # OPTIONAL
    c.timeout = 25 # request timeout in seconds
    c.logger = Logger.new($stdout) # custom logger
end
```

These settings will be used by default in
all requests without local configuration
objects.

You can also create configuration objects
and pass them as arguments to particular request
method calls.

```rb
# create a config object
config = DataPlaneApi::Configuration.new(
    url: 'http://example.com',
    basic_user: 'api_user'
    basic_password: 'api_password'
)

# make a request
response = DataPlaneApi::Server.get_runtime_settings(
    backend: 'foo',
    config: config # use the configuration object
)
```

A configuration object like that may contain
incomplete configuration data. Any missing
options will be inherited from the global
configuration object.

For example, let's say, that you've got a global
configuration like that.

```rb
DataPlaneApi.configure do |c|
    c.url = 'http://example.com'
    c.basic_user = 'api_user'
    c.basic_password = 'api_password'
    c.timeout = 25 # request timeout in seconds
end
```

You want to change the timeout to 2 seconds
for a single request. You can achieve it
by creating a new config object which contains
only the new data, that you want to change when
compared to the global config. The rest will
be inherited.

```rb
config = DataPlaneApi::Configuration.new(timeout: 2)
config.timeout #=> 2
config.url #=> 'http://example.com'
config.basic_user #=> 'api_user'
```

### Response

You will always get a `Faraday::Response` object as a return value
from a request call.

The response body will be parsed to Ruby structures (Hash, Array, Integer, etc.)

You may want to look at the [documentation of the faraday gem](https://lostisland.github.io/faraday/usage/) for more
details.

### Server

Server endpoints live under the `DataPlaneApi::Server` module.

### Runtime settings

[Return an array of runtime servers' settings](https://www.haproxy.com/documentation/dataplaneapi/community/#get-/services/haproxy/runtime/servers)

You can get an array of runtime servers' settings like so.

```rb
# @type [Faraday::Response]
response = DataPlaneApi::Server.get_runtime_settings(backend: 'my_backend_name')

response.status #=> 200
response.headers #=> {"server"=>"Fly/c375678 (2021-04-23)", "content-type"=> ...
response.body #=> [{"address":"12.0.5.102","admin_state":"ready","id":"1","name":"foo_bar1","operational_state":"up","port":4512}]
```

[Return one server runtime settings](https://www.haproxy.com/documentation/dataplaneapi/community/#get-/services/haproxy/runtime/servers/-name-)

You can provide the name of a particular server to get only its
settings.

```rb
# @type [Faraday::Response]
response = DataPlaneApi::Server.get_runtime_settings(backend: 'my_backend_name', name: 'my_server_name')

response.status #=> 200
response.headers #=> {"server"=>"Fly/c375678 (2021-04-23)", "content-type"=> ...
response.body #=> [{"address":"12.0.5.102","admin_state":"ready","id":"1","name":"foo_bar1","operational_state":"up","port":4512}]
```

You can override the global config by providing a config object.

```rb
# create a config object
config = DataPlaneApi::Configuration.new(timeout: 2)

response = DataPlaneApi::Server.get_runtime_settings(
    config: config # use the new config
    backend: 'my_backend_name',
    name: 'my_server_name'
)
```

### Transient settings

[Replace server transient settings](https://www.haproxy.com/documentation/dataplaneapi/community/#put-/services/haproxy/runtime/servers/-name-)

You can replace server transient settings like so.

```rb
# @type [Faraday::Response]
response = DataPlaneApi::Server.get_runtime_settings(
    backend: 'my_backend_name',
    name: 'my_server_name',
    settings: {
        admin_state: 'ready',
        operational_state: 'up'
    }
)

response.status #=> 200
response.headers #=> {"server"=>"Fly/c375678 (2021-04-23)", "content-type"=> ...
response.body #=> [{"address":"12.0.5.102","admin_state":"ready","id":"1","name":"foo_bar1","operational_state":"up","port":4512}]
```

You can override the global config by providing a config object.

```rb
# create a config object
config = DataPlaneApi::Configuration.new(timeout: 2)

response = DataPlaneApi::Server.get_runtime_settings(
    config: config # use the new config
    backend: 'my_backend_name',
    name: 'my_server_name',
    settings: {
        admin_state: 'ready',
        operational_state: 'up'
    }
)
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/espago/data_plane_api_ruby.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
