#!/bin/sh

# Get current IP from checkip.dyndns.org, filter out current WAN IP, check
# against cached value; if different, log, send email, and update DynDNS
# (dyndns.org).

# So I'm going to give up the "responsiveness" of checking the IP every
# minute and use dyndns's checkip service, which can't be polled more
# frequently than once every 10mins. Oh well. At least it'll be more
# reliable!

### Configuration

# This is run from cron, so make sure that we can find sed, curl, mail and
# logger.
export PATH=/usr/local/bin:$PATH

# Put this whereever you want. The scripts write a couple of files here.
# If you're running from cron as a regular user, this directory needs to be
# readable and writable by that user.
cd /home/user/dyndns/scripts

# This is whatever you set up when you opened your DynDns account.
#myid="username:userpass"
#myhost="myhostname.dyndns.info"

# By default we use one of the test accounts. Set your real id and host
# above and comment these out!
myid="test:test"
myhost="test.merseine.nu"

# If you want email notification of IP address changes _and_ you have an
# MTA running on this machine, set this:
myemail=

### End of configuration

update_dyndns () {
    reason=$1
    # keep is deprecated in the API, so we leave it out
    #keep="&wildcard=NOCHG&mx=NOCHG&backmx=NOCHG"
    keep=

    svc="members.dyndns.org/nic/update"
    agent="http://notes.nimblemachines.com/show/DynamicDnsUpdater"
    response=$(curl --cacert cacert_mozilla.pem \
        -A $agent "https://$myid@$svc?hostname=$myhost&myip=$currentip$keep")

    logger -t "update-ip" "$reason: $lastip --> $currentip"
    logger -t "update-ip" "DynDns responded: $response"

    if [ "$myemail" ]; then
        echo "$response" | mail -s "$myhost IP changed: $lastip --> $currentip" $myemail
    fi

    echo $currentip > lastip
}

# The IP address part of the response from checkip.dyndns.org (an HTML
# page) looks like this: "Current IP Address: 71.34.77.71"

#currentip=$(curl "http://checkip.dyndns.org/" \
currentip=$(cat checkip.dyndns.org.html \
    | sed -e 's/\(.*Current IP Address: \)\([0-9.]\{1,\}\)\(.*\)/\2/')

# get IP from last run
lastip="0.0.0.0"
[ -f lastip ] && lastip=$(cat lastip)

# If, by some miracle, 28 days have elapsed _and_ our IP address has
# changed, don't do both updates.

# get count of weeks
[ -f weeks ] && weeks=$(cat weeks)

if [ "$weeks" == "1111" ]; then
    update_dyndns "28 days passed"
    cat /dev/null > weeks

# Make sure we got an IP before we blow away our old one and contact
# dyndns. We don't want to get blocked for abuse.

elif [ "$currentip" -a "$currentip" != "$lastip" ]; then
    update_dyndns "WAN IP changed"
fi

