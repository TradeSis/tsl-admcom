
def var  vdti as date.
def var  vdtf as date.

def var vnum-lanca as int.

def var vetbcod like estab.etbcod.

def temp-table tt-estab like estab.

def temp-table tt-resumo
    field data as date
    field tiplan as char
    field debito as dec
    field credito as dec
    index i1 data tiplan
    .
    
update vetbcod with frame f-estab side-label width 80 1 down.
if vetbcod > 0
then do:
    find estab where estab.etbcod = vetbcod no-lock.
    disp estab.etbnom no-label with frame f-estab.
    create tt-estab.
    buffer-copy estab to tt-estab.
end.
else do:
    for each estab no-lock:
        create tt-estab.
        buffer-copy estab to tt-estab.
    end.
end.            

update vdti label "Data Inicio" format "99/99/9999"
     vdtf label "Data Fim"      format "99/99/9999"
     with frame ff1 1 down width 80 side-label
     no-box color message.
/*
if vdti >= 01/01/15 or
   vdtf >= 01/01/15
then do:
    message color red/with
    "Pereiodo bloqueado."
     view-as alert-box.
     return.
end.
*/
def var vmes as int.
def var vano as int.
vmes = month(vdti).
vano = year(vdti).

def temp-table tt-arquivo
    field CD_ESTAB      as char format "x(16)"      
        /*Código do estabelecimento ou filial 1-16*/
    field DT_INI_PERIODO    as int  format "99999999"   
        /*Data de início do período 17-8*/
    field AN_LIVRO          as char format "x(10)"      
        /*Código do livro 25-10 Por exemplo:. DIARIO para Diário Geral,         FORNECEDOR para Diário Auxiliar de fornecedores*/
    field DT_LCTO           as int  format "99999999"       
        /*Data do lançamento 35-8*/
    field AN_NUM_LCTO       as char format "x(20)"          
        /*Número ou código de identificação única 
            do lançamento contábil 43-20*/
    field AN_LANCTO_LOTE    as char format "x(10)"          
        /*Código do lote quando houver lote de lançamentos 63-10*/
    field NR_BOLETIM        as int  format "99999"          
        /*Número do boletim quando houver boletim de lançamentos 73-5*/
    field NR_LANCTO         as int  format "99999999"       
        /*Numero do lançamento dentro do numero único de 
        lançamentos e ou lote 78-8*/
    field DT_FIM_PERIODO    as int  format "99999999"       
        /*Data de final do período 86-8*/
    field CD_COD_CTA        as char format "x(52)"          
        /*Código da conta analítica debitada-creditada 94-52*/
    field CD_COD_CCUS       as char format "x(30)"          
        /*Código do centro de custos 146-30*/
    field VL_DC             as dec  format "99999999999999.99" 
        /*Valor do lançamento 176-17*/
    field IN_IND_DC         as char format "x"              
        /*Indicador da natureza da partida: D - Débito;C - Crédito 193-1*/
    field IN_IND_LCTO       as char format "x"              
        /*Indicador do tipo de lançamento: N - Lançamento normal (todos os
          lançamentos, exceto os de encerramento das contas de resultado);
            E - Lançamento de encerramento de contas de resultado 194-1*/
    field AN_NUM_ARQ        as char format "x(50)"          
        /*Número, código ou caminho de localização dos 
            documentos arquivados 195-50*/
    field AN_COD_HIST_PAD   as char format "x(5)"           
        /*Código do histórico padrão, conforme tabela I075  245-5*/
    field AN_HIST           as char format "x(254)"         
        /*Histórico completo da partida ou histórico complementar 250-254*/
    field AN_COD_PART       as char format "x(22)"          
        /*Código de identificação do participante 504-22*/
    field CD_DOCUMENTO      as char format "x(10)"          
        /*Código de documento 526-10*/
    field IN_ROTINA         as char format "x(30)"          
        /*Texto indicando a rotina - origem dos dados 536-30*/
    field CD_USUARIO        as char format "x(16)"          
        /*Código do Usuário que realizou a gravação 566-16*/
    field DT_ALTERACAO      as int  format "99999999"       
        /*Data da última gravação do registro 582-8*/
    field HR_ALTERACAO      as char format "x(8)"           
        /*Hora da última gravação do registro no formato hh:mm:ss 590-8*/
    field CD_STID           as char format "x(30)"          
        /*Código da estação onde foi realizada a última gravação 598-30*/
    field AN_COD_PART_AUX   as char format "x(22)"          
        /*Código do cliente ou fornecedor cfe o livro 690-22*/
    field AN_NM_PART_AUX    as char format "x(100)"          
        /*Razão social do cliente ou fornecedor 712-100*/
    field DT_OPER           as int  format "99999999"       
        /*Data da operação ref. Documento 812-8*/
    field AN_TP_OPER        as char format "x(20)"          
        /*Tipo de operacao . texto identificando a operacao. 
            Exemplo: entrada, pagamento 820-20*/
    field AN_TP_DOC         as char format "x(10)"          
        /*Tipo do documento 840-10*/
    field AN_DOC            as char format "x(20)"          
        /*Número do documento 850-20*/
    .

