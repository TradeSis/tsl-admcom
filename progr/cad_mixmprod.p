/*
*
*    mixmprod.p    -    Esqueleto de Programacao    com esqvazio
*
*/
{admcab.i}

hide frame f-opcoes no-pause.
hide frame f-com2  no-pause.

def input parameter par-rec as recid.

find produ where recid(produ) = par-rec no-lock.

find mixmprod where mixmprod.procod = produ.procod no-lock no-error.
if avail mixmprod then do:
    find mixmgrupo of mixmprod no-lock.
    disp mixmprod.procod mixmprod.etbcod mixmprod.codgrupo mixmgrupo.nome mixmprod.estmin mixmprod.estmax.
end.
else do:
    message "Produto sem registro de mix!" view-as alert-box.
end.

/**
disp
    produ.procod format ">>>>>>9"
    produ.pronom no-label format "x(30)"
    produ.clacod
    with frame f-produ side-label no-box row 8.

def var recatu1         as recid.
def var reccont         as int.
def var esqpos1         as int.
def var esqvazio        as log.
def var esqcom1         as char format "x(12)" extent 5
    initial ["  ","  ","  "," "].

def buffer bmixmprod       for mixmprod.

form
    esqcom1
    with frame f-com1 row 9 no-box no-labels column 1 centered.

assign
    esqpos1  = 1.

bl-princ:
repeat:
    disp esqcom1 with frame f-com1.
    if recatu1 = ?
    then
        run leitura (input "pri").
    else
        find mixmprod where recid(mixmprod) = recatu1 no-lock.
    if not available mixmprod
    then esqvazio = yes.
    else esqvazio = no.
    clear frame frame-a all no-pause.
    if not esqvazio
    then do:
        run frame-a.
    end.

    recatu1 = recid(mixmprod).
    color display message esqcom1[esqpos1] with frame f-com1.
    if not esqvazio
    then repeat:
        run leitura (input "seg").
        if not available mixmprod
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
            find mixmprod where recid(mixmprod) = recatu1 no-lock.
/***
            if mixmprod.etbcod = 0
            then esqcom1[3] = "".
            else esqcom1[3] = " Situacao ".
            disp esqcom1 with frame f-com1.
***/
            status default "".

            color display message
                mixmprod.codgrupo
                mixmgrupo.nome
                mixmprod.etbcod
                estab.etbnom
                mixmprod.estmin
                mixmprod.estmax
                with frame frame-a.

            choose field mixmprod.codgrupo help ""
                go-on(cursor-down cursor-up
                      cursor-left cursor-right
                      page-down   page-up
                      PF4 F4 ESC return) .

            color display normal
                mixmprod.codgrupo
                mixmgrupo.nome
                mixmprod.etbcod
                estab.etbnom
                mixmprod.estmin
                mixmprod.estmax
                with frame frame-a.

            status default "".

        end.
            if keyfunction(lastkey) = "cursor-right"
            then do:
                    color display normal esqcom1[esqpos1] with frame f-com1.
                    esqpos1 = if esqpos1 = 5 then 5 else esqpos1 + 1.
                    color display messages esqcom1[esqpos1] with frame f-com1.
                next.
            end.
            if keyfunction(lastkey) = "cursor-left"
            then do:
                    color display normal esqcom1[esqpos1] with frame f-com1.
                    esqpos1 = if esqpos1 = 1 then 1 else esqpos1 - 1.
                    color display messages esqcom1[esqpos1] with frame f-com1.
                next.
            end.
            if keyfunction(lastkey) = "page-down"
            then do:
                do reccont = 1 to frame-down(frame-a):
                    run leitura (input "down").
                    if not avail mixmprod
                    then leave.
                    recatu1 = recid(mixmprod).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "page-up"
            then do:
                do reccont = 1 to frame-down(frame-a):
                    run leitura (input "up").
                    if not avail mixmprod
                    then leave.
                    recatu1 = recid(mixmprod).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "cursor-down"
            then do:
                run leitura (input "down").
                if not avail mixmprod
                then next.
                color display white/red mixmprod.codgrupo with frame frame-a.
                if frame-line(frame-a) = frame-down(frame-a)
                then scroll with frame frame-a.
                else down with frame frame-a.
            end.
            if keyfunction(lastkey) = "cursor-up"
            then do:
                run leitura (input "up").
                if not avail mixmprod
                then next.
                color display white/red mixmprod.codgrupo with frame frame-a.
                if frame-line(frame-a) = 1
                then scroll down with frame frame-a.
                else up with frame frame-a.
            end.
 
        if keyfunction(lastkey) = "end-error"
        then leave bl-princ.

        if keyfunction(lastkey) = "return" or esqvazio
        then do:
            hide frame frame-a no-pause.
                display caps(esqcom1[esqpos1]) @ esqcom1[esqpos1]
                        with frame f-com1.

                if esqcom1[esqpos1] = " Inclusao " or esqvazio
                then do.
                    run inclusao.
                    leave.
                end.
                if esqcom1[esqpos1] = " Alteracao "
                then do on error undo with frame frame-a.
                    find current mixmprod exclusive.
                    update mixmprod.estmin.
                    update mixmprod.estmax.
                end.
                if esqcom1[esqpos1] = " Situacao "
                then do on error undo.
                    sresp = no.
                    message "Confirma Alterar Situacao de" mixmprod.codgrupo "?"
                            update sresp.
                    if sresp
                    then do.
                        find current mixmprod exclusive.
                        mixmprod.situacao = not mixmprod.situacao.
                    end.
                    leave.
                end.

                if esqcom1[esqpos1] = " Listagem "
                then do with frame f-Lista:
                    leave.
                end.
        end.
        if not esqvazio
        then do:
            run frame-a.
        end.
        display esqcom1[esqpos1] with frame f-com1.
        recatu1 = recid(mixmprod).
    end.
    if keyfunction(lastkey) = "end-error"
    then do:
        view frame fc1.
        view frame fc2.
    end.
