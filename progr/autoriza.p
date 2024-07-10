/*
*
*    Esqueletao de Programacao
*
*/
{admcab.i}


def var varq as char.
def temp-table tt-livre
    field procod like produ.procod
    field fincod like finan.fincod
    field preco  like estoq.estvenda
    field pronom like produ.pronom
        index ind-1 pronom.
def var vprocod like produ.procod.
def var vfincod like finan.fincod.
def var vpreco  like estoq.estvenda.

def var varq-auto as char.

if opsys = "UNIX"
then varq-auto = "/admcom/progr/autoriza.txt".
else varq-auto = "l:\progr\autoriza.txt".

input from value(varq-auto).

repeat:
    
    import varq.
                     
    find first tt-livre where tt-livre.procod = int(substring(varq,1,6)) and
                              tt-livre.fincod = int(substring(varq,7,2))
                                        no-error. 
    if not avail tt-livre
    then do:
        
        create tt-livre.
        assign tt-livre.procod = int(substring(varq,1,6))
               tt-livre.fincod = int(substring(varq,7,2)) 
               tt-livre.preco  = dec(substring(varq,9,9)). 
        find produ where produ.procod = tt-livre.procod no-lock no-error.
        if avail produ
        then tt-livre.pronom = produ.pronom.
               
    end.

    
end.
input close.
for each tt-livre.
    find produ where produ.procod = tt-livre.procod no-lock no-error.
    if not avail produ
    then delete tt-livre.
end.

def var reccont         as int.
def var vinicio         as log.
def var recatu1         as recid.
def var recatu2         as recid.
def var esqpos1         as int.
def var esqpos2         as int.
def var esqregua        as log.
def var esqcom1         as char format "x(12)" extent 3
            initial ["Inclusao","Exclusao","Procura"].
def var esqcom2         as char format "x(12)" extent 5
            initial ["","","","",""].


def buffer btt-livre       for tt-livre.


    form
        esqcom1
            with frame f-com1
                 row 3 no-box no-labels side-labels centered.
    form
        esqcom2
            with frame f-com2
                 row screen-lines no-box no-labels side-labels column 1.
    esqregua  = yes.
    esqpos1  = 1.
    esqpos2  = 1.

