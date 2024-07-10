/* helio 26072023 NOVAÇÃO COM ENTRADA (BOLETO) + SEGURO PRESTAMISTA . SOLUÇÃO 3 */
{cabec.i}

def var vbusca as char.
def var vtotal as int.
def var vhora as char format "x(5)" label "Hr".
def var par-busca       as   char.

def var recatu1         as recid.
def var recatu2         as recid.
def var reccont         as int.
def var esqpos1         as int.
def var esqpos2         as int.
def var esqregua        as log.
def var esqvazio        as log.
def var esqascend     as log initial yes.
def var esqcom1         as char format "x(15)" extent 5
    initial [" Acordo ", ""].
def var esqcom2         as char format "x(12)" extent 5
            initial ["Filtros","","","",""].
def var esqhel1         as char format "x(80)" extent 5.
def var esqhel2         as char format "x(12)" extent 5.

def var vprimeiro as log.

pause 0 before-hide.

def buffer bcybacordo    for cybacordo.

def temp-table ttacordo no-undo
    field marca   as log format "*/ "
    field rec     as recid
    field idAcordo like cybacordo.idAcordo
    field Situacao like cybacordo.Situacao
    index x idAcordo desc
    /*#1 index y Situacao idAcordo desc*/.

def buffer xttacordo for ttacordo.
    
form
    esqcom1
    with frame f-com1
                 row 3 no-box no-labels side-labels column 1 centered.
form
    esqcom2
    with frame f-com2
                 row screen-lines no-box no-labels side-labels column 1
                 centered.
assign
    esqregua = yes
    esqpos1  = 1
    esqpos2  = 1.

def var vboleto as char format "x(24)"  extent 3
            init [" TODOS",
                  " Vinculados a Boleto ",
                  " Ainda sem vinculos "].

def var vtipos as char format "x(24)"  extent 3
            init [" TODOS",
                  " Acordos Novacao ",
                  " Promessas "].
    
def var vsituacao as char format "x(24)"  extent 3
            init [" TODOS",
                  " Pendentes ",
                  " Efetivados "].

def var vadesao as char format "x(24)"  extent 3
            init [" TODOS",
                  " Sem Adesao Seguro ",
                  " Com Adesao Seguro "].
 
def var psituacao as char format "x(30)".
def var pboleto as char format "x(30)".
def var ptipo as char format "x(30)".
def var padesao as char format "x(30)".

def var pdtini as date format "99/99/9999".
def var pdtfim as date format "99/99/9999".

def var par-idAcordo like cybacordo.idAcordo.

    form
       /** ttacordo.marca  format " / " column-label "" **/
        cybacordo.tipo
        cybacordo.idAcordo
        cybacordo.dtacordo
        vhora
        cybacordo.etbcod column-label "Fil"
        cybacordo.clifor
        cybacordo.vlacordo format ">>,>>9.99"
        cybacordo.dtefetiva
        cybacordo.situacao column-label "S"
        cybacordo.adesaoPrestamista 
        cybacordo.SeguroPrestamistaAutomatico 
        
        with frame frame-a 
        12 down centered color white/red row 4
                          title psituacao width 80.
                          

form with frame flinha down no-box.
form 
         par-idAcordo        colon 30
         psituacao        colon 30 label "Situacao"
         ptipo     colon 30 label "Tipo"
         pboleto   colon 30 label "Boleto"
         padesao  colon 30 label "Adesao Seguro"
         
         pdtini     colon 30 label "Periodo de"
            pdtfim label "Ate"
         with frame fcab side-labels
            row 3 centered
            title "Filtros Acordos ".

repeat.    
    run pfiltros.
    if keyfunction(lastkey) = "end-error"
    then leave.

find first ttacordo no-lock no-error.
if not avail ttacordo
then do:
    message "Nao foram encontrados registros para esta selecao"
            view-as alert-box.
    leave.
end.

