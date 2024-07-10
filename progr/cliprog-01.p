{admcab.i}
/*
message color red/with
    "BLOQUEADO PARA MANUTENÇÃO."
    view-as alert-box.
    
do:
return.
end.
  */  

connect ninja -H db2 -S sdrebninja -N tcp.
connect sensei -H db2 -S ssensei -N tcp.

/*
run conecta_d.p.
run cliprog01.p.
*/

run cliprog01-v0118.p.

if connected("ninja")
then disconnect "ninja".
if connected("sensei")
then disconnect "sensei".

/*
run desconecta_d.p.
*/
