{admcab.i}
{gerxmlnfe.i}

def input parameter p-recid as recid.

def var varquivo  as char.
def var arq_envio as char.
def var vretorno  as char.
def var vmetodo   as char.

find A01_infnfe where recid(A01_infnfe) = p-recid NO-LOCK.

if sremoto
then do:
    run danfe_nfe_remoto.p (p-recid).
end.
else do.
    run le_tabini.p (A01_infnfe.etbcod, 0,
                     "NFE - DIRETORIO ENVIO ARQUIVO", OUTPUT arq_envio).
    assign vmetodo = "ConsultarPdfNfe".
    assign varquivo = arq_envio + vmetodo + "_" +
                      string(A01_infnfe.numero) + "_" + string(time).

    output to value(varquivo).
    geraXmlNfe(yes,
               "chave_nfe",
               A01_infnfe.id,
               yes). 
    output close.
   
    run chama-ws.p(input A01_infnfe.emite,
                   input A01_InfNFe.numero,
                   input "NotaMax",
                   input vmetodo,
                   input varquivo,
                   output vretorno).
    if not sremoto
    then run visurel.p(vretorno,"").
end.

do on error undo.
    find first tab_log where tab_log.etbcod = A01_InfNFe.etbcod and
                             tab_log.nome_campo = "NFe-Solicitacao" and
                             tab_log.valor_campo = A01_InfNFe.chave
                       no-error.
    if not avail tab_log
    then do:
        create tab_log.
        assign
            tab_log.etbcod      = A01_InfNFe.etbcod
            tab_log.nome_campo  = "NFe-Solicitacao"
            tab_log.valor_campo = A01_InfNFe.chave.
    end.
    assign
        tab_log.dtinclu = today
        tab_log.hrinclu = time.

    find first tab_log where tab_log.etbcod = A01_InfNFe.etbcod and
                             tab_log.nome_campo = "NFe-UltimoEvento" and
                             tab_log.valor_campo = A01_InfNFe.chave
                       no-error.
    if not avail tab_log
    then do:
        create tab_log.
        assign
            tab_log.etbcod      = A01_InfNFe.etbcod
            tab_log.nome_campo  = "NFe-UltimoEvento"
            tab_log.valor_campo = A01_InfNFe.chave.
    end.
    assign
        tab_log.dtinclu = today
        tab_log.hrinclu = time.
end.

