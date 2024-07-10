{admcab.i}
def var vnfdevqtd as i.
def var vetbcod   like estab.etbcod.
def var vfuncod   like func.funcod.
def var vmovqtm   like movim.movqtm.
def var vcheque   like titulo.titvlcob.
def var vchepre   like titulo.titvlcob.
def var vcartao   like titulo.titvlcob.
def var vreal     like titulo.titvlcob.
def var vfunc     like titulo.titvlcob.

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

    {mdadmcab.i
        &Saida     = "printer" /*"value(varqsai)"*/
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


for each plani where (plani.movtdc = 5 or
                      plani.movtdc = 12) and
                     plani.etbcod = vetbcod and
                     plani.pladat >= vdti and
                     plani.pladat <= vdtf and
                     (if vfuncod = 0
                      then true
                      else plani.vencod = vfuncod) no-lock
                      break by plani.vencod
                            by plani.pladat
                            by plani.numero.

    if first-of(plani.vencod)
    then do:
        find func where func.etbcod = plani.etbcod and
                        func.funcod = plani.vencod no-lock.
        disp funcod label "Funcionario"
             funnom no-label skip with frame f-func side-label.
    end.
    if plani.movtdc = 5 then do:
        for each movim where movim.etbcod = plani.etbcod and
                             movim.placod = plani.placod no-lock.
            vmovqtm = vmovqtm + movim.movqtm.
        end.
        display
          plani.numero   label "DOCUMENTO" space(2)
          vmovqtm        label "QUANT." format ">>>>9" space(2)
          plani.platot   column-label "VALOR TOTAL" format "->>,>>9.99" space(2)
          plani.acfprod  column-label "ACRESCIMO" format ">>9.99" space(2)
          plani.descprod label "DESCONTO" format ">>9.99" space(2)
          vreal          label "DINHEIRO" format ">>>,>>9.99" space(2)
          vcheque        label "VALOR CHEQUE" format ">>>,>>9.99" space(2)
          vchepre        label "PRE-DATADO" format ">>>,>>9.99" space(2)
          vcartao        label "CARTAO" format ">>>,>>9.99" space(2)
          vfunc          label "FUNCIONARIO" format ">>>,>>9.99"
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

    if plani.movtdc = 12 then do:
        vnfdevqtd = 0.
        for each movim where movim.etbcod = plani.etbcod and
                             movim.placod = plani.placod no-lock.
            vqtddev = vqtddev + movim.movqtm.
            vnfdevqtd = vnfdevqtd + movim.movqtm.
        end.
        vtotdev = vtotdev + plani.platot.
        vtotqtm = vtotqtm - vnfdevqtd.
        vtotven = vtotven - plani.platot.
        display
          plani.numero   label "DOCUMENTO" space(2)
          vnfdevqtd @ vmovqtm     label "QUANT." format ">>>>9" space(2)
          (plani.platot * -1) @ plani.platot
                          with frame f2 width 120 down.
    end.

  if last-of(plani.vencod)
  then do:
    display
         "TOT.FUNC." space(4)
         vtotqtm format ">>>9" space(3)
         vtotven format ">>>,>>9.99" space(5)
         vtotacf format ">>9.99" space(4)
         vtotdes format ">>9.99" space(2)
         vtotreal format ">>>,>>9.99" space(4)
         vtotcheque format ">>>,>>9.99" space(2)
         vtotchepre format ">>>,>>9.99" space(2)
         vtotcartao format ">>>,>>9.99" space(3)
         vtotfunc format ">>>,>>9.99" skip(1)
                with frame f3 no-label width 120.

    vtotgerqtm = vtotgerqtm + vtotqtm.
    vtotgerven = vtotgerven + vtotven.
    vtotgeracf = vtotgeracf + vtotacf.
    vtotgerdes = vtotgerdes + vtotdes.
    vtotgerreal = vtotgerreal + vtotreal.
    vtotgercheque = vtotgercheque + vtotcheque.
    vtotgerchepre = vtotgerchepre + vtotchepre.
    vtotgercartao = vtotgercartao + vtotcartao.
    vtotgerfunc = vtotgerfunc + vtotfunc.

  assign vtotqtm = 0
         vtotven = 0
         vtotacf = 0
         vtotdes = 0
         vtotreal = 0
         vtotcheque = 0
         vtotchepre = 0
         vtotcartao = 0
         vtotfunc = 0.
  end.
end.

    put skip fill("-",120) format "x(120)".
    display
         "TOT.GERAL" space(4)
         (vtotgerqtm + vqtddev)  format ">>>9" space(3)
         (vtotgerven + vtotdev)  format ">>>,>>9.99" space(5)
         vtotgeracf format ">>9.99" space(4)
         vtotgerdes format ">>9.99" space(2)
         vtotgerreal format ">>>,>>9.99" space(4)
         vtotgercheque format ">>>,>>9.99" space(2)
         vtotgerchepre format ">>>,>>9.99" space(2)
         vtotgercartao format ">>>,>>9.99" space(3)
         vtotgerfunc format ">>>,>>9.99"
                with frame f4 no-label width 120.

    disp "DEVOLUCAO" space(4)
         vqtddev format ">>>9" space(3)
         vtotdev format ">>>,>>9.99" with frame f5 no-label width 120.

    vtotliq = vtotliq + ( vtotgerven  ).
    vtotgerqtm = vtotgerqtm .

    disp "TOT.LIQUIDO" space(2)
         vtotgerqtm format ">>>9" space(3)
         vtotliq format ">>>,>>9.99" with frame f6 no-label width 120.

  put skip(2)
        "CHEQUES A VISTA....: R$_____________________________" skip
        "CHEQUES PRE-DATADOS: R$_____________________________" skip
        "DINHEIRO...........: R$_____________________________" skip
        "CARTOES DE CREDITO.: R$_____________________________" skip
        "DESPESAS...........: R$_____________________________" skip
        "BOL. ALT. CHEQUE...: R$_____________________________" skip
        "COMPRAS DIRECAO....: R$_____________________________" skip
        "___________________: R$_____________________________" skip
        "TOTAL GERAL........: R$_____________________________".
    output close.
end.
