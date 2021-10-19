# Created by: Stephen Weeks <sweeks@sweeks.com>

# Previously maintained by Jesper Louis Andersen
# (jesper.louis.andersen@gmail.com) and Geoffrey Mainland
# (mainland@apeiron.net)
#
# Because MLton is written in SML, it needs an SML compiler to build.
# It is easiest to use another (earlier) binary version of MLton as
# the SML compiler.  So, this Makefile fetches and installs an
# already-built version of MLton, BOOT_DIST, to use for bootstrapping.
PORTNAME=	mlton
#PKGNAMESUFFIX=	-from_11
PORTVERSION=	20210816
DISTVERSIONSUFFIX=	-from_11
CATEGORIES=	lang
MASTER_SITES+=	https://github.com/beyert/mlton-freebsd_bootstrap/raw/c7371c1/:bootstrap
DISTFILES+=	${PORTNAME}-${PORTVERSION}.i386-freebsd-11${BOOT_SUFX}:bootstrap \
		${PORTNAME}-${PORTVERSION}.amd64-freebsd-11${BOOT_SUFX}:bootstrap

MAINTAINER=	beyert@cs.ucr.edu
COMMENT=	Optimizing Standard ML compiler

LICENSE=				HPND
LICENSE_GROUPS=	COPYFREE OSI
LICENSE_NAME=		Historical Permission Notice and Disclaimer
LICENSE_FILE=		${WRKSRC}/LICENSE
LICENSE_PERMS=	${_LICENSE_PERMS_DEFAULT}

ONLY_FOR_ARCHS=	amd64 i386

BUILD_DEPENDS=	bash:shells/bash
LIB_DEPENDS=	libgmp.so:math/gmp
RUN_DEPENDS=	bash:shells/bash

USES=	compiler:c11 gmake

OPTIONS_DEFINE=	DOCS EXAMPLES

OPTIONS_SINGLE=	TARGET BOOTSTRAP
OPTIONS_SINGLE_TARGET=	NATIVE MINGW32
OPTIONS_SINGLE_BOOTSTRAP=	MLTON SMLNJ POLYML WINE

OPTIONS_DEFAULT=	NATIVE MLTON

MLTON_DESC=	Bootstrap with MLton (ideal if supported)
SMLNJ_DESC=	Bootstrap with SML/NJ (can take many hours)
POLYML_DESC=	Bootstrap with PolyML
WINE_DESC=	Bootstrap MINGW32 with wine

NATIVE_DESC=	Use default target for given architecture
MINGW32_DESC=	Add mingw32 Windows target (requires wine)

.include <bsd.port.options.mk>

.if ${OSREL:R} != 11 && ${OSREL:R} != 12
IGNORE_FreeBSD_${OSREL:R}=	port is bootstrapped via FreeBSD 11.X
.endif

.if ${PORT_OPTIONS:MMINGW32}
BROKEN+=	not yet implemented MINGW32 option in modern versions of ${PORTNAME}
.endif

BOOTVERSION=	${PORTVERSION}
BOOT_WRKSRC=	${WRKDIR}/build
BOOT_WRKTMP=	${WRKDIR}/mlton-bootstrap
REMOTE_BOOT_WRKSRC=	${REMOTE_WRKDIR}/build
REMOTE_BOOT_WRKTMP=	${REMOTE_WRKSRC}/${PKGNAME}-1.${MLTON_ARCH}-${OPSYS:tl}

.if ! ${PORT_OPTIONS:MMLTON}
MAKE_ARGS=	DESTDIR='' MLTON_VERSION=${PORTVERSION} \
		PATH=${WRKSRC}/build/bin:${WRKDIR}/bin:${PATH} \
		PREFIX=${PREFIX} \
		WITH_GMP_DIR=${PREFIX}
.else
MAKE_ARGS=	DESTDIR='' MLTON_VERSION=${PORTVERSION} \
		PATH=${WRKSRC}/build/bin:${BOOT_WRKSRC}/bin:${PATH} \
		PREFIX=${PREFIX} \
		SML_LIB=${BOOT_WRKSRC}/lib/sml WITH_GMP_DIR=${PREFIX} \
		PREFIX=${PREFIX} LIB=${BOOT_WRKSRC}/lib \
		TDOC=${STAGEDIR}${DOCSDIR} \
		TEXM=${STAGEDIR}${EXAMPLESDIR} \
		BOOTSTRAP=${BOOT_WRKTMP}
REMOTE_PREFIX=	${PREFIX}
REMOTE_WRKDIR=	${WRKDIR}
REMOTE_WRKSRC=	${WRKSRC}

