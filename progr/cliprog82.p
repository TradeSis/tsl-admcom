{admcab.i}
    

def var vetb-cod like estab.etbcod.
def var vcli-for like clien.clicod.
def var vtotal as dec.

def shared var vdti as date.
def shared var vdtf as date.

def var vtipo as char.

update vdti vdtf.
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

def var v-finestemi as dec.
def var v-finestacr as dec.
def var v-reneg as dec.
def var v-devol as dec.
def var v-estorno as dec.
def var v-recnovacao as dec.
def var vacrescimo as dec.
def var vemiacre as dec.
def var v-emicanfin as dec.
def var v-recestfin as dec.

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
            "/admcom/audit/DiarioClientes2013/tit_" + trim(string(vetbcod,"999")) + "_" +
                string(day(vdti),"99") +  
                string(month(vdti),"99") +  
                string(year(vdti),"9999") + "_" + 
                string(day(vdtf),"99") +  
                string(month(vdtf),"99") +  
                string(year(vdtf),"9999") + ".txt".
        else varqexp = 
            "l:\audit\DiarioClientes2013\tit_" + trim(string(vetbcod,"999")) + "_" + 
                string(day(vdti),"99") +   
                string(month(vdti),"99") +   
                string(year(vdti),"9999") + "_" +  
                string(day(vdtf),"99") +   
                string(month(vdtf),"99") +   
                string(year(vdtf),"9999") + ".txt".
 
    update varqexp at 1 format "x(75)".
    output to value(varqexp).
    
    output stream tl to terminal.
    do:       
        do vdata1 = vdti to vdtf:
            disp stream tl "Processando ... "  vdata1 
                with frame fxy1 no-label 1 down centered no-box
                color message .
            pause 0.
            
            if day(vdata1) = 1
            then    
            for each arqclien where 
                      arqclien.mes = month(vdata1) and
                      arqclien.ano = year(vdata1)  
                      no-lock:
                
                if arqclien.campo20 = "FINANCEIRA"
                then next.
                if arqclien.tipo begins "JUROS"
                then next.

                if year(vdata1) = 2012 and
                   month(vdata1) >= 2  and
                   month(vdata1) <= 6  and
                   arqclien.tipo begins "RENEGOCIACAO"
                then next.
                   
                
                run p-put.
                
                
                if arqclien.tipo begins "EMISSAO"
                then do:
                    vemissao = vemissao + dec(arqclien.campo8).
                end.
                else if arqclien.tipo begins "ACRESCIMO"
                then do: 
                    vemiacre = vemiacre + dec(arqclien.campo8).  
                        dec(arqclien.campo8).
                end.
                else if arqclien.tipo begins "RECEBIMENTO"
                then do: 
                    vrecebimento = vrecebimento + dec(arqclien.campo8).
                end.
                else if arqclien.tipo begins "JUROS" 
                then do:
                    vjuro = vjuro + dec(arqclien.campo8).
                end.
                else if arqclien.tipo begins "ESTORNO"
                then do:  
                    v-estorno = v-estorno + dec(arqclien.campo8).           
                end.
                else if arqclien.tipo begins "DEVOLUCAO"
                then do: 
                    vtipo = "DEVOLUCAO".
                    v-devol = v-devol + dec(arqclien.campo8).
                end.
                else if arqclien.tipo begins "RENEGOCIACAO"
                then do:
                    v-reneg = v-reneg + dec(arqclien.campo8).
                end.
                else if arqclien.tipo begins "FINESTACR"
                then do:
                    v-finestacr = v-finestacr + dec(arqclien.campo8).
                end.
                else if arqclien.tipo begins "FINESTEMI"
                then do:
                    v-finestemi = v-finestemi + dec(arqclien.campo8).
                end.
                else if arqclien.tipo begins "RECNOVACAO"
                then do:
                    v-recnovacao = v-recnovacao + dec(arqclien.campo8).
                end.
                else do:
                    message arqclien.tipo.
                    pause.
                end.  
                

            end.
            if vtipo = ""
            then run estorno-devolucao.
            
            run cancelamento-financeira.
            run estorno-financeira.
            
        end.
    end.
    output close.
    
    output stream tl close.
disp vemissao     format ">>>,>>>,>>9.99" label "EMISSAO     "
     vemiacre     format ">>>,>>>,>>9.99" label "ACRESCIMO   "
     vrecebimento format ">>>,>>>,>>9.99" LABEL "RECEBIMENTO "
     vjuro        format ">>>,>>>,>>9.99" LABEL "JURO        "
     v-estorno    format ">>>,>>>,>>9.99" LABEL "ESTORNO     "
     v-devol      format ">>>,>>>,>>9.99" LABEL "DEVOLUCAO   "
     v-reneg      format ">>>,>>>,>>9.99" LABEL "RENEGOCIACAO"
     v-emicanfin  format ">>>,>>>,>>9.99" LABEL "EMI CAN FIN "
     v-recestfin  format ">>>,>>>,>>9.99" LABEL "REC EST FIN "
     v-recnovacao format ">>>,>>>,>>9.99" label "REC NOVACAO "
     with frame f-fim 1 column.                              

