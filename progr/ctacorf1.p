/* PMO PTE */
 
{admcab.i}
{setbrw.i} 

def temp-table tt-contacor like contacor.

def buffer bestab for estab.

def var recatu1         as recid.
def var recatu2         as recid.
def var reccont         as int.
def var esqpos1         as int.
def var esqpos2         as int.
def var esqregua        as log.
def var esqvazio        as log.
def var esqascend     as log initial yes.
def var esqcom1         as char format "x(15)" extent 5
    initial ["","  Inclui","  Filtro","  Exclui", ""].
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
     func.funnom        column-label "Nome"  format "x(20)"
     contacor.setcod    column-label "Setor"
     setaut.setnom      column-label "Set. Nome" format "x(15)" 
     contacor.datemi    column-label "Data"
     contacor.valcob    column-label "Valor" format "->>>,>>9.99"
     /*contacor.ndxdes    column-label "%"*/ 
     with frame f-linha 10 down color with/cyan /*no-box*/
         width 80.
                                                                         
                                                                                
disp space(20) "CONTA CORRENTE CONSULTORES  - CREDITOS" space(20)  
            with frame f1 1 down centered width 80                                       
            color message no-box no-label row 4.
                                                  
disp " " with frame f2 1 down width 80 color message no-box no-label            
    row 20.                                                                     
def buffer btbcntgen for tbcntgen.                            
def var i as int.

def var f-etbcod like estab.etbcod.
def var f-funcod like func.funcod.

