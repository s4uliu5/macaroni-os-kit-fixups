# Distributed under the terms of the GNU General Public License v2

EAPI=6

#mogilefs
#push
#upstream_check

GENTOO_DEPEND_ON_PERL="no"

declare -A mod{_a,_pn,_pv,_lic,_sha,_p,_uri,_wd,_doc}
declare -A mods

# encrypted_session depend on ndk.
# place ndk before modules that depend on it.

# Nginx Development Kit (NDK) (https://github.com/simpl/ngx_devel_kit)
# Must be behind encrypted_session
mod_a["ndk"]="simpl"
mod_pn["ndk"]="ngx_devel_kit"
mod_pv["ndk"]="0.3.1"
mod_lic["ndk"]="BSD"
mod_p["ndk"]="${mod_pn["ndk"]}-${mod_pv["ndk"]}"
mod_uri["ndk"]="https://github.com/${mod_a["ndk"]}/${mod_pn["ndk"]}/archive/v${mod_pv["ndk"]}.tar.gz"
mod_wd["ndk"]="${WORKDIR}/${mod_p["ndk"]}"
mod_doc["ndk"]="README.md README_AUTO_LIB.md"

# # ngx_brotli (https://github.com/eustas/ngx_brotli, BSD-2)
mod_a["brotli"]="google"
mod_pn["brotli"]="ngx_brotli"
mod_pv["brotli"]="25f86f0bac1101b6512135eac5f93c49c63609e3"
mod_lic["brotli"]="BSD-2"
mod_p["brotli"]="${mod_pn["brotli"]}-${mod_pv["brotli"]}"
mod_uri["brotli"]="https://github.com/${mod_a["brotli"]}/${mod_pn["brotli"]}/archive/${mod_pv["brotli"]}.tar.gz"
mod_wd["brotli"]="${WORKDIR}/${mod_p["brotli"]}"
mod_doc["brotli"]="README.md"

# Dav Ext (https://github.com/arut/nginx-dav-ext-module)
mod_a["dav_ext"]="arut"
mod_pn["dav_ext"]="nginx-dav-ext-module"
mod_pv["dav_ext"]="3.0.0"
mod_lic["dav_ext"]="BSD-2"
mod_p["dav_ext"]="${mod_pn["dav_ext"]}-${mod_pv["dav_ext"]}"
mod_uri["dav_ext"]="https://github.com/${mod_a["dav_ext"]}/${mod_pn["dav_ext"]}/archive/v${mod_pv["dav_ext"]}.tar.gz"
mod_wd["dav_ext"]="${WORKDIR}/${mod_p["dav_ext"]}"
mod_doc["dav_ext"]="README.rst"

# Encrypted Session (https://github.com/openresty/encrypted-session-nginx-module)
mod_a["encrypted_session"]="openresty"
mod_pn["encrypted_session"]="encrypted-session-nginx-module"
mod_pv["encrypted_session"]="0.08"
mod_sha["encrypted_session"]="a42c37118588833723935aa460b2dc2e3234f0b0"
mod_lic["encrypted_session"]="BSD-2"
mod_p["encrypted_session"]="${mod_pn["encrypted_session"]}-${mod_sha["encrypted_session"]}"
mod_uri["encrypted_session"]="https://github.com/${mod_a["encrypted_session"]}/${mod_pn["encrypted_session"]}/archive/${mod_sha["encrypted_session"]}.tar.gz"
mod_wd["encrypted_session"]="${WORKDIR}/${mod_p["encrypted_session"]}"
#mod_doc["encrypted_session"]="README"

# Fancy Index (https://github.com/aperezdc/ngx-fancyindex)
mod_a["fancyindex"]="aperezdc"
mod_pn["fancyindex"]="ngx-fancyindex"
mod_pv["fancyindex"]="0.4.4"
mod_lic["fancyindex"]="BSD-2"
mod_p["fancyindex"]="${mod_pn["fancyindex"]}-${mod_pv["fancyindex"]}"
mod_uri["fancyindex"]="https://github.com/${mod_a["fancyindex"]}/${mod_pn["fancyindex"]}/archive/v${mod_pv["fancyindex"]}.tar.gz"
mod_wd["fancyindex"]="${WORKDIR}/${mod_p["fancyindex"]}"
mod_doc["fancyindex"]="README.rst HACKING.md CHANGELOG.md"

# MogileFS Client (http://www.grid.net.ru/nginx/mogilefs.en.html)
mod_a["mogilefs"]="vkholodkov"
mod_pn["mogilefs"]="nginx-mogilefs-module"
mod_pv["mogilefs"]="1.0.4"
# mod_sha["mogilefs"]="020937ff4624fc31928adb51a5c43753bf256b34"
mod_lic["mogilefs"]="BSD"
mod_p["mogilefs"]="${mod_pn["mogilefs"]}-${mod_pv["mogilefs"]}"
mod_uri["mogilefs"]="https://github.com/${mod_a["mogilefs"]}/${mod_pn["mogilefs"]}/archive/${mod_pv["mogilefs"]}.tar.gz"
mod_uri["mogilefs"]="https://github.com/${mod_a["mogilefs"]}/${mod_pn["mogilefs"]}/archive/${mod_sha["mogilefs"]}.tar.gz"
mod_wd["mogilefs"]="${WORKDIR}/${mod_p["mogilefs"]}"
mod_doc["mogilefs"]="README Changelog"

