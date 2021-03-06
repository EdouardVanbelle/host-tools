Lazy script to check host health and notify my in case of issues

# basic usage

```
# host-tools help

usage host-tools [options] <command>

options:
	-c|--config <file>	specify config file (default: /etc/host-tools.conf)
	-r|--report <file>	specify report file (default: /var/run/host-tools.report)
	-s|--silent		mute notifications

command:


	full-check		perform a full host check (use it in cron for periodic check)
	last-report		dump last report from full-check command (ex: use in in /etc/update-motd.d)

	install-packages	install mandatory packages
	backup-etc [<path>]	backup /etc and package list to <path> destination

	notify-alive		notify host is alive (ex: use it in cron for periodic notification)
	notify-boot		notify host just boot (ex: put it in /etc/rc.local)
	notify <message>	send a custom notification

	help 			this help

```

# sample of use

```
# host-tools full-check

checking disk /dev/sda
checking disk /dev/sdb
checking docker my-mailer-instance running
checking container my-mailer-instance security
my-mailer-instance is a debian
checking docker roundcube-instance running
checking container roundcube-instance security
roundcube-instance is a debian
checking docker vtun-instance running
checking container vtun-instance security
vtun-instance is a debian
checking docker sync-vale running
checking container sync-vale security
sync-vale is an alpine (case not implemented)
check that /data-active/mail-data exists
checking no root password
mandatory package openssh-server is installed
mandatory package unattended-upgrades is installed
mandatory package postfix is installed
checking partition /dev/md2
checking partition /dev/mapper/cryptdata1
checking partition /dev/mapper/cryptdata2
raid md2 (raid1) is clean
ensure that ssh-rsa ... ed@bureau is present for root
checking security package to upgrade
checking systemd services status
mandatory service ssh.service is running
May 13 22:17:05 host-tools: full check sucess

```

# config file sample

```bash
# -------------------------------------- config

# alarm if disck space or inode space reach 75%
DISKLIMIT=75

# number of badsectors to trigger alarm
BADSECTORLIMIT=0

# we don't accept root password on this host
ALLOW_ROOT_PASWORD="NO"

# special partitions that must be mounted
PARTITIONS=("/home" "/home-backup")

# mandatory packages on system
MANDATORY_PACKAGES=("openssh-server" "unattended-upgrades")

# package that must not be installed
FORBIDDEN_PACKAGES=()

# systemd services that must be running
MANDATORY_SERVICES=("ssh.service" "script-name@ed.service")

# docker instances that must be running
MANDATORY_DOCKERS=("my-mailer-instance" "roundcube-instance" "vtun-instance" )

MANDATORY_FILES=("/home/mail-data")

# domain name to use to grab farm list
DOMAIN=""

# raid disk to mute notification in case of error (* = matchall)
SILENT_RAID=()

# disk to mute notification in case of badsector (* = matchall)
SILENT_BADSECTOR=()

# host mute notification in case of badsector (* = matchall)
SILENT_HOSTDOWN=()

# docker mute notification in case of upgrade needed (* = matchall)
SILENT_DOCKER_NEEDUPGRADE=()

# this ssh key must be present in root account
ROOT_KEYS=( 
"ssh-rsa AAAAB.... ed@desktop"
)

# SSL connections to test
SSL_CONNECTIONS=("www.example.com:443")

# warn SSL_PREVENTION_EXPIRATION days before expiration
SSL_PREVENTION_EXPIRATION=30

# here will send a message on your telegram account
WEBHOOK='https://api.telegram.org/bot.....:..../sendMessage?chat_id=.....&text='

```