def var vtotal as dec format ">>>,>>>,>>9.99".

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
    vtotal = 0.
    for each contacor where  contacor.sitcor = "" and
                    contacor.natcor = yes and
                    (if f-etbcod > 0 then contacor.etbcod = f-etbcod
                                     else true) and
                    (if f-funcod > 0 then contacor.funcod = f-funcod
                                     else true) 
                                     no-lock.
        vtotal = vtotal + contacor.valcob.
    end.                                 
     
    disp vtotal no-label with frame f-total row 19 no-box overlay
            column 65.
    pause 0.
    
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
                           "  
        &aftfnd1 = " find func where func.etbcod = contacor.etbcod and
                                     func.funcod = contacor.funcod
                        no-lock no-error. 
                     find setaut where setaut.setcod = contacor.setcod
                        no-lock no-error.
                        "
        &where  = " contacor.sitcor = """" and
                    contacor.natcor = yes and
                    (if f-etbcod > 0 then contacor.etbcod = f-etbcod
                                     else true) and
                    (if f-funcod > 0 then contacor.funcod = f-funcod
                                     else true) "
        &aftselect1 = " run aftselect.
                        a-seeid = -1.
                        if esqcom1[esqpos1] = ""  Exclui"" or
                           esqcom1[esqpos1] = ""  Altera"" or
                           esqcom1[esqpos1] = ""  Filtro""
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
    if esqcom1[esqpos1] = "  EXCLUI"
    THEN DO:
        run exclui.
    END.
    if esqcom1[esqpos1] = "  Filtro"
    then do:
        update f-etbcod label "Filial"
               f-funcod label "Consultor"
               with frame f-fil 1 down centered row 10
               side-label overlAY.
    end.            
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
        update tt-contacor.setcod at 1 label "Setor"with frame f-inclui.
        if tt-contacor.setcod > 0
        then do:
            find setaut where setaut.setcod = tt-contacor.setcod
                    no-lock.
            disp setaut.setnom no-label with frame f-inclui.
        end.
        tt-contacor.datemi = today.
        update tt-contacor.datemi at 1 label "Data"  with frame f-inclui.
        update tt-contacor.valcob at 1 label "Valor" with frame f-inclui. 
        
        find last contacor  use-index ndx-7 where 
                  contacor.etbcod = tt-contacor.etbcod
                  no-lock no-error.
        if not avail contacor
        then tt-contacor.numcor = tt-contacor.etbcod * 10000000.
        else tt-contacor.numcor = contacor.numcor + 1.
        tt-contacor.sitcor = "LIB".
        if tt-contacor.etbcod > 0 and
           tt-contacor.funcod > 0
        then do:
            run Pi-Concilia-conta(input recid(tt-contacor), "INC").
        end.    
    end.
end procedure.

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

        sresp = no.
        message "Confirma excluir registro ?" update sresp.
        if sresp
        then do transaction:
            for each tt-contacor.
                    delete tt-contacor.
            end.    
            buffer-copy contacor to tt-contacor.
            contacor.sitcor = "EXC".
            run Pi-Concilia-conta(input recid(tt-contacor), "EXC").
        end.
end procedure.



Procedure Pi-Concilia-conta.

def input parameter p-recid as recid.
def input parameter p-operacao as char.

find first tt-contacor where recid(tt-contacor) = p-recid no-error.


def var vfuncod as int.
def var vetbcod like estab.etbcod.

def var valor-cre as dec.
def var valor-deb as dec.
def var valor-dif as dec.
 
vetbcod   = tt-contacor.etbcod.
vfuncod   = tt-contacor.funcod.
valor-cre = tt-contacor.valcob.
valor-deb = 0.

def buffer bcontacor for contacor.
def buffer dcontacor for contacor.

def var valor-pag as dec.

if p-operacao = "INC"
then do:
  find first contacor where contacor.natcor = no and
                        contacor.etbcod = vetbcod and
                        contacor.clifor = ? and
                        contacor.funcod = vfuncod and
                        contacor.sitcor = "LIB" no-lock no-error.
  if not avail contacor
  then do:
    message "Nao ha Debitos p/serem conciliados ! " skip
            "Lancamento a Credito nao permitido ." 
            view-as alert-box.
    undo, leave.         
  end.
  else 
  for each contacor where contacor.natcor = no and
                        contacor.etbcod = vetbcod and
                        contacor.clifor = ? and
                        contacor.funcod = vfuncod and
                        contacor.sitcor = "LIB" :
    valor-pag = 0.
    if contacor.valcob - contacor.valpag >= valor-cre
    then do on error undo:
        valor-pag = valor-cre.
        contacor.valpag = contacor.valpag + valor-pag.
        valor-deb = valor-deb + valor-pag.
        create dcontacor.
        find last bcontacor  use-index ndx-7 where 
                  bcontacor.etbcod = vetbcod
                  no-lock no-error.
        if not avail bcontacor
        then dcontacor.numcor = vetbcod * 10000000.
        else dcontacor.numcor = bcontacor.numcor + 1.
         assign
            dcontacor.natcor = yes
            dcontacor.etbcod = vetbcod
            dcontacor.funcod = vfuncod
            dcontacor.datemi = today
            dcontacor.datven = today
            dcontacor.valcob = valor-pag
            dcontacor.rec-conta = recid(contacor).
        valor-cre = 0.    
        if contacor.valcob = contacor.valpag
        then contacor.sitcor = "PAG".
        leave.
    end.
    else do on error undo:
        valor-pag = contacor.valcob - contacor.valpag.
        create dcontacor.
        find last bcontacor  use-index ndx-7 where 
                  bcontacor.etbcod = vetbcod
                  no-lock no-error.
        if not avail bcontacor
        then dcontacor.numcor = vetbcod * 10000000.
        else dcontacor.numcor = bcontacor.numcor + 1.
        assign
            dcontacor.natcor = yes
            dcontacor.etbcod = vetbcod
            dcontacor.funcod = vfuncod
            dcontacor.datemi = today
            dcontacor.datven = today
            dcontacor.valcob = valor-pag
            dcontacor.rec-conta = recid(contacor).
        valor-cre = valor-cre - valor-pag.
        valor-deb = valor-deb + valor-pag.
        contacor.valpag = contacor.valpag - valor-pag.
        if contacor.valcob = contacor.valpag
        then contacor.sitcor = "PAG".                           
    end.    
  end.
end.

if p-operacao = "EXC"
then do:
  find first contacor where contacor.natcor = no and
                        contacor.etbcod = vetbcod and
                        contacor.clifor = ? and
                        contacor.funcod = vfuncod and
                        contacor.sitcor = "PAG" no-lock no-error.
  if not avail contacor
  then do:
    message "Nao ha Debitos p/serem conciliados ! " skip
            "Exclusao de Credito nao permitida ." 
            view-as alert-box.
    undo, leave.         
  end.
  else 
  for each contacor where contacor.natcor = no and
                          contacor.etbcod = vetbcod and
                          contacor.clifor = ? and
                          contacor.funcod = vfuncod and
                          ( contacor.sitcor = "PAG" or
                            contacor.sitcor = "LIB"):

    if contacor.valpag >= valor-cre 
    then do:
        assign 
           contacor.valpag = contacor.valpag - valor-cre
           contacor.sitcor = "LIB"
           valor-cre = 0.
        leave.
    end.
    else do:
        assign valor-cre = valor-cre - contacor.valpag
               contacor.valpag = 0
               contacor.sitcor = "LIB".
        next.
    end.
  end.
end.

end procedure.



