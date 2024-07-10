/** 16/05/2017 - #1 Projeto Moda no ecommerce */
{admcab.i}


def var vpack as int. /* #1 */
def var vbusca as char.
def var primeiro as log.
def buffer xprodistr for prodistr.
def var recatu1         as recid.
def var recatu2         as recid.
def var reccont         as int.
def var esqpos1         as int.
def var esqpos2         as int.
def var esqregua        as log.
def var esqvazio        as log.
def var esqascend     as log initial yes.
def var esqcom1         as char format "x(12)" extent 5
    initial [" Incluir "," Alterar "," Relatorio"," Historico "," Excluir"].
def var esqcom2         as char format "x(12)" extent 5
    init["","","",""," Parametros"].
def var esqhel1         as char format "x(80)" extent 5.
def var esqhel2         as char format "x(12)" extent 5.

def buffer bprodistr       for prodistr.
def var vprodistr         like prodistr.procod.


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

def var vtipo as log format "Automatica/Manual".
form   vtipo /*prodistr.tipo*/ column-label "Tipo"
        prodistr.etbabast     
        prodistr.etbabast column-label "Estab"
        prodistr.procod
        produ.pronom  
        prodistr.lipqtd   format ">>>>>9"
        prodistr.preqtent format ">>>>>9"
        prodistr.predt          column-label "DtInicio"
        prodistr.SimbEntregue   column-label "DtFim"
        with frame frame-a overlay.

def var p-procod like produ.procod.

