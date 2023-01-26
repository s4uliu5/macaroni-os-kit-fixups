# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit flag-o-matic optfeature

DESCRIPTION="A powerful light-weight programming language designed for extending applications"
HOMEPAGE="https://www.lua.org/"
# tarballs produced from ${PV} branches in https://gitweb.gentoo.org/proj/lua-patches.git
SRC_URI="https://dev.gentoo.org/~soap/distfiles/${P}.tar.xz"

LICENSE="MIT"
SLOT="5.4"
KEYWORDS="*"
IUSE="+deprecated readline"

DEPEND="
	>=app-eselect/eselect-lua-3
	readline? ( sys-libs/readline:= )
	!dev-lang/lua:0"
RDEPEND="${DEPEND}"
BDEPEND="virtual/pkgconfig"

PATCHES=(
	"${FILESDIR}/${P}-lparser-overread.patch"
)

src_prepare() {
	default

	if use elibc_musl; then
		# locales on musl are non-functional (#834153)
		# https://wiki.musl-libc.org/open-issues.html#Locale-limitations
		sed -e 's|os.setlocale("pt_BR") or os.setlocale("ptb")|false|g' \
			-i tests/literals.lua || die
	fi
}

src_configure() {
	use deprecated && append-cppflags -DLUA_COMPAT_5_3
	econf $(use_with readline)
}

src_install() {
	default
	find "${ED}" -name '*.la' -delete || die
}

pkg_postinst() {
	eselect lua set --if-unset "${PN}${SLOT}"

	optfeature "Lua support for Emacs" app-emacs/lua-mode
}