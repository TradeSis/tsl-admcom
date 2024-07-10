/*
*
*    Esqueletao de Programacao
*
*/
def var vpro as char.
def buffer menu2 for menu.
    v-down2 = 0.
    for each menu2 where menu2.aplicod = vaplicod and
            not can-find(admaplic where admaplic.cliente = scliente and
                                        admaplic.aplicod = vaplicod and
                                        admaplic.menniv  = 2        and
                                        admaplic.ordsup  = menu.menord and
                                        admaplic.menord  = menu2.menord) and
            menu2.menniv = 2 and
            menu2.ordsup = menu.menord:
        v-down2 = v-down2 + 1.
    end.
recatu2 = ?.
wtitulo = fill(" ",42 - int(length(trim(wtitulo) + trim(mentit)) / 2))
                    + trim(wtitulo) + " - " + trim(mentit).
display  wtitulo
    with frame fc2.

if search("F:\OPERADOR\GUAIBA.CHP") <> ?
then put screen "LIGACAO INTERROMPIDA!" row 23 column 60 color blink/red.

procedure cnt-acesmenu:
    find acesmenu where 
         acesmenu.etbcod = setbcod and
         acesmenu.funcod = sfuncod and
         acesmenu.mencod = menu2.mencod
         no-error.
    if not avail acesmenu
    then do transaction:
        create acesmenu.
        
        assign
            acesmenu.etbcod = setbcod
            acesmenu.funcod = sfuncod
            acesmenu.mencod = menu2.mencod
            acesmenu.dtacesso = today
            acesmenu.hracesso = time
            .
    end.     
    else do transaction:
        assign
            acesmenu.dtacesso = today
            acesmenu.hracesso = time
            .

    end.
end procedure.


