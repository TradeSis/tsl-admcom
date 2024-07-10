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
    initial ["","  Inclui","  Filtro","  Exclui",""].
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

def var fil-vprocod like produ.procod.
def var fil-eprocod like produ.procod.


form produaux.procod column-label "Equivalente"
     produ.pronom    column-label "Descricao"
     produaux.valor_campo column-label "Produto"
     with frame f-linha 10 down color with/cyan /*no-box*/
     centered.
                                                                         
                                                                                
disp "                   CADASTRO DE PRODUTOS EQUIVALENTES      " 
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
        &file = produaux   
        &cfield = produaux.procod
        &noncharacter = /* 
        &ofield = " produ.pronom when avail produ 
                    produaux.valor_campo format ""x(10)"" "  
        &aftfnd1 = " 
                find produ where
                     produ.procod = produaux.procod no-lock no-error.
                 "    
        &where  = " (if fil-eprocod > 0
                    then produaux.procod = fil-eprocod else true) and
                    produaux.nome_campo = ""PRODUTO-EQUIVALENTE"" and
                    (if fil-vprocod > 0
                    then produaux.valor_campo = string(fil-vprocod)
                        else true) and
                    produaux.valor_campo <> """"    
                    "
        &aftselect1 = " run aftselect.
                        a-seeid = -1.
                        if esqcom1[esqpos1] = ""  EXCLUI"" or
                           esqcom2[esqpos2] = ""  CLASSE""
                        then do:
                            next l1.
                        end.
                        else next keys-loop. "
        &go-on = TAB 
        &naoexiste1 = "  run inclui.
                         if keyfunction(lastkey) = ""END-ERROR""
                         then leave keys-loop.
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
    THEN DO:
        run inclui.
    END.
    if esqcom1[esqpos1] = "  filtro"
    THEN DO:
        run filtro.
    END.
    if esqcom1[esqpos1] = "  EXCLUI"
    THEN DO:
        sresp = no.
        message "Confirma Exclui? " update sresp.
        if sresp 
        then do:
            produaux.valor_campo = "".
        end.
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

procedure inclui:
    def var vprocod like produ.procod.
    def var eprocod like produ.procod.
    def buffer bprodu for produ.
    repeat on error undo with frame f-inclui side-label 1 column 1 down centered
                        row 7 title "  inclui  ":
        if keyfunction(lastkey) = "END-ERROR"
        THEN leave.
        update vprocod label "Produto".
        find bprodu where bprodu.procod = vprocod no-lock no-error.
        if not avail bprodu
        then do:
            message "Produto nao cadatrado.".
            pause.
            undo.
        end.
        update eprocod label "Equivalente".
        find bprodu where bprodu.procod = eprocod no-lock no-error.
        if not avail bprodu
        then do:
            message "Produto nao cadatrado.".
            pause.
            undo.
        end.
        find produaux where produaux.procod = eprocod and
                             produaux.nome_campo = "PRODUTO-EQUIVALENTE" and
                             produaux.valor_campo = string(vprocod)
                             no-lock no-error.
        if not avail produaux
        then do:                     
            find produaux where produaux.procod = eprocod and
                             produaux.nome_campo = "PRODUTO-EQUIVALENTE" and
                             produaux.valor_campo = ""
                              no-error.
            if not avail produaux
            then do: 
                create produaux.
                assign
                    produaux.procod = eprocod
                    produaux.nome_campo = "PRODUTO-EQUIVALENTE"
                    produaux.valor_campo = string(vprocod)
                    produaux.tipo_campo = "int"
                    .
            END.
            else produaux.valor_campo = string(vprocod).
        end.       
        leave.         
    end.
end procedure.
procedure filtro:
    def buffer bprodu for produ.
    do on error undo with frame f-filtro side-label 1 column 1 down centered
                        row 7 title "  filtro  ":
        /*
        update fil-vprocod label "Produto".
        if fil-vprocod > 0
        then do:
        find bprodu where bprodu.procod = fil-vprocod no-lock no-error.
        if not avail bprodu
        then do:
            message "Produto nao cadatrado.".
            pause.
            undo.
        end.
        end.*/
        update fil-eprocod label "Equivalente".
        /*if fil-eprocod > 0
        then*/ do:
        find bprodu where bprodu.procod = fil-eprocod no-lock no-error.
        if not avail bprodu
        then do:
            message "Produto nao cadatrado.".
            pause.
            undo.
        end.
        end.
        find produaux where produaux.procod = fil-eprocod and
                             produaux.nome_campo = "PRODUTO-EQUIVALENTE" /*and
                             produaux.valor_campo = string(fil-vprocod)  */
                             no-lock no-error.
        if not avail produaux
        then do:                     
            message color red/woth
                "Nenhum regitro encontrado."
                 view-as alert-box.
            fil-eprocod = 0.
            fil-vprocod = 0.     
        end.                
    end.
end procedure.
