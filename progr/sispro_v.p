{admcab.i}
def var vmes as int.
def var vano as int.
def var data_mes like plani.pladat.
def var v-seq as int.
def var vseq as int.
def var qtd_lote as int.
def var cod_lote as char.
def var cd_batch as char.
def stream stela.
def var vetbcod like estab.etbcod.
def var vdata       like titulo.titdtemi.
def var vdt1        as   date  format "99/99/9999" initial today. 
def var vdt2        as   date  format "99/99/9999" initial today.
def stream tela.
def temp-table tt-cab
    field data   like fiscal.plarec
    field qtdlot as int
    field totval like fiscal.platot
    field codlot as char.
    
def temp-table tt-lanca
    field etbcod like estab.etbcod
    field etbcre as char
    field etbdeb as char
    field subdeb as char
    field subcre as char
    field cre  as char
    field deb  as char
    field val  as dec format ">,>>>,>>9.99" 
    field cod  as int format "999"
    field his  as char format "x(50)"
    field data like fiscal.plarec
    field total_lote as int
    field seq  as int. 
        
def var vprazo as dec.
def var vvista as dec.

repeat with 1 down side-label width 80 row 4 color blue/white:

    for each tt-lanca:
        delete tt-lanca.
    end.
    
    for each tt-cab:
        delete tt-cab.
    end.    
     
    update vetbcod label "Filial".

    if vetbcod = 0
    then display "Geral" @ estab.etbnom.
    else do: 
        find estab where estab.etbcod = vetbcod no-lock.
        disp estab.etbnom no-label.
    end.
    
    update vdt1 label "Data Inicial" at 1 
           vdt2 label "Data Final". 
   
    for each tt-lanca:
        delete tt-lanca.
    end.
    
    output stream stela to terminal.
    for each estab where if vetbcod = 0
                         then true
                         else estab.etbcod = vetbcod no-lock,
        each fiscal where fiscal.movtdc = 12           and
                          fiscal.emite  = estab.etbcod and
                          fiscal.opfcod = 1202         and
                          fiscal.plarec >= vdt1        and
                          fiscal.plarec <= vdt2 no-lock: 
                          
        disp stream stela fiscal.emite
                          fiscal.numero
                          fiscal.plarec format "99/99/9999" 
                                with 1 down. pause 0.
        
        vprazo = 0.
        vvista = fiscal.platot.
        run devol-vp.
        vvista = vvista - vprazo.

        if vvista < 0
        then vvista = 0.

        if fiscal.platot < vvista + vprazo
        then do:
            if vvista > 0
            then vvista = fiscal.platot - vprazo.
            else vprazo = fiscal.platot.
        end.
        data_mes = vdt2.
        
        find first tt-cab where tt-cab.data = data_mes no-error.
        if not avail tt-cab
        then do:
            create tt-cab.
            assign tt-cab.data   = data_mes.
        end.
        assign tt-cab.codlot = "70" + string(day(data_mes),"99")
               tt-cab.totval = tt-cab.totval + (vvista + vprazo).
               
        /**
        find first tt-lanca 
                   where /*tt-lanca.etbcre = "01" + string(fiscal.emite,">>9")*/
                   tt-lanca.etbcod = estab.etbcod
                   and   tt-lanca.data   = data_mes 
                   and no-error.
                
        if not avail tt-lanca
        then**/ 
        do:
            if vvista > 0
            then do:
                find first tt-lanca 
                   where /*tt-lanca.etbcre = "01" + string(fiscal.emite,">>9")*/
                   tt-lanca.etbcod = estab.etbcod
                   and   tt-lanca.data   = data_mes 
                   and tt-lanca.deb = "293" no-error.
                if not avail tt-lanca
                then do:
                create tt-lanca.
                assign tt-lanca.etbcod  = estab.etbcod /*0101*/
                   tt-lanca.etbdeb  = "01" + string(fiscal.emite,"999")
                   tt-lanca.etbcre  = "01001"
                            /*"01" + string(fiscal.emite,"99")*/
                   tt-lanca.data    = data_mes
                   tt-lanca.deb     = "293"  
                   tt-lanca.subcre  = ""
                   tt-lanca.subdeb  = ""
                   tt-lanca.cre     = "1"
                   tt-lanca.cod     = 0   
                   tt-lanca.his = "*LIVRE@DEV.N/DATA CF REG.ENTRADAS"
                   tt-cab.qtdlot = tt-cab.qtdlot + 1.
                end.
                tt-lanca.val     = tt-lanca.val + vvista.
            end.
            if vprazo > 0
            then do:
                find first tt-lanca 
                   where /*tt-lanca.etbcre = "01" + string(fiscal.emite,">>9")*/
                   tt-lanca.etbcod = estab.etbcod
                   and   tt-lanca.data   = data_mes 
                   and tt-lanca.deb = "163" no-error.
                if not avail tt-lanca
                then do:
                create tt-lanca.
                assign tt-lanca.etbcod  = estab.etbcod /*0101*/
                   tt-lanca.etbdeb  = "01" + string(fiscal.emite,"999")
                   tt-lanca.etbcre  = "01001"
                            /*"01" + string(fiscal.emite,"99")*/
                   tt-lanca.data    = data_mes
                   tt-lanca.deb     = "163"  
                   tt-lanca.subcre  = ""
                   tt-lanca.subdeb  = ""
                   tt-lanca.cre     = "15"
                   tt-lanca.cod     = 0   
                   tt-lanca.his = "*LIVRE@DEV.N/DATA CF REG.ENTRADAS"
                   tt-cab.qtdlot = tt-cab.qtdlot + 1.
                end.
                tt-lanca.val     = tt-lanca.val + vprazo.
            end.
        end.
        /*
        assign tt-lanca.val     = tt-lanca.val + fiscal.platot.
        */
        /*
        disp stream stela vvista(total) vprazo(total) vvista + vprazo(total)
            fiscal.platot(total).
        pause 0.    
        */    
    end.
    output stream stela close.
    
    vseq = 0.
    for each tt-lanca break by tt-lanca.data:

        vseq = vseq + 1.
        tt-lanca.seq = vseq.
         
        if last-of(tt-lanca.data)
        then vseq = 0.
        
    end.

    
    if opsys = "UNIX" 
    then output to value("/admcom/sispro/Dev_vend/dev_vend"  + 
                         string(day(vdt1),"99") + 
                         "a" +  
                         string(day(vdt2),"99")  +  
                         string(month(vdt2),"99") +  
                         string(year(vdt2),"9999") + ".txt").
    else output to value("l:\sispro\dev_vend\dev_vend" +
                         string(day(vdt1),"99") + 
                         "a" +   
                         string(day(vdt2),"99") +  
                         string(month(vdt2),"99") + 
                         string(year(vdt2),"9999") + ".txt").
        
 
    v-seq = 1000.

    for each tt-cab:
    
    /********************* HEADER ********************/
    cd_batch = "DEV_VEND" +
               string(day(today),"99") +  
               string(month(today),"99") +    
               string(year(today),"9999") +  
               string(time,"HH:MM").
               
    
    
    put unformatted 
    /* 01 */       "FISCAL         "
    /* 02 */       " " format "x(01)" 
    /* 03 */       "01001"  format "x(20)"
    /* 04 */       " " format "x(01)" 
    /* 05 */       cd_batch   format "x(30)" 
    /* 06 */       " " format "x(01)" 
    /* 07 */       "DEV_VEND" format "x(15)" 
    /* 08 */       " " format "x(01)" 
    /* 09 */       tt-cab.codlot   format "x(10)" 
    /* 10 */       " " format "x(01)"  
    /* 11 */       "HEADER    " 
    /* 12 */       " " format "x(01)"  
    /* 13 */       tt-cab.qtdlot  format "999999"  
    /* 14 */       " " format "x(01)"  
    /* 15 */       string(day(tt-cab.data),"99") format "99"  
                   string(month(tt-cab.data),"99") format "99"  
                   string(year(tt-cab.data),"9999") format "9999" 
    /* 16 */       " " format "x(01)"  
    /* 17 */       (tt-cab.totval * 100) format "999999999999999999"  
    /* 18 */       " " format "x(01)"  
    /* 19 */       (tt-cab.totval * 100) format "999999999999999999"  
    /* 20 */       " " format "x(01)"  
    /* 21 */       string(day(tt-cab.data),"99") format "99"  
                   string(month(tt-cab.data),"99") format "99"  
                   string(year(tt-cab.data),"9999") format "9999" 
    /* 22 */       " " format "x(01)"  
    /* 23 */       " " format "x(721)"  
    /* 24 */       " " format "x(01)"  
    /* 25 */       "000000"   
    /* 26 */       " " format "x(01)" skip.

    

    
    for each tt-lanca where tt-lanca.data   = tt-cab.data:

