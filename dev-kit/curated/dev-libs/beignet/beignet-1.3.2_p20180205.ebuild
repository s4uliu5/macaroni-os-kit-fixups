# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

PYTHON_COMPAT=( python2+ )
CMAKE_BUILD_TYPE="Release"

inherit python-any-r1 cmake-multilib flag-o-matic llvm toolchain-funcs

DESCRIPTION="OpenCL implementation for Intel GPUs"
HOMEPAGE="https://01.org/beignet"
COMMIT_ID="7e181af2ea4d37f67406f2563c0e13fa1fdbb14b"
LICENSE="LGPL-2.1+"
SLOT="0"
IUSE="ocl-icd ocl20"

if [[ "${PV}" == "9999" ]]; then
	inherit git-r3
	EGIT_REPO_URI="https://anongit.freedesktop.org/git/beignet.git"
	KEYWORDS="amd64"
else
	KEYWORDS="amd64"
	SRC_URI="https://cgit.freedesktop.org/${PN}/snapshot/${COMMIT_ID}.tar.gz -> ${P}.tar.gz"
	S=${WORKDIR}/${COMMIT_ID}
fi

COMMON="media-libs/mesa[${MULTILIB_USEDEP}]
	<sys-devel/clang-6.0.0:=[${MULTILIB_USEDEP}]
	>=x11-libs/libdrm-2.4.70[video_cards_intel,${MULTILIB_USEDEP}]
	x11-libs/libXext[${MULTILIB_USEDEP}]
	x11-libs/libXfixes[${MULTILIB_USEDEP}]"
RDEPEND="${COMMON}
	app-eselect/eselect-opencl"
DEPEND="${COMMON}
	${PYTHON_DEPS}
	ocl-icd? ( dev-libs/ocl-icd )
	virtual/pkgconfig"

LLVM_MAX_SLOT=5

PATCHES=(
	"${FILESDIR}"/${PN}-build.patch
)

DOCS=(
	docs/.
)

pkg_pretend() {
	if [[ ${MERGE_TYPE} != "binary" ]]; then
		if tc-is-gcc; then
			if [[ $(gcc-major-version) -eq 4 ]] && [[ $(gcc-minor-version) -lt 6 ]]; then
				eerror "Compilation with gcc older than 4.6 is not supported"
				die "Too old gcc found."
			fi
		fi
	fi
}

pkg_setup() {
	llvm_pkg_setup
	python_setup
}

src_prepare() {
	# See Bug #593968
	append-flags -fPIC

	cmake-utils_src_prepare
	# We cannot run tests because they require permissions to access
	# the hardware, and building them is very time-consuming.
	cmake_comment_add_subdirectory utests
}

multilib_src_configure() {
	VENDOR_DIR="/usr/$(get_libdir)/OpenCL/vendors/${PN}"

	local mycmakeargs=(
		-DCMAKE_INSTALL_PREFIX="${VENDOR_DIR}"
		-DOCLICD_COMPAT=$(usex ocl-icd)
		$(usex ocl20 "" "-DENABLE_OPENCL_20=OFF")
	)

	cmake-utils_src_configure
}

multilib_src_install() {
	VENDOR_DIR="/usr/$(get_libdir)/OpenCL/vendors/${PN}"

	cmake-utils_src_install

	insinto /etc/OpenCL/vendors/
	echo "${VENDOR_DIR}/lib/${PN}/libcl.so" > "${PN}-${ABI}.icd" || die "Failed to generate ICD file"
	doins "${PN}-${ABI}.icd"

	dosym "lib/${PN}/libcl.so" "${VENDOR_DIR}"/libOpenCL.so.1
	dosym "lib/${PN}/libcl.so" "${VENDOR_DIR}"/libOpenCL.so
	dosym "lib/${PN}/libcl.so" "${VENDOR_DIR}"/libcl.so.1
	dosym "lib/${PN}/libcl.so" "${VENDOR_DIR}"/libcl.so
}
