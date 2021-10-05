# Distributed under the terms of the GNU General Public License v2

EAPI="7"

CMAKE_MAKEFILE_GENERATOR=emake

inherit cmake flag-o-matic linux-info multiprocessing prefix toolchain-funcs user

MY_PV="${PV//_pre*}"
MY_P="${PN}-${MY_PV}"

# Patch version
PATCH_SET="https://dev.gentoo.org/~whissi/dist/mysql/mysql-8.0.26-patches-01.tar.xz"

SRC_URI="https://cdn.mysql.com/Downloads/MySQL-8.0/mysql-boost-${MY_PV}.tar.gz
	https://cdn.mysql.com/archives/mysql-8.0/mysql-boost-${MY_PV}.tar.gz
	http://downloads.mysql.com/archives/MySQL-8.0/mysql-boost-${MY_PV}.tar.gz
	${PATCH_SET}"

HOMEPAGE="https://www.mysql.com/"
DESCRIPTION="A fast, multi-threaded, multi-user SQL database server"
LICENSE="GPL-2"
SLOT="8.0"
IUSE="cjk cracklib debug jemalloc latin1 numa +perl profiling router selinux +server tcmalloc"
S="${WORKDIR}"/mysql-${PV}

REQUIRED_USE="?? ( tcmalloc jemalloc )
	cjk? ( server )
	jemalloc? ( server )
	numa? ( server )
	profiling? ( server )
	router? ( server )
	tcmalloc? ( server )"

KEYWORDS="next"

COMMON_DEPEND="
	>=app-arch/lz4-0_p131:=
	app-arch/zstd:=
	sys-libs/ncurses:0=
	>=sys-libs/zlib-1.2.3:0=
	>=dev-libs/openssl-1.0.0:0=
	server? (
		dev-libs/icu:=
		dev-libs/libevent:=[ssl,threads]
		>=dev-libs/protobuf-3.8:=
		net-libs/libtirpc:=
		cjk? ( app-text/mecab:= )
		jemalloc? ( dev-libs/jemalloc:0= )
		kernel_linux? (
			dev-libs/libaio:0=
			sys-process/procps:0=
		)
		numa? ( sys-process/numactl )
		tcmalloc? ( dev-util/google-perftools:0= )
	)
"

DEPEND="
	${COMMON_DEPEND}
	sys-devel/gcc
	virtual/yacc
	server? ( net-libs/rpcsvc-proto )
"

RDEPEND="
	${COMMON_DEPEND}
	!dev-db/mariadb !dev-db/mariadb-galera !dev-db/percona-server !dev-db/mysql-cluster
	!dev-db/mysql:0
	!dev-db/mysql:5.7
	selinux? ( sec-policy/selinux-mysql )
	!prefix? (
		dev-db/mysql-init-scripts
	)
"

# For other stuff to bring us in
# dev-perl/DBD-mysql is needed by some scripts installed by MySQL
PDEPEND="perl? ( >=dev-perl/DBD-mysql-2.9004 )"

mysql_init_vars() {
	: ${MY_SHAREDSTATEDIR="${EPREFIX}/usr/share/mysql"}
	: ${MY_SYSCONFDIR="${EPREFIX}/etc/mysql"}
	: ${MY_LOCALSTATEDIR="${EPREFIX}/var/lib/mysql"}
	: ${MY_LOGDIR="${EPREFIX}/var/log/mysql"}
	MY_DATADIR="${MY_LOCALSTATEDIR}"

	export MY_SHAREDSTATEDIR MY_SYSCONFDIR
	export MY_LOCALSTATEDIR MY_LOGDIR
	export MY_DATADIR
}

pkg_setup() {
	if use numa ; then
		linux-info_get_any_version
		local CONFIG_CHECK="~NUMA"
		local WARNING_NUMA="This package expects NUMA support in kernel which this system does not have at the moment;"
		WARNING_NUMA+=" Either expect runtime errors, enable NUMA support in kernel or rebuild the package without NUMA support"
		check_extra_config
	fi
	enewgroup mysql 60 || die "problem adding 'mysql' group"
	enewuser mysql 60 -1 /dev/null mysql || die "problem adding 'mysql' user"
}

