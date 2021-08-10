# Distributed under the terms of the GNU General Public License v2

EAPI=7
EGO_PN="github.com/docker/libnetwork"

EGIT_COMMIT=64b7a4574d1426139437d20e81c0b6d391130ec8
SRC_URI="https://github.com/docker/libnetwork/archive/${EGIT_COMMIT}.tar.gz -> ${P}.tar.gz"
KEYWORDS="*"
inherit golang-vcs-snapshot

DESCRIPTION="Docker container networking"
HOMEPAGE="https://github.com/docker/libnetwork"

LICENSE="Apache-2.0"
SLOT="0"

S=${WORKDIR}/${P}/src/${EGO_PN}

# needs dockerd
RESTRICT="strip test"

src_compile() {
	GO111MODULE=auto GOPATH="${WORKDIR}/${P}" \
		go build -o "bin/docker-proxy" ./cmd/proxy || die
}

src_install() {
	dodoc README.md CHANGELOG.md
	dobin bin/docker-proxy
}