bl-princ:
repeat:

    disp esqcom1 with frame f-com1.
    disp esqcom2 with frame f-com2.
    if recatu1 = ?
    then
        run leitura (input "pri").
    else
        find prodistr where recid(prodistr) = recatu1 no-lock.
    if not available prodistr
    then esqvazio = yes.
    else esqvazio = no.
    clear frame frame-a all no-pause.
    if not esqvazio
    then do:
        run frame-a.
    end.

    recatu1 = recid(prodistr).
    if esqregua
    then color display message esqcom1[esqpos1] with frame f-com1.
    else color display message esqcom2[esqpos2] with frame f-com2.
    if not esqvazio
    then repeat:
        run leitura (input "seg").
        if not available prodistr
        then leave.
        if frame-line(frame-a) = frame-down(frame-a)
        then leave.
        down
            with frame frame-a.
        run frame-a.
    end.
    if not esqvazio
    then up frame-line(frame-a) - 1 with frame frame-a.

    repeat with frame frame-a :

        if not esqvazio
        then do:
            find prodistr where recid(prodistr) = recatu1 no-lock.

            status default
                if esqregua
                then esqhel1[esqpos1] + if esqpos1 > 1 and
                                           esqhel1[esqpos1] <> ""
                                        then  string(prodistr.procod)
                                        else ""
                else esqhel2[esqpos2] + if esqhel2[esqpos2] <> ""
                                        then string(prodistr.procod)
                                        else "".

            choose field prodistr.procod help ""
                go-on(cursor-down cursor-up
                      cursor-left cursor-right
                      page-down   page-up 1 2 3 4 5 6 7 8 9 0 
                      F7 p P
                      tab PF4 F4 ESC return) .
                     
            if lastkey = keycode("p") or lastkey = keycode("P")
            then do on error undo:
                 pause 0.
                 update p-procod label "Produto" with frame f-b1 centered
                 side-label  color message row 9 overlay.
                 find first prodistr where prodistr.etbabast = 200 and
                                  prodistr.lipsit   = "A" and
                                  (prodistr.tipo   = "ECOM" or
                                   prodistr.tipo     = "ECMA") and
                                prodistr.procod = p-procod 
                      and prodistr.SimbEntregue > today
                           no-lock no-error.
                 if avail prodistr
                 then recatu1 = recid(prodistr). 
                 else do:
                    message color red/with
                     "Produto nao encontrato."
                     view-as alert-box.
                    recatu1 = ?.
                 end.
                 hide frame f-b1 no-pause.
                 p-procod = 0.
                 next bl-princ.
            end.

            if keyfunction(lastkey) = "1" or  
               keyfunction(lastkey) = "2" or  
               keyfunction(lastkey) = "3" or  
               keyfunction(lastkey) = "4" or  
               keyfunction(lastkey) = "5" or
               keyfunction(lastkey) = "6" or  
               keyfunction(lastkey) = "7" or  
               keyfunction(lastkey) = "8" or  
               keyfunction(lastkey) = "9" or  
               keyfunction(lastkey) = "0" or
               keyfunction(lastkey) = "P" or
               keyfunction(lastkey) = "p"
            then do with centered row 8 color message no-label
                                frame f-procura side-label overlay:
                if keyfunction(lastkey) <> "HELP" and
                   keyfunction(lastkey) <> "P" and
                   keyfunction(lastkey) <> "p"
                then assign
                        vbusca = keyfunction(lastkey)
                        primeiro = yes.
                pause 0.
                update vbusca
                    editing:
                        if primeiro
                        then do:
                            apply keycode("cursor-right").
                            primeiro = no.
                        end.
                    readkey.
                    apply lastkey.
                    end.
                do on error undo with frame f-procura.
                    find first
                         xprodistr where xprodistr.procod   >= int(vbusca)  and
                                         xprodistr.etbabast  = 200          and
                                         (xprodistr.tipo     = "ECOM" or
                                          xprodistr.tipo     = "ECMA")
                                    no-lock no-error.
                    if avail xprodistr
                    then recatu1 = recid(xprodistr).
                    else recatu1 = recatu2.
                end.
                next bl-princ.
            end.

            
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
                    if not avail prodistr
                    then leave.
                    recatu1 = recid(prodistr).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "page-up"
            then do:
                do reccont = 1 to frame-down(frame-a):
                    run leitura (input "up").
                    if not avail prodistr
                    then leave.
                    recatu1 = recid(prodistr).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "cursor-down"
            then do:
                run leitura (input "down").
                if not avail prodistr
                then next.
                color display white/red prodistr.procod with frame frame-a.
                if frame-line(frame-a) = frame-down(frame-a)
                then scroll with frame frame-a.
                else down with frame frame-a.
            end.
            if keyfunction(lastkey) = "cursor-up"
            then do:
                run leitura (input "up").
                if not avail prodistr
                then next.
                color display white/red prodistr.procod with frame frame-a.
                if frame-line(frame-a) = 1
                then scroll down with frame frame-a.
                else up with frame frame-a.
            end.
        if keyfunction(lastkey) = "end-error"
        then leave bl-princ.

        if keyfunction(lastkey) = "return" or esqvazio
        then do:
            form prodistr
                 with frame f-prodistr color black/cyan
                      centered side-label row 5 .
            /*hide frame frame-a no-pause.
            */
            if esqregua
            then do:
                display caps(esqcom1[esqpos1]) @ esqcom1[esqpos1]
                        with frame f-com1 overlay.

                if esqcom1[esqpos1] = " Incluir " or esqvazio
                then do with frame frame-a overlay on error undo, next bl-princ
                        .
                    sresp = no.
                    run senha-reserva("INCLUIR").
                    if not sresp then leave.
                    
                    hide frame frame-a no-pause.
                    clear frame frame-a all no-pause.
                    create prodistr.
                    prodistr.numero   = next-value(prodistr).
                    prodistr.lipseq   = prodistr.numero.
                    prodistr.etbabast = 200.
                    prodistr.etbcod   = 200.
                    prodistr.tipo   = "ECOM".
                    vtipo = no.
                    disp prodistr.etbabast vtipo.
                    do on error undo.
                        update prodistr.procod.
                        find produ of prodistr no-lock no-error.
                        if not avail produ
                        then do. 
                            message "Produto Invalido" .
                            undo.           
                        end.
                        disp produ.pronom.
                        update prodistr.lipqtd format ">>>>>,>>9".
                       
                        
                        /** 16/05/17 Moda no Ecommerce **/
                        /* #1 */

                        if produ.catcod = 41 and
                           prodistr.etbabast = 200
                        then do:
                            vpack = 0.
                            find produaux where     
                                produaux.procod = prodistr.procod and
                                produaux.nome_campo = "Pack"
                                no-lock no-error.
                            if avail produaux
                            then vpack = int(produaux.valor_campo).
                            if vpack > 0
                            then do:
                                if prodistr.lipqtd mod vpack <> 0
                                then do:
                                    message 
                                        "Use multiplos do"
                                        "Pack " vpack.
                                    undo.    
                                end.
                            end.
                            
                                                   
                        end.                                                   
                        
                        do on error undo.
                            update
                               prodistr.predt          column-label "DtInicio"
                                with no-validate.
                            if prodistr.predt = ? or
                               prodistr.predt < today
                            then do.
                                message "Data Inicio nao pode ser inferior a"
                                            "hoje, ou em branco".
                                undo.
                            end.
                            do on error undo.
                                update 
                                    prodistr.SimbEntregue column-label "DtFim"
                                    with no-validate.
                                if prodistr.SimbEntregue = ?  or
                                   prodistr.SimbEntregue < prodistr.predt
                                then do.
                                    message 
                                        "Data Final nao pode ser inferior a"
                                                "Data de inicio, ou em branco".
                                    undo.
                                end.
                            end.                            
                        end.
                    end.
                    recatu1 = recid(prodistr).
                    leave.
                end.
                if esqcom1[esqpos1] = " Consulta " or
                   esqcom1[esqpos1] = " Excluiro " or
                   esqcom1[esqpos1] = " Alterar "
                then do with frame f-prodistr.
                end.
                if esqcom1[esqpos1] = " Alterar "
                then do with frame frame-a overlay on error undo, 
                                next bl-princ:
                    sresp = no.
                    run senha-reserva("ALTERAR").
                    if not sresp then leave.

                    find prodistr where
                            recid(prodistr) = recatu1 
                        exclusive.
                    do on error undo.
                        update prodistr.lipqtd format ">>,>>>,>>9".

                        /** 16/05/17 Moda no Ecommerce **/
                         /* #1 */

                        if produ.catcod = 41 and
                           prodistr.etbabast = 200
                        then do:
                            vpack = 0.
                            find produaux where     
                                produaux.procod = prodistr.procod and
                                produaux.nome_campo = "Pack"
                                no-lock no-error.
                            if avail produaux
                            then vpack = int(produaux.valor_campo).
                            hide message no-pause.
                            if vpack > 0
                            then do:
                                if prodistr.lipqtd mod vpack <> 0
                                then do:
                                    message 
                                        "Use multiplos do"
                                        "Pack " vpack.
                                    undo.    
                                end.
                            end.
                            
                                                   
                        end.                                                   
                        
                        
                        do on error undo.
                            update
                               prodistr.predt          column-label "DtInicio"
                                when prodistr.predt = ? or
                                     prodistr.predt = today
                                with no-validate.
                            if prodistr.predt entered and
                               (prodistr.predt = ? or
                                prodistr.predt < today)
                            then do.
                                message "Data Inicio nao pode ser inferior a"
                                            "hoje, ou em branco".
                                undo.
                            end.
                            do on error undo.
                                update 
                                    prodistr.SimbEntregue column-label "DtFim"
                                    with no-validate.
                                if prodistr.SimbEntregue = ?  or
                                   prodistr.SimbEntregue < prodistr.predt or
                                   prodistr.SimbEntregue < today
                                then do.
                                    message 
                                        "Data Final nao pode ser inferior a"
                                                "Data de inicio, ou em branco".
                                    undo.
                                end.
                            end.                            
                        end.
                    end.

                end.
                if esqcom1[esqpos1] = " Historico "
                then do.
                    hide frame f-com1  no-pause. 
                    hide frame f-com2  no-pause.
                    pause 0.
                    run alcis/hprodistr.p (recatu1).
                    view frame f-com1. 
                    view frame f-com2.
                end.
                if esqcom1[esqpos1] = " Excluir "
                then do with frame f-exclui  row 5 1 column centered
                        on error undo.
                    
                    sresp = no.
                    run senha-reserva("EXCLUIR").
                    if not sresp then leave.
                    message "Confirma Exclusao de" prodistr.procod
                            update sresp.
                    if not sresp
                    then undo, leave.
                    find next prodistr where true no-error.
                    if not available prodistr
                    then do:
                        find prodistr where recid(prodistr) = recatu1.
                        find prev prodistr where true no-error.
                    end.
                    recatu2 = if available prodistr
                              then recid(prodistr)
                              else ?.
                    find prodistr where recid(prodistr) = recatu1
                            exclusive.
                    prodistr.lipsit = "C".
                    recatu1 = ?.
                    next bl-princ.
                end.
                if esqcom1[esqpos1] = " Listagem "
                then do with frame f-Lista:
                    update "Deseja Imprimir todas ou a selecionada "
                           sresp format "Todas/Selecionada"
                                 help "Todas/Selecionadas"
                           with frame f-lista row 15 centered color black/cyan
                                 no-label.
                    if sresp
                    then run lprodistr.p (input 0).
                    else run lprodistr.p (input prodistr.procod).
                    leave.
                end.
                if esqcom1[esqpos1] = " Relatorio "
                then do :
                    run relatorio.
                    leave.
                end.

            end.
            else do:
                display caps(esqcom2[esqpos2]) @ esqcom2[esqpos2]
                        with frame f-com2 overlay.

                if esqcom2[esqpos2] = " Parametros "
                then do:
                    run man-parmetros.
                    hide frame f-par no-pause.
                end.
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
        then do:
            run frame-a.
        end.
        if esqregua
        then display esqcom1[esqpos1] with frame f-com1.
        else display esqcom2[esqpos2] with frame f-com2.
        recatu1 = recid(prodistr).
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
find produ of prodistr no-lock.
if prodistr.tipo = "ECMA"
then vtipo = yes.
else vtipo = no.
display vtipo /*prodistr.tipo format "xxxx" */
        prodistr.etbabast column-label "Estab"
        prodistr.procod
        produ.pronom  format "x(15)"
        prodistr.lipqtd         column-label "Reserv" format ">>>>>9"
        prodistr.preqtent       column-label "Utiliz" format ">>>>>9"
        prodistr.predt          column-label "DtInicio"
        prodistr.SimbEntregue   column-label "DtFim"
        prodistr.predt <= today and
            prodistr.SimbEntregue >= today format "***/" label "Vig"
        with frame frame-a 12 down centered color white/red row 5
        overlay.
