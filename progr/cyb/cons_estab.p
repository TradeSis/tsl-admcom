/*
*    09/2018 - Mostrar regras
*    estab.p    -    Esqueleto de Programacao    com esqvazio
*/
{admcab.i}

def var vprocessa_novacao as log format "Sim/   " label "Novacao".
def var vprocessa_lp      as log format "Sim/   " label "LP".
def var vprocessa_geral   as log format "Sim/   " label "GER".
def var vprocessa_normal  as log format "Sim/   " label "Normal".
def var vprocessa_cp      as log format "Sim/   " Label "CP".
def var vdias_novacao     as int format "->>>" label "Dias Nov".
def var vdias_lp          as int format "->>>" label "Dias LP".
def var vdias_boleto      as int format "->>>" label "Dias Boleto".
def var vdias_cp          as int format "->>>" label "Dias CP".
def var vdias             as int format "->>>" label "Dias".

def var recatu1         as recid.
def var recatu2         as recid.
def var reccont         as int.
def var esqpos1         as int.
def var esqvazio        as log.
def var esqcom1         as char format "x(12)" extent 5
    initial [" "].

form
    esqcom1
    with frame f-com1 row 4 no-box no-labels column 1 centered.
assign
    esqpos1  = 1.

bl-princ:
repeat:
    disp esqcom1 with frame f-com1.
    if recatu1 = ?
    then
        run leitura (input "pri").
    else
        find estab where recid(estab) = recatu1 no-lock.
    if not available estab
    then esqvazio = yes.
    else esqvazio = no.
    clear frame frame-a all no-pause.
    if not esqvazio
    then run frame-a.

    recatu1 = recid(estab).
    color display message esqcom1[esqpos1] with frame f-com1.
    if not esqvazio
    then repeat:
        run leitura (input "seg").
        if not available estab
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
            find estab where recid(estab) = recatu1 no-lock.

            status default  "".
            run color-message.
            choose field estab.etbcod help ""
                go-on(cursor-down cursor-up
                      cursor-left cursor-right
                      page-down   page-up
                      PF4 F4 ESC return) .
            run color-normal.
            status default "".

        end.
            if keyfunction(lastkey) = "cursor-right"
            then do:
                    color display normal esqcom1[esqpos1] with frame f-com1.
                    esqpos1 = if esqpos1 = 5 then 5 else esqpos1 + 1.
                    color display messages esqcom1[esqpos1] with frame f-com1.
                next.
            end.
            if keyfunction(lastkey) = "cursor-left"
            then do:
                    color display normal esqcom1[esqpos1] with frame f-com1.
                    esqpos1 = if esqpos1 = 1 then 1 else esqpos1 - 1.
                    color display messages esqcom1[esqpos1] with frame f-com1.
                next.
            end.
            if keyfunction(lastkey) = "page-down"
            then do:
                do reccont = 1 to frame-down(frame-a):
                    run leitura (input "down").
                    if not avail estab
                    then leave.
                    recatu1 = recid(estab).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "page-up"
            then do:
                do reccont = 1 to frame-down(frame-a):
                    run leitura (input "up").
                    if not avail estab
                    then leave.
                    recatu1 = recid(estab).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "cursor-down"
            then do:
                run leitura (input "down").
                if not avail estab
                then next.
                color display white/red estab.etbcod with frame frame-a.
                if frame-line(frame-a) = frame-down(frame-a)
                then scroll with frame frame-a.
                else down with frame frame-a.
            end.
            if keyfunction(lastkey) = "cursor-up"
            then do:
                run leitura (input "up").
                if not avail estab
                then next.
                color display white/red estab.etbcod with frame frame-a.
                if frame-line(frame-a) = 1
                then scroll down with frame frame-a.
                else up with frame frame-a.
            end.
 
        if keyfunction(lastkey) = "end-error"
        then leave bl-princ.

        if keyfunction(lastkey) = "return" or esqvazio
        then do:
            form estab
                 with frame f-estab color black/cyan
                      centered side-label row 5 .
            hide frame frame-a no-pause.
                display caps(esqcom1[esqpos1]) @ esqcom1[esqpos1]
                        with frame f-com1.

                leave.
        end.
        if not esqvazio
        then do:
            run frame-a.
        end.
        display esqcom1[esqpos1] with frame f-com1.
        recatu1 = recid(estab).
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

    vprocessa_novacao = no.
    find first tab_ini where tab_ini.etbcod    = 0 and
                             tab_ini.parametro = "CYBER_REGRA_NOVACAO"
                       no-lock no-error.
    if avail tab_ini and
       tab_ini.valor = "SIM"
    then vprocessa_novacao = yes.
    find first tab_ini where tab_ini.etbcod    = estab.etbcod and
                             tab_ini.parametro = "CYBER_REGRA_NOVACAO"
                       no-lock no-error.
    if avail tab_ini 
    then
        if tab_ini.valor = "SIM"
        then vprocessa_novacao = yes.
        else vprocessa_novacao = no.


    find first tab_ini where tab_ini.etbcod    = 0 and
                             tab_ini.parametro = "CYBER_NDIAS_NOVACAO"
                       no-lock no-error.
    if not avail tab_ini
    then vprocessa_novacao = no.

    vdias_novacao = int(tab_ini.valor).
    
    vprocessa_lp = no.

    find first tab_ini where tab_ini.etbcod    = 0 and
                             tab_ini.parametro = "CYBER_REGRA_LP"
                       no-lock no-error.
    if avail tab_ini and
       tab_ini.valor = "SIM"
    then vprocessa_lp = yes.

    find first tab_ini where tab_ini.etbcod    = estab.etbcod and
                             tab_ini.parametro = "CYBER_REGRA_LP"
                       no-lock no-error.
    if avail tab_ini 
    then
        if tab_ini.valor = "SIM"
        then vprocessa_lp = yes.
        else vprocessa_lp = no.


    find first tab_ini where tab_ini.etbcod    = 0 and
                             tab_ini.parametro = "CYBER_NDIAS_LP"
                       no-lock no-error.
    if not avail tab_ini
    then vprocessa_lp = no.

    vdias_lp = int(tab_ini.valor).

    /** #2       PROCESSA CP **/
    vprocessa_cp = no.
    vdias_cp = 0.
    
    find first tab_ini where tab_ini.etbcod    = 0 and
                             tab_ini.parametro = "CYBER_REGRA_CP"
                       no-lock no-error.
    if avail tab_ini and
       tab_ini.valor = "SIM"
    then vprocessa_cp = yes.

    find first tab_ini where tab_ini.etbcod    = estab.etbcod and
                             tab_ini.parametro = "CYBER_REGRA_CP"
                       no-lock no-error.
    if avail tab_ini 
    then
        if tab_ini.valor = "SIM"
        then vprocessa_cp = yes.
        else vprocessa_cp = no.

    find first tab_ini where tab_ini.etbcod    = 0 and
                             tab_ini.parametro = "CYBER_NDIAS_CP"
                       no-lock no-error.
    if avail tab_ini /* #4 */
    then do:
        vdias_cp = int(tab_ini.valor).
    end.
 
    find first tab_ini where tab_ini.etbcod    = estab.etbcod and
                             tab_ini.parametro = "CYBER_NDIAS_CP"
                       no-lock no-error.
    if avail tab_ini
    then do:
        vdias_cp = int(tab_ini.valor).
    end.
    /** #2 FIM - PROCESSA CP */

    /** #1 **/
    find first tab_ini where tab_ini.etbcod    = 0 and
                             tab_ini.parametro = "CYBER_NDIAS_BOLETO"
                       no-lock no-error.
    if not avail tab_ini
    then vdias_boleto = 0.
    else do:
        vdias_boleto = int(tab_ini.valor).
    end.


    vprocessa_geral = no.

    find first tab_ini where tab_ini.etbcod    = 0 and
                             tab_ini.parametro = "CYBER_REGRA_GERAL"
                       no-lock no-error.
    if avail tab_ini and
       tab_ini.valor = "SIM"
    then vprocessa_geral = yes.

    find first tab_ini where tab_ini.etbcod    = estab.etbcod and
                             tab_ini.parametro = "CYBER_REGRA_GERAL"
                       no-lock no-error.
    if avail tab_ini 
    then
        if tab_ini.valor = "SIM"
        then vprocessa_geral = yes.
        else vprocessa_geral = no.


    vprocessa_normal = no.

    find first tab_ini where tab_ini.etbcod    = 0 and
                             tab_ini.parametro = "CYBER_REGRA_NDIAS"
                       no-lock no-error.
    if avail tab_ini and
       tab_ini.valor = "SIM"
    then vprocessa_normal = yes.

    find first tab_ini where tab_ini.etbcod    = estab.etbcod and
                             tab_ini.parametro = "CYBER_REGRA_NDIAS"
                       no-lock no-error.
    if avail tab_ini 
    then
        if tab_ini.valor = "SIM"
        then vprocessa_normal = yes.
        else vprocessa_normal = no.

    find first tab_ini where tab_ini.etbcod    = 0 and
                             tab_ini.parametro = "CYBER_NDIAS"
                       no-lock no-error.
    if not avail tab_ini
    then vprocessa_normal = no.

    vdias  = int(tab_ini.valor).

    display
        estab.etbcod
        vprocessa_novacao
        vdias_novacao
        vprocessa_lp
        vdias_lp
        vdias_boleto
        vprocessa_normal
        vdias
        vprocessa_cp
        vdias_cp
        with frame frame-a 11 down centered color white/red row 5.
end procedure.


procedure color-message.
color display message
        estab.etbcod
        with frame frame-a.
end procedure.


procedure color-normal.
color display normal
        estab.etbcod
        with frame frame-a.
end procedure.


procedure leitura . 
def input parameter par-tipo as char.
        
if par-tipo = "pri" 
then find first estab where true no-lock no-error.
                                             
if par-tipo = "seg" or par-tipo = "down" 
then find next estab  where true no-lock no-error.
             
if par-tipo = "up" 
then find prev estab  where true no-lock no-error.
        
end procedure.
         
