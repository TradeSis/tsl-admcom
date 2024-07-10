{admcab.i}

def var vdti as date format "99/99/9999".
def var vdtf as date format "99/99/9999".
def var vdata as date format "99/99/9999".
def var vind-venda as log format "Sim/Nao".
def var vind-devol as log format "Sim/Nao".

update vdti label "Data inicial"
       vdtf label "Data final"
       with frame fdt 1 down side-label width 80.

if vdtf = ? or vdti = ? or vdti > vdtf
then undo.

/***
if vdti < 01/01/2011
then do:
    if vdtf > 12/31/2010
    then vdtf = 12/31/2010.
    disp vdtf with frame fdt.
    pause 0.
end.
***/
 
def var vtipo as char format "x(20)" extent 2
    init["VENDA MERCADORIA","DEVOLUCAO VENDA"].
disp vtipo with frame ftp 1 down no-label centered.
choose field vtipo with frame ftp.

if frame-index = 1
then assign
        vind-venda = yes
        vind-devol = no.
else assign
         vind-devol = yes
         vind-venda = no.

if connected ("mov")
then disconnect mov.
 
if vdti < 01/01/2011
then do:
    
    connect mov -H 10.2.0.29 -S 60003 -N tcp.
    
    run /admcom/progr/ctb/ger-vpc-02.p(vdti, vdtf, vind-venda, vind-devol).
    
    disconnect mov.

end.
 
else do:
    run /admcom/progr/ctb/ger-vpc-01.p
                        (vdti, vdtf, vind-venda, vind-devol).
    
end.   
