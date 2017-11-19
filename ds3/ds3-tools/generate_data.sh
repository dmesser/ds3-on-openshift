#!/bin/bash

set -e

cd /ds3

export GIT_COMMITTER_NAME='anoynmous'
export GIT_COMMITTER_EMAIL='anoynmous@internet.com'

git clone -b mysql-init https://github.com/dmesser/ds3-on-openshift.git

cd ds3-on-openshift/ds3

perl Install_DVDStore.pl --db-size=${DB_SIZE} --db-size-unit=GB --db-type=${DB_TYPE} --os-type=LINUX