bl-princ:
repeat:    
    run ptotal.
    
    disp esqcom1 with frame f-com1.
    disp esqcom2 with frame f-com2.
    if recatu1 = ?
    then run leitura (input "pri").
    else find ttacordo where recid(ttacordo) = recatu1 no-lock.
    if not available ttacordo
    then return.
            
    else esqvazio = no.
    clear frame frame-a all no-pause.
    if not esqvazio
    then run frame-a.

    recatu1 = recid(ttacordo).
    if esqregua
    then color display message esqcom1[esqpos1] with frame f-com1.
    else color display message esqcom2[esqpos2] with frame f-com2.
    if not esqvazio
    then repeat:
        run leitura (input "seg").
        if not available ttacordo
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
            find ttacordo where recid(ttacordo) = recatu1 no-lock.
            find cybacordo where recid(cybacordo) = ttacordo.rec no-lock.

            if cybacordo.dtefetiva = ?
            then do:
                if cybacordo.adesaoprestamista                
                then esqcom1[2] = "Retira Seguro".
                else esqcom1[2] = "Adesao Seguro".
            end.
            disp esqcom1 with frame f-com1.

            status default
                if esqregua
                then esqhel1[esqpos1] + if esqpos1 > 1 and
                                           esqhel1[esqpos1] <> ""
                                        then  string(cybacordo.idAcordo)
                                        else ""
                else esqhel2[esqpos2] + if esqhel2[esqpos2] <> ""
                                        then string(cybacordo.idAcordo)
                                        else "".

            choose field cybacordo.idAcordo help ""
                go-on(cursor-down cursor-up
                      cursor-left cursor-right
                      page-down   page-up
                      1 2 3 4 5 6 7 8 9 0 
                      tab PF4 F4 ESC return).
            
            if keyfunction(lastkey) >= "0" and 
               keyfunction(lastkey) <= "9"
            then do with centered row 8 color message
                                frame f-procura side-label overlay.
                vbusca = keyfunction(lastkey).
                pause 0.
                vprimeiro = yes.
                update vbusca label "Busca"
                    editing:
                        if vprimeiro
                        then do:
                            apply keycode("cursor-right").
                            vprimeiro = no.
                        end.
                    readkey.
                    apply lastkey.
                end.
                recatu2 = recatu1.
                find first bcybacordo where bcybacordo.idAcordo = 
                    int(vbusca)
                                    no-lock no-error.
                if avail bcybacordo
                then do.
                    create ttacordo.
                    ttacordo.rec     = recid(bcybacordo).
                    ttacordo.idAcordo = bcybacordo.idAcordo.
                    recatu1 = recid(ttacordo).
                end.
                else do:
                    recatu1 = recatu2.
                    message "OS nao encontrada".
                    pause 1 no-message.
                end.    
                leave.
            end.

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
                    if not avail ttacordo
                    then leave.
                    recatu1 = recid(ttacordo).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "page-up"
            then do:
                do reccont = 1 to frame-down(frame-a):
                    run leitura (input "up").
                    if not avail ttacordo
                    then leave.
                    recatu1 = recid(ttacordo).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "cursor-down"
            then do:
                run leitura (input "down").
                if not avail ttacordo
                then next.
                if frame-line(frame-a) = frame-down(frame-a)
                then scroll with frame frame-a.
                else down with frame frame-a.
            end.
            if keyfunction(lastkey) = "cursor-up"
            then do:
                run leitura (input "up").
                if not avail ttacordo
                then next.
                if frame-line(frame-a) = 1
                then scroll down with frame frame-a.
                else up with frame frame-a.
            end.
 
        if keyfunction(lastkey) = "end-error"
        then leave bl-princ.

        if keyfunction(lastkey) = "return" or esqvazio
        then do:
            form with frame f-etiqest color black/cyan
                      centered side-label row 5 .
            if esqregua
            then do:
                display caps(esqcom1[esqpos1]) @ esqcom1[esqpos1]
                        with frame f-com1.

                if esqcom1[esqpos1] = " Acordo "
                then do:
                    hide frame frame-a no-pause.
                    hide frame f-com1  no-pause.
                    hide message no-pause. 
                    hide frame f-com2 no-pause.
                    hide frame ftotal no-pause.
                    recatu2 = recid(cybacordo).
                    run cyb/cybacordoman_v1701.p (input-output recatu2).
                    view frame f-com1.
                    view frame f-com2.
                    run ptotal.
                    view frame ftotal.
                end.

                if esqcom1[esqpos1] = "Retira Seguro"
                then do on error undo:
                    find current cybacordo exclusive.
                    cybacordo.adesaoprestamista = no.
                    cybacordo.SeguroPrestamistaAutomatico = no.
                end.
                if esqcom1[esqpos1] = "Adesao Seguro"
                then do on error undo:
                    find current cybacordo exclusive.
                    cybacordo.adesaoprestamista = yes.
                    cybacordo.SeguroPrestamistaAutomatico = no.
                end.
 

            end.
            else do:
                display caps(esqcom2[esqpos2]) @ esqcom2[esqpos2]
                        with frame f-com2.
                if esqcom2[esqpos2] = "Filtros" 
                then do.
                    hide frame f-com1  no-pause.
                    hide frame f-com2  no-pause.
                    run pfiltros.
                    recatu1 = ?.
                    leave.
                end.
                if esqcom2[esqpos2] = "Relatorio" 
                then do.
                    hide frame f-com1  no-pause.
                    hide frame f-com2  no-pause.
                    run relatorio.
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
        recatu1 = recid(ttacordo).
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
end.

