/*
*
*    abasintegracao.p    -    Esqueleto de Programacao    com esqvazio
*
*/

{admcab.i}
/*{tpalcis-wms.i}*/

def input param par-interface  as char init "FCGL".
def input param par-pendente   as log init yes.

/*run confirma-pedido-finalizado.p.*/
def var vhora   as char format "x(05)" column-label "Hora".

setbcod = 900.

def new shared temp-table ttarq no-undo
    field arq as char format "x(50)"
    field interface     as char     
    field Arquivo       as char initial ?
    field diretorio     as char
    index idx is unique primary interface asc Arquivo asc.
    
def var recatu1         as recid.
def var reccont         as int.
def var esqpos1         as int.
def var esqcom1         as char format "x(15)" extent 5
    initial [" Emissao NFE ", " Todas ", " Cons.NFE"," Consulta ", ""].

form
    esqcom1
    with frame f-com1 row 4 no-box no-labels column 1 centered.

assign
    esqpos1  = 1.

/*find tipo-alcis where tipo-alcis.tp = par-interface no-lock.*/

run diretorio.    

bl-princ:
repeat:
    disp esqcom1 with frame f-com1.
    if recatu1 = ?
    then run leitura (input "pri").
    else find abasintegracao where recid(abasintegracao) = recatu1 no-lock.
    if not available abasintegracao
    then do.
        message "Sem arquivos " string(par-pendente,"PENDENTES/ NO GERAL") view-as alert-box.
        if par-pendente = no
        then leave.
        
        par-pendente = no.
        recatu1 = ?.
        next.
    end.
    clear frame frame-a all no-pause.
    run frame-a.

    recatu1 = recid(abasintegracao).
    color display message esqcom1[esqpos1] with frame f-com1.
    repeat:
        run leitura (input "seg").
        if not available abasintegracao
        then leave.
        if frame-line(frame-a) = frame-down(frame-a)
        then leave.
        down with frame frame-a.
        run frame-a.
    end.
    up frame-line(frame-a) - 1 with frame frame-a.

    repeat with frame frame-a:

        find abasintegracao where recid(abasintegracao) = recatu1 no-lock.
        /*find tipo-alcis where tipo-alcis.tp = substr(abasintegracao.arquivo,1,4) no-lock.*/

        status default "".

        esqcom1[1] = "".
        esqcom1[2] = if par-pendente 
                     then " Todas"
                     else " So Pendentes".
        esqcom1[3] = " "             .
        esqcom1[4] = " Consulta".
        release plani.
        if abasintegracao.placod <> ? 
        then
        find first plani where plani.etbcod = abasintegracao.etbcd and
                         plani.placod = abasintegracao.placod
                         no-lock no-error.
        if not avail plani and par-pendente
        then do:
            esqcom1[1] = " Emissao NFE".
        end.    
        else do:
            esqcom1[3]= " Cons.NFE".
        end.
        
        disp esqcom1 with frame f-com1.
        
        run color-message.

        choose field abasintegracao.Arquivo 
                help "Refresh de 15 segundos"
                pause 15
                go-on(cursor-down cursor-up
                      cursor-left cursor-right
                      page-down   page-up
                      tab PF4 F4 ESC return).
        run color-normal.
        pause 0. 

        if lastkey = -1 
        then do:  
            run diretorio.
            next bl-princ. 
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
                    if not avail abasintegracao
                    then leave.
                    recatu1 = recid(abasintegracao).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "page-up"
            then do:
                do reccont = 1 to frame-down(frame-a):
                    run leitura (input "up").
                    if not avail abasintegracao
                    then leave.
                    recatu1 = recid(abasintegracao).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "cursor-down"
            then do:
                run leitura (input "down").
                if not avail abasintegracao
                then next.
                color display white/red abasintegracao.Arquivo with frame frame-a.
                if frame-line(frame-a) = frame-down(frame-a)
                then scroll with frame frame-a.
                else down with frame frame-a.
            end.
            if keyfunction(lastkey) = "cursor-up"
            then do:
                run leitura (input "up").
                if not avail abasintegracao
                then next.
                color display white/red abasintegracao.Arquivo with frame frame-a.
                if frame-line(frame-a) = 1
                then scroll down with frame frame-a.
                else up with frame frame-a.
            end.
 
        if keyfunction(lastkey) = "end-error"
        then leave bl-princ.

        if keyfunction(lastkey) = "return"
        then do:
            display caps(esqcom1[esqpos1]) @ esqcom1[esqpos1]
                        with frame f-com1.

            if esqcom1[esqpos1] = " So Pendentes "
            then do.
                par-pendente = yes.
                recatu1 = ?.
                 leave.
            end.
            if esqcom1[esqpos1] = " Todas "
            then do.
                par-pendente = no.
                recatu1 = ?.
                leave.
            end.
            
            if esqcom1[esqpos1] = " Cons.NFE "
            then do.
                
                run not_consnota.p (recid(plani)).
                
            end.
            
            if esqcom1[esqpos1] = " Emissao NFE "
            then do.
                /* ABAS */
                if par-interface = "EBLJ"
                then do:
                    run abas/ebljcria.p (abasintegracao.arquivo).
                    run abas/acao-eblj-wms-nfe.p (recid(abasintegracao)).
                end.    
                
                if par-interface = "FCGL"
                then do:
                    run abas/fcglcria.p (abasintegracao.arquivo).
                    run abas/fcgl_acao_it.p (recid(abasintegracao)).
                end.                    
                
                if par-interface = "VEXM"
                then run abas/vexm_conf_nf.p (recid(abasintegracao)).
                

                recatu1 = ?.
                clear  frame frame-a all no-pause.
                run diretorio.
                next bl-princ.
            end.
            
            /*
            if esqcom1[esqpos1] = " Consulta "
            then run value(tipo-alcis.consulta) (abasintegracao.arquivo).
            */
            
        end.
        run frame-a.
        display esqcom1[esqpos1] with frame f-com1.
        recatu1 = recid(abasintegracao).
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
    release plani.
    if abasintegracao.placod <> ?
    then
    find first plani where plani.etbcod = abasintegracao.etbcd and
                     plani.placod = abasintegracao.placod
                     no-lock no-error.
    display 
                    abasintegracao.interface
                    abasintegracao.arquivo 
                    abasintegracao.NCarga 
                    abasintegracao.etbcD 
                    abasintegracao.etbcod     
                    abasintegracao.data  format "999999"
                    string(abasintegracao.hora,"HH:MM") @ vhora
                    plani.numero when avail plani
                    abasintegracao.placod
        with frame frame-a 11 down centered color white/red row 5.
