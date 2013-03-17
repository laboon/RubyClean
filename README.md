Clean your Ruby codebase!

Checks for various style issues with your Ruby code.  Most of the checks were taken from B. Batsov's Ruby Style Guide ( https://github.com/bbatsov/ruby-style-guide ) and automated.

Simply run "ruby ruby_clean.rb <root_directory>" (no quotes, obviously)

RubyClean can help you find:
* Commented-out code
* Hard tabs
* Trailing whitespace
* Verbal Boolean operators
* Same-line do..end blocks
* Multi-line { .. } blocks
* Use of "for" loops
* Using ||= to initialize Boolean values
* Method definitions with empty parens
* Class variables
* Rescuing of bare exceptions
* Superfluous "then" keywords
* ... probably some other stuff

