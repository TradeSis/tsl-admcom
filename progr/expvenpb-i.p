/*{admcab.i new}
  */

{ajusta-rateio-venda-def.i new}

for each tabaux where tabaux.tabela = "PLANOBIZ" no-lock:
    create tt-planobiz.
    assign
        tt-planobiz.catcod = int(tabaux.nome_campo)
        tt-planobiz.fincod = int(tabaux.valor_campo)
        .
end.

def var vimprimir as log format "Impressora/Tela".

def var vok        as   log.
def var vcatcod    like com.produ.catcod.
def var i          as   integer.
def var varquivo   as   char format "x(20)".
def var vtotal     like com.plani.platot.

def var vcontra    as   integer.

def var vdata      like com.plani.pladat.
def var vdtini     like com.plani.pladat         initial today.
def var vdtfim     like com.plani.pladat         initial today.
def var vetbi      like estab.etbcod.
def var vetbf      like estab.etbcod.

def buffer bf-movim for movim.

def var val_fin as dec.
def var val_des as dec.
def var val_dev as dec.
def var val_acr as dec.
def var val_com as dec.
def var valtotal as dec. 

def var vsum-venda-aux   like plani.platot.
def var vint-depto-nota  as   integer.

def stream stela.

def temp-table tt-ven
    field catcod as int
    field etbcod like estab.etbcod
    field vencod like ger.func.funcod
    field valor  as   dec format ">>,>>>,>>9.99"
    field contra as   integer
    field acr      as dec 
    field venda    as dec  .

def temp-table tt-plano
    
    field etbcod   like estab.etbcod
    field vencod   like ger.func.funcod
    
    field fincod   like finan.fincod 
    field contra   as integer 
    field valor    as dec format ">>,>>>,>>9.99"
    field acr      as dec 
    field venda    as dec  
    index idx01 etbcod vencod.
    
def temp-table tt-total-plano
    field etbcod   like estab.etbcod
    field vencod   like ger.func.funcod
    field fincod   like finan.fincod     
    field valor    as dec format ">>,>>>,>>9.99"   
    field contra   as integer
    field acr      as dec 
    field venda    as dec  .
    
def temp-table tt-total-ven
    field etbcod    like estab.etbcod
    field vencod    like ger.func.funcod
    field valor     as dec format ">>,>>>,>>9.99"
    field contra    as integer
    field acr      as dec 
    field venda    as dec 
    field biss     as dec.

def var vdti as date.
def var vdtf as date.
def var vdat as date.


vdtf = today.
vdti = date(month(today),01,year(today)).

/*
vdtf = 11/30/2013.
vdti = 11/01/2013.
*/

for each estab where estab.etbcod < 500 NO-LOCK:
    do vdata = vdti to vdtf:

        for each com.plani use-index pladat 
                          where com.plani.movtdc = 5
                            and com.plani.etbcod = estab.etbcod
                            and com.plani.pladat = vdata no-lock:
            
            vok = no.
            assign valtotal        = 0
                   vint-depto-nota = 0.

            
            vcatcod = 41.
            run cal-movim.

            vok = no.
            assign valtotal        = 0
                   vint-depto-nota = 0.
            
            vcatcod = 31.
            run cal-movim.
                
        end.
    end.
end. 

def var vqtdven as int.
def var vtotalven as dec.
def var vpct as dec.
def var vtotal31 as dec.
def var vtotal41 as dec.
def var val-catcod as dec.
def var val-vencod as dec.
def var vfunnom like func.funnom.
def var vfuncod like func.funcod.

varquivo = "/var/www/drebes/arquivosdesenv/bis/planobis31.txt".
output to value(varquivo).
for each tt-plano where tt-plano.fincod = 31 or
                        tt-plano.fincod = 0 no-lock
          break by tt-plano.etbcod
                by tt-plano.fincod
                by tt-plano.vencod :

    vfunnom = "".
    if tt-plano.vencod > 0
    then do:
        find first func where func.etbcod = tt-plano.etbcod and
                     func.funcod = tt-plano.vencod no-lock
                     no-error.
        if avail func
        then vfunnom = func.funnom.
    end.
                     
    find first tt-ven where tt-ven.etbcod = tt-plano.etbcod
                      and tt-ven.catcod = tt-plano.fincod
                      and tt-ven.vencod = tt-plano.vencod no-lock no-error.
    
    val-vencod = tt-ven.valor.
    
    vsum-venda-aux = vsum-venda-aux + tt-plano.valor.
    
    vfuncod = tt-plano.vencod.
    if tt-plano.fincod = 0
    then vfuncod = 999.
    
        put unformatted tt-plano.etbcod  ";"
            vfuncod ";"
            vfunnom ";"
            tt-plano.contra ";"
            vsum-venda-aux ";"
            (vsum-venda-aux * 100 ) / val-vencod 
             ";" 
            val-vencod
            skip.
        vsum-venda-aux = 0.        
        val-vencod = 0.
    /*end.
      */
