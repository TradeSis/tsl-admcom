
/*  alcis/conf_acao.p                                                       */
/*  COCKPIT - CONFIRMACAO ORDEM DE VENDA                                    */
{admcab.i}
{alcis/tpalcis.i}
def var setbcod-ant like setbcod.

setbcod-ant = setbcod.

setbcod = 900.

def var  par-tipo as char init "CONF".

find tipo-alcis where tipo-alcis.tp = par-tipo  no-lock.

def new shared temp-table tt-pedid like pedid.
def new shared temp-table tt-liped like liped.
def new shared temp-table tt-plani like plani.
def new shared temp-table tt-movim like movim.
def new shared temp-table tt-movimimp like movimimp.

def temp-table ttarq
    field Arquivo   as char format "x(15)"
    field etbori    like wmsarq.etbori  column-label "Origem"
    field etbdes    like wmsarq.etbdes  column-label "Desti"
    field Itens     like wmsarq.itens   column-label "Itens"
    field Qtd       as   dec format ">>,>>>,>>9" column-label "Quantidade"   
    field npedido   like pedid.pednum
    field DataREAL  as date format "99/99/9999" column-label "Data"
    field HoraREAL  as char format "xxxxx" column-label "Hora"
    field Sit       as log format "OK/NOK" initial no 
    field motivo as char format "x(100)"
    index dataa is primary DataREAL asc horareal asc Arquivo ASC .
    
    
def var recatu1         as recid.
def var reccont         as int.
def var esqpos1         as int.
def var esqcom1         as char format "x(12)" extent 5
    initial [" Consulta "," Emissao NFE" ,""].

form
    esqcom1
    with frame f-com1 row 4 no-box no-labels column 1 centered.

assign
    esqpos1  = 1.

run diretorio.    

