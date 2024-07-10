/* helio 23022022 - iepro */

{admcab.i}
def input param ptpCampanha as char.
def buffer bnovcampanha for novcampanha.
    
def var xtime as int.
def var vconta as int.


def var recatu1         as recid.
def var recatu2     as reci.
def var reccont         as int.
def var esqpos1         as int.
def var esqcom1         as char format "x(11)" extent 6
    initial [" parametros "," clientes", " planos "," filiais"," inclusao "," exclusao"].


form
    esqcom1
    with frame f-com1 row 6 no-box no-labels column 1 centered.

assign
    esqpos1  = 1.
def var ptitle as char.
ptitle = if ptpcampanha = "" then " CAMPANHAS " else if ptpcampanha = "PRO" then " NEGOCIACAO DE PROTESTOS " else "".

def var vcliente as log format "Cliente/Geral".

    form  
        
        novcampanha.camnom column-label "companha"  format "x(26)"
        novcampanha.dtini
        novcampanha.dtfim
        
        vcliente        column-label "por"
        with frame frame-a 8 down centered row 8
         title ptitle.


bl-princ:
repeat:


    disp esqcom1 with frame f-com1.
    if recatu1 = ?
    then run leitura (input "pri").
    else find novcampanha where recid(novcampanha) = recatu1 no-lock.
    if not available novcampanha
    then do.
        run pinclui (output recatu1).
        if recatu1 = ? then return.
        next.
        
    end.
    clear frame frame-a all no-pause.
    run frame-a.

    recatu1 = recid(novcampanha).
    color display message esqcom1[esqpos1] with frame f-com1.
    repeat:
        run leitura (input "seg").
        if not available novcampanha
        then leave.
        if frame-line(frame-a) = frame-down(frame-a)
        then leave.
        down with frame frame-a.
        run frame-a.
    end.
    up frame-line(frame-a) - 1 with frame frame-a.

    repeat with frame frame-a:

        find novcampanha where recid(novcampanha) = recatu1 no-lock.

        status default "".
        
        if novcampanha.dtfim <= today 
        then esqcom1[6] = " exclusao".
        else esqcom1[6] = "".
        
        disp esqcom1 with frame f-com1.
        
        run color-message.
        
        choose field novcampanha.camnom

                go-on(cursor-down cursor-up
                      cursor-left cursor-right
                      page-down   page-up
                      L l
                      tab PF4 F4 ESC return).

                run color-normal.
        hide message no-pause.
                 
        pause 0. 

                                                                
            if keyfunction(lastkey) = "cursor-right"
            then do:
                color display normal esqcom1[esqpos1] with frame f-com1.
                esqpos1 = if esqpos1 = 6 then 6 else esqpos1 + 1.
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
                    if not avail novcampanha
                    then leave.
                    recatu1 = recid(novcampanha).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "page-up"
            then do:
                do reccont = 1 to frame-down(frame-a):
                    run leitura (input "up").
                    if not avail novcampanha
                    then leave.
                    recatu1 = recid(novcampanha).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "cursor-down"
            then do:
                run leitura (input "down").
                if not avail novcampanha
                then next.
                if frame-line(frame-a) = frame-down(frame-a)
                then scroll with frame frame-a.
                else down with frame frame-a.
            end.
            if keyfunction(lastkey) = "cursor-up"
            then do:
                run leitura (input "up").
                if not avail novcampanha
                then next.
                if frame-line(frame-a) = 1
                then scroll down with frame frame-a.
                else up with frame frame-a.
            end.
 
        if keyfunction(lastkey) = "end-error"
        then leave bl-princ.
                
                
        if keyfunction(lastkey) = "return"
        then do:
            

            if esqcom1[esqpos1] = " parametros "
            then do:
                hide frame f-com1 no-pause.

                if ptpcampanha = "PRO"
                then   run pparampro.
                else   run pparametros.    
                leave.
            end.
            if esqcom1[esqpos1] = " inclusao "
            then do:
                hide frame f-com1 no-pause.
                run pinclui (output recatu1).
                if ptpcampanha = "PRO"
                then   run pparampro.
                else   run pparametros.    
                leave.
                
            end. 
            if esqcom1[esqpos1] = " exclusao "
            then do:
                run color-message.

                run pexclui.
                recatu1 = ?.
                leave.
            end. 
            
            
            if esqcom1[esqpos1] = " planos "
            then do:
                hide frame f-com1 no-pause.
                hide frame frame-a no-pause.
                run fin/novplano.p (recid(novcampanha)).
                
            end. 
            if esqcom1[esqpos1] = " filiais "
            then do:
                hide frame f-com1 no-pause.
                hide frame frame-a no-pause.
                run fin/novestab.p (recid(novcampanha)).
                
            end. 
            if esqcom1[esqpos1] = " clientes "
            then do:
                hide frame f-com1 no-pause.
                hide frame frame-a no-pause.
                run fin/novcampctr.p (recid(novcampanha)).
                
            end. 
            
            
            
            
             
        end.
        run frame-a.
        display esqcom1[esqpos1] with frame f-com1.
        recatu1 = recid(novcampanha).
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
    find first novcampctr of novcampanha no-lock no-error.
    vcliente = avail novcampctr. 
    display  
        novcampanha.camnom
        novcampanha.dtini
        novcampanha.dtfim
        vcliente 
        with frame frame-a.


end procedure.

procedure color-message.
    color display message
        novcampanha.camnom
        with frame frame-a.
end procedure.


procedure color-input.
    color display input
        novcampanha.camnom
        with frame frame-a.
end procedure.


procedure color-normal.
    color display normal
        novcampanha.camnom
        with frame frame-a.
