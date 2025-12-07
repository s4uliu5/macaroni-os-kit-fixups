# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit autotools

DESCRIPTION="A container init that is so simple it's effectively brain-dead"
HOMEPAGE="https://github.com/openSUSE/catatonit"

SRC_URI="https://github.com/openSUSE/${PN}/archive/v${PV}.tar.gz -> ${P}.tar.gz"
KEYWORDS="*"

LICENSE="GPL-2+"
SLOT="0"

src_prepare() {
	default
	eautoreconf
}

src_install() {
	default
	dodir /usr/libexec/podman
	dosym /usr/bin/"${PN}" /usr/libexec/podman/"${PN}"
}
