{
:put "Downloading and installing Iran GeoIP system...";
/tool fetch url="https://raw.githubusercontent.com/netadminplus/mikrotik-iran-geoip/main/installer.rsc" mode=https dst-path=temp_installer.rsc;
/import file-name=temp_installer.rsc;
/file remove temp_installer.rsc;
:put "Bootstrap complete!";
}
