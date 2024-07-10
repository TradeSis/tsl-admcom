{admcab.i}
    
def shared var vdti as date.
def shared var vdtf as date.

def temp-table tt-venda
        field etbcod like estab.etbcod
        field data as date
        field aprazo as dec
        field acrescimo as dec
        field recebi as dec
        field juros  as dec
        index i1 etbcod data.
 
def shared temp-table tt-index
    field etbcod like estab.etbcod
    field data as date
    field indx as dec 
    field venda as dec 
    field titulo as dec
    field vl-prazo as dec  decimals 2
    field vl-titulo as dec decimals 2
    index i1 etbcod data.

def shared temp-table tt-titulo
      field data      as date
      field etbcod like estab.etbcod
      field tipo      as char format "X(15)"  Label "Tipo"
      field titvlcob  like titulo.titvlcob label "Valor"
      field titvlpag  like titulo.titvlpag
      field entrada   as dec
      index ix is primary unique
                  tipo
                  etbcod
                  data
                  .

def var vest as dec.
def var vrec1 as dec.
def var vrec2 as dec.

def var vemissao as dec.
def var vrecebimento as dec.
def var vjuro as dec.
def var vtitvlcob as dec.

def var v-devol as dec.
def var v-estorno as dec.
def var vacrescimo as dec.
def var vemiacre as dec.
def shared temp-table tt-estab
    field etbcod like estab.etbcod
    .           
    
