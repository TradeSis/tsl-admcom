/*
*
*    Esqueletao de Programacao
*
*/
{admcab.i}
{anset.i}.

def var recatu1         as recid.
def var recatu2         as recid.
def var esqpos1         as int.
def var esqpos2         as int.
def var esqregua        as log.
def var esqcom1         as char format "x(12)" extent 5
            initial ["Inclusao","Alteracao","Exclusao","Consulta","Listagem"].
def var esqcom2         as char format "x(12)" extent 5
            initial ["","","","",""].

def buffer wmenu       for menu.
def buffer bmenu       for menu.
def buffer badmaplic   for admaplic.
def var vsenha         as char .
def input parameter vaplicod     like menu.aplicod.
def input parameter vordsup     like menu.ordsup.
find aplicativo where aplicativo.aplicod = vaplicod.
wtitulo = fill(" ",40 - int(length(trim(aplinom)) / 2))
                    + trim(aplinom).
display wtitulo
    with frame fc2.

if search("F:\OPERADOR\GUAIBA.CHP") <> ?
then put screen "LIGACAO INTERROMPIDA!" row 23 column 60 color blink/red.

def buffer bfunc        for func.
def var vhora           as char.
def buffer bcorreio     for correio.
def var varqsai         as char.


def var v-down           as int.
def var v-down2          as int.
def var vl               as char.

form
    correio.funemi column-label "Emit"
        help "ENTER=Consulta  F4=Encerra  F8=Imprime"   
    bfunc.funape    format "x(18)" 
    correio.assunto format "x(29)"
    correio.dtmens
    vhora   column-label "Hora"
    correio.situacao column-label "S" format "x"
    with frame f-receb1
        centered
        down
        title " MENSAGENS RECEBIDAS ". 

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
    for each menu where menu.aplicod = vaplicod and
            not can-find(admaplic where admaplic.cliente = scliente and
                                        admaplic.aplicod = vaplicod and
                                        admaplic.menniv  = 1        and
                                        admaplic.ordsup  = 0        and
                                        admaplic.menord  = menu.menord) and
            menniv = 1:
        v-down = v-down + 1.
    end.
