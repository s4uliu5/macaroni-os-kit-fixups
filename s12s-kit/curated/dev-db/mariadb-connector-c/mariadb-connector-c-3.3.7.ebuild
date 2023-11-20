# Distributed under the terms of the GNU General Public License v2

EAPI=7

MY_PN=${PN#mariadb-}
MY_PV=${PV/_b/-b}
SRC_URI="https://downloads.mariadb.com/Connectors/c/connector-c-${PV}/${P}-src.tar.gz"
S="${WORKDIR%/}/${PN}-${MY_PV}-src"
KEYWORDS="*"

inherit cmake toolchain-funcs

DESCRIPTION="C client library for MariaDB/MySQL"
HOMEPAGE="https://mariadb.org/"

LICENSE="LGPL-2.1"
SLOT="0/3"
IUSE="+curl gnutls kerberos +ssl static-libs test"
RESTRICT="!test? ( test )"

DEPEND="
	sys-libs/zlib:=
	virtual/libiconv:=
	curl? ( net-misc/curl )
	kerberos? (
		|| (
			app-crypt/mit-krb5
			app-crypt/heimdal
		)
	)
	ssl? (
		gnutls? ( >=net-libs/gnutls-3.3.24:= )
		!gnutls? ( dev-libs/openssl:= )
	)
"
BDEPEND="test? ( dev-db/mariadb[server] )"
RDEPEND="${DEPEND}"

# MULTILIB_CHOST_TOOLS=( /usr/bin/mariadb_config )
# MULTILIB_WRAPPED_HEADERS+=( /usr/include/mariadb/mariadb_version.h )

PATCHES=(
	"${FILESDIR}"/${PN}-3.1.3-fix-pkconfig-file.patch
	"${FILESDIR}"/${PN}-3.3.7-remove-zstd.patch
)

src_prepare() {
	# These tests the remote_io plugin which requires network access
	sed -i 's/{"test_remote1", test_remote1, TEST_CONNECTION_NEW, 0, NULL, NULL},//g' "unittest/libmariadb/misc.c" || die

	# These tests don't work with --skip-grant-tables
	sed -i 's/{"test_conc366", test_conc366, TEST_CONNECTION_DEFAULT, 0, NULL, NULL},//g' "unittest/libmariadb/connection.c" || die
	sed -i 's/{"test_conc66", test_conc66, TEST_CONNECTION_DEFAULT, 0, NULL,  NULL},//g' "unittest/libmariadb/connection.c" || die

	# [Warning] Aborted connection 2078 to db: 'test' user: 'root' host: '' (Got an error reading communication packets)
	# Not sure about this one - might also require network access
	sed -i 's/{"test_default_auth", test_default_auth, TEST_CONNECTION_NONE, 0, NULL, NULL},//g' "unittest/libmariadb/connection.c" || die

	cmake_src_prepare
}

src_configure() {
	# mariadb cannot use ld.gold, bug #508724
	tc-ld-disable-gold

	local mycmakeargs=(
		-DWITH_EXTERNAL_ZLIB=ON
		-DWITH_SSL:STRING=$(usex ssl $(usex gnutls GNUTLS OPENSSL) OFF)
		-DWITH_CURL=$(usex curl)
		-DWITH_ICONV=ON
		-DCLIENT_PLUGIN_AUTH_GSSAPI_CLIENT:STRING=$(usex kerberos DYNAMIC OFF)
		-DMARIADB_UNIX_ADDR="${EPREFIX}/var/run/mysqld/mysqld.sock"
		-DINSTALL_LIBDIR="$(get_libdir)"
		-DINSTALL_MANDIR=share/man
		-DINSTALL_PCDIR="$(get_libdir)/pkgconfig"
		-DINSTALL_PLUGINDIR="$(get_libdir)/mariadb/plugin"
		-DINSTALL_BINDIR=bin
		-DWITH_UNIT_TESTS=$(usex test)
	)

	cmake_src_configure
}

src_test() {
	mkdir -vp "${T}/mysql/data" || die

	maridb_install_db --no-defaults --datadir="${T}/mysql/data" || die
	mysqld --no-defaults --datadir="${T}/mysql/data" --socket="${T}/mysql/mysql.sock" --skip-grant-tables --skip-networking &

	while ! maridbadmin ping --socket="${T}/mysql/mysql.sock" --silent ; do
		sleep 1
	done

	cd unittest/libmariadb || die
	MYSQL_TEST_SOCKET="${T}/mysql/mysql.sock" MARIADB_CC_TEST=1 ctest --verbose || die
}

src_install_all() {
	if ! use static-libs ; then
		find "${ED}" -name "*.a" -delete || die
	fi
}
