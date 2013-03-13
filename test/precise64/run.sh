#!/bin/sh -e

bundle exec vagrant up
bundle exec cap test_all
bundle exec vagrant destroy -f

# vim:set ft=sh :
