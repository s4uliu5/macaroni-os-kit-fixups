# Distributed under the terms of the GNU General Public License v2

EAPI=7

PYTHON_COMPAT=( python3+ )

inherit cmake meson python-any-r1

DESCRIPTION="FUSE filesystem for LXC"
HOMEPAGE="https://linuxcontainers.org/lxcfs/introduction/ https://github.com/lxc/lxcfs/"
SRC_URI="https://linuxcontainers.org/downloads/lxcfs/${P}.tar.gz"

LICENSE="Apache-2.0 LGPL-2+"
SLOT="0"
KEYWORDS="*"
IUSE="doc test"

DEPEND="sys-fs/fuse:3"
RDEPEND="${DEPEND}"
BDEPEND="${PYTHON_DEPS}
	virtual/pkgconfig
	$(python_gen_any_dep '
		dev-python/jinja[${PYTHON_USEDEP}]
	')
	doc? ( sys-apps/help2man )"

# Needs some black magic to work inside container/chroot.
RESTRICT="test"

VERIFY_SIG_OPENPGP_KEY_PATH=/usr/share/openpgp-keys/linuxcontainers.asc

python_check_deps() {
	python_has_version -b "dev-python/jinja[${PYTHON_USEDEP}]"
}

pkg_setup() {
	python-any-r1_pkg_setup
}

src_prepare() {
	default

	# Fix python shebangs for python-exec[-native-symlinks], #851480
	local shebangs=($(grep -rl "#!/usr/bin/env python3" || die))
	python_fix_shebang -q ${shebangs[*]}
}

src_configure() {
	local emesonargs=(
		--localstatedir "${EPREFIX}/var"

		$(meson_use doc docs)
		$(meson_use test tests)

		-Dfuse-version=3
		-Dinit-script=""
		-Dwith-init-script=""
	)

	meson_src_configure
}

src_test() {
	cd "${BUILD_DIR}"/tests || die "failed to change into tests/ directory."
	./main.sh || die
}

src_install() {
	meson_src_install

	newinitd "${FILESDIR}"/6.0.0/lxcfs.initd lxcfs
	newconfd "${FILESDIR}"/6.0.0/lxcfs.confd lxcfs
}
