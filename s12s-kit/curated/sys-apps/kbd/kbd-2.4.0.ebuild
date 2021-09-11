# Distributed under the terms of the GNU General Public License v2

EAPI=7

SRC_URI="https://www.kernel.org/pub/linux/utils/kbd/${P}.tar.xz"
KEYWORDS=""

DESCRIPTION="Keyboard and console utilities"
HOMEPAGE="http://kbd-project.org/"

LICENSE="GPL-2"
SLOT="0"
IUSE="nls pam test"
#RESTRICT="!test? ( test )"
# Upstream has strange assumptions how to run tests (see bug #732868)
RESTRICT="test"

RDEPEND="
	app-arch/gzip
	pam? (
		!app-misc/vlock
		sys-libs/pam
	)
"
DEPEND="${RDEPEND}"
BDEPEND="
	virtual/pkgconfig
	test? ( dev-libs/check )
"

src_unpack() {
	default

	# Rename conflicting keymaps to have unique names, bug #293228
	cd "${S}"/data/keymaps/i386 || die
	mv fgGIod/trf.map fgGIod/trf-fgGIod.map || die
	mv olpc/es.map olpc/es-olpc.map || die
	mv olpc/pt.map olpc/pt-olpc.map || die
	mv qwerty/cz.map qwerty/cz-qwerty.map || die
}

src_prepare() {
	default
}

src_configure() {
	local myeconfargs=(
		# USE="test" installs .a files
		--disable-static
		$(use_enable nls)
		$(use_enable pam vlock)
		$(use_enable test tests)
	)
	econf "${myeconfargs[@]}"
}

src_install() {
	default
	docinto html
	dodoc docs/doc/*.html

	# USE="test" installs .la files
	find "${ED}" -type f -name "*.la" -delete || die
}
