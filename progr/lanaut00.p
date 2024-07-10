/*
*
*    lanaut.p    -    Esqueleto de Programacao    com esqvazio
*
*/
{admcab.i new}

def var vmodcod like modal.modcod.
def var varquivo as char.

def var recatu1         as recid.
def var recatu2         as recid.
def var reccont         as int.
def var esqpos1         as int.
def var esqpos2         as int.
def var esqregua        as log.
def var esqvazio        as log.
def var esqascend     as log initial yes.
def var esqcom1         as char format "x(12)" extent 5
    initial [" Inclusao "," Alteracao "," "," Consulta "," Listagem "].
def var esqcom2         as char format "x(12)" extent 5.
def var esqhel1         as char format "x(80)" extent 5
    initial [" Inclusao  de lanaut ",
             " Alteracao da lanaut ",
             " Exclusao  da lanaut ",
             " Consulta  da lanaut ",
             " Listagem  Geral de lanaut "].
def var esqhel2         as char format "x(12)" extent 5.

def buffer blanaut       for lanaut.

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
    if recatu1 = ?
    then
        run leitura (input "pri").
    else
        find lanaut where recid(lanaut) = recatu1 no-lock.
    if not available lanaut
    then esqvazio = yes.
    else esqvazio = no.
    clear frame frame-a all no-pause.
    if not esqvazio
    then do:
        run frame-a.
    end.

    recatu1 = recid(lanaut).
    if esqregua
    then color display message esqcom1[esqpos1] with frame f-com1.
    else color display message esqcom2[esqpos2] with frame f-com2.
    if not esqvazio
    then repeat:
        run leitura (input "seg").
        if not available lanaut
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
            find lanaut where recid(lanaut) = recatu1 no-lock.

            status default
                if esqregua
                then esqhel1[esqpos1] + if esqpos1 > 1 and
                                           esqhel1[esqpos1] <> ""
                                        then  string(lanaut.modcod)
                                        else ""
                else esqhel2[esqpos2] + if esqhel2[esqpos2] <> ""
                                        then string(lanaut.modcod)
                                        else "".
            run color-message.
            choose field lanaut.modcod help ""
                go-on(cursor-down cursor-up
                      cursor-left cursor-right
                      page-down   page-up
                      PF4 F4 ESC return P p) .
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
                    if not avail lanaut
                    then leave.
                    recatu1 = recid(lanaut).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "page-up"
            then do:
                do reccont = 1 to frame-down(frame-a):
                    run leitura (input "up").
                    if not avail lanaut
                    then leave.
                    recatu1 = recid(lanaut).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "cursor-down"
            then do:
                run leitura (input "down").
                if not avail lanaut
                then next.
                color display white/red lanaut.modcod with frame frame-a.
                if frame-line(frame-a) = frame-down(frame-a)
                then scroll with frame frame-a.
                else down with frame frame-a.
            end.
            if keyfunction(lastkey) = "cursor-up"
            then do:
                run leitura (input "up").
                if not avail lanaut
                then next.
                color display white/red lanaut.modcod with frame frame-a.
                if frame-line(frame-a) = 1
                then scroll down with frame frame-a.
                else up with frame frame-a.
            end.

        if keyfunction(lastkey) = "p"
        then do:
            pause 0.
            update vmodcod with frame fall
                    1 down centered row 10 side-label
                    overlay color message.
            find first blanaut where
                       blanaut.etbcod = ? and
                       blanaut.forcod = ? and
                       blanaut.modcod = vmodcod
                       no-lock no-error.
            if avail blanaut
            then recatu1 = recid(blanaut).     
            hide frame fall no-pause. 
            next bl-princ.     
        end.
  
        if keyfunction(lastkey) = "end-error"
        then leave bl-princ.

        if keyfunction(lastkey) = "return" or esqvazio
        then do:
            form with frame f-lanaut color black/cyan
                      centered side-label row 5.
            hide frame frame-a no-pause.
            display caps(esqcom1[esqpos1]) @ esqcom1[esqpos1]
                        with frame f-com1.

            if esqcom1[esqpos1] = " Inclusao " or esqvazio
            then do with frame f-lanaut on error undo.
                prompt-for lanaut.modcod label "Modalidade".
                find modal where modal.modcod = input lanaut.modcod NO-LOCK.
                if not avail modal
                then do.
                    message "Modalidade invalida" view-as alert-box.
                    undo.
                end.
                disp modal.modnom no-label.

                find first lanaut where lanaut.etbcod = ?
                                    and lanaut.forcod = ?
                                    and lanaut.modcod = modal.modcod
                                  no-lock no-error.
                if avail lanaut
                then do.
                    message "Modalidade ja cadastrada" view-as alert-box.
                    undo.
                end.

                prompt-for lanaut.lancod label "Cod. Contabil" .
                find tablan where tablan.lancod = input lanaut.lancod
                                  no-lock no-error.
                if not avail tablan
                then do:
                    message "Codigo contabil nao cadastrado".
                    pause.
                    undo, retry.
                end.
                display tablan.landes no-label
                    tablan.lanhis @ lanaut.lanhis.
                    
                create lanaut. 
                assign lanaut.etbcod = ?
                       lanaut.forcod = ?
                       lanaut.lancod = tablan.lancod
                       lanaut.lanhis = tablan.lanhis
                       lanaut.modcod = modal.modcod.
                recatu1 = recid(tablan).
                leave.
            end.

            if esqcom1[esqpos1] = " Consulta " or
               esqcom1[esqpos1] = " Exclusao " or
               esqcom1[esqpos1] = " Alteracao "
            then do with frame f-lanaut.
                find tablan of lanaut no-lock no-error.
                find modal of lanaut no-lock.
                find hispad where hispad.hiscod = lanaut.lanhis
                            no-lock no-error.
                display
                    lanaut.modcod colon 15 column-label "Mod" 
                    modal.modnom  no-label
                    lanaut.lancod colon 15 column-label "Conta"
                    tablan.landes when avail tablan
                    lanaut.lanhis colon 15 column-label "Hist" format ">>9"
                    hispad.hisdes no-label.
            end.

            if esqcom1[esqpos1] = " Alteracao "
            then do with frame f-lanaut on error undo.

                find lanaut where recid(lanaut) = recatu1 exclusive.

