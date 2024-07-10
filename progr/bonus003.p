{admcab.i}

def shared temp-table tt-cli
    field clicod like clien.clicod
    field clinom like clien.clinom
    field valor  as dec
    field bonus as dec
    field recencia like rfvcli.recencia 
    field frequencia like rfvcli.frequencia 
    field valor-rfv like rfvcli.valor  
    index icli is primary unique clicod.

def var recatu1         as recid.
def var recatu2         as recid.
def var reccont         as int.
def var esqpos1         as int.
def var esqpos2         as int.
def var esqregua        as log.
def var esqvazio        as log.
def var esqascend     as log initial yes.

def var esqcom1         as char format "x(16)" extent 4
    initial [" Gerar Campanha ","","",""].

/*def var esqcom2         as char format "x(12)" extent 5
            initial [" "," ","","",""].*/

def var esqhel1         as char format "x(80)" extent 5
    initial [" ",
             " ",
             " ",
             " ",
             " "].

def var esqhel2         as char format "x(12)" extent 5
   initial ["  ",
            " ",
            " ",
            " ",
            " "].

def buffer btt-cli       for tt-cli.
def var vtt-cli         like tt-cli.clicod.


form
    esqcom1
    with frame f-com1
                 row 4 no-box no-labels side-labels column 1 centered.
/*form
    esqcom2
    with frame f-com2
                 row screen-lines no-box no-labels side-labels column 1
                 centered.*/
                 
assign
    esqregua = yes
    esqpos1  = 1
    esqpos2  = 1.

def var vtotpar as int.
def var vtotbon as dec.

for each btt-cli:
    assign vtotpar = vtotpar + 1
           vtotbon = vtotbon + btt-cli.bonus.
end.

disp space(10) vtotpar label "Total de Participantes"
     vtotbon label "Total de Bonus"
     with frame f-totais 
            side-labels row 20 overlay no-box.
            
