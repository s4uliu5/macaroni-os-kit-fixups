# Distributed under the terms of the GNU General Public License v2

EAPI=7

# Generate using https://github.com/thesamesam/sam-gentoo-scripts/blob/main/niche/generate-cmake-docs
# Set to 1 if prebuilt, 0 if not
# (the construct below is to allow overriding from env for script)
: ${CMAKE_DOCS_PREBUILT:=1}

CMAKE_DOCS_PREBUILT_DEV=sam
CMAKE_DOCS_VERSION=$(ver_cut 1-2).0
# Default to generating docs (inc. man pages) if no prebuilt; overridden later
# See bug #784815
CMAKE_DOCS_USEFLAG="+doc"

# TODO RunCMake.LinkWhatYouUse fails consistently w/ ninja
# ... but seems fine as of 3.22.3?
# TODO ... but bootstrap sometimes(?) fails with ninja now. bug #834759.
CMAKE_MAKEFILE_GENERATOR="emake"
CMAKE_REMOVE_MODULES_LIST=( none )
inherit bash-completion-r1 cmake flag-o-matic multiprocessing toolchain-funcs

MY_P="${P/_/-}"

DESCRIPTION="Cross platform Make"
HOMEPAGE="https://cmake.org/"
SRC_URI="https://cmake.org/files/v$(ver_cut 1-2)/${MY_P}.tar.gz"

if [[ ${CMAKE_DOCS_PREBUILT} == 1 ]] ; then
	SRC_URI+=" !doc? ( https://dev.gentoo.org/~${CMAKE_DOCS_PREBUILT_DEV}/distfiles/dev-build/${PN}/${PN}-${CMAKE_DOCS_VERSION}-docs.tar.xz )"
fi

KEYWORDS="*"


[[ ${CMAKE_DOCS_PREBUILT} == 1 ]] && CMAKE_DOCS_USEFLAG="doc"

S="${WORKDIR}/${MY_P}"

LICENSE="BSD"
SLOT="0"
IUSE="${CMAKE_DOCS_USEFLAG} dap ncurses test"
RESTRICT="!test? ( test )"

RDEPEND="
	>=app-arch/libarchive-3.3.3:=
	app-crypt/rhash:0=
	>=dev-libs/expat-2.0.1
	>=dev-libs/jsoncpp-1.9.2-r2:0=
	>=dev-libs/libuv-1.10.0:=
	>=net-misc/curl-7.21.5[ssl]
	sys-libs/zlib
	virtual/pkgconfig
	dap? ( dev-cpp/cppdap )
	ncurses? ( sys-libs/ncurses:= )
"
DEPEND="${RDEPEND}"
BDEPEND+="
	doc? (
		dev-python/requests
		dev-python/sphinx
	)
	test? ( app-arch/libarchive[zstd] )
"

SITEFILE="50${PN}-gentoo.el"

PATCHES=(
	# Prefix
	"${FILESDIR}"/${PN}-3.27.0_rc1-0001-Don-t-use-.so-for-modules-on-darwin-macos.-Use-.bund.patch
	"${FILESDIR}"/${PN}-3.27.0_rc1-0002-Set-some-proper-paths-to-make-cmake-find-our-tools.patch
	# Misc
	"${FILESDIR}"/${PN}-3.31.6-Prefer-pkgconfig-in-FindBLAS.patch
	"${FILESDIR}"/${PN}-3.27.0_rc1-0004-Ensure-that-the-correct-version-of-Qt-is-always-used.patch
	"${FILESDIR}"/${PN}-3.27.0_rc1-0005-Respect-Gentoo-s-Python-eclasses.patch
	# Cuda
	"${FILESDIR}"/${PN}-3.30.3-cudahostld.patch

	# Upstream fixes (can usually be removed with a version bump)
	"${FILESDIR}"/${PN}-3.31.7-hdf5.patch
	"${FILESDIR}/${PN}-4.1.1-curl-8.16.0.patch"
)

cmake_src_bootstrap() {
	# disable running of cmake in bootstrap command
	sed -i \
		-e '/"${cmake_bootstrap_dir}\/cmake"/s/^/#DONOTRUN /' \
		bootstrap || die "sed failed"

	# bootstrap script isn't exactly /bin/sh compatible
	tc-env_build ${CONFIG_SHELL:-sh} ./bootstrap \
		--prefix="${T}/cmakestrap/" \
		--parallel=$(makeopts_jobs "${MAKEOPTS}" "$(get_nproc)") \
		|| die "Bootstrap failed"
}

