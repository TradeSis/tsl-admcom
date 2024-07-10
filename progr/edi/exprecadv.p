/* RECADV.xml */
def var p-saida as char.
def input parameter p-rec as recid.

def var vdiretoriosaida as char init "/EDI_NeogridClient/out/".  /* 01.11.19 */

find plani where recid(plani) = p-rec no-lock.

DEFINE VARIABLE hPDS    AS HANDLE  NO-UNDO.
DEFINE VARIABLE lReturn AS LOGICAL NO-UNDO.

DEFINE TEMP-TABLE CABECALHO NO-UNDO 
    field   CAB as char init "1"  serialize-hidden 
    field   FUNCAO_MENSAGEM as char 
    field   NUMERO_AVISO_RECEBIMENTO    as char 
    field   TIPO_RESPOSTA_CODIFICADA    as char 
    field   DATA_HORA_EMISSAO_AVISO     as char 
    field   DATA_HORA_RECEBIMENTO_MERCADOR  as char 
    field   NUMERO_AVISO_SUBSTITUIDO    as char 
    field   NUMERO_NOTA_FISCAL  as char 
    field   SERIE_NOTA_FISCAL   as char 
    field   SUBSERIE_NOTA_FISCAL    as char 
    field   NUMERO_PEDIDO_COMPRADOR as char 
    field   DATA_HORA_EMISSAO_NOTA_FISCAL   as char 
    field   EAN_LOCAL_COMPRADOR as char 
    field   CNPJ_COMPRADOR  as char 
    field   EAN_LOCAL_FORNECEDOR    as char 
    field   CNPJ_FORNECEDOR as char 
    field   EAN_LOCAL_LOCAL_ENTREGA as char 
    field   CNPJ_LOCAL_ENTREGA  as char 
    field   EAN_LOCAL_TRANSPORTADORA    as char 
    field   CNPJ_TRANSPORTADORA as char 
    field   EAN_LOCAL_EMISSOR_FATURA    as char 
    field   CNPJ_EMISSOR_FATURA as char 
    field   COD_INTERNO_DOC_MERCADOR    as char 
    field   NOME_ARQUIVO    as char 
    field   DATA_CRIACAO_DOCUMENTO_MERCADOR as char.

DEFINE TEMP-TABLE OUTROS NO-UNDO 
    FIELD CAB as char init "1" serialize-hidden.

DEFINE TEMP-TABLE CAMPO_ADICIONAL NO-UNDO 
    FIELD CAB as char init "1" serialize-hidden
    FIELD CAMPO as char
    FIELD VALOR as char.

DEFINE TEMP-TABLE ITENS NO-UNDO 
    FIELD CAB as char serialize-hidden init "1".
    
DEFINE TEMP-TABLE ITEM NO-UNDO 
    field CAB as char serialize-hidden init "1"
    field NUMERO_LINHA_ITEM     as char
    field TIPO_CODIGO_PRODUTO   as char
    field CODIGO_PRODUTO        as char
    field DESCRICAO_PRODUTO     as char
    field REFERENCIA_PRODUTO    as char
    field CODIGO_COMPRADOR      as char
    field CODIGO_FORNECEDOR     as char
    field UNIDADE_CONSUMO_EMBALAGEM as char
    field UNIDADE_MEDIDA        as char
    field QUANTIDADE_PEDIDA     as char
    field QUANTIDADE_INFORMADA_NF   as char
    field QUANTIDADE_DESPACHADA as char
    field QUANTIDADE_RECEBIDA_ACEITA    as char
    field QUANTIDADE_RECUSADA   as char
    field DISCREPANCIA_CODIFICADA   as char
    field NUMERO_PEDIDO_COMPRADOR   as char.
    

DEFINE DATASET RECADV FOR CABECALHO, OUTROS, CAMPO_ADICIONAL ,ITENS, ITEM
  DATA-RELATION CAB FOR CABECALHO, OUTROS
        RELATION-FIELDS(CABECALHO.CAB,OUTROS.CAB) NESTED
  DATA-RELATION CAB1 FOR OUTROS, CAMPO_ADICIONAL
        RELATION-FIELDS(OUTROS.CAB,CAMPO_ADICIONAL.CAB) NESTED
  DATA-RELATION CAB2 FOR ITENS, ITEM
        RELATION-FIELDS(ITENS.CAB,ITEM.CAB) NESTED.
        
        
                              

    hPDS = DATASET RECADV:HANDLE.
     /*
    *lReturn = hPDS:READ-XML ("FILE","/admcom/helio/edi/arq/RECADV.xml", "EMPTY",
                             ?, no). 
    *disp lReturn. 
    */

