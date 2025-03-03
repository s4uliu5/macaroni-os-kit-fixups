# Distributed under the terms of the GNU General Public License v2

EAPI=7

DISTUTILS_USE_PEP517=poetry
PYTHON_COMPAT=( python3+ )

inherit distutils-r1

DESCRIPTION="Interface Python with pkg-config"
HOMEPAGE="
	https://github.com/matze/pkgconfig/
	https://pypi.org/project/pkgconfig/
"
SRC_URI="
	https://github.com/matze/pkgconfig/archive/v${PV}.tar.gz
		-> ${P}.gh.tar.gz
"

LICENSE="MIT"
SLOT="0"
KEYWORDS="*"

RDEPEND="
	virtual/pkgconfig
"

distutils_enable_tests pytest
