{admcab.i}
def input parameter par-rec as recid.

def var recatu1         as recid.
def var recatu2         as recid.
def var reccont         as int.
def var esqpos1         as int.
def var esqascend     as log initial yes.
def var esqcom1         as char format "x(15)" extent 5.

def var vabtqtd like abastransf.abtqtd.
    form
        abascorteprod.dcbpseq
        abastransf.dttransf format "999999"
        abastransf.abatipo
        abastipo.abatnom format "x(05)"
        abascorteprod.abtcod
        abastransf.procod
        abascorteprod.procod
        produ.pronom format "x(08)" column-label "Nome"
        abascorteprod.qtdCorte format ">>9"
        abasconfprod.qtdConf   format ">>9"
        abasconfprod.qtdcarga  format ">>9" 
        abastransf.abtsit
        vabtqtd column-label "Pend" format ">>>>"
        with frame frame-a 10 down centered 
        row 7 
            overlay no-box.

    
    form
        esqcom1
        with frame f-com1 overlay row 6 no-box no-labels column 1 centered.

    assign
        esqpos1 = 1.
def var vhrconfer    as char format "x(05)".
def var vhorareal    as char format "x(05)".
def var vhrimparqui  as char format "x(05)".

find abascorte where recid(abascorte) = par-rec no-lock.
pause 0.
    display 
        abascorte.etbcod
        abascorte.box format ">>>"
        abascorte.dcbcod
        abascorte.datareal format "999999"
        string(abascorte.horareal,"HH:MM") @ vhorareal label ""
        abascorte.arquivoIntegracao
        "|"        
        abascorte.dtconfer format "999999"
        string(abascorte.hrconfer,"HH:MM") @ vhrconfer label ""
        abascorte.ArquivoCONF

        with frame fcab
            row 3 1 down centered no-box
            color messages. 

bl-princ:
repeat:
    disp esqcom1 with frame f-com1.
    if recatu1 = ?
    then run leitura (input "pri").
    else find abascorteprod where recid(abascorteprod) = recatu1 no-lock.
    if not available abascorteprod
    then do.
        leave.
    end.

    clear frame frame-a all no-pause.
        run frame-a.

    recatu1 = recid(abascorteprod).
    color display message esqcom1[esqpos1] with frame f-com1.
    repeat:
        run leitura (input "seg").
        if not available abascorteprod
        then leave.
        if frame-line(frame-a) = frame-down(frame-a)
        then leave.
        down
            with frame frame-a.
        run frame-a.
    end.
    up frame-line(frame-a) - 1 with frame frame-a.

    repeat with frame frame-a:

            find abascorteprod where recid(abascorteprod) = recatu1 no-lock.
            
            find abastransf of abascorteprod no-lock no-error.
            esqcom1[1] =  if avail abastransf
                          then " Cortes"
                          else "".
            disp esqcom1 with frame f-com1.                
            status default "".
            run color-message. 
            choose field abascorteprod.procod
            help ""
                go-on(cursor-down cursor-up
                      cursor-left cursor-right
                      page-down   page-up
                      PF4 F4 ESC return) .
            run color-normal.
            status default "".

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
                    if not avail abascorteprod
                    then leave.
                    recatu1 = recid(abascorteprod).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "page-up"
            then do:
                do reccont = 1 to frame-down(frame-a):
                    run leitura (input "up").
                    if not avail abascorteprod
                    then leave.
                    recatu1 = recid(abascorteprod).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "cursor-down"
            then do:
                run leitura (input "down").
                if not avail abascorteprod
                then next.
                if frame-line(frame-a) = frame-down(frame-a)
                then scroll with frame frame-a.
                else down with frame frame-a.
            end.
            if keyfunction(lastkey) = "cursor-up"
            then do:
                run leitura (input "up").
                if not avail abascorteprod
                then next.
                if frame-line(frame-a) = 1
                then scroll down with frame frame-a.
                else up with frame frame-a.
            end.
 
        if keyfunction(lastkey) = "end-error"
        then leave bl-princ.

        if keyfunction(lastkey) = "return"
        then do:
            form abascorteprod
                 with frame f-abascorteprod color black/cyan
                      centered side-label row 5 .
            hide frame frame-a no-pause.
                display caps(esqcom1[esqpos1]) @ esqcom1[esqpos1]
                        with frame f-com1.

                if esqcom1[esqpos1] = " Cortes " 
                then do:  
                    run abas/cortes.p (input "TELA|" + 
                                        string(abastransf.procod) + "|" +
                                        string(recid(abastransf))).
                                    
                                    
                end.
        end.
            run frame-a.
        display esqcom1[esqpos1] with frame f-com1.
        recatu1 = recid(abascorteprod).
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

    find abastransf of abascorteprod no-lock no-error. 
    if avail abastransf
    then do:
        find abastipo of abastransf no-lock.
        find produ of abastransf no-lock no-error.
    end.
    find abasconfprod of abascorteprod no-lock no-error.
    vabtqtd = 0.
    if avail abastransf
    then do:
                if abastransf.abtsit = "EL" or 
                   abastransf.abtsit = "CA"
                then vabtqtd = abastransf.abtqtd.
                else vabtqtd = abastransf.abtqtd - (abastransf.qtdemWMS + abastransf.qtdatend).
    end.
    
    disp
        abascorteprod.dcbpseq
        abastransf.dttransf when avail abastransf
        abastransf.abatipo  when avail abastransf
        abastipo.abatnom    when avail abastipo
        abascorteprod.abtcod
        abastransf.procod when avail abastransf
        abascorteprod.procod
        produ.pronom when avail produ
        abascorteprod.qtdCorte
        abasconfprod.qtdconf when avail abasconfprod         
        abasconfprod.qtdcarga when avail abasconfprod         
        
        abastransf.abtsit when avail abastransf
        vabtqtd        
        with frame frame-a.

end procedure.

procedure color-message.
color display message
        abascorteprod.dcbpseq
        abastransf.dttransf                      
        abastransf.abatipo  
        abastipo.abatnom    
        abascorteprod.abtcod
        abascorteprod.procod
        produ.pronom
        abascorteprod.qtdCorte
        abasconfprod.qtdconf
        abasconfprod.qtdcarga 
        abastransf.abtsit 
        vabtqtd        
        
        with frame frame-a.
end procedure.

procedure color-normal.
color display normal
        abascorteprod.dcbpseq
        abastransf.dttransf                      
        abastransf.abatipo  
        abastipo.abatnom    
        abascorteprod.abtcod
        abascorteprod.procod
        produ.pronom
        abascorteprod.qtdCorte
        abasconfprod.qtdconf
        abasconfprod.qtdcarga 
        abastransf.abtsit 
        vabtqtd        
        
        with frame frame-a.
end procedure.




procedure leitura . 
def input parameter par-tipo as char.
        
if par-tipo = "pri" 
then  
    if esqascend  
    then  
        find first abascorteprod of abascorte 
                                                no-lock no-error.
    else  
        find last abascorteprod  of abascorte
                                                 no-lock no-error.
                                             
if par-tipo = "seg" or par-tipo = "down" 
then  
    if esqascend  
    then  
        find next abascorteprod  of abascorte
                                                no-lock no-error.
    else  
        find prev abascorteprod   of abascorte
                                                no-lock no-error.
             
if par-tipo = "up" 
then                  
    if esqascend   
    then   
        find prev abascorteprod of abascorte
                                        no-lock no-error.
    else   
        find next abascorteprod of abascorte
                                        no-lock no-error.
        
end procedure.
         


 
