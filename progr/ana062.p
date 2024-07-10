{admcab.i}

def var val_des     as dec.
def var val_acr     as dec.
def var varquivo    as char.
def  var wcompra like plani.platot.
def buffer bcontnf for contnf.
def buffer xplani for plani.
def var vvltotal    like contrato.vltotal.
def var vdtini      like plani.pladat.
def var vok         as log initial yes.
def var vdtfin      like plani.pladat.
def var vtotcom     as dec.
def var vtipo       as char             format "x(11)".
def var vtprcod     like comis.tprcod.
def var vvencod     like func.funcod label "Vendedor".
def var vdomfer     as integer  label "Dom/Fer".
def var vdiatra     as integer  label "Dias Trab.".
def var vdt         as date.
def var vcatcod     as int.


def temp-table wpla field platot       like plani.platot
                  field vencod       like comis.vencod
                  field numero       like plani.numero
                  field serie        like plani.serie
                  field wdata        like plani.pladat
                  field wdev         like plani.vlserv
                  field wrec         as recid.

repeat:

    for each wpla.
        delete wpla.
    end.


    prompt-for estab.etbcod  colon 20 with frame f-1 side-label width 80.
    find estab using estab.etbcod.

    update vdtini colon 20
           vdtfin colon 45
           vvencod colon 20 with frame f-1.

    do vdt = vdtini to vdtfin:

        for each plani where plani.etbcod = estab.etbcod and
                             plani.movtdc = 5 and
                             plani.pladat = vdt no-lock:
            if vvencod <> plani.vencod
            then next.
            wcompra = 0.
            
            /*
            if plani.crecod = 1
            then wcompra =  (plani.protot + plani.acfprod -
                            plani.descprod)
                            - plani.vlserv.
            if plani.crecod = 2
            then do:
                find last contnf where contnf.etbcod = plani.etbcod and
                                       contnf.placod = plani.placod
                                        no-lock no-error.
                if avail contnf
                then do:

                    vvltotal = 0.
                    for each bcontnf where bcontnf.etbcod  = contnf.etbcod and
                                           bcontnf.contnum = contnf.contnum
                                                       no-lock:
                        for each xplani where xplani.etbcod = bcontnf.etbcod and
                                              xplani.placod = bcontnf.placod and
                                              xplani.pladat = plani.pladat
                                                no-lock.
                            vvltotal = vvltotal +
                                        (xplani.platot - xplani.vlserv).
                        end.
                    end.

                    find contrato where contrato.contnum = contnf.contnum
                                        no-lock no-error.
                    if not avail contrato
                    then next.

                    wcompra  = plani.platot - plani.vlserv +
                                                ((contrato.vltotal - vvltotal) *
                                                 (plani.platot / vvltotal)).
                end.
                else wcompra = plani.platot - plani.vlserv.
            end.
            */

            val_acr = 0.
            val_des = 0.
                        
            if plani.biss > (plani.platot - plani.vlserv)
            then assign val_acr = plani.biss -
                        (plani.platot - plani.vlserv).
            else val_acr = plani.acfprod.
                                                
            if val_acr < 0 or val_acr = ?
            then val_acr = 0.
            
            assign val_des = val_des + plani.descprod.
                        
            assign
                wcompra = (plani.platot - /* plani.vlserv -*/
                  val_des + val_acr).
                  
            if wcompra = 0
                then next.

        create wpla.
        assign wpla.vencod = plani.vencod
               wpla.numero = plani.numero
               wpla.serie  = plani.serie
               wpla.platot = wcompra
               wpla.wdata  = plani.pladat
               wpla.wdev   = plani.vlserv.

        end.

    end.


sresp = no.
message "Deseja Imprimir o Relatorio ?" update sresp.
if sresp
then do:
    /*
    if opsys = "UNIX"
        then varquivo = "../relat/ana062" + string(time).
        else varquivo = "..\relat\ana062" + string(time).
    */                    

    {mdadmcab.i &Saida     = "printer" /* "value(varquivo)" */
                &Page-Size = "64"
                &Cond-Var  = "120"
                &Page-Line = "66"
                &Nom-Rel   = ""DREB062""
                &Nom-Sis   = """SISTEMA CREDIARIO"""
                &Tit-Rel   = """COMISSAO DOS VENDEDORES PERIODO DE "" +
                                string(vdtini) + "" A "" + string(vdtfin)  +
                                ""  "" + string(estab.etbnom)"
                &Width     = "120"
                &Form      = "frame f-cabcab"}

    for each wpla break by wpla.vencod with frame fpcom.

        find func where func.etbcod = input estab.etbcod and
                        func.funcod = wpla.vencod no-lock no-error.

        display wpla.vencod   column-label "Cod"
                func.funnom  when avail func
                wpla.numero
                wpla.serie
                wpla.platot (total by wpla.vencod)
                wpla.wdata   column-label "Data"
                wpla.wdev   column-label "Devolucao"
                            with frame f-wpla down width 140.
    end.
    output close.

    /*
    if opsys = "UNIX"
    then do:
        run visurel.p (varquivo, "").
    end.
    else do:
        {mrod.i}
    end.
    */                                                            


end.
end.
