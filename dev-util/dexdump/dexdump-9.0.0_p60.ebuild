# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI="7"

inherit flag-o-matic ninja-utils toolchain-funcs

MY_PV="${PV/_p/_r}"
MY_P=${PN}-${MY_PV}

DESCRIPTION="Android build tools dexdeump"
HOMEPAGE="https://android.googlesource.com/platform/dalvik"
# The ninja file was created by running the ruby script from archlinux by hand and fixing the build vars.
# No point in depending on something large/uncommon like ruby just to generate a ninja file.
SRC_URI="https://android.googlesource.com/platform/dalvik/+archive/refs/tags/android-${MY_PV}/${PN}.tar.gz -> ${P}.tar.gz
	https://android.googlesource.com/platform/dalvik/+archive/refs/tags/android-${MY_PV}/libdex.tar.gz -> ${P}-libdex.tar.gz
	https://android.googlesource.com/platform/system/core/+archive/refs/tags/android-${MY_PV}/base.tar.gz -> ${P}-base.tar.gz
	https://android.googlesource.com/platform/system/core/+archive/refs/tags/android-${MY_PV}/include.tar.gz -> ${P}-include.tar.gz
	https://android.googlesource.com/platform/system/core/+archive/refs/tags/android-${MY_PV}/libbacktrace.tar.gz -> ${P}-libbacktrace.tar.gz
	https://android.googlesource.com/platform/system/core/+archive/refs/tags/android-${MY_PV}/libcutils.tar.gz -> ${P}-libcutils.tar.gz
	https://android.googlesource.com/platform/system/core/+archive/refs/tags/android-${MY_PV}/liblog.tar.gz -> ${P}-liblog.tar.gz
	https://android.googlesource.com/platform/system/core/+archive/refs/tags/android-${MY_PV}/libsystem.tar.gz -> ${P}-libsystem.tar.gz
	https://android.googlesource.com/platform/system/core/+archive/refs/tags/android-${MY_PV}/libutils.tar.gz -> ${P}-libutils.tar.gz
	https://android.googlesource.com/platform/system/core/+archive/refs/tags/android-${MY_PV}/libziparchive.tar.gz -> ${P}-libziparchive.tar.gz"

# The entire source code is Apache-2.0, except for fastboot which is BSD-2.
LICENSE="Apache-2.0 BSD-2"
SLOT="0"
KEYWORDS="~amd64 ~arm ~arm64 ~x86"
IUSE=""

DEPEND="dev-libs/safe-iop:=
	dev-libs/nativehelper:=
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
	unpack_into "${P}.tar.gz" dalvik/"${PN}"
	unpack_into "${P}-libdex.tar.gz" dalvik/libdex
	unpack_into "${P}-base.tar.gz" system/core/base
	unpack_into "${P}-include.tar.gz" system/core/include
	unpack_into "${P}-libbacktrace.tar.gz" system/core/libbacktrace
	unpack_into "${P}-libcutils.tar.gz" system/core/libcutils
	unpack_into "${P}-liblog.tar.gz" system/core/liblog
	unpack_into "${P}-libsystem.tar.gz" system/core/libsystem
	unpack_into "${P}-libutils.tar.gz" system/core/libutils
	unpack_into "${P}-libziparchive.tar.gz" system/core/libziparchive

	cp "${FILESDIR}/${P}-build.ninja" "build.ninja" || die
}

src_prepare() {
	eapply "${FILESDIR}"/${P}-build.patch
	eapply "${FILESDIR}"/${P}-musl.patch

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
	dobin dexdump
}
