{admcab.i}

def shared var vtitulo as char.

/*def var par-clicod like clien.clicod init 10002804.*/

def shared temp-table tt-plani 
    field etbcod like estab.etbcod
    field placod like plani.placod
    field pladat like plani.pladat
    field movtdc like plani.movtdc
    field numero like plani.numero
    field valor  like plani.platot   
    index irecencia pladat descending
    index ivalor    valor  descending.

def shared var vtotqtd as int format ">>>>>>>>9".
def var vtotpro as int format ">>>>>>>>9".

def shared var vtotval as dec format ">>,>>9.99".

def temp-table tt-pro
    field procod like produ.procod
    field pronom like produ.pronom
    field valor  like movim.movpc
    field movdat like movim.movdat
    field qtd    as    int format ">>9"
    index imovdat movdat desc.

for each tt-plani:
    for each movim where movim.etbcod = tt-plani.etbcod
                     and movim.placod = tt-plani.placod
                     and movim.movtdc = tt-plani.movtdc
                     and movim.movdat = tt-plani.pladat no-lock:
        
        find produ where produ.procod = movim.procod no-lock no-error.
        
        find first tt-pro where tt-pro.procod = movim.procod 
                            and tt-pro.movdat = movim.movdat no-error.
        if not avail tt-pro
        then do:
            create tt-pro.
            assign tt-pro.procod = movim.procod
                   tt-pro.pronom = produ.pronom
                   tt-pro.valor  = movim.movpc
                   tt-pro.movdat = movim.movdat.
        end.
        
        tt-pro.qtd = tt-pro.qtd + movim.movqtm.
        vtotpro = vtotpro + movim.movqtm.
        
        
    end.                     
end.


find first tt-pro no-error.
if not avail tt-pro
then do:
    message "Nenhum registro encontrado.".
    pause 3 no-message.
    undo.
end.    


def var recatu1         as recid.
def var recatu2         as recid.
def var reccont         as int.
def var esqpos1         as int.
def var esqpos2         as int.
def var esqregua        as log.
def var esqvazio        as log.
def var esqascend     as log initial yes.

/*def var esqcom1         as char format "x(14)" extent 5
    initial [" "," "," ", " "," "].*/

/*def var esqcom2         as char format "x(14)" extent 5
            initial [" "," ","","",""].*/


def buffer btt-pro       for tt-pro.


/*form    
    esqcom1
    with frame f-com1
                 row 4 no-box no-labels side-labels column 1 centered.
form
    esqcom2
    with frame f-com2
                 row screen-lines no-box no-labels side-labels column 1
                 centered.
*/                 
assign
    esqregua = yes
    esqpos1  = 1
    esqpos2  = 1.