bl-princ:
repeat:
    disp esqcom1 with frame f-com1.
    if recatu1 = ?
    then run leitura (input "pri").
    else find ttarq where recid(ttarq) = recatu1 no-lock.
    if not available ttarq
    then do.
        message "Sem arquivos para" skip tipo-alcis.tm
                    view-as alert-box.
        leave.
    end.
    clear frame frame-a all no-pause.
    run frame-a.

    recatu1 = recid(ttarq).
    color display message esqcom1[esqpos1] with frame f-com1.
    repeat:
        run leitura (input "seg").
        if not available ttarq
        then leave.
        if frame-line(frame-a) = frame-down(frame-a)
        then leave.
        down with frame frame-a.
        run frame-a.
    end.
    up frame-line(frame-a) - 1 with frame frame-a.

    repeat with frame frame-a:

        find ttarq where recid(ttarq) = recatu1 no-lock.
        find tipo-alcis where tipo-alcis.tp = substr(ttarq.arquivo,1,4) no-lock.

            status default "".

            run color-message.
            choose field ttarq.Arquivo 
                help "Refresh de 15 segundos"
                pause 15
                go-on(cursor-down cursor-up
                      cursor-left cursor-right
                      page-down   page-up
                      tab PF4 F4 ESC return).
            run color-normal.
            pause 0. 
            if lastkey = -1 
            then do:  
                hide frame frame-a no-pause.
                run diretorio.
                recatu1 = ?.
                next bl-princ. 
            end.
                                                                
            status default "".

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
                    if not avail ttarq
                    then leave.
                    recatu1 = recid(ttarq).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "page-up"
            then do:
                do reccont = 1 to frame-down(frame-a):
                    run leitura (input "up").
                    if not avail ttarq
                    then leave.
                    recatu1 = recid(ttarq).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "cursor-down"
            then do:
                run leitura (input "down").
                if not avail ttarq
                then next.
                color display white/red ttarq.Arquivo with frame frame-a.
                if frame-line(frame-a) = frame-down(frame-a)
                then scroll with frame frame-a.
                else down with frame frame-a.
            end.
            if keyfunction(lastkey) = "cursor-up"
            then do:
                run leitura (input "up").
                if not avail ttarq
                then next.
                color display white/red ttarq.Arquivo with frame frame-a.
                if frame-line(frame-a) = 1
                then scroll down with frame frame-a.
                else up with frame frame-a.
            end.
 
        if keyfunction(lastkey) = "end-error"
        then leave bl-princ.

        if keyfunction(lastkey) = "return"
        then do:
            hide frame frame-a no-pause.
            display caps(esqcom1[esqpos1]) @ esqcom1[esqpos1]
                        with frame f-com1.

            if esqcom1[esqpos1] = " Emissao NFE "
            then do.
                if ttarq.sit = no
                then do.
                    message "Arquivo Inconsistente"
                            ttarq.motivo
                            view-as alert-box.
                end.
                else do.
                    for each tt-pedid.
                        delete tt-pedid.
                    end.
                    for each tt-liped .
                        delete tt-liped.
                    end.
                    /* verifica estoque */
                    def var vlinha as char.
                    def var vpedido as char.
                    input from value(alcis-diretorio + "/" + ttarq.arquivo).
                    repeat.
                        import unformatted vlinha.
                        if substr(vlinha,15,8 ) = "CONFH"  /* HEADER */
                        then do.
                            vPedido       =     substr(vlinha, 38  ,   12  ).
                            ttarq.etbdes  = int(substr(vpedido,1,3)).
                            ttarq.npedido = int(substr(vpedido,4)).
                            find pedid where pedid.etbcod = ttarq.etbdes and
                                             pedid.pednum = ttarq.npedido and
                                         pedid.pedtdc = 95 no-lock no-error.
                            if avail pedid
                            then do.
                                create tt-pedid.
                                buffer-copy pedid to tt-pedid.
                            end.
                            next.
                        end.
                        if substr(vlinha,15,8 ) = "CONFI"  
                        then do.
                            find pedid where pedid.etbcod = ttarq.etbdes and
                                             pedid.pednum = ttarq.npedido and
                                         pedid.pedtdc = 95 no-lock no-error.
                            if avail pedid
                            then do.
                                find first liped of pedid where 
                                    liped.procod = int(substr(vlinha,54,40)) 
                                        no-lock no-error.
                                if avail liped
                                then do.
                                    find tt-liped of pedid where
                                     tt-liped.procod = int(substr(vlinha,54,40))
                                                no-error.
                                    if not avail tt-liped 
                                    then  create tt-liped.
                                    buffer-copy liped except lipsep
                                                            to tt-liped .
                                        tt-liped.lipsep = tt-liped.lipsep +
                                        (dec((substr(vlinha,  94  ,   18  ))) /
                                                    1000000000).
                                end.
                            end.
                            next.
                        end.
                    end.
                    input close.
                    def buffer xestoq for estoq.
                    def var vok as log.
                    vok = yes.
                    for each tt-pedid,
                        each tt-liped of tt-pedid.
                        find xestoq where xestoq.etbcod = setbcod and
                                          xestoq.procod = tt-liped.procod
                                                no-lock.
                        if  /*xestoq.estatual >= 0 and */
                           (xestoq.estatual - tt-liped.lipsep) < 0
                        then do:
                             display xestoq.procod  
                               "  Qtd Estoque :" at 5 xestoq.estatual 
                                                    no-label format ">>,>>9.99"
                               "  Qtd Desejada:" at 5 tt-liped.lipsep 
                                                    no-label format ">>,>>9.99"
                                    with frame f-aviso overlay row 10
                                        side-label centered 
                                    title "Estoque nao possui esta Quantidade".
                            vok = no.
                            pause.
                            undo, retry.
                        end.
                        
                    end.
                    if vok = no then next bl-princ.
                    run alcis/conf_acao_nf.p (ttarq.arquivo,
                                              ttarq.npedido,
                                              ttarq.etbdes).
                end.
                run diretorio.
                recatu1 = ?.
                next bl-princ.
            end.

            if esqcom1[esqpos1] = " xxxxxAcaoxxxxx "
            then do.
                sresp = no.
                message "Confirma" tipo-alcis.tm "?" update sresp.
                if sresp and search(tipo-alcis.acao) <> ?
                then do.
                    run value(tipo-alcis.acao) (ttarq.arquivo).
                    pause 1 no-message.
                    run diretorio.
                    recatu1 = ?. 
                    next bl-princ.
                end.
            end.
            if esqcom1[esqpos1] = " Consulta "
            then run value(tipo-alcis.consulta) (ttarq.arquivo).
        end.
        run frame-a.
        display esqcom1[esqpos1] with frame f-com1.
        recatu1 = recid(ttarq).
    end.
    if keyfunction(lastkey) = "end-error"
    then do:
        view frame fc1.
        view frame fc2.
    end.
