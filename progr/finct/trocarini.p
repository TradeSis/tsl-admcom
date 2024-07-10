/* 09022023 helio ID 155965 */
/* helio 20122021 - Melhorias contas a receber fase II  */

{admcab.i}

def var vfiltraoperacao as log format "Sim/Nao" label "Filtra por data operacao".
def var vfiltracontabil as log format "Sim/Nao" label "Filtra por data contabilizacao".
def var vfiltraenvSap as log format "Sim/Nao" label "Filtra por data Envio P/Sap".


def var vdtini  as date format "99/99/9999" label "De".
def var vdtfin  as date format "99/99/9999" label "Ate".             
form 
     vfiltraoperacao colon 40
     vfiltracontabil colon 40
     vfiltraenvsap   colon 40
     vdtini colon 40 label "De"
     vdtfin label "Ate"
         with frame fcab
         no-box
        row 3 width 80
        side-labels.
   vfiltraoperacao = yes.
   vfiltracontabil = no.

repeat with frame fcab:
        
    update vfiltraoperacao.
    if not vfiltraoperacao
    then do:
        update vfiltracontabil.
        if not vfiltracontabil
        then update vfiltraenvSap = yes.
        else update vfiltraenvSap = no.
    end.
    else do:
        vfiltracontabil = no.    
        vfiltraenvsap = no.
    end.    
    disp vfiltracontabil vfiltraenvSap.
    if not vfiltraoperacao and not vfiltracontabil and not vfiltraenvSap
    then do:
        message "escolha uma opcao".
        undo.
    end.
    update vdtini vdtfin .
 
    if vfiltraoperacao
    then run finct/trocarope.p (vdtini , vdtfin).
    if vfiltracontabil
    then run finct/trocarctb.p (vdtini , vdtfin).
    if vfiltraenvsap
    then run finct/trocaresap.p (vdtini , vdtfin).
    
    

end.

