#!/usr/bin/env bash

# Source the Bioconductor configuraiton
. /usr/local/bioc-cm/setup-environment.sh

# Staging directory is full of artifacts that get
/usr/bin/python /home/biocbuild/BBS/utils/killproc.py >> "${CM_SOFTWARE_BUILD_STAGING}"/log/killproc.log 2>&1
