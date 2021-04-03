# Distributed under the terms of the GNU General Public License v2

EAPI=7

DESCRIPTION="Manages the {,/usr}/sbin/iptables symlink"
HOMEPAGE="https://wiki.gentoo.org/wiki/No_homepage"
SRC_URI="https://dev.gentoo.org/~chutzpah/dist/iptables/${P}.tar.xz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="*"

RDEPEND="app-admin/eselect"

src_install() {
	insinto /usr/share/eselect/modules
	doins iptables.eselect

	local symlink
	for symlink in {eb,arp}tables; do
		dosym iptables.eselect /usr/share/eselect/modules/${symlink}.eselect
	done
}
