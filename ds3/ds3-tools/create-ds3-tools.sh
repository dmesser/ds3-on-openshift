#!/bin/bash

set -e

oc create -f ds3-tools-build-config.yml

oc start-build ds3-tools --follow
