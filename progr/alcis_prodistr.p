/* alcis_prodistr.p */
{admcab.i }

/***
for each prodistr where prodistr.Tipo         = "BLOQ_ALCIS" and
                        prodistr.etbcod       = 995          and
                        prodistr.lipsit       = "A" no-lock.
    find produ where produ.procod = prodistr.procod no-lock no-error. 
    if avail produ 
    then run alcis/sinc_prodistr.p (input prodistr.procod).    
end.
***/

def var par-sit as char init "A".

find first prodistr where 
                    prodistr.Tipo         = "BLOQ_ALCIS" and
                    prodistr.etbcod       = 995          and
                    prodistr.lipsit       = par-sit
                    no-lock no-error.
if not avail prodistr
then par-sit = "F".

def var recatu1         as recid.
def var reccont         as int.
def var esqpos1         as int.
def var esqvazio        as log.
def var esqascend     as log initial yes.
def var esqcom1         as char format "x(12)" extent 5
    initial [" Abertos "," Listagem "," Historico ",""].


def var primeiro as log.
def var vbusca          like titulo.titnum.
def var recatu2 as recid.
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
        find prodistr where recid(prodistr) = recatu1 no-lock.
    if not available prodistr
    then esqvazio = yes.
    else esqvazio = no.
    clear frame frame-a all no-pause.
    if not esqvazio
    then run frame-a.
    else do.
        message "Nenhum produto na situacao" par-sit view-as alert-box.
        leave.
    end.        

    recatu1 = recid(prodistr).
    color display message esqcom1[esqpos1] with frame f-com1.
    if not esqvazio
    then repeat:
        run leitura (input "seg").
        if not available prodistr
        then leave.
        if frame-line(frame-a) = frame-down(frame-a)
        then leave.
        down with frame frame-a.
        run frame-a.
    end.
    if not esqvazio
    then up frame-line(frame-a) - 1 with frame frame-a.

    repeat with frame frame-a:

        if not esqvazio
        then do:
            find prodistr where recid(prodistr) = recatu1 no-lock.

            if par-sit = "A"
            then esqcom1[1] = " Fechados ".
            else esqcom1[1] = " Abertos ".
            display esqcom1
                    with frame f-com1.

            status default "".
            run color-message.
            choose field prodistr.procod help ""
                go-on(cursor-down cursor-up
                      1 2 3 4 5 6 7 8 9 0
                      cursor-left cursor-right
                      page-down   page-up
                      PF4 F4 ESC return) .
            if keyfunction(lastkey) = "0" or keyfunction(lastkey) = "1" or
               keyfunction(lastkey) = "2" or keyfunction(lastkey) = "3" or
               keyfunction(lastkey) = "4" or keyfunction(lastkey) = "5" or
               keyfunction(lastkey) = "6" or keyfunction(lastkey) = "7" or
               keyfunction(lastkey) = "8" or keyfunction(lastkey) = "9" 
            then do with centered row 8 color message
                                frame f-procura side-label overlay.
                vbusca = keyfunction(lastkey).
                pause 0.
                primeiro = yes.
                update vbusca label "Produto"
                    editing:
                        if primeiro
                        then do:
                            apply keycode("cursor-right").
                            primeiro = no.
                        end.
                    readkey.
                    apply lastkey.
                end.
                find last prodistr where 
                        prodistr.Tipo         = "BLOQ_ALCIS" and
                        prodistr.etbcod       = 995          and
                        prodistr.lipsit       = par-sit      and
                        prodistr.procod  = int(vbusca)
                                                no-lock no-error.
                if avail prodistr
                then recatu1 = recid(prodistr). 
                else recatu1 = recatu2. 
                leave.
            end.
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
                    if not avail prodistr
                    then leave.
                    recatu1 = recid(prodistr).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "page-up"
            then do:
                do reccont = 1 to frame-down(frame-a):
                    run leitura (input "up").
                    if not avail prodistr
                    then leave.
                    recatu1 = recid(prodistr).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "cursor-down"
            then do:
                run leitura (input "down").
                if not avail prodistr
                then next.
                color display white/red prodistr.procod with frame frame-a.
                if frame-line(frame-a) = frame-down(frame-a)
                then scroll with frame frame-a.
                else down with frame frame-a.
            end.
            if keyfunction(lastkey) = "cursor-up"
            then do:
                run leitura (input "up").
                if not avail prodistr
                then next.
                color display white/red prodistr.procod with frame frame-a.
                if frame-line(frame-a) = 1
                then scroll down with frame frame-a.
                else up with frame frame-a.
            end.
 
        if keyfunction(lastkey) = "end-error"
        then leave bl-princ.

        if keyfunction(lastkey) = "return" or esqvazio
        then do:
                hide frame frame-a no-pause.

                display caps(esqcom1[esqpos1]) @ esqcom1[esqpos1]
                        with frame f-com1.

                if esqcom1[esqpos1] = " Fechados "
                then do.
                    par-sit = "F".
                    recatu1 = ?.
                    leave.
                end.
                if esqcom1[esqpos1] = " Abertos "
                then do.
                    par-sit = "A".
                    recatu1 = ?.
                    leave.
                end.
                if esqcom1[esqpos1] = " Historico "
                then do.
                    hide frame f-com1  no-pause. 
                    hide frame f-com2  no-pause.
                    pause 0.
                    run alcis/hprodistr.p (recatu1).
                    view frame f-com1. 
                    view frame f-com2.
                end.
                if esqcom1[esqpos1] = " Listagem "
                then do:
                    run listagem.
                    recatu1 = ?.                    
                    leave.
                end.
        end.
        if not esqvazio
        then do:
            run frame-a.
        end.
        display esqcom1[esqpos1] with frame f-com1.
        recatu1 = recid(prodistr).
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

    find produ of prodistr no-lock.
    find estoq where estoq.procod = produ.procod and
                     estoq.etbcod = 995 no-lock no-error.   
    display prodistr.predt
        prodistr.procod
        produ.pronom format "x(25)"
        prodistr.lipqtd format ">>>>>,>>9" column-label "Qtd"
        prodistr.preqtent column-label "Qtd.Desbloq" format ">>>>>,>>9"
        estoq.estatual format "->>>>>9" column-label "Estoq CD"
        prodistr.lipsit
        with frame frame-a screen-lines - 9 down color white/red row 5.
