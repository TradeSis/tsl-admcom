/*
*
*    lipedpai.p    -    Esqueleto de Programacao    com esqvazio
*
*/
{admcab.i}

def input parameter par-rec         as recid.

def var vlipqtd     like liped.lipqtd.
def var vpreqtent   like liped.lipent.
def var vlipqtdcanc like liped.lipqtdcanc.
def var vpreco like lipedpai.lippreco.
def var vtotal      like lipedpai.lippreco.
def var vi          as int.
def buffer blipedpai       for lipedpai.
 
def var recatu1         as recid.
def var recatu2         as recid.
def var reccont         as int.
def var esqpos1         as int.
def var esqvazio        as log.
def var esqcom1         as char format "x(12)" extent 5.

form
    esqcom1
    with frame f-com1 row screen-lines no-box no-labels column 1 centered
            overlay.

form
    pedid.pedtot
    with frame f-pedtot width 80 side-label row 6 col 52 overlay no-box.

assign
    esqpos1  = 1.

find pedid  where recid(pedid) = par-rec no-lock.

assign
    esqcom1[1] = if pedid.pedsit /*pedid.sitped <> "A"*/
                 then "1.Consulta "
                 else "1.Inclusao "
    esqcom1[2] = if pedid.pedsit
                 then ""
                 else "2.Preco "
    esqcom1[4] = if pedid.pedsit
                 then ""
                 else "4.Exclui "
    esqcom1[5] = "6.Indiv".

pause 0.
display " " format "x(25)"  "P R O D U T O S  P A I" 
    with frame fprod centered width 80 no-box color message row 9 overlay.

display pedid.pedtot
    with frame f-pedtot.

bl-princ:
repeat:
    disp esqcom1 with frame f-com1.
    if recatu1 = ?
    then run leitura("pri").
    else find lipedpai where recid(lipedpai) = recatu1 no-lock.
    if not available lipedpai
    then do:
        esqvazio = yes.
        if pedid.sitped = "F" or pedid.sitped = "C"
        then leave.
    end.
    else esqvazio = no.
    clear frame frame-a all no-pause.
    if not esqvazio
    then run frame-a.

    recatu1 = recid(lipedpai).
    color display message esqcom1[esqpos1] with frame f-com1.
    if not esqvazio
    then repeat:
        run leitura("seg").
        if not available lipedpai
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
            find lipedpai where recid(lipedpai) = recatu1 no-lock.

              find produpai of lipedpai no-lock.
              find fabri of produpai no-lock.
              find pack of lipedpai no-lock.
              disp produpai.itecod
                   produpai.pronom no-label format "x(40)"
                   pack.qtde
                   fabri.fabcod
                   fabri.fabnom no-label
                   with frame fsub row screen-lines - 2 overlay no-box
                        width 80 side-label.

            status default "".

            run color-message.
            choose field lipedpai.itecod help ""
                go-on(cursor-down cursor-up
                      cursor-left cursor-right
                      page-down   page-up
                      1 2 3 4 5  
                      PF4 F4 ESC return).

            run color-normal.
            status default "".

        end.
            if keyfunction(lastkey) = "1" or  
               keyfunction(lastkey) = "2" or  
               keyfunction(lastkey) = "3" or  
               keyfunction(lastkey) = "4" or  
               keyfunction(lastkey) = "5"  or
               keyfunction(lastkey) = "6"
            then do:
                color display normal esqcom1[esqpos1] with frame f-com1.
                esqpos1 = int(keyfunction(lastkey)).
                color display message esqcom1[esqpos1] with frame f-com1.
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
                    if not avail lipedpai
                    then leave.
                    recatu1 = recid(lipedpai).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "page-up"
            then do:
                do reccont = 1 to frame-down(frame-a):
                    run leitura (input "up").
                    if not avail lipedpai
                    then leave.
                    recatu1 = recid(lipedpai).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "cursor-down"
            then do:
                run leitura (input "down").
                if not avail lipedpai
                then next.
                color display white/red lipedpai.itecod with frame frame-a.
                if frame-line(frame-a) = frame-down(frame-a)
                then scroll with frame frame-a.
                else down with frame frame-a.
            end.
            if keyfunction(lastkey) = "cursor-up"
            then do:
                run leitura (input "up").
                if not avail lipedpai
                then next.
                color display white/red lipedpai.itecod with frame frame-a.
                if frame-line(frame-a) = 1
                then scroll down with frame frame-a.
                else up with frame frame-a.
            end.

        if keyfunction(lastkey) = "end-error"
        then leave bl-princ.

        if keyfunction(lastkey) = "return" or esqvazio or
           keyfunction(lastkey) = "1" or 
           keyfunction(lastkey) = "2" or 
           keyfunction(lastkey) = "3" or 
           keyfunction(lastkey) = "4" or 
           keyfunction(lastkey) = "5" or 
           keyfunction(lastkey) = "6" or 
           keyfunction(lastkey) = "7" or 
           keyfunction(lastkey) = "8" or 
           keyfunction(lastkey) = "9"  
        then do:
            display caps(esqcom1[esqpos1]) @ esqcom1[esqpos1]
                    with frame f-com1.
            if esqcom1[esqpos1] = "1.Inclusao " or esqvazio
            then do:
                if not esqvazio
                then if pedid.sitped = "F"
                     then return.
                hide frame frame-a no-pause.
                hide frame f-com1  no-pause.
                hide frame fsub    no-pause.
                run co_lipedp.p (input recid(pedid),
                                 input ?,
                                 "").
                run totaliza.
                recatu1 = ?.
                leave.
            end.
            if esqcom1[esqpos1] = "2.Preco "
            then do.
                    hide frame frame-a no-pause.
                    hide frame f-com1  no-pause.
                    hide frame fsub    no-pause.
                    run co_lipedp.p (recid(pedid),
                                     recid(lipedpai),
                                     "Alt").
                    view frame frame-a.
                    view frame f-com1.
                    view frame fsub.
                    run totaliza.
            end.
                if esqcom1[esqpos1] = "1.Consulta "
                then do.
                    hide frame frame-a no-pause.
                    hide frame f-com1  no-pause.
                    hide frame fsub    no-pause.
                    run co_lipedp.p (recid(pedid) ,
                                     recid(lipedpai),
                                     "Con").
                    view frame frame-a.
                    view frame f-com1.
                    view frame fsub.
                end.
