# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI="7"

inherit flag-o-matic ninja-utils toolchain-funcs

MY_PV="${PV/_p/_r}"
MY_P=${PN}-${MY_PV}

DESCRIPTION="APK split and selection tool"
HOMEPAGE="https://android.googlesource.com/platform/frameworks/base/"
# The ninja file was created by running the ruby script from archlinux by hand and fixing the build vars.
# No point in depending on something large/uncommon like ruby just to generate a ninja file.
SRC_URI="https://android.googlesource.com/platform/frameworks/base/+archive/refs/tags/android-${MY_PV}/tools/${PN}.tar.gz -> ${P}.tar.gz
	https://android.googlesource.com/platform/frameworks/native/+archive/refs/tags/android-${MY_PV}/include.tar.gz -> ${P}-nativeinclude.tar.gz"

# The entire source code is Apache-2.0, except for fastboot which is BSD-2.
LICENSE="Apache-2.0 BSD-2"
SLOT="0"
KEYWORDS="~amd64 ~arm ~arm64 ~x86"
IUSE=""

DEPEND="dev-util/aapt:=
	dev-libs/android-core:=
	dev-libs/androidfw:=
	dev-libs/expat:=
	media-libs/libpng:=
	sys-libs/zlib:="
RDEPEND="${DEPEND}"

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
	unpack_into "${P}.tar.gz" frameworks/base/tools/"${PN}"
	unpack_into "${P}-nativeinclude.tar.gz" frameworks/native/include

	cp "${FILESDIR}/${P}-build.ninja" "build.ninja" || die
}

src_prepare() {
	if use elibc_musl; then
		cd "${S}"
		#580686
		find "${S}" -name '*.h' -exec \
			sed -e 's|^#include <sys/cdefs.h>$|/* \0 */|' \
				-e 's|^__BEGIN_DECLS$|#ifdef __cplusplus\nextern "C" {\n#endif|' \
				-e 's|^__END_DECLS$|#ifdef __cplusplus\n}\n#endif|' \
				-i {} \; || die
	fi

	default
}

src_configure() {
	append-lfs-flags

	sed -i \
		-e "s:@CC@:$(tc-getCC):g" \
		-e "s:@CXX@:$(tc-getCXX):g" \
		-e "s:@CFLAGS@:${CFLAGS}:g" \
		-e "s:@CPPFLAGS@:${CPPFLAGS}:g" \
		-e "s:@CXXFLAGS@:${CXXFLAGS}:g" \
		-e "s:@LDFLAGS@:${LDFLAGS}:g" \
		-e "s:@PV@:${PV}:g" \
		build.ninja || die
}

src_compile() {
	eninja
}

src_install() {
	dobin "${PN}"
	#dolib.so lib${PN}.so
}
