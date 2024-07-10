{admcab.i}

def input parameter p-etbcod like estab.etbcod.
def input parameter p-mes as int.
def input parameter p-ano as int.

def var vi as int.
def temp-table tt-g
    field indx as int
    field g1 as int
    field g2 as int
    index i1 indx
    .
def var vin as int.
p-ano = 0.
p-mes = 0.
find tabmeta where tabmeta.codtm  = 1 and
                   tabmeta.anoref = p-ano and
                   tabmeta.mesref = p-mes and
                   tabmeta.diaref = 0 and
                   tabmeta.etbcod = p-etbcod and
                   tabmeta.funcod = 0 and
                   tabmeta.clacod = 0
                   no-lock no-error.
if avail tabmeta
then do:
    do vi = 1 to 20:
        if vi < 11
        then do:
            if valger1[vi] = 0 and valger2[vi] = 0
            then leave.   
            create tt-g.
            assign
                vin = vi
                tt-g.indx = vi
                tt-g.g1 = valger1[vi]
                tt-g.g2 = valger2[vi]
                .
        end.
        else do:
            if valger3[vi - 10] = 0 and valger4[vi - 10] = 0
            then leave.
            create tt-g.
            assign
                vin = vi
                tt-g.indx = vi
                tt-g.g1 = valger3[vi - 10]
                tt-g.g2 = valger4[vi - 10]
                .

        end.            
    end.
end.

def buffer btt-g for tt-g. 
def buffer bclase for clase.

form tt-g.indx no-label        format ">9"
     tt-g.g1 column-label "G1" format ">>>>>>>>>"
     clase.clanom no-label     format "x(15)"
     tt-g.g2 column-label "G2" format ">>>>>>>>>"
     bclase.clanom no-label    format "x(15)"
     with frame f-mercadologico
     down centered row 6 overlay 
     title " Mercadologico Filial " + string(p-etbcod) + " " 
     width 60.
     
{setbrw.i}                                                                      

assign a-seeid = -1 a-recid = -1 a-seerec = ?.

l1: repeat:
    hide frame f-mercadologico no-pause.
    clear frame f-mercadologico all.
    {sklcls.i  
        &file = tt-g  
        &help = "          [a]=altera [i]=inclui [e]=exclui"
        &cfield = tt-g.g1
        &noncharacter = /*  
        &ofield = " tt-g.indx
                    clase.clanom when avail clase
                    tt-g.g2 
                    bclase.clanom when avail bclase "  
        &aftfnd1 = " find clase where
                            clase.clacod  = tt-g.g1 no-lock no-error.
                     find bclase where
                            bclase.clacod = tt-g.g2 no-lock no-error.
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
                            find tt-g where recid(tt-g) = a-seerec[frame-line]
                            no-error.
                            if avail tt-g
                            then do:
                            lastkey = keycode(""b"").
                            run altera.
                            end.
                            a-seeid = -1.
                            next l1.
                        end.
                        if lastkey = keycode(""e"") or
                           lastkey = keycode(""E"")
                        then do:
                            find tt-g where recid(tt-g) = a-seerec[frame-line]
                            no-error.
                            if avail tt-g
                            then do:
                            run exclui.
                            end.
                            a-seeid = -1.
                            next l1.
                        end.    
                        next keys-loop.
                        end.
                        /*else do:
                            a-seeid = - 1.
                            next l1.
                        end.*/
                      "
        &locktype = " no-lock "
        &form   = " frame f-mercadologico "
    }   
    if keyfunction(lastkey) = "end-error"
    then DO:
        leave l1.       
    END.
end.

procedure inclui:
    scroll from-current down with frame f-mercadologico.
    do on error undo with frame f-mercadologico:
        clear frame f-mercadologico.
        prompt-for tt-g.g1 with frame f-mercadologico.
        find clase where clase.clacod = 
                input frame f-mercadologico tt-g.g1 no-lock no-error.
        if not avail clase and input frame f-mercadologico tt-g.g1 > 0
        then do:
            bell.
            message color red/with
            "Nenhum registro encontrato para mercadologico."
            view-as alert-box.
            undo.
        end.
        find first btt-g where
                   btt-g.g1 = input frame f-mercadologico tt-g.g1
                   no-error.
        if avail btt-g and btt-g.g1 <> 0
        then do:
            bell.
            message color red/with
                "Mercadologico ja cadastrado para G1."
                view-as alert-box.
            undo.    
        end.     
        find first btt-g where
                   btt-g.g2 = input frame f-mercadologico tt-g.g1
                   no-error.
        if avail btt-g and btt-g.g2 <> 0
        then do:
            bell.
            message color red/with
                "Mercadologico ja cadastrado para G2."
                view-as alert-box.
            undo.    
        end.      
        create tt-g.
        assign
            vin = vin + 1
            tt-g.indx = vin
            tt-g.g1 = input frame f-mercadologico tt-g.g1
            .
        disp tt-g.indx tt-g.g1 
                        with frame f-mercadologico.
    do on error undo:    
        prompt-for tt-g.g2 with frame f-mercadologico.    
        find bclase where bclase.clacod = 
                    input frame f-mercadologico tt-g.g2 no-lock no-error.
        if not avail bclase and input frame f-mercadologico tt-g.g2 > 0
        then do:
            bell.
            message color red/with
            "Nenhum registro encontrato para mercadologico."
            view-as alert-box.
            undo.
        end. 
        find first btt-g where
                   btt-g.g1 = input frame f-mercadologico tt-g.g2
                   no-error.
        if avail btt-g and btt-g.g1 <> 0
        then do:
            bell.
            message color red/with
                "Mercadologico ja cadastrado para G1."
                view-as alert-box.
            undo.    
        end.     
        find first btt-g where
                   btt-g.g2 = input frame f-mercadologico tt-g.g2
                   no-error.
        if avail btt-g and btt-g.g2 <> 0
        then do:
            bell.
            message color red/with
                "Mercadologico ja cadastrado para G2."
                view-as alert-box.
            undo.    
        end.       
        /*create tt-g.
        assign
            vin = vin + 1
            tt-g.indx = vin
            tt-g.g1 = input frame f-mercadologico tt-g.g1
            */
            tt-g.g2 = input frame f-mercadologico tt-g.g2
            .
    end.
    end.
        disp tt-g.indx tt-g.g1 tt-g.g2
                with frame f-mercadologico.
        pause 0.        
        run inclui-tabmeta. 
        
