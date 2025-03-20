This is a sample of running wands as a socket client using ruby.wasm in the browser.

Prepare a wasm binary that includes the wands gem.

```
bundle install
bundle exec rbwasm build --ruby-version 3.4 -o dist/ruby+gems.wasm
```

Please wait half an hour.

Start the echo server:

```shell
bundle exec ../echo_server.rb
```

Start a HTTP server:

```shell
ruby -run -e httpd . -p 8000
```

Open http://localhost:8000 .