bl-princ:
repeat:

    if recatu1 = ?
    then
        find first menu where menu.aplicod = vaplicod and
            not can-find(admaplic where admaplic.cliente = scliente and
                                        admaplic.aplicod = vaplicod and
                                        admaplic.menniv  = 1        and
                                        admaplic.ordsup  = 0        and
                                        admaplic.menord  = menu.menord) and
            menniv = 1 no-error.
    else
        find menu where recid(menu) = recatu1.
    if not available menu
    then leave.
    clear frame frame-a all no-pause.
    display
        menu.mentit
            with frame frame-a v-down down no-labels
                color red/white  row 4
                    title color red/white aplicativo.aplinom.

    recatu1 = recid(menu).
    repeat:
        find next menu where menu.aplicod = vaplicod and
            not can-find(admaplic where admaplic.cliente = scliente and
                                        admaplic.aplicod = vaplicod and
                                        admaplic.menniv  = 1        and
                                        admaplic.ordsup  = 0        and
                                        admaplic.menord  = menu.menord) and
            menniv = 1 no-error.
        if not available menu
        then leave.
        if frame-line(frame-a) = frame-down(frame-a)
        then leave.
        down
            with frame frame-a.
        display
            menu.mentit
                with frame frame-a.
    end.
    up frame-line(frame-a) - 1 with frame frame-a.
    bl-1:
    repeat with frame frame-a:

        find menu where recid(menu) = recatu1.
        put screen row 24 column 1 string(menu.mensta,"x(80)")
            color black/cyan.
        choose field menu.mentit color message
            go-on(cursor-down cursor-up
                  cursor-left cursor-right PF5 F5
                  PF4 F4 P ESC return F8 PF8 F9 PF9 PF10 F10) auto-return.
    

        if keyfunction(lastkey) = "cursor-down"
        then do:
            find next menu where menu.aplicod = vaplicod and
                not can-find(admaplic where admaplic.cliente = scliente and
                                        admaplic.aplicod = vaplicod and
                                        admaplic.menniv  = 1        and
                                        admaplic.ordsup  = 0        and
                                        admaplic.menord  = menu.menord) and
                menniv = 1 no-error.
            if not avail menu
            then next.
            color display red/white
                menu.mentit.
            if frame-line(frame-a) = frame-down(frame-a)
            then scroll with frame frame-a.
            else down with frame frame-a.
        end.
        if keyfunction(lastkey) = "cursor-up"
        then do:
            find prev menu where menu.aplicod = vaplicod and
                not can-find(admaplic where admaplic.cliente = scliente and
                                        admaplic.aplicod = vaplicod and
                                        admaplic.menniv  = 1        and
                                        admaplic.ordsup  = 0        and
                                        admaplic.menord  = menu.menord) and
                menniv = 1 no-error.
            if not avail menu
            then next.
            color display red/white
                menu.mentit.
            if frame-line(frame-a) = 1
            then scroll down with frame frame-a.
            else up with frame frame-a.
        end.
        if keyfunction(lastkey) = "end-error" or
           keyfunction(lastkey) = "cursor-left"
        then leave bl-princ.

        if keyfunction(lastkey) = "return" or
           keyfunction(lastkey) = "cursor-right"
        then do on error undo, retry on endkey undo, leave.
            color display white/blue
                menu.mentit with frame frame-a.
            {logmeni.i}
            view frame fc1.
            wtitulo = fill(" ",40 - int(length(trim(aplinom)) / 2))
                    + trim(aplinom).
            display wtitulo
                with frame fc2.
            view frame fc2.

        end.     /*
        if keyfunction(lastkey) = "."
        then do ON ERROR UNDO:
            find badmaplic where badmaplic.cliente = scliente and
                                badmaplic.aplicod = vaplicod and
                                badmaplic.menniv  = 1        and
                                badmaplic.ordsup  = 0        and
                                badmaplic.menord  = menu.menord
                    no-error.
            if not available badmaplic
            then do:
                create badmaplic.
                assign
                    badmaplic.cliente = scliente
                    badmaplic.aplicod = vaplicod
                    badmaplic.menniv  = 1
                    badmaplic.ordsup  = 0
                    badmaplic.menord  = menu.menord.
            end.
            else do:
                delete badmaplic.
            end.
            leave.
        end.       */
        if keyfunction(lastkey) = "NEW-LINE"
        then do with frame insere0
                overlay side-label 1 column
                row 16 centered on endkey undo:
            if keyfunction(lastkey) = "END-ERROR"
            then do:
                hide frame insere0 no-pause.
                hide frame mensta0 no-pause.
                leave.
            end.
            create wmenu .
            update wmenu.mentit
                   wmenu.menpro
                   wmenu.menpar
                   wmenu.menare.
            update wmenu.mensta
                   with frame mensta0
                        no-box no-label centered overlay row 22 .
            assign wmenu.aplicod = menu.aplicod
                   wmenu.ordsup  = menu.ordsup
                   wmenu.menniv  = menu.menniv
                   wmenu.menord  = menu.menord + 1 .
            leave bl-1 .
        end.

        if keyfunction(lastkey) = "CLEAR"
        then do with frame altera0
                overlay side-label 1 column
                row 16 centered on endkey undo:
            if keyfunction(lastkey) = "END-ERROR"
            then do:
                hide frame altera0 no-pause.
                hide frame mensta10 no-pause.
                leave.
            end.
            update menu.mentit
                   menu.menpro
                   menu.menpar
                   menu.menare.
            update menu.mensta
                   with frame mensta10
                        no-box no-label centered overlay row 22 .
        end.

        if keyfunction(lastkey) = "DELETE-LINE"
        then do on endkey undo:
            update vsenha blank label "Senha"
                   with frame senha0 side-label
                        centered overlay color message .
            hide frame senha0 no-pause.
            if vsenha <> "admcom"
            then do:
                message "Senha Invalida".
                pause 2 no-message .
                leave bl-1.
            end.
            message "Confirma a exclusao do Nivel" update sresp.
            if sresp
            then do:
                delete menu.
                leave bl-1 .
            end.
        end.

        if keyfunction(lastkey) = "end-error"
        then view frame frame-a.
        display
                menu.mentit
                    with frame frame-a.
        recatu1 = recid(menu).
   end.
end.
