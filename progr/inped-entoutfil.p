{admcab.i}

{/admcom/progr/loja-com-ecf-def.i} 

if setbcod < 300 then do:
  message "Menu PEDIDO DE ENTREGA EM OUTRA FILIAL disponivel apenas para os quiosques!" view-as alert-box title "  ATENCAO!  ".
  leave.
end.

def buffer bc-estab for estab.
def buffer eestab for estab.
def var etb-entrega like estab.etbcod.
def var dat-entrega as date format "99/99/9999".
def var nome-retirada as char format "x(30)".
def var fone-retirada as char format "x(15)".
def var ven-desti   like clien.clicod.
def var ven-numero  like plani.numero format ">>>>>>>>9".
def var ven-serie   as char format "x(5)".
def var vped-num like pedid.pednum.
def buffer bpedid for pedid.
def buffer bliped for liped.

repeat on endkey undo, return:
    update ven-numero at 15 label "Numero da Venda"
           ven-serie  at 16 label "Serie da venda"
           with frame f-entrega.
    find plani where plani.etbcod = setbcod and
                     plani.emite  = setbcod and
                     plani.serie  = ven-serie and
                     plani.numero = ven-numero
                     no-lock no-error.
    if not avail plani
    then do:
        bell.
        message color red/with
               "Venda ainda não esta na Matriz." skip
               "Favor tentar mais tarde."
                       view-as alert-box.
        undo.
    end.
    update etb-entrega at 16 validate(etb-entrega <> 0,"Filial nao existe")
           label "Filial entrega" with frame f-entrega overlay            row 4 side-label width 70 centered title " Dados para entrega ".
 
    {/admcom/progr/loja-com-ecf.i etb-entrega} 
    if p-loja-com-ecf 
    then do:
        message "Nao e possivel realizar entrega para a loja de
                Santa Catarina." view-as alert-box.
        undo, retry.
    end.

    find first bc-estab where
               bc-estab.etbcod = etb-entrega and
               bc-estab.etbcod <> 22 and
               bc-estab.etbnom begins "DREBES-FIL"
               NO-LOCK NO-ERROR.
    if not avail bc-estab
    then do:
        message color red/with
                "Entrega somente podera ser feita em outra filial."
                                view-as alert-box.
        undo, retry.
    end.
    do on error undo:
        update dat-entrega at 6
               validate(dat-entrega > today,"Data Invalida")
               label "Data previsao de entrega" format "99/99/9999"
                                with frame f-entrega.
        if dat-entrega = ? or
           dat-entrega > today + 30
        then do:
            message color red/with skip
                    "Agendamento maximo = 30 dias" today + 30 skip
                    view-as alert-box .
            undo, retry.
        end.
    end.
    do on error undo:
        update nome-retirada    at 5 label "Nome Responsavel retirada"
                    validate(nome-retirada <> "","Campo obrigatorio.")
                    help "Informe o nome do responsavel pela retirada."
                                        with frame f-entrega.
    end.
    do on error undo:
        update fone-retirada        at 1
               label "Telefone Responsavel retirada"
               validate(fone-retirada <> "","Campo obrigatorio.")
                   help "Informe o Telefone do responsavel pela retirada."
                                      with frame f-entrega.
    end.
    find eestab where eestab.etbcod = etb-entrega no-lock.
            if etb-entrega = setbcod
                        then dat-entrega = ?.

    leave.
end.

def temp-table tt-produ
    field procod like produ.procod
    field movqtm like movim.movqtm
    field rec-movim as recid
    index i1 procod.
    
{setbrw.i}

form tt-produ.procod label "Codigo Produto"
     produ.pronom    label "Nome Produto"
     tt-produ.movqtm label "Quantidade"
     with frame f-linha down width 80.

def var vpeda as log.
vpeda = no.
for each movim where movim.etbcod = plani.etbcod and
                     movim.placod = plani.placod and
                     movim.movtdc = plani.movtdc and
                     movim.movdat = plani.pladat
                     no-lock:
    find produ where produ.procod = movim.procod no-lock no-error.
    if not avail produ then next.
    if produ.proipiper = 98 then next.
    if produ.catcod <> 31 then next.
    if produ.pronom matches "*recarga*" then next.
    create tt-produ.
    assign tt-produ.procod = produ.procod
           tt-produ.movqtm = movim.movqtm
           tt-produ.rec-movim = recid(movim)
           .
    find pedaxnf where pedaxnf.tpreg  = plani.serie  and
                       pedaxnf.etbcod = movim.etbcod and
                       pedaxnf.movtdc = movim.movtdc and
                       pedaxnf.placod = movim.placod and
                       pedaxnf.procod = movim.procod and
                       pedaxnf.pladat = movim.movdat
              no-lock no-error.
    if avail pedaxnf and pedaxnfv.situacao = "ESP"
    then do:
        find first pedid where 
                   pedid.etbcod = pedaxnf.etbcod and
                   pedid.pednum = pedaxnf.pednum and
                   pedid.pedtdc = 3
        no-lock no-error.
        if avail pedid
        then do:           
            vpeda = yes.
            leave.
        end.
    end.          
