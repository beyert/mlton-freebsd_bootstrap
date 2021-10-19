--- basis-library/mlton/mlton.sml.orig	2018-02-07 09:59:23 UTC
+++ basis-library/mlton/mlton.sml
@@ -28,7 +28,9 @@ fun shareAll () =
     ; GC.collect ())
 
 fun size x =
-   C_Size.toInt (Primitive.MLton.size x)
+   C_Size.toLargeInt (Primitive.MLton.size x)
+
+fun sizeAll (): IntInf.int = ~1
 
 (* fun cleanAtExit () = let open Cleaner in clean atExit end *)
 
