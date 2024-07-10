/*
    Abril/2015 - Gera Mix
    Setembro/2015 - Ruptura
*/
pause 0 before-hide.

/* Parametros */
def var p-diasmedia   as int.
def var p-diasestoq   as int.
def var p-dataestoq   as date.
def var p-coeficiente as dec.

def var par-operacao as char.
def var varqaux      as char.
def var varquivo     as char.
def var vprodlidos   as int.
def var vsel         as int.
def var vdata        as date.
def var vdias-medven as int.
def var vestminimo   like tabmix.qtdmix.
def var vesthist     like hiest.hiestf.
def var vestatualloj like estoq.estatual.
def var vestideal    like estoq.estatual.
def var vestcobert   like estoq.estatual.
def var vestpedido   like estoq.estatual.
def var vestatual981 like estoq.estatual.
def var vestatual993 like estoq.estatual.
def var vvendas      like movim.movqtm.
def var vmediavenda  as dec /*like movim.movqtm*/.
def var vcobertura   as int.
def var vdiascobertura as dec /*like movim.movqtm*/.
def var vreserva1    like liped.lipqtd.
def var vreserva2    like liped.lipqtd.
def var vnecessidade as int /*like estoq.estatual*/.
def var vpladat      like plani.pladat.
def var vdebug       as log.

def buffer btabmix for tabmix.
def buffer depto   for clase.
def buffer setor   for clase.
def buffer grupo   for clase.
def buffer classe  for clase.
def buffer sclasse for clase.

def var vreserva3   like liped.lipqtd.

par-operacao = SESSION:PARAMETER.
if par-operacao = ""
then par-operacao = "gera-mix".

if par-operacao = "gera-mix"
then varqaux = "gera-mix".
else if par-operacao = "gera-paei" 
then varqaux = "gera-paei".
else varqaux = "relatorio_ruptura".

def stream debug.
if par-operacao = "gera-mix" or
   par-operacao = "gera-paei"
then output stream debug to value("/admcom/relat/" + varqaux + "_naogerado_" +
                                 string(today,"999999") + "_" + string(time) +
                                 ".csv").

/* Parametros definidos para o processo */
assign
    p-diasmedia   = 30
    p-diasestoq   = 14
    p-coeficiente = 0.85.

varquivo = "/admcom/relat/" + varqaux + "_" + string(today,"999999") + "_" +
           string(time) + ".csv".

p-dataestoq = today - p-diasestoq.
p-dataestoq = date(month(p-dataestoq), 1, year(p-dataestoq)) - 1.

if par-operacao = "gera-mix" or par-operacao = "gera-paei"
then put stream debug unformatted
        varquivo    format "x(35)"
        " Dias media=" p-diasmedia
        " Dias Estoq=" p-diasestoq
        " Data Estoq=" p-dataestoq
        " Coeficiente=" p-coeficiente
        " Gera Pedido PAEI " today
        " INICIO:" string(time,"HH:MM:SS")
        skip.

if not vdebug
then output to value(varquivo).

if par-operacao = "gera-mix" or par-operacao = "gera-paei"
then put unformatted
        "Loja;"
        "Produto;"
        "Descricao;"
        "Setor;"
        "Grupo;"
        "Classe;"
        "Subclasse;"
        "Est.Minimo;"
        "Vendas;"
        "Dias Media;"
        "Media Venda;"
        "Cobertura;"
        "Dias Cobertura;"
        "Est.Cobertura;"
        "Est.Ideal;"
        "Est.Atual;"
        "Necessidade;"
        "Est.CD 900;"
        "PEDA/PEDO/PEDF/PEDE;"
        "PEDC/PEDX/PEDM/PEDR/PAEI;"
        skip.
else put unformatted
        "Loja;"
        "Produto;"
        "Descricao;"
        "Est.Minimo;"
        "Est.Atual;"
        "Est.Ideal;"
        "Vendas;"
        "Est.CD900;"
        "Pedidos;"
        skip.

def var gera-pedido-repos as log init no.

