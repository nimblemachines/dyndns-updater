#!/bin/sh

# We want to make sure our DynDns account doesn't expire. They allow a "no
# change" update (which is normally considered _abusive_) every 28 days,
# and expire the account after a month of inactivity. These numbers are
# chosen to make it hard to run a cron job to do this refreshing, since we
# can run something once a month, on a given day (ie, the 1st) - which
# isn't often enough - or we can run weekly, which is too often, and will
# be considered abusive.

# However! With a small amount of cleverness we can do this. 28 days is
# exactly four weeks. What if we wrote a character to a file, once a week,
# and checked when that file's contents were exactly four characters long?
# That would be 28 days, no?

# This needs to match the setting in update-ip.sh, and be writable by the
# user that will be executing this script.
cd /home/user/dyndns/scripts

# BTW, I'm _not_ using the shell builtin because on my Mac (running
# GNU bash, version 3.2.17(1)-release (i386-apple-darwin9.0))
#   echo -n "1"
# echoes "-n 1\n" - 5 characters.

# If this script is invoked as /bin/bash echo works correctly. This fix
# seems the more portable of the two - ie, it will work on non-OSX BSD
# systems - which may lack a bash shell (amazing but true).

# Add another 1; without -n we'd get a newline too
/bin/echo -n "1" >> weeks

# That's it! We'll check it in our update script.
