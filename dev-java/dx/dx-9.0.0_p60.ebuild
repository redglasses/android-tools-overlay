# Copyright 2008-2020 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI="7"
JAVA_PKG_IUSE="doc source"

inherit java-pkg-2 java-pkg-simple

MY_PV="${PV/_p/_r}"
MY_P=${PN}-${MY_PV}

DESCRIPTION=""
HOMEPAGE="https://android.googlesource.com/platform/dalvik/"
SRC_URI="https://android.googlesource.com/platform/dalvik/+archive/refs/tags/android-${MY_PV}/dx.tar.gz -> ${P}.tar.gz"

LICENSE="BSD"
SLOT="0/24"
KEYWORDS="~amd64 ~arm ~arm64 ~ppc64 ~x86 ~amd64-linux ~x86-linux ~x64-macos ~x86-macos"
IUSE=""

BDEPEND=">=virtual/jdk-1.7"
DEPEND=">=virtual/jdk-1.7"
RDEPEND=">=virtual/jre-1.7"

S="${WORKDIR}/${P}/src"

unpack_into() {
	local archive="$1"
	local dir="$2"

	mkdir -p "${dir}"
	pushd "${dir}" >/dev/null || die
	unpack "${archive}"
	popd >/dev/null
}

src_unpack() {
	unpack_into "${P}.tar.gz" "${WORKDIR}/${P}"
}

src_prepare() {
	pushd "${WORKDIR}/${P}" > /dev/null || die
	eapply_user
	popd > /dev/null || die

	default
}

src_compile() {
	JAVA_MAIN_CLASS="com.android.dx.command.Main" JAVA_JAR_FILENAME="${PN}.jar" java-pkg-simple_src_compile
}

src_install() {
	JAVA_JAR_FILENAME="${PN}.jar" java-pkg-simple_src_install

	exeinto /usr/share/${PN}/
	doexe ../etc/{${PN},mainDexClasses}
	insinto /usr/share/${PN}/
	doins ../etc/{mainDexClasses.rules,mainDexClassesNoAapt.rules}

	dosym /usr/share/${PN}/${PN} /usr/bin/dx
}
