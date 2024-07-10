/* sisp_ban.p >>> porgrama de importacao extban.p */

{admcab.i}
def var vetbi  like estab.etbcod.
def var vetbf  like estab.etbcod.
def var vtitvlpag like extban.valdep.

def var vnomarq as char.
def var vlote as char.
def var vbancod as int.         
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
    field codlot as char
    index xx is primary unique data.
    
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
def var tvlpag like vtitvlpag.

 def var vrede as char.
 def var vb as char extent 3 format "x(18)"
        init[" BANCO DO BRASIL  "," CAIXA FEDERAL "," BANRISUL "]. 

repeat with 1 down side-label width 80 row 3 color blue/white:

    for each tt-lanca:
        delete tt-lanca.
    end.
    
    for each tt-cab:
        delete tt-cab.
    end.    

    disp vb with frame f-b 1 down centered no-label.
    choose field vb with frame f-b.
    vrede = vb[frame-index].      
     
    update vdt1 label "Data Inicial" at 1 
           vdt2 label "Data Final" with frame f-x 1 col centered width 60. 
   
    update vlote label "Lote" with frame f-x.
    
    tvlpag = 0.

    vrede = trim(vrede).

    vdata = today.

    if vrede = "BANCO DO BRASIL"
    then assign
             vbancod = 1001
             vconta = "2" /* "108" */ .
    else if vrede = "CAIXA FEDERAL"
        then assign
                vbancod = 1002
                vconta = "4" /* "110" */ .
        else if vrede = "BANRISUL"
            then assign
                    vbancod = 1003
                    vconta = "3" /* "109" */.
            else assign
                    vconta = ""
                    vbancod = 0.

    output stream stela to terminal.
   
    def var vy as int no-undo.

            assign vtitvlpag  = 0.
            
    for each extban where extban.etbcod = vbancod
                           and extban.datmov >= vdt1
                           and extban.datmov <= vdt2
                              no-lock:

                 if extban.valdep <= 0 then next.
                  
                 vtitvlpag = vtitvlpag + extban.valdep.

                 tvlpag = tvlpag + extban.valdep.

                 find first tt-lanca 
                           where tt-lanca.etbcod = extban.etbcod and
                                 tt-lanca.etbcre = "01001" and
                                 tt-lanca.data = extban.datmov and
                                 tt-lanca.deb   = vconta no-error.
                   
                 if not avail tt-lanca
                 then do:
                    create tt-lanca.
                    assign tt-lanca.etbcod  = extban.etbcod  /* 01001 */ 
                           tt-lanca.etbdeb  = "01001"
                           tt-lanca.etbcre  = "01001" 
                           tt-lanca.data    = extban.datmov  /* vdata */
                          tt-lanca.deb = vconta.

                    find first tt-cab where tt-cab.data = extban.datmov
                                no-error.
                    if not avail tt-cab
                    then do:
                        create tt-cab.
                        assign tt-cab.data   =   extban.datmov /* vdata */ 
                        tt-cab.codlot = vlote +  
                                 string(day(extban.datmov),"99").

                    end.
                
                    assign tt-cab.qtdlot = tt-cab.qtdlot + 1.
                          
                 end.          
                 assign    tt-lanca.subcre  = ""
                           tt-lanca.subdeb  = ""
                           tt-lanca.cre     = "1"
                           tt-lanca.cod     = 0   
                           tt-lanca.his = 
                            "*LIVRE@N/DEP.N/DATA CF.REC.".

                            

                assign tt-lanca.val  = tt-lanca.val + extban.valdep.
                
                find first tt-cab where tt-cab.data = extban.datmov
                                 no-error.
                assign tt-cab.totval = tt-cab.totval + extban.valdep.
     end.

    output stream stela close.

    disp /* tvlcob label "Venda"        format ">>,>>>,>>9.99" */
         tvlpag label "Total" format ">>,>>>,>>9.99"
        /*  tvldes label "Desconto"     format ">>,>>>,>>9.99" */
         with frame f 1 down centered row 10
         1 column side-label.
    
    vseq = 0.
    for each tt-lanca 
        break by tt-lanca.data:

        vseq = vseq + 1.
        tt-lanca.seq = vseq.
         
        if last-of(tt-lanca.data)
        then vseq = 0.
        
    end.
    vnomarq = "extrato_" + lc(replace(vrede," ","")).
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
    cd_batch = trim(vrede) +
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
    /* 07 */       "EXTRATO" format "x(15)" 
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

    

    
    for each tt-lanca where tt-lanca.data = tt-cab.data  
                     by tt-lanca.data:
/*************************** LANCAMENTOS *************************/
    
    
        v-seq = v-seq + 1.
        put unformatted
    /* 01 */       "FISCAL         " at 01
                   " " format "x(01)"
                   "01001" format "x(20)"
                   " " format "x(01)" 
                   cd_batch   format "x(30)" 
                   " " format "x(01)"
                   "EXTRATO" format "x(15)"  
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
         /* 07 */       "EXTRATO" format "x(15)"  
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