def var vetb-pag like estab.etbcod.    
def var varqexp as char.
def stream tl .
def var vdata1 as date. 
def var vhist as char.
def var vetbcod like estab.etbcod.
    if opsys = "unix"
        then varqexp = 
            "/admcom/audit/tit_" + trim(string(vetbcod,"999")) + "_" +
                string(day(vdti),"99") +  
                string(month(vdti),"99") +  
                string(year(vdti),"9999") + "_" + 
                string(day(vdtf),"99") +  
                string(month(vdtf),"99") +  
                string(year(vdtf),"9999") + ".txt".
        else varqexp = 
            "l:\audit\tit_" + trim(string(vetbcod,"999")) + "_" + 
                string(day(vdti),"99") +   
                string(month(vdti),"99") +   
                string(year(vdti),"9999") + "_" +  
                string(day(vdtf),"99") +   
                string(month(vdtf),"99") +   
                string(year(vdtf),"9999") + ".txt".
 
    output to value(varqexp).
    output stream tl to terminal.
    for each tt-estab:       
        if tt-estab.etbcod >= 900 and
           tt-estab.etbcod <> 993
        then vetb-pag = 996.
        else vetb-pag = tt-estab.etbcod.
           
         do vdata1 = vdti to vdtf:
            disp stream tl "Processando ... " tt-estab.etbcod vdata1 
                with frame fxy1 no-label 1 down centered no-box
                color message .
             pause 0.

             create tt-venda.
             tt-venda.etbcod = tt-estab.etbcod.
             tt-venda.data = vdata1.


             for each contrato where contrato.etbcod = tt-estab.etbcod and
                                    contrato.dtinicial = vdata1
                                    no-lock:
                if contrato.vltotal <= 0
                then next.
                find first contnf where 
                            contnf.etbcod = contrato.etbcod and
                            contnf.contnum = contrato.contnum
                        no-lock no-error.
                if not avail contnf
                then next.
                find first plani where plani.etbcod = contnf.etbcod and
                                 plani.placod = contnf.placod and
                                 plani.serie  = "V"
                                 no-lock no-error.
                if avail plani and
                   substr(string(plani.notped),1,1) <> "C"
                then next.                 

                find first envfinan where 
                                       envfinan.empcod = 19
                                    and envfinan.titnat = no
                                    and envfinan.modcod = "CRE"
                                    and envfinan.etbcod = contrato.etbcod
                                    and envfinan.clifor = contrato.clicod
                                  and envfinan.titnum = string(contrato.contnum)
                                    no-lock no-error.
                if  avail envfinan
                then next.

                disp stream tl contrato.contnum format ">>>>>>>>>9"
                            with frame fxy1 .
                pause 0.
                
                
                find cpcontrato where 
                     cpcontrato.contnum = contrato.contnum
                     no-lock no-error.
                if not avail cpcontrato or
                    cpcontrato.indecf = no 
                then next.
                if cpcontrato.financeira <> 0
                then next.

                if cpcontrato.indacr = yes
                then assign
                         vtitvlcob = cpcontrato.dec3
                         vacrescimo = contrato.vltotal - cpcontrato.dec3.
                else if cpcontrato.carteira = 77
                then assign
                        vtitvlcob = cpcontrato.dec3
                        vacrescimo = 0.
                else assign
                        vtitvlcob = contrato.vltotal
                        vacrescimo = 0.
                
                if vtitvlcob <= 0
                then next.
                
                /******* EMISSOES ********/
                put unformat skip
     contrato.etbcod format ">>9"           /* 01-03 */
     "C" + string(contrato.clicod,"9999999999") format "x(18)" /* 04-21 */
     "TIT "  format "x(5)"                /* 22-26 */
     " " format "X(5)"                    /* 27-31 */ 
     contrato.contnum format "999999999999"  /* 32-43 */
     year(contrato.dtinicial) format "9999"          /* 44-51 */
     month(contrato.dtinicial) format "99"          
     day(contrato.dtinicial)   format "99"
     "C  "     format "x(3)"             /* 52-54 */
     vtitvlcob /*contrato.vltotal*/    format "9999999999999.99" /* 55-70 */
     "+"                 format "x(1)"             /* 71 */
     year(contrato.dtinicial)  format "9999" /* 72-79 */
     month(contrato.dtinicial) format "99"  
     day(contrato.dtinicial)   format "99"
     vtitvlcob /*contrato.vltotal*/ format "9999999999999.99"  /* 80-95 */
     year(contrato.dtinicial) format "9999"  /* 96-103 */
     month(contrato.dtinicial) format "99"  
     day(contrato.dtinicial) format "99"
     string(contrato.contnum)     format "x(12)" /* 104-115 nro arquivamento */   
     "1.1.02.01.001" format "x(28)"                  /* 116-143 cod.contabil */
     "EMISSAO" format "x(250)"               /* 144-393  Histórico */ .

            vemissao = vemissao + vtitvlcob.
            tt-venda.aprazo = tt-venda.aprazo + vtitvlcob.
     put skip.
                
        /******* ACRESCIMO ********/
                put unformat skip
     contrato.etbcod format ">>9"           /* 01-03 */
     "C" + string(contrato.clicod,"9999999999") format "x(18)" /* 04-21 */
     "ACR "  format "x(5)"                /* 22-26 */
     " " format "X(5)"                    /* 27-31 */ 
     contrato.contnum format "999999999999"  /* 32-43 */
     year(contrato.dtinicial) format "9999"          /* 44-51 */
     month(contrato.dtinicial) format "99"          
     day(contrato.dtinicial)   format "99"
     "A  "     format "x(3)"             /* 52-54 */
     vacrescimo    format "9999999999999.99" /* 55-70 */
     "+"                 format "x(1)"             /* 71 */
     year(contrato.dtinicial)  format "9999" /* 72-79 */
     month(contrato.dtinicial) format "99"  
     day(contrato.dtinicial)   format "99"
     vacrescimo format "9999999999999.99"  /* 80-95 */
     year(contrato.dtinicial) format "9999"  /* 96-103 */
     month(contrato.dtinicial) format "99"  
     day(contrato.dtinicial) format "99"
     string(contrato.contnum)  format "x(12)" /* 104-115 nro arquivamento */
     "1.1.02.01.001" format "x(28)"                  /* 116-143 cod.contabil */
     "ACRESCIMO" format "x(250)"               /* 144-393  Histórico */ .
  
     put skip.
                 
                
                vemiacre = vemiacre + vacrescimo.  
                tt-venda.acrescimo = tt-venda.acrescimo + vacrescimo.
            end. 
            disp stream tl "Processando RECEB... " tt-estab.etbcod vdata1 
                with frame fxy1 no-label 1 down centered no-box
                color message .
             pause 0.
            
             
            for each tituarqm where
                     tituarqm.datexp = vdata1 and
                     tituarqm.etbcobra = tt-estab.etbcod no-lock.
                

                /******* RECEBIMENTOS ********/
                if tituarqm.titsit <> "PAGCTB"
                then next.
                find first titulo where
                           titulo.empcod = tituarqm.empcod and
                           titulo.titnat = tituarqm.titnat and
                           titulo.modcod = tituarqm.modcod and
                           titulo.etbcod = tituarqm.etbcod and
                           titulo.clifor = tituarqm.clifor and
                           titulo.titnum = tituarqm.titnum
                           no-lock no-error.
                if not avail titulo then next.
                find first envfinan where 
                                       envfinan.empcod = 19
                                    and envfinan.titnat = no
                                    and envfinan.modcod = "CRE"
                                    and envfinan.etbcod = titulo.etbcod
                                    and envfinan.clifor = titulo.clifor
                                    and envfinan.titnum = titulo.titnum
                                    no-lock no-error.
                if  avail envfinan
                then next.
                
                find cpcontrato where 
                     cpcontrato.contnum = int(titulo.titnum)
                    no-lock no-error.
                if titulo.titdtemi >= 01/01/2009 and
                   not avail cpcontrato
                then next.

                if avail cpcontrato and
                   cpcontrato.indecf = no and
                   cpcontrato.indpag = no   
                then next.
                 
                /*
                if avail cpcontrato and
                    cpcontrato.financeira <> 0 /*and
                    cpcontrato.carteira <> 88    */
                then next.
                */

                put unformat skip
     vetb-pag /*tituarqm.etbcod*/ format ">>9"           /* 01-03 */
     "C" + string(tituarqm.clifor,"9999999999") format "x(18)" /* 04-21 */
     "TIT "  format "x(5)"                /* 22-26 */
     " " format "X(5)"                    /* 27-31 */ 
     tituarqm.titnum format "999999999999"  /* 32-43 */
     year(tituarqm.datexp) format "9999"          /* 44-51 */
     month(tituarqm.datexp) format "99"          
     day(tituarqm.datexp)   format "99"
     "R  "     format "x(3)"             /* 52-54 */
     tituarqm.titvlcob        format "9999999999999.99" /* 55-70 */
     "-"                 format "x(1)"             /* 71 */
     year(tituarqm.titdtemi)  format "9999" /* 72-79 */
     month(tituarqm.titdtemi) format "99"  
     day(tituarqm.titdtemi)   format "99"
     tituarqm.titvlpag format "9999999999999.99"  /* 80-95 */
     year(tituarqm.titdtven) format "9999"  /* 96-103 */
     month(tituarqm.titdtven) format "99"  
     day(tituarqm.titdtven) format "99"
     tituarqm.titnum     format "x(12)" /* 104-115 nro arquivamento */   
     "1.1.02.01.001" format "x(28)"                  /* 116-143 cod.contabil */
     "RECEBIMENTO" format "x(250)"               /* 144-393  Histórico */ .
  
     put skip.
                vrecebimento = vrecebimento + tituarqm.titvlcob.
                tt-venda.recebi = tt-venda.recebi + tituarqm.titvlcob.
                vrec1 = vrec1 + tituarqm.titvlcob.
            end.         
             
             
            for each titulo use-index etbcod where
                 titulo.etbcobra = tt-estab.etbcod and
                 titulo.titdtpag = vdata1 no-lock:
                 if titulo.titvlcob <= 0
                 THEN NEXT.
                if titulo.clifor = 1 then next.
                if titulo.titnat = yes then next.
                if titulo.titpar = 0 then next. 
                if titulo.modcod <> "CRE" then next.
                
                find first tituarqm of titulo no-lock no-error.
                if avail tituarqm 
                then do:
                    /*if tituarqm.etbcobra = tt-estab.etbcod and
                    tituarqm.titdtpag = vdata1 
                    then next.
                    */
                    next.    
                end.
                
                /*
                find first tituarqm where
                           tituarqm.empcod = titulo.empcod and
                           tituarqm.titnat = titulo.titnat and
                           tituarqm.modcod = titulo.modcod and
                           tituarqm.etbcod = titulo.etbcod and
                           tituarqm.clifor = titulo.clifor and
                           tituarqm.titnum = titulo.titnum
                           no-lock no-error.
                if avail tituarqm
                then next.
                */
                find first envfinan where 
                                       envfinan.empcod = 19
                                    and envfinan.titnat = no
                                    and envfinan.modcod = "CRE"
                                    and envfinan.etbcod = titulo.etbcod
                                    and envfinan.clifor = titulo.clifor
                                    and envfinan.titnum = titulo.titnum
                                    no-lock no-error.
                if  avail envfinan
                then next.
                
                find cpcontrato where 
                     cpcontrato.contnum = int(titulo.titnum)
                    no-lock no-error.
                if titulo.titdtemi >= 01/01/2009 and
                   not avail cpcontrato
                then next.

                if avail cpcontrato and
                   cpcontrato.indecf = no and
                   cpcontrato.indpag = no 
                then next. 

                
                if avail cpcontrato and
                    cpcontrato.financeira = 9 /*<> 0*/ /*and
                    cpcontrato.carteira <> 88    */
                then next.
                
                /******* RECEBIMENTOS ********/
    
                put unformat skip
     vetb-pag /*titulo.etbcod*/ format ">>9"           /* 01-03 */
     "C" + string(titulo.clifor,"9999999999") format "x(18)" /* 04-21 */
     "TIT "  format "x(5)"                /* 22-26 */
     " " format "X(5)"                    /* 27-31 */ 
     titulo.titnum format "999999999999"  /* 32-43 */
     year(titulo.titdtpag) format "9999"          /* 44-51 */
     month(titulo.titdtpag) format "99"          
     day(titulo.titdtpag)   format "99"
     "R  "     format "x(3)"             /* 52-54 */
     titulo.titvlcob        format "9999999999999.99" /* 55-70 */
     "-"                 format "x(1)"             /* 71 */
     year(titulo.titdtemi)  format "9999" /* 72-79 */
     month(titulo.titdtemi) format "99"  
     day(titulo.titdtemi)   format "99"
     titulo.titvlpag format "9999999999999.99"  /* 80-95 */
     year(titulo.titdtven) format "9999"  /* 96-103 */
     month(titulo.titdtven) format "99"  
     day(titulo.titdtven) format "99"
     titulo.titnum     format "x(12)" /* 104-115 nro arquivamento */   
     "1.1.02.01.001" format "x(28)"                  /* 116-143 cod.contabil */
     "RECEBIMENTO" format "x(250)"               /* 144-393  Histórico */ .
  
     put skip.
                vrecebimento = vrecebimento + titulo.titvlcob.
                tt-venda.recebi = tt-venda.recebi + titulo.titvlcob.
                vrec2 = vrec2 + titulo.titvlcob.

  /**************************/
                   
                if titulo.titjuro > 0
                then do:

                    /******* JUROS ********
    
                put unformat skip
     titulo.etbcod format ">>9"           /* 01-03 */
     "C" + string(titulo.clifor,"9999999999") format "x(18)" /* 04-21 */
     "TIT "  format "x(5)"                /* 22-26 */
     " " format "X(5)"                    /* 27-31 */ 
     titulo.titnum format "999999999999"  /* 32-43 */
     year(titulo.titdtpag) format "9999"          /* 44-51 */
     month(titulo.titdtpag) format "99"          
     day(titulo.titdtpag)   format "99"
     "J  "     format "x(3)"             /* 52-54 */
     titulo.titjuro        format "9999999999999.99" /* 55-70 */
     "+"                 format "x(1)"             /* 71 */
     year(titulo.titdtemi)  format "9999" /* 72-79 */
     month(titulo.titdtemi) format "99"  
     day(titulo.titdtemi)   format "99"
     titulo.titjuro format "9999999999999.99"  /* 80-95 */
     year(titulo.titdtven) format "9999"  /* 96-103 */
     month(titulo.titdtven) format "99"  
     day(titulo.titdtven) format "99"
     titulo.titnum     format "x(12)" /* 104-115 nro arquivamento */   
     "5.3.02.01.001" format "x(28)"                  /* 116-143 cod.contabil */
     "JUROS" format "x(250)"               /* 144-393  Histórico */ .
              put skip.
              **/
              
              vjuro = vjuro + titulo.titjuro.
              tt-venda.juro = tt-venda.juro + titulo.titjuro.
                /**************************/
                 
                end.
            end.
            
            /***** devolucao ***********/
            for each contarqm where 
                     contarqm.etbcod = tt-estab.etbcod and
                     contarqm.datexp = vdata1 and
                     contarqm.situacao = 4
                     no-lock:
                vest = 0.
                vest = contarqm.vltotal - contarqm.vlfrete.
                /*if vest < 0
                then next.*/
                 v-estorno = v-estorno + (contarqm.vltotal - contarqm.vlfrete).
                v-devol = v-devol + contarqm.vltotal.
                if vest > 0
                then
                put unformat skip
     contarqm.etbcod format ">>9"           /* 01-03 */
     "C" + string(contarqm.clicod,"9999999999") format "x(18)" /* 04-21 */
     "EST "  format "x(5)"                /* 22-26 */
     " " format "X(5)"                    /* 27-31 */ 
     contarqm.contnum format "999999999999"  /* 32-43 */
     year(contarqm.datexp) format "9999"          /* 44-51 */
     month(contarqm.datexp) format "99"          
     day(contarqm.datexp)   format "99"
     "E  "     format "x(3)"             /* 52-54 */
     vest            format "9999999999999.99" /* 55-70 */
     "+"                 format "x(1)"             /* 71 */
     year(contarqm.dtinicial)  format "9999" /* 72-79 */
     month(contarqm.dtinicial) format "99"  
     day(contarqm.dtinicial)   format "99"
     vest               format "9999999999999.99"  /* 80-95 */
     year(contarqm.dtinicial) format "9999"  /* 96-103 */
     month(contarqm.dtinicial) format "99"  
     day(contarqm.dtinicial) format "99"
     string(contarqm.contnum) format "x(12)" /* 104-115 nro arquivamento */   
     "1.1.02.01.001" format "x(28)"                  /* 116-143 cod.contabil */
     "ESTORNO" format "x(250)"               /* 144-393  Histórico */ .
              put skip.

           /***devolucao ****/
            put unformat skip
     contarqm.etbcod format ">>9"           /* 01-03 */
     "C" + string(contarqm.clicod,"9999999999") format "x(18)" /* 04-21 */
     "DEV "  format "x(5)"                /* 22-26 */
     " " format "X(5)"                    /* 27-31 */ 
     contarqm.contnum format "999999999999"  /* 32-43 */
     year(contarqm.datexp) format "9999"          /* 44-51 */
     month(contarqm.datexp) format "99"          
     day(contarqm.datexp)   format "99"
     "D  "     format "x(3)"             /* 52-54 */
     contarqm.vltotal format "9999999999999.99" /* 55-70 */
     "-"                 format "x(1)"             /* 71 */
     year(contarqm.dtinicial)  format "9999" /* 72-79 */
     month(contarqm.dtinicial) format "99"  
     day(contarqm.dtinicial)   format "99"
     contarqm.vltotal  format "9999999999999.99"  /* 80-95 */
     year(contarqm.dtinicial) format "9999"  /* 96-103 */
     month(contarqm.dtinicial) format "99"  
     day(contarqm.dtinicial) format "99"
     string(contarqm.contnum) format "x(12)" /* 104-115 nro arquivamento */   
     "1.1.02.01.001" format "x(28)"                  /* 116-143 cod.contabil */
     "DEVOLUCAO" format "x(250)"               /* 144-393  Histórico */ .
              put skip.

            end.         
        end.
    end.
    output close.
    output stream tl close.
