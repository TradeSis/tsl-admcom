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
        do vdata1 = vdti to vdtf:
            disp stream tl "Processando ... " tt-estab.etbcod vdata1 
                with frame fxy1 no-label 1 down centered no-box
                color message .
            pause 0.

            create tt-venda.
            tt-venda.etbcod = tt-estab.etbcod.
            tt-venda.data = vdata1.

            for each arqclien where 
                      arqclien.mes = month(vdata1) and
                      arqclien.ano = year(vdata1) and
                      arqclien.tipo = "EMISSAO" and
                      arqclien.etbcod = tt-estab.etbcod and
                      arqclien.data = vdata1
                      no-lock:
                
                run p-put.
                
                vemissao = vemissao + dec(arqclien.campo8).
                tt-venda.aprazo = tt-venda.aprazo + dec(arqclien.campo8).
            end.
            for each arqclien where 
                      arqclien.mes = month(vdata1) and
                      arqclien.ano = year(vdata1) and
                      arqclien.tipo = "ACRESCIMO" and
                      arqclien.etbcod = tt-estab.etbcod and
                      arqclien.data = vdata1
                      no-lock:
                
                run p-put.
                
                vemiacre = vemiacre + dec(arqclien.campo8).  
                tt-venda.acrescimo = tt-venda.acrescimo + dec(arqclien.campo8).
            end. 

            for each arqclien where 
                      arqclien.mes = month(vdata1) and
                      arqclien.ano = year(vdata1) and
                      arqclien.tipo = "RECEBIMENTO" and
                      arqclien.etbcod = tt-estab.etbcod and
                      arqclien.data = vdata1
                      no-lock:
                
                if arqclien.campo20 = "FINANCEIRA"
                then next.
                
                run p-put.

                vrecebimento = vrecebimento + dec(arqclien.campo8).
                tt-venda.recebi = tt-venda.recebi + dec(arqclien.campo8).
            end.         

            /*
            for each arqclien where 
                      arqclien.mes = month(vdata1) and
                      arqclien.ano = year(vdata1) and
                      arqclien.tipo = "JUROS" and
                      arqclien.etbcod = tt-estab.etbcod and
                      arqclien.data = vdata1
                      no-lock:
                
                run p-put.
              
                vjuro = vjuro + dec(arqclien.campo8).
                tt-venda.juro = tt-venda.juro + dec(arqclien.campo8).
  
            end.
            */
            
            for each arqclien where 
                      arqclien.mes = month(vdata1) and
                      arqclien.ano = year(vdata1) and
                      arqclien.tipo = "ESTORNO"  and
                      arqclien.etbcod = tt-estab.etbcod and
                      arqclien.data = vdata1
                      no-lock:
                
                run p-put.
                v-estorno = v-estorno + dec(arqclien.campo8).           
            end.
            for each arqclien where 
                      arqclien.mes = month(vdata1) and
                      arqclien.ano = year(vdata1) and
                      arqclien.tipo = "DEVOLUCAO" and
                      arqclien.etbcod = tt-estab.etbcod and
                      arqclien.data = vdata1
                      no-lock:
                
                run p-put.
                v-devol = v-devol + dec(arqclien.campo8).

            end.
        end.
    end.
    output close.
    output stream tl close.
disp vemissao     format ">>>,>>>,>>9.99" label "EMISSAO    "
     vemiacre     format ">>>,>>>,>>9.99" label "ACRESCIMO  "
     vrecebimento format ">>>,>>>,>>9.99" LABEL "RECEBIMENTO"
     vjuro        format ">>>,>>>,>>9.99" LABEL "JURO       "
     v-estorno    format ">>>,>>>,>>9.99" LABEL "ESTORNO    "
     v-devol      format ">>>,>>>,>>9.99" LABEL "DEVOLUCAO  "
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
        arqclien.campo13 format "x(12)"    /* 104-115 nro arquivamento */   
        arqclien.campo14 format "x(28)"    /* 116-143 cod.contabil */
        arqclien.campo15 format "x(250)"   /* 144-393  Histórico */ 
        skip.
end.