end procedure.
procedure color-message.
color display message
        prodistr.procod
        with frame frame-a.
end procedure.
procedure color-normal.
color display normal
        prodistr.procod
        with frame frame-a.
end procedure.

procedure leitura . 
def input parameter par-tipo as char.
        
if par-tipo = "pri" 
then  
    if esqascend  
    then  
        find first prodistr where prodistr.etbabast = 200 and
                                  prodistr.lipsit   = "A" and
                                  (prodistr.tipo   = "ECOM" or
                                   prodistr.tipo     = "ECMA")
                      and (if p-procod > 0
                           then prodistr.procod = p-procod else true)
                      and prodistr.SimbEntregue > today
                           no-lock no-error.
    else  
        find last prodistr  where prodistr.etbabast = 200 and
                                    prodistr.lipsit   = "A" and
                                  (prodistr.tipo   = "ECOM" or
                                   prodistr.tipo     = "ECMA")
                      and (if p-procod > 0
                           then prodistr.procod = p-procod else true)
                      and prodistr.SimbEntregue > today
                                                 no-lock no-error.
                                             
if par-tipo = "seg" or par-tipo = "down" 
then  
    if esqascend  
    then  
        find next prodistr  where prodistr.etbabast = 200 and
                                    prodistr.lipsit   = "A" and
                                  (prodistr.tipo   = "ECOM" or
                                    prodistr.tipo     = "ECMA")
                      and (if p-procod > 0
                           then prodistr.procod = p-procod else true)
                      and prodistr.SimbEntregue > today
                                                no-lock no-error.
    else  
        find prev prodistr   where prodistr.etbabast = 200 and
                                    prodistr.lipsit   = "A" and
                                  (prodistr.tipo   = "ECOM" or
                                   prodistr.tipo     = "ECMA")
                      and (if p-procod > 0
                           then prodistr.procod = p-procod else true)
                      and prodistr.SimbEntregue > today
                                                no-lock no-error.
             
