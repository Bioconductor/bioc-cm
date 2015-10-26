The crontab in all cases should be refactored according the `killPython.sh` example below.

Information on sourcing / running in Cron:  http://unix.stackexchange.com/a/27291/11917 

```
# If you absolutely have to, source configuration rather than hardocding 
# 0 5 * * * . /usr/local/bioc-cm/setup-environment.sh; /path/to/command/to/run

# Example of upgrade
# 	Goal: kill all R processes that have run for too long:
# 	
#	Initial cron job : 
# 10 * * * * /usr/bin/python /home/biocbuild/BBS/utils/killproc.py >> /home/biocbuild/bbs-3.2-bioc/log/killproc.log 2>&1
# 
#	Upgraded cron job : 
10 * * * * /usr/local/bioc-cm/killPython.sh

```
