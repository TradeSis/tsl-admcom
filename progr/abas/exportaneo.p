def var xtime as int.
xtime = time.

def var par-dtini   as date.
def var par-dtfim   as date.

par-dtini = today - 2.
par-dtfim = today - 1.


def var vdir-arquivo as char format "x(50)" init "/admcom/tmp/expneo/".


def var tmp-arquivo as char extent 8.
def var nome-arquivo as char extent 8.

    
def var vsysdata     as char.  
vsysdata = string(year(today) ,"9999") 
         + string(month(today),"99")
         + string(day(today)  ,"99")
/*         + string(time,"HH:MM")*/.
vsysdata = replace(vsysdata,":","").

/* SPRINT1
Upload . Itens                                   [1] X_LOJASLEBES_AAAAMMDD_itens.txt
Upload - Origem da SKU                           [2] X_LOJASLEBES-AAAAMMDD_origens.txt
Upload - Local de estoque                        [3] X_LOJASLEBES-AAAAMMDD_localEstoque.txt
Upload - Cadastro de Dimensão de Demanda         [4] X_LOJASLEBES-AAAAMMDD_dimdemanda1.txt

Upload - Fornecedores                            [5] X_LOJASLEBES-AAAAMMDD_fornecedores.txt
Upload - Movimentação DFU                        [6] X_LOJASLEBES-AAAAMMDD_movim_dfu.txt
Upload - Movimentação SKU                        [7] X_*_LOJASLEBES-AAAAMMDD_movim_sku.txt
Upload - Movimentação SKU Atualização do Estoque [8] X_LOJASLEBES-AAAAMMDD_movim_sku_estoque.txt
*/

tmp-arquivo[1] = vdir-arquivo + "X_LOJASLEBES-" + vsysdata + "_tmp1".
tmp-arquivo[2] = vdir-arquivo + "X_LOJASLEBES-" + vsysdata + "_tmp2".
tmp-arquivo[3] = vdir-arquivo + "X_LOJASLEBES-" + vsysdata + "_tmp3".
tmp-arquivo[4] = vdir-arquivo + "X_LOJASLEBES-" + vsysdata + "_tmp4".

tmp-arquivo[5] = vdir-arquivo + "X_LOJASLEBES-" + vsysdata + "_tmp5".
tmp-arquivo[6] = vdir-arquivo + "X_LOJASLEBES-" + vsysdata + "_tmp6".
tmp-arquivo[7] = vdir-arquivo + "X_LOJASLEBES-" + vsysdata + "_tmp7".
tmp-arquivo[8] = vdir-arquivo + "X_LOJASLEBES-" + vsysdata + "_tmp8".

nome-arquivo[1] = vdir-arquivo + "X_LOJASLEBES-" + vsysdata + "_itens.txt".
nome-arquivo[2] = vdir-arquivo + "X_LOJASLEBES-" + vsysdata + "_origens.txt".
nome-arquivo[3] = vdir-arquivo + "X_LOJASLEBES-" + vsysdata + "_localEstoque.txt".
nome-arquivo[4] = vdir-arquivo + "X_LOJASLEBES-" + vsysdata + "_dimdemanda1.txt".

nome-arquivo[5] = vdir-arquivo + "X_LOJASLEBES-" + vsysdata + "_fornecedores.txt".
nome-arquivo[6] = vdir-arquivo + "X_LOJASLEBES-" + vsysdata + "_movim_dfu.txt".
nome-arquivo[7] = vdir-arquivo + "X_LOJASLEBES-" + vsysdata + "_movim_sku.txt".
nome-arquivo[8] = vdir-arquivo + "X_LOJASLEBES-" + vsysdata + "_movim_sku_estoque.txt".



def stream ITEM.      output stream ITEM  to value(tmp-arquivo[1]).
def stream ORIGENS.   output stream ORIGENS   to value(tmp-arquivo[2]).
/*def stream STOCK.   output stream STOCK to value(tmp-arquivo[3]).*/
def stream MOVIMSKU. output stream MOVIMSKU to value(tmp-arquivo[8]).



