/*
*
*    Esqueletao de Programacao
*
*/
{admcab.i}
def var rr like plani.platot.
def var jj like plani.platot.
def var vdata like plani.pladat.
def input parameter vdt1 like plani.pladat.
def input parameter vdt2 like plani.pladat.
def shared var vtotrec  like titulo.titvlcob format "zzz,zzz,zz9.99".
def shared var vtotjur  like titulo.titvlcob format "zzz,zzz,zz9.99".
def var alt-jur like titulo.titvlcob.
def var alt-rec like titulo.titvlcob.
def var operacao as log format "Soma/Diminui".

def shared temp-table tt-totais
    field etbcod like estab.etbcod
    field totpra like titulo.titvlcob
    field totent like titulo.titvlcob
    field totpre like titulo.titvlcob
    field totrec like titulo.titvlcob
    field altrec like titulo.titvlcob
    field altjur like titulo.titvlcob
    field totjur like titulo.titvlcob
    field totger like titulo.titvlcob
    field perrec as dec format "->>9.99"
    field perjur as dec format "->>9.99".
    

def var reccont         as int.
def var vinicio         as log.
def var recatu1         as recid.
def var recatu2         as recid.
def var esqpos1         as int.
def var esqpos2         as int.
def var esqregua        as log.
def var esqcom1         as char format "x(12)" extent 3
            initial ["Recebimentos","  Juros","Individual"].
def var esqcom2         as char format "x(12)" extent 5
            initial ["","","","",""].


def buffer btt-totais       for tt-totais.
def var vetbcod         like tt-totais.etbcod.


    form
        esqcom1
            with frame f-com1
                 row 3 no-box no-labels side-labels centered.
    form
        esqcom2
            with frame f-com2
                 row screen-lines no-box no-labels side-labels column 1.
    esqregua  = yes.
    esqpos1  = 1.
    esqpos2  = 1.

