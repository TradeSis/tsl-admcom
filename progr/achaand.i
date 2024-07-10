/*---------------------------------------------------------------------------*/
/* /usr/admger/zoomesq.i                                    Esqueleto do Zoom */
/*                                                                            */
/* Data     Autor   Caracteristica                                            */
/* -------- ------- ------------------                                        */
/* 27/02/92 Miguel  Criacao                                                   */
/* 28/05/92 Miguel  Modifiquei de pre-select p/ for each por performance.     */
/* 29/08/96 Alessan Modificacao nos for each                                  */
/*----------------------------------------------------------------------------*/
def var vdtnasc as char format "x(10)".
def var array as char format "x({4})" extent 13.
def var array1 as char format "x(50)" extent 13.
def var array-cod as char format "x(10)" extent 13.
def var campo as char format "x({4})".
def var aux as char format "x({4})".
def var aux-cod as char format "x(10)".
def var i as i.
def var j as i.
form campo
     with no-label frame f1
          overlay column 79 - {4} row 4 title color white/black " ZOOM "
                  color black/CYAN.

form array 
     with no-label frame f2
          overlay column 79 - {4} title color white/black " {5} "
          1 column color black/CYAN. view frame f1.

l1:
    repeat with frame f2:
        for each {1} {7} where {6} no-lock by {3} with frame f2 i = 1 to 13:
            
            if (clien.dtnasc = ?) or (not avail clien)
            then vdtnasc = "".
            else vdtnasc = string(clien.dtnasc,"99/99/9999").
            
            array1[i] = {3}.
            array[i] = string({3},"x(40)") + " - " +
                       string(clien.clicod,">>>>>>>9") + " " +
                       vdtnasc.
                       array-cod[i] = string({2}).
        end.
        display array.
        campo = array[1].
    
        display campo with frame f1.
        color display normal array[1].
        i = 1.
        
        prompt-for campo with frame f1 editing:
                   color display message array[i].
                  
        if lastkey = keycode("PAGE-DOWN") or
           lastkey = keycode("PAGE-UP") or 
           lastkey = keycode("CURSOR-DOWN") or 
           lastkey = keycode("CURSOR-UP")
        then do:
        
            next-prompt campo with frame f1.
            campo = array[i].
            display campo with frame f1.
        
        end.
        
        readkey.
        
        if lastkey = keycode("F4") or 
           lastkey = keycode("PF4") 
        then leave l1.
        
        if lastkey = keycode("CURSOR-RIGHT") or
           lastkey = keycode("CURSOR-LEFT")
        then do: 
            bell. 
            next. 
        end.
        
        color display normal array[i].
        hide message.

        if lastkey = keycode("PAGE-DOWN") 
        then do: 
            if array[13] <> "" 
            then do: 
                for each {1} {7} where ({6}) and {3} > array1[13] no-lock 
                    by (3) j = 1 to 13:
                    
                    if (clien.dtnasc = ?) or (not avail clien) 
                    then vdtnasc = "". 
                    else vdtnasc = string(clien.dtnasc,"99/99/9999"). 
                    
                    array1[j] = {3}. 
                    array[j] = string({3},"x(40)") + " - " + 
                               string(clien.clicod,">>>>>>>9") + " " +
                               vdtnasc.
                               
                    array-cod[j] = string({2}). 
                end.  
                
                if j > 0 
                then do: 
                    if j < 13
                    then do i = j + 1 to 13: 
                        
                        array[i] = "". 
                        array1[i] = "".
                        
                    end.
                    
                    i = 1. 
                    
                    display array. 
                    next.  
                end.
            end. 
            
            bell. 
            next. 
            
        end. 
        
        if lastkey = keycode("PAGE-UP") 
        then do: 
            for each {1}  {7} where ({6}) and {3} <= array1[1] no-lock 
                by {3} descending j = 13 to 1 by -1:
                
                if (clien.dtnasc = ?) or (not avail clien) 
                then vdtnasc = "". 
                else vdtnasc = string(clien.dtnasc,"99/99/9999"). 
                
                array1[j] = {3}. 
                array[j] = string({3},"x(40)") + " - " + 
                           string(clien.clicod,">>>>>>>9") + " " +
                           vdtnasc.
                
                array-cod[j] = string({2}).
            end.
            
            if j < 14
            then do: 
                if j > 1 
                then do: 
                    array1[1] = array1[j].
                    array[1] = array[j].
                    array-cod[1] = array-cod[j]. 
                    
                    for each {1} {7} where ({6}) and {3} > array1[1] no-lock
                                 by {3} j = 2 to 13: 
                                 
                        
                        if (clien.dtnasc = ?) or (not avail clien) 
                        then vdtnasc = "". 
                        else vdtnasc = string(clien.dtnasc,"99/99/9999").
                        
                        array1[j] = {3}. 
                        array[j] = string({3},"x(40)") + " - " +
                                   string(clien.clicod,">>>>>>>9") + " " +
                                   vdtnasc.
                        array-cod[j] = string({2}).
                    end.
                end. 
                
                i = 1. 
                
                display array.
                next.
             
            end. 
             
            bell. 
            next. 
             
        end. 
        
        if lastkey = keycode("CURSOR-UP")
        then do: 
            if i > 1 
            then i = i - 1. 
            else do: 
            
                for each {1} {7} where ({6}) and {3} <= array1[1]
                                   and {2} <> int(array-cod[1]) 
                                   by {3} descending j = 1 to 1:

                        if (clien.dtnasc = ?) or (not avail clien) 
                        then vdtnasc = "". 
                        else vdtnasc = string(clien.dtnasc,"99/99/9999").
                        
                        aux = string({3},"x(40)") + " - " +
                              string(clien.clicod,">>>>>>>9") + " " +
                              vdtnasc.
                        
                    
                    aux-cod = string({2}).
                end. 
                
                if j > 0 
                then do: 
                    do i = 13 to 2 by -1: 
                        array[i] = array[i - 1]. 
                        array-cod[i] = array-cod[i - 1].
                        array1[i] = array1[i - 1].
                    end. 
                    
                    i = 1. 
                    array[i] = aux. 
                    array-cod[i] = aux-cod. 
                    array1[i] = {3}. 
                    
                    display array. 
                    
                end.
                else bell.
            end. 
            next. 
        end. 
        
        if lastkey = keycode("CURSOR-DOWN") 
        then do: 
            if i < 13 
            then do: 
                if array1[i + 1] = "" 
                then do: 
                    bell. 
                    next. 
                end. 
                
                i = i + 1.
            end. 
            else do: 
                for each {1}  {7}  where ({6}) and {3} >= array1[13]
                                     and {2} <> int(array-cod[13]) 
                                     no-lock by {3} j = 1 to 1:

                        if (clien.dtnasc = ?) or (not avail clien)
                        then vdtnasc = "".
                        else vdtnasc = string(clien.dtnasc,"99/99/9999").

                        aux =  string({3},"x(40)") + " - " +
                               string(clien.clicod,">>>>>>>9") + " " + vdtnasc.

                    aux-cod = string({2}).
                    
                end. 
                if j > 0 
                then do: 
                    do i = 1 to 12: 
                        array1[i] = array1[i + 1]. 
                        array[i] = array[i + 1].  
                        array-cod[i] = array-cod[i + 1].
                    end. 
                    i = 13. 
                    array1[i] = {3}. 
                    array[i] = aux.
                    array-cod[i] = aux-cod. 
                    display array. 
                end. 
                else bell. 
                
            end. 
            next.
        end. 
            
        if lastkey = keycode("RETURN") or
           lastkey = keycode("PF1") 
        then leave l1. 
        
        apply lastkey. 
        
        if input campo >= array[1] and input campo <= array[13]
        then do: 
            do j = 1 to 13: 
                if array[j] begins input campo 
                then leave. 
            end.
        
            if j <> 14 
            then do: 
                i = j. 
                next. 
            end. 
        end. 
        else do: 
            find first {1} {7} where ({6}) and {3} begins input campo
                                       no-lock no-error. 
            if available {1} 
            then do: 
                if (clien.dtnasc = ?) or (not avail clien)
                then vdtnasc = "".
                else vdtnasc = string(clien.dtnasc,"99/99/9999"). 
                
                array1 = "". 
                array = "". 
                
                array[1] = string({3},"x(40)") + " - " +
                           string(clien.clicod,">>>>>>>9") + " " + vdtnasc.
                
                array1[1] = {3}.

                array-cod[1] = string({2}). 
                
                for each {1} {7} where ({6}) and {3} > array1[1] no-lock
                                      by {3} i = 2 to 13:
                                      
                    if (clien.dtnasc = ?) or (not avail clien) 
                    then vdtnasc = "". 
                    else vdtnasc = string(clien.dtnasc,"99/99/9999").
                    
                    array1[i] = {3}. 
                    array[i] = string({3},"x(40)") + " - " +
                               string(clien.clicod,">>>>>>>9") + " " + vdtnasc.
                               
                    array-cod[i] = string({2}).
                end. 
                
                i = 1. 
                display array. 
                next.
            end.
        end. 

        bell. 
        message "Nenhuma ocorrencia com estas iniciais.". 
        apply keycode("BACKSPACE"). 
    end. 
end. 

hide frame f1 no-pause. 
hide frame f2 no-pause. 
if lastkey <> keycode("PF4") and 
   lastkey <> keycode("F4") 
then assign frame-value = array-cod[i]. 

sretorno    = array-cod[i].