# Phusion Passenger (https://github.com/phusion/passenger)
#mod_a["passenger"]="phusion"
#mod_pn["passenger"]="passenger"
#mod_pv["passenger"]="5.0.6"
#mod_lic["passenger"]="MIT"
#mod_p["passenger"]="${mod_pn["passenger"]}-release-${mod_pv["passenger"]}"
#mod_uri["passenger"]="https://github.com/${mod_a["passenger"]}/${mod_pn["passenger"]}/archive/release-${mod_pv["passenger"]}.tar.gz"
#mod_wd["passenger"]="${WORKDIR}/${mod_p["passenger"]}/ext/nginx"
# mod_doc["passenger"]="README.md CHANGELOG"

# Upload Progress (https://github.com/masterzen/nginx-upload-progress-module)
mod_a["upload_progress"]="masterzen"
mod_pn["upload_progress"]="nginx-upload-progress-module"
mod_pv["upload_progress"]="0.9.2"
mod_lic["upload_progress"]="BSD-2"
mod_p["upload_progress"]="${mod_pn["upload_progress"]}-${mod_pv["upload_progress"]}"
mod_uri["upload_progress"]="https://github.com/${mod_a["upload_progress"]}/${mod_pn["upload_progress"]}/archive/v${mod_pv["upload_progress"]}.tar.gz"
mod_wd["upload_progress"]="${WORKDIR}/${mod_p["upload_progress"]}"
mod_doc["upload_progress"]="README CHANGES"

# Headers More (http://github.com/agentzh/headers-more-nginx-module)
mod_a["headers_more"]="agentzh"
mod_pn["headers_more"]="headers-more-nginx-module"
mod_pv["headers_more"]="0.33"
mod_lic["headers_more"]="BSD"
mod_p["headers_more"]="${mod_pn["headers_more"]}-${mod_pv["headers_more"]}"
mod_uri["headers_more"]="https://github.com/${mod_a["headers_more"]}/${mod_pn["headers_more"]}/archive/v${mod_pv["headers_more"]}.tar.gz"
mod_wd["headers_more"]="${WORKDIR}/${mod_p["headers_more"]}"
#mod_doc["headers_more"]="README.markdown"

# Push (http://pushmodule.slact.net)
mod_a["push"]="slact"
mod_pn["push"]="nchan"
#mod_pv["push"]="0.731"
mod_pv["push"]="v1.2.5"
mod_sha["push"]="2f6f22e54f16416457d0050574a657fa24b3739f"
mod_lic["push"]="MIT"
mod_p["push"]="${mod_pn["push"]}-${mod_sha["push"]}"
# mod_uri["push"]="https://github.com/${mod_a["push"]}/${mod_pn["push"]}/archive/${mod_pv["push"]}.tar.gz"
mod_uri["push"]="https://github.com/${mod_a["push"]}/${mod_pn["push"]}/archive/${mod_sha["push"]}.tar.gz"
mod_wd["push"]="${WORKDIR}/${mod_p["push"]}"
mod_doc["push"]="README.md changelog.txt"

# Cache Purge (http://labs.frickle.com/nginx_ngx_cache_purge)
mod_a["cache_purge"]="FRiCKLE"
mod_pn["cache_purge"]="ngx_cache_purge"
mod_pv["cache_purge"]="2.3"
mod_lic["cache_purge"]="BSD-2"
mod_p["cache_purge"]="${mod_pn["cache_purge"]}-${mod_pv["cache_purge"]}"
mod_uri["cache_purge"]="https://github.com/${mod_a["cache_purge"]}/${mod_pn["cache_purge"]}/archive/${mod_pv["cache_purge"]}.tar.gz"
mod_wd["cache_purge"]="${WORKDIR}/${mod_p["cache_purge"]}"
mod_doc["cache_purge"]="README.md CHANGES TODO.md"

# SlowFS Cache (http://labs.frickle.com/nginx_ngx_slowfs_cache)
mod_a["slowfs_cache"]="FRiCKLE"
mod_pn["slowfs_cache"]="ngx_slowfs_cache"
mod_pv["slowfs_cache"]="1.10"
mod_lic["slowfs_cache"]="BSD-2"
mod_p["slowfs_cache"]="${mod_pn["slowfs_cache"]}-${mod_pv["slowfs_cache"]}"
mod_uri["slowfs_cache"]="https://github.com/${mod_a["slowfs_cache"]}/${mod_pn["slowfs_cache"]}/archive/${mod_pv["slowfs_cache"]}.tar.gz"
mod_wd["slowfs_cache"]="${WORKDIR}/${mod_p["slowfs_cache"]}"
mod_doc["slowfs_cache"]="README.md CHANGES"

# Lua (https://github.com/openresty/lua-nginx-module)
mod_a["lua"]="openresty"
mod_pn["lua"]="lua-nginx-module"
mod_pv["lua"]="v0.10.15"
mod_sha["lua"]="28cf5ce3b6ec8e7ab44eadac9cc1c3b6f5c387ba"
mod_lic["lua"]="BSD-2"
mod_p["lua"]="${mod_pn["lua"]}-${mod_pv["lua"]/v/}"
mod_uri["lua"]="https://github.com/${mod_a["lua"]}/${mod_pn["lua"]}/archive/${mod_pv["lua"]}.tar.gz"
mod_wd["lua"]="${WORKDIR}/${mod_p["lua"]}"
mod_doc["lua"]="README.markdown doc/HttpLuaModule.wiki"

