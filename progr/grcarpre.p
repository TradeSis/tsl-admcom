{admcab.i}

def var num-ini as int.
def var num-fim as int.
def var cont-num as int.
def var vnumero-chp as char format "x(15)".
update num-ini label "Numeracao inicial" format ">>>>>>>>9"
       num-fim label "Numeracao final" format ">>>>>>>>9"
       with frame f1 width 80 1 down side-label.
if num-ini = ? or num-fim = 0 or
   num-fim = ? or num-fim = 0 or
   num-ini > num-fim 
then undo.

def var dt-ini as date.
def var dt-fim as date.
/**/
update dt-ini label "Validade - Inicial"
        validate(dt-ini = ? or dt-ini >= today,
               "Validade inicil deve ser maior ou igual a " + 
               string(today,"99/99/9999"))
    with frame f1.
if dt-ini <> ?
then update  dt-fim label  "Final"
        validate(dt-fim <> ? and
                 dt-fim >= today,
                 "Validade final deve ser maior ou igual a " +
                 string(today,"99/99/9999"))
            with frame f1.
/**/
sresp = no.      
message "Confirma gerar Cartao Presente ?" update sresp.
if sresp
then do:

    do cont-num = num-ini to num-fim:
 
       vnumero-chp = string(cont-num).
 
       disp "Gerando Cartao Presente...   "  vnumero-chp
        with frame f-disp 1 down no-box color message side-label
        row 17 NO-LABEL.
        pause 0.    

        find titulo where titulo.empcod = 19
                      and titulo.titnat = yes
                      and titulo.modcod = "CHP"
                      and titulo.etbcod = 999
                      and titulo.clifor = 110165
                      and titulo.titnum = vnumero-chp
                      and titulo.titpar = 1 no-lock no-error.
        if not avail titulo
        then do transaction:
            create titulo.
            assign titulo.empcod    = 19
                   titulo.titnat    = yes
                   titulo.modcod    = "CHP"
                   titulo.etbcod    = 999
                   titulo.clifor    = 110165
                   titulo.titnum    = vnumero-chp
                   titulo.titpar    = 1
                   titulo.titsit    = "LIB"
                   titulo.titvlcob  = 0
                   titulo.titdtemi  = today 
                   titulo.datexp    = today
                   titulo.exportado = no.
            assign
                titulo.titdtdes = dt-ini
                titulo.titdtven = dt-fim
                .
        end.
    end.
    message color red/with
        "FIM DA GERACAO DE CARTAO PRESENTE"
        VIEW-AS ALERT-BOX.
        
end.