procedure frame-a.
    find cybacordo where recid(cybacordo) = ttacordo.rec no-lock.
    vhora = string(cybacordo.hracordo,"HH:MM").
    
    disp
        cybacordo.tipo
        cybacordo.idAcordo
        cybacordo.dtacordo
        vhora
        cybacordo.etbcod
        cybacordo.clifor
        cybacordo.vlacordo
        cybacordo.dtefetiva
        cybacordo.situacao 
        cybacordo.adesaoPrestamista
        cybacordo.SeguroPrestamistaAutomatico when cybacordo.adesaoPrestamista
        with frame frame-a.

end procedure.


procedure leitura.
def input parameter par-tipo as char.

if par-tipo = "pri" 
then find first ttacordo use-index x no-error.
                                             
if par-tipo = "seg" or par-tipo = "down" 
then find next ttacordo use-index x no-error.

if par-tipo = "up" 
then find prev ttacordo use-index x no-error.

end procedure.
         

procedure ptotal. 
    vtotal = 0.
    for each xttacordo no-lock.
        vtotal = vtotal + 1.
    end.
    pause 0 before-hide.
    disp vtotal label "Total"  to 80
         with frame ftotal row screen-lines - 1 no-box side-labels column 1
                 centered.
end procedure.


procedure montatt.

    for each ttacordo.
        delete ttacordo.
    end.

    if par-idAcordo <> 0
    then do:
        for each cybacordo where cybacordo.idAcordo = par-idAcordo no-lock.
            run criatt.
        end.
        leave.
    end.

    hide message no-pause.

    do:        
        if psituacao = "PENDENTES" 
        then do:
            for each cybacordo where cybacordo.dtefetiva = ? no-lock.
                if (ptipo = "Acordos Novacao" and cybacordo.tipo = "NOV") or
                   (ptipo = "PROMESSA" and cybacordo.tipo = "PRO") or
                   Ptipo = "TODOS"
                then.
                else next.
                if (pboleto= "Vinculados a Boleto" and 
                                    cybacordo.situacao = "V") or
                   (pboleto = "Ainda Sem Vinculos" and 
                                    cybacordo.situacao = "A") or
                    pboleto = "TODOS"                
                                    
                then.
                else next.
                if (padesao = "Sem Adesao Seguro" and                                         cybacordo.adesaoPrestamista = no) or
                   (padesao = "Com Adesao Seguro" and                                                             cybacordo.adesaoPrestamista = yes) or
                    padesao = "TODOS"
                then.
                else next.
                    
                if pdtini <> ?
                then if cybacordo.dtacordo < pdtini
                     then next.
                if pdtfim <> ?
                then if cybacordo.dtacordo > pdtfim
                     then next.
                     
                
                run criatt.
            end.
        end.
        if psituacao = "EFETIVADOS" 
        then do:
            for each cybacordo where cybacordo.dtefetiva >= pdtini and
                                    cybacordo.dtefetiva  <= pdtfim
                                    no-lock.
                if (ptipo = "ACORDOS Novacao" and cybacordo.tipo = "NOV") or
                   (ptipo = "PROMESSA" and cybacordo.tipo = "PRO") or
                   ptipo = "TODOS"
                then.
                else next.
                if (padesao = "Sem Adesao Seguro" and                                                             cybacordo.adesaoPrestamista = no) or
                   (padesao = "Com Adesao Seguro" and                                                             cybacordo.adesaoPrestamista = yes) or
                    padesao = "TODOS"
                then.
                else next.
            
                run criatt.
            end.        
        end.
        if psituacao = "TODOS"
        then do:
            for each cybacordo where cybacordo.dtacordo >= pdtini and
                                     cybacordo.dtacordo <= pdtfim
                    no-lock.
                if (ptipo = "Acordos Novacao" and cybacordo.tipo = "NOV") or
                   (ptipo = "PROMESSA" and cybacordo.tipo = "PRO") or
                   Ptipo = "TODOS"
                then.
                else next.
                if (padesao = "Sem Adesao Seguro" and                                         cybacordo.adesaoPrestamista = no) or
                   (padesao = "Com Adesao Seguro" and                                                             cybacordo.adesaoPrestamista = yes) or
                    padesao = "TODOS"
                then.
                else next.
                    
                run criatt.
            end.
        end.
        
    end.        
    run ptotal.
                             
