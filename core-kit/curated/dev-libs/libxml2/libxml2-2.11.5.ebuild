# Distributed under the terms of the GNU General Public License v2

EAPI=7

# Note: Please bump in sync with dev-libs/libxslt

inherit autotools flag-o-matic gnome.org libtool

XSTS_HOME="http://www.w3.org/XML/2004/xml-schema-test-suite"
XSTS_NAME_1="xmlschema2002-01-16"
XSTS_NAME_2="xmlschema2004-01-14"
XSTS_TARBALL_1="xsts-2002-01-16.tar.gz"
XSTS_TARBALL_2="xsts-2004-01-14.tar.gz"
XMLCONF_TARBALL="xmlts20130923.tar.gz"

DESCRIPTION="XML C parser and toolkit"
HOMEPAGE="https://gitlab.gnome.org/GNOME/libxml2/-/wikis/home"
KEYWORDS=""

SRC_URI+="
	test? (
		${XSTS_HOME}/${XSTS_NAME_1}/${XSTS_TARBALL_1}
		${XSTS_HOME}/${XSTS_NAME_2}/${XSTS_TARBALL_2}
		https://www.w3.org/XML/Test/${XMLCONF_TARBALL}
	)
"
S="${WORKDIR}/${PN}-${PV%_rc*}"

LICENSE="MIT"
SLOT="2"
IUSE="debug examples +ftp icu lzma +python readline static-libs test"
RESTRICT="!test? ( test )"

RDEPEND="
	virtual/libiconv
	>=sys-libs/zlib-1.2.8-r1:=
	icu? ( >=dev-libs/icu-51.2-r1:= )
	lzma? ( >=app-arch/xz-utils-5.0.5-r1:= )
	python? ( dev-python/libxml2-python )
	readline? ( sys-libs/readline:= )
"
DEPEND="${RDEPEND}"
BDEPEND="virtual/pkgconfig
dev-util/gtk-doc-am"

PATCHES=(
	"${FILESDIR}"/${PN}-2.11.5-CVE-2023-45322.patch
)

src_unpack() {
	local tarname=${P/_rc/-rc}.tar.xz

	# ${A} isn't used to avoid unpacking of test tarballs into ${WORKDIR},
	# as they are needed as tarballs in ${S}/xstc instead and not unpacked
	unpack ${tarname}

	if [[ -n ${PATCHSET_VERSION} ]] ; then
		unpack ${PN}-${PATCHSET_VERSION}.tar.xz
	fi

	cd "${S}" || die

	if use test ; then
		cp "${DISTDIR}/${XSTS_TARBALL_1}" \
			"${DISTDIR}/${XSTS_TARBALL_2}" \
			"${S}"/xstc/ \
			|| die "Failed to install test tarballs"
		unpack ${XMLCONF_TARBALL}
	fi
}

src_configure() {
	# Filter seemingly problematic CFLAGS (bug #26320)
	filter-flags -fprefetch-loop-arrays -funroll-loops

	# Notes:
	# The meaning of the 'debug' USE flag does not apply to the --with-debug
	# switch (enabling the libxml2 debug module). See bug #100898.
	ECONF_SOURCE="${S}" econf \
		--enable-ipv6 \
		$(use_with ftp) \
		$(use_with debug run-debug) \
		$(use_with icu) \
		$(use_with lzma) \
		$(use_enable static-libs static) \
		$(use_with readline) \
		$(use_with readline history) \
		--without-python
}

src_test() {
	ln -s "${S}"/xmlconf || die
	emake check
}

src_install() {
	emake DESTDIR="${D}" install
	einstalldocs

	if ! use examples ; then
		rm -rf "${ED}"/usr/share/doc/${PF}/examples || die
		rm -rf "${ED}"/usr/share/doc/${PF}/python/examples || die
	fi

	rm -rf "${ED}"/usr/share/doc/${PN}-python-${PVR} || die

	find "${ED}" -name '*.la' -delete || die
}

pkg_postinst() {
	# We don't want to do the xmlcatalog during stage1, as xmlcatalog will not
	# be in / and stage1 builds to ROOT=/tmp/stage1root. This fixes bug #208887.
	if [[ -n "${ROOT}" ]]; then
		elog "Skipping XML catalog creation for stage building (bug #208887)."
	else
		# Need an XML catalog, so no-one writes to a non-existent one
		CATALOG="${EROOT}/etc/xml/catalog"

		# We don't want to clobber an existing catalog though,
		# only ensure that one is there
		# <obz@gentoo.org>
		if [[ ! -e "${CATALOG}" ]]; then
			[[ -d "${EROOT}/etc/xml" ]] || mkdir -p "${EROOT}/etc/xml"
			"${EPREFIX}"/usr/bin/xmlcatalog --create > "${CATALOG}"
			einfo "Created XML catalog in ${CATALOG}"
		fi
	fi
}

# vim: ts=4 sw=4 noet