# Auth PAM (https://github.com/sto/ngx_http_auth_pam_module)
mod_a["auth_pam"]="stogh"
mod_pn["auth_pam"]="ngx_http_auth_pam_module"
mod_pv["auth_pam"]="1.5.2"
# mod_sha["auth_pam"]="f5d706ac299dc3c517fef644873739e975556e6b"
mod_lic["auth_pam"]="BSD-2"
mod_p["auth_pam"]="${mod_pn["auth_pam"]}-${mod_pv["auth_pam"]}"
mod_uri["auth_pam"]="https://github.com/${mod_a["auth_pam"]}/${mod_pn["auth_pam"]}/archive/v${mod_pv["auth_pam"]}.tar.gz"
mod_wd["auth_pam"]="${WORKDIR}/${mod_p["auth_pam"]}"
mod_doc["auth_pam"]="README.md ChangeLog"

# Upstream Check (https://github.com/yaoweibin/nginx_upstream_check_module)
mod_a["upstream_check"]="yaoweibin"
mod_pn["upstream_check"]="nginx_upstream_check_module"
mod_pv["upstream_check"]="0.3.0"
mod_sha["upstream_check"]="9aecf15ec379fe98f62355c57b60c0bc83296f04"
mod_lic["upstream_check"]="BSD-2"
mod_p["upstream_check"]="${mod_pn["upstream_check"]}-${mod_sha["upstream_check"]}"
mod_uri["upstream_check"]="https://github.com/${mod_a["upstream_check"]}/${mod_pn["upstream_check"]}/archive/${mod_sha["upstream_check"]}.tar.gz"
mod_wd["upstream_check"]="${WORKDIR}/${mod_p["upstream_check"]}"
mod_doc["upstream_check"]="README CHANGES"

# Metrics (https://github.com/zenops/ngx_metrics)
mod_a["metrics"]="zenops"
mod_pn["metrics"]="ngx_metrics"
mod_pv["metrics"]="0.1.1"
mod_lic["metrics"]="BSD-2"
mod_p["metrics"]="${mod_pn["metrics"]}-${mod_pv["metrics"]}"
mod_uri["metrics"]="https://github.com/${mod_a["metrics"]}/${mod_pn["metrics"]}/archive/v${mod_pv["metrics"]}.tar.gz"
mod_wd["metrics"]="${WORKDIR}/${mod_p["metrics"]}"
mod_doc["metrics"]="README.md"

# NAXSI (https://github.com/nbs-system/naxsi)
mod_a["naxsi"]="nbs-system"
mod_pn["naxsi"]="naxsi"
mod_pv["naxsi"]="0.56"
mod_lic["naxsi"]="GPL-2+"
mod_p["naxsi"]="${mod_pn["naxsi"]}-${mod_pv["naxsi"]}"
mod_uri["naxsi"]="https://github.com/${mod_a["naxsi"]}/${mod_pn["naxsi"]}/archive/${mod_pv["naxsi"]}.tar.gz"
mod_wd["naxsi"]="${WORKDIR}/${mod_p["naxsi"]}/naxsi_src"
mod_doc["naxsi"]="README.md"

# RTMP (http://github.com/arut/nginx-rtmp-module)
mod_a["rtmp"]="arut"
mod_pn["rtmp"]="nginx-rtmp-module"
mod_pv["rtmp"]="1.2.1"
mod_lic["rtmp"]="BSD-2"
mod_p["rtmp"]="${mod_pn["rtmp"]}-${mod_pv["rtmp"]}"
mod_uri["rtmp"]="https://github.com/${mod_a["rtmp"]}/${mod_pn["rtmp"]}/archive/v${mod_pv["rtmp"]}.tar.gz"
mod_wd["rtmp"]="${WORKDIR}/${mod_p["rtmp"]}"
mod_doc["rtmp"]="README.md AUTHORS"

# Accept Language (https://github.com/giom/nginx_accept_language_module)
mod_a["accept_language"]="giom"
mod_pn["accept_language"]="nginx_accept_language_module"
mod_pv["accept_language"]=""
mod_lic["accept_language"]="BSD-2"
mod_sha["accept_language"]="2f69842f83dac77f7d98b41a2b31b13b87aeaba7"
mod_p["accept_language"]="${mod_pn["accept_language"]}-${mod_sha["accept_language"]}"
mod_uri["accept_language"]="https://github.com/${mod_a["accept_language"]}/${mod_pn["accept_language"]}/archive/${mod_sha["accept_language"]}.tar.gz"
mod_wd["accept_language"]="${WORKDIR}/${mod_p["accept_language"]}"
mod_doc["accept_language"]="README.textile"

# Concat (https://github.com/alibaba/nginx-http-concat)
mod_a["concat"]="alibaba"
mod_pn["concat"]="nginx-http-concat"
mod_pv["concat"]="1.2.2"
mod_lic["concat"]="BSD-2"
mod_p["concat"]="${mod_pn["concat"]}-${mod_pv["concat"]}"
mod_uri["concat"]="https://github.com/${mod_a["concat"]}/${mod_pn["concat"]}/archive/${mod_pv["concat"]}.tar.gz"
mod_wd["concat"]="${WORKDIR}/${mod_p["concat"]}"
mod_doc["concat"]="README.md"

