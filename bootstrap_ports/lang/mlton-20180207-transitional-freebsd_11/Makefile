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
#PKGNAMESUFFIX=	-transitional
PORTVERSION=	20180207
DISTVERSIONSUFFIX=	-transitional
CATEGORIES=	lang
MASTER_SITES+=	https://github.com/beyert/mlton-freebsd_bootstrap/raw/c7371c1/:bootstrap
DISTFILES+=	${PKGNAME}.i386-${OPSYS:tl}-11.txz:bootstrap \
	${PKGNAME}.amd64-${OPSYS:tl}-11.txz:bootstrap
EXTRACT_ONLY=	${DISTNAME}.tar.gz ${BOOT_DIST}

MAINTAINER=	beyert@cs.ucr.edu
COMMENT=	Optimizing Standard ML compiler

LICENSE=        MLTON
LICENSE_GROUPS= COPYFREE OSI
LICENSE_NAME=   MLton BSD-style license
LICENSE_FILE=   ${WRKSRC}/LICENSE
LICENSE_PERMS=  ${_LICENSE_PERMS_DEFAULT}

ONLY_FOR_ARCHS=	amd64 i386

BUILD_DEPENDS=	bash:shells/bash
LIB_DEPENDS=	libgmp.so:math/gmp
RUN_DEPENDS=	bash:shells/bash

USES=	compiler:c11 gmake

OPTIONS_DEFINE=	SMLNJ POLYML MINGW32 DOCS EXAMPLES

SMLNJ_DESC=	Bootstrap with SML/NJ (can take >15 hours)
POLYML_DESC=	Bootstrap with PolyML (can also take a long time)
MINGW32_DESC=	Add the mingw32 target (requires wine)

.include <bsd.port.options.mk>

.if ${PORT_OPTIONS:MMINGW32}
BROKEN+=	not yet implemented MINGW32 option in modern versions of ${PORTNAME}
.endif

BOOTVERSION=	${PORTVERSION}
BOOT_WRKSRC=	${WRKSRC}/build
BOOT_WRKTMP=	${WRKDIR}/mlton-bootstrap

.if ${PORT_OPTIONS:MSMLNJ} || ${PORT_OPTIONS:MPOLYML}
MAKE_ARGS=	DESTDIR='' MLTON_VERSION=${PORTVERSION} \
		PATH=${WRKDIR}/bin:${BOOT_WRKSRC}/bin:${PATH} \
		PREFIX=${PREFIX} \
		WITH_GMP_DIR=${PREFIX}
.else
MAKE_ARGS=	DESTDIR='' MLTON_VERSION=${PORTVERSION} \
		PATH=${BOOT_WRKSRC}/bin:${PATH} \
		PREFIX=${PREFIX} \
		SML_LIB=${WRKSRC}/build/lib/sml WITH_GMP_DIR=${PREFIX} \
		PREFIX=${PREFIX} LIB=${BOOT_WRKSRC}/lib \
		TDOC=${STAGEDIR}${DOCSDIR} \
		TEXM=${STAGEDIR}${EXAMPLESDIR} \
.endif

.if ${PORT_OPTIONS:MDOCS}
BUILD_DEPENDS+=	htmldoc:textproc/asciidoc
# not sure which build directive is better, but latex-formats is directly used
#USE_TEX=       latex:build
USE_TEX=	latex:formats
INSTALL_TARGET=	install
ALL_TARGET=	all
.else
INSTALL_TARGET=	install-no-strip install-strip
ALL_TARGET=	all
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
#CPPFLAGS+= -L/usr/local/lib -lpolyml -lpolymain
#LDFLAGS+= -L/usr/local/lib -lpolyml -lpolymain
.if ! ${PORT_OPTIONS:MDOCS}
ALL_TARGET=	polyml-mlton all-no-docs
.else
ALL_TARGET=	polyml-mlton all
.endif
.else
BOOT_DIST=	${PKGNAME}.${ARCH}-${OPSYS:tl}-11.txz
.endif

BOOT_DIST_NEW=	${PKGNAME}${DISTVERSIONSUFFIX}.${ARCH}-${OPSYS:tl}-${OSREL:R}${BOOT_SUFX}

.if ${PORT_OPTIONS:MMINGW32}
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
GH_TAGNAME=	dc01cdc

BOOT_CMD=	--xz
BOOT_SUFX=	.txz

post-extract:
	@${MKDIR} ${BOOT_WRKSRC}
