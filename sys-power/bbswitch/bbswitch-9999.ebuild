# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="4"

inherit git-2 linux-mod

DESCRIPTION="Toggle discrete NVIDIA Optimus graphics card"
HOMEPAGE="https://github.com/Bumblebee-Project/bbswitch"
EGIT_REPO_URI="https://github.com/TheSiege/bbswitch.git"
EGIT_BRANCH="hack-lenovo"
SRC_URI=""

SLOT="0"
LICENSE="GPL-2"
KEYWORDS=""
IUSE=""

DEPEND="virtual/linux-sources
	sys-kernel/linux-headers"

RDEPEND=""

MODULE_NAMES="bbswitch(acpi)"

pkg_setup() {
	linux-mod_pkg_setup

	BUILD_TARGETS="default"
	BUILD_PARAMS="KVERSION=${KV_FULL}"
}

src_install() {
	insinto /etc/modprobe.d
	newins "${FILESDIR}"/bbswitch.modprobe bbswitch.conf
	dodoc NEWS

	linux-mod_src_install
}