# Echo (https://github.com/openresty/echo-nginx-module)
mod_a["echo"]="openresty"
mod_pn["echo"]="echo-nginx-module"
mod_pv["echo"]="v0.62"
#mod_sha["echo"]="0525d0c2db1f2a5c19a141687cd055e09b5cded1"
mod_lic["echo"]="BSD-2"
mod_p["echo"]="${mod_pn["echo"]}-${mod_pv["echo"]/v/}"
mod_uri["echo"]="https://github.com/${mod_a["echo"]}/${mod_pn["echo"]}/archive/${mod_pv["echo"]}.tar.gz"
mod_wd["echo"]="${WORKDIR}/${mod_p["echo"]}"
#mod_doc["echo"]="README.markdown"

# ModSecurity (https://www.modsecurity.org/download.html)
mod_a["modsecurity"]="modsecurity"
mod_pn["modsecurity"]="modsecurity"
mod_pv["modsecurity"]="2.9.3"
mod_lic["modsecurity"]="Apache-2.0"
mod_p["modsecurity"]="${mod_pn["modsecurity"]}-${mod_pv["modsecurity"]}"
mod_uri["modsecurity"]="https://www.modsecurity.org/tarball/${mod_pv[modsecurity]}/${mod_p["modsecurity"]}.tar.gz"
mod_wd["modsecurity"]="${WORKDIR}/${mod_p["modsecurity"]}/nginx/${mod_pn["modsecurity"]}"
mod_doc["modsecurity"]="README.md CHANGES NOTICE"

# Push Stream (https://github.com/wandenberg/nginx-push-stream-module)
mod_a["push_stream"]="wandenberg"
mod_pn["push_stream"]="nginx-push-stream-module"
mod_pv["push_stream"]="0.5.4"
mod_lic["push_stream"]="GPL-3"
mod_p["push_stream"]="${mod_pn["push_stream"]}-${mod_pv["push_stream"]}"
mod_uri["push_stream"]="https://github.com/${mod_a["push_stream"]}/${mod_pn["push_stream"]}/archive/${mod_pv["push_stream"]}.tar.gz"
mod_wd["push_stream"]="${WORKDIR}/${mod_p["push_stream"]}"
mod_doc["push_stream"]="README.textile CHANGELOG.textile AUTHORS"

# Sticky (https://bitbucket.org/nginx-goodies/nginx-sticky-module-ng)
mod_a["sticky"]="nginx-goodies"
mod_pn["sticky"]="nginx-sticky-module-ng"
mod_pv["sticky"]="1.2.6"
mod_sha["sticky"]="08a395c66e425540982c00482f55034e1fee67b6"
mod_lic["sticky"]="BSD-2"
mod_p["sticky"]="${mod_a["sticky"]}-${mod_pn["sticky"]}-08a395c66e42"
mod_uri["sticky"]="http://bitbucket.org/${mod_a["sticky"]}/${mod_pn["sticky"]}/get/${mod_sha["sticky"]}.tar.gz"
mod_wd["sticky"]="${WORKDIR}/${mod_p["sticky"]}"
mod_doc["sticky"]="README.md Changelog.txt"

# AJP (https://github.com/yaoweibin/nginx_ajp_module)
mod_a["ajp"]="yaoweibin"
mod_pn["ajp"]="nginx_ajp_module"
mod_pv["ajp"]="0.3.0"
mod_sha["ajp"]="bf6cd93f2098b59260de8d494f0f4b1f11a84627"
mod_lic["ajp"]="BSD-2"
mod_p["ajp"]="${mod_pn["ajp"]}-${mod_sha["ajp"]}"
mod_uri["ajp"]="https://github.com/${mod_a["ajp"]}/${mod_pn["ajp"]}/archive/${mod_sha["ajp"]}.tar.gz"
mod_wd["ajp"]="${WORKDIR}/${mod_p["ajp"]}"
mod_doc["ajp"]="README"

inherit autotools eutils ssl-cert toolchain-funcs perl-module flag-o-matic user versionator pax-utils

DESCRIPTION="Robust, small and high performance http and reverse proxy server"
HOMEPAGE="http://nginx.org"
SRC_URI="http://nginx.org/download/${P}.tar.gz"

for m in ${!mod_a[@]} ; do
	SRC_URI+=" nginx_modules_external_${m}? (
		${mod_uri[$m]} -> ${mod_p[$m]}.tar.gz )"
done

LICENSE="BSD-2"

for m in ${!mod_a[@]} ; do
	LICENSE+=" nginx_modules_external_${m}? ( ${mod_lic[$m]} )"
done

SLOT="0"
KEYWORDS="*"

# Package doesn't provide a real test suite
RESTRICT="test"

mods[standard]="access auth_basic autoindex browser charset empty_gif fastcgi
	geo  grpc gzip limit_conn limit_req map memcached mirror
	proxy referer rewrite scgi ssi split_clients userid uwsgi"

mods[upstream]="upstream_hash upstream_ip_hash upstream_keepalive upstream_least_conn upstream_zone"

mods[optional]="addition auth_request dav degradation flv geoip gunzip
	gzip_static image_filter mp4 perl random_index realip secure_link
	ssl stub_status sub xslt"

mods[standard_stream]="access geo limit_conn map return split_clients upstream_hash upstream_least_conn upstream_zone"

mods[optional_stream]="geoip realip ssl_preread"

mods[mail]="imap pop3 smtp"

mods[dynamic]="xslt image_filter geoip perl mail stream stream_geoip"

IUSE="+aio +http +http2 +http-cache +pcre pcre-jit +poll rtmp +select cpp_test debug full
	google_perftools +ipv6 libatomic libressl luajit ssl stream threads vim-syntax"

for m in ${mods[upstream]} ; do
	IUSE+=" +nginx_modules_http_${m}" ; done

