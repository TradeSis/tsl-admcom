/* Projeto Melhorias Mix - Luciano
#1 TP 23815683 20.04.18
#2 TP 24882172 24.05.18
#3 TP 31999779 16.07.19
*/
{admcab.i}

def input parameter p-codmix like tabmix.codmix.
def input parameter p-procod like produ.procod.

def shared var sexclui as log.

def buffer bproduaux for produaux.
def buffer p-tabmix for tabmix.
def buffer e-tabmix for tabmix.

if p-codmix = 99
then return.

/*** #1 Rotina refeita e unificada ***/

find first tabmix where tabmix.tipomix = "M"
                    and tabmix.codmix  = p-codmix
                  no-lock.
for each p-tabmix where p-tabmix.tipomix = "P"
                    and p-tabmix.codmix  = tabmix.codmix
                  no-lock:
    if p-procod > 0 and
       p-tabmix.promix <> p-procod
    then next.
        
    find produ where produ.procod = p-tabmix.promix no-lock no-error.
    if not avail produ
    then next.
    disp "Processando....... " produ.procod produ.pronom
          with frame f-disp1 1 down centered row 10 no-box color messa.
    pause 0.

    find first e-tabmix where e-tabmix.tipomix = "F" and
                              e-tabmix.codmix  = tabmix.codmix and
                              e-tabmix.etbcod  = tabmix.etbcod and
                              e-tabmix.promix  = produ.clacod
                        no-lock no-error.
    if avail e-tabmix  
    then do:
        /***
        if p-tabmix.mostruario
        then run grava (produ.procod, e-tabmix.etbcod, "Sim").
        else run grava (produ.procod, e-tabmix.etbcod, "Nao").
        ***/
        if sexclui = no
        then run grava (produ.procod, e-tabmix.etbcod, "Sim").
        else run grava (produ.procod, e-tabmix.etbcod, "Nao").
    end.
end.

/* #1 Ajuste de produtos excluidos */
/* #2 Ajuste de item excluido */
/* #3 Retirado comentario */
for each bproduaux where bproduaux.nome_campo = "mix"
                     and (if p-procod > 0 
                          then bproduaux.procod = p-procod else true)  
                     and bproduaux.valor_campo = 
                                         string(tabmix.etbcod,"999") + ",Sim"
                     and bproduaux.datexp <> today
                   no-lock.
    run grava (bproduaux.procod, tabmix.etbcod, "Nao").
end.
/* #3 */


procedure grava.

    def input parameter par-procod like produaux.procod.
    def input parameter par-etbcod as int.
    def input parameter par-valor  as char.

    do on error undo:            
        find first produaux where
                          produaux.procod     = par-procod and
                          produaux.nome_campo = "Mix" and
                          produaux.valor_campo begins string(par-etbcod,"999")
                          no-error.
        if not avail produaux
        then do.
            create produaux.
            assign
                produaux.procod     = par-procod
                produaux.nome_campo = "Mix".
        end.
        assign
            produaux.valor_campo = string(par-etbcod,"999") + "," + par-valor
            produaux.datexp      = today
            produaux.exportar    = yes.
    
        find current produaux no-lock.
    end.
end procedure.

