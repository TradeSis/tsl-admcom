{admcab.i}

def var varquivo as char.


def var vbrindes as int.
def var vdata1 as date format "99/99/9999".
def var vdata2 as date format "99/99/9999".
def var vtotal as dec.

repeat:

    update vdata1 label "Data Inicial"
           vdata2 label "Data Final"
           with side-labels width 80.

    varquivo = "/usr/admcom/relat/dev" + string(day(today),"99") 
                                       + string(month(today),"99") 
                                       + string(year(today),"9999").
                                    
    {mdadmcab.i &Saida     = "value(varquivo)"   
                &Page-Size = "64"  
                &Cond-Var  = "100" 
                &Page-Line = "66" 
                &Nom-Rel   = ""RESPLA"" 
                &Nom-Sis   = """SISTEMA ESTOQUE""" 
                &Tit-Rel   = """LISTAGEM DE BRINDES - COMPRAS ACIMA DE 200 REAIS"" 
                           + "" - LOJA "" 
                           + string(estab.etbcod) + "" - "" 
                           + estab.etbnom " 
                &Width     = "100"
                &Form      = "frame f-cabcab"}
                
                                    
    vbrindes = 0.
    for each plani where plani.movtdc = 5
                     and plani.etbcod = setbcod
                     and plani.pladat >= vdata1
                     and plani.pladat <= vdata2 no-lock:

        find clien where clien.clicod = plani.desti no-lock no-error.
        if not avail clien
        then next.
    
        vtotal = 0.
        vtotal = if plani.biss > 0
                 then plani.biss
                 else plani.platot.
             
        if vtotal < 200
        then next.

        vbrindes = vbrindes + 1.
        
        disp clien.clicod   column-label "Codigo"
             clien.clinom   column-label "Cliente"
             plani.numero   column-label "Numero NF"
             vtotal(total)  column-label "Valor NF"
                with frame f-cli-brindes down centered.

    end.

    disp skip (2) "TOTAL DE BRINDES -->" vbrindes no-label format ">>>>>>>>9"
         with frame f-brin side-labels.

    output close.

    os-command silent /fiscal/lp value(varquivo).


end.