bl-princ:
repeat:

    /*
    disp esqcom1 with frame f-com1.
    disp esqcom2 with frame f-com2.
    */
    if recatu1 = ?
    then
        run leitura (input "pri").
    else
        find tt-pro where recid(tt-pro) = recatu1 no-error. 
        
    if not available tt-pro
    then esqvazio = yes.
    else esqvazio = no.
    
    clear frame frame-a all no-pause.
    
    if not esqvazio
    then do:
        run frame-a.
    end.

    recatu1 = recid(tt-pro).
    
    /*
    if esqregua
    then color display message esqcom1[esqpos1] with frame f-com1.
    else color display message esqcom2[esqpos2] with frame f-com2.
    */
    if not esqvazio
    then repeat:
        run leitura (input "seg").
    
        if not available tt-pro
        then leave.
        
        if frame-line(frame-a) = frame-down(frame-a)
        then leave.
        down
            with frame frame-a.
        
        run frame-a.
        
    end.

    if not esqvazio
    then up frame-line(frame-a) - 1 with frame frame-a.

    repeat with frame frame-a:

        if not esqvazio
        then do:
             find tt-pro where recid(tt-pro) = recatu1 no-error.


            run mostra-totais.
            run color-message.
            
            choose field tt-pro.procod
                         tt-pro.pronom
                         tt-pro.movdat
                         tt-pro.qtd
                         tt-pro.valor
                         help ""
                go-on(cursor-down cursor-up
                      /*cursor-left curor-right*/
                      page-down   page-up
                      tab PF4 F4 ESC return).

            run color-normal.
            
            status default "".

        end.
            if keyfunction(lastkey) = "TAB"
            then do:
                /*
                if esqregua
                then do:
                    color display normal esqcom1[esqpos1] with frame f-com1.
                    color display message esqcom2[esqpos2] with frame f-com2.
                end.
                else do:
                    color display normal esqcom2[esqpos2] with frame f-com2.
                    color display message esqcom1[esqpos1] with frame f-com1.
                end.
                */
                esqregua = not esqregua.
            end.
            if keyfunction(lastkey) = "cursor-right"
            then do:
                /*
                if esqregua
                then do:
                    color display normal esqcom1[esqpos1] with frame f-com1.
                    esqpos1 = if esqpos1 = 5 then 5 else esqpos1 + 1.
                    color display messages esqcom1[esqpos1] with frame f-com1.
                end.
                else do:
                    color display normal esqcom2[esqpos2] with frame f-com2.
                    esqpos2 = if esqpos2 = 5 then 5 else esqpos2 + 1.
                    color display messages esqcom2[esqpos2] with frame f-com2.
                end.
                next.
                */
            end.
            if keyfunction(lastkey) = "cursor-left"
            then do:
                /*
                if esqregua
                then do:
                    color display normal esqcom1[esqpos1] with frame f-com1.
                    esqpos1 = if esqpos1 = 1 then 1 else esqpos1 - 1.
                    color display messages esqcom1[esqpos1] with frame f-com1.
                end.
                else do:
                    color display normal esqcom2[esqpos2] with frame f-com2.
                    esqpos2 = if esqpos2 = 1 then 1 else esqpos2 - 1.
                    color display messages esqcom2[esqpos2] with frame f-com2.
                end.
                next.
                */
            end.
            if keyfunction(lastkey) = "page-down"
            then do:
                do reccont = 1 to frame-down(frame-a):
                    run leitura (input "down").
                    if not avail tt-pro
                    then leave.
                    recatu1 = recid(tt-pro).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "page-up"
            then do:
                do reccont = 1 to frame-down(frame-a):
                    run leitura (input "up").
                    if not avail tt-pro
                    then leave.
                    recatu1 = recid(tt-pro).
                end.
                leave.
            end.
    
            if keyfunction(lastkey) = "cursor-down"
            then do:
                run leitura (input "down").
                if not avail tt-pro
                then next.
                color display white/red 
                              tt-pro.procod
                              tt-pro.pronom
                              tt-pro.movdat
                              tt-pro.qtd
                              tt-pro.valor
                              with frame frame-a.
                if frame-line(frame-a) = frame-down(frame-a)
                then scroll with frame frame-a.
                else down with frame frame-a.
            end.
            
            if keyfunction(lastkey) = "cursor-up"
            then do:
                run leitura (input "up").
                if not avail tt-pro
                then next.
                color display white/red tt-pro.procod
                                        tt-pro.pronom
                                        tt-pro.movdat
                                        tt-pro.qtd
                                        tt-pro.valor
                                        with frame frame-a.
                if frame-line(frame-a) = 1
                then scroll down with frame frame-a.
                else up with frame frame-a.
            end.
 
        if keyfunction(lastkey) = "end-error"
        then leave bl-princ.

        if keyfunction(lastkey) = "return"
        then do:

            if esqregua
            then do:
            
                /*display caps(esqcom1[esqpos1]) @ esqcom1[esqpos1]
                        with frame f-com1.*/

            end.
            else do:
                /*display caps(esqcom2[esqpos2]) @ esqcom2[esqpos2]
                        with frame f-com2.
                if esqcom2[esqpos2] = "  "
                then do:
                    hide frame f-com1  no-pause.
                    hide frame f-com2  no-pause.
                    /* run programa de relacionamento.p (input ). */
                    view frame f-com1.
                    view frame f-com2.
                end.
                
                leave.*/
            end.
        end.
        if not esqvazio
        then do:
            run frame-a.
        end.
        /*
        if esqregua
        then display esqcom1[esqpos1] with frame f-com1.
        else display esqcom2[esqpos2] with frame f-com2.
        */
        recatu1 = recid(tt-pro).
    end.
    if keyfunction(lastkey) = "end-error"
    then do:
        view frame fc1.
        view frame fc2.
    end.
end.
hide frame f-com1  no-pause.
hide frame f-com2  no-pause.
hide frame frame-a no-pause.

procedure frame-a.
    display tt-pro.procod    column-label "Produto"
            tt-pro.pronom    column-label "Descricao" format "x(40)"
            tt-pro.movdat    column-label "Dt.Venda"
            tt-pro.qtd       column-label "Qtd"
            tt-pro.valor     column-label "Preco"
            with frame frame-a 11 down 
                color white/red row 3 title vtitulo.
end procedure.
procedure color-message.
    color display message 
            tt-pro.procod    column-label "Produto"
            tt-pro.pronom    column-label "Descricao"
            tt-pro.movdat    column-label "Dt.Venda"
            tt-pro.qtd       column-label "Qtd"
            tt-pro.valor     column-label "Preco"
            with frame frame-a.
end procedure.

procedure color-normal.
    color display normal
            tt-pro.procod    column-label "Produto"
            tt-pro.pronom    column-label "Descricao"
            tt-pro.movdat    column-label "Dt.Venda"
            tt-pro.qtd       column-label "Qtd"
            tt-pro.valor     column-label "Preco"
            with frame frame-a.
end procedure.

procedure leitura.

    def input parameter par-tipo as char.
        
    if par-tipo = "pri"
    then
        if esqascend
        then 
            find first tt-pro where true no-error.
        else 
            find last tt-pro where true no-error.
                                             
    if par-tipo = "seg" or par-tipo = "down" 
    then
        if esqascend  
        then
            find next tt-pro where true  no-error.
                    
        else
            find prev tt-pro where true  no-error.
             
             
    if par-tipo = "up" 
    then
        if esqascend   
        then
             find prev tt-pro where true  no-error.
        else
             find next tt-pro where true  no-error.
        
end procedure.

procedure mostra-totais.
    disp 
         "TOTAIS " skip
         "Qtd. Notas  |->" vtotqtd no-label skip
         "Qtd.Produtos|->" vtotpro no-label skip
         "Valor Total |->" vtotval no-label
         with frame f-tot col 45 no-box.
end procedure.