/*************************** LANCAMENTOS *************************/
    
    
        v-seq = v-seq + 1.
        put unformatted
    /* 01 */       "FISCAL         "
                   " " format "x(01)"
                   "01001" format "x(20)"
                   " " format "x(01)" 
                   cd_batch   format "x(30)" 
                   " " format "x(01)"
                   "DEV_VEND" format "x(15)"  
                   " " format "x(01)" 
                   tt-cab.codlot   format "x(10)" 
     /* 10 */      " " format "x(01)"
                   "LANCTO    "  
                   " " format "x(01)"
                   string(day(tt-lanca.data),"99") format "99"  
                   string(month(tt-lanca.data),"99") format "99"  
                   string(year(tt-lanca.data),"9999") format "9999" 
                   " " format "x(01)" 
      /* 15 */     tt-lanca.deb format "x(30)" 
      /* 16 */             " " format "x(01)" 
      /* 17 */     tt-lanca.subdeb format "x(22)" 
      /* 18 */     " " format "x(01)" 
      /* 19 */     tt-lanca.cre format "x(30)"
      /* 20 */      " " format "x(01)" 
      /* 21 */      tt-lanca.subcre format "x(22)" 
                   " " format "x(01)" 
                   tt-lanca.etbdeb format "x(20)" 
                   " " format "x(01)"
                   tt-lanca.etbcre   format "x(20)" 
                   " " format "x(01)" 
                   " " format "x(06)" 
                   " " format "x(01)" 
                   " " format "x(15)"  
     /* 30 */      " " format "x(01)"  
                   " " format "x(06)"  
                   " " format "x(01)"  
                   " " format "x(15)"  
                   " " format "x(01)"  
                   " " format "x(06)" 
                   " " format "x(01)" 
                   " " format "x(15)"  
                   " " format "x(01)" 
                   " " format "x(06)"
     /* 40 */      " " format "x(01)" 
                   " " format "x(15)"  
                   " " format "x(01)" 
                   " " format "x(06)" 
                   " " format "x(01)" 
                   " " format "x(15)"  
                   " " format "x(01)" 
                   " " format "x(06)" 
                   " " format "x(01)" 
                   " " format "x(15)" 
     /* 50 */      " " format "x(01)" 
                   " " format "x(06)" 
                   " " format "x(01)" 
                   " " format "x(15)"  
                   " " format "x(01)" 
                   " " format "x(06)" 
                   " " format "x(01)" 
                   " " format "x(15)"  
                   " " format "x(01)" 
                   " " format "x(06)"
     /* 60 */      " " format "x(01)" 
                   " " format "x(15)"   
                   " " format "x(01)" 
                   " " format "x(06)" 
                   " " format "x(01)" 
                   " " format "x(15)"  
                   " " format "x(01)" 
                   " " format "x(06)" 
                   " " format "x(01)" 
                   " " format "x(15)" 
     /* 70 */      " " format "x(01)" 
                   " " format "x(06)" 
                   " " format "x(01)" 
                   " " format "x(15)"  
                   " " format "x(01)" 
                   (tt-lanca.val * 100) format "999999999999999999" 
                   " " format "x(01)" 
                   "0    " format "x(05)" 
                   " " format "x(01)" 
                   tt-lanca.his format "x(119)"
     /* 80 */      " " format "x(01)" 
                   " " format "x(15)" 
                   " " format "x(01)" 
                   " " format "x(120)" 
                   " " format "x(01)" 
                   " " format "x(05)" 
                   " " format "x(01)" 
                   " " format "x(01)"   
                   " " format "x(01)"   
                   "EXC" format "x(03)"  
     /* 90 */      " " format "x(01)"   
                   " " format "x(10)"    
                   " " format "x(01)"   
                   " " format "x(10)"   
                   " " format "x(34)"   
                   " " format "x(01)"   
                   v-seq format "999999"
     /* 97 */      " " format "x(01)"  skip.

    end.
    
