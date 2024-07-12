
{admcab.i}
def input param ptpnegociacao as char.
def buffer baconegoc for aconegoc.
    
def var xtime as int.
def var vconta as int.


def var recatu1         as recid.
def var recatu2     as reci.
def var reccont         as int.
def var esqpos1         as int.
def var esqcom1         as char format "x(11)" extent 6
    initial [" parametros "," planos "," inclusao "," exclusao",""].


form
    esqcom1
    with frame f-com1 row 6 no-box no-labels column 1 centered.

assign
    esqpos1  = 1.
def var ptitle as char.
ptitle = ptpnegociacao.


    form  
        aconegoc.negcod  column-label "ID"
        aconegoc.negnom column-label "companha"  format "x(26)"
        aconegoc.dtini
        aconegoc.dtfim
        
        with frame frame-a 8 down centered row 8
         title ptitle.


bl-princ:
repeat:


    disp esqcom1 with frame f-com1.
    if recatu1 = ?
    then run leitura (input "pri").
    else find aconegoc where recid(aconegoc) = recatu1 no-lock.
    if not available aconegoc
    then do.
        run pinclui (output recatu1).
        if recatu1 = ? then return.
        next.
        
    end.
    clear frame frame-a all no-pause.
    run frame-a.

    recatu1 = recid(aconegoc).
    color display message esqcom1[esqpos1] with frame f-com1.
    repeat:
        run leitura (input "seg").
        if not available aconegoc
        then leave.
        if frame-line(frame-a) = frame-down(frame-a)
        then leave.
        down with frame frame-a.
        run frame-a.
    end.
    up frame-line(frame-a) - 1 with frame frame-a.

    repeat with frame frame-a:

        find aconegoc where recid(aconegoc) = recatu1 no-lock.

        status default "".
        
        if aconegoc.dtfim <= today 
        then esqcom1[6] = " exclusao".
        else esqcom1[6] = "".
        
        disp esqcom1 with frame f-com1.
        
        run color-message.
        
        choose field aconegoc.negnom

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
                    if not avail aconegoc
                    then leave.
                    recatu1 = recid(aconegoc).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "page-up"
            then do:
                do reccont = 1 to frame-down(frame-a):
                    run leitura (input "up").
                    if not avail aconegoc
                    then leave.
                    recatu1 = recid(aconegoc).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "cursor-down"
            then do:
                run leitura (input "down").
                if not avail aconegoc
                then next.
                if frame-line(frame-a) = frame-down(frame-a)
                then scroll with frame frame-a.
                else down with frame frame-a.
            end.
            if keyfunction(lastkey) = "cursor-up"
            then do:
                run leitura (input "up").
                if not avail aconegoc
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

                if ptpnegociacao = "PRO"
                then   run pparampro.
                else   run pparametros.    
                leave.
            end.
            if esqcom1[esqpos1] = " inclusao "
            then do:
                hide frame f-com1 no-pause.
                run pinclui (output recatu1).
                if ptpnegociacao = "PRO"
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
                run aco/acoplano.p (recid(aconegoc)).
                
            end. 

            
            
             
        end.
        run frame-a.
        display esqcom1[esqpos1] with frame f-com1.
        recatu1 = recid(aconegoc).
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
    display  
        aconegoc.negcod
        aconegoc.negnom
        aconegoc.dtini
        aconegoc.dtfim
        with frame frame-a.


end procedure.

procedure color-message.
    color display message
        aconegoc.negnom
        with frame frame-a.
end procedure.


procedure color-input.
    color display input
        aconegoc.negnom
        with frame frame-a.
end procedure.


procedure color-normal.
    color display normal
        aconegoc.negnom
        with frame frame-a.
end procedure.

procedure leitura . 
def input parameter par-tipo as char.
        
if par-tipo = "pri" 
then do:
        find first aconegoc  where aconegoc.tpnegociacao = ptpnegociacao
                no-lock no-error.
end.    
                                             
if par-tipo = "seg" or par-tipo = "down" 
then do:
        find next aconegoc  where aconegoc.tpnegociacao = ptpnegociacao
                no-lock no-error.

end.    
             
if par-tipo = "up" 
then do:
        find prev aconegoc  where aconegoc.tpnegociacao = ptpnegociacao
                no-lock no-error.

end.    
        
end procedure.



