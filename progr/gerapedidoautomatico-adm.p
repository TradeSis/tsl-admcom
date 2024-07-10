/*neo_piloto - 17.06.2019 - nao gerar para lojas no piloto*/
{/admcom/progr/abas/neo_piloto.i}

/* Projeto Melhorias Mix - Luciano   */

/* 
#1 Claudir VEX Moda
#2 Claudir TP 27670774
#3 12.12.18 - Ricardo - Tratamento de lock
**/

{/admcom/progr/admcab-batch.i new}
setbcod = 999.
sfuncod = 101.

def shared var varqlog as char.
def shared var vhoraini as int.

def var vmodcod like pedid.modcod.
def var p-corte as log init no .
def var p-prosub like produ.procod.
def var p-ajsub  like estoq.estatual.
def var p-pednum like pedid.pednum.
def var est-prosubst like estoq.estatual.
def var est-deposito like estoq.estatual.
 
def var p-teste as log init no.
def var p-etbcod like estab.etbcod.
p-teste = no.
p-etbcod = 0.
 
FUNCTION acha-pro returns character
    (input par-oque as char,
     input par-onde as char,
     input par-proc as char).
         
    def var vx as int.
    def var vret as char.  
    
    vret = ?.  
    
    do vx = 1 to num-entries(par-onde,"|"). 
        if entry(1,entry(vx,par-onde,"|"),"=") = par-oque 
        then do: 
            vret = entry(2,entry(vx,par-onde,"|"),"="). 
            if vret = par-proc
            then leave. 
        end. 
    end.
    return vret. 
END FUNCTION.
 
def var p-ok as log.
def var v-peda as log.
def var p-sugerido as dec.
def var vmovqtm as dec.
def var qtd-conjunto as dec.
def var vpednum like pedid.pednum.
def var vaj-min as dec.
def var vaj-mix as dec.
def var qtd-mix as int.
def var qtd-estoque as dec.
def var qtd-pedido as int.
def var ventrega-out as dec.
             
def buffer bpedid for pedid.

def new shared temp-table tt-proped
    field etbcod like estab.etbcod
    field pladat like plani.pladat
    field placod like plani.placod
    field numero like plani.numero
    field procod like produ.procod
    field movqtm like movim.movqtm
    field sugere like p-sugerido
    field tipo   as char  
    field whr    as int
    field pednum as int.  

def var vdtinicio as date.
def var vhrinicio as int.
def var vdtfim as date init today.
def var vhrfim as int.
def var vfilial as int.
def var vlinha as char.

procedure ver-corte.
    assign
        vdtinicio = ?
        vhrinicio = 0
        vdtfim = today
        vhrfim = 0
        vfilial = 0
        vlinha = "".
    
    input from /admcom/logs/log-corte-cnt-mix.log.
    repeat:
        import unformatted vlinha.
        if entry(1,vlinha,";") = "#INICIO"
        then assign
            vdtinicio = date(entry(2,vlinha,";"))
            vhrinicio = int(entry(3,vlinha,";"))
            vdtfim = ? /*30/05/2011*/
            .
        else if entry(1,vlinha,";") = "#FILIAL"
            then vfilial = int(entry(2,vlinha,";")).
            else if entry(1,vlinha,";") = "#FIM"
                then assign
                        vdtfim = date(entry(2,vlinha,";"))
                        vhrfim = int(entry(3,vlinha,";"))
                        .
                else if vdtinicio = ? then vdtfim = today.
    end.
    if  vdtfim <> ? and
        vdtfim <> today
    then vdtfim = today.

    p-corte = no.
    if vdtinicio <> ? and vdtfim = ? and p-teste = no
    then do:
        p-corte = yes.
        output to value(varqlog) append.
        put "#WMSCORTE;" string(vdtinicio) ";" vhrinicio ";"
                        time skip .
        output close.
    end.
end procedure.

def var vdtven as date.

def var mix-difer as log.
def var v-time as int.

/*
p-corte = no.
run ver-corte.
if p-corte
then do:
    pause 60.
    return.
end.  
*/
def temp-table tt-movim like movim.

output to value(varqlog) append.
        put "#SEL MOVIM;" string(estab.etbcod) ";" 
                time skip .
output close.

def temp-table tt-ltr
    field etbcod like estab.etbcod
    field hora as int
    field hora-venda as int
    index i1 etbcod
    .
 
for each tt-ltr.
    delete tt-ltr.
