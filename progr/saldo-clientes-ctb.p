{admcab.i}

def var vmen as char format "x(20)" extent 5.
vmen[1] = "SALDO 31/12/2010".
vmen[2] = "SALDO 31/12/2011".
vmen[3] = "SALDO 31/12/2012".
vmen[4] = "SALDO 31/12/2013".
vmen[5] = "SALDO 31/12/2014".

def var vdatref as date.

def var vindex as int.
disp vmen with frame f-men 1 column no-label.
choose field vmen with frame f-men.
vindex = frame-index.

if vindex = 1 then vdatref = 12/31/10.
if vindex = 2 then vdatref = 12/31/11.
if vindex = 3 then vdatref = 12/31/12.
if vindex = 4 then vdatref = 12/31/13.
if vindex = 5 then vdatref = 12/31/14.

connect ninja -H db2 -S sdrebninja -N tcp.
if not connected ("ninja")
then return.

run relatorio-saldo-clientes.p(vdatref).

if connected ("ninja")
then disconnect ninja.
 

