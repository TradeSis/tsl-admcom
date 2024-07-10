def var varquivo as char.

def shared temp-table ttser 
    field etbcod like plani.etbcod
    field cxacod like plani.cxacod
    field pladat like plani.pladat
    field ventot like plani.platot
    field situacao as char
    index serial etbcod
                 cxacod
                 pladat.

def var recatu1         as recid.
def var recatu2         as recid.
def var reccont         as int.
def var esqpos1         as int.
def var esqpos2         as int.
def var esqregua        as log.
def var esqvazio        as log.
def var esqascend     as log initial yes.

def var esqcom1         as char format "x(12)" extent 5
    initial [" Imprimir "," "," "," "," "].
    
def var esqcom2         as char format "x(12)" extent 5
            initial [" "," ","","",""].

def var esqhel1         as char format "x(80)" extent 5
    initial [" ", " ", " ", " ", " "].
    
def var esqhel2         as char format "x(12)" extent 5
   initial ["  ", " ", " ", " ", " "].
   

{admcab.i}

def buffer bttser      for ttser.
def var vttser         like ttser.etbcod.


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
        find ttser where recid(ttser) = recatu1 no-lock.
    if not available ttser
    then esqvazio = yes.
    else esqvazio = no.
    clear frame frame-a all no-pause.
    if not esqvazio
    then do:
        run frame-a.
    end.

    recatu1 = recid(ttser).
    if esqregua
    then color display message esqcom1[esqpos1] with frame f-com1.
    else color display message esqcom2[esqpos2] with frame f-com2.
    if not esqvazio
    then repeat:
        run leitura (input "seg").
        if not available ttser
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
            find ttser where recid(ttser) = recatu1 no-lock.

            status default
                if esqregua
                then esqhel1[esqpos1] + if esqpos1 > 1 and
                                           esqhel1[esqpos1] <> ""
                                        then  string(ttser.etbcod)
                                        else ""
                else esqhel2[esqpos2] + if esqhel2[esqpos2] <> ""
                                        then string(ttser.etbcod)
                                        else "".
            run color-message.
            choose field 
                ttser.etbcod 
                          ttser.cxacod  
                          ttser.pladat   
                          ttser.ventot 
                          ttser.situacao
                help ""
                go-on(cursor-down cursor-up
                      cursor-left cursor-right
                      page-down   page-up
                      tab PF4 F4 ESC return) color white/black.
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
                    if not avail ttser
                    then leave.
                    recatu1 = recid(ttser).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "page-up"
            then do:
                do reccont = 1 to frame-down(frame-a):
                    run leitura (input "up").
                    if not avail ttser
                    then leave.
                    recatu1 = recid(ttser).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "cursor-down"
            then do:
                run leitura (input "down").
                if not avail ttser
                then next.
                color display white/red ttser.etbcod 
                          ttser.cxacod  
                          ttser.pladat   
                          ttser.ventot 
                          ttser.situacao
                          with frame frame-a.
                if frame-line(frame-a) = frame-down(frame-a)
                then scroll with frame frame-a.
                else down with frame frame-a.
            end.
            if keyfunction(lastkey) = "cursor-up"
            then do:
                run leitura (input "up").
                if not avail ttser
                then next.
                color display white/red ttser.etbcod 
                          ttser.cxacod  
                          ttser.pladat   
                          ttser.ventot 
                          ttser.situacao
                         with frame frame-a.
                if frame-line(frame-a) = 1
                then scroll down with frame frame-a.
                else up with frame frame-a.
            end.
 
        if keyfunction(lastkey) = "end-error"
        then leave bl-princ.

        if keyfunction(lastkey) = "return"
        then do:
            form ttser.etbcod 
                 ttser.cxacod  
                 ttser.pladat   
                 ttser.ventot 
                 ttser.situacao

                 with frame f-ttser color black/cyan
                      centered side-label row 5 .
            hide frame frame-a no-pause.
            if esqregua
            then do:
                display caps(esqcom1[esqpos1]) @ esqcom1[esqpos1]
                        with frame f-com1.

                if esqcom1[esqpos1] = " Imprimir "
                then do with frame f-ttser on error undo.

                    message "Confirma emissao do Relatorio? " update sresp.
                    if sresp
                    then do:

                        if opsys = "UNIX"
                        then 
                            varquivo = "/admcom/relat/rserial" + string(time).
                        else 
                            varquivo = "l:\relat\rserial" + string(time).

                        {mdad.i
                            &Saida     = "value(varquivo)"
                            &Page-Size = "0"
                            &Cond-Var  = "80"
                            &Page-Line = "0"
                            &Nom-Rel   = ""serial2a""
                            &Nom-Sis   = """SISTEMA COMERCIAL"""
                            &Tit-Rel   = """CONTROLE DE REDUCOES Z"""
                            &Width     = "80"
                            &Form      = "frame f-cabcab"}

                
                            for each ttser by ttser.etbcod
                                           by ttser.cxacod
                                           by ttser.pladat:

                                
                                disp ttser.etbcod   column-label "Filial"
                                     ttser.cxacod   column-label "Caixa"
                                     ttser.pladat   column-label "Data"
                                     ttser.ventot   column-label "Tot.Venda"
                                     ttser.situacao column-label "Situacao" 
                                     format "x(15)"
                                     with frame fttser down.
                            
                            end.
                            
                        output close.
                        
                        if opsys = "UNIX"
                        then do:
                            run visurel.p (input varquivo, input "").
                        end.
                        else do:
                            {mrod.i}.
                        end.    
                    end.
                    recatu1 = ?.
                end.
                if esqcom1[esqpos1] = " Consulta " or
                   esqcom1[esqpos1] = " Exclusao " or
                   esqcom1[esqpos1] = " Alteracao "
                then do with frame f-ttser.
                    disp ttser.
                end.
                if esqcom1[esqpos1] = " Alteracao "
                then do with frame f-ttser on error undo.
                    find ttser where
                            recid(ttser) = recatu1 
                        exclusive.
                    update ttser.
                end.
                if esqcom1[esqpos1] = " Exclusao "
                then do with frame f-exclui  row 5 1 column centered
                        on error undo.
                    message "Confirma Exclusao de" ttser.etbcod
                            update sresp.
                    if not sresp
                    then undo, leave.
                    find next ttser where true no-error.
                    if not available ttser
                    then do:
                        find ttser where recid(ttser) = recatu1.
                        find prev ttser where true no-error.
                    end.
                    recatu2 = if available ttser
                              then recid(ttser)
                              else ?.
                    find ttser where recid(ttser) = recatu1
                            exclusive.
                    delete ttser.
                    recatu1 = recatu2.
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
        if not esqvazio
        then do:
            run frame-a.
        end.
        if esqregua
        then display esqcom1[esqpos1] with frame f-com1.
        else display esqcom2[esqpos2] with frame f-com2.
        recatu1 = recid(ttser).
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
    display ttser.etbcod   column-label "Filial"
            ttser.cxacod   column-label "Caixa"
            ttser.pladat   column-label "Data"
            ttser.ventot   column-label "Tot.Venda"
            ttser.situacao column-label "Situacao" format "x(15)"
            with frame frame-a 11 down centered color white/red row 5.
end procedure.

procedure color-message.
    color display message ttser.etbcod 
                          ttser.cxacod  
                          ttser.pladat   
                          ttser.ventot 
                          ttser.situacao
                          with frame frame-a.
end procedure.
procedure color-normal.
    color display normal ttser.etbcod 
                         ttser.cxacod  
                         ttser.pladat   
                         ttser.ventot 
                         ttser.situacao
                         with frame frame-a.
end procedure.

procedure leitura.
def input parameter par-tipo as char.
        
if par-tipo = "pri" 
then  
    if esqascend  
    then  
        find first ttser where true
                                                no-lock no-error.
    else  
        find last ttser  where true
                                                 no-lock no-error.
                                             
if par-tipo = "seg" or par-tipo = "down" 
then  
    if esqascend  
    then  
        find next ttser  where true
                                                no-lock no-error.
    else  
        find prev ttser   where true
                                                no-lock no-error.
             
if par-tipo = "up" 
then                  
    if esqascend   
    then   
        find prev ttser where true  
                                        no-lock no-error.
    else   
        find next ttser where true 
                                        no-lock no-error.
        
end procedure.
         
