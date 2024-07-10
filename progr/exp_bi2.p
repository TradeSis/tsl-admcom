/* {admcab.i} */

def var vdata as date.
 vdata = today - 1. 

def var auxdt as char format "x(10)".
 
auxdt = substring(string(today,"99-99-9999"),7,4)
      + substring(string(today,"99-99-9999"),3,4) 
      + substring(string(today,"99-99-9999"),1,2).

def var vdir as char init "/gera-ecs/" .

output to value(vdir + "fornecedor.txt").

put "CODFORNECEDOR;FORNECEDOR" AT 01 SKIP.

for each forne no-lock by forne.forcod:
    
    if not can-find(first produ where produ.fabcod = forne.forcod)
    then next. 
       
    put forne.forcod at 1 
        ";"
        forne.fornom format "x(50)"  SKIP.
        
end. 
output close.

def var v-i as int.

output to value(vdir + "fatoestoque.txt").
 PUT "DATA;"
    "CODFILIAL;"
    "CODFORNECEDOR;" 
    "CODITEM;"
    "CODSUBCARACT;"
    "CODESTACAO;"
    "QTDESTOQUE;"
    "VLRPRODUTOPRECOVENDA;"
    "VLRPRODUTOPRECOCUSTO;"
    "QTDESTOQUEIDEAL"
  SKIP.
 
 v-i = 0.
 for each produ no-lock by produ.procod:
        
        find last movim where movim.procod  = produ.procod
                          and movim.movdat >= 01/01/2005 no-lock no-error.
        if not avail movim
        then do:
            if not can-find(first estoq where estoq.procod = produ.procod
                                   and estoq.estatual > 0)
            then next.
        end.
    
        find first procaract where procaract.procod = produ.procod
                           no-lock no-error.

        for each estab no-lock:
        
            find estoq where estoq.procod = produ.procod and
                             estoq.etbcod = estab.etbcod
                      no-lock no-error.
            if not avail estoq
            then next.

            put unformat
                auxdt at 1 ";"
                estab.etbcod ";"
                produ.fabcod ";"
                produ.procod ";"
               (if avail procaract then string(procaract.subcod) else "0") ";"
                produ.etccod ";"  /* estacao */
               (if estoq.estatual = ? or estoq.estatual < 1 
                               then 0 else estoq.estatual)
                     format "->>>>>9.9" ";"
               (if estoq.estvenda = ? then 0 else estoq.estvenda)
                        format "->>>>>9.99" ";" 
                (if estoq.estcusto = ? then 0 else estoq.estcusto)
                          format "->>>>>9.99" ";"
              /*  (if estoq.estideal = ? then 0 else estoq.estideal) */
                  0
                      format "->>>>9.9"
                SKIP.
        end.
  end.
output close.


output to value(vdir + "fatocomprapedido.txt").
PUT "DATA;"
    "CODPEDIDO;" 
    "CODESTACAO;"
    "CODFILIAL;"
    "CODFORNECEDOR;" 
    "CODITEM;"
    "CODSUBCARACT;"
    "CODTIPOPEDIDOCOMPRA;"
    "QTDSOLICITADO;"
    "QTDENTREGUE;"
    "QTDSALDO" 
    SKIP.

for each estab no-lock,
    each pedid where pedid.pedtdc = 1
                    and pedid.etbcod = estab.etbcod 
                    and pedid.peddat = vdata no-lock,
    each liped where liped.etbcod = pedid.etbcod and
                     liped.pedtdc = pedid.pedtdc  and
                     liped.pednum = pedid.pednum no-lock,
    first produ where produ.procod = liped.procod no-lock:
    
    find first procaract where procaract.procod = produ.procod
                           no-lock no-error.
 
    put unformat
        auxdt at 1  ";"
        pedid.pednum ";"
        produ.etccod ";"
        pedid.etbcod ";"
        pedid.clfcod ";"
        produ.procod ";"
        (if avail procaract then string(procaract.subcod) else "0") ";"
        pedid.pedtdc ";"
         liped.lipqtd format ">>>>>>9" ";"
        liped.lipent  format ">>>>>>9"  ";"
        (liped.lipqtd - liped.lipent) format ">>>>>>9"
        SKIP.

end.       

output close.

output to value(vdir + "tipopedidocompra.txt").
    PUT "CODTIPOPEDIDOCOMPRA;TIPOPEDIDOCOMPRA" AT 1
                    SKIP. 

    put unformat "1;COMPRA"  AT 01
             SKIP.
    put unformat "3;PEDIDIDO LOJA"  AT 01
             SKIP.
    put unformat "4;ANTIGO PEDIDO ESPECIAL"  AT 01
             SKIP.
    put unformat "5;PEDIDO ESPECIAL"  AT 01
             SKIP.
    put unformat "6;PEDIDO ESPECIAL"  AT 01
             SKIP.
    put unformat "7;REPOSICAO"  AT 01
             SKIP.

output close.             
             
             

             
             



 


