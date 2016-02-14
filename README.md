# Help Extract Real Phrases #

This is a CLI tool that take text input and return possible words and their
location. It can extract word segments from snake_case_phrase, camelCase or
breaking down *URLString* to "URL" and "String".

## Install ##

* Download the source code from [Github][herp].
* Build it with [Swift Package Maneger][swiftpm].
  `swift build --configuration release`
* Move the resulting binary in `herp` in `path/to/your/copy/.build/release/` to
  wherever you normally keep your CLI utilities.

[herp]: https://github.com/dduan/herp
[swiftpm]: https://github.com/apple/swift-package-manager

## Use ##

Read `herp -h`.

## License ##

This source code belongs to public domain.