end.
procedure altera:
    do on error undo, return:
        prompt-for tt-g.g1 go-on(F4) with frame f-mercadologico
        .
        find first btt-g where
                   btt-g.indx <> tt-g.indx and
                   btt-g.g1 = input frame f-mercadologico tt-g.g1 no-error.
        if avail btt-g and btt-g.g1 <> 0
        then do:
            bell.
            message color red/with
                "Mercadologico ja cadastrado para G1."
                view-as alert-box.
            undo.    
        end.     
        find first btt-g where 
                   /*btt-g.indx <> tt-g.indx and*/
                   btt-g.g2 = input frame f-mercadologico tt-g.g1 no-error.
        if avail btt-g and btt-g.g2 <> 0
        then do:
            bell.
            message color red/with
                "Mercadologico ja cadastrado para G2."
                view-as alert-box.
            undo.    
        end. 
        find clase where clase.clacod = tt-g.g1 no-lock no-error.
        if not avail clase and tt-g.g1 > 0
        then do:
            bell.
            message color red/with
            "Nenhum registro encontrato para mercadologico."
            view-as alert-box.
            undo.
        end. 
        if avail clase then
        disp clase.clanom with frame f-mercadologico.
        pause 0.
        tt-g.g1 = input frame f-mercadologico tt-g.g1.
        prompt-for tt-g.g2 with frame f-mercadologico.
        find first btt-g where 
                   /*btt-g.indx <> tt-g.indx and*/
                   btt-g.g1 = input frame f-mercadologico tt-g.g2  no-error.
        if avail btt-g and btt-g.g1 <> 0
        then do:
            bell.
            message color red/with
                "Mercadologico ja cadastrado para G1."
                view-as alert-box.
            undo.    
        end.     
        find first btt-g where 
                   btt-g.indx <> tt-g.indx and
                   btt-g.g2 = input frame f-mercadologico tt-g.g2 no-error.
        if avail btt-g and btt-g.g2 <> 0
        then do:
            bell.
            message color red/with
                "Mercadologico ja cadastrado para G2."
                view-as alert-box.
            undo.    
        end. 
        find bclase where bclase.clacod = tt-g.g2 no-lock no-error.
        if not avail bclase and tt-g.g2 > 0
        then do:
            bell.
            message color red/with
            "Nenhum registro encontrato para mercadologico."
            view-as alert-box.
            undo.
        end. 
        if avail bclase then
        disp bclase.clanom with frame f-mercadologico.
        pause 0.
        tt-g.g2 = input frame f-mercadologico tt-g.g2.
        a-seeid = -1.
        run inclui-tabmeta.
    end.
end procedure.             
procedure exclui:
    def var vcont as int.
    sresp = no.
    message "Confirma excluir?" update sresp.
    if sresp
    then do:
        if avail tt-g
        then do on error undo:
            vcont = tt-g.indx.
            delete tt-g.
        end.
        for each tt-g where tt-g.indx > vcont:
            tt-g.indx = tt-g.indx - 1.
        end.
        run inclui-tabmeta.
    end.
end procedure.   
procedure inclui-tabmeta:
    find tabmeta where tabmeta.codtm  = 1 and
                   tabmeta.anoref = p-ano and
                   tabmeta.mesref = p-mes and
                   tabmeta.diaref = 0 and
                   tabmeta.etbcod = p-etbcod and
                   tabmeta.funcod = 0 and
                   tabmeta.clacod = 0
                   exclusive no-error.
    if not avail tabmeta
    then do:
        create tabmeta.
        assign
            tabmeta.codtm  = 1
            tabmeta.anoref = p-ano
            tabmeta.mesref = p-mes
            tabmeta.diaref = 0
            tabmeta.etbcod = p-etbcod
            tabmeta.funcod = 0
            tabmeta.clacod = 0
            .
    end.
    do vi = 1 to 20:
        find first btt-g where
                   btt-g.indx = vi no-error.
        if avail btt-g
        then do:
            if vi < 11
            then assign
                tabmeta.valger1[vi] = btt-g.g1
                tabmeta.valger2[vi] = btt-g.g2.
            else assign
                tabmeta.valger3[vi - 10] = btt-g.g1
                tabmeta.valger4[vi - 10] = btt-g.g2.
            if btt-g.g1 = 0 and btt-g.g2 = 0
            then delete  btt-g.
        end.
        else do:
            if vi < 11
            then assign
                tabmeta.valger1[vi] = 0
                tabmeta.valger2[vi] = 0.
            else assign
                tabmeta.valger3[vi - 10] = 0
                tabmeta.valger4[vi - 10] = 0.
        end.            
    end.
    find current tabmeta no-lock.            
end procedure.                
                
