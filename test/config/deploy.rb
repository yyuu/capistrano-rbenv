set :application, "capistrano-rbenv"
set :repository,  "."
set :deploy_to do
  File.join("/home", user, application)
end
set :deploy_via, :copy
set :scm, :none
set :use_sudo, false
set :user, "vagrant"
set :password, "vagrant"
set :ssh_options do
  {:user_known_hosts_file => "/dev/null"}
end

role :web, "192.168.33.10"
role :app, "192.168.33.10"
role :db,  "192.168.33.10", :primary => true

$LOAD_PATH.push(File.expand_path("../../lib", File.dirname(__FILE__)))
require "capistrano-rbenv"

task(:test_all) {
  find_and_execute_task("test_default")
  find_and_execute_task("test_without_global")
}

namespace(:test_default) {
  task(:default) {
    methods.grep(/^test_/).each do |m|
      send(m)
    end
  }
  before "test_default", "test_default:setup"
  after "test_default", "test_default:teardown"

  task(:setup) {
    find_and_execute_task("rbenv:setup")
  }

  task(:teardown) {
  }

  task(:test_rbenv) {
    run("rbenv --version")
  }

## standard
  task(:test_rbenv_exec) {
    rbenv.exec("ruby --version")
  }

  task(:test_run_rbenv_exec) {
    run("rbenv exec ruby --version")
  }

## with path
  task(:test_rbenv_exec_with_path) {
    rbenv.exec("ruby -e 'exit(Dir.pwd==%{/}?0:1)'", :path => "/")
  }

# task(:test_rbenv_exec_ruby_via_sudo_with_path) {
#   # capistrano does not provide safer way to invoke multiple commands via sudo.
#   rbenv.exec("ruby -e 'exit(Dir.pwd==%{/}&&Process.uid==0?0:1'", :path => "/", :via => :sudo )
# }

## via sudo
  task(:test_rbenv_exec_via_sudo) {
    rbenv.exec("ruby -e 'exit(Process.uid==0?0:1)'", :via => :sudo)
  }

  task(:test_run_sudo_rbenv_exec) {
    # we may not be able to invoke rbenv since sudo may reset $PATH.
    # if you prefer to invoke rbenv via sudo, call it with absolute path.
#   run("#{sudo} rbenv exec ruby -e 'exit(Process.uid==0?0:1)'")
    run("#{sudo} #{rbenv_cmd} exec ruby -e 'exit(Process.uid==0?0:1)'")
  }

  task(:test_sudo_rbenv_exec) {
    sudo("#{rbenv_cmd} exec ruby -e 'exit(Process.uid==0?0:1)'")
  }

## bundler
  task(:test_run_bundle) {
    run("#{bundle_cmd} version")
  }

  task(:test_run_sudo_bundle) {
    run("#{sudo} #{bundle_cmd} version")
  }

  task(:test_sudo_bundle) {
    sudo("#{bundle_cmd} version")
  }
}

namespace(:test_without_global) {
  task(:default) {
    methods.grep(/^test_/).each do |m|
      send(m)
    end
  }
  before "test_without_global", "test_without_global:setup"
  after "test_without_global", "test_without_global:teardown"

  task(:setup) {
    version_file = File.join(rbenv_path, "version")
    run("mv -f #{version_file} #{version_file}.orig")
    set(:rbenv_setup_global_version, false)
    find_and_execute_task("rbenv:setup")
    run("test \! -f #{version_file.dump}")
  }

  task(:teardown) {
    version_file = File.join(rbenv_path, "version")
    run("mv -f #{version_file}.orig #{version_file}")
  }

## standard
  task(:test_rbenv_exec_ruby) {
    rbenv.exec("ruby --version")
  }

## with path
  task(:test_rbenv_exec_ruby_with_path) {
    rbenv.exec("ruby -e 'exit(Dir.pwd==%{/}?0:1)'", :path => "/")
  }

## via sudo
  task(:test_rbenv_exec_ruby_via_sudo) {
    rbenv.exec("ruby -e 'exit(Process.uid==0?0:1)'", :via => :sudo)
  }
}

# vim:set ft=ruby sw=2 ts=2 :
