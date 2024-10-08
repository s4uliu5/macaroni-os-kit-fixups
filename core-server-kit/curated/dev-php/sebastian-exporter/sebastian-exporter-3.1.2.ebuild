# Distributed under the terms of the GNU General Public License v2

EAPI=7

MY_PN="${PN/sebastian-//}"

DESCRIPTION="Export PHP variables for visualization"
HOMEPAGE="https://phpunit.de"
SRC_URI="https://github.com/sebastianbergmann/${MY_PN}/archive/${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="BSD"
SLOT="0"
KEYWORDS="*"
IUSE=""

S="${WORKDIR}/${MY_PN}-${PV}"

RDEPEND="dev-php/fedora-autoloader
	=dev-php/sebastian-recursion-context-3*
	=dev-lang/php-7*:*"

src_install() {
	insinto /usr/share/php/SebastianBergmann/Exporter
	doins -r src/*
	doins "${FILESDIR}/autoload.php"
}
