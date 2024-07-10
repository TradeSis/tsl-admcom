{admcab.i}
def input parameter p-recid as recid.
def var varquivo as char.
def var v-chave as char.
def var p-valor as char.
p-valor = "".

find A01_infnfe where recid(A01_infnfe) = p-recid .

p-valor = "".
run le_tabini.p (0, 0,
         "NFE - TIPO DE ARQUIVO", OUTPUT p-valor) .
                        
if p-valor = "TXT"
then do:

    p-valor = "".
    run le_tabini.p (0, 0,
                "NFE - DIRETORIO ENVIO ARQUIVO", OUTPUT p-valor) .

    if A01_infnfe.id <> "" and 
        substr(string(A01_infnfe.id),1,3) <> "NFe"
    then v-chave = A01_infnfe.id.
    else v-chave = substr(string(A01_infnfe.chave),4,34).

    varquivo = p-valor + v-chave + "_cancelar.txt".

    output to value(varquivo).
    put unformatted "CANCELAR|" + v-chave SKIP.
    output close.

end.

if A01_infnfe.situacao = "Autorizada"
then A01_InfNFe.solicitacao = "Cancelamento". 
else A01_InfNFe.solicitacao = "Inutilizacao".

 A01_InfNFe.Aguardando = "Envio".                   

pause.
find first tab_log where tab_log.etbcod = A01_InfNFe.etbcod and
                        tab_log.nome_campo = "NFe-Solicitacao" and
                        tab_log.valor_campo = A01_InfNFe.chave
                        no-error.
if not avail tab_log
then do:
    create tab_log.
    assign
        tab_log.etbcod = A01_InfNFe.etbcod
        tab_log.nome_campo = "NFe-Solicitacao"
        tab_log.valor_campo = A01_InfNFe.chave
        .
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
        tab_log.etbcod = A01_InfNFe.etbcod
        tab_log.nome_campo = "NFe-UltimoEvento"
        tab_log.valor_campo = A01_InfNFe.chave
        .
end.
assign
    tab_log.dtinclu = today
    tab_log.hrinclu = time.


