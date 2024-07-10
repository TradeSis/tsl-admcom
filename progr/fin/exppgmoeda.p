/* helio 13/10/2021 */
{admcab.i}

def var recatu2        as recid.
def buffer bbanboleto for banboleto.
def var prec as recid.
def var par-rec as recid.
def var vdtini  as date label "data inicial" format "99/99/9999" initial today.
def var vdtfin  as date label "data final"   format "99/99/9999" initial today.
def var vmoecod like titulo.moecod init "BOL". 
update vdtini colon 20
       vdtfin
       with frame fcab centered
       row 4 side-labels.
update vmoecod colon 20 label "moeda" with frame fcab.
find moeda where moeda.moecod = vmoecod no-lock no-error.
if not avail moeda
then do:
    message "moeda invalida".
    pause.
    undo.
end.    
disp moeda.moenom no-label with frame fcab.
def var voutrosboletosvinculados as char.

   def var varq as char format "x(60)".
   def var vcp  as char init ";".
   varq = "/admcom/relat/" + "lan" + lc(trim(vmoecod)) +  "_" +
                             "dat" + string(vdtini,"999999") + string(vdtfin,"999999") + 
                             "_"   + string(today,"999999")  + string(time) +
                             ".csv" .
                               
    pause 0.
    update skip(2) varq skip(2)
        with
        centered 
        overlay
        color messages
        no-labels
        row 8
        title "arquivo de saida".

        
    /* helio 13.10.2021. novo modelo */
    run fin/exppgmoeda_v2110.p (input vdtini , input vdtfin , input varq)  .
        


    message varq "gerado com sucesso.".
    pause 2 no-message.