find estab where estab.etbcod = 900 no-lock.

create cabecalho.
FUNCAO_MENSAGEM = "9".
EAN_LOCAL_COMPRADOR = replace(replace(replace(estab.etbcgc,".",""),"/",""),"-","") .
CNPJ_COMPRADOR = replace(replace(replace(estab.etbcgc,".",""),"/",""),"-","") .


create outros.
create campo_adicional.
NUMERO_AVISO_RECEBIMENTO = "".
SERIE_NOTA_FISCAL        = plani.serie.
NUMERO_NOTA_FISCAL       = string(plani.numero).    
find estab where estab.etbcod = plani.etbcod no-lock.
find forne where forne.forcod = plani.emite no-lock no-error.

find first  plaped where 
        plaped.forcod = plani.emite and  
        plaped.numero  = plani.numero 
        no-lock no-error.
if avail plaped
then do:
    find pedid where pedid.pedtdc = plaped.pedtdc and
                     pedid.etbcod = plaped.pedetb and
                     pedid.pednum = plaped.pednum
                     no-lock no-error.
    if avail pedid
    then do:
        find first  ediagendam where ediagendam.pedtdc = pedid.pedtdc and
                                    ediagendam.etbcod = pedid.etbcod and
                                    ediagendam.pednum = pedid.pednum
            no-lock no-error.                                     
        if avail ediagendam
        then do:
            cabecalho.NUMERO_AVISO_RECEBIMENTO = ediagendam.numero_ticket.
            campo_adicional.campo = "TICKET".
            campo_adicional.valor = ediagendam.numero_ticket.
        end.    
    end.                    
                         
                         
end.        

DATA_HORA_EMISSAO_AVISO  = string( year(plani.dtinclu),"9999") +
                                              string(month(plani.dtinclu),"99") +
                                              string(  day(plani.dtinclu),"99") + 
                           replace(string(plani.horincl,"HH:MM"),":","").                   
CNPJ_FORNECEDOR          = replace(replace(replace(forne.forcgc,".",""),"/",""),"-","").
CNPJ_LOCAL_ENTREGA       = replace(replace(replace(estab.etbcgc,".",""),"/",""),"-","").


create ITENS.
for each movim where movim.etbcod = plani.etbcod and
                     movim.placod = plani.placod
        no-lock.              
    find produ of movim no-lock.
               
    create ITEM.
    NUMERO_LINHA_ITEM = string(movim.movseq).
    CODIGO_PRODUTO    = string(movim.procod).
    DESCRICAO_PRODUTO = produ.pronom.
    QUANTIDADE_PEDIDA       = trim(string(movim.movqtm,">>>>>>>>>>>9.99")).
    QUANTIDADE_INFORMADA_NF = trim(string(movim.movqtm,">>>>>>>>>>>9.99")).
    QUANTIDADE_DESPACHADA   = trim(string(movim.movqtm,">>>>>>>>>>>9.99")).
    QUANTIDADE_RECEBIDA_ACEITA = trim(string(movim.movqtm,">>>>>>>>>>>9.99")).
    QUANTIDADE_RECUSADA = "0.00".
    ITEM.NUMERO_PEDIDO_COMPRADOR = if avail pedid then string(pedid.pednum) else "".
end.


            /*

        FOR EACH cabecalho.
            disp cabecalho with 2 col.
            for each campo_adicional.
                disp campo_adicional.
            end.
        END. 
        for each itens.
        disp itens.
        end.
         for each ITEM.
            disp ITEM.
          end.            
              */
              
    p-saida = vdiretoriosaida + "/recadv" + string(plani.emite) + string(plani.numero) + ".xml".    
    lReturn = hPDS:WRITE-XML ("FILE",p-saida, true).

    hide message no-pause.
    message "Arquivo " p-saida
        view-as alert-box.
    
        
