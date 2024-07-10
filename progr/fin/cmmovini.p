 /*
*
*    cmon.p    -    Esqueleto de Programacao    com esqvazio


            substituir    cmon
                          <tab>
*
*/

def var par-today as date format "99/99/9999" initial today.


def var recatu1         as recid.
def var recatu2         as recid.
def var reccont         as int.
def var esqpos1         as int.
def var esqpos2         as int.
def var esqregua        as log.
def var esqvazio        as log.
def var esqascend     as log initial yes.
def var esqcom1         as char format "x(12)" extent 5
    initial [" Movimento "," Conciliacao "," Extrato "," Troca Data "," "].
def var esqcom2         as char format "x(12)" extent 5
            initial [" Consultas "," Historico "," Reabre ","",""].
def var esqhel1         as char format "x(80)" extent 5
    initial [" Inclusao  de cmon ",
             " Alteracao da cmon ",
             " Exclusao  da cmon ",
             " Consulta  da cmon ",
             " Listagem  Geral de cmon "].
def var esqhel2         as char format "x(12)" extent 5
   initial ["  ",
            " ",
            " ",
            " ",
            " "].

{cabec.i new}

def var par-cmtipo     like cmtipo.cmtcod init "EXT".
def buffer bcmon       for cmon.
def var vcmon         like cmon.cxanom.

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
def var par-etbcod like estab.etbcod init 0.

find cmtipo where cmtipo.cmtcod = par-cmtipo no-lock.

if cmtipo.cmtcod = "BAN" 
then esqascend = yes. 
else esqascend = no.
    form
        par-etbcod label "Estab"
        estab.etbnom no-labels
        par-today          format "99/99/9999" no-label colon 68
         with frame f-data row 3 width 81 /*color messages*/
                         side-labels no-box.
find estab where estab.etbcod = setbcod no-lock.

disp estab.etbnom when avail estab
    with frame f-data.


