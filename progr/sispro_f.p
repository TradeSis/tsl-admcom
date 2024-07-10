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
        each fiscal where fiscal.movtdc = 4       and
                          fiscal.desti  = estab.etbcod and
                          fiscal.plarec >= vdt1   and
                          fiscal.plarec <= vdt2 no-lock.

        if fiscal.emite = 5027
        then next.

        if fiscal.opfcod <> 1102 and
           fiscal.opfcod <> 2102 and
           fiscal.opfcod <> 1101 and
           fiscal.opfcod <> 2101 and
           fiscal.opfcod <> 1403 and
           fiscal.opfcod <> 2403
        then next.

        find forne where forne.forcod = fiscal.emite no-lock no-error.

        disp stream stela fiscal.numero format ">>>>>>>>9"
                          fiscal.plarec format "99/99/9999" 
                                with 1 down. pause 0.
        
 
        if fiscal.emite = 533 or
           fiscal.emite = 100071
        then next.
        
        find first titulo where
                   titulo.empcod = 19 and
                   titulo.titnat = yes and
                   /*titulo.modcod = "DUP" and*/
                   titulo.modcod <> "" and
                   titulo.etbcod = fiscal.desti and
                   titulo.clifor = fiscal.emite and
                   titulo.titnum = string(fiscal.numero)
                   no-lock no-error.
        if not avail titulo then next.

        find first tt-cab where tt-cab.data = fiscal.plarec no-error.
        if not avail tt-cab
        then do:
            create tt-cab.
            assign tt-cab.data   = fiscal.plarec.
        end.
        assign tt-cab.qtdlot = tt-cab.qtdlot + 1
               tt-cab.codlot = "40" + string(day(fiscal.plarec),"99")
               tt-cab.totval = tt-cab.totval + fiscal.platot.
        
        create tt-lanca.
        assign tt-lanca.val     = fiscal.platot
               tt-lanca.etbcod  = 01001
               tt-lanca.etbcre  = "01001"
               tt-lanca.etbdeb  = "01" + string(fiscal.desti,"999")
               tt-lanca.data    = fiscal.plarec
               tt-lanca.cre     = "91"  
               tt-lanca.subcre  = string(fiscal.emite)
               tt-lanca.deb     = "168"
               tt-lanca.cod     = 0  
               tt-lanca.his = "*LIVRE@S/NT.N. " 
                               + string(fiscal.numero,"999999999") 
                               + " " + string(forne.fornom).
                               
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
    then varquivo = ("/admcom/sispro/Compras/compras"  + 
                         string(day(vdt1),"99") + 
                         "a" +  
                         string(day(vdt2),"99")  +  
                         string(month(vdt2),"99") +  
                         string(year(vdt2),"9999") + ".txt").
    else varquivo = ("l:\sispro\Compras\compras" +
                         string(day(vdt1),"99") + 
                         "a" +   
                         string(day(vdt2),"99") +  
                         string(month(vdt2),"99") + 
                         string(year(vdt2),"9999") + ".txt").
        

    output to value(varquivo).
    
    v-seq = 0.

    for each tt-cab:
    
    /********************* HEADER ********************/
    cd_batch = "COMPRAS" +
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
    /* 07 */       "COMPRAS" format "x(15)" 
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
                   "COMPRAS" format "x(15)"  
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
                   " " format "x(01)" 
                   tt-lanca.subdeb format "x(22)" 
                   " " format "x(01)" 
                   tt-lanca.cre format "x(30)"
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
         /* 07 */       "COMPRAS" format "x(15)"  
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
