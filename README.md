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
 * `:rbenv_plugins` - rbenv plugins to install. install `ruby-build` by default.
 * `:rbenv_repository` - repository URL of rbenv.
 * `:rbenv_ruby_dependencies` - dependency packages.
 * `:rbenv_ruby_version` - the ruby version to install. install `1.9.3-p194` by default.
 * `:rbenv_install_bundler` - controls whether installing bundler or not. `true` by default.
 * `:rbenv_install_dependencies` - controls whether installing dependencies or not. `true` if the required packages are missing.
 * `:rbenv_setup_shell` - setup rbenv in your shell config or not. `true` by default. users who are using Chef/Puppet may prefer setting this value `false`.
 * `:rbenv_setup_default_environment` - setup `RBENV_ROOT` and update `PATH` to use rbenv over capistrano. `true` by default.
 * `:rbenv_configure_files` - list of shell configuration files to be configured for rbenv. by default, guessing from user's `$SHELL` and `$HOME`.
 * `:rbenv_configure_basenames` - advanced option for `:rbenv_configure_files`. list of filename of your shell configuration files if you don't like the default value of `:rbenv_configure_files`.

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

## Author

- YAMASHITA Yuu (https://github.com/yyuu)
- Geisha Tokyo Entertainment Inc. (http://www.geishatokyo.com/)
- Nico Schottelius (http://www.nico.schottelius.org/)

## License

MIT
