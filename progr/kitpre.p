{admcab.i}

def var vaux as int.
def var varquivo as char.
def stream stela.

def var vprocod like produ.procod.
def var vdtini  like plani.pladat.
def var vdtfin  like plani.pladat.
def var vetbcod like estab.etbcod.

def workfile wf-produ
    field procod like produ.procod
    field numero like plani.numero
    field vencod like plani.vencod
    field etbcod like plani.etbcod
    field qtd    as int
    field pre    as dec.


repeat:
    
    for each wf-produ:
        delete wf-produ.
    end.

    update vetbcod with frame f-produ side-label width 80.
    if vetbcod = 0
    then display "GERAL" @ estab.etbnom no-label with frame f-produ.
    else do:
        find estab where estab.etbcod = vetbcod no-lock.
        disp estab.etbnom no-label with frame f-produ.
    end.
     
    update vdtini label "Periodo" colon 15
           vdtfin no-label with frame f-produ.
          
    
 
    
    vaux = 0.
    
    input from l:\work\kitpre.txt.
    
    
    repeat:
        import vprocod.
        if vaux = vprocod
        then next.
        vaux = vprocod.
        
        for each estab where if vetbcod = 0 
                             then true
                             else estab.etbcod = vetbcod no-lock,
            each movim where movim.etbcod = estab.etbcod and
                             movim.movtdc = 5 and
                             movim.procod = vprocod and
                             movim.movdat >= vdtini and
                             movim.movdat <= vdtfin no-lock:
                             
            find first plani where plani.etbcod = movim.etbcod and
                                   plani.placod = movim.placod and
                                   plani.movtdc = movim.movtdc and
                                   plani.pladat = movim.movdat 
                                            no-lock no-error.
            if not avail plani
            then next.
            find first wf-produ where wf-produ.etbcod = movim.etbcod and
                                      wf-produ.numero = plani.numero and
                                      wf-produ.procod = movim.procod and
                                      wf-produ.vencod = plani.vencod no-error.
            if not avail wf-produ
            then do:
                create wf-produ.
                assign
                    wf-produ.etbcod = estab.etbcod
                    wf-produ.numero = plani.numero
                    wf-produ.procod = movim.procod
                    wf-produ.vencod = plani.vencod.
            end.
            assign wf-produ.qtd = wf-produ.qtd + movim.movqtm
                   wf-produ.pre = wf-produ.pre + movim.movpc.
                   
        end.
    end.
    input close.

    if opsys <> "UNIX"
    then varquivo = "..\relat\con-4" + string(day(today)).
    else varquivo = "/admcom/relat/con-4" + string(day(today)).
    
    {mdad.i
        &Saida     = "value(varquivo)"
        &Page-Size = "64"
        &Cond-Var  = "130"
        &Page-Line = "66"
        &Nom-Rel   = ""kitpre""
        &Nom-Sis   = """SISTEMA DE VENDA""" 
        &Tit-Rel   = """KIT-PRE"" + "" Fil. ""
                        + string(vetbcod) + "" PERIODO DE: "" +
                        string(vdtini,""99/99/9999"") + 
                      "" ATE "" + string(vdtfin,""99/99/9999"") " 
        &Width     = "130"
        &Form      = "frame f-cabcab"}
        
    output stream stela to terminal.
    for each wf-produ break by wf-produ.etbcod  
                            by wf-produ.vencod 
                            by wf-produ.procod.
                         
        
        if first-of(wf-produ.etbcod)
        then do:
            display wf-produ.etbcod label "Filial" 
                with frame f-etb side-label.
        end.
        
         

        find produ where produ.procod = wf-produ.procod no-lock no-error.
        if not avail produ
        then next. 
        find func where func.etbcod = wf-produ.etbcod and
                        func.funcod = wf-produ.vencod no-lock no-error.
                        
        
        disp wf-produ.vencod column-label "Vend."
             func.funnom  column-label "Nome" format "x(20)" when avail func
             wf-produ.numero column-label "Numero NF"
             wf-produ.procod 
             produ.pronom format "x(30)"
             wf-produ.qtd(total by wf-produ.vencod) column-label "QTD"
             wf-produ.pre(total by wf-produ.vencod) column-label "Valor"
                with frame f2 down width 200. 
     
             
    end.
    output stream stela close.
    output close.
    
    {mrod.i}
    
end.
