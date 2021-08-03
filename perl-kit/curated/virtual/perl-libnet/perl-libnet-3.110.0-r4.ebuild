# Distributed under the terms of the GNU General Public License v2

EAPI=7

DESCRIPTION="Virtual for ${PN#perl-}"
SLOT="0"
KEYWORDS="*"
IUSE="+ssl"

RDEPEND="
	|| ( =dev-lang/perl-5.32* =dev-lang/perl-5.30* ~perl-core/${PN#perl-}-${PV} )
	dev-lang/perl:=
	!<perl-core/${PN#perl-}-${PV}
	!>perl-core/${PN#perl-}-${PV}-r999
"
# https://bugs.gentoo.org/735004
PDEPEND="
	ssl? (
		>=dev-perl/IO-Socket-SSL-2.7.0
	)
"
