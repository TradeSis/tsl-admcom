{admcab.i}
def input parameter rp as char.
def var vetbi  like estab.etbcod.
def var vetbf  like estab.etbcod.
def var vtitvlcob like reccar.titvlcob.
def var vtitvlpag like reccar.titvlpag.
def var vtitvldes like reccar.titvldes.

def var vnomarq as char.
def var vlote as char.
         
def new shared var ind-alfa as char  init "a=1|b=2|c=3|d=4|e=5|f=6|g=7|h=8|i=9|j=10|k=11|l=12|m=13|n=14|o=15|p=16|q=17|r=1
8|s=19|t=20|u=21|v=22|x=23|y=24|z=25".
 
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
        
def var vconta as char.
def var tvlcob like vtitvlcob.
def var tvlpag like vtitvlpag.
def var tvldes like vtitvldes.

repeat with 1 down side-label width 80 row 3 color blue/white:

    for each tt-lanca:
        delete tt-lanca.
    end.
    
    for each tt-cab:
        delete tt-cab.
    end.    
     
    update vdt1 label "Data Inicial" at 1 
           vdt2 label "Data Final". 
   
    update vlote.
    
    for each tt-lanca:
        delete tt-lanca.
    end.

    tvlcob = 0.
    tvlpag = 0.
    tvldes = 0.
    def var vrede as char.
    def var vb as char extent 3 format "x(10)"
        init["  VISA  "," MASTER "," BANRI "] 
    .
    disp vb with frame f-b 1 down centered no-label.
    choose field vb with frame f-b.
    vrede = vb[frame-index].      def var vmoeda as char.
    def var vcartao as char.
    vcartao = trim(vrede).
    vrede = "".
    if vcartao = "VISA"
    then assign
             vmoeda = "RCV"
             vconta = "108".
    else if vcartao = "MASTER"
        then assign
                vmoeda = "RCM"
                vconta = "110".
        else if vcartao = "BANRI"
            then assign
                    vmoeda = "RCB"
                    vconta = "109".
            else assign
                    vmoeda = ""
                    vconta = "".
    def var va as int.    
    do va = 1 to length(vmoeda):
        vrede = vrede + acha(substr(vmoeda,va,1),ind-alfa).
    end. 
    
    output stream stela to terminal.
    do:  /*for each estab  no-lock:*/
        do vdata = vdt1 to vdt2:
            display stream stela estab.etbcod vdata 
                with frame ff side-label 1 down. pause 0.

            assign vtitvlcob  = 0 
                   vtitvldes  = 0 
                   vtitvlpag  = 0.
            for each reccar where reccar.etbcod = 0 and
                                  reccar.titdtven = vdata
                                  no-lock:
                if reccar.rede <> int(vrede)
                then next.
                if reccar.numres <> rp
                then next.
                if reccar.titvlcob < 0
                then next.
                vtitvlcob = vtitvlcob + reccar.titvlcob.
                vtitvlpag = vtitvlpag + reccar.titvlpag.
                vtitvldes = vtitvldes + reccar.titvldes. 
            end.
            tvlcob = tvlcob + vtitvlcob.
            tvlpag = tvlpag + vtitvlpag.
            tvldes = tvldes + vtitvldes.
            if vtitvlcob > 0 or
               vtitvlpag > 0 or
               vtitvldes > 0            
            then do:  
                find first tt-cab where tt-cab.data = vdata no-error.
                if not avail tt-cab
                then do:
                    create tt-cab.
                    assign tt-cab.data   = vdata
                           tt-cab.codlot = vlote + string(day(vdata),"99").

                end.
            end.                               
            if vtitvlcob > 0 
            then do:

                find first tt-lanca 
                           where tt-lanca.etbcre = "01001" and
                                 tt-lanca.data   = vdata and
                                 tt-lanca.deb    = vconta no-error.
                   
                if not avail tt-lanca
                then do:
                    create tt-lanca.
                    assign tt-lanca.etbcod  = 01001
                           tt-lanca.etbdeb  = "01001"
                           tt-lanca.etbcre  = "01001" 
                           tt-lanca.data    = vdata
                           tt-lanca.deb     = vconta  
                           tt-lanca.subcre  = ""
                           tt-lanca.subdeb  = ""
                           tt-lanca.cre     = "15"
                           tt-lanca.cod     = 0   
                           tt-lanca.his = 
                            "*LIVRE@RECEBIMENTO DE DIVS. CLIENTES N/DATA "
                           tt-cab.qtdlot = tt-cab.qtdlot + 1.
                end.
                assign tt-lanca.val  = tt-lanca.val + vtitvlcob
                       tt-cab.totval = tt-cab.totval + vtitvlcob.
            end.

            if vtitvldes > 0
            then do:
                find first tt-lanca 
                     where tt-lanca.etbcre = "01001" and 
                           tt-lanca.data   = vdata and
                           tt-lanca.deb    = "227" no-error.
                   
                if not avail tt-lanca 
                then do: 
                    create tt-lanca.
                    assign tt-lanca.etbcod  = 01001
                           tt-lanca.etbdeb  = "01001"
                           tt-lanca.etbcre  = "01001"
                           tt-lanca.data    = vdata
                           tt-lanca.deb     = "227" 
                           tt-lanca.subcre  = ""
                           tt-lanca.subdeb  = ""
                           tt-lanca.cre     = vconta
                           tt-lanca.cod     = 0   
                           tt-lanca.his     = 
                                    "*LIVRE@VLR REF DESPESAS BANCARIAS "
                           tt-cab.qtdlot = tt-cab.qtdlot + 1.
                end.
                assign tt-lanca.val  = tt-lanca.val + vtitvldes
                       tt-cab.totval = tt-cab.totval + vtitvldes.
            end.
        end.
    end.
    output stream stela close.

    disp tvlcob label "Venda"        format ">>,>>>,>>9.99"
         tvlpag label "Recebimento"  format ">>,>>>,>>9.99"
         tvldes label "Desconto"     format ">>,>>>,>>9.99"
         with frame f 1 down centered row 10
         1 column side-label.

    sresp = no.
    message "Exportar ? " update sresp.
    if not sresp then return.
    
    vseq = 0.
    for each tt-lanca break by tt-lanca.data:

        vseq = vseq + 1.
        tt-lanca.seq = vseq.
         
        if last-of(tt-lanca.data)
        then vseq = 0.
        
    end.
    vnomarq = "vendas_cartao_" + vcartao.
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
    cd_batch = "VENDAS CARTAO" +
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
    /* 07 */       "VENDAS CARTAO" format "x(15)" 
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
                   "VENDAS CARTAO" format "x(15)"  
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
         /* 07 */       "VENDAS CARTAO" format "x(15)"  
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
