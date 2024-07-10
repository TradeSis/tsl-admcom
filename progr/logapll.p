/*
*
*    Esqueletao de Programacao
*
*/

/*----------------------------------------------------------------------------*/
def var vsenha like func.senha.
def var vpropath        as char format "x(150)".
def var vtprnom         as char. /* like tippro.tprnom.   */
input from ../propath no-echo.  /* Seta Propath */
set vpropath with width 200 no-box frame ff.
input close.
propath = vpropath + ",\dlc".
{../progr/admcab.i new}

def var funcao          as char.
def var parametro       as char.
def var v-ok            as log.
def var vok             as log.

input from ../work/admcom.ini no-echo.
repeat:
    set funcao parametro.
    if funcao = "ESTAB"
    then setbcod = int(parametro).
    if funcao = "CAIXA"
    then scxacod = int(parametro).
    if funcao = "CLIEN"
    then scliente = parametro.
    if funcao = "RAMO"
    then stprcod = int(parametro).
    else stprcod = ?.
end.

input close.
find admcom where admcom.cliente = scliente.
wdata = today.

on F5 help.
on PF5 help.
on PF7 help.
on F7 help.
on f6 help.
on PF6 help.
def var vfuncod like func.funcod.

do on error undo, return on endkey undo, retry:
    vsenha = "".
    update vfuncod label "Matricula"
           vsenha blank with frame f-senh side-label centered row 10.
    if vfuncod = 0 and
       vsenha  = ""
    then quit.
    find first func where func.funcod = vfuncod and
                          func.etbcod = 999      and
                          func.senha  = vsenha no-lock no-error.
    if not avail func
    then do:
        message "Funcionario Invalido.".
        undo, retry.
    end.
    else sfuncod = func.funcod.
end.

     /*
find tippro where tippro.tprcod = stprcod no-lock no-error.
if avail tippro
then vtprnom = tippro.tprnom.
else vtprnom = "CONFEC/MOVEIS".  */
find estab where estab.etbcod = setbcod no-lock.
find first wempre no-lock.
display trim(caps(wempre.emprazsoc)) + " / " + trim(caps(estab.etbnom))
 + "-" + trim(func.funnom)
 
 /* +
                    " /CAIXA - " + string(scxacod) +
                    " " + string(vtprnom,"x(18)") */ @  wempre.emprazsoc
                    wdata with frame fc1.

ytit = fill(" ",integer((30 - length(wtittela)) / 2)) + wtittela.

/*-----  R1 - Pede a Identificacao do Caixa  -----------------

repeat with frame f1 row 20 col 56 side-labels overlay
            on endkey undo, retry.
    display scxacod @ caixa.cxacod.
    prompt-for caixa.cxacod.
    find first caixa using caixa.cxacod no-error.

    hide frame f1 no-pause.
    if  not available caixa then do:
        bell. bell.
        next.
    end.
    else do:
        scxacod = input caixa.cxacod.
        leave.
    end.

end.

-----  Fim do R1 -----------------------------------------*/

def var recatu1         as recid.
def var recatu2         as recid.
def var esqpos1         as int.
def var esqpos2         as int.
def var esqregua        as log.
def var esqcom1         as char format "x(12)" extent 5
            initial ["Inclusao","Alteracao","Exclusao","Consulta","Listagem"].
def var esqcom2         as char format "x(12)" extent 5
            initial ["","","","",""].


def buffer bAPLICATIVO       for APLICATIVO.

def var v-down           as int.

    form
        esqcom1
            with frame f-com1
                 row 3 no-box no-labels side-labels column 1.
    form
        esqcom2
            with frame f-com2
                 row screen-lines no-box no-labels side-labels column 1.
    esqregua  = yes.
    esqpos1  = 1.
    esqpos2  = 1.
    v-down = 0.
    for each aplicativo:
        v-down = v-down + 1.
    end.
bl-princ:
repeat:
display "" with frame ff1
            1 down centered no-labels
                color white/blue  row 4 width 60 no-box.