bl-princ:
repeat:

    disp esqcom1 with frame f-com1.
    disp esqcom2 with frame f-com2.
    if recatu1 = ?
    then
        find first tt-livre where
            true no-error.
    else
        find tt-livre where recid(tt-livre) = recatu1.
    vinicio = yes.
    if not available tt-livre
    then do:
        message "Cadastro de tt-livreidades de Tit. Vazio".
        message "Deseja Incluir " update sresp.
        if not sresp
        then undo.
        do with frame f-inclui1  overlay row 6 1 column centered.
                create tt-livre.
                update tt-livre.procod
                       tt-livre.fincod.
          vinicio = no.
        end.
    end.
    clear frame frame-a all no-pause.

    find produ where produ.procod = tt-livre.procod no-lock no-error.
    display
        tt-livre.procod
        produ.pronom when avail produ
        tt-livre.fincod column-label "Plano"
        tt-livre.preco  column-label "Preco" format ">>,>>9.99"
            with frame frame-a 13 down centered title "B R I N D E".

    recatu1 = recid(tt-livre).
    color display message
        esqcom1[esqpos1]
            with frame f-com1.
    repeat:
        find next tt-livre where
                true.
        if not available tt-livre
        then leave.
        if frame-line(frame-a) = frame-down(frame-a)
        then leave.
        if vinicio
        then down
            with frame frame-a.
        find produ where produ.procod = tt-livre.procod no-lock no-error.
        display
            tt-livre.procod
            produ.pronom when avail produ
            tt-livre.fincod
            tt-livre.preco
                with frame frame-a.
    end.
    up frame-line(frame-a) - 1 with frame frame-a.

    repeat with frame frame-a:

        find tt-livre where recid(tt-livre) = recatu1.

        choose field tt-livre.procod
            go-on(cursor-down cursor-up
                  cursor-left cursor-right
                  page-down page-up
                  tab PF4 F4 ESC return).
        if keyfunction(lastkey) = "TAB"
        then do:
            if esqregua
            then do:
                color display normal
                    esqcom1[esqpos1]
                    with frame f-com1.
                color display message
                    esqcom2[esqpos2]
                    with frame f-com2.
            end.
            else do:
                color display normal
                    esqcom2[esqpos2]
                    with frame f-com2.
                color display message
                    esqcom1[esqpos1]
                    with frame f-com1.
            end.
            esqregua = not esqregua.
        end.
        if keyfunction(lastkey) = "cursor-right"
        then do:
            if esqregua
            then do:
                color display normal
                    esqcom1[esqpos1]
                    with frame f-com1.
                esqpos1 = if esqpos1 = 3
                          then 3
                          else esqpos1 + 1.
                color display messages
                    esqcom1[esqpos1]
                    with frame f-com1.
            end.
            else do:
                color display normal
                    esqcom2[esqpos2]
                    with frame f-com2.
                esqpos2 = if esqpos2 = 5
                          then 5
                          else esqpos2 + 1.
                color display messages
                    esqcom2[esqpos2]
                    with frame f-com2.
            end.
            next.
        end.

        if keyfunction(lastkey) = "page-down"
        then do:
            do reccont = 1 to frame-down(frame-a):
                find next tt-livre where true no-error.
                if not avail tt-livre
                then leave.
                recatu1 = recid(tt-livre).
            end.
            leave.
        end.
        if keyfunction(lastkey) = "page-up"
        then do:
            do reccont = 1 to frame-down(frame-a):
                find prev tt-livre where true no-error.
                if not avail tt-livre
                then leave.
                recatu1 = recid(tt-livre).
            end.
            leave.
        end.


        if keyfunction(lastkey) = "cursor-left"
        then do:
            if esqregua
            then do:
                color display normal
                    esqcom1[esqpos1]
                    with frame f-com1.
                esqpos1 = if esqpos1 = 1
                          then 1
                          else esqpos1 - 1.
                color display messages
                    esqcom1[esqpos1]
                    with frame f-com1.
            end.
            else do:
                color display normal
                    esqcom2[esqpos2]
                    with frame f-com2.
                esqpos2 = if esqpos2 = 1
                          then 1
                          else esqpos2 - 1.
                color display messages
                    esqcom2[esqpos2]
                    with frame f-com2.
            end.
            next.
        end.
        if keyfunction(lastkey) = "cursor-down"
        then do:
            find next tt-livre where
                true no-error.
            if not avail tt-livre
            then next.
            color display normal
                tt-livre.procod.
            if frame-line(frame-a) = frame-down(frame-a)
            then scroll with frame frame-a.
            else down with frame frame-a.
        end.
        if keyfunction(lastkey) = "cursor-up"
        then do:
            find prev tt-livre where
                true no-error.
            if not avail tt-livre
            then next.
            color display normal
                tt-livre.procod.
            if frame-line(frame-a) = 1
            then scroll down with frame frame-a.
            else up with frame frame-a.
        end.
        if keyfunction(lastkey) = "end-error"
        then leave bl-princ.

        if keyfunction(lastkey) = "return"
        then do on error undo, retry on endkey undo, leave.
        hide frame frame-a no-pause.

          if esqregua
          then do:
            display caps(esqcom1[esqpos1]) @ esqcom1[esqpos1]
                with frame f-com1.

            if esqcom1[esqpos1] = "Procura"
            then do on error undo, retry
                    with frame f-proc overlay row 8 centered side-labels.
                view frame frame-a. pause 0.
                vprocod = 0.
                vfincod = 0.

                update vprocod label "Produto"
                       vfincod label "Plano".
                
                    
                find first tt-livre where tt-livre.fincod = vfincod and
                                          tt-livre.procod = vprocod no-error.
                if not avail tt-livre                          
                then do:
                    recatu1 = ?.
                    message "Produto " vprocod " com plano " vfincod
                            " nao encontrado.".
                    undo, retry.
                end.
                
                vprocod = 0. vfincod = 0.
                recatu1 = recid(tt-livre).
                leave.
                
            end.
            
            if esqcom1[esqpos1] = "Inclusao"
            then do on error undo, retry
                    with frame f-inclui overlay row 6 1 column centered.
                
                update vprocod label "Produto"
                       vfincod label "Plano"
                       vpreco  label "Preco".

                find produ where produ.procod = vprocod no-lock no-error.
                if not avail produ
                then do:
                    message "Produto nao cadastrado".
                    undo, retry.
                end.
                find finan where finan.fincod = vfincod no-lock no-error.
                if not avail finan
                then do:
                    message "Plano nao cadastrado".
                    undo, retry.
                end.
                 
                find first tt-livre where tt-livre.fincod = vfincod and
                                          tt-livre.procod = vprocod no-error.
                if avail tt-livre                          
                then do:
                    message "Produto ja cadastrado".
                    pause.
                    undo, retry.
                     
                end.
                       
                create tt-livre.
                update tt-livre.procod = vprocod
                       tt-livre.fincod = vfincod
                       tt-livre.preco  = vpreco.
                recatu1 = recid(tt-livre).
                leave.
                
            end.
            if esqcom1[esqpos1] = "Alteracao"
            then do with frame f-altera overlay row 6 1 column centered.
                update tt-livre with frame f-altera no-validate.
            end.
            if esqcom1[esqpos1] = "Consulta"
            then do with frame f-consulta overlay row 6 1 column centered.
                disp tt-livre with frame f-consulta no-validate.
            end.
            if esqcom1[esqpos1] = "Exclusao"
            then do with frame f-exclui overlay row 6 1 column centered.
                message "Confirma Exclusao de" produ.pronom update sresp.
                if not sresp
                then leave.
                find next tt-livre where true no-error.
                if not available tt-livre
                then do:
                    find tt-livre where recid(tt-livre) = recatu1.
                    find prev tt-livre where true no-error.
                end.
                recatu2 = if available tt-livre
                          then recid(tt-livre)
                          else ?.
                find tt-livre where recid(tt-livre) = recatu1.
                delete tt-livre.
                recatu1 = recatu2.
                leave.
            end.
            if esqcom1[esqpos1] = "Listagem"
            then do with frame f-Lista overlay row 6 1 column centered.
                message "Confirma Impressao de tt-livreidades " update sresp.
                if not sresp
                then leave.
                recatu2 = recatu1.
                output to printer.
                for each tt-livre:
                    display tt-livre.
                end.
                output close.
                recatu1 = recatu2.
                leave.
            end.

          end.
          else do:
            display caps(esqcom2[esqpos2]) @ esqcom2[esqpos2]
                with frame f-com2.
            message esqregua esqpos2 esqcom2[esqpos2].
            pause.
          end.
          view frame frame-a .
        end.
          if keyfunction(lastkey) = "end-error"
          then view frame frame-a.

        find produ where produ.procod = tt-livre.procod no-lock no-error.
    
        display
                tt-livre.procod
                produ.pronom when avail produ
                tt-livre.fincod
                tt-livre.preco
                    with frame frame-a.
        if esqregua
        then display esqcom1[esqpos1] with frame f-com1.
        else display esqcom2[esqpos2] with frame f-com2.
        recatu1 = recid(tt-livre).
   end.
end.

output to value(varq-auto).

    for each tt-livre.
        put tt-livre.procod format "999999" 
            tt-livre.fincod format "99" 
            tt-livre.preco  format "99,999.99" skip.
    end.

output close.