def var vlocal as char.
def var cmovdat as char.

def var vdata   as date.
def var vloop as int.
def var vCNPJ as char.
 
def var vcp     as char no-undo init ";".

/* TEMP CRIADA PARA COMPATIBILIDADE COM PROGRAMA ANTERIOR*/
def temp-table temp-item NO-UNDO
    field item    as char
    field ean     as char
    field descr   as char
    field fornecedor as char
    field unidade as char
    field emb     as int
    field categoria as char
    field dgrupo1 as char
    field dgrupo2 as char
    field dgrupo3 as char
    field dgrupo4 as char
    field dgrupo5 as char
    field estacao as char
    field temporada as char
    field caract1   as char
    field subcaract1 as char
    field caract2   as char
    field subcaract2 as char
    field tipo as char
    
    index item is primary unique item.

def temp-table temp-sku NO-UNDO
    field item                  as char
    field local                 as char
    field item-origem           as char
    field local-origem          as char
    field empresa-origem        as char
    field forne-origem          as char
    field leadTIME              as char
    field LOTE                  as char
    index temp-sku   is primary unique item asc local asc.
    
    

def temp-table  temp-stock NO-UNDO
    field DtRefer        as char     
    field Local          as char     
    field Item           as char     
    field EstDisp        as char     
    field estcusto       as char
    field EstTran        as char     
    field EstornoVenda   as char     
    field QtdPedPendente as char     
    field QtdSaiTransf   as char     
    field QtdEntTransf   as char   
    index temp-stock is primary unique DtRefer Local Item.

/**def temp-table temp-local no-undo
    field codigo    as char
    field aux       as char
    field descr     as char
    field cidade    as char
    field ufecod    as char
    field estatus   as char
    field tipo      as char
    field bandeira  as char
    field descband  as char
    index temp-local is primary unique codigo.**/
    
def temp-table temp-vendas no-undo
    field item              as char format "x(25)"
    field local             as char format "x(10)"
    field dtreferencia      as char format "x(16)"
    
    field qtdvenda          as dec format ">>>>>>>>>>>>9.9999"
    field pcvenda           as dec format ">>>>>>>>>>>>9.99"
    field ctomedio          as dec format ">>>>>>>>>>>>9.9999"
    
    field vltotal           as dec format ">>>>>>>>>>>>9.9999"
    field qtdtickets        as dec format ">>>>>>>>>>>>>>>>>9"
    
    field abtqtd            as dec format ">>>>>>>>>>>>9.99"
    field estatual          as dec format ">>>>>>>>>>>>9.99"
    index xx is primary unique item local dtreferencia.

def buffer sclase   for clase.
def buffer grupo    for clase.
def buffer setclase for clase.
def buffer depto    for clase.


def var vcompras_pendentes_entrega_CD as dec NO-UNDO.
def var vestatual as dec.
pause 0 before-hide.

hide message no-pause.
message today string(time,"HH:MM:SS") string(time - xtime,"HH:MM:SS") "Exportando Filiais...".

output to value(tmp-arquivo[4]).
for each estab no-lock.
    find regiao of estab no-lock no-error.
    put unformatted 
        estab.etbcod vcp
        estab.etbnom vcp
        estab.tamanho vcp
        estab.tipoloja vcp
        estab.ufecod    vcp
        regiao.regnom   vcp
        estab.munic vcp
        skip.
end.            
output close.       


output to value(tmp-arquivo[3]).

for each estab no-lock.

    find regiao of estab no-lock no-error.

    put unformatted 
        estab.etbcod    vcp
        estab.etbnom    vcp
        estab.tamanho   vcp
        estab.tipoloja  vcp
        estab.ufecod    vcp
        regiao.regnom   vcp
        "0"             vcp
        "1"             vcp
        "0"             vcp
        ";;"            vcp
        "0"             vcp 
        ";;"            vcp
        estab.munic     vcp
        skip.
    
end.            
            
output close.       


hide message no-pause.
message today string(time,"HH:MM:SS") string(time - xtime,"HH:MM:SS") "Exportando Fornecedores...".

