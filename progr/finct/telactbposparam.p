/* 17/09/2021 helio*/

{admcab.i}

def shared var vdtini as date format "99/99/9999" label "De".
def shared var vdtfin as date format "99/99/9999" label "Ate".              

def var recatu1         as recid.
def var recatu2     as reci.
def var reccont         as int.
def var esqpos1         as int.
def var esqcom1         as char format "x(15)" extent 5
    initial [""].
{setbrw.i}

def temp-table tt-parametro-padrao
    field parametro as char.
def var pparametros as char.
                                                                                    
def buffer bctbprzmprod for ctbprzmprod.
form
    esqcom1
    with frame f-com1 row 4 no-box no-labels column 1 centered.

assign
    esqpos1  = 1.

    form  
        ctbprzmprod.pparametros no-label  skip
        space(5)
        ctbprzmprod.pstatus column-label "Status"
        ctbprzmprod.dtiniper column-label "Periodo!De"
        ctbprzmprod.dtfimper column-label " !Ate"
        ctbprzmprod.dtiniproc column-label "Proces!Inicio"
        ctbprzmprod.hriniproc format "99999" column-label "Hr"
        ctbprzmprod.hrfimproc format "99999" column-label "Tempo"
        ctbprzmprod.qtdPC column-label "Qtd!Reg" format ">>>>>>>>>>>9"
        with frame frame-a 5 down centered row 5.
        

bl-princ:
repeat:


    disp esqcom1 with frame f-com1.
    if recatu1 = ?
    then run leitura (input "pri").
    else find ctbprzmprod where recid(ctbprzmprod) = recatu1 no-lock.
    if not available ctbprzmprod
    then do.
        run pnova. 
        return.
    end.
    clear frame frame-a all no-pause.
    run frame-a.

    recatu1 = recid(ctbprzmprod).
    color display message esqcom1[esqpos1] with frame f-com1.
    repeat:
        run leitura (input "seg").
        if not available ctbprzmprod
        then leave.
        if frame-line(frame-a) = frame-down(frame-a)
        then leave.
        down with frame frame-a.
        run frame-a.
    end.
    up frame-line(frame-a) - 1 with frame frame-a.

    repeat with frame frame-a:

        find ctbprzmprod where recid(ctbprzmprod) = recatu1 no-lock.

        status default "".

            esqcom1[1] = if ctbprzmprod.pstatus <> "PRONTO" and 
                             (ctbprzmprod.dtiniproc < today or
                             (ctbprzmprod.dtiniproc = today and
                              time - ctbprzmprod.hrfimproc > 3000))
                         then "Reprocessar"
                         else "-".
            esqcom1[1] = if ctbprzmprod.pstatus = "PRONTO"
                         then " OK "
                         else esqcom1[1].

            esqcom1[2] = " Nova ".
            esqcom1[3] = "Excluir".
            
        def var vx as int.
        def var va as int.
        va = 1.
        do vx = 1 to 5.
            if esqcom1[vx] = ""
            then next.
            esqcom1[va] = esqcom1[vx].
            va = va + 1.  
        end.
        vx = va.
        do vx = va to 5.
            esqcom1[vx] = "".
        end.     
        
        
        disp esqcom1 with frame f-com1.
        
        run color-message.
        choose field ctbprzmprod.pstatus
                go-on(cursor-down cursor-up
                      cursor-left cursor-right
                      page-down   page-up
                      tab PF4 F4 ESC return).

            if lastkey = -1
            then do:
                pause 1 /*no-message*/ .
                find current ctbprzmprod no-lock.
                recatu1 = ?.
                leave.
            end.     
            run color-normal. 
            
            pause 0. 
                                                                
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
                    if not avail ctbprzmprod
                    then leave.
                    recatu1 = recid(ctbprzmprod).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "page-up"
            then do:
                do reccont = 1 to frame-down(frame-a):
                    run leitura (input "up").
                    if not avail ctbprzmprod
                    then leave.
                    recatu1 = recid(ctbprzmprod).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "cursor-down"
            then do:
                run leitura (input "down").
                if not avail ctbprzmprod
                then next.
                color display white/red ctbprzmprod.pstatus with frame frame-a.
                if frame-line(frame-a) = frame-down(frame-a)
                then scroll with frame frame-a.
                else down with frame frame-a.
            end.
            if keyfunction(lastkey) = "cursor-up"
            then do:
                run leitura (input "up").
                if not avail ctbprzmprod
                then next.
                color display white/red ctbprzmprod.pstatus with frame frame-a.
                if frame-line(frame-a) = 1
                then scroll down with frame frame-a.
                else up with frame frame-a.
            end.
 
        if keyfunction(lastkey) = "end-error"
        then leave bl-princ.
            

        if keyfunction(lastkey) = "return"
        then do:
            
                if esqcom1[esqpos1] = "Excluir" 
                then do: 
                    message "Confirma Exclusao?" update sresp.
                    if sresp
                    then do on error undo:
                        for each bctbprzmprod where 
                                bctbprzmprod.pparametros = ctbprzmprod.pparametros and
                                bctbprzmprod.dtiniper = ctbprzmprod.dtiniper and
                                bctbprzmprod.dtfimper = ctbprzmprod.dtfimper:
                            delete bctbprzmprod.
                        end.                    
                    
                    end.
                    recatu1 = ?.
                    leave.
                end.
                
                if esqcom1[esqpos1] = " Nova" 
                then do on error undo: 
                    run pnova.
                    procedure pnova.
                        find first ctbprzmprod where 
                                ctbprzmprod.pparametros = "CARTEIRA" and
                                ctbprzmprod.dtiniper = vdtini and
                                ctbprzmprod.dtfimper = vdtfin and
                                ctbprzmprod.campo = "TOTAL" and 
                                ctbprzmprod.valor = "" no-error. 
                        if not avail ctbprzmprod
                        then do:
                            create ctbprzmprod.
                            ctbprzmprod.pparametros = "CARTEIRA".
                            ctbprzmprod.dtiniper = vdtini.
                            ctbprzmprod.dtfimper = vdtfin.
                            ctbprzmprod.campo = "TOTAL".
                            ctbprzmprod.valorcampo = "".
                        end.    
                        ctbprzmprod.dtrefSAIDA = ?.
                        ctbprzmprod.vlrPago    = 0.
                        ctbprzmprod.qtdPC      = 0.
                        ctbprzmprod.PrzMedio   = 0.
                        ctbprzmprod.pstatus    = "PROCESSAR".
                        ctbprzmprod.dtiniproc  = ?.
                        ctbprzmprod.hriniproc  = ?.
                        ctbprzmprod.dtfimproc  = ?.
                        ctbprzmprod.hrfimproc  = ?.
                                        
                          recatu1 = recid(ctbprzmprod).
                 end procedure.                             
                            leave.
                end. 
        
        end.
        run frame-a.
        display esqcom1[esqpos1] with frame f-com1.
        recatu1 = recid(ctbprzmprod).
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
def var vhrini as char format "x(05)".
def var vtempo as char format "x(08)".
        
    vhrini = string(ctbprzmprod.hriniproc,"HH:MM").
    vtempo = string(ctbprzmprod.hrfimproc - ctbprzmprod.hriniproc,"HH:MM:SS").
