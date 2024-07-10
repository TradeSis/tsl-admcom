{admcab.i}
/*
connect sensei -H 10.2.0.29 -S 60000 -N tcp.
connect nissei -H 10.2.0.29 -S 60001 -N tcp.
connect ninja  -H 10.2.0.29 -S 60002 -N tcp.
*/
connect sensei -H 10.2.0.248 -S 60000 -N tcp.
connect nissei -H 10.2.0.248 -S 60001 -N tcp.
connect ninja  -H 10.2.0.248 -S 60002 -N tcp.

run ctb/cliprog01-v0118.p.

if connected("ninja") then disconnect "ninja".
if connected("sensei") then disconnect "sensei".
if connected("nissei") then disconnect "nissei".


