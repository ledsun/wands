This is a sample of running wands as a socket client using ruby.wasm in the browser.

Prepare a wasm binary that includes the wands gem.
at project root:

```
bundle exec rake wasm:build
```

Please wait half an hour.

```
cp dist/ruby+wands.wasm examples/ruby_wasm/dist
```

Start the echo server:

```shell
bundle exec ../echo_server.rb
```

Start a HTTP server:

```shell
ruby -run -e httpd . -p 8000
```

Open http://localhost:8000 .
