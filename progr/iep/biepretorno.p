 /* 05012022 helio iepro */

def input param pacao   as char.

def var vi as int.
def var poperacao as char init "IEPRO".
def var pxmlcodocorrencia as char.
def var pxmlocorrencia as char.
def var parquivo as char.
def var dstatus   as char. 
def var parquivorecid as recid.
def var premessa as int.

if pacao = "confirmacao"
then do: 
        message "buscando " pacao.

        /* CHAMA API */ 
        run iep/geraarquivo.p (input poperacao,
                               input pacao,
                               output parquivorecid, 
                               output parquivo,
                               output premessa).
   
        run iep/montaxml-confirmacao.p (poperacao, 
                                        input parquivo,
                                        input parquivorecid,
                                        output pxmlcodocorrencia,        
                                        output pxmlocorrencia).
    
        message parquivo     "XML Ocorrencia:" pxmlcodocorrencia pxmlocorrencia.
end.    
                                        
if pacao = "retorno"
then do: 
        message "buscando " pacao.

        /* CHAMA API */ 
        run iep/geraarquivo.p (input poperacao,
                               input pacao,
                               output parquivorecid,
                               output parquivo,
                               output premessa).
   
        run iep/montaxml-retorno.p (poperacao, 
                                        input parquivo,
                                        input parquivorecid,
                                        output pxmlcodocorrencia,        
                                        output pxmlocorrencia).
                        
        message parquivo "XML Ocorrencia:" pxmlcodocorrencia pxmlocorrencia.
end.    
    
