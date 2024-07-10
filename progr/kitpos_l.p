{admcab.i}

def var vtotger as int format ">>>>>>9".
def var vtotfil as int format ">>>>>>9".
def var varquivo as char.
def stream stela.
def var vprocod like produ.procod.
def var vdtini  like plani.pladat.
def var vdtfin  like plani.pladat.
def var vetbcod like estab.etbcod.
def shared temp-table wf-lista
    field procod like produ.procod
    field numero like plani.numero
    field vencod like plani.vencod
    field etbcod like plani.etbcod
    field qtd    as int
    field pre    as dec.



    varquivo = "..\relat\kitpos" + string(day(today)).
    
    {mdad.i
        &Saida     = "value(varquivo)"
        &Page-Size = "0"
        &Cond-Var  = "130"
        &Page-Line = "66"
        &Nom-Rel   = ""kitpos_l""
        &Nom-Sis   = """SISTEMA DE VENDA""" 
        &Tit-Rel   = """KIT-POS"" + "" Fil. ""
                        + string(vetbcod) + "" PERIODO DE: "" +
                        string(vdtini,""99/99/9999"") + 
                      "" ATE "" + string(vdtfin,""99/99/9999"") " 
        &Width     = "130"
        &Form      = "frame f-cabcab"}
        
    output stream stela to terminal.
    vtotger = 0.
    vtotfil = 0.

    for each estab no-lock:
        find first wf-lista where wf-lista.etbcod = estab.etbcod no-error.
        if not avail wf-lista
        then next.
        display estab.etbcod label "Filial" 
                with frame f-etb side-label.
        vtotfil = 0.

        for each wf-lista where wf-lista.etbcod = estab.etbcod
                                       break by wf-lista.vencod 
                                             by wf-lista.procod.
                         

        find produ where produ.procod = wf-lista.procod no-lock no-error.
        if not avail produ
        then next.
        find func where func.etbcod = wf-lista.etbcod and
                        func.funcod = wf-lista.vencod no-lock no-error.
                        
        
        vtotfil = vtotfil + wf-lista.qtd.
        vtotger = vtotger + wf-lista.qtd.
        
        disp wf-lista.vencod column-label "Vend."
             func.funnom  column-label "Nome" format "x(20)" when avail func
             wf-lista.numero column-label "Numero NF"
             wf-lista.procod 
             produ.pronom format "x(30)"
             wf-lista.qtd(total by wf-lista.vencod) column-label "QTD"
             wf-lista.pre(total by wf-lista.vencod) column-label "Valor"
                with frame f2 down width 200. 
        end.
        
        /* put skip(2) "TOTAL..........." at 55 vtotfil skip(3). */

    end.
    
    put skip(3) "TOTAL GERAL" at 59 vtotger.
    
    output stream stela close.
    output close.
    {mrod.i}
