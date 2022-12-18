# Distributed under the terms of the GNU General Public License v2

EAPI=7

DESCRIPTION="Lua eselect module"
HOMEPAGE="https://wiki.gentoo.org/wiki/No_homepage"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="*"
IUSE=""

RDEPEND="app-admin/eselect
	!dev-lang/lua:0"

S="${WORKDIR}"

src_install() {
	insinto /usr/share/eselect/modules/
	newins "${FILESDIR}"/lua.eselect-${PV} lua.eselect
}
