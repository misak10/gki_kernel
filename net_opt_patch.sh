#!/usr/bin/env bash
set -euo pipefail

# Net optimization patcher for Android GKI 6.1
# Usage:
#   1) Place this repo side-by-side with your synced GKI source, or
#   2) Provide path to GKI source as the first argument.
#
# The script will append required Netfilter/IPSet/IPv6 NAT/BBR configs
# into common/arch/arm64/configs/gki_defconfig.

GKI_ROOT="${1:-}"
if [[ -z "${GKI_ROOT}" ]]; then
  # Try current working directory as GKI root
  if [[ -d "./common" && -f "./common/BUILD.bazel" ]]; then
    GKI_ROOT="$(pwd)"
  else
    echo "ERROR: Please pass the GKI source root path as the first argument,"
    echo "or run this script from inside the GKI source root (where ./common exists)."
    exit 1
  fi
fi

CONFIG_FILE="$GKI_ROOT/common/arch/arm64/configs/gki_defconfig"
if [[ ! -f "$CONFIG_FILE" ]]; then
  echo "ERROR: gki_defconfig not found at: $CONFIG_FILE"
  exit 1
fi

echo "[+] Target defconfig: $CONFIG_FILE"

# Additional TTL/HL helpers
{
  echo "CONFIG_IP_NF_TARGET_TTL=y"
  echo "CONFIG_IP6_NF_TARGET_HL=y"
  echo "CONFIG_IP6_NF_MATCH_HL=y"
} >> "$CONFIG_FILE"

# IP_SET core and varieties
{
  echo "CONFIG_NETFILTER=y"
  echo "CONFIG_NETFILTER_ADVANCED=y"
  echo "CONFIG_NETFILTER_XTABLES=y"
  echo "CONFIG_IP_SET=y"
  echo "CONFIG_IP_SET_MAX=256"
  echo "CONFIG_IP_SET_BITMAP_IP=y"
  echo "CONFIG_IP_SET_BITMAP_IPMAC=y"
  echo "CONFIG_IP_SET_BITMAP_PORT=y"
  echo "CONFIG_IP_SET_HASH_IP=y"
  echo "CONFIG_IP_SET_HASH_IPMARK=y"
  echo "CONFIG_IP_SET_HASH_IPPORT=y"
  echo "CONFIG_IP_SET_HASH_IPPORTIP=y"
  echo "CONFIG_IP_SET_HASH_IPPORTNET=y"
  echo "CONFIG_IP_SET_HASH_IPMAC=y"
  echo "CONFIG_IP_SET_HASH_MAC=y"
  echo "CONFIG_IP_SET_HASH_NETPORTNET=y"
  echo "CONFIG_IP_SET_HASH_NET=y"
  echo "CONFIG_IP_SET_HASH_NETNET=y"
  echo "CONFIG_IP_SET_HASH_NETPORT=y"
  echo "CONFIG_IP_SET_HASH_NETIFACE=y"
  echo "CONFIG_IP_SET_LIST_SET=y"
  echo "CONFIG_IP_NF_SET=y"
  echo "CONFIG_IP6_NF_SET=y"
} >> "$CONFIG_FILE"

# iptables set extensions
{
  echo "CONFIG_NETFILTER_XT_SET=y"
  echo "CONFIG_NETFILTER_XT_MATCH_SET=y"
  echo "CONFIG_NETFILTER_XT_TARGET_TPROXY=y"
  echo "CONFIG_NETFILTER_XT_TARGET_REDIRECT=y"
  echo "CONFIG_NETFILTER_XT_TARGET_MARK=y"
  echo "CONFIG_NETFILTER_XT_MATCH_SOCKET=y"
  echo "CONFIG_NETFILTER_XT_MATCH_OWNER=y"
  echo "CONFIG_NETFILTER_XT_MATCH_MARK=y"
  echo "CONFIG_NETFILTER_XT_MATCH_ADDRTYPE=y"
  echo "CONFIG_NETFILTER_XT_MATCH_MULTIPORT=y"
} >> "$CONFIG_FILE"

# IPv6 NAT
{
  echo "CONFIG_NF_NAT=y"
  echo "CONFIG_IP6_NF_IPTABLES=y"
  echo "CONFIG_IP6_NF_NAT=y"
  echo "CONFIG_IP6_NF_TARGET_MASQUERADE=y"
  echo "CONFIG_IP6_NF_TARGET_NPT=y"
} >> "$CONFIG_FILE"

# BBR
{
  echo "CONFIG_TCP_CONG_ADVANCED=y"
  echo "CONFIG_TCP_CONG_BBR=y"
  echo "CONFIG_NET_SCH_FQ=y"
  # Keep other common algos reasonable
  echo "CONFIG_TCP_CONG_WESTWOOD=y"
} >> "$CONFIG_FILE"

echo "[+] Net optimization config appended successfully."
