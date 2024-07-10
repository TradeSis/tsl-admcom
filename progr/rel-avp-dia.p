{admcab.i}

def var vmen as char format "x(20)" extent 5.
vmen[1] = "AVP 31/12/2010".

def var vindex as int.
disp vmen with frame f-men 1 column no-label.
choose field vmen with frame f-men.
vindex = frame-index.

connect ninja -H db2 -S sdrebninja -N tcp.
if not connected ("ninja")
then return.

if vindex = 1
then run rel-avp-dia-31122010.p.

if connected ("ninja")
then disconnect ninja.
                                                            