/***                
                update lanaut.modcod.
                find modal of lanaut no-lock no-error.
                if not avail modal
                then do.
                    message "Modalidade invalida" view-as alert-box.
                    undo.
                end.
                disp modal.modnom no-label.
***/

                update lanaut.lancod.
                find tablan where tablan.lancod = lanaut.lancod 
                        no-lock no-error.
                if not avail tablan
                then do:
                    message "Conta Contabil nao Cadastrada".
                    pause.
                    undo, retry.
                end.
                display tablan.landes.

                update lanaut.lanhis  
                       lanaut.comhis.

            end.

                if esqcom1[esqpos1] = " Exclusao "
                then do with frame f-exclui  row 5 1 column centered
                        on error undo.
                    message "Confirma Exclusao de" lanaut.modcod
                            update sresp.
                    if not sresp
                    then undo, leave.
                    find next lanaut where true no-error.
                    if not available lanaut
                    then do:
                        find lanaut where recid(lanaut) = recatu1.
                        find prev lanaut where true no-error.
                    end.
                    recatu2 = if available lanaut
                              then recid(lanaut)
                              else ?.
                    find lanaut where recid(lanaut) = recatu1
                            exclusive.
                    delete lanaut.
                    recatu1 = recatu2.
                    leave.
                end.

            if esqcom1[esqpos1] = " Listagem "
            then do with frame f-Lista:
                recatu2 = recatu1.
                varquivo = "/admcom/relat/lanaut." + string(time).  
                
                {mdad.i &Saida     = "value(varquivo)" 
                        &Page-Size = "0" 
                        &Cond-Var  = "110" 
                        &Page-Line = "0" 
                        &Nom-Rel   = ""lanaut"" 
                        &Nom-Sis   = """SISTEMA CONTABILIDADE""" 
                        &Tit-Rel   = """PLANO DE CONTAS"""
                        &Width     = "110"  
                        &Form      = "frame f-cabcab"}
                
                for each lanaut where lanaut.forcod = ? and
                                      lanaut.etbcod = ?
                                no-lock by lanaut.modcod:
                     
                    find tablan where tablan.lancod = lanaut.lancod 
                            no-lock no-error.
                    find modal where modal.modcod = lanaut.modcod
                            no-lock no-error.
                    
                    display lanaut.modcod column-label "Mod" 
                            modal.modnom format "x(30)" when avail modal
                            lanaut.lancod column-label "Cod.Cont."
                            tablan.landes format "x(30)" when avail tablan
                            lanaut.lanhis column-label "Hist" format ">>9"
                            lanaut.comhis format "x(25)"
                            with frame f-Lista down width 120
                                title "Fornecedor: " + string(lanaut.forcod).
                end.

                output close.
                run visurel.p(varquivo,"").
                
                recatu1 = recatu2.
                leave.
            end.
        end.
        if not esqvazio
        then do:
            run frame-a.
        end.
        if esqregua
        then display esqcom1[esqpos1] with frame f-com1.
        recatu1 = recid(lanaut).
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
    find tablan where tablan.lancod = lanaut.lancod no-lock no-error.
    find modal of lanaut no-lock.
    find hispad where hispad.hiscod = lanaut.lanhis no-lock no-error.
    display
        lanaut.modcod column-label "Mod" 
        modal.modnom format "x(5)" no-label
        lanaut.lancod column-label "Conta"
        tablan.landes format "x(30)" when avail tablan
        lanaut.lanhis column-label "Hist" format ">>9"
        hispad.hisdes format "x(25)"
        with frame frame-a 11 down centered color white/red row 5.
end procedure.


procedure color-message.
color display message
        lanaut.modcod
        with frame frame-a.
end procedure.


procedure color-normal.
color display normal
        lanaut.modcod
        with frame frame-a.
end procedure.


procedure leitura . 
def input parameter par-tipo as char.
        
if par-tipo = "pri" 
then  
    if esqascend  
    then  
        find first lanaut where lanaut.forcod = ? no-lock no-error.
    else  
        find last lanaut  where lanaut.forcod = ? no-lock no-error.
                                             
if par-tipo = "seg" or par-tipo = "down" 
then  
    if esqascend  
    then  
        find next lanaut  where lanaut.forcod = ? no-lock no-error.
    else  
        find prev lanaut   where lanaut.forcod = ? no-lock no-error.
             
if par-tipo = "up" 
then                  
    if esqascend   
    then   
        find prev lanaut where lanaut.forcod = ?   no-lock no-error.
    else   
        find next lanaut where lanaut.forcod = ?  no-lock no-error.
        
end procedure.
         
