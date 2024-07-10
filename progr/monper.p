{admcab.i}

def var recatu1         as recid.
def var recatu2         as recid.
def var reccont         as int.
def var esqpos1         as int.
def var esqpos2         as int.
def var esqregua        as log.
def var esqvazio        as log.
def var esqascend     as log initial yes.
def var esqcom1         as char format "x(12)" extent 5
    initial [" Inclusao "," Alteracao "," Consulta "," "," "].
def var esqcom2         as char format "x(12)" extent 5
            initial [" Arquivo CSV"," ","","",""].
def var esqhel1         as char format "x(80)" extent 5
    initial [" Inclusao  de Percentuais de Montagem - Filial ",
             " Alteracao de Percentuais de Montagem - Filial ",
             " Consulta  de Percentuais de Montagem - Filial ",
             "",
             ""].
def var esqhel2         as char format "x(12)" extent 5
   initial ["  ",
            " ",
            " ",
            " ",
            " "].

def buffer bmonper       for monper.


form
    esqcom1
    with frame f-com1
                 row 4 no-box no-labels side-labels column 1 centered.
form
    esqcom2
    with frame f-com2
                 row screen-lines no-box no-labels side-labels column 1
                 centered.
assign
    esqregua = yes
    esqpos1  = 1
    esqpos2  = 1.