end.
for each estab where estab.etbnom begins "DREBES-FIL" no-lock:
    if estab.etbcod >= 400 or estab.etbcod = 200 
        then next.
    create tt-ltr.
    tt-ltr.etbcod = estab.etbcod.
    tt-ltr.hora = time.
end.

for each produ where produ.catcod = 31 no-lock:

    if produ.proipiper = 98 then next.
    
    if produ.procod = 10000 then next.
            
    if produ.pronom matches "*RECARGA*"  or
       produ.pronom matches "*FRETEIRO*" 
    then next.

    if produ.pronom begins "*"
    then do:
        find estoq where estoq.etbcod = 900 and
                         estoq.procod = produ.procod 
                   no-lock no-error.
        if not avail estoq or
           estoq.estatual <= 0
        then next.                 
    end.
            
    for each movim where movim.procod = produ.procod and
                         movim.movtdc = 5 and
                         movim.movdat >= today - 2
                   no-lock,
        first estab where estab.etbcod = movim.etbcod and
                          estab.etbnom begins "DREBES-FIL"
                          no-lock:
        if estab.etbcod >= 400 or estab.etbcod = 200
        then next.                  
        
        if p-etbcod > 0 and estab.etbcod <> p-etbcod
        then next.
         
        if movim.movdat = today and p-teste = no
        then do:
            find first tt-ltr where tt-ltr.etbcod = movim.etbcod no-error.
            if not avail tt-ltr
            then do:
                create tt-ltr.
                tt-ltr.etbcod = movim.etbcod.
                tt-ltr.hora = time.
            end.
            if tt-ltr.hora-venda < movim.movhr
            then tt-ltr.hora-venda = movim.movhr.
        end.

        find first plani where plani.etbcod = movim.etbcod and
                               plani.placod = movim.placod and
                               /***plani.serie = "V" and 18/02/2015 ***/
                               plani.movtdc = movim.movtdc
                         no-lock.

        /* Pedido Especial */
        if movim.ocnum[9] = movim.placod
        then do /*#3*/ on error undo:                          
            find pedaxnf where pedaxnf.tpreg  = plani.serie  and
                               pedaxnf.etbcod = movim.etbcod and
                               pedaxnf.movtdc = movim.movtdc and
                               pedaxnf.placod = movim.placod and
                               pedaxnf.procod = movim.procod and
                               pedaxnf.pladat = movim.movdat
                         exclusive no-wait /*#3*/
                         no-error.
            if not avail pedaxnfv
            then do.
                /*#3*/
                if locked pedaxnfv
                then next.

                create pedaxnfv.
            end.
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
                pedaxnfv.estcusto = estoq.estcusto
                pedaxnfv.estvenda = estoq.estvenda
                pedaxnfv.estloja  = qtd-estoque
                pedaxnfv.estdep   = est-deposito
                pedaxnfv.qtdmix   = qtd-mix
                pedaxnfv.sugerido = p-sugerido
                pedaxnfv.qtdpedido   = qtd-pedido
                pedaxnfv.qtdconjunto = qtd-conjunto
                pedaxnfv.ajustemin   = vaj-min
                pedaxnfv.ajustemix   = vaj-mix
                pedaxnfv.entregaout  = ventrega-out
                pedaxnfv.mixdifer = mix-difer
                pedaxnfv.prosubst = p-prosub
                pedaxnfv.ajusub   = p-ajsub
                pedaxnfv.estsub   = est-prosubst
                pedaxnfv.situacao = "ESP".   
            next.
        end.
                
        find pedaxnf where pedaxnf.tpreg  = plani.serie and
                           pedaxnf.etbcod = movim.etbcod and
                           pedaxnf.movtdc = movim.movtdc and
                           pedaxnf.placod = movim.placod and
                           pedaxnf.procod = movim.procod and
                           pedaxnf.pladat = movim.movdat
                           exclusive no-wait no-error. /*#2*/
        if avail pedaxnf and pedaxnf.situacao <> ""
        then next.
        else if locked pedaxnf /*#2*/
            then next.

        find first movimaux where movimaux.etbcod      = movim.etbcod AND
                                  movimaux.placod      = movim.placod AND
                                  movimaux.procod      = movim.procod AND
                                  movimaux.nome_campo  = "PEDIDO_AUTOMATICO"
                            no-lock no-error.
        if avail movimaux and movimaux.valor_campo <> ""
        then next.

        create tt-movim.
        buffer-copy movim to tt-movim. 
        
        do on error undo.
            find first movimaux where movimaux.etbcod     = movim.etbcod AND
                                      movimaux.placod     = movim.placod AND
                                      movimaux.procod     = movim.procod AND
                                      movimaux.nome_campo = "PEDIDO_AUTOMATICO"
                                      no-error.
            if not avail movimaux
            then do.
                create movimaux.
                ASSIGN movimaux.etbcod      = movim.etbcod 
                       movimaux.placod      = movim.placod 
                       movimaux.procod      = movim.procod 
                       movimaux.nome_campo  = "PEDIDO_AUTOMATICO"
                       movimaux.valor_campo = "".
            end.
            assign 
                   movimaux.movtdc      = movim.movtdc
                   movimaux.tipo_campo  = "LINX"
                   movimaux.datexp      = today
                   movimaux.exportar    = no.
        end.
    end.
