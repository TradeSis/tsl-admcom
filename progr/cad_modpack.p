/*
*
*   cad_modpack.p    -    Esqueleto de Programacao    com esqvazio
*
*/
{admcab.i}

def var vcores  like modpack.cores.
def var vgracod like modpack.gracod.
def var vtamanho as char.

def var recatu1         as recid.
def var recatu2         as recid.
def var reccont         as int.
def var esqpos1         as int.
def var esqpos2         as int.
def var esqregua        as log.
def var esqvazio        as log.
def var esqascend     as log initial yes.
def var esqcom1         as char format "x(12)" extent 5
    initial [" Inclusao"," Alteracao"," Situacao"," Exclusao"," Listagem"].
def var esqcom2         as char format "x(12)" extent 5
    initial [" Cores ","", " Importa ", "", ""].
def var esqhel1         as char format "x(80)" extent 5
    initial [" Inclusao de modelo de pack ",
             " Alteracao do modelo de pack ",
             " Situacao do modelo de pack ",
             " Exclusao do modelo de pack ",
             ""].
def var esqhel2         as char format "x(12)" extent 5.

def buffer bmodpack       for modpack.

form
    esqcom1
    with frame f-com1
                 row 4 no-box no-labels column 1 centered.
form
    esqcom2
    with frame f-com2
                 row screen-lines no-box no-labels column 1 centered.
assign
    esqregua = yes
    esqpos1  = 1
    esqpos2  = 1.

