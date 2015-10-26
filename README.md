# bioc-cm [![Build Status](https://travis-ci.org/Bioconductor/bioc-cm.svg?branch=master)](https://travis-ci.org/Bioconductor/bioc-cm)

This project has been created to solve the following problem : https://github.com/Bioconductor/BBS/issues/11 .

#### Usage
```
. setup-environment.sh
```

#### Implementation
The only side effect of `setup-environment.sh` should be to export environment variables.  This will
allow us to use it (or some later iteration) in other tools (e.g. the BBS, Python & Ruby scripts).

#### Installation
This repository is cloned on Linux nodes to `/usr/local/bioc-cm`, and each user has the following in
their `.bash_profile`:
```
# '.' is more standard than using "source"
. /usr/local/bioc-cm/setup-environment.sh
```

_More info coming soon!_
