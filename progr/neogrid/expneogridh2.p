def var xtime as int.
xtime = time.

def input parameter par-tipo    as char .
def input parameter par-dtini   as date.
def input parameter par-dtfim   as date.


def var vdir-arquivo as char format "x(50)" init "/admcom/tmp/neogrid/".

/*hide message no-pause. message "HML" update vdir-arquivo.*/

def var nome-arquivo as char extent 6.
    
def var vsysdata     as char.  
vsysdata = string(year(today) ,"9999") 
         + string(month(today),"99")
         + string(day(today)  ,"99")
         + string(time,"HH:MM").
vsysdata = replace(vsysdata,":","").

nome-arquivo[1] = vdir-arquivo + "ITEM_"  + vsysdata + "001".
nome-arquivo[2] = vdir-arquivo + "SKU_"   + vsysdata + "001".
nome-arquivo[3] = vdir-arquivo + "STOCK_" + vsysdata + "001".
nome-arquivo[4] = vdir-arquivo + "LOCATION_" + vsysdata + "001".
nome-arquivo[5] = vdir-arquivo + "VENDOR_" + vsysdata + "001".

if par-tipo = "SEMANAL"
then nome-arquivo[6] = vdir-arquivo + "SEMANAL_" + vsysdata + ".txt".
else nome-arquivo[6] = vdir-arquivo + "SALES_"   + vsysdata + "001".



def stream ITEM.  output stream ITEM  to value(nome-arquivo[1]).
def stream SKU.   output stream SKU   to value(nome-arquivo[2]).
def stream STOCK. output stream STOCK to value(nome-arquivo[3]).

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
    field fabcod  as char
    field marca   as char
    field unidade as char
    field emb     as int
    field embtra  as int
    field grupo1  as char
    field dgrupo1 as char
    field grupo2  as char
    field dgrupo2 as char
    field grupo3  as char
    field dgrupo3 as char
    field grupo4  as char
    field dgrupo4 as char
    field grupo5  as char
    field dgrupo5 as char
    index item is primary unique item.

def temp-table temp-sku NO-UNDO
    field local                 as char
    field item                  as char
    field tipo                  as char
    field Local_Abast           as char
    field Descontinuado         as char
    field DataDescontinuacao    as char
    field Indicador             as char
    field DataValidade          as char
    index temp-sku   is primary unique local asc item asc.
    
    

def temp-table  temp-stock NO-UNDO
    field DtRefer        as char     
    field Local          as char     
    field Item           as char     
    field EstDisp        as char     
    field EstTran        as char     
    field EstornoVenda   as char     
    field QtdPedPendente as char     
    field QtdSaiTransf   as char     
    field QtdEntTransf   as char   
    index temp-stock is primary unique DtRefer Local Item.

def temp-table temp-local no-undo
    field codigo    as char
    field aux       as char
    field descr     as char
    field cidade    as char
    field ufecod    as char
    field estatus   as char
    field tipo      as char
    field bandeira  as char
    field descband  as char
    index temp-local is primary unique codigo.
    
def temp-table temp-sales no-undo
    field dtreferencia      as char format "x(16)"
    field local             as char format "x(10)"
    field item              as char format "x(25)"
    field qtdvenda          as dec format ">>>>>>>>>>>>9.9999"
    field ctomedio          as dec format ">>>>>>>>>>>>9.9999"
    field pcvenda           as dec format ">>>>>>>>>>>>9.99"
    field vltotal           as dec format ">>>>>>>>>>>>9.9999"
    field qtdtickets        as dec format ">>>>>>>>>>>>>>>>>9"
    index xx is primary unique 
                        dtreferencia
                        local  
                        item     .

def buffer sclase   for clase.
def buffer grupo    for clase.
def buffer setclase for clase.
def buffer depto    for clase.
 

def var vtipoLoja as char.
def var vcompras_pendentes_entrega_CD as dec NO-UNDO.
def var vestatual as dec.
pause 0 before-hide.

