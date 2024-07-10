{admcab.i}

def temp-table tt-menu 
    field mentit like menu.mentit
    field menpro like menu.menpro
    field menpar like menu.menpar
    field menniv like menu.menniv
    field ordsup like menu.ordsup
    field menord like menu.menord
    field aplicod like menu.aplicod
    .

def var v-mencod as int.
def buffer bmenu for menu.
def buffer cmenu for menu.
def var vapli as int.

for each acesmenu where 
         acesmenu.etbcod = setbcod and
         acesmenu.funcod = sfuncod 
         no-lock break by int1 descending
                 :
    find first menu where
               menu.aplicod = acesmenu.char1 
           and menu.menniv = int(substr(string(acesmenu.mencod,"9999999"),1,1))
           and menu.ordsup = int(substr(string(acesmenu.mencod,"9999999"),2,3))
           and menu.menord = int(substr(string(acesmenu.mencod,"9999999"),5,3))
           no-lock no-error.
    if avail menu
    then do:
    
        run p-cria-tt-menu.
        
        vapli = vapli + 1.
    end.       
    if vapli = 12
    then leave.
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
    initial ["","","","",""].
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


form "  "
     with frame f-linha 13 down color with/cyan /*no-box*/
     centered WIDTH 58 .
                                  
find func where func.etbcod = setbcod and
                func.funcod = sfuncod no-lock.
                                                                               
disp "            M E N U   -   12 mais acessado por "
        func.funnom format "x(20)" 
            with frame f1 1 down width 80                                                 color message no-box no-label row 4.
                                                  
disp "  F4 RETORNA AO MENU PRINCIPAL " 
    with frame f2 1 down width 80 color message no-box no-label            
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
                        a-recid = a-seeid.
                        next keys-loop. "
        &go-on = TAB 
        &naoexiste1 = " leave l1. " 
        &otherkeys1 = " run controle. "
        &locktype = " "
        &form   = " frame f-linha no-label "
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
    def var v-mencod as int.
    v-mencod = int(string(tt-menu.menniv,"9") +
                   string(tt-menu.ordsup,"999") +
                   string(tt-menu.menord,"999")).
                   
    run p-cria-acesmenu.    
                 
    hide frame f-com1.
    hide frame f-com2.
    hide frame f-linha.
    hide frame f1.
    hide frame f2.
    if tt-menu.menpar <> ""
    then run value(tt-menu.menpro + ".p") (tt-menu .menpar).
    else run value(tt-menu.menpro + ".p").
    view frame f-com1.
    view frame f-com2.
    view frame f1.
    view frame f-linha.
    view frame f2.
    pause 0.
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

procedure p-cria-tt-menu:
 
    create tt-menu.
    assign tt-menu.mentit = menu.mentit
           tt-menu.menpro = menu.menpro
           tt-menu.menpar = menu.menpar
           tt-menu.aplicod = menu.aplicod
           tt-menu.menord = menu.menord
           tt-menu.ordsup = menu.ordsup
           tt-menu.menniv = menu.menniv.

end procedure.

procedure p-cria-acesmenu:

    find acesmenu where
         acesmenu.etbcod = setbcod and
         acesmenu.funcod = sfuncod and
         acesmenu.mencod = v-mencod
                        no-error.
    if not avail acesmenu
    then do transaction:
        create acesmenu.
        assign acesmenu.etbcod = setbcod
               acesmenu.funcod = sfuncod
               acesmenu.mencod = v-mencod
               acesmenu.int1 = 1
               acesmenu.char1 = tt-menu.aplicod
               acesmenu.dtacesso = today
               acesmenu.hracesso = time
                                    .
    end.
    else do transaction:
        assign acesmenu.dtacesso = today
               acesmenu.hracesso = time
               acesmenu.int1     = acesmenu.int1 + 1
                              .

    end.

end procedure.