{admcab.i}

run conecta_d.p .
connect ninja -H db2 -S sdrebninja -N tcp.

run rel-salclien-ctb.p .

disconnect "d".
disconnect "ninja".

