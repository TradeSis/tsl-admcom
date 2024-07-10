/*
*
*    Esqueletao de Programacao
*
*/
{admcab.i}

def var vdtini  like plani.pladat.
def var vdtfin  like plani.pladat.
def var vativo  as log.

 
def temp-table tt-icms
    field procod like produ.procod
    field dtini  like plani.pladat
    field dtfin  like plani.pladat
    field ativo  as log
        index ind-1 procod.


def var reccont         as int.
def var vinicio         as log.
def var recatu1         as recid.
def var recatu2         as recid.
def var esqpos1         as int.
def var esqpos2         as int.
def var esqregua        as log.
def var esqcom1         as char format "x(12)" extent 4
            initial ["Inclusao","Exclusao","Alteracao","Procura"].
def var esqcom2         as char format "x(12)" extent 5
            initial ["","","","",""].


def buffer btt-icms       for tt-icms.
def var vprocod         like tt-icms.procod.


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

    for each tt-icms:
        delete tt-icms.
    end.
    
    input from ..\progr\icms.txt.
    repeat:
        import vprocod
               vdtini
               vdtfin
               vativo.
        find first tt-icms where tt-icms.procod = vprocod no-error.
        if not avail tt-icms
        then do:
               
        
            create tt-icms.
            assign tt-icms.procod = vprocod
                   tt-icms.dtini  = vdtini
                   tt-icms.dtfin  = vdtfin
                   tt-icms.ativo  = vativo.
                   
                   
            
        end.
        
    end.
    input close.

    for each tt-icms.

        find produ where produ.procod = tt-icms.procod no-lock no-error.
        if not avail produ
        then do:
            delete tt-icms.
            next.
        end.
    
    end.    
     


