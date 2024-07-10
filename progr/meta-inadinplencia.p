{admcab.i}

def input parameter p-mes as int.
def input parameter p-ano as int.

def var vi as int.
def var valor_meta as dec.
def var real_meta  as dec.
def var valor_metacp as dec.
def var real_metacp as dec.
def var total_meta as dec.

def var total_metacp as dec.

def temp-table tt-tabmeta
    field etbcod like estab.etbcod
    field valinadin as dec
    field realinadin as dec
    field valinadincp as dec
    field realinadincp as dec
    index i1 etbcod.

form tt-tabmeta.etbcod
     estab.etbnom no-label
     tt-tabmeta.valinadin column-label "Meta" format ">>>,>>9.99"
     tt-tabmeta.realinadin column-label "Realizado" 
                            format ">>>,>>9.99"
     tt-tabmeta.valinadincp column-label "Meta CP" 
                            format ">>>,>>9.99"
     tt-tabmeta.realinadincp column-label "Realizado CP" 
                                format ">>>,>>9.99"
     with frame f-mcp
     title " Meta Inadinplencia "
     width 80 centered 10 down row 6 overlay.

form total_meta at 30 label "Total" format ">>>,>>9.99" 
     total_real  as dec  no-label  format ">>>,>>9.99"
     total_metacp  no-label        format ">>>,>>9.99"
     total_realcp as dec no-label format ">>>,>>9.99"
    with frame f-totalm side-label 1 down no-box row 20
    width 80 overlay.
    
def buffer btabmeta for tabmeta.

{setbrw.i}                                                                      

assign a-seeid = -1 a-recid = -1 a-seerec = ?.

l1: repeat:
    run cal-total-meta.
    hide frame f-mcp no-pause.
    clear frame f-mcp all.
    {sklcls.i  
        &file = tt-tabmeta  
        &help = "          [a]=altera [i]=inclui [e]=exclui"
        &cfield = tt-tabmeta.etbcod
        &noncharacter = /*  
        &ofield = " estab.etbnom when avail estab
                    tt-tabmeta.valinadin
                    tt-tabmeta.realinadin
                    tt-tabmeta.valinadincp
                    tt-tabmeta.realinadincp
                    "
        &aftfnd1 = " find estab where
                          estab.etbcod = tt-tabmeta.etbcod
                          no-lock no-error.
                   "       
        &where  = " true "
        &naoexiste1 = " bell.
                        sresp = no.
                        message ""Nenhum registro encontrado. Deseja inclui?""
                        update sresp.
                        if not sresp then leave l1.
                        run inclui.
                        next l1.
                       "  
        &aftselect1 = " "
        &otherkeys1 = " 
                        if lastkey = keycode(""i"") or
                           lastkey = keycode(""I"") or
                           lastkey = keycode(""a"") or
                           lastkey = keycode(""A"") or
                           lastkey = keycode(""e"") or
                           lastkey = keycode(""E"")
                        then do:
                        if lastkey = keycode(""i"") or
                           lastkey = keycode(""I"") 
                        then do:
                            run inclui.
                            a-seeid = -1.
                            next l1.
                        end.
                        if lastkey = keycode(""a"") or
                           lastkey = keycode(""A"") 
                        then do:
                            find tt-tabmeta where 
                                recid(tt-tabmeta) = a-seerec[frame-line] .
                            lastkey = keycode(""b"").
                            run altera.
                            a-seeid = -1.
                            next keys-loop.
                        end.
                        if lastkey = keycode(""e"") or
                           lastkey = keycode(""E"")
                        then do:
                            find tt-tabmeta where 
                                recid(tt-tabmeta) = a-seerec[frame-line] .
                            run exclui.
                            a-seeid = -1.
                            next l1.
                        end.    
                        next keys-loop.
                        end.
                        /*
                        else do:
                            a-seeid = - 1.
                            next l1.
                        end.
                        */
                      "
        &locktype = " no-lock "
        &form   = " frame f-mcp "
    }   
    if keyfunction(lastkey) = "end-error"
    then DO:
        leave l1.       
    END.
end.
hide frame f-mpc no-pause.
hide frame f-totalm no-pause.