end.
/*#1-ini*/  

for each produ where produ.catcod = 41 and produ.ind_vex no-lock:

    if produ.pronom begins "*"
    then do:
        find estoq where estoq.etbcod = 900 and
                         estoq.procod = produ.procod 
                   no-lock no-error.
        if not avail estoq or
           estoq.estatual <= 0
        then next.                 
    end.

    for each movim where movim.procod = produ.procod and
                         movim.movtdc = 5 and
                         movim.movdat >= today - 2
                   no-lock,
        first estab where estab.etbcod = movim.etbcod and
                          estab.etbnom begins "DREBES-FIL"
                          no-lock:
        if estab.etbcod >= 400 or estab.etbcod = 200
        then next.                  
        
        if p-etbcod > 0 and estab.etbcod <> p-etbcod
        then next.
         
        if movim.movdat = today and p-teste = no
        then do:
            find first tt-ltr where tt-ltr.etbcod = movim.etbcod no-error.
            if not avail tt-ltr
            then do:
                create tt-ltr.
                tt-ltr.etbcod = movim.etbcod.
                tt-ltr.hora = time.
            end.
            if tt-ltr.hora-venda < movim.movhr
            then tt-ltr.hora-venda = movim.movhr.
        end.

        find first plani where plani.etbcod = movim.etbcod and
                               plani.placod = movim.placod and
                               plani.movtdc = movim.movtdc
                         no-lock no-error.
        if not avail plani then next.                 

        find pedaxnf where pedaxnf.tpreg  = plani.serie and
                           pedaxnf.etbcod = movim.etbcod and
                           pedaxnf.movtdc = movim.movtdc and
                           pedaxnf.placod = movim.placod and
                           pedaxnf.procod = movim.procod and
                           pedaxnf.pladat = movim.movdat
                           exclusive no-wait no-error. /*#2*/
        if avail pedaxnf and pedaxnf.situacao <> ""
        then next.
        else if locked pedaxnf /*#2*/
            then next.

        find first movimaux where movimaux.etbcod      = movim.etbcod AND
                                  movimaux.placod      = movim.placod AND
                                  movimaux.procod      = movim.procod AND
                                  movimaux.nome_campo  = 
                                    "PEDIDO_AUTOMATICO_VEXM"
                            no-lock no-error.
        if avail movimaux and movimaux.valor_campo <> ""
        then next.
        
        create tt-movim.
        buffer-copy movim to tt-movim. 
        
        do on error undo.
            find first movimaux where movimaux.etbcod     = movim.etbcod AND
                                      movimaux.placod     = movim.placod AND
                                      movimaux.procod     = movim.procod AND
                                      movimaux.nome_campo = 
                                            "PEDIDO_AUTOMATICO_VEXM"
                                      no-error.
            if not avail movimaux
            then do.
                create movimaux.
                ASSIGN movimaux.etbcod      = movim.etbcod 
                       movimaux.placod      = movim.placod 
                       movimaux.procod      = movim.procod 
                       movimaux.nome_campo  = "PEDIDO_AUTOMATICO_VEXM"
                       movimaux.valor_campo = "".
            end.
            assign 
                   movimaux.movtdc      = movim.movtdc
                   movimaux.tipo_campo  = "LINX"
                   movimaux.datexp      = today
                   movimaux.exportar    = no.
        end.
    end.
end.   
/*#1-fim*/

if vhoraini = 0 or
   time > vhoraini + (3600) 
then do:   
    if p-teste = no
    then run envia-info.
    vhoraini = time.
end.

p-corte = no.
run ver-corte.

if p-corte then return.
 
