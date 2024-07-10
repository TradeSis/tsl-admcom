{admcab.i}                                      
{setbrw.i}                                                                      

def var vetbcod like estab.etbcod.
def var vclicod like clien.clicod.
def var vdti as date.
def var vdtf as date.
def var recatu1         as recid.
def var recatu2         as recid.
def var reccont         as int.
def var esqpos1         as int.
def var esqpos2         as int.
def var esqregua        as log.
def var esqvazio        as log.
def var esqascend     as log initial yes.
def var esqcom1         as char format "x(15)" extent 5
    initial ["","  Filtro"," Inclusao"," "," "].
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

def new shared  temp-table tt-intven
    field etbcod like estab.etbcod
    field clacod like clase.clacod
    field clicod like clien.clicod
    field peddat like pedid.peddat
    field peddti like pedid.peddti
    field qtdint like liped.lipqtd
    field vencod like pedid.vencod
    index i1 etbcod clacod clicod peddti. 
    
def new shared temp-table tt-intaux
    field etbcod like estab.etbcod
    field clacod like clase.clacod
    field clicod like clien.clicod
    field peddat like pedid.peddat
    field peddti like pedid.peddti
    field qtdint like liped.lipqtd
    field vencod like pedid.vencod
    .

def temp-table tt-aux
    field etbcod like estab.etbcod
    field clacod like clase.clacod
    field clicod like clien.clicod
    field peddat like pedid.peddat
    field peddti like pedid.peddti
    field qtdint like liped.lipqtd
    field vencod like pedid.vencod.

form vetbcod label   "Cod.Filial"
     estab.etbnom no-label
     vclicod label   "Cliente" format ">>>>>>>>>9"
     clien.clinom
     vdti at 1 label "Periodo de"
     vdtf      label "Ate"
     with frame f-c 1 down width 80 side-label.

do on error undo, retry with frame f-c side-labels width 78:

    assign vetbcod = 0.
    update vetbcod.
    if vetbcod > 0
    then do:
        find estab where estab.etbcod = vetbcod no-lock no-error.
        if avail estab then disp estab.etbnom format "x(40)" no-label 
        with frame f-c.
        else do:
            message "Filial Inexistente" view-as alert-box.
            undo, retry.
        end.
    end.
    else disp "Geral" @ estab.etbnom format "x(40)" skip with frame f-c.

    assign vclicod = 0.
    update vclicod.
    if vclicod > 0
    then do:
        find clien where clien.clicod = vclicod no-lock no-error.
        if avail clien then disp clien.clinom no-label with frame f-c.
        else do:
            message "Cliente Inexistente" view-as alert-box.
            undo, retry.
        end.
    end.
    else disp "Todos" @ clien.clinom.

     update vdti vdtf.
    if vdti > vdtf
    then undo.    
end.

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

form tt-intaux.etbcod column-label "Fil" format ">>9"
     tt-intaux.clicod column-label "Conta" format ">>>>>>>>>9"
     clien.clinom column-label "Nome" format "x(14)"
     tt-intaux.peddti column-label "Dat.Int" format "99/99/99"
     clase.clanom no-label format "x(11)"
     tt-intaux.vencod column-label "Vend." format ">>>>9"
     clien.fone column-label "Fone" format "x(10)" 
     clien.fax  column-label "Celular" format "x(10)"
     with frame f-linha 10 down color with/cyan /*no-box*/
     width 80.
                                                                         
                             
def var vtit-cab as char.
vtit-cab = "  INTENCAO DE COMPRA ".
if vetbcod > 0
then vtit-cab = vtit-cab + "   Filial: " + string(vetbcod,">>9").
vtit-cab = vtit-cab + "  Periodo de: " + string(vdti,"99/99/9999") +
            " Ate: " + string(vdtf,"99/99/9999").
disp vtit-cab format "x(70)"
            with frame f1 1 down width 80                                       
            color message no-box no-label row 4.
                                                  
disp " " with frame f2 1 down width 80 color message no-box no-label            
    row 20.                                                                     

def var i as int.
def buffer bestab for estab.
for each bestab where (if vetbcod > 0
    then bestab.etbcod = vetbcod else true) no-lock:
    for each pedid where pedid.pedtdc = 21 and
                         pedid.etbcod = bestab.etbcod and
                         pedid.peddat >= vdti and
                         pedid.peddat <= vdtf
                         no-lock:
        for each liped of pedid no-lock:
            find first tt-intven where
                       tt-intven.etbcod = pedid.etbcod and
                       tt-intven.clacod = liped.procod and
                       tt-intven.clicod = pedid.clfcod and
                       tt-intven.peddti = pedid.peddti
                       no-error.

            if vclicod <> 0 then if pedid.clfcod <> vclicod then next.
            if not avail tt-intven
            then do:
                create tt-intven.
                assign
                    tt-intven.etbcod = pedid.etbcod
                    tt-intven.clacod = liped.procod   
                    tt-intven.clicod = pedid.clfcod
                    tt-intven.peddti = pedid.peddti
                    tt-intven.vencod = pedid.vencod
                    .     
            end.
            assign
                tt-intven.peddat = pedid.peddat
                tt-intven.qtdint = tt-intven.qtdint + 1
                .
        end.
    end.                         