for m in ${mods[standard]} ; do
	IUSE+=" +nginx_modules_http_${m}" ; done

for m in ${mods[standard_stream]} ; do
	IUSE+=" +nginx_modules_stream_${m}" ; done

for m in ${mods[optional]} ; do
	IUSE+=" nginx_modules_http_${m}" ; done

for m in ${mods[optional_stream]} ; do
	IUSE+=" nginx_modules_stream_${m}" ; done

for m in ${mods[mail]} ; do
	IUSE+=" nginx_modules_mail_${m}" ; done

for m in ${mods[dynamic]} ; do
    IUSE+=" nginx_modules_dynamic_${m}" ; done

for m in ${!mod_a[@]} ; do
	IUSE+=" nginx_modules_external_${m}" ; done

# 	nginx_modules_http_geoip2? ( dev-libs/libmaxminddb )
RDEPEND="
	!www-server/nginx:0
	google_perftools? ( dev-util/google-perftools )
	http-cache? (
		!libressl? ( dev-libs/openssl:0= )
		libressl? ( dev-libs/libressl:= )
	)
	pcre? ( dev-libs/libpcre )
	pcre-jit? ( dev-libs/libpcre[jit] )
	ssl? (
		!libressl? ( dev-libs/openssl:0= )
		libressl? ( dev-libs/libressl:= )
	)
	http2? (
		!libressl? ( dev-libs/openssl:0= )
		libressl? ( dev-libs/libressl:= )
	)
	nginx_modules_external_brotli? ( app-arch/brotli )
	nginx_modules_http_geoip? ( dev-libs/geoip )
	nginx_modules_http_gunzip? ( sys-libs/zlib )
	nginx_modules_http_gzip? ( sys-libs/zlib )
	nginx_modules_http_gzip_static? ( sys-libs/zlib )
	nginx_modules_http_image_filter? ( media-libs/gd[jpeg,png] )
	nginx_modules_http_perl? ( >=dev-lang/perl-5.8:= )
	nginx_modules_http_rewrite? ( dev-libs/libpcre )
	nginx_modules_http_secure_link? (
		!libressl? ( dev-libs/openssl:0= )
		libressl? ( dev-libs/libressl:= )
	)
	nginx_modules_http_xslt? ( dev-libs/libxml2 dev-libs/libxslt )
	nginx_modules_external_lua? ( dev-lang/luajit:2= )
	nginx_modules_external_auth_pam? ( virtual/pam )
	nginx_modules_external_metrics? ( dev-libs/yajl )
	nginx_modules_external_dav_ext? ( dev-libs/libxml2 )
	nginx_modules_external_modsecurity? (
		dev-libs/apr
		dev-libs/apr-util
		dev-libs/libxml2
		net-misc/curl
		www-servers/apache
	)
	nginx_modules_stream_geoip? ( dev-libs/geoip )
	"
	# 	nginx_modules_stream_geoip2? ( dev-libs/libmaxminddb:= )
	# 	nginx_modules_http_auth_ldap? ( net-nds/openldap[ssl?] )

DEPEND="${RDEPEND}
	arm? ( dev-libs/libatomic_ops )
	libatomic? ( dev-libs/libatomic_ops )"

PDEPEND="vim-syntax? ( app-vim/nginx-syntax )"

#   nginx_modules_http_slice
#   nginx_modules_http_upstream_random
#   nginx_modules_stream_ssl
#   nginx_modules_stream_upstream_random

REQUIRED_USE="
	full? (
        nginx_modules_http_access
        nginx_modules_http_addition
        nginx_modules_http_auth_basic
        nginx_modules_http_auth_request
        nginx_modules_http_autoindex
        nginx_modules_http_browser
        nginx_modules_http_charset
        nginx_modules_http_dav
        nginx_modules_http_degradation
        nginx_modules_http_empty_gif
        nginx_modules_http_fastcgi
        nginx_modules_http_flv
        nginx_modules_http_geo
        nginx_modules_http_geoip
        nginx_modules_http_grpc
        nginx_modules_http_gunzip
        nginx_modules_http_gzip
        nginx_modules_http_gzip_static
        nginx_modules_http_image_filter
        nginx_modules_http_limit_conn
        nginx_modules_http_limit_req
        nginx_modules_http_map
        nginx_modules_http_memcached
        nginx_modules_http_mirror
        nginx_modules_http_mp4
        nginx_modules_http_perl
        nginx_modules_http_proxy
        nginx_modules_http_random_index
        nginx_modules_http_realip
        nginx_modules_http_referer
        nginx_modules_http_rewrite
        nginx_modules_http_scgi
        nginx_modules_http_secure_link
        nginx_modules_http_split_clients
        nginx_modules_http_ssi
        nginx_modules_http_ssl
        nginx_modules_http_stub_status
        nginx_modules_http_sub
        nginx_modules_http_upstream_hash
        nginx_modules_http_upstream_ip_hash
        nginx_modules_http_upstream_keepalive
        nginx_modules_http_upstream_least_conn
        nginx_modules_http_upstream_zone
        nginx_modules_http_userid
        nginx_modules_http_uwsgi
        nginx_modules_http_xslt
        nginx_modules_mail_imap
        nginx_modules_mail_pop3
        nginx_modules_mail_smtp
        nginx_modules_stream_access
        nginx_modules_stream_geo
        nginx_modules_stream_geoip
        nginx_modules_stream_limit_conn
        nginx_modules_stream_map
        nginx_modules_stream_realip
        nginx_modules_stream_return
        nginx_modules_stream_split_clients
        nginx_modules_stream_ssl_preread
        nginx_modules_stream_upstream_hash
        nginx_modules_stream_upstream_least_conn
        nginx_modules_stream_upstream_zone
    )
	pcre-jit? ( pcre )
	nginx_modules_http_grpc? ( http2 )
	nginx_modules_external_dav_ext? ( nginx_modules_http_dav nginx_modules_http_xslt )
	nginx_modules_external_encrypted_session? ( nginx_modules_external_ndk )
	nginx_modules_external_lua? (
		luajit
		nginx_modules_http_rewrite
	)
	nginx_modules_external_metrics? ( nginx_modules_http_stub_status )
	nginx_modules_external_modsecurity? ( pcre )
	nginx_modules_external_naxsi? ( pcre )
	nginx_modules_external_push_stream? ( ssl )"

