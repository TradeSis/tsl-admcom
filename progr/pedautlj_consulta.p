/* Projeto Melhorias Mix - Luciano     */

def buffer liped_pend for liped.

def var recatu1         as recid.
def var recatu2         as recid.
def var reccont         as int.
def var esqpos1         as int.
def var esqpos2         as int.
def var esqregua        as log.
def var esqvazio        as log.
def var esqascend     as log initial yes.
def var esqcom1         as char format "x(12)" extent 5
        init [" ", ""].
def var esqcom2         as char format "x(12)" extent 5.
def var esqhel1         as char format "x(80)" extent 5.
def var esqhel2         as char format "x(12)" extent 5.

{admcab.i}
def input parameter par-rec as recid.
find pedid where recid(pedid)  = par-rec no-lock.

def buffer bliped       for liped.
def var vliped         like liped.procod.
def new global shared temp-table tt-reservas
    field sequencia    as dec
    field rec_liped     as recid
    field tipo          as char
    field atende        as int
    field dispo         as int
    field prioridade    as int format "->>>>" label "Pri"
    field regra         as int
    index sequencia   is primary prioridade
    index rec_liped is unique rec_liped .
for each tt-reservas.
    delete tt-reservas.
end.


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
        find liped where recid(liped) = recatu1 no-lock.
    if not available liped
    then esqvazio = yes.
    else esqvazio = no.
    clear frame frame-a all no-pause.
    if not esqvazio
    then do:
        run frame-a.
    end.

    recatu1 = recid(liped).
    if esqregua
    then color display message esqcom1[esqpos1] with frame f-com1.
    else color display message esqcom2[esqpos2] with frame f-com2.
    if not esqvazio
    then repeat:
        run leitura (input "seg").
        if not available liped
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
            find liped where recid(liped) = recatu1 no-lock.

            status default
                if esqregua
                then esqhel1[esqpos1] + if esqpos1 > 1 and
                                           esqhel1[esqpos1] <> ""
                                        then  string(liped.procod)
                                        else ""
                else esqhel2[esqpos2] + if esqhel2[esqpos2] <> ""
                                        then string(liped.procod)
                                        else "".
            run color-message.
            choose field liped.procod help ""
                go-on(cursor-down cursor-up
                      cursor-left cursor-right
                      page-down   page-up
                      tab PF4 F4 ESC return) .
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
                    if not avail liped
                    then leave.
                    recatu1 = recid(liped).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "page-up"
            then do:
                do reccont = 1 to frame-down(frame-a):
                    run leitura (input "up").
                    if not avail liped
                    then leave.
                    recatu1 = recid(liped).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "cursor-down"
            then do:
                run leitura (input "down").
                if not avail liped
                then next.
                color display white/red liped.procod with frame frame-a.
                if frame-line(frame-a) = frame-down(frame-a)
                then scroll with frame frame-a.
                else down with frame frame-a.
            end.
            if keyfunction(lastkey) = "cursor-up"
            then do:
                run leitura (input "up").
                if not avail liped
                then next.
                color display white/red liped.procod with frame frame-a.
                if frame-line(frame-a) = 1
                then scroll down with frame frame-a.
                else up with frame frame-a.
            end.
 
        if keyfunction(lastkey) = "end-error"
        then leave bl-princ.

        if keyfunction(lastkey) = "return" or esqvazio
        then do:
            form liped
                 with frame f-liped color black/cyan
                      centered side-label row 5 .
            hide frame frame-a no-pause.
            if esqregua
            then do:
                display caps(esqcom1[esqpos1]) @ esqcom1[esqpos1]
                        with frame f-com1.

                if esqcom1[esqpos1] = " Prioridades "
                then do with frame f-liped on error undo.
                    find produ where produ.procod = liped.procod no-lock.
                    run reservpro.p (input "PROCOD=" + string(produ.procod) +
                                     "|" + 
                                     "RECID_LIPED=" + string(recid(liped)) ).
                    recatu1 = recid(liped).
                    leave.
                end.
                if esqcom1[esqpos1] = " Consulta " or
                   esqcom1[esqpos1] = " Exclusao " or
                   esqcom1[esqpos1] = " Alteracao "
                then do with frame f-liped.
                    disp liped.
                end.
                if esqcom1[esqpos1] = " Alteracao "
                then do with frame f-liped on error undo.
                    find liped where
                            recid(liped) = recatu1 
                        exclusive.
                    update liped.
                end.
                if esqcom1[esqpos1] = " Exclusao "
                then do with frame f-exclui  row 5 1 column centered
                        on error undo.
                    message "Confirma Exclusao de" liped.procod
                            update sresp.
                    if not sresp
                    then undo, leave.
                    find next liped where of pedid no-error.
                    if not available liped
                    then do:
                        find liped where recid(liped) = recatu1.
                        find prev liped where of pedid no-error.
                    end.
                    recatu2 = if available liped
                              then recid(liped)
                              else ?.
                    find liped where recid(liped) = recatu1
                            exclusive.
                    delete liped.
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
                    then run lliped.p (input 0).
                    else run lliped.p (input liped.procod).
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
        recatu1 = recid(liped).
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

