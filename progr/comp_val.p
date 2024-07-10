{admcab.i}
def var t-ven like plani.platot.
def var t-ecf like plani.platot.
def var varquivo as char.
def var totecf like plani.platot.
def var i as i.
def var vetb1 like estab.etbcod.
def var vetb2 like estab.etbcod.
def var totavi like titulo.titvlcob.
def var totapr like titulo.titvlcob.

def var x as i.
def var vdata       like titulo.titdtemi.
def var wpar        as int format ">>9" .
def var vcxacod     like titulo.cxacod.
def var vlvist      like plani.platot.
def var vlpraz      like plani.platot.
def var vtot        like plani.platot.
def var vdtexp      as   date format "99/99/9999".
def var vdtimp      as   date format "99/99/9999". 
def var vdt1        as   date format "99/99/9999".
def var vdt2        as   date format "99/99/9999".
def stream tela.

def temp-table tt-venda
        field etbcod like estab.etbcod
        field data   like plani.pladat
        field valor  like plani.platot
        field ecf    like plani.platot
            index ind1 etbcod
                       data.

repeat:
    for each tt-venda:
        delete tt-venda.
    end.
    update vetb1 colon 20 
           vetb2 with frame f1 side-label width 80.
    x = 0.
    totavi = 0.
    totapr = 0.

    update vdt1 label "Data Inicial" colon 20
           vdt2 label "Data Final" colon 20 with frame f1.

    t-ven = 0.
    t-ecf = 0.
    do vdata = vdt1 to vdt2:

            vlpraz = 0.
            vlvist = 0. 
            totecf = 0.
        for each estab where estab.etbcod >= vetb1 and
                             estab.etbcod <= vetb2 no-lock:

            for each plani use-index pladat where plani.movtdc = 5 
                                             and  plani.etbcod = estab.etbcod
                                             and  plani.pladat = vdata no-lock.
                vlpraz = 0.
                vlvist = 0.
                if plani.crecod = 1
                then  vlvist = vlvist + if plani.outras > 0
                                        then plani.outras
                                        else plani.platot.
                if plani.crecod = 2
                then  vlpraz = vlpraz + if plani.outras > 0
                                        then plani.outras
                                        else plani.platot.
            
                find tt-venda where tt-venda.etbcod = plani.etbcod and
                                    tt-venda.data   = plani.pladat no-error.
                if not avail tt-venda
                then do:
                    create tt-venda.
                    assign tt-venda.etbcod = plani.etbcod
                           tt-venda.data   = plani.pladat.
                end.
                tt-venda.valor = tt-venda.valor + (vlpraz + vlvist).
            end.
            for each serial where serial.etbcod = estab.etbcod and
                                  serial.serdat = vdata no-lock.
                find tt-venda where tt-venda.etbcod = serial.etbcod and
                                    tt-venda.data   = serial.serdat no-error.
                if not avail tt-venda
                then do:
                    create tt-venda.
                    assign tt-venda.etbcod = serial.etbcod
                           tt-venda.data   = serial.serdat.
                end.
                tt-venda.ecf = tt-venda.ecf + 
                    (serial.icm12 + serial.icm17 + serial.sersub).
            end.
        end.
    end.
    
    varquivo = "i:\admcom\relat\co".

    {mdadmcab.i
        &Saida     = "value(varquivo)"
        &Page-Size = "64"
        &Cond-Var  = "130"
        &Page-Line = "66"
        &Nom-Rel   = ""comp_val""
        &Nom-Sis   = """SISTEMA DE CONTABILIDADE"""
        &Tit-Rel   = """COMPARATIVO DOS VALORES DAS IMPRESSORAS"""      
        &Width     = "130"}
        
    for each tt-venda use-index ind1 break by tt-venda.etbcod:
        display tt-venda.etbcod
                tt-venda.data
                tt-venda.valor(total by tt-venda.etbcod) column-label "Valor"
                tt-venda.ecf(total by tt-venda.etbcod)  column-label "ECF"
                (tt-venda.valor - tt-venda.ecf) 
                    (total by tt-venda.etbcod) column-label "Diferenca"
                (100 - (tt-venda.ecf / tt-venda.valor) * 100) 
                    (average by tt-venda.etbcod)
                        column-label " Dif % "
                             format "->>>9.99" 
                                with frame f-a down width 200.
    
        t-ven = t-ven + tt-venda.valor.
        t-ecf = t-ecf + tt-venda.ecf.
    end.
    /*
    put (100 - (t-ecf / t-ven) * 100) at 55                          
                             format "->>9.99 %" .
    */

    
    output close.
    
    message "Mostrar na tela? " update sresp.
    if sresp
    then do:
        
        for each tt-venda use-index ind1 break by tt-venda.etbcod:
            display tt-venda.etbcod
                    tt-venda.data
                    tt-venda.valor(total by tt-venda.etbcod) 
                        column-label "Valor"                 
                    tt-venda.ecf(total by tt-venda.etbcod)  column-label "ECF"
                    (tt-venda.valor - tt-venda.ecf)  (total by tt-venda.etbcod) 
                                        column-label "Diferenca"
                    (100 - (tt-venda.ecf / tt-venda.valor) * 100) 
                    (average by tt-venda.etbcod) column-label " Dif %"
                                 format "->>>9.99" 
                                        with frame f-b down width 80.
    
        t-ven = t-ven + tt-venda.valor.
        t-ecf = t-ecf + tt-venda.ecf.
    end.
    end.
    message "Listar Relatorio? " update sresp.
    if sresp
    then dos silent value("type " + varquivo + "> prn").




end.

