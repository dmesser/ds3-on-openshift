#!/bin/bash

set -e

cd /ds3

git clone -b mysql-init https://github.com/dmesser/ds3-on-openshift.git

cd ds3-on-openshift/ds3

perl Install_DVDStore.pl --db-size=${DB_SIZE} --db-size-unit=GB --db-type=${DB_TYPE} --os-type=LINUX
