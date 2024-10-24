/* PMO PTE */  
{admcab.i}
{setbrw.i}                                                                      

def temp-table tt-contacor like contacor.

def buffer bestab    for estab.
def buffer bcontacor for contacor. 

def var recatu1         as recid.
def var recatu2         as recid.
def var reccont         as int.
def var esqpos1         as int.
def var esqpos2         as int.
def var esqregua        as log.
def var esqvazio        as log.
def var esqascend     as log initial yes.
def var esqcom1         as char format "x(15)" extent 5
    initial [" Consulta ","  Inclui","  Altera","  Exclui",""].
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

form contacor.etbcod    column-label "Fil"
     contacor.funcod    column-label "Codigo"
     func.funnom           column-label "Nome"  format "x(19)"
     contacor.setcod       label "Setor"   
     setaut.setnom         column-label "Set. Nome" format "x(12)" 
     contacor.datemi    column-label "Data"
     contacor.valcob    column-label "Valor" format "->>>,>>9.99"
     contacor.campo3[1] column-label "Tipo" format "x(3)"
     /*contacor.ndxdes    column-label "%"*/ 
     with frame f-linha 10 down color with/cyan /*no-box*/
         width 80.
                                                                         
                                                                                
disp space(20) "CONTA CORRENTE CONSULTORES  - DEBITOS" space(20)  
            with frame f1 1 down centered width 80                                       
            color message no-box no-label row 4.
                                                  
disp " " with frame f2 1 down width 80 color message no-box no-label            
    row 20.                                                                     
def buffer btbcntgen for tbcntgen.                            
def var i as int.
def var v-aux-numcor as int.

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
        &file =  contacor 
        &cfield = contacor.etbcod
        &noncharacter = /* 
        &ofield = " contacor.funcod
                    func.funnom   when avail func
                    contacor.setcod
                    setaut.setnom when avail setaut
                    contacor.datemi
                    contacor.valcob
                    contacor.campo3[1]
                           "  
        &aftfnd1 = " find func where func.etbcod = contacor.etbcod and
                                     func.funcod = contacor.funcod
                        no-lock no-error. 
                     find setaut where setaut.setcod = contacor.setcod
                        no-lock no-error.
                        "
        &where  = " contacor.sitcor = ""LIB"" and
                    contacor.natcor = no and
                    contacor.clifor = ? "
        &aftselect1 = " run aftselect.
                        a-seeid = -1.
                        if esqcom1[esqpos1] = ""  Exclui"" or
                           esqcom1[esqpos1] = ""  Altera""
                        then do:
                            next l1.
                        end.
                        else next keys-loop. "
        &go-on = TAB 
        &naoexiste1 = " run inclui.
                if keyfunction(lastkey) = ""end-error""
                then leave l1. 
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
    if esqcom1[esqpos1] = " CONSULTA "
    THEN DO on error undo:
        run consulta.
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
    def var setbcod-ant like estab.etbcod. 
    for each tt-contacor.
        delete tt-contacor.
    end.    
    setbcod-ant = setbcod.
    do on error undo, retry:
        create tt-contacor.
        update tt-contacor.etbcod at 1 label "Filial"
               with frame f-inclui 1 down centered row 10 
               /*color message*/ side-label overlay
               title "    Incluir   ".
        find bestab where bestab.etbcod = tt-contacor.etbcod
                    no-lock.
        setbcod = tt-contacor.etbcod.            
        update tt-contacor.funcod at 1 label "Funcionario" 
                        with frame f-inclui.
        find func where func.etbcod = tt-contacor.etbcod and
                        func.funcod = tt-contacor.funcod
               no-lock.
        disp func.funnom no-label with frame f-inclui .
        setbcod = setbcod-ant.
        update tt-contacor.setcod at 1 label "Setor" with frame f-inclui.
        if tt-contacor.setcod > 0
        then do:
            find setaut where setaut.setcod = tt-contacor.setcod
                    no-lock.
            disp setaut.setnom no-label with frame f-inclui.
        end.
        tt-contacor.datemi = today.
        update tt-contacor.datemi at 1 label "Data"  with frame f-inclui.
        update tt-contacor.valcob at 1 label "Valor" with frame f-inclui. 
       
        update tt-contacor.campo3[1] at 1 label "Tipo"
                    help "Tipo: Est = Estoque / Compl =  Complemento Salarial"
                            with frame f-inclui.
        
        find last contacor  use-index ndx-7 where 
                  contacor.etbcod = tt-contacor.etbcod 
                  no-lock no-error.
        if not avail contacor
        then tt-contacor.numcor = tt-contacor.etbcod * 10000000.
        /* antonio */
        else do:
             assign v-aux-numcor = contacor.numcor + 1.
             repeat:
                find first bcontacor where bcontacor.numcor = v-aux-numcor
                    no-lock no-error.
                if avail bcontacor
                then do:
                    v-aux-numcor = v-aux-numcor + 1.
                    next.
                end.
                tt-contacor.numcor = v-aux-numcor.
                leave.
             end.
        end.
        /**/
        tt-contacor.sitcor = "LIB".
        if tt-contacor.etbcod > 0 and
           tt-contacor.funcod > 0
        then do:
            create contacor.
            buffer-copy tt-contacor to contacor.
            delete tt-contacor.
        end.    
    end.
