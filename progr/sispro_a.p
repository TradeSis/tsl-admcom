{admcab.i}
def var vlpraz like plani.platot.
def var vlvist like plani.platot.
def var totecf like plani.platot.
def var vlentr like plani.platot.
def var vlpres like plani.platot.
def var vljuro like plani.platot.
def var vetbi  like estab.etbcod.
def var vetbf  like estab.etbcod.

def var vindex as int.
def var vnomarq as char.
def var vlote as char.
def var vesc as char format "x(15)" extent 3
        init["Venda a Vista","Venda a Prazo","Recebimentos"].
         
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
        

form vesc with frame f-esc 1 down no-label centered
        row 4.

repeat with 1 down side-label width 80 row 7 color blue/white:

    for each tt-lanca:
        delete tt-lanca.
    end.
    
    for each tt-cab:
        delete tt-cab.
    end.    
    disp vesc with frame f-esc.
    choose field vesc with frame f-esc.
    vindex = frame-index.
     
    update vetbi label "Filial"
           vetbf label "Ate".

    
    update vdt1 label "Data Inicial" at 1 
           vdt2 label "Data Final". 
   
    for each tt-lanca:
        delete tt-lanca.
    end.

    
    output stream stela to terminal.
    for each estab where estab.etbcod >= vetbi and
                         estab.etbcod <= vetbf no-lock:
        do vdata = vdt1 to vdt2:
            display stream stela estab.etbcod vdata 
                with frame ff side-label 1 down. pause 0.

            assign vlpraz  = 0 
                   vlvist  = 0 
                   totecf  = 0
                   vlpres  = 0
                   vljuro  = 0
                   vlentr  = 0.
           
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
                       
                    if mapctb.ch2 = "E"  
                    then next.
 
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
            if vindex = 1 then vlpraz = 0.
            else if vindex = 2 then vlvist = 0.
            else if vindex = 3 then assign vlvist = 0 vlpraz = 0.
            
            if vindex = 3
            then
            for each titold where titold.etbcobra = estab.etbcod and
                                  titold.titdtpag = vdata        no-lock.
                if titold.clifor = 1
                then next.
                if titold.titnat = yes
                then next.
                if titold.modcod <> "CRE"
                then next.
                if titold.etbcod = estab.etbcod and
                   titold.titpar = 0
                then do:
                    assign vlentr  = vlentr  + titold.titvlcob.
                end.
                else do:
                    assign vlpres = vlpres + titold.titvlcob 
                           vljuro = vljuro + titold.titjuro.
                end.
            end.
            
            vlote = "".
            
            if vlvist > 0 or
               vlpraz > 0 or
               vljuro > 0 or
               vlentr > 0 or
               vlpres > 0
            then do:  
                if vindex = 1 then vlote = "60".
                else if vindex = 2 then vlote = "80".
                else if vindex = 3 then vlote = "90".
                find first tt-cab where tt-cab.data = vdata no-error.
                if not avail tt-cab
                then do:
                    create tt-cab.
                    assign tt-cab.data   = vdata
                           tt-cab.codlot = vlote + string(day(vdata),"99").

                end.
            end.                               
        
            if vlvist > 0 
            then do:

                find first tt-lanca 
                           where tt-lanca.etbcre = "01" + 
                                                 string(estab.etbcod,"999") and
                                 tt-lanca.data   = vdata and
                                 tt-lanca.cre    = "161" no-error.
                   
                if not avail tt-lanca
                then do:
                    create tt-lanca.
                    assign tt-lanca.etbcod  = 01001
                           tt-lanca.etbdeb  = "01001"
                           tt-lanca.etbcre  = "01" + string(estab.etbcod,"999")
                           tt-lanca.data    = vdata
                           tt-lanca.deb     = "1"  
                           tt-lanca.subcre  = ""
                           tt-lanca.subdeb  = ""
                           tt-lanca.cre     = "161"
                           tt-lanca.cod     = 0   
                           tt-lanca.his = "*LIVRE@VENDAS A VISTA N/DATA"
                           tt-cab.qtdlot = tt-cab.qtdlot + 1.
                end.
                assign tt-lanca.val  = tt-lanca.val + vlvist
                       tt-cab.totval = tt-cab.totval + vlvist.
            end.
            
            if vljuro > 0
            then do:
                find first tt-lanca 
                     where tt-lanca.etbcre = "01" + 
                                             string(estab.etbcod,"999") and
                           tt-lanca.data   = vdata and
                           tt-lanca.cre    = "234" no-error.
                   
                if not avail tt-lanca 
                then do: 
                    create tt-lanca.
                    assign tt-lanca.etbcod  = 01001
                           tt-lanca.etbdeb  = "01001"
                           tt-lanca.etbcre  = "01001"
                                    /*"01" + string(estab.etbcod,"999")*/
                           tt-lanca.data    = vdata
                           tt-lanca.deb     = "1"  
                           tt-lanca.subcre  = ""
                           tt-lanca.subdeb  = ""
                           tt-lanca.cre     = "234"
                           tt-lanca.cod     = 0   
                           tt-lanca.his     = 
                                    "*LIVRE@REC.DE JUROS DIVS.CLIENTES N/DATA"
                           tt-cab.qtdlot = tt-cab.qtdlot + 1.
                end.
                assign tt-lanca.val  = tt-lanca.val + vljuro
                       tt-cab.totval = tt-cab.totval + vljuro.
            end.
            
            
            if vlpres > 0
            then do:
                create tt-lanca.
                assign tt-lanca.etbcod  = 01001
                       tt-lanca.etbdeb  = "01001"
                       tt-lanca.etbcre  = "01001" 
                                    /*"01" + string(estab.etbcod,"999") */
                       tt-lanca.data    = vdata
                       tt-lanca.deb     = "1"   
                       tt-lanca.subcre  = "" 
                       tt-lanca.subdeb  = "" 
                       tt-lanca.cre     = "15" 
                       tt-lanca.cod     = 0    
                       tt-lanca.his = "*LIVRE@REC.DE DIVS.CLIENTES N/DATA" 
                       tt-cab.qtdlot = tt-cab.qtdlot + 1
                       tt-lanca.val  = vlpres
                       tt-cab.totval = tt-cab.totval + vlpres.
            end.
            
            
            if vlentr > 0
            then do:
                create tt-lanca.
                assign tt-lanca.etbcod  = 01001
                       tt-lanca.etbdeb  = "01001"
                       tt-lanca.etbcre  = "01001" 
                                        /*"01" + string(estab.etbcod,"999")*/
                       tt-lanca.data    = vdata
                       tt-lanca.deb     = "1"   
                       tt-lanca.subcre  = "" 
                       tt-lanca.subdeb  = "" 
                       tt-lanca.cre     = "15" 
                       tt-lanca.cod     = 0    
                       tt-lanca.his = "*LIVRE@REC.DE DIVS.CLIENTES N/DATA" 
                       tt-cab.qtdlot = tt-cab.qtdlot + 1
                       tt-lanca.val  = vlentr
                       tt-cab.totval = tt-cab.totval + vlentr.
            end.
            
            if vlpraz > 0
            then do:
                create tt-lanca.
                assign tt-lanca.etbcod  = 01001
                       tt-lanca.etbdeb  = "01001"
                       tt-lanca.etbcre  = "01" + string(estab.etbcod,"999")
                       tt-lanca.data    = vdata
                       tt-lanca.deb     = "15"   
                       tt-lanca.subcre  = "" 
                       tt-lanca.subdeb  = "" 
                       tt-lanca.cre     = "162" 
                       tt-lanca.cod     = 0    
                       tt-lanca.his = "*LIVRE@VENDAS A PRAZO CF REG SAIDAS" 
                       tt-cab.qtdlot = tt-cab.qtdlot + 1
                       tt-lanca.val  = vlpraz
                       tt-cab.totval = tt-cab.totval + vlpraz.
            end.
            

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
    vnomarq = "".
    if vindex = 1
    then vnomarq = "venda_vista".
    else if vindex = 2
    then vnomarq = "venda_prazo".
    else if vindex = 3
    then vnomarq = "recebimento".
    if opsys = "UNIX"
    then output to value("/admcom/sispro/vendas/"  + vnomarq +
                         string(day(vdt1),"99") + 
                         "a" + 
                         string(day(vdt2),"99")  + 
                         string(month(vdt2),"99") + 
                         string(year(vdt2),"9999") + ".txt").
    else output to value("l:~\sispro~\vendas~\" + vnomarq +
                        string(day(vdt1),"99") + 
                        "a" +  
                        string(day(vdt2),"99") + 
                        string(month(vdt2),"99") +
                        string(year(vdt2),"9999") + ".txt").

    v-seq = 1000.

    for each tt-cab:
    

    /********************* HEADER ********************/
    cd_batch = "VENDAS" +
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
    /* 07 */       "VENDAS" format "x(15)" 
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
                   "VENDAS" format "x(15)"  
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
         /* 07 */       "VENDAS" format "x(15)"  
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