output to value(tmp-arquivo[5]).
for each fabri no-lock. 
    find first forne where forne.forcod = fabri.fabcod no-lock no-error.
    if not avail forne then next.
    put unformatted 
        forne.forcod        vcp
        forne.forpai        vcp
        forne.fornom        vcp
        "Nacionalidade"     vcp
        ";;"                vcp
        forne.forctfon      vcp
        ";;"                vcp
        forne.email         vcp
        forne.forrua        vcp
        forne.forcep        vcp
        forne.ufecod        vcp
        forne.formunic      vcp
        forne.forpais       vcp        
        ";;"                vcp
        "0"                 vcp
        skip.
end.
output close.       

hide message no-pause.
message today string(time,"HH:MM:SS") string(time - xtime,"HH:MM:SS") "Exportando Itens Vendidos de"  par-dtini "a" par-dtfim.

for each tipmov where movtdc = 5 no-lock.
    for each estab where estab.etbcod >= 1 and estab.etbcod <= 1000 no-lock. 
        do vdata = par-dtini to par-dtfim .
            for each plani where plani.movtdc = tipmov.movtdc
                             and plani.etbcod = estab.etbcod
                             and plani.pladat = vdata no-lock.
                for each movim where movim.etbcod = plani.etbcod
                             and movim.placod = plani.placod
                             and movim.movtdc = plani.movtdc
                             and movim.movdat = plani.pladat no-lock,
                    first produ where produ.procod = movim.procod no-lock,
                    first sclase where sclase.clacod = produ.clacod no-lock,
                    first clase where clase.clacod = sclase.clasup no-lock,
                    first grupo where grupo.clacod = clase.clasup no-lock,
                    first setclase where setclase.clacod = grupo.clasup no-lock.
                    if setclase.clacod = 0
                    then next.
                    if produ.catcod = 41 or
                       produ.catcod = 31 
                    then.
                    else next.
                    if produ.proseq = 0
                    then.
                    else next.
                    find fabri of produ no-lock no-error.
                    if not avail fabri then next.
                    find first forne where forne.forcod = fabri.fabcod 
                                no-lock no-error.
                    if not avail forne then next.
            
                    vlocal  =  string(movim.etbcod,"999").
                    cmovdat =  string(year (movim.movdat),"9999") +
                               string(month(movim.movdat),"99"  ) +
                               string(day  (movim.movdat),"99"  ).
            
                    find first temp-vendas where
                            temp-vendas.dtreferencia = cmovdat and
                            temp-vendas.item         = string(movim.procod) and
                            temp-vendas.local        = vlocal
                             no-error.
                    if not avail temp-vendas
                    then do:         
                        create temp-vendas.
                        temp-vendas.dtreferencia = cmovdat.
                        temp-vendas.item     = string(movim.procod).
                        temp-vendas.local   = vlocal.
                    end. 
                    find estoq where estoq.etbcod = movim.etbcod and 
                                    estoq.procod = movim.procod no-lock. 
                    temp-vendas.qtdvenda   = temp-vendas.qtdvenda + movim.movqtm .
                    temp-vendas.qtdtickets = temp-vendas.qtdtickets + 1.
                    temp-vendas.pcvenda = estoq.estvenda.
                end.    /*  for each movim      */
            end.    /*  for each plani      */
        end.    /*  do vdata = vdtini   */
    end.    /*  for each estab      */
end.        /*  for each tipmov     */