end procedure.


procedure criatt.
 
    create ttacordo.
    ttacordo.rec   = recid(cybacordo).
    ttacordo.idAcordo = cybacordo.idAcordo.
    ttacordo.Situacao = cybacordo.Situacao.
    
end procedure.


form with frame flinha no-box width 140.
    def var vtotpc  as dec.

procedure pfiltros.

repeat.
    par-idAcordo = 0.
    hide message no-pause.
    message color normal "Pressionando F1 EH o mesmo que dar . ENTER ate o ulti~mo campo".
 
    update par-idAcordo when keyfunction(lastkey) <> "I" and
                      keyfunction(lastkey) <> "CLEAR"
        go-on(F8 PF8)
    with frame fcab.

    find cybacordo where cybacordo.idAcordo = par-idAcordo no-lock no-error.
    if par-idAcordo <> 0
    then do:
        if not avail cybacordo
        then do:
            message "Acordo Inexistente".
            undo.
        end.
        else do.
            if avail cybacordo
            then do:
                recatu1 = ?.
                run montatt.
                return.
            end.        
        end.
    end.


        display vsituacao
            with frame fff centered row 6 no-label overlay width 80.
        choose field vsituacao with frame fff.                         
        psituacao =  trim(vsituacao[frame-index]).
        
            display vtipos
                with frame fff1 centered row 7 no-label overlay width 80.
            choose field vtipos with frame fff1.                         
            ptipo =  trim(vtipos[frame-index]).
        pboleto = "".
        if psituacao = "PENDENTES"
        then do:
        
            display vboleto
                with frame fff2 centered row 8 no-label overlay width 80.
            choose field vboleto with frame fff2.                         
             pboleto =  trim(vboleto[frame-index]).
        
        end.        
            display vadesao
                with frame fff3 centered row 8 no-label overlay width 80.
            choose field vadesao with frame fff3.                         
             padesao =  trim(vadesao[frame-index]).
        
    
    disp
        ptipo
        psituacao
        pboleto
        padesao
         par-idAcordo 
         with frame fcab.
    hide message no-pause.
    if psituacao = "PENDENTES"
    then message "Periodo Geracao do Acordo".
    else message "Periodo Efetivacao do Acordo".

    update pdtini pdtfim
        with frame fcab.
         
        recatu1 = ?.
        run montatt.

    leave.

end.

end procedure.

