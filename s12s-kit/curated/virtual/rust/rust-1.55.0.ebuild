# Distributed under the terms of the GNU General Public License v2

EAPI=7

DESCRIPTION="Virtual for Rust language compiler"

LICENSE=""
SLOT="0"
KEYWORDS="*"

BDEPEND=""
RDEPEND="|| ( ~dev-lang/rust-${PV} ~dev-lang/rust-bin-${PV} )"
