{admcab.i} 

{setbrw.i}                                                                      
{seltpmo.i " " "PREMIO"}

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
    initial ["","  Inclui","  Altera","",""].
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
def var vfunnom like func.funnom.
def var vdti as date.
def var vdtf as date.
form contacor.etbcod    column-label "Fil"
     estab.etbnom no-label
     contacor.campo1[1] column-label "Inicio" 
     contacor.campo1[2] column-label "Fim"
     " - "
     vdti 
     " a "
     vdtf
     with frame f-linha 10 down color with/cyan /*no-box*/
         width 80.
                                                                                
disp space(20) "AGENDA PAGAMENTO DE PREMIOS" space(20)  
            with frame f1 1 down centered width 80                                         color message no-box no-label row 4.
                                                  
disp " " with frame f2 1 down width 80 color message no-box no-label            
    row 20.                                                                     
def buffer btbcntgen for tbcntgen.                            
def var i as int.
def var v-aux-numcor as int.

def var ultimo-dia-mes as int.
ultimo-dia-mes = day(date(if month(today) = 12 then 1 else month(today) + 1,
    01,if month(today) = 12 then year(today) + 1 else year(today)) - 1).

for each contacor where contacor.modcod = "LPP":
    if contacor.campo1[1] > ultimo-dia-mes
    then contacor.campo1[1] = ultimo-dia-mes.
    if contacor.campo1[2] > ultimo-dia-mes
    then contacor.campo1[2] = ultimo-dia-mes.
end.

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
        &ofield = " estab.etbnom
                    contacor.campo1[1]
                    contacor.campo1[2]
                    vdti 
                    vdtf
                           "  
        &aftfnd1 = " find estab where estab.etbcod = contacor.etbcod no-lock.
                     vdti = date(month(today),contacor.campo1[1],year(today)).
                     vdtf = date(month(today),contacor.campo1[2],year(today)).
                    /*find func where func.etbcod = contacor.etbcod and
                                     func.funcod = contacor.funcod
                        no-lock no-error. 
                     if avail func 
                     then vfunnom = func.funnom.
                     else vfunnom = acha(""PREMIO"",contacor.campo3[2]). 
                     if vfunnom = ? then vfunnom = "" "".
                     find setaut where setaut.setcod = contacor.setcod
                        no-lock no-error.
                     */   "
        &where  = " contacor.modcod = ""LPP""  "
        &aftselect1 = " run aftselect.
                        a-seeid = -1.
                        next keys-loop. "
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
    if esqcom2[esqpos2] = "  Libera"
    THEN DO:
        run libera("libera").
    END.
    if esqcom2[esqpos2] = "  Previa"
    THEN DO:
        run libera("previa").
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
    def var vmeta as log format "Sim/Nao".
    def var dti-venda as date format "99/99/9999".
    def var dtf-venda as date format "99/99/9999".
    for each tt-contacor.
        delete tt-contacor.
    end.    
    setbcod-ant = setbcod.
    do on error undo, retry:
        v-tipodes = "".
        hide frame f-inclui.
        create tt-contacor.
        update tt-contacor.etbcod at 1 label "Filial"
               with frame f-inclui 1 down centered row 09 
               side-label overlay
               title "  Incluir  " + v-tipodes + " ".
        if tt-contacor.etbcod > 0
        then do:
            find bestab where bestab.etbcod = tt-contacor.etbcod
                    no-lock.
            disp estab.etbnom no-label with frame f-inclui.
            /*
            setbcod = tt-contacor.etbcod.            
            update tt-contacor.funcod at 1 label "Consultor" 
                        with frame f-inclui.
            if tt-contacor.funcod > 0
            then do:
                find func where func.etbcod = tt-contacor.etbcod and
                        func.funcod = tt-contacor.funcod
                    no-lock.
                disp func.funnom no-label with frame f-inclui .
            end. */
        end.
        setbcod = setbcod-ant.

        tt-contacor.datemi = today.
             
        update tt-contacor.campo1[1] at 1 label "Dia Inicio"
               tt-contacor.campo1[2]  label "Dia Fim"
                  with frame f-inclui. 
        if  tt-contacor.campo1[1] > 0 and
            tt-contacor.campo1[2] > 0 and
            tt-contacor.campo1[1] > tt-contacor.campo1[2] and
            tt-contacor.campo1[2] > ultimo-dia-mes
        then do:
            bell.
            message color red/with
            "Valores para Iicio e Fim incorretor."
            view-as alert-box. 
        end.
        else do:
        find last contacor  use-index ndx-7 where 
                  contacor.etbcod = tt-contacor.etbcod 
                  no-lock no-error.
        if not avail contacor
        then tt-contacor.numcor = tt-contacor.etbcod * 10000000.
        else tt-contacor.numcor = contacor.numcor + 1.

        tt-contacor.sitcor = "".
        tt-contacor.natcor = yes.
        tt-contacor.clifor = 0.
        tt-contacor.modcod = "LPP".

        if tt-contacor.campo1[1] <> 0 and
           tt-contacor.campo1[2] <> 0
        then do:
            create contacor.
            buffer-copy tt-contacor to contacor.
            delete tt-contacor.
        end.    
        end.
    end.
