--- basis-library/mlton/mlton.sig.orig	2018-02-07 09:59:23 UTC
+++ basis-library/mlton/mlton.sig
@@ -29,7 +29,8 @@ signature MLTON =
 (*      val serialize: 'a -> Word8Vector.vector *)
       val share: 'a -> unit
       val shareAll: unit -> unit
-      val size: 'a -> int
+      val size: 'a -> IntInf.int
+      val sizeAll: unit -> IntInf.int
 
       structure Array: MLTON_ARRAY
       structure BinIO: MLTON_BIN_IO
