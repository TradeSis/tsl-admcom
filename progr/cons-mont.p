{admcab.i}

def var vdata1   as   date format "99/99/9999".
def var vdata2   as   date format "99/99/9999".
def var vdata    as   date format "99/99/9999".

def temp-table tt-mon no-undo
    field montcod like adm.monmov.montcod
    field montnom like adm.montador.montnom
    field valor   like adm.monmov.movpc
    index i-montcod is primary unique montcod asc.
    
    
update vdata1 label "Data Inicial..." 
       vdata2 label "Data Final" 
       with frame f-dados centered side-labels width 80 overlay
            row 3.


for each estab no-lock:
    do vdata = vdata1 to vdata2: 
        for each adm.monmov use-index i-etb-dat where 
                 adm.monmov.etbcod = estab.etbcod 
             and adm.monmov.mondat = vdata no-lock:
                              
             find adm.monper where 
                  adm.monper.etbcod = adm.monmov.etbcod
              and adm.monper.moncod = adm.monmov.moncod 
                                            no-lock no-error.
             if not avail adm.monper 
             then next.
                                                                  
             find tt-mon where
                  tt-mon.montcod = adm.monmov.montcod no-error.
             if not avail tt-mon
             then do:
                 find adm.montador where
                      adm.montador.montcod = adm.monmov.montcod
                      no-lock no-error.
                      
                 create tt-mon.
                 assign tt-mon.montcod = adm.monmov.montcod
                        tt-mon.montnom = adm.montador.montnom
                                         when avail adm.montador.
             end.

             tt-mon.valor = tt-mon.valor +
                   (adm.monmov.movpc * adm.monper.monper) / 100.
        
        end.
    end.                                  
end.

def var recatu1         as recid.
def var recatu2         as recid.
def var reccont         as int.
def var esqpos1         as int.
def var esqpos2         as int.
def var esqregua        as log.
def var esqvazio        as log.
def var esqascend     as log initial yes.

/*def var esqcom1         as char format "x(12)" extent 5
    initial [" Inclusao "," Alteracao "," Exclusao "," Consulta "," Listagem "].
def var esqcom2         as char format "x(12)" extent 5
            initial [" "," ","","",""].*/
            
/*def var esqhel1         as char format "x(80)" extent 5
    initial [" Inclusao  de tt-mon ",
             " Alteracao da tt-mon ",
             " Exclusao  da tt-mon ",
             " Consulta  da tt-mon ",
             " Listagem  Geral de tt-mon "].
def var esqhel2         as char format "x(12)" extent 5
   initial ["  ",
            " ",
            " ",
            " ",
            " "].*/


def buffer btt-mon       for tt-mon.
def var vtt-mon         like tt-mon.montcod.


/*form
    esqcom1
    with frame f-com1
                 row 4 no-box no-labels side-labels column 1 centered.*/
/*form
    esqcom2
    with frame f-com2
                 row screen-lines no-box no-labels side-labels column 1
                 centered.*/
assign
    esqregua = yes
    esqpos1  = 1
    esqpos2  = 1.

bl-princ:
repeat:

/*    disp esqcom1 with frame f-com1.
    disp esqcom2 with frame f-com2.*/
    if recatu1 = ?
    then
        run leitura (input "pri").
    else
        find tt-mon where recid(tt-mon) = recatu1 no-lock.
    if not available tt-mon
    then do:
        esqvazio = yes.
        message "Nenhum registro encontrato".
        pause 3.
        return.
    end.        
    else esqvazio = no.
    clear frame frame-a all no-pause.
    if not esqvazio
    then do:
        run frame-a.
    end.

    recatu1 = recid(tt-mon).
/*    if esqregua
    then color display message esqcom1[esqpos1] with frame f-com1.
    else color display message esqcom2[esqpos2] with frame f-com2.*/
    if not esqvazio
    then repeat:
        run leitura (input "seg").
        if not available tt-mon
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
            find tt-mon where recid(tt-mon) = recatu1 no-lock.