bl-princ:
repeat:

    disp esqcom1 with frame f-com1.
    /*disp esqcom2 with frame f-com2.*/
    if recatu1 = ?
    then
        run leitura (input "pri").
    else
        find tt-cli where recid(tt-cli) = recatu1 no-lock.
    if not available tt-cli
    then esqvazio = yes.
    else esqvazio = no.
    clear frame frame-a all no-pause.
    if not esqvazio
    then do:
        run frame-a.
    end.

    recatu1 = recid(tt-cli).
    if esqregua
    then color display message esqcom1[esqpos1] with frame f-com1.
    /*else color display message esqcom2[esqpos2] with frame f-com2.*/

    if not esqvazio
    then repeat:
        run leitura (input "seg").
        if not available tt-cli
        then leave.
        if frame-line(frame-a) = frame-down(frame-a)
        then leave.
        down
            with frame frame-a.
        run frame-a.
    end.
    if not esqvazio
    then up frame-line(frame-a) - 1 with frame frame-a.

    repeat with frame frame-a:

        if not esqvazio
        then do:
            find tt-cli where recid(tt-cli) = recatu1 no-lock.

            status default
                if esqregua
                then esqhel1[esqpos1] + if esqpos1 > 1 and
                                           esqhel1[esqpos1] <> ""
                                        then  string(tt-cli.clicod)
                                        else ""
                else esqhel2[esqpos2] + if esqhel2[esqpos2] <> ""
                                        then string(tt-cli.clicod)
                                        else "".
            run color-message.
    
            choose field tt-cli.clicod help ""
                go-on(cursor-down cursor-up
                      cursor-left cursor-right
                      page-down   page-up
                      tab PF4 F4 ESC return).
                      
            run color-normal.
            status default "".

        end.
            if keyfunction(lastkey) = "TAB"
            then do:
                if esqregua
                then do:
                    color display normal esqcom1[esqpos1] with frame f-com1.
                   /*color display message esqcom2[esqpos2] with frame f-com2.*/
                end.
                else do:
                   /*color display normal esqcom2[esqpos2] with frame f-com2.*/
                    color display message esqcom1[esqpos1] with frame f-com1.
                end.
                esqregua = not esqregua.
            end.
            if keyfunction(lastkey) = "cursor-right"
            then do:
                if esqregua
                then do:
                    color display normal esqcom1[esqpos1] with frame f-com1.
                    esqpos1 = if esqpos1 = 4 then 4 else esqpos1 + 1.
                    color display messages esqcom1[esqpos1] with frame f-com1.
                end.
                /*else do:
                    color display normal esqcom2[esqpos2] with frame f-com2.
                    esqpos2 = if esqpos2 = 4 then 4 else esqpos2 + 1.
                    color display messages esqcom2[esqpos2] with frame f-com2.
                end.*/
                next.
            end.                            
            if keyfunction(lastkey) = "cursor-left"
            then do:
                if esqregua
                then do:
                    color display normal esqcom1[esqpos1] with frame f-com1.
                    esqpos1 = if esqpos1 = 1 then 1 else esqpos1 - 1.
                    color display messages esqcom1[esqpos1] with frame f-com1.
                end.
                /*else do:
                    color display normal esqcom2[esqpos2] with frame f-com2.
                    esqpos2 = if esqpos2 = 1 then 1 else esqpos2 - 1.
                    color display messages esqcom2[esqpos2] with frame f-com2.
                end.*/
                next.
            end.
            if keyfunction(lastkey) = "page-down"
            then do:
                do reccont = 1 to frame-down(frame-a):
                    run leitura (input "down").
                    if not avail tt-cli
                    then leave.
                    recatu1 = recid(tt-cli).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "page-up"
            then do:
                do reccont = 1 to frame-down(frame-a):
                    run leitura (input "up").
                    if not avail tt-cli
                    then leave.
                    recatu1 = recid(tt-cli).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "cursor-down"
            then do:
                run leitura (input "down").
                if not avail tt-cli
                then next.
                color display white/red tt-cli.clicod with frame frame-a.
                if frame-line(frame-a) = frame-down(frame-a)
                then scroll with frame frame-a.
                else down with frame frame-a.
            end.
            if keyfunction(lastkey) = "cursor-up"
            then do:
                run leitura (input "up").
                if not avail tt-cli
                then next.
                color display white/red tt-cli.clicod with frame frame-a.
                if frame-line(frame-a) = 1
                then scroll down with frame frame-a.
                else up with frame frame-a.
            end.
 
        if keyfunction(lastkey) = "end-error"
        then leave bl-princ.

        if keyfunction(lastkey) = "return" or esqvazio
        then do:

            if esqregua
            then do:
                display caps(esqcom1[esqpos1]) @ esqcom1[esqpos1]
                        with frame f-com1.

                if esqcom1[esqpos1] = " Gerar Campanha "
                then do with frame f-gera-campanha on error undo.

                    run p-gera-acao.
                    
                    recatu1 = ?.
                    leave.
                end.
            end.
            else do:
                /*
                display caps(esqcom2[esqpos2]) @ esqcom2[esqpos2]
                        with frame f-com2.
                if esqcom2[esqpos2] = "  "
                then do:
                    hide frame f-com1  no-pause.
                    hide frame f-com2  no-pause.
                    /* run programa de relacionamento.p (input ). */
                    view frame f-com1.
                    view frame f-com2.
                end.*/
                leave.
            end.
        end.
        if not esqvazio
        then do:
            run frame-a.
        end.
        if esqregua
        then display esqcom1[esqpos1] with frame f-com1.
        /*else display esqcom2[esqpos2] with frame f-com2.*/
        recatu1 = recid(tt-cli).
    end.
    if keyfunction(lastkey) = "end-error"
    then do:
        view frame fc1.
        view frame fc2.
    end.
end.
hide frame f-com1  no-pause.
/*hide frame f-com2  no-pause.*/
hide frame frame-a no-pause.

procedure frame-a.
    display tt-cli.clicod column-label "Codigo"
            tt-cli.clinom column-label "Cliente"
            tt-cli.bonus  column-label "Bonus"
            with frame frame-a 11 down centered color white/red row 5.
end procedure.

procedure color-message.
    color display message tt-cli.clicod
                          tt-cli.clinom
                          tt-cli.bonus 
                          with frame frame-a.
