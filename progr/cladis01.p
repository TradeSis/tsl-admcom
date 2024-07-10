{admcab.i}

def input parameter p-catcod like tipodistr.catcod.

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
    initial ["","  Inclui","  Exclui","Relatorio",""].
def var esqcom2         as char format "x(19)" extent 5
  initial ["","Filiais por tamanho"," Filiais referencia",
                " Gera Distribuicao"].
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
form tabaux.valor_campo  column-label "Classe" format "x(10)"
     clase.clanom        column-label "Descricao"
     with frame f-linha 7 down color with/cyan /*no-box*/
     centered.
                                                                         
                                                                                
disp "                CLASSES PARA DISTRIBUICAO      " 
            with frame f1 1 down width 80                                       
            color message no-box no-label row 4.
                                                  
disp " " with frame f2 1 down width 80 color message no-box no-label            
    row 20.                                                                     
def buffer btbcntgen for tbcntgen.                            
def var i as int.

def temp-table tt-tabaux like tabaux.
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
        &file = tabaux     
        &cfield = tabaux.valor_campo
        &noncharacter = /* 
        &ofield = " clase.clanom when avail clase "  
        &aftfnd1 = " 
            find clase where clase.clacod = int(tabaux.valor_campo)
                no-lock no-error.
            "
        &where  = " tabaux.tabela = ""cladist"" and
                    tabaux.nome_campo = string(p-catcod)
                    "
        &aftselect1 = " run aftselect.
                        a-seeid = -1.
                        if esqcom1[esqpos1] = ""  EXCLUI"" or
                           esqcom2[esqpos2] = ""Filiais por tamanho""
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
    if esqcom2[esqpos2] = "Filiais por tamanho"
    THEN DO:
        run filtam01.p(p-catcod, input int(tabaux.valor_campo)).
    END.
    if esqcom2[esqpos2] = " Filiais referencia"
    THEN DO:
        run filref01.p(p-catcod).
    END.
    if esqcom2[esqpos2] = " Gera distribuicao"
    THEN DO:
        run gerdis01.p(p-catcod, input int(tabaux.valor_campo)).
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
    then varquivo = "/admcom/relat/cladis01." + string(time).
    else varquivo = "..~\relat~\cladis01." + string(time).
    
    {mdadmcab.i &Saida     = "value(varquivo)"   
                &Page-Size = "64"  
                &Cond-Var  = "80" 
                &Page-Line = "66" 
                &Nom-Rel   = ""cladis01"" 
                &Nom-Sis   = """SISTEMA COMERCIAL""" 
                &Tit-Rel   = """CLASSES PARA DISTRIBUICAO""" 
                &Width     = "80"
                &Form      = "frame f-cabcab"}

    for each tabaux where
                  tabaux.tabela = "CLADIST"        and
                  tabaux.nome_campo = STRING(p-catcod)
                  no-lock:
        find clase where clase.clacod = int(tabaux.valor_campo)
                no-lock no-error.
        disp tabaux.valor_campo column-label "Classe" format "x(10)"
             clase.clanom when avail clase column-label "Descricao"
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
    def var p-clacod like clase.clacod.
    clear frame f-inclui all.
    do on error undo with frame f-inclui 1 down centered row 8
            1 column.
        for each tt-tabaux.
            delete tt-tabaux.
        end.
        create tt-tabaux.
        tt-tabaux.tabela = "CLADIST".
        tt-tabaux.nome_campo = string(p-catcod).
        p-clacod = 0.  
        update p-clacod label "Classe" .
        find clase where clase.clacod = p-clacod
                no-lock no-error.
        if not avail clase
        then undo.
        disp clase.clanom label "Descricao".        
        tt-tabaux.valor_campo = string(p-clacod).
        find first tabaux where
                  tabaux.tabela = tt-tabaux.tabela        and
                  tabaux.nome_campo = tt-tabaux.nome_campo  and
                  tabaux.valor_campo = tt-tabaux.valor_campo
                  no-lock no-error.
        if not avail tabaux
        then do:          
            create tabaux.
            buffer-copy tt-tabaux to tabaux.
        end.
    end.
    
    hide frame f-inclui no-pause.
end.            
procedure exclui:
    do on error undo with frame f-exclui 1 down centered row 8
            1 column.
        do:
            sresp = no.
            message "Confirma excluir?" update sresp.
            if sresp then delete tabaux.
        end.  
    end.

end procedure.
