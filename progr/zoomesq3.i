/*----------------------------------------------------------------------------*/
/* /usr/admger/zoomesq.i                                    Esqueleto do Zoom */
/*                                                                            */
/* Data     Autor   Caracteristica                                            */
/* -------- ------- ------------------                                        */
/* 27/02/92 Miguel  Criacao                                                   */
/* 28/05/92 Miguel  Modifiquei de pre-select p/ for each por performance.     */
/*----------------------------------------------------------------------------*/
def var array     as char format "x({4})" extent 13.
def var array-aux as char format "x({4})" extent 13.
def var array-cod as char format "x(10)" extent 13.
def var campo as char format "x({4})".
def var aux as char format "x({4})".
def var aux-cod as char format "x(10)".
def var aux-seq as char format "x(10)".
def var vcont as integer.
def var vcont2 as integer.
def var vretorno   as char.
def var i as i.
def var j as i.
def temp-table tt-jamostrou
    field rowid as rowid.

def temp-table tt-{1} like {1}
        field numseq as integer
            index idx01 numseq.
    
form campo
        with no-label frame f1
        overlay column 79 - {4} row 4 title color normal " ZOOM "
        color message
        .
form array
        with no-label frame f2
        overlay column 79 - {4} title color normal " {5} "
        1 column
        color normal.
        
vcont = 0.

message "Carregando lista de {5}...".


for each {1} no-lock by {3} by {7}:
    
    assign vcont = vcont + 1.    
    
    create tt-{1}.
    buffer-copy {1} to tt-{1}.
    assign tt-{1}.numseq = vcont.
        
end.        
        
view frame f1.
l1:
repeat with frame f2:
    for each tt-{1} where {6} by tt-{1}.{3} with frame f2 i = 1 to 13:
        array-aux[i] = tt-{1}.{3}.
        array[i] = tt-{1}.{3}.
        array[i] = string(array[i],"x(35)") + " - " + tt-{1}.{7}.
        array-cod[i] = string(tt-{1}.{2}).
    end.
    display array.
    campo = array[1].
    display campo with frame f1.
    color display message array[1].
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
                for each tt-{1} where ({6})
                                and tt-{1}.{3} > array-aux[13]
                                            by tt-{1}.numseq j = 1 to 13:
                    array[j] = tt-{1}.{3}.
                    array[j] = string(array[j],"x(35)") + " - " + tt-{1}.{7}.
                    array-aux[j] = tt-{1}.{3}.
                    array-cod[j] = string(tt-{1}.{2}).
                end.
                if j > 0
                    then do:
                    if j < 13
                        then do i = j + 1 to 13:
                           array[i] = "".
                           array-aux[i] = "".
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
            for each tt-{1} where ({6}) and tt-{1}.{3} < array-aux[1]
                                        by tt-{1}.numseq descending
                                                 j = 13 to 1 by -1:
                array[j] = tt-{1}.{3}.
                array[j] = string(array[j],"x(35)") + " - " + tt-{1}.{7}.
                array-aux[j] = tt-{1}.{3}.
                array-cod[j] = string(tt-{1}.{2}).
            end.
            if j < 14
                then do:
                if j > 1
                  then do:
                    array[1] = array[j].
                  array-aux[j] = string(array[j],"x(35)") + " - " + tt-{1}.{7}.
                    
                    array-cod[1] = array-cod[j].
                    for each tt-{1} where ({6}) and tt-{1}.{3} > array-aux[1] by tt-{1}.numseq
                                 j = 2 to 13:
                        array[j] = tt-{1}.{3}.
                        array[j] = string(array[j],"x(35)") + " - " + tt-{1}.{7}.
                        array-aux[j] = tt-{1}.{3}.
                        array-cod[j] = string(tt-{1}.{2}).
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
                for each tt-{1} where ({6})
                                  and tt-{1}.{3} <= array-aux[1]
                                  and tt-{1}.numseq < integer(aux-seq)
                                    by tt-{1}.numseq descending j = 1 to 1.
                                    
                    aux = tt-{1}.{3}.
                    aux = string(aux,"x(35)") + " - " + tt-{1}.{7}.
                    aux-cod = string(tt-{1}.{2}).
                    aux-seq = string(tt-{1}.numseq).
                end.
                if j > 0
                    then do:
                    do i = 13 to 2 by -1:
                        array-aux[i] = array-aux[i - 1].
                        array[i] = array[i - 1].
                        array-cod[i] = array-cod[i - 1].
                    end.
                    i = 1.
                    array-aux[i] = string(aux,"x(35)").
                    array[i] = aux.
                    array-cod[i] = aux-cod.
                    display array.
                    end.
                    else bell.
                end.
            next.
            end.
        if lastkey = keycode("CURSOR-DOWN")
            then do:
            /*
            empty temp-table tt-jamostrou.
            */
            if i < 13
                then do:
                if array[i + 1] = ""
                    then do:
                    bell.
                    next.
                    end.
                i = i + 1.
                end.
                else do:
                for each tt-{1} where ({6}) and tt-{1}.{3} >= array-aux[13]
                                    /*   and string(tt-{1}.{2}) <> aux-cod */
                                         and tt-{1}.numseq > integer(aux-seq)
                                    by tt-{1}.numseq j = 1 to 1:
                                    
                     aux = tt-{1}.{3}.
                     aux = string(aux,"x(35)") + " - " + tt-{1}.{7}.
                     aux-cod = string(tt-{1}.{2}).
                     aux-seq = string(tt-{1}.numseq).
                end.
                if j > 0
                    then do:
                    
                    do i = 1 to 12:
                        array-aux[i] = array-aux[i + 1].
                        array[i] = array[i + 1].
                        array-cod[i] = array-cod[i + 1].
                    end.
                    i = 13.
                    array-aux[i] = string(aux,"x(35)").
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
        if input campo >= array-aux[1] and input campo <= array-aux[13]
            then do:
            do j = 1 to 13:
                if array-aux[j] begins input campo
                    then leave.
            end.
            if j <> 14
                then do:
                i = j.
                next.
                end.
            end.
            else do:
            find first tt-{1} where ({6})
                                and tt-{1}.{3} begins input campo no-error.
            if available tt-{1}
                then do:
                array = "".
                array[1] = tt-{1}.{3}.
                array[1] = string(array[1],"x(35)") + " - " + tt-{1}.{7}.
                array-aux[1] = trim(tt-{1}.{3}).
                array-cod[1] = string(tt-{1}.{2}).
                
                for each tt-{1} where ({6}) and tt-{1}.{3} >= array-aux[1]
                                  /* and string(tt-{1}.{2}) <> array-cod[1]*/       ~                                   no-lock
                    by tt-{1}.numseq i = 2 to 13:
                    array[i] = tt-{1}.{3}.
                    array[i] = string(array[i],"x(35)") + " - " + tt-{1}.{7}.
                    array-aux[i] = tt-{1}.{3}.
                    array-cod[i] = string(tt-{1}.{2}).
                end.
                i = 1.
                display array.
                next.
                end.
            end.
    /* message "Nenhuma ocorrencia com esta iniciais.". */
    apply keycode("BACKSPACE").
    end.
end.
hide frame f1 no-pause.
hide frame f2 no-pause.
if lastkey <> keycode("PF4") and
   lastkey <> keycode("F4")
then do:
     
    assign vretorno = array-cod[i].
    
    do vcont2 = 1 to 40:
    
        assign vretorno = replace(vretorno,"  "," ").
    
    end.
    
    frame-value = vretorno.
     
end.     