for each estab where estab.etbnom begins "DREBES-FIL" no-lock:
    if estab.etbcod > 400 or estab.etbcod = 200
    then next.
 
    if p-teste = no
    then do:
        output to value(varqlog) append.
        put "#FILIAL;" string(estab.etbcod) ";" 
                time skip .
        output close.

        p-corte = no.
        run ver-corte.
        if p-corte then leave.
    end.

    for each tt-proped: delete tt-proped. end.
    
    pause 2 no-message.
        
    v-time = time.

    for each tt-movim where tt-movim.etbcod = estab.etbcod no-lock,
        first movim of tt-movim no-lock,
        produ where produ.procod = movim.procod no-lock,
        first plani where plani.etbcod = movim.etbcod and
                          plani.placod = movim.placod and
                          plani.movtdc = movim.movtdc 
                          no-lock:
        p-corte = no.
        run ver-corte.
        if p-corte then leave. 

        find  pedaxnf where pedaxnf.tpreg  = plani.serie and
                            pedaxnf.etbcod = plani.etbcod and
                            pedaxnf.movtdc = plani.movtdc and
                            pedaxnf.placod = plani.placod and
                            pedaxnf.procod = movim.procod and
                            pedaxnf.pladat = plani.pladat
                            exclusive no-wait no-error. /*#2*/
        if avail pedaxnf and pedaxnf.situacao <> ""
        then next.
        else if locked pedaxnf   /*#2*/
            then next.
            
        assign                    
            p-ok = no
            p-sugerido = 0
            vmovqtm = 0
            qtd-conjunto = 0
            qtd-estoque = 0
            vaj-min = 0
            vaj-mix = 0
            qtd-pedido = 0
            qtd-mix = 0
            ventrega-out = 0
            p-prosub = 0
            p-ajsub = 0
            p-pednum = 0
            est-prosubst = 0
            est-deposito = 0.
        
        if produ.catcod = 41 and not produ.ind_vex then next.

        if produ.catcod = 31
        then do:
            run /admcom/progr/gerapedidoautomatico-valida-mix.p 
                                   (input recid(plani),
                                    input p-teste,
                                    input movim.procod,
                                    input movim.movqtm,
                                    input movim.etbcod,
                                    output qtd-estoque,
                                    output p-ok,
                                    output qtd-mix,
                                    output qtd-pedido,
                                    output p-sugerido,
                                    output vmovqtm,
                                    output qtd-conjunto,
                                    output vaj-min,
                                    output vaj-mix,
                                    output ventrega-out,
                                    output mix-difer,
                                    output p-prosub,
                                    output p-ajsub,
                                    output p-pednum,
                                    output est-prosubst,
                                    output est-deposito ).
    
        if p-teste = yes
        then do:
            disp produ.procod
                 produ.pronom
                 movim.movqtm
                 movim.etbcod
                 p-ok
                 qtd-mix        label "Mix"
                 qtd-pedido     label "Pedido"
                 qtd-estoque    label "Estoque"
                 qtd-conjunto   label "Conjunto"
                 p-sugerido     label "Sugerido"
                 vaj-min        label "Ajuste-minimo"
                 vaj-mix        label "Ajuste-mix"
                 ventrega-out   label "Entrega-outfi"
                 mix-difer      label "Mix-Diferenciado"
                 with 1 column.
        end.
        else do on error undo /*transaction*/:
                        p-corte = no.
                        run ver-corte.
                        if p-corte then leave.
                        
                        output to value(varqlog) append.
                        put "#COBERTURA;" v-time ";" plani.etbcod ";" 
                            plani.placod format ">>>>>>>>>9" ";"
                            produ.procod  format ">>>>>>>>>9" ";"
                            movim.movqtm ";" p-ok ";" qtd-mix ";"
                            qtd-pedido ";" qtd-estoque format "->>>>9" ";" 
                            qtd-conjunto ";"
                            p-sugerido ";" vaj-min ";" vaj-mix ";" 
                            ventrega-out ";"
                            mix-difer ";"
                            skip.
                        output close.

                        find pedaxnf where pedaxnf.tpreg = plani.serie and
                               pedaxnf.etbcod = plani.etbcod and
                               pedaxnf.movtdc = plani.movtdc and
                               pedaxnf.placod = plani.placod and
                               pedaxnf.procod = movim.procod and
                               pedaxnf.pladat = plani.pladat
                               no-error.
                        if not avail pedaxnf
                        then create pedaxnfv.
                        assign
                            pedaxnfv.tpreg    = plani.serie
                            pedaxnfv.etbcod   = plani.etbcod
                            pedaxnfv.movtdc   = plani.movtdc
                            pedaxnfv.placod   = plani.placod
                            pedaxnfv.numero   = plani.numero
                            pedaxnfv.pladat   = plani.pladat
                            pedaxnfv.datgera  = today
                            pedaxnfv.horgera  = time
                            pedaxnfv.procod   = movim.procod
                            pedaxnfv.movqtm   = movim.movqtm
                            pedaxnfv.movpc    = movim.movpc
                            pedaxnfv.estcusto = estoq.estcusto
                            pedaxnfv.estvenda = estoq.estvenda
                            pedaxnfv.estloja  = qtd-estoque
                            pedaxnfv.estdep   = est-deposito
                            pedaxnfv.qtdmix   = qtd-mix
                            pedaxnfv.sugerido = p-sugerido
                            pedaxnfv.qtdpedido   = qtd-pedido
                            pedaxnfv.qtdconjunto = qtd-conjunto
                            pedaxnfv.ajustemin       = vaj-min
                            pedaxnfv.ajustemix       = vaj-mix
                            pedaxnfv.entregaout  = ventrega-out
                            pedaxnfv.mixdifer    = mix-difer
                            pedaxnfv.prosubst    = p-prosub
                            pedaxnfv.ajusub     = p-ajsub
                            pedaxnfv.estsub      = est-prosubst
                            .   

                        if p-pednum > 0 and
                           p-ajsub > 0
                        then assign
                            pedaxnfv.pednum = p-pednum
                            pedaxnfv.situacao = "AJS"
                            p-ok = no.
                        else if p-ok = no
                        then pedaxnfv.situacao = "OKN".  
        end.     

        if p-ok = no then next.
            
        if p-teste = no
        then do on error undo /*transaction*/:

            if p-sugerido > 0 
            then do:
                vmodcod = "PEDA".
                run cria-pedido.
            end. 
            else if p-sugerido <= 0 
            then do:
 
                            assign
                                pedaxnfv.pednum = 0
                                pedaxnfv.situacao = "NSU".
 
                            create tt-proped.
                            assign
                                tt-proped.etbcod = plani.etbcod
                                tt-proped.pladat = plani.pladat
                                tt-proped.placod = plani.placod
                                tt-proped.numero = plani.numero
                                tt-proped.procod = movim.procod
                                tt-proped.movqtm = movim.movqtm
                                tt-proped.sugere = p-sugerido
                                tt-proped.whr = v-time.
            end.
        end.
        if p-corte then leave.
        end.
        else if produ.catcod = 41
        then do on error undo /*transaction*/:
        
            p-sugerido = movim.movqtm.
            vmodcod = "VEXM".
        
                        find pedaxnf where pedaxnf.tpreg = plani.serie and
                               pedaxnf.etbcod = plani.etbcod and
                               pedaxnf.movtdc = plani.movtdc and
                               pedaxnf.placod = plani.placod and
                               pedaxnf.procod = movim.procod and
                               pedaxnf.pladat = plani.pladat
                               no-error.
                        if not avail pedaxnf
                        then create pedaxnfv.
                        assign
                            pedaxnfv.tpreg    = plani.serie
                            pedaxnfv.etbcod   = plani.etbcod
                            pedaxnfv.movtdc   = plani.movtdc
                            pedaxnfv.placod   = plani.placod
                            pedaxnfv.numero   = plani.numero
                            pedaxnfv.pladat   = plani.pladat
                            pedaxnfv.datgera  = today
                            pedaxnfv.horgera  = time
                            pedaxnfv.procod   = movim.procod
                            pedaxnfv.movqtm   = movim.movqtm
                            pedaxnfv.movpc    = movim.movpc
                            pedaxnfv.estcusto = estoq.estcusto
                            pedaxnfv.estvenda = estoq.estvenda
                            pedaxnfv.estloja  = qtd-estoque
                            pedaxnfv.estdep   = est-deposito
                            pedaxnfv.qtdmix   = qtd-mix
                            pedaxnfv.sugerido = p-sugerido
                            pedaxnfv.qtdpedido   = qtd-pedido
                            pedaxnfv.qtdconjunto = qtd-conjunto
                            pedaxnfv.ajustemin       = vaj-min
                            pedaxnfv.ajustemix       = vaj-mix
                            pedaxnfv.entregaout  = ventrega-out
                            pedaxnfv.mixdifer    = mix-difer
                            pedaxnfv.prosubst    = p-prosub
                            pedaxnfv.ajusub     = p-ajsub
                            pedaxnfv.estsub      = est-prosubst
                            .   
            run cria-pedido-VEXM.    
        end.
    end.
    if p-teste = no
    then do:
        output to value(varqlog) append.
        for each tt-proped:
            export tt-proped.
        end.
        output close.
    end.
    for each tt-proped: delete tt-proped. end.
    if p-corte then leave.