procedure inclui:
    
    scroll from-current down with frame f-mcp.
    do on error undo with frame f-mcp:
        clear frame f-mcp.
        prompt-for tt-tabmeta.etbcod.
        find estab where estab.etbcod = 
                    input frame f-mcp tt-tabmeta.etbcod
                    no-lock no-error.
        if not avail estab
        then do:
            bell.
            message color red/with
            "Nenhum registro encontrato para estabelecimento."
            view-as alert-box.
            undo.
        end.
        disp estab.etbnom.     
        prompt-for tt-tabmeta.valinadin
                   tt-tabmeta.realinadin
                   tt-tabmeta.valinadincp
                   tt-tabmeta.realinadincp.
        valor_meta   = input frame f-mcp tt-tabmeta.valinadin.
        real_meta    = input frame f-mcp tt-tabmeta.realinadin.
        valor_metacp = input frame f-mcp tt-tabmeta.valinadincp.
        real_metacp  = input frame f-mcp tt-tabmeta.realinadincp.
        run inclui-tabmeta.
    end.
end.
procedure altera:

    update tt-tabmeta.valinadin
           tt-tabmeta.realinadin 
           tt-tabmeta.valinadincp 
           tt-tabmeta.realinadincp
            with frame f-mcp.
    do on error undo:    
        find tabmeta where tabmeta.codtm  = 4 and
                   tabmeta.anoref = p-ano and
                   tabmeta.mesref = p-mes and
                   tabmeta.diaref = 0 and
                   tabmeta.etbcod = tt-tabmeta.etbcod and
                   tabmeta.funcod = 0 and
                   tabmeta.clacod = 0
                   exclusive no-error.
        if avail tabmeta
        then assign
                 tabmeta.ValMeta4[1] = tt-tabmeta.valinadin
                 tabmeta.ValMeta5[1] = tt-tabmeta.realinadin
                 tabmeta.ValMeta4[2] = tt-tabmeta.valinadincp
                 tabmeta.ValMeta5[2] = tt-tabmeta.realinadincp
                 tabmeta.val_meta = tt-tabmeta.valinadin +
                                    tt-tabmeta.valinadincp
                                    .
    end.
    run cal-total-meta.
end procedure.             
procedure exclui:
    def var vcont as int.
    sresp = no.
    message "Confirma excluir?" update sresp.
    if sresp
    then do on error undo:
        find tabmeta where tabmeta.codtm  = 4 and
                   tabmeta.anoref = p-ano and
                   tabmeta.mesref = p-mes and
                   tabmeta.diaref = 0 and
                   tabmeta.etbcod = tt-tabmeta.etbcod and
                   tabmeta.funcod = 0 and
                   tabmeta.clacod = 0
                   exclusive no-error.
        if avail tabmeta
        then delete tabmeta.
        delete tt-tabmeta.
    end.
    run cal-total-meta.
end procedure.   
procedure inclui-tabmeta:
    find tabmeta where tabmeta.codtm  = 4 and
                   tabmeta.anoref = p-ano and
                   tabmeta.mesref = p-mes and
                   tabmeta.diaref = 0 and
                   tabmeta.etbcod = estab.etbcod and
                   tabmeta.funcod = 0 and
                   tabmeta.clacod = 0
                   exclusive no-error.
    if not avail tabmeta
    then do:
        create tabmeta.
        assign
            tabmeta.codtm  = 4
            tabmeta.anoref = p-ano
            tabmeta.mesref = p-mes
            tabmeta.diaref = 0
            tabmeta.etbcod = estab.etbcod
            tabmeta.funcod = 0
            tabmeta.clacod = 0
            .
    end.
    assign
        tabmeta.ValMeta4[1] = valor_meta
        tabmeta.Valmeta5[1] = real_meta
        tabmeta.ValMeta4[2] = valor_metacp
        tabmeta.Valmeta5[2] = real_metacp
        tabmeta.val_meta = valor_meta + valor_metacp.
end procedure.  
procedure cal-total-meta:
    total_meta = 0.
    total_real = 0.
    total_metacp = 0.
    total_realcp = 0.
    for each tt-tabmeta: delete tt-tabmeta. end.
    for each tabmeta where tabmeta.codtm  = 4 and
                   tabmeta.anoref = p-ano and
                   tabmeta.mesref = p-mes and
                   tabmeta.diaref = 0 
                   no-lock:
        total_meta = total_meta + tabmeta.ValMeta4[1].
        total_real = total_real + tabmeta.ValMeta5[1].
        total_metacp = total_metacp + tabmeta.ValMeta4[2].
        total_realcp = total_realcp + tabmeta.ValMeta5[2].
        create tt-tabmeta.
        tt-tabmeta.etbcod = tabmeta.etbcod.
        tt-tabmeta.valinadin = tabmeta.ValMeta4[1].
        tt-tabmeta.realinadin = tabmeta.ValMeta5[1].
        tt-tabmeta.valinadincp = tabmeta.ValMeta4[2].
        tt-tabmeta.realinadincp = tabmeta.ValMeta5[2].
    end.
    disp total_meta
         total_real
         total_metacp
         total_realcp
         with frame f-totalm.         
end procedure.              
