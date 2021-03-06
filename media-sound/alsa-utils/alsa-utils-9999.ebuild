# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=3
inherit autotools base eutils libtool systemd git-2 python

MY_P=${P/_rc/rc}
ALSA_DRIVER_VER="1.0.24"

DESCRIPTION="Advanced Linux Sound Architecture Utils (alsactl, alsamixer, etc.)"
HOMEPAGE="http://www.alsa-project.org/"

LICENSE="GPL-2"
SLOT="0.9"
KEYWORDS=""
IUSE="doc nls minimal"
PROPERTIES="interactive"
EGIT_REPO_URI="git://git.alsa-project.org/alsa-utils.git"

DEPEND=">=sys-libs/ncurses-5.1
	dev-util/dialog
	>=media-libs/alsa-lib-1.0.24.1
	doc? ( app-text/xmlto )"
RDEPEND=">=sys-libs/ncurses-5.1
	dev-util/dialog
	>=media-libs/alsa-lib-1.0.24.1
	sys-apps/module-init-tools
	!minimal? ( sys-apps/pciutils )"

S="${WORKDIR}/${MY_P}"
PATCHES=( "${FILESDIR}/alsa-utils-1.0.23-modprobe.d.patch" )

pkg_setup() {
	if [[ -e "${ROOT}etc/modules.d/alsa" ]]; then
		eerror "Obsolete config /etc/modules.d/alsa found."
		die "Move /etc/modules.d/alsa to /etc/modprobe.d/alsa.conf."
	fi

	if [[ -e "${ROOT}etc/modprobe.d/alsa" ]]; then
		eerror "Obsolete config /etc/modprobe.d/alsa found."
		die "Move /etc/modprobe.d/alsa to /etc/modprobe.d/alsa.conf."
	fi
}

src_unpack() {
		git-2_src_unpack
		cd "${S}"
}

src_prepare() {
		elibtoolize
		epunt_cxx
		aclocal -I m4
		gettextize
		rm Makefile.am configure.in;
		mv Makefile.am~ Makefile.am
		mv configure.in~ configure.in
		aclocal -I m4
		autoconf
		autoheader
		automake --add-missing --copy --foreign
}

src_configure() {
	local myconf=""
	use doc || myconf="--disable-xmlto"

	econf ${myconf} \
		$(use_enable nls) \
		"$(systemd_with_unitdir)"
}

src_install() {
	local ALSA_UTILS_DOCS="ChangeLog README TODO
		seq/aconnect/README.aconnect
		seq/aseqnet/README.aseqnet"

	emake DESTDIR="${D}" install || die "emake install failed"

	dodoc ${ALSA_UTILS_DOCS} || die

	newbin "${WORKDIR}/alsa-driver-${ALSA_DRIVER_VER}/utils/alsa-info.sh" \
		alsa-info

	newinitd "${FILESDIR}/alsasound.initd-r4" alsasound
	newconfd "${FILESDIR}/alsasound.confd-r3" alsasound
	insinto /etc/modprobe.d
	newins "${FILESDIR}/alsa-modules.conf-rc" alsa.conf

	keepdir /var/lib/alsa
}

pkg_postinst() {
	echo
	elog "To take advantage of the init script, and automate the process of"
	elog "saving and restoring sound-card mixer levels you should"
	elog "add alsasound to the boot runlevel. You can do this as"
	elog "root like so:"
	elog "	# rc-update add alsasound boot"
	echo
	elog "The script will load ALSA modules, if you choose to use a modular"
	elog "configuration. The Gentoo ALSA developers recommend you to build"
	elog "your audio drivers into the kernel unless the device is hotpluggable"
	elog "or you need to supply specific options (such as model= to HD Audio)."
	echo
	ewarn "Automated unloading of ALSA modules is deprecated and unsupported."
	ewarn "Should you choose to use it, bug reports will not be accepted."
	echo
	if use minimal; then
		ewarn "The minimal use flag disables the dependency on pciutils that"
		ewarn "is needed by alsaconf at runtime."
	fi
}
