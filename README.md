# Test Server with Swifter

![MIT Licence](https://img.shields.io/badge/license-MIT-blue.svg)

An experiment to test server interactions using a local test HTTP server using the [Swifter](https://github.com/httpswift/swifter) library.

Making a library which is an API client more testable with unit tests means not making calls to the actual server which would be an integration test. Not actually making real calls to a server means critical parts of the code based are not tested and code coverage is as not as high as it could be.

In this experimental project the Swifter library is used to start an HTTP server from within the test environment and use the same code which would normally make remote API calls. The HTTP server is started and runs on localhost on port 8081. Then there are 2 sample requests. One fetches an HTML path and another fetches JSON data.

## How It Works

For iOS tests an app is required in order to run the tests. The experiment demonstrated in this project is in the test files. In `TestServerTests` see `WebServer.swift` which defines and starts the HTTP server and `ServerTests.swift` which includes the 2 tests which make HTTP requests on the test server.

## Potential Improvements

Instead of returning documents and data which are assembled with the Swifter library it is possible to also load static files with this content and return that content as responses. It could more directly simulate the real behavior of making a call to the real API. For the purpose of this experiment the 2 example tests making requests from the test server are sufficient.

## App Transport Security

In order to make the tests work it is necessary to allow access to localhost without SSL as there is not configured certificate for this HTTP server. The configuration below can be added to your `info.plist` to give your app access to lcalhost without requiring SSL.

```xml
<key>NSAppTransportSecurity</key>
<dict>
  <key>NSExceptionDomains</key>
  <dict>
    <key>localhost</key>
    <dict>
      <key>NSExceptionAllowsInsecureHTTPLoads</key>
      <true/>
    </dict>
  </dict>
</dict>
```

## License

MIT

## Author

Brennan Stehling - 2016
