/*
*
*    chq.p    -    Esqueleto de Programacao    com esqvazio


            substituir    chq
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
def var esqcom1         as char format "x(12)" extent 5
    initial [" Marca "," Selecao ",""].
def var esqcom2         as char format "x(12)" extent 5
            initial ["Gera Arquivo"," ","","",""].
def var esqhel1         as char format "x(80)" extent 5.
def var esqhel2         as char format "x(12)" extent 5
   initial ["  ",
            " ",
            " ",
            " ",
            " "].

{admcab.i }

def var vtotal      like chq.valor label "Total".
def var vmarcado    like chq.valor label "Marcado". 
def var vtotsel     like chq.valor label "Selecao".

def buffer bchq       for chq.
def var vchq         like chq.numero.

def new shared temp-table tt-chq
    field rec  as recid
    index rec is primary unique rec asc.

def temp-table tpchq
    field rec   as recid
    field data  like chq.data
    index data  data asc.
    
def var vast    as char.

form 
    vast        no-label format "x" 
    chq.banco       format "999"
    chq.agencia     format "zzzz99"
    chq.conta       
    with frame frame-a.

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

run totaliza.

bl-princ:
repeat:

    disp esqcom1 with frame f-com1.
    disp esqcom2 with frame f-com2.
    if recatu1 = ?
    then
        run leitura (input "pri").
    else
        find tpchq where recid(tpchq) = recatu1 no-lock.
    if not available tpchq
    then esqvazio = yes.
    else esqvazio = no.
    clear frame frame-a all no-pause.
    if not esqvazio
    then do:
        run frame-a.
    end.

    recatu1 = recid(tpchq).
    if esqregua
    then color display message esqcom1[esqpos1] with frame f-com1.
    else color display message esqcom2[esqpos2] with frame f-com2.
    if not esqvazio
    then repeat:
        run leitura (input "seg").
        if not available tpchq
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
            find tpchq where recid(tpchq) = recatu1 no-lock.
            find chq where recid(chq) = tpchq.rec no-lock.
            status default
                if esqregua
                then esqhel1[esqpos1] + if esqpos1 > 1 and
                                           esqhel1[esqpos1] <> ""
                                        then  string(chq.numero)
                                        else ""
                else esqhel2[esqpos2] + if esqhel2[esqpos2] <> ""
                                        then string(chq.numero)
                                        else "".
            find tt-chq where tt-chq.rec = recid(chq) no-error.
            if avail tt-chq
            then esqcom1[1] = " Desmarca ".
            else esqcom1[1] = " Marca ".
            display esqcom1 with frame f-com1.
            run color-message.
            choose field chq.numero help ""
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
                    if not avail tpchq
                    then leave.
                    recatu1 = recid(tpchq).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "page-up"
            then do:
                do reccont = 1 to frame-down(frame-a):
                    run leitura (input "up").
                    if not avail tpchq
                    then leave.
                    recatu1 = recid(tpchq).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "cursor-down"
            then do:
                run leitura (input "down").
                if not avail tpchq
                then next.
                color display normal chq.numero with frame frame-a.
                if frame-line(frame-a) = frame-down(frame-a)
                then scroll with frame frame-a.
                else down with frame frame-a.
            end.
            if keyfunction(lastkey) = "cursor-up"
            then do:
                run leitura (input "up").
                if not avail tpchq
                then next.
                color display normal chq.numero with frame frame-a.
                if frame-line(frame-a) = 1
                then scroll down with frame frame-a.
                else up with frame frame-a.
            end.
 
        if keyfunction(lastkey) = "end-error"
        then leave bl-princ.

        if keyfunction(lastkey) = "return" or esqvazio
        then do:
            form chq
                 with frame f-chq color black/cyan
                      centered side-label row 5 .
            hide frame frame-a no-pause.
            if esqregua
            then do:
                display caps(esqcom1[esqpos1]) @ esqcom1[esqpos1]
                        with frame f-com1.
                if esqcom1[esqpos1] = " Selecao "
                then do: 
                    run selecao.
                    recatu1 = ?.
                    leave.
                end.
                if esqcom1[esqpos1] = " Marca "  or
                   esqcom1[esqpos1] = " desMarca " 
                then do with frame f-chq on error undo.
                    recatu2 = recatu1.
                    find chq where recid(chq) = tpchq.rec no-lock.
                    find tt-chq where tt-chq.rec = recid(chq) no-error.
                    if not avail tt-chq
                    then do:
                        create tt-chq.
                        assign tt-chq.rec = recid(chq).
                        vmarcado = vmarcado + chq.valor.
                    end.
                    else do:
                        vmarcado = vmarcado - chq.valor.
                        delete tt-chq.
                    end.    
                    vast = if avail tt-chq
                           then "*"
                           else "".
                    display vast
                            with frame frame-a.
                    display space(7)
                            vtotal   space(5)
                            vtotsel space(5)
                        vmarcado
                        with side-label no-box color message row 20
                        width 81 frame ftot.
                   /* leave.*/
                end.
            end.
            else do:
                display caps(esqcom2[esqpos2]) @ esqcom2[esqpos2]
                        with frame f-com2.
                if esqcom2[esqpos2] = "Gera Arquivo"
                then do:
                    hide frame f-com1  no-pause.
                    hide frame f-com2  no-pause.
                    run fgchq041.p.
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
        recatu1 = recid(tpchq).
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
find chq where recid(chq) = tpchq.rec no-lock.
find tt-chq where tt-chq.rec = recid(chq) no-lock no-error.
find first chqtit of chq no-lock no-error.
vast = if avail tt-chq
       then "*"
       else "".
