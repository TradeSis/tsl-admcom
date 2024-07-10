{admcab.i}
def var varquivo as char format "x(20)".
def var vetbcod like estab.etbcod.
def var vcatcod like produ.catcod.
def var vdep    like estoq.estatual.
def var vcol    as int.
def buffer bestoq for estoq.
def stream stela.
def var vcont as int.

repeat:
    vcont = 0.
    
    update vetbcod label "Filial" with frame f1 side-label width 80.
    find estab where estab.etbcod = vetbcod no-lock no-error.
    disp estab.etbnom no-label with frame f1.
    update vcatcod label "Categoria" colon 10 with frame f1.
    find categoria where categoria.catcod = vcatcod no-lock.
    display categoria.catnom no-label with frame f1.

    varquivo = "l:\relat\est" + STRING(day(today)) + 
                string(estab.etbcod,">>9").

    {mdadmcab.i
            &Saida     = "value(varquivo)" 
            &Page-Size = "64"
            &Cond-Var  = "160"
            &Page-Line = "66"
            &Nom-Rel   = ""fil-dep""
            &Nom-Sis   = """SISTEMA DE ESTOQUE"""
            &Tit-Rel   = """SALDO DREBES -  "" + estab.etbnom"
            &Width     = "160"
            &Form      = "frame f-cabcab"}
            
     put "CODIGO  DESCRICAO                                       "
         "EST.DEP       "
        "          CODIGO DESCRICAO                                    "
        "   EST.DEP    " skip
        fill("-",160) format "x(160)" skip.

        
    output stream stela to terminal.
    for each produ where produ.catcod = vcatcod no-lock,
        each estoq where estoq.etbcod = vetbcod      and
                         estoq.procod = produ.procod and
                         estoq.estatual <= 0 no-lock by produ.pronom:
        display stream stela produ.pronom 
            with frame f3 centered side-label. 
        pause 0.
        
        vdep = 0.
        for each bestoq where bestoq.etbcod >= 95 and
                              bestoq.procod = produ.procod no-lock.
            if bestoq.estatual > 0
            then vdep = vdep + bestoq.estatual.
        end.      
        if vdep <= 0
        then next.
        if vcont = 56
        then do:
            page.
            put
                "CODIGO  DESCRICAO                                      "
                " EST.DEP    "
                "             CODIGO DESCRICAO                               "
                "        EST.DEP    " skip
                    fill("-",160) format "x(160)" skip.
            vcont = 0.
        end.

         
        
        
        vcol = vcol + 1.
        if vcol = 1
        then do:
            put
                produ.procod space(2)
                produ.pronom format "x(45)" space(1)
                vdep  space(3).
        end.
        if vcol = 2
        then do:
            put
                produ.procod at 81 space(1)
                produ.pronom format "x(45)" space(1)
                vdep  space(2) skip.
            vcont = vcont + 1.
    
            vcol = 0.
        end.
    end.
    output stream stela close.
    output close.
    message "Deseja Imprimir relatorio" update sresp.
    if sresp
    then dos silent value("type " + varquivo + " > prn").  
end.



            
    