end procedure.

procedure consulta:

    form contacor.etbcod at 1 label "Filial"
         bestab.etbnom no-label
         contacor.funcod at 1 label "Funcionario" 
         func.funnom no-label
         contacor.setcod at 1 label "Setor"
         setaut.setnom no-label 
         contacor.datemi at 1 label "Data" 
         contacor.valcob at 1 label "Valor Cob"
         contacor.valpag at 1 label "Valor Pag"
         contacor.campo3[1] at 1 label "Tipo"
             with frame f-contacor color black/cyan
          centered side-label row 5 .


     disp contacor.etbcod
            with frame f-contacor.

     find bestab where bestab.etbcod = contacor.etbcod
                    no-lock.
     disp bestab.etbnom no-label
            with frame f-contacor.
        
     disp contacor.funcod 
                with frame f-contacor.

     find func where func.etbcod = contacor.etbcod and
                     func.funcod = contacor.funcod
                             no-lock.
     disp func.funnom no-label with frame f-contacor .
 
     find setaut where setaut.setcod = contacor.setcod
                    no-lock no-error.
     disp setaut.setnom no-label when avail setaut with frame f-contacor.
     disp contacor.datemi at 1 label "Data"  with frame f-contacor.
     disp contacor.valcob at 1 with frame f-contacor.
     disp contacor.valpag at 1 with frame f-contacor.
        
     disp contacor.campo3[1] at 1 label "Tipo"
                with frame f-contacor.
        
        
     pause.



end.

procedure altera:
    for each tt-contacor:
        delete tt-contacor.
    end.
    create tt-contacor.
    buffer-copy contacor to tt-contacor.
        
    do on error undo, retry:
        
        disp tt-contacor.etbcod at 1 label "Filial"
               with frame f-altera 1 down centered row 10 
               /*color message*/ side-label overlay
               title "   Alterar   ".
        find bestab where bestab.etbcod = tt-contacor.etbcod
                    no-lock.
        disp bestab.etbnom no-label with frame f-altera.
        
        disp tt-contacor.funcod at 1 label "Funcionario" 
                        with frame f-altera.
        find func where func.etbcod = tt-contacor.etbcod and
                        func.funcod = tt-contacor.funcod
               no-lock.
        disp func.funnom no-label with frame f-altera .
 
        update tt-contacor.setcod at 1 label "Setor"with frame f-altera.
        if tt-contacor.setcod > 0
        then do:
            find setaut where setaut.setcod = tt-contacor.setcod
                    no-lock.
            disp setaut.setnom no-label with frame f-altera.
        end.
        update tt-contacor.datemi at 1 label "Data"  with frame f-altera.
        update tt-contacor.valcob at 1 label "Valor" with frame f-altera.
        
        update tt-contacor.campo3[1] at 1 label "Tipo"
              help "Tipo: Est = Estoque / Compl =  Complemento Salarial"
                            with frame f-altera.
        
        
        buffer-copy tt-contacor to contacor.
    end.
end procedure.

procedure exclui:
        disp contacor.etbcod at 1 label "Filial"
               with frame f-exclui 1 down centered row 10 
               /*color message*/ side-label overlay
               title "    Excluir   ".
        find bestab where bestab.etbcod = contacor.etbcod
                    no-lock.
        disp bestab.etbnom no-label with frame f-exclui.
        
        disp contacor.funcod at 1 label "Funcionario" 
                        with frame f-exclui.
        find func where func.etbcod = contacor.etbcod and
                        func.funcod = contacor.funcod
               no-lock.
        disp func.funnom no-label with frame f-exclui .
 
        disp contacor.setcod at 1 label "Setor"with frame f-exclui.
        if contacor.setcod > 0
        then do:
            find setaut where setaut.setcod = contacor.setcod
                    no-lock.
            disp setaut.setnom no-label with frame f-exclui.
        end.
        disp contacor.datemi at 1 label "Data"  with frame f-exclui.
        disp contacor.valcob at 1 label "Valor" with frame f-exclui.
        disp contacor.campo3[1] at 1 label "Tipo"
                            with frame f-exclui.

        sresp = no.
        message "Confirma excluir registro ?" update sresp.
        if sresp
        then do transaction:
            contacor.sitcor = "EXC".
        end.
end procedure.
