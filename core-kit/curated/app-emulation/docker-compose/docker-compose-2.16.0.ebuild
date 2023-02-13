# Distributed under the terms of the GNU General Public License v2

EAPI=7
inherit bash-completion-r1 go-module
MY_PV=${PV/_/-}

SRC_URI="https://github.com/docker/compose/archive/v${MY_PV}.tar.gz -> ${P}.tar.gz
	https://s12s.host.funtoo.org/funtoo/distfiles/${CATEGORY}/${PN}/${P}-deps.tar.xz"

DESCRIPTION="Multi-container orchestration for Docker"
HOMEPAGE="https://github.com/docker/compose"

LICENSE="Apache-2.0"
SLOT="2"
KEYWORDS="*"

RDEPEND=">=app-emulation/docker-cli-20.10.22"

S="${WORKDIR}/compose-${MY_PV}"

src_prepare() {
	default
	# do not strip
	sed -i -e 's/-s -w//' Makefile || die
}

src_compile() {
	emake VERSION=v${PV}
}

src_test() {
	emake test
}

src_install() {
	exeinto /usr/libexec/docker/cli-plugins
	doexe bin/build/docker-compose
	dodoc README.md
}

pkg_postinst() {
	ewarn
	ewarn "docker-compose 2.x is a sub command of docker"
	ewarn "Use 'docker compose' from the command line instead of"
	ewarn "'docker-compose'"
	ewarn "If you need to keep 1.x around, please run the following"
	ewarn "command before your next --depclean"
	ewarn "# emerge --noreplace docker-compose:0"
}