pkg_setup() {

	NGINX_HOME="${EROOT}var/lib/${PN}"
	NGINX_HOME_TMP="${NGINX_HOME}/tmp"

	if egetent group ${PN} > /dev/null ; then
		elog "${PN} group already exist."
		elog "group creation step skipped."
	else
		enewgroup  ${PN} > /dev/null
		elog "${PN} group created by portage."
	fi

	if egetent passwd  ${PN} > /dev/null ; then
		elog "${PN} user already exist."
		elog "user creation step skipped."
	else
		enewuser ${PN} -1 -1 "${NGINX_HOME}" \
			${PN} > /dev/null
		elog "${PN} user with ${NGINX_HOME} home"
		elog "was created by portage."
	fi

	if use libatomic ; then
		ewarn "GCC 4.1+ features built-in atomic operations."
		ewarn "Using libatomic_ops is only needed if using"
		ewarn "a different compiler or a GCC prior to 4.1"
	fi

	if [[ -n $NGINX_ADD_MODULES ]] ; then
		ewarn "You are building custom modules via \$NGINX_ADD_MODULES!"
		ewarn "This nginx installation is not supported!"
		ewarn "Make sure you can reproduce the bug without those modules"
		ewarn "_before_ reporting bugs."
	fi

	if ! use http ; then
		ewarn "To actually disable all http-functionality you also have"
		ewarn "to disable all nginx http modules."
	fi

	if use nginx_modules_external_mogilefs && use threads; then
		eerror "mogilefs won't compile with threads support."
		eerror "Please disable either flag and try again."
		die "Can't compile mogilefs with threads support"
	fi
}

src_prepare() {

	eapply "${FILESDIR}/${PN}-fix-perl-install-path.patch"
	eapply "${FILESDIR}/${PN}-httpoxy-mitigation-r1.patch"

	if use nginx_modules_external_upstream_check; then
		epatch "${FILESDIR}/check-1.11.5.patch"
	fi

	if use nginx_modules_external_modsecurity; then
		cd "${WORKDIR}/${mod_p[modsecurity]}"

		eautoreconf

		if use luajit ; then
			sed -i -e 's|^\(LUA_PKGNAMES\)=.*|\1="luajit"|' configure || die
		fi

		cd "${S}" || die
	fi

	find auto/ -type f -print0 | xargs -0 sed -i 's:\&\& make:\&\& \\$(MAKE):' || die
	# We have config protection, don't rename etc files
	sed -i 's;.default;;' auto/install || die
	# remove useless files

	sed -e '/koi-/d' -e '/win-/d' -i "${S}/auto/install" || die

	# Don't install to /etc/nginx/ if not in use
	local m
	for m in fastcgi scgi uwsgi ; do
		if ! use nginx_modules_http_${m} ; then
			sed -e "/${m}/d" -i "${S}/auto/install" || die
		fi
	done

	eapply_user
}

