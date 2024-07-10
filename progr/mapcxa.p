/*
*
*    Esqueletao de Programacao
*
*/
{admcab.i new}
def var vtipo as char format "x(10)"
    extent 2 initial ["Sintetico","Analitico"].
def var vtot01          like mapcxa.t01.
def var vtot02          like mapcxa.t01.
def var vtot03          like mapcxa.t01.
def var vtot04          like mapcxa.t01.
def var vtot05          like mapcxa.t01.
def var reccont         as int.
def var vinicio         as log.
def var recatu1         as recid.
def var recatu2         as recid.
def var esqpos1         as int.
def var esqpos2         as int.
def var esqregua        as log.
def var esqcom1         as char format "x(12)" extent 5
    initial ["Inclusao","Alteracao","Consulta","Exclusao","Listagem"].
def var esqcom2         as char format "x(12)" extent 5
            initial ["","","","",""].


def buffer bmapcxa       for mapcxa.
def var vetbcod         like mapcxa.etbcod.
def var vdti like plani.pladat.
def var vdtf like plani.pladat.

def temp-table tt-mapcxa
    field etbcod like mapcxa.etbcod
    field cxacod like mapcxa.cxacod
    field datmov like mapcxa.datmov
    field nrored like mapcxa.nrored
    field venbru like plani.platot
    field rec    as recid
        index ind-1 etbcod
                    cxacod
                    datmov.
      
      
      
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

repeat:


    for each tt-mapcxa:
        delete tt-mapcxa.
    end.
            
    recatu1 = ?.
            
    vetbcod = 0.
    update vetbcod label "Filial" with frame f1 side-label width 80.
    if vetbcod = 0
    then display "TODAS" @ estab.etbnom with frame f1.
    else do:
        find estab where estab.etbcod = vetbcod no-lock no-error.
        if not avail estab
        then do:
            message "Filial nao cadastrada".
            pause.
            undo, retry.
        end.
        display estab.etbnom no-label with frame f1.
            
    end.
 
    update vdti label "Periodo" 
           vdtf no-label with frame f1.
            

    assign vtot01 = 0
           vtot02 = 0
           vtot03 = 0
           vtot04 = 0
           vtot05 = 0.
    for each estab where if vetbcod = 0
                         then true
                         else estab.etbcod = vetbcod no-lock:
                         
        
        for each mapcxa where mapcxa.etbcod = estab.etbcod and 
                              mapcxa.datmov >= vdti        and 
                              mapcxa.datmov <= vdtf no-lock:
                                  
                                  
            create tt-mapcxa. 
            assign tt-mapcxa.etbcod = mapcxa.etbcod 
                   tt-mapcxa.cxacod = mapcxa.cxacod 
                   tt-mapcxa.datmov = mapcxa.datmov
                   tt-mapcxa.rec    = recid(mapcxa)
                   tt-mapcxa.venbru = mapcxa.t01 + 
                                      mapcxa.t02 + 
                                      mapcxa.t03 + 
                                      mapcxa.t04 + 
                                      mapcxa.t05 + 
                                      mapcxa.vlsub.
            if int(mapcxa.nrofab) > 0
            then tt-mapcxa.nrored = mapcxa.nrored + 1.
            else tt-mapcxa.nrored = mapcxa.nrored.
            
            assign vtot01 = vtot01 + mapcxa.t01
                   vtot02 = vtot02 + mapcxa.t02
                   vtot03 = vtot03 + mapcxa.t03
                   vtot04 = vtot04 + mapcxa.vlsub
                   vtot05 = vtot05 + tt-mapcxa.venbru.
                   
                   
                       
        end.

    end.        
        
                                           

    display  vtot01  to 34 format ">>>>>,>>9.99"
             vtot02  to 44
             vtot03  to 55 format ">>>>,>>9.99"
             vtot04  to 66
             vtot05  to 79 format ">>>>>,>>9.99"
                with frame f-tot no-label no-box 
                    row 20 color message width 80.

 



                       
     


