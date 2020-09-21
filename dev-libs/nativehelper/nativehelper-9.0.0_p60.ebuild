# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI="7"

inherit flag-o-matic ninja-utils toolchain-funcs

MY_PV="${PV/_p/_r}"
MY_P=${PN}-${MY_PV}

DESCRIPTION="Android build tools dexdeump"
HOMEPAGE="https://android.googlesource.com/platform/libnativehelper"
# The ninja file was created by running the ruby script from archlinux by hand and fixing the build vars.
# No point in depending on something large/uncommon like ruby just to generate a ninja file.
SRC_URI="https://android.googlesource.com/platform/libnativehelper/+archive/refs/tags/android-${MY_PV}.tar.gz -> ${P}.tar.gz
	https://android.googlesource.com/platform/system/core/+archive/refs/tags/android-${MY_PV}/include.tar.gz -> ${P}-include.tar.gz
	https://android.googlesource.com/platform/system/core/+archive/refs/tags/android-${MY_PV}/libcutils.tar.gz -> ${P}-libcutils.tar.gz
	https://android.googlesource.com/platform/system/core/+archive/refs/tags/android-${MY_PV}/liblog.tar.gz -> ${P}-liblog.tar.gz
	https://android.googlesource.com/platform/system/core/+archive/refs/tags/android-${MY_PV}/libsystem.tar.gz -> ${P}-libsystem.tar.gz
	https://android.googlesource.com/platform/system/core/+archive/refs/tags/android-${MY_PV}/libutils.tar.gz -> ${P}-libutils.tar.gz"

# The entire source code is Apache-2.0, except for fastboot which is BSD-2.
LICENSE="Apache-2.0 BSD-2"
SLOT="0"
KEYWORDS="~amd64 ~arm ~arm64 ~x86"
IUSE=""

DEPEND="dev-libs/safe-iop:=
	sys-libs/zlib:="
RDEPEND="${DEPEND}"

S=${WORKDIR}

unpack_into() {
	local archive="$1"
	local dir="$2"

	mkdir -p "${dir}"
	pushd "${dir}" >/dev/null || die
	unpack "${archive}"
#	if [[ ${dir} != ./* ]] ; then
#		mv */* ./ || die
#	fi
	popd >/dev/null
}

src_unpack() {
	unpack_into "${P}.tar.gz" "lib${PN}"
	unpack_into "${P}-include.tar.gz" system/core/include
	unpack_into "${P}-libcutils.tar.gz" system/core/libcutils
	unpack_into "${P}-liblog.tar.gz" system/core/liblog
	unpack_into "${P}-libsystem.tar.gz" system/core/libsystem
	unpack_into "${P}-libutils.tar.gz" system/core/libutils

	cp "${FILESDIR}/${P}-build.ninja" "build.ninja" || die

	#cd "${S}"/libnativehelper/include && ln -s ../include nativehelper || die
	#cd "${S}"/libnativehelper/platform_include && ln -s ../platform_include nativehelper || die
}

src_prepare() {
	#cp "${FILESDIR}/${P}-build.ninja" "build.ninja" || die

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
	dolib.so lib${PN}.so
	doheader -r "lib${PN}"/{include,header_only_include}/"${PN}" "lib${PN}"/include_jni/jni.h
}
