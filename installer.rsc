{
:local LIST "IRAN";
:local RAW "https://raw.githubusercontent.com/netadminplus/mikrotik-iran-geoip/main/iran.rsc";
:local DST "iran.rsc";
:local UPDATESCRIPT "update_iran_geoip";
:local SCHEDNAME "iran_geoip_weekly";

:put "Removing old IRAN entries (keeping custom entries with comments)...";
/ip firewall address-list remove [find list=$LIST and comment=""];

:put "Downloading Iran IP list...";
/tool fetch url=$RAW mode=https dst-path=$DST keep-result=yes;

:put "Importing Iran IPs...";
/import file-name=$DST;

:put "Adding RFC1918 ranges...";
:if ([len [/ip firewall address-list find list=$LIST and address=10.0.0.0/8]] = 0) do={/ip firewall address-list add list=$LIST address=10.0.0.0/8 comment="RFC1918"};
:if ([len [/ip firewall address-list find list=$LIST and address=172.16.0.0/12]] = 0) do={/ip firewall address-list add list=$LIST address=172.16.0.0/12 comment="RFC1918"};
:if ([len [/ip firewall address-list find list=$LIST and address=192.168.0.0/16]] = 0) do={/ip firewall address-list add list=$LIST address=192.168.0.0/16 comment="RFC1918"};

:put "Creating update script...";
/system script remove [find name=$UPDATESCRIPT];
/system script add name=$UPDATESCRIPT source=":local LIST \"IRAN\"; :local RAW \"https://raw.githubusercontent.com/netadminplus/mikrotik-iran-geoip/main/iran.rsc\"; :local DST \"iran.rsc\"; /ip firewall address-list remove [find list=\$LIST and comment=\"\"]; /tool fetch url=\$RAW mode=https dst-path=\$DST keep-result=yes; /import file-name=\$DST; :if ([len [/ip firewall address-list find list=\$LIST and address=10.0.0.0/8]] = 0) do={/ip firewall address-list add list=\$LIST address=10.0.0.0/8 comment=\"RFC1918\"}; :if ([len [/ip firewall address-list find list=\$LIST and address=172.16.0.0/12]] = 0) do={/ip firewall address-list add list=\$LIST address=172.16.0.0/12 comment=\"RFC1918\"}; :if ([len [/ip firewall address-list find list=\$LIST and address=192.168.0.0/16]] = 0) do={/ip firewall address-list add list=\$LIST address=192.168.0.0/16 comment=\"RFC1918\"}";

:put "Creating weekly scheduler...";
/system scheduler remove [find name=$SCHEDNAME];
/system scheduler add name=$SCHEDNAME interval=1w start-time=03:00:00 on-event=("/system script run " . $UPDATESCRIPT);

:local count [len [/ip firewall address-list find list=$LIST]];
:put ("Installation complete! IRAN list contains " . $count . " entries");
:put ("Update script: " . $UPDATESCRIPT);
:put ("Weekly scheduler: " . $SCHEDNAME);
:put "NOTE: Add comments to your custom IPs to prevent removal during updates";
}