if par-operacao = "gera-paei"
then gera-pedido-repos = yes.

for each produ where produ.catcod = 31
                 and produ.clacod > 0
                 and produ.proseq = 0 /* Ativo */
               no-lock
               use-index iprodu.
    vprodlidos = vprodlidos + 1.
    find sClasse where sClasse.clacod = produ.clacod no-lock no-error.
    if not avail sClasse
    then next.

    find Classe where Classe.clacod = sClasse.clasup no-lock no-error.
    if not avail classe
    then next.

    find grupo where grupo.clacod = Classe.clasup no-lock no-error.
    if not avail grupo
    then next.

    find setor where setor.clacod = grupo.clasup no-lock no-error.
    if not avail setor
    then next.

    find depto where depto.clacod = setor.clasup no-lock.

    /* Produto */
    find prontaentrega where prontaentrega.tipo   = "P"
                         and prontaentrega.codigo = produ.procod
                       no-lock no-error.
    if not avail prontaentrega
    then
        /* Subclasse */         
        find prontaentrega where prontaentrega.tipo   = "C"
                             and prontaentrega.codigo = sClasse.clacod
                           no-lock no-error.

    if not avail prontaentrega
    then
        /* Classe */
        find prontaentrega where prontaentrega.tipo   = "C"
                             and prontaentrega.codigo = Classe.clacod
                           no-lock no-error.

    if not avail prontaentrega
    then
        /* Grupo */
        find prontaentrega where prontaentrega.tipo   = "C"
                             and prontaentrega.codigo = grupo.clacod
                           no-lock no-error.

    if not avail prontaentrega
    then
        /* Setor */
        find prontaentrega where prontaentrega.tipo   = "C"
                             and prontaentrega.codigo = setor.clacod
                           no-lock no-error.

    if not avail prontaentrega
    then
        /* Departamento */
        find prontaentrega where prontaentrega.tipo   = "C"
                             and prontaentrega.codigo = depto.clacod
                           no-lock no-error.

    if (par-operacao = "gera-mix" or
        par-operacao = "gera-paei") and 
       (not avail prontaentrega or
        prontaentrega.pentrega = no)
    then next.

    assign
        vcobertura   = 0
        vestatual981 = 0
        vestatual993 = 0
        vestatualloj = 0.

    if avail prontaentrega
    then vcobertura = prontaentrega.cobertura.

    find estoq where estoq.procod = produ.procod
                 and estoq.etbcod = 981
               no-lock no-error.
    if avail estoq
    then assign vestatual981 = estoq.estatual.

    find estoq where estoq.procod = produ.procod
                 and estoq.etbcod = 900
               no-lock no-error.
    if avail estoq
    then assign vestatual993 = estoq.estatual.

/***
    if par-operacao = "Ruptura"
    then do.
        run /admcom/progr/corte_disponivel.p (input produ.procod,
                            output vestoq_depos, 
                            output vreservas, 
                            output vdisponivel).
        for each tt-reservas.
            find liped where recid(liped) = tt-reservas.rec_liped no-lock.
            find pedid of liped no-lock.
            find tt-estab where tt-estab.etbcod = pedid.etbcod and
                                tt-estab.procod = produ.procod
                                no-error.
            if not avail tt-estab
            then do.
                create tt-estab.
                assign
                    tt-estab.etbcod = pedid.etbcod
                    tt-estab.procod = produ.procod.
            end.
            tt-estab.pedidos_lojas = tt-estab.pedidos_lojas + liped.lipqtd.
        end.
    end.
***/