end procedure.

procedure color-normal.
    color display normal tt-cli.clicod
                         tt-cli.clinom
                         tt-cli.bonus 
                         with frame frame-a.
end procedure.




procedure leitura . 
def input parameter par-tipo as char.
        
if par-tipo = "pri" 
then  
    if esqascend  
    then  
        find first tt-cli where true
                                                no-lock no-error.
    else  
        find last tt-cli  where true
                                                 no-lock no-error.
                                             
if par-tipo = "seg" or par-tipo = "down" 
then  
    if esqascend  
    then  
        find next tt-cli  where true
                                                no-lock no-error.
    else  
        find prev tt-cli   where true
                                                no-lock no-error.
             
if par-tipo = "up" 
then                  
    if esqascend   
    then   
        find prev tt-cli where true  
                                        no-lock no-error.
    else   
        find next tt-cli where true 
                                        no-lock no-error.

end procedure.

procedure p-gera-acao:

    def var vnumacao as int.
    def var vdescricao as char.
    def var vdata1 as date format "99/99/9999".
    def var vdata2 as date format "99/99/9999".
    def var vvalor like acao.valor.
    def var vconfirma  as logi init no.
    
    hide message no-pause.

    do on error undo:
        
         update skip(1)
                space(2) vdescricao label "Tipo de Acao" 
                         format "x(50)" space(2)
                skip
                space(2) vdata1     label "Data Inicio."
                vdata2     label "Final"
                skip
                space(2) vvalor     label "Valor......."
                skip(1)
                with frame f-acao centered overlay
                            row 10 side-labels
                            title " Acao ".

         message "Considera participantes em outras acoes?"
                 view-as alert-box buttons yes-no 
                         title "ATENCAO" update vconfirma.
    end.

    sresp = yes.
    message "Confirma a geracao da campanha ?" update sresp.
    if sresp
    then do:

        hide message no-pause.
        message "Aguarde ... Gerando Campanha ...".

        find last acao no-lock no-error.
        if not avail acao
        then vnumacao = 1.
        else vnumacao = acao.acaocod + 1.
        
        do transaction:
            create acao.
            assign acao.acaocod   = vnumacao
                   acao.descricao = caps(vdescricao)
                   acao.dtini     = vdata1
                   acao.dtfin     = vdata2
                   acao.valor     = vvalor.
        end.
    
/* NAO GERAR ACAO QUANDO PARTICIPAR NO PERIODO */

if vconfirma = yes
then do:

        for each acao where
                 acao.dtini   >= vdata1           and
                 acao.dtini   <= vdata2           or
                 acao.dtfin   >= vdata1           and
                 acao.dtfin   <= vdata2           no-lock:
            for each acao-cli where
                     acao-cli.acaocod = acao.acaocod no-lock:
                find first tt-cli where 
                           tt-cli.clicod  = acao-cli.clicod
                           exclusive-lock no-error.
                if avail tt-cli
                then do:
                     assign vtotpar = vtotpar - 1 
                            vtotbon = vtotbon - tt-cli.bonus. 
                    delete tt-cli.
                end.     
            end.    
        end.

end.

disp space(10) vtotpar label "Total de Participantes"
     vtotbon label "Total de Bonus"
     with frame f-totais 
            side-labels row 20 overlay no-box.
 
/* ------------------------------------------- */
        for each tt-cli.
                        
            find acao-cli where acao-cli.acaocod = vnumacao
                            and acao-cli.clicod = tt-cli.clicod no-error.
                      
            if not avail acao-cli 
            then do transaction:

                create acao-cli.
                assign acao-cli.clicod     = tt-cli.clicod
                       acao-cli.acaocod    = vnumacao
                       acao-cli.recencia   = tt-cli.recencia
                       acao-cli.frequencia = tt-cli.frequencia
                       acao-cli.valor      = tt-cli.valor-rfv
                       acao-cli.aux        = string(tt-cli.bonus).
            end.
        end.
        hide message no-pause.
        message "Campanha gerada com sucesso.". pause 2 no-message.
        hide message no-pause.
    end.

end procedure.
