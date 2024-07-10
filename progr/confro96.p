{admcab.i}

def var varquivo as char.
def var vpath as char format "x(30)".
def var vcol as i.
def var vlei            as char format "x(26)".
def var vetb            as i    format ">>9".
def var vcod            as i    format "9999999".
def var vcod2           as i    format "999999".
def var vqtd            as i    format "999999".
def var vnumero         like plani.numero.
def var vetbcod         like estab.etbcod.
def var vmovseq         as i.
def temp-table tt-produ
    field procod like produ.procod
    field qtdcol as int format "->>>>>9" initial 0
    field qtdmov as int format "->>>>>9" initial 0.


repeat:  
    
    for each tt-produ:
        delete tt-produ.
    end.
            
            

    update vetbcod label "Filial" with frame f1 side-label width 80.
                            
    find estab where estab.etbcod = vetbcod no-lock no-error.
    if not avail estab
    then do:
        message "Filial Nao Cadastrada".
        pause.
        undo, retry.
    end.
    display estab.etbnom no-label with frame f1.
    update vnumero label "Nota Fiscal" at 1 with frame f1.
    
    find plani where plani.etbcod = estab.etbcod and
                     plani.emite  = estab.etbcod and
                     plani.movtdc = 06           and
                     plani.serie  = "U"          and
                     plani.numero = vnumero no-lock no-error.
    if not avail plani
    then do:
        message "Nota Fiscal nao Cadastrada".
        pause.
        undo, retry.
    end.        
    update vcol label "Coletor" format "9" at 1
                       with frame f1.
                
    dos silent c:\dlc\bin\quoter

    value("m:\coletor\col" + string(vcol,"9") + "\leitura.txt") > 
                
    value("m:\coletor\col" + string(vcol,"9") + "\le99.txt") .
 
            
    vpath = "m:\coletor\col" + string(vcol,"9") +  "\le99.txt".

    input from value(vpath).  
    repeat:  
        import vlei.  
        if vcol = 1  
        then do:  
            assign vetb = int(substring(string(vlei),1,2)) 
                   vcod = int(substring(string(vlei),5,6)) 
                   vcod2 = int(substring(string(vlei),5,6)) 
                   vqtd = int(substring(string(vlei),18,5)).
        end.  
        else do:  
            assign vetb = int(substring(string(vlei),1,2)) 
                   vcod = int(substring(string(vlei),5,7))  
                   vcod2 = int(substring(string(vlei),5,6))  
                   vqtd = int(substring(string(vlei),18,5)).
        end.  
        if vetb <> estab.etbcod or vcod = 0 or vcod = ? or 
           vcod = 1 or vcod = 2 or vcod = 3 or vcod = 4 or vcod = 5 
        then next. 
        find produ where produ.procod = vcod no-lock no-error.  
        if not avail produ  
        then next. 
    
        find first tt-produ where tt-produ.procod = produ.procod no-error.
        if not avail tt-produ
        then do:
            create tt-produ.
            assign tt-produ.procod = vcod.
            find movim where movim.etbcod = plani.etbcod and
                             movim.placod = plani.placod and
                             movim.procod = produ.procod no-lock no-error.
            if avail movim
            then tt-produ.qtdmov = movim.movqtm.
        end.
        tt-produ.qtdcol = tt-produ.qtdcol + vqtd.
    end.
    input close.

    for each movim where movim.etbcod = plani.etbcod and
                         movim.placod = plani.placod and
                         movim.movtdc = plani.movtdc and
                         movim.movdat = plani.pladat no-lock:
        find first tt-produ where tt-produ.procod = movim.procod no-error.
        if not avail tt-produ
        then do:
            create tt-produ.
            assign tt-produ.procod = movim.procod
                   tt-produ.qtdmov = movim.movqtm.
        end.
    end.     
    
    varquivo = "l:\relat\conf96." + string(plani.numero).
    
 
    {mdad.i &Saida     = "value(varquivo)"
            &Page-Size = "0" 
            &Cond-Var  = "90" 
            &Page-Line = "0" 
            &Nom-Rel   = ""confro96"" 
            &Nom-Sis   = """SISTEMA DE ESTOQUE""" 
            &Tit-Rel   = """CONFRONTO FILIAL: "" + 
                         string(estab.etbcod,"">>9"") +  
                         "" NF: "" +  string(plani.numero,"">>>>99"")"
            &Width      = "90" 
            &Form       = "frame f-cabcab"}

    for each tt-produ by tt-produ.procod:

        if tt-produ.qtdcol = tt-produ.qtdmov
        then next.
        
        find produ where produ.procod = tt-produ.procod no-lock.
                    
        display produ.procod 
                produ.pronom 
                tt-produ.qtdcol(total) column-label "Qtd!Coletor"
                tt-produ.qtdmov(total) column-label "Qtd!Nota Fiscal"
                                with frame f-conf down width 130.
    end. 
    output close.       
    
    if opsys = "UNIX" 
    then run visurel.p (input varquivo, input "").  
    else {mrod.i}. 
 
    
end.        
     