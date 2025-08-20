:put "Installing Iran GeoIP system..."

:local LIST "IRAN"
:local RAW "https://raw.githubusercontent.com/netadminplus/mikrotik-iran-geoip/main/iran.rsc"
:local DST "iran.rsc"
:local UPDATE_SCRIPT "update-iran-geoip"
:local SCHED_NAME "iran-geoip-weekly"

/system script remove [find name=$UPDATE_SCRIPT]
/system scheduler remove [find name=$SCHED_NAME]

/system script add name=$UPDATE_SCRIPT source=":local LIST \"IRAN\"\r\n:local RAW \"https://raw.githubusercontent.com/netadminplus/mikrotik-iran-geoip/main/iran.rsc\"\r\n:local DST \"iran.rsc\"\r\n:put \"Starting Iran IP list update...\"\r\n/ip firewall address-list remove [find list=\$LIST]\r\n:put \"Fetching latest IP list...\"\r\n/tool fetch url=\$RAW mode=https dst-path=\$DST keep-result=yes\r\n:put \"Importing IP ranges...\"\r\n/import file-name=\$DST\r\n:put \"Adding RFC1918 private ranges...\"\r\n/ip firewall address-list add list=\$LIST address=10.0.0.0/8 comment=\"RFC1918\"\r\n/ip firewall address-list add list=\$LIST address=172.16.0.0/12 comment=\"RFC1918\"\r\n/ip firewall address-list add list=\$LIST address=192.168.0.0/16 comment=\"RFC1918\"\r\n:local count [len [/ip firewall address-list find list=\$LIST]]\r\n:put (\"Update complete! \" . \$LIST . \" list now contains \" . \$count . \" entries\")"

/system scheduler add name=$SCHED_NAME interval=1w start-time=03:00:00 on-event=("/system script run " . $UPDATE_SCRIPT)

:put "Running initial update..."
/system script run $UPDATE_SCRIPT

:put "Installation complete!"
:put ("Update script: " . $UPDATE_SCRIPT)
:put ("Weekly scheduler: " . $SCHED_NAME)
:put ("Address list: " . $LIST)
