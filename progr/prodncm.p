{admcab.i}

def var vselncm as log format "Sim/Nao".
def var vselicm as log format "Sim/Nao".
def var vcodfis like clafis.codfis.
def var valicms as int.
def var v-ativo as log format "Sim/Nao" init yes.
def var vproseq as int.
def var vpronom like produ.pronom.
def var vpronom2 like produ.pronom.

def var recatu1         as recid.
def var reccont         as int.
def var esqpos1         as int.
def var esqcom1         as char format "x(12)" extent 5
    initial [" "," Alteracao "," "," Consulta "," "].

def temp-table tt-produ
    field procod like produ.procod    
    index produ is primary unique procod.

def buffer bprodu       for produ.
def var vprocod like produ.procod.

form
    esqcom1
    with frame f-com1
                 row 7 no-box no-labels side-labels column 1 centered.

repeat on error undo with frame f-filtro side-label no-box.
    assign
        v-ativo = ?
        vproseq = ?.

    update vselncm label "Selecionar NCM?".
        update vcodfis label "NCM".
        find clafis where clafis.codfis = vcodfis no-lock no-error.
        disp clafis.desfis no-label format "x(20)" when avail clafis.

    update vselicm label "Selecionar ICMS?".
    if vselicm
    then update valicms label "ICMS Padrao" format ">9".

    update v-ativo label "Ativo" help "Sim/Nao".
    if v-ativo <> ?
    then if v-ativo
        then vproseq = 0.
        else vproseq = 99.

    update vpronom  label "Inicio" format "x(20)".

    update vpronom2 label "Meio" format "x(20)".

    for each tt-produ.
        delete tt-produ.
    end.
    for each produ no-lock.
        if vselncm and produ.codfis = vcodfis
        then next.

        if vproseq <> ? and vproseq <> produ.proseq
        then next.

        if vselicm and valicms = produ.proipiper
        then next.

        if vpronom <> ""
        then
            if produ.pronom begins vpronom or
               produ.pronom begins "*" + vpronom
            then .
            else next.

        if vpronom2 <> "" and (not produ.pronom matches "*" + vpronom2 + "*")
        then next.

        create tt-produ.
        tt-produ.procod = produ.procod.
    end.
/*
*
*    tt-produ.p    -    Esqueleto de Programacao    com esqvazio
*
*/

assign
    esqpos1  = 1
    recatu1  = ?.