bl-princ:
repeat:

    disp esqcom1 with frame f-com1.
    disp esqcom2 with frame f-com2.
    display vtotrec no-label  to 44
            vtotjur no-label  to 65
                with frame f-tot 
                    side-label color 
                        message row 21 no-box width 74 centered.
                
    if recatu1 = ?
    then
        find first tt-totais where
            true no-error.
    else
        find tt-totais where recid(tt-totais) = recatu1.
    vinicio = yes.
    if not available tt-totais
    then do:
        message "Nenhum arquivo gerado neste periodo ".
        pause.
        return.
    end.
    clear frame frame-a all no-pause.

    display vtotrec no-label  
            vtotjur no-label  
                with frame f-tot. 
     
    display
        tt-totais.etbcod column-label "Fl"
        tt-totais.totent column-label "Entrada"      format ">>>,>>9.99"
        tt-totais.totpre column-label "Prestacao"    format ">>,>>>,>>9.99"
        tt-totais.totrec column-label "Recebimentos" format ">>,>>>,>>9.99"
        tt-totais.perrec column-label "% Rec"        
        tt-totais.totjur column-label "Juros"        format ">,>>>,>>9.99"
        tt-totais.perjur column-label "% Juros" 
                   with frame frame-a 13 down centered.

    recatu1 = recid(tt-totais).
    color display message
        esqcom1[esqpos1]
            with frame f-com1.
    repeat:
        find next tt-totais where
                true.
        if not available tt-totais
        then leave.
        if frame-line(frame-a) = frame-down(frame-a)
        then leave.
        if vinicio
        then down
            with frame frame-a.
        display tt-totais.etbcod 
                tt-totais.totent  
                tt-totais.totpre 
                tt-totais.totrec 
                tt-totais.perrec 
                tt-totais.totjur  
                tt-totais.perjur 
                    with frame frame-a.
    end.
    up frame-line(frame-a) - 1 with frame frame-a.

    repeat with frame frame-a:

        find tt-totais where recid(tt-totais) = recatu1.

        choose field tt-totais.etbcod
            go-on(cursor-down cursor-up
                  cursor-left cursor-right
                  page-down page-up
                  tab PF4 F4 ESC return).
        if keyfunction(lastkey) = "TAB"
        then do:
            if esqregua
            then do:
                color display normal
                    esqcom1[esqpos1]
                    with frame f-com1.
                color display message
                    esqcom2[esqpos2]
                    with frame f-com2.
            end.
            else do:
                color display normal
                    esqcom2[esqpos2]
                    with frame f-com2.
                color display message
                    esqcom1[esqpos1]
                    with frame f-com1.
            end.
            esqregua = not esqregua.
        end.
        if keyfunction(lastkey) = "cursor-right"
        then do:
            if esqregua
            then do:
                color display normal
                    esqcom1[esqpos1]
                    with frame f-com1.
                esqpos1 = if esqpos1 = 3
                          then 3
                          else esqpos1 + 1.
                color display messages
                    esqcom1[esqpos1]
                    with frame f-com1.
            end.
            else do:
                color display normal
                    esqcom2[esqpos2]
                    with frame f-com2.
                esqpos2 = if esqpos2 = 3
                          then 3
                          else esqpos2 + 1.
                color display messages
                    esqcom2[esqpos2]
                    with frame f-com2.
            end.
            next.
        end.

        if keyfunction(lastkey) = "page-down"
        then do:
            do reccont = 1 to frame-down(frame-a):
                find next tt-totais where true no-error.
                if not avail tt-totais
                then leave.
                recatu1 = recid(tt-totais).
            end.
            leave.
        end.
        if keyfunction(lastkey) = "page-up"
        then do:
            do reccont = 1 to frame-down(frame-a):
                find prev tt-totais where true no-error.
                if not avail tt-totais
                then leave.
                recatu1 = recid(tt-totais).
            end.
            leave.
        end.


        if keyfunction(lastkey) = "cursor-left"
        then do:
            if esqregua
            then do:
                color display normal
                    esqcom1[esqpos1]
                    with frame f-com1.
                esqpos1 = if esqpos1 = 1
                          then 1
                          else esqpos1 - 1.
                color display messages
                    esqcom1[esqpos1]
                    with frame f-com1.
            end.
            else do:
                color display normal
                    esqcom2[esqpos2]
                    with frame f-com2.
                esqpos2 = if esqpos2 = 1
                          then 1
                          else esqpos2 - 1.
                color display messages
                    esqcom2[esqpos2]
                    with frame f-com2.
            end.
            next.
        end.
        if keyfunction(lastkey) = "cursor-down"
        then do:
            find next tt-totais where
                true no-error.
            if not avail tt-totais
            then next.
            color display normal
                tt-totais.etbcod.
            if frame-line(frame-a) = frame-down(frame-a)
            then scroll with frame frame-a.
            else down with frame frame-a.
        end.
        if keyfunction(lastkey) = "cursor-up"
        then do:
            find prev tt-totais where
                true no-error.
            if not avail tt-totais
            then next.
            color display normal
                tt-totais.etbcod.
            if frame-line(frame-a) = 1
            then scroll down with frame frame-a.
            else up with frame frame-a.
        end.
        if keyfunction(lastkey) = "end-error"
        then leave bl-princ.

        if keyfunction(lastkey) = "return"
        then do on error undo, retry on endkey undo, leave.
        hide frame frame-a no-pause.

        if esqregua 
        then do:
            display caps(esqcom1[esqpos1]) @ esqcom1[esqpos1]
                with frame f-com1.

            if esqcom1[esqpos1] = "Recebimentos"
            then do with frame f-inclui overlay row 4 centered side-label.
               
                alt-rec = 0.
                update alt-rec label "Valor Recebimentos" 
                        format "->>,>>>,>>9.99". 
                        
                if alt-rec < 0
                then assign operacao = no
                            alt-rec  = (alt-rec * -1).
                else assign operacao = yes.            
                
                for each tt-totais:

                    tt-totais.altrec = (alt-rec * (tt-totais.perrec / 100)).
                   
                    
                    tt-totais.perrec = 
                                 ((tt-totais.altrec / tt-totais.totrec) * 100). 
                    
                  
                    display tt-totais.etbcod 
                            tt-totais.totrec(total) 
                            tt-totais.altrec(total) format "->>>,>>>,>>9.99"
                            operacao
                            tt-totais.perrec.
                            
                end.    
                
                
                
               for each tt-totais:
                   rr = 0.
                   
                   if rr > tt-totais.altrec
                   then next.
                   
                   do vdata = vdt1 to vdt2:
         
                        for each titold where 
                                 titold.etbcobra = tt-totais.etbcod and
                                 titold.titdtpag = vdata 
                                        by titold.titvlcob desc.
                        
                            
                                                        
                            if operacao = no
                            then do:
 
                                titold.titvlcob = titold.titvlcob -
                                                  (titold.titvlcob *
                                                  (tt-totais.perrec / 100)).

                                titold.titvlpag = titold.titvlcob + 
                                                  titold.titjuro.
                                
                                rr = rr + (titold.titvlcob *
                                          (tt-totais.perrec / 100)).
                                          

                            end.
                            else do:

                                titold.titvlcob = titold.titvlcob +
                                                  (titold.titvlcob *
                                                   (tt-totais.perrec / 100)).

                                titold.titvlpag = titold.titvlcob + 
                                                  titold.titjuro.  
 
                                rr = rr + (titold.titvlcob *
                                          (tt-totais.perrec / 100)).

                            end.
                
                        end.
                    end.
                end.
                
                recatu1 = recid(tt-totais).
                leave.
                
            end.
            if esqcom1[esqpos1] = "  Juros"
            then do with frame f-altera overlay row 4 centered.

                alt-jur = 0.
                update alt-jur label "Valor Juros" format "->>,>>>,>>9.99"
                        with frame f-altera no-validate side-label.
                        
                if alt-jur < 0
                then assign operacao = no
                            alt-jur  = (alt-jur * -1).
                else assign operacao = yes.            
                
                for each tt-totais:

                    tt-totais.altjur = (alt-jur * (tt-totais.perjur / 100)).
                   
                    
                    tt-totais.perjur = 
                                 ((tt-totais.altjur / tt-totais.totjur) * 100). 
                    
                  
                    display tt-totais.etbcod 
                            tt-totais.totjur(total) 
                            tt-totais.altjur(total) format "->>>,>>>,>>9.99"
                            operacao
                            tt-totais.perjur.
                            
                end.    
                
                
                
                for each tt-totais:
                    jj = 0.
                   
                    if jj > tt-totais.altjur 
                    then next.
                   
                    do vdata = vdt1 to vdt2:
         
                        for each titold where 
                                 titold.etbcobra = tt-totais.etbcod and
                                 titold.titdtpag = vdata 
                                        by titold.titvlcob desc.

                            if titold.titjuro = 0
                            then next.
                            
                                                        
                            if operacao = no
                            then do:
 
                                titold.titjuro = titold.titjuro -
                                                 (titold.titjuro *
                                                 (tt-totais.perjur / 100)).

                                titold.titvlpag = titold.titvlcob + 
                                                  titold.titjuro.
                                
                                jj = jj + (titold.titjuro *
                                          (tt-totais.perjur / 100)).
                                          

                            end.
                            else do:

                                titold.titjuro = titold.titjuro +
                                                 (titold.titjuro *
                                                 (tt-totais.perjur / 100)).

                                titold.titvlpag = titold.titvlcob + 
                                                  titold.titjuro.  
 
                                jj = jj + (titold.titjuro *
                                          (tt-totais.perjur / 100)).

                            end.
                
                        end.
                    end.
                end.
                
                
                recatu1 = recid(tt-totais).
                leave.
            

            
            end.
            if esqcom1[esqpos1] = "Individual"
            then do with frame f-consulta overlay row 4 centered.
            
                run tt-indiv.p(input tt-totais.etbcod,
                               input vdt1,
                               input vdt2).
            

            end.
            if esqcom1[esqpos1] = "Exclusao"
            then do with frame f-exclui overlay row 6 1 column centered.
                message "Confirma Exclusao de" tt-totais.totent update sresp.
                if not sresp
                then leave.
                find next tt-totais where true no-error.
                if not available tt-totais
                then do:
                    find tt-totais where recid(tt-totais) = recatu1.
                    find prev tt-totais where true no-error.
                end.
                recatu2 = if available tt-totais
                          then recid(tt-totais)
                          else ?.
                find tt-totais where recid(tt-totais) = recatu1.
                delete tt-totais.
                recatu1 = recatu2.
                leave.
            end.
            if esqcom1[esqpos1] = "Listagem"
            then do with frame f-Lista overlay row 6 1 column centered.
                message "Confirma Impressao de tt-totaisidades " update sresp.
                if not sresp
                then leave.
                recatu2 = recatu1.
                output to printer.
                for each tt-totais:
                    display tt-totais.
                end.
                output close.
                recatu1 = recatu2.
                leave.
            end.

        end. 
        else do: 
            display caps(esqcom2[esqpos2]) @ esqcom2[esqpos2]
            with frame f-com2. 
            message esqregua esqpos2 esqcom2[esqpos2]. 
            pause.
        end.
        view frame frame-a .
        end.
        
        if keyfunction(lastkey) = "end-error"
        then view frame frame-a.

        display vtotrec no-label  
                vtotjur no-label with frame f-tot. 

        display tt-totais.etbcod 
                tt-totais.totent  
                tt-totais.totpre  
                tt-totais.totrec 
                tt-totais.perrec 
                tt-totais.totjur 
                tt-totais.perjur
                    with frame frame-a.
        
        if esqregua
        then display esqcom1[esqpos1] with frame f-com1.
        else display esqcom2[esqpos2] with frame f-com2.
        recatu1 = recid(tt-totais).
   end.
end.