def var vreg as int format ">>>>>>>>9".
def stream sdisp.    
def var varqexp as char.
def var varqres as char.
def var vnomarq as char.
vnomarq = "tit".
        
varqexp = "/admcom/decision/" + vnomarq + "_" + 
                trim(string(vetbcod,"999")) + "_" +
                string(day(vdti),"99") +  
                string(month(vdti),"99") +  
                string(year(vdti),"9999") + "_" + 
                string(day(vdtf),"99") +  
                string(month(vdtf),"99") +  
                string(year(vdtf),"9999") + ".txt".

varqres = "/admcom/decision/" + vnomarq + "_RESUMO_" + 
                string(month(vdtf),"99") + "_" +
                string(year(vdtf),"9999") + ".csv".

output stream sdisp to terminal.
output to value(varqexp).

for each tt-estab where tt-estab.etbcod > 0 no-lock:
for each tabdac use-index indx5 where
         tabdac.etblan = tt-estab.etbcod and
         tabdac.datlan >= vdti and
         tabdac.datlan <= vdtf and
         tabdac.situacao <> 1
         no-lock:

    vreg = vreg + 1.
    if vreg mod 10000 = 0
    then do:
        disp stream sdisp  "Aguarde processamento... " vreg no-label
             "registros processados"
              with frame f-disp 1 down no-box color message row 10
              width 80.
        pause 0.      
    end.  
    if sitlan = "LEBES"
    THEN.
    else next.
    
    if tabdac.tiplan = "DEVVISTA"    or
       tabdac.tiplan = "VENDAVISTA"  or
       tabdac.tiplan = "JUROS" 
    then next.
    

    find first clien where clien.clicod = int(tabdac.clicod) no-lock no-error.

    vnum-lanca = vnum-lanca + 1.
    
    if tabdac.tiplan = "EMISSAO" or
       tabdac.tiplan = "EMINOVACAO" or
       tabdac.tiplan = "EMICANFINAN"
    then run put-emissao.
    else if tabdac.tiplan = "ESTORNO"
    then run put-estorno. 
    else if tabdac.tiplan = "ACRESCIMO"   or
            tabdac.tiplan = "ACRCANFINAN" or
            tabdac.tiplan = "ACRNOVACAO"  
    then run put-acrescimo.
    else if tabdac.tiplan = "DEVOLUCAO"
    then run put-devolucao.
    else if tabdac.tiplan = "RECEBIMENTO" or
            tabdac.tiplan = "RECESTFINAN" or
            tabdac.tiplan = "RECNOVACAO"  
    then run put-recebimento.         
    /*else if tabdac.tiplan = "JUROS"
    then run put-juros.  
    */            
end.
end.
output stream sdisp close.
output close.
def var vdebito as char.
def var vcredito as char.
output to value(varqres).
put "Data;Debito;Credito" skip.
for each tt-resumo use-index i1:

    assign
        vdebito = string(tt-resumo.debito,">>>>>>>>>>>9.99")
        vdebito = replace(vdebito,".",",")
        vcredito = string(tt-resumo.credito,">>>>>>>>>>>9.99")
        vcredito = replace(vcredito,".",",")
        .
    
    put unformatted tt-resumo.data ";"
        tt-resumo.tiplan ";"
        vdebito format "x(16)" ";"
        vcredito format "x(16)" ";"
        skip.

end.
output close.    
output to ./xdac.
unix silent unix2dos value(varqexp).
output close.

message color red/with
    "Arquivos gerados" skip 
    varqexp skip
    varqres
    view-as alert-box.
      
