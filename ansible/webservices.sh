#!/bin/bash

echo "--- 1. Deploy Websersvers ---"
ansible-playbook plays/webservers/webservers.yml

echo "--- 1. Loadbalance ---"
ansible-playbook plays/proxy/haproxy.yml
