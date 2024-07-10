{admcab.i}
{setbrw.i}                                                                      

def var vano as int format "9999".
def var vmes as int format "99".
vano = year(today).
vmes = month(today).

update vano label "Ano" vmes label "Mes"
    with frame f1 side-label 1 down width 80.
    
def var recatu1         as recid.
def var recatu2         as recid.
def var reccont         as int.
def var esqpos1         as int.
def var esqpos2         as int.
def var esqregua        as log.
def var esqvazio        as log.
def var esqascend     as log initial yes.
def var esqcom1         as char format "x(15)" extent 5
    initial ["","  Altera","  Inclui","",""].
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

def temp-table tt-tvendfil like tvendfil.

form tvendfil.etbcod column-label "Filial"
     estab.etbnom
     tvendfil.moveis column-label "Moveis"
     tvendfil.moda   column-label "Moda"
     with frame f-linha 10 down color with/cyan /*no-box*/
     centered.
                                                                         
                                                                                
disp "               VENDEDORES POR FILIAL       " 
            with frame f1 1 down width 80                                       
            color message no-box no-label row 4.
                                                  
disp " " with frame f2 1 down width 80 color message no-box no-label            
    row 20.                                                                     
def buffer btbcntgen for tbcntgen.                            
def var i as int.


l1: repeat:
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
        &file = tvendfil  
        &cfield = tvendfil.etbcod
        &noncharacter = /* 
        &ofield = " estab.etbnom when avail estab
                    tvendfil.moveis
                    tvendfil.moda
                    "  
        &aftfnd1 = " find estab where estab.etbcod = tvendfil.etbcod
                        no-lock no-error. "
        &where  = " tvendfil.anoref = vano and
                    tvendfil.mesref = vmes
                    "
        &aftselect1 = " run aftselect.
                        a-seeid = -1.
                        if esqcom1[esqpos1] = ""  EXCLUI"" 
                        then do:
                            next l1.
                        end.
                        else next keys-loop. "
        &go-on = TAB 
        &naoexiste1 = " bell.
                        message color red/with
                        ""Nenhum registro encontrato."" 
                        view-as alert-box.
                        esqvazio = yes.
                        leave keys-loop.
                      "  
        &otherkeys1 = " run controle. "
        &locktype = " "
        &form   = " frame f-linha "
    }   
    if keyfunction(lastkey) = "end-error"
    then DO:
        leave l1.       
    END.
    if esqvazio
    then do:
        sresp = no.
        message "Importar arquivo?" update sresp.
        if sresp
        then do:
            run importar-arquivo.
            if keyfunction(lastkey) = "END-ERROR"
            then leave l1.
            next l1.
        end.
        else do:
            esqcom1[esqpos1] = "  INCLUI".
            run aftselect .
            esqcom1[esqpos1] = "".
            next l1.
        end.
    end.
end.
hide frame f1 no-pause.
hide frame f2 no-pause.
hide frame ff2 no-pause.
hide frame f-linha no-pause.

procedure aftselect:
    clear frame f-linha1 all.
    if esqcom1[esqpos1] = "  INCLUI"
    THEN DO on error undo on endkey undo, leave:
        scroll from-current down with frame f-linha.
        prompt-for            
                    tvendfil.etbcod  with frame f-linha.
        find estab where estab.etbcod = input frame f-linha tvendfil.etbcod
                no-lock no-error.
        if  not avail estab
        then do:
            message color red/with "Filial não cadastrada."
            view-as alert-box.
            undo. 
        end.        
        disp estab.etbnom with frame f-linha.
        prompt-for            
                    tvendfil.moveis
                    tvendfil.moda
                    with frame f-linha.

        create tvendfil.
        assign
                    tvendfil.anoref = vano
                    tvendfil.mesref = vmes
                    tvendfil.etbcod = input frame f-linha tvendfil.etbcod
                    tvendfil.moveis = input frame f-linha tvendfil.moveis
                    tvendfil.moda   = input frame f-linha tvendfil.moda
                    .
    END.
    if esqcom1[esqpos1] = "  ALTERA"
    THEN DO on error undo:
        update
            tvendfil.moveis
                    tvendfil.moda  
                    with frame f-linha.
    END.
    if esqcom1[esqpos1] = "  EXCLUI"
    THEN DO:
        sresp = no.
        message "Confirma EXCLUIR? " update sresp
        .
        if sresp
        then do on error undo:
            delete tvendfil.
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

procedure importar-arquivo:
    def var vlinha as char.
    def var varquivo as char format "x(65)".
    varquivo = "/admcom/folha/ferias/".
    for each tt-tvendfil. delete tt-tvendfil. end.
    repeat:
        update varquivo label "Arquivo"
            with frame f-imp 1 down row 10 width 80 side-label.
        if search(varquivo) = ?
        then do:
            message color red/with
            "Arquivo não encontrado."
             view-as alert-box.
             next.
        end.
        else do:
            input from value(varquivo).
            repeat:
                import unformatted vlinha.
                create tt-tvendfil.
                assign
                    tt-tvendfil.anoref = int(entry(2,vlinha,";"))
                    tt-tvendfil.mesref = int(entry(1,vlinha,";"))
                    tt-tvendfil.etbcod = int(entry(3,vlinha,";"))
                    tt-tvendfil.moveis = int(entry(4,vlinha,";"))
                    tt-tvendfil.moda   = int(entry(5,vlinha,";"))
                    .
            end.
            input close.
            for each tt-tvendfil where 
                     tt-tvendfil.anoref = vano and
                     tt-tvendfil.mesref = vmes:
                create tvendfil.
                buffer-copy tt-tvendfil to tvendfil.
            end.
        end.
        hide frame f-imp no-pause.
        leave.
    end.
end procedure.
