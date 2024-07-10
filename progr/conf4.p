{admcab.i}
def var vdata like plani.pladat.
  
def var totchedia like plani.platot format ">>,>>>,>>9.99".
def var totchedre like plani.platot format ">>,>>>,>>9.99".
def var totcheglo like plani.platot format ">>,>>>,>>9.99".
def var totpag    like plani.platot format ">>,>>>,>>9.99".
def var vetbnom like estab.etbnom.


def var varquivo as char format "x(30)".
def var vdti   as date format "99/99/9999".
def var vdtf   as date format "99/99/9999".
def stream stela.
def var vetbcod like estab.etbcod.

repeat:

      
    assign totchedia = 0
           totchedre = 0
           totcheglo = 0
           totpag    = 0.

    update vetbcod label "Filial" colon 16 with frame f-data.
    if vetbcod = 0
    then do:
        display "TODAS FILIAIS" @ estab.etbnom with frame f-data.
        vetbnom = "TODAS FILIAIS".
    end.
    else do:
        find estab where estab.etbcod = vetbcod no-lock.
        disp estab.etbnom no-label with frame f-data.
        vetbnom = estab.etbnom.
    end.
    update vdti label "Data Inicial" colon 16
           vdtf label "Data Final" 
            with frame f-data centered color blue/cyan side-label width 80.
    
    if opsys = "UNIX"
    then assign varquivo =  "/admcom/relat/conf3.txt".
    else assign varquivo =  "..\relat\conf3.txt".
        
    {mdad.i
         &Saida     = "value(varquivo)"
         &Page-Size = "64"
         &Cond-Var  = "130"
         &Page-Line = "66"
         &Nom-Rel   = ""CONF4.P""
         &Nom-Sis   = """SISTEMA FINANCEIRO"""
         &Tit-Rel   = """CONFIRMACOES  PERIODO "" + 
                          string(vdti,""99/99/9999"") + "" A "" + 
                          string(vdtf,""99/99/9999"") + ""  "" + 
                          string(vetbnom,""x(25)"")"  
         &Width     = "130"
         &Form      = "frame dep1"}

    if vetbcod = 0
    then do:
        for each deposito where deposito.datcon >= vdti and
                                deposito.datcon <= vdtf no-lock
                                            break by deposito.datcon:

            totchedia = totchedia + deposito.chedia.
            totchedre = totchedre + deposito.chedre.
         /* totcheglo = totcheglo + deposito.cheglo. */
            totpag    = totpag    + deposito.deppag.

            if last-of(deposito.datcon)
            then do:
                display deposito.datcon    column-label "Confimacao"
                        totchedia(total)     column-label "Cheq Dia"
                        totchedre(total)     column-label "Cheq Pre"
                        (totchedia + totchedre)(total) column-label "Acumulado"
                            format "->>>,>>>,>>9.99"
                       /* totcheglo(total)     column-label "Cheq Glo" */
                        totpag(total)     column-label "Pgtos"
                            format "->>>,>>>,>>9.99"
                        deposito.depalt   column-label "Alterado"
                            with frame f4 down width 200.
                
                assign totchedia = 0
                       totchedre = 0
                       totcheglo = 0
                       totpag    = 0.
            end.
        end.
    end.
    else do:
        
       for each deposito where deposito.datcon >= vdti and
                               deposito.datcon <= vdtf and
                               deposito.etbcod = vetbcod no-lock
                                            by deposito.datmov:

            display deposito.datcon    column-label "Confimacao"
                    deposito.chedia(total)     column-label "Cheq Dia"
                    deposito.chedre(total)     column-label "Cheq Pre"
                    (deposito.chedia + deposito.chedre)(total) 
                                               column-label "Acumulado" 
                /*  deposito.cheglo(total)     column-label "Cheq Glo" */
                    deposito.deppag(total)     column-label "Pgtos"
                    deposito.depalt            column-label "Alterado"
                                with frame f2 down width 200.
        end.

    end.

    display " N A O    C O N F I M A D O S" 
                            with frame f-top centered width 200.
    
    for each deposito where deposito.datmov >= vdti and
                            deposito.datmov <= vdtf and
                            deposito.depsit = no no-lock by deposito.datmov
                                                         by deposito.etbcod:

        display deposito.etbcod            column-label "Filial"
                deposito.datmov            column-label "Movimentacao"
                deposito.chedia(total)     column-label "Cheq Dia"
                deposito.chedre(total)     column-label "Cheq Pre"
             /* deposito.cheglo(total)     column-label "Cheq Glo"  */
                deposito.deppag(total)     column-label "Pgtos"
                deposito.depalt            column-label "Alterado"
                    with frame f3 down width 200.
    end.

    /*
    display " N A O    I N F O R M A D O S" 
                            with frame f-top2 centered width 200.
    

    do vdata = vdti to vdtf:
      if weekday(vdata) = 1
      then next.

      put "Data: " vdata "  Filiais: " .            
      for each estab where estab.etbcod < 900 and
                           estab.etbcod <> 22 no-lock:
          find deposito where deposito.etbcod = estab.etbcod and
                              deposito.datmov = vdata no-lock no-error.
          
          if {conv_igual.i estab.etbcod}
          then next.
                               
          if not avail deposito
          then put estab.etbcod.
      end.
      put skip.
    end.
    */        
    output close.
    
    if opsys = "UNIX"
    then run visurel.p (input varquivo, input "").
    else do:
        {mrod.i}.
    end.    

end.
