def buffer bprodu for produ.

def var recatu1         as recid.
def var recatu2         as recid.
def var reccont         as int.
def var esqpos1         as int.
def var esqpos2         as int.
def var esqregua        as log.
def var esqvazio        as log.
def var esqascend       as log initial yes.
def var esqcom1         as char format "x(12)" extent 5
    initial [" Inclusao "," Alteracao "," Consulta "," "," "].
def var esqcom2         as char format "x(12)" extent 5
            initial [" "," ","","",""].

def var esqhel1         as char format "x(80)" extent 5
    initial [" Inclusao  ",
             " Alteracao ",
             " Consulta  ",
             "   ",
             "   "].
             
def var esqhel2         as char format "x(12)" extent 5
   initial ["  ",
            " ",
            " ",
            " ",
            " "].

{admcab.i}

def buffer bbonusviv       for  bonusviv.
def var vbonusviv          like bonusviv.tipviv.


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
        find bonusviv where recid(bonusviv) = recatu1 no-lock.

    if not available bonusviv
    then esqvazio = yes.
    else esqvazio = no.

    clear frame frame-a all no-pause.
    if not esqvazio
    then do:
        run frame-a.
    end.

    recatu1 = recid(bonusviv).
    if esqregua
    then color display message esqcom1[esqpos1] with frame f-com1.
    else color display message esqcom2[esqpos2] with frame f-com2.
    if not esqvazio
    then repeat:
        run leitura (input "seg").
        if not available bonusviv
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
            find bonusviv where recid(bonusviv) = recatu1 no-lock.

            status default
                if esqregua
                then esqhel1[esqpos1] + if esqpos1 > 1 and
                                           esqhel1[esqpos1] <> ""
                                        then  string(bonusviv.tipviv)
                                        else ""
                else esqhel2[esqpos2] + if esqhel2[esqpos2] <> ""
                                        then string(bonusviv.tipviv)
                                        else "".
            run color-message.
            choose field
                bonusviv.tipviv
                bonusviv.codviv
                bonusviv.procod
                produ.pronom
                bonusviv.probonus
                bprodu.pronom
                bonusviv.exportado
                help "" go-on(cursor-down cursor-up
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
                    if not avail bonusviv
                    then leave.
                    recatu1 = recid(bonusviv).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "page-up"
            then do:
                do reccont = 1 to frame-down(frame-a):
                    run leitura (input "up").
                    if not avail bonusviv
                    then leave.
                    recatu1 = recid(bonusviv).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "cursor-down"
            then do:
                run leitura (input "down").
                if not avail bonusviv
                then next.
                color display white/red 
                        bonusviv.tipviv
                        bonusviv.codviv
                        bonusviv.procod
                        produ.pronom
                        bonusviv.probonus
                        bprodu.pronom
                        bonusviv.exportado column-label "Situacao"
                        with frame frame-a.
                if frame-line(frame-a) = frame-down(frame-a)
                then scroll with frame frame-a.
                else down with frame frame-a.
            end.
            if keyfunction(lastkey) = "cursor-up"
            then do:
                run leitura (input "up").
                if not avail bonusviv
                then next.
                color display white/red 
                    bonusviv.tipviv
                    bonusviv.codviv
                    bonusviv.procod
                    produ.pronom
                    bonusviv.probonus
                    bprodu.pronom
                    bonusviv.exportado column-label "Situacao"
                with frame frame-a.
                if frame-line(frame-a) = 1
                then scroll down with frame frame-a.
                else up with frame frame-a.
            end.
 
        if keyfunction(lastkey) = "end-error"
        then leave bl-princ.

        if keyfunction(lastkey) = "return" or esqvazio
        then do:
            form bonusviv.tipviv   label "Pro"
                 bonusviv.codviv   label "Plano"
                 bonusviv.procod   label "Produto"
                 bonusviv.probonus label "Bonus"
                 bonusviv.exportado label "Situacao"
                 with frame f-bonusviv color black/cyan
                      centered side-label row 5 .
            hide frame frame-a no-pause.
            if esqregua
            then do:
                display caps(esqcom1[esqpos1]) @ esqcom1[esqpos1]
                        with frame f-com1.

                if esqcom1[esqpos1] = " Inclusao " or esqvazio
                then do with frame f-bonusviv on error undo.
                    create bonusviv.

            update bonusviv.tipviv   label "Pro"
                    bonusviv.codviv   label "Plano"
                    bonusviv.procod   label "Produto"
                    /*produ.pronom format "x(20)" column-label "Descricao"*/
                    bonusviv.probonus label "Bonus"
                    /*bprodu.pronom format "x(20)" column-label "Descricao"*/.
                    
                    
                    recatu1 = recid(bonusviv).
                    leave.
                end.
                if esqcom1[esqpos1] = " Consulta " or
                   esqcom1[esqpos1] = " Exclusao " or
                   esqcom1[esqpos1] = " Alteracao "
                then do with frame f-bonusviv.
                    disp bonusviv.tipviv   label "Pro"
                        bonusviv.codviv   label "Plano"
                        bonusviv.procod   label "Produto"
                        bonusviv.probonus label "Bonus"
                        bonusviv.exportado label "Situacao".
                end.
                
                if esqcom1[esqpos1] = " Alteracao "
                then do with frame f-bonusviv on error undo.
                    find bonusviv where
                            recid(bonusviv) = recatu1 
                        exclusive.
                    update bonusviv.exportado
                           label "Situacao"
                           format "Ativo/Inativo"
                           help "[A] Ativo  [I] Inativo".
                end.
                if esqcom1[esqpos1] = " Exclusao "
                then do with frame f-exclui  row 5 1 column centered
                        on error undo.
                    message "Confirma Exclusao de" bonusviv.tipviv
                            update sresp.
                    if not sresp
                    then undo, leave.
                    find next bonusviv where true no-error.
                    if not available bonusviv
                    then do:
                        find bonusviv where recid(bonusviv) = recatu1.
                        find prev bonusviv where true no-error.
                    end.
                    recatu2 = if available bonusviv
                              then recid(bonusviv)
                              else ?.
                    find bonusviv where recid(bonusviv) = recatu1
                            exclusive.
                    delete bonusviv.
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
                    then run lbonusviv.p (input 0).
                    else run lbonusviv.p (input bonusviv.tipviv).
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
        recatu1 = recid(bonusviv).
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
    find produ where produ.procod = bonusviv.procod no-lock no-error.
    find bprodu where bprodu.procod = bonusviv.probonus no-lock no-error.
        
    display bonusviv.tipviv   column-label "Pro"
            bonusviv.codviv   column-label "Plano"
            bonusviv.procod   column-label "Produto"
            produ.pronom format "x(20)" column-label "Descricao"
            bonusviv.probonus column-label "Bonus"
            bprodu.pronom format "x(20)" column-label "Descricao"
            bonusviv.exportado column-label "Situacao" format "Ativo/Inativo"
            with frame frame-a 11 down centered color white/red row 5.
            
end procedure.

procedure color-message.
    find produ where produ.procod = bonusviv.procod no-lock no-error.
    find bprodu where bprodu.procod = bonusviv.probonus no-lock no-error.

    color display message
            bonusviv.tipviv   column-label "Pro"
            bonusviv.codviv   column-label "Plano"
            bonusviv.procod   column-label "Produto"
            produ.pronom format "x(20)" column-label "Descricao"
            bonusviv.probonus column-label "Bonus"
            bprodu.pronom format "x(20)" column-label "Descricao"
            bonusviv.exportado column-label "Situacao" format "Ativo/Inativo"
            with frame frame-a.
end procedure.

procedure color-normal.
    find produ where produ.procod = bonusviv.procod no-lock no-error.
    find bprodu where bprodu.procod = bonusviv.probonus no-lock no-error.
    
    color display normal
            bonusviv.tipviv   column-label "Pro"
            bonusviv.codviv   column-label "Plano"
            bonusviv.procod   column-label "Produto"
            produ.pronom format "x(20)" column-label "Descricao"
            bonusviv.probonus column-label "Bonus"
            bprodu.pronom format "x(20)" column-label "Descricao"
            bonusviv.exportado column-label "Situacao" format "Ativo/Inativo"
            with frame frame-a.
end procedure.




procedure leitura.
def input parameter par-tipo as char.
        
if par-tipo = "pri" 
then  
    if esqascend  
    then  
        find first bonusviv where true
                                                no-lock no-error.
    else  
        find last bonusviv  where true
                                                 no-lock no-error.
                                             
if par-tipo = "seg" or par-tipo = "down" 
then  
    if esqascend  
    then  
        find next bonusviv  where true
                                                no-lock no-error.
    else  
        find prev bonusviv   where true
                                                no-lock no-error.
             
if par-tipo = "up" 
then                  
    if esqascend   
    then   
        find prev bonusviv where true  
                                        no-lock no-error.
    else   
        find next bonusviv where true 
                                        no-lock no-error.
        
end procedure.
         
