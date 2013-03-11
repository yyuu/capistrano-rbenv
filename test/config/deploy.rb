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
  run_locally("rm -f known_hosts")
  {:user_known_hosts_file => "known_hosts"}
end

role :web, "192.168.33.10"
role :app, "192.168.33.10"
role :db,  "192.168.33.10", :primary => true

$LOAD_PATH.push("../../lib")
require "capistrano-rbenv"

namespace(:test_all) {
  task(:default) {
    find_and_execute_task("rbenv:setup")
    methods.grep(/^test_/).each do |m|
      send(m)
    end
    find_and_execute_task("rbenv:purge")
  }

  task(:test_rbenv_is_installed) {
    run("rbenv --version")
  }

  task(:test_ruby_is_installed) {
    run("rbenv exec ruby --version")
  }

  task(:test_bundler_is_installed) {
    run("rbenv exec bundle version")
  }
}

# vim:set ft=ruby sw=2 ts=2 :
