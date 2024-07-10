/*
*
*    ttcontrato.p    -    Esqueleto de Programacao    com esqvazio


            substituir    ttcontrato
                          <tab>
*
*/

def var recatu1         as recid.
def var recatu2         as recid.
def var reccont         as int.
def var esqpos1         as int.
def var esqpos2         as int.
def var esqregua        as log.
def var esqvazio        as log.
def var esqascend     as log initial yes.
def var vbusca          like titulo.titnum.
def var primeiro as log.
def var esqcom1         as char format "x(12)" extent 5
    initial [" Titulos "," ","  "].
def var esqcom2         as char format "x(12)" extent 5
            initial [" "," ","","",""].
def var esqhel1         as char format "x(80)" extent 5.
def var esqhel2         as char format "x(12)" extent 5
   initial ["  ",
            " ",
            " ",
            " ",
            " "].
{cabec.i}

def input parameter par-clicod  like titulo.clifor .

def temp-table ttcontrato 
    field etbcod    like estab.etbcod
    field titnum    like titulo.titnum
    field modcod    like titulo.modcod
    field NPc       as   int format ">>9"
    field dtemi     like titulo.titdtemi
    field vlctr     like titulo.titvlcob    column-label "Total"
    field vpago     like titulo.titvlcob    column-label "Pago"
    index titnum    is primary unique titnum asc.
    
    
def new shared temp-table ttparc
    field titnum    like titulo.titnum
    field titpar    like titulo.titpar
    field modcod    like titulo.modcod
    field titdtemi  like titulo.titdtemi
    field rec       as   recid
    index titnum    is   primary       titnum asc
                                       titpar asc
                                       modcod asc
                                       titdtemi asc
    index rec is unique  rec asc.                                      

for each ttcontrato.
    delete ttcontrato.
end.
for each ttparc.
    delete ttparc.
end.
def var vtitnat as log.
vtitnat = if sretorno = "yes"
          then yes
          else no.
for each titulo use-index iclicod where titulo.titnat = vtitnat and
                      titulo.clifor = par-clicod        no-lock.
    if titulo.titdtpag = 01/01/1111 then next.
    find  ttcontrato where ttcontrato.titnum = titulo.titnum    
/*                       and ttcontrato.modcod = titulo.modcod*/
                           no-error.
    if not avail ttcontrato
    then create ttcontrato.
    assign ttcontrato.etbcod = titulo.etbcod
           ttcontrato.titnum = titulo.titnum  
           ttcontrato.dtemi  = titulo.titdtemi
           ttcontrato.modcod = titulo.modcod
           ttcontrato.NPc    = ttcontrato.NPc + 1
           ttcontrato.vlctr  = ttcontrato.vlctr + titulo.titvlcob
           ttcontrato.vpago  = ttcontrato.vpago + titulo.titvlpag.
    create ttparc .
    assign ttparc.titnum = titulo.titnum
           ttparc.titpar = titulo.titpar
           ttparc.modcod = titulo.modcod
           ttparc.titdtemi = titulo.titdtemi
           ttparc.rec    = recid(titulo).
end.                       

def buffer bttcontrato       for ttcontrato.
def var vttcontrato         like ttcontrato.titnum.


form
    esqcom1
    with frame f-com1
                 row 10 no-box no-labels side-labels column 1 centered.

form
    esqcom2
    with frame f-com2
                 row screen-lines no-box no-labels side-labels column 1
                 centered.
assign
    esqregua = yes
    esqpos1  = 1
    esqpos2  = 1.

form
    ttcontrato.etbcod
    with frame frame-a.
    