def var vestoq_depos    as int format "->>>>>9".
def var vreservas       as int format "->>>>>9".
def var vdisponivel     as int format "->>>>>9".
find com.produ where com.produ.procod = com.liped.procod no-lock. 
for each tt-reservas.
    delete tt-reservas.
end.

        def var vpend as char format "x(13)".
        vpend = "".
        find first pedpend where pedpend.etbcod-ori = liped.etbcod and
                                 pedpend.pedtdc-ori = liped.pedtdc and
                                 pedpend.pednum-ori = liped.pednum
                                 no-lock no-error.
        if avail pedpend
        then do.
            find liped_pend where liped_pend.etbcod = pedpend.etbcod-des and
                                  liped_pend.pedtdc = pedpend.pedtdc-des and
                                  liped_pend.pednum = pedpend.pednum-des and
                                  liped_pend.procod = liped.procod
                                  no-lock no-error.
            if avail liped_pend
            then vpend = "Gerado=" + string(pednum-des).
        end.
        find first pedpend where pedpend.etbcod-des = liped.etbcod and
                                 pedpend.pedtdc-des = liped.pedtdc and
                                 pedpend.pednum-des = liped.pednum
                                 no-lock no-error.
        if avail pedpend
        then do.
            find liped_pend where liped_pend.etbcod = pedpend.etbcod-ori and
                                  liped_pend.pedtdc = pedpend.pedtdc-ori and
                                  liped_pend.pednum = pedpend.pednum-ori and
                                  liped_pend.procod = liped.procod
                                  no-lock no-error.
            if avail liped_pend
            then vpend = "Orig=" + string(pednum-ori).
        end.
        
        
        disp com.liped.procod   column-label "Codigo"
             com.produ.pronom   format "x(15)" column-label "Produto"
             com.liped.lipqtd   column-label "Qtd!Pedido" format ">>>>9" 
             com.liped.lipent   column-label "Qtd!Entreg" format ">>>>9" 
             com.liped.PendMotivo
             com.liped.Lip_Status
        with frame frame-a 5 down centered color white/red row 5
                    width 80
                title " Pedido " + string(pedid.pednum) + " filial " +
                                    string(pedid.etbcod) + " ".
end procedure.
procedure color-message.
color display message
        liped.procod
        with frame frame-a.
end procedure.
procedure color-normal.
color display normal
        liped.procod
        with frame frame-a.
end procedure.




procedure leitura . 
def input parameter par-tipo as char.
        
if par-tipo = "pri" 
then  
    if esqascend  
    then  
        find first liped where of pedid
                                                no-lock no-error.
    else  
        find last liped  where of pedid
                                                 no-lock no-error.
                                             
if par-tipo = "seg" or par-tipo = "down" 
then  
    if esqascend  
    then  
        find next liped  where of pedid
                                                no-lock no-error.
    else  
        find prev liped   where of pedid
                                                no-lock no-error.
             
if par-tipo = "up" 
then                  
    if esqascend   
    then   
        find prev liped where of pedid  
                                        no-lock no-error.
    else   
        find next liped where of pedid 
                                        no-lock no-error.
        
end procedure.
         