/***
    if par-operacao = "Ruptura" 
    then do.
        for each estab where estab.tipoLoja = "normal" no-lock.
            find estoq where estoq.procod = produ.procod
                         and estoq.etbcod = estab.etbcod
                       no-lock no-error.
            if avail estoq
            then vestatualloj = vestatualloj + estoq.estatual.
        end.
        if vdebug
        then
            disp vprodlidos   column-label "Lidos" format ">>>>9"
                 vsel         format ">>>>9"
                 produ.procod
                 vestatual981 column-label "Est.981" format "->>9.99"
                 vestatual993 column-label "Est.900" format "->>9.99"
                 vestatualloj column-label "Est.Loj" format "->>9.99".
        if vestatual981 + vestatual993 + vestatualloj < 5
        then do.
            if vdebug
            then pause 1.
            next.
        end.
    end.
***/

    for each estab where estab.tipoLoja = "normal" no-lock.
        
        if gera-pedido-repos   and
           estab.etbcod <> 13 and
           estab.etbcod <> 61
        then next.
           
        assign
            vmediavenda = 0
            vestminimo  = 0
            vestatualloj = 0
            vvendas     = 0
            vesthist    = 0
            vreserva1   = 0
            vreserva2   = 0
            vreserva3   = 0
            /*vpedidos    = 0*/.

        /*
            Buscar o estoque minimo - MIX
        */
        for each tabmix where tabmix.tipomix = "M"
                          and tabmix.etbcod  = estab.etbcod
                         no-lock.
            for each btabmix where btabmix.tipomix = "P"
                               and btabmix.codmix  = tabmix.codmix
                               and btabmix.promix  = produ.procod
                             no-lock.
                vestminimo = vestminimo + btabmix.qtdmix.
            end.
        end.

        if vestminimo <= 0
        then do.
            if gera-pedido-repos   or par-operacao = "gera-mix"
            then put stream debug unformatted
                    estab.etbcod format ">>9" ";"
                    produ.procod ";"
                    produ.pronom ";"
                    setor.clacod  ";"
                    grupo.clacod  ";"
                    classe.clacod ";"
                    sclasse.clacod ";"
                    vestminimo ";"
                               ";" /* vendas */
                               ";" /* dias-m */
                               ";" /* media */
                    vcobertura ";"
                    skip.
            if vdebug
            then do.
                disp estab.etbcod produ.procod vestminimo.
                pause 0.
            end.
            next.
        end.

