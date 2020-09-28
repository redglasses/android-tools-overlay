# Copyright 2008-2020 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI="7"
JAVA_PKG_IUSE="doc source"

inherit java-pkg-2 java-pkg-simple

MY_PV="${PV/_p/_r}"
MY_P=${PN}-${MY_PV}

DESCRIPTION="aims to simplify APK signing and checking whether APK signatures are expected"
HOMEPAGE="https://android.googlesource.com/platform/tools/apksig/"
SRC_URI="https://android.googlesource.com/platform/tools/apksig/+archive/refs/tags/android-${MY_PV}.tar.gz -> ${P}.tar.gz"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~amd64 ~arm ~arm64 ~ppc64 ~x86 ~amd64-linux ~x86-linux ~x64-macos ~x86-macos"
IUSE=""

BDEPEND=">=virtual/jdk-1.8"
DEPEND=">=virtual/jdk-1.8"
RDEPEND=">=virtual/jre-1.8"

JAVA_SRC_DIR=( "${S}/src/apksigner"
	"${S}/src/main" )
JAVA_RESOURCE_DIRS="${S}/src/apksigner/java"

src_compile() {
	JAVA_MAIN_CLASS="com.android.apksigner.ApkSignerTool" JAVA_JAR_FILENAME="apksigner.jar" java-pkg-simple_src_compile
}

src_install() {
	JAVA_GENTOO_CLASSPATH="junit" JAVA_JAR_FILENAME="apksigner.jar" java-pkg-simple_src_install

	exeinto /usr/share/${PN}/
	doexe etc/apksigner
	dosym /usr/share/${PN}/apksigner /usr/bin/apksigner
}
