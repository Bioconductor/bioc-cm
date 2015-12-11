# bioc-cm [![Build Status](https://travis-ci.org/Bioconductor/bioc-cm.svg?branch=master)](https://travis-ci.org/Bioconductor/bioc-cm)

This project has been created to help with this task : https://github.com/Bioconductor/BBS/issues/11 .

#### Usage
```
. setup-environment.sh
```

#### Implementation
The only side effect of `setup-environment.sh` should be to export environment variables.  We should use them to automate daily tasks on the controller nodes (`zin1` and `zin2`), but prefer properties files for use in code.  Properties files
are platform independent and are a much easier to use and maintain in the SPB, BBS, and other Python & Ruby scripts.
