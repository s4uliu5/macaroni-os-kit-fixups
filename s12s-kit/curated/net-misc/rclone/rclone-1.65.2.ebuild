# Distributed under the terms of the GNU General Public License v2

EAPI=7
inherit bash-completion-r1 go-module

GO_MOD_TIDY_SKIP=true

go-module_set_globals

KEYWORDS="*"
SRC_URI="https://github.com/rclone/rclone/tarball/d7c7d0e893d931405d01788273bd0f01ff8ffb96 -> rclone-1.65.2-d7c7d0e.tar.gz
https://s12s.xyz/funtoo/distfiles/rclone-1.65.2-deps.tar.xz -> rclone-1.65.2-deps.tar.xz"

DESCRIPTION="A program to sync files to and from various cloud storage providers"
HOMEPAGE="https://rclone.org/"

LICENSE="Apache-2.0 BSD BSD-2 ISC MIT"
SLOT="0"
IUSE="+mount"

post_src_unpack() {
	mv ${WORKDIR}/rclone-* "${S}" || die
}

src_compile() {
	go build -mod=mod . || die "compile failed"
}

src_install() {
	dobin ${PN}
	doman ${PN}.1
	dodoc README.md

	./rclone genautocomplete bash ${PN}.bash || die
	newbashcomp ${PN}.bash ${PN}

	./rclone genautocomplete zsh ${PN}.zsh || die
	insinto /usr/share/zsh/site-functions
	newins ${PN}.zsh _${PN}

	use mount && insinto /usr/bin && \
		doins ${FILESDIR}/rclonefs && \
		fperms +x /usr/bin/rclonefs
}