/*            status default
                if esqregua
                then esqhel1[esqpos1] + if esqpos1 > 1 and
                                           esqhel1[esqpos1] <> ""
                                        then  string(tt-mon.montnom)
                                        else ""
                else esqhel2[esqpos2] + if esqhel2[esqpos2] <> ""
                                        then string(tt-mon.montnom)
                                        else "".*/
            run color-message.
            choose field tt-mon.montcod help ""
                go-on(cursor-down cursor-up
                      cursor-left cursor-right
                      page-down   page-up
                      tab PF4 F4 ESC return).
            run color-normal.
            status default "".

        end.
  /*          if keyfunction(lastkey) = "TAB"
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
*/            
            if keyfunction(lastkey) = "page-down"
            then do:
                do reccont = 1 to frame-down(frame-a):
                    run leitura (input "down").
                    if not avail tt-mon
                    then leave.
                    recatu1 = recid(tt-mon).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "page-up"
            then do:
                do reccont = 1 to frame-down(frame-a):
                    run leitura (input "up").
                    if not avail tt-mon
                    then leave.
                    recatu1 = recid(tt-mon).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "cursor-down"
            then do:
                run leitura (input "down").
                if not avail tt-mon
                then next.
                color display normal tt-mon.montcod 
                                     tt-mon.montnom
                                     tt-mon.valor   
                                        with frame frame-a.
                if frame-line(frame-a) = frame-down(frame-a)
                then scroll with frame frame-a.
                else down with frame frame-a.
            end.
            if keyfunction(lastkey) = "cursor-up"
            then do:
                run leitura (input "up").
                if not avail tt-mon
                then next.
                color display normal tt-mon.montcod
                                     tt-mon.montnom
                                     tt-mon.valor
                                     with frame frame-a.
                if frame-line(frame-a) = 1
                then scroll down with frame frame-a.
                else up with frame frame-a.
            end.
 
        if keyfunction(lastkey) = "end-error"
        then leave bl-princ.

/*        if keyfunction(lastkey) = "return" or esqvazio
        then do:
            form tt-mon
                 with frame f-tt-mon color black/cyan
                      centered side-label row 5 .
            hide frame frame-a no-pause.
            if esqregua
            then do:
                display caps(esqcom1[esqpos1]) @ esqcom1[esqpos1]
                        with frame f-com1.

                if esqcom1[esqpos1] = " Inclusao " or esqvazio
                then do with frame f-tt-mon on error undo.
                    create tt-mon.
                    update tt-mon.
                    recatu1 = recid(tt-mon).
                    leave.
              end.
                if esqcom1[esqpos1] = " Consulta " or
                   esqcom1[esqpos1] = " Exclusao " or
                   esqcom1[esqpos1] = " Alteracao "
                then do with frame f-tt-mon.
                    disp tt-mon.
                end.
                if esqcom1[esqpos1] = " Alteracao "
                then do with frame f-tt-mon on error undo.
                    find tt-mon where
                            recid(tt-mon) = recatu1 
                        exclusive.
                    update tt-mon.
                end.
                if esqcom1[esqpos1] = " Exclusao "
                then do with frame f-exclui  row 5 1 column centered
                        on error undo.
                    message "Confirma Exclusao de" tt-mon.montnom
                            update sresp.
                    if not sresp
                    then undo, leave.
                    find next tt-mon where true no-error.
                    if not available tt-mon
                    then do:
                        find tt-mon where recid(tt-mon) = recatu1.
                        find prev tt-mon where true no-error.
                    end.
                    recatu2 = if available tt-mon
                              then recid(tt-mon)
                              else ?.
                    find tt-mon where recid(tt-mon) = recatu1
                            exclusive.
                    delete tt-mon.
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
                    then run ltt-mon.p (input 0).
                    else run ltt-mon.p (input tt-mon.montcod).
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
                leave.
            end.
        end.
        */
        if not esqvazio
        then do:
            run frame-a.
        end.
/*        if esqregua
        then display esqcom1[esqpos1] with frame f-com1.
        else display esqcom2[esqpos2] with frame f-com2.*/
        recatu1 = recid(tt-mon).
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
    display tt-mon.montcod column-label "Codigo"
            tt-mon.montnom column-label "Montador"
            tt-mon.valor   column-label "Valor Rec."
            with frame frame-a 11 down centered color white/red row 6.
end procedure.

procedure color-message.
    color display message tt-mon.montcod 
                          tt-mon.montnom
                          tt-mon.valor
                          with frame frame-a.
end procedure.
procedure color-normal.
    color display normal tt-mon.montcod
                         tt-mon.montnom
                         tt-mon.valor
                         with frame frame-a.
end procedure.




procedure leitura . 
def input parameter par-tipo as char.
        
if par-tipo = "pri" 
then  
    if esqascend  
    then  
        find first tt-mon where true
                                                no-lock no-error.
    else  
        find last tt-mon  where true
                                                 no-lock no-error.
                                             
if par-tipo = "seg" or par-tipo = "down" 
then  
    if esqascend  
    then  
        find next tt-mon  where true
                                                no-lock no-error.
    else  
        find prev tt-mon   where true
                                                no-lock no-error.
             
if par-tipo = "up" 
then                  
    if esqascend   
    then   
        find prev tt-mon where true  
                                        no-lock no-error.
    else   
        find next tt-mon where true 
                                        no-lock no-error.
        
end procedure.

