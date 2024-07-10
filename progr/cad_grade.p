/*
*
*    grade.p    -    Esqueleto de Programacao    com esqvazio
*
*/
{admcab.i}

form
    gratam.tamcod
    gratam.graord
    with frame freee 12 down column 47 color white/red row 5.

form
    grafabri.fabcod
    with frame freee2 12 down column 59 color white/red row 5.

form
    graclasse.clacod column-label "Grupo"
    with frame freee3 12 down column 68 color white/red row 5.

def var recatu1         as recid.
def var recatu2         as recid.
def var reccont         as int.
def var esqpos1         as int.
def var esqpos2         as int.
def var esqregua        as log.
def var esqvazio        as log.
def var esqascend       as log initial yes.
def var esqcom1         as char format "x(12)" extent 5
    initial [" Inclusao "," Alteracao ",""," Situacao "," Listagem "].
def var esqcom2         as char format "x(12)" extent 5
    initial [" Tamanhos "," Grupos "," Fabricantes ","",""].
def var esqhel1         as char format "x(80)" extent 5
    initial [" Inclusao  de grade ",
             " Alteracao da grade ",
             "",
             "",
             ""].
def var esqhel2         as char format "x(12)" extent 5.

def buffer bgrade       for grade.

form
    esqcom1
    with frame f-com1
                 row 4 no-box no-labels side-labels column 1 centered.
form
    esqcom2
    with frame f-com2
                 row screen-lines no-box no-labels side-labels column 1
                 centered.
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
        find grade where recid(grade) = recatu1 no-lock.
    if not available grade
    then do.
        esqvazio = yes.
        if sretorno = "ZOOM"
        then do.
            message "Cadastro de grade Vazio" view-as alert-box.
            leave.
        end.
    end.
    else esqvazio = no.
    clear frame frame-a all no-pause.
    if not esqvazio
    then do:
        run frame-a.
    end.

    recatu1 = recid(grade).
    if esqregua
    then color display message esqcom1[esqpos1] with frame f-com1.
    else color display message esqcom2[esqpos2] with frame f-com2.
    if not esqvazio
    then repeat:
        run leitura (input "seg").
        if not available grade
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
            find grade where recid(grade) = recatu1 no-lock.

            clear frame freee  all no-pause.
            clear frame freee2 all no-pause.
            clear frame freee3 all no-pause.
            for each gratam of grade use-index graord no-lock.
                display gratam except gracod dtexp with frame freee.
                down with frame freee.                    
                pause 0.                    
            end.
            for each grafabri of grade no-lock.
                disp grafabri.fabcod with frame freee2.
                down with frame freee2.
            end.
            for each graclasse of grade no-lock.
                display graclasse.clacod with frame freee3.
                down with frame freee3.                    
                pause 0.
            end.

            if sretorno = "ZOOM" 
            then 
                assign esqcom1 = "" 
                       esqcom2 = ""
                       esqcom1[1] = " Seleciona ". 
            display esqcom1 with frame f-com1.
            display esqcom2 with frame f-com2.

            status default
                if esqregua
                then esqhel1[esqpos1] + if esqpos1 > 1 and
                                           esqhel1[esqpos1] <> ""
                                        then  string(grade.granom)
                                        else ""
                else esqhel2[esqpos2] + if esqhel2[esqpos2] <> ""
                                        then string(grade.granom)
                                        else "".
            run color-message.
            choose field grade.gracod help ""
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
                    if not avail grade
                    then leave.
                    recatu1 = recid(grade).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "page-up"
            then do:
                do reccont = 1 to frame-down(frame-a):
                    run leitura (input "up").
                    if not avail grade
                    then leave.
                    recatu1 = recid(grade).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "cursor-down"
            then do:
                run leitura (input "down").
                if not avail grade
                then next.
                color display white/red grade.gracod with frame frame-a.
                if frame-line(frame-a) = frame-down(frame-a)
                then scroll with frame frame-a.
                else down with frame frame-a.
            end.
            if keyfunction(lastkey) = "cursor-up"
            then do:
                run leitura (input "up").
                if not avail grade
                then next.
                color display white/red grade.gracod with frame frame-a.
                if frame-line(frame-a) = 1
                then scroll down with frame frame-a.
                else up with frame frame-a.
            end.
 
        if keyfunction(lastkey) = "end-error"
        then leave bl-princ.

        if keyfunction(lastkey) = "return" or esqvazio
        then do:
            form grade
                 with frame f-grade color black/cyan
                      centered side-label row 5 1 col.
            if esqregua
            then do:
                display caps(esqcom1[esqpos1]) @ esqcom1[esqpos1]
                        with frame f-com1.

                if esqcom1[esqpos1] = " Seleciona "
                then do with frame f-pv on error undo.
                    sretorno = string(grade.gracod).
                    leave bl-princ.
                end. 

                if esqcom1[esqpos1] = " Inclusao " or esqvazio
                then do with frame f-grade on error undo.
                    pause 0.
                    find last bgrade no-lock no-error.
                    create grade.
                    grade.gracod = if avail bgrade
                                then bgrade.gracod + 1
                                else 1.
                    disp grade.gracod.
                    UPDATE
                        grade.granom
                        grade.limtam 
                            validate(grade.limtam > 0 and grade.limtam <= 9,
                                         "Limite de 1 a 9").
                    grade.granom = caps(grade.granom).
                    grade.dtexp = today.
                    recatu1 = recid(grade).
                    leave.
                end.
                if esqcom1[esqpos1] = " Alteracao "
                then do with frame f-grade on error undo.
                    pause 0.
                    find grade where recid(grade) = recatu1 exclusive.
                    UPDATE grade.granom grade.limtam grade.situacao.
                    grade.granom = caps(grade.granom).
                    grade.dtexp = today.
                end.
                if esqcom1[esqpos1] = " Listagem "
                then do:
                    run listagem.
                    leave.
                end.
            end.
            else do:
                display caps(esqcom2[esqpos2]) @ esqcom2[esqpos2]
                        with frame f-com2.
                hide frame f-com1 no-pause.
                hide frame f-com2 no-pause.
                if esqcom2[esqpos2] = " Tamanhos " 
                then do .
                    run cad_gratam.p (input grade.gracod).  
                end.
                if esqcom2[esqpos2] = " Grupos " 
                then do .
                    hide frame frame-a no-pause.
                    run cad_graclasse.p (input recid(grade)).
                end.
                if esqcom2[esqpos2] = " Fabricantes " 
                then do .
                    hide frame frame-a no-pause.
                    run cad_grafabri.p (input recid(grade)).
                end.
                view frame f-com1.
                view frame f-com2.

                leave.
            end.
        end.
        if not esqvazio
        then do:
            run frame-a.
        end.
        if esqregua
        then display esqcom1[esqpos1] with frame f-com1.
        else display esqcom2[esqpos2] with frame f-com2.
        recatu1 = recid(grade).
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

