# Copyright 2020 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit flag-o-matic ninja-utils toolchain-funcs

MY_PV="${PV/_p/_r}"
MY_P="${PN}-${MY_PV}"

DESCRIPTION="Core libraies for android tools"
HOMEPAGE="https://android.googlesource.com/platform/system/core/"
SRC_URI="https://android.googlesource.com/platform/system/core/+archive/refs/tags/android-${MY_PV}.tar.gz -> ${P}.tar.gz"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="libbacktrace"

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
	unpack_into "${P}.tar.gz" system/core

	cp "${FILESDIR}"/${P}-build.ninja build.ninja || die
}

src_prepare() {

	eapply "${FILESDIR}"/${P}-build.patch

	if use elibc_musl; then
		eapply "${FILESDIR}"/${P}-musl.patch
		#580686
		find "${S}" -name '*.h' -exec \
			sed -e 's|^#include <sys/cdefs.h>$|/* \0 */|' \
				-e 's|^__BEGIN_DECLS$|#ifdef __cplusplus\nextern "C" {\n#endif|' \
				-e 's|^__END_DECLS$|#ifdef __cplusplus\n}\n#endif|' \
				-i {} \; || die
	fi

	find "${S}" -name '*.h' -exec \
		sed -e 's|^#include <stdatomic.h>$|#ifndef __cplusplus\n# include <stdatomic.h>\n#else\n# include <atomic>\n# define _Atomic(X) std::atomic< X >\nusing namespace std;\n#endif|' \
		-i {} \; || die

	#sed -e 's|operator = (static_cast<const VectorImpl&>(rhs))|operator = const_cast<VectorImpl*>(static_cast<const VectorImpl&>(rhs))|' \
	#	-i system/core/include/utils/Vector.h || die

# operator = (static_cast<const VectorImpl&>(rhs))
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
	dolib.so lib{base,log,cutils,utils,ziparchive}.so
	doheader -r system/core/lib{cutils,log,system,utils,ziparchive}/include/*
	doheader -r system/core/base/include/*
}