bl-2:
repeat:

    if recatu2 = ?
    then
        find first menu2 where menu2.aplicod = vaplicod and
            not can-find(admaplic where admaplic.cliente = scliente and
                                        admaplic.aplicod = vaplicod and
                                        admaplic.menniv  = 2        and
                                        admaplic.ordsup  = menu.menord and
                                        admaplic.menord  = menu2.menord) and
            menu2.menniv = 2 and
            menu2.ordsup = menu.menord
            no-error.
    else
        find menu2 where recid(menu2) = recatu2.
    if not available menu2
    then leave.
    clear frame frame-b all no-pause.
    display
        menu2.mentit
            with frame frame-b v-down2 down no-labels
                color red/white  row 4 column 42
                    title color red/white menu.mentit.

    recatu2 = recid(menu2).
    repeat:
        find next menu2 where menu2.aplicod = vaplicod and
            not can-find(admaplic where admaplic.cliente = scliente and
                                        admaplic.aplicod = vaplicod and
                                        admaplic.menniv  = 2        and
                                        admaplic.ordsup  = menu.menord and
                                        admaplic.menord  = menu2.menord) and
            menu2.menniv = 2 and
            menu2.ordsup = menu.menord
            no-error.
        if not available menu2
        then leave.
        if frame-line(frame-b) = frame-down(frame-b)
        then leave.
        down
            with frame frame-b.
        display
            menu2.mentit
                with frame frame-b.
    end.
    up frame-line(frame-b) - 1 with frame frame-b.

    repeat with frame frame-b:

        find menu2 where recid(menu2) = recatu2.
        put screen row 24 column 1 string(menu2.mensta,"x(80)")
            color black/cyan.
        choose field menu2.mentit color message
            go-on(cursor-down cursor-up
                  cursor-left cursor-right
                 PF4 F4 P ESC return I i F8 PF8 F9 PF9 PF10 F10) auto-return.
        if keyfunction(lastkey) = "P"
        then do:
            message menu2.aplicod "/" menu2.menpro.
            pause.
        end.
        if keyfunction(lastkey) = "cursor-down"
        then do:
            find next menu2 where menu2.aplicod = vaplicod and
                not can-find(admaplic where admaplic.cliente = scliente and
                                        admaplic.aplicod = vaplicod and
                                        admaplic.menniv  = 2        and
                                        admaplic.ordsup  = menu.menord and
                                        admaplic.menord  = menu2.menord) and
                menu2.menniv = 2 and
                menu2.ordsup = menu.menord
                    no-error.
            if not avail menu2
            then next.
            color display red/white
                menu2.mentit.
            if frame-line(frame-b) = frame-down(frame-b)
            then scroll with frame frame-b.
            else down with frame frame-b.
        end.
        if keyfunction(lastkey) = "cursor-up"
        then do:
            find prev menu2 where menu2.aplicod = vaplicod and
                not can-find(admaplic where admaplic.cliente = scliente and
                                        admaplic.aplicod = vaplicod and
                                        admaplic.menniv  = 2        and
                                        admaplic.ordsup  = menu.menord and
                                        admaplic.menord  = menu2.menord) and
                menu2.menniv = 2 and
                menu2.ordsup = menu.menord
                    no-error.
            if not avail menu2
            then next.
            color display red/white
                menu2.mentit.
            if frame-line(frame-b) = 1
            then scroll down with frame frame-b.
            else up with frame frame-b.
        end.
        if keyfunction(lastkey) = "end-error" or
           keyfunction(lastkey) = "cursor-left"
        then leave bl-2.

        if keyfunction(lastkey) = "return" or
           keyfunction(lastkey) = "cursor-right"
        then do on error undo, retry on endkey undo, leave.
                vpro = if menu2.menare = ""
                       then menu2.menpro + ".p"
                       else trim(menu2.menare) + "~/" + menu2.menpro + ".p".
                if search(vpro) = ?
                then DO:
                    bell.
                    message menu2.mentit "NAO DISPONIVEL".
                    PAUSE 4 NO-MESSAGE.
                    HIDE MESSAGE.
                    NEXT.
                END.
        wtitulo = fill(" ",42 - int(length(trim(wtitulo) +
                            trim(menu2.mentit)) / 2))
                    + trim(wtitulo) + " - " + trim(menu2.mentit).
        display  wtitulo
            with frame fc2.
                hide frame frame-a no-pause.
                hide frame frame-b no-pause.
                put screen row 24 column 1
                    fill(" ",80).
            /*  SPROGRAMA = MENU2.MENPRO.*/
                
                
                find first correio where correio.funcod = sfuncod and
                                     correio.situacao = "E"   and
                                     correio.etbcod = setbcod 
                                     no-lock no-error.
                if avail correio and sfuncod <> 999 
                then do:
                    bell. bell.
                    disp "                        " skip
                       "    VOCE TEM CORREIO    " skip
                       "                        "
                       with frame f-corr 1 down no-labels
                       color messages overlay centered row 10.
                    pause.
                    hide frame f-corr.
                    
                    sresp = no.
                    message "Consulta o Correio" update sresp.
                    if sresp = yes 
                    then do: 
                        assign an-seeid = -1 an-recid = -1 an-seerec = ?.
                        {anbrowse.i
                            &File   = correio
                            &CField = correio.funemi
                            &Ofield = " bfunc.funape correio.dtmens 
                                        vhora correio.assunto 
                                        correio.situacao "
                            &color  = "message"
                            &Where = "correio.funcod = sfuncod and
                                      correio.situacao <> ""o""  and
                                      correio.situacao <> ""x"" and
                                      correio.etbcod = setbcod  "   
                            &NonCharacter = /*          
                            &Aftfnd = "
                                 find first bfunc where 
                                      bfunc.funcod = correio.funemi no-lock.
                                 vhora = string(correio.hrmens,""hh:mm:ss"").  "
                            &AftSelect1 =  "    find first bcorreio where 
                                recid(bcorreio) = recid(correio).
                                bcorreio.situacao = ""L"". 
                                disp correio.mens[1] correio.mens[2]    
                                 correio.mens[3] correio.mens[4]
                                correio.mens[5] correio.mens[6] 
                                correio.mens[7] correio.mens[8]
                                correio.mens[9] correio.mens[10] 
                                correio.mens[11]  correio.mens[12] 
                                correio.mens[13] correio.mens[14] 
                                correio.mens[15]  with frame f-linha 
                                overlay row 5 no-labels 1 down centered
                                title ""MENSAGEM"" .  pause.
                                an-seeid = -1. clear frame f-linha all. 
                                hide frame f-linha. next keys-loop.  " 
                            &LockType = "no-lock" 
                            &Form = " frame f-receb1 "
                         }.
                    end.    
                end.  

                run cnt-acesmenu.
                 
                if menpar <> ""
                then
                    run value(vpro) (menu2.menpar).
                else
                    run value(vpro).
            /*  SPROGRAMA = "".*/
            hide all no-pause.
        wtitulo = fill(" ",42 - int(length(trim(aplinom) +
                trim(menu.mentit)) / 2))
                    + trim(aplinom) + " - " + trim(menu.mentit).
            display  wtitulo
                with frame fc2.
            view frame fc1.
            view frame fc2.
            view frame frame-a.
            color display white/blue
                menu.mentit with frame frame-a.
            view frame frame-b.
        end.

        if keyfunction(lastkey) = "i"
        then do with frame insere
                overlay side-label 1 column
                row 16 centered on endkey undo:
            if keyfunction(lastkey) = "END-ERROR"
            then do:
                hide frame insere no-pause.
                hide frame mensta no-pause.
                leave.
            end.
            create wmenu .
            update wmenu.mentit
                   wmenu.menpro
                   wmenu.menpar
                   wmenu.menare.
            update wmenu.mensta
                   with frame mensta
                        no-box no-label centered overlay row 22 .
            assign wmenu.aplicod = menu2.aplicod
                   wmenu.ordsup  = menu2.ordsup
                   wmenu.menniv  = menu2.menniv
                   wmenu.menord  = menu2.menord + 1 .
            leave bl-2 .
        end.

        if keyfunction(lastkey) = "CLEAR"
        then do with frame altera
                overlay side-label 1 column
                row 15 centered on endkey undo:
            if keyfunction(lastkey) = "END-ERROR"
            then do:
                hide frame altera no-pause.
                hide frame mensta1 no-pause.
                leave.
            end.
            update menu2.mentit
                   menu2.menpro
                   menu2.menpar
                   menu2.menare
                   menu2.ordsup
                   menu2.menord.
            update menu2.mensta
                   with frame mensta1
                        no-box no-label centered overlay row 22 .
        end.

        if keyfunction(lastkey) = "DELETE-LINE"
        then do on endkey undo:
            update vsenha blank label "Senha"
                   with frame senha side-label
                        centered overlay color message .
            hide frame senha no-pause.
            if vsenha <> "admcom"
            then do:
                message "Senha Invalida".
                pause 2 no-message .
                leave bl-2.
            end.
            message "Confirma a exclusao do Nivel" update sresp.
            if sresp
            then do:
                delete menu2.
                leave bl-2 .
            end.
        end.


        if keyfunction(lastkey) = "end-error"
        then view frame frame-b.
        display
                menu2.mentit
                    with frame frame-b.
        recatu2 = recid(menu2).
   end.
end.
hide frame frame-b no-pause.
