#!/bin/sh -e

vagrant up
bundle exec cap test_all
vagrant halt

# vim:set ft=sh :
