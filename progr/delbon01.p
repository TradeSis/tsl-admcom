{admcab.i}

def var vacao1 as int format ">>>>>9".
def var vacao2 as int format ">>>>>9".

def var vclicod like clien.clicod.

repeat:

    update vacao1 label "Acao Ini"
           help "Informe a faixa das acoes ou deixe 0 para exclusao por cliente" 
           vacao2 label "Acao Fin"
           with frame f-del-acao with width 80 side-labels
            title " Exclusao de Bonus ".

    if vacao1 = 0 and vacao2 = 0
    then do:
    
        update skip vclicod label "Cliente."
               with frame f-del-acao.
    
    end.
    
    sresp = no.

    if vacao1 = 0 and vacao2 = 0
    then message "Confirma a exclusao dos Bonus em aberto deste cliente?"   
                 update sresp.
    else message "Confirma a exclusao dos Bonus?" update sresp.
    
    if not sresp
    then leave.
    
    hide message no-pause.
    
    for each titulo where titulo.empcod = 19
                      and titulo.titnat = yes
                      and titulo.modcod = "BON" 
                      and titulo.titsit = "LIB":

        if vacao1 = 0 and vacao2 = 0
        then do:
            if titulo.clifor = vclicod
            then assign titulo.titsit   = "EXC" 
                       titulo.titdtpag = today.
        end.
        else do:
            if int(titobs[1]) >= vacao1 and
               int(titobs[1]) <= vacao2
            then do:
                assign titulo.titsit   = "EXC" 
                       titulo.titdtpag = today.
            end.
        end.
            
    end.

    message "Os Bonus foram excluidos...".
    pause 2 no-message.
    
end.    