src_prepare() {
	eapply "${WORKDIR}"/mysql-patches

	# Avoid rpm call which would trigger sandbox, #692368
	sed -i \
		-e 's/MY_RPM rpm/MY_RPM rpmNOTEXISTENT/' \
		CMakeLists.txt || die

	# Remove the centos and rhel selinux policies to support mysqld_safe under SELinux
	if [[ -d "${S}/support-files/SELinux" ]] ; then
		echo > "${S}/support-files/SELinux/CMakeLists.txt" || die
	fi

	# Remove man pages for client-lib tools we don't install
	rm \
		man/my_print_defaults.1 \
		man/perror.1 \
		man/zlib_decompress.1 \
		|| die

	cmake_src_prepare
}

src_configure() {
	# Bug #114895, bug #110149
	filter-flags "-O" "-O[01]"

	append-cxxflags -felide-constructors

	# code is not C++17 ready, bug #786402
	append-cxxflags -std=c++14

	# bug #283926, with GCC4.4, this is required to get correct behavior.
	append-flags -fno-strict-aliasing

	CMAKE_BUILD_TYPE="RelWithDebInfo"

	# debug hack wrt #497532
	mycmakeargs=(
		-DCMAKE_C_FLAGS_RELWITHDEBINFO="$(usex debug '' '-DNDEBUG')"
		-DCMAKE_CXX_FLAGS_RELWITHDEBINFO="$(usex debug '' '-DNDEBUG')"
		-DMYSQL_DATADIR="${EPREFIX}/var/lib/mysql"
		-DSYSCONFDIR="${EPREFIX}/etc/mysql"
		-DINSTALL_BINDIR=bin
		-DINSTALL_DOCDIR=share/doc/${PF}
		-DINSTALL_DOCREADMEDIR=share/doc/${PF}
		-DINSTALL_INCLUDEDIR=include/mysql
		-DINSTALL_INFODIR=share/info
		-DINSTALL_LIBDIR=$(get_libdir)
		-DINSTALL_MANDIR=share/man
		-DINSTALL_MYSQLSHAREDIR=share/mysql
		-DINSTALL_PLUGINDIR=$(get_libdir)/mysql/plugin
		-DINSTALL_MYSQLDATADIR="${EPREFIX}/var/lib/mysql"
		-DINSTALL_SBINDIR=sbin
		-DINSTALL_SUPPORTFILESDIR="${EPREFIX}/usr/share/mysql"
		-DCOMPILATION_COMMENT="Funtoo Linux ${PF}"
		-DWITH_UNIT_TESTS=OFF
		# Using bundled editline to get CTRL+C working
		-DWITH_EDITLINE=bundled
		-DWITH_ZLIB=system
		-DWITH_SSL=system
		-DWITH_LIBWRAP=0
		-DENABLED_LOCAL_INFILE=1
		-DMYSQL_UNIX_ADDR="${EPREFIX}/var/run/mysqld/mysqld.sock"
		-DWITH_DEFAULT_COMPILER_OPTIONS=0
		# The build forces this to be defined when cross-compiling. We pass it
		# all the time for simplicity and to make sure it is actually correct.
		-DSTACK_DIRECTION=$(tc-stack-grows-down && echo -1 || echo 1)
		-DCMAKE_POSITION_INDEPENDENT_CODE=ON
		-DWITH_CURL=system
		-DWITH_BOOST="${S}/boost"
		-DWITH_ROUTER=$(usex router ON OFF)
	)

	if is-flagq -fno-lto ; then
		einfo "LTO disabled via {C,CXX,F,FC}FLAGS"
		mycmakeargs+=( -DWITH_LTO=OFF )
	elif is-flagq -flto ; then
		einfo "LTO forced via {C,CXX,F,FC}FLAGS"
		myconf+=( -DWITH_LTO=ON )
	else
		# Disable automagic
		myconf+=( -DWITH_LTO=OFF )
	fi

	mycmakeargs+=( -DINSTALL_MYSQLTESTDIR='' )
	mycmakeargs+=( -DWITHOUT_CLIENTLIBS=YES )

	mycmakeargs+=(
		-DWITH_ICU=system
		-DWITH_LZ4=system
		# Our dev-libs/rapidjson doesn't carry necessary fixes for std::regex
		-DWITH_RAPIDJSON=bundled
		-DWITH_ZSTD=system
	)

	if [[ -n "${MYSQL_DEFAULT_CHARSET}" && -n "${MYSQL_DEFAULT_COLLATION}" ]] ; then
		ewarn "You are using a custom charset of ${MYSQL_DEFAULT_CHARSET}"
		ewarn "and a collation of ${MYSQL_DEFAULT_COLLATION}."
		ewarn "You MUST file bugs without these variables set."
		ewarn "Tests will probably fail!"

		mycmakeargs+=(
			-DDEFAULT_CHARSET=${MYSQL_DEFAULT_CHARSET}
			-DDEFAULT_COLLATION=${MYSQL_DEFAULT_COLLATION}
		)
	elif use latin1 ; then
		mycmakeargs+=(
			-DDEFAULT_CHARSET=latin1
			-DDEFAULT_COLLATION=latin1_swedish_ci
		)
	else
		mycmakeargs+=(
			-DDEFAULT_CHARSET=utf8mb4
			-DDEFAULT_COLLATION=utf8mb4_0900_ai_ci
		)
	fi

	if use server ; then
		mycmakeargs+=(
			-DWITH_EXTRA_CHARSETS=all
			-DWITH_DEBUG=$(usex debug)
			-DWITH_MECAB=$(usex cjk system OFF)
			-DWITH_LIBEVENT=system
			-DWITH_PROTOBUF=system
			-DWITH_NUMA=$(usex numa ON OFF)
		)

		if use jemalloc ; then
			mycmakeargs+=( -DWITH_JEMALLOC=ON )
		elif use tcmalloc ; then
			mycmakeargs+=( -DWITH_TCMALLOC=ON )
		fi

		if use profiling ; then
			# Setting to OFF doesn't work: Once set, profiling options will be added
			# to `mysqld --help` output via sql/sys_vars.cc causing
			# "main.mysqld--help-notwin" test to fail
			mycmakeargs+=( -DENABLED_PROFILING=ON )
		fi

		# Storage engines
		mycmakeargs+=(
			-DWITH_EXAMPLE_STORAGE_ENGINE=0
			-DWITH_ARCHIVE_STORAGE_ENGINE=1
			-DWITH_BLACKHOLE_STORAGE_ENGINE=1
			-DWITH_CSV_STORAGE_ENGINE=1
			-DWITH_FEDERATED_STORAGE_ENGINE=1
			-DWITH_HEAP_STORAGE_ENGINE=1
			-DWITH_INNOBASE_STORAGE_ENGINE=1
			-DWITH_INNODB_MEMCACHED=0
			-DWITH_MYISAMMRG_STORAGE_ENGINE=1
			-DWITH_MYISAM_STORAGE_ENGINE=1
		)
	else
		mycmakeargs+=(
			-DWITHOUT_SERVER=1
			-DWITH_SYSTEMD=no
		)
	fi

	cmake_src_configure
}