bl-princ:
repeat:

    disp esqcom1 with frame f-com1.
    if recatu1 = ?
    then
        run leitura (input "pri").
    else
        find ttcontrato where recid(ttcontrato) = recatu1 no-lock.
    if not available ttcontrato
    then esqvazio = yes.
    else esqvazio = no.
    clear frame frame-a all no-pause.
    if not esqvazio
    then do:
        run frame-a.
    end.

    recatu1 = recid(ttcontrato).
    if esqregua
    then color display message esqcom1[esqpos1] with frame f-com1.
    else color display message esqcom2[esqpos2] with frame f-com2.
    if not esqvazio
    then repeat:
        run leitura (input "seg").
        if not available ttcontrato
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
            find ttcontrato where recid(ttcontrato) = recatu1 no-lock.

            status default
                if esqregua
                then esqhel1[esqpos1] + if esqpos1 > 1 and
                                           esqhel1[esqpos1] <> ""
                                        then  string(ttcontrato.titnum)
                                        else ""
                else esqhel2[esqpos2] + if esqhel2[esqpos2] <> ""
                                        then string(ttcontrato.titnum)
                                        else "".

            choose field ttcontrato.titnum help ""
                go-on(cursor-down cursor-up
                      cursor-left cursor-right
                      page-down   page-up
                      1 2 3 4 5 6 7 8 9 0

                      PF4 F4 ESC return) .

            status default "".
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
                update vbusca
                    editing:
                        if primeiro
                        then do:
                            apply keycode("cursor-right").
                            primeiro = no.
                        end.
                    readkey.
                    apply lastkey.
                end. 
                recatu2  = recatu1.
                find first ttcontrato where ttcontrato.titnum = 
                            vbusca no-error.
                if avail ttcontrato 
                then recatu1 = recid(ttcontrato).
                else recatu1 = recatu2.
                next bl-princ.
            end.

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
                    if not avail ttcontrato
                    then leave.
                    recatu1 = recid(ttcontrato).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "page-up"
            then do:
                do reccont = 1 to frame-down(frame-a):
                    run leitura (input "up").
                    if not avail ttcontrato
                    then leave.
                    recatu1 = recid(ttcontrato).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "cursor-down"
            then do:
                run leitura (input "down").
                if not avail ttcontrato
                then next.
                color display white/red ttcontrato.titnum with frame frame-a.
                if frame-line(frame-a) = frame-down(frame-a)
                then scroll with frame frame-a.
                else down with frame frame-a.
            end.
            if keyfunction(lastkey) = "cursor-up"
            then do:
                run leitura (input "up").
                if not avail ttcontrato
                then next.
                color display white/red ttcontrato.titnum with frame frame-a.
                if frame-line(frame-a) = 1
                then scroll down with frame frame-a.
                else up with frame frame-a.
            end.
 
        if keyfunction(lastkey) = "end-error"
        then leave bl-princ.

        if keyfunction(lastkey) = "return" or esqvazio
        then do:
            form ttcontrato
                 with frame f-ttcontrato color black/cyan
                      centered side-label row 5 .
            hide frame frame-a no-pause.
            if esqregua
            then do:
                display caps(esqcom1[esqpos1]) @ esqcom1[esqpos1]
                        with frame f-com1.

                if esqcom1[esqpos1] = " titulos "
                then do with frame f-Lista:
                    hide frame f-com1 no-pause.
                    run fin/fqconttit.p (ttcontrato.titnum).
                    view frame f-com1.
                end.
            end.
            else do:
                display caps(esqcom2[esqpos2]) @ esqcom2[esqpos2]
                        with frame f-com2.
                if esqcom2[esqpos2] = "  "
                then do:
                    hide frame f-com1  no-pause.
                    view frame f-com1.
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
        recatu1 = recid(ttcontrato).
    end.
    if keyfunction(lastkey) = "end-error"
    then do:
        view frame fc1.
        view frame fc2.
    end.
end.
pause 0.
hide frame f-com1  no-pause.
hide frame f-com2  no-pause.
hide frame frame-a no-pause.

procedure frame-a.
def var vsaldo  like titulo.titvlcob column-label "Saldo"
                    format "->>>,>>9.99".

def var vultpgto    like titulo.titdtpag.
def var vatraso as int.
vsaldo   = ttcontrato.vlctr - ttcontrato.vpago .
vultpgto = 01/01/0001.
vatraso  = 0.
for each ttparc of ttcontrato.
    find titulo where recid(titulo) = ttparc.rec no-lock.
    if titulo.titdtpag <> ?
    then
        vultpgto = max(vultpgto,titulo.titdtpag).
    else
        if titulo.titdtven < today
        then
            vatraso = max(vatraso,today - titulo.titdtven).
end.
if vultpgto = 01/01/0001
then vultpgto = ?.
display ttcontrato.etbcod   column-label "Etb"
        ttcontrato.titnum   
        ttcontrato.modcod   
        ttcontrato.NPc      
        ttcontrato.dtemi    format "999999"
        ttcontrato.vlctr    format "->>>>,>>9.99"
        vsaldo  format "->>>>,>>9.99"

        vultpgto    column-label "Ult.Pagto" format "99/99/9999"
        vatraso     column-label "atraso" format ">>>9"
                with frame frame-a 8 down centered 
                /*color white/red*/ row 13
                                no-box width 80.

end procedure.

procedure leitura . 
def input parameter par-tipo as char.
        
if par-tipo = "pri" 
then  
    if esqascend  
    then  
        find first ttcontrato where true
                                                no-lock no-error.
    else  
        find last ttcontrato  where true
                                                 no-lock no-error.
                                             
if par-tipo = "seg" or par-tipo = "down" 
then  
    if esqascend  
    then  
        find next ttcontrato  where true
                                                no-lock no-error.
    else  
        find prev ttcontrato   where true
                                                no-lock no-error.
             
if par-tipo = "up" 
then                  
    if esqascend   
    then   
        find prev ttcontrato where true  
                                        no-lock no-error.
    else   
        find next ttcontrato where true 
                                        no-lock no-error.
        
end procedure.
         