bl-princ:
repeat:
    disp esqcom1 with frame f-com1.
    disp esqcom2 with frame f-com2.
    if recatu1 = ?
    then
        run leitura (input "pri").
    else
        find modpack where recid(modpack) = recatu1 no-lock.
    if not available modpack
    then esqvazio = yes.
    else esqvazio = no.
    clear frame frame-a all no-pause.
    if not esqvazio
    then do:
        run frame-a.
    end.

    recatu1 = recid(modpack).
    if esqregua
    then color display message esqcom1[esqpos1] with frame f-com1.
    else color display message esqcom2[esqpos2] with frame f-com2.
    if not esqvazio
    then repeat:
        run leitura (input "seg").
        if not available modpack
        then leave.
        if frame-line(frame-a) = frame-down(frame-a)
        then leave.
        down
            with frame frame-a.
        run frame-a.
    end.
    if not esqvazio
    then up frame-line(frame-a) - 1 with frame frame-a.

    repeat with frame frame-a:

        if not esqvazio
        then do:
            find modpack where recid(modpack) = recatu1 no-lock.
            run cad_modpackcor.p (recid(modpack), "Consulta").
            find grade of modpack no-lock.
            vtamanho = "".
            for each gratam of grade no-lock.
                vtamanho = vtamanho + gratam.tamcod + " ".
            end.
            disp grade.gracod grade.granom  no-label
                 vtamanho format "x(45)" no-label
                 with frame f-sub row screen-lines - 1 side-label no-box.

            status default
                if esqregua
                then esqhel1[esqpos1] + if esqpos1 > 1 and
                                           esqhel1[esqpos1] <> ""
                                        then  string(modpack.modpnom)
                                        else ""
                else esqhel2[esqpos2] + if esqhel2[esqpos2] <> ""
                                        then string(modpack.modpnom)
                                        else "".
            run frame-a.
            run color-message.
            choose field modpack.modpcod help ""
                go-on(cursor-down cursor-up
                      cursor-left cursor-right
                      page-down   page-up
                      tab PF4 F4 ESC return).
            run color-normal.
            status default "".

        end.
            if keyfunction(lastkey) = "TAB"
            then do:
                if esqregua
                then do:
                    color display normal esqcom1[esqpos1] with frame f-com1.
                    color display message esqcom2[esqpos2] with frame f-com2.
                end.
                else do:
                    color display normal esqcom2[esqpos2] with frame f-com2.
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
            if keyfunction(lastkey) = "page-down"
            then do:
                do reccont = 1 to frame-down(frame-a):
                    run leitura (input "down").
                    if not avail modpack
                    then leave.
                    recatu1 = recid(modpack).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "page-up"
            then do:
                do reccont = 1 to frame-down(frame-a):
                    run leitura (input "up").
                    if not avail modpack
                    then leave.
                    recatu1 = recid(modpack).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "cursor-down"
            then do:
                run leitura (input "down").
                if not avail modpack
                then next.
                color display white/red modpack.modpcod with frame frame-a.
                if frame-line(frame-a) = frame-down(frame-a)
                then scroll with frame frame-a.
                else down with frame frame-a.
            end.
            if keyfunction(lastkey) = "cursor-up"
            then do:
                run leitura (input "up").
                if not avail modpack
                then next.
                color display white/red modpack.modpcod with frame frame-a.
                if frame-line(frame-a) = 1
                then scroll down with frame frame-a.
                else up with frame frame-a.
            end.
 
        if keyfunction(lastkey) = "end-error"
        then leave bl-princ.

        if keyfunction(lastkey) = "return" or esqvazio
        then do:
            if esqregua
            then do:
                display caps(esqcom1[esqpos1]) @ esqcom1[esqpos1]
                        with frame f-com1.

                if esqcom1[esqpos1] = " Inclusao " or esqvazio
                then do with frame f-modpack 1 col on error undo.
                    pause 0.
                    find last bmodpack where bmodpack.modpcod < 9999
                              no-lock no-error.
                    create modpack.
                    modpack.modpcod = if avail bmodpack
                                      then bmodpack.modpcod + 1 else 1.
                    update modpack.modpcod.
                    update modpack.modpnom.
                    update modpack.gracod.
                    find grade of modpack no-lock no-error.
                    if not avail grade or
                       grade.situacao = no
                    then do.
                        message "Grade invalida" view-as alert-box.
                        undo.
                    end.
                    disp grade.granom no-label.

                    update modpack.cores 
                    modpack.dtcad = today.
                    recatu1 = recid(modpack).
                    leave.
                end.
                if esqcom1[esqpos1] = " Alteracao "
                then do.
                    assign
                        vcores  = modpack.cores
                        vgracod = modpack.gracod.
                    do with frame frame-a on error undo.
                        find modpack where recid(modpack) = recatu1 exclusive.
                        update modpack.modpnom.

                        find first pack where pack.modpcod = modpack.modpcod
                                        no-lock no-error.
                        if not avail pack
                        then do.
                            update modpack.gracod.
                            find grade of modpack no-lock no-error.
                            if not avail grade or
                               grade.situacao = no
                            then do.
                                message "Grade invalida" view-as alert-box.
                                undo.
                            end.
                            disp grade.granom.

                            update modpack.cores.
                            if modpack.gracod <> vgracod or
                               modpack.cores < vcores
                            then do.
                                message "Alguns registros deste modelo serao"
                                        "apagados. Confirma?"
                                update sresp.
                                if not sresp
                                then undo.
                            end.

                            if modpack.gracod <> vgracod
                            then
                                for each modpackcortam of modpack.
                                    delete modpackcortam.
                                end.

                            if modpack.cores < vcores
                            then
                                for each modpackcor of modpack
                                          where modpackcor.cor > modpack.cores.
                                    for each modpackcortam of modpackcor.
                                        delete modpackcortam.
                                    end.
                                    delete modpackcor.
                                end.
                        end.
                    end.
                end.
                if esqcom1[esqpos1] = " Situacao "
                then do on error undo.
                    sresp = no.
                    message "Confirma alterar situacao de" modpack.modpnom "?"
                            update sresp.
                    if not sresp
                    then leave.
                    find modpack where recid(modpack) = recatu1 exclusive.
                    modpack.situacao = not modpack.situacao.
                    leave.
                end.

                if esqcom1[esqpos1] = " Exclusao "
                then do on error undo.
                    find first pack where pack.modpcod = modpack.modpcod
                                    no-lock no-error.
                    if avail pack
                    then do.
                        message "Modelo tem packs associados:" pack.paccod
                            view-as alert-box.
                        next.
                    end.
                    sresp = no.
                    message "Confirma Exclusao de" modpack.modpnom "?"
                            update sresp.
                    if not sresp
                    then leave.
                    find next modpack no-lock no-error.
                    if not available modpack
                    then do:
                        find modpack where recid(modpack) = recatu1 no-lock.
                        find prev modpack no-lock no-error.
                    end.
                    recatu2 = if available modpack
                              then recid(modpack)
                              else ?.
                    find modpack where recid(modpack) = recatu1 exclusive.
                    for each modpackcor of modpack.
                        delete modpackcor.
                    end.
                    for each modpackcortam of modpack.
                        delete modpackcortam.
                    end.
                    delete modpack.
                    recatu1 = recatu2.
                    leave.
                end.
                
                if esqcom1[esqpos1] = " Listagem "
                then do.
                    run relatorio.
                    leave.
                end.
            end.
            else do:
                display caps(esqcom2[esqpos2]) @ esqcom2[esqpos2]
                        with frame f-com2.
                if esqcom2[esqpos2] = " Cores "
                then do:
                    hide frame f-com1  no-pause.
                    hide frame f-com2  no-pause.
                    run cad_modpackcor.p (recid(modpack), "Altera").
                    view frame f-com1.
                    view frame f-com2.
                end.
                if esqcom2[esqpos2] = " Importa "
                then run importa.
                leave.
            end.
        end.
        if not esqvazio
        then run frame-a.
        if esqregua
        then display esqcom1[esqpos1] with frame f-com1.
        else display esqcom2[esqpos2] with frame f-com2.
        recatu1 = recid(modpack).
    end.
    if keyfunction(lastkey) = "end-error"
    then do:
        view frame fc1.
        view frame fc2.
    end.
end.
hide frame f-com1  no-pause.
hide frame f-com2  no-pause.
hide frame frame-a no-pause.
hide frame f-sub   no-pause.

procedure frame-a.

    find grade of modpack no-lock.
    display
        modpack.modpcod column-label "Mod."
        modpack.modpnom format "x(14)"
        modpack.gracod
        grade.granom    format "x(13)"
        modpack.cores
        modpack.situacao column-label "Sit" format "Ati/Ina"
        with frame frame-a screen-lines - 10 down color white/red row 5.
