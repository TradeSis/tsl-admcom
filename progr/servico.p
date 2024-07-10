/*
*
*    suporte.solic.p    -  solicitacoes de servico (para CPD)
*/
{admcab.i}
def var varqsai as char.
 pause 0.
 def buffer bfunc for func.
def var vsituacao   like suporte.solic.situacao.
def var primeiro as log.
def var vbusca          as char   label "Solicitacao".
def var vabertos        as log init yes.
def var recatu1         as recid.
def var recatu2         as recid.
def var reccont         as int.
def var esqpos1         as int.
def var esqpos2         as int.
def var esqregua        as log.
def var esqvazio        as log.
def var esqascend     as log initial yes.
def var esqcom1         as char format "x(14)" extent 5
    initial [" Consulta "," Inclusao "," Alteracao ",
                    " Exporta "," Todos "].
def var esqcom2         as char format "x(14)" extent 5
            initial [" Acompanhamento ", " Resultados ",
                            " Inicio "," Encerra "," Completo "].
def var esqhel1         as char format "x(80)" extent 5
    initial [" Inclusao  de servico ",
             " Alteracao da servico ",
             " Exclusao  da servico ",
             " Consulta  da servico ",
             " "].
def var esqhel2         as char format "x(12)" extent 5
   initial ["  ",
            " ",
            " ",
            " ",
            " "].

def buffer bsolic       for suporte.solic.
def var vservico         like suporte.solic.data.
def var par-funcod like func.funcod.
def var vhora       as  char label "Hora" format "x(5)".
def var vhrfim      as  char label "Hora" format "x(5)".
def var vhrini      as  char label "Hora" format "x(5)".
def var vhrvis      as  char label "Hora" format "x(5)".
def var vsousuario  aS log init no.
def var vlocal      as char extent 13 format "x(15)"
       init [" Informatica "," C.Pagar ",
             " C.Receber "," Estoque "," Compras ", " Vendas " ,
                " Crediario "," Contabilidade ",           ""
             ].
def var vtipo      as char extent 13
       init [" Informatica "," C.Pagar ",
             " C.Receber "," Estoque "," Compras ", " Vendas " ,
              " Crediario "," Contabilidade ",           ""
             ].
def var vtit-usu aS char.
def var vtit-abe as char.              
                sfuncod = if sfuncod = 0 then 99 else sfuncod.
par-funcod = sfuncod.

find segur where segur.cntcod = 99      and
                 segur.usucod = sfuncod       no-lock no-error.
/*
if not avail segur then leave.
*/
form
    esqcom1
    with frame f-com1
                 row 1 no-labels side-labels column 1 centered
                 overlay width 80 title " Solicitacoes de Servico " +
                            vtit-abe + " " + vtit-uSu.
                 
form
    esqcom2
    with frame f-com2
                 row screen-lines - 2 no-labels side-labels column 1
                 centered overlay width 80.

assign
    esqregua = yes
    esqpos1  = 1
    esqpos2  = 1
    esqascend = no
    vabertos  = no
    vtit-uSu = if vsouSuario
               then " P/Usuario "
               elSe " Todos "
    vtit-abe = if vabertos 
               then " So Abertos " 
               elSe " Completo ".
     
