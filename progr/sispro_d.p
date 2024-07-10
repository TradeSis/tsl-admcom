{admcab.i}
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
    field data   like plani.pladat
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
    field data like plani.pladat
    field total_lote as int
    field seq  as int. 
        

def var varquivo as char.
def var vemite like plani.emite.

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
        each plani where plani.movtdc = 13           and
                         plani.etbcod = estab.etbcod and
                         plani.pladat >= vdt1        and
                         plani.pladat <= vdt2        no-lock.
        
        if plani.emite = 5027
        then next.
       
        find forne where forne.forcod = plani.desti no-lock no-error.
        if not avail forne
        then next.

 
        disp stream stela plani.numero
                          plani.pladat format "99/99/9999" 
                                with 1 down. pause 0.
        

    
        find first tt-cab where tt-cab.data = plani.pladat no-error.
        if not avail tt-cab
        then do:
            create tt-cab.
            assign tt-cab.data   = plani.pladat.
        end.
        assign tt-cab.qtdlot = tt-cab.qtdlot + 1
               tt-cab.codlot = "50" + string(day(plani.pladat),"99")
               tt-cab.totval = tt-cab.totval + plani.platot.
               
        
        if plani.emite = 998 
        then vemite = 995.
        else if plani.emite = 930
        then vemite = 900.
        else vemite = plani.emite.

        create tt-lanca.
        assign tt-lanca.val     = plani.platot
               tt-lanca.etbcod  = 01001
               tt-lanca.etbdeb  = "01001"
               tt-lanca.etbcre  = "01" + string(vemite,"999")
               tt-lanca.data    = plani.pladat
               tt-lanca.deb     = "91"  
               tt-lanca.subcre  = ""
               tt-lanca.subdeb  = string(plani.desti)
               tt-lanca.cre     = "170"
               tt-lanca.cod     = 0  
               tt-lanca.his     = 
                       "*LIVRE@DEVOLUCAO DE COMPRA CONF. REGISTRO DE SAIDAS "   
                       + string(plani.numero,"999999")  + 
                       "-" + string(forne.fornom).
 
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
    then varquivo = ("/admcom/sispro/Dev_comp/dev_comp"  + 
                         string(day(vdt1),"99") +  
                         "a" +  
                         string(day(vdt2),"99")  +  
                         string(month(vdt2),"99") +  
                         string(year(vdt2),"9999") + ".txt").
    else varquivo = ("l:\sispro\dev_comp\Dev_comp" +
                         string(day(vdt1),"99") + 
                         "a" +  
                         string(day(vdt2),"99") + 
                         string(month(vdt2),"99") +
                         string(year(vdt2),"9999") + ".txt").
        

    output to value(varquivo).
    
    v-seq = 0.

    for each tt-cab:
    
    /********************* HEADER ********************/
    cd_batch = "DEV_COMP" +
               string(day(today),"99") +  
               string(month(today),"99") +    
               string(year(today),"9999") +   
               string(time,"HH:MM").
               
    
    
    put unformatted 
    /* 01 */       "FISCAL         "
    /* 02 */       " " format "x(01)" 
    /* 03 */       "01001" format "x(20)"
    /* 04 */       " " format "x(01)" 
    /* 05 */       cd_batch   format "x(30)" 
    /* 06 */       " " format "x(01)" 
    /* 07 */       "DEV_COMP" format "x(15)" 
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
                   "DEV_COMP" format "x(15)"  
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
         /* 07 */       "DEV_COMP" format "x(15)"  
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

    output to value("./unixdos." + string(time)).
    unix silent value("unix2dos " + varquivo).
    output close.
 
end.