end procedure.

procedure leitura . 
def input parameter par-tipo as char.
        
if par-tipo = "pri" 
then do:
        find first novcampanha  where novcampanha.tpcampanha = ptpcampanha
                no-lock no-error.
end.    
                                             
if par-tipo = "seg" or par-tipo = "down" 
then do:
        find next novcampanha  where novcampanha.tpcampanha = ptpcampanha
                no-lock no-error.

end.    
             
if par-tipo = "up" 
then do:
        find prev novcampanha  where novcampanha.tpcampanha = ptpcampanha
                no-lock no-error.

end.    
        
end procedure.



procedure pparametros.

    do on error undo:

        find current novcampanha exclusive.
        disp    
            novcampanha.camcod      colon 16 novcampanha.camnom format "x(26)" no-label colon 40
            novcampanha.dtini       colon 16 novcampanha.dtfim       colon 40
            novcampanha.vlr_total   colon 16 label "vlr contrato"
                    novcampanha.perc_pagas  colon 40 label "perc pagas"
                            novcampanha.qtd_pagas colon 60 label "qtd pagas"
            novcampanha.dtemissao_de   colon 16 label "emissao desde"
            novcampanha.dtemissao_ate  colon 40 label "ate"
            
                    novcampanha.vlr_parcela colon 16 label "vlr parcela"
                        novcampanha.dias_atraso colon 60 label "dias atraso"
            novcampanha.vlr_aberto  colon 16 label "vlr aberto" 
                    /*  novcampanha.dias_venc colon 40 "dias vencido" --- redundante com dias_atraso*/
            novcampanha.modcod  format "x(20)"    colon 16 
                
            novcampanha.tpcontrato format "x(12)" colon 60
            Skip(1)
            novcampanha.parcvencidaso colon 16 novcampanha.parcvencidaqtd colon 40
            novcampanha.parcvencerqtd
            skip(1)
            novcampanha.arrasta     colon 60
                    label "Arrasta Outros Contratos?"
            skip(1)
            novcampanha.PermiteTitProtesto colon 60
                                
            /*
                    Arrast_dias_atraso colon 16  label "dias atraso"
                   arrast_dias_vencer  colon 40  label "dias a vencer"
                   Arrast_vlr_vencido  colon 16  label "vlr vencido"
                    Arrast_vlr_vencer  colon 40  label "vlr vencer"
                    arrast_dtemissao_de colon 16 label "emissao de"
                    arrast_dtemissao_ate colon 40 label "ate"
              */
        with side-labels 
            row 7
            centered
               overlay width 80.
              
        update
            novcampanha.camnom 
            novcampanha.dtini           novcampanha.dtfim
            novcampanha.vlr_total       novcampanha.perc_pagas novcampanha.qtd_pagas
            novcampanha.dtemissao_de                  novcampanha.dtemissao_ate      

             novcampanha.vlr_parcela novcampanha.dias_atraso
            novcampanha.vlr_aberto      .

        update novcampanha.modcod.
        if lookup ("CRE",novcampanha.modcod) > 0
        then update novcampanha.tpcontrato
                help "C - CDC NORMAL, N - NOVACAO , FA - FEIRAO ANTIGO, F - FEIRAO , L - L&P".
        else novcampanha.tpcontrato = "".
        
        update novcampanha.parcvencidaso.
        update novcampanha.parcvencidaqtd.
        if novcampanha.parcvencidaso
        then novcampanha.parcvencerqtd = 0.
        else update novcampanha.parcvencerqtd.
        
        update
            novcampanha.arrasta.
            
            /*
        if not novcampanha.arrasta
        then do:
            update Arrast_dias_atraso
                   arrast_dias_venc
                   Arrast_vlr_vencido
                    Arrast_vlr_vencer
                    arrast_dtemissao_de
                    arrast_dtemissao_ate.
        end.  */
        
        update novcampanha.PermiteTitProtesto.
    end.

end.



procedure pparampro.

    do on error undo:

        find current novcampanha exclusive.
        disp    
            novcampanha.camcod      colon 16 novcampanha.camnom format "x(26)" no-label colon 40
            novcampanha.dtini       colon 16 novcampanha.dtfim       colon 40

            skip(1)
            novcampanha.pagaCustas colon 60
            /*
            skip(2)
            novcampanha.arrasta     colon 60
                    label "Arrasta Outros Contratos?"
                    */
        with side-labels 
            row 7
            centered
               overlay width 80.
              
        update
            novcampanha.camnom 
            novcampanha.dtini           novcampanha.dtfim.
    
        update novcampanha.pagaCustas format "Lebes/Cliente".
    /*            
        update
            novcampanha.arrasta.
      */  
    end.

end.



procedure pinclui.
def output param prec as recid.
do on error undo.

    find last bnovcampanha no-lock no-error.
    create novcampanha.
    novcampanha.tpcampanha = ptpcampanha.
    prec = recid(novcampanha).
    novcampanha.camcod = if not avail bnovcampanha then 1 else bnovcampanha.camcod + 1.
    
    update
        novcampanha.camnom format "x(26)"
        with row 9 
        centered
        overlay 1 column.
    
    novcampanha.dtini = today.


end.


end procedure.



procedure pexclui.
sresp = yes.
message color normal "confirma?" update sresp.
if sresp
then do on error undo:
    find current novcampanha exclusive no-wait no-error.
    if avail novcampanha
    then do:
        for each novplanos of novcampanha.
            delete novplanos.
        end.  
        for each  novestab of novcampanha.
            delete novestab.
        end.
        delete novcampanha.    
    end.        
end.
end procedure.
