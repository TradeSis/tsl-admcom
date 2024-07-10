def input parameter p-recid         as recid.
def input parameter p-nome-campo    as char.
def input parameter p-tipo-campo    as char.

find first a01_infnfe where recid(a01_infnfe) = p-recid no-lock no-error.

find first tab_log where tab_log.etbcod = A01_InfNFe.etbcod and
                        tab_log.nome_campo = p-nome-campo and
                        tab_log.valor_campo = A01_InfNFe.chave
                        no-error.
if not avail tab_log
then do:
    create tab_log.
    assign
        tab_log.etbcod = A01_InfNFe.etbcod
        tab_log.nome_campo = p-nome-campo
        tab_log.valor_campo = A01_InfNFe.chave
        .
end.

assign
    tab_log.dtinclu = today
    tab_log.hrinclu = time
    tab_log.tipo_campo = p-tipo-campo.



