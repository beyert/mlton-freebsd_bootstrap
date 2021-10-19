--- runtime/gc/int-inf.c.orig	2010-06-11 13:35:14 UTC
+++ runtime/gc/int-inf.c
@@ -6,6 +6,10 @@
  * See the file MLton-LICENSE for details.
  */
 
+#ifndef __gmp_const
+# define __gmp_const const
+#endif
+
 /*
  * Test if a intInf is a fixnum.
  */
