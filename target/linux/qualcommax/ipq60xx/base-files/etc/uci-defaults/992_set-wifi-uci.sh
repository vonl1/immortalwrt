#!/bin/sh

board_name=$(cat /tmp/sysinfo/board_name)
BASE_SSID=$(uci get wireless.default_radio0.ssid)
BASE_SSID=${BASE_SSID:-"OWRT"}

configure_wifi() {
	local radio=$1
	local channel=$2
	local htmode=$3
	local txpower=$4
	local ssid=$5
	local key=$6
	local now_encryption=$(uci get wireless.default_radio${radio}.encryption)
	if [ -n "$now_encryption" ] && [ "$now_encryption" != "none" ]; then
		return 0
	fi

	uci set wireless.radio${radio}.channel="${channel}"
	uci set wireless.radio${radio}.htmode="${htmode}"
	uci set wireless.radio${radio}.mu_beamformer='1'
	uci set wireless.radio${radio}.country='US'
	uci set wireless.radio${radio}.txpower="${txpower}"
	uci set wireless.radio${radio}.disabled='0'
	uci set wireless.default_radio${radio}.ssid="${ssid}"
	uci set wireless.default_radio${radio}.encryption='psk2+ccmp'
	uci set wireless.default_radio${radio}.key="${key}"
	uci set wireless.default_radio${radio}.ieee80211k='1'
	uci set wireless.default_radio${radio}.time_advertisement='2'
	uci set wireless.default_radio${radio}.time_zone='CST-8'
	uci set wireless.default_radio${radio}.bss_transition='1'
	uci set wireless.default_radio${radio}.wnm_sleep_mode='1'
	uci set wireless.default_radio${radio}.wnm_sleep_mode_no_keys='1'
}

dual_band_wifi_cfg() {
	configure_wifi 0 149 HE80 20 "${BASE_SSID}-5G" '12345678'
	configure_wifi 1 1 HE20 20 "${BASE_SSID}" '12345678'
}

tri_band_wifi_cfg() {
	configure_wifi 0 149 HE80 20 "${BASE_SSID}-5.8G" '12345678'
	configure_wifi 1 1 HE20 20 "${BASE_SSID}-2.4G" '12345678'
	configure_wifi 2 44 HE160 23 "${BASE_SSID}-5.2G" '12345678'
}

case "${board_name}" in
	cmiot,ax18|\
	glinet,gl-ax1800|\
	glinet,gl-axt1800|\
	jdcloud,re-ss-01|\
	qihoo,360v6|\
	redmi,ax5|\
	redmi,ax5-jdcloud|\
	xiaomi,ax1800|\
	zn,m2)
		dual_band_wifi_cfg
	;;
	jdcloud,re-cs-02)
		tri_band_wifi_cfg
	;;
	*)
		exit 0
	;;
esac

uci commit wireless
/etc/init.d/network restart
