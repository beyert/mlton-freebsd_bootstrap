# Created by: Stephen Weeks <sweeks@sweeks.com>

# Previously maintained by Jesper Louis Andersen
# (jesper.louis.andersen@gmail.com) and Geoffrey Mainland
# (mainland@apeiron.net)
#
# Since MLton is written in SML, it needs an SML compiler to build.
# It is easiest to  use another (earlier) binary version of MLton as
# the SML compiler.  So, this Makefile fetches and installs an
# already-built version of MLton, BOOT_DIST, to use for bootstrapping.
PORTNAME=	mlton
PORTVERSION=	20100608
PORTREVISION=	8
CATEGORIES=	lang
MASTER_SITES=	SF http://www.tbrk.org/distfiles/
DISTFILES=	${SRC_DIST} ${BOOT_DIST}
EXTRACT_ONLY=	${SRC_DIST}

MAINTAINER=	beyert@cs.ucr.edu
COMMENT=	Optimizing Standard ML compiler

LICENSE=		MLTON
LICENSE_GROUPS=	COPYFREE OSI
LICENSE_NAME=	MLton BSD-style license
LICENSE_FILE=	${WRKSRC}/doc/license/MLton-LICENSE
LICENSE_PERMS=	${_LICENSE_PERMS_DEFAULT}

ONLY_FOR_ARCHS=	amd64 i386

BUILD_DEPENDS=	bash:shells/bash
LIB_DEPENDS=	libgmp.so:math/gmp
RUN_DEPENDS=	bash:shells/bash

USES=		gmake shebangfix

OPTIONS_DEFINE=	SMLNJ MINGW32 DOCS
SMLNJ_DESC=	Bootstrap with SML/NJ (can take >15 hours)
MINGW32_DESC=	Add the mingw32 target (requires wine)

MAKE_JOBS_UNSAFE=	yes
# build works without GCC at all...
#USE_GCC=	any

PORTNAMEVERSION=	${PKGNAMEPREFIX}${PORTNAME}${PKGNAMESUFFIX}-${PORTVERSION}

.include <bsd.port.options.mk>

.if ${PORT_OPTIONS:MDOCS}
BUILD_DEPENDS+=	gsed:textproc/gsed \
		htmldoc:textproc/htmldoc
USE_TEX=	latex:build
.else
INSTALL_TARGET=	install-no-docs remove-docs
ALL_TARGET=	all-no-docs
.endif

SRC_DIST=	${DISTNAME}.src.tgz

.if ${OSREL:R} > 11
BROKEN+=	only intended for FreeBSD 11
.endif

.if ${PORT_OPTIONS:MSMLNJ}
BROKEN+=	port ${PKGNAME} does not bootstrap properly with SMLNJ
.endif

.if ${PORT_OPTIONS:MSMLNJ}
BUILD_DEPENDS+=	smlnj>=110.65:lang/smlnj
BOOT_DIST=
MAKE_ENV+=	SMLNJ_DEVEL=yes
.if ! ${PORT_OPTIONS:MDOCS}
ALL_TARGET=	smlnj-mlton all-no-docs
.else
ALL_TARGET=	smlnj-mlton all
.endif
.else
BOOT_DIST=	${PORTNAMEVERSION}-1.${ARCH}-${OPSYS:tl}${BOOT_SUFX}
.endif

BOOT_DIST_NEW=	${PORTNAMEVERSION}.${ARCH}-${OPSYS:tl}-${OSREL:R}${BOOT_SUFX_NEW}

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

# MINGW32 requires wine, which doesn't have an official amd64 port
.if ${PORT_OPTIONS:MSMLNJ} || ${PORT_OPTIONS:MMINGW32}
.if ${ARCH} != "i386"
BROKEN+=>...not yet implemented MINGW32 option for ${ARCH}
.endif
.endif

MBUILD_WRKSRC=	${WRKSRC}/build
BOOT_WRKSRC=	${WRKDIR}/mlton-bootstrap
BOOT_WRKTMP=	${WRKDIR}/mlton-bootstrap-new

MAKE_ARGS=	DESTDIR='' \
		PATH=${MBUILD_WRKSRC}/bin:${BOOT_WRKSRC}/bin:${PATH} \
		PREFIX=${PREFIX}

.if ${ARCH} == "i386"
MLTON_ARCH=	"x86"
.elif ${ARCH} == "amd64"
MLTON_ARCH=	"x64"
.endif

#BOOT_EXTRACT=	--bzip2
BOOT_CMD=	--bzip2
BOOT_CMD_NEW=	--xz
BOOT_SUFX=	.tbz
BOOT_SUFX_NEW=	.txz

post-extract:
	@${CP} ${FILESDIR}/add-local-cross ${WRKSRC}/bin/
	@${CHMOD} 755 ${WRKSRC}/bin/add-local-cross
