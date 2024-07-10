/*
*
*    profissao.p    -    Esqueleto de Programacao    com esqvazio
*
*/

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
    initial [" Inclusao "," Alteracao ","  Filtro","  Replica",""].
def var esqcom2         as char format "x(12)" extent 5
            initial [" "," ","","",""].
def var esqhel1         as char format "x(80)" extent 5
    initial [" Inclusao  de profissao ",
             " Alteracao da profissao ",
             " "].
def var esqhel2         as char format "x(12)" extent 5.

def buffer bprofissao       for profissao.
def buffer brendaprofi for rendaprofi.
def temp-table tt-rendaprofi like rendaprofi.

def var fil-ori like estab.etbcod.
def var fil-des like estab.etbcod.


form rendaprofi.etbcod
     rendaprofi.codprof column-label "Codigo"
     profissao.profdesc column-label "Descrição"
     rendaprofi.valrenda column-label "Renda"
     with frame frame-a 11 down centered row 5
     .

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

def new global shared var f-etbcod as int init ?.
def new global shared var f-codprof as int init ?.

bl-princ:
repeat:
    hide frame frame-a no-pause.
    clear frame frame-a all.
    disp esqcom1 with frame f-com1.
    disp esqcom2 with frame f-com2.

    if recatu1 = ?
    then
        run leitura (input "pri").
    else
        find rendaprofi where recid(rendaprofi) = recatu1 no-lock.
    if not available rendaprofi
    then esqvazio = yes.
    else esqvazio = no.
    clear frame frame-a all no-pause.
    find first profissao where
               profissao.codprof = rendaprofi.codprof
               no-lock no-error.
    if not esqvazio
    then do:
        run frame-a.
    end.

    recatu1 = recid(rendaprofi).
    if esqregua
    then color display message esqcom1[esqpos1] with frame f-com1.
    else color display message esqcom2[esqpos2] with frame f-com2.
    if not esqvazio
    then repeat:
        run leitura (input "seg").
        if not available rendaprofi
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
            find rendaprofi where recid(rendaprofi) = recatu1 no-lock.
            find first profissao where
               profissao.codprof = rendaprofi.codprof
               no-lock no-error.
 
             status default
                if esqregua
                then esqhel1[esqpos1] + if esqpos1 > 1 and
                                           esqhel1[esqpos1] <> ""
                                        then string(profissao.profdesc)
                                        else ""
                else esqhel2[esqpos2] + if esqhel2[esqpos2] <> ""
                                        then string(profissao.profdesc)
                                        else "".
            run color-message.
            choose field rendaprofi.codprof help ""
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
                    if not avail rendaprofi
                    then leave.
                    recatu1 = recid(rendaprofi).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "page-up"
            then do:
                do reccont = 1 to frame-down(frame-a):
                    run leitura (input "up").
                    if not avail rendaprofi
                    then leave.
                    recatu1 = recid(rendaprofi).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "cursor-down"
            then do:
                run leitura (input "down").
                if not avail rendaprofi
                then next.
                color display white/red rendaprofi.codprof with frame frame-a.
                if frame-line(frame-a) = frame-down(frame-a)
                then scroll with frame frame-a.
                else down with frame frame-a.
            end.
            if keyfunction(lastkey) = "cursor-up"
            then do:
                run leitura (input "up").
                if not avail rendaprofi
                then next.
                color display white/red rendaprofi.codprof with frame frame-a.
                if frame-line(frame-a) = 1
                then scroll down with frame frame-a.
                else up with frame frame-a.
            end.
 
        if keyfunction(lastkey) = "end-error"
        then leave bl-princ.

        if keyfunction(lastkey) = "return" or esqvazio
        then do:
            form rendaprofi.etbcod
                 rendaprofi.codprof label "Codigo" 
                 profissao.profdesc format "x(50)" label "Descrição"
                 rendaprofi.valrenda   label "Renda"
                 with frame f-rendaprofi color black/cyan
                      centered side-label row 5 1 column.
            hide frame frame-a no-pause.
            if esqregua
            then do:
                display caps(esqcom1[esqpos1]) @ esqcom1[esqpos1]
                        with frame f-com1.

                if esqcom1[esqpos1] = " Inclusao " or esqvazio
                then do with frame f-rendaprofi on error undo.
                    prompt-for rendaprofi.etbcod.
                    prompt-for rendaprofi.codprof.
                    find profissao where
                         profissao.codprof = input rendaprofi.codprof
                         no-lock no-error.
                    if not avail profissao then undo.    
                    disp profissao.profdesc.
                    prompt-for rendaprofi.valrenda.
                    if input rendaprofi.valrenda = 0
                    then undo. 
                    create rendaprofi.
                    assign
                        rendaprofi.etbcod  = input rendaprofi.etbcod
                        rendaprofi.codprof = input rendaprofi.codprof
                        rendaprofi.valrenda = input rendaprofi.valrenda
                        rendaprofi.datexp = today
                        rendaprofi.datcad = today
                        .
                    
                    recatu1 = recid(rendaprofi).
                    leave.
                end.
                if esqcom1[esqpos1] = " Exclusao " or
                   esqcom1[esqpos1] = " Alteracao "
                then do with frame f-rendaprofi.
                    disp rendaprofi.etbcod
                         rendaprofi.codprof
                         profissao.profdesc.
                end.
                if esqcom1[esqpos1] = " Alteracao "
                then do with frame f-rendaprofi on error undo.
                    find rendaprofi where
                            recid(rendaprofi) = recatu1 
                        exclusive.
                    update rendaprofi.valrenda.
                end.
                if esqcom1[esqpos1] = " Exclusao "
                then do with frame f-exclui  row 5 1 column centered
                        on error undo.
                    /**
                    message "Confirma Exclusao?" update sresp.
                    if not sresp
                    then undo, leave.
                    find next rendaprofi where true no-error.
                    if not available rendaprofi
                    then do:
                        find rendaprofi where recid(rendaprofi) = recatu1.
                        find prev rendaprofi where true no-error.
                    end.
                    recatu2 = if available rendaprofi
                              then recid(rendaprofi)
                              else ?.
                    find rendaprofi where recid(rendaprofi) = recatu1
                            exclusive.
                    delete rendaprofi.
                    */
                    recatu1 = recatu2.
                    leave.
                end.
                if esqcom1[esqpos1] = "  Replica "
                then do on error undo, retry with frame f-replica
                                1 down centered row 10 side-label
                                overlay :
                    update fil-ori label "Filial origem"
                           fil-des label "Filial destino"
                            validate(fil-des > 0,"Informe a filial destino.") 
                           .
                    
                    sresp = no.
                    message "Confirma replicar informações de renda?"
                            update sresp.

                    if sresp 
                    then do on error undo:
                        FOR EACH tt-rendaprofi: DELETE tt-rendaprofi. END.
                        for each rendaprofi where
                                 rendaprofi.etbcod = fil-ori no-lock:
                            create tt-rendaprofi.
                            buffer-copy rendaprofi to tt-rendaprofi.
                        end.
                        for each tt-rendaprofi:
                            tt-rendaprofi.etbcod = fil-des.
                        end.
                        for each tt-rendaprofi:
                            find first brendaprofi where
                               brendaprofi.etbcod =  tt-rendaprofi.etbcod  and
                               brendaprofi.codprof = tt-rendaprofi.codprof and
                               brendaprofi.datcad  = tt-rendaprofi.datcad
                               no-error.
                            if not avail brendaprofi
                            then create brendaprofi.
                            buffer-copy tt-rendaprofi to brendaprofi.
                        end.
                    end.                 

                    leave.
                end.
                if esqcom1[esqpos1] = "  Filtro"
                then do:
                    update f-etbcod label "Filial"
                           f-codprof label "Profissao"
                            with frame f-filtro
                            overlay centered row 9.
                    recatu1 = ?.
                    next bl-princ.        
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
        if not esqvazio
        then do:
            run frame-a.
        end.
        if esqregua
        then display esqcom1[esqpos1] with frame f-com1.
        else display esqcom2[esqpos2] with frame f-com2.
        recatu1 = recid(rendaprofi).
    end.
    if keyfunction(lastkey) = "end-error"
    then do:
        view frame fc1.
        view frame fc2.
    end.
