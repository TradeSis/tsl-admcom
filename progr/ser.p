/*
*
*    MANUTENCAO EM acrfilELECIMENTOS                         finan.p    02/05/95
*
*/


{admcab.i}  

def var vdtini  like plani.pladat.
def var vdtfin  like plani.pladat.
def var vativo  as log.
def var vprocod like produ.procod.
 
def temp-table tt-icms
    field procod like produ.procod
    field dtini  like plani.pladat
    field dtfin  like plani.pladat
    field ativo  as log
        index ind-1 procod.




def temp-table tt-07
    field etbcod like estab.etbcod
    field cxacod like plani.cxacod
    field data   like plani.pladat
    field valor  like plani.platot.
def var icms07  like plani.platot.
def var icms17  like plani.platot.    
def input parameter vetb like estab.etbcod.
def input parameter vdt1 as date.
def input parameter vdt2 as date.
def var v-mar as dec.
def var vmarca          as char format "x"                          no-undo.
def var reccont         as int.
def var vinicio         as log.
def var recatu1         as recid.
def var recatu2         as recid.
def var esqpos1         as int.
def var esqpos2         as int.
def var esqregua        as log.
def var esqcom1         as char format "x(12)" extent 5
            initial ["Inclusao","Alteracao","Exclusao","","        "].
def var esqcom2         as char format "x(12)" extent 5
            initial ["","","","",""].


def buffer bserial       for serial.
def var vclicod         like serial.redcod.

def var v-ven  as dec.
def var v-con  as dec.
def var v-acr  as dec.
def var v-07   as dec.

    form
        esqcom1
            with frame f-com1
                 row 3 no-box no-labels side-labels column 1.
    form
        esqcom2
            with frame f-com2
                 row screen-lines no-box no-labels side-labels column 1.
    esqregua  = yes.
    esqpos1  = 1.
    esqpos2  = 1.
    v-ven = 0.
    v-acr = 0.
    v-con = 0.
    v-07  = 0.


    for each tt-07.
        delete tt-07.
    end.
    
    
    find estab where estab.etbcod = vetb no-lock.
    

   
    for each tt-icms:
        delete tt-icms.
    end.
    
    input from ..\progr\icms.txt.
    repeat:
        import vprocod
               vdtini
               vdtfin
               vativo.
        find first tt-icms where tt-icms.procod = vprocod no-error.
        if not avail tt-icms
        then do:
               
        
            create tt-icms.
            assign tt-icms.procod = vprocod
                   tt-icms.dtini  = vdtini
                   tt-icms.dtfin  = vdtfin
                   tt-icms.ativo  = vativo.
                   
                   
            
        end.
        
    end.
    input close.

    for each tt-icms.

        find produ where produ.procod = tt-icms.procod no-lock no-error.
        if not avail produ
        then do:
            delete tt-icms.
            next.
        end.
    
    end.    
     
    
    
    for each tt-icms where tt-icms.dtini <= vdt1 and
                           tt-icms.dtfin >= vdt2:
        for each movim where movim.etbcod = estab.etbcod and
                             movim.movtdc = 5            and
                             movim.movdat >= vdt1        and
                             movim.movdat <= vdt2        and
                             movim.procod = tt-icms.procod no-lock.
                             
            find plani where plani.etbcod = movim.etbcod and
                             plani.placod = movim.placod and
                             plani.movtdc = movim.movtdc and
                             plani.pladat = movim.movdat no-lock no-error.
            if not avail plani
            then next.
            
            find first tt-07 where tt-07.etbcod = plani.etbcod and
                                   tt-07.cxacod = plani.cxacod and
                                   tt-07.data   = plani.pladat no-error.
            if not avail tt-07
            then do:
                create tt-07.
                assign tt-07.etbcod = plani.etbcod
                       tt-07.cxacod = plani.cxacod
                       tt-07.data   = plani.pladat.
            end.
            tt-07.valor = tt-07.valor + (movim.movpc * movim.movqtm).
        end.
    end.        
                                   
                              

    
    
    
    for each serial where serial.etbcod = vetb and
                          serial.serdat >= vdt1 and
                          serial.serdat <= vdt2 no-lock:
        
        find first tt-07 where tt-07.etbcod = serial.etbcod and
                               tt-07.cxacod = serial.cxacod and
                               tt-07.data   = serial.serdat no-error.
        if avail tt-07
        then icms07 = tt-07.valor.
        else icms07 = 0.
                               
         
        v-ven = v-ven + serial.icm12.
        v-con = v-con + (serial.icm17 - icms07).
        v-acr = v-acr + serial.serval.
        v-07  = v-07  + icms07.
        
        
    end.
 
    
    
    display  v-07    to 32
             v-ven   to 42
             v-con   to 53
             v-acr   to 74
                with frame f-tot no-label row 20 no-box
                         color white/red centered.
 


