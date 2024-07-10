{admcab.i}
def var vlpraz like plani.platot.
def var vlvist like plani.platot.
def var totecf like plani.platot.

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
                         else estab.etbcod = vetbcod no-lock:
        do vdata = vdt1 to vdt2:
            display stream stela estab.etbcod vdata 
                with frame ff side-label 1 down. pause 0.

            assign vlpraz  = 0 
                   vlvist  = 0 
                   totecf  = 0.
           
            for each plani use-index pladat 
                            where plani.movtdc = 5       and
                                  plani.etbcod = estab.etbcod and
                                  plani.pladat = vdata no-lock.
                if plani.crecod = 1
                then vlvist = vlvist +  if plani.outras > 0
                                        then plani.outras
                                        else plani.platot.
                if plani.crecod = 2
                then vlpraz = vlpraz + if plani.outras > 0
                                       then plani.outras
                                       else plani.platot.

            end.
            if vdata >= 07/01/2005
            then do: 
                for each mapctb where mapctb.etbcod = estab.etbcod and
                                      mapctb.datmov = vdata no-lock.
                    totecf = totecf + 
                             mapctb.t01 + 
                             mapctb.t02 + 
                             mapctb.t03 + 
                             mapctb.vlsub.
                end.      
            end.
            else do:
                for each serial where serial.etbcod = estab.etbcod and
                                      serial.serdat = vdata no-lock:
                
                    totecf = totecf + 
                             serial.icm12 + 
                             serial.icm17 +
                             serial.sersub.
                end.                      
            end.
                    
            if vlpraz > 0 
            then do: 
                if vlvist < vlpraz
                then do: 
                    vlvist = (vlvist / vlpraz) * totecf.
                    vlpraz = totecf - vlvist.
                end. 
                else do: 
                    vlpraz = (vlpraz / vlvist) * totecf.
                    vlvist = totecf - vlpraz.
                end.
            end.
            else vlvist = totecf.

            
            if vlpraz = 0
            then next.
            

            find first tt-cab where tt-cab.data = vdata no-error.
            if not avail tt-cab
            then do:
                create tt-cab.
                assign tt-cab.data   = vdata.
            end.
            assign tt-cab.codlot = "20" + string(day(vdata),"99")
                   tt-cab.totval = tt-cab.totval + vlpraz.
                   
        
            find first tt-lanca 
                       where tt-lanca.etbcre = "01" + string(estab.etbcod,">>9")
                       and   tt-lanca.data   = vdata no-error.
                   
            if not avail tt-lanca
            then do:
                create tt-lanca.
                assign tt-lanca.etbcod  = 0101
                       tt-lanca.etbdeb  = "0101"
                       tt-lanca.etbcre  = "01" + string(estab.etbcod,">>9")
                       tt-lanca.data    = vdata
                       tt-lanca.deb     = "1"  
                       tt-lanca.subcre  = ""
                       tt-lanca.subdeb  = ""
                       tt-lanca.cre     = "162"
                       tt-lanca.cod     = 0   
                       tt-lanca.his = "*LIVRE@VENDAS A PRAZO"
                       tt-cab.qtdlot = tt-cab.qtdlot + 1.
            end.
            assign tt-lanca.val     = tt-lanca.val + vlpraz.
        
        end.
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
    then output to value("/admcom/sispro/venapr" + string(vetbcod,">>9") 
                          + ".txt").
    else output to value("l:\sispro\venapr" + string(vetbcod,">>9") + ".txt").

    v-seq = 1000.

    for each tt-cab:
    
    /********************* HEADER ********************/
    cd_batch = "INTVENAPR" +
               string(day(today),"99") +  
               string(month(today),"99") +    
               string(year(today),"9999") +  
               "0101".
               
    
    
    put unformatted 
    /* 01 */       "FISCAL         "
    /* 02 */       " " format "x(01)" 
    /* 03 */       "0101" format "x(20)"
    /* 04 */       " " format "x(01)" 
    /* 05 */       cd_batch   format "x(30)" 
    /* 06 */       " " format "x(01)" 
    /* 07 */       "INTVENAPR" format "x(15)" 
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
                   "0101" format "x(20)"
                   " " format "x(01)" 
                   cd_batch   format "x(30)" 
                   " " format "x(01)"
                   "INTVENAPR" format "x(15)"  
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
         /* 03 */       "0101" format "x(20)" 
         /* 04 */       " " format "x(01)"  
         /* 05 */       cd_batch   format "x(30)"  
         /* 06 */       " " format "x(01)"  
         /* 07 */       "INTVENAPR" format "x(15)"  
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