end.
output close.
/*
{admcab.i new}
run  visurel.p(varquivo,"").
*/
vqtdven = 0.
vtotalven = 0.
varquivo = "/var/www/drebes/arquivosdesenv/bis/planobis41.txt".
output to value(varquivo).
for each tt-plano where tt-plano.fincod = 41 or
                        tt-plano.fincod = 0 no-lock
                          break by tt-plano.etbcod
                by tt-plano.vencod :
    vfunnom = "".
    if tt-plano.vencod > 0
    then do:
        find first func where func.etbcod = tt-plano.etbcod and
                     func.funcod = tt-plano.vencod no-lock
                     no-error.
        if avail func
        then vfunnom = func.funnom.
    end.
    
    find first tt-ven where tt-ven.etbcod = tt-plano.etbcod
                      and tt-ven.catcod = tt-plano.fincod
                      and tt-ven.vencod = tt-plano.vencod no-lock no-error.
    if avail tt-ven
    then val-vencod = tt-ven.valor.
    else val-vencod = 0.

    vsum-venda-aux = vsum-venda-aux + tt-plano.valor.
                      
    /*if last-of(tt-plano.vencod)
    then do:*/

    vfuncod = tt-plano.vencod.
    if tt-plano.fincod = 0
    then vfuncod = 999.
 

        put unformatted tt-plano.etbcod  ";"
            vfuncod ";"
            vfunnom ";"
            tt-plano.contra ";"
            vsum-venda-aux ";"
            (vsum-venda-aux * 100) / val-vencod ";"
            val-vencod
            skip.
        vsum-venda-aux = 0.
        val-vencod = 0.
     /*end.*/
                        
end.
output close.

def var vbiss like plani.biss.