procedure put-emissao.

    run resumo(input tabdac.datlan, 
               input tabdac.vallan + tabdac.seguro,
               input 0,
               input tabdac.tiplan).
               
    put unformat
     tabdac.etbcod format ">>9"           /* 01-16 */
     "C" + string(tabdac.clicod,"9999999999") format "x(18)" /* 04-21 */
     "TIT "  format "x(5)"                /* 22-26 */
     " " format "X(5)"                    /* 27-31 */ 
     tabdac.numlan format "999999999999"  /* 32-43 */
     year(tabdac.datlan) format "9999"          /* 44-51 */
     month(tabdac.datlan) format "99"          
     day(tabdac.datlan)   format "99"
     "C  "     format "x(3)"             /* 52-54 */
     tabdac.vallan + tabdac.seguro   format "9999999999999.99" /* 55-70 */
     "+"                 format "x(1)"             /* 71 */
     year(tabdac.datlan)  format "9999" /* 72-79 */
     month(tabdac.datlan) format "99"  
     day(tabdac.datlan)   format "99"
     tabdac.vallan + tabdac.seguro format "9999999999999.99"  /* 80-95 */
     year(tabdac.datlan) format "9999"  /* 96-103 */
     month(tabdac.datlan) format "99"  
     day(tabdac.datlan) format "99"
     ""   format "x(12)" /* 104-115 nro arquivamento */
     "1.1.02.01.001" format "x(28)"        /* 116-143 cod.contabil */
     tabdac.tiplan  format "x(250)"               /* 144-393  Histórico */ 
     skip
     .
end procedure.

procedure put-estorno:

    run resumo(input tabdac.datlan, 
               input tabdac.vallan + tabdac.seguro,
               input 0,
               input tabdac.tiplan).
    
    put unformat
        tabdac.etbcod format ">>9"           /* 01-03 */
        "C" + string(tabdac.clicod,"9999999999") format "x(18)" /* 04-21 */
        "EST"  format "x(5)"                /* 22-26 */
        " " format "X(5)"                    /* 27-31 */ 
        tabdac.numlan format "999999999999"  /* 32-43 */
        year(tabdac.datlan) format "9999"          /* 44-51 */
        month(tabdac.datlan) format "99"          
        day(tabdac.datlan)   format "99"
        "A  "     format "x(3)"             /* 52-54 */
        tabdac.vallan + tabdac.seguro   format "9999999999999.99" /* 55-70 */
        "+"                 format "x(1)"             /* 71 */
        year(tabdac.datlan)  format "9999" /* 72-79 */
        month(tabdac.datlan) format "99"  
        day(tabdac.datlan)   format "99"
        tabdac.vallan + tabdac.seguro format "9999999999999.99"  /* 80-95 */
        year(tabdac.datlan) format "9999"  /* 96-103 */
        month(tabdac.datlan) format "99"  
        day(tabdac.datlan) format "99"
        ""  format "x(12)" /* 104-115 nro arquivamento */
        "1.1.02.01.001" format "x(28)"   /* 116-143 cod.contabil */
        tabdac.tiplan format "x(250)"               /* 144-393  Histórico */ 
        skip
        .
end procedure.
procedure put-acrescimo:

    run resumo(input tabdac.datlan, 
               input tabdac.vallan,
               input 0,
               input tabdac.tiplan).

    put unformat
        tabdac.etbcod format ">>9"           /* 01-03 */
        "C" + string(tabdac.clicod,"9999999999") format "x(18)" /* 04-21 */
        "ACR "  format "x(5)"                /* 22-26 */
        " " format "X(5)"                    /* 27-31 */ 
        tabdac.numlan format "999999999999"  /* 32-43 */
        year(tabdac.datlan) format "9999"          /* 44-51 */
        month(tabdac.datlan) format "99"          
        day(tabdac.datlan)   format "99"
        "A  "     format "x(3)"             /* 52-54 */
        tabdac.vallan    format "9999999999999.99" /* 55-70 */
        "+"                 format "x(1)"             /* 71 */
        year(tabdac.datlan)  format "9999" /* 72-79 */
        month(tabdac.datlan) format "99"  
        day(tabdac.datlan)   format "99"
        tabdac.vallan format "9999999999999.99"  /* 80-95 */
        year(tabdac.datlan) format "9999"  /* 96-103 */
        month(tabdac.datlan) format "99"  
        day(tabdac.datlan) format "99"
        ""  format "x(12)" /* 104-115 nro arquivamento */
        "1.1.02.01.001" format "x(28)"   /* 116-143 cod.contabil */
        tabdac.tiplan format "x(250)"               /* 144-393  Histórico */
        skip 
         .
