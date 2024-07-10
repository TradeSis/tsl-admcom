{admcab.i}
def temp-table tt-menu like menu
    index i1 aplicod.
def var v-mencod as int.
def buffer bmenu for menu.
def buffer cmenu for menu.
def var vapli as int.
for each tt-menu:
    delete tt-menu.
end.
def var vniv2 as log init yes.
def var vniv1 as log init yes.
for each aplicativo no-lock:
    find first tt-menu where tt-menu.aplicod = aplicativo.aplicod and
                             tt-menu.menniv  = 0 and
                             tt-menu.ordsup  = 0 and
                             tt-menu.menord  = 1
                             no-lock no-error.
    if not avail tt-menu
    then do:
        create tt-menu.
        assign
            tt-menu.aplicod = aplicativo.aplicod
            tt-menu.mentit  = aplicativo.aplinom
            tt-menu.menniv  = 0
            tt-menu.ordsup  = 0
            tt-menu.menord  = 1.
    end.                      
    vniv1 = no.   
    for each menu where menu.aplicod = aplicativo.aplicod and
                        menu.menniv  = 1 and
                        menu.ordsup = 0
                        no-lock:
        find first tt-menu where tt-menu.aplicod = aplicativo.aplicod and
                             tt-menu.menniv  = 1 and
                             tt-menu.ordsup  = 0 and
                             tt-menu.menord  = menu.menord
                             no-lock no-error.
        if not avail tt-menu
        then do:
            create tt-menu.
            buffer-copy menu to tt-menu.
            tt-menu.mentit = "   " + tt-menu.mentit.
        end. 
        vniv2 = no.
        for each bmenu where bmenu.aplicod = aplicativo.aplicod and
                             bmenu.menniv = 2 and
                             bmenu.ordsup = menu.menord
                             no-lock:
            v-mencod = int(string(bmenu.menniv,"9") +
                           string(bmenu.ordsup,"999") +
                           string(bmenu.menord,"999")).

            find first acesmenu where
                       acesmenu.mencod = v-mencod
                       no-lock no-error.
            if not avail acesmenu
            then do:
                vniv2 = yes.
                find first tt-menu where 
                           tt-menu.aplicod = aplicativo.aplicod and
                           tt-menu.menniv  = 2 and
                           tt-menu.ordsup  = bmenu.ordsup and
                           tt-menu.menord  = bmenu.menord
                             no-lock no-error.
                if not avail tt-menu
                then do:
                    create tt-menu.
                    buffer-copy bmenu to tt-menu.
                    tt-menu.mentit = "      " + tt-menu.mentit.
                end.    
            end.
        end.
        if vniv2 = no
        then delete tt-menu.
        else vniv1 = yes.
    end.
    if vniv1 = no
    then do:
        find first tt-menu where tt-menu.aplicod = aplicativo.aplicod and
                             tt-menu.menniv  = 0 and
                             tt-menu.ordsup  = 0 and
                             tt-menu.menord  = 1
                             no-error.
        if avail tt-menu
        then delete tt-menu.
    end.
end.                                                        
                                
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
    initial ["","  RELATORIO","","",""].
def var esqcom2         as char format "x(15)" extent 5
            initial ["","","","",""].
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


form " " 
     " "
     with frame f-linha 13 down color with/cyan /*no-box*/
     centered no-label.
                                                                         
                                                                                
disp "                  MONITORAMENTO DE MENU - NIVEIS NAO USADOS       " 
            with frame f1 1 down width 80                                       
            color message no-box no-label row 4.
                                                  
disp " " with frame f2 1 down width 80 color message no-box no-label            
    row 20.                                                                     
def buffer btbcntgen for tbcntgen.                            
def var i as int.

l1: repeat:
    disp esqcom1 with frame f-com1.
    disp esqcom2 with frame f-com2.
    assign
        a-seeid = -1 a-recid = -1 a-seerec = ?
        esqpos1 = 1 esqpos2 = 1. 
    hide frame f-linha no-pause.
    clear frame f-linha all.
    {sklclstb.i  
        &color = with/cyan
        &file = tt-menu  
        &cfield = tt-menu.mentit
        &noncharacter = /* 
        &ofield = " tt-menu.mentit format ""x(50)"" "  
        &aftfnd1 = " "
        &where  = " true "
        &aftselect1 = " run aftselect.
                        a-seeid = -1.
                        if esqcom1[esqpos1] = ""  EXCLUI"" or
                           esqcom2[esqpos2] = ""  CLASSE""
                        then do:
                            next l1.
                        end.
                        else next keys-loop. "
        &go-on = TAB 
        &naoexiste1 = "  " 
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
    if esqcom1[esqpos1] = "  RELATORIO"
    THEN DO on error undo:
        run relatorio.
    END.
    if esqcom1[esqpos1] = "  ALTERA"
    THEN DO:
    
    END.
    if esqcom1[esqpos1] = "  EXCLUI"
    THEN DO:
        
    END.
    if esqcom2[esqpos2] = "    "
    THEN DO on error undo:
    
    END.

end procedure.

procedure relatorio:
    def var varquivo as char.
    if opsys = "UNIX"
    then varquivo = "/admcom/relat/monmen"  + string(time).
    else varquivo = "l:\relat\monmen" + string(time).
                                    
    {mdadmcab.i &Saida     = "value(varquivo)"   
                &Page-Size = "64"  
                &Cond-Var  = "80" 
                &Page-Line = "66" 
                &Nom-Rel   = ""monmen01"" 
                &Nom-Sis   = """SISTEMA ADMINISTRATIVO""" 
                &Tit-Rel   = """  MONITORAMENTO DO MENU - NIVEIS NAO USADOS """ 
                &Width     = "80"
                &Form      = "frame f-cabcab"}

    for each tt-menu no-lock use-index i1.
        disp tt-menu.mentit
            with frame f-disp down width 80
            .
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

 