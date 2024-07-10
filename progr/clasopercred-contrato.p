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
    initial ["","  ALTERA","  INCLUI","",""].
/*
def var esqcom2         as char format "x(15)" extent 5
            initial [""," BASE CONTABIL "," BASE GERENCIAL","",""].
*/
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

def temp-table tt-tbcntgen 
    field nivel as char
    field numini as char
    field numfim as char
    field valor as dec
    index i1 nivel.

form " " 
     " "
     tt-tbcntgen.nivel format "x(10)" column-label "Nivel" 
     "Atraso de  "  tt-tbcntgen.numini no-label 
     "A  "  tt-tbcntgen.numfim  no-label "Dias"  
       tt-tbcntgen.valor  column-label "Provisao" format ">>9.99%"
        with frame f-linha 10 down color with/cyan 
        centered
     .
                                                                         
                                                                                
disp "                     CLASSIFICACAO CONTRATOS POR VENCIMENTO       " 
            with frame f1 1 down width 80                                       
            color message no-box no-label row 4.
                                                  
disp " " with frame f2 1 down width 80 color message no-box no-label            
    row 20.                                                                     
def var i as int.

for each tbcntgen where tbcntgen.tipcon = 13
                    no-lock by tbcntgen.campo1[1]  :
    create tt-tbcntgen.
    assign
        tt-tbcntgen.nivel = tbcntgen.campo1[1]
        tt-tbcntgen.numini = tbcntgen.numini
        tt-tbcntgen.numfim = tbcntgen.numfim
        tt-tbcntgen.valor = tbcntgen.valor
        .
end.                    
                    
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
        &file = tt-tbcntgen  
        &cfield = " tt-tbcntgen.nivel "
        &ofield = " tt-tbcntgen.numini           
                    tt-tbcntgen.numfim 
                    tt-tbcntgen.valor   "  
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
        &naoexiste1 = " esqcom1[esqpos1] = ""  INCLUI"".
                        run aftselect. 
                        esqcom1[esqpos1] = ""  "".
                        next l1.
                        " 

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
        create tt-tbcntgen.
        update tt-tbcntgen.nivel label "Nivel" format "x(10)"
               tt-tbcntgen.numini    label "Atraso em dias de"
               tt-tbcntgen.numfim    label "Ate"
               tt-tbcntgen.valor     label "%"
               with frame f-inclui 1 down centered row 8
                        side-label 
                        .
                
        if keyfunction(lastkey) = "RETURN" and
            tt-tbcntgen.nivel <> "" and
            tt-tbcntgen.numini <> "" and
            tt-tbcntgen.numfim <> ""
        then do:
            tt-tbcntgen.nivel = caps(tt-tbcntgen.nivel) .
            create tbcntgen.
            assign
                tbcntgen.tipcon = 13
                tbcntgen.etbcod = 0
                tbcntgen.campo1[1] = tt-tbcntgen.nivel
                tbcntgen.numini = tt-tbcntgen.numini
                tbcntgen.numfim = tt-tbcntgen.numfim
                tbcntgen.valor = tt-tbcntgen.valor
                .
        end.        
    END.
    if esqcom1[esqpos1] = "  ALTERA"
    THEN DO on error undo:
        find first tbcntgen where 
                   tbcntgen.tipcon = 13 and
                   tbcntgen.etbcod = 0 and
                   tbcntgen.numfim = tt-tbcntgen.numfim and
                   tbcntgen.numini = tt-tbcntgen.numini 
                   .
                                    
        update tt-tbcntgen.nivel label "Nivel" format "x(10)"
               tt-tbcntgen.numini    label "Atraso em dias de"
               tt-tbcntgen.numfim    label "Ate"
               tt-tbcntgen.valor     label "%"
               with frame f-altera 1 down centered row 8
                        side-label 
                        .
                
        if keyfunction(lastkey) = "RETURN" and
            tt-tbcntgen.nivel <> "" and
            tt-tbcntgen.numini <> "" and
            tt-tbcntgen.numfim <> ""
        then do:
            tt-tbcntgen.nivel = caps(tt-tbcntgen.nivel).
            assign
                tbcntgen.campo1[1] = tt-tbcntgen.nivel
                tbcntgen.numini = tt-tbcntgen.numini
                tbcntgen.numfim = tt-tbcntgen.numfim
                tbcntgen.valor = tt-tbcntgen.valor
                .
        end. 
    END.
    if esqcom1[esqpos1] = "  EXCLUI"
    THEN DO:
        
    END.
    if esqcom2[esqpos2] = " BASE GERENCIAL"
    THEN DO on error undo:
        hide frame f-com1 no-pause.
        hide frame f-com2 no-pause.
        connect ninja -H db2 -S sdrebninja -N tcp.
        run pro-clasopercred-contrato-bg.p.
        if connected("ninja")
        then disconnect "ninja".
    END.
    if esqcom2[esqpos2] = " BASE CONTABIL"
    THEN DO on error undo:
        hide frame f-com1 no-pause.
        hide frame f-com2 no-pause.
        connect ninja -H db2 -S sdrebninja -N tcp.
        
        run pro-clasopercred-contrato-bc.p.

        /*
        run clasopercred-contrato-bc.p.
        */
        
        if connected("ninja")
        then disconnect "ninja".
        
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

