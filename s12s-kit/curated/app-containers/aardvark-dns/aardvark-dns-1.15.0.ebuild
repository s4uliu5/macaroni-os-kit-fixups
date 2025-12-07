# Distributed under the terms of the GNU General Public License v2

EAPI=7

CRATES="${PN}@${PV}"
inherit cargo

DESCRIPTION="A container-focused DNS server"
HOMEPAGE="https://github.com/containers/aardvark-dns"

SRC_URI="${CARGO_CRATE_URIS}"
SRC_URI+="https://github.com/containers/aardvark-dns/releases/download/v${PV}/${PN}-v${PV}-vendor.tar.gz"
KEYWORDS="*"

# main
LICENSE="Apache-2.0"
# deps
LICENSE+=" 0BSD Apache-2.0-with-LLVM-exceptions MIT Unlicense Unicode-DFS-2016 ZLIB"
SLOT="0"
QA_FLAGS_IGNORED="usr/libexec/podman/${PN}"
QA_PRESTRIPPED="usr/libexec/podman/${PN}"
ECARGO_VENDOR="${WORKDIR}/vendor"

src_unpack() {
	cargo_src_unpack
}

src_prepare() {
	default
	sed -i -e "s|m0755 bin|m0755 $(cargo_target_dir)|g;" Makefile || die
}

src_install() {
	export PREFIX="${EPREFIX}"/usr
	default
}