procedure frame-a.

    display
        grade.gracod
        grade.granom format "x(30)"
        grade.limtam 
        grade.situacao column-label "Sit" format "Ati/Ina"
        with frame frame-a 12 down color white/red row 5.
end procedure.


procedure color-message.
color display message
        grade.gracod
        grade.granom
        grade.limtam
        grade.situacao
        with frame frame-a.
end procedure.


procedure color-normal.
color display normal
        grade.gracod
        grade.granom
        grade.limtam
        grade.situacao
        with frame frame-a.
end procedure.


procedure leitura . 
def input parameter par-tipo as char.
        
if par-tipo = "pri" 
then   find first grade where  if sretorno = "ZOOM" 
                               then grade.situacao
                               else true 
                                                no-lock no-error.
                                             
if par-tipo = "seg" or par-tipo = "down" 
then   find next grade  where if sretorno = "ZOOM" 
                               then grade.situacao
                               else true 
                                                no-lock no-error.
             
if par-tipo = "up" 
then   find prev grade where if sretorno = "ZOOM" 
                               then grade.situacao
                               else true 
                                        no-lock no-error.
        
end procedure.

procedure listagem.

    def var varquivo as char.
    def var vtamanho as char.

    varquivo = "/admcom/relat/cad_grade" + string(time).

    {mdad.i
        &Saida     = "value(varquivo)"
        &Page-Size = "0"
        &Cond-Var  = "96"
        &Page-Line = "0"
        &Nom-Rel   = ""cad_modpack""
        &Nom-Sis   = """SISTEMA DE ESTOQUE"""
        &Tit-Rel   = """GRADES DE TAMANHOS"""
        &Width     = "96"
        &Form      = "frame f-cabcab"}

    for each grade no-lock.

        vtamanho = "".
        for each gratam of grade no-lock break by gratam.graord.
            vtamanho = vtamanho + gratam.tamcod + " ".
        end.

        display
            grade.gracod
            grade.granom    format "x(20)"
            vtamanho column-label "Grade" format "x(35)"
            with frame f-rel2 down no-box width 136.

        put skip(1).
    end.

    output close.

    run visurel.p (input varquivo, input "").

end procedure.
         
