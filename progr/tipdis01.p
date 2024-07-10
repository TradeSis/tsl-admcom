{admcab.i}

def input parameter p-catcod like tipodistr.catcod.

/*
def input parameter p-clacod like clase.clacod.

p-catcod = int(string(p-catcod,"999") + string(p-clacod,"999999")).
*/
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
    initial ["","  Inclui","  Altera","  Exclui",""].
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
                 .
assign
    esqregua = yes
    esqpos1  = 1
    esqpos2  = 1.

def var vfiliais as char .
                                                                                
disp "                        TIPOS DE DISTRIBUICAO      " 
            with frame f1 1 down width 80                                       
            color message no-box no-label row 4.
                                                  
disp " " with frame f2 1 down width 80 color message no-box no-label            
    row 20.                                                                     
def buffer btbcntgen for tbcntgen.                            
def var i as int.

def temp-table tt-distr
    field codtipo like tipodistr.codtipo
    field tamanho as char extent 10
    field qtdtam as int extent 10
    index i1 codtipo.
def var vi as int.    
form tt-distr.codtipo column-label "Tipo" format ">>>>"
     tt-distr.tamanho[1] no-label format "  !"
     tt-distr.qtdtam[1] no-label format ">"
     tt-distr.tamanho[2] no-label format " !"
     tt-distr.qtdtam[2] no-label format ">"
     tt-distr.tamanho[3] no-label format " !"
     tt-distr.qtdtam[3] no-label format ">"
     tt-distr.tamanho[4] no-label format " !"
     tt-distr.qtdtam[4] no-label format ">"
     tt-distr.tamanho[5] no-label format " !"
     tt-distr.qtdtam[5] no-label format ">"
     tt-distr.tamanho[6] no-label format " !"
     tt-distr.qtdtam[6] no-label format ">"
     tt-distr.tamanho[7] no-label format " !"
     tt-distr.qtdtam[7] no-label format ">"
     tt-distr.tamanho[8] no-label format " !"
     tt-distr.qtdtam[8] no-label format ">"
     tt-distr.tamanho[9] no-label format " !"
     tt-distr.qtdtam[9] no-label format ">"
     tt-distr.tamanho[10] no-label format " !"
     tt-distr.qtdtam[10] no-label format ">"
     with frame f-linha 7 down color with/cyan 
     centered.
procedure recal-distr:
for each tt-distr: delete tt-distr. end.
for each tipodistr where 
        tipodistr.catcod = p-catcod 
        by tipodistr.codtipo
        by tipodistr.tamanho:
    find first tt-distr where
               tt-distr.codtip = tipodistr.codtipo
               no-error.
    if not avail tt-distr          
    then do:
        create tt-distr.
        tt-distr.codtipo = tipodistr.codtipo.
    end.
    do vi = 1 to 10:
        if tt-distr.tamanho[vi] = ""
        then do:
            tt-distr.tamanho[vi] = tipodistr.tamanho.
            tt-distr.qtdtam[vi] = tipodistr.qtdtam.
            leave.
        end.    
    end.
        
end.    
end procedure.

def temp-table tt-tipodistr like tipodistr.
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
    run recal-distr.
    
    {sklclstb.i  
        &color = with/cyan
        &file = tt-distr     
        &cfield = tt-distr.codtipo
        &noncharacter = /* 
        &ofield = " tt-distr.tamanho[1]
                    tt-distr.qtdtam[1] 
                    tt-distr.tamanho[2]
                    tt-distr.qtdtam[2] 
                    tt-distr.tamanho[3]
                    tt-distr.qtdtam[3] 
                    tt-distr.tamanho[4]
                    tt-distr.qtdtam[4] 
                    tt-distr.tamanho[5]
                    tt-distr.qtdtam[5] 
                    tt-distr.tamanho[6]
                    tt-distr.qtdtam[6] 
                    tt-distr.tamanho[7]
                    tt-distr.qtdtam[7] 
                    tt-distr.tamanho[8]
                    tt-distr.qtdtam[8] 
                    tt-distr.tamanho[9]
                    tt-distr.qtdtam[9] 
                    tt-distr.tamanho[10]
                    tt-distr.qtdtam[10] 
                    "  
        &aftfnd1 = " "
        &where  = " true use-index i1 "
        &aftselect1 = " run aftselect.
                        a-seeid = -1.
                        if esqcom1[esqpos1] = ""  EXCLUI"" or
                           esqcom2[esqpos2] = """"    or
                           keyfunction(lastkey) = ""END-ERROR""
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
    def buffer btipodistr for tipodistr.
    do  :

        find last btipodistr no-lock no-error.
        scroll from-current down with frame f-linha.

        create tt-distr.
        tt-distr.codtipo = if avail btipodistr
                            then btipodistr.codtipo + 1
                            else 1.
        disp tt-distr.codtipo  with frame f-linha.   
        do vi = 1 to 10:
            update tt-distr.tamanho[vi] 
                   tt-distr.qtdtam[vi] 
                   with frame f-linha.
        end.     
        for each tt-tipodistr.
            delete tt-tipodistr.
        end.
        do vi = 1 to 10:
            if tt-distr.tamanho[vi] <> ""
            then do:
                create tt-tipodistr.
                tt-tipodistr.catcod = p-catcod.
                tt-tipodistr.tamanho = tt-distr.tamanho[vi].
                tt-tipodistr.codtipo = tt-distr.codtipo.
                tt-tipodistr.qtdtam = tt-distr.qtdtam[vi].
            end.
        end.
        for each tt-tipodistr where
                 tt-tipodistr.tamanho <> "":
            create tipodistr.
            buffer-copy tt-tipodistr to tipodistr.
        end.
    end.
    hide frame f-inclui no-pause.
end.            
procedure altera:

        do vi = 1 to 10:
            update tt-distr.tamanho[vi] 
                   tt-distr.qtdtam[vi] 
                   with frame f-linha.
        end.     
        for each tt-tipodistr.
            delete tt-tipodistr.
        end.
        do vi = 1 to 10:
            if tt-distr.tamanho[vi] <> ""
            then do:
                create tt-tipodistr.
                tt-tipodistr.catcod = p-catcod.
                tt-tipodistr.tamanho = tt-distr.tamanho[vi].
                tt-tipodistr.codtipo = tt-distr.codtipo.
                tt-tipodistr.qtdtam = tt-distr.qtdtam[vi].
            end.
        end.
        for each tipodistr where
                 tipodistr.catcod = p-catcod and
                 tipodistr.codtipo = tt-distr.codtipo:
            delete tipodistr.
        end.    
        for each tt-tipodistr where
                 tt-tipodistr.tamanho <> "":
            create tipodistr.
            buffer-copy tt-tipodistr to tipodistr.
        end.

end procedure.
procedure exclui:
    sresp = no.
    message "Confirma excluir ? " update sresp.
    if sresp then    
    for each tipodistr where
                 tipodistr.catcod = p-catcod and
                 tipodistr.codtipo = tt-distr.codtipo:
            delete tipodistr.
    end.  
end procedure.
