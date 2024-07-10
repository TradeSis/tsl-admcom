{admcab.i}

def var totecf like plani.platot.


def var ct-vist     as   int.
def var ct-praz     as   int.
def var ct-entr     as   int.
def var ct-pres     as   int.
def var ct-juro     as   int.
def var ct-desc     as   int.


def var vlvist      like plani.platot.
def var vlpraz      like plani.platot.
def var vlentr      like plani.platot.
def var vljuro      like plani.platot.
def var vldesc      like plani.platot.
def var vlpred      like plani.platot.


def var totavi like titold.titvlcob.
def var totapr like titold.titvlcob.
def var totent like titold.titvlcob.
def var totjur like titold.titjuro.
def var totpre like titold.titvlcob.

def var vlpres      like plani.platot.
def var vcta01      as char format "99999".
def var vcta02      as char format "99999".
def var vdata       like titold.titdtemi.

def var v-seq as int.
def var vseq as int.
def var qtd_lote as int.
def var cod_lote as char.
def var cd_batch as char.
def stream stela.
def var vetbcod like estab.etbcod.
def var vdt1        as   date  format "99/99/9999" initial today. 
def var vdt2        as   date  format "99/99/9999" initial today.
def var vlote       as char format "xxxx".
def stream tela.
def temp-table tt-cab
    field etbcod like estab.etbcod
    field data   like plani.pladat
    field qtdlot as int
    field totval like fiscal.platot
    field codlot as char
    field codest as char.

def temp-table tt-lanca
    field tip  as char format "x(01)"
    field cre  as char format "x(04)"
    field val  as dec format ">,>>>,>>9.99" 
    field cod  as int format "999"
    field his  as char format "x(50)"
    field etbcod like estab.etbcod
    field data like plani.pladat
    field total_lote as int
    field seq  as int. 
        


