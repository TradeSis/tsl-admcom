{admcab.i}

{gerxmlnfe.i}


def var vetbcod        as integer.
def var vnumero        as integer.
def var vserie         as char.

def var chave-nfe      as char.

def var ibge-uf-emite as char.

def var vemitecgc      as char.
def var vplacod        as integer.

form vetbcod    at 03   label "Filial"         skip
     vnumero    at 05   label "Nota"         skip
     vserie     at 04   label "Serie"         skip
        with frame f01 side-label width 70.

assign vserie = "1".

    update vetbcod format ">>>9"
            with frame f01.

    find first estab where estab.etbcod = vetbcod no-lock no-error.
    if not avail estab
    then do:
    
        message "Estabelecimento Invalido!" view-as alert-box.
        undo,retry.
                
    end.                
                
    update vnumero format ">>>>>>9"
            with frame f01.
                
    update vserie format "x(02)"
            with frame f01.

    assign vplacod = integer("55"
                       + string(vnumero,"9999999")).

    find first plani where plani.etbcod = vetbcod
                       and plani.numero = vnumero
                       and plani.serie = vserie no-lock no-error.
                       
    if avail plani
    then do:

        message "Esta nota foi autorizada, efetue o cancelamento dela"
                "através do Painel de Controle da NFE!"
                        view-as alert-box.

        undo, return.
        
    end.

    find estab where estab.etbcod = vetbcod no-lock no-error.

    find first tabaux where tabaux.tabela = "codigo-ibge" and
                            tabaux.nome_campo = estab.ufecod
                                       no-lock no-error.

    assign ibge-uf-emite = tabaux.valor_campo.

    assign vemitecgc = estab.etbcgc
           vemitecgc = replace(vemitecgc,".","")
           vemitecgc = replace(vemitecgc,"/","")
           vemitecgc = replace(vemitecgc,"-","").

find first a01_infnfe where a01_infnfe.etbcod = vetbcod
                        and a01_infnfe.placod = vplacod exclusive-lock no-error.

if avail a01_infnfe and a01_infnfe.serie = "55"
    and not can-find(first a01_infnfe
                     where a01_infnfe.emite = vetbcod
                       and a01_infnfe.numero = vnumero
                       and a01_infnfe.serie = "1")
then assign a01_infnfe.serie = "1".

if not avail a01_infnfe
then find first a01_infnfe where a01_infnfe.emite  = vetbcod
                       and a01_infnfe.numero = vnumero
                       and a01_infnfe.serie = vserie no-lock no-error.

if not avail a01_infnfe
then find first a01_infnfe where a01_infnfe.etbcod  = vetbcod
                       and a01_infnfe.numero = vnumero
                       and a01_infnfe.serie = vserie no-lock no-error.
                         
if not avail a01_infnfe
then do:                        

    message vetbcod  vserie vnumero view-as alert-box.
    pause.

    chave-nfe = "NFe" + ibge-uf-emite + 
                 substr(string(year(today),"9999"),3,2) +
                 string(month(today),"99") +
                 vemitecgc +
                 "55" +
                 string(int(01),"999") +
                 string(vnumero,"999999999").
         
    create A01_infnfe.
    assign A01_infnfe.chave = chave-nfe
           A01_infnfe.emite = vetbcod
           A01_infnfe.serie = vserie
           A01_infnfe.numero = vnumero
           A01_infnfe.etbcod = vetbcod
           A01_infnfe.placod = vplacod
           A01_infnfe.versao = 1.10
           A01_infnfe.id     = "NFe".

end.

find first B01_IdeNFe of A01_infnfe no-lock no-error.

if not avail B01_IdeNFe
then do:
    create B01_IdeNFe.
    assign B01_IdeNFe.chave = A01_infnfe.chave.
end.

find first C01_Emit of A01_infnfe no-lock no-error.
          
if not avail C01_Emit
then do:
    create C01_Emit.
    assign C01_Emit.chave = A01_infnfe.chave
           C01_Emit.cnpj = vemitecgc.
end.    



run p-descarta-nfe(input recid(a01_infnfe)).

procedure p-descarta-nfe.

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
          with frame f-motivo title "Informe o motivo do cancelamento." row 8.


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
                       
run chama-ws3.p(input A01_infnfe.emite,
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
message A01_InfNFe.solicitacao " solicitado, acompanhe o retorno no Cockpit."  ~                       view-as alert-box.               
else do:

    assign p-valor = "".
    run /admcom/progr/le_xml.p(input vretorno,
                               input "mensagem_erro",
                               output p-valor).

    message "Erro ao solicitar " A01_InfNFe.solicitacao ": " skip p-valor
                            view-as alert-box.

end.

/*
message vretorno.
pause.
*/


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


 end procedure.
