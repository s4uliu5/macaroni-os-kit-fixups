# Distributed under the terms of the GNU General Public License v2

EAPI=6
PYTHON_COMPAT=( python3+ )

inherit eutils elisp-common gnome3 python-single-r1 readme.gentoo-r1

DESCRIPTION="GTK+ Documentation Generator"
HOMEPAGE="https://www.gtk.org/gtk-doc/"

LICENSE="GPL-2 FDL-1.1"
SLOT="0"
KEYWORDS="*"

IUSE="debug doc emacs"
REQUIRED_USE="${PYTHON_REQUIRED_USE}"

RDEPEND="
	${PYTHON_DEPS}
	!<dev-util/gtk-doc-am-1.29-r2
	>=dev-libs/glib-2.62.2:2
	>=dev-lang/perl-5.18
	dev-libs/libxslt
	>=dev-libs/libxml2-2.3.6:2
	~app-text/docbook-xml-dtd-4.3
	app-text/docbook-xsl-stylesheets
	~app-text/docbook-sgml-dtd-3.0
	>=app-text/docbook-dsssl-stylesheets-1.40
	emacs? ( virtual/emacs )
	dev-python/pygments
"
DEPEND="${RDEPEND}
	app-text/yelp-tools
	virtual/pkgconfig
"
pkg_setup() {
	DOC_CONTENTS="gtk-doc does no longer define global key bindings for Emacs.
		You may set your own key bindings for \"gtk-doc-insert\" and
		\"gtk-doc-insert-section\" in your ~/.emacs file."
	SITEFILE=61${PN}-gentoo.el
	python-single-r1_pkg_setup
}

src_prepare() {
	# Remove global Emacs keybindings, bug #184588
	eapply "${FILESDIR}"/${PN}-1.32-emacs-keybindings.patch

	gnome3_src_prepare
}

src_configure() {
	gnome3_src_configure \
		--with-xml-catalog="${EPREFIX}"/etc/xml/catalog \
		$(use_enable debug)
}

src_compile() {
	gnome3_src_compile
	use emacs && elisp-compile tools/gtk-doc.el
}

src_install() {
	gnome3_src_install
	python_fix_shebang "${ED}"/usr/bin/gtkdoc-depscan

	if use doc; then
		docinto doc
		dodoc doc/*
		docinto examples
		dodoc examples/*
	fi

	if use emacs; then
		elisp-install ${PN} tools/gtk-doc.el*
		elisp-site-file-install "${FILESDIR}/${SITEFILE}"
		readme.gentoo_create_doc
	fi
	# gtkdoc-mktmpl still required for some old software. FL-6013.
	newbin "${FILESDIR}"/gtkdoc-mktmpl gtkdoc-mktmpl
	insinto /usr/share/gtk-doc/data
	doins "${FILESDIR}"/gtkdoc-common.pl
}

pkg_postinst() {
	gnome3_pkg_postinst
	if use emacs; then
		elisp-site-regen
		readme.gentoo_print_elog
	fi
}

pkg_postrm() {
	gnome3_pkg_postrm
	use emacs && elisp-site-regen
}