src_configure() {
	# modsecurity needs to generate nginx/modsecurity/config before including it
	if use nginx_modules_external_modsecurity; then
		cd "${WORKDIR}/${mod_p[modsecurity]}"

		./configure \
			--enable-standalone-module \
			--disable-mlogc \
			--with-ssdeep=no \
			$(use_enable pcre-jit) \
			$(use_with nginx_modules_external_lua lua) || die "configure failed for modsecurity"
	fi

	cd "${S}"

	local nginx_configure= http_enabled= mail_enabled= stream_enabled= WITHOUT_IPV6=

	use aio                && nginx_configure+=" --with-file-aio"
	use cpp_test           && nginx_configure+=" --with-cpp_test_module"
	use debug              && nginx_configure+=" --with-debug"
	use google_perftools   && nginx_configure+=" --with-google_perftools_module"
	use http2              && nginx_configure+=" --with-http_v2_module"
	use libatomic          && nginx_configure+=" --with-libatomic"
	use pcre               && nginx_configure+=" --with-pcre"
	use pcre-jit           && nginx_configure+=" --with-pcre-jit"
	use threads            && nginx_configure+=" --with-threads"

	if ! use ipv6; then
		WITHOUT_IPV6=" -DNGX_HAVE_INET6=0"
	fi

	for m in ${mods[upstream]}; do
		use nginx_modules_http_${m} && http_enabled=1 || nginx_configure+=" --without-http_${m}_module"
	done

	for m in ${mods[standard]}; do
		use nginx_modules_http_${m} && http_enabled=1 || nginx_configure+=" --without-http_${m}_module"
	done

	for m in ${mods[standard_stream]}; do
		use nginx_modules_stream_${m} && stream_enabled=1 && nginx_configure+=" --without-stream_${m}_module"
	done

	for m in ${mods[optional]}; do
		use nginx_modules_http_${m} && http_enabled=1 && nginx_configure+=" --with-http_${m}_module"
	done

	for m in ${mods[optional_stream]}; do
		use nginx_modules_stream_${m} && stream_enabled=1 && nginx_configure+=" --with-stream_${m}_module"
	done

	# enable dynamic ngx_http_geoip_module
	use nginx_modules_dynamic_geoip && nginx_configure+=" --with-http_geoip_module=dynamic"

	# enable dynamic ngx_http_image_filter_module
	use nginx_modules_dynamic_image_filter && nginx_configure+=" --with-http_image_filter_module=dynamic"

	# enable dynamic POP3/IMAP4/SMTP proxy module
	use nginx_modules_dynamic_mail && nginx_configure+=" --with-mail=dynamic"

	#	# enable dynamic ngx_http_perl_module
	#	use nginx_modules_dynamic_perl && nginx_configure+=" --with-http_perl_module=dynamic"

	# enable dynamic TCP/UDP proxy module
	use nginx_modules_dynamic_stream && nginx_configure+=" --with-stream=dynamic"

	# enable dynamic ngx_stream_geoip_module
	use nginx_modules_dynamic_stream_geoip && nginx_configure+=" --with-stream_geoip_module=dynamic"

	# enable dynamic ngx_http_xslt_module
	use nginx_modules_dynamic_xslt && nginx_configure+=" --with-http_xslt_module=dynamic"

	# Fix https://bugs.funtoo.org/browse/FL-6539
	use nginx_modules_external_ndk && http_enabled=1 && nginx_configure+=" --add-module=${mod_wd['ndk']}"

	for m in ${!mod_a[@]} ; do
		[[ $m == "ndk" ]] && continue
		use nginx_modules_external_${m} && http_enabled=1 && nginx_configure+=" --add-module=${mod_wd[$m]}"
	done

	if use nginx_modules_external_lua ; then
		http_enabled=1
		export LUAJIT_LIB=$(pkg-config --variable libdir luajit)
		export LUAJIT_INC=$(pkg-config --variable includedir luajit)
	fi

	if use http || use http-cache || use http2; then
		http_enabled=1
	fi

	if [[ $http_enabled ]] ; then
		use http-cache || nginx_configure+=" --without-http-cache"
		use ssl && nginx_configure+=" --with-http_ssl_module"
	else
		nginx_configure+=" --without-http --without-http-cache"
	fi

	if use stream ; then
		stream_enabled=1
	fi

	if [[ $stream_enabled ]] ; then
		nginx_configure+=" --with-stream"
		use ssl && nginx_configure+=" --with-stream_ssl_module"
	fi

	for m in ${mods[mail]} ; do
		use nginx_modules_mail_${m} && \
			mail_enabled=1 || \
			nginx_configure+=" --without-mail_${m}_module"
	done

	if [[ -n "${mail_enabled}" ]] ; then
		nginx_configure+=" --with-mail"
		use ssl && nginx_configure+=" --with-mail_ssl_module"
	fi

	for mod in $NGINX_ADD_MODULES; do
		nginx_configure+=" --add-module=${mod}"
	done

	# https://bugs.gentoo.org/286772
	export LANG=C LC_ALL=C
	tc-export CC

	if ! use prefix; then
		nginx_configure+=" --user=${PN} --group=${PN}"
	fi

	./configure \
		--prefix="${EPREFIX}/usr" \
		--conf-path="${EPREFIX}/etc/${PN}/${PN}.conf" \
		--error-log-path="${EPREFIX}/var/log/${PN}/error_log" \
		--pid-path="${EPREFIX}/run/${PN}.pid" \
		--lock-path="${EPREFIX}/run/lock/${PN}.lock" \
		--with-cc-opt="-I${EROOT}usr/include${WITHOUT_IPV6}" \
		--with-ld-opt="-L${EROOT}usr/$(get_libdir)" \
		--http-log-path="${EPREFIX}/var/log/${PN}/access_log" \
		--http-client-body-temp-path="${EPREFIX}/${NGINX_HOME_TMP}/client" \
		--http-proxy-temp-path="${EPREFIX}/${NGINX_HOME_TMP}/proxy" \
		--http-fastcgi-temp-path="${EPREFIX}/${NGINX_HOME_TMP}/fastcgi" \
		--http-scgi-temp-path="${EPREFIX}/${NGINX_HOME_TMP}/scgi" \
		--http-uwsgi-temp-path="${EPREFIX}/${NGINX_HOME_TMP}/uwsgi" \
		$(use_with poll poll_module) \
		$(use_with select select_module) \
		--with-compat \
		${nginx_configure} || die "configure failed"

	# A purely cosmetic change that makes nginx -V more readable. This can be
	# good if people outside the gentoo community would troubleshoot and
	# question the users setup.
	sed -e "s;${WORKDIR};external_module;g" -i "${S}/objs/ngx_auto_config.h" || die
}

src_compile() {
	use nginx_modules_external_modsecurity && emake -C "${WORKDIR}/${mod_p[modsecurity]}"

	# https://bugs.gentoo.org/286772
	export LANG=C LC_ALL=C
	emake LINK="${CC} ${LDFLAGS}" OTHERLDFLAGS="${LDFLAGS}"
}

