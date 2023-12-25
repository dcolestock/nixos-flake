# CLOUDFLARE_ZONE_ID=""
# CLOUDFLARE_TOKEN=""
# CLOUDFLARE_RECORD_ID=""

# api url
URL="https://api.cloudflare.com/client/v4/zones"
# you can get the record id showing all A records with this call:
# curl -s -X GET "${URL}/${CLOUDFLARE_ZONE_ID}/dns_records?type=A" -H "Authorization: Bearer ${CLOUDFLARE_TOKEN}" \
# -H "Content-Type: application/json"|jq '.result[]|{id,name,type,content,ttl}'

# get actual record information
REC=$(curl -s -X GET "${URL}/${CLOUDFLARE_ZONE_ID}/dns_records/${CLOUDFLARE_RECORD_ID}" -H "Authorization: Bearer ${CLOUDFLARE_TOKEN}" \
-H "Content-Type: application/json")

# actual registered ip
registered=$(echo ${REC}|jq '.result.content')
# current real external ip
current=\"$(curl -s ifconfig.me || curl -s icanhazip.com)\"

# function to update record ip (other values remain the same)
function change_record() {
    name=$(echo ${REC}|jq '.result.name')
    type=$(echo ${REC}|jq '.result.type')
    ttl=$(echo ${REC}|jq '.result.ttl')
    proxied=$(echo ${REC}|jq '.result.proxied')
    curl -X PUT "${URL}/${CLOUDFLARE_ZONE_ID}/dns_records/${CLOUDFLARE_RECORD_ID}" -H "Authorization: Bearer ${CLOUDFLARE_TOKEN}" \
    --data '{"type":'"${type}"',"name":'"${name}"',"content":'"${current}"',"ttl":'"${ttl}"',"proxied":'"${proxied}"'}'
}

[ "$current" != "$registered" ] && {
    change_record
  }
