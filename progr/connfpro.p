{admcab.i}

def input parameter p-clicod like clien.clicod.
def input parameter p-titnum like titulo.titnum.
def input parameter p-modcod like titulo.modcod.

def temp-table tt-pro
    field procod like produ.procod
    field numero like plani.numero
    field pladat like plani.pladat
    field pronom like produ.pronom
    field movqtm like movim.movqtm
    field movpc  like movim.movpc
    index i-pladat pladat numero.

if p-modcod = "CRE"
then do:
    for each contrato where contrato.contnum = int(p-titnum) no-lock:
        for each contnf where contnf.etbcod  = contrato.etbcod
                          and contnf.contnum = contrato.contnum no-lock:
            for each plani where plani.etbcod = contnf.etbcod
                             and plani.placod = contnf.placod no-lock:
                
                for each movim where movim.etbcod = plani.etbcod 
                                 and movim.placod = plani.placod 
                                 and movim.movtdc = plani.movtdc 
                                 and movim.movdat = plani.pladat no-lock:
                     
                    find produ where
                         produ.procod = movim.procod no-lock no-error.
        
                    find first tt-pro where
                               tt-pro.procod = movim.procod and
                               tt-pro.numero = plani.numero no-error.
                    if not avail tt-pro
                    then do:
                        create tt-pro.
                        assign tt-pro.procod = movim.procod
                               tt-pro.pronom = produ.pronom when avail produ
                               tt-pro.numero = plani.numero
                               tt-pro.pladat = plani.pladat.
                    end.
                    tt-pro.movqtm = tt-pro.movqtm + movim.movqtm.
                end.
            end.
        end.
    end.
    
end.                 
else do:

  for each plani where plani.movtdc = 5
                 and plani.desti = p-clicod no-lock:
                 
      for each movim where movim.etbcod = plani.etbcod
                     and movim.placod = plani.placod
                     and movim.movtdc = plani.movtdc
                     and movim.movdat = plani.pladat no-lock:
                     
        find produ where produ.procod = movim.procod no-lock no-error.
        
        find first tt-pro where tt-pro.procod = movim.procod
                            and tt-pro.numero = plani.numero no-error.
        if not avail tt-pro
        then do:
            create tt-pro.
            assign tt-pro.procod = movim.procod
                   tt-pro.pronom = produ.pronom when avail produ
                   tt-pro.numero = plani.numero
                   tt-pro.pladat = plani.pladat.
        end.
        tt-pro.movqtm = tt-pro.movqtm + movim.movqtm.
      end.
  end.    
end.



for each tt-pro where tt-pro.procod = 0.
    delete tt-pro.
end.

find first tt-pro no-error.
if not avail tt-pro
then do:
    message "Nenhum registro encontrado".
    leave.
end.    

def var recatu1         as recid.
def var recatu2         as recid.
def var reccont         as int.
def var esqpos1         as int.
def var esqpos2         as int.
def var esqregua        as log.
def var esqvazio        as log.
def var esqascend     as log initial yes.
def var esqcom1         as char format "x(12)" extent 5
    initial [" "," "," "," "," "].

def var esqcom2         as char format "x(12)" extent 5
            initial [" "," ","","",""].

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