end procedure.

procedure altera:
    for each tt-contacor:
        delete tt-contacor.
    end.
    create tt-contacor.
    buffer-copy contacor to tt-contacor.
        
    def var dti-venda as date format "99/99/9999".
    def var dtf-venda as date format "99/99/9999".
    
    do on error undo, retry with frame f-linha:

        a-recid = recid(contacor).
        
        update contacor.campo1[1] 
               contacor.campo1[2] 
               .
                
        if  contacor.campo1[1] > 0 and
            contacor.campo1[2] > 0 and
            contacor.campo1[1] > tt-contacor.campo1[2] and
            tt-contacor.campo1[2] > ultimo-dia-mes
        then do:
            bell.
            message color red/with
            "Valores para Iicio e Fim incorretor."
            view-as alert-box. 
            undo.
        end.
    end.
end procedure.

procedure exclui:
        disp contacor.etbcod at 1 label "Filial"
               with frame f-exclui 1 down centered row 10 
               /*color message*/ side-label overlay
               title "    Excluir   ".
        if contacor.etbcod > 0
        then do:
        find bestab where bestab.etbcod = contacor.etbcod
                    no-lock.
        disp bestab.etbnom no-label with frame f-exclui.
        end.
        disp contacor.funcod at 1 label "Funcionario" 
                        with frame f-exclui.
        /*find func where func.etbcod = contacor.etbcod and
                        func.funcod = contacor.funcod
               no-lock.
        disp func.funnom no-label with frame f-exclui .
        */
        disp contacor.setcod at 1 label "Setor"with frame f-exclui.
        if contacor.setcod > 0
        then do:
            find setaut where setaut.setcod = contacor.setcod
                    no-lock.
            disp setaut.setnom no-label with frame f-exclui.
        end.
        disp contacor.datemi at 1 label "Data"  with frame f-exclui.
        disp contacor.datemi at 1 label "Data Inicio do pagamento"  
                format "99/99/9999"
                with frame f-exclui.
            
        disp contacor.datven at 1 label "Liberar Premios de"
                    format "99/99/9999"
             contacor.datpag      label "Ate"  format "99/99/9999"
                 with frame f-exclui. 

        def var dti-venda as date format "99/99/9999".
        def var dtf-venda as date format "99/99/9999".
        def var vmeta as log format "Sim/Nao".
        if  acha("VALIDAR-META",contacor.campo3[1]) = "SIM"
        then vmeta = yes.
        else vmeta = no.
        dti-venda = date(acha("DTI-VENDA",contacor.campo3[1])).
        dtf-venda = date(acha("DTF-VENDA",contacor.campo3[1])).
 
        disp vmeta at 1 label "Validar Meta?" with frame f-exclui.
        disp dti-venda at 1 label "Periodo de Venda de"
               dtf-venda label "Ate"
               with frame f-exclui.
 
        sresp = no.
        message "Confirma excluir registro ?" update sresp.
        if sresp
        then do transaction:
            contacor.sitcor = "EXC".
        end.
end procedure.