procedure cal-movim:
    vok = no.
    valtotal = 0.

            for each tt-plani: delete tt-plani. end.
            for each tt-movim: delete tt-movim. end.

            create tt-plani.
            buffer-copy plani to tt-plani.
                                
            for each com.movim where 
                        com.movim.placod = com.plani.placod
                    and com.movim.etbcod = com.plani.etbcod
                    and com.movim.movtdc = com.plani.movtdc
                    and com.movim.movdat = com.plani.pladat no-lock:
                
                if movim.movqtm = 0 or
                   movim.movpc  = 0
                then next.

                create tt-movim.
                buffer-copy movim to tt-movim.
            end.

            run ajusta-rateio-venda-pro.p.
 
            assign val_fin = 0 
                       val_des = 0
                       val_dev = 0
                       val_acr = 0
                       val_com = 0.
 
             for each tt-movim where 
                        tt-movim.placod = com.plani.placod
                    and tt-movim.etbcod = com.plani.etbcod
                    and tt-movim.movtdc = com.plani.movtdc
                    and tt-movim.movdat = com.plani.pladat no-lock:
                                
                   find com.produ where
                        com.produ.procod = tt-movim.procod
                                                        no-lock no-error.
                   if not avail com.produ
                   then next.
                   if com.produ.catcod = vcatcod 
                   then vok = yes.
                   else next.
                   
                         
                val_acr = val_acr + tt-movim.acr-fin.
                val_des = val_des + tt-movim.movdes.
                val_dev = val_dev + tt-movim.movdev.
    
                vbiss = vbiss + tt-movim.movtot.
                
                val_com = tt-movim.movtot.
                if val_com = ?
                then val_com = 0.
                
                valtotal = valtotal + val_com.

            end.
            
            if vok
            then do: 

               vint-depto-nota = vcatcod. 
               vbiss = com.plani.platot 
                                       -  com.plani.vlserv 
                                       -  com.plani.descprod
                                       +  com.plani.acfprod
                                       .
 
               if vbiss = ? or
                  vbiss < 0
               then vbiss = 0. 
               
               if com.plani.crecod = 2
               then do:
               find first tt-ven where tt-ven.etbcod = com.plani.etbcod
                                   and tt-ven.catcod = vint-depto-nota
                                   and tt-ven.vencod = com.plani.vencod
                      no-error.
               if not avail tt-ven
               then do:
                   create tt-ven.
                   assign tt-ven.etbcod = com.plani.etbcod
                          tt-ven.vencod = com.plani.vencod 
                          tt-ven.catcod = vint-depto-nota
                             .
               end.

               assign 
                      tt-ven.contra  = tt-ven.contra + 1
                      tt-ven.acr     = tt-ven.acr + val_acr
                      tt-ven.venda   = tt-ven.venda + valtotal
                      tt-ven.valor   = tt-ven.valor + vbiss
                      .
                             
               find first tt-ven where tt-ven.etbcod = com.plani.etbcod
                                   and tt-ven.catcod = vint-depto-nota
                                   and tt-ven.vencod = 0
                      no-error.
               if not avail tt-ven
               then do:
                   create tt-ven.
                   assign tt-ven.etbcod = com.plani.etbcod
                          tt-ven.vencod = 0 
                          tt-ven.catcod = vint-depto-nota
                             .
               end.

               assign 
                      tt-ven.contra  = tt-ven.contra + 1
                      tt-ven.acr     = tt-ven.acr + val_acr
                      tt-ven.venda   = tt-ven.venda + valtotal
                      tt-ven.valor = tt-ven.valor + vbiss
                      .
               
               find first tt-ven where tt-ven.etbcod = com.plani.etbcod
                                   and tt-ven.catcod = 0
                                   and tt-ven.vencod = 0
                      no-error.
               if not avail tt-ven
               then do:
                   create tt-ven.
                   assign tt-ven.etbcod = com.plani.etbcod
                          tt-ven.vencod = 0 
                          tt-ven.catcod = 0
                             .
               end.

               assign 
                      tt-ven.contra  = tt-ven.contra + 1
                      tt-ven.acr     = tt-ven.acr + val_acr
                      tt-ven.venda   = tt-ven.venda + valtotal
                      tt-ven.valor = tt-ven.valor + vbiss
                      .
   
               find first tt-planobiz where
                          tt-planobiz.catcod = vcatcod and
                          tt-planobiz.fincod = plani.pedcod no-error.
               if not avail tt-planobiz then next.
               

               find first tt-plano where 
                          tt-plano.etbcod = com.plani.etbcod
                      and tt-plano.vencod = com.plani.vencod
                      and tt-plano.fincod = vcatcod no-error.

               if not avail tt-plano
               then do:
                   create tt-plano.
                   assign tt-plano.etbcod = com.plani.etbcod
                          tt-plano.vencod = com.plani.vencod
                          tt-plano.fincod = vcatcod /*com.plani.pedcod*/.
               end.
                       
               assign tt-plano.contra = tt-plano.contra + 1
                      tt-plano.valor  = tt-plano.valor + vbiss 
                      tt-plano.acr    = tt-plano.acr + val_acr
                      tt-plano.venda  = tt-plano.venda + valtotal.
                      
               find first tt-plano where 
                          tt-plano.etbcod = com.plani.etbcod
                      and tt-plano.vencod = 0
                      and tt-plano.fincod = vcatcod no-error.

               if not avail tt-plano
               then do:
                   create tt-plano.
                   assign tt-plano.etbcod = com.plani.etbcod
                          tt-plano.vencod = 0
                          tt-plano.fincod = vcatcod /*com.plani.pedcod*/.
               end.
                       
               assign tt-plano.contra = tt-plano.contra + 1
                      tt-plano.valor  = tt-plano.valor + vbiss 
                      tt-plano.acr    = tt-plano.acr + val_acr
                      tt-plano.venda  = tt-plano.venda + valtotal.
               
               find first tt-plano where 
                          tt-plano.etbcod = com.plani.etbcod
                      and tt-plano.vencod = 0
                      and tt-plano.fincod = 0 no-error.

               if not avail tt-plano
               then do:
                   create tt-plano.
                   assign tt-plano.etbcod = com.plani.etbcod
                          tt-plano.vencod = 0
                          tt-plano.fincod = 0 /*com.plani.pedcod*/.
               end.
                       
               assign tt-plano.contra = tt-plano.contra + 1
                      tt-plano.valor  = tt-plano.valor + vbiss 
                      tt-plano.acr    = tt-plano.acr + val_acr
                      tt-plano.venda  = tt-plano.venda + valtotal.
       
       
               end.
               else do:
               find first tt-ven where tt-ven.etbcod = com.plani.etbcod
                                   and tt-ven.catcod = vint-depto-nota
                                   and tt-ven.vencod = com.plani.vencod
                      no-error.
               if not avail tt-ven
               then do:
                   create tt-ven.
                   assign tt-ven.etbcod = com.plani.etbcod
                          tt-ven.vencod = com.plani.vencod 
                          tt-ven.catcod = vint-depto-nota
                             .
               end.

               assign 
                      tt-ven.contra  = tt-ven.contra + 1
                      tt-ven.acr     = tt-ven.acr + val_acr
                      tt-ven.venda   = tt-ven.venda + valtotal
                      tt-ven.valor = tt-ven.valor
                                       + (com.plani.platot 
                                       -  com.plani.vlserv 
                                       -  com.plani.descprod
                                       +  com.plani.acfprod)
 
                      .
                             
               find first tt-ven where tt-ven.etbcod = com.plani.etbcod
                                   and tt-ven.catcod = vint-depto-nota
                                   and tt-ven.vencod = 0
                                                         no-error.
               if not avail tt-ven
               then do:
                   create tt-ven.
                   assign tt-ven.etbcod = com.plani.etbcod
                          tt-ven.vencod = 0 
                          tt-ven.catcod = vint-depto-nota
                             .
               end.

               assign 
                      tt-ven.contra  = tt-ven.contra + 1
                      tt-ven.acr     = tt-ven.acr + val_acr
                      tt-ven.venda   = tt-ven.venda + valtotal
                      tt-ven.valor = tt-ven.valor
                                       + (com.plani.platot 
                                       -  com.plani.vlserv 
                                       -  com.plani.descprod
                                       +  com.plani.acfprod)
 
                      .
                 
               find first tt-ven where tt-ven.etbcod = com.plani.etbcod
                                   and tt-ven.catcod = 0
                                   and tt-ven.vencod = 0
                                                         no-error.
               if not avail tt-ven
               then do:
                   create tt-ven.
                   assign tt-ven.etbcod = com.plani.etbcod
                          tt-ven.vencod = 0 
                          tt-ven.catcod = 0
                             .
               end.

               assign 
                      tt-ven.contra  = tt-ven.contra + 1
                      tt-ven.acr     = tt-ven.acr + val_acr
                      tt-ven.venda   = tt-ven.venda + valtotal
                      tt-ven.valor = tt-ven.valor
                                       + (com.plani.platot 
                                       -  com.plani.vlserv 
                                       -  com.plani.descprod
                                       +  com.plani.acfprod)
 
                      .
               find first tt-planobiz where
                          tt-planobiz.catcod = vcatcod and
                          tt-planobiz.fincod = plani.pedcod no-error.
               if not avail tt-planobiz then next.
               
               find first tt-plano where 
                          tt-plano.etbcod = com.plani.etbcod
                      and tt-plano.vencod = com.plani.vencod
                      and tt-plano.fincod = vcatcod no-error.

               if not avail tt-plano
               then do:
                   create tt-plano.
                   assign tt-plano.etbcod = com.plani.etbcod
                          tt-plano.vencod = com.plani.vencod
                          tt-plano.fincod = vcatcod /*com.plani.pedcod*/.
               end.
                       
               assign tt-plano.contra = tt-plano.contra + 1
                      tt-plano.valor  = tt-plano.valor 
                                           + (com.plani.platot
                                           - com.plani.vlserv
                                           - com.plani.descprod
                                           + com.plani.acfprod)
                      tt-plano.acr    = tt-plano.acr + val_acr
                      tt-plano.venda  = tt-plano.venda + valtotal.
               
               find first tt-plano where 
                          tt-plano.etbcod = com.plani.etbcod
                      and tt-plano.vencod = 0
                      and tt-plano.fincod = vcatcod no-error.

               if not avail tt-plano
               then do:
                   create tt-plano.
                   assign tt-plano.etbcod = com.plani.etbcod
                          tt-plano.vencod = 0
                          tt-plano.fincod = vcatcod /*com.plani.pedcod*/.
               end.
                       
               assign tt-plano.contra = tt-plano.contra + 1
                      tt-plano.valor  = tt-plano.valor 
                                           + (com.plani.platot
                                           - com.plani.vlserv
                                           - com.plani.descprod
                                           + com.plani.acfprod)
                      tt-plano.acr    = tt-plano.acr + val_acr
                      tt-plano.venda  = tt-plano.venda + valtotal.
               
               find first tt-plano where 
                          tt-plano.etbcod = com.plani.etbcod
                      and tt-plano.vencod = 0
                      and tt-plano.fincod = 0 no-error.

               if not avail tt-plano
               then do:
                   create tt-plano.
                   assign tt-plano.etbcod = com.plani.etbcod
                          tt-plano.vencod = 0
                          tt-plano.fincod = 0 .
               end.
                       
               assign tt-plano.contra = tt-plano.contra + 1
                      tt-plano.valor  = tt-plano.valor 
                                           + (com.plani.platot
                                           - com.plani.vlserv
                                           - com.plani.descprod
                                           + com.plani.acfprod)
                      tt-plano.acr    = tt-plano.acr + val_acr
                      tt-plano.venda  = tt-plano.venda + valtotal.
       
       
               end.          
            end.

end procedure