end.    

for each tt-proped: delete tt-proped. end.
def var recid_pedid  as recid.

procedure cria-pedido:

    /*
    find last pedid where pedid.etbcod = movim.etbcod and
                          pedid.pedtdc = 3 and
                          pedid.pednum >= 100000 and
                          pedid.sitped = "E" and
                          pedid.peddat = today and
                          pedid.modcod = vmodcod
                          exclusive no-wait no-error.
    */
    if true  /*not avail pedid */
    then do:
        if false /*locked pedid*/
        then.
        else do:
            find last bpedid where  
                      bpedid.etbcod = movim.etbcod  and
                      bpedid.pedtdc = 3 and
                      bpedid.pednum >= 100000
                      no-lock no-error.              
            if avail bpedid
            then vpednum = bpedid.pednum + 1.
            else vpednum = 100000.
    
            create pedid.
            assign pedid.etbcod = movim.etbcod
                            pedid.pedtdc = 3
                            pedid.peddat = movim.movdat /*today*/
                            pedid.pednum = vpednum
                            pedid.sitped = "E"
                            pedid.modcod = vmodcod
                            pedid.pedsit = yes.

                /*neo_piloto*/
                find first ttpiloto where ttpiloto.etbcod  = pedid.etbcod  and
                                          ttpiloto.dtini  <= today
                    no-error.
                if today >= wfilvirada 
                   or avail ttpiloto  /* Troca a Situacao para  Lojas Piloto */
                then com.pedid.sitped = "N".   
                /*neo_piloto*/
                                        
            recid_pedid = recid(pedid).
            find first movimaux where movimaux.etbcod     = movim.etbcod AND
                                      movimaux.placod     = movim.placod AND
                                      movimaux.procod     = movim.procod AND
                                      movimaux.nome_campo = "PEDIDO_AUTOMATICO"
                                      no-error.
            if not avail movimaux
            then do.
                create movimaux.
                ASSIGN movimaux.movtdc      = movim.movtdc 
                       movimaux.etbcod      = movim.etbcod 
                       movimaux.placod      = movim.placod 
                       movimaux.procod      = movim.procod 
                       movimaux.nome_campo  = "PEDIDO_AUTOMATICO"
                       movimaux.valor_campo = string(pedid.pednum)
                       movimaux.tipo_campo  = "LINX"
                       movimaux.datexp      = today
                       movimaux.exportar    = no.
            end.
            else movimaux.valor_campo = string(pedid.pednum).

        end.               
    end.
    find pedid where recid(pedid) = recid_pedid exclusive no-wait no-error.
    /*
    find last pedid where pedid.etbcod = movim.etbcod and
                          pedid.pedtdc = 3 and
                          pedid.pednum >= 100000 and
                          pedid.sitped = "E" and
                          pedid.peddat = today and
                          pedid.modcod = vmodcod
                          exclusive no-wait no-error.
    */
    if avail pedid
    then do:
        find first liped where 
                   liped.etbcod = pedid.etbcod and
                   liped.pedtdc = pedid.pedtdc and
                   liped.pednum = pedid.pednum and
                   liped.procod = movim.procod 
                   exclusive no-wait no-error.
        if not avail liped
        then do:
            if locked liped
            then.
            else do :
                create liped.
                assign liped.pedtdc    = pedid.pedtdc
                           liped.pednum    = pedid.pednum
                           liped.procod    = movim.procod
                           liped.lippreco  = movim.movpc
                           liped.lipsit    = "Z"
                           liped.predtf    = pedid.peddat
                           liped.predt     = pedid.peddat
                           liped.etbcod    = pedid.etbcod
                           liped.protip    = string(movim.movhr)
                           liped.prehr     = movim.movhr
                           liped.venda-placod    = movim.placod
                           .
            end.
        end.
        
        find first liped where 
                   liped.etbcod = pedid.etbcod and
                   liped.pedtdc = pedid.pedtdc and
                   liped.pednum = pedid.pednum and
                   liped.procod = movim.procod 
                   exclusive no-wait no-error.

        if avail liped
        then do:
            if qtd-conjunto > 0
            then liped.lipqtd = liped.lipqtd + p-sugerido.
            else liped.lipqtd = liped.lipqtd + p-sugerido /*movim.movqtm*/.
                                        
            pedid.pedobs[5] = pedid.pedobs[5] +
                    string(movim.placod) + "=" + string(movim.procod) +
                                "|".

            assign
                pedaxnfv.pednum = pedid.pednum
                pedaxnfv.situacao = "AUT".
                
            create tt-proped.
            assign
                        tt-proped.etbcod = plani.etbcod
                        tt-proped.pladat = plani.pladat
                        tt-proped.placod = plani.placod
                        tt-proped.numero = plani.numero
                        tt-proped.procod = movim.procod
                        tt-proped.movqtm = movim.movqtm
                        tt-proped.sugere = p-sugerido
                        tt-proped.tipo = vmodcod
                        tt-proped.whr  = v-time
                        tt-proped.pednum = if avail pedid
                                    then pedid.pednum else 0
                        .
        end.
    end.    
 end procedure.

 procedure cria-pedido-VEXM:

            find last bpedid where  
                      bpedid.etbcod = movim.etbcod  and
                      bpedid.pedtdc = 95 and
                      bpedid.pednum >= 100000
                      no-lock no-error.              
            if avail bpedid
            then vpednum = bpedid.pednum + 1.
            else vpednum = 100000.
    
            create pedid.
            assign pedid.etbcod = movim.etbcod
                            pedid.pedtdc = 95
                            pedid.peddat = movim.movdat /*today*/
                            pedid.pednum = vpednum
                            pedid.sitped = "E"
                            pedid.modcod = vmodcod
                            pedid.pedsit = yes.

                /*neo_piloto*/
                find first ttpiloto where ttpiloto.etbcod  = pedid.etbcod  and
                                          ttpiloto.dtini  <= today
                    no-error.
                if avail ttpiloto  /* Troca a Situacao para  Lojas Piloto */
                then com.pedid.sitped = "N".   
                /*neo_piloto*/

            recid_pedid = recid(pedid).
            find first movimaux where movimaux.etbcod     = movim.etbcod AND
                                      movimaux.placod     = movim.placod AND
                                      movimaux.procod     = movim.procod AND
                                      movimaux.nome_campo = 
                                      "PEDIDO_AUTOMATICO_VEXM"
                                      no-error.
            if not avail movimaux
            then do.
                create movimaux.
                ASSIGN movimaux.movtdc      = movim.movtdc 
                       movimaux.etbcod      = movim.etbcod 
                       movimaux.placod      = movim.placod 
                       movimaux.procod      = movim.procod 
                       movimaux.nome_campo  = "PEDIDO_AUTOMATICO_VEXM"
                       movimaux.valor_campo = string(pedid.pednum)
                       movimaux.tipo_campo  = "LINX"
                       movimaux.datexp      = today
                       movimaux.exportar    = no.
            end.
            else movimaux.valor_campo = string(pedid.pednum).

    find pedid where recid(pedid) = recid_pedid exclusive no-wait no-error.
    if avail pedid
    then do:
        find first liped where 
                   liped.etbcod = pedid.etbcod and
                   liped.pedtdc = pedid.pedtdc and
                   liped.pednum = pedid.pednum and
                   liped.procod = movim.procod 
                   exclusive no-wait no-error.
        if not avail liped
        then do:
            if locked liped
            then.
            else do :
                create liped.
                assign liped.pedtdc    = pedid.pedtdc
                           liped.pednum    = pedid.pednum
                           liped.procod    = movim.procod
                           liped.lippreco  = movim.movpc
                           liped.lipsit    = "Z"
                           liped.predtf    = pedid.peddat
                           liped.predt     = pedid.peddat
                           liped.etbcod    = pedid.etbcod
                           liped.protip    = string(movim.movhr)
                           liped.prehr     = movim.movhr
                           liped.venda-placod    = movim.placod
                           .
            end.
        end.
        
        find first liped where 
                   liped.etbcod = pedid.etbcod and
                   liped.pedtdc = pedid.pedtdc and
                   liped.pednum = pedid.pednum and
                   liped.procod = movim.procod 
                   exclusive no-wait no-error.

        if avail liped
        then do:
            if qtd-conjunto > 0
            then liped.lipqtd = liped.lipqtd + p-sugerido.
            else liped.lipqtd = liped.lipqtd + p-sugerido /*movim.movqtm*/.
                                        
            pedid.pedobs[5] = pedid.pedobs[5] +
                    string(movim.placod) + "=" + string(movim.procod) +
                                "|".

            assign
                pedaxnfv.pednum = pedid.pednum
                pedaxnfv.situacao = "AUT".
                
            create tt-proped.
            assign
                        tt-proped.etbcod = plani.etbcod
                        tt-proped.pladat = plani.pladat
                        tt-proped.placod = plani.placod
                        tt-proped.numero = plani.numero
                        tt-proped.procod = movim.procod
                        tt-proped.movqtm = movim.movqtm
                        tt-proped.sugere = p-sugerido
                        tt-proped.tipo = vmodcod
                        tt-proped.whr  = v-time
                        tt-proped.pednum = if avail pedid
                                    then pedid.pednum else 0
                        .
        end.
    end.    
 end procedure.
 
 procedure envia-info:
 def var vaspas as char format "x(1)".
