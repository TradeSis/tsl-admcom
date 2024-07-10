{admcab.i}

{setbrw.i}                                                                      

def input parameter p-codexpositor like expositor.codexpositor.
def input parameter p-clacod like clase.clacod.

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

def temp-table tt-exploja
    field etbcod like estab.etbcod
    field qtdexp as int
    field qtdpec as int
    field qtdest as int
    index i1 etbcod.

def buffer bestab for estab.
form tt-exploja.etbcod
     bestab.etbnom no-label   
     tt-exploja.qtdexp label "Expositores"  format ">>>>>9"
     tt-exploja.qtdpec label "Qtd.Itens" format ">>>>>>9"
     tt-exploja.qtdest label "Estoque" format ">>>>>>>>9"
     with frame f-linha 10 down color with/cyan /*no-box*/
     centered.
                                                                         
find expositor where expositor.codexpositor = p-codexpositor no-lock.
find clase where clase.clacod = p-clacod no-lock.
find expcapacidade where
     expcapacidade.codexpositor = expositor.codexpositor and
     expcapacidade.clacod = clase.clacod 
     no-lock.
     
disp "     "
     expositor.descricao format "x(30)"
     " - "                           
     clase.clanom format "x(30)"
            with frame f1 1 down width 80                                       
            color message no-box no-label row 4.
                                                                                 disp " " with frame f2 1 down width 80 color message no-box no-label            
    row 20.                                                                     
def buffer btbcntgen for tbcntgen.                            
def var i as int.

def var vestatual like estoq.estatual.
def buffer bclase for clase.
def buffer cclase for clase.
def buffer dclase for clase.
def buffer eclase for clase.

procedure cal-est:
    vestatual = 0.
    for each produ where produ.clacod = clase.clacod no-lock:
        find estoq where estoq.etbcod = exploja.etbcod and
                         estoq.procod = produ.procod
                         no-lock no-error.
        if avail estoq
        then vestatual = vestatual + estoq.estatual.
    end.
    for each bclase where bclase.clasup = clase.clacod no-lock.
        for each produ where produ.clacod = bclase.clacod no-lock:
            find estoq where estoq.etbcod = exploja.etbcod and
                         estoq.procod = produ.procod
                         no-lock no-error.
            if avail estoq
            then vestatual = vestatual + estoq.estatual.
        end.
        for each cclase where cclase.clasup = bclase.clacod no-lock.
            for each produ where produ.clacod = cclase.clacod no-lock:
                find estoq where estoq.etbcod = exploja.etbcod and
                         estoq.procod = produ.procod
                         no-lock no-error.
                if avail estoq
                then vestatual = vestatual + estoq.estatual.
            end.
            for each dclase where dclase.clasup = cclase.clacod no-lock.
                for each produ where produ.clacod = dclase.clacod no-lock:
                    find estoq where estoq.etbcod = exploja.etbcod and
                         estoq.procod = produ.procod
                         no-lock no-error.
                    if avail estoq
                    then vestatual = vestatual + estoq.estatual.
                end.
                for each eclase where eclase.clasup = dclase.clacod no-lock.
                    for each produ where produ.clacod = eclase.clacod no-lock:
                        find estoq where estoq.etbcod = exploja.etbcod and
                             estoq.procod = produ.procod
                             no-lock no-error.
                        if avail estoq
                        then vestatual = vestatual + estoq.estatual.
                    end.
                end.
            end.            
        end.
    end.
        
end procedure.
for each estab where 
         estab.etbnom begins "DREBES-FIL"
         NO-LOCK.
    if estab.etbcod = 22
    then next.
    create tt-exploja.
    tt-exploja.etbcod = estab.etbcod.
    find first exploja where
               exploja.codexpositor = p-codexpositor and
               exploja.clacod = p-clacod and
               exploja.etbcod = estab.etbcod
               no-lock no-error.
    if avail exploja
    then  do:
        vestatual = 0.
        run cal-est.
        assign
            tt-exploja.qtdexp = exploja.qtdexpositor
            tt-exploja.qtdpec = expcapacidade.quantidade * exploja.qtdexposito
            tt-exploja.qtdest = tt-exploja.qtdest + vestatual.
    end.         
    else assign
             tt-exploja.qtdexp = 0
             tt-exploja.qtdpec = 0
             tt-exploja.qtdest = 0
             .          
