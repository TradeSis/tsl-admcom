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
    initial [""," MARCA"," MARCA TODOS","",""].
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
                 row 10 no-box no-labels side-labels column 1 centered.
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
     with frame f-linha 6 down color with/cyan /*no-box*/
     centered.
           
def var vesc as log format "Sim/Nao" initial no.
def var vdti as date.
def var vdtf as date.
def var vsetcod as char.

def temp-table tt-setor
    field setcod like setaut.setcod 
    field setnom like setaut.setnom
    field marca as char.

assign
    vdti = date(month(today),01,year(today))
    vdtf = today.

for each setaut no-lock:
    if not can-find(first tt-setor where 
                          tt-setor.setcod = setaut.setcod) then do:
        create tt-setor.
        assign tt-setor.setcod = setaut.setcod
               tt-setor.setnom = setaut.setnom
               tt-setor.marca  = "".
    end.       
end.

repeat:              

    if connected ("banfin")
    then disconnect banfin.
                       
    update vesc label "Conectar LP"
        with frame f0 side-label width 80.
    
    connect banfin -H erp.lebes.com.br -S sbanfin -N tcp -ld banfin.
    
    update vsetcod label "Setor" with frame f-sel.
    
    if vsetcod <> ""
    then do:
        find setaut where setaut.setcod = int(vsetcod) no-lock.
        disp setaut.setnom no-label with frame f-sel.
    end.

    if vsetcod = "" then
        run monta-browser.

    hide frame f-com1.
    
    update vdti at 1 label "Periodo de"  format "99/99/9999"
       vdtf label "Ate"  format "99/99/9999"
       with frame f-sel 1 down side-label width 80 row 6.
    
    def var vindex as int.
    def var vsel as char extent 2 format "x(15)"
        init["Analitico ","Sintetico  "] .
    disp vsel with frame f10.
    choose field vsel with frame f10 1 down
        centered side-label no-label.
        
    if frame-index = 1
    then do:    
        run rmetdes1a.p(input vesc,
                        input vsetcod,
                        input vdti,
                        input vdtf). 
    end.
    else do:
        run rmetdes2a.p(input vesc,
                        input vsetcod,
                        input vdti,
                        input vdtf).
    end.
    disconnect banfin.
    leave.
end.    
procedure monta-browser:

/*disp "                                SETORES          " 
            with frame f1 1 down width 80                                       
            color message no-box no-label row 10.*/
                                                  
/*disp " " with frame f2 1 down width 80 color message no-box no-label            
    row 20. */                                                                   

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
        &file = tt-setor  
        &cfield = tt-setor.setcod 
        &noncharacter = /* 
        &ofield = "tt-setor.marca tt-setor.setnom"  
        &aftfnd1 = " "
        &where  = " "
        &aftselect1 = " run aftselect.
                        a-seeid = -1.
                        "
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

end procedure.

procedure aftselect:
    clear frame f-linha1 all.
    if esqcom1[esqpos1] = " MARCA"
    THEN DO on error undo:
        if tt-setor.marca = "*" then do: 
            assign tt-setor.marca = ""
                   vsetcod = " ".
            for each tt-setor where tt-setor.marca = "*" :
                assign vsetcod = if vsetcod <> "" then vsetcod + "," + string(tt-setor.setcod) else string(tt-setor.setcod).
            end.    
        end.
        else do:
            assign tt-setor.marca = "*".
            if vsetcod = "0" then         
                assign vsetcod = string(tt-setor.setcod).
            else 
                assign vsetcod = vsetcod + "," + string(tt-setor.setcod).
        end.
        disp skip vsetcod format "x(20)" with frame f-sel.
    END.
    if esqcom1[esqpos1] = " MARCA TODOS"
    THEN DO:
        assign vsetcod = "".
        for each tt-setor:
            assign tt-setor.marca = "*".
            
            if vsetcod <> ""
            then assign vsetcod = vsetcod + "," + string(tt-setor.setcod).
            else assign vsetcod = string(tt-setor.setcod).
            
        end.    
        disp skip "TODOS" with frame f-sel.
    END.
    if esqcom1[esqpos1] = "  EXCLUI"
    THEN DO:
        
    END.
    if esqcom2[esqpos2] = "    "
    THEN DO on error undo:
    
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

