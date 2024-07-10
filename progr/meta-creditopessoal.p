{admcab.i}

def input parameter p-mes as int.
def input parameter p-ano as int.

def var vi as int.
def var valor_meta as dec.
def var total_meta as dec.

form tabmeta.etbcod
     estab.etbnom
     tabmeta.val_meta format ">>>,>>9.99"
     with frame f-mcp
     title " Credito Pessoal "
     width 60 centered 10 down row 6 overlay.
     
form total_meta label "Total" format ">>>,>>>,>>9.99"
    with frame f-totalm side-label 1 down no-box row 20
    centered overlay.
    
def buffer btabmeta for tabmeta.

{setbrw.i}                                                                      

assign a-seeid = -1 a-recid = -1 a-seerec = ?.

l1: repeat:
    run cal-total-meta.
    hide frame f-mcp no-pause.
    clear frame f-mcp all.
    {sklcls.i  
        &file = tabmeta  
        &help = "          [a]=altera [i]=inclui [e]=exclui"
        &cfield = tabmeta.etbcod
        &noncharacter = /*  
        &ofield = " estab.etbnom when avail estab
                    tabmeta.val_meta
                    "
        &aftfnd1 = " find estab where
                          estab.etbcod = tabmeta.etbcod
                          no-lock no-error.
                   "       
        &where  = " tabmeta.codTM = 3 and
                    tabmeta.anoref = p-ano and
                    tabmeta.mesref = p-mes "
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
                        find tabmeta where 
                                recid(tabmeta) = a-seerec[frame-line] .
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
                            lastkey = keycode(""b"").
                            run altera.
                            a-seeid = -1.
                            next keys-loop.
                        end.
                        if lastkey = keycode(""e"") or
                           lastkey = keycode(""E"")
                        then do:
                            run exclui.
                            a-seeid = -1.
                            next l1.
                        end.    
                        /*next keys-loop.*/
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
        prompt-for tabmeta.etbcod.
        find estab where estab.etbcod = 
                    input frame f-mcp tabmeta.etbcod
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
        prompt-for tabmeta.val_meta.
        valor_meta = input frame f-mcp tabmeta.val_meta.
        run inclui-tabmeta.
    end.
end.
procedure altera:
    update tabmeta.val_meta with frame f-mcp.
    run cal-total-meta.
end procedure.             
procedure exclui:
    def var vcont as int.
    sresp = no.
    message "Confirma excluir?" update sresp.
    if sresp
    then do on error undo:
        delete tabmeta.
    end.
    run cal-total-meta.
end procedure.   
procedure inclui-tabmeta:
    find tabmeta where tabmeta.codtm  = 3 and
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
            tabmeta.codtm  = 3
            tabmeta.anoref = p-ano
            tabmeta.mesref = p-mes
            tabmeta.diaref = 0
            tabmeta.etbcod = estab.etbcod
            tabmeta.funcod = 0
            tabmeta.clacod = 0
            .
    end.
    tabmeta.val_meta = valor_meta.
end procedure.  
procedure cal-total-meta:
    total_meta = 0.
    for each tabmeta where tabmeta.codtm  = 3 and
                   tabmeta.anoref = p-ano and
                   tabmeta.mesref = p-mes and
                   tabmeta.diaref = 0 
                   no-lock:
        total_meta = total_meta + tabmeta.val_meta.
    end.
    disp total_meta with frame f-totalm.         
end procedure.              
