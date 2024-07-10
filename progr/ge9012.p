def input parameter par-arquivo as char.
def input parameter par-dtini   as date.
def input parameter par-dtfim   as date.
def var vdg as char.

{/admcom/progr/cntgendf.i}
find first tbcntgen where tbcntgen.tipcon = 9012 no-lock no-error.
if not avail tbcntgen  or 
    (tbcntgen.validade <> ? and
     tbcntgen.validade < today)
then do:
    message "Controle para DG nao cadastrado ou desativado".
    pause 10.
    return.
end.

def var vlimite as dec.
def var assunto as char.
def var vldesc  as dec.
def var venvmail as log init no.
def var tvlcob as dec.
def var tvlpag as dec.
def var tdesno as dec.
def var tdesan as dec.

vdg = "9012".
output to value(par-arquivo) append.

def var vdata as date.
do vdata = par-dtini to par-dtfim.
for each estab where estab.etbcod > 0 no-lock:
    for each asstec where asstec.etbcod = estab.etbcod
                      and asstec.dtsaida = ? no-lock.

        if vdata - asstec.datexp  = 30  
        then.
        else next.                
               
        find produ where produ.procod = asstec.procod no-lock no-error.
        if not avail produ then next.
        put unformatted
            par-dtini  ";"
            vdg ";"
            asstec.oscod    "|"
            asstec.etbcod   "|"
            asstec.datexp   "|"
            asstec.procod
            skip.
    end.
end.
end.
output close.