end.    
if vpeda = yes
then do:
    message color red/with
    "Pedido ja gerado anteriormente." skip
    "Impossivel continuar."
    view-as alert-box.
    return.
end.
    
find first tt-produ where tt-produ.procod > 0 no-lock no-error.
if not avail tt-produ
then do:
    message color red/with
        "Nenhum produto de MOVEIS encontrado na venda informada."
        view-as alert-box.
    return.    
end.

l1: repeat:
    assign
        a-seeid = -1 a-recid = -1 a-seerec = ?.
    hide frame f-linha no-pause.
    clear frame f-linha all.
    {sklclstb.i  
        &color = with/cyan
        &file = tt-produ  
        &cfield = tt-produ.procod
        &help = "Enter=Altera F1=Gera pedido F4=Retorna"
        &noncharacter = /* 
        &ofield = " produ.pronom when avail produ
                    tt-produ.movqtm
                    "  
        &aftfnd1 = " find produ where produ.procod = tt-produ.procod
                     no-lock no-error.
                     "
        &where  = " true "
        &aftselect1 = " if keyfunction(lastkey) = ""return""
                        then update tt-produ.movqtm  with frame f-linha.
                        "
                    
        &go-on = TAB 
        &naoexiste1 = " run inclui. 
                        if keyfunction(lastkey) = ""end-error""
                        then leave keys-loop.
                        else next l1.
                         " 
        &otherkeys1 = " if keyfunction(lastkey) = ""GO""
                        then leave keys-loop.
                        if keyfunction(lastkey) = ""i""
                        then do:
                            run inclui.
                            next l1.
                        end.    
                        else if keyfunction(lastkey) = ""e""
                            then do:
                                run exclui.
                                next l1.
                            end.    
                      "
        &locktype = " "
        &form   = " frame f-linha "
    }   
    if keyfunction(lastkey) = "end-error"
    then DO:
        sresp = no.
        message "Confirma sair sem gravar?" update sresp.
        if sresp
        then leave l1.       
    END.
    def var vped like pedid.pednum.
    def var vped-ant like pedid.pednum.
    vped = 0.
    vped-ant = 0.
    if keyfunction(lastkey) = "GO"
    then DO:
        sresp = no.
        message "Confirma gerar pedido ENTREGA OUTRA FILIAL?"
        update sresp.
        if sresp 
        then do:
            for each tt-produ where tt-produ.procod > 0:
                find movim where recid(movim) = tt-produ.rec-movim .
                find first pedaxnf where pedaxnf.tpreg  = plani.serie  and
                               pedaxnf.etbcod = movim.etbcod and
                               pedaxnf.movtdc = movim.movtdc and
                               pedaxnf.placod = movim.placod and
                               pedaxnf.procod = movim.procod and
                               pedaxnf.pladat = movim.movdat and
                               pedaxnf.situacao <> "ESP"
                         no-error.
                if avail pedaxnf
                then do on error undo:
                    find first pedid where 
                               pedid.etbcod = pedaxnf.etbcod and
                               pedid.pednum = pedaxnf.pednum and
                               pedid.pedtdc = 3
                               no-error.
                    if avail pedid and
                             pedid.sitped = "E"
                    then do:
                        for each liped of pedid where
                                 liped.procod = movim.procod:
                            delete liped.       
                        end.
                        find first liped of pedid no-error.
                        if not avail liped
                        then delete pedid.
                    end.   
                    delete pedaxnfv.
                end.     
                find first pedaxnf where pedaxnf.tpreg  = plani.serie  and
                               pedaxnf.etbcod = movim.etbcod and
                               pedaxnf.movtdc = movim.movtdc and
                               pedaxnf.placod = movim.placod and
                               pedaxnf.procod = movim.procod and
                               pedaxnf.pladat = movim.movdat and
                               pedaxnf.situacao = "ESP"
                         no-lock no-error.
                if not avail pedaxnf
                then do on error undo:
                    do transaction:
                        com.movim.ocnum[9] = com.movim.placod.
                    end.
                    find last com.pedid where
                              com.pedid.pedtdc = 3 and
                              com.pedid.sitped = "E" and
                              com.pedid.etbcod = etb-entrega and
                              com.pedid.pednum >= 100000 and
                              com.pedid.peddat = dat-entrega and
                              com.pedid.modcod = "PEDO" and
                              com.pedid.clfcod = com.movim.desti
                          no-error.
                    if not avail com.pedid 
                    then do transaction:
                        find last bpedid where bpedid.pedtdc = 3 and
                                  bpedid.etbcod = etb-entrega and
                                  bpedid.pednum >= 100000 no-error.
                        if avail bpedid
                        then vped-num = bpedid.pednum + 1.
                        else vped-num = 100000.
                        
                        create com.pedid.
                        assign com.pedid.etbcod = etb-entrega
                               com.pedid.pedtdc = 3
                               com.pedid.peddat = dat-entrega
                               com.pedid.pednum = vped-num
                               com.pedid.sitped = "E"
                               com.pedid.modcod = "PEDO"
                               com.pedid.pedsit = yes
                               com.pedid.clfcod = com.movim.desti
                               com.pedid.vencod = com.movim.etbcod
                               com.pedid.frecod = com.movim.placod
                               com.pedid.condat = com.movim.movdat
                               .
                    end.
                    find first com.liped where
                               com.liped.etbcod = com.pedid.etbcod
                           and com.liped.pedtdc = com.pedid.pedtdc
                           and com.liped.pednum = com.pedid.pednum
                           and com.liped.procod = com.movim.procod
                           no-error.
                    if not avail com.liped
                    then do transaction:
                        create com.liped.
                        assign 
                            com.liped.pedtdc    = com.pedid.pedtdc
                            com.liped.pednum    = com.pedid.pednum
                            com.liped.procod    = com.movim.procod
                            com.liped.lippreco  = com.movim.movpc
                            com.liped.lipsit    = "E"
                            com.liped.predtf    = com.pedid.peddat
                            com.liped.predt     = com.pedid.peddat
                            com.liped.etbcod    = com.pedid.etbcod
                            com.liped.protip = string(com.movim.movhr)
                            com.liped.prehr     = com.movim.movhr
                            com.liped.venda-placod = com.movim.placod
                              .
                
 
                        create pedaxnfv.
                        assign
                            pedaxnfv.tpreg    = plani.serie
                            pedaxnfv.etbcod   = movim.etbcod
                            pedaxnfv.movtdc   = movim.movtdc
                            pedaxnfv.placod   = movim.placod
                            pedaxnfv.numero   = plani.numero
                            pedaxnfv.pladat   = plani.pladat
                            pedaxnfv.datgera  = today
                            pedaxnfv.horgera  = time
                            pedaxnfv.procod   = movim.procod
                            pedaxnfv.movqtm   = movim.movqtm
                            pedaxnfv.movpc    = movim.movpc
                            pedaxnfv.pednum   = pedid.pednum
                            /*pedaxnfv.estcusto = 0
                            pedaxnfv.estvenda = 0
                            pedaxnfv.estloja  = 0
                            pedaxnfv.estdep   = 0
                            pedaxnfv.qtdmix   = 0
                            pedaxnfv.sugerido = 0
                            pedaxnfv.qtdpedido   = 0
                            pedaxnfv.qtdconjunto = 0
                            pedaxnfv.ajustemin   = 0
                            pedaxnfv.ajustemix   = 0
                            pedaxnfv.entregaout  = 0
                            pedaxnfv.mixdifer = 0
                            pedaxnfv.prosubst = 0
                            pedaxnfv.ajusub   = 0
                            pedaxnfv.estsub   = 0*/
                            pedaxnfv.situacao = "ESP".   
 
                    end. 
                    do transaction:
                        com.liped.lipqtd = com.liped.lipqtd +
                                                com.movim.movqtm.
                        com.pedid.pedobs[5] = com.pedid.pedobs[5] +
                        string(movim.placod) + "=" + string(movim.procod)
                        + "|".
                    end.
                    find first pedaxnf where pedaxnf.tpreg  = plani.serie  and
                               pedaxnf.etbcod = movim.etbcod and
                               pedaxnf.movtdc = movim.movtdc and
                               pedaxnf.placod = movim.placod and
                               pedaxnf.procod = movim.procod and
                               pedaxnf.pladat = movim.movdat
                         no-error.
                    if avail pedaxnf
                    then vped = pedaxnf.pednum.
                end.
                else vped-ant = pedaxnf.pednum.
            end.
            if vped > 0
            then do:
                        message color red/with
                        "Pedido gerado " vped
                        view-as alert-box.
                        leave l1.
                    end.
            else if vped-ant > 0
            then do:
                    message color red/with
                    "Pedido gerado anteriormente " vped-ant
                    view-as alert-box.
                end.
        end.
    end.
end.

procedure exclui:
    find first tt-produ where recid(tt-produ) = a-seerec[frame-line].
    sresp = no.
    message "Confirma excluir?" update sresp.
    if sresp
    then do:
        delete tt-produ.
    end.
end procedure. 
procedure inclui:
    scroll from-current down with frame f-linha.
    repeat on endkey undo, leave:
            prompt-for tt-produ.procod with frame f-linha
            .
            find produ where produ.procod = 
                input frame f-linha tt-produ.procod
                no-lock no-error.
            if not avail produ
            then do:
                bell.
                message "Produto nao cadastrado.".
                pause .

                undo.
            end.        
            if produ.catcod <> 31
            then do:
                bell.
                message color red/with
                "Somente MOVEIS."
                view-as alert-box.
                undo.
            end.
            disp produ.pronom with frame f-linha.
            prompt-for tt-produ.movqtm with frame f-linha.
            if input frame f-linha tt-produ.movqtm = 0 or
               input frame f-linha tt-produ.movqtm > 5
            then do:
                bell.
                message "Quantidade nao permitida".
                pause.
                undo.
            end.   
            create tt-produ.
            assign
                tt-produ.procod = input frame f-linha tt-produ.procod
                tt-produ.movqtm = input frame f-linha tt-produ.movqtm
                .

        leave.
    end.    
end procedure.