vaspas = chr(34).

def var vhora as int.
def var vmin as int.
def var vseg as int.

def var varquivo as char.
varquivo = "/admcom/relat/log-peaut." + string(time) + ".html".

output to value(varquivo).

put "<html>" skip
               "<body>" skip
               /****
               "<IMG SRC="
               vaspas
               "http://geocities.yahoo.com.br/morpheurgs/lebes.jpg" 
               vaspas 
               ">"
               "</IMG>" skip
               "<IMG SRC="
               vaspas
               "http://geocities.yahoo.com.br/morpheurgs/logo.jpg" 
               vaspas
               ">"
               "</IMG>" skip
               "<br><br>"
               ****/
               skip
               "<table border=" vaspas "0" vaspas "summary=>" skip
               "<tr>" skip
               "<td width=756 align=center><b><h2> " today /*"   -   "
                string(time,"hh:mm:ss")*/
               "</h2></b></td>" skip
               "</tr>" skip
               "</table>" skip
               "<table border=" vaspas "3" vaspas "borderColor=green summary=>"
               "<tr>" skip
               "<td width=712 align=center><b>ULTIMO MOVIM DO DIA NA MATRIZ"
               "</b></td>"
               "</tr>"    skip
               "</table>"
               "<table border=3 borderColor=green>" skip
               "<tr>" skip
               "<td width=100 align=left><b>Filial</b></td>" skip
               "<td width=100 align=left><b>Hora Atual</b></td>" skip
               "<td width=100 align=left><b>Hora Venda</b></td>" skip
               "<td width=100 align=left><b>Diferença</b></td>" skip
               "<td width=100 align=left><b>Hora</b></td>" skip
               "<td width=100 align=left><b>Minuto</b></td>" skip
               "<td width=100 align=left><b>Segundo</b></td>" skip
               "</tr>" skip.

 