def buffer btt-pro       for tt-pro.
def var vtt-pro         like tt-pro.procod.


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
        find tt-pro where recid(tt-pro) = recatu1 no-lock.
    if not available tt-pro
    then esqvazio = yes.
    else esqvazio = no.
    clear frame frame-a all no-pause.
    if not esqvazio
    then do:
        run frame-a.
    end.

    recatu1 = recid(tt-pro).
    if esqregua
    then color display message esqcom1[esqpos1] with frame f-com1.
    else color display message esqcom2[esqpos2] with frame f-com2.
    if not esqvazio
    then repeat:
        run leitura (input "seg").
        if not available tt-pro
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
            find tt-pro where recid(tt-pro) = recatu1 no-lock.

            status default
                if esqregua
                then esqhel1[esqpos1] + if esqpos1 > 1 and
                                           esqhel1[esqpos1] <> ""
                                        then  string(tt-pro.pronom)
                                        else ""
                else esqhel2[esqpos2] + if esqhel2[esqpos2] <> ""
                                        then string(tt-pro.pronom)
                                        else "".
            run color-message.
            choose field 
                tt-pro.pladat
                help "F4 = Retorna "
                tt-pro.numero
                tt-pro.procod 
                tt-pro.pronom  
                tt-pro.movqtm
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
                    if not avail tt-pro
                    then leave.
                    recatu1 = recid(tt-pro).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "page-up"
            then do:
                do reccont = 1 to frame-down(frame-a):
                    run leitura (input "up").
                    if not avail tt-pro
                    then leave.
                    recatu1 = recid(tt-pro).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "cursor-down"
            then do:
                run leitura (input "down").
                if not avail tt-pro
                then next.
                color display white/red
                    tt-pro.pladat
                    tt-pro.numero
                    tt-pro.procod 
                    tt-pro.pronom  
                    tt-pro.movqtm
                      with frame frame-a.
                if frame-line(frame-a) = frame-down(frame-a)
                then scroll with frame frame-a.
                else down with frame frame-a.
            end.
            if keyfunction(lastkey) = "cursor-up"
            then do:
                run leitura (input "up").
                if not avail tt-pro
                then next.
                color display white/red 
                        tt-pro.pladat
                        tt-pro.numero
                        tt-pro.procod 
                        tt-pro.pronom  
                        tt-pro.movqtm  
                        with frame frame-a.
                if frame-line(frame-a) = 1
                then scroll down with frame frame-a.
                else up with frame frame-a.
            end.
 
        if keyfunction(lastkey) = "end-error"
        then leave bl-princ.

        if keyfunction(lastkey) = "return" or esqvazio
        then do:
            form tt-pro
                 with frame f-tt-pro color black/cyan
                      centered side-label row 5 .
            hide frame frame-a no-pause.
            if esqregua
            then do:
                display caps(esqcom1[esqpos1]) @ esqcom1[esqpos1]
                        with frame f-com1.

                if esqcom1[esqpos1] = " Inclusao " or esqvazio
                then do with frame f-tt-pro on error undo.
                    create tt-pro.
                    update tt-pro.
                    recatu1 = recid(tt-pro).
                    leave.
                end.
                if esqcom1[esqpos1] = " Consulta " or
                   esqcom1[esqpos1] = " Exclusao " or
                   esqcom1[esqpos1] = " Alteracao "
                then do with frame f-tt-pro.
                    disp tt-pro.
                end.
                if esqcom1[esqpos1] = " Alteracao "
                then do with frame f-tt-pro on error undo.
                    find tt-pro where
                            recid(tt-pro) = recatu1 
                        exclusive.
                    update tt-pro.
                end.
                if esqcom1[esqpos1] = " Exclusao "
                then do with frame f-exclui  row 5 1 column centered
                        on error undo.
                    message "Confirma Exclusao de" tt-pro.pronom
                            update sresp.
                    if not sresp
                    then undo, leave.
                    find next tt-pro where true no-error.
                    if not available tt-pro
                    then do:
                        find tt-pro where recid(tt-pro) = recatu1.
                        find prev tt-pro where true no-error.
                    end.
                    recatu2 = if available tt-pro
                              then recid(tt-pro)
                              else ?.
                    find tt-pro where recid(tt-pro) = recatu1
                            exclusive.
                    delete tt-pro.
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
                    then run ltt-pro.p (input 0).
                    else run ltt-pro.p (input tt-pro.procod).
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
        recatu1 = recid(tt-pro).
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
display tt-pro.pladat
        help "F4 = Retorna "
        tt-pro.numero column-label "Num. NF"
        tt-pro.procod 
        tt-pro.pronom format "x(40)"
        tt-pro.movqtm
        with frame frame-a 11 down centered color white/red row 5
                   title " Notas Fiscais / Produtos " .
end procedure.

procedure color-message.
color display message
                tt-pro.pladat
                tt-pro.numero
                tt-pro.procod 
                tt-pro.pronom  
                tt-pro.movqtm  
                with frame frame-a.
end procedure.
procedure color-normal.
color display normal
              tt-pro.pladat
              tt-pro.numero
              tt-pro.procod 
              tt-pro.pronom  
              tt-pro.movqtm
              with frame frame-a.
end procedure.




procedure leitura . 
def input parameter par-tipo as char.
        
if par-tipo = "pri" 
then  
    if esqascend  
    then  
        find first tt-pro where true
                                                no-lock no-error.
    else  
        find last tt-pro  where true
                                                 no-lock no-error.
                                             
if par-tipo = "seg" or par-tipo = "down" 
then  
    if esqascend  
    then  
        find next tt-pro  where true
                                                no-lock no-error.
    else  
        find prev tt-pro   where true
                                                no-lock no-error.
             
if par-tipo = "up" 
then                  
    if esqascend   
    then   
        find prev tt-pro where true  
                                        no-lock no-error.
    else   
        find next tt-pro where true 
                                        no-lock no-error.
        
end procedure.
         
