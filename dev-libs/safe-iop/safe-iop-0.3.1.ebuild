# Copyright 2020 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

MY_PV=$(ver_cut 1-2)

DESCRIPTION="Safe integer operations."
HOMEPAGE="https://code.google.com/archive/p/safe-iop/"
SRC_URI="https://storage.googleapis.com/google-code-archive-downloads/v2/code.google.com/${PN}/${P}.tgz"

LICENSE="BSD"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="static-libs"

DEPEND=""
RDEPEND="${DEPEND}"
BDEPEND=""

src_install() {
	dolib.so libsafe_iop.so.${MY_PV}
	dosym libsafe_iop.so.${MY_PV} /usr/$(get_libdir)/libsafe-iop.so

	insinto /usr/include
	doins include/safe_iop.h
}

src_compile() {
	use static-libs && append-flags -static
	emake so || die
}