bl-princ:
repeat:
    disp esqcom1 with frame f-com1.
    if recatu1 = ?
    then
        run leitura (input "pri").
    else
        find tt-produ where recid(tt-produ) = recatu1 no-lock.
    if not available tt-produ
    then do.
        message "Produtos nao encontrados" view-as alert-box.
        leave.
    end.
    clear frame frame-a all no-pause.
    run frame-a.

    recatu1 = recid(tt-produ).
    color display message esqcom1[esqpos1] with frame f-com1.
    repeat:
        run leitura (input "seg").
        if not available tt-produ
        then leave.
        if frame-line(frame-a) = frame-down(frame-a)
        then leave.
        down
            with frame frame-a.
        run frame-a.
    end.
    up frame-line(frame-a) - 1 with frame frame-a.

    repeat with frame frame-a:

            find tt-produ where recid(tt-produ) = recatu1 no-lock.
            find produ of tt-produ no-lock.

            status default produ.pronom.

            run color-message.
            choose field tt-produ.procod help ""
                go-on(cursor-down cursor-up
                      cursor-left cursor-right
                      page-down   page-up
                      PF4 F4 ESC return) .
            run color-normal.

            if keyfunction(lastkey) = "cursor-left"
            then do:
                    color display normal esqcom1[esqpos1] with frame f-com1.
                    esqpos1 = if esqpos1 = 1 then 1 else esqpos1 - 1.
                    color display messages esqcom1[esqpos1] with frame f-com1.
                next.
            end.
            if keyfunction(lastkey) = "cursor-right"
            then do:
                    color display normal esqcom1[esqpos1] with frame f-com1.
                    esqpos1 = if esqpos1 = 5 then 5 else esqpos1 + 1.
                    color display messages esqcom1[esqpos1] with frame f-com1.
            end.
            if keyfunction(lastkey) = "page-down"
            then do:
                do reccont = 1 to frame-down(frame-a):
                    run leitura (input "down").
                    if not avail tt-produ
                    then leave.
                    recatu1 = recid(tt-produ).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "page-up"
            then do:
                do reccont = 1 to frame-down(frame-a):
                    run leitura (input "up").
                    if not avail tt-produ
                    then leave.
                    recatu1 = recid(tt-produ).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "cursor-down"
            then do:
                run leitura (input "down").
                if not avail tt-produ
                then next.
                color display white/red tt-produ.procod with frame frame-a.
                if frame-line(frame-a) = frame-down(frame-a)
                then scroll with frame frame-a.
                else down with frame frame-a.
            end.
            if keyfunction(lastkey) = "cursor-up"
            then do:
                run leitura (input "up").
                if not avail tt-produ
                then next.
                color display white/red tt-produ.procod with frame frame-a.
                if frame-line(frame-a) = 1
                then scroll down with frame frame-a.
                else up with frame frame-a.
            end.
 
        if keyfunction(lastkey) = "end-error"
        then leave bl-princ.

        if keyfunction(lastkey) = "return"
        then do:
            hide frame frame-a no-pause.
                display caps(esqcom1[esqpos1]) @ esqcom1[esqpos1]
                        with frame f-com1.

            if esqcom1[esqpos1] = " Consulta "
            then do.
                vprocod = tt-produ.procod.
                run cad_produman.p ("CON",
                                0,
                                0,
                                0,
                                0,
                                0,
                                input-output vprocod).
            end.
            if esqcom1[esqpos1] = " Alteracao "
            then do with frame frame-a on error undo.
                find tt-produ where recid(tt-produ) = recatu1 no-lock.
                find produ of tt-produ exclusive.
                if vselicm and produ.proipiper = 0
                then produ.proipiper = valicms.
                update produ.proipiper colon 12 label "Ali.Icms".
                run valida-aliquota-icms.
                if not sresp
                then undo.
                if produ.proipiper <> 17 and
                   produ.proipiper <> 12 and
                   produ.proipiper <> 18 and
                   produ.proipiper <> 99
                then do:
                    message "Aliquota Invalida".
                    undo.
                end.
                if vcodfis <> 0 and
                   (produ.codfis = 99999999 or
                    produ.codfis = 0)
                then produ.codfis = vcodfis.
                update produ.codfis.
                find clafis of produ no-lock no-error.
                if not avail clafis
                then do.
                    message "NCM invalido" view-as alert-box.
                    undo.
                end.
            end.
        end.
        run frame-a.
        display esqcom1[esqpos1] with frame f-com1.
        recatu1 = recid(tt-produ).
    end.
    if keyfunction(lastkey) = "end-error"
    then do:
        view frame fc1.
        view frame fc2.
    end.
end.
hide frame f-com1  no-pause.
hide frame frame-a no-pause.

end. /* repeat */

procedure frame-a.
    find produ of tt-produ no-lock.
    display tt-produ.procod
        produ.pronom format "x(40)"
        produ.proipiper column-label "ICMS%"
        produ.codfis format ">>>>>>>9"
        with frame frame-a 10 down centered color white/red row 8.
end procedure.


procedure color-message.
color display message
        tt-produ.procod
        with frame frame-a.
end procedure.

procedure color-normal.
color display normal
        tt-produ.procod
        with frame frame-a.
end procedure.


procedure leitura . 
def input parameter par-tipo as char.
        
if par-tipo = "pri" 
then find first tt-produ no-lock no-error.
                                             
if par-tipo = "seg" or par-tipo = "down" 
then find next  tt-produ no-lock no-error.
             
if par-tipo = "up" 
then find prev  tt-produ no-lock no-error.
        
end procedure.

procedure valida-aliquota-icms:

    def var produ-lst   as char init "405853,407721".
    
    sresp = yes.
    
    if lookup(string(produ.procod),produ-lst) > 0 then return "".
    
    if produ.pronom matches "*celular*" or
       produ.pronom matches "*chip*" or
       produ.pronom matches "*auto radio*" or
       produ.pronom matches "*auto-radio*" or
       produ.pronom matches "*alto falante*" or
       produ.pronom matches "*alto-falante*" or
       produ.pronom matches "*auto falante*" or
       produ.pronom matches "*auto-falante*" or
       produ.pronom matches "*bateria*" or
       produ.pronom matches "*colchao*" or
       produ.pronom matches "*pneu*" or
       produ.pronom matches "*vivo*" or
       produ.pronom matches "* tim *" or
       produ.pronom matches "*claro*" 
    then do:
        if produ.proipiper = 99
        then.
        else message "Aliquota invalida. Confirma?" sresp.
    end.
end.