bl-princ:
repeat:

    
   

    disp esqcom1 with frame f-com1.
    disp esqcom2 with frame f-com2.
    if recatu1 = ?
    then
        find first tt-icms where
            true no-error.
    else
        find tt-icms where recid(tt-icms) = recatu1.
    vinicio = yes.
    if not available tt-icms
    then do:
        message "Cadastro de tt-icmsidades de Tit. Vazio".
        message "Deseja Incluir " update sresp.
        if not sresp
        then undo.
        do with frame f-inclui1  overlay row 6 1 column centered.
            create tt-icms.
            update tt-icms.procod.
            vinicio = no.
            find produ where produ.procod = tt-icms.procod no-error.
            if avail produ
            then do transaction:
                assign produ.proseq = 1
                       produ.datexp = today.
            end.
        end.
    end.
    clear frame frame-a all no-pause.

    find produ where produ.procod = tt-icms.procod no-lock no-error.
    display tt-icms.procod 
            produ.pronom  format "x(40)"
            tt-icms.dtini column-label "Periodo!Inicial"
            tt-icms.dtfin column-label "Periodo!Final"
            tt-icms.ativo column-label "Ativo" format "Sim/Nao"
                with frame frame-a 13 down centered.

    recatu1 = recid(tt-icms).
    color display message
        esqcom1[esqpos1]
            with frame f-com1.
    repeat:
        find next tt-icms where true.
        if not available tt-icms
        then leave.
        if frame-line(frame-a) = frame-down(frame-a)
        then leave.
        if vinicio
        then down
            with frame frame-a.
        find produ where produ.procod = tt-icms.procod no-lock no-error.
        display tt-icms.procod 
                produ.pronom 
                tt-icms.dtini
                tt-icms.dtfin
                tt-icms.ativo with frame frame-a.
    end.
    up frame-line(frame-a) - 1 with frame frame-a.

    repeat with frame frame-a:

        find tt-icms where recid(tt-icms) = recatu1.

        choose field tt-icms.procod
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
                esqpos1 = if esqpos1 = 4
                          then 4
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
                find next tt-icms where true no-error.
                if not avail tt-icms
                then leave.
                recatu1 = recid(tt-icms).
            end.
            leave.
        end.
        if keyfunction(lastkey) = "page-up"
        then do:
            do reccont = 1 to frame-down(frame-a):
                find prev tt-icms where true no-error.
                if not avail tt-icms
                then leave.
                recatu1 = recid(tt-icms).
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
            find next tt-icms where
                true no-error.
            if not avail tt-icms
            then next.
            color display normal
                tt-icms.procod.
            if frame-line(frame-a) = frame-down(frame-a)
            then scroll with frame frame-a.
            else down with frame frame-a.
        end.
        if keyfunction(lastkey) = "cursor-up"
        then do:
            find prev tt-icms where
                true no-error.
            if not avail tt-icms
            then next.
            color display normal
                tt-icms.procod.
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

            if esqcom1[esqpos1] = "Inclusao"
            then do with frame f-inclui overlay row 6 1 column centered.
                
                vprocod = 0.    
                update vprocod label "Produto".
                find first tt-icms where tt-icms.procod = vprocod no-error.
                if avail tt-icms
                then do:
                    message "Produto ja cadastrado".
                    pause.
                    undo, retry.
                end.
                       
                
                find produ where produ.procod = vprocod no-error.
                if avail produ
                then do transaction:
                    create tt-icms.
                    assign tt-icms.procod = vprocod
                           tt-icms.ativo  = yes.
                        
                    update tt-icms.dtini label "Periodo Inicial"
                           tt-icms.dtfin label "Periodo Final".
                                         
                    assign produ.proseq = 1
                           produ.datexp = today.
                    recatu1 = recid(tt-icms).
                        
                end.

                leave.
            end.

            if esqcom1[esqpos1] = "Procura"
            then do:
                vprocod = 0.
                update vprocod label "Produto"
                        with frame f-procura side-label centered.
                find first tt-icms where tt-icms.procod = vprocod no-error.
                if avail tt-icms
                then recatu1 = recid(tt-icms).
                else do:
                    message "Produto nao cadastrado".
                    recatu1 = ?.
                    pause.
                end.
                leave.

            end.
            if esqcom1[esqpos1] = "Alteracao"
            then do with frame f-alteracao overlay row 6 1 column centered.
                update tt-icms.dtini label "Periodo Inicial"
                       tt-icms.dtfin label "Periodo Final"
                       tt-icms.ativo label "Ativo" format "Sim/Nao"
                    with frame f-alteracao no-validate.

                find produ where produ.procod = tt-icms.procod no-error.
                if avail produ
                then do transaction: 
                    if tt-icms.ativo
                    then produ.proseq = 1. 
                    else produ.proseq = 0. 
                    produ.datexp = today.
                end.
                    
            end.
            if esqcom1[esqpos1] = "Exclusao"
            then do with frame f-exclui overlay row 6 1 column centered.
                message "Confirma Exclusao de" produ.pronom update sresp.
                if not sresp
                then leave.
                find next tt-icms where true no-error.
                if not available tt-icms
                then do:
                    find tt-icms where recid(tt-icms) = recatu1.
                    find prev tt-icms where true no-error.
                end.
                recatu2 = if available tt-icms
                          then recid(tt-icms)
                          else ?.
                find tt-icms where recid(tt-icms) = recatu1.
                find produ where produ.procod = tt-icms.procod no-error.
                if avail produ
                then do transaction:
                    assign produ.proseq = 0
                           produ.datexp = today.
                end.
                delete tt-icms.
                recatu1 = recatu2.
                leave.
            end.
            if esqcom1[esqpos1] = "Listagem"
            then do with frame f-Lista overlay row 6 1 column centered.
                message "Confirma Impressao de tt-icmsidades " update sresp.
                if not sresp
                then leave.
                recatu2 = recatu1.
                output to printer.
                for each tt-icms:
                    display tt-icms.
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

        find produ where produ.procod = tt-icms.procod no-lock no-error.

        display tt-icms.procod 
                produ.pronom 
                tt-icms.dtini
                tt-icms.dtfin
                tt-icms.ativo with frame frame-a.
        if esqregua
        then display esqcom1[esqpos1] with frame f-com1.
        else display esqcom2[esqpos2] with frame f-com2.
        recatu1 = recid(tt-icms).
   end.
end.

output to ..\progr\icms.txt.
for each tt-icms.
    put tt-icms.procod format "999999" " "
        tt-icms.dtini  format "99/99/9999" " "
        tt-icms.dtfin  format "99/99/9999" " "
        tt-icms.ativo  skip.
end.
output close.
    