end procedure.


procedure color-message.
color display message
        prodistr.procod
        produ.pronom
        with frame frame-a.
end procedure.


procedure color-normal.
color display normal
        prodistr.procod
        produ.pronom
        with frame frame-a.
end procedure.


procedure leitura . 
def input parameter par-tipo as char.
        
if par-tipo = "pri" 
then  
    if esqascend  
    then  
        find first prodistr where 
                    prodistr.Tipo         = "BLOQ_ALCIS" and
                    prodistr.etbcod       = 995          and
                    prodistr.lipsit       = par-sit
                                                no-lock no-error.
    else  
        find last prodistr  where 
                    prodistr.Tipo         = "BLOQ_ALCIS" and
                    prodistr.etbcod       = 995          and
                    prodistr.lipsit       = par-sit
                                                 no-lock no-error.
                                             
if par-tipo = "seg" or par-tipo = "down" 
then  
    if esqascend  
    then  
        find next prodistr  where 
                    prodistr.Tipo         = "BLOQ_ALCIS" and
                    prodistr.etbcod       = 995          and
                    prodistr.lipsit       = par-sit
                                                no-lock no-error.
    else  
        find prev prodistr   where  
                    prodistr.Tipo         = "BLOQ_ALCIS" and
                    prodistr.etbcod       = 995          and
                    prodistr.lipsit       = par-sit
                                                no-lock no-error.
             
if par-tipo = "up" 
then                  
    if esqascend   
    then   
        find prev prodistr where   
                    prodistr.Tipo         = "BLOQ_ALCIS" and
                    prodistr.etbcod       = 995          and
                    prodistr.lipsit       = par-sit
                                        no-lock no-error.
    else   
        find next prodistr where 
                    prodistr.Tipo         = "BLOQ_ALCIS" and
                    prodistr.etbcod       = 995          and
                    prodistr.lipsit       = par-sit
                                        no-lock no-error.
        
end procedure.
         

procedure listagem.

def var varquivo as char.
varquivo = "../relat/prodistr." + string(time).
{mdad_l.i
            &Saida     = "value(varquivo)"
            &Page-Size = "0"
            &Cond-Var  = "80"
            &Page-Line = "66"
            &Nom-Rel   = ""prodistr""
            &Nom-Sis   = """INTEGRACAO WMS ALCIS"""
            &Tit-Rel   = """PRODUTOS BLOQUEADOS PELO ALCIS"""
            &Width     = "80"
            &Form      = "frame f-cabcab"}
for each prodistr   where  
                    prodistr.Tipo         = "BLOQ_ALCIS" and
                    prodistr.etbcod       = 995          and
                    prodistr.lipsit       = par-sit
                                                no-lock.
    run frame-a.
    down with frame frame-a.
end.
output close.
    
if opsys = "UNIX" 
then run visurel.p (input varquivo, input ""). 
else do: 
    {mrod.i}
end.

end procedure.