hide message no-pause.
message today string(time,"HH:MM:SS") string(time - xtime,"HH:MM:SS") "Exportando Produtos,Estoques...".
def var vconta as int.
vconta = 0.
for each produ no-lock.
    
    /* filtros */
    if produ.catcod = 31 or
       produ.catcod = 41
    then.
    else next.
    if produ.proseq = 0
    then.
    else next.
    
         
    
    vconta = vconta + 1.
    if vconta mod 1000 = 0
    then do:
        hide message no-pause.
        message today string(time,"HH:MM:SS") string(time - xtime,"HH:MM:SS") "Exportando Produtos,Estoques..." vconta.
    end.    

    find first temp-vendas where temp-vendas.item = string(produ.procod) no-error.
    
    if vconta <= 10000 or avail temp-vendas
    then .
    else next.

    
    find sClase     where sClase.clacod   = produ.clacod    no-lock no-error.
    if not avail sClase 
    then do on error undo.  
        next.
    end.        
    find Clase      where Clase.clacod    = sClase.clasup   no-lock no-error.
    if not avail clase 
    then do on error undo.
        next.
    end.
    find grupo      where grupo.clacod    = Clase.clasup    no-lock no-error.
    if not avail grupo 
    then do on error undo.
        next.
    end.
    find setClase   where setClase.clacod = grupo.clasup    no-lock no-error.  
    if not avail setclase 
    then do on error undo.
        next.
    end.
    find depto   where depto.clacod = setclase.clasup    no-lock no-error.   
    if not avail depto 
    then do on error undo.
        next.                  
    end.        
        
    if setClase.clacod = 0 
    then do on error undo.
        next.      
    end.
    if grupo.clacod = 0 
    then do on error undo.
        next.         
    end.
    if depto.clacod = 0 
    then do on error undo.
        next.         
    end.
    if Clase.clacod = 0 
    then do on error undo.
        next.         
    end.
    if sClase.clacod = 0 
    then do on error undo.
        next.        
    end.
    find categoria of produ no-lock no-error.
    find fabri of produ no-lock no-error.
    if avail fabri
    then find forne where forne.forcod = fabri.fabcod no-lock no-error.
    find estac where estac.etccod = produ.etccod no-lock no-error.
    find temporada where temporada.temp-cod = produ.temp-cod no-lock no-error.
    

        /* CRIA TEMP PARA COMPATIBILIDADE  COM PROGRAMA ANTERIOR */
    create temp-item.
    assign temp-item.item    = string(produ.procod)
           temp-item.ean     = if produ.proindice <> ?
                               then if trim(produ.proindice) = "SEM GTIN"
                                    then ""
                                    else produ.proindice
                               else "".
           temp-item.descr   = produ.pronom.
           temp-item.fornecedor = string(produ.fabcod) + "-" + (if avail forne then forne.fornom else "").
           temp-item.unidade = if avail produ
                                  then produ.prouncom
                                  else "".
           temp-item.emb     = 1                .

           temp-item.categoria = string(produ.catcod) + "-" +
                                (if avail categoria then categoria.catnom else "").

           temp-item.dgrupo1 = (if avail depto then string(depto.clacod) else "" ) + "-" +
                               (if avail depto then depto.clanom else "").
           
           temp-item.dgrupo2 = (if avail setclase then string(setclase.clacod) else "") + "-" +
                               (if avail setclase then setclase.clanom else ""). 
           
           temp-item.dgrupo3 = (if avail grupo then string(grupo.clacod) else "") + "-" +
                               (if avail grupo then grupo.clanom else "").
           
           temp-item.dgrupo4  = (if avail clase then string(clase.clacod) else "") + "-" +
                                (if avail clase then clase.clanom else "").

           temp-item.dgrupo5  = (if avail sclase then string(sclase.clacod) else "") + "-" +
                                (if avail sclase then sclase.clanom else "").

           temp-item.estacao = string(produ.etccod) + "-" + (if avail estac then  estac.etcnom else "") .
           temp-item.temporada = string(produ.temp-cod)  + "-" + (if avail temporada then temporada.tempnom else "") .
           temp-item.caract1   = if produ.catcod = 41
                                 then produ.prorefter
                                 else "".
           temp-item.subcaract1   = if produ.catcod = 41
                                 then produ.prorefter
                                 else "".
                                 
           temp-item.caract2   = if produ.catcod = 41
                                 then produ.prorefter
                                 else "".
           temp-item.subcaract2   = if produ.catcod = 41
                                 then produ.prorefter
                                 else "".
           temp-item.tipo       = if produ.proipival = 1 then "PE"
                                 else if produ.ind_vex  then "VEX"
                                                        else "NORMAL". 
           
    put stream ITEM unformatted 
           temp-item.item    vcp
           temp-item.ean     vcp
           temp-item.descr   vcp
           temp-item.unidade vcp
           temp-item.emb     vcp
           temp-item.fornecedor  vcp
           temp-item.categoria  vcp
           temp-item.dgrupo1 vcp
           temp-item.dgrupo2 vcp
           temp-item.dgrupo3 vcp
           temp-item.dgrupo4 vcp
           temp-item.dgrupo5 vcp
           temp-item.estacao vcp
           ";;" vcp
           ";;" vcp
           ";;" vcp
           temp-item.caract1 vcp
           temp-item.subcaract1 vcp
           temp-item.caract2 vcp
           temp-item.subcaract2 vcp
           temp-item.tipo vcp            
               
        skip.
    delete temp-item.    

    /*    
    run compras_pendentes_entrega_CD 
            ( input  produ.procod,  
              output vcompras_pendentes_entrega_CD).
    */
    
    find first produaux of produ where produaux.nome_campo = "PACK"
                no-lock no-error.
       
    for each estab no-lock.

        if estab.tipoLoja = "Virtual" then next.
        if estab.tipoLoja = "escritorio" then next.
            
        find estoq where estoq.etbcod = estab.etbcod and
                         estoq.procod = produ.procod
                    no-lock no-error.
        vestatual   = if avail estoq
                      then estoq.estatual
                      else 0.
                      
        create temp-sku.
        assign 
            temp-sku.item   = string(produ.procod).
            temp-sku.local  = string(estab.etbcod,"999"). 
            temp-sku.item-origem = if estab.tipoloja = "CD"
                                   then ";;"
                                   else string(produ.procod).
            temp-sku.local-origem = if estab.tipoloja = "CD"
                                    then ";;"
                                    else string(900).
            temp-sku.empresa-origem = if estab.tipoloja = "CD"
                                    then ";;"
                                    else string(1).
            temp-sku.forne-origem = if estab.tipoloja = "CD"
                                    then string(produ.fabcod)
                                    else ";;".
            temp-sku.LEADTIME       = "".
            temp-sku.lote           = if avail produaux
                                      then produaux.valor_campo
                                      else "". 
                                      
            /** STOCK */
            
        put stream ORIGENS unformatted 
               temp-sku.item                vcp
               temp-sku.local               vcp
               temp-sku.item-origem         vcp
               temp-sku.local-origem        vcp
               temp-sku.empresa-origem      vcp
               temp-sku.forne-origem        vcp
               "1"              vcp
               "1"              vcp
               temp-sku.LEADTIME        vcp
               temp-sku.LEADTIME        vcp    
               
               temp-sku.lote                vcp
               temp-sku.lote                vcp
               
            skip.
        delete temp-sku.    
        
        

        
        create temp-stock. 
        assign 
            temp-stock.DtRefer = string(year (today),"9999") +
                                 string(month(today),"99"  ) + 
                                 string(day  (today),"99"  )
            temp-stock.Local          = string(estab.etbcod,"999"). 
            temp-stock.Item           = string(produ.procod) .
            temp-stock.EstDisp        = if vestatual > 0 
                                        then trim(string(vestatual,">>>>>>>>>>>>>>9.9999"))
                                        else trim("0").
            temp-stock.EstTran        = "".
            temp-stock.EstornoVenda   = "".
            temp-stock.QtdPedPendente = trim(string(vcompras_pendentes_entrega_CD ,">>>>>>>>>>>>>>9.9999")).
            temp-stock.QtdSaiTransf   = "".
            temp-stock.QtdEntTransf   = "" .