bl-princ:
repeat:

    disp esqcom1 with frame f-com1.
    disp esqcom2 with frame f-com2.
    if recatu1 = ?
    then
        find first tt-mapcxa where
            true no-error.
    else
        find tt-mapcxa where recid(tt-mapcxa) = recatu1.
    vinicio = yes.
    if not available tt-mapcxa
    then do:
        message "Nenhum Registro Encontrado".
        pause.
        return.
    end.
    clear frame frame-a all no-pause.
    find mapcxa where recid(mapcxa) = tt-mapcxa.rec no-lock.
    display
        tt-mapcxa.etbcod column-label "Fl" format ">>9"
        tt-mapcxa.cxacod column-label "Eq" format ">9"
        mapcxa.de1       column-label "Cx" format ">9"
        mapcxa.datmov    column-label "Data.Mov"
        tt-mapcxa.nrored    column-label "Red." format ">>99"
        mapcxa.t01       column-label "Val.17%" format ">>,>>9.99"
        mapcxa.t02       column-label "Val.12%" format ">,>>9.99"
        mapcxa.t03       column-label "Val.07%" format ">,>>9.99"
        mapcxa.vlsub     column-label "Val.Sub" 
        tt-mapcxa.venbru column-label "Venda Bruta"
            with frame frame-a 12 down centered row 4 
                title "Periodo: " + string(vdti) + " - " + 
                      string(vdtf).

    recatu1 = recid(tt-mapcxa).
    color display message
        esqcom1[esqpos1]
            with frame f-com1.
    repeat:
        find next tt-mapcxa where
                true.
        if not available tt-mapcxa
        then leave.
        if frame-line(frame-a) = frame-down(frame-a)
        then leave.
        if vinicio
        then down
            with frame frame-a.
        find mapcxa where recid(mapcxa) = tt-mapcxa.rec no-lock.
        display
            tt-mapcxa.etbcod
            tt-mapcxa.cxacod
            mapcxa.de1
            mapcxa.datmov
            tt-mapcxa.nrored 
            mapcxa.t01    
            mapcxa.t02    
            mapcxa.t03    
            mapcxa.vlsub   
            tt-mapcxa.venbru  
                with frame frame-a.
    end.
    up frame-line(frame-a) - 1 with frame frame-a.

    repeat with frame frame-a:

        find tt-mapcxa where recid(tt-mapcxa) = recatu1.

        run color-message.
        choose field tt-mapcxa.etbcod
            go-on(cursor-down cursor-up
                  cursor-left cursor-right
                  page-down page-up
                  tab PF4 F4 ESC return).
        run color-normal.
        
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
                esqpos1 = if esqpos1 = 5
                          then 5
                          else esqpos1 + 1.
                color display messages
                    esqcom1[esqpos1]
                    with frame f-com1.
            end.
            else do:
                color display normal
                    esqcom2[esqpos2]
                    with frame f-com2.
                esqpos2 = if esqpos2 = 5
                          then 5
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
                find next tt-mapcxa where true no-error.
                if not avail tt-mapcxa
                then leave.
                recatu1 = recid(tt-mapcxa).
            end.
            leave.
        end.
        if keyfunction(lastkey) = "page-up"
        then do:
            do reccont = 1 to frame-down(frame-a):
                find prev tt-mapcxa where true no-error.
                if not avail tt-mapcxa
                then leave.
                recatu1 = recid(tt-mapcxa).
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
            find next tt-mapcxa where
                true no-error.
            if not avail tt-mapcxa
            then next.
            color display normal
                tt-mapcxa.etbcod.
            if frame-line(frame-a) = frame-down(frame-a)
            then scroll with frame frame-a.
            else down with frame frame-a.
        end.
        if keyfunction(lastkey) = "cursor-up"
        then do:
            find prev tt-mapcxa where
                true no-error.
            if not avail tt-mapcxa
            then next.
            color display normal
                tt-mapcxa.etbcod.
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

            if esqcom1[esqpos1] = "Inclusao"
            then do with frame f-inclui overlay row 6 2 column centered.
        
                create mapcxa.
                update mapcxa.etbcod   label "Filial"
                       mapcxa.de1 label "Caixa"   
                       mapcxa.cxacod   label "Equipamento"
                       mapcxa.de2      label "Versao"
                       mapcxa.ch1 format "x(25)" label "No.Serie"
                       mapcxa.datmov   label "Data Movimento"
                       mapcxa.datred   label "Data Ultima Reducao"
                       mapcxa.datatu   label "Data Atual"
                       mapcxa.nrored   label "Ultima Reducao Z"
                       mapcxa.t01      label "Val.17%"
                       mapcxa.t02      label "Val.12%" format ">,>>9.99"
                       mapcxa.t03      label "Val.07%"
                       mapcxa.vlsub    label "Val.Sub" 
                       mapcxa.gtotal   label "Grande Total"
                       cooini          label "Contador Inicial"
                       coofin          label "Contador Final".

                                      
                create tt-mapcxa. 
                assign tt-mapcxa.etbcod = mapcxa.etbcod 
                       tt-mapcxa.cxacod = mapcxa.cxacod 
                       tt-mapcxa.datmov = mapcxa.datmov
                       tt-mapcxa.rec    = recid(mapcxa)
                       tt-mapcxa.venbru = mapcxa.t01 + 
                                          mapcxa.t02 + 
                                          mapcxa.t03 + 
                                          mapcxa.t04 + 
                                          mapcxa.t05 + 
                                          mapcxa.vlsub.
                if int(mapcxa.nrofab) > 0
                then tt-mapcxa.nrored = mapcxa.nrored + 1.
                else tt-mapcxa.nrored = mapcxa.nrored.
            
                
                assign vtot01 = 0
                       vtot02 = 0 
                       vtot03 = 0 
                       vtot04 = 0 
                       vtot05 = 0.
            
                for each estab where if vetbcod = 0
                                     then true
                                     else estab.etbcod = vetbcod no-lock:
                         
        
                    for each bmapcxa where bmapcxa.etbcod = estab.etbcod and 
                                           bmapcxa.datmov >= vdti        and 
                                           bmapcxa.datmov <= vdtf no-lock:
                                  
                        assign vtot01 = vtot01 + bmapcxa.t01
                               vtot02 = vtot02 + bmapcxa.t02
                               vtot03 = vtot03 + bmapcxa.t03
                               vtot04 = vtot04 + bmapcxa.vlsub
                               vtot05 = vtot05 + (bmapcxa.t01 + 
                                                  bmapcxa.t02 + 
                                                  bmapcxa.t03 + 
                                                  bmapcxa.t04 + 
                                                  bmapcxa.t05 + 
                                                  bmapcxa.vlsub).
                    end.
                    
                end. 

                recatu1 = recid(tt-mapcxa).
                leave.
            end.
            if esqcom1[esqpos1] = "Alteracao"
            then do with frame frame-altera.

                find mapcxa where recid(mapcxa) = tt-mapcxa.rec.

                update mapcxa.datmov   
                       mapcxa.t01      
                       mapcxa.t02      
                       mapcxa.t03  
                       mapcxa.t05    
                       mapcxa.vlsub
                       mapcxa.vlcan
                       mapcxa.gtotal
                       mapcxa.ch1 format "x(21)"
                       . 
                
                assign vtot01 = 0
                       vtot02 = 0 
                       vtot03 = 0 
                       vtot04 = 0 
                       vtot05 = 0.
            
                for each estab where if vetbcod = 0
                                     then true
                                     else estab.etbcod = vetbcod no-lock:
                         
        
                    for each bmapcxa where bmapcxa.etbcod = estab.etbcod and 
                                           bmapcxa.datmov >= vdti        and 
                                           bmapcxa.datmov <= vdtf no-lock:
                                  
                        assign vtot01 = vtot01 + bmapcxa.t01
                               vtot02 = vtot02 + bmapcxa.t02
                               vtot03 = vtot03 + bmapcxa.t03
                               vtot04 = vtot04 + bmapcxa.vlsub
                               vtot05 = vtot05 + (bmapcxa.t01 + 
                                                  bmapcxa.t02 + 
                                                  bmapcxa.t03 + 
                                                  bmapcxa.t04 + 
                                                  bmapcxa.t05 + 
                                                  bmapcxa.vlsub).
                    end.
                    
                end. 
                       

            end.
            if esqcom1[esqpos1] = "Consulta"
            then do with frame f-consulta overlay row 6 2 column centered.
                find mapcxa where recid(mapcxa) = tt-mapcxa.rec no-lock.
                disp mapcxa.etbcod   label "Filial"
                     int(mapcxa.de1) label "Caixa"   
                     mapcxa.cxacod   label "Equipamento"
                     mapcxa.de2      label "Versao"
                     mapcxa.ch1 format "x(25)" label "No.Serie"
                     mapcxa.datmov   label "Data Movimento"
                     mapcxa.datred   label "Data Reducao"
                     mapcxa.datatu   label "Data Atual"
                     mapcxa.nrored   label "Reducao Z"
                     mapcxa.t01      label "Val.17%"
                     mapcxa.t02      label "Val.12%" format ">,>>9.99"
                     mapcxa.t03      label "Val.07%"
                     mapcxa.vlsub    label "Val.Sub" 
                     mapcxa.gtotal   label "Grande Total"
                     cooini          label "Contador Inicial"
                     coofin          label "Contador Final".
            
            end.
            if esqcom1[esqpos1] = "Exclusao"
            then do with frame f-exclui overlay row 6 1 column centered.
                message "Confirma Exclusao de" tt-mapcxa.cxacod update sresp.
                if not sresp
                then leave.
                find next tt-mapcxa where true no-error.
                if not available tt-mapcxa
                then do:
                    find tt-mapcxa where recid(tt-mapcxa) = recatu1.
                    find prev tt-mapcxa where true no-error.
                end.
                recatu2 = if available tt-mapcxa
                          then recid(tt-mapcxa)
                          else ?.
                find tt-mapcxa where recid(tt-mapcxa) = recatu1.
                find mapcxa where mapcxa.etbcod = tt-mapcxa.etbcod and
                                  mapcxa.cxacod = tt-mapcxa.cxacod and
                                  mapcxa.datmov = tt-mapcxa.datmov
                                    no-error.
                if avail mapcxa
                then do:
                    
                    delete mapcxa.
                    
                end.
                delete tt-mapcxa.
                
                assign vtot01 = 0
                       vtot02 = 0 
                       vtot03 = 0 
                       vtot04 = 0 
                       vtot05 = 0.
            
                for each estab where if vetbcod = 0
                                     then true
                                     else estab.etbcod = vetbcod no-lock:
                         
        
                    for each bmapcxa where bmapcxa.etbcod = estab.etbcod and 
                                           bmapcxa.datmov >= vdti        and 
                                           bmapcxa.datmov <= vdtf no-lock:
                                  
                        assign vtot01 = vtot01 + bmapcxa.t01
                               vtot02 = vtot02 + bmapcxa.t02
                               vtot03 = vtot03 + bmapcxa.t03
                               vtot04 = vtot04 + bmapcxa.vlsub
                               vtot05 = vtot05 + (bmapcxa.t01 + 
                                                  bmapcxa.t02 + 
                                                  bmapcxa.t03 + 
                                                  bmapcxa.t04 + 
                                                  bmapcxa.t05 + 
                                                  bmapcxa.vlsub).
                    end.
                    
                end. 
                 
                recatu1 = recatu2.
                leave.
            end.
            if esqcom1[esqpos1] = "Listagem"
            then do with frame f-Lista overlay row 6 1 column centered.
                
                display vtipo no-label 
                        with frame flista no-label row 10 centered.

                choose field vtipo with frame flista.
                hide frame flista no-pause. 
                if frame-index = 1 
                then run rel_map2.p (input vetbcod,
                                     input vdti,
                                     input vdtf).

                if frame-index = 2 
                then run rel_map.p (input tt-mapcxa.etbcod,
                                    input vdti,
                                    input vdtf).


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

        find mapcxa where recid(mapcxa) = tt-mapcxa.rec no-lock.
  
        display tt-mapcxa.etbcod
                tt-mapcxa.cxacod 
                mapcxa.de1
                mapcxa.datmov
                tt-mapcxa.nrored  
                mapcxa.t01     
                mapcxa.t02     
                mapcxa.t03     
                mapcxa.vlsub   
                tt-mapcxa.venbru
                    with frame frame-a.
        if esqregua
        then display esqcom1[esqpos1] with frame f-com1.
        else display esqcom2[esqpos2] with frame f-com2.
        recatu1 = recid(tt-mapcxa).
   end.
end.
end.

procedure color-message.
color display message tt-mapcxa.etbcod  
                      tt-mapcxa.cxacod 
                      mapcxa.de1 
                      mapcxa.datmov
                      tt-mapcxa.nrored   
                      mapcxa.t01      
                      mapcxa.t02      
                      mapcxa.t03      
                      mapcxa.vlsub     
                      tt-mapcxa.venbru
                        with frame frame-a.
end procedure.
procedure color-normal.
color display normal tt-mapcxa.etbcod 
                     tt-mapcxa.cxacod 
                     mapcxa.de1
                     mapcxa.datmov 
                     tt-mapcxa.nrored  
                     mapcxa.t01     
                     mapcxa.t02     
                     mapcxa.t03     
                     mapcxa.vlsub     
                     tt-mapcxa.venbru
                        with frame frame-a.
end procedure.


