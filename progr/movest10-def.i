def {1} shared var vdt like plani.pladat.
def {1} shared var t-sai   like plani.platot.
def {1} shared var t-ent   like plani.platot.
def {1} shared var vetbcod like estab.etbcod.
def {1} shared var vprocod like produ.procod.
def {1} shared var vdata1 like plani.pladat label "Data".
def {1} shared var vdata2 like plani.pladat label "Data".
def {1} shared var sal-ant   like estoq.estatual.
def {1} shared var sal-atu   like estoq.estatual.
def {1} shared var vdisp as log.
    
def {1} shared temp-table tt-movest
    field etbcod like estab.etbcod
    field procod like produ.procod
    field data as date
    field movtdc like tipmov.movtdc
    field tipmov as char
    field numero as char
    field serie like plani.serie
    field emite like plani.emite
    field desti like plani.desti
    field movqtm like movim.movqtm
    field movpc like movim.movpc
    field sal-ant as dec
    field sal-atu as dec
    field cus-ent as dec
    field cus-med as dec
    field qtd-ent as dec
    field qtd-sai as dec 
    .
     
def {1} shared temp-table tt-saldo
    field etbcod like estab.etbcod 
    field procod like produ.procod
    field codfis as int
    field sal-ant as dec
    field qtd-ent as dec
    field qtd-sai as dec
    field sal-atu as dec
    field cto-mes as dec
    field ano-cto as int
    field mes-cto as int
    field cus-ent as dec
    field cus-med as dec
    index i1 ano-cto mes-cto etbcod procod
    .