/******************** TRAILLER ******************************/
    
    
    put unformatted 
         /* 01 */       "FISCAL         "
         /* 02 */       " " format "x(01)"  
         /* 03 */       "01001" format "x(20)" 
         /* 04 */       " " format "x(01)"  
         /* 05 */       cd_batch   format "x(30)"  
         /* 06 */       " " format "x(01)"  
         /* 07 */       "DEV_VEND" format "x(15)"  
         /* 08 */       " " format "x(01)"  
         /* 09 */       tt-cab.codlot   format "x(10)"  
         /* 10 */       " " format "x(01)"   
         /* 11 */       "TRAILLER  "  
         /* 12 */       " " format "x(01)"  
         /* 13 */       " " format "x(785)"  
         /* 14 */       "000000" format "x(06)"  
         /* 15 */       " " format "x(01)" skip.

    end.    
    output close.

end.


procedure devol-vp:
    def var vtotpla as dec.
    def var vtotpro as dec.
    def var vqtmpro as dec.
    def buffer bplani for plani.
    def buffer cplani for plani.
    def buffer cmovim for movim.
    find plani where plani.etbcod = estab.etbcod 
                     and plani.emite  = fiscal.emite  
                     and plani.movtdc = fiscal.movtdc  
                     and plani.serie  = fiscal.serie  
                     and plani.numero = fiscal.numero 
                                   no-lock no-error.
    if avail plani
    then do:
        vtotpro = 0.
        for each movim where movim.etbcod = plani.etbcod and
                         movim.placod = plani.placod and
                         movim.movtdc = plani.movtdc and
                         movim.movdat = plani.pladat
                         no-lock: 
            vtotpro = vtotpro + movim.movpc * movim.movqtm.   
            vqtmpro = movim.movqtm.                              
            for each ctdevven where 
                    ctdevven.movtdc = plani.movtdc and
                    ctdevven.etbcod = plani.etbcod and
                    ctdevven.placod = plani.placod
                    no-lock:
                find first  cplani where 
                            cplani.movtdc = ctdevven.movtdc-ori and
                            cplani.etbcod = ctdevven.etbcod-ori and
                            cplani.placod = ctdevven.placod-ori
                            no-lock no-error.
                if avail cplani and cplani.crecod = 2
                then do:
                    for each cmovim where cmovim.movtdc = cplani.movtdc and
                             cmovim.etbcod = cplani.etbcod and
                             cmovim.placod = cplani.placod and
                             cmovim.movdat = cplani.pladat and
                             cmovim.procod = movim.procod
                             no-lock:
                        if cmovim.movqtm <= vqtmpro
                        then vprazo = vprazo + 
                                (movim.movpc * cmovim.movqtm).
                        else vprazo = vprazo +
                                (movim.movpc * vqtmpro).

                    end.
                end.
            end.                                             
        end.
    end.
end procedure.
