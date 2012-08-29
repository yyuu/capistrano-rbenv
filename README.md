# capistrano-rbenv

a capistrano recipe to manage rubies with [rbenv](https://github.com/sstephenson/rbenv).

## Installation

Add this line to your application's Gemfile:

    gem 'capistrano-rbenv'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install capistrano-rbenv

## Usage

This recipe will install [rbenv](https://github.com/sstephenson/rbenv) and [ruby-build](https://github.com/sstephenson/ruby-build) during `deploy:setup` task.

To setup rbenv for your application, add following in you `config/deploy.rb`.

    # in "config/deploy.rb"
    require 'capistrano-rbenv'

Following options are available to manage your rbenv.

 * `:rbenv_branch` - the git branch to install `rbenv` from. use `master` by default.
 * `:rbenv_bundler_gem` - package name of `bundler`.
 * `:rbenv_bundler_version` -  version for `bundler` package.
 * `:rbenv_cmd` - the `rbenv` command.
 * `:rbenv_path` - the path where `rbenv` will be installed. use `$HOME/.rbenv` by default.
 * `:rbenv_plugins_options` - install options for rbenv plugins.
 * `:rbenv_plugins` - rbenv plugins to install. install `ruby-build` by default.
 * `:rbenv_repository` 'git://github.com/sstephenson/rbenv.git')
 * `:rbenv_ruby_dependencies` %w(build-essential libreadline6-dev zlib1g-dev libssl-dev bison))
 * `:rbenv_ruby_version` - the ruby version to install. install `1.9.3-p194` by default.
 * `:rbenv_use_bundler` - controls whether installing bundler or not. `true` by default.
 * `:rbenv_use_plugins` - controls whether installing rbenv plugins or not. `true` by default.

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

## Author

- YAMASHITA Yuu (https://github.com/yyuu)
- Geisha Tokyo Entertainment Inc. (http://www.geishatokyo.com/)

## License

MIT
