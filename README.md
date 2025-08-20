[فارسی](https://github.com/netadminplus/mikrotik-iran-geoip/blob/main/README.fa.md)
# MikroTik Iran GeoIP List

Automatically install and update Iran IP address ranges on MikroTik RouterOS devices.

## Features

- **One-command installation** - Single copy-paste command to install everything
- **Automatic weekly updates** - Stays current with latest IP ranges
- **Multiple sources** - Combines data from ipdeny, Parspack, and ArvanCloud
- **RFC1918 inclusion** - Automatically adds private IP ranges
- **Safe and idempotent** - Can be re-run safely anytime
- **Custom IP preservation** - Keeps user-added IPs with comments during updates
- **System note tracking** - Updates system note with last update timestamp

## Quick Install

Copy and paste this single command into your MikroTik terminal:

```bash
/tool fetch url="https://raw.githubusercontent.com/netadminplus/mikrotik-iran-geoip/main/installer.rsc" mode=https dst-path=installer.rsc; /import file-name=installer.rsc
```

That's it! The system will:
- Create an address list named `IRAN`
- Import all Iran IP ranges (~1,800+ entries)
- Add RFC1918 private ranges (10.0.0.0/8, 172.16.0.0/12, 192.168.0.0/16)
- Set up automatic weekly updates every Sunday at 03:00
- Update system note with installation timestamp

## Requirements

- RouterOS v7+ (v6 might work but not tested)
- Internet access for downloading updates
- Valid system time for HTTPS certificate verification

## Troubleshooting

If you get HTTPS certificate errors due to incorrect system time:

```bash
/tool fetch url="https://raw.githubusercontent.com/netadminplus/mikrotik-iran-geoip/main/installer.rsc" mode=https check-certificate=no dst-path=installer.rsc; /import file-name=installer.rsc
```

## Management

**Manual update:**
```bash
/system script run update_iran_geoip
```

**Check last update time:**
```bash
/system note print
```

**Disable automatic updates:**
```bash
/system scheduler disable iran_geoip_weekly
```

**Completely remove:**
```bash
/system scheduler remove iran_geoip_weekly
/system script remove update_iran_geoip
/ip firewall address-list remove [find list=IRAN]
```

## Custom IP Management

You can safely add your own IPs to the IRAN list. **Always add a comment** to prevent removal during updates:

```bash
# Add custom IP with comment (will be preserved)
/ip firewall address-list add list=IRAN address=1.2.3.4 comment="My custom server"

# Add custom range with comment
/ip firewall address-list add list=IRAN address=203.0.113.0/24 comment="Company network"
```

IPs without comments will be removed during updates.

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

# Log Iran connections
/ip firewall filter add chain=forward src-address-list=IRAN action=log log-prefix="Iran-Traffic"
```

## License

MIT License - see [LICENSE](LICENSE) file for details.

## Links

- [Persian README](README.fa.md) - راهنمای فارسی
- [Issues](../../issues) - Report problems or request features
- [Releases](../../releases) - Version history