REMOTE_MAKE_ARGS=	DESTDIR='' MLTON_VERSION=${PORTVERSION} \
	PATH=${REMOTE_WRKSRC}/build/bin:${REMOTE_BOOT_WRKSRC}/bin:${PATH} \
	PREFIX=${REMOTE_PREFIX} \
	SML_LIB=${REMOTE_BOOT_WRKSRC}/lib/sml \
	WITH_GMP_DIR=${REMOTE_PREFIX} \
	PREFIX=${REMOTE_PREFIX} LIB=${REMOTE_BOOT_WRKSRC}/lib \
	TDOC=${STAGEDIR}${DOCSDIR} \
	TEXM=${STAGEDIR}${EXAMPLESDIR}
.endif

.if ${PORT_OPTIONS:MDOCS} && ${OSREL:R} == 11
BUILD_DEPENDS+=	htmldoc:textproc/asciidoc
MAKE_ARGS+=	MLTON_BINARY_RELEASE_WITH_DOCS=true
#USE_TEX=	latex:build
USE_TEX=	latex:formats
#INSTALL_TARGET=	install-docs
INSTALL_TARGET=	install-docs install-bootstrap
#ALL_TARGET=	install-docs remote-bootstrap
ALL_TARGET=	remote-bootstrap
.else
MAKE_ARGS+=	MLTON_BINARY_RELEASE_WITH_DOCS=false
##ALL_TARGET=	all-no-docs
# these both work fine, but we need to install docs and then remove them
# nevermind, just do not allow EXAMPLES without DOCS enabled
#INSTALL_TARGET=	install
INSTALL_TARGET=	install-bootstrap
ALL_TARGET=	remote-bootstrap
.endif

EMPTY=
.if ${PORT_OPTIONS:MMLTON}
.if ${ARCH} == "i386"
.if defined(REMOTE_MACHINE_FREEBSD_12_I386) || ${OSREL:R} == 12
REMOTE_MACHINE_NEW=	${REMOTE_MACHINE_FREEBSD_12_I386}
.else
IGNORE+=	need to set variable \
	REMOTE_MACHINE_FREEBSD_12_I386=[remote-server-hostname] in\
	/${EMPTY}etc/make.conf to connect via ssh to build bootstrap\
	image for FreeBSD 12.X i386...
.endif
.elif ${ARCH} == "amd64"
.if defined(REMOTE_MACHINE_FREEBSD_12_AMD64) || ${OSREL:R} == 12
REMOTE_MACHINE_NEW=	${REMOTE_MACHINE_FREEBSD_12_AMD64}
.else
IGNORE+=	need to set variable \
	REMOTE_MACHINE_FREEBSD_12_AMD64=[remote-server-hostname] in\
	/${EMPTY}etc/make.conf to connect via ssh to build bootstrap\
	image for FreeBSD 12.X amd64...
.endif
.endif
BOOT_OSREL_NEW=	12
.if ${ARCH} == "i386" || ${PORT_OPTIONS:MMINGW32}
MLTON_ARCH=	x86
BOOT_ARCH_NEW=	i386
.else
MLTON_ARCH=	${ARCH}
BOOT_ARCH_NEW=	amd64
.endif
MAKE_ARGS+=	REMOTE_MACHINE=${REMOTE_MACHINE_NEW} REMOTE_TARGET=self \
	REMOTE_TMP=${REMOTE_WRKSRC} \
	REMOTE_MAKE="cd ${REMOTE_WRKSRC} && ${GMAKE} \
		REMOTE_MAKEFLAGS=${REMOTE_MAKE_ARGS} ${REMOTE_MAKE_ARGS} \
		MAKE=${GMAKE} '${REMOTE_MAKE_ARGS}'" \
	MAKE="${GMAKE} ${REMOTE_MAKE_ARGS}" \
	REMOTE_TMP=${REMOTE_WRKSRC}
.endif

.if ${PORT_OPTIONS:MSMLNJ}
BUILD_DEPENDS+=	smlnj>=110.65:lang/smlnj
BOOT_DIST=
MAKE_JOBS_UNSAFE=	yes
MAKE_ENV+=	SMLNJ_DEVEL=yes
.if ! ${PORT_OPTIONS:MDOCS}
ALL_TARGET=	smlnj-mlton all-no-docs
.else
ALL_TARGET=	smlnj-mlton all
.endif
.elif ${PORT_OPTIONS:MPOLYML}
BUILD_DEPENDS+=	polyc:lang/polyml
BOOT_DIST=
MAKE_JOBS_UNSAFE=	yes
#CPPFLAGS+=	-L/usr/local/lib -lpolyml -lpolymain
#LDFLAGS+=	-L/usr/local/lib -lpolyml -lpolymain
.if ! ${PORT_OPTIONS:MDOCS}
ALL_TARGET=	polyml-mlton all-no-docs
.else
ALL_TARGET=	polyml-mlton all
.endif
.elif ${PORT_OPTIONS:MNATIVE}
BOOT_DIST=	${PKGNAME}.${ARCH}-${OPSYS:tl}-11.txz
.else
BOOT_DIST=
.endif

