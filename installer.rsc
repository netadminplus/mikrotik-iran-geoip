# MikroTik Iran GeoIP Installer - Simple Version
:local LIST "IRAN"
:local RAW "https://raw.githubusercontent.com/netadminplus/mikrotik-iran-geoip/main/iran.rsc"
:local DST "iran.rsc"
:local UPDATE_SCRIPT "update-iran-geoip"
:local SCHED_NAME "iran-geoip-weekly"

:put "Installing Iran GeoIP system..."

# Remove existing script and scheduler
/system script remove [find name=$UPDATE_SCRIPT]
/system scheduler remove [find name=$SCHED_NAME]

# Create the update script with simple syntax
/system script add name=$UPDATE_SCRIPT owner=admin policy=ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source="
:local LIST \"IRAN\"
:local RAW \"https://raw.githubusercontent.com/netadminplus/mikrotik-iran-geoip/main/iran.rsc\"
:local DST \"iran.rsc\"

:put \"Starting Iran IP list update...\"

/ip firewall address-list remove [find list=\$LIST]

:put \"Fetching latest IP list...\"
/tool fetch url=\$RAW mode=https dst-path=\$DST keep-result=yes

:put \"Importing IP ranges...\"
/import file-name=\$DST

:put \"Adding RFC1918 private ranges...\"
/ip firewall address-list add list=\$LIST address=10.0.0.0/8 comment=\"RFC1918\"
/ip firewall address-list add list=\$LIST address=172.16.0.0/12 comment=\"RFC1918\"
/ip firewall address-list add list=\$LIST address=192.168.0.0/16 comment=\"RFC1918\"

:local count [len [/ip firewall address-list find list=\$LIST]]
:put (\"Update complete! \" . \$LIST . \" list now contains \" . \$count . \" entries\")
"

# Create weekly scheduler
/system scheduler add name=$SCHED_NAME interval=1w start-time=03:00:00 on-event=("/system script run " . $UPDATE_SCRIPT)

:put "Running initial update..."
/system script run $UPDATE_SCRIPT

:put "Installation complete!"
:put ("Update script: " . $UPDATE_SCRIPT)
:put ("Weekly scheduler: " . $SCHED_NAME)
:put ("Address list: " . $LIST)