bl-princ:
repeat:

    disp esqcom1 with frame f-com1.
    disp esqcom2 with frame f-com2.
    if recatu1 = ?
    then
        run leitura (input "pri").
    else
        find monper where recid(monper) = recatu1 no-lock.
    if not available monper
    then esqvazio = yes.
    else esqvazio = no.
    clear frame frame-a all no-pause.
    if not esqvazio
    then do:
        run frame-a.
    end.

    recatu1 = recid(monper).
    if esqregua
    then color display message esqcom1[esqpos1] with frame f-com1.
    else color display message esqcom2[esqpos2] with frame f-com2.
    if not esqvazio
    then repeat:
        run leitura (input "seg").
        if not available monper
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
            find monper where recid(monper) = recatu1 no-lock.

            status default
                if esqregua
                then esqhel1[esqpos1] + if esqpos1 > 1 and
                                           esqhel1[esqpos1] <> ""
                                        then  string(monper.etbcod)
                                        else ""
                else esqhel2[esqpos2] + if esqhel2[esqpos2] <> ""
                                        then string(monper.etbcod)
                                        else "".
            run color-message.
            choose field monper.etbcod
                         monper.moncod
                         adm.montagem.monnom
                         monper.monper
                help ""
                go-on(cursor-down cursor-up
                      cursor-left cursor-right
                      page-down   page-up
                      tab PF4 F4 ESC return) /*color white/black*/.
            run color-normal.
            status default "".

        end.
            if keyfunction(lastkey) = "TAB"
            then do:
                if esqregua
                then do:
                    color display normal esqcom1[esqpos1] with frame f-com1.
                    color display message esqcom2[esqpos2] with frame f-com2.
                end.
                else do:
                    color display normal esqcom2[esqpos2] with frame f-com2.
                    color display message esqcom1[esqpos1] with frame f-com1.
                end.
                esqregua = not esqregua.
            end.
            if keyfunction(lastkey) = "cursor-right"
            then do:
                if esqregua
                then do:
                    color display normal esqcom1[esqpos1] with frame f-com1.
                    esqpos1 = if esqpos1 = 5 then 5 else esqpos1 + 1.
                    color display messages esqcom1[esqpos1] with frame f-com1.
                end.
                else do:
                    color display normal esqcom2[esqpos2] with frame f-com2.
                    esqpos2 = if esqpos2 = 5 then 5 else esqpos2 + 1.
                    color display messages esqcom2[esqpos2] with frame f-com2.
                end.
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
                else do:
                    color display normal esqcom2[esqpos2] with frame f-com2.
                    esqpos2 = if esqpos2 = 1 then 1 else esqpos2 - 1.
                    color display messages esqcom2[esqpos2] with frame f-com2.
                end.
                next.
            end.
            if keyfunction(lastkey) = "page-down"
            then do:
                do reccont = 1 to frame-down(frame-a):
                    run leitura (input "down").
                    if not avail monper
                    then leave.
                    recatu1 = recid(monper).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "page-up"
            then do:
                do reccont = 1 to frame-down(frame-a):
                    run leitura (input "up").
                    if not avail monper
                    then leave.
                    recatu1 = recid(monper).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "cursor-down"
            then do:
                run leitura (input "down").
                if not avail monper
                then next.
                color display white/red 
                              monper.etbcod
                              monper.moncod
                              monper.monper
                              with frame frame-a.
                if frame-line(frame-a) = frame-down(frame-a)
                then scroll with frame frame-a.
                else down with frame frame-a.
            end.
            if keyfunction(lastkey) = "cursor-up"
            then do:
                run leitura (input "up").
                if not avail monper
                then next.
                color display white/red 
                              monper.etbcod
                              monper.moncod
                              monper.monper
                              with frame frame-a.
                if frame-line(frame-a) = 1
                then scroll down with frame frame-a.
                else up with frame frame-a.
            end.
 
        if keyfunction(lastkey) = "end-error"
        then leave bl-princ.

        if keyfunction(lastkey) = "return" or esqvazio
        then do:
            form monper.etbcod   label "Filial...." skip
                 monper.moncod   label "Montagem.." skip
                 monper.monper   label "Percentual" skip
                 monper.situacao label "Situacao.."
                 with frame f-monper color black/cyan
                      centered side-label row 5 .

            form monper.etbcod label "Filial...." skip
                 monper.moncod label "Montagem.." skip
                 monper.monper label "Percentual"
                 with frame f-monper1 color black/cyan
                      centered side-label row 7 .
                      
            hide frame frame-a no-pause.
            if esqregua
            then do:
                display caps(esqcom1[esqpos1]) @ esqcom1[esqpos1]
                        with frame f-com1.

                if esqcom1[esqpos1] = " Inclusao " or esqvazio
                then do with frame f-monper1 on error undo.
                    create monper.
                    update monper.etbcod
                           monper.moncod
                           monper.monper.
                    
                    monper.situacao = yes.
                    recatu1 = recid(monper).
                    leave.
                end.
                if esqcom1[esqpos1] = " Consulta " or
                   esqcom1[esqpos1] = " Exclusao " or
                   esqcom1[esqpos1] = " Alteracao "
                then do with frame f-monper.
                    disp monper.etbcod
                         monper.moncod
                         monper.monper
                         monper.situacao.
                end.
                if esqcom1[esqpos1] = " Alteracao "
                then do with frame f-monper on error undo.
                    find monper where
                            recid(monper) = recatu1 
                        exclusive.

                    update monper.etbcod
                           monper.moncod
                           monper.monper
                           monper.situacao.

                end.
                if esqcom1[esqpos1] = " Exclusao "
                then do with frame f-exclui  row 5 1 column centered
                        on error undo.
                    message "Confirma Exclusao de" monper.moncod
                            update sresp.
                    if not sresp
                    then undo, leave.
                    find next monper where true no-error.
                    if not available monper
                    then do:
                        find monper where recid(monper) = recatu1.
                        find prev monper where true no-error.
                    end.
                    recatu2 = if available monper
                              then recid(monper)
                              else ?.
                    find monper where recid(monper) = recatu1
                            exclusive.
                    delete monper.
                    recatu1 = recatu2.
                    leave.
                end.
                if esqcom1[esqpos1] = " Listagem "
                then do with frame f-Lista:
                    update "Deseja Imprimir todas ou a selecionada "
                           sresp format "Todas/Selecionada"
                                 help "Todas/Selecionadas"
                           with frame f-lista row 15 centered color black/cyan
                                 no-label.
                    if sresp
                    then run lmonper.p (input 0).
                    else run lmonper.p (input monper.moncod).
                    leave.
                end.
            end.
            else do:
                display caps(esqcom2[esqpos2]) @ esqcom2[esqpos2]
                        with frame f-com2.
                if esqcom2[esqpos2] = "  "
                then do:
                    hide frame f-com1  no-pause.
                    hide frame f-com2  no-pause.
                    /* run programa de relacionamento.p (input ). */
                    view frame f-com1.
                    view frame f-com2.
                end.
                if esqcom2[esqpos2] = " Arquivo CSV"
                then do:
                    run arquivo-CSV.
                end.
                leave.
            end.
        end.
        if not esqvazio
        then do:
            run frame-a.
        end.
        if esqregua
        then display esqcom1[esqpos1] with frame f-com1.
        else display esqcom2[esqpos2] with frame f-com2.
        recatu1 = recid(monper).
    end.
    if keyfunction(lastkey) = "end-error"
    then do:
        view frame fc1.
        view frame fc2.
    end.
