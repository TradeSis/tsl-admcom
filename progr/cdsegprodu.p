/*
*
*    segprodu.p    -    Esqueleto de Programacao    com esqvazio
*
Out/17 - Projeto Garantia/RFQ
*/
{admcab.i}

def var vtempogar as int.

def var recatu1         as recid.
def var recatu2         as recid.
def var reccont         as int.
def var esqpos1         as int.
def var esqpos2         as int.
def var esqregua        as log.
def var esqvazio        as log.
def var esqascend       as log initial yes.
def var esqcom1         as char format "x(12)" extent 5
    initial [" Inclusao "," Pesquisa "," Consulta "," "," "].
def var esqcom2         as char format "x(12)" extent 5.
def var esqhel1         as char format "x(80)" extent 5.
def var esqhel2         as char format "x(12)" extent 5.

def buffer bsegprodu       for segprodu.

form
    esqcom1
    with frame f-com1 row 4 no-box no-labels column 1 centered.
form
    esqcom2
    with frame f-com2 row screen-lines no-box no-labels column 1 centered.
assign
    esqregua = yes
    esqpos1  = 1
    esqpos2  = 1.

bl-princ:
repeat:
    disp esqcom1 with frame f-com1.
    disp esqcom2 with frame f-com2.
    if recatu1 = ?
    then run leitura (input "pri").
    else find segprodu where recid(segprodu) = recatu1 no-lock.
    if not available segprodu
    then do.
        message "Sem registros" view-as alert-box.
        leave.
    end.
    else esqvazio = no.
    clear frame frame-a all no-pause.
    if not esqvazio
    then run frame-a.

    recatu1 = recid(segprodu).
    if esqregua
    then color display message esqcom1[esqpos1] with frame f-com1.
    else color display message esqcom2[esqpos2] with frame f-com2.
    if not esqvazio
    then repeat:
        run leitura (input "seg").
        if not available segprodu
        then leave.
        if frame-line(frame-a) = frame-down(frame-a)
        then leave.
        down with frame frame-a.
        run frame-a.
    end.
    if not esqvazio
    then up frame-line(frame-a) - 1 with frame frame-a.

    repeat with frame frame-a:

        if not esqvazio
        then do:
            find segprodu where recid(segprodu) = recatu1 no-lock.

            status default
                if esqregua
                then esqhel1[esqpos1] + if esqpos1 > 1 and
                                           esqhel1[esqpos1] <> ""
                                        then  string(segprodu.procod)
                                        else ""
                else esqhel2[esqpos2] + if esqhel2[esqpos2] <> ""
                                        then string(segprodu.procod)
                                        else "".
            run color-message.
            choose field segprodu.procod help ""
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
                    if not avail segprodu
                    then leave.
                    recatu1 = recid(segprodu).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "page-up"
            then do:
                do reccont = 1 to frame-down(frame-a):
                    run leitura (input "up").
                    if not avail segprodu
                    then leave.
                    recatu1 = recid(segprodu).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "cursor-down"
            then do:
                run leitura (input "down").
                if not avail segprodu
                then next.
                color display white/red segprodu.procod with frame frame-a.
                if frame-line(frame-a) = frame-down(frame-a)
                then scroll with frame frame-a.
                else down with frame frame-a.
            end.
            if keyfunction(lastkey) = "cursor-up"
            then do:
                run leitura (input "up").
                if not avail segprodu
                then next.
                color display white/red segprodu.procod with frame frame-a.
                if frame-line(frame-a) = 1
                then scroll down with frame frame-a.
                else up with frame frame-a.
            end.
 
        if keyfunction(lastkey) = "end-error"
        then leave bl-princ.

        if keyfunction(lastkey) = "return" or esqvazio
        then do:
            form segprodu.procod colon 15
                 produ.pronom no-label
                 segprodu.tpseguro  colon 15
                 segtipo.descricao no-label
                 segprodu.meses colon 15
                                validate (segprodu.meses > 0, "")
                 segprodu.ramo  colon 45
                                validate (segprodu.ramo = 710 or
                                          segprodu.ramo = 810, "")
                          help "710 = Garantia   810 = RFQ"
                 segprodu.subtipo   colon 15
                                    validate (segprodu.subtipo = "R" or
                                              segprodu.subtipo = "Y" or
                                              segprodu.subtipo = "F", "")
                                    help "Valores validos = R/Y/F"
                 segprodu.padrao    colon 45
                 segprodu.dtivig    colon 15
                 segprodu.dtfvig    colon 45
                 segprodu.percvenda colon 15
                 segprodu.perccusto colon 45
                 segprodu.dtinclu   colon 15
                 segprodu.datexp    colon 45
                 segprodu.dtintegra colon 15
                 with frame f-segprodu color black/cyan
                      centered side-label row 5.
            hide frame frame-a no-pause.
            if esqregua
            then do:
                display caps(esqcom1[esqpos1]) @ esqcom1[esqpos1]
                        with frame f-com1.
                if (esqcom1[esqpos1] = " Inclusao " or esqvazio) 
                then do.
                    run inclusao.
                    leave.
                end.
                if esqcom1[esqpos1] = " Consulta " or
                   esqcom1[esqpos1] = " Exclusao " or
                   esqcom1[esqpos1] = " Alteracao "
                then do with frame f-segprodu.
                    find produ of segprodu no-lock.

                    find segtipo of segprodu no-lock.
                    find first produaux where produaux.procod = segprodu.procod
                                          and produaux.Nome_Campo = "TempoGar"
                               no-lock no-error.
                    if avail produaux
                    then vtempogar = int(produaux.valor_campo).
                    
                    disp segprodu.
                    disp produ.pronom
                         segtipo.descricao.
                end.