disp vemissao     format ">>>,>>>,>>9.99" label "EMISSAO    "
     vemiacre     format ">>>,>>>,>>9.99" label "ACRESCIMO  "
     vrecebimento format ">>>,>>>,>>9.99" LABEL "RECEBIMENTO"
     vrec1        format ">>>,>>>,>>9.99" label "REC 1      "
     vrec2        format ">>>,>>>,>>9.99" label "REC 2      "
     vjuro        format ">>>,>>>,>>9.99" LABEL "JURO       "
     v-estorno    format ">>>,>>>,>>9.99" LABEL "ESTORNO    "
     v-devol      format ">>>,>>>,>>9.99" LABEL "DEVOLUCAO  "
     with frame f-fim 1 column.                              

/***     
sresp = no.
message  "Atualizar ?" update sresp.
if sresp then
for each tt-venda no-lock:
    find ctcartcl where ctcartcl.etbcod = tt-venda.etbcod and
                        ctcartcl.datref = tt-venda.data
                        no-error.
    if not avail ctcartcl
    then do:
        create ctcartcl.
        ctcartcl.etbcod = tt-venda.etbcod.
        ctcartcl.datref = tt-venda.data.
    end.
    assign
        ctcartcl.recebimento = tt-venda.recebi
        ctcartcl.juro        = tt-venda.juro
        ctcartcl.ecfprazo    = tt-venda.aprazo
        ctcartcl.acrescimo   = tt-venda.acrescimo
        .                 
end.
***/