end.                     
for each tt-exploja where tt-exploja.qtdexp = 0:
    delete tt-exploja.
end.    

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
    {sklclstb.i  
        &color = with/cyan
        &file = tt-exploja     
        &cfield = tt-exploja.etbcod
        &noncharacter = /* 
        &ofield = " bestab.etbnom  when avail bestab
                    tt-exploja.qtdexp 
                    tt-exploja.qtdpec
                    tt-exploja.qtdest "  
        &aftfnd1 = " 
            find bestab where bestab.etbcod = tt-exploja.etbcod
                    no-lock no-error. "
        &where  = " true "
        &aftselect1 = " run aftselect.
                        a-seeid = -1.
                        if esqcom1[esqpos1] = ""  EXCLUI"" 
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
        run exposi02.p(input recid(expositor)).
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
    find estab where estab.etbcod = setbcod no-lock.
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
                &Nom-Rel   = ""exposi02"" 
                &Nom-Sis   = """SISTEMA COMERCIAL""" 
                &Tit-Rel   = """CAPACIDADE DE EXPOSITORES POR CLASSE""" 
                &Width     = "80"
                &Form      = "frame f-cabcab"}
    disp with frame f1.
    for each tt-exploja:
        find bestab where bestab.etbcod = tt-exploja.etbcod 
            no-lock no-error.
        disp tt-exploja.etbcod
             bestab.etbnom when avail bestab
             tt-exploja.qtdexp column-label "Expositor"
             tt-exploja.qtdpec column-label "Qtd.Itens"
             tt-exploja.qtdest column-label "Estoque"
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
    do on error undo with frame f-inclui 1 down centered row 8
            1 column.
        create tt-exploja.
        update tt-exploja.etbcod.
        find bestab where bestab.etbcod = tt-exploja.etbcod 
                no-lock no-error.
        disp  bestab.etbnom when avail bestab
             tt-exploja.qtdexp
             .
        update tt-exploja.qtdexp.
        vestatual = 0.
        find exploja where exploja.codexpositor = p-codexpositor and
                           exploja.clacod = p-clacod and
                           exploja.etbcod = tt-exploja.etbcod
                           no-error.
        if avail exploja
        then exploja.qtdexpositor = tt-exploja.qtdexp .
        else if tt-exploja.qtdexp > 0
        then do:
            create exploja.
            assign
                exploja.codexpositor = p-codexpositor 
                exploja.clacod = p-clacod 
                exploja.etbcod = tt-exploja.etbcod
                exploja.qtdexpositor = tt-exploja.qtdexp
                .
        end.          
        run cal-est.
        assign
            tt-exploja.qtdpec = expcapacidade.quantidade * exploja.qtdexposito
            tt-exploja.qtdest = tt-exploja.qtdest + vestatual.
       
    end.
    hide frame f-inclui no-pause.
end.            
procedure altera:
    do on error undo with frame f-altera 1 down centered row 8
            1 column.
        find bestab where bestab.etbcod = tt-exploja.etbcod 
            no-lock no-error.
        disp tt-exploja.etbcod
             bestab.etbnom when avail bestab
             tt-exploja.qtdexp
             .
        update tt-exploja.qtdexp.
             
        find exploja where exploja.codexpositor = p-codexpositor and
                           exploja.clacod = p-clacod and
                           exploja.etbcod = tt-exploja.etbcod
                           no-error.
        if avail exploja
        then assign
                exploja.qtdexpositor = tt-exploja.qtdexp
                tt-exploja.qtdpec = 
                    expcapacidade.quantidade * exploja.qtdexpositor
                .
        if exploja.qtdexpositor = 0
        then delete exploja.
    end.

end procedure.
procedure exclui:
    do on error undo with frame f-exclui 1 down centered row 8
            1 column.
        find exploja where exploja.codexpositor = p-codexpositor and
                           exploja.clacod = p-clacod and
                           exploja.etbcod = tt-exploja.etbcod
                           no-error.
        if avail exploja
        then do:
            sresp = no.
            message "Confirma excluir?" update sresp.
            if sresp 
            then do:
                delete exploja.
                delete tt-exploja.
            end.    
        end.    
    end.

end procedure.
