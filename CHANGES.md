v1.0.0 (Yamashita, Yuu)

* Rename some of options
  * `:rbnev_use_bundler` -> `:rbenv_install_bundler`
  * `:rbenv_use_configure` -> `:rbenv_setup_shell`
  * `:rbenv_define_default_environment` -> `:rbenv_setup_default_environment`
* Update default ruby version (1.9.3-p327 -> 1.9.3p392)
* Add rbenv convenience methods such like `rbenv.global()` and `rbenv.exec()`.
* Add `:rbenv_make_options` and `:rbenv_configure_options` to control `ruby-build`. By default, create `make` jobs as much as processor count.

v1.0.1 (Yamashita, Yuu)

* Use [capistrano-platform-resources](https://github.com/yyuu/capistrano-platform-resources) to manage platform packages.
* Add `rbenv:setup_default_environment` task.
* Join `PATH` variables with ':' on generating `:default_environment` to respect pre-defined values.
* Fix a problem during invoking rbenv via sudo with path.

v1.0.2 (Yamashita, Yuu)

* Set up `:default_environment` after the loading of the recipes, not after the task start up.
* Fix a problem on generating `:default_environment`.

v1.0.3 (Yamashita, Yuu)

* Add support for extra flavors of RedHat.
* Remove useless gem dependencies.
