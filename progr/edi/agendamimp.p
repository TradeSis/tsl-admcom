/* CONFAGE.xml */

def input param p-arquivo   as char.
def input param p-diretorio as char.

DEFINE VARIABLE hPDS    AS HANDLE  NO-UNDO.
DEFINE VARIABLE lReturn AS LOGICAL NO-UNDO.

DEFINE TEMP-TABLE ttHEADER NO-UNDO serialize-name "HEADER"
    field CD_TENANT as char     format "x(40)"        
    field FUNCAO_MENSAGEM as char 
    field DATA_EMISSAO as char 
    field DATA_CRIACAO_AGENDAMENTO as char 
    field NUMERO_TICKET as char format "x(40)"
    field CGC_FILIAL as char    format "x(40)"
    field CODIGO_ERP_SETOR as char 
    field CODIGO_LOCAL_ENTREGA as char 
    field DATA_AGENDAMENTO as char 

    field cSTATUS as char serialize-name "STATUS" format "x(40)"
    field CGC_TRANSPORTADORA as char 
    field DATA_ENTREGA as char 
    field CODIGO_AGRUPADOR_ENTREGA as char .

DEFINE TEMP-TABLE DOCUMENTOS NO-UNDO 
    FIELD DOCUMENTO as char serialize-hidden.

DEFINE TEMP-TABLE DOCUMENTO NO-UNDO 
    field NUMERO_DOCUMENTO       as char  format "x(40)"
    field CGC_FORNECEDOR as char          format "x(40)" 
    field DATA_ENTREGA_ORIGINAL as char 
    field VALOR_TOTAL as char 
    field VALOR_AGENDADO as char 
    field VALOR_ENTREGUE as char 
    field CNPJ_COMPRADOR as char          format "x(40)"
    field CNPJ_ENTREGA as char            format "x(40)"  .


DEFINE TEMP-TABLE ITENS NO-UNDO 
    FIELD ITEM as char serialize-hidden.
    
DEFINE TEMP-TABLE ITEM NO-UNDO  
    field NUMERO_DOCUMENTO  as char serialize-hidden format "x(40)"
    field NUMERO_SEQUENCIAL as char 
    field CODIGO_PRODUTO as char 
    field QUANTIDADE_PEDIDA as char 
    field QUANTIDADE_AGENDADA as char 
    field QUANTIDADE_SALDO as char .
    

DEFINE DATASET CONFIRMACAOAGENDAMENTO FOR ttHEADER, DOCUMENTOS, DOCUMENTO, ITENS, ITEM.

        def var vNUMERO_DOCUMENTO as char.


    hPDS = DATASET CONFIRMACAOAGENDAMENTO:HANDLE.
    hide message no-pause.
    message p-diretorio + "/" + p-arquivo.
    
    lReturn = hPDS:READ-XML ("FILE",p-diretorio + "/" + p-arquivo, "EMPTY",
                             ?, no). 
    /* Ajusta documentos x itens */
        for each DOCUMENTO.
            vNUMERO_DOCUMENTO = "".
            for each ITEM.
                if trim(ITEM.NUMERO_DOCUMENTO) <> ""
                then next.

                if int(ITEM.NUMERO_SEQUENCIAL) = 1
                then do:
                    
                    if vNUMERO_DOCUMENTO = ""
                    then vNUMERO_DOCUMENTO = DOCUMENTO.NUMERO_DOCUMENTO.
                    else leave.
                    
                end.    
                ITEM.NUMERO_DOCUMENTO = vNUMERO_DOCUMENTO.
            end.
        end.
        
        
        for each ttHEADER:
            for each DOCUMENTO:
            
                find first ediagendam where ediagendam.NUMERO_TICKET    = ttHeader.NUMERO_TICKET and
                                            ediagendam.CGC_FORNECEDOR   = DOCUMENTO.CGC_FORNECEDOR and
                                            ediagendam.NUMERO_DOCUMENTO = DOCUMENTO.NUMERO_DOCUMENTO 
                    no-error.
                if not avail ediagendam
                then do:
                    create ediagendam.
                    ediagendam.NUMERO_TICKET    = ttHeader.NUMERO_TICKET.
                    ediagendam.CGC_FORNECEDOR   = DOCUMENTO.CGC_FORNECEDOR. 
                    ediagendam.NUMERO_DOCUMENTO = DOCUMENTO.NUMERO_DOCUMENTO .
                    ediagendam.dtinc            = ?.
                    ediagendam.hrinc            = time.
                    ediagendam.diretorio        = p-diretorio.
                    ediagendam.arquivo          = p-arquivo.
                end.
                find forne where forne.forcgc = ediagendam.CGC_FORNECEDOR no-lock no-error.
                if avail forne
                then do:
                    find first pedid where 
                        pedid.pedsit = yes and 
                        pedid.clfcod = forne.forcod and  
                        pedid.pednum = int(ediagendam.NUMERO_DOCUMENTO) 
                        no-lock no-error.
                    if not avail pedid then
                    find first pedid where 
                        pedid.pedsit = no and 
                        pedid.clfcod = forne.forcod and  
                        pedid.pednum = int(ediagendam.NUMERO_DOCUMENTO) 
                       no-lock no-error.
                    if avail pedid
                    then do:
                        ediagendam.clfcod = pedid.clfcod .
                        ediagendam.etbcod = pedid.etbcod.
                        ediagendam.pedtdc = pedid.pedtdc.
                        ediagendam.pednum = pedid.pednum.
                        ediagendam.dtinc  = today.
                    end.     
                end.
                ediagendam.dtagenda = date(int(substring(DATA_AGENDAMENTO,5,2)),
                                           int(substring(DATA_AGENDAMENTO,7,2)),
                                           int(substring(DATA_AGENDAMENTO,1,4))).
                                                                                      
                for each ITEM where ITEM.NUMERO_DOCUMENTO = DOCUMENTO.NUMERO_DOCUMENTO.
                end.            
            end.      
        end.            
        

        
         
