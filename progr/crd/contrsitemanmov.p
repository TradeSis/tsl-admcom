/*
*
*
*/
{admcab.i}

def input parameter par-rec as recid.
def var vmaxdevol as int.
def var vqtddevol as int.

/**
def var vtotalproduto  as dec.
def var vpercitem      as dec.
def var vunititem      as dec.
**/

def buffer bcontrsitem for contrsitem.

def shared temp-table ttcancela no-undo
    field prec as recid
    field operacao as char    
    field qtddevol as int
    field valordevol as dec.

def shared temp-table ttdevolve no-undo
    field prec as recid
    field qtddevol as int.


find contrsitem where recid(contrsitem) = par-rec no-lock.
find contrsite  of contrsitem no-lock.
find contrato   of contrsite  no-lock.
def var recatu1         as recid.
def var reccont         as int.
def var esqpos1         as int.
def var esqcom1         as char format "x(12)" extent 3
    init [" devolve"," nota ", ""].

form
    esqcom1
    with frame f-com1 row screen-lines no-box no-labels column 40.
pause 0.
    esqpos1  = 1.
    form
        plani.numero format "999999999"
        plani.serie  column-label "Ser"
        contrsitmov.qtd      column-label "qtd"
        contrsitmov.qtddevol column-label "devol"
        /**
        contrsitem.valorunitario column-label "unit"
        **/
        with frame frame-a screen-lines - 17 down col 21 color white/red row 13 overlay width 60
            title " NF de " + string(contrsitem.codigoProduto) + " " + contrsitem.descricao.

