{admcab.i}

/*connect ninja -H db2 -S sdrebninja -N tcp.
*/
connect ninja -H 10.2.0.29 -S 60002 -N tcp.
connect sensei -H db2 -S ssensei -N tcp.


run bg-clasopercred-con.p.


/*
run con-clasopercred-bg.p.
*/
/*
run con-clasopercred-bc.p.
*/
if connected("ninja") then disconnect "ninja".
if connected("sensei") then disconnect "sensei".
