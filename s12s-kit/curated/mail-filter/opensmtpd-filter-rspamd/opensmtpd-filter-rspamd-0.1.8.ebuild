# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit go-module

DESCRIPTION="OpenSMTPD filter for putting emails through rspamd"
HOMEPAGE="https://github.com/poolpOrg/filter-rspamd"
SRC_URI="https://github.com/docker/compose/archive/v${MY_PV}.tar.gz -> ${P}.tar.gz
https://s12s.host.funtoo.org/funtoo/distfiles/${CATEGORY}/${PN}/${P}-deps.tar.xz"

LICENSE="ISC"
SLOT="0"
KEYWORDS="*"
IUSE=""

DEPEND=""
RDEPEND="${DEPEND} mail-mta/opensmtpd"
BDEPEND=""

S=${WORKDIR}/${P#opensmtpd-}
DOCS=( README.md )

src_compile() {
	go build -ldflags="-s -w" -buildmode=pie -o filter-rspamd || die
}

src_install() {
	default
	exeinto /usr/libexec/opensmtpd
	doexe filter-rspamd
}