/*        put stream STOCK unformatted 
             temp-stock.DtRefer        vcp     
             temp-stock.Local          vcp     
             temp-stock.Item           vcp     
             temp-stock.EstDisp        vcp     
             temp-stock.EstTran        vcp     
             temp-stock.EstornoVenda   vcp     
             temp-stock.QtdPedPendente vcp     
             temp-stock.QtdSaiTransf   vcp     
             temp-stock.QtdEntTransf    
            skip.*/

        find first temp-vendas where
                temp-vendas.local = temp-stock.local and
                temp-vendas.item  = temp-stock.item
                no-error.
        if not avail temp-vendas
        then do:       
            put stream MOVIMSKU unformatted 
                 temp-stock.Item           vcp     
                 temp-stock.Local          vcp     
                 temp-stock.DtRefer        vcp     
                 temp-stock.EstDisp        vcp     
                 temp-stock.Estcusto       vcp     
                skip.
        end.        
    
        delete temp-stock.
        
    end. /* for each estab ... */
    

end.

output stream ITEM  close.
output stream ORIGENS   close.
output stream MOVIMSKU close.
/*output stream STOCK close.*/




output to value(tmp-arquivo[6] ).                    

for each temp-vendas.

    put unformatted
        temp-vendas.Item                     vcp
        temp-vendas.Local                    vcp
        "LOJASLEBES"                        vcp    
        temp-vendas.DtReferencia             vcp
        trim(string(temp-vendas.qtdvenda  ,">>>>>>>>>>>>9.999")) vcp
        trim(string(0                    ,">>>>>>>>>>>>9.999")) vcp
        trim(string(temp-vendas.pcvenda   ,">>>>>>>>>>>>9.99"  )) vcp
        trim(string(temp-vendas.ctomedio  ,">>>>>>>>>>>>9.9999")) vcp
        temp-vendas.Local                    vcp
        
        /*trim(string(temp-vendas.vltotal   ,">>>>>>>>>>>>9.99"  )) vcp*/
        /*trim(string(temp-vendas.qtdtickets,">>>>>>>>>>>>>>>>>9"))*/
        skip.