procedure p-put:
     put unformat skip
        arqclien.campo1  format "x(3)"     /* 01-03 */
        arqclien.campo2  format "x(18)"    /* 04-21 */
        arqclien.campo3  format "x(5)"     /* 22-26 */
        arqclien.campo4  format "X(5)"     /* 27-31 */ 
        arqclien.campo5  format "x(12)"    /* 32-43 */
        arqclien.campo6  format "x(8)"     /* 44-51 */
        arqclien.campo7  format "x(3)"     /* 52-54 */
        arqclien.campo8  format "x(16)"    /* 55-70 */
        arqclien.campo9  format "x(1)"     /* 71 */
        arqclien.campo10 format "x(8)"     /* 72-79 */
        arqclien.campo11 format "x(16)"    /* 80-95 */
        arqclien.campo12 format "x(8)"     /* 96-103 */
        " " /*arqclien.campo13*/ format "x(12)"    /* 104-115 nro arquivamento */         arqclien.campo14 format "x(28)"    /* 116-143 cod.contabil */
        entry(1,arqclien.campo15," ") + " " + arqclien.campo5
         format "x(250)"   /* 144-393  Histórico */ 
        skip.
end.

procedure estorno-devolucao:
       for each tt-estab no-lock:
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
end procedure.

procedure cancelamento-financeira:

    for each financeirace where
                 financeirace.datcan = vdata1
                 no-lock:
        find first contrato where
         contrato.contnum = financeirace.contnum
         no-lock no-error.
        if not avail contrato
        then do:
            find first envfinan where
                   titnum = string(financeirace.contnum)
                   no-lock no-error.
            if avail envfinan
            then assign
                vetb-cod = envfinan.etbcod
                vcli-for = envfinan.clifor
                .
            else next.     
        end.
        else assign
            vetb-cod = contrato.etbcod
            vcli-for = contrato.clicod
            .

        vtitvlcob = financeirace.valcan /*+ financeirace.acrescimo*/.
        vtotal = vtotal + vtitvlcob.         
        vacrescimo = vacrescimo + financeirace.acrescimo.
    
        if financeirace.valcan > 0
        then do:
        put unformat skip
     vetb-cod /*tituarqm.etbcod*/ format ">>9"           /* 01-03 */
     "C" + string(vcli-for,"9999999999") format "x(18)" /* 04-21 */
     "TIT "  format "x(5)"                /* 22-26 */
     " " format "X(5)"                    /* 27-31 */ 
     financeirace.contnum format "999999999999"  /* 32-43 */
     year(financeirace.datcan) format "9999"          /* 44-51 */
     month(financeirace.datcan) format "99"          
     day(financeirace.datcan)   format "99"
     "C  "     format "x(3)"             /* 52-54 */
     financeirace.valcan        format "9999999999999.99" /* 55-70 */
     "+"                 format "x(1)"             /* 71 */
     year(financeirace.datcan)  format "9999" /* 72-79 */
     month(financeirace.datcan) format "99"  
     day(financeirace.datcan)   format "99"
     financeirace.valcan format "9999999999999.99"  /* 80-95 */
     year(financeirace.datcan) format "9999"  /* 96-103 */
     month(financeirace.datcan) format "99"  
     day(financeirace.datcan) format "99"
     " "     format "x(12)" /* 104-115 nro arquivamento */   
     "1.1.02.01.001" format "x(28)"                  /* 116-143 cod.contabil */
     "EMICANFIN " + string(financeirace.contnum) 
            format "x(250)"               /* 144-393  Histórico */ 
     skip.
          v-emicanfin = v-emicanfin + financeirace.valcan .
       end.    
    end.
     
end procedure.

procedure estorno-financeira:
    for each financeirace where
                 financeirace.datest = vdata1
                 no-lock:
        find first contrato where
         contrato.contnum = financeirace.contnum
         no-lock no-error.
        if not avail contrato
        then do:
            find first envfinan where
                   titnum = string(financeirace.contnum)
                   no-lock no-error.
            if avail envfinan
            then assign
                vetb-cod = envfinan.etbcod
                vcli-for = envfinan.clifor
                .
            else assign
                vetb-cod = 1
                vcli-for = 123
                .
            
        end.
        else assign
            vetb-cod = contrato.etbcod
            vcli-for = contrato.clicod
            .

        vtotal = vtotal + financeirace.valest.         
    
        put unformat skip
     vetb-cod /*tituarqm.etbcod*/ format ">>9"           /* 01-03 */
     "C" + string(vcli-for,"9999999999") format "x(18)" /* 04-21 */
     "TIT "  format "x(5)"                /* 22-26 */
     " " format "X(5)"                    /* 27-31 */ 
     financeirace.contnum format "999999999999"  /* 32-43 */
     year(financeirace.datest) format "9999"          /* 44-51 */
     month(financeirace.datest) format "99"          
     day(financeirace.datest)   format "99"
     "R  "     format "x(3)"             /* 52-54 */
     financeirace.valest        format "9999999999999.99" /* 55-70 */
     "-"                 format "x(1)"             /* 71 */
     year(financeirace.datest)  format "9999" /* 72-79 */
     month(financeirace.datest) format "99"  
     day(financeirace.datest)   format "99"
     financeirace.valest format "9999999999999.99"  /* 80-95 */
     year(financeirace.datest) format "9999"  /* 96-103 */
     month(financeirace.datest) format "99"  
     day(financeirace.datest) format "99"
     " "     format "x(12)" /* 104-115 nro arquivamento */   
     "1.1.02.01.001" format "x(28)"                  /* 116-143 cod.contabil */
     "RECESTFIN " + string(financeirace.contnum) 
            format "x(250)"               /* 144-393  Histórico */ 
     skip.
       v-recestfin = v-recestfin + financeirace.valest.
       
    end.
 
end procedure.

