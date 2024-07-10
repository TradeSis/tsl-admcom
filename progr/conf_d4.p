{admcab.i}

def var varquivo as char format "x(20)".
def var ventrada like titulo.titvlcob.
def var vtotcomp like titulo.titvlcob.
def var x like plani.platot format ">>>,>>>,>>9.99".
def var y like plani.platot format ">>>,>>>,>>9.99".
def var w like plani.platot format ">>>,>>>,>>9.99".
def var z like plani.platot format ">>>,>>>,>>9.99".
def temp-table wmargem
    field data like plani.pladat
    field valor like plani.platot.

def temp-table w-demo
    field etbcod  like estab.etbcod
    field etbnom  like estab.etbnom
    field wtot    like plani.platot
    field wtotal  like plani.platot
    field wtotacr like plani.platot
    field wtotser like plani.platot
    field wentra  like contrato.vlentra
    field wcompr  like contrato.vltotal.

def buffer bplani for plani.
def buffer bcontnf for contnf.
def var vtot like plani.platot.
def var wacr like plani.platot.
def var vetbcod like estab.etbcod.
def var vdt1 like plani.pladat.
def var vdt2 like plani.pladat.
def var vtotal like plani.platot.
def var vtotal1 like plani.platot.
def var vtotal2 like plani.platot.
def var valortot like plani.platot.
def var vvltotal like plani.platot.
def var vtotacr like plani.platot.
def var vtotser like plani.platot.
def var vvlcont like plani.platot.
def var wper like plani.platot.
def var vvldesc like plani.platot.
def var vvlacre like plani.platot.
repeat:

    for each wmargem:
        delete wmargem.
    end.
    
    for each w-demo:
        delete w-demo.
    end.
    
    vtotcomp = 0.
    ventrada = 0.
    
    update vetbcod
           with frame f1 side-label width 80.
    
    if vetbcod <> 0
    then do:
        find estab where estab.etbcod = vetbcod no-lock.
        display estab.etbnom no-label with frame f1.
    end.
    else display "GERAL" @ estab.etbnom with frame f1.

    update vdt1 label "Periodo"
           vdt2 no-label 
           with frame f1.

    for each estab where ( if vetbcod = 0
                           then true
                           else estab.etbcod = vetbcod ) no-lock.
        for each plani where plani.etbcod = estab.etbcod and
                             plani.movtdc = 5 and
                             plani.pladat >= vdt1 and
                             plani.pladat <= vdt2 
                                    no-lock break by plani.etbcod:

            vvltotal = 0.
            vvlcont = 0.
            vvldesc = 0.
            wacr = 0.
            if plani.crecod > 1
            then do:
                wacr = plani.biss - (plani.platot - 
                                     plani.descprod - 
                                     plani.vlserv +
                                     plani.acfprod).

                if wacr < 0
                then wacr = 0.
            
                assign vvldesc  = vvldesc  + plani.descprod
                       vvlacre  = vvlacre  + wacr.
        
                vtot = vtot + plani.platot.
                vtotal = vtotal + plani.platot - vvldesc - 
                         plani.vlserv + wacr.
                         
                vtotacr = vtotacr + wacr.
                vtotser = vtotser + plani.vlserv.
                
            end.
            else do:
                vtot = vtot + plani.platot.
                vtotal = vtotal + plani.platot - plani.vlserv.
                vtotser = vtotser + plani.vlserv.
            end.
            if last-of(plani.etbcod)
            then do:
                find first w-demo where w-demo.etbcod = plani.etbcod no-error.
                if not avail w-demo
                then do:
                    create w-demo.
                    assign w-demo.etbcod  = estab.etbcod
                           w-demo.etbnom  = estab.etbnom
                           w-demo.wtot    = vtot
                           w-demo.wtotal  = vtotal
                           w-demo.wtotacr = vtotacr
                           w-demo.wtotser = vtotser.
                end.
                clear frame f2 no-pause.
                x = 0.
                y = 0.
                w = 0.
                z = 0.
                for each w-demo by w-demo.etbnom:
                    display w-demo.etbnom format "x(20)"
                        wtot   column-label "Total Liq." format ">,>>>,>>9.99"
                        wtotal column-label "Total Venda"
                        wtotacr column-label "Tot.Acre." format ">>>,>>9.99"
                        wtotser column-label "Total Devolucao"
                                    with frame f2 down width 80.
                    x = x + wtot.
                    y = y + wtotal.
                    w = w + wtotacr.
                    z = z + wtotser.
                    down with frame f2.
                    pause 0.
                end.


                create wmargem.
                assign wmargem.data = plani.pladat
                       wmargem.valor = vtotal.
                vtotal = 0.
                vtotacr = 0.
                vvlacre = 0.
                vvldesc = 0.
                valortot = 0.
                wacr = 0.
                wper = 0.
                vvltotal = 0.
                vvlcont  = 0.
                valortot = 0.
                vtot = 0.
                vtotser = 0.
            end.
        end.

        for each contrato where contrato.etbcod = estab.etbcod and
                                contrato.dtinicial >= vdt1 and
                                contrato.dtinicial <= vdt2 no-lock:
                        
           find first w-demo where w-demo.etbcod = contrato.etbcod no-error.
           if not avail w-demo
           then do:

               create w-demo.
               assign w-demo.etbcod  = estab.etbcod
                      w-demo.etbnom  = estab.etbnom.
           end.
           assign w-demo.wentra = w-demo.wentra + contrato.vlentra
                  w-demo.wcompr = w-demo.wcompr + contrato.vltotal
                  ventrada      = ventrada + contrato.vlentra
                  vtotcomp      = vtotcomp + contrato.vltotal.
                  
        end.

    end.

    display x label "Total Liquido"
            y label "Total Venda"
            w label "Total Acre."
            z label "Total Devolucao"
            ventrada label "Total Entrada"
            vtotcomp label "Total Contratos"       
                        with frame f-tot side-label color white/red.

    if opsys = "UNIX"
    then varquivo = "/admcom/encerra/demo" + string(month(vdt1),"99").
    else varquivo = "L:\encerra\demo" + STRING(month(vdt1),"99").

    {mdadmcab.i
        &Saida     = "value(varquivo)"
        &Page-Size = "64"
        &Cond-Var  = "130"
        &Page-Line = "66"
        &Nom-Rel   = ""conf_d4""
        &Nom-Sis   = """SISTEMA DE ESTOQUE"""
        &Tit-Rel   = """DEMONSTRATIVO DE VENDAS POR FILIAL - PERIODO DE "" +
                                  string(vdt1,""99/99/9999"") + "" A "" +
                                  string(vdt2,""99/99/9999"")"
        &Width     = "130"
        &Form      = "frame f-cabcab"}

        for each w-demo:
            display w-demo.etbnom format "x(20)"
                    wtot(total) column-label "Venda(1)" 
                                format ">>>,>>>,>>9.99"
                    wtotal(total) column-label "Total Venda"
                                format ">>>,>>>,>>9.99"
                    wtotacr(total) column-label "Total Acre." 
                                format ">>>,>>>,>>9.99"
                    wtotser(total) column-label "Total Devolucao"
                                format ">>>,>>>,>>9.99"
                    wentra(total) column-label "Total Entrada"
                                format ">>>,>>>,>>9.99"
                    wcompr(total) column-label "Total Contratos"
                                    with frame f4 down width 200.
        end.
        output close.
    
        if opsys = "UNIX"
        then do:
            sresp = no.
            message "Arquivo gerado: " varquivo " Deseja visualizar? "
                    update sresp.
            pause 5.
            
            if sresp
            then run visurel.p(varquivo,"").
            
        end.    
        else do:
            {mrod.i}
        end.    
        
/***
        message "Deseja imprimir relatorio" update sresp.
        if sresp
        then dos silent value("type " + varquivo + " > prn").
***/
end.
