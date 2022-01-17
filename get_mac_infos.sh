#!/usr/bin/bash
################################################################
# Generate logs with this:                                     #
# sudo airodump-ng -w airotraffic --output-format csv wlan0mon #
################################################################
# Run script: ./get_mac_infos.sh airotraffic.csv               #
################################################################

CSV=$1

FILENAME=$(basename -- "$0")
LOGFILE="${FILENAME%.*}.logs"

# Extract Mac Address 
grep -o -E '([[:xdigit:]]{1,2}:){5}[[:xdigit:]]{1,2}' ${CSV} > MAC_ADDRESS_FULL.tmp

# Remove duplicate line
sort MAC_ADDRESS_FULL.tmp | uniq -u > MAC_ADDRESS_UNIQ.tmp

# Show stats, line number
LINES=$(wc -l MAC_ADDRESS_UNIQ.tmp | awk -F' ' '{print $1}')
echo "Number of MAC Address: ${LINES}"

# Get product id for each Mac Address
while read MAC; do
        result=$(curl --silent "https://api.macvendors.com/${MAC}")
        if [[ "${result}" == *"Not Found"* ]]; then
                echo "${MAC}: Unknown"; >> ${LOGFILE}
        else
                echo "${MAC}: ${result}"; >> ${LOGFILE}
        fi;
        sleep 1s # Sleep because limitation of the free plan api.macvendors.com
done <MAC_ADDRESS_UNIQ.tmp

rm MAC_ADDRESS_FULL.tmp MAC_ADDRESS_UNIQ.tmp
echo "Completed !"
