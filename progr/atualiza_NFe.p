{gerxmlnfe.i}    

def input parameter par-rec as recid.

def var vmetodo as char.
def var varquivo as char.    
def var vnumero as int.
def var vretorno as char.
def var vetbcod like estab.etbcod.
find first A01_infnfe where
           recid(A01_infnfe) = par-rec 
           exclusive no-error.
if not avail A01_infnfe
then return.
          
if not avail A01_infnfe then next.
            
vetbcod = A01_infnfe.etbcod.
vnumero = A01_infnfe.numero.
def var arq_envio as char.
def var p-valor as char.

p-valor = "".
run le_tabini.p (A01_infnfe.etbcod, 0,
                 "NFE - DIRETORIO ENVIO ARQUIVO", OUTPUT p-valor) .
arq_envio = p-valor.

def var cnpj_emi as char.
find C01_Emit of A01_infnfe .
if C01_Emit.cnpj <> ""
then cnpj_emi = C01_Emit.cnpj.
else cnpj_emi = C01_Emit.cpf.

def var vserie as int.
vserie = 1.

def var v-idamb as int.

def var v-chave-nfe as char.

v-idamb = 2.
p-valor = "".
run le_tabini.p (A01_infnfe.etbcod, 0,
            "NFE - AMBIENTE", OUTPUT p-valor) .
if p-valor = "PRODUCAO"
THEN v-idamb = 1.

    assign vmetodo = "ConsultarNfe".

    assign varquivo = arq_envio + vmetodo + "_"
                                  + string(vnumero) + "_"
                                  + string(time).

            output to value(varquivo).
        
            geraXmlNfe(yes,
                       "cnpj_emitente",
                       cnpj_emi,
                       no). 
                       
            geraXmlNfe(no,
                       "numero_nota",
                       string(vnumero),
                       no).
                       
            geraXmlNfe(no,
                       "serie_nota",
                       string(vserie),
                       yes).
                       
            output close.
    /*
    unix silent value("chmod 777 " + varquivo).
    */
    run chama-ws.p(input vetbcod,
                   input vnumero,
                   input "NotaMax",
                   input vmetodo,
                   input varquivo,
                   output vretorno).

run p-trata-retorno.

message "NFe atualizada! Utilize a opção Consulta!"
                view-as alert-box.

procedure p-trata-retorno:
    
    assign p-valor = "".
    run le_xml.p(input vretorno,
                               input "status_nfe_notamax",
                               output p-valor).

    case p-valor:
    
    when "7" then do:

        if avail A01_infnfe
            and A01_infnfe.situacao <> "Autorizada"
            and v-idamb = 1
        then do:
        
            run alt_mov_nfe.p(input "Cria",
                              input rowid(A01_infnfe)).
        end.
                                        
        if avail A01_infnfe
        then do:
            assign A01_infnfe.sitnfe = integer(p-valor)  
                    A01_infnfe.situacao = "Autorizada"
                    A01_infnfe.solicitacao = "".
            
            run le_xml.p(input vretorno,
                         input "chave_nfe",
                         output v-chave-nfe).
                         
            assign A01_infnfe.id = v-chave-nfe.
                    
        end.
    end.
    
    when "8" then do:
        
        if avail A01_infnfe
        then assign A01_infnfe.sitnfe = integer(p-valor)  
                    A01_infnfe.situacao = ""
                    A01_infnfe.solicitacao = "Autorizacao"
                    A01_infnfe.aguardando = "Intervenção-Rejeição SEFAZ".
    
    end.
    
    when "9" then do:
        
        if avail A01_infnfe
        then assign A01_infnfe.sitnfe = integer(p-valor)  
                    A01_infnfe.situacao = "Denegada"
                    A01_infnfe.solicitacao = ""
                    A01_infnfe.aguardando = "".
    
    end.

    when "12" then do:
        
        if avail A01_infnfe
        then assign A01_infnfe.sitnfe = integer(p-valor)  
                    A01_infnfe.situacao = "Inutilizada"
                    A01_infnfe.solicitacao = "".
    
    end.
    

    when "14" then do:
    
        if avail A01_infnfe
        then assign A01_infnfe.sitnfe = integer(p-valor)
                    A01_infnfe.situacao = "Cancelada"
                    A01_infnfe.solicitacao = "".

        if v-idamb = 1
        then run alt_mov_nfe.p(input "Cancela",
                                        input rowid(A01_infnfe)).

    end.
    /*
    when " " then do:
        assign p-valor = "".
        run le_xml.p(input par-arq-retorno,
                               input "mensagem_erro",
                               output p-valor).
         if p-valor <> ""
         then do :
            find B01_IdeNFe of bA01_infnfe.
            B01_IdeNFe.temite = p-valor.
         end.
    end.
    */
    end case.
    
end procedure.