end.
hide frame f-com1  no-pause.
hide frame frame-a no-pause.
hide frame f-grupo no-pause.
**/

/**
procedure frame-a.

    def var vetbnom like estab.etbnom.

    find mixmgrupo of mixmprod no-lock.
    find estab of mixmprod no-lock no-error.

    if avail estab
    then vetbnom = estab.etbnom.
    else vetbnom = "Geral".

    display
        mixmprod.codgrupo
        mixmgrupo.nome         format "x(17)"
        mixmprod.etbcod
        vetbnom @ estab.etbnom format "x(17)"
        mixmprod.estmin
        mixmprod.estmax
        mixmprod.situacao
        with frame frame-a screen-lines - 15 down centered color white/red
            row 10 title " Mix de Moda do Produto ".
end procedure.


procedure leitura . 
def input parameter par-tipo as char.
        
if par-tipo = "pri" 
then find first mixmprod of produ no-lock no-error.
                                             
if par-tipo = "seg" or par-tipo = "down" 
then find next mixmprod  of produ no-lock no-error.
             
if par-tipo = "up" 
then find prev mixmprod of produ   no-lock no-error.
        
end procedure.

procedure inclusao.

    def var vok       as log.
    def var vcodgrupo like mixmprod.codgrupo.
    def var vetbcod   like mixmprod.etbcod.

    def buffer depto   for clase.
    def buffer setor   for clase.
    def buffer grupo   for clase.
    def buffer classe  for clase.
    def buffer sclasse for clase.

    do on error undo with frame f-inclusao side-label centered
        title " Inclusao de Mix de Moda ".

        assign
            vcodgrupo = 0
            vetbcod   = 0.

       /* update vcodgrupo colon 15.*/
        find mixmgrupo where mixmgrupo.codgrupo = vcodgrupo no-lock no-error.
        if not avail mixmgrupo or mixmgrupo.situacao = no
        then do.
            message "Grupo invalido" view-as alert-box.
            undo.
        end.
        disp mixmgrupo.nome no-label.

        /* validacao das classes do grupo */
        find first mixmgrucla of mixmgrupo where mixmgrucla.situacao
                no-lock no-error.
        if avail mixmgrucla
        then do.
            find sClasse where sClasse.clacod = produ.clacod no-lock.
            find Classe  where Classe.clacod = sClasse.clasup no-lock.
            find grupo   where grupo.clacod = Classe.clasup no-lock.
            find setor   where setor.clacod = grupo.clasup no-lock.
            find depto   where depto.clacod = setor.clasup no-lock.

            vok = no.
            for each mixmgrucla of mixmgrupo where mixmgrucla.situacao no-lock.
                if sclasse.clacod = mixmgrucla.clacod or
                   Classe.clacod  = mixmgrucla.clacod or
                   grupo.clacod   = mixmgrucla.clacod or
                   setor.clacod   = mixmgrucla.clacod or
                   depto.clacod   = mixmgrucla.clacod
                then do.
                    vok = yes.
                    leave.
                end.
            end.
            if not vok
            then do.
                message "Grupo de Mix invalido para a classe do produto"
                        view-as alert-box.
                undo.
            end.
        end.

        find first bmixmprod of produ
                             where bmixmprod.codgrupo = vcodgrupo
                               and bmixmprod.situacao no-lock no-error.
        if avail bmixmprod
        then do on error undo.
            update vetbcod colon 15.
            find estab where estab.etbcod = vetbcod no-lock no-error.
            if not avail estab
            then do.
                message "Estab.invalido" view-as alert-box.
                undo.
            end.
            disp estab.etbnom no-label.

            find bmixmprod of produ
                           where bmixmprod.codgrupo = vcodgrupo
                             and bmixmprod.etbcod   = vetbcod
                           no-lock no-error.
            if avail bmixmprod
            then do.
                message "Mix ja cadastrado" view-as alert-box.
                undo.
            end.

            find mixmgruetb where mixmgruetb.codgrupo = vcodgrupo
                              and mixmgruetb.etbcod   = vetbcod
                            no-lock no-error.
            if not avail mixmgruetb or mixmgruetb.situacao = no
            then do.
                message "Estab.invalido para o grupo" view-as alert-box.
                undo.
            end.
        end.

        create mixmprod.
        assign
             mixmprod.procod   = produ.procod
             mixmprod.etbcod   = vetbcod
             mixmprod.codgrupo = vcodgrupo.
        update mixmprod.estmin colon 15.
        update mixmprod.estmax colon 15.

        recatu1 = recid(mixmprod).
    end.

end procedure.
**/