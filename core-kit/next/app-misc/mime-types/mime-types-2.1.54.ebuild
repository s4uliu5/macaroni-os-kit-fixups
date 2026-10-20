# Distributed under the terms of the GNU General Public License v2

EAPI=7

DESCRIPTION="Provides /etc/mime.types file"
HOMEPAGE="https://pagure.io/mailcap"
SRC_URI="https://releases.pagure.org/mailcap/mailcap-2.1.54.tar.xz -> mailcap-2.1.54.tar.xz
"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="*"
IUSE=""

DEPEND=""
RDEPEND=""

S="${WORKDIR}/mailcap-${PV}"

src_install() {
	insinto /etc
	doins mime.types
}