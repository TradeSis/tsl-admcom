{admcab.i}
{gerxmlnfe.i}

def input parameter p-recid as recid.
def var varquivo as char.

def var p-valor as char.
p-valor = "".

def var v-email as char format "x(50)".
find A01_infnfe where recid(A01_infnfe) = p-recid no-lock.
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
def var v-chave as char.
if A01_infnfe.id <> ""
then v-chave = A01_infnfe.id.
else v-chave = substr(string(A01_infnfe.id),4,34).
disp A01_infnfe.emite
     A01_infnfe.serie
     A01_infnfe.numero
     with frame f-mail row 6 .
def var v-index as int .
disp v-email label "Email" with frame f-mail 1 down 
        side-label .
update v-email with frame f-mail.

if v-email = "" then undo.

def var v-tipo as char extent 3 format "x(15)"
init ["1 - XML","2 - DANFE","3 - AMBOS"].

disp v-tipo with frame f-esc 1 down no-label 1 column .
choose field v-tipo with frame f-esc.
v-index = frame-index .              
p-valor = "".
run le_tabini.p (A01_infnfe.emite, 0,
            "NFE - DIRETORIO ENVIO ARQUIVO", OUTPUT p-valor) .

varquivo = p-valor + "EnviarEmailDistribuicao_" + v-chave + ".xml".

def var mail-dest as char.
def var mail-tran as char.
def var opc-dest as char.
def var opc-tran as dec.
def var vretorno as char.

sresp = no.
message "Confirma enviar Email?" update sresp.
if sresp
then do:

    find first C01_Emit of A01_infnfe no-lock no-error.

    output to value(varquivo).
        
    /*geraXmlNfe(yes, "cnpj_emitente", C01_Emit.cnpj, no).
    geraXmlNfe(no, "numero_nota", string(A01_infnfe.numero), no).
    geraXmlNfe(no, "serie_nota", A01_infnfe.serie, no). */
    geraXmlNfe(yes, "chave_nfe", v-chave, no).
    geraXmlNfe(no, "email_destinatario", v-email, no).
    /*geraXmlNfe(no, "email_transportadora", "", no).*/
    geraXmlNfe(no, "opcao_destinatario", string(v-index), yes).
    /*geraXmlNfe(no, "opcao_transportadora", "", yes).*/
    
    output close.


    run chama-wsnfe.p(input A01_InfNFe.etbcod,
               input A01_InfNFe.numero,
               input "NotaMax",
               input "EnviarEmailDistribuicao",
               input varquivo,
               input mail-dest,
               input opc-dest,
               input mail-tran,
               input opc-tran,
               output vretorno).

    pause 5 no-message.
        
    assign p-valor = "".
    run /admcom/progr/le_xml.p(input vretorno,
                           input "status_notamax",
                           output p-valor).
               
    if p-valor = "0"
    then do:    
        bell.   
        message color red/with
             "NOTAMAX RETORNOU QUE RECBEU A SOLICITACAO " skip
             "E QUE ENVIARA O EMAIL AO DESTINATARIO."
             view-as alert-box.
    END.
    else do:

        assign p-valor = "".
        run /admcom/progr/le_xml.p(input vretorno,
                               input "mensagem_erro",
                               output p-valor).

        bell.
        message color red/with
        p-valor
        view-as alert-box.
    end.
end. 
