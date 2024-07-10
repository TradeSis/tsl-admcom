{admcab.i }
def var vnfdevqtd as i.
def var vetbcod   like estab.etbcod.
def var vfuncod   like func.funcod.
def var vmovqtm   like movim.movqtm.
def var vcheque   like titulo.titvlcob.
def var vchepre   like titulo.titvlcob.
def var vcartao   like titulo.titvlcob.
def var vreal     like titulo.titvlcob.
def var vfunc     like titulo.titvlcob.
def var varquivo   as char.

def var v-valor   as dec.
def var val_acr   as dec.
def var val_des   as dec.
def var vtotqtm   like movim.movqtm.
def var vtotven   like movim.movqtm.
def var vtotacf   like plani.acfprod.
def var vtotdes   like plani.descprod.
def var vtotreal   like titulo.titvlcob .
def var vtotcheque like titulo.titvlcob .
def var vtotchepre like titulo.titvlcob .
def var vtotcartao like titulo.titvlcob .
def var vtotfunc   like titulo.titvlcob .

def var vqtdliq   like movim.movqtm.
def var vqtddev   like movim.movqtm.
def var vtotliq   like plani.platot.
def var vtotdev   like plani.platot.

def var vtotgerqtm   like movim.movqtm.
def var vtotgerven   like movim.movqtm.
def var vtotgeracf   like plani.acfprod.
def var vtotgerdes   like plani.descprod.
def var vtotgerreal   like titulo.titvlcob .
def var vtotgercheque like titulo.titvlcob .
def var vtotgerchepre like titulo.titvlcob .
def var vtotgercartao like titulo.titvlcob .
def var vtotgerfunc   like titulo.titvlcob .

def var vdti      as date format "99/99/9999".
def var vdtf      as date format "99/99/9999".

repeat:
    assign
        vtotgerqtm = 0
        vtotgerven = 0
        vtotgeracf = 0
        vtotgerdes = 0
        vtotgerreal = 0
        vtotgercheque = 0
        vtotgerchepre = 0
        vtotgercartao = 0
        vtotgerfunc = 0
        vqtddev = 0
        vtotdev = 0
        vtotliq = 0.

    update vetbcod colon 18 with frame f1 centered side-label
                    color blue/cyan row 4 width 80.
    find estab where estab.etbcod = vetbcod no-lock no-error.
    if not avail estab
    then do:
          message  "Estabelecimento nao cadastrado".
          undo.
    end.
    disp estab.etbnom no-label  with frame f1.

    update vfuncod label "Funcionario" colon 18  with frame f1.
    if vfuncod <> 0
    then do:
        find func where func.etbcod = vetbcod and
                        func.funcod = vfuncod no-lock no-error.
        if not avail func
        then do:
            message "Funcionario nao cadastrado".
            undo.
        end.
        else disp func.funnom no-label with frame f1.
    end.

    update  vdti label "Dt.Inicial"
            vdtf label "Dt.Final"
                 with frame f-dat centered row 10 color blue/cyan side-label
                            title ("Periodo").

    /*
    if opsys = "UNIX"
    then varquivo = "../relat/comven1" + string(time).
    else varquivo = "..\relat\comven1" + string(time).
    */
    
    {mdadmcab.i
        &Saida     = "printer" /* "value(varquivo)" */
        &Page-Size = "64"
        &Cond-Var  = "118"
        &Page-Line = "66"
        &Nom-Rel   = ""VENVEND""
        &Nom-Sis   = """ADMINISTRACAO"""
        &Tit-Rel   = """VENDAS POR FUNCIONARIO - PERIODO DE "" +
                                  string(vdti,""99/99/9999"") + "" A "" +
                                  string(vdtf,""99/99/9999"") "
        &Width     = "120"
        &Form      = "frame f-cabcab"}
    form with frame flin down.

disp space "Loja:" space(2)
estab.etbnom no-label with frame f-est side-label.
put fill ("-",120) format "x(120)".


for each plani where plani.movtdc = 5       and
                     plani.etbcod = vetbcod and
                     plani.pladat >= vdti and
                     plani.pladat <= vdtf and
                     plani.vencod = vfuncod no-lock
                      break by plani.vencod
                            by plani.pladat
                            by plani.numero.

    if first-of(plani.vencod)
    then do:
        find func where func.etbcod = plani.etbcod and
                        func.funcod = plani.vencod no-lock.
        disp func.funcod label "Funcionario"
             func.funnom no-label skip with frame f-func side-label.
    end.
    if plani.movtdc = 5 then do:

        v-valor = 0.
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
            v-valor = (plani.platot - /* plani.vlserv -*/
              val_des + val_acr).
                  
        if v-valor = 0
        then next.

        for each movim where movim.etbcod = plani.etbcod and                                                  movim.placod = plani.placod no-lock.
            vmovqtm = vmovqtm + movim.movqtm.
        end.
        display
          plani.pladat   label "Data"
          plani.numero   label "DOCUMENTO" space(2)
          vmovqtm        label "QUANT." format ">>>>>9" space(2)
          v-valor(total by plani.vencod)
                column-label "VALOR TOTAL" format "->>,>>9.99" space(2)
          plani.vlserv(total by plani.vencod)
                column-label "Devolucao" format ">>,>>9.99" space(2)
          val_acr(total by plani.vencod)  
            column-label "ACRESCIMO" format ">>>9.99" space(2)
          val_des(total by plani.vencod)
                label "DESCONTO" format ">>>9.99" space(2)
                          with frame f2 width 120 down.


    vtotqtm = vtotqtm + vmovqtm.
    vtotven = vtotven + plani.platot.
    vtotacf = vtotacf + plani.acfprod.
    vtotdes = vtotdes + plani.descprod.
    vtotreal = vtotreal + vreal.
    vtotcheque = vtotcheque + vcheque.
    vtotchepre = vtotchepre + vchepre.
    vtotcartao = vtotcartao + vcartao.
    vtotfunc = vtotfunc + vfunc.

   assign vmovqtm = 0
          vreal = 0
          vcheque = 0
          vchepre = 0
          vcartao = 0
          vfunc = 0.
  end.

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
