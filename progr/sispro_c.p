{admcab.i}

def var varquivo as char.
def var codigo_evento as char.
def var vflag as log.
def var ii as int.
def var vv as char.
def var cc as char.
def var vi as int.
def var zz as int.

def var vtipo as l format "Entrada/Saida" initial no.

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
        

def var vetblan like estab.etbcod.

repeat with 1 down side-label width 80 row 4 color blue/white:

    for each tt-lanca:
        delete tt-lanca.
    end.
    
    for each tt-cab:
        delete tt-cab.
    end.    

     
           
    update vdt1 label "Data Inicial" colon 20
           vdt2 label "Data Final" 
           vtipo label "Movimento" colon 20.

    if vtipo = yes
    then assign vv = "D"
                codigo_evento = "CXA_ENTR".
    else assign vv = "C"
                codigo_evento = "CXA_SAID".

       
   
    for each tt-lanca:
        delete tt-lanca.
    end.

    
    output stream stela to terminal.
    
    do vdata = vdt1 to vdt2:
    
        for each lancxa where lancxa.datlan = vdata and
                              lancxa.lantip = vv no-lock:
            
            find hispad where hispad.hiscod = lancxa.lanhis no-lock no-error.
            if not avail hispad 
            then next.
            /*
            find tablan where tablan.lancod = lancxa.lancod no-lock no-error. 
            */
            /*
            find first tablan where 
                        tablan.codred = lancxa.lancod no-lock no-error.
            if not avail tablan 
            then next.

            find sispro where sispro.codred = tablan.codred no-lock no-error.
            */
            
            find sispro where sispro.codred = lancxa.lancod no-lock no-error.
            if not avail sispro
            then next.
            if lancxa.datlan >= 01/01/07
            then do:
                sresp = no.
                run ident-icms.
                if sresp
                then do:
                    find sispro where 
                            sispro.codred = 116 no-lock no-error.
                    if not avail sispro
                    then next.
 
                end.
            end.

            find first tt-cab where tt-cab.data = lancxa.datlan no-error.
            if not avail tt-cab
            then do:
                create tt-cab.
                assign tt-cab.data   = lancxa.datlan.
            end.
            assign tt-cab.codlot = "20" + string(day(datlan),"99")
                   tt-cab.totval = tt-cab.totval + lancxa.vallan.
                   tt-cab.qtdlot = tt-cab.qtdlot + 1.

            if vtipo
            then tt-cab.codlot = "30" + string(day(datlan),"99").
                   
            find estab where estab.etbcod = lancxa.etbcod no-lock no-error.
            if not avail estab or
                estab.etbcgc = ""
            then vetblan = 996.
            else vetblan = lancxa.etbcod.   
                        
            
            create tt-lanca. 
            assign tt-lanca.etbcod  = 01001
                   tt-lanca.etbcre  =  "01" + string(vetblan,"999")
                   tt-lanca.etbdeb  =  "01" + string(vetblan,"999")
                   tt-lanca.data    = lancxa.datlan
                   tt-lanca.cre     = "1"  
                   tt-lanca.deb     = string(sispro.codred)
                   tt-lanca.cod     = 0   
                   tt-lanca.val     = tt-lanca.val + lancxa.vallan.
            
             tt-lanca.cre = string(lancxa.cxacod).
             
            /*if tablan.lancre > 0
            then tt-lanca.cre = string(tablan.lancre).
            else*/ do:
            if lancxa.lancod = 1233 or
               lancxa.lancod = 1234 or
               lancxa.lancod = 1235 or
               lancxa.lancod = 1236
            then tt-lanca.cre = "4".
            
            if lancxa.lancod = 1594
            then tt-lanca.cre = "107".
            
            if lancxa.forcod = 533 or
               lancxa.forcod = 100071 or
               lancxa.forcod = 100072
            then tt-lanca.deb = "190".
            end.        
            
            if tt-lanca.cre = "13"
            then tt-lanca.cre = "1".
            
            if vtipo
            then do:
                assign tt-lanca.etbdeb  = "01" + string(vetblan,"999")
                       tt-lanca.etbcre  =  "01" + string(vetblan,"999")
                       tt-lanca.cre     = "235"   
                       tt-lanca.deb     = "1".
                       
                if lancxa.forcod = 100090
                then tt-lanca.cre = "93".
                if lancxa.forcod = 101290
                then tt-lanca.cre = "116".
                if lancxa.forcod = 103866
                then tt-lanca.cre = "30".
                
                
            end.            
            if sispro.codred = 91 or
               sispro.codred = 650
            then do:
                 assign tt-lanca.subdeb  = string(lancxa.forcod)
                        tt-lanca.etbdeb  = "01001". 
            end.
            else if tt-lanca.cre = "91" or
                    tt-lanca.cre = "650"
                then tt-lanca.subcre  = string(lancxa.forcod).
                    
            zz = 0.
            ii = 0.
            vflag = no.
            do zz = 1 to 50. /* length(hisdes). */
                if substring(hispad.hisdes,zz,1) = ""
                then ii = ii + 1.
                else ii = 0.
    
                cc = cc + substring(hispad.hisdes,zz,1).
                if ii >= 3
                then do:
                    vflag = yes.
                    cc = cc + lancxa.comhis. 
                    tt-lanca.his     = "*LIVRE@" + cc.
                    cc = "".
                    leave.
                end.
            end.
            if vflag = no
            then do:
                tt-lanca.his     = "*LIVRE@" + cc.
                cc = "".
            end.
   
            if vtipo
            then do:
                if lancxa.etbcod = 999
                then tt-lanca.etbcre  = /*if tablan.etbfixc 
                                        then "01001" else*/ "01996".
                if lancxa.etbcod = 0 
                then tt-lanca.etbcre  = "01001". 
                if lancxa.etbcod = 98
                then tt-lanca.etbcre  = /*if tablan.etbfixc
                                        then "01001" else*/ "01095".
                if tt-lanca.his = "*LIVRE@"
                then tt-lanca.his = "*LIVRE@REC.DESC. S/DUPL.".
                
            end.
            else do:
                if lancxa.etbcod = 999
                then tt-lanca.etbdeb  = /*if tablan.etbfixd
                                        then "01001" else*/ "01996".
                if lancxa.etbcod = 0 
                then tt-lanca.etbdeb  = "01001". 
                if lancxa.etbcod = 98
                then tt-lanca.etbdeb  = /*if tablan.etbfixd
                                        then "01001" else*/ "01095". 
                if tt-lanca.his = "*LIVRE@"
                then tt-lanca.his = "*LIVRE@PG.REC. S/N.".
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


    if vtipo
    then do:
        
        if opsys = "UNIX"
        then varquivo = "/admcom/sispro/Cxa_entr/cxa_entr"  + 
                             string(day(vdt1),"99") + 
                             "a" + 
                             string(day(vdt2),"99")  + 
                             string(month(vdt2),"99") + 
                             string(year(vdt2),"9999") + ".txt".
        else varquivo = "l:\sispro\cxa_entr\cxa_entr" +
                            string(day(vdt1),"99") + 
                            "a" +  
                            string(day(vdt2),"99") + 
                            string(month(vdt2),"99") +
                            string(year(vdt2),"9999") + ".txt".
        /***
        if opsys = "UNIX"
        then output to value("/admcom/sispro/Cxa_entr/cxa_entr"  + 
                             string(day(vdt1),"99") + 
                             "a" + 
                             string(day(vdt2),"99")  + 
                             string(month(vdt2),"99") + 
                             string(year(vdt2),"9999") + ".txt").
        else output to value("l:\sispro\cxa_entr\cxa_entr" +
                            string(day(vdt1),"99") + 
                            "a" +  
                            string(day(vdt2),"99") + 
                            string(month(vdt2),"99") +
                            string(year(vdt2),"9999") + ".txt").
         **/
    end.
    else do: 
        
        if opsys = "UNIX"
        then varquivo = "/admcom/sispro/Cxa_said/cxa_said"  + 
                             string(day(vdt1),"99") + 
                             "a" + 
                             string(day(vdt2),"99")  + 
                             string(month(vdt2),"99") + 
                             string(year(vdt2),"9999") + ".txt".
        else varquivo = "l:\sispro\cxa_said\cxa_said" +
                            string(day(vdt1),"99") + 
                            "a" +  
                            string(day(vdt2),"99") + 
                            string(month(vdt2),"99") +
                            string(year(vdt2),"9999") + ".txt".
    
        /**
        if opsys = "UNIX"
        then output to value("/admcom/sispro/Cxa_said/cxa_said"  + 
                             string(day(vdt1),"99") + 
                             "a" + 
                             string(day(vdt2),"99")  + 
                             string(month(vdt2),"99") + 
                             string(year(vdt2),"9999") + ".txt").
        else output to value("l:\sispro\cxa_said\cxa_said" +
                            string(day(vdt1),"99") + 
                            "a" +  
                            string(day(vdt2),"99") + 
                            string(month(vdt2),"99") +
                            string(year(vdt2),"9999") + ".txt").
        **/

    end.

    output to value(varquivo).
    
    v-seq = 1000.

    for each tt-cab:
    
    /********************* HEADER ********************/
    cd_batch = codigo_evento +
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
    /* 07 */       codigo_evento format "x(15)" 
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
                   codigo_evento format "x(15)"  
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
         /* 07 */       codigo_evento format "x(15)"  
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

    if opsys = "UNIX"
    then do.
        output to ./unixdos.txt.
        unix silent unix2dos value(varquivo). 
        unix silent chmod 777 value(varquivo).
        output close.
        unix silent value("rm ./unixdos.txt -f").
    end.

end.

procedure ident-icms:
    sresp = no.
    do vi = 1 to 50:
        if substr(string(lancxa.comhis),vi,1) = "/"
        then do:
            if substr(string(lancxa.comhis),vi + 1,4) = "ICMS"
            then do:
                sresp = yes.
                leave.
            end.
        end.
    end.  
end procedure.
