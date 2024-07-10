{admcab.i}
    
def shared var vdti as date.
def shared var vdtf as date.

def temp-table tt-arqclien like arqclien.

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
def var vacrescimo as dec.
def var vemiacre as dec.
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
            "/admcom/custom/Claudir/clientes2012/tit_" + trim(string(vetbcod,"999")) + "_" +
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
 
    update varqexp at 1 format "x(75)".
    /*output to value(varqexp).
    */



message "Executando quoter...".
pause 0.

os-command silent value("/usr/dlc/bin/quoter -c 1-3,4-21,22-26,27-31,32-43,44-51,52-54,55-70,71-71,72-79,80-95,96-103,104-115,11
6-143,144-393 " + varqexp + " > " + varqexp + ".quo").

pause 0.
    message "Importando arquivo...".
    pause 0.
    input from value(varqexp + ".quo") .
    repeat:
    
    create tt-arqclien.
    import campo1 campo2 campo3 campo4 campo5 campo6 campo7 campo8 campo9
           campo10 campo11 campo12 campo13 campo14 campo15
           .
    assign       
        mes = month(vdti)
        ano = year(vdti) 
        tipo = campo15
        tt-arqclien.etbcod = int(campo1)
        tt-arqclien.data = date(int(substr(string(campo6),5,2)),
                             int(substr(string(campo6),7,2)),
                             int(substr(string(campo6),1,4)))
        .      
             
    end.
    input close.           
           

    message "FIM             ".
    pause 0.
    output stream tl to terminal.
    do:       
        do vdata1 = vdti to vdtf:
            disp stream tl "Processando ... "  vdata1 
                with frame fxy1 no-label 1 down centered no-box
                color message .
            pause 0.
            
            if day(vdata1) = 1
            then    
            for each tt-arqclien where 
                      tt-arqclien.mes = month(vdata1) and
                      tt-arqclien.ano = year(vdata1)  
                      no-lock:
                
                if tt-arqclien.campo20 = "FINANCEIRA"
                then next.
                /*if tt-arqclien.tipo begins "JUROS"
                then next.
                */
                /*
                run p-put.
                */
                
                if tt-arqclien.tipo begins "EMISSAO"
                then do:
                    vemissao = vemissao + dec(tt-arqclien.campo8).
                end.
                else if tt-arqclien.tipo begins "ACRESCIMO"
                then do: 
                    vemiacre = vemiacre + dec(tt-arqclien.campo8).  
                        dec(tt-arqclien.campo8).
                end.
                else if tt-arqclien.tipo begins "RECEBIMENTO"
                then do: 
                    vrecebimento = vrecebimento + dec(tt-arqclien.campo8).
                end.
                else if tt-arqclien.tipo begins "JUROS" 
                then do:
                    vjuro = vjuro + dec(tt-arqclien.campo8).
                end.
                else if tt-arqclien.tipo begins "ESTORNO"
                then do:  
                    v-estorno = v-estorno + dec(tt-arqclien.campo8).           
                end.
                else if tt-arqclien.tipo begins "DEVOLUCAO"
                then do: 
                    v-devol = v-devol + dec(tt-arqclien.campo8).
                end.
                else if tt-arqclien.tipo begins "RENEGOCIACAO"
                then do:
                    v-reneg = v-reneg + dec(tt-arqclien.campo8).
                end.
                else if tt-arqclien.tipo begins "FINESTACR"
                then do:
                    v-finestacr = v-finestacr + dec(tt-arqclien.campo8).
                end.
                else if tt-arqclien.tipo begins "FINESTEMI"
                then do:
                    v-finestemi = v-finestemi + dec(tt-arqclien.campo8).
                end.
                else do:
                    message tt-arqclien.tipo.
                    pause.
                end.  
                
            end.
            /*
            run estorno-devolucao.
            */
        end.
    end.
    /*output close.
    */
    output stream tl close.
disp vemissao     format ">>>,>>>,>>9.99" label "EMISSAO     "
     vemiacre     format ">>>,>>>,>>9.99" label "ACRESCIMO   "
     vrecebimento format ">>>,>>>,>>9.99" LABEL "RECEBIMENTO "
     vjuro        format ">>>,>>>,>>9.99" LABEL "JURO        "
     v-estorno    format ">>>,>>>,>>9.99" LABEL "ESTORNO     "
     v-devol      format ">>>,>>>,>>9.99" LABEL "DEVOLUCAO   "
     v-reneg      format ">>>,>>>,>>9.99" LABEL "RENEGOCIACAO"
     v-finestemi  format ">>>,>>>,>>9.99" LABEL "EMI EST FINA"
     v-finestacr  format ">>>,>>>,>>9.99" LABEL "ACR EST FINA"
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