end.
hide frame f-com1  no-pause.
hide frame frame-a no-pause.

setbcod = setbcod-ant.

procedure frame-a.
    display ttarq  except motivo 
        with frame frame-a 11 down centered color white/red row 5
                title " " + tipo-alcis.tm + " ".
end procedure.

procedure color-message.
    color display message
        ttarq.Arquivo
        ttarq.etbori   Qtd
        ttarq.etbdes
        ttarq.itens 
        ttarq.npedido
        ttarq.DataREAL
        ttarq.HoraREAL
        with frame frame-a.
end procedure.

procedure color-normal.
    color display normal
        ttarq.Arquivo
        ttarq.etbori
        ttarq.etbdes      Qtd
        ttarq.itens 
        ttarq.npedido
        ttarq.DataREAL
        ttarq.HoraREAL
        with frame frame-a.
end procedure.


procedure leitura . 
def input parameter par-tipo as char.
        
if par-tipo = "pri" 
then find first ttarq where true no-lock no-error.
                                             
if par-tipo = "seg" or par-tipo = "down" 
then find next  ttarq where true no-lock no-error.
             
if par-tipo = "up" 
then find prev  ttarq where true no-lock no-error.
        
end procedure.


procedure diretorio.

    def var varquivo as char.
    def var vlinha   as char.
    def var vpedido as char.
    for each ttarq.
        delete ttarq.
    end.

    varquivo = "/admcom/relat/lealcis." + string(time).
    unix silent value("ls " + alcis-diretorio + " > " + varquivo).
    input from value(varquivo).
    
    repeat transaction.
        create ttarq.
        import ttarq.
    
        if par-tipo <> substr(ttarq.arquivo,1,4)
        then do.
            delete ttarq.
            next.
        end.

    end.
    input close.
    unix silent value("rm -f " + varquivo).
    
    for each ttarq.
        itens = 0. 
        qtd = 0.
        input from value(alcis-diretorio + "/" + ttarq.arquivo).
        repeat.
            import unformatted vlinha.
            if substr(vlinha,15,8 ) = "CONFH"  /* HEADER */
            then do.
                ttarq.etbori  = int(substr(vlinha, 26  ,   12  )).
                vPedido       =     substr(vlinha, 38  ,   12  ).
                ttarq.etbdes  = int(substr(vpedido,1,3)).
                ttarq.npedido = int(substr(vpedido,4)).
                ttarq.DataREAL = date(
                                    int(substr(vlinha, 64  ,   2   )),
                                    int(substr(vlinha, 62  ,   2   )),
                                    int(substr(vlinha, 66  ,   4   )) ).
                ttarq.horaREAL = substr(vlinha, 70  ,   5   ).
                find pedid where pedid.etbcod = ttarq.etbdes and
                                 pedid.pednum = ttarq.npedido and
                                 pedid.pedtdc = 95 no-lock no-error.
                ttarq.sit = avail pedid.
                if not avail pedid
                then ttarq.motivo = "Pedido nao Localizado".
                next.
            end.
            if substr(vlinha,15,8 ) = "CONFI"  
            then do.
                find pedid where pedid.etbcod = ttarq.etbdes and
                                 pedid.pednum = ttarq.npedido and
                                 pedid.pedtdc = 95 no-lock no-error.
                itens = itens + 1.
                qtd   = qtd   + 
                     (dec((substr(vlinha,  94  ,   18  ))) /
                                1000000000) .
                if avail pedid
                then do.
                    find first liped of pedid where 
                            liped.procod = int(substr(vlinha,54,40)) 
                            no-error.
                    if not avail liped and not ttarq.motivo matches
                                    "*Produto nao enviado*"
                    then assign ttarq.sit = no
                                ttarq.motivo = ttarq.motivo +
                                               ". Produto nao enviado".
                    else do.
                        find produ of liped no-lock no-error. 
                        if not avail produ and not ttarq.motivo matches
                                    "*Produto nao cadastrado*"
                        then assign ttarq.sit = no
                                    ttarq.motivo = ttarq.motivo +
                                    ". Produto nao cadastrado" 
                                    .
                    end.
                end.
                next.
            end.
        end.
        input close.
        
    end.
    
    
end procedure.