if par-tipo = "up" 
then                  
    if esqascend   
    then   
        find prev prodistr where prodistr.etbabast = 200 and
                                    prodistr.lipsit   = "A" and
                                  (prodistr.tipo   = "ECOM" or
                                   prodistr.tipo     = "ECMA")
                      and (if p-procod > 0
                           then prodistr.procod = p-procod else true)
                      and prodistr.SimbEntregue > today
                                        no-lock no-error.
    else   
        find next prodistr where prodistr.etbabast = 200 and
                                    prodistr.lipsit   = "A" and
                                  (prodistr.tipo   = "ECOM" or
                                   prodistr.tipo     = "ECMA")
                      and (if p-procod > 0
                           then prodistr.procod = p-procod else true)
                      and prodistr.SimbEntregue > today
                                        no-lock no-error.
        
end procedure.

procedure man-parmetros:
    def var v-cobertura as dec.
    def var v-disponivel as dec.
    def var v-senhapar as char.
    def var v-senhares as char.
    def var vresp as log format "Sim/Nao".
    def var vsenha-par as char.
    def buffer btbcntgen for tbcntgen.
    find last tbcntgen where
              tbcntgen.tipcon = 12 exclusive no-error.
    if avail tbcntgen
    then
    assign
        v-cobertura  = tbcntgen.valor
        v-disponivel = tbcntgen.quantidade
        v-senhapar   = tbcntgen.campo1[1]
        v-senhares   = tbcntgen.campo1[2]
        .

    disp v-cobertura  label "Dias de Cobertura"
         v-disponivel label "% Estoque Disponivel"
         /*v-senhares   label "Senha Reserva"
           v-senhapar   label "Senha Parametros"*/ 
         with frame f-par centered row 13 1 column side-label
         color message overlay.            
    vsenha-par = "".    
    vresp = no.
    message "Deseja alterar os parametros?" update vresp.
    if vresp then
    repeat:          
        disp "Informe a senha para alterar os parametros"
            with frame f-senha 1 down side-label row 19
            color message overlay no-box.
        update vsenha-par blank no-label
            with frame f-senha.
        if vsenha-par <> v-senhapar    
        then do:
            bell.
            message "Senha invalida.".
            pause.
            next.
        end.
        else leave. 
    end.
    else do:
        hide frame f-senha no-pause.
        hide frame f-par no-pause. 
        return.
    end.
    hide frame f-senha no-pause.
    if vsenha-par = v-senhapar
    then do:
        update v-cobertura 
         v-disponivel 
         v-senhares label "Senha Reserva"
         v-senhapar label "Senha Parametros"
         with frame f-par.
        if not avail tbcntgen or
           (v-cobertura <> tbcntgen.valor or
           v-disponivel <> tbcntgen.quantidade or
           v-senhapar   <> tbcntgen.campo1[1] or
           v-senhares   <> tbcntgen.campo1[2])
        then do on error undo:
            if avail tbcntgen
            then
            assign
                tbcntgen.numfim = string(today,"99999999")
                tbcntgen.datfim = today
                .
            create btbcntgen.
            assign
                btbcntgen.tipcon = 12
                btbcntgen.etbcod = ?
                btbcntgen.numini = string(today,"99999999")
                btbcntgen.numfim = ?
                btbcntgen.datini = today
                btbcntgen.datfim = ?
                btbcntgen.valor  = v-cobertura
                btbcntgen.quantidade = v-disponivel
                btbcntgen.campo1[1] = v-senhapar
                btbcntgen.campo1[2] = v-senhares
                . 
        end.
    end.
    clear frame f-par all.
    hide frame f-par no-pause.
