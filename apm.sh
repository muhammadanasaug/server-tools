#!/usr/bin/env bash
set +e

FILE="$0"

services=("nginx" "varnish" "apache2" "php-fpm" "mysql" "memcached" "redis-server" "imunify360")

for s in "${services[@]}"; do
    [[ $s == "php-fpm" ]] && s=$(php -v | awk '{print "php"substr($2,1,3)"-fpm";exit}')
    [[ $s == "imunify360" ]] && s=$(systemctl list-unit-files | grep -q imunify360-agent && echo imunify360-agent || echo imunify360)

    if systemctl restart "$s" &>/dev/null; then
        echo "$(tput setaf 2)   |✓ $s restarted$(tput sgr0)"
    else
        echo "$(tput setaf 1)   |✗ $s failed$(tput sgr0)"
    fi
done

swapoff -a && swapon -a && \
    echo "$(tput setaf 2)   |✓ Swap cleared$(tput sgr0)" || \
    echo "$(tput setaf 1)   |✗ Swap clear failed$(tput sgr0)"

# Imunify tuning + output
if command -v imunify360-agent >/dev/null 2>&1; then
    imunify360-agent config update '{"ENHANCED_DOS": {"default_limit": 50}, "MALWARE_SCAN_INTENSITY": {"cpu": 1}}' >/dev/null

    if command -v jq >/dev/null 2>&1; then
        imunify360-agent config show | jq '{enhanced_dos: .ENHANCED_DOS.default_limit, malware_cpu: .MALWARE_SCAN_INTENSITY.cpu}'
    else
        imunify360-agent config show | grep -E "ENHANCED_DOS|MALWARE_SCAN_INTENSITY"
    fi
fi

# cleanup
rm -f "$FILE"