repeat with 1 down side-label width 80 row 4 color blue/white:

    for each tt-lanca:
        delete tt-lanca.
    end.
    
    for each tt-cab:
        delete tt-cab.
    end.    
    
    update vetbcod label "Filial" colon 20.
           
    find estab where estab.etbcod = vetbcod no-lock.
    
    disp estab.etbnom no-label.
    
    update vdt1 label "Data Inicial" colon 20
           vdt2 label "Data Final". 
   
    for each tt-lanca:
        delete tt-lanca.
    end.

    
    output stream stela to terminal.
    
    
    for each estab where estab.etbcod = vetbcod no-lock:
    
        assign  vlpraz  = 0 vlvist  = 0 vlentr  = 0 vljuro  = 0 
                vldesc  = 0 vlpres = 0
                ct-vist = 0
                ct-praz = 0 vlpred  = 0  
                totecf = 0.



        totavi = 0.
        totapr = 0.
        totjur = 0.
        totpre = 0.
        totent = 0.


    
        do vdata = vdt1 to vdt2:
            display stream stela estab.etbcod vdata 
                with frame ff side-label 1 down. pause 0.
            assign vcta01 = string(estab.prazo,"99999")
                   vcta02 = string(estab.vista,"99999").
        
            assign  vlpraz  = 0 vlvist  = 0 vlentr  = 0 vljuro  = 0 
                    vldesc  = 0 vlpres = 0
                    ct-pres = 0 ct-juro = 0 ct-desc = 0 ct-vist = 0
                    ct-praz = 0 vlpred  = 0  
                    totecf = 0.
            for each plani use-index pladat 
                            where plani.movtdc = 5       and
                                  plani.etbcod = estab.etbcod and
                                  plani.pladat = vdata no-lock.
                if plani.crecod = 1
                then assign ct-vist = ct-vist + 1
                            vlvist = vlvist +  if plani.outras > 0
                                               then plani.outras
                                               else plani.platot.
                if plani.crecod = 2
                then assign ct-praz = ct-praz + 1
                            vlpraz = vlpraz + if plani.outras > 0
                                              then plani.outras
                                              else plani.platot.

            end.
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
                    assign ct-entr = ct-entr + 1
                           vlentr  = vlentr  + titold.titvlcob.
                end.
                else do:
                    assign vlpres = vlpres + titold.titvlcob /* titold.titvlpag
                                    - titold.titjuro + titold.titdesc */
                           vljuro = vljuro + titold.titjuro
                           ct-pres = ct-pres + if titold.titvlcob > 0
                                               then 1
                                               else 0
                           ct-juro = ct-juro + if titold.titjuro > 0
                                               then 1
                                               else 0.
                end.
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

            do on error undo, retry:
            
                if vlpraz = 0 and
                   vlvist = 0 and
                   vljuro = 0 and
                   vlpres = 0 and
                   vlentr = 0
                then next.
        
                totavi = totavi + vlvist.
                totapr = totapr + vlpraz.
                totjur = totjur + vljuro.
                totpre = totpre + vlpres.
                totent = totent + vlentr.
                
                
                
                create tt-lanca.
                assign tt-lanca.cre  = vcta01   
                       tt-lanca.data = vdata  
                       tt-lanca.val  = vlpraz  
                       tt-lanca.cod  = 0
                       tt-lanca.etbcod = estab.etbcod.
            
                create tt-lanca.
                assign tt-lanca.cre  = vcta02  
                       tt-lanca.data = vdata
                       tt-lanca.val  = vlvist 
                       tt-lanca.cod  = 0
                       tt-lanca.etbcod = estab.etbcod.
    
                create tt-lanca.
                assign tt-lanca.cre  = "15"  
                       tt-lanca.data = vdata
                       tt-lanca.val  = vlentr
                       tt-lanca.cod  = 0
                       tt-lanca.etbcod = estab.etbcod.

            
                create tt-lanca. 
                assign tt-lanca.cre  = "15"   
                       tt-lanca.data = vdata 
                       tt-lanca.val  = vlpres 
                       tt-lanca.cod  = 0
                       tt-lanca.etbcod = estab.etbcod.
            
            
                create tt-lanca. 
                assign tt-lanca.cre  = "6839"   
                       tt-lanca.data = vdata 
                       tt-lanca.val  = vljuro 
                       tt-lanca.cod  = 0
                       tt-lanca.etbcod = estab.etbcod.
       
            end.
        end.    

 
    
       disp stream stela plani.numero
                         plani.pladat format "99/99/9999" 
                                with 1 down. pause 0.
        
        find first tt-cab where tt-cab.etbcod = plani.emite and
                                tt-cab.data   = plani.pladat no-error.
        if not avail tt-cab
        then do:
            create tt-cab.
            assign tt-cab.etbcod = plani.emite
                   tt-cab.data   = plani.pladat
                   tt-cab.codest = "01" + string(plani.emite,"99").
        end.
        assign tt-cab.qtdlot = tt-cab.qtdlot + 1
               tt-cab.codlot = string(day(plani.pladat),"99")
               tt-cab.totval = tt-cab.totval + plani.platot.
               
    
    end.
    output stream stela close.
    
    for each tt-cab no-lock:
        if tt-cab.totval > 0
        then do:
            create tt-lanca.
            assign tt-lanca.tip  = "D"
                   tt-lanca.cre  = "01" + string(estab.etbcod,">>9")
                   tt-lanca.cod  = 0
                   tt-lanca.his = "*LIVRE@"
                   tt-lanca.val  = tt-cab.totval.
        end.

    end.

    vseq = 0.
    for each tt-lanca break by tt-lanca.data:
        vseq = vseq + 1.
        tt-lanca.seq = vseq.
         
        if last-of(tt-lanca.data)
        then vseq = 0.
        
    end.


    
    output to value("l:\sispro\sisecf" + string(estab.etbcod,">>9") +
               ".txt").

    v-seq = 0.

    for each tt-cab:
    
    /********************* HEADER ********************/
    cd_batch = "INTPGT" +
               string(day(today),"99") +  
               string(month(today),"99") +    
               string(year(today),"9999") +  
               tt-cab.codest.
               
    
    
    put unformatted 
    /* 01 */       "FISCAL         "
    /* 02 */       " " format "x(01)" 
    /* 03 */       tt-cab.codest format "x(20)"
    /* 04 */       " " format "x(01)" 
    /* 05 */       cd_batch   format "x(30)" 
    /* 06 */       " " format "x(01)" 
    /* 07 */       "INTPGT" format "x(15)" 
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
    /* 17 */       "000000000000000000"  
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

    

    
    for each tt-lanca where tt-lanca.etbcod = tt-cab.etbcod and
                            tt-lanca.data   = tt-cab.data:

/*************************** LANCAMENTOS *************************/
    
    
        v-seq = v-seq + 1.
        put unformatted
    /* 01 */       "FISCAL         "
                   " " format "x(01)"
                   tt-cab.codest format "x(20)"
                   " " format "x(01)" 
                   cd_batch   format "x(30)" 
                   " " format "x(01)"
                   "INTPGT" format "x(15)"  
                   " " format "x(01)" 
                   tt-cab.codlot   format "x(10)" 
     /* 10 */      " " format "x(01)"
                   "LANCTO    "  
                   " " format "x(01)"
                   string(day(tt-lanca.data),"99") format "99"  
                   string(month(tt-lanca.data),"99") format "99"  
                   string(year(tt-lanca.data),"9999") format "9999" 
                   " " format "x(01)" 
                   " " format "x(30)" 
                   " " format "x(01)" 
                   " " format "x(22)" 
                   " " format "x(01)" 
                   tt-lanca.cre format "x(30)"
     /* 20 */      " " format "x(01)" 
                   tt-lanca.cre format "x(22)" 
                   " " format "x(01)" 
                   " " format "x(20)" 
                   " " format "x(01)"
                   tt-cab.codest format "x(20)" 
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
                   "DIV" format "x(03)"  
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
         /* 03 */       tt-cab.codest format "x(20)" 
         /* 04 */       " " format "x(01)"  
         /* 05 */       cd_batch   format "x(30)"  
         /* 06 */       " " format "x(01)"  
         /* 07 */       "INTPGT" format "x(15)"  
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