src_install() {
	cmake_src_install

	# Make sure the vars are correctly initialized
	mysql_init_vars

	# Convenience links
	einfo "Making Convenience links for mysqlcheck multi-call binary"
	dosym "mysqlcheck" "/usr/bin/mysqlanalyze"
	dosym "mysqlcheck" "/usr/bin/mysqlrepair"
	dosym "mysqlcheck" "/usr/bin/mysqloptimize"

	# INSTALL_LAYOUT=STANDALONE causes cmake to create a /usr/data dir
	if [[ -d "${ED}/usr/data" ]] ; then
		rm -Rf "${ED}/usr/data" || die
	fi

	# Unless they explicitly specific USE=test, then do not install the
	# testsuite. It DOES have a use to be installed, esp. when you want to do a
	# validation of your database configuration after tuning it.
	rm -rf "${ED}/${MY_SHAREDSTATEDIR#${EPREFIX}}/mysql-test"

	# Configuration stuff
	einfo "Building default configuration ..."
	insinto "${MY_SYSCONFDIR#${EPREFIX}}"
	[[ -f "${S}/scripts/mysqlaccess.conf" ]] && doins "${S}"/scripts/mysqlaccess.conf
	cp "${FILESDIR}/my.cnf-8.0" "${TMPDIR}/my.cnf" || die
	eprefixify "${TMPDIR}/my.cnf"
	doins "${TMPDIR}/my.cnf"
	insinto "${MY_SYSCONFDIR#${EPREFIX}}/mysql.d"
	cp "${FILESDIR}/my.cnf-8.0.distro-client" "${TMPDIR}/50-distro-client.cnf" || die
	eprefixify "${TMPDIR}/50-distro-client.cnf"
	doins "${TMPDIR}/50-distro-client.cnf"

	mycnf_src="my.cnf-8.0.distro-server"
	sed -e "s!@DATADIR@!${MY_DATADIR}!g" \
		"${FILESDIR}/${mycnf_src}" \
		> "${TMPDIR}/my.cnf.ok" || die

	if use prefix ; then
		sed -i -r -e '/^user[[:space:]]*=[[:space:]]*mysql$/d' \
			"${TMPDIR}/my.cnf.ok" || die
	fi

	if use latin1 ; then
		sed -i \
			-e "/character-set/s|utf8mb4|latin1|g" \
			"${TMPDIR}/my.cnf.ok" || die
	fi

	eprefixify "${TMPDIR}/my.cnf.ok"

	newins "${TMPDIR}/my.cnf.ok" 50-distro-server.cnf

	#Remove mytop if perl is not selected
	[[ -e "${ED}/usr/bin/mytop" ]] && ! use perl && rm -f "${ED}/usr/bin/mytop"

	if use router ; then
		rm -rf \
			"${ED}/usr/LICENSE.router" \
			"${ED}/usr/README.router" \
			"${ED}/usr/run" \
			"${ED}/usr/var" \
			|| die
	fi

	# Kill old libmysqclient_r symlinks if they exist. Time to fix what depends on them.
	find "${D}" -name 'libmysqlclient_r.*' -type l -delete || die
}

pkg_postinst() {
	# Make sure the vars are correctly initialized
	mysql_init_vars

	# Create log directory securely if it does not exist
	# NOTE: $MY_LOGDIR contains $EPREFIX by default
	[[ -d "${MY_LOGDIR}" ]] || install -d -m0750 -o mysql -g mysql "${MY_LOGDIR}"

	# Note about configuration change
	einfo
	elog "This version of ${PN} reorganizes the configuration from a single my.cnf"
	elog "to several files in /etc/mysql/mysql.d."
	elog "Please backup any changes you made to /etc/mysql/my.cnf"
	elog "and add them as a new file under /etc/mysql/mysql.d with a .cnf extension."
	elog "You may have as many files as needed and they are read alphabetically."
	elog "Be sure the options have the appropriate section headers, i.e. [mysqld]."
	einfo
	elog "Please follow these steps for initial setup. Run these commands as root:"
	einfo
	elog "# mysqld --initialize-insecure --default_authentication_plugin=mysql_native_password --datadir=${EPREFIX}/var/lib/mysql"
	elog "# /etc/init.d/mysql start"
	elog "# mysql_secure_installation"
	einfo
	elog "See https://www.funtoo.org/Package:Mysql-community for more information."

}
