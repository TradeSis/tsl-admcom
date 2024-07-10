/*
*
*    opcom.p    -    Esqueleto de Programacao    com esqvazio

Programa original: opcom.p
*
*/
{admcab.i}

def var recatu1         as recid.
def var recatu2         as recid.
def var reccont         as int.
def var esqpos1         as int.
def var esqpos2         as int.
def var esqregua        as log.
def var esqvazio        as log.
def var esqascend       as log initial yes.
def var esqcom1         as char format "x(12)" extent 5
    initial [" Inclusao "," Alteracao "," Pesquisa"," Consulta "," Listagem "].
def var esqcom2         as char format "x(12)" extent 5.
def var esqhel1         as char format "x(80)" extent 5
    initial [" Inclusao  de opcom ",
             " Alteracao da opcom ",
             " Pesquisa da opcom ",
             " Consulta da opcom ",
             " Listagem Geral de opcom "].
def var esqhel2         as char format "x(12)" extent 5.

def buffer bopcom       for opcom.

def var vcod-bc-pf as char.

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
        find opcom where recid(opcom) = recatu1 no-lock.
    if not available opcom
    then esqvazio = yes.
    else esqvazio = no.
    clear frame frame-a all no-pause.
    if not esqvazio
    then do:
        run frame-a.
    end.

    recatu1 = recid(opcom).
    if esqregua
    then color display message esqcom1[esqpos1] with frame f-com1.
    else color display message esqcom2[esqpos2] with frame f-com2.
    if not esqvazio
    then repeat:
        run leitura (input "seg").
        if not available opcom
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
            find opcom where recid(opcom) = recatu1 no-lock.

            status default
                if esqregua
                then esqhel1[esqpos1] + if esqpos1 > 1 and
                                           esqhel1[esqpos1] <> ""
                                        then  string(opcom.opcnom)
                                        else ""
                else esqhel2[esqpos2] + if esqhel2[esqpos2] <> ""
                                        then string(opcom.opcnom)
                                        else "".
            run color-message.
            choose field opcom.opccod help ""
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
                    if not avail opcom
                    then leave.
                    recatu1 = recid(opcom).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "page-up"
            then do:
                do reccont = 1 to frame-down(frame-a):
                    run leitura (input "up").
                    if not avail opcom
                    then leave.
                    recatu1 = recid(opcom).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "cursor-down"
            then do:
                run leitura (input "down").
                if not avail opcom
                then next.
                color display white/red opcom.opccod with frame frame-a.
                if frame-line(frame-a) = frame-down(frame-a)
                then scroll with frame frame-a.
                else down with frame frame-a.
            end.
            if keyfunction(lastkey) = "cursor-up"
            then do:
                run leitura (input "up").
                if not avail opcom
                then next.
                color display white/red opcom.opccod with frame frame-a.
                if frame-line(frame-a) = 1
                then scroll down with frame frame-a.
                else up with frame frame-a.
            end.
 
        if keyfunction(lastkey) = "end-error"
        then leave bl-princ.

        if keyfunction(lastkey) = "return" or esqvazio
        then do:
            form
                opcom.opccod    colon 15
                opcom.opcnom    no-label
                opcom.movtdc    colon 15
                tipmov.movtnom  no-label
                tipmov.contapiscof
                opcom.opctip    colon 15
                opcom.piscofins colon 15
                opcom.CSTPisCofins  colon 15
                opcom.CSTPisCofinsA0
                vcod-bc-pf   label "Cod BC Pis/Cof" format "xx"
                help "Codigo Base de Credito Pis e Cofins."
                opcom.opcant    colon 15
                opcom.opcgia    colon 15
                opcom.opfcod-st colon 40
                with frame f-opcom color black/cyan
                      centered side-label row 5 /*1 col*/ width 80.
            hide frame frame-a no-pause.
            if esqregua
            then do:
                display caps(esqcom1[esqpos1]) @ esqcom1[esqpos1]
                        with frame f-com1.

                if esqcom1[esqpos1] = " Inclusao " or esqvazio
                then do with frame f-opcom on error undo.
                    create opcom.
                    update opcom.
                    update vcod-bc-pf.
                    if vcod-bc-pf <> ""
                    then do:
                        create tabaux.
                        assign
                        tabaux.tabela = "OPCOM" + opccod
                        tabaux.nome_campo = 
                            "Codigo Base de credito Pis e Cofins"
                        tabaux.valor_campo = vcod-bc-pf
                        tabaux.datexp = today
                        tabaux.exportar = yes.   
                    end.
                    recatu1 = recid(opcom).
                    leave.
                end.
                if esqcom1[esqpos1] = " Consulta " or
                   esqcom1[esqpos1] = " Exclusao " or
                   esqcom1[esqpos1] = " Alteracao "
                then do with frame f-opcom.
                    opcom.opcnom:format = "x(50)".
                    disp opcom.
                    find tipmov of opcom no-lock no-error.
                    disp
                        tipmov.movtnom     when avail tipmov
                        tipmov.contapiscof when avail tipmov.
                    find first tabaux where
                        tabaux.tabela = "OPCOM" + opcom.opccod and
                        tabaux.nome_campo = 
                            "Codigo Base de credito Pis e Cofins"
                        no-lock no-error.
                    if avail tabaux
                    then vcod-bc-pf = tabaux.valor_campo.
                    else vcod-bc-pf = "".    

                    disp vcod-bc-pf.
                    pause.
                end.
                if esqcom1[esqpos1] = " Alteracao "
                then do with frame f-opcom on error undo.
                    find opcom where recid(opcom) = recatu1 exclusive.

                    find first tabaux where
                        tabaux.tabela = "OPCOM" + opcom.opccod and
                        tabaux.nome_campo = 
                            "Codigo Base de credito Pis e Cofins"
                         no-error.
                    if avail tabaux
                    then vcod-bc-pf = tabaux.valor_campo.
                    else vcod-bc-pf = "".   
                    
                    update
                        opcom.opccod
                        opcom.opcnom
                        opcom.piscofins
                        opcom.CSTPisCofins
                        opcom.CSTPisCofinsA0
                        vcod-bc-pf
                        opcom.opfcod-st.
                    
                    if avail tabaux
                    then tabaux.valor_campo = vcod-bc-pf.
                    else if vcod-bc-pf <> ""
                    then do:
                        create tabaux.
                        assign
                        tabaux.tabela = "OPCOM" + opccod
                        tabaux.nome_campo = 
                            "Codigo Base de credito Pis e Cofins"
                        tabaux.valor_campo = vcod-bc-pf
                        tabaux.datexp = today
                        tabaux.exportar = yes.   
                    end.
                end.
                if esqcom1[esqpos1] = " Pesquisa "
                then do with frame f-pesq side-label.
                    prompt-for opcom.opccod.
                    find bopcom where bopcom.opccod = input opcom.opccod
                                no-lock no-error.
                    if avail bopcom
                    then recatu1 = recid(bopcom).
                    leave.
                end.
                
                if esqcom1[esqpos1] = " Listagem "
                then do with frame f-Lista:
                    message "Confirma Impressao de Rel. Trib." update sresp.
                    if not sresp
                    then leave.
                    recatu2 = recatu1.
                    output to printer.
                    for each opcom no-lock:
                        display opcom.
                    end.
                    output close.
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
        recatu1 = recid(opcom).
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
    display
        opcom.opccod
        opcom.opcnom   format "x(33)"
        /*opcom.opcant*/
        opcom.movtdc         column-label "Tip!Mov"
        opcom.opctip
        opcom.piscofins      column-label "Pis!Cof"
        opcom.CSTPisCofins   column-label "CST!Pis/Cof"
        opcom.CSTPisCofinsA0 column-label "CST Al.0!Pis/Cof"
        with frame frame-a 11 down centered color white/red row 5.
end procedure.

procedure color-message.
color display message
        opcom.opccod
        opcom.opcnom
        opcom.movtdc
        with frame frame-a.
end procedure.


procedure color-normal.
color display normal
        opcom.opccod
        opcom.opcnom
        opcom.movtdc
        with frame frame-a.
end procedure.


procedure leitura . 
def input parameter par-tipo as char.
        
if par-tipo = "pri" 
then  
    if esqascend  
    then   find first opcom where true no-lock no-error.
    else   find last opcom  where true no-lock no-error.
                                             
if par-tipo = "seg" or par-tipo = "down" 
then  
    if esqascend  
    then   find next opcom  where true no-lock no-error.
    else   find prev opcom   where true no-lock no-error.
             
if par-tipo = "up" 
then                  
    if esqascend   
    then    find prev opcom where true   no-lock no-error.
    else    find next opcom where true  no-lock no-error.
        
end procedure.