end procedure.
procedure put-devolucao:

    run resumo(input tabdac.datlan, 
               input 0,
               input tabdac.vallan,
               input tabdac.tiplan).
    
    put unformat
     tabdac.etbcod format ">>9"           /* 01-03 */
     "C" + string(tabdac.clicod,"9999999999") format "x(18)" /* 04-21 */
     "TIT "  format "x(5)"                /* 22-26 */
     " " format "X(5)"                    /* 27-31 */ 
     tabdac.numlan format "999999999999"  /* 32-43 */
     year(tabdac.datlan) format "9999"          /* 44-51 */
     month(tabdac.datlan) format "99"          
     day(tabdac.datlan)   format "99"
     "C  "     format "x(3)"             /* 52-54 */
     tabdac.vallan    format "9999999999999.99" /* 55-70 */
     "-"                 format "x(1)"             /* 71 */
     year(tabdac.datlan)  format "9999" /* 72-79 */
     month(tabdac.datlan) format "99"  
     day(tabdac.datlan)   format "99"
     tabdac.vallan format "9999999999999.99"  /* 80-95 */
     year(tabdac.datlan) format "9999"  /* 96-103 */
     month(tabdac.datlan) format "99"  
     day(tabdac.datlan) format "99"
     ""   format "x(12)" /* 104-115 nro arquivamento */
     "1.1.02.01.001" format "x(28)"        /* 116-143 cod.contabil */
     tabdac.tiplan format "x(250)"               /* 144-393  Histórico */ 
     skip
     .
end procedure.
procedure put-recebimento:
    
    run resumo(input tabdac.datlan, 
               input 0,
               input tabdac.vallan + tabdac.seguro,
               input tabdac.tiplan).

    put unformat skip
     tabdac.etblan format ">>9"           /* 01-03 */
     "C" + string(tabdac.clicod,"9999999999") format "x(18)" /* 04-21 */
     "TIT "  format "x(5)"                /* 22-26 */
     " " format "X(5)"                    /* 27-31 */ 
     tabdac.numlan format "999999999999"  /* 32-43 */
     year(tabdac.datlan) format "9999"          /* 44-51 */
     month(tabdac.datlan) format "99"          
     day(tabdac.datlan)   format "99"
     "R  "     format "x(3)"             /* 52-54 */
     tabdac.vallan + tabdac.seguro format "9999999999999.99" /* 55-70 */
     "-"                 format "x(1)"             /* 71 */
     year(tabdac.datemi)  format "9999" /* 72-79 */
     month(tabdac.datemi) format "99"  
     day(tabdac.datemi)   format "99"
     tabdac.vallan + tabdac.seguro format "9999999999999.99"  /* 80-95 */
     year(tabdac.datven) format "9999"  /* 96-103 */
     month(tabdac.datven) format "99"  
     day(tabdac.datven) format "99"
     " "   format "x(12)" /* 104-115 nro arquivamento */   
     "1.1.02.01.001" format "x(28)"                  /* 116-143 cod.contabil */
     tabdac.tiplan format "x(250)"    /* 144-393  Histórico */ 
     skip
     .
     
end procedure.

procedure put-juros:
    
    /***
    put unformat skip
        tabdac.etblan format ">>9"           /* 01-03 */
        "C" + string(tabdac.clicod,"9999999999") format "x(18)" /* 04-21 */
        "TIT "  format "x(5)"                /* 22-26 */
        " " format "X(5)"                    /* 27-31 */ 
        tabdac.numlan format "999999999999"  /* 32-43 */
        year(tabdac.datlan) format "9999"          /* 44-51 */
        month(tabdac.datlan) format "99"          
        day(tabdac.datlan)   format "99"
        "J  "     format "x(3)"             /* 52-54 */
        tabdac.vallan        format "9999999999999.99" /* 55-70 */
        "-"                 format "x(1)"             /* 71 */
        year(tabdac.datemi)  format "9999" /* 72-79 */
        month(tabdac.datemi) format "99"  
        day(tabdac.datemi)   format "99"
        tabdac.vallan format "9999999999999.99"  /* 80-95 */
        year(tabdac.datven) format "9999"  /* 96-103 */
        month(tabdac.datven) format "99"  
        day(tabdac.datven) format "99"
        " " format "x(12)" /* 104-115 nro arquivamento */   
        "5.3.02.01.001" format "x(28)"     /* 116-143 cod.contabil */
        tabdac.tiplan format "x(250)"            /* 144-393  Histórico */
        skip 
         .
     ***/

end procedure.

procedure resumo:
    
    def input parameter p-data as date.
    def input parameter p-debito as dec.
    def input parameter p-credito as dec.
    def input parameter p-tiplan as char.

    find first tt-resumo where
               tt-resumo.data = p-data and
               tt-resumo.tiplan = p-tiplan
               no-error.
    if not avail tt-resumo
    then do:
        create tt-resumo.
        tt-resumo.data = p-data.
        tt-resumo.tiplan = p-tiplan.
    end.

    assign
        tt-resumo.debito = tt-resumo.debito + p-debito
        tt-resumo.credito = tt-resumo.credito + p-credito.        

end procedure.