procedure pparametros.

    do on error undo:

        find current aconegoc exclusive.
        disp    
            aconegoc.negcod      colon 16 aconegoc.negnom format "x(26)" no-label colon 40
            aconegoc.dtini       colon 16 aconegoc.dtfim       colon 40
            aconegoc.vlr_total   colon 16 label "vlr contrato"
                    aconegoc.perc_pagas  colon 40 label "perc pagas"
                            aconegoc.qtd_pagas colon 60 label "qtd pagas"
            aconegoc.dtemissao_de   colon 16 label "emissao desde"
            aconegoc.dtemissao_ate  colon 40 label "ate"
            
                    aconegoc.vlr_parcela colon 16 label "vlr parcela"
                        aconegoc.dias_atraso format ">>>9 "colon 60 label "dias atraso"
            aconegoc.vlr_aberto  colon 16 label "vlr aberto" 
                    /*  aconegoc.dias_venc colon 40 "dias vencido" --- redundante com dias_atraso*/
            aconegoc.modcod  format "x(20)"    colon 16 
                
            aconegoc.tpcontrato format "x(12)" colon 60
            Skip(1)
            aconegoc.parcvencidaso colon 16 aconegoc.parcvencidaqtd colon 40
            aconegoc.parcvencerqtd
            skip(1)
            aconegoc.arrasta     colon 60
                    label "Arrasta Outros Contratos?"
            skip(1)
            aconegoc.PermiteTitProtesto colon 60
                                
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
               overlay width 80
               title ptitle.
              
        update
            aconegoc.negnom 
            aconegoc.dtini           aconegoc.dtfim
            aconegoc.vlr_total       aconegoc.perc_pagas aconegoc.qtd_pagas
            aconegoc.dtemissao_de                  aconegoc.dtemissao_ate      

             aconegoc.vlr_parcela aconegoc.dias_atraso format ">>>9"
            aconegoc.vlr_aberto      .

        update aconegoc.modcod.
        if lookup ("CRE",aconegoc.modcod) > 0
        then update aconegoc.tpcontrato
                help "C - CDC NORMAL, N - NOVACAO , FA - FEIRAO ANTIGO, F - FEIRAO , L - L&P".
        else aconegoc.tpcontrato = "".
        
        update aconegoc.parcvencidaso.
        update aconegoc.parcvencidaqtd.
        if aconegoc.parcvencidaso
        then aconegoc.parcvencerqtd = 0.
        else update aconegoc.parcvencerqtd.
        
        update
            aconegoc.arrasta.
            
            /*
        if not aconegoc.arrasta
        then do:
            update Arrast_dias_atraso
                   arrast_dias_venc
                   Arrast_vlr_vencido
                    Arrast_vlr_vencer
                    arrast_dtemissao_de
                    arrast_dtemissao_ate.
        end.  */
        
        update aconegoc.PermiteTitProtesto.
    end.

end.



procedure pparampro.

    do on error undo:

        find current aconegoc exclusive.
        disp    
            aconegoc.negcod      colon 16 aconegoc.negnom format "x(26)" no-label colon 40
            aconegoc.dtini       colon 16 aconegoc.dtfim       colon 40

            skip(1)
            aconegoc.pagaCustas colon 60
            /*
            skip(2)
            aconegoc.arrasta     colon 60
                    label "Arrasta Outros Contratos?"
                    */
        with side-labels 
            row 7
            centered
               overlay width 80
               title ptitle.
              
        update
            aconegoc.negnom 
            aconegoc.dtini           aconegoc.dtfim.
    
        update aconegoc.pagaCustas format "Lebes/Cliente".
    /*            
        update
            aconegoc.arrasta.
      */  
    end.

end.



procedure pinclui.
def output param prec as recid.
do on error undo.

    find last baconegoc no-lock no-error.
    create aconegoc.
    aconegoc.tpnegociacao = ptpnegociacao.
    prec = recid(aconegoc).
    aconegoc.negcod = if not avail baconegoc then 1 else baconegoc.negcod + 1.
    
    update
        aconegoc.negnom format "x(26)"
        with row 9 
        centered
        overlay 1 column.
    
    aconegoc.dtini = today.


end.


end procedure.



procedure pexclui.
sresp = yes.
message color normal "confirma?" update sresp.
if sresp
then do on error undo:
    find current aconegoc exclusive no-wait no-error.
    if avail aconegoc
    then do:
        for each acoplanos of aconegoc.
            delete acoplanos.
        end.  
        delete aconegoc.    
    end.        
end.
end procedure.