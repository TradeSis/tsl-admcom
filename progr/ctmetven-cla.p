{admcab.i}
{setbrw.i}                                                                      

def input parameter p-etbcod like estab.etbcod.
def input parameter p-ano as int.
def input parameter p-mes as int.

pause 0.
def var recatu1         as recid.
def var recatu2         as recid.
def var reccont         as int.
def var esqpos1         as int.
def var esqpos2         as int.
def var esqregua        as log.
def var esqvazio        as log.
def var esqascend     as log initial yes.
def var esqcom1         as char format "x(15)" extent 5
    initial ["","  INCLUI","  ALTERA","",""].
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

def temp-table tt-metven like metven
    index i1 metano metmes etbcod .

form   tt-metven.clacod column-label "Classe"
       clase.clanom no-label
       tt-metven.metval column-label "Valor"     
                format ">>>,>>>,>>9.99"
     with frame f-linha 10 down color with/cyan /*no-box*/
     centered OVERLAY.
                                                                         
disp "                            CONTROLE DE METAS     "
            with frame f1 1 down width 80                                                   color message no-box no-label row 4
             overlay.
pause 0.
                                    
def var vmes as int format "99".
def var vano as int format "9999".
def var i as int.
VANO = P-ANO.
VMES = P-MES.
/*
update 
    vmes label "Mes" format "99"
    vano label "Ano" format "9999" with frame f-mt side-labe.
                                       */
hide frame f1.

disp "                     CONTROLE DE METAS - MES " + STRING(VMES,"99") +
            " ANO " + string(vano,"9999")        format "x(70)"
            with frame f-1 1 down width 80                                       
            color message no-box no-label row 4
            overlay.
                                                  
disp " " with frame f2 1 down width 80 color message no-box no-label            
    row 20 overlay.   
    
for each metven where metven.etbcod = p-etbcod and
                      metven.metano = p-ano and
                      metven.metmes = p-mes and
                      metven.clacod > 0 no-lock:
    create tt-metven.
    buffer-copy metven to tt-metven.
end.    

l1: repeat:
    assign
        a-seeid = -1 a-recid = -1 a-seerec = ?
        esqpos1 = 2 esqpos2 = 2. 
    hide frame f-linha no-pause.
    clear frame f-linha all.
    disp esqcom1 with frame f-com1.
    disp esqcom2 with frame f-com2.
    {sklclstb.i  
        &color = with/cyan
        &file = tt-metven  
        &cfield = tt-metven.clacod
        &noncharacter = /* 
        &ofield = " 
                    clase.clanom when avail clase
                    tt-metven.metval
                      "
        &aftfnd1 = " 
                    Find clase where clase.clacod = tt-metven.clacod
                        no-lock no-error.
                    "
        &where  = " tt-metven.etbcod = p-etbcod and
                    tt-metven.metano = p-ano and
                    tt-metven.metmes = p-mes "
        &aftselect1 = " run aftselect.
                        a-seeid = -1.
                        if esqcom1[esqpos1] = ""  EXCLUI"" or
                           esqcom2[esqpos2] = ""  CLASSE""
                        then do:
                            next l1.
                        end.
                        else next keys-loop. "
        &go-on = TAB 
        &naoexiste1 = "  Message ""Nenhum registro encontrado.""
                        .
                        sresp = no.
                        message ""Deseja incluir? "" update sresp. 
                        if sresp 
                        then do:
                            esqcom1[esqpos1] = ""  INCLUI"".
                            run aftselect.
                            next l1.
                        end.
                        else leave l1.
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
        create tt-metven.
        tt-metven.metano = p-ano.
        tt-metven.metmes = p-mes.
        tt-metven.etbcod = p-etbcod.
        update tt-metven.clacod
               tt-metven.metval  format ">>>,>>>,>>9.99"
                 with frame f-linha1 
                 1 down 1 column row 10 centered.
        sresp = no.
        message "Confirma Incluir ?" update sresp.
        if sresp then do:
            create metven.
            buffer-copy tt-metven to metven.
        end.
    END.
    if esqcom1[esqpos1] = "  ALTERA"
    THEN DO:
        disp tt-metven.clacod with frame f-linha1.
        update 
               tt-metven.metval
                 with frame f-linha1 
                 1 down 1 column row 10 centered.
                 
        find first metven where 
                   metven.etbcod = tt-metven.etbcod and
                   metven.forcod = tt-metven.forcod and
                   metven.clacod = tt-metven.clacod and
                   metven.metano = tt-metven.metano and
                   metven.metmes = tt-metven.metmes
                   no-error.
        if avail metven and
                 metven.metval <> tt-metven.metval
        then do:
            sresp = no.
            message "Confirma Alterar ?" update sresp.
            if sresp then do:
                metven.metval = tt-metven.metval.           
            end.
        end.

    END.
    if esqcom1[esqpos1] = "  EXCLUI"
    THEN DO:
        find first metven where 
                   metven.etbcod = tt-metven.etbcod and
                   metven.forcod = tt-metven.forcod and
                   metven.clacod = tt-metven.clacod and
                   metven.metano = tt-metven.metano and
                   metven.metmes = tt-metven.metmes
                   no-error.
        if avail metven 
        then do:
            sresp = no.
            message "Confirma Excluir ?" update sresp.
            if sresp then do:
                delete metven.
                delete tt-metven.
            end.
        end.
    
    END.
    if esqcom2[esqpos2] = "  classe"
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