bl-princ:
repeat:
    disp esqcom1 with frame f-com1.
    if recatu1 = ?
    then run leitura (input "pri").
    else find contrsitmov where recid(contrsitmov) = recatu1 no-lock.
    if not available contrsitmov
    then do.
        message "Sem registros" view-as alert-box.
        leave.
    end.
    clear frame frame-a all no-pause.
        run frame-a.

    recatu1 = recid(contrsitmov).
    color display message esqcom1[esqpos1] with frame f-com1.

    repeat.
        run leitura (input "seg").
        if not available contrsitmov
        then leave.
        if frame-line(frame-a) = frame-down(frame-a)
        then leave.
        down with frame frame-a.
        run frame-a.
    end.
    up frame-line(frame-a) - 1 with frame frame-a.

    repeat with frame frame-a:

            find contrsitmov where recid(contrsitmov) = recatu1 no-lock.

            status default "".
            run color-message.
            choose field plani.numero help ""
                go-on(cursor-down cursor-up                       cursor-left cursor-right

                      page-down   page-up
                      PF4 F4 ESC return) .
            run color-normal.
            if keyfunction(lastkey) = "cursor-right"
            then do:
                color display normal esqcom1[esqpos1] with frame f-com1.
                esqpos1 = if esqpos1 = 3 then 3 else esqpos1 + 1.
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
                    if not avail contrsitmov
                    then leave.
                    recatu1 = recid(contrsitmov).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "page-up"
            then do:
                do reccont = 1 to frame-down(frame-a):
                    run leitura (input "up").
                    if not avail contrsitmov
                    then leave.
                    recatu1 = recid(contrsitmov).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "cursor-down"
            then do:
                run leitura (input "down").
                if not avail contrsitmov
                then next.
                color display white/red plani.numero with frame frame-a.
                if frame-line(frame-a) = frame-down(frame-a)
                then scroll with frame frame-a.
                else down with frame frame-a.
            end.
            if keyfunction(lastkey) = "cursor-up"
            then do:
                run leitura (input "up").
                if not avail contrsitmov
                then next.
                color display white/red plani.numero with frame frame-a.
                if frame-line(frame-a) = 1
                then scroll down with frame frame-a.
                else up with frame frame-a.
            end.
 
        if keyfunction(lastkey) = "end-error"
        then leave bl-princ.

        if keyfunction(lastkey) = "return"
        then do:
            hide frame frame-a no-pause.
                display caps(esqcom1[esqpos1]) @ esqcom1[esqpos1]
                        with frame f-com1.

            if esqcom1[esqpos1] = " devolve "
            then do with frame frame-a:

                vmaxdevol = contrsitmov.qtd - contrsitmov.qtddevol.
                pause 0.
                update
                    vqtddevol column-label "devolver"
                        validate (input vqtddevol <= vmaxdevol and input vqtddevol >= 0,"qtd maxima atingida").
               
                find first ttdevolve where ttdevolve.prec = recid(contrsitmov) no-error.
                if not avail ttdevolve
                then do:
                    create ttdevolve.
                    ttdevolve.prec = recid(contrsitmov).
                end.
                ttdevolve.qtddevol = vqtddevol.
                if ttdevolve.qtddevol = 0
                then do:
                    delete  ttdevolve.
                end.
                find first ttcancela where ttcancela.prec = recid(contrsitem) no-error.
                if not avail ttcancela
                then do:
                    create ttcancela.
                    ttcancela.prec = recid(contrsitem).
                end.    
                ttcancela.operacao = trim(esqcom1[esqpos1]).
                ttcancela.qtddevol = vqtddevol.                        
                /**/
                
                /**
                vtotalproduto = 0.
                for each bcontrsitem of contrsite no-lock.
                    vtotalproduto = vtotalproduto + (bcontrsitem.valorunitario * bcontrsitem.qtd).
                end.
                vpercitem = (contrsitem.valorunitario * contrsitem.qtd) / vtotalproduto.
                vunititem = (contrato.vltotal * vpercitem) / contrsitem.qtd.   
                **/
                
                /*
                ttcancela.valordevol = ttcancela.qtddevol * vunititem.
                **/
                /**/
                ttcancela.valordevol = round(ttcancela.qtddevol * (contrsitem.valorPeso / contrsitem.qtd) ,2).
                /**/
                
                if ttcancela.qtddevol = 0
                then do:
                    delete ttcancela.    
                    leave.
                end.    
            end.

                if esqcom1[esqpos1] = " nota "
                then do.

                    find movim where movim.etbcod = contrsitmov.etbcod and
                                     movim.placod = contrsitmov.placod and
                                     movim.procod = contrsitmov.codigoProduto and
                                     movim.movseq = contrsitmov.movseq
                                     no-lock.
                    find plani where plani.etbcod = movim.etbcod and
                                     plani.placod = movim.placod
                                     no-lock.
                    run not_consnota.p (recid(plani)).
                end.
        end.
        run frame-a.
        display esqcom1[esqpos1] with frame f-com1.
        recatu1 = recid(contrsitmov).
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

    find movim where movim.etbcod = contrsitmov.etbcod and
                     movim.placod = contrsitmov.placod and
                     movim.procod = contrsitmov.codigoProduto and
                     movim.movseq = contrsitmov.movseq
                     no-lock.
    find plani where plani.etbcod = movim.etbcod and
                     plani.placod = movim.placod
                     no-lock.
    display
        plani.numero format "999999999"
        plani.serie  column-label "Ser"
        contrsitmov.qtd      column-label "qtd"
        contrsitmov.qtddevol column-label "devol"
            /*        contrsitem.valorunitario column-label "unit"*/
        with frame frame-a screen-lines - 17 down col 21 color white/red row 13 overlay width 60
            title " NF de " + string(contrsitem.codigoProduto) + " " + contrsitem.descricao.
end procedure.


procedure color-message.
    color display message
        plani.numero
        with frame frame-a.
end procedure.


procedure color-normal.
    color display normal
        plani.numero
        with frame frame-a.
end procedure.


procedure leitura . 
def input parameter par-tipo as char.
        
if par-tipo = "pri" 
then find first contrsitmov of contrsitem no-lock no-error.
                                             
if par-tipo = "seg" or par-tipo = "down" 
then find next contrsitmov  of contrsitem no-lock no-error.
             
if par-tipo = "up" 
then find prev contrsitmov of contrsitem  no-lock no-error.
        
end procedure.
