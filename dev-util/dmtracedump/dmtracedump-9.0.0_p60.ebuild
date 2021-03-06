# Copyright 2020 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit flag-o-matic toolchain-funcs

MY_PV="${PV/_p/_r}"
MY_P=${PN}-${MY_PV}

DESCRIPTION="Java method trace dump tool"
HOMEPAGE="https://android.googlesource.com/platform/art/"

SRC_URI="https://android.googlesource.com/platform/art/+archive/refs/tags/android-${MY_PV}/tools/${PN}.tar.gz -> ${P}.tar.gz"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~amd64 ~arm ~arm64 ~x86"
IUSE=""

DEPEND=""
RDEPEND="${DEPEND}"
BDEPEND=""

S=${WORKDIR}

unpack_into() {
	local archive="$1"
	local dir="$2"

	mkdir -p "${dir}"
	pushd "${dir}" >/dev/null || die
	unpack "${archive}"
	popd >/dev/null
}

src_unpack() {
	unpack_into "${P}.tar.gz" .
}

src_compile() {
	$(tc-getCXX) ${CFLAGS} ${CPPFLAGS} ${LDFLAGS} -o ${PN} tracedump.cc || die
}

src_install() {
	dobin ${PN}
}
