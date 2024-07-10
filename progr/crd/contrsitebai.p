/*
*
*
*/
{admcab.i}

def input parameter par-rec as recid.
def var vmaxdevol as int.
def var vqtddevol as int.

    def var ttitvlprod as dec              .
    def var ttitvlfrete as dec             .
    def var ttitvlacres as dec             .
    def var ttitvlbaixa as dec             .
    def var ttitvlcredito as dec           .
      
find contrsite where recid(contrsite) = par-rec no-lock.
find contrato   of contrsite  no-lock.


        ttitvlbaixa     = 0.
        ttitvlcredito   = 0.
        ttitvlprod      = 0.
        ttitvlfrete     = 0.
        ttitvlacres     = 0.

for each contrsitbai of contrsite no-lock.
    

        ttitvlbaixa     = ttitvlbaixa + contrsitbai.titvlbaixa.
        ttitvlcredito   = ttitvlcredito + contrsitbai.titvlcredito.
        ttitvlprod      = ttitvlprod + contrsitbai.titvlprod.
        ttitvlfrete     = ttitvlfrete + contrsitbai.titvlfrete.
        ttitvlacres     = ttitvlacres + contrsitbai.titvlacres.
     
end.
def var recatu1         as recid.
def var reccont         as int.
def var esqpos1         as int.
def var esqcom1         as char format "x(12)" extent 3
    init [" ","  ", ""].

form
    esqcom1
    with frame f-com1 row screen-lines no-box no-labels column 40.
pause 0.
    esqpos1  = 1.
    form
        contrsitbai.titpar format ">9" column-label "Pc"
        contrsitbai.titdtpag column-label "Data" format "99/99/9999"
        contrsitbai.titvlbaixa   format ">>>9.99" column-label "Baixa"
        contrsitbai.titvlcredito format ">>>9.99" column-label "Credito"
        "|" space(0)
        contrsitbai.titvlprod    format ">>>9.99" column-label "Produ"
        contrsitbai.titvlfrete   format ">>>9.99" column-label "Frete"
        contrsitbai.titvlacres   format ">>>9.99" column-label "Acres"
        
        
        
        with frame frame-a 7 down centered row 9 overlay  
            title " Baixas de  Devolucao do Pedido  " + contrsite.codigoPedido + "/" + string(contrato.contnum,">>>>>>>>>>9").

    disp
        space(14)
        
        ttitvlbaixa   format ">>>9.99" column-label "Baixa"
        ttitvlcredito format ">>>9.99" column-label "Credito"
        "|" space(0)
        ttitvlprod    format ">>>9.99" column-label "Produ"
        ttitvlfrete   format ">>>9.99" column-label "Frete"
        ttitvlacres   format ">>>9.99" column-label "Acres"
        
        
        
        with frame frame-t 1 down centered row screen-lines - 1 overlay no-labels no-box.


bl-princ:
repeat:
    disp esqcom1 with frame f-com1.
    if recatu1 = ?
    then run leitura (input "pri").
    else find contrsitbai where recid(contrsitbai) = recatu1 no-lock. 
    if not available contrsitbai
    then do.
        message "Sem registros" view-as alert-box.
        leave.
    end.
    clear frame frame-a all no-pause.
        run frame-a.

    recatu1 = recid(contrsitbai).
    color display message esqcom1[esqpos1] with frame f-com1.

    repeat.
        run leitura (input "seg").
        if not available contrsitbai
        then leave.
        if frame-line(frame-a) = frame-down(frame-a)
        then leave.
        down with frame frame-a.
        run frame-a.
    end.
    up frame-line(frame-a) - 1 with frame frame-a.

    repeat with frame frame-a:

            find contrsitbai where recid(contrsitbai) = recatu1 no-lock.

            status default "".
            run color-message.
            choose field contrsitbai.titpar help ""
                go-on(cursor-down cursor-up                       cursor-left cursor-right

                      page-down   page-up
                      PF4 F4 ESC return) .
            run color-normal.
            if keyfunction(lastkey) = "cursor-right"
            then do:
                color display normal esqcom1[esqpos1] with frame f-com1.
                esqpos1 = if esqpos1 = 3 then 3 else esqpos1 + 1.
                color display messages esqcom1[esqpos1] with frame f-com1.
                next.
            end.
            if keyfunction(lastkey) = "cursor-left"
            then do:
                color display normal esqcom1[esqpos1] with frame f-com1.
                esqpos1 = if esqpos1 = 1 then 1 else esqpos1 - 1.
                color display messages esqcom1[esqpos1] with frame f-com1.
                next.
            end.

            if keyfunction(lastkey) = "page-down"
            then do:
                do reccont = 1 to frame-down(frame-a):
                    run leitura (input "down").
                    if not avail contrsitbai
                    then leave.
                    recatu1 = recid(contrsitbai).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "page-up"
            then do:
                do reccont = 1 to frame-down(frame-a):
                    run leitura (input "up").
                    if not avail contrsitbai
                    then leave.
                    recatu1 = recid(contrsitbai).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "cursor-down"
            then do:
                run leitura (input "down").
                if not avail contrsitbai
                then next.
                if frame-line(frame-a) = frame-down(frame-a)
                then scroll with frame frame-a.
                else down with frame frame-a.
            end.
            if keyfunction(lastkey) = "cursor-up"
            then do:
                run leitura (input "up").
                if not avail contrsitbai
                then next.
                if frame-line(frame-a) = 1
                then scroll down with frame frame-a.
                else up with frame frame-a.
            end.
 
        if keyfunction(lastkey) = "end-error"
        then leave bl-princ.

        if keyfunction(lastkey) = "return"
        then do:
            hide frame frame-a no-pause.
                display caps(esqcom1[esqpos1]) @ esqcom1[esqpos1]
                        with frame f-com1.

        
        end.
        run frame-a.
        display esqcom1[esqpos1] with frame f-com1.
        recatu1 = recid(contrsitbai).
    end.
    if keyfunction(lastkey) = "end-error"
    then do:
        view frame fc1.
        view frame fc2.
    end.
end.
hide frame f-com1  no-pause.
hide frame frame-a no-pause.


procedure frame-a.

    display
        contrsitbai.titpar
        contrsitbai.titdtpag
        contrsitbai.titvlbaixa
        contrsitbai.titvlcredito
        contrsitbai.titvlprod
        contrsitbai.titvlfrete
        contrsitbai.titvlacres
        
        with frame frame-a.
end procedure.


procedure color-message.
    color display message
            contrsitbai.titpar
        with frame frame-a.
end procedure.


procedure color-normal.
    color display normal
            contrsitbai.titpar
        with frame frame-a.
end procedure.


procedure leitura . 
def input parameter par-tipo as char.
        
if par-tipo = "pri" 
then find first contrsitbai of contrsite no-lock no-error.
                                             
if par-tipo = "seg" or par-tipo = "down" 
then find next contrsitbai of contrsite no-lock no-error.
             
if par-tipo = "up" 
then find prev contrsitbai of contrsite  no-lock no-error.
        
end procedure.