end.
hide frame f-com1  no-pause.
hide frame f-com2  no-pause.
hide frame frame-a no-pause.

procedure frame-a.
    find adm.montagem where 
         adm.montagem.moncod = monper.moncod no-lock no-error.
    
    display monper.etbcod    column-label "Filial"
            monper.moncod    column-label "Cod" format ">>9"
            adm.montagem.monnom when avail adm.montagem
                             format "x(20)"
                             column-label "Montagem"
            monper.monper    column-label "Percentual"
            monper.situacao  column-label "Situacao"
            with frame frame-a 11 down centered color white/red row 5.
end procedure.

procedure color-message.
    find adm.montagem where 
         adm.montagem.moncod = monper.moncod no-lock no-error.

    color display message
            monper.etbcod
            monper.moncod
            adm.montagem.monnom when avail adm.montagem
            monper.monper
            monper.situacao
            with frame frame-a.
end procedure.
procedure color-normal.
    find adm.montagem where 
         adm.montagem.moncod = monper.moncod no-lock no-error.

    color display normal
            monper.etbcod
            monper.moncod
            adm.montagem.monnom when avail adm.montagem
            monper.monper
            monper.situacao
            with frame frame-a.
end procedure.




procedure leitura . 
def input parameter par-tipo as char.
        
if par-tipo = "pri" 
then  
    if esqascend  
    then  
        find first monper where true
                                                no-lock no-error.
    else  
        find last monper  where true
                                                 no-lock no-error.
                                             
if par-tipo = "seg" or par-tipo = "down" 
then  
    if esqascend  
    then  
        find next monper  where true
                                                no-lock no-error.
    else  
        find prev monper   where true
                                                no-lock no-error.
             
if par-tipo = "up" 
then                  
    if esqascend   
    then   
        find prev monper where true  
                                        no-lock no-error.
    else   
        find next monper where true 
                                        no-lock no-error.
        
end procedure.
         

procedure arquivo-CSV:

    def var vpercent as char.
    def var varquivo as char.
    varquivo = "/admcom/relat/monper-" + string(time) + ".csv".

    output to value(varquivo) page-size 0.
    
    put "Filial;MonCod;MonDes;Percentual;Situacao" skip.
    
    for each monper no-lock by monper.etbcod by monper.moncod:
        find adm.montagem where
             adm.montagem.moncod = monper.moncod no-lock no-error.

        vpercent = string(monper.monper,">>9.99").
        vpercent = replace(vpercent,".",",").
        
        put unformatted
            monper.etbcod ";"
            monper.moncod ";"
            .
            
        if avail adm.montagem
        then put unformatted adm.montagem.monnom ";".
        
        put unformatted 
                 vpercent ";"
                 .
        if monper.situacao
        then put "Ativo".
        else put "Inativo".         
                 
        put  skip .
    end.
    output close.
    
    varquivo = replace(varquivo,"admcom","L:~\").
    varquivo = replace(varquivo,"relat","relat~\").
    varquivo = replace(varquivo,"/","").
    
    message color red/with
                  "Arquivo gerado" varquivo view-as alert-box.

end procedure.