bl-princ:
repeat:

    disp esqcom1 with frame f-com1.
    disp esqcom2 with frame f-com2.
    if recatu1 = ?
    then
        find first serial where serial.etbcod = vetb and
                                serial.serdat >= vdt1 and
                                serial.serdat <= vdt2 no-error.
    else find serial where recid(serial) = recatu1.
    vinicio = no.
    if not available serial
    then do:
        bell.
        message "Nao existe Ecf para esta filial".
        pause.
        return.
        form serial
            with frame f-altera
            overlay row 6 1 column centered color white/cyan.
        message "Cadastro de Ecf Vazio".
        message "Deseja Incluir " update sresp.
        if not sresp
        then undo.
        do transaction with frame f-altera:
                create serial.
                update serial.
                vinicio = yes.
        end.
    end.
    clear frame frame-a all no-pause.

    find first tt-07 where tt-07.etbcod = serial.etbcod and
                           tt-07.cxacod = serial.cxacod and
                           tt-07.data   = serial.serdat no-error.
                           
    if avail tt-07
    then icms07 = tt-07.valor.
    else icms07 = 0.
    
    icms17 = serial.icm17 - icms07.

    display 
            serial.serdat
            serial.redcod format ">>>>>>>9"
            serial.cxacod column-label "CX" format ">9"
            icms07   column-label "Icms 07" format ">>,>>9.99"
            serial.icm12  format ">>,>>9.99"
            icms17 @ serial.icm17
                    format ">>>,>>9.99" column-label "Icms 17"
            serial.sersub format ">,>>9.99" column-label "Sub.Trib."
            serial.serval format ">>>,>>9.99"
            with frame frame-a 12 down centered color white/red
            title string(estab.etbcod) + " " +
                  estab.etbnom + " " +
                  string(vdt1,"99/99/9999") + " " +
                  string(vdt2,"99/99/9999").

    recatu1 = recid(serial).
    color display message
        esqcom1[esqpos1]
            with frame f-com1.
    repeat:
        find next serial where serial.etbcod = vetb and
                               serial.serdat >= vdt1 and
                               serial.serdat <= vdt2 no-error.
        if not available serial
        then leave.
        if frame-line(frame-a) = frame-down(frame-a)
        then leave.
        if vinicio = no
        then down with frame frame-a.
        find first tt-07 where tt-07.etbcod = serial.etbcod and
                               tt-07.cxacod = serial.cxacod and
                               tt-07.data   = serial.serdat no-error.
                 
        if avail tt-07 
        then icms07 = tt-07.valor. 
        else icms07 = 0.
    
                        

        icms17 = serial.icm17 - icms07.

 
        display 
            serial.serdat
            serial.redcod
            serial.cxacod
            icms07
            serial.icm12
            icms17 @ serial.icm17
            serial.sersub
            serial.serval
                with frame frame-a.
    end.
    up frame-line(frame-a) - 1 with frame frame-a.

    repeat with frame frame-a:

        find serial where recid(serial) = recatu1.

        choose field serial.redcod
            go-on(cursor-down cursor-up
                  page-down   page-up
                  cursor-left cursor-right
                  tab PF4 F4 ESC return).
        hide message no-pause.
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
        if keyfunction(lastkey) = "page-down"
        then do:
            do reccont = 1 to frame-down(frame-a):
                find next serial where serial.etbcod = vetb and
                                       serial.serdat >= vdt1 and
                                       serial.serdat <= vdt2 no-error.
                if not avail serial
                then leave.
                recatu2 = recid(serial).
            end.
            if reccont = frame-down(frame-a)
            then recatu1 = recatu2.
            leave.
        end.
        if keyfunction(lastkey) = "page-up"
        then do:
            do reccont = 1 to frame-down(frame-a):
                find prev serial where serial.etbcod = vetb and
                                       serial.serdat >= vdt1 and
                                       serial.serdat <= vdt2 no-error.
                if not avail serial
                then leave.
                recatu1 = recid(serial).
            end.
            leave.
        end.
        if keyfunction(lastkey) = "cursor-down"
        then do:
            find next serial where serial.etbcod = vetb and
                                   serial.serdat >= vdt1 and
                                   serial.serdat <= vdt2 no-error.
            if not avail serial
            then next.
            color display white/red
                serial.redcod.
            if frame-line(frame-a) = frame-down(frame-a)
            then scroll with frame frame-a.
            else down with frame frame-a.
        end.
        if keyfunction(lastkey) = "cursor-up"
        then do:
            find prev serial where serial.etbcod = vetb and
                                   serial.serdat >= vdt1 and
                                   serial.serdat <= vdt2 no-error.
            if not avail serial
            then next.
            color display white/red
                serial.redcod.
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
            then do transaction with frame f-inc side-label.
                create serial.
                update serial.etbcod colon 16
                       serial.cxacod colon 16
                       serial.redcod
                       serial.serdat
                       serial.icm12  colon 16
                       serial.icm17 
                       serial.sersub. 
                
                serial.serval = serial.icm12 + serial.icm17 + serial.sersub.

                v-ven = 0.
                v-con = 0.
                v-acr = 0.
                for each bserial where bserial.etbcod = serial.etbcod and
                                       bserial.serdat >= vdt1 and
                                       bserial.serdat <= vdt2 no-lock.
                    v-ven = v-ven + bserial.icm12.
                    v-con = v-con + bserial.icm17.
                    v-acr = v-acr + bserial.serval.
                end.
                
                recatu1 =  recid(serial).                 
                leave.
            end.
            
            
            if esqcom1[esqpos1] = "Exclusao"
            then do with frame f-altera:
                message "Confirma Exclusao" serial.redcod update sresp.
                if not sresp
                then leave.
                find next serial where serial.etbcod = vetb and
                                       serial.serdat >= vdt1 and
                                       serial.serdat <= vdt2 no-error.
                if not available serial
                then do:
                    find serial where recid(serial) = recatu1.
                    find prev serial where serial.etbcod = vetb and
                                           serial.serdat >= vdt1 and
                                           serial.serdat <= vdt2
                                no-error.
                end.
                recatu2 = if available serial
                          then recid(serial)
                          else ?.
                find serial where recid(serial) = recatu1.
                do transaction:
                    find retra where retra.etbcod = serial.etbcod and
                                     retra.dtret  = serial.serdat and
                                     retra.dtsol  = serial.serdat and
                                     retra.tabela = string(serial.redcod)
                                            no-error.
                    if not avail retra
                    then do:
                        create retra.
                        assign retra.etbcod = serial.etbcod 
                               retra.dtret  = serial.serdat 
                               retra.dtsol  = serial.serdat 
                               retra.tabela = string(serial.redcod).
                    end.           
                    delete serial.
                end.
                recatu1 = recatu2.
                leave.
            end.
            if esqcom1[esqpos1] = "Alteracao"
            then do transaction with frame frame-a.
                update serial.redcod
                       serial.icm12
                       serial.icm17 
                       serial.sersub.
                serial.serval = serial.icm12 + serial.icm17 + serial.sersub.

                v-ven = 0.
                v-con = 0.
                v-acr = 0.
                
                for each bserial where bserial.etbcod = serial.etbcod and
                                       bserial.serdat >= vdt1 and
                                       bserial.serdat <= vdt2 no-lock.
                    v-ven = v-ven + bserial.icm12.
                    v-con = v-con + bserial.icm17.
                    v-acr = v-acr + bserial.serval.
                end.

                recatu1 = recid(serial). 
                leave. 
            end.
            
            if esqcom1[esqpos1] = "Consulta" or
               esqcom1[esqpos1] = "Exclusao"
            then do with frame f-altera:
                disp serial.
            end.
            if esqcom1[esqpos1] = "Listagem"
            then leave bl-princ.
            if esqcom1[esqpos1] = "Marca"
            then do:
            end.
            if esqcom1[esqpos1] = "Listagem"
            then do:
                message "Confirma Impressao do serialelecimento" update sresp.
                if not sresp
                then LEAVE.
                recatu2 = recatu1.
                output to printer.
                for each serial where serial.etbcod = vetb and
                                      serial.serdat >= vdt1 and
                                      serial.serdat <= vdt2 no-lock:
                    display serial.
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
        if keyfunction (lastkey) = "end-error"
        then view frame frame-a.

        find first tt-07 where tt-07.etbcod = serial.etbcod and
                               tt-07.cxacod = serial.cxacod and
                               tt-07.data   = serial.serdat no-error.
                               
                 
        if avail tt-07 
        then icms07 = tt-07.valor. 
        else icms07 = 0.
    
        icms17 = serial.icm17 - icms07.
                 
    
          
        display 
            serial.serdat
            serial.redcod
            serial.cxacod
            icms07
            serial.icm12
            icms17 @ serial.icm17
            serial.sersub
            serial.serval
                with frame frame-a.
                               

        display 
             v-07  to 32
             v-ven to 42
             v-con to 53
             v-acr to 74
                with frame f-tot no-label row 20 no-box
                         color white/red centered.
        if esqregua
        then display esqcom1[esqpos1] with frame f-com1.
        else display esqcom2[esqpos2] with frame f-com2.
        recatu1 = recid(serial).
   end.
end.