BOOT_DIST_NEW=	${PKGNAME}${DISTVERSIONSUFFIX}.${BOOT_ARCH_NEW}-${OPSYS:tl}-${BOOT_OSREL_NEW}${BOOT_SUFX}

.if ${PORT_OPTIONS:MMINGW32} && ${PORT_OPTIONS:MWINE}
BUILD_DEPENDS+=	wine:emulators/wine \
		mingw32-gcc:devel/mingw32-gcc \
		${LOCALBASE}/mingw32/lib/libgmp.a:math/mingw32-libgmp
RUN_DEPENDS+=	mingw32-gcc:devel/mingw32-gcc \
		${LOCALBASE}/mingw32/lib/libgmp.a:math/mingw32-libgmp
SSP_CFLAGS?=	-fstack-protector	# XXX -strong isn't supported by GCC < 4.9

PLIST_SUB+=	MINGW32CROSS=""
.else
PLIST_SUB+=	MINGW32CROSS="@comment "
.endif

USE_GITHUB=	yes
GH_ACCOUNT=	MLton
GH_PROJECT=	mlton
GH_TAGNAME=	b2fca3d

BOOT_CMD=	--xz
BOOT_SUFX=	.txz

.if ${OSREL:R} == 11
HAS_REMOTE_MAKEFILE!=	ssh -x ${REMOTE_MACHINE_NEW}\
	"${TEST} -f ${.CURDIR}/Makefile && ${ECHO} true || ${ECHO} ${FALSE}"
.endif

.if ${OSREL:R} == 12
BATCH=	yes
NO_INSTALL=	yes
do-build:
	@${PRINTF} "READY: cleaned and patched for remote bootstrap "
	@${ECHO}   "image creaton of ${OPSYS} ${OSREL:R}.X, which will be "
	@${ECHO}   "initiated via ${OPSYS} 11.X"
.endif

post-extract:
	@${MKDIR} ${BOOT_WRKSRC}
.if ! (${PORT_OPTIONS:MSMLNJ} || ${PORT_OPTIONS:MPOLYML})
	@${TAR} xf ${DISTDIR}/${BOOT_DIST} ${BOOT_CMD} -C ${BOOT_WRKSRC}
	@${REINPLACE_CMD} \
		's|/usr/local/lib/mlton|${BOOT_WRKSRC}/lib/mlton|g' \
		${BOOT_WRKSRC}/bin/mlton
	@${REINPLACE_CMD} "s|gcc=\'gcc9\'|CC=\'${CC}\'|g" ${BOOT_WRKSRC}/bin/mlton
	@${REINPLACE_CMD} 's/CC := cc/CC := ${CC}/g' ${WRKSRC}/Makefile.config
	@${REINPLACE_CMD} 's|$$gcc|$$CC|g' ${BOOT_WRKSRC}/bin/mlton
	@${REINPLACE_CMD} 's|gcc|${CC}|g' ${WRKSRC}/doc/examples/ffi/Makefile
.endif
	@${REINPLACE_CMD} \
		's|-lpolymain -lpolyml|-L ${PREFIX}/lib -lpolymain -lpolyml|g' \
		${WRKSRC}/mlton/Makefile
.if ${PORT_OPTIONS:MDOCS}
	@${MKDIR} ${STAGEDIR}${EXAMPLESDIR}
.endif
	@${REINPLACE_CMD} 's|cd $$(REMOTE_ROOT)/runtime/bootstrap|$$(MKDIR) $$(REMOTE_TMP)/runtime/bootstrap \&\& cd $$(REMOTE_TMP)/runtime/bootstrap|g' ${WRKSRC}/Makefile
.if ${ARCH} == "i386"
# it seems as if all of these settings must be exactly as such to work
	@${REINPLACE_CMD} -e 's/ram-slop 0\.7/ram-slop 0.7/' \
		-e 's|COMPILE_XARGS :=|COMPILE_XARGS := -polyvariance false|' \
		${WRKSRC}/mlton/Makefile
