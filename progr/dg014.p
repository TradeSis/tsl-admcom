{/admcom/progr/cntgendf.i}
find first tbcntgen where tbcntgen.etbcod = 14 no-lock no-error.
if not avail tbcntgen  or 
    (tbcntgen.validade <> ? and
     tbcntgen.validade < today)
then do:
    message "Controle para DG nao cadastrado ou desativado".
    pause 0.
    return.
end.
def var varquivo as char.

def var vlimite as dec.
def var assunto as char.
def var vldesc  as dec.
def var venvmail as log init no.
def var tvlcob as dec.
def var tvlpag as dec.
def var tdesno as dec.
def var tdesan as dec.

varquivo = "/admcom/work/arquivodg014.htm".
output to value(varquivo).
put unformatted
"OS MAIS DE 30 DIAS ABERTA <BR> "
"------------------------------ <BR>"
.
for each estab where estab.etbcod > 0 no-lock:
    for each asstec where asstec.etbcod = estab.etbcod and
                          asstec.dtenvass = ? and
                          asstec.dtretass = ? and
                          asstec.dtenvfil = ?
                           no-lock:
        if today - asstec.datexp  <= 30  
        then next.                
               
        find produ where produ.procod = asstec.procod no-lock no-error.
        if not avail produ then next.
        put unformatted
        "Filial: " asstec.etbcod format ">>9"         " <BR>"
        "Numero: " asstec.oscod                       " <BR>"
        "Data  : " asstec.datexp format "99/99/9999"  " <BR>"
        .
        if asstec.dtentdep <> ?
        then put unformatted
                "Deposito: " asstec.dtentdep format "99/99/9999" " <BR>"
                .
        put "Produto: " asstec.procod                         " <BR>"
            "Descricao: " produ.pronom format "x(20)"         " <BR>"
            "-----------------------------------"             " <BR>"
            .
        venvmail = yes.
    end.
end.
output close.

if venvmail = yes
then do:
    run /admcom/progr/envia_dg.p("14",varquivo).
end.
