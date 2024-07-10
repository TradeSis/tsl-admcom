def {1} shared var vdebug as log.

def {1} shared temp-table tt-planobiz
    field crecod as integer
        index idx01 crecod.

def {1} shared temp-table tt-movim like movim
    field movtot    like plani.platot 
    field chpres    like plani.platot
    field bonus     like plani.platot
    field vencod    like func.funcod
    field vendedor  like func.funnom
    field acr-fin   as dec
    field tipmov    as char 
    field crecod    as integer
    field planobiz  as character
    field clicod    as integer
    field serie     as char
    field planumero as integer
      index idx01 etbcod                
      index idx02 etbcod procod
      index idx03 etbcod asc placod asc movtot desc
      index idx04 etbcod movdat
      index idx05 etbcod placod movdat movtdc
      index idx_pk is primary unique etbcod placod procod movdat tipmov.        

def {1} shared temp-table tt-plani like plani
    field chpres like plani.platot
    field bonus  like plani.platot
    field tipmov as char   
    field clicod like plani.desti   
    field qtd-total as int
      index idx01 etbcod
      index idx_pk is primary unique etbcod placod serie.

def {1} shared temp-table wf-plani like plani.
def {1} shared temp-table wf-movim like movim.