end procedure.

procedure color-message.
color display message
        modpack.modpcod
        modpack.modpnom
        modpack.gracod
        grade.granom
        modpack.cores
        modpack.situacao
        with frame frame-a.
end procedure.

procedure color-normal.
color display normal
        modpack.modpcod
        modpack.modpnom
        modpack.gracod
        grade.granom
        modpack.cores
        modpack.situacao
        with frame frame-a.
end procedure.


procedure leitura . 
def input parameter par-tipo as char.
        
if par-tipo = "pri" 
then  
    if esqascend
    then   find first modpack  no-lock no-error.
    else   find last modpack   no-lock no-error.
                                             
if par-tipo = "seg" or par-tipo = "down" 
then  
    if esqascend  
    then   find next modpack   no-lock no-error.
    else   find prev modpack   no-lock no-error.
             
if par-tipo = "up" 
then                  
    if esqascend   
    then    find prev modpack   no-lock no-error.
    else    find next modpack   no-lock no-error.
        
end procedure.

def temp-table tt-mod
    field modpcod as int
    field modpnom as char
    field gracod  as int
    field cores   as int

    field cor     as int
    field tam1    as int
    field tam2    as int
    field tam3    as int
    field tam4    as int
    field tam5    as int
    field tam6    as int
    field tam7    as int
    field tam8    as int
    field tam9    as int.

procedure importa.

    def var varquivo as char init "/admcom/import/Packs.csv".
    def var vct as int.

    pause 0.
    update varquivo label "Arquivo" format "x(30)" 
           "(maximo 9 tamanhos por grade)"
           with side-label.
    input from value(varquivo).
    repeat.
        create tt-mod.
        import delimiter ";" tt-mod .
    end.
    input close.

    for each tt-mod where modpcod > 0.
        disp tt-mod.modpcod.
        find modpack where modpack.modpcod = tt-mod.modpcod no-error.
        if not avail modpack
        then do.
            create modpack.
            modpack.modpcod = tt-mod.modpcod.

            for each modpackcor of modpack 
                                where modpackcor.cor > modpack.cores.
                for each modpackcortam of modpackcor.
                    delete modpackcortam.
                end.
                delete modpackcor.
            end.
        
        end.
        assign
            modpack.modpnom = tt-mod.modpnom
            modpack.gracod  = tt-mod.gracod
            modpack.cores   = tt-mod.cores
            modpack.dtcad   = today.

        find grade of modpack no-lock.
 
        create modpackcor.
        assign
            modpackcor.modpcod = tt-mod.modpcod
            modpackcor.cor     = tt-mod.cor.

        vct = 0.
        for each gratam of grade no-lock break by gratam.graord.
            create modpackcortam.
            assign
                modpackcortam.modpcod = tt-mod.modpcod
                modpackcortam.cor     = tt-mod.cor
                modpackcortam.tamcod  = gratam.tamcod.

            vct = vct + 1.
            if vct = 1
            then modpackcortam.qtde = tt-mod.tam1.
            else if vct = 2
            then modpackcortam.qtde = tt-mod.tam2.
            else if vct = 3
            then modpackcortam.qtde = tt-mod.tam3.
            else if vct = 4
            then modpackcortam.qtde = tt-mod.tam4.
            else if vct = 5
            then modpackcortam.qtde = tt-mod.tam5.
            else if vct = 6
            then modpackcortam.qtde = tt-mod.tam6.
            else if vct = 7
            then modpackcortam.qtde = tt-mod.tam7.
            else if vct = 8
            then modpackcortam.qtde = tt-mod.tam8.
            else if vct = 9
            then modpackcortam.qtde = tt-mod.tam9.
        end.
    end.

end procedure.


procedure relatorio.
    def var varquivo as char.

    varquivo = "/admcom/relat/cad_modpack" + string(time).

    {mdad.i
        &Saida     = "value(varquivo)"
        &Page-Size = "0"
        &Cond-Var  = "96"
        &Page-Line = "0"
        &Nom-Rel   = ""cad_modpack""
        &Nom-Sis   = """SISTEMA DE ESTOQUE"""
        &Tit-Rel   = """MODELOS DE PACKS"""
        &Width     = "96"
        &Form      = "frame f-cabcab"}
 

    for each modpack no-lock.
        find grade of modpack no-lock.

        for each modpackcor of modpack no-lock.
            vtamanho = "".
            for each gratam of grade no-lock break by gratam.graord.
                for each modpackcortam of modpackcor
                                   where modpackcortam.tamcod = gratam.tamcod
                            no-lock.
                    vtamanho = vtamanho + modpackcortam.tamcod + "=" +
                           string(modpackcortam.qtde) + "  ".
                end.
            end.

            display
                modpack.modpcod column-label "Mod."
                modpack.modpnom format "x(20)"
                modpack.gracod
                grade.granom    format "x(20)"
                modpackcor.cor
                vtamanho column-label "Grade" format "x(35)"
                with frame f-rel2 down no-box width 136.
        end.

        put skip(1).
    end.

    output close.

    run visurel.p (input varquivo, input "").

end procedure.