display vast
        chqtit.etbcod   column-label "Etb" when avail chqtit
        chq.banco       column-label "Bco"
        chq.agencia     column-label "Agencia"  
        chq.conta
        chq.numero
        chq.datemi      column-label "Emissao"
        chq.data        column-label "Vencimento"
        chq.valor
        chq.exportado
        with frame frame-a 11 down centered row 5.
end procedure.

procedure color-message.
color display message
        chq.banco    chqtit.etbcod
        chq.agencia  
        chq.conta
        chq.numero
        chq.datemi   
        chq.data     
        chq.valor
        chq.exportado
        with frame frame-a.
end procedure.
procedure color-normal.
color display normal
        chq.banco    
        chq.agencia      chqtit.etbcod
        chq.conta
        chq.numero
        chq.datemi   
        chq.data     
        chq.valor
        chq.exportado
        with frame frame-a.            
end procedure.



procedure leitura . 
def input parameter par-tipo as char.
        
if par-tipo = "pri" 
then  
    if esqascend  
    then  
        find first tpchq where true
                                                no-lock no-error.
    else  
        find last tpchq  where true
                                                 no-lock no-error.
                                             
if par-tipo = "seg" or par-tipo = "down" 
then  
    if esqascend  
    then  
        find next tpchq  where true
                                                no-lock no-error.
    else  
        find prev tpchq   where true
                                                no-lock no-error.
             
if par-tipo = "up" 
then                  
    if esqascend   
    then   
        find prev tpchq where true
                                        no-lock no-error.
    else                              
        find next tpchq where true
                                        no-lock no-error.
        
end procedure.
         
         
procedure totaliza.
    vtotal = 0.
    vmarcado = 0.
    for each tpchq.
        delete tpchq.
    end.
    for each tt-chq.
        delete tt-chq.
    end.
    for each chq where chq.exportado  = no no-lock.
        create tpchq.
        assign tpchq.rec = recid(chq)
               tpchq.data = chq.datemi.
        find tt-chq where tt-chq.rec = recid(chq) no-lock no-error.
        vtotal = vtotal + chq.valor.
        vmarcado = vmarcado + if avail tt-chq
                              then chq.valor 
                              else 0.
    end.
    display vtotsel 
            vtotal 
            vmarcado
            
            with side-label no-box color message row 20
                        width 81 frame ftot.
end procedure.

procedure selecao.

def var tetbcod    like estab.etbcod.
def var tdtemiini as   date format "99/99/9999".
def var tdtemifim as   date format "99/99/9999". 
def var tdtvenini as   date format "99/99/9999".
def var tdtvenfim as   date format "99/99/9999".

update tetbcod      colon 19 
        with frame fffff. 
find estab where estab.etbcod = tetbcod no-lock no-error.
display if avail estab
        then estab.etbnom
        else "Geral" @ estab.etbnom no-label skip(1)
        with frame fffff.
update tdtemiini    colon 19 label "Emissao" " a "
       tdtemifim    no-label                          skip(1)
       tdtvenini    colon 19 label "Vencimento" " a "
       tdtvenfim    no-label
       with color message side-label overlay frame fffff centered
                width 80 row 8.

for each tt-chq.
    delete tt-chq.
end.
for each tpchq.
    delete tpchq.
end. 
for each chq where chq.exportado  = no no-lock. 
    if tdtvenini <> ? or
       tdtvenfim <> ?
    then
        if chq.data >= tdtvenini and
           chq.data <= tdtvenfim
        then.
        else next.
    if tdtemiini <> ? or
       tdtemifim <> ?
    then
        if chq.datemi >= tdtemiini and
           chq.datemi <= tdtemifim
        then.
        else next.    
    if tetbcod <> 0
    then do:
        find first chqtit of chq no-lock no-error.
        if not avail chqtit
        then next.
        if chqtit.etbcod <> tetbcod
        then next.
    end. 
    create tpchq.  
    assign tpchq.rec = recid(chq) 
           tpchq.data = chq.datemi. 
    vtotsel = vtotsel + chq.valor.
    display vtotsel    vmarcado vtotal
            with frame ftot.
end.
recatu1 = ?.
end procedure.


         
