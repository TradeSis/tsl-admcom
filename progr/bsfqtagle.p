/*  bsfqtagle.p  */
{admcab.i}

def input        parameter vtitnat          like titulo.titnat.
def input        parameter vclfcod           like clien.clicod.
def input        parameter vtipo            as   char.
def input-output parameter vtotvencido      like titulo.titvlcob.
def input-output parameter vtotvencer       like titulo.titvlcob.
def input-output parameter vtotjuro         like titulo.titvlcob.
def input-output parameter vtotal           like titulo.titvlcob.
def input-output parameter vtotvencjur      like titulo.titvlcob.
def input-output parameter vtotliquidado    like titulo.titvlcob.


def var vjuro        like titulo.titvlcob.
def var vldevido     like titulo.titvlcob.

if vtipo = "ABERTO"
then
for each titulo where titulo.titnat     = vtitnat   and
                      titulo.clifor     = vclfcod   and
                      titulo.titsit     = "LIB"     and 
                      titulo.modcod     = "CRE"     no-lock.
    if titulo.titdtpag = ?
    then do:
        assign vjuro = 0
               vtotal = 0
               vldevido = titulo.titvlcob - titulo.titvlpag.
        
        if titulo.titdtven < today
        then do:
            /*
            run fbjuro.p (
                             input titulo.cobcod,
                             input titulo.carcod,
                             input titulo.titnat,
                             input titulo.titvlcob - titulo.titvlpag,
                             input titulo.titdtven,
                             input today,
                             output vtotal,
                             output vperc) .
            */
            assign
                    vjuro = vtotal - vldevido
                    vtotvencjur = vtotvencjur + vtotal
                    vtotvencido = vtotvencido + vtotal - vjuro
                    vtotjuro = vtotjuro + vjuro.
        end.
        else
            vtotvencer = vtotvencer + vldevido.
    end.
    else
        vtotliquidado = vtotliquidado + titulo.titvlpag.
end.
else
for each titulo where titulo.titnat      = vtitnat and
                      titulo.clifor       = vclfcod
                      no-lock.
    if titulo.titdtpag = ?
    then do:
        assign vjuro = 0
               vtotal = 0
               vldevido = titulo.titvlcob - titulo.titvlpag.
        if titulo.titdtven < today
        then do:
            /*
            run fbjuro.p (
                             input titulo.cobcod,
                             input titulo.carcod,
                             input titulo.titnat,
                             input titulo.titvlcob - titulo.titvlpag,
                             input titulo.titdtven,
                             input today,
                             output vtotal,
                             output vperc) .
            */    
            assign
                    vjuro = vtotal - vldevido
                    vtotvencjur = vtotvencjur + vtotal
                    vtotvencido = vtotvencido + vtotal - vjuro
                    vtotjuro = vtotjuro + vjuro.
        end.
        else
            vtotvencer = vtotvencer + vldevido.
    end.
    else
        vtotliquidado = vtotliquidado + titulo.titvlpag.
end.
