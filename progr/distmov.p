{admcab.i}

def buffer bpedid for pedid.
def var v-correto as log.
def var dsresp as log.
def var vprocod like produ.procod format ">>>>>>>9".
def var vqtddis as   int format ">>>>>9".

def temp-table tt-dis
    field etbcod like estab.etbcod
    field etbnom like estab.etbnom
    field qtddis as   int format ">>>>>9"
    index i-etbcod is primary unique etbcod.

/*vprocod = 401790.*/

update vprocod label "Produto" colon 17
       with frame f-dados width 80 side-labels.
find produ where produ.procod = vprocod no-lock no-error.
if not avail produ
then do:
    message "Produto nao cadastrado".
    undo.
end.
else do:
    
    if produ.catcod = 31
    then disp produ.pronom no-label with frame f-dados.
    else do:
        message "Distribuicao permitida somente para Moveis.".
        undo.
    end.        
end.

update vqtddis label "Qtd a distribuir"
       with frame f-dados.

def var vqtd-sobra as int.

vqtd-sobra = vqtddis.

for each estab where estab.etbcod < 900 no-lock.
    if {conv_igual.i estab.etbcod} then next.

    find tt-dis where tt-dis.etbcod = estab.etbcod no-error.
    if not avail tt-dis
    then do:
        create tt-dis.
        assign tt-dis.etbcod = estab.etbcod
               tt-dis.etbnom = estab.etbnom.
        if vqtd-sobra > 0
        then tt-dis.qtddis = 1.
        else tt-dis.qtddis = 0.

        vqtd-sobra = vqtd-sobra - 1.

    end.
end.

create tt-dis.
assign tt-dis.etbcod = 995
       tt-dis.etbnom = "DREBES & CIA LTDA DEP-995".
if vqtd-sobra > 0
then tt-dis.qtddis = vqtd-sobra.

def var recatu1         as recid.
def var recatu2         as recid.
def var reccont         as int.
def var esqpos1         as int.
def var esqpos2         as int.
def var esqregua        as log.
def var esqvazio        as log.
def var esqascend     as log initial yes.
def var esqcom1         as char format "x(12)" extent 5
    initial [" Alteracao "," "," "," "," "].
def var esqcom2         as char format "x(12)" extent 5
            initial [" "," ","","",""].
def var esqhel1         as char format "x(80)" extent 5
    initial [" ",
             " ",
             " ",
             " ",
             " "].
def var esqhel2         as char format "x(12)" extent 5
   initial ["  ",
            " ",
            " ",
            " ",
            " "].


def buffer btt-dis       for tt-dis.
def var vtt-dis         like tt-dis.etbcod.


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
        find tt-dis where recid(tt-dis) = recatu1 no-lock.
    if not available tt-dis
    then esqvazio = yes.
    else esqvazio = no.
    clear frame frame-a all no-pause.
    if not esqvazio
    then do:
        run frame-a.
    end.

    recatu1 = recid(tt-dis).
    if esqregua
    then color display message esqcom1[esqpos1] with frame f-com1.
    else color display message esqcom2[esqpos2] with frame f-com2.
    if not esqvazio
    then repeat:
        run leitura (input "seg").
        if not available tt-dis
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
            find tt-dis where recid(tt-dis) = recatu1 no-lock.

            status default
                if esqregua
                then esqhel1[esqpos1] + if esqpos1 > 1 and
                                           esqhel1[esqpos1] <> ""
                                        then  string(tt-dis.etbnom)
                                        else ""
                else esqhel2[esqpos2] + if esqhel2[esqpos2] <> ""
                                        then string(tt-dis.etbnom)
                                        else "".
            run color-message.
            choose field tt-dis.etbcod 
                         tt-dis.etbnom
                         tt-dis.qtddis help ""
                go-on(cursor-down cursor-up
                      cursor-left cursor-right
                      page-down   page-up
                      tab PF4 F4 ESC return).
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
                    if not avail tt-dis
                    then leave.
                    recatu1 = recid(tt-dis).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "page-up"
            then do:
                do reccont = 1 to frame-down(frame-a):
                    run leitura (input "up").
                    if not avail tt-dis
                    then leave.
                    recatu1 = recid(tt-dis).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "cursor-down"
            then do:
                run leitura (input "down").
                if not avail tt-dis
                then next.
                color display white/red tt-dis.etbcod 
                                        tt-dis.etbnom
                                        tt-dis.qtddis
                                        with frame frame-a.
                if frame-line(frame-a) = frame-down(frame-a)
                then scroll with frame frame-a.
                else down with frame frame-a.
            end.
            if keyfunction(lastkey) = "cursor-up"
            then do:
                run leitura (input "up").
                if not avail tt-dis
                then next.
                color display white/red tt-dis.etbcod 
                                        tt-dis.etbnom
                                        tt-dis.qtddis
                                        with frame frame-a.
                if frame-line(frame-a) = 1
                then scroll down with frame frame-a.
                else up with frame frame-a.
            end.
 
        if keyfunction(lastkey) = "end-error"
        then do:

            run p-finaliza(output v-correto).
            recatu1 = ?.
            if v-correto
            then
                leave bl-princ.
        end.            

        if keyfunction(lastkey) = "return" or esqvazio
        then do:
            form tt-dis
                 with frame f-tt-dis color black/cyan
                      centered side-label row 5 .
            hide frame frame-a no-pause.
            if esqregua
            then do:
                display caps(esqcom1[esqpos1]) @ esqcom1[esqpos1]
                        with frame f-com1.

                if esqcom1[esqpos1] = " Inclusao " or esqvazio
                then do with frame f-tt-dis on error undo.
                    create tt-dis.
                    update tt-dis.
                    recatu1 = recid(tt-dis).
                    leave.
                end.
                if esqcom1[esqpos1] = " Consulta " or
                   esqcom1[esqpos1] = " Exclusao " 
                then do with frame f-tt-dis.
                    disp tt-dis.
                end.
                if esqcom1[esqpos1] = " Alteracao "
                then do with frame frame-a.
                    update tt-dis.qtddis.
                end.
                if esqcom1[esqpos1] = " Exclusao "
                then do with frame f-exclui  row 5 1 column centered
                        on error undo.
                    message "Confirma Exclusao de" tt-dis.etbnom
                            update sresp.
                    if not sresp
                    then undo, leave.
                    find next tt-dis where true no-error.
                    if not available tt-dis
                    then do:
                        find tt-dis where recid(tt-dis) = recatu1.
                        find prev tt-dis where true no-error.
                    end.
                    recatu2 = if available tt-dis
                              then recid(tt-dis)
                              else ?.
                    find tt-dis where recid(tt-dis) = recatu1
                            exclusive.
                    delete tt-dis.
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
                    then run ltt-dis.p (input 0).
                    else run ltt-dis.p (input tt-dis.etbcod).
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
        recatu1 = recid(tt-dis).
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
display tt-dis.etbcod column-label "Codigo" 
        tt-dis.etbnom column-label "Filial" format "x(50)"
        tt-dis.qtddis column-label "Quantidade!Distribuir"
        with frame frame-a 11 down centered color white/red row 5.