.if ${PORT_OPTIONS:MSMLNJ}
	@${CP} ${FILESDIR}/upgrade-basis.sml ${WRKSRC}/mlton/
	@for f in `ls ${FILESDIR}/ml.* ${FILESDIR}/mlb.*`; do \
		${CP} $$f ${WRKSRC}/mlton/front-end/; \
	done
	@for f in `ls ${FILESDIR}/yacc.*`; do \
		${CP} $$f ${WRKSRC}/mlyacc/src/; \
	done
.else
	@${MKDIR} ${BOOT_WRKSRC}
	@${TAR} xf ${DISTDIR}/${BOOT_DIST} ${BOOT_CMD} -C ${BOOT_WRKSRC}
.endif

post-patch:
	@${REINPLACE_CMD} -e 's/CC := gcc9 -std=gnu99/CC := ${CC} -std=gnu99/' \
		-e 's/ -gstabs+//' \
		${WRKSRC}/runtime/Makefile
	@${REINPLACE_CMD} 's/CC := gcc -std=gnu99/CC := ${CC} -std=gnu99/g' \
		${BOOT_WRKSRC}/lib/mlton/sml/mlnlffi-lib/Makefile
	@${REINPLACE_CMD} 's|GCC := gcc$$|GCC := ${CC}|' \
		${WRKSRC}/runtime/Makefile
	@${REINPLACE_CMD} -e 's/gcc -v/${CC} -v/g' \
		-e 's/ -gstabs+//' \
		${WRKSRC}/runtime/util/Makefile
	@${REINPLACE_CMD} 's/CC = gcc -std=gnu99/CC = ${CC} -std=gnu99/g' \
		${WRKSRC}/runtime/util/Makefile
	@${REINPLACE_CMD} 's|gcc9|${CC}|g' \
		${BOOT_WRKSRC}/lib/mlton/sml/mlrisc-lib/c-call/varargs/interp/Makefile
	@${REINPLACE_CMD} 's|gcc|${CC}|g' \
		${WRKSRC}/doc/examples/ffi/Makefile
.if ${ARCH} == "i386"
#	@${REINPLACE_CMD} 's/ram-slop 0\.7/max-heap 800m/g' ${WRKSRC}/mlton/Makefile
	@${REINPLACE_CMD} 's/ram-slop 0\.7/ram-slop 0.8/g' ${WRKSRC}/mlton/Makefile
#.else
#	@${REINPLACE_CMD} 's/ram-slop 0\.7/max-heap 2g/g' ${WRKSRC}/mlton/Makefile
.endif
.if ! ${PORT_OPTIONS:MSMLNJ}
	@${REINPLACE_CMD} -e \
		"s|/usr/local/lib/mlton|${BOOT_WRKSRC}/lib/mlton|;s|/usr/local|${LOCALBASE}|" \
		${BOOT_WRKSRC}/bin/mlton
	@${REINPLACE_CMD} -e "s|"$$"dir/../lib/mlton|${BOOT_WRKSRC}/lib/mlton|" \
		${BOOT_WRKSRC}/bin/mlton
	@${REINPLACE_CMD} -e "s|"$$"dir/../lib|${BOOT_WRKSRC}/lib/mlton|" \
		${WRKSRC}/bin/mlton-script
.endif
	@${REINPLACE_CMD} -e "s|no-mllex|${BOOT_WRKSRC}/bin/mllex|" \
		${WRKSRC}/mlton/front-end/Makefile \
		${WRKSRC}/mlyacc/Makefile
	@${REINPLACE_CMD} -e "s|no-mlyacc|${BOOT_WRKSRC}/bin/mlyacc|" \
		${WRKSRC}/mlton/front-end/Makefile \
		${WRKSRC}/mlyacc/Makefile
	@${REINPLACE_CMD} -e "s|! mlton |! ${BOOT_WRKSRC}/bin/mlton |" \
		${WRKSRC}/bin/upgrade-basis
	@${REINPLACE_CMD} -e \
		"s|/usr/local|${LOCALBASE}|" \
		${WRKSRC}/runtime/Makefile \
		${WRKSRC}/runtime/bytecode/Makefile \
		${WRKSRC}/runtime/cenv.h \
		${WRKSRC}/bin/add-cross \
		${WRKSRC}/bin/add-local-cross \
		${WRKSRC}/bin/regression \
		${WRKSRC}/bin/mlton-script \
		${WRKSRC}/doc/guide/PortingMLton \
		${WRKSRC}/doc/guide/SelfCompiling \
		${WRKSRC}/doc/guide/Installation \
		${WRKSRC}/regression/parse.sml
	@${REINPLACE_CMD} -e \
		"s|gcc|${CC}|" \
		${WRKSRC}/bin/add-cross \
		${WRKSRC}/bin/regression \
		${WRKSRC}/lib/mlnlffi-lib/Makefile \
		${WRKSRC}/mlnlffigen/gen-cppcmd \
		${WRKSRC}/mlnlffigen/README \
		${BOOT_WRKSRC}/lib/mlton/sml/mlrisc-lib/c-call/test/Makefile \
		${BOOT_WRKSRC}/lib/mlton/sml/mlrisc-lib/c-call/varargs/interp/Makefile
	@${REINPLACE_CMD} -e \
		"s|'gcc'|'${CC}'|" \
		${WRKSRC}/bin/mlton-script \
		${BOOT_WRKSRC}/bin/mlton