pkg_pretend() {
	if [[ -z ${EPREFIX} ]] ; then
		local file
		local errant_files=()

		# See bug #599684 and bug #753581 (at least)
		for file in /etc/arch-release /etc/redhat-release /etc/debian_version ; do
			if [[ -e ${file} ]]; then
				errant_files+=( "${file}" )
			fi
		done

		# If errant files exist
		if [[ ${#errant_files[@]} -gt 0 ]]; then
			eerror "Errant files found!"
			eerror "The presence of these files is known to confuse CMake's"
			eerror "library path logic. Please (re)move these files:"

			for file in "${errant_files[@]}"; do
				eerror " mv ${file} ${file}.bak"
			done

			die "Stray files found in /etc/, see above message"
		fi
	fi
}

src_unpack() {
	cd "${WORKDIR}" || die

	default
}

src_prepare() {
	cmake_src_prepare

	# Add gcc libs to the default link paths
	sed -i \
		-e "s|@GENTOO_PORTAGE_GCCLIBDIR@|${EPREFIX}/usr/${CHOST}/lib/|g" \
		-e "$(usex prefix-guest "s|@GENTOO_HOST@||" "/@GENTOO_HOST@/d")" \
		-e "s|@GENTOO_PORTAGE_EPREFIX@|${EPREFIX}/|g" \
		Modules/Platform/{UnixPaths,Darwin}.cmake || die "sed failed"

	## in theory we could handle these flags in src_configure, as we do in many other packages. But we *must*
	## handle them as part of bootstrapping, sadly.

	# ODR warnings, bug #858335
	# https://gitlab.kitware.com/cmake/cmake/-/issues/20740
	filter-lto

	if ! has_version -b \>=${CATEGORY}/${PN}-3.13 || ! cmake --version &>/dev/null ; then
		CMAKE_BINARY="${S}/Bootstrap.cmk/cmake"
		cmake_src_bootstrap
	fi
}

src_configure() {
	local mycmakeargs=(
		-DCMAKE_USE_SYSTEM_LIBRARIES=ON
		-DCMake_ENABLE_DEBUGGER=$(usex dap)
		-DCMAKE_DOC_DIR=/share/doc/${PF}
		-DCMAKE_MAN_DIR=/share/man
		-DCMAKE_DATA_DIR=/share/${PN}
		-DSPHINX_MAN=$(usex doc)
		-DSPHINX_HTML=$(usex doc)
		-DBUILD_CursesDialog="$(usex ncurses)"
		-DBUILD_TESTING=$(usex test)
	)

	cmake_src_configure
}

src_test() {
	# Fix OutDir and SelectLibraryConfigurations tests
	# these are altered thanks to our eclass
	sed -i -e 's:^#_cmake_modify_IGNORE ::g' \
		"${S}"/Tests/{OutDir,CMakeOnly/SelectLibraryConfigurations}/CMakeLists.txt \
		|| die

	unset CLICOLOR CLICOLOR_FORCE CMAKE_COMPILER_COLOR_DIAGNOSTICS CMAKE_COLOR_DIAGNOSTICS

	pushd "${BUILD_DIR}" > /dev/null || die

	# Excluded tests:
	#    BootstrapTest: we actually bootstrap it every time so why test it?
	#    BundleUtilities: bundle creation broken
	#    CMakeOnly.AllFindModules: pthread issues
	#    CTest.updatecvs: which fails to commit as root
	#    Fortran: requires fortran
	#    RunCMake.CompilerLauncher: also requires fortran
	#    RunCMake.CPack_RPM: breaks if app-arch/rpm is installed because
	#        debugedit binary is not in the expected location
	#    RunCMake.CPack_DEB: breaks if app-arch/dpkg is installed because
	#        it can't find a deb package that owns libc
	#    TestUpload, which requires network access
	#    RunCMake.CMP0125, known failure reported upstream (bug #829414)
	local myctestargs=(
		--output-on-failure
		-E "(BootstrapTest|BundleUtilities|CMakeOnly.AllFindModules|CompileOptions|CTest.UpdateCVS|Fortran|RunCMake.CompilerLauncher|RunCMake.CPack_(DEB|RPM)|TestUpload|RunCMake.CMP0125)" \
	)

	local -x QT_QPA_PLATFORM=offscreen

	cmake_src_test
}

src_install() {
	cmake_src_install

	# If USE=doc, there'll be newly generated docs which we install instead.
	if ! use doc && [[ ${CMAKE_DOCS_PREBUILT} == 1 ]] ; then
		doman "${WORKDIR}"/${PN}-${CMAKE_DOCS_VERSION}-docs/man*/*.[0-8]
	fi

	insinto /usr/share/vim/vimfiles/syntax
	doins Auxiliary/vim/syntax/cmake.vim

	insinto /usr/share/vim/vimfiles/indent
	doins Auxiliary/vim/indent/cmake.vim

	insinto /usr/share/vim/vimfiles/ftdetect
	doins "${FILESDIR}/${PN}.vim"

	dobashcomp Auxiliary/bash-completion/{${PN},ctest,cpack}
}