end procedure.
procedure color-message.
color display message
        tt-dis.etbcod
        tt-dis.etbnom
        tt-dis.qtddis
        with frame frame-a.
end procedure.
procedure color-normal.
color display normal
        tt-dis.etbcod
        tt-dis.etbnom
        tt-dis.qtddis
        with frame frame-a.
end procedure.




procedure leitura . 
def input parameter par-tipo as char.
        
if par-tipo = "pri" 
then  
    if esqascend  
    then  
        find first tt-dis where true
                                                no-lock no-error.
    else  
        find last tt-dis  where true
                                                 no-lock no-error.
                                             
if par-tipo = "seg" or par-tipo = "down" 
then  
    if esqascend  
    then  
        find next tt-dis  where true
                                                no-lock no-error.
    else  
        find prev tt-dis   where true
                                                no-lock no-error.
             
if par-tipo = "up" 
then                  
    if esqascend   
    then   
        find prev tt-dis where true  
                                        no-lock no-error.
    else   
        find next tt-dis where true 
                                        no-lock no-error.
        
end procedure.
         
procedure p-finaliza:
    def var vqtd as int.
    def output parameter p-correto as log.    
    def buffer bttdis for tt-dis.
    vqtd = 0.
    for each btt-dis:
       vqtd = vqtd + btt-dis.qtddis.     
    end.    
    
    p-correto = yes.

    if vqtd <> vqtddis
    then do:
        p-correto = no.
        run msg2.p (input-output dsresp, 
                    
                    input "           DIVERGENCIA NA DISTRIBUICAO" 
                        + " !!" 
                        + "     QUANTIDADE A DISTRIBUIR: " 
                        + STRING(VQTDDIS,">>>>>>9")
                        + " !"
                        + "     QUANTIDADE DISTRIBUIDA.: " 
                        + STRING(VQTD,">>>>>>9")
                        + " !"
                        + "     D I V E R G E N C I A..: "
                        + STRING((VQTD - VQTDDIS),"->>>>>9"),
                    input " *** ATENCAO *** ", 
                    input "    OK").
   
    end.
    else do:
        message "Confirma a distribuicao do produto?" update sresp.
        if sresp
        then do:
            message "criou liped.". pause 2 no-message.

            /*** Cria liped ***/
                  
            for each btt-dis where btt-dis.etbcod <> 995
                               and btt-dis.qtddis <> 0:

                find last pedid where pedid.pedtdc = 3 
                                  and pedid.etbcod = btt-dis.etbcod
                                  and pedid.sitped = "E"
                                  and pedid.pednum >= 100000 no-lock no-error.
                if not avail pedid
                then do:
                    find last bpedid where bpedid.pedtdc = 3 
                                       and bpedid.etbcod = btt-dis.etbcod
                                       and bpedid.pednum >= 100000 
                                       no-error.

                    create pedid.
                    assign pedid.etbcod = btt-dis.etbcod
                           pedid.pedtdc = 3
                           pedid.peddat = today
                           pedid.pednum = (if avail bpedid
                                           then bpedid.pednum + 1
                                           else 100000)
                           pedid.sitped = "E" 
                           pedid.pedsit = yes.
                           
                end.
                
                find first liped where liped.etbcod = pedid.etbcod
                                   and liped.pedtdc = pedid.pedtdc
                                   and liped.pednum = pedid.pednum
                                   and liped.procod = vprocod no-error.
                if not avail liped
                then do:
                    
                    create liped.
                    assign liped.etbcod = pedid.etbcod
                           liped.pedtdc = pedid.pedtdc
                           liped.pednum = pedid.pednum
                           liped.procod = vprocod
                           liped.lipqtd = btt-dis.qtd.
                    
                end.
                else liped.lipqtd = liped.lipqtd + btt-dis.qtd.
            
            end.
            
            /******************/
            
            p-correto = yes.
        end.
        else do:
            message "Desistir da distribuicao?" update sresp.
            if sresp
            then p-correto = yes.
            else p-correto = no.
        end.
    end.    
end procedure.
