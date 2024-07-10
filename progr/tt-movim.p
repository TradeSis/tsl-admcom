{admcab.i}


def shared temp-table tt-movim
    field rec as recid 
    field procod    like movim.procod 
    field movqtm    like movim.movqtm 
    field movpc     like movim.movpc   
    field movalicms like movim.movalicms  
    field movicms   like movim.movicms    
    field movalipi  like movim.movalipi   
    field movipi    like movim.movipi     
    field movpdes   like movim.movpdes    
    field movdes    like movim.movdes     
    field movdev    like movim.movdev.   



form tt-movim.procod column-label "Codigo" format ">>>>>9" 
     tt-movim.movqtm format ">>>>9" column-label "Qtd"   
     tt-movim.movpc  format ">>,>>9.99" column-label "Val.Unit" 
     tt-movim.movalicms column-label "%ICMS" format ">9.99" 
     tt-movim.movicms   column-label "ICMS"  format ">>,>>9.99" 
     tt-movim.movalipi  column-label "%IPI"  format ">9.99" 
     tt-movim.movipi    column-label "IPI"   format ">,>>9.99" 
     tt-movim.movpdes   column-label "%Des" format ">9.99" 
     tt-movim.movdes    column-label "Desc" format ">>,>>9.99" 
     tt-movim.movdev    column-label "Frete" format ">,>>9.99"
        with frame frame-a row 13 7 down overlay
                   centered color white/cyan width 80.



def var reccont         as int.
def var vinicio         as log.
def var recatu1         as recid.
def var recatu2         as recid.
def var esqpos1         as int.
def var esqpos2         as int.
def var esqregua        as log.


def buffer btt-movim       for tt-movim.
def var vprocod         like tt-movim.procod.


    esqregua  = yes.
    esqpos1  = 1.
    esqpos2  = 1.

bl-princ:
repeat:

    if recatu1 = ?
    then find first tt-movim where true no-error.
    else find tt-movim where recid(tt-movim) = recatu1.
    vinicio = yes.
    if not available tt-movim
    then do:
        message "Nota Fiscal Sem Produtos".
        pause.
        return.
    end.
    clear frame frame-a all no-pause.
    display
        tt-movim.procod
        tt-movim.movqtm 
        tt-movim.movpc    
        tt-movim.movalicms   
        tt-movim.movicms     
        tt-movim.movalipi    
        tt-movim.movipi      
        tt-movim.movpdes     
        tt-movim.movdes      
        tt-movim.movdev
            with frame frame-a.
        
    find produ where produ.procod = tt-movim.procod no-lock.

    display produ.pronom label "Produto" format "x(40)"  
            produ.codfis label "Class.Fiscal" format ">>>>>>>9" 
                with frame f-pro overlay
                    side-label centered row 10 
                        color white/cyan width 80.
    
    recatu1 = recid(tt-movim).
    repeat:
        find next tt-movim where true.
        if not available tt-movim
        then leave.
        if frame-line(frame-a) = frame-down(frame-a)
        then leave.
        if vinicio
        then down with frame frame-a.

        display tt-movim.procod 
                tt-movim.movqtm  
                tt-movim.movpc     
                tt-movim.movalicms    
                tt-movim.movicms      
                tt-movim.movalipi     
                tt-movim.movipi       
                tt-movim.movpdes      
                tt-movim.movdes       
                tt-movim.movdev 
                       with frame frame-a.
        
        find produ where produ.procod = tt-movim.procod no-lock.
        display produ.pronom
                produ.codfis with frame f-pro.

     end.
    up frame-line(frame-a) - 1 with frame frame-a.

    repeat with frame frame-a:

        find tt-movim where recid(tt-movim) = recatu1.

        run color-message.
        choose field tt-movim.procod
            go-on(cursor-down cursor-up
                  cursor-left cursor-right
                  page-down page-up
                  tab PF4 F4 ESC return).
        run color-normal.
        

        if keyfunction(lastkey) = "page-down"
        then do:
            do reccont = 1 to frame-down(frame-a):
                find next tt-movim where true no-error.
                if not avail tt-movim
                then leave.
                recatu1 = recid(tt-movim).
            end.
            leave.
        end.
        if keyfunction(lastkey) = "page-up"
        then do:
            do reccont = 1 to frame-down(frame-a):
                find prev tt-movim where true no-error.
                if not avail tt-movim
                then leave.
                recatu1 = recid(tt-movim).
            end.
            leave.
        end.


        if keyfunction(lastkey) = "cursor-down"
        then do:
            find next tt-movim where
                true no-error.
            if not avail tt-movim
            then next.
            color display normal
                tt-movim.procod.
            if frame-line(frame-a) = frame-down(frame-a)
            then scroll with frame frame-a.
            else down with frame frame-a.
        end.
        if keyfunction(lastkey) = "cursor-up"
        then do:
            find prev tt-movim where
                true no-error.
            if not avail tt-movim
            then next.
            color display normal
                tt-movim.procod.
            if frame-line(frame-a) = 1
            then scroll down with frame frame-a.
            else up with frame frame-a.
        end.
        if keyfunction(lastkey) = "end-error"
        then leave bl-princ.

        if keyfunction(lastkey) = "return"
        then do on error undo, retry on endkey undo, leave.
        hide frame frame-a no-pause.

          view frame frame-a .
        end.
        if keyfunction(lastkey) = "end-error" 
        then view frame frame-a.
        
        display tt-movim.procod  
                tt-movim.movqtm   
                tt-movim.movpc      
                tt-movim.movalicms     
                tt-movim.movicms       
                tt-movim.movalipi      
                tt-movim.movipi        
                tt-movim.movpdes       
                tt-movim.movdes        
                tt-movim.movdev 
                    with frame frame-a.
         
        find produ where produ.procod = tt-movim.procod no-lock.
        display produ.pronom
                produ.codfis with frame f-pro.
 
        recatu1 = recid(tt-movim).
        
   end.
end.

procedure color-message.
 
find produ where produ.procod = tt-movim.procod no-lock. 
display produ.pronom 
        produ.codfis with frame f-pro.

 
 
color display message
        tt-movim.procod
        tt-movim.movqtm 
        tt-movim.movpc    
        tt-movim.movalicms   
        tt-movim.movicms     
        tt-movim.movalipi    
        tt-movim.movipi      
        tt-movim.movpdes     
        tt-movim.movdes      
        tt-movim.movdev
            with frame frame-a.

end procedure.
procedure color-normal.
find produ where produ.procod = tt-movim.procod no-lock. 
display produ.pronom 
        produ.codfis with frame f-pro.

 
color display normal
        tt-movim.procod
        tt-movim.movqtm 
        tt-movim.movpc    
        tt-movim.movalicms   
        tt-movim.movicms     
        tt-movim.movalipi    
        tt-movim.movipi      
        tt-movim.movpdes     
        tt-movim.movdes      
        tt-movim.movdev
            with frame frame-a.
end procedure.