#	@${REINPLACE_CMD} 's/ram-slop 0\.7/ram-slop 0.7/' ${WRKSRC}/mlton/Makefile
	@${REINPLACE_CMD} -e 's/ram-slop 0\.7/ram-slop 0.8/' \
		-e 's|^OLD_MLTON_RUNTIME_ARGS :=|OLD_MLTON_RUNTIME_ARGS := ram-slop 0.8|' \
		-e 's|^OLD_MLTON_COMPILE_ARGS :=|OLD_MLTON_COMPILE_ARGS := -polyvariance false|' \
		-e 's|^MLTON_RUNTIME_ARGS :=|MLTON_RUNTIME_ARGS := ram-slop 0.8|' \
		-e 's|^MLTON_COMPILE_ARGS :=|MLTON_COMPILE_ARGS := -polyvariance false|' \
		${WRKSRC}/Makefile.config
.endif
.if ${OSREL:R} == 11
.if ${HAS_REMOTE_MAKEFILE} == "false"
IGNORE+=	port missing on ${REMOTE_MACHINE_NEW};\
	this port must be copied to the remote machine to complete\
	remote-bootstrap
.endif
.endif
	@${REINPLACE_CMD} 's|gcc|${CC}|g' ${WRKSRC}/mlnlffigen/gen-cppcmd
	@${REINPLACE_CMD} 's|"cc"|"${CC}"|g' ${WRKSRC}/bin/mlton-script
	@${FIND} ${WRKDIR} | ${GREP} '\.bak$$' | ${AWK} '{ system("${RM} "$$0); }'

.if ${OSREL:R} == 11
post-patch:
	ssh -x ${REMOTE_MACHINE_NEW} "cd ${.CURDIR} && ${MAKE}"
.endif

pre-install:
.if ${OSREL:R} == 11
.if !exists(${BOOT_WRKTMP})
	@${MKDIR} ${BOOT_WRKTMP}
	@scp -qpr ${REMOTE_MACHINE_NEW}:${REMOTE_BOOT_WRKTMP}/* ${BOOT_WRKTMP}
.endif
.if !exists(${BOOT_WRKSRC})
	@${CP} -pR ${BOOT_WRKTMP} ${BOOT_WRKSRC}
.endif
.endif

post-install:
.if ${OSREL:R} == 11
.if ${PORT_OPTIONS:MDOCS} && ${PORT_OPTIONS:MEXAMPLES}
	${MV} ${STAGEDIR}${DOCSDIR}/examples/* ${STAGEDIR}${EXAMPLESDIR}/
.elif ${PORT_OPTIONS:MDOCS}
	${RM} -r ${STAGEDIR}${DOCSDIR}/examples
	${RMDIR} ${STAGEDIR}${EXAMPLESDIR}
.elif ${PORT_OPTIONS:MEXAMPLES}
#	${MV} ${STAGEDIR}${DOCSDIR}/examples/* ${STAGEDIR}${EXAMPLESDIR}/
#	${RM} -r ${STAGEDIR}${DOCSDIR}
	BROKEN+=	In port ${PORTNAME}, EXAMPLES requires DOCS
.endif
.endif

makebootstrap:	all
	@${ECHO_MSG} "====> Making new bootstrap image (${BOOT_DIST_NEW})"
#	@${FIND} ${WRKDIR} | ${GREP} '\.bak$$' | ${AWK} '{ system("${RM} "$$0); }'
	@${MKDIR} ${BOOT_WRKTMP}
	@cd ${STAGEDIR}${PREFIX} && ${CP} -pR lib bin ${BOOT_WRKTMP}/
	@${MKDIR} ${BOOT_WRKTMP}/doc && cd ${WRKSRC}/doc && \
		${CP} -pR license README.adoc CHANGELOG.adoc ${BOOT_WRKTMP}/doc/
	@cd ${WRKSRC} && ${CP} -pR LICENSE README.adoc CHANGELOG.adoc \
		${BOOT_WRKTMP}/
	@cd ${BOOT_WRKTMP} && \
		${TAR} cfp ${BOOT_WRKTMP}/${BOOT_DIST_NEW} ${BOOT_CMD} \
			lib bin doc LICENSE README.adoc CHANGELOG.adoc
	@${ECHO_MSG} "====> Installing new bootstrap image (${BOOT_DIST_NEW})"
	@${CP} -p ${BOOT_WRKTMP}/${BOOT_DIST_NEW} ${DISTDIR}/
	@${ECHO_MSG} "====> Backing up new bootstrap image (${BOOT_DIST_NEW})"
	@${MV} ${BOOT_WRKTMP}/${BOOT_DIST_NEW} ${MASTERDIR}/
##	@${RMDIR} ${BOOT_WRKTMP}

post-build-MINGW32-on:
	@${ECHO} Adding mingw32 target...
	${WRKSRC}/bin/add-local-cross mingw32 x86 mingw

.include <bsd.port.mk>