bl-princ:
repeat:

    disp esqcom1 with frame f-com1.
    disp esqcom2 with frame f-com2.
    if recatu1 = ?
    then
        if esqascend
        then
            find first cmon  where
                    cmon.cmtcod = cmtipo.cmtcod and
                                    if par-etbcod = 0
                                    then true
                                    else  cmon.etbcod = par-etbcod
                                    use-index cmon-banco 
                                        no-lock no-error.
        else
            find first cmon where cmon.cmtcod = cmtipo.cmtcod and

                                    if par-etbcod = 0
                                    then true
                                    else   cmon.etbcod = par-etbcod

                                    use-index cmon-caixa
                                        no-lock no-error.
    else
        find cmon where recid(cmon) = recatu1 no-lock.
    if not available cmon
    then esqvazio = yes.
    else esqvazio = no.
    clear frame frame-a all no-pause.
    clear frame frame-b all no-pause.
    
    if not esqvazio
    then do:

            display
                cmon.etbcod column-label "Estab."
                cmon.cxacod
                cmon.cxanom
                with frame frame-a 10 down centered                 row 5.
        disp par-today
            with frame f-data.
    end.

    recatu1 = recid(cmon).
    if esqregua
    then color display message esqcom1[esqpos1] with frame f-com1.
    else color display message esqcom2[esqpos2] with frame f-com2.
    if not esqvazio
    then repeat:
        if esqascend
        then
            find next cmon  
            where
                cmon.cmtcod = cmtipo.cmtcod and

            if par-etbcod = 0
                                    then true
                                    else   cmon.etbcod = par-etbcod
                                    
                                    use-index cmon-banco

                                        no-lock  no-error.
        else
            find next cmon  where 
                cmon.cmtcod = cmtipo.cmtcod and
                            if par-etbcod = 0
                                    then true
                                    else   cmon.etbcod = par-etbcod

                    use-index cmon-caixa
                                        no-lock no-error.
        if not available cmon
        then leave.
        if cmtipo.cmtcod = "BAN"
        then
            if frame-line(frame-b) = frame-down(frame-b)
            then leave.
            else.
        else
            if frame-line(frame-a) = frame-down(frame-a)
            then leave.
        
            down
                with frame frame-a.
            display
                cmon.cxacod
                cmon.cxanom
                cmon.etbcod
                with frame frame-a.
    end.
    if not esqvazio
    then
        if cmtipo.cmtcod = "BAN"
        then
            up frame-line(frame-b) - 1 with frame frame-b.
        else
            up frame-line(frame-a) - 1 with frame frame-a.

    repeat:

        if not esqvazio
        then do:
            find cmon where recid(cmon) = recatu1 no-lock.

            status default
                if esqregua
                then esqhel1[esqpos1] + if esqpos1 > 1 and
                                           esqhel1[esqpos1] <> ""
                                        then  string(cmon.cxanom)
                                        else ""
                else esqhel2[esqpos2] + if esqhel2[esqpos2] <> ""
                                        then string(cmon.cxanom)
                                        else "".
            color disp messages
                cmon.cxacod
                cmon.cxanom
                cmon.etbcod
                with frame frame-a.
            disp 
                par-today 
                with frame f-data.
                
            if cmtipo.cmtcod = "BAN"
            then
                choose field cmon.cxanom help ""
                    go-on(cursor-down cursor-up
                          cursor-left cursor-right
                          page-down   page-up
                          tab PF4 F4 ESC return) 
                                    with frame frame-b.
            else
                choose field cmon.cxanom help ""
                    go-on(cursor-down cursor-up
                          cursor-left cursor-right
                          page-down   page-up
                          tab PF4 F4 ESC return) 
                                    with frame frame-a.

            status default "".
        if cmtipo.cmtcod = "BAN"
        then
            color disp normal
                cmon.bancod
                cmon.agecod
                cmon.ccornum
                cmon.cxanom
                with frame frame-b.
        else
            color display normal
                cmon.cxacod
                cmon.cxanom
                cmon.etbcod
                with frame frame-a.

        end.
        if cmtipo.cmtcod = "BAN"
        then do:
        {esquema.i &tabela = "cmon"
                   &campo  = "cmon.cxanom"
                   &indice = "use-index cmon-banco" 
                   &where  = "  
                            
                             (if par-etbcod = 0
                                    then true
                                    else  cmon.etbcod = par-etbcod) and

                                    cmon.cmtcod = cmtipo.cmtcod "
"
                   &frame  = "frame-b"}
        end.
        else do:
            esqascend = yes.
        {esquema.i &tabela = "cmon"
                   &campo  = "cmon.cxanom"
                   &indice = "use-index cmon-caixa"

                   &where  = "cmon.cmtcod = cmtipo.cmtcod and                                      if par-etbcod = 0
                                    then true
                                    else  cmon.etbcod = par-etbcod
"
                   &frame  = "frame-a"}
            esqascend = no.                   
        end.
        if keyfunction(lastkey) = "end-error"
        then leave bl-princ.

        if keyfunction(lastkey) = "return" or esqvazio
        then do:
            form cmon
                 with frame f-cmon color black/cyan
                      centered side-label row 5 1 column.
            hide frame frame-a no-pause.
                         if esqregua
            then do:
                display caps(esqcom1[esqpos1]) @ esqcom1[esqpos1]
                        with frame f-com1.

                if esqcom1[esqpos1] = " Troca Data "
                then do:
                    hide frame f-tot    no-pause.
                    
                    run trocadata.
                    color disp normal esqcom1[esqpos1]
                        with frame f-com1.
                    esqpos1 = 1.
                    esqpos2 = 1.
                    leave.
                end.
                        
                if esqcom1[esqpos1] = " Movimento " and
                    par-cmtipo <> "CHE" and
                    par-cmtipo <> "CAR"
                then do:
                    hide frame f-com1 no-pause.
                    hide frame f-com2 no-pause.
                    hide frame frame-a no-pause.
                    hide frame frame-b no-pause.
                    /*
                    run   fin/cmmov.p (cmtipo.cmtcod, recid(cmon), par-today).
                    */
                    
                    hide frame ftotsaldo no-pause.
            

                     run fin/cmmovcai.p (cmtipo.cmtcod + "," + 
                                         string(cmon.cxacod)).
                    
                    run calcsaldotot.

                    view frame f-com1.
                    view frame f-com2.
                    leave.
                end.
                if esqcom1[esqpos1] = " Movimento " and
                    (par-cmtipo = "CHE" or
                    par-cmtipo = "CAR" )
                then do:
                    hide frame f-com1 no-pause.
                    hide frame f-com2 no-pause.
                    hide frame frame-a no-pause.
                    hide frame frame-b no-pause.
                    if today <= 10/04/2005
                    then run fin/cmmov.p (cmtipo.cmtcod, recid(cmon), par-today).
                    else run fin/cmcriafi.p (recid(cmon)).
                    view frame f-com1.
                    view frame f-com2.
                    leave.
                end.
                 
                if esqcom1[esqpos1] = " Conciliacao "
                then do:
                    hide frame f-com1 no-pause.
                    hide frame f-com2 no-pause.
                    hide frame frame-a no-pause.
                    hide frame frame-b no-pause.

                        hide frame ftotsaldo no-pause.
            
                    
                    run fin/cmcext.p (recid(cmon),?).
                    run calcsaldotot.
                    
                    view frame f-com1.
                    view frame f-com2.
                    leave.
                end.
                if esqcom1[esqpos1] = " Extrato "
                then do:
                    hide frame f-com1 no-pause.
                    hide frame f-com2 no-pause.
                    hide frame frame-a no-pause.
                    hide frame frame-b no-pause.

                        hide frame ftotsaldo no-pause.
            
                     
                    run  fin/cmcext.p (recid(cmon),par-today).
                    view frame f-com1.
                    view frame f-com2.
                    run calcsaldotot.
                    leave.
                end.
                 
            end.
            else do:
                display caps(esqcom2[esqpos2]) @ esqcom2[esqpos2]
                        with frame f-com2.
                if esqcom2[esqpos2] = " Reabre "
                then do:
                    hide frame f-com1  no-pause.
                    hide frame f-com2  no-pause.
                    message "Tem certeza reabrir???" update sresp.
                    if sresp
                    then
                    run fin/cmghis.p (input recid(cmon),
                                  input sfuncod,
                                  input par-today,
                                  input no). /* Fecha */
                    view frame f-com1.
                    view frame f-com2.
                end.
                if esqcom2[esqpos2] = " Historico "
                then do:
                    hide frame f-com1  no-pause.
                    hide frame f-com2  no-pause.
                    run fin/cmonhis.p (input recid(cmon)).
                    view frame f-com1.
                    view frame f-com2.
                end.
                if esqcom2[esqpos2] = " Limites "
                then do:
                    hide frame f-com1  no-pause.
                    hide frame f-com2  no-pause.
                    run fin/cmonlim.p (input recid(cmon)).
                    view frame f-com1.
                    view frame f-com2.
                end.
                if esqcom2[esqpos2] = " Consultas "
                then do:
                    hide frame f-com1 no-pause.
                    hide frame f-com2 no-pause.
                    hide frame frame-a no-pause.
                    hide frame frame-b no-pause.
                    hide frame f-data no-pause.
                    sretorno = "CMOCOD=" + string(cmon.cmocod).
                    run fin/concmon.p.
                    sretorno = "".
                    view frame f-data.
                    view frame f-com1.
                    view frame f-com2.
                    
                end.
                leave.
            end.
        end.
        if not esqvazio
        then do:
                display
                    cmon.cxacod
                    cmon.cxanom
                    cmon.etbcod
                                     with frame frame-a.
        end.
        if esqregua
        then display esqcom1[esqpos1] with frame f-com1.
        else display esqcom2[esqpos2] with frame f-com2.
        recatu1 = recid(cmon).
    end.
end.
hide frame f-com1  no-pause.
hide frame f-com2  no-pause.
hide frame frame-b no-pause.
hide frame frame-a no-pause.


procedure trocadata.

def var vfunape like func.funape.
def var vdata as date format "99/99/9999".
def var vfuncod like func.funcod.



    do on error undo.
        update par-today
            with frame f-data.
            
    end.


end procedure.
