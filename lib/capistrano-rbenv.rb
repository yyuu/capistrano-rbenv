require "capistrano-rbenv/version"
require "capistrano/configuration"
require "capistrano/recipes/deploy/scm"

module Capistrano
  module RbEnv
    def self.extended(configuration)
      configuration.load {
        namespace(:rbenv) {
          _cset(:rbenv_path) {
            capture("echo $HOME/.rbenv").chomp()
          }
          _cset(:rbenv_bin) {
            File.join(rbenv_path, 'bin', 'rbenv')
          }
          _cset(:rbenv_cmd) { # to use custom rbenv_path, we use `env` instead of cap's default_environment.
            "env RBENV_VERSION=#{rbenv_ruby_version.dump} #{rbenv_bin}"
          }
          _cset(:rbenv_repository, 'git://github.com/sstephenson/rbenv.git')
          _cset(:rbenv_branch, 'master')

          _cset(:rbenv_plugins) {{
            "ruby-build" => { :repository => "git://github.com/sstephenson/ruby-build.git", :branch => "master" },
          }}
          _cset(:rbenv_plugins_options, {}) # for backward compatibility. plugin options can be configured from :rbenv_plugins.
          _cset(:rbenv_plugins_path) {
            File.join(rbenv_path, 'plugins')
          }
          _cset(:rbenv_ruby_version, "1.9.3-p327")

          _cset(:rbenv_use_bundler, true)
          set(:bundle_cmd) { # override bundle_cmd in "bundler/capistrano"
            rbenv_use_bundler ? "#{rbenv_cmd} exec bundle" : 'bundle'
          }

          desc("Setup rbenv.")
          task(:setup, :except => { :no_release => true }) {
            dependencies
            update
            configure
            build
            setup_bundler if rbenv_use_bundler
          }
          after 'deploy:setup', 'rbenv:setup'

          def rbenv_update_repository(destination, options={})
            configuration = Capistrano::Configuration.new()
            options = {
              :source => proc { Capistrano::Deploy::SCM.new(configuration[:scm], configuration) },
              :revision => proc { configuration[:source].head },
              :real_revision => proc {
                configuration[:source].local.query_revision(configuration[:revision]) { |cmd| with_env("LC_ALL", "C") { run_locally(cmd) } }
              },
            }.merge(options)
            variables.merge(options).each do |key, val|
              configuration.set(key, val)
            end
            source = configuration[:source]
            revision = configuration[:real_revision]
            #
            # we cannot use source.sync since it cleans up untacked files in the repository.
            # currently we are just calling git sub-commands directly to avoid the problems.
            #
            verbose = configuration[:scm_verbose] ? nil : "-q"
            run((<<-EOS).gsub(/\s+/, ' ').strip)
              if [ -d #{destination} ]; then
                cd #{destination} &&
                #{source.command} fetch #{verbose} #{source.origin} &&
                #{source.command} fetch --tags #{verbose} #{source.origin} &&
                #{source.command} reset #{verbose} --hard #{revision};
              else
                #{source.checkout(revision, destination)};
              fi
            EOS
          end

          desc("Update rbenv installation.")
          task(:update, :except => { :no_release => true }) {
            rbenv_update_repository(rbenv_path, :scm => :git, :repository => rbenv_repository, :branch => rbenv_branch)
            plugins.update
          }

          desc("Purge rbenv.")
          task(:purge, :except => { :no_release => true }) {
            run("rm -rf #{rbenv_path}")
          }

          namespace(:plugins) {
            desc("Update rbenv plugins.")
            task(:update, :except => { :no_release => true }) {
              rbenv_plugins.each do |name, repository|
                # for backward compatibility, obtain plugin options from :rbenv_plugins_options first
                options = rbenv_plugins_options.fetch(name, {})
                options = options.merge(Hash === repository ? repository : {:repository => repository})
                rbenv_update_repository(File.join(rbenv_plugins_path, name), options.merge(:scm => :git))
              end
            }
          }

          _cset(:rbenv_configure_home) { capture("echo $HOME").chomp }
          _cset(:rbenv_configure_shell) { capture("echo $SHELL").chomp }
          _cset(:rbenv_configure_files) {
            if fetch(:rbenv_configure_basenames, nil)
              [ rbenv_configure_basenames ].flatten.map { |basename|
                File.join(rbenv_configure_home, basename)
              }
            else
              bash_profile = File.join(rbenv_configure_home, '.bash_profile')
              profile = File.join(rbenv_configure_home, '.profile')
              case File.basename(rbenv_configure_shell)
              when /bash/
                [ capture("test -f #{profile.dump} && echo #{profile.dump} || echo #{bash_profile.dump}").chomp ]
              when /zsh/
                [ File.join(rbenv_configure_home, '.zshenv') ]
              else # other sh compatible shell such like dash
                [ profile ]
              end
            end
          }
          _cset(:rbenv_configure_script) {
            (<<-EOS).gsub(/^\s*/, '')
              # Configured by capistrano-rbenv. Do not edit directly.
              export PATH="#{rbenv_path}/bin:$PATH"
              eval "$(rbenv init -)"
            EOS
          }
          _cset(:rbenv_configure_signature, '##rbenv:configure')
          task(:configure, :except => { :no_release => true }) {
            if fetch(:rbenv_use_configure, true)
              script = File.join('/tmp', "rbenv.#{$$}")
              config = [ rbenv_configure_files ].flatten
              config_map = Hash[ config.map { |f| [f, File.join('/tmp', "#{File.basename(f)}.#{$$}")] } ]
              begin
                execute = []
                put(rbenv_configure_script, script)
                config_map.each { |file, temp|
                  ## (1) copy original config to temporaly file and then modify
                  execute << "( test -f #{file} || touch #{file} )"
                  execute << "cp -fp #{file} #{temp}" 
                  execute << "sed -i -e '/^#{Regexp.escape(rbenv_configure_signature)}/,/^#{Regexp.escape(rbenv_configure_signature)}/d' #{temp}"
                  execute << "echo #{rbenv_configure_signature.dump} >> #{temp}"
                  execute << "cat #{script} >> #{temp}"
                  execute << "echo #{rbenv_configure_signature.dump} >> #{temp}"
                  ## (2) update config only if it is needed
                  execute << "cp -fp #{file} #{file}.orig"
                  execute << "( diff -u #{file} #{temp} || mv -f #{temp} #{file} )"
                }
                run(execute.join(' && '))
              ensure
                remove = [ script ] + config_map.values
                run("rm -f #{remove.join(' ')}") rescue nil
              end
            end
          }

          _cset(:rbenv_platform) {
            capture((<<-EOS).gsub(/\s+/, ' ')).strip
              if test -f /etc/debian_version; then
                if test -f /etc/lsb-release && grep -i -q DISTRIB_ID=Ubuntu /etc/lsb-release; then
                  echo ubuntu;
                else
                  echo debian;
                fi;
              elif test -f /etc/redhat-release; then
                echo redhat;
              else
                echo unknown;
              fi;
            EOS
          }
          _cset(:rbenv_ruby_dependencies) {
            case rbenv_platform
            when /(debian|ubuntu)/i
              %w(git-core build-essential libreadline6-dev zlib1g-dev libssl-dev bison)
            when /redhat/i
              %w(git-core autoconf glibc-devel patch readline readline-devel zlib zlib-devel openssl bison)
            else
              []
            end
          }
          task(:dependencies, :except => { :no_release => true }) {
            unless rbenv_ruby_dependencies.empty?
              case rbenv_platform
              when /(debian|ubuntu)/i
                begin
                  run("dpkg-query -s #{rbenv_ruby_dependencies.join(' ')} > /dev/null")
                rescue
                  run("#{sudo} apt-get install -q -y #{rbenv_ruby_dependencies.join(' ')}")
                end
              when /redhat/i
                begin
                  run("rpm -qi #{rbenv_ruby_dependencies.join(' ')} > /dev/null")
                rescue
                  run("#{sudo} yum install -q -y #{rbenv_ruby_dependencies.join(' ')}")
                end
              else
                # nop
              end
            end
          }

          desc("Build ruby within rbenv.")
          task(:build, :except => { :no_release => true }) {
            ruby = fetch(:rbenv_ruby_cmd, 'ruby')
            if rbenv_ruby_version != 'system'
              run("#{rbenv_bin} whence #{ruby} | fgrep -q #{rbenv_ruby_version} || #{rbenv_bin} install #{rbenv_ruby_version}")
            end
            run("#{rbenv_cmd} exec #{ruby} --version && #{rbenv_cmd} global #{rbenv_ruby_version}")
          }

          _cset(:rbenv_bundler_gem, 'bundler')
          task(:setup_bundler, :except => { :no_release => true }) {
            gem = "#{rbenv_cmd} exec gem"
            if v = fetch(:rbenv_bundler_version, nil)
              q = "-n #{rbenv_bundler_gem} -v #{v}"
              f = "fgrep #{rbenv_bundler_gem} | fgrep #{v}"
              i = "-v #{v} #{rbenv_bundler_gem}"
            else
              q = "-n #{rbenv_bundler_gem}"
              f = "fgrep #{rbenv_bundler_gem}"
              i = "#{rbenv_bundler_gem}"
            end
            run("unset -v GEM_HOME; #{gem} query #{q} 2>/dev/null | #{f} || #{gem} install -q #{i}")
            run("#{rbenv_cmd} rehash && #{bundle_cmd} version")
          }
        }
      }
    end
  end
end

if Capistrano::Configuration.instance
  Capistrano::Configuration.instance.extend(Capistrano::RbEnv)
end

# vim:set ft=ruby ts=2 sw=2 :