end.                         

def new shared var qtd-sel as int.
def new shared var qtd-tot as int.
def var f-etbcod like estab.etbcod.
def var f-clacod like clase.clacod.
def var f-clicod like clien.clicod.
def var f-dtinti as date.
def var f-dtintf as date.

f-etbcod = vetbcod.
 
for each tt-intven no-lock:
    create tt-intaux.
    buffer-copy tt-intven to tt-intaux. 
    qtd-sel = qtd-sel + 1.
    qtd-tot = qtd-tot + 1.
end.

l1: repeat:
    disp " Clientes Total = "  + string(qtd-tot) +
     "     Selecionados = " + string(qtd-sel)
     format "x(70)"
    with frame f2 1 down width 80 color message no-box no-label            
    row 20.    
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
        &file = tt-intaux  
        &cfield = tt-intaux.clicod
        &noncharacter = /* 
        &ofield = " clien.clinom  when avail clien
                    tt-intaux.etbcod
                    clase.clanom  when avail clase
                    tt-intaux.peddti
                    tt-intaux.vencod 
                    clien.fone when avail clien 
                    clien.fax when avail clien "  
        &aftfnd1 = "
            find clien where 
                    clien.clicod = tt-intaux.clicod no-lock no-error.
            find clase where clase.clacod = tt-intaux.clacod
                    no-lock no-error.
            "
        &where  = " true "
        &aftselect1 = " run aftselect.
                        if esqcom1[esqpos1] = ""  Filtro"" or
                            esqcom1[esqpos1] = "" Inclusao""
                        then do:
                            next l1.
                        end.
                        else next keys-loop.  "
        &go-on = TAB 
        &naoexiste1 = " bell.
                message color red/with
                    ""Nenhum Registro encontrato.""
                    view-as alert-box.
                    leave l1.
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
    if esqcom1[esqpos1] = "  Filtro"
    THEN DO on error undo, retry with frame f-filtro
                    1 down centered row 7 color message side-label
                    title "  Filtro  ":
        f-etbcod = vetbcod.
        update f-etbcod label "Cod.Filial" 
               f-clacod at 1 label "Cod.Classe"
               f-clicod at 1 label "Cod. Conta"
               f-dtinti at 1 label "Dat.Int de"
               f-dtintf label "Ate"
               .
        for each tt-aux:
               delete tt-aux.
        end.
        for each tt-intven no-lock:
            if f-etbcod > 0 and
               tt-intven.etbcod <> f-etbcod
            then next.    
            if f-clacod > 0 and
               tt-intven.clacod <> f-clacod 
            then next.   
            if f-clicod > 0 and
               tt-intven.clicod <> f-clicod 
            then next.
            if f-dtinti <> ? and
               f-dtinti <> ?
            then do:
                if tt-intven.peddti < f-dtinti or
                   tt-intven.peddti > f-dtintf
                then next.   
            end.
            else if f-dtinti <> ? and
                    tt-intven.peddti <> f-dtinti
                 then next.
            create tt-aux.
            buffer-copy tt-intven to tt-aux.
        end.
        find first tt-aux no-error.
        if not avail tt-aux
        then do:
            bell.
            message color red/with
                "Nenhum registro encontrado."
                view-as alert-box.
            undo, retry.    
        end.
        else do:
            for each tt-intaux:
                delete tt-intaux.
            end.
            qtd-sel = 0.
            for each tt-aux:
                create tt-intaux.
                buffer-copy tt-aux to tt-intaux.
                qtd-sel = qtd-sel + 1.
            end.    
        end.
    END.
    if esqcom1[esqpos1] = "  Consulta"
    THEN DO:
        run Consulta.
    END.
    
    if esqcom1[esqpos1] = " Inclusao"
    then do with frame f-inclui overlay row 6 4 column centered.

        run intcmp00.p.
        
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

procedure Consulta:


    for each tt-intaux no-lock:
        find clien where clien.clicod = tt-intaux.clicod no-lock.
        find clase where clase.clacod = tt-intaux.clacod no-lock.
        disp
            tt-intaux.etbcod column-label "Fil" format ">>9"
            tt-intaux.clicod column-label "Conta" format ">>>>>>>>9"
            clien.clinom column-label "Nome" format "x(20)"
            tt-intaux.peddti column-label "Dat.Int" format "99/99/9999"
            /*tt-intaux.clacod column-label "Classe" format ">>>>9"
            */
            clase.clanom no-label format "x(15)"
            tt-intaux.vencod column-label "Vend." format ">>>>9"
            clien.fone column-label "Fone" format "x(10)"
            clien.fax  column-label "Celular" format "x(10)"
            with frame f-imp down width 80.
        down with frame f-imp. 
    end.
    

end procedure.