.if ! (${PORT_OPTIONS:MSMLNJ} || ${PORT_OPTIONS:MPOLYML})
	@${TAR} xf ${DISTDIR}/${BOOT_DIST} ${BOOT_CMD} -C ${BOOT_WRKSRC}
	@${REINPLACE_CMD} \
		's|/usr/local/lib/mlton|${BOOT_WRKSRC}/lib/mlton|g' \
		${BOOT_WRKSRC}/bin/mlton
	@${REINPLACE_CMD} "s|gcc=\'gcc9\'|CC=\'${CC}\'|g" \
		${BOOT_WRKSRC}/bin/mlton
	@${REINPLACE_CMD} 's|$$gcc|$$CC|g' ${BOOT_WRKSRC}/bin/mlton
.endif
	@${REINPLACE_CMD} 's/CC := gcc/CC := ${CC}/g' ${WRKSRC}/Makefile \
		${WRKSRC}/Makefile.binary \
		${WRKSRC}/runtime/Makefile \
		${WRKSRC}/lib/mlnlffi-lib/Makefile \
		${WRKSRC}/Makefile
#	@${REINPLACE_CMD} 's/CC := gcc9/CC := ${CC}/g' ${WRKSRC}/Makefile \
#	${REINPLACE_CMD} 's| build-constants| $$(SRC)/build-constants|g' \
#		${WRKSRC}/Makefile
#	${REINPLACE_CMD} 's|\.\/build-constants|$$(SRC)/build-constants|g' \
#		${WRKSRC}/Makefile
	@${REINPLACE_CMD} 's/gcc version/gcc9 --version/g' ${WRKSRC}/Makefile \
		${WRKSRC}/runtime/Makefile
	@${REINPLACE_CMD} 's|gcc|${CC}|g' ${WRKSRC}/doc/examples/ffi/Makefile
	@${REINPLACE_CMD} \
		's|-lpolymain -lpolyml|-L${PREFIX}/lib -lpolymain -lpolyml|g' \
		${WRKSRC}/mlton/Makefile
.if ${PORT_OPTIONS:MDOCS}
	@${MKDIR} ${STAGEDIR}${EXAMPLESDIR}
.endif
.if ${ARCH} == "i386"
#	@${REINPLACE_CMD} 's/ram-slop 0\.7/max-heap 3200m/g' ${WRKSRC}/mlton/Makefile
	@${REINPLACE_CMD} 's/ram-slop 0\.7/ram-slop 0.8/g' ${WRKSRC}/mlton/Makefile
#.else
#	@${REINPLACE_CMD} 's/ram-slop 0\.7/max-heap 2g/g' ${WRKSRC}/mlton/Makefile
.endif
	@${REINPLACE_CMD} 's|gcc|${CC}|g' ${WRKSRC}/bin/mlton-script
	@${REINPLACE_CMD} 's|gcc|${CC}|g' ${WRKSRC}/bin/add-cross
	@${REINPLACE_CMD} 's|gcc|${CC}|g' ${WRKSRC}/mlnlffigen/gen-cppcmd
	@${FIND} ${WRKDIR} | ${GREP} '\.bak$$' | ${AWK} '{ system("${RM} "$$0); }'

post-patch:
	@${REINPLACE_CMD} 's|c_compiler|${CC}|g' ${WRKSRC}/lib/mlrisc-lib/Makefile
	@${REINPLACE_CMD} 's|work_source|${WRKSRC}|g' ${WRKSRC}/lib/mlrisc-lib/Makefile
	@${FIND} ${WRKDIR} | ${GREP} '\.bak$$' | ${AWK} '{ system("${RM} "$$0); }'

post-install:
.if ${PORT_OPTIONS:MDOCS} && ${PORT_OPTIONS:MEXAMPLES}
	@${MV} ${STAGEDIR}${DOCSDIR}/examples/* ${STAGEDIR}${EXAMPLESDIR}/
	@${CP} -pR ${WRKSRC}/doc/guide/src/Documentation.attachments/*.pdf \
		${STAGEDIR}${DOCSDIR}/
.elif ${PORT_OPTIONS:MDOCS}
	@${RM} -r ${STAGEDIR}${DOCSDIR}/examples
	@${RMDIR} ${STAGEDIR}${EXAMPLESDIR}
	@${CP} -pR ${WRKSRC}/doc/guide/src/Documentation.attachments/*.pdf \
		${STAGEDIR}${DOCSDIR}/
.elif ${PORT_OPTIONS:MEXAMPLES}
	BROKEN+=	In port ${PORTNAME}, EXAMPLES requires DOCS
.else
	@${RM} -r ${STAGEDIR}${EXAMPLESDIR} ${STAGEDIR}${DOCSDIR}
.endif
	@${FIND} ${WRKDIR} | ${GREP} '\.bak$$' | ${AWK} '{ system("${RM} "$$0); }'

makebootstrap:	${ALL_TARGET}
	@${ECHO_MSG} "====> Making new bootstrap image (${BOOT_DIST_NEW})"
	@${FIND} ${WRKDIR} | ${GREP} '\.core$$' | ${AWK} '{ system("${RM} "$$0); }'
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