end.
f-etbcod = ?.
f-codprof = ?.
hide frame f-com1  no-pause.
hide frame f-com2  no-pause.
hide frame frame-a no-pause.


procedure frame-a.
find first profissao where
               profissao.codprof = rendaprofi.codprof
               no-lock no-error.
 
display rendaprofi.etbcod
        rendaprofi.codprof
        profissao.profdesc format "x(50)"
        rendaprofi.valrenda
        with frame frame-a 11 down centered row 5.
end procedure.
procedure color-message.
color display message
        rendaprofi.etbcod
        rendaprofi.codprof
        profissao.profdesc format "x(50)"
        rendaprofi.valrenda
        with frame frame-a.
end procedure.

procedure color-normal.
color display normal
        rendaprofi.etbcod
        rendaprofi.codprof
        profissao.profdesc
        rendaprofi.valrenda
        with frame frame-a.
end procedure.

procedure leitura . 
def input parameter par-tipo as char.
        
if par-tipo = "pri" 
then  
    if esqascend  
    then  
        find first rendaprofi where 
                (if f-etbcod <> ?
                 then rendaprofi.etbcod = f-etbcod else true) and
                (if f-codprof <> ?
                 then rendaprofi.codprof = f-codprof else true)
                                                no-lock no-error.
    else  
        find last rendaprofi where 
                (if f-etbcod <> ?
                 then rendaprofi.etbcod = f-etbcod else true) and
                (if f-codprof <> ?
                 then rendaprofi.codprof = f-codprof else true)
                                                no-lock no-error.
                                             
if par-tipo = "seg" or par-tipo = "down" 
then  
    if esqascend  
    then  
        find next rendaprofi where 
                (if f-etbcod <> ?
                 then rendaprofi.etbcod = f-etbcod else true) and
                (if f-codprof <> ?
                 then rendaprofi.codprof = f-codprof else true)
                                                no-lock no-error.

    else  
        find prev rendaprofi where 
                (if f-etbcod <> ?
                 then rendaprofi.etbcod = f-etbcod else true) and
                (if f-codprof <> ?
                 then rendaprofi.codprof = f-codprof else true)
                                                no-lock no-error.
             
if par-tipo = "up" 
then                  
    if esqascend   
    then   
        find prev rendaprofi where 
                (if f-etbcod <> ?
                 then rendaprofi.etbcod = f-etbcod else true) and
                (if f-codprof <> ?
                 then rendaprofi.codprof = f-codprof else true)
                                                no-lock no-error.

    else   
        find next rendaprofi where 
                (if f-etbcod <> ?
                 then rendaprofi.etbcod = f-etbcod else true) and
                (if f-codprof <> ?
                 then rendaprofi.codprof = f-codprof else true)
                                                no-lock no-error.

        
end procedure.
         
