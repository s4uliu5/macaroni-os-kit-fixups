# Distributed under the terms of the GNU General Public License v2

EAPI=7

DESCRIPTION="A collection of profiles for the AppArmor application security system"
HOMEPAGE="https://gitlab.com/apparmor/apparmor/wikis/home"
SRC_URI="https://gitlab.com/apparmor/apparmor/-/archive/v${PV}/apparmor-v${PV}.tar.bz2 -> ${P}.tar.bz2"

S=${WORKDIR}/apparmor-v${PV}/profiles

LICENSE="GPL-2"
SLOT="0/$(ver_cut 1-2)"
KEYWORDS="*"
IUSE="minimal"
RESTRICT="test"

src_install() {
	if use minimal ; then
		insinto /etc/apparmor.d
		doins -r apparmor.d/{abi,abstractions,tunables}
	else
		default
	fi
}
