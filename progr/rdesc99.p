{admcab.i}

def buffer bprodu for produ.            
def var varquivo as char.
def var vetbcod  as int.
def var vdata1   as date format "99/99/9999".
def var vdata2   as date format "99/99/9999".
def var vdata    as date format "99/99/9999".
def var vtotnfqtd  as   int format ">>>>>>>>9".
def var vtotnfval  like plani.platot.
def var vtotbon    like plani.platot.
def var vtotdef    like plani.platot.
def var vtotbondef like plani.platot.
def var vtotdif    like plani.platot.
def var vperc as dec.

def temp-table tt-totais
    field catcod    like produ.catcod
    field totnfqtd  as   int format ">>>>>>>>9"
    field totnfval  like plani.platot
    field totbon    like plani.platot
    field totdef    like plani.platot
    
    index totais is primary unique catcod.

repeat:
    vdata1 = today. vdata2 = today.
    
    do on error undo:
        update vetbcod label "Filial......"
               with frame f-dados side-labels width 80.
        if vetbcod <> 0
        then do:
            find estab where estab.etbcod = vetbcod no-lock no-error.
            if not avail estab
            then do:
                message "Filial nao cadastrada".
                undo.
            end.    
            else disp estab.etbnom no-label with frame f-dados.
        end.
        else disp "Geral" @ estab.etbnom 
                  with frame f-dados.
    end.
    
    do on error undo:
        update skip
               vdata1 label "Data Inicial"
               vdata2 label "Data Final"
               with frame f-dados.
        if vdata2 < vdata1 then undo.    
    end.

    for each tt-totais.
        delete tt-totais.
    end.
        
    if opsys = "UNIX" 
    then varquivo = "../relat/rdesc99." + string(time). 
    else varquivo = "..\relat\rdesc99." + string(time).
    
    {mdad.i &Saida     = "value(varquivo)" 
            &Page-Size = "64"
            &Cond-Var  = "120"
            &Page-Line = "66"
            &Nom-Rel   = ""rdesc99""
            &Nom-Sis   = """SISTEMA ESTOQUE FILIAL """
            &Tit-Rel   = """LISTAGEM DE DESCONTOS DE "" 
                       + string(vdata1,""99/99/9999"") 
                       + "" A "" 
                       + string(vdata2,""99/99/9999"")" 
            &Width     = "120" 
            &Form      = "frame f-cabcab2"} 
            
            
    assign vtotnfqtd  = 0  
           vtotnfval  = 0  
           vtotbon    = 0  
           vtotdef    = 0  
           vtotbondef = 0  
           vtotdif    = 0.
    
    for each estab where estab.etbcod = (if vetbcod <> 0 
                                         then vetbcod 
                                         else estab.etbcod) no-lock:
        do vdata = vdata1 to vdata2:
            for each plani where plani.movtdc = 5 
                             and plani.etbcod = estab.etbcod 
                             and plani.pladat = vdata no-lock 
                             break by plani.pladat 
                                   by plani.numero:
                                   
                if plani.descprod = 0 and
                   plani.vlserv   = 0 
                then next.   
               
                disp /*skip(1) */
                     plani.etbcod   column-label "LJ"   
                     plani.numero   column-label "Numero"  format ">>>>>>>9" 
                     plani.pladat   column-label "Emissao" 
                     plani.platot   column-label "Total NF" 
                     plani.descprod column-label "Desconto!Bonus" 
                     plani.vlserv   column-label "Desconto!Defeito" skip. 
                     
                assign vtotnfqtd  = vtotnfqtd + 1  
                       vtotnfval  = vtotnfval + plani.platot 
                       vtotbon    = vtotbon   + plani.descprod 
                       vtotdef    = vtotdef   + plani.vlserv.

                for each movim where movim.etbcod = plani.etbcod 
                                 and movim.placod = plani.placod 
                                 and movim.movtdc = plani.movtdc 
                                 and movim.movdat = plani.pladat no-lock:
                    
                    find bprodu where
                         bprodu.procod = movim.procod no-lock no-error.

                    vperc = (movim.movqtm * movim.movpc) / plani.platot.
                    if vperc = ?
                    then vperc = 0.
                    find tt-totais where tt-totais.catcod = bprodu.catcod
                                   no-lock no-error.
                    if not avail tt-totais
                    then do.
                        create tt-totais.
                        tt-totais.catcod = bprodu.catcod.
                    end.
                    assign
                       tt-totais.totnfqtd = tt-totais.totnfqtd + 1
                       tt-totais.totnfval = tt-totais.totnfval + 
                                            (vperc * plani.platot)
                       tt-totais.totbon   = tt-totais.totbon   + 
                                            (vperc * plani.descprod)
                       tt-totais.totdef   = tt-totais.totdef   + 
                                            (vperc * plani.vlserv).
                    
                    disp movim.procod at 5 column-label "Codigo" 
                         bprodu.pronom column-label "Produto" when avail bprodu
                         bprodu.catcod column-label "Dep" when avail bprodu
                         movim.movqtm  
                         movim.movpc
                         with width 120.
                end.
            end.
        end.
    end.

    for each tt-totais no-lock.
        vtotbondef = (tt-totais.totbon + tt-totais.totdef).
        vtotdif    = (tt-totais.totnfval - vtotbondef).
        disp
            tt-totais.catcod
            tt-totais.totnfqtd column-label "Total de NF"
            tt-totais.totnfval column-label "Valor de NF"
            tt-totais.totbon   column-label "Desc.Bonus"
            tt-totais.totdef   column-label "Desc.Defeito"
            vtotbondef         column-label "Bonus + Defeito"
            vtotdif            column-label "Dif.Total"
            with frame f-totaiscat width 136 down.
    end.
                
    vtotbondef = (vtotbon + vtotdef).
    vtotdif    = (vtotnfval - vtotbondef).
                
    put skip(1).
                
    disp "TOTAL DE NF            -> " vtotnfqtd  skip  
         "TOTAL VALOR NF         -> " vtotnfval  skip(1)  
         "TOTAL DESCONTO BONUS   -> " vtotbon    skip  
         "TOTAL DESCONTO DEFEITO -> " vtotdef    skip(1)   
         "TOTAL BONUS + DEFEITO  -> " vtotbondef skip(1)             
         "DIFERENCA TOTAL        -> " vtotdif  
         with frame f-totais centered side-labels no-labels 
                             title " * TOTAIS * ".                
                
    output close.

    if opsys = "UNIX" 
    then run visurel.p (input varquivo, input ""). 
    else {mrod.i}.
end.            