/***
               if esqcom1[esqpos1] = "3.Quantidade " or
                   esqcom1[esqpos1] = "3.Entregas"         
                then do.
                    hide frame frame-a no-pause.
                    hide frame f-com1 no-pause.
                    hide frame fsub no-pause.

                    run co/ocproenp.p (recid(lipedpai)).
                    view frame frame-a.
                    view frame fsub.
                    view frame f-com1 .
                    pause 0.
                    if lipedpai.lipsit = "A" then
                       run totaliza.
                end.
***/
                if esqcom1[esqpos1] = "4.Exclui " and
                    pedid.sitped <> "F"
                then do.
                    find produpai of lipedpai no-lock.
                    message "Excluir o produto " produpai.itecod "-" 
                            Trim(produpai.ProNom) "?" update sresp.
                    hide message no-pause.
                    if sresp
                    then do transaction.
                        find lipedpai where recid(lipedpai) = recatu1 exclusive.
                        for each liped where liped.etbcod = lipedpai.etbcod
                                         and liped.pedtdc = lipedpai.pedtdc
                                         and liped.pednum = lipedpai.pednum
                                         and liped.lipcor =
                                                      string(lipedpai.paccod).
                            delete liped.
                        end.
                        delete lipedpai.
/***
                        find pedid of lipedpai no-lock.
                        run co/verifsitoc.p (recid(pedid)).
***/
                        run totaliza.
                        recatu1 = ?.
                        leave.
                    end.
                end.
                                     
                if esqcom1[esqpos1] = "6.Indiv" 
                then do.
                    hide frame frame-a no-pause.
                    hide frame f-com1 no-pause.
                    hide frame fsub no-pause.
                    run co_ocppro.p (recid(pedid),
                                     recid(lipedpai)).
                    view frame frame-a.
                    view frame fsub.
                    view frame f-com1.
                    pause 0.