src_install() {
	emake DESTDIR="${ED}" install

	insinto "${EROOT}etc/${PN}"
	doins "${FILESDIR}/${PN}.conf"

	newinitd "${FILESDIR}/${PN}.initd" "${PN}"

	keepdir "${EROOT}etc/${PN}"/sites-{available,enabled}
	insinto "${EROOT}etc/${PN}/sites-available"
	doins "${FILESDIR}/sites-available/localhost"
	dodir "${EROOT}usr/share/nginx/html"
	insinto "${EROOT}usr/share/nginx/html"
	doins "${FILESDIR}/example/index.html"
	doins "${FILESDIR}/example/nginx-logo.png"
	doins "${FILESDIR}/example/powered-by-funtoo.png"

	doman "${S}/man/nginx.8"
	dodoc CHANGES* README

	# just keepdir. do not copy the default htdocs files (bug #449136)
	keepdir "${EROOT}var/www/localhost"
	rm -r "${ED}usr/html" || die
	# set up a list of directories to keep

	local keepdir_list="${NGINX_HOME_TMP}/client"
	local m
	for m in proxy fastcgi scgi uwsgi; do
		use nginx_modules_http_${m} && keepdir_list+=" ${NGINX_HOME_TMP}/${m}"
	done

	keepdir /var/log/nginx ${keepdir_list}

	# this solves a problem with SELinux where nginx doesn't see the directories
	# as root and tries to create them as nginx
	fperms 0750 "${NGINX_HOME_TMP}"
	fowners ${PN}:0 "${NGINX_HOME_TMP}"

	fperms 0700 ${keepdir_list}
	fowners ${PN}:${PN} ${keepdir_list}

	fperms 0750 /var/log/nginx
	fowners 0:${PN} /var/log/nginx
	# logrotate
	insinto /etc/logrotate.d
	newins "${FILESDIR}/${PN}.logrotate" "${PN}"
	keepdir_list+=" /var/log/${PN}"

	# Don't create /run
	rm -rf "${ED%/}"/run || die

#	if use luajit; then
#		pax-mark m "${ED%/}/usr/sbin/nginx"
#	fi

	if use nginx_modules_http_perl ; then
		cd "${S}/objs/src/http/modules/perl"
		emake DESTDIR="${ED}" INSTALLDIRS=vendor install
		perl_delete_localpod
	fi

	for m in ${!mod_a[@]} ; do
	if use nginx_modules_external_${m} ; then
		docinto "${mod_p[$m]}"
		for d in ${mod_doc[$m]} ; do
			dodoc ${WORKDIR}/${mod_p[$m]}/${d} ; done
	fi
	done
}

pkg_preinst() {
	if [[ ! -d "${EROOT}etc/${PN}/sites-available" ]] ; then
		first_install=yes
	else
		first_install=no
	fi
}

pkg_postinst() {
	if [[ "${first_install}" = "yes" ]] && \
		[[ ! -e "${EROOT}etc/${PN}/sites-enabled/localhost" ]] ; then
			einfo "Enabling example Web site (see http://127.0.0.1)"
			ln -s "../sites-available/localhost" \
			"${EROOT}etc/${PN}/sites-enabled/localhost" || \
			die
	fi

	if use ssl; then
		if [[ ! -f "${EROOT}"etc/ssl/${PN}/${PN}.key ]]; then
			install_cert /etc/ssl/${PN}/${PN}
			use prefix || chown ${PN}:${PN} "${EROOT}"etc/ssl/${PN}/${PN}.{crt,csr,key,pem}
		fi
	fi

# 	if use nginx_modules_http_spdy; then
# 		ewarn ""
# 		ewarn "In nginx 1.9.5 the spdy module was superseded by http2."
# 		ewarn "Update your configs and package.use accordingly."
# 	fi

# 	if use nginx_modules_http_lua; then
# 		ewarn ""
# 		ewarn "While you can build lua 3rd party module against ${P}"
# 		ewarn "the author warns that >=${PN}-1.11.11 is still not an"
# 		ewarn "officially supported target yet. You are on your own."
# 		ewarn "Expect runtime failures, memory leaks and other problems!"
# 	fi
#
# 	if use nginx_modules_http_lua && use http2; then
# 		ewarn ""
# 		ewarn "Lua 3rd party module author warns against using ${P} with"
# 		ewarn "NGINX_MODULES_HTTP=\"lua http2\". For more info, see https://git.io/OldLsg"
# 	fi

	einfo "If nginx complains about insufficient number of open files at"
	einfo "start, ensure that you have a correct /etc/security/limits.conf"
	einfo "and then do relogin to your system to ensure that the new max"
	einfo "open file limits are active. Then try restarting nginx again."

	# If the nginx user can't change into or read the dir, display a warning.
	# If su is not available we display the warning nevertheless since
	# we can't check properly
	su -s /bin/sh -c "cd ${EROOT}var/log/${PN} && ls" ${PN} >&/dev/null
	if [[ $? -ne 0 ]] ; then
		ewarn "Please make sure that the (${PN}) user"
		ewarn "or (${PN}) group has"
		ewarn "at least 'rx' permissions (default on fresh install)"
		ewarn "on ${EROOT}var/log/${PN} directory."
		ewarn "Otherwise you end up with empty log files"
		ewarn "after a logrotate."
		# Contrary to this warning, it was not the default for <nginx-1.19.4-r2
		ewarn "Attempting to fix permissions automatically:"
		ewarn "Changing group ownership to ${PN} and adding 'rx' to group."
		chown :${PN} ${EROOT}var/log/${PN}
		chmod g+rx ${EROOT}var/log/${PN}
	fi
}



