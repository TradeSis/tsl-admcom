{admcab.i}

connect ninja -H db2 -S sdrebninja -N tcp.
connect sensei -H db2 -S ssensei -N tcp.
connect nissei -H db2 -S 60002 -N tcp.

run ctb/pagreb-v0119.p.

if connected("ninja")
then disconnect "ninja".
if connected("sensei")
then disconnect "sensei".
if connected("nissei")
then disconnect "nissei".





