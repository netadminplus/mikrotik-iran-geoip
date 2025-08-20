#!/usr/bin/env python3
"""
Build iran.rsc file from multiple IP sources for MikroTik RouterOS
Sources:
- https://www.ipdeny.com/ipblocks/data/countries/ir.zone
- https://parspack.com/cdnips.txt  
- https://www.arvancloud.ir/fa/ips.txt
"""

import sys
import urllib.request
import urllib.error
import ipaddress
from typing import Set, List

# Source URLs
SOURCES = {
    'ipdeny': 'https://www.ipdeny.com/ipblocks/data/countries/ir.zone',
    'parspack': 'https://parspack.com/cdnips.txt',
    'arvancloud': 'https://www.arvancloud.ir/fa/ips.txt'
}

OUTPUT_FILE = 'iran.rsc'

def fetch_url(url: str, description: str) -> str:
    """Fetch content from URL with error handling"""
    print(f"Fetching {description} from {url}")
    try:
        with urllib.request.urlopen(url, timeout=30) as response:
            content = response.read().decode('utf-8')
            print(f"✓ Successfully fetched {description} ({len(content)} bytes)")
            return content
    except urllib.error.URLError as e:
        print(f"✗ Failed to fetch {description}: {e}")
        return ""
    except Exception as e:
        print(f"✗ Error fetching {description}: {e}")
        return ""

def validate_and_normalize_cidr(cidr_str: str) -> str:
    """Validate CIDR and return normalized form, or empty string if invalid"""
    cidr_str = cidr_str.strip()
    if not cidr_str or cidr_str.startswith('#'):
        return ""
    
    try:
        # Parse and normalize the CIDR
        network = ipaddress.ip_network(cidr_str, strict=False)
        return str(network)
    except ValueError:
        return ""

def extract_cidrs_from_content(content: str, source_name: str) -> Set[str]:
    """Extract and validate CIDRs from content"""
    cidrs = set()
    lines = content.split('\n')
    
    for line_num, line in enumerate(lines, 1):
        line = line.strip()
        if not line or line.startswith('#'):
            continue
            
        # Handle different formats
        # Some sources might have additional info after the CIDR
        parts = line.split()
        if parts:
            cidr_candidate = parts[0]
            normalized = validate_and_normalize_cidr(cidr_candidate)
            if normalized:
                cidrs.add(normalized)
            elif cidr_candidate:  # Only warn if there was actual content
                print(f"Warning: Invalid CIDR in {source_name} line {line_num}: {cidr_candidate}")
    
    print(f"✓ Extracted {len(cidrs)} valid CIDRs from {source_name}")
    return cidrs

def generate_rsc_file(all_cidrs: Set[str], output_file: str):
    """Generate RouterOS script file"""
    # Sort CIDRs for consistent output
    sorted_cidrs = sorted(all_cidrs, key=lambda x: ipaddress.ip_network(x))
    
    print(f"Generating {output_file} with {len(sorted_cidrs)} entries")
    
    with open(output_file, 'w', encoding='utf-8') as f:
        f.write("# Iran IP ranges for MikroTik RouterOS\n")
        f.write("# Auto-generated from multiple sources\n")
        f.write("# DO NOT EDIT - This file is automatically updated\n")
        f.write("\n")
        
        for cidr in sorted_cidrs:
            f.write(f"/ip firewall address-list add list=IRAN address={cidr}\n")
    
    print(f"✓ Generated {output_file} successfully")

def main():
    print("Building iran.rsc from multiple IP sources...")
    
    all_cidrs = set()
    
    # Fetch from all sources
    for source_name, url in SOURCES.items():
        content = fetch_url(url, source_name)
        if content:
            cidrs = extract_cidrs_from_content(content, source_name)
            all_cidrs.update(cidrs)
        else:
            print(f"Warning: Failed to fetch data from {source_name}")
    
    if not all_cidrs:
        print("Error: No valid CIDRs found from any source!")
        sys.exit(1)
    
    print(f"\nTotal unique CIDRs collected: {len(all_cidrs)}")
    
    # Generate the RouterOS script
    generate_rsc_file(all_cidrs, OUTPUT_FILE)
    
    print(f"\n✓ Build complete! Generated {OUTPUT_FILE}")

if __name__ == "__main__":
    main()