/***
                    if lipedpai.lipsit = "A" then
                       run totaliza.
***/
                end.
                                    
                if esqcom1[esqpos1] = "5.Grade " 
                then do.
                    hide frame frame-a no-pause.
                    hide frame f-com1 no-pause.
                    hide frame fsub no-pause.
                    run co_graite.p (input recid(lipedpai),
                                     input recid(pedid)).
                    view frame frame-a.
                    view frame fsub.
                    view frame f-com1 .
                    pause 0.
                    if lipedpai.lipsit = "A"
                    then run totaliza. 
                end.
                
                if esqcom1[esqpos1] = "4.Cancela "
                then do.
                    hide frame frame-a no-pause.
                    hide frame f-com1 no-pause.
                    find pedid of lipedpai no-lock.
                    run co/occancela.p (?, recid(lipedpai)).
                    run co/verifsitoc.p (recid(pedid)).
                    view frame frame-a.
                    view frame f-com1 .
                    recatu1 = ?.
                    leave.
                end.

                if esqcom1[esqpos1] = "5.Nota Fiscal "
                then do.
                    find pedid of lipedpai no-lock.
                    hide frame frame-a no-pause.
                    hide frame f-com1 no-pause.
                    run co/ocproenocpainf.p ( recid(pedid), lipedpai.itecod).
                    view frame frame-a.
                    view frame f-com1 .
                end.
              end.

        if not esqvazio
        then run frame-a.
        display esqcom1[esqpos1] with frame f-com1.
        recatu1 = recid(lipedpai).
    end.
    if keyfunction(lastkey) = "end-error"
    then do:
        view frame fc1.
        view frame fc2.
    end.
end.
hide frame f-com1  no-pause.
hide frame frame-a no-pause.
hide frame fprod   no-pause.
hide frame fsub    no-pause.
pause 0.

procedure frame-a.
/***
    run co_lipedqtd.p (recid(lipedpai),
                       output vlipqtd,
                       output vpreqtent,
                       output vlipqtdcanc).
***/

/***
    esqcom1[3] = if lipedpai.lipsit = "A"
                 then "3.Quantidade"
                 else "3.Entregas"
    esqcom1[4] = if pedid.sitped = "F" or pedid.sitped = "C" or 
                    lipedpai.lipsit = "C" /***or vpreqtent <> 0***/
                 then ""
                 else 
                   if pedid.sitped = "A" 
                   then "4.Exclui " 
                   else "4.Cancela ".
   
    esqcom1[5] = "5.Grade ". /*if lipedpai.preqtent > 0 then " 5.Nota Fiscal " else "". */
       disp esqcom1 with frame f-com1.
***/

    find produpai of lipedpai no-lock.
    find pack of lipedpai no-lock no-error.

/*        vtotal = lipedpai.lipqtd  * lipedpai.lippreco - lipedpai.lipdes.*/
        vtotal = (lipedpai.lipqtdtot * lipedpai.lippreco) - lipedpai.lipdes + lipedpai.lipipi.

/***
        vpreco = (lipedpai.lippreco - (lipedpai.lipdes / vlipqtd)).
        if vpreco = 0 or vpreco = ?
        then***/ vpreco = lipedpai.lippreco.
         
        
    display
        lipedpai.itecod     column-label "Codigo"
        produpai.pronom column-label "Descricao" format "x(15)"
        lipedpai.paccod column-label "Pack"
        pack.pacnom no-label format "x(10)" when avail pack
        lipedpai.lipqtd column-label "Qtd"       format ">>>9.99"
        lipedpai.lipent column-label "Entreg."   format ">>>9.99"
/***
            vlipqtdcanc column-label "Cancel."   format ">>>9.99"
***/
        vpreco           column-label "Preco" format ">>>9.99"
        vtotal           column-label "Total" format ">>>>9.99"
        lipedpai.lipsit  column-label ""      format "x(1)"
        with frame frame-a screen-lines - 16 down centered row 10 no-box
                                   overlay.
end Procedure.

procedure color-message.

    color display message
        lipedpai.paccod
        lipedpai.lipqtd
        with frame frame-a.
end procedure.


procedure color-normal.
    color display normal
        lipedpai.paccod
        lipedpai.lipqtd
        with frame frame-a.
end procedure.


procedure totaliza.

    find current pedid exclusive.
    pedid.pedtot = 0.
    for each blipedpai of pedid.
        run co_lipedqtd.p (recid(blipedpai),
                           output vlipqtd,
                           output vpreqtent,
                           output vlipqtdcanc).
        pedid.pedtot = pedid.pedtot + (blipedpai.lippreco * vlipqtd)
                                  - blipedpai.lipdes + blipedpai.lipipi.
        blipedpai.lipqtdtot = vlipqtd.
    end.
    find current pedid no-lock.

    display 
        pedid.pedtot
        with frame f-pedtot.
    pause 0.

end procedure.


procedure leitura . 
def input parameter par-tipo as char.
        
if par-tipo = "pri" 
then find first lipedpai of pedid no-lock no-error.
                                             
if par-tipo = "seg" or par-tipo = "down" 
then find next lipedpai of pedid no-lock no-error.
             
if par-tipo = "up" 
then find prev lipedpai of pedid no-lock no-error.
        
end procedure.

