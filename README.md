# Wands

A low-level WebSocket library compatible with Ruby's TCPSocket.

## Installation

Install the gem and add to the application's Gemfile by executing:

```bash
bundle add wands
```

If bundler is not being used to manage dependencies, install the gem by executing:

```bash
gem install wands
```

## Usage

### Server

```ruby
server = Wands::WebSocketServer.open('localhost', 2345)

loop do
  socket = server.accept
  socket.puts("Hello World!")
  socket.close
end
```

### Client

```ruby
socket = Wands::WebSocket.open('localhost', 2345)
socket.puts("Hello World!")
puts socket.gets
socket.close
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/ledsun/wands.