end procedure.

procedure color-message.
    color display message
                    abasintegracao.interface
                    abasintegracao.arquivo 
                    abasintegracao.NCarga 
                    abasintegracao.etbcD 
                    abasintegracao.etbcod     
                    abasintegracao.data  
                    vhora
        with frame frame-a.
end procedure.

procedure color-normal.
    color display normal

                    abasintegracao.interface
                    
                    abasintegracao.arquivo 
                    abasintegracao.NCarga 
                    abasintegracao.etbcD 
                    abasintegracao.etbcod     
                    abasintegracao.data  
            vhora
        with frame frame-a.
end procedure.

procedure leitura . 
def input parameter par-tipo as char.
        
if par-tipo = "pri" 
then do:
    if par-pendente
    then do:
        find first abasintegracao  where
                abasintegracao.interface = par-interface and
                abasintegracao.placod     = ?
                no-lock no-error.
    end.
    else do:
        find first abasintegracao where
            abasintegracao.interface = par-interface
            no-lock no-error.
    end.        
end.    
                                             
if par-tipo = "seg" or par-tipo = "down" 
then do:
    if par-pendente
    then do:
        find next abasintegracao  where
                abasintegracao.interface = par-interface and
                abasintegracao.placod     = ?
                no-lock no-error.
    end.
    else do:
        find next abasintegracao where
            abasintegracao.interface = par-interface
            no-lock no-error.
    end.        
end.    
             
if par-tipo = "up" 
then do:
    if par-pendente
    then do:
        find prev abasintegracao  where
                abasintegracao.interface = par-interface and
                abasintegracao.placod     = ?
                no-lock no-error.
    end.
    else do:
        find prev abasintegracao where
            abasintegracao.interface = par-interface
            no-lock no-error.
    end.        

end.    
        
end procedure.

procedure diretorio.

    for each ttarq.
        delete ttarq.
    end.    

    /* Verifica se tem CONF */
    if par-interface <> "FCGL"
    then do:
        run abas/buscaarquivo.p (input "CONF"). 
            run abas/corteconfirma.p.
    end.
    for each ttarq.
        delete ttarq.
    end.    

    run abas/buscaarquivo.p (input par-interface).
    if par-interface = "EBLJ" then  run abas/ebljcria.p ("").
    if par-interface = "FCGL" then  run abas/fcglcria.p ("").
    if par-interface = "VEXM" then  run abas/vexmcria.p.
    
    hide message no-pause.
      
end procedure.