display "" with frame ff2
             1 down centered no-labels
                color white/blue  row 5 + v-down width 60 no-box.

    if recatu1 = ?
    then
        find first APLICATIVO  where true and
                   not can-find( aplifun where aplifun.funcod = func.funcod and
                                 aplifun.aplicod = aplicativo.aplicod) no-error.
    else find APLICATIVO where recid(APLICATIVO) = recatu1.
    if not available APLICATIVO
    then leave.
    clear frame frame-a all no-pause.
    display
        APLICATIVO.APLINOM at 20
            with frame frame-a v-down down centered no-labels
                color white/blue  row 5 width 60 no-box.

    recatu1 = recid(APLICATIVO).
    repeat:
        find next APLICATIVO  where true and
                   not can-find( aplifun where aplifun.funcod = func.funcod and
                       aplifun.aplicod = aplicativo.aplicod) no-error.
        if not available APLICATIVO
        then leave.
        if frame-line(frame-a) = frame-down(frame-a)
        then leave.
        down
            with frame frame-a.
        display
            APLICATIVO.APLINOM
                with frame frame-a.
    end.
    up frame-line(frame-a) - 1 with frame frame-a.

    repeat with frame frame-a:

        hide frame f-senha.
        find APLICATIVO where recid(APLICATIVO) = recatu1.
        put screen row 24 column 1 string(aplicativo.aplihel,"x(80)")
            color black/cyan.
        on F5 get.
        on f10 delete-line.
        choose field APLICATIVO.APLINOM color black/white
            go-on(cursor-down cursor-up
                  cursor-left cursor-right PF5 F5 PF10 F10
                  tab PF4 F4 ESC return).
        hide message no-pause.
        if keyfunction(lastkey) = "get"
        then do WITH FRAME F-F5 ROW 20 COLUMN 56 SIDE-LABEL overlay
                    on endkey undo, retry.
            disp setbcod @ estab.etbcod.
            prompt-for estab.etbcod.
            find estab using estab.etbcod no-error.
            hide frame f-f5 no-pause.
            if not avail estab
            then do:
                bell.
                next.
            end.
            setbcod = input estab.etbcod.
            disp trim(caps(wempre.emprazsoc)) + "/" +
                      trim(caps(estab.etbnom)) @ wempre.emprazsoc wdata
                      with frame fc1.
        end.
        on F5 help.
        hide message no-pause.
        if keyfunction(lastkey) = "cursor-down"
        then do:
            find next APLICATIVO  where true and
                   not can-find( aplifun where aplifun.funcod = func.funcod  and
                       aplifun.aplicod = aplicativo.aplicod) no-error.
            if not avail APLICATIVO
            then next.
            color display white/blue
                APLICATIVO.APLINOM.
            if frame-line(frame-a) = frame-down(frame-a)
            then scroll with frame frame-a.
            else down with frame frame-a.
        end.
        if keyfunction(lastkey) = "cursor-up"
        then do:
            find prev APLICATIVO  where true and
                   not can-find( aplifun where aplifun.funcod = func.funcod and
                       aplifun.aplicod = aplicativo.aplicod) no-error.
            if not avail APLICATIVO
            then next.
            color display white/blue
                APLICATIVO.APLINOM.
            if frame-line(frame-a) = 1
            then scroll down with frame frame-a.
            else up with frame frame-a.
        end.
        if keyfunction(lastkey) = "end-error"
        then do:
            quit.
        end.
        if keyfunction(lastkey) = "delete-line"
        then do:
            return.
        end.

        if keyfunction(lastkey) = "return" or
           keyfunction(lastkey) = "cursor-right"
        then do on error undo, retry on endkey undo, leave.
            v-ok = no.
            for each menu where menu.aplicod = aplicativo.aplicod and
                not can-find(admaplic
                        where admaplic.cliente = scliente and
                              admaplic.aplicod = aplicativo.aplicod and
                              admaplic.menniv  = 1        and
                              admaplic.ordsup  = 0        and
                              admaplic.menord  = menu.menord) and
                    menniv = 1:
                v-ok = yes.
                leave.
            end.
            if not v-ok
            then do:
                bell.
                message "MODULO NAO DISPONIVEL".
                next.
            end.
            hide frame ff1.
            hide frame ff2.
            hide frame f-senha.
            vok = yes.

            if aplicativo.aplicod = "labo"
            then do:
                vsenha = "".
                update vsenha blank with frame f-senha side-label overlay
                                    centered.
                if vsenha <> "senha"
                then do:
                    message "Senha Invalida".
                    undo, retry.
                end.
                /* run senha.p(output vok). */
            end.
            hide frame f-senha.
            if vok = yes
            then
            run logmenp.p( input aplicativo.aplicod,input 0).
            hide all no-pause.
            view frame ff1.
            view frame ff2.
            view frame fc1.
        end.
        if keyfunction(lastkey) = "end-error"
        then view frame frame-a.
        if keyfunction(lastkey) = "GET"
        then do with frame fs row 20 col 56 side-labels overlay
            on endkey undo, retry.
            display setbcod @ estab.etbcod.
            prompt-for estab.etbcod.
            find estab using estab.etbcod no-lock no-error.
            hide frame fs no-pause.
            if not available estab
            then do:
                bell. bell.
                next.
            end.
            setbcod = input estab.etbcod.
            display trim(caps(wempre.emprazsoc)) + "/" +
                        trim(caps(estab.etbnom)) @ wempre.emprazsoc
                    wdata with frame fc1.
        end.
        display
                APLICATIVO.APLINOM
                    with frame frame-a.
        recatu1 = recid(aplicativo).
   end.
end.
return.
 
