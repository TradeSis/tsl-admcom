{admcab.i}
    
def shared var vdti as date.
def shared var vdtf as date.

def shared temp-table tt-venda
        field etbcod like estab.etbcod
        field data as date
        field vl-prazo as dec 
        field vl-vista as dec
        field avista as dec
        field aprazo as dec
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

def var vemissao as dec.
def var vrecebimento as dec.
def var vjuro as dec.
def var vtitvlcob as dec.

def shared temp-table tt-estab
    field etbcod like estab.etbcod
    .
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
        /*
        assign
            vemissao = 0 
            vrecebimento = 0 
            vjuro = 0.
        */
         do vdata1 = vdti to vdtf:
            disp stream tl "Processando ... " tt-estab.etbcod vdata1 
                with frame fxy1 no-label 1 down centered no-box
                color message .
             pause 0.
             for each contrato where contrato.etbcod = tt-estab.etbcod and
                                    contrato.dtinicial = vdata1
                                    no-lock:
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
                   plani.notped <> "C"
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

                disp stream tl contrato.contnum with frame fxy .
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
                then vtitvlcob = vtitvlcob + contrato.vltotal.
                else vtitvlcob = vtitvlcob + cpcontrato.dec3.
                
                /******* EMISSOES ********/
                /*
                for each titulo where
                         titulo.clifor = contrato.clicod and
                         titulo.titnum = string(contrato.contnum)
                         no-lock:
                */
                put unformat skip
     contrato.etbcod format ">>9"           /* 01-03 */
     string(contrato.clicod) format "x(18)" /* 04-21 */
     "TIT "  format "x(5)"                /* 22-26 */
     " " format "X(5)"                    /* 27-31 */ 
     contrato.contnum format "999999999999"  /* 32-43 */
     year(contrato.dtinicial) format "9999"          /* 44-51 */
     month(contrato.dtinicial) format "99"          
     day(contrato.dtinicial)   format "99"
     "C  "     format "x(3)"             /* 52-54 */
     contrato.vltotal        format "9999999999999.99" /* 55-70 */
     "+"                 format "x(1)"             /* 71 */
     year(contrato.dtinicial)  format "9999" /* 72-79 */
     month(contrato.dtinicial) format "99"  
     day(contrato.dtinicial)   format "99"
     contrato.vltotal format "9999999999999.99"  /* 80-95 */
     year(contrato.dtinicial) format "9999"  /* 96-103 */
     month(contrato.dtinicial) format "99"  
     day(contrato.dtinicial) format "99"
     string(contrato.contnum)     format "x(12)" /* 104-115 nro arquivamento */   
     " " format "x(28)"                  /* 116-143 cod.contabil */
     "EMISSAO" format "x(250)"               /* 144-393  Histórico */ .
  
     put skip.
                vemissao = vemissao + contrato.vltotal.   
                /*end.*/
            end. 
            disp stream tl "Processando RECEB... " tt-estab.etbcod vdata1 
                with frame fxy1 no-label 1 down centered no-box
                color message .
             pause 0.
     

            for each titulo use-index etbcod where
                 titulo.etbcobra = tt-estab.etbcod and
                 titulo.titdtpag = vdata1 no-lock:

                if titulo.clifor = 1 then next.
                if titulo.titnat = yes then next.
                if titulo.titpar = 0 then next. 
                if titulo.modcod <> "CRE" then next.

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
                   (cpcontrato.indecf = no /*or
                    cpcontrato.indacr*/)
                then next.     
                if avail cpcontrato and
                    cpcontrato.financeira <> 0
                then next.
                    
                /******* RECEBIMENTOS ********/
    
                put unformat skip
     titulo.etbcod format ">>9"           /* 01-03 */
     string(titulo.clifor) format "x(18)" /* 04-21 */
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
     " " format "x(28)"                  /* 116-143 cod.contabil */
     "RECEBIMENTO" format "x(250)"               /* 144-393  Histórico */ .
  
     put skip.
                vrecebimento = vrecebimento + titulo.titvlcob.
                /**************************/
                   
                if titulo.titjuro > 0
                then do:

                    /******* JUROS ********/
    
                put unformat skip
     titulo.etbcod format ">>9"           /* 01-03 */
     string(titulo.clifor) format "x(18)" /* 04-21 */
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
     " " format "x(28)"                  /* 116-143 cod.contabil */
     "JUROS" format "x(250)"               /* 144-393  Histórico */ .
              put skip.
              vjuro = vjuro + titulo.titjuro.
                /**************************/
                 
                end.
            end.
        end.
    end.
    output close.
    output stream tl close.


disp vemissao     format ">>>,>>>,>>9.99" label "EMISSAO    "
     vrecebimento format ">>>,>>>,>>9.99" LABEL "RECEBIMENTO"
     vjuro        format ">>>,>>>,>>9.99" LABEL "JURO       "
     with frame f-fim 1 column.
     
