# Set things up automatically.

here=$(pwd)

for f in crontab update-ip.sh count-weeks.sh; do
    sed -e "s#\$scriptdir#$here#g" < $f.in > $f
done
chmod 755 update-ip.sh count-weeks.sh