.if ! ${PORT_OPTIONS:MSMLNJ}
	@${REINPLACE_CMD} -e "s|/usr/local|${LOCALBASE}|" \
		${BOOT_WRKSRC}/lib/mlton/include/cenv.h
.endif
	@${RM} ${WRKSRC}/doc/guide/PortingMLton.bak \
		${WRKSRC}/doc/guide/SelfCompiling.bak \
		${WRKSRC}/doc/guide/Installation.bak
	@${FIND} ${WRKDIR} | ${GREP} '\.bak$$' | ${AWK} '{ system("${RM} "$$0); }'
	@${FIND} ${WRKDIR} | ${GREP} '\.orig$$' | ${AWK} '{ system("${RM} "$$0); }'

post-build:
	@${REINPLACE_CMD} -i '' -e '1s|/usr/bin/perl|${perl_CMD}|' \
		${MBUILD_WRKSRC}/lib/sml/mlrisc-lib/cm/makecm \
		${MBUILD_WRKSRC}/lib/sml/mlrisc-lib/cm/makeallcm \
		${MBUILD_WRKSRC}/lib/sml/mlrisc-lib/Doc/html/mltex2html
	@${FIND} ${WRKDIR} | ${GREP} '\.bak$$' | ${AWK} '{ system("${RM} "$$0); }'
	@${FIND} ${WRKDIR} | ${GREP} '\.orig$$' | ${AWK} '{ system("${RM} "$$0); }'

makebootstrap:	all
	@${ECHO_MSG} "====> Making new bootstrap image (${BOOT_DIST_NEW})"
#	@${FIND} ${WRKDIR} | ${GREP} '\.bak$$' | ${AWK} '{ system("${RM} "$$0); }'
#	@${FIND} ${WRKDIR} | ${GREP} '\.orig$$' | ${AWK} '{ system("${RM} "$$0); }'
	@${MKDIR} ${BOOT_WRKTMP}
	@cd ${STAGEDIR}${PREFIX} && ${CP} -pR lib bin ${BOOT_WRKTMP}/
	@${MKDIR} ${BOOT_WRKTMP}/doc && cd ${WRKSRC}/doc && \
		${CP} -pR license README changelog ${BOOT_WRKTMP}/doc/
	${TEST} -e ${BOOT_WRKTMP}/LICENSE || \
		(cd ${BOOT_WRKTMP} && ${LN} -s doc/license/MLton-LICENSE LICENSE)
	${TEST} -e ${BOOT_WRKTMP}/README || \
		(cd ${BOOT_WRKTMP} && ${LN} -s doc/README .)
	${TEST} -e ${BOOT_WRKTMP}/changelog || \
	(cd ${BOOT_WRKTMP} && ${LN} -s doc/changelog .)
#.if !exists(${BOOT_WRKTMP}/LICENSE)
#	cd ${BOOT_WRKTMP} && ${LN} -s doc/license/MLton-LICENSE LICENSE
#.endif
#.if !exists(${BOOT_WRKTMP}/README)
#	cd ${BOOT_WRKTMP} && ${LN} -s doc/README .
#.endif
#	@cd ${WRKSRC} && ${CP} -pR LICENSE README ${BOOT_WRKTMP}/
	@cd ${BOOT_WRKTMP} && \
		${TAR} cfp ${BOOT_WRKTMP}/${BOOT_DIST_NEW} ${BOOT_CMD_NEW} \
			lib bin doc LICENSE README changelog
	@${ECHO_MSG} "====> Installing new bootstrap image (${BOOT_DIST_NEW})"
	@${CP} -p ${BOOT_WRKTMP}/${BOOT_DIST_NEW} ${DISTDIR}/
	@${ECHO_MSG} "====> Backing up new bootstrap image (${BOOT_DIST_NEW})"
	@${MV} ${BOOT_WRKTMP}/${BOOT_DIST_NEW} ${MASTERDIR}/
##	@${RMDIR} ${BOOT_WRKTMP}

post-build-MINGW32-on:
	@${ECHO} Adding mingw32 target...
	${WRKSRC}/bin/add-local-cross mingw32 x86 mingw

.include <bsd.port.mk>
