#!/bin/sh -e

bundle exec vagrant up
bundle exec cap test_all
bundle exec vagrant halt

# vim:set ft=sh :
