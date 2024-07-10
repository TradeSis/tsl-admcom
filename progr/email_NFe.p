{admcab.i}
def input parameter p-recid as recid.
def var varquivo as char.

def var p-valor as char.
p-valor = "".

def var v-email as char.
find A01_infnfe where recid(A01_infnfe) = p-recid .
find E01_Dest of A01_infnfe no-lock no-error.
find first placon where
           placon.etbcod = A01_infnfe.etbcod and
           placon.emite  = A01_infnfe.emite and
           placon.serie  = A01_infnfe.serie and
           placon.numero = A01_infnfe.numero
            no-lock no-error.
if avail placon
then do:
    find cpforne where cpforne.forcod = placon.desti no-lock no-error.
    if avail cpforne
    then v-email = cpforne.char-2.
    else v-email = E01_Dest.email. 
end.
            
p-valor = "".
run le_tabini.p (0, 0,
            "NFE - DIRETORIO ENVIO ARQUIVO", OUTPUT p-valor) .

def var v-chave as char.
if A01_infnfe.id <> ""
then v-chave = A01_infnfe.id.
else v-chave = substr(string(A01_infnfe.id),4,34).

varquivo = p-valor + v-chave + "_email.txt".

output to value(varquivo).
put unformatted "EMAIL|" + v-chave  + "|" + v-email skip.
output close.

A01_InfNFe.solicitacao = "Re-envio Email". 
A01_InfNFe.Aguardando  = "Envio de Email".                   

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

