{admcab.i}

{gerxmlnfe.i}

def input parameter p-recid as recid.
def var varquivo      as char.
def var v-chave       as char.
def var p-valor       as char.
def var v-justif-canc as char.
def var vretorno      as char.

def buffer bB01_IdeNFe for B01_IdeNFe.

p-valor = "".

find A01_infnfe where recid(A01_infnfe) = p-recid .

find bB01_IdeNFe of A01_infnfe exclusive-lock.

p-valor = "".
run le_tabini.p (A01_infnfe.emite, 0,
            "NFE - DIRETORIO ENVIO ARQUIVO", OUTPUT p-valor) .

v-chave = A01_infnfe.chave.

varquivo = p-valor + "Descartar_" + v-chave + ".xml".

if A01_infnfe.situacao = "Autorizada"
then A01_InfNFe.solicitacao = "Cancelamento". 
else A01_InfNFe.solicitacao = "Inutilizacao".

A01_InfNFe.Aguardando = "Envio".                   

/* Executa WS para enviar solicitação de descarte ao NotaMax */

update v-justif-canc format "x(70)" no-label
          with frame f01 title "Informe o motivo do cancelamento." row 8.

assign bB01_IdeNFe.TDesti = v-justif-canc. 

output to value(varquivo).

if A01_infnfe.id <> "" and A01_infnfe.id <> "NFe"
then do:
 
    geraXmlNfe(yes,
               "chave_nfe",
               A01_infnfe.id,
               no).
    
    geraXmlNfe(no,
               "justificativa",
               bB01_IdeNFe.TDesti,
               yes).
                       
end.
else do:

    find first C01_Emit of A01_infnfe no-lock no-error.
                       
    geraXmlNfe(yes,
               "cnpj_emitente",
               C01_Emit.cnpj,
               no).

    geraXmlNfe(no,
               "numero_nota",
               string(A01_infnfe.numero),
               no).
          
    geraXmlNfe(no,
               "serie_nota",
               string(A01_infnfe.serie),
               no).

    geraXmlNfe(no,
               "justificativa",
               bB01_IdeNFe.TDesti,
               yes).


end.                       

output close.                       
                       
run chama-ws.p(input A01_infnfe.emite,
               input A01_InfNFe.numero,
               input "NotaMax",
               input "DescartarNfe",
               input varquivo,
               output vretorno).

pause 5 no-message.
        
assign p-valor = "".
run /admcom/progr/le_xml.p(input vretorno,
                           input "status_notamax",
                           output p-valor).
               
if p-valor = "0"
then            
message A01_InfNFe.solicitacao " solicitado, acompanhe o retorno no Cockpit."                         view-as alert-box.               
else do:

    assign p-valor = "".
    run /admcom/progr/le_xml.p(input vretorno,
                               input "mensagem_erro",
                               output p-valor).

    message "Erro ao solicitar " A01_InfNFe.solicitacao ": " skip p-valor
                            view-as alert-box.

end.

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


