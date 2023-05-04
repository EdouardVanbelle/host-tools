Lazy script to check host health and notify my in case of issues

# basic usage

```

# host-tools help
usage host-tools [options] <command>

options:
	-c|--config <file>	specify config file (default: /etc/host-tools.conf)
	-r|--report <file>	specify report file (default: /var/lib/host-tools/host-tools.report)
	-s|--silent		mute notifications

command:

	check-list		list check available
	<check...>		call directly a check (list available on check-list)
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

== check_cpusanity ==
check load avg in 15min
check for blocked processes (in IOWait for example)

== check_disk_health ==
checking sd disk sda
sda seems to be a HDD
INFO: Reallocated Sector Count: 0
INFO: Spin Retry Count: 0
INFO: Temperature Celsius: 35
INFO: Reported command timeout: 0
INFO: Current Pending Sector: 0
checking sd disk sdb
sdb seems to be a HDD
INFO: Reallocated Sector Count: 0
INFO: Spin Retry Count: 0
INFO: Temperature Celsius: 39
INFO: Reported command timeout: 0
INFO: Current Pending Sector: 0

== check_docker ==

checking that mandatory docker my-mailer-instance running
checking container my-mailer-instance security
my-mailer-instance is a debian debian

checking that mandatory docker roundcube-instance running
checking container roundcube-instance security
roundcube-instance is a debian debian

checking that mandatory docker sync-vale running
checking container sync-vale security
sync-vale is an alpine

checking that mandatory docker sync-ed running
checking container sync-ed security
sync-ed is an alpine

checking that mandatory docker bitwarden-nginx running
checking container bitwarden-nginx security
bitwarden-nginx is a debian debian
Inst libxml2 [2.9.10+dfsg-6.7+deb11u3] (2.9.10+dfsg-6.7+deb11u4 Debian:11.7/stable, Debian-Security:11/stable-security [amd64])
Conf libxml2 (2.9.10+dfsg-6.7+deb11u4 Debian:11.7/stable, Debian-Security:11/stable-security [amd64])
SILENT ALERT: container bitwarden-nginx need security upgrade (or a rebuild)

checking that mandatory docker bitwarden-mssql running
checking container bitwarden-mssql security
ignoring bitwarden-mssql ubuntu

checking that mandatory docker bitwarden-sso running
checking container bitwarden-sso security
bitwarden-sso is a debian debian

checking that mandatory docker traefik running
checking container traefik security
traefik is an alpine
libcrypto3-3.0.8-r3                     < 3.0.8-r4
libssl3-3.0.8-r3                        < 3.0.8-r4
SILENT ALERT: container traefik need upgrade (or a rebuild)

check for looping containers
check for dead containers
check for OOMKilled containers
check for unhealthy containers

== check_farm ==
discovering mydomain.tld farm using DNS...
checking server serverx.mydomain.tld (ping)
ping: serverx.mydomain.tld is alive
checking server servery.mydomain.tld (ping)
ping: servery.mydomain.tld is alive

== check_file_age ==
checking /data/example/file.ext is not older than 30 minutes
file /data/example/file.ext is less than 30 min old

== check_file_exists ==
checking that /data/example exists

== check_github_releases ==

checking github syncthing/syncthing, current release v1.23.4
using cache /var/lib/host-tools/github.syncthing.syncthing.latest
github syncthing/syncthing release match (v1.23.4)

checking github bitwarden/self-host, current release v2023.4.2
using cache /var/lib/host-tools/github.bitwarden.self-host.latest
github bitwarden/self-host release match (v2023.4.2)

checking github traefik/traefik, current release v2.10.1
using cache /var/lib/host-tools/github.traefik.traefik.latest
github traefik/traefik release match (v2.10.1)

== check_kernel_crit_message ==
check critical kernel message since 3 days

== check_last_backup ==

== check_mmc_health ==
no MMC found [ignoring test]

== check_mount_points ==
checking partition /data2 is mounted
checking partition /data1 is mounted

== check_need_reboot ==

== check_net_devices ==
checking network devices
checking physical device eth0
device eth0 is in good health (no error, no collision)
checking physical device eth1
device eth1 is not connected

== check_no_root_password ==
checking no root password

== check_oomkilled ==
check oomkilled process since 1 day

== check_packages ==
mandatory package openssh-server is installed
mandatory package unattended-upgrades is installed
mandatory package postfix is installed

== check_partition_space ==
checking partition /dev/md2
/dev/md2 size ok (40 %)
/dev/md2 inode size ok (9 %)
checking partition /dev/mapper/cryptdata1
/dev/mapper/cryptdata1 size ok (20 %)

== check_partition_writable ==

== check_raid ==
raid md2 (raid1) is clean

== check_rbl ==
123.123.123.123 is (rbl)-clean on dnsbl.httpbl.org
123.123.123.123 is (rbl)-clean on cbl.abuseat.org
123.123.123.123 is (rbl)-clean on dnsbl.sorbs.net
123.123.123.123 is (rbl)-clean on bl.spamcop.net
123.123.123.123 is (rbl)-clean on zen.spamhaus.org

== check_root_sshkeys ==
ensure that ssh-rsa ... ed@my-pretty-laptop is present for root

== check_security_upgrade ==
checking security package to upgrade

== check_sensors ==
checking sensors (like temperature)
sensor 'pch_haswell-virtual-0 > Adapter: Virtual device > temp1: > temp1' is ok (54 < 80)
sensor 'coretemp-isa-0000 > Adapter: ISA adapter > Package id 0: > temp1' is ok (33 < 88)
sensor 'Core 0: > temp2' is ok (33 < 88)
sensor 'Core 1: > temp3' is ok (33 < 88)
sensor 'Core 2: > temp4' is ok (33 < 88)
sensor 'Core 3: > temp5' is ok (33 < 88)

== check_services ==
checking systemd services status
mandatory service ssh.service is running

== check_ssl ==
checking service.mydomain.tld port 443
checking otherservice.mydomain.tld port 443


full check sucess
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

# list of file that should be recent (format: file:expiration-in-minutes)
FILE_AGE=("/data/example/myfile.ext:15")

# check presence of files
MANDATORY_FILES=("/data/example")

# mandatory packages on system
MANDATORY_PACKAGES=("openssh-server" "unattended-upgrades")

# package that must not be installed
FORBIDDEN_PACKAGES=()

# systemd services that must be running
MANDATORY_SERVICES=("ssh.service" "script-name@ed.service")

# docker instances that must be running
MANDATORY_DOCKERS=("my-mailer-instance" "roundcube-instance" "vtun-instance" )

MANDATORY_FILES=("/home/mail-data")

# domain name to use to grab farm list (otherwise use HOSTS=() array )
DOMAIN="mydomain.tld"

# raid disk to mute notification in case of error (* = matchall)
SILENT_RAID=()

# disk to mute notification in case of badsector (* = matchall)
SILENT_BADSECTOR=()

# host mute notification in case of badsector (* = matchall)
SILENT_HOSTDOWN=()

# docker mute notification in case of upgrade needed (* = matchall)
SILENT_DOCKER_NEEDUPGRADE=("*")

# this ssh key must be present in root account
ROOT_KEYS=( 
"ssh-rsa AAAAB.... ed@desktop"
)

# SSL connections to test
SSL_CONNECTIONS=("www.example.com:443")

# warn SSL_PREVENTION_EXPIRATION days before expiration
SSL_PREVENTION_EXPIRATION=30

# check RBL black list (is IP considered as spammer or similar ?)
IP_RBLCHECK=("123.123.123.123")

# monitor github new releases (format: owner|repository|release) 
# (helpful to ensure your are using latest repos) (Work in progress, format may change)
GITHUB_RELEASES=( 
	"syncthing|syncthing|v1.23.4" 
	"bitwarden|self-host|v2023.4.2" 
	"traefik|traefik|v2.10.1" 
)

# here will send a message on your telegram account
WEBHOOK='https://api.telegram.org/bot.....:..../sendMessage?chat_id=.....&text='

```