hide message no-pause.
message today string(time,"HH:MM:SS") string(time - xtime,"HH:MM:SS") "Exportando Produtos,Estoques...".
def var vconta as int.
vconta = 0.
for each produ no-lock.
    
    vconta = vconta + 1.
    if vconta mod 1000 = 0
    then do:
        hide message no-pause.
        message today string(time,"HH:MM:SS") string(time - xtime,"HH:MM:SS") "Exportando Produtos,Estoques..." vconta.
    end.    
    /* filtros */
    if produ.catcod = 31 or
       produ.catcod = 41
    then.
    else next.
    if produ.proseq = 0
    then.
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
    
    /* CRIA TEMP PARA COMPATIBILIDADE  COM PROGRAMA ANTERIOR */
    create temp-item.
    assign temp-item.item    = string(produ.procod)
           temp-item.ean     = if produ.proindice <> ?
                               then if
                                     trim(produ.proindice) matches "*SEM GTIN*"
                                    then ""
                                    else produ.proindice
                               else "".
           temp-item.descr   = produ.pronom.
           temp-item.fabcod  = string(produ.fabcod).
           temp-item.marca   = "".
           temp-item.unidade = if avail produ
                                  then produ.prouncom
                                  else "".
           temp-item.emb     = 0                .
           temp-item.embtra  = 0.

           temp-item.grupo1  = if avail depto then string(depto.clacod) else "".
           temp-item.dgrupo1 = if avail depto then depto.clanom else "".
           
           temp-item.grupo2  = if avail setclase then string(setclase.clacod) else "".
           temp-item.dgrupo2 = if avail setclase then setclase.clanom else "". 
           
           temp-item.grupo3 = if avail grupo then string(grupo.clacod) else "".
           temp-item.dgrupo3 = if avail grupo then grupo.clanom else "".
           
           temp-item.grupo4  = if avail clase then string(clase.clacod) else "".
           temp-item.dgrupo4 = if avail clase then clase.clanom else "".

           temp-item.grupo5  = if avail sclase then string(sclase.clacod) else "".
           temp-item.dgrupo5 = if avail sclase then sclase.clanom else "".


    put stream ITEM unformatted 
           temp-item.item    vcp
           temp-item.ean     vcp
           temp-item.descr   vcp
           temp-item.fabcod  vcp
           temp-item.marca   vcp
           temp-item.unidade vcp
           temp-item.emb     vcp
           temp-item.embtra  vcp
           temp-item.grupo1  vcp
           temp-item.dgrupo1 vcp
           temp-item.grupo2  vcp
           temp-item.dgrupo2 vcp
           temp-item.grupo3  vcp
           temp-item.dgrupo3 vcp
           temp-item.grupo4  vcp
           temp-item.dgrupo4 vcp
           temp-item.grupo5  vcp
           temp-item.dgrupo5 
        skip.
    delete temp-item.    
    
    run compras_pendentes_entrega_CD 
            ( input  produ.procod,  
              output vcompras_pendentes_entrega_CD).
       
    for each estab no-lock.
        vtipoLoja = if estab.tipoLoja = "Normal"
                    then "S"
                    else
                    if estab.tipoLoja = "CD"
                    then "W"
                    else
                    if estab.tipoLoja = "Outlet"
                    then "O"
                    else
                    if estab.tipoLoja = "E-COMMERCE"
                    then "E"
                    else "S".
      /*  if vtipoLoja      = "W"       then next.*/
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
            temp-sku.local  = string(estab.etbcod,"999"). 
            temp-sku.item   = string(produ.procod).
            temp-sku.tipo               = "".
            temp-sku.Local_Abast        = string(900,"999").
            temp-sku.Descontinuado      = if produ.descontinuado = yes  
                                            then "1"   
                                            else "0".
            temp-sku.DataDescontinuacao = if produ.datfimvida = ?
                                            then "00000000"
                                            else 
                                string(year (produ.datfimvida),"9999") +
                                string(month(produ.datfimvida),"99"  ) + 
                                string(day  (produ.datfimvida),"99"  ).
            temp-sku.indicador          = ""   .
            temp-sku.DataValidade       = ""  .
            /** STOCK */
            
        put stream SKU unformatted 
               temp-sku.local               vcp
               temp-sku.item                vcp
               temp-sku.tipo                vcp
               temp-sku.Local_Abast         vcp
               temp-sku.Descontinuado       vcp
               temp-sku.DataDescontinuacao  vcp
               temp-sku.Indicador           vcp
               temp-sku.DataValidade  
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

        put stream STOCK unformatted 
             temp-stock.DtRefer        vcp     
             temp-stock.Local          vcp     
             temp-stock.Item           vcp     
             temp-stock.EstDisp        vcp     
             temp-stock.EstTran        vcp     
             temp-stock.EstornoVenda   vcp     
             temp-stock.QtdPedPendente vcp     
             temp-stock.QtdSaiTransf   vcp     
             temp-stock.QtdEntTransf    
            skip.
    
        delete temp-stock.
        
    end. /* for each estab ... */
    

end.

output stream ITEM  close.
output stream SKU   close.
output stream STOCK close.

hide message no-pause.
message today string(time,"HH:MM:SS") string(time - xtime,"HH:MM:SS") "Exportando Filiais...".