/*    
    hide message no-pause.
    message /*lastkey string(time,"HH:MM:SS")*/ vtempo /*ctbprzmprod.hriniproc ctbprzmprod.hrfimproc*/.
  */
  
    if ctbprzmprod.pstatus <> "PRONTO" and
        (ctbprzmprod.dtiniproc < today or
         (ctbprzmprod.dtiniproc = today and time - ctbprzmprod.hrfimproc > 3000))
    then vtempo = "PARADO".
    
        disp 
        ctbprzmprod.pparametros    
        ctbprzmprod.pstatus
        ctbprzmprod.dtiniper
        ctbprzmprod.dtfimper
        ctbprzmprod.dtiniproc
        vhrini @ ctbprzmprod.hriniproc 
        vtempo  @ ctbprzmprod.hrfimproc 
        ctbprzmprod.qtdPC

        with frame frame-a.


end procedure.

procedure color-message.
    color display message
            ctbprzmprod.pparametros    
            ctbprzmprod.pstatus
        ctbprzmprod.dtiniper
        ctbprzmprod.dtfimper
        ctbprzmprod.dtiniproc
        ctbprzmprod.hriniproc 
        ctbprzmprod.hrfimproc 
        ctbprzmprod.qtdPC

        with frame frame-a.
end procedure.

procedure color-normal.
    color display normal
            ctbprzmprod.pparametros    

        ctbprzmprod.pstatus
        ctbprzmprod.dtiniper
        ctbprzmprod.dtfimper
        ctbprzmprod.dtiniproc
        ctbprzmprod.hriniproc 
        ctbprzmprod.hrfimproc 
        ctbprzmprod.qtdPC
        with frame frame-a.
end procedure.

procedure leitura . 
def input parameter par-tipo as char.
release ctbprzmprod.
        
if par-tipo = "pri" 
then do:
        find first ctbprzmprod use-index query1 where ctbprzmprod.campo = "TOTAL" and ctbprzmprod.pparametro = "CARTEIRA"
            no-lock no-error.
end.    
                                             
if par-tipo = "seg" or par-tipo = "down" 
then do:
            find next ctbprzmprod use-index query1
        where ctbprzmprod.campo = "TOTAL" and ctbprzmprod.pparametro = "CARTEIRA"
            no-lock no-error.
end.    
             
if par-tipo = "up" 
then do:
        find prev ctbprzmprod use-index query1
        where ctbprzmprod.campo = "TOTAL" and ctbprzmprod.pparametro = "CARTEIRA"
            no-lock no-error.
end.    
        
end procedure.