/*
        find tt-estab where tt-estab.etbcod = estab.etbcod and
                            tt-estab.procod = produ.procod
                      no-error.
        if avail tt-estab
        then assign
                vpedidos = tt-estab.pedidos_lojas.
*/

        find estoq where estoq.procod = produ.procod
                     and estoq.etbcod = estab.etbcod
                   no-lock no-error.
        if avail estoq
        then vestatualloj = estoq.estatual.
        
        /*
            Media de Vendas
        */
        for each tipmov where tipmov.movtvenda no-lock.
            do vdata = today - p-diasmedia to today.
                for each movim where movim.etbcod = estab.etbcod
                                 and movim.movtdc = tipmov.movtdc
                                 and movim.procod = produ.procod
                                 and movim.movdat = vdata 
                               no-lock.
                    if tipmov.movtdev = no
                    then vvendas = vvendas + movim.movqtm.
                    else vvendas = vvendas - movim.movqtm.
                end.
            end. /* movim */
        end. /* tipmov */

        if (gera-pedido-repos or par-operacao = "gera-mix")
                and vvendas <= 0
        then do.
            put stream debug unformatted
                    estab.etbcod format ">>9" ";"
                    produ.procod ";"
                    produ.pronom ";"
                    setor.clacod  ";"
                    grupo.clacod  ";"
                    classe.clacod ";"
                    sclasse.clacod ";"
                    vestminimo ";"
                    vvendas    ";" /* vendas */
                               ";" /* dias-m */
                               ";" /* media */
                    vcobertura ";"
                    skip.
            next.
        end.            

        vsel = vsel + 1.
      
        find last hiest where hiest.etbcod = estab.etbcod
                          and hiest.procod = produ.procod
                          and hiest.hiemes <= month(p-dataestoq)
                          and hiest.hieano = year(p-dataestoq)
                        no-lock no-error.
        if avail hiest
        then vesthist = hiest.hiestf.

        vdias-medven = p-diasmedia.
        if vesthist <= 0
        then do.
            /* Verificar notas de transferencia */
            vpladat = ?.
            find first movim where movim.procod = produ.procod
                               and movim.movtdc = 6
                               and movim.movdat >= p-dataestoq
                             no-lock no-error.
            repeat.
                if not avail movim
                then leave.
    
                find plani where plani.etbcod = movim.etbcod
                             and plani.placod = movim.placod
                           no-lock no-error.
                if avail plani and
                   plani.emite > 500 and
                   plani.desti = estab.etbcod
                then do.
                    vpladat = plani.pladat.
                    leave.
                end.
                find next movim where movim.procod = produ.procod
                                  and movim.movtdc = 6
                                  and movim.movdat >= p-dataestoq
                                no-lock no-error.
            end.
             
            if vpladat <> ?
            then vdias-medven = min(p-diasmedia, today - vpladat).
            else vdias-medven = 0. 
                /* Baixar media de vendas e usar o estoque minimo */
        end.
        vdias-medven = round(vdias-medven * p-coeficiente, 0).
        if vdias-medven <> 0
        then vmediavenda = vvendas / vdias-medven.

        vestcobert = vmediavenda * vcobertura.

        vestideal = max(vestcobert, vestminimo).

        if vdebug
        then disp estab.etbcod column-label "Etb"
                 vvendas vestminimo vestatualloj
                 vmediavenda 
                 vcobertura column-label "Cobert" format ">>>>9".

        do vdata = today - (30 * 4) to today.
            for each liped where liped.pedtdc = 3
                             and liped.procod = produ.procod
                             and liped.predt  = vdata
                             and liped.etbcod = estab.etbcod
                           no-lock:
                                         
                find pedid where pedid.etbcod = liped.etbcod and
                                 pedid.pedtdc = liped.pedtdc and
                                 pedid.pednum = liped.pednum
                           no-lock no-error.
                if not avail pedid 
                then next.
                if pedid.sitped <> "E" and
                   pedid.sitped <> "L"
                then next.

                if pedid.modcod = "PEDA" or
                   pedid.modcod = "PEDO" or
                   pedid.modcod = "PEDF" or
                   pedid.modcod = "PEDE"
                then vreserva1 = vreserva1 + liped.lipqtd.

                if pedid.modcod = "PEDC" or
                   pedid.modcod = "PEDX" or
                   pedid.modcod = "PEDM" or
                   pedid.modcod = "PEDR" or
                   pedid.modcod = "PAEI"
                then vreserva2 = vreserva2 + liped.lipqtd.
            end.
        end.

        if par-operacao = "Ruptura"
        then do. /* copiado de corte_disponivel.p */
            assign vdata = today + 1.
            for each liped where liped.pedtdc = 3
                             and liped.procod = produ.procod
                             and liped.predt  >= vdata
                             and liped.etbcod = estab.etbcod
                           no-lock:
                                         
                find pedid where pedid.etbcod = liped.etbcod and
                                 pedid.pedtdc = liped.pedtdc and
                                 pedid.pednum = liped.pednum no-lock no-error.
                if not avail pedid 
                then next.

                if pedid.sitped <> "E" and
                   pedid.sitped <> "L"
                then next.
                vreserva3 = vreserva3 + liped.lipqtd.
            end.
        end.

        vestatualloj = vestatualloj + vreserva1.

        if vmediavenda <> 0
        then vdiascobertura = vestatualloj / vmediavenda. /*Apenas informativo*/

        vnecessidade = vestideal - vestatualloj - vreserva1 - vreserva2.

        if vdebug
        then disp vestatualloj
                vdiascobertura column-label "D.Cobert" format "->>>>9"
                vnecessidade   column-label "Neces" format "->>>>9".
        
        if (gera-pedido-repos or par-operacao = "gera-mix")
            and vnecessidade <= 0
        then do.
            /* Log */
            put stream debug unformatted
                estab.etbcod format ">>9" ";"
                produ.procod  ";"
                produ.pronom  ";"
                setor.clacod  ";"
                grupo.clacod  ";"
                classe.clacod ";"
                sclasse.clacod ";"
                vestminimo    ";"
                vvendas       ";" /* vendas */
                vdias-medven  ";" /* dias-m */
                vmediavenda   ";" /* media */
                vcobertura    ";"                
                vdiascobertura ";" /* cobertura */
                vestminimo    ";"
                vestcobert    ";"
                vestideal     ";" /* estoque ideal */
                vestatualloj  ";"
                vnecessidade  ";" 
                vestatual993  ";"
                vreserva1     ";"
                vreserva2     ";"
                skip.
            next.
        end.

        if gera-pedido-repos or par-operacao = "gera-mix"
        then put unformatted
                estab.etbcod  ";"
                produ.procod  ";"
                produ.pronom  ";"
                setor.clacod  ";"
                grupo.clacod  ";"
                classe.clacod ";"
                sclasse.clacod ";"
                vvendas       ";"
                vdias-medven  ";"
                vmediavenda   ";"
                vcobertura    ";"
                vdiascobertura ";" /* cobertura */
                vestminimo    ";"
                vestcobert    ";"
                vestideal     ";" /* estoque ideal */
                vestatualloj  ";"
                vnecessidade  ";" 
                vestatual993  ";"
                vreserva1     ";"
                vreserva2     ";"
                skip.
        else put unformatted
                estab.etbcod ";"
                produ.procod ";"
                produ.pronom ";"
                vestminimo   ";"
                vestatualloj ";"
                vestideal    ";"
                vvendas      ";"
                vestatual981 + vestatual993 ";"
                vreserva1 + vreserva2 + vreserva3 ";"
                skip.
        /*
        if gera-pedido-repos /*par-operacao = "gera-mix" and
           (estab.etbcod = 13 or estab.etbcod = 61)*/
        then run gera-paei (estab.etbcod, produ.procod, vnecessidade).
        */
    end. /* estab */
