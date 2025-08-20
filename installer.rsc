# MikroTik Iran GeoIP Installer
# This script installs and configures automatic Iran IP list updates

:local LIST "IRAN";
:local RAW "https://raw.githubusercontent.com/netadminplus/mikrotik-iran-geoip/main/iran.rsc";
:local DST "iran.rsc";
:local UPDATE_SCRIPT "update-iran-geoip";
:local SCHED_NAME "iran-geoip-weekly";

:put "Installing Iran GeoIP system...";

# Create the update script
:put "Creating update script: $UPDATE_SCRIPT";
/system script remove [find name=$UPDATE_SCRIPT];
/system script add name=$UPDATE_SCRIPT owner=admin policy=ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source={
    :local LIST "IRAN";
    :local RAW "https://raw.githubusercontent.com/netadminplus/mikrotik-iran-geoip/main/iran.rsc";
    :local DST "iran.rsc";
    
    :put "Starting Iran IP list update...";
    
    # Remove old entries
    :put "Removing old $LIST entries...";
    /ip firewall address-list remove [find list=$LIST];
    
    # Fetch latest list
    :put "Fetching latest IP list...";
    :do {
        /tool fetch url=$RAW mode=https dst-path=$DST keep-result=yes;
        :put "Successfully downloaded $DST";
    } on-error={
        :put "ERROR: Failed to download IP list";
        :error "Download failed";
    };
    
    # Import the list
    :put "Importing IP ranges...";
    :do {
        /import file-name=$DST;
        :put "Successfully imported IP ranges";
    } on-error={
        :put "ERROR: Failed to import IP list";
        :error "Import failed";
    };
    
    # Add RFC1918 ranges
    :put "Adding RFC1918 private ranges...";
    /ip firewall address-list add list=$LIST address=10.0.0.0/8 comment="RFC1918";
    /ip firewall address-list add list=$LIST address=172.16.0.0/12 comment="RFC1918";
    /ip firewall address-list add list=$LIST address=192.168.0.0/16 comment="RFC1918";
    
    # Show final count
    :local count [len [/ip firewall address-list find list=$LIST]];
    :put "Update complete! $LIST list now contains $count entries";
};

# Create weekly scheduler
:put "Setting up weekly scheduler: $SCHED_NAME";
/system scheduler remove [find name=$SCHED_NAME];
/system scheduler add name=$SCHED_NAME interval=1w start-time=03:00:00 on-event=("/system script run " . $UPDATE_SCRIPT);

:put "Running initial update...";
/system script run $UPDATE_SCRIPT;

:put "Installation complete!";
:put "- Update script: $UPDATE_SCRIPT";
:put "- Weekly scheduler: $SCHED_NAME (runs Sundays at 03:00)";
:put "- Address list: $LIST";
:put "";
:put "To manually update: /system script run $UPDATE_SCRIPT";
:put "To disable scheduler: /system scheduler disable $SCHED_NAME";
:put "To remove everything: /system scheduler remove $SCHED_NAME; /system script remove $UPDATE_SCRIPT; /ip firewall address-list remove [find list=$LIST]";