pause 0.
bl-princ:
repeat:
                esqcom1[5] = if vsouSuario 
                               then " Todos " 
                               else " P/Usuario ". 
            esqascend = if vSouSuario 
                        then no 
                        else no. 
            vtit-uSu = if vsouSuario 
                       then " P/Usuario " 
                       elSe " Todos ".
            esqcom2[5] = if vabertos 
                               then " Completo " 
                               else " So Abertos ". 
            esqascend = if vabertos 
                        then no  
                        else no. 
            vtit-abe = if vabertos 
                       then " So Abertos " 
                       elSe " Completo ".
 
            display esqcom1
                        with frame f-com1.
            display esqcom2
                        with frame f-com2.
            
     pause 0.
    disp esqcom1 with frame f-com1.
    disp esqcom2 with frame f-com2.
    if recatu1 = ?
    then
        if esqascend
        then
            find first SUPORTE.solic where
                                  ( if vSouSuario = no
                                   then true
                                   else suporte.solic.funcod = par-funcod) and 
             
                                  (if vabertos = no
                                   then true
                                   else suporte.solic.dtfim = ?)
                                        no-lock no-error.
        else
            find last solic where
                                   ( if vSouSuario = no
                                   then true
                                   else suporte.solic.funcod = par-funcod) and 
                                  (if vabertos = no
                                   then true
                                   else suporte.solic.dtfim = ?)
                                        no-lock no-error.
    else
        find solic where recid(solic) = recatu1 no-lock.
    if not available solic
    then esqvazio = yes.
    else esqvazio = no.
    clear frame frame-a all no-pause.
    if not esqvazio
    then do:
        find func where func.etbcod = setbcod and
                        func.funcod = suporte.solic.funcod no-lock.
        display suporte.solic.servcod         column-label "Num"
                suporte.solic.data            format "99999999"
                suporte.solic.solicitante column-label "Solicit" format "x(8)"
                suporte.solic.modsis           format "x(13)"
                if suporte.solic.assunto = ""
                then suporte.solic.descricao[1]
                else suporte.solic.assunto @ suporte.solic.assunto
                                            format "x(28)"
                if suporte.solic.dtfim = ?
                then if suporte.solic.dtini <> ?
                     then "Iniciado"
                     else "Aberto"
                else "Encerrado" @ vsituacao label "Situacao"
                                    format "X(9)"
                suporte.solic.situacao format "x(4)" no-label
                with frame frame-a 13 down centered color white/red row 4
                            width 81 no-box.
    end.

    recatu1 = recid(solic).
    if esqregua
    then color display message esqcom1[esqpos1] with frame f-com1.
    else color display message esqcom2[esqpos2] with frame f-com2.
    if not esqvazio
    then repeat:
        if esqascend
        then
            find next solic where
                                   ( if vSouSuario = no
                                   then true
                                   else suporte.solic.funcod = par-funcod) and 
                                  (if vabertos = no
                                   then true
                                   else suporte.solic.dtfim = ?)
                                        no-lock.
        else
            find prev solic where
                                   ( if vSouSuario = no
                                   then true
                                   else suporte.solic.funcod = par-funcod) and 
                                  (if vabertos = no
                                   then true
                                   else suporte.solic.dtfim = ?)
                                        no-lock.
        if not available solic
        then leave.
        if frame-line(frame-a) = frame-down(frame-a)
        then leave.
        down
            with frame frame-a.
        find func where func.etbcod = setbcod and
                        func.funcod = suporte.solic.funcod no-lock.
        display suporte.solic.servcod
                suporte.solic.data
                suporte.solic.solicitante
                suporte.solic.modsis          column-label "Modulo"  
                if suporte.solic.assunto = ""
                then suporte.solic.descricao[1]
                else suporte.solic.assunto @ suporte.solic.assunto
                if suporte.solic.dtfim = ?
                then if suporte.solic.dtini <> ?
                     then "Iniciado"
                     else "Aberto"
                else "Encerrado" @ vsituacao label "Situacao"
                suporte.solic.situacao                                
                
                 with frame frame-a.
    end.
    if not esqvazio
    then up frame-line(frame-a) - 1 with frame frame-a.

    repeat with frame frame-a:

        if not esqvazio
        then do:
            find solic where recid(solic) = recatu1 no-lock.

            status default
                if esqregua
                then esqhel1[esqpos1] + if esqpos1 > 1 and
                                           esqhel1[esqpos1] <> ""
                                        then  string(suporte.solic.data)
                                        else ""
                else esqhel2[esqpos2] + if esqhel2[esqpos2] <> ""
                                        then string(suporte.solic.data)
                                        else "".
            esqcom1[5] = if vsouSuario 
                               then " Todos " 
                               else " P/Usuario ". 
            esqascend = if vSouSuario 
                        then no 
                        else no. 
            vtit-uSu = if vsouSuario 
                       then " P/Usuario " 
                       elSe " Todos ".
            esqcom2[5] = if vabertos 
                               then " Completo " 
                               else " So Abertos ". 
            esqascend = if vabertos 
                        then no  
                        else no. 
            vtit-abe = if vabertos 
                       then " So Abertos " 
                       elSe " Completo ".
 
            display esqcom1
                        with frame f-com1.
            display esqcom2
                        with frame f-com2.
            
            choose field suporte.solic.data help ""
                go-on(cursor-down cursor-up
                      cursor-left cursor-right
                      1 2 3 4 5 6 7 8 9 0
                      page-down   page-up
                      tab PF4 F4 ESC return) .

            status default "".
            if keyfunction(lastkey) = "0" or keyfunction(lastkey) = "1" or
               keyfunction(lastkey) = "2" or keyfunction(lastkey) = "3" or
               keyfunction(lastkey) = "4" or keyfunction(lastkey) = "5" or
               keyfunction(lastkey) = "6" or keyfunction(lastkey) = "7" or
               keyfunction(lastkey) = "8" or keyfunction(lastkey) = "9"
            then do with centered row 8 color message
                                frame f-procura side-label overlay.
                vbusca = keyfunction(lastkey).
                pause 0.
                primeiro = yes.
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
                recatu2  = recatu1.
                find first solic where suporte.solic.servcod = int(vbusca)
                                        no-lock no-error.
                if avail solic
                then recatu1 = recid(solic).
                else recatu1 = recatu2.
                leave.
            end.

        end.
        
        {esquema.i &tabela = "solic"
                   &campo  = "suporte.solic.data"
                   &where  = "
                                  ( if vSouSuario = no
                                   then true
                                   else suporte.solic.funcod = par-funcod) and 
                                 (if vabertos = no
                                then true
                                else suporte.solic.dtfim = ?)"
                   &frame  = "frame-a"}
        
        if keyfunction(lastkey) = "end-error"
        then leave bl-princ.

        if keyfunction(lastkey) = "return" or esqvazio
        then do on error undo, retry on endkey undo, leave:
            pause 0.
            form
                 suporte.solic.data           colon 15
                 vhora                  no-label
                 suporte.solic.funcod            colon 15 label "Usuario"
                 func.funnom       no-label
                 suporte.solic.solicitante colon 15

                 suporte.solic.modsis           colon 15 label "Local"
                 suporte.solic.assunto        colon 15
                 suporte.solic.descricao[1]  colon 15 label "Descricao"
                 suporte.solic.descricao[2]  colon 15  label ""
                 suporte.solic.descricao[3]  colon 15  label ""
                 suporte.solic.descricao[4]  colon 15  label ""
                 suporte.solic.descricao[5]  colon 15  label ""
                 suporte.solic.descricao[6]  colon 15  label ""
                 suporte.solic.descricao[7]  colon 15  label ""
                 suporte.solic.descricao[8]  colon 15  label ""
                 suporte.solic.descricao[9]  colon 15  label ""
                 suporte.solic.descricao[10] colon 15  label ""
                 with frame f-solic color black/cyan
                      centered side-label row 4 width 80
                        title "Solicitacao de Servico " +
                                string(suporte.solic.servcod).
            form
                 suporte.solic.dtvis          colon 15
                 vhrvis                  no-label
                 suporte.solic.dtpro          colon 15
                 suporte.solic.hrpro           no-label
                 suporte.solic.tipo           colon 15 label "Tipo"
                 suporte.solic.tecnico        colon 15
                 suporte.solic.resultado[1]  colon 15 label "Resultado"
                 suporte.solic.resultado[2]  colon 15  label ""
                 suporte.solic.resultado[3]  colon 15  label ""
                 suporte.solic.resultado[4]  colon 15  label ""
                 suporte.solic.resultado[5]  colon 15  label ""
                 suporte.solic.resultado[6]  colon 15  label ""
                 suporte.solic.resultado[7]  colon 15  label ""
                 suporte.solic.resultado[8]  colon 15  label ""
                 suporte.solic.resultado[9]  colon 15  label ""
                 suporte.solic.resultado[10] colon 15  label ""
                 suporte.solic.dtini         colon 15
                 vhrini                no-label
                 suporte.solic.dtfim         colon 15
                 vhrfim                no-label
                 with frame f-result color black/cyan
                      centered side-label row 6 width 80 overlay
                        title " Parecer Tecnico ".
            form
                 suporte.solic.data           colon 15
                 vhora                  no-label
                 suporte.solic.funcod            colon 15 label "Usuario"
                 func.funnom            no-label
                 suporte.solic.solicitante colon 15
                 suporte.solic.modsis           colon 15 label "Local"
                 suporte.solic.assunto        colon 15    skip(1)
                 "Descricao do Servico" at 25
                 "====================" at 25 skip(1)
                 suporte.solic.descricao[1]  no-label format "x(75)"          skip(1)
                 suporte.solic.descricao[2]  no-label format "x(75)"          skip(1)
                 suporte.solic.descricao[3]  no-label format "x(75)"          skip(1)
                 suporte.solic.descricao[4]  no-label format "x(75)"          skip(1)
                 suporte.solic.descricao[5]  no-label format "x(75)"          skip(1)
                 suporte.solic.descricao[6]  no-label format "x(75)"          skip(1)
                 suporte.solic.descricao[7]  no-label format "x(75)"          skip(1)
                 suporte.solic.descricao[8]  no-label format "x(75)"          skip(1)
                 suporte.solic.descricao[9]  no-label format "x(75)"          skip(1)
                 suporte.solic.descricao[10] no-label format "x(75)"
                 with frame fsolic color black/cyan no-box
                      centered side-label row 4 width 80.
            form
                 suporte.solic.dtvis          colon 15
                 vhrvis                  no-label
                 suporte.solic.dtpro          colon 15
                 suporte.solic.hrpro           no-label
                 suporte.solic.tipo             colon 15 label "Tipo"
                 suporte.solic.tecnico        colon 15                         skip(1)
                 suporte.solic.resultado[1]  no-label format "x(75)"           skip(1)
                 suporte.solic.resultado[2]  no-label format "x(75)"           skip(1)
                 suporte.solic.resultado[3]  no-label format "x(75)"           skip(1)
                 suporte.solic.resultado[4]  no-label format "x(75)"           skip(1)
                 suporte.solic.resultado[5]  no-label format "x(75)"           skip(1)
                 suporte.solic.resultado[6]  no-label format "x(75)"           skip(1)
                 suporte.solic.resultado[7]  no-label format "x(75)"           skip(1)
                 suporte.solic.resultado[8]  no-label format "x(75)"           skip(1)
                 suporte.solic.resultado[9]  no-label format "x(75)"           skip(1)
                 suporte.solic.resultado[10] no-label format "x(75)"           skip(1)
                 suporte.solic.dtini         colon 15
                 vhrini                no-label
                 suporte.solic.dtfim         colon 40
                 vhrfim                no-label
                 with frame fresult color black/cyan
                      centered side-label row 6 width 80 overlay
                        title " Parecer Tecnico ".
            hide frame frame-a no-pause.
            if esqregua
            then do:
                display caps(esqcom1[esqpos1]) @ esqcom1[esqpos1]
                        with frame f-com1.
                if esqcom1[esqpos1] = " Inclusao " or esqvazio
                then do with frame f-solic on endkey undo.
                    if keyfunction(laStkey) = "end-error" 
                    then do:
                        recatu1 = ?.
                        next bl-princ.
                    end.
                    find last bsolic where bsolic.cliente = wempre.emprazsoc
                                       and bsolic.servcod <> ? no-error.
                    create suporte.solic.
                    suporte.solic.servcod = if avail bsolic
                                    then bsolic.servcod + 1
                                    else 1.
                    assign suporte.solic.cliente = wempre.emprazsoc.
                    assign suporte.solic.data = today
                           suporte.solic.hora = time
                           suporte.solic.funcod = sfuncod.
                    find func where func.etbcod = setbcod and
                                    func.funcod = suporte.solic.funcod no-lock.
                    display suporte.solic.data
                            func.funnom
                            string(suporte.solic.hora,"HH:MM") @ vhora.
                    update suporte.solic.funcod.        
                    find func where func.etbcod = setbcod and
                                    func.funcod = suporte.solic.funcod no-lock.
                    display suporte.solic.data
                            func.funnom
                            string(suporte.solic.hora,"HH:MM") @ vhora.
                    update suporte.solic.solicitante.
                    pause 0.        
                    display vlocal 
                            with frame fescolha 1 column
                                    column 6 row 4 overlay
                                        no-label title " Local ".
                    choose field vlocal with frame fescolha.     
                    hide frame feScolha no-pause.
                    suporte.solic.modsis = caps(trim(vlocal[frame-index])).
                    display suporte.solic.modsis.
                    update suporte.solic.assunto
                           text(suporte.solic.descricao).
                    suporte.solic.assunto = caps(suporte.solic.assunto).
                    suporte.solic.tecnico = caps(suporte.solic.tecnico).
                    suporte.solic.solicitante = caps(suporte.solic.solicitante).
                    suporte.solic.descricao[1] = caps(suporte.solic.descricao[1]).
                    suporte.solic.descricao[2] = caps(suporte.solic.descricao[2]).
                    suporte.solic.descricao[3] = caps(suporte.solic.descricao[3]).
                    suporte.solic.descricao[4] = caps(suporte.solic.descricao[4]).
                    suporte.solic.descricao[5] = caps(suporte.solic.descricao[5]).
                    suporte.solic.descricao[6] = caps(suporte.solic.descricao[6]).
                    suporte.solic.descricao[7] = caps(suporte.solic.descricao[7]).
                    suporte.solic.descricao[8] = caps(suporte.solic.descricao[8]).
                    suporte.solic.descricao[9] = caps(suporte.solic.descricao[9]).
                    suporte.solic.descricao[10] = caps(suporte.solic.descricao[10]).
                    recatu1 = recid(solic).
                    leave.
                end.

                if esqcom1[esqpos1] = " Consulta " or
                   esqcom1[esqpos1] = " Exclusao " or
                   esqcom1[esqpos1] = " Alteracao "
                then do with frame f-solic.
                    find func where func.etbcod = setbcod and
                                    func.funcod = suporte.solic.funcod no-lock.
                    display func.funnom
                            suporte.solic.data
                            suporte.solic.modsiS
                            string(suporte.solic.hora,"HH:MM") @ vhora.
                    display suporte.solic.solicitante.
                    display
                            suporte.solic.assunto
                            suporte.solic.descricao.
                    if suporte.solic.hrfim = 0
                    then vhrfim = "".
                    else vhrfim = string(suporte.solic.hrfim,"HH:MM").

                    if suporte.solic.hrvis = 0
                    then vhrvis = "".
                    else vhrvis = string(suporte.solic.hrvis,"HH:MM").

                    if suporte.solic.hrini = 0
                    then vhrini = "".
                    else vhrini = string(suporte.solic.hrini,"HH:MM").

                    if suporte.solic.dtvis <> ? and
                       esqcom1[esqpos1] <> " Alteracao "
                    then do:
                        display suporte.solic.dtvis
                                vhrvis
                                suporte.solic.dtpro
                                suporte.solic.hrpro
                                suporte.solic.tecnico
                                suporte.solic.resultado
                                suporte.solic.dtfim
                                vhrfim
                                suporte.solic.dtini
                                vhrini
                                with frame f-result.
                        pause.
                    end.
                    if esqcom1[esqpos1] <> " Exclusao " and
                      suporte.solic.servcod = ?
                    then do with frame f-result:
                        find solic where recid(solic) = recatu1.
                        update suporte.solic.dtvis
                               suporte.solic.dtpro
                               suporte.solic.hrpro
                               suporte.solic.tecnico
                               text(suporte.solic.resultado).
                        suporte.solic.tecnico = caps(suporte.solic.tecnico).
                        suporte.solic.resultado[1] = caps(suporte.solic.resultado[1]).
                        suporte.solic.resultado[2] = caps(suporte.solic.resultado[2]).
                        suporte.solic.resultado[3] = caps(suporte.solic.resultado[3]).
                        suporte.solic.resultado[4] = caps(suporte.solic.resultado[4]).
                        suporte.solic.resultado[5] = caps(suporte.solic.resultado[5]).
                        suporte.solic.resultado[6] = caps(suporte.solic.resultado[6]).
                        suporte.solic.resultado[7] = caps(suporte.solic.resultado[7]).
                        suporte.solic.resultado[8] = caps(suporte.solic.resultado[8]).
                        suporte.solic.resultado[9] = caps(suporte.solic.resultado[9]).
                        suporte.solic.resultado[10] = caps(suporte.solic.resultado[10]).
                        if suporte.solic.dtpro        <> ?  or
                           suporte.solic.hrpro        <> "" or
                           suporte.solic.tecnico      <> "" or
                           suporte.solic.resultado[1] <> "" or
                           suporte.solic.resultado[2] <> "" or
                           suporte.solic.resultado[3] <> "" or
                           suporte.solic.resultado[4] <> "" or
                           suporte.solic.resultado[5] <> "" or
                           suporte.solic.resultado[6] <> "" or
                           suporte.solic.resultado[7] <> "" or
                           suporte.solic.resultado[8] <> "" or
                           suporte.solic.resultado[9] <> "" or
                           suporte.solic.resultado[10] <> ""
                        then do:
                            suporte.solic.dtvis = today.
                            suporte.solic.hrvis = time.
                            if suporte.solic.hrvis = 0
                            then vhrvis = "".
                            else vhrvis = string(suporte.solic.hrvis,"HH:MM").
                            display suporte.solic.dtvis
                                    vhrvis
                                    with frame f-result.
                        end.
                    end.
                end.
                if (esqcom1[esqpos1] = " Alteracao " and
                    suporte.solic.servcod = ? and
                    suporte.solic.dtfim = ? and
                    suporte.solic.dtvis = ? and
                    suporte.solic.funcod = sfuncod) or ((avail segur) and
                                            esqcom1[esqpos1] = " Alteracao ")

                then do with frame f-solic.
                    find solic where recid(solic) = recatu1.
                    display suporte.solic.data
                            string(suporte.solic.hora,"HH:MM") @ vhora.
                    update suporte.solic.solicitante.

                    meSsage "Alterar Local ?" update Sresp.
                    if SreSp
                    then do:
                        pause 0.        
                        display vlocal 
                                with frame f-escolha 1 column
                                        column 6 row 4 overlay
                                            no-label title " Local ".
                        choose field vlocal with frame f-escolha.     
                        hide frame f-eScolha no-pause.
                        suporte.solic.modsis = caps(trim(vlocal[frame-index])).
                        display suporte.solic.modsis.
                    end.
                    update suporte.solic.data.
                    update suporte.solic.assunto
                           text(suporte.solic.descricao).
                    suporte.solic.assunto = suporte.solic.assunto.
                    suporte.solic.solicitante = suporte.solic.solicitante.
                    suporte.solic.descricao[1] = suporte.solic.descricao[1].
                    suporte.solic.descricao[2] = suporte.solic.descricao[2].
                    suporte.solic.descricao[3] = suporte.solic.descricao[3].
                    suporte.solic.descricao[4] = suporte.solic.descricao[4].
                    suporte.solic.descricao[5] = suporte.solic.descricao[5].
                    suporte.solic.tecnico = suporte.solic.tecnico.
                    suporte.solic.descricao[6] = suporte.solic.descricao[6].
                    suporte.solic.descricao[7] = suporte.solic.descricao[7].
                    suporte.solic.descricao[8] = suporte.solic.descricao[8].
                    suporte.solic.descricao[9] = suporte.solic.descricao[9].
                    suporte.solic.descricao[10] = suporte.solic.descricao[10].
                    leave.
 
                end.
                if esqcom1[esqpos1] = " Exclusao " and
                   suporte.solic.dtfim = ? and
                   suporte.solic.dtpro = ? and
                   suporte.solic.dtvis = ? and
                   suporte.solic.servcod = ?
                then do with frame f-exclui  row 5 1 column centered.
                    find solic where recid(solic) = recatu1.
                    message "Confirma Exclusao de" suporte.solic.data
                            update sresp.
                    if not sresp
                    then undo, leave.
                    find next solic where
                                        (if vabertos = no
                                         then true
                                         else suporte.solic.dtfim = ?)
                                            no-error.
                    if not available solic
                    then do:
                        find solic where recid(solic) = recatu1.
                        find prev solic where
                                        (if vabertos = no
                                         then true
                                         else suporte.solic.dtfim = ?)
                                                no-error.
                    end.
                    recatu2 = if available solic
                              then recid(solic)
                              else ?.
                    find solic where recid(solic) = recatu1.
                    delete suporte.solic.
                    recatu1 = ?.
                    leave.
                end.
                if esqcom1[esqpos1] = " Imprime "
                then do with frame fsolic.
                    message "Relatorio Geral ?" update sresp.
                    if sresp
                    then do:
                        run lsolabe.p.
                        leave.
                    end.
                    varqsai = "../impress/suporte.solic." + 
                                    string(suporte.solic.servcod) +
                                            ".txt".
                    {mdadmcab.i
                        &Saida     = "printer"
                        &Page-Size = "64"
                        &Cond-Var  = "80"
                        &Page-Line = "66"
                        &Nom-Rel   = ""SERVICO""
                        &Nom-Sis   = """SISTEMA DE SUPORTE - "" + 
                                        suporte.solic.cliente "
                        &Tit-Rel   = " ""SOLICITACAO DE SERVICO "" +
                                         string(suporte.solic.servcod,"">>>9"")"
                        &Width     = "80"
                        &Form      = "frame f-cabcab"}

                    find func where func.etbcod = setbcod and
                                    func.funcod = suporte.solic.funcod no-lock.
                    display func.funnom
                            suporte.solic.data
                            string(suporte.solic.hora,"HH:MM") @ vhora.
                    display
                            suporte.solic.assunto
                            suporte.solic.modSiS
                            suporte.solic.solicitante
                           
                           (if suporte.solic.descricao[1] <> ""
                            then suporte.solic.descricao[1]
                            else fill("_",75))  @ suporte.solic.descricao[1]
                           (if suporte.solic.descricao[2] <> ""
                            then suporte.solic.descricao[2]
                            else fill("_",75))  @ suporte.solic.descricao[2]
                           (if suporte.solic.descricao[3] <> ""
                            then suporte.solic.descricao[3]
                            else fill("_",75))  @ suporte.solic.descricao[3]
                           (if suporte.solic.descricao[4] <> ""
                            then suporte.solic.descricao[4]
                            else fill("_",75))  @ suporte.solic.descricao[4]
                           (if suporte.solic.descricao[5] <> ""
                            then suporte.solic.descricao[5]
                            else fill("_",75))  @ suporte.solic.descricao[5]
                           (if suporte.solic.descricao[6] <> ""
                            then suporte.solic.descricao[6]
                            else fill("_",75))  @ suporte.solic.descricao[6]
                           (if suporte.solic.descricao[7] <> ""
                            then suporte.solic.descricao[7]
                            else fill("_",75))  @ suporte.solic.descricao[7]
                           (if suporte.solic.descricao[8] <> ""
                            then suporte.solic.descricao[8]
                            else fill("_",75))  @ suporte.solic.descricao[8]
                           (if suporte.solic.descricao[9] <> ""
                            then suporte.solic.descricao[9]
                            else fill("_",75))  @ suporte.solic.descricao[9]
                           (if suporte.solic.descricao[10] <> ""
                            then suporte.solic.descricao[10]
                            else fill("_",75))  @ suporte.solic.descricao[10].
 
                    if suporte.solic.hrfim = 0
                    then vhrfim = "".
                    else vhrfim = string(suporte.solic.hrfim,"HH:MM").

                    if suporte.solic.hrvis = 0
                    then vhrvis = "".
                    else vhrvis = string(suporte.solic.hrvis,"HH:MM").

                    if suporte.solic.hrini = 0
                    then vhrini = "".
                    else vhrini = string(suporte.solic.hrini,"HH:MM").
                    put skip(1).
                    display suporte.solic.dtvis
                            vhrvis
                            suporte.solic.dtpro
                            suporte.solic.hrpro
                           (if suporte.solic.tecnico <> ""
                            then suporte.solic.tecnico
                            else fill("_",8)) @ suporte.solic.tecnico
                           (if suporte.solic.resultado[1] <> ""
                            then suporte.solic.resultado[1]
                            else fill("_",75))  @ suporte.solic.resultado[1]
                           (if suporte.solic.resultado[2] <> ""
                            then suporte.solic.resultado[2]
                            else fill("_",75))  @ suporte.solic.resultado[2]
                           (if suporte.solic.resultado[3] <> ""
                            then suporte.solic.resultado[3]
                            else fill("_",75))  @ suporte.solic.resultado[3]
                           (if suporte.solic.resultado[4] <> ""
                            then suporte.solic.resultado[4]
                            else fill("_",75))  @ suporte.solic.resultado[4]
                           (if suporte.solic.resultado[5] <> ""
                            then suporte.solic.resultado[5]
                            else fill("_",75))  @ suporte.solic.resultado[5]
                           (if suporte.solic.resultado[6] <> ""
                            then suporte.solic.resultado[6]
                            else fill("_",75))  @ suporte.solic.resultado[6]
                           (if suporte.solic.resultado[7] <> ""
                            then suporte.solic.resultado[7]
                            else fill("_",75))  @ suporte.solic.resultado[7]
                           (if suporte.solic.resultado[8] <> ""
                            then suporte.solic.resultado[8]
                            else fill("_",75))  @ suporte.solic.resultado[8]
                           (if suporte.solic.resultado[9] <> ""
                            then suporte.solic.resultado[9]
                            else fill("_",75))  @ suporte.solic.resultado[9]
                           (if suporte.solic.resultado[10] <> ""
                            then suporte.solic.resultado[10]
                            else fill("_",75))  @ suporte.solic.resultado[10]
                            suporte.solic.dtfim
                            vhrfim
                            suporte.solic.dtini
                            vhrini
                            with frame fresult.
                    output close.
                    /*
                    {mdadmrod.i &Saida     = "value(varqsai)"
                                &NomRel    = """SERVICO"""
                                &Page-Size = "64"
                                &Width     = "80"
                                &Traco     = "30"
                                &Form      = "frame f-rod3"}.
                    */
                end.
                if esqcom1[esqpos1] = " Exporta "
                then do with frame fsolic.
                    
                    do on error undo.
                        find solic where recid(solic) = recatu1.
                        suporte.solic.situacao = "Exportada".
                        suporte.solic.dtvis    = today.
                    end.
                    output to solic.d.
                    for each bsolic.
                        export bsolic.
                    end.
                    output close.
                    def buffer bsolmov for solmov.
                    output to solmov.d.
                    for each bsolmov.
                        export bsolmov.
                    end.
                    output close.
                end.
                
                if esqcom1[esqpos1] = " P/Usuario " or
                   esqcom1[esqpos1] = " Todos "
                then do .
                    if esqcom1[esqpos1] = " P/Usuario " 
                    then do:
                        update par-funcod with frame fff side-label.
                        find func where func.etbcod = setbcod and
                                        func.funcod = par-funcod no-lock
                                        no-error.
                        if not avail func
                        then do:
                            message "Funcionario nao Cadastrado".
                            undo.
                        end.    
                    end.
                    hide frame f-com1  no-pause.
                    hide frame f-com2  no-pause.
                    vsouSuario = not vSouSuario.
                    esqcom1[esqpos1] = if vsouSuario
                                       then " Todos "
                                       else " P/Usuario ".
                    esqascend = if vSouSuario
                                then no
                                else no.
                    vtit-uSu = if vsouSuario
                               then " P/Usuario "
                               elSe " Todos ".
                    recatu1 = ?.
                    leave.
                    view frame f-com1.
                    view frame f-com2.
                end.
 
            end.
            else do:
                display caps(esqcom2[esqpos2]) @ esqcom2[esqpos2]
                        with frame f-com2.
                if esqcom2[esqpos2] = " Resultados " and
                  (avail segur) and
                  suporte.solic.dtfim = ?        and
                  suporte.solic.servcod <> ?
                then do.
                    find solic where recid(solic) = recatu1.
                    if suporte.solic.hrfim = 0
                    then vhrfim = "".
                    else vhrfim = string(suporte.solic.hrfim,"HH:MM").

                    if suporte.solic.hrvis = 0
                    then vhrvis = "".
                    else vhrvis = string(suporte.solic.hrvis,"HH:MM").

                    pause 0.
                    display suporte.solic.dtvis
                            vhrvis
                            suporte.solic.dtpro
                            suporte.solic.hrpro
                            suporte.solic.tecnico
                            suporte.solic.resultado
                            suporte.solic.dtfim
                            vhrfim
                            with frame f-result.
                    if suporte.solic.tipo = "" then suporte.solic.tipo = "SISTEMA".
                    update suporte.solic.dtpro
                           suporte.solic.hrpro
                           suporte.solic.tipo
                           suporte.solic.tecnico
                           text(suporte.solic.resultado)
                           with frame f-result.
                    suporte.solic.tecnico = caps(suporte.solic.tecnico).
                    suporte.solic.resultado[1] = caps(suporte.solic.resultado[1]).
                    suporte.solic.resultado[2] = caps(suporte.solic.resultado[2]).
                    suporte.solic.resultado[3] = caps(suporte.solic.resultado[3]).
                    suporte.solic.resultado[4] = caps(suporte.solic.resultado[4]).
                    suporte.solic.resultado[5] = caps(suporte.solic.resultado[5]).
                    suporte.solic.resultado[6] = caps(suporte.solic.resultado[6]).
                    suporte.solic.resultado[7] = caps(suporte.solic.resultado[7]).
                    suporte.solic.resultado[8] = caps(suporte.solic.resultado[8]).
                    suporte.solic.resultado[9] = caps(suporte.solic.resultado[9]).
                    suporte.solic.resultado[10] = caps(suporte.solic.resultado[10]).
                end.
                if esqcom2[esqpos2] = " Acompanhamento " and
                   suporte.solic.servcod <> ?
                then do:
                    hide frame f-com1 no-pause.
                    hide frame f-com2 no-pause.
                    run solmov.p (input recid(solic)).
                    pause 0.
                    view frame f-com1.
                    pause 0.
                    view frame f-com2.
                    pause 0.
                end.
                if esqcom2[esqpos2] = " Inicio " and
                  (avail segur)  and
                  suporte.solic.dtini = ? and
                  suporte.solic.dtfim = ?    and
                  suporte.solic.servcod <> ?
                then do .
                    find solic where recid(solic) = recatu1.
                    message "Confirma o Inicio do Servico ?" update sresp.
                    if sresp
                    then
                        assign suporte.solic.dtini = today
                               suporte.solic.hrini = time.
                end.
                if esqcom2[esqpos2] = " So Abertos " or
                   esqcom2[esqpos2] = " Completo "
                then do .
                    hide frame f-com1  no-pause.
                    hide frame f-com2  no-pause.
                    vabertos = not vabertos.
                    esqcom2[esqpos2] = if vabertos
                                       then " Completo "
                                       else " So Abertos ".
                    esqascend = if vabertos
                                then no
                                else no.
                    vtit-abe = if vabertos
                               then " So Abertos "
                               elSe " Completo ".

                    recatu1 = ?.
                    leave.
                    view frame f-com1.
                    view frame f-com2.
               end.
               if esqcom2[esqpos2] = " Encerra " and
                  (avail segur) and
                  suporte.solic.dtfim = ? and
                  suporte.solic.servcod <> ?
                then do .
                    find solic where recid(solic) = recatu1.
                    sresp = no.
                    message "Confirma ?" update sresp.
                    if sresp
                    then
                        if suporte.solic.dtfim = ?
                        then
                            assign suporte.solic.dtfim = today
                                   suporte.solic.hrfim = time.
                        else
                            message "Servico ja Encerrado".
                end.
                leave.
            end.
        end.
        if not esqvazio
        then do:
            find func where func.etbcod = setbcod and
                            func.funcod = suporte.solic.funcod no-lock.
            display
                suporte.solic.servcod
                suporte.solic.data
                suporte.solic.solicitante
                suporte.solic.modsis          column-label "Modulo"  
                if suporte.solic.assunto = ""
                then suporte.solic.descricao[1]
                else suporte.solic.assunto @ suporte.solic.assunto
                if suporte.solic.dtfim = ?
                then if suporte.solic.dtini <> ?
                     then "Iniciado"
                     else "Aberto"
                else "Encerrado" @ vsituacao label "Situacao"
                suporte.solic.situacao                                
                
                     with frame frame-a.
        end.
        if esqregua
        then display esqcom1[esqpos1] with frame f-com1.
        else display esqcom2[esqpos2] with frame f-com2.
        recatu1 = recid(solic).
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
