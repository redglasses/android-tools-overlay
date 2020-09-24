# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI="7"

inherit flag-o-matic ninja-utils toolchain-funcs

MY_PV="${PV/_p/_r}"
MY_P=${PN}-${MY_PV}

DESCRIPTION="a tool that lets users abstract away IPC in Android."
HOMEPAGE="https://source.android.com/devices/architecture/aidl/overview"
# The ninja file was created by running the ruby script from archlinux by hand and fixing the build vars.
# No point in depending on something large/uncommon like ruby just to generate a ninja file.
SRC_URI="https://android.googlesource.com/platform/system/tools/aidl/+archive/refs/tags/android-${MY_PV}.tar.gz -> ${P}.tar.gz"

# The entire source code is Apache-2.0, except for fastboot which is BSD-2.
LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~amd64 ~arm ~arm64 ~x86"
IUSE=""

DEPEND="dev-libs/android-core:=
	dev-libs/androidfw:=
	dev-libs/expat:=
	dev-libs/protobuf:=
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
	unpack_into "${P}.tar.gz" system/tools/"${PN}"

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

	sed -e 's|%pure-parser||' -i "${S}"/system/tools/aidl/aidl_language_y.yy || die

	lex	-o "${S}"/system/tools/aidl/aidl_language_l.cpp "${S}"/system/tools/aidl/aidl_language_l.ll || die
	yacc --defines="${S}"/system/tools/aidl/aidl_language_y.h -o "${S}"/system/tools/aidl/aidl_language_y.cpp "${S}"/system/tools/aidl/aidl_language_y.yy || die

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
	dobin aidl
}
