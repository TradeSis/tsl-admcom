/*
*
*    mdfnfe.p    -    Esqueleto de Programacao    com esqvazio
#1 TP 28872041 16.01.19 - Etbcod e modcod na origem
*
*/
{cabec.i}

def var recatu1         as recid.
def var recatu2 as recid.
def var reccont         as int.
def var esqpos1         as int.
def var esqvazio        as log.
def var esqascend     as log initial yes.
def var esqcom1         as char format "x(13)" extent 5
    initial [" Consulta "," ","  ","",""].

form
    esqcom1
    with frame f-com1 row screen-lines no-box no-labels column 1 centered.

assign
    esqpos1  = 1.

def input parameter par-rec-cybacordo as recid.

find cybacordo where recid(cybacordo) = par-rec-cybacordo no-lock.
find estab  where estab.etbcod = cybacordo.etbcod no-lock.

def temp-table tt-parcelas no-undo   
    field recid_tit as recid
    field contnum like cybacorigem.contnum
    field etbcod  like CybAcOrigem.etbcod /* #1 */
    field titpar  like titulo.titpar
    field modcod  like CybAcOrigem.modcod /* #1 */
    index x contnum asc titpar desc.
   
recatu1 = ?.
    
    form
        tt-parcelas.etbcod
        tt-parcelas.contnum
        tt-parcelas.titpar
        tt-parcelas.modcod
        titulo.titdtemi
        titulo.titdtven
        titulo.titdtpag
        titulo.titsit
        titulo.titvlcob
        with frame frame-a 9 down centered row 09
        title " Contratos Origem " no-underline width 80.

run pesquisa.

find first tt-parcelas no-error.
if not avail tt-parcelas
then do:
    message "Parcelas nao encontradas".
    pause.
    return.
end.    

bl-princ:
repeat:
    disp esqcom1 with frame f-com1.
    if recatu1 = ?
    then
        run leitura (input "pri").
    else
        find tt-parcelas where recid(tt-parcelas) = recatu1 no-lock.
    if not available tt-parcelas
    then esqvazio = yes.
    else esqvazio = no.
    clear frame frame-a all no-pause.
    if not esqvazio
    then
        run frame-a.
    else do.
        recatu1 = ?.
        leave.
    end.

    recatu1 = recid(tt-parcelas).
    color display message esqcom1[esqpos1] with frame f-com1.
    if not esqvazio
    then repeat:
        run leitura (input "seg").
        if not available tt-parcelas
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
            find tt-parcelas where recid(tt-parcelas) = recatu1 no-lock.
            find titulo where recid(titulo) = tt-parcelas.recid_tit no-lock  
                           no-error.

        color disp messages
        tt-parcelas.titpar.
                    
            if not avail titulo
            then do:
                esqcom1[1] = " Consulta".
                esqcom1[2] = " ".
                esqcom1[3] = "" .
                esqcom1[4] = "".
                esqcom1[5] = "".
            end.    

            disp esqcom1 with frame f-com1.
            
            choose field tt-parcelas.titpar
                go-on(cursor-down cursor-up
                      cursor-left cursor-right
                      page-down   page-up
                      PF4 F4 ESC return).
            hide message no-pause.
            status default "".
 
        color disp normal
        tt-parcelas.titpar.
 
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
                    if not avail tt-parcelas
                    then leave.
                    recatu1 = recid(tt-parcelas).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "page-up"
            then do:
                do reccont = 1 to frame-down(frame-a):
                    run leitura (input "up").
                    if not avail tt-parcelas
                    then leave.
                    recatu1 = recid(tt-parcelas).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "cursor-down"
            then do:
                run leitura (input "down").
                if not avail tt-parcelas
                then next.
                if frame-line(frame-a) = frame-down(frame-a)
                then scroll with frame frame-a.
                else down with frame frame-a.
            end.
            if keyfunction(lastkey) = "cursor-up"
            then do:
                run leitura (input "up").
                if not avail tt-parcelas
                then next.
                if frame-line(frame-a) = 1
                then scroll down with frame frame-a.
                else up with frame frame-a.
            end.
 
        if keyfunction(lastkey) = "end-error"
        then do:
            leave bl-princ.
        end.    

        if keyfunction(lastkey) = "return" or esqvazio
        then do:
                display caps(esqcom1[esqpos1]) @ esqcom1[esqpos1]
                        with frame f-com1.

            if esqcom1[esqpos1] = " Consulta"
            then do:
                run bsfqtitulo.p (input recid(titulo)).
            end.    
                
        end.
        if not esqvazio
        then do:
            run frame-a.
        end.
        display esqcom1[esqpos1] with frame f-com1.
        recatu1 = recid(tt-parcelas).
    end.
end.
hide frame f-com1  no-pause.
hide frame frame-a no-pause.
hide frame f-dados no-pause.

procedure frame-a.

    find titulo where recid(titulo) = tt-parcelas.recid_tit no-lock no-error.

    display 
        tt-parcelas.etbcod /* #1 */
        tt-parcelas.contnum
        tt-parcelas.titpar
        tt-parcelas.modcod /* #1 */
        with frame frame-a.
    if avail titulo
    then disp            
        titulo.titdtemi
        titulo.titdtven
        titulo.titdtpag
        titulo.titsit
        titulo.titvlcob
        with frame frame-a.

end procedure.

procedure leitura.
def input parameter par-tipo as char.
        
if par-tipo = "pri" 
then find last tt-parcelas  no-lock no-error.
                                             
if par-tipo = "seg" or par-tipo = "down" 
then find prev tt-parcelas  no-lock no-error.
             
if par-tipo = "up" 
then find next tt-parcelas no-lock no-error.

end procedure.



procedure pesquisa.

def var vi as int.
def var vtitpar as int.

def var vrec as recid.
for each tt-parcelas.
    delete tt-parcelas.
end.
    recatu1 = ?.

for each cybacorigem of cybacordo no-lock.

    find contrato where contrato.contnum = cybacorigem.contnum no-lock.
    do vi = 1 to num-entries(cybacorigem.parcelasLista).
        vtitpar = int(entry(vi,cybacorigem.parcelasLista)).       
        for each titulo where 
                titulo.empcod = 19 and 
                titulo.titnat = no and 
                titulo.modcod = contrato.modcod and 
                titulo.etbcod = contrato.etbcod and 
                titulo.clifor = contrato.clicod and 
                titulo.titnum = string(contrato.contnum) and
                titulo.titpar = vtitpar
                no-lock.
            create tt-parcelas.
            tt-parcelas.recid_tit = recid(titulo).
            tt-parcelas.etbcod  = CybAcOrigem.etbcod. /* #1 */
            tt-parcelas.contnum = cybacorigem.contnum.
            tt-parcelas.titpar  = vtitpar.
            tt-parcelas.modcod  = CybAcOrigem.modcod. /* #1 */
        end. 
    end.                   
end.

end procedure.

