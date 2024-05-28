# UniFi-Controller
A client for communicating with the UniFi Controller/

This is an unofficial project and still a work in progress (WIP) ... more to come soon.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'unifi-controller'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install unifi-controller

## Usage

```ruby
  require 'unifi-controller'
  client = UnifiController::Client.new(base_path: "https://127.0.0.1", port: 8443, username: 'your username or email', password: 'your password', verify_ssl: false)

  client.backup(days: -1) # Return backup file as a stream, no log backup
  client.backup(days: 60) # Return backup file as a stream, 60 days of logs

  # verify_ssl is used if the controller has SSL configured
```

### Endpoints
  - Login
  - Backup

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

### Tests
To run tests execute:

    $ rake test

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/trex22/unifi-controller. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the unifi-controller: project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/trex22/unifi-controller/blob/master/CODE_OF_CONDUCT.md).
