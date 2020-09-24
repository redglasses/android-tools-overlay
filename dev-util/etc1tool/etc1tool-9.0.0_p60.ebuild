# Copyright 2020 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit flag-o-matic toolchain-funcs

MY_PV="${PV/_p/_r}"
MY_P=${PN}-${MY_PV}

DESCRIPTION="a command line utility that lets you encode/decode ETC1 compressiion PNG image"
HOMEPAGE="https://android.googlesource.com/platform/development/"

SRC_URI="https://android.googlesource.com/platform/development/+archive/refs/tags/android-${MY_PV}/tools/${PN}.tar.gz -> ${P}.tar.gz
	https://android.googlesource.com/platform/frameworks/native/+archive/refs/tags/android-${MY_PV}/opengl/libs/ETC1.tar.gz -> ${P}-libetc1.tar.gz
	https://android.googlesource.com/platform/frameworks/native/+archive/refs/tags/android-${MY_PV}/opengl/include.tar.gz -> ${P}-include.tar.gz"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~amd64 ~arm ~arm64 ~x86"
IUSE=""

DEPEND="dev-libs/expat:=
	media-libs/libpng:=
	sys-libs/zlib:="
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
	unpack_into "${P}-libetc1.tar.gz" .
	unpack_into "${P}-include.tar.gz" include
}

src_compile() {
	$(tc-getCXX) ${CFLAGS} ${CPPFLAGS} -Iinclude -c -o etc1.o etc1.cpp || die
	$(tc-getCXX) ${CFLAGS} ${CPPFLAGS} -Iinclude -c -o ${PN}.o ${PN}.cpp || die
	$(tc-getCXX) ${LDFLAGS} -o ${PN} ${PN}.o etc1.o -lpng -lexpat -lz || die
}

src_install() {
	dobin ${PN}
}