end. 
output close.

output to value(tmp-arquivo[7] ).                    

for each temp-vendas.

    put unformatted
        temp-vendas.Item                     vcp
        temp-vendas.Local                    vcp
        temp-vendas.DtReferencia             vcp
        trim(string(temp-vendas.qtdvenda  ,">>>>>>>>>>>>9.999")) vcp
        trim(string(0                    ,">>>>>>>>>>>>9.999")) vcp
        trim(string(temp-vendas.pcvenda   ,">>>>>>>>>>>>9.99"  )) vcp
        trim(string(temp-vendas.ctomedio  ,">>>>>>>>>>>>9.9999")) vcp

        trim(string(temp-vendas.abtqtd    ,">>>>>>>>>>>>9.9999")) vcp

        trim(string(0                    ,">>>>>>>>>>>>9.999")) vcp
        trim(string(temp-vendas.ctomedio  ,">>>>>>>>>>>>9.9999")) vcp

        trim(string(temp-vendas.estatual  ,">>>>>>>>>>>>9.999")) vcp
        
        ";;"                vcp
        skip.

end. 
output close.


hide message no-pause.

message today string(time,"HH:MM:SS") string(time - xtime,"HH:MM:SS") "Encerrando...".
do vloop = 1 to 8:
    unix silent value ("unix2dos -q " + tmp-arquivo[vloop]).
    unix silent value ("mv -f " + tmp-arquivo[vloop] + " " + nome-arquivo[vloop]).

    
end.    

 

procedure compras_pendentes_entrega_CD.
    def input  parameter par-procod like produ.procod.
    def output parameter par-compras_pendentes_entrega_CD as int.
    par-compras_pendentes_entrega_CD = 0.
    for each liped where  liped.procod = par-procod and
                                 liped.pedtdc = 1 and
                                 (liped.predtf = ? or
                                 liped.predtf >= today - 30) no-lock,
        first pedid of liped where pedid.pedsit = yes and
                            pedid.sitped <> "F"  and
                            pedid.peddat > today - 180   no-lock:
        par-compras_pendentes_entrega_CD = par-compras_pendentes_entrega_CD +
                                (liped.lipqtd - liped.lipent).
    end.

    if par-compras_pendentes_entrega_CD < 0
    then par-compras_pendentes_entrega_CD = 0.
end procedure.


hide message no-pause.
message today string(time,"HH:MM:SS") string(time - xtime,"HH:MM:SS") "FIM".

