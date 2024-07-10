/*{admcab.i}*/
{gerxmlnfe.i}    
def input parameter p-recid as recid.
def output parameter chave-nfe as char.
find placon where recid(placon) = p-recid no-lock no-error.
if not avail placon then return.
def var p-valor as char.
def var vmodo as char.
def var arq_envio as char.
def var vmetodo as char.
def var varquivo as char.
def var vretorno as char.
def var vcnpj as char.     
def var vnum-erro as int.
def var p-chave as char.
def var p-desc-status as char.
def var p-status as char.
def var p-protocolo as char.
find estab where estab.etbcod = placon.emite no-lock no-error.
if not avail estab then return.
vcnpj = estab.etbcgc.
vcnpj = replace(vcnpj,".","").
vcnpj = replace(vcnpj,"/","").
vcnpj = replace(vcnpj,"-","").

def buffer b01 for a01_infnfe.
def buffer c01 for a01_infnfe.

    p-valor = "".
    run le_tabini.p (placon.etbcod, 0,
                     "NFE - DIRETORIO ENVIO ARQUIVO", OUTPUT p-valor) .
                         arq_envio = p-valor.

    vmetodo = "ConsultarNfe".
    varquivo = arq_envio + vmetodo + "_"
                                    + string(placon.numero) + "_"
                                    + string(time).

    output to value(varquivo).
        
    geraXmlNfe(yes,
                   "cnpj_emitente",
                   vcnpj,
                   no). 
                     
    geraXmlNfe(no,
                   "numero_nota",
                   string(placon.numero),
                   no).
                       
    geraXmlNfe(no,
                   "serie_nota",
                   string(placon.serie),
                   yes).
                       
    output close.

    run chama-wsnfe-integra.p(input placon.etbcod,
                       input placon.numero,
                       input "NotaMax",
                       input vmetodo,
                       input varquivo,
                       input "",
                       input "",
                       input "",
                       input "",
                       output vretorno).
                      
    p-valor = "".
    p-chave = "".
    run le_xml.p(input vretorno,
                     input "chave_nfe",
                     output p-valor).
    p-chave = p-valor. 
    chave-nfe = p-chave.
    p-valor = "".
    p-status = "".
    run le_xml.p(input vretorno,
                     input "status_nfe_notamax",
                     output p-valor).
    p-status = p-valor.  
    p-valor = "".
    p-protocolo = "".
    run le_xml.p(input vretorno,
                     input "protocolo_autorizacao",
                     output p-valor).
    p-protocolo = p-valor.  
    p-valor = "".
    p-desc-status = "".
    run le_xml.p(input vretorno,
                     input "desc_status_nfe_notamax",
                     output p-valor).
    p-desc-status = p-valor.                            

if p-chave <> ""
then do on error undo:
    find current placon no-error.
    find       a01_infnfe where
               a01_infnfe.emite = placon.emite and
               a01_infnfe.serie = placon.serie and
               a01_infnfe.numero = placon.numero
               no-error.
    if not avail a01_infnfe
    then do:
        find b01 where b01.chave = p-chave no-lock no-error.
        if not avail b01
        then do:
            find c01 where c01.etbcod = placon.etbcod and
                           c01.placod = placon.placod
                           no-lock no-error.
            if not avail c01
            then do on error undo:

                create a01_infnfe.
                assign
                    a01_infnfe.emite = placon.emite
                    a01_infnfe.serie = placon.serie
                    a01_infnfe.numero = placon.numero
                    a01_infnfe.etbcod = placon.etbcod
                    a01_infnfe.placod = placon.placod
                    a01_infnfe.mod = "55"
                    a01_infnfe.id = p-chave
                    a01_infnfe.chave = p-chave
                    a01_infnfe.sitnfe = int(p-status)
                    a01_infnfe.situacao = p-desc-status
                    .
                placon.ufdes = p-chave.
            end.
        end.          
    end.
    else do on error undo:
        if a01_infnfe.id = ""
        then a01_infnfe.id = p-chave.
        if placon.ufdes = ""
        then placon.ufdes = p-chave.
        if a01_infnfe.sitnfe <> int(p-status)
        then assign
                a01_infnfe.sitnfe = int(p-status)
                a01_infnfe.situacao = p-desc-status.
    end.    
end.
return.
                    
