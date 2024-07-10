
def var vassunto as char.
def var varquivo as char.
def var varqsai as char.
def var vemail as char.
def var sresp as log format "Sim/Nao".
repeat:
update vemail  label "Destinatario" format "x(60)"
       vassunto  label "Assunto"    format "x(60)"
       varquivo  label "Anexo"      format "x(60)"
       with frame f1 1 down width 80 side-label 1 column.
       
varqsai = varquivo + ".log".
sresp = no.
message "Confirma enviar e-mail?" update sresp.
if not sresp then undo.

if search(varquivo) = ?
then do:
    message "Arquivo nao encontrato."
    view-as alert-box.
    undo.
end.

unix silent value("/admcom/progr/mail.sh "
                             + "~"" + vassunto + "~" "
                             + varquivo
                             + " "
                             + vemail
                             + " "
                             + "informativo@lebes.com.br"
                             + " "
                             + "~"zip~""
                             + " > "
                             + varqsai
                             + " 2>&1 ").    
end.