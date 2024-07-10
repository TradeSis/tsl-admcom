{admcab.i}     

def var v10 like plani.platot.
def var v15 like plani.platot.
def var v20 like plani.platot.
def var v25 like plani.platot.
def var vmes as char format "x(09)" extent 12.
def var vext1 as char format "x(40)".
def var vext2 as char format "x(40)".
def var vcomis as int.
def buffer bfree for free.
def var totqtd like free.fresal.
def var totpre like free.fresal.
def var x as i.
def var xx as i.
def var xxx as i.
def var vcre as int.
def var vpag as dec.
def var vetbi like plani.etbcod.
def var vetbf like plani.etbcod.
def var vdti like plani.pladat initial today.
def var vdtf like plani.pladat initial today.
def var totfil as int.
def var vcheque as int format ">>>>>>9".
def var varquivo as char.
def var vcont as int.

def temp-table wf-ven
    field etbcod like estab.etbcod
    field procod like movim.procod
    field vencod like plani.vencod
    field numero like plani.numero
    field serie  like plani.serie
    field movqtm like movim.movqtm
    field movpc  like movim.movpc
    field pladat like plani.pladat.
    
def buffer bwf-ven for wf-ven.    
repeat:
    

    for each wf-ven:
        delete wf-ven.
    end.
    
    update vetbi label "Filial"  colon 16
           vetbf label "Filial" with frame f1 side-label width 80.

    update vdti label "Data Inicial" colon 16
           vdtf label "Data Final" with frame f1.

    for each produ where fabcod = 5027 no-lock:
        if produ.procod = 469665
        then next.
        for each estab where estab.etbcod >= vetbi and
                             estab.etbcod <= vetbf no-lock:

            for each movim where movim.etbcod = estab.etbcod and
                                 movim.procod = produ.procod and
                                 movim.movtdc = 5            and
                                 movim.movdat >= vdti        and
                                 movim.movdat <= vdtf no-lock.
                find first plani where plani.etbcod = movim.etbcod and
                                       plani.placod = movim.placod and
                                       plani.movtdc = movim.movtdc 
                                                no-lock no-error.
                if not avail plani
                then next.
                find first wf-ven where wf-ven.etbcod = movim.etbcod and
                                        wf-ven.procod = movim.procod and
                                        wf-ven.numero = plani.numero and
                                        wf-ven.vencod = plani.vencod no-error.
                if not avail wf-ven
                then do:
                    create wf-ven.
                    assign wf-ven.etbcod = plani.etbcod
                           wf-ven.procod = movim.procod
                           wf-ven.vencod = plani.vencod
                           wf-ven.numero = plani.numero
                           wf-ven.serie  = plani.serie
                           wf-ven.pladat = plani.pladat
                           wf-ven.movqtm = movim.movqtm
                           wf-ven.movpc  = movim.movpc.
                end.
                
                display movim.procod 
                        plani.etbcod 
                        plani.pladat
                        plani.vencod with 1 down. pause 0.
            end.
        end.
    end.
    
    
        
    varquivo = "l:\relat\new" +  string(day(vdti)) +
                                 string(month(vdti)).

    {mdad.i
        &Saida     = "value(varquivo)" 
        &Page-Size = "64" 
        &Cond-Var  = "160" 
        &Page-Line = "66" 
        &Nom-Rel   = ""new01"" 
        &Nom-Sis   = """SISTEMA NEWFREE""" 
        &Tit-Rel   = """CONFERENCIA DE VENDAS NEW FREE "" + 
                      "" PERIODO "" + string(vdti,""99/99/9999"") + 
                      "" ATE "" +  string(vdtf,""99/99/9999"")" 
        &Width     = "160" 
        &Form      = "frame f-cabcab"}
    
        
    for each wf-ven break by wf-ven.etbcod
                          by wf-ven.vencod
                          by wf-ven.pladat
                          by wf-ven.procod:
         
        if first-of(wf-ven.etbcod)
        then do:
            find estab where estab.etbcod = wf-ven.etbcod no-lock.
            display estab.etbnom with frame f-estab side-label.
        end.
        if first-of(wf-ven.vencod)
        then do:
        
            find func where func.funcod = wf-ven.vencod and
                            func.etbcod = wf-ven.etbcod no-lock no-error.
            display wf-ven.vencod
                    func.funnom when avail func
                        with frame f-func side-label.
                        
        end.     
        find produ where produ.procod = wf-ven.procod no-lock no-error.
        
        display wf-ven.numero column-label "Nota!Fiscal" format "9999999"
                wf-ven.serie  column-label "Ser"
                wf-ven.procod
                produ.pronom when avail produ
                wf-ven.pladat
                wf-ven.movqtm(total by wf-ven.vencod) column-label "Pecas"
                    with frame f4 down width 200.

            
    end.     
    output close.  
    {mrod.i}
    


    
end.