for each tt-ltr:

    assign
        vseg = 0
        vmin = 0
        vhora = 0.
        
    if tt-ltr.hora > tt-ltr.hora-venda
    then assign
    vseg = int(substr(string(tt-ltr.hora - tt-ltr.hora-venda,"hh:mm:ss"),7,2))
    vmin = int(substr(string(tt-ltr.hora - tt-ltr.hora-venda,"hh:mm:ss"),4,2))
    vhora = int(substr(string(tt-ltr.hora - tt-ltr.hora-venda,"hh:mm:ss"),1,2))
    .
    
    if  vhora > 0 or vmin > 30 
    then do:

        put skip
                    "<tr>"
                    skip
                    "<td width=100 align=right>" tt-ltr.etbcod
                    "</td>"
                    skip
                    "<td width=100 align=right>" string(tt-ltr.hora,"hh:mm:ss") 
                    "</td>"
                    skip
                    "<td width=100 align=right>" 
                        string(tt-ltr.hora-venda,"hh:mm:ss")
                    "</td>"
                    skip
                    "<td width=100 align=right>" 
                        string((tt-ltr.hora - tt-ltr.hora-venda),"hh:mm:ss")
                    "</td>"
                    skip.

                    put "<td width=100 align=right>".
                    if vhora <> 0 then put vhora format ">9".
                    else put " ".
                    put "</td>" skip.
                    put "<td width=100 align=right>".
                    if vmin <> 0 then put vmin format ">9".
                                 else put " ".
                    put "</td>" skip.
                    put "<td width=100 align=right>".
                    if vseg <> 0 then put vseg format ">9".
                                 else put " ".
                    put "</td>" skip.
                    put "</tr>" skip.

     end.
end.
put "</table>" skip
               "</body>"  skip
                              "</html>".
                              

output close.
def var varqdg as char.
varqdg = "/admcom/progr/mail.sh " 
            + "~"" + "Transmissao Vendas" + "~"" + " ~"" 
            + varquivo + "~"" + " ~"" 
            + "claudir.santolin@linx.com.br" + "~"" 
            + " ~"informativo@lebes.com.br~"" 
            + " ~"text/html~"". 
            
unix silent value(varqdg).
end procedure.
