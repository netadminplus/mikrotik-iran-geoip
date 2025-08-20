# MikroTik Iran GeoIP

Automatically install and update Iran IP address ranges on MikroTik RouterOS devices.

## Features

- **One-command installation** - Single copy-paste command to install everything
- **Automatic weekly updates** - Stays current with latest IP ranges
- **Multiple sources** - Combines data from ipdeny, Parspack, and ArvanCloud
- **RFC1918 inclusion** - Automatically adds private IP ranges
- **Safe and idempotent** - Can be re-run safely anytime

## Quick Install

Copy and paste these two commands into your MikroTik terminal:

```bash
/tool fetch url="https://raw.githubusercontent.com/netadminplus/mikrotik-iran-geoip/main/installer.rsc" mode=https dst-path=installer.rsc
/import file-name=installer.rsc
```

That's it! The system will:
- Create an address list named `IRAN`
- Import all Iran IP ranges
- Add RFC1918 private ranges (10.0.0.0/8, 172.16.0.0/12, 192.168.0.0/16)
- Set up automatic weekly updates every Sunday at 03:00

## Requirements

- RouterOS v7+ (v6 might work but not tested)
- Internet access for downloading updates
- Valid system time for HTTPS certificate verification

## Troubleshooting

If you get HTTPS certificate errors due to incorrect system time:

```bash
/tool fetch url="https://raw.githubusercontent.com/netadminplus/mikrotik-iran-geoip/main/installer.rsc" mode=https check-certificate=no dst-path=installer.rsc
/import file-name=installer.rsc
```

## Management

**Manual update:**
```bash
/system script run update-iran-geoip
```

**Disable automatic updates:**
```bash
/system scheduler disable iran-geoip-weekly
```

**Completely remove:**
```bash
/system scheduler remove iran-geoip-weekly
/system script remove update-iran-geoip  
/ip firewall address-list remove [find list=IRAN]
```

## Data Sources

This project combines IP ranges from:
- [IPdeny Iran country blocks](https://www.ipdeny.com/ipblocks/data/countries/ir.zone)
- [Parspack CDN IPs](https://parspack.com/cdnips.txt)
- [ArvanCloud IPs](https://www.arvancloud.ir/fa/ips.txt)

Last updated: <!--LAST_UPDATED-->Never<!--/LAST_UPDATED-->

## Usage Examples

Use the `IRAN` address list in your firewall rules:

```bash
# Block Iran traffic
/ip firewall filter add chain=forward src-address-list=IRAN action=drop

# Allow only Iran traffic  
/ip firewall filter add chain=forward src-address-list=!IRAN action=drop

# Rate limit Iran traffic
/ip firewall mangle add chain=forward src-address-list=IRAN action=mark-connection new-connection-mark=iran-conn
```

## License

MIT License - see [LICENSE](LICENSE) file for details.

## Links

- [Persian README](README.fa.md) - راهنمای فارسی
- [Issues](../../issues) - Report problems or request features
- [Releases](../../releases) - Version history