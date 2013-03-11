#!/bin/sh -e

vagrant up
cap test_all
vagrant destroy -f

# vim:set ft=sh :
