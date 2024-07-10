{admcab.i}
def var vprocod like produ.procod.

def temp-table tt-nfent
    field etbcod like plani.etbcod
    field serie  like plani.serie
    field numero like plani.numero format ">>>>>>9"
    field pladat like plani.pladat
    field emite  like plani.emite
    field movqtm like movim.movqtm
    field total  as dec
    index i1 pladat descending
    .

def var vtotal as dec.
    
repeat:
    update vprocod  label "Codigo Produto"
        with frame f-1 1 down side-label width 80.
    find produ where produ.procod = vprocod .
    disp produ.pronom no-label with frame f-1.
    
    for each movim where movim.procod = produ.procod and
                         movim.movtdc = 4 
                         no-lock:
        find plani where plani.etbcod = movim.etbcod and
                    plani.placod = movim.placod and
                    plani.movtdc = movim.movtdc 
                    no-lock no-error.
        if avail plani
        then do:
            find first tt-nfent where tt-nfent.numero = plani.numero and
                                      tt-nfent.pladat = plani.pladat and
                                      tt-nfent.emite  = plani.emite
                                      no-error.
            if not avail tt-nfent
            then do:
                create tt-nfent.
                tt-nfent.etbcod = plani.etbcod.
                tt-nfent.numero = plani.numero.
                tt-nfent.pladat = plani.pladat.
                tt-nfent.emite = plani.emite.
                tt-nfent.serie = plani.serie .
            end.    
            tt-nfent.movqtm = tt-nfent.movqtm + movim.movqtm.                            end.                
    end.
    for each tt-nfent by tt-nfent.pladat descending.
        vtotal = vtotal + tt-nfent.movqtm.
        tt-nfent.total = vtotal.
        
        /*
        disp tt-nfent.pladat column-label "Data"
             tt-nfent.numero column-label "Numero"
             tt-nfent.emite  column-label "Fornecedor"
             tt-nfent.movqtm column-label "Quantidade"
             vtotal          column-label "Acumulado"
             with frame f-disp down.
        */
    end.
    leave.
end. 

form tt-nfent.pladat       column-label "Data"
     help "TECLE ENTER PARA VER OS ITENS DA NF"
     tt-nfent.etbcod column-label "Fil"
     tt-nfent.emite  column-label "Fornecedor"
     tt-nfent.serie  column-label "Serie"
     tt-nfent.numero column-label "Numero"
     tt-nfent.movqtm column-label "Quantidade"
     tt-nfent.total  column-label "Acumulado"
     with frame f-linha down.
         
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
    initial ["","  INCLUI","","",""].
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


def buffer btbcntgen for tbcntgen.                            
def var i as int.

l1: repeat:
    assign
        a-seeid = -1 a-recid = -1 a-seerec = ?
        esqpos1 = 1 esqpos2 = 1. 
    hide frame f-linha no-pause.
    clear frame f-linha all.
    {sklclstb.i  
        &color = with/cyan
        &file = tt-nfent  
        &cfield = tt-nfent.pladat
        &noncharacter = /* 
        &ofield = " tt-nfent.numero
                    tt-nfent.etbcod
                    tt-nfent.emite
                    tt-nfent.serie
                    tt-nfent.movqtm
                    tt-nfent.total
                    "               
        &aftfnd1 = " "
        &where  = " true "
                          
        &aftselect1 = " 
                        if keyfunction(lastkey) = ""RETURN""
                        then do:
                            find plani where
                                 plani.etbcod = tt-nfent.etbcod and
                                 plani.emite  = tt-nfent.emite and
                                 plani.serie  = tt-nfent.serie and
                                 plani.numero = tt-nfent.numero
                                 no-lock no-error.
                            if avail plani
                            then do:     
                            for each movim where 
                                    movim.etbcod = plani.etbcod and
                                    movim.movtdc = plani.movtdc and
                                    movim.placod = plani.placod 
                                    no-lock:
                                disp movim.procod 
                                     movim.movpc
                                     movim.movqtm
                                     with frame f-mov column 40
                                     row 6 down overlay
                                     .
                            end.
                            pause.
                            end.            
                                    
      
                        end.
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

procedure aftselect:
    clear frame f-linha1 all.
    if esqcom1[esqpos1] = "  INCLUI"
    THEN DO on error undo:
        
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


