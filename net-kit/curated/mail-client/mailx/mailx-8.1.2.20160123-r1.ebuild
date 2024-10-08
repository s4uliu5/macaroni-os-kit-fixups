# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit eutils flag-o-matic

DP="bsd-${PN}_${PV%.*}-0.${PV##*.}cvs"
DPT="${DP}.orig.tar.bz2"
DPP="${DP}-4.debian.tar.xz"

DESCRIPTION="The $ mail program, which is used to send mail via shell scripts"
HOMEPAGE="https://www.debian.org/"
SRC_URI="http://http.debian.net/debian/pool/main/b/bsd-${PN}/${DPT}
	http://http.debian.net/debian/pool/main/b/bsd-${PN}/${DPP}"

S="${WORKDIR}/${DP/_/-}.orig"

LICENSE="BSD"
SLOT="0"
KEYWORDS="*"
IUSE=""

DEPEND=">=net-libs/liblockfile-1.03
	dev-libs/libbsd
	virtual/mta
	mail-client/mailx-support"

RDEPEND="${DEPEND}
	!mail-client/nail
	!net-mail/mailutils"

PATCHES=(
	"${WORKDIR}/debian/patches"
	"${FILESDIR}/${PN}-8.1.2.20050715-offsetof.patch"
)

src_compile() {
	append-cflags "-fcommon"
	emake CC=$(tc-getCC) EXTRAFLAGS="${CFLAGS}"
}

src_install() {
	dobin mail

	doman mail.1

	dosym mail /usr/bin/Mail
	dosym mail /usr/bin/mailx
	dosym mail.1 /usr/share/man/man1/Mail.1

	insinto /usr/share/mailx/
	doins misc/mail.help misc/mail.tildehelp
	insinto /etc
	doins misc/mail.rc
}
