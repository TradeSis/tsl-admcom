{admcab.i}
{setbrw.i}                                                                      

if setbcod <> 999 then return.

def var recatu1         as recid.
def var recatu2         as recid.
def var reccont         as int.
def var esqpos1         as int.
def var esqpos2         as int.
def var esqregua        as log.
def var esqvazio        as log.
def var esqascend     as log initial yes.
def var esqcom1         as char format "x(15)" extent 5
    initial ["","  ALTERA","  INCLUI","",""].
def var esqcom2         as char format "x(15)" extent 5
            initial ["","  SUB-MENU","","",""].
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


form with frame f-linha 12 down color with/cyan /*no-box*/
     centered.
                                                                         
                                                                                
disp "                             MANUTENÇÃO SSHMENU  " 
            with frame f1 1 down width 80                                       
            color message no-box no-label row 4.
                                                  
def buffer btbcntgen for tbcntgen.                            
def var i as int.

def temp-table tt-aplisshmenu like sshmenu
    index i1 menord.
def temp-table tt-menu like sshmenu.

for each sshmenu where sshmenu.ordsup = 0 no-lock by menord.
    create tt-aplisshmenu.
    buffer-copy sshmenu to tt-aplisshmenu.
end.    

l1: repeat:
    disp  esqcom1 with frame f-com1.
    disp  esqcom2 with frame f-com2.
    disp with frame f1.
    assign
        a-seeid = -1 a-recid = -1 a-seerec = ?
        esqpos1 = 1 esqpos2 = 1
        esqregua = yes. 
    hide frame f-linha no-pause.
    clear frame f-linha all.

    {sklclstb.i  
        &color = with/cyan
        &file = tt-aplisshmenu  
        &cfield = tt-aplisshmenu.aplicod
        &noncharacter = /* 
        &ofield = " tt-aplisshmenu.mentit format ""x(30)""
                    tt-aplisshmenu.menniv
                    tt-aplisshmenu.ordsup
                    tt-aplisshmenu.menord
                    "  
        &aftfnd1 = " "
        &where  = " true "
        &aftselect1 = " run aftselect.
                        a-seeid = -1.
                        if esqcom1[esqpos1] = ""  EXCLUI"" or
                           esqcom2[esqpos2] = ""  SUB-MENU""
                        then do:
                            next l1.
                        end.
                        else next keys-loop. "
        &go-on = TAB 
        &naoexiste1 = " esqcom1[esqpos1] = ""  Inclui"".
                        run aftselect.
                        next l1.
                      "  
        &otherkeys1 = " run controle. "
        &locktype = " no-lock "
        &form   = " frame f-linha "
    }   
    if keyfunction(lastkey) = "end-error"
    then DO:
        leave l1.       
    END.
end.
hide frame f-com1 no-pause.
hide frame f-com2 no-pause.
hide frame f1 no-pause.
hide frame f2 no-pause.
hide frame ff2 no-pause.
hide frame f-linha no-pause.

procedure aftselect:
    clear frame f-linha1 all.
    if esqcom1[esqpos1] = "  INCLUI"
    THEN DO on error undo:
        
        create tt-aplisshmenu.
        update tt-aplisshmenu.aplicod
               tt-aplisshmenu.mentit  format "x(30)"
               tt-aplisshmenu.menniv
               tt-aplisshmenu.ordsup
               tt-aplisshmenu.menord
               with frame f-inclui. 
        SRESP = NO.
        message "Confirma incluir menu?" update sresp.
        if sresp
        then do on error undo:
            create sshmenu.
            buffer-copy tt-aplisshmenu to sshmenu.
        end.
        else delete tt-aplisshmenu.
    END.
    if esqcom1[esqpos1] = "  ALTERA"
    THEN DO:
        find sshmenu where sshmenu.aplicod = tt-aplisshmenu.aplicod and
                           sshmenu.mentit  = tt-aplisshmenu.mentit  and
                           sshmenu.menniv  = tt-aplisshmenu.menniv  and
                           sshmenu.ordsup  = tt-aplisshmenu.ordsup  and
                           sshmenu.menord  = tt-aplisshmenu.menord
                           no-error.  
        update tt-aplisshmenu.aplicod
               tt-aplisshmenu.mentit   format "x(30)"
               tt-aplisshmenu.menniv
               tt-aplisshmenu.ordsup
               tt-aplisshmenu.menord
               with frame f-altera. 
        SRESP = NO.
        message "Confirma alterar menu?" update sresp.
        if sresp
        then do on error undo:
            buffer-copy tt-aplisshmenu to sshmenu.
        end.
        ELSE do:
            buffer-copy sshmenu to tt-aplisshmenu.
        end.
    END.
    if esqcom1[esqpos1] = "  EXCLUI"
    THEN DO:
        
    END.
    if esqcom2[esqpos2] = "  SUB-MENU"
    THEN DO on error undo:
        color display normal esqcom2[esqpos2] with frame f-com2.
        pause 0.
        hide frame f-com1 no-pause.
        clear frame f-com1 all.
        hide frame f-com1 no-pause.
        clear frame f-com1 all.
 
        RUN mansshmenu-n2.p(tt-aplisshmenu.aplicod,
                            tt-aplisshmenu.menniv,
                            tt-aplisshmenu.ordsup,
                            tt-aplisshmenu.menord,
                            tt-aplisshmenu.mentit).
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
    then varquivo = "/admcom/relat/" + string(setbcod) + "."
                    + string(time).
    else varquivo = "..~\relat~\" + string(setbcod) + "."
                    + string(time).
    
    {mdadmcab.i &Saida     = "value(varquivo)"   
                &Page-Size = "64"  
                &Cond-Var  = "80" 
                &Page-Line = "66" 
                &Nom-Rel   = ""programa"" 
                &Nom-Sis   = """SISTEMA""" 
                &Tit-Rel   = """TITULO""" 
                &Width     = "80"
                &Form      = "frame f-cabcab"}

    output close.

    if opsys = "UNIX"
    then do:
        run visurel.p(varquivo,"").
    end.
    else do:
        {mrod.i}
    end.
end procedure.