/*
                if esqcom1[esqpos1] = " Alteracao "
                then do with frame f-segprodu on error undo.
                    find segprodu where recid(segprodu) = recatu1 exclusive.
                    update segprodu.dtfvig.
                end.
***/
                if esqcom1[esqpos1] = " Exclusao "
                then do on error undo.
                    message "Confirma Fim de Vigencia de" segprodu.procod
                            update sresp.
                    if not sresp
                    then undo, leave.
                    find segprodu where recid(segprodu) = recatu1 exclusive.
                    assign
                        segprodu.dtfvig = today
                        segprodu.datexp = today.
                    recatu1 = recatu2.
                    leave.
                end.
                if esqcom1[esqpos1] = " Pesquisa "
                then do with frame f-pesq with side-label:
                    prompt-for segprodu.procod.
                    find first bsegprodu
                                 where bsegprodu.procod = input segprodu.procod
                                 no-lock no-error. 
                    if avail bsegprodu
                    then recatu1 = recid(bsegprodu).
                    leave.
                end.
            end.
            else do:
                display caps(esqcom2[esqpos2]) @ esqcom2[esqpos2]
                        with frame f-com2.
                if esqcom2[esqpos2] = "  "
                then do:
                    hide frame f-com1  no-pause.
                    hide frame f-com2  no-pause.
                    /* run programa de relacionamento.p (input ). */
                    view frame f-com1.
                    view frame f-com2.
                end.
                leave.
            end.
        end.
        if not esqvazio
        then run frame-a.
        if esqregua
        then display esqcom1[esqpos1] with frame f-com1.
        else display esqcom2[esqpos2] with frame f-com2.
        recatu1 = recid(segprodu).
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
    def var vtempogar as int.

    find produ of segprodu no-lock.
    find segtipo of segprodu no-lock.
    find first produaux where produaux.procod     = segprodu.procod
                          and produaux.Nome_Campo = "TempoGar"
                        no-lock no-error.
    if avail produaux
    then vtempogar = int(produaux.valor_campo).

    display
        segprodu.procod
        produ.pronom format "x(25)"
        vtempogar column-label "Gar!Fab" format ">9"
        segtipo.sigla
        segprodu.subtipo
        segprodu.meses
        segprodu.dtfvig
        segprodu.percvenda
        segprodu.padrao
        with frame frame-a 11 down centered color white/red row 5.
end procedure.


procedure color-message.
    color display message
        segprodu.procod
        segtipo.sigla
        segprodu.subtipo
        segprodu.meses
        with frame frame-a.
end procedure.


procedure color-normal.
    color display normal
        segprodu.procod
        segtipo.sigla
        segprodu.subtipo
        segprodu.meses
        with frame frame-a.
end procedure.


procedure leitura.
def input parameter par-tipo as char.

if par-tipo = "pri" 
then  
    if esqascend  
    then find first segprodu where true no-lock no-error.
    else find last segprodu  where true no-lock no-error.
                                             
if par-tipo = "seg" or par-tipo = "down" 
then  
    if esqascend  
    then find next segprodu  where true no-lock no-error.
    else find prev segprodu  where true no-lock no-error.
             
if par-tipo = "up" 
then                  
    if esqascend   
    then find prev segprodu where true  no-lock no-error.
    else find next segprodu where true  no-lock no-error.

end procedure.


procedure inclusao.

    def var verro as char.

    do with frame f-segprodu on error undo.
        verro = "".
        prompt-for segprodu.procod.
        find produ where produ.procod = input segprodu.procod no-lock no-error.
        if not avail produ
        then do.
            message "Produto nao cadastrado" view-as alert-box.
            next.
        end.
        disp produ.pronom.
        if produ.catcod <> 31
        then verro = "Categoria diferente de 31".
        else if produ.proipiper = 98
        then verro = "Produto nao e de venda".
        if verro <> ""
        then do.
            message verro view-as alert-box.
            next.
        end.

        find first produaux where produaux.procod     = segprodu.procod
                              and produaux.Nome_Campo = "TempoGar"
                            no-lock no-error.
        if avail produaux
        then vtempogar = int(produaux.valor_campo).

        prompt-for segprodu.tpseguro.
        find segtipo where segtipo.tpseguro = input segprodu.tpseguro
                     no-lock no-error.
        if not avail segtipo or
           segtipo.ramo = 0
        then do.
            message "Tipo de Seguro invalido" view-as alert-box.
            next.
        end.
        disp segtipo.descricao
             segtipo.ramo @ segprodu.ramo.
            
        create segprodu.
        assign
            segprodu.procod   = input segprodu.procod
            segprodu.tpseguro = input segprodu.tpseguro
            segprodu.ramo     = segtipo.ramo.

        update
            segprodu.meses
            segprodu.subtipo
            segprodu.padrao
            segprodu.dtivig.

        recatu1 = recid(segprodu).
    end.

end procedure.
