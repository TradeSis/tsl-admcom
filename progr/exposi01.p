{admcab.i}

{setbrw.i}                                                                      

def var recatu1         as recid.
def var recatu2         as recid.
def var reccont         as int.
def var esqpos1         as int.
def var esqpos2         as int.
def var esqregua        as log.
def var esqvazio        as log.
def var esqascend     as log initial yes.
def var esqcom1         as char format "x(15)" extent 5
    initial ["","  Inclui","  Altera","  Exclui","Relatorio"].
def var esqcom2         as char format "x(15)" extent 5
            initial ["","Capacidade","  Filtro","",""].
def var esqhel1         as char format "x(80)" extent 5
    initial ["teste teste",
             "",
             "",
             "",
             ""].
def var esqhel2         as char format "x(12)" extent 5
   initial ["teste teste  ",
            " ",
            " ",
            " ",
            " "].

form
    esqcom1
    with frame f-com1
                 row 3 no-box no-labels side-labels column 1 centered.
form
    esqcom2
    with frame f-com2
                 row screen-lines no-box no-labels side-labels column 1
                 centered.
assign
    esqregua = yes
    esqpos1  = 1
    esqpos2  = 1.


form expositor.codexpositor
     expositor.descricao
     with frame f-linha 10 down color with/cyan /*no-box*/
     centered.
                                                                         
                                                                                
disp "                       CADASTRO DE EXPOSITORES       " 
            with frame f1 1 down width 80                                       
            color message no-box no-label row 4.
                                                  
disp " " with frame f2 1 down width 80 color message no-box no-label            
    row 20.                                                                     
def buffer btbcntgen for tbcntgen.                            
def var i as int.

def temp-table tt-expositor like expositor.
l1: repeat :
    clear frame f-com1 all.
    clear frame f-com2 all.
    assign
        a-seeid = -1 a-recid = -1 a-seerec = ?
        esqpos1 = 1 esqpos2 = 1. 
    disp esqcom1 with frame f-com1.
    disp esqcom2 with frame f-com2.
    hide frame f-linha no-pause.
    clear frame f-linha all.
    view frame f1.
    view frame f2.
    {sklclstb.i  
        &color = with/cyan
        &file = expositor     
        &cfield = expositor.codexpositor
        &noncharacter = /* 
        &ofield = " expositor.descricao "  
        &aftfnd1 = " "
        &where  = " true "
        &aftselect1 = " run aftselect.
                        a-seeid = -1.
                        if esqcom1[esqpos1] = ""  EXCLUI"" or
                           esqcom2[esqpos2] = ""capacidade""
                        then do:
                            next l1.
                        end.
                        else next keys-loop. "
        &go-on = TAB 
        &naoexiste1 = " run inclui. 
                        hide frame f-inclui no-pause.
                        if keyfunction(lastkey) = ""end-error""
                        then leave l1.
                        else next l1. "
         
        &otherkeys1 = " run controle. "
        &locktype = " "
        &form   = " frame f-linha "
    }   
    if keyfunction(lastkey) = "end-error"
    then DO:
        leave l1.       
    END.
end.
hide frame f1 no-pause.
hide frame f2 no-pause.
hide frame ff2 no-pause.
hide frame f-linha no-pause.

procedure aftselect:
    clear frame f-linha1 all.
    if esqcom1[esqpos1] = "  INCLUI"
    THEN DO on error undo:
        run inclui.
    END.
    if esqcom1[esqpos1] = "  ALTERA"
    THEN DO:
        run altera.    
    END.
    if esqcom1[esqpos1] = "  EXCLUI"
    THEN DO:
        run exclui.    
    END.
    if esqcom1[esqpos1] = "Relatorio"
    THEN DO:
        run relatorio.    
    END.
    if esqcom2[esqpos2] = "Capacidade"
    THEN DO:
        run exposi02.p(input expositor.codexpositor).
    END.
    if esqcom2[esqpos2] = "  Filtro"
    THEN DO:
        run exposi04.p.
    END.


end procedure.

procedure controle:
        def var ve as int.
            if keyfunction(lastkey) = "TAB"
            then do:
                if esqregua
                then do:
                    esqpos1 = 1.
                    do ve = 1 to 5:
                    color display normal esqcom1[ve] with frame f-com1.
                    end.
                    color display message esqcom2[esqpos2] with frame f-com2.
                end.
                else do:
                    do ve = 1 to 5:
                    color display normal esqcom2[ve] with frame f-com2.
                    end.
                    esqpos2 = 1.
                    color display message esqcom1[esqpos1] with frame f-com1.
                end.
                esqregua = not esqregua.
            end.
            if keyfunction(lastkey) = "cursor-right"
            then do:
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
            end.
            if keyfunction(lastkey) = "cursor-left"
            then do:
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
            end.
end procedure.

procedure relatorio:

    def var varquivo as char.
    
    if opsys = "UNIX"
    then varquivo = "/admcom/relat/expositor" + string(setbcod) + "."
                    + string(time).
    else varquivo = "..~\relat~\ expositor" + string(setbcod) + "."
                    + string(time).
    
    {mdadmcab.i &Saida     = "value(varquivo)"   
                &Page-Size = "64"  
                &Cond-Var  = "80" 
                &Page-Line = "66" 
                &Nom-Rel   = ""exposi01"" 
                &Nom-Sis   = """SISTEMA COMERCIAL""" 
                &Tit-Rel   = """CADASTRO DE EXPOSITORES""" 
                &Width     = "80"
                &Form      = "frame f-cabcab"}

    for each expositor no-lock:
        disp expositor.codexpositor
             expositor.descricao
             with frame f-disp down.
        down with frame f-disp.     
    end.
    output close.

    if opsys = "UNIX"
    then do:
        run visurel.p(varquivo,"").
    end.
    else do:
        {mrod.i}
    end.
end procedure.

procedure inclui:
    def buffer bexpositor for expositor.
    do on error undo with frame f-inclui 1 down centered row 8
            1 column.
        find last bexpositor no-error.
        for each tt-expositor.
        delete tt-expositor.
        end.
        create tt-expositor.
        if avail bexpositor
        then tt-expositor.codexpositor = bexpositor.codexpositor + 1.
        else tt-expositor.codexpositor = 1.
        disp tt-expositor.codexpositor.
        update tt-expositor.descricao.

        create expositor.
        buffer-copy tt-expositor to expositor.
    end.
    hide frame f-inclui no-pause.
end.            
procedure altera:
    do on error undo with frame f-altera 1 down centered row 8
            1 column.
        for each tt-expositor.
        delete tt-expositor.
        end.
        create tt-expositor.
        buffer-copy expositor to tt-expositor.
        disp tt-expositor.codexpositor.
        update tt-expositor.descricao.

        buffer-copy tt-expositor to expositor.
    end.

end procedure.
procedure exclui:
    do on error undo with frame f-exclui 1 down centered row 8
            1 column.
        find first expcapacidade where
                   expcapacidade.codexpositor = expositor.codexpositor
                   no-lock no-error.
        if avail expcapacidade
        then do:
            message color red/with
            "Expositor com capacidade cadatrada." skip
            "Impossivel excluir."
            view-as alert-box.
        end.           
        else do:
            sresp = no.
            message "Confirma excluir?" update sresp.
            if sresp then delete expositor.
        end.    
    end.

end procedure.