output to value(nome-arquivo[4]).

for each estab no-lock.
    vtipoLoja = if estab.tipoLoja = "Normal"
                then "S"
                else
                if estab.tipoLoja = "CD"
                then "W"
                else
                if estab.tipoLoja = "Outlet"
                then "O"
                else 
                if estab.tipoLoja = "E-COMMERCE"
                then "E"
                else "S".
    
    find regiao of estab no-lock no-error.
    find unfed of estab no-lock.
    def var vtipo as char.
    vtipo =  
            if estab.tipoLoja = "CD" 
            then "01" else
            if estab.tipoLoja = "E-commerce"  
            then "08" else
            if estab.tipoLoja = "Escritorio"  
            then "10" else
            if estab.tipoLoja = "Normal"  
            then "05" else
            if estab.tipoLoja = "Outlet"  
            then "05" else 
            if estab.tipoLoja = "Virtual" 
            then "08" else "05".
    vCNPJ = replace (estab.etbcgc,".","").
    vCNPJ = replace (vCNPJ,"/","").
    vCNPJ = replace (vCNPJ,"-","").
    
    if vCNPJ = ""
    then next.
    
    create temp-local.
    assign temp-local.codigo  = string(estab.etbcod,"999") 
           temp-local.aux     = vCNPJ               
           temp-local.descr  = /*string(estab.etbcod,"999") + " " + */
                                                estab.endereco 
           temp-local.cidade = estab.munic          
           temp-local.ufecod = estab.ufecod         
           temp-local.estatus = "1"                  
           temp-local.tipo   = vtipo                
           temp-local.bandeira = ""                 
           temp-local.descband = ""                  .
           
    put unformatted 
        temp-local.codigo  ";"
        temp-local.aux ";"
        temp-local.descr   ";"
        temp-local.cidade  ";"
        temp-local.ufecod  ";"
        temp-local.estatus ";"
        temp-local.tipo    ";"
        temp-local.bandeira    ";"
        temp-local.descband    
        skip.
    delete temp-local.
           
           
    
end.            
            
output close.       

hide message no-pause.
message today string(time,"HH:MM:SS") string(time - xtime,"HH:MM:SS") "Exportando Fornecedores...".

output to value(nome-arquivo[5]).
for each fabri no-lock. 
    find first forne where forne.forcod = fabri.fabcod no-lock no-error.
    if not avail forne then next.
    put unformatted 
        fabri.fabcod   ";"
       (if avail forne
        then forne.forcgc
        else string(fabri.fabcod))   ";"
        fabri.fabnom   ";"
        (if avail forne
        then forne.ufecod
        else "")
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
            
                    find first temp-sales where
                            temp-sales.dtreferencia = cmovdat and
                            temp-sales.item         = string(movim.procod) and
                            temp-sales.local        = vlocal
                             no-error.
                    if not avail temp-sales
                    then do:         
                        create temp-sales.
                        temp-sales.dtreferencia = cmovdat.
                        temp-sales.item     = string(movim.procod).
                        temp-sales.local   = vlocal.
                    end. 
                    find estoq where estoq.etbcod = movim.etbcod and 
                                    estoq.procod = movim.procod no-lock. 
                    temp-sales.qtdvenda   = temp-sales.qtdvenda + movim.movqtm .
                    temp-sales.qtdtickets = temp-sales.qtdtickets + 1.
                    temp-sales.pcvenda = estoq.estvenda.
                end.    /*  for each movim      */
            end.    /*  for each plani      */
        end.    /*  do vdata = vdtini   */
    end.    /*  for each estab      */
end.        /*  for each tipmov     */


output to value(nome-arquivo[6] ).                    

for each temp-sales.

    put unformatted
        temp-sales.DtReferencia             ";"
        temp-sales.Local                    ";"
        temp-sales.Item                     ";"
        trim(string(temp-sales.qtdvenda  ,">>>>>>>>>>>>9.9999")) ";"
        trim(string(temp-sales.ctomedio  ,">>>>>>>>>>>>9.9999")) ";"
        trim(string(temp-sales.pcvenda   ,">>>>>>>>>>>>9.99"  )) ";"
        trim(string(temp-sales.vltotal   ,">>>>>>>>>>>>9.99"  )) ";"
        trim(string(temp-sales.qtdtickets,">>>>>>>>>>>>>>>>>9"))
        skip.

end. 
output close.

hide message no-pause.

message today string(time,"HH:MM:SS") string(time - xtime,"HH:MM:SS") "Encerrando...".
do vloop = 1 to 6:
    unix silent value ("unix2dos -q " + nome-arquivo[vloop]).
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