end.
output close.

if par-operacao = "gera-mix" or par-operacao = "gera-paei"
then do.
    put stream debug unformatted
        skip
        varquivo
        " Gera Pedido PAEI " today 
        " FINAL:" string(time,"HH:MM:SS")
        skip.
    output stream debug close.
end.

procedure gera-paei.

    def input parameter p-etbcod like ger.estab.etbcod.
    def input parameter p-procod like produ.procod.
    def input parameter p-ajusta as dec.

    def var vpednum like pedid.pednum.
    def buffer bpedid for pedid.

        find last pedid where 
                          pedid.pedtdc = 3 and
                          pedid.etbcod = p-etbcod and
                          pedid.peddat = today and
                          pedid.sitped = "E" and
                          pedid.pednum >= 100000 and
                          pedid.modcod = "PAEI"
                          no-lock no-error.
        if not avail pedid 
        then do: 
            find last bpedid where bpedid.pedtdc = 3 and
                                   bpedid.etbcod = p-etbcod  and
                                   bpedid.pednum >= 100000 no-error.
            if avail bpedid 
            then vpednum = bpedid.pednum + 1. 
            else vpednum = 100000.
    
            create pedid. 
            assign pedid.etbcod = p-etbcod
                   pedid.pedtdc = 3 
                   pedid.peddat = today 
                   pedid.pednum = vpednum 
                   pedid.sitped = "E"  
                   pedid.modcod = "PAEI"
                   pedid.pedsit = yes.
        end.

        find first liped where
                   liped.etbcod = pedid.etbcod and
                   liped.pedtdc = pedid.pedtdc and
                   liped.pednum = pedid.pednum and
                   liped.procod = p-procod no-lock no-error.
        if not avail liped 
        then do:
            create liped.
            assign liped.pedtdc    = pedid.pedtdc
                   liped.pednum    = pedid.pednum
                   liped.procod    = p-procod
                   liped.lippreco  = estoq.estvenda
                   liped.lipsit    = "Z"
                   liped.predtf    = pedid.peddat
                   liped.predt     = pedid.peddat
                   liped.etbcod    = pedid.etbcod
                   liped.protip    = "0"
                   liped.lipqtd    = p-ajusta
                   liped.prehr     = time.
        end.
end procedure.