end procedure.

procedure senha-reserva.
    def input parameter p-tipo as char.
    def var vsenha-res as char.
    find last tbcntgen where
              tbcntgen.tipcon = 12 no-lock no-error.
    if not avail tbcntgen
    then sresp = yes.
    else repeat:
        p-tipo = "Informe a senha para " + p-tipo + " reserva".
        disp p-tipo format "x(40)"  no-label
            with frame f-senha 1 down side-label row 19
            color message overlay no-box.
        update vsenha-res blank no-label
            with frame f-senha.
        if vsenha-res <> tbcntgen.campo1[2]    
        then do:
            bell.
            message "Senha invalida.".
            pause.
            next.
        end.
        else leave. 
    end.
    hide frame f-senha no-pause.
    if vsenha-res = tbcntgen.campo1[2]
    then sresp = yes.
    if keyfunction(lastkey) = "END-ERROR"
    then sresp = no.
end procedure.

procedure relatorio:
    

    def var vestoq_depos as dec.
    def var vreservas as dec.
    def var vdisponivel as dec.
    def var vtipo as log format "Automatica/Manual".
    def var varquivo as char.
    
    varquivo = "/admcom/relat/reserva_ECM." + string(time).
    
    {mdadmcab.i &Saida     = "value(varquivo)"   
                &Page-Size = "64"  
                &Cond-Var  = "120" 
                &Page-Line = "66" 
                &Nom-Rel   = ""prodistecom"" 
                &Nom-Sis   = """COMERCIAL ECOM""" 
                &Tit-Rel   = """ RESERVAS ECOMMERCE """ 
                &Width     = "120"
                &Form      = "frame f-cabcab"}

    for each prodistr where
             prodistr.etbabast = 200 and
             prodistr.lipsit   = "A" and
             /*prodistr.tipo   = "ECOM" and*/ 
             (if p-procod > 0
              then prodistr.procod = p-procod else true)
             no-lock:
             
        find produ where produ.procod = prodistr.procod no-lock no-error.
        if not avail produ then next.

        run /admcom/progr/corte_disponivel_wms.p (input  produ.procod,
                                                  output vestoq_depos,
                                                  output vreservas,
                                                  output vdisponivel).
        if prodistr.tipo = "ECMA"
        then vtipo = yes.
        else vtipo = no.
        disp produ.procod 
             produ.pronom
             vdisponivel   column-label "Estoque"
             prodistr.lipqtd    column-label "Reservado"
             prodistr.preqtent  column-label "Utilizado"
             vtipo      column-label "Tipo"
             prodistr.predt          column-label "DtInicio"
             prodistr.SimbEntregue   column-label "DtFim"
             with frame f-relat down width 150.

             
    end.     
    output close.

    if opsys = "UNIX"
    then do:
        run visurel.p(varquivo,"").
    end.
    else do:
        {mrod.i}
    end.

end procedure.
