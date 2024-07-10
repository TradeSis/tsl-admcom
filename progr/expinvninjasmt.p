{admcab.i}
connect ninja -H db2 -S sdrebninja -N tcp.
run geraarqinvsmart.p.

if connected("ninja")
then disconnect "ninja".
