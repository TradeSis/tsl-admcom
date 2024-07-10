
def shared var vdti as date.
def shared var vdtf as date.

def var vnum-lanca as int.

def var vetbcod like estab.etbcod.

def temp-table tt-estab like estab.

def temp-table tt-resumo
    field data as date
    field tipo as char
    field debito as dec
    field credito as dec
    index i1 data
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

/*************
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
****************/

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

def var vdata as date.
def var vhistorico as char.
form with frame f-disp  row 12 1 down side-label.

do vdata = vdti to vdtf:
    disp stream sdisp vdata label "Data" with frame f-disp.
    pause 0.
    for each estab where (if vetbcod > 0 then estab.etbcod = vetbcod
                          else true) no-lock:
        
        disp stream sdisp estab.etbcod label "Filial"
        with frame f-disp. pause 0.

        
        for each diauxcli where
                 diauxcli.data = vdata and
                 diauxcli.etbcod = estab.etbcod
                 no-lock:
            if diauxcli.tipo = "EMISSAO"
            then run diauxcli-emissao.
            if diauxcli.tipo = "RECEBIMENTO"
            then run diauxcli-recebimento.
        end.         
                 
        /*****************************************************
        vhistorico = "VENDAS A PRAZO CF REG SAIDAS".
        /***************
        for each opctbval where opctbval.etbcod = estab.etbcod and
                                opctbval.datref = vdata  and
               opctbval.t1 = "CONTRATO" and
               opctbval.t2 = "A-PRAZO" and
               opctbval.t3 = "CRE" and
               opctbval.t4 = "LEBES" and
               opctbval.t5 = "ABATE" AND /*
               opctbval.t6 = "" and
               opctbval.t7 = "TROCA"  and
               opctbval.t8 = ""  and  */
               opctbval.t9 <> "" /*and
               opctbval.t0 = ""   */
               no-lock:
            run message-reg(input opctbval.t1 + " " + opctbval.t5).

            find contrato where contrato.contnum = int(opctbval.t9) 
                    no-lock no-error.
            if avail contrato
            then do:        
                find first   clien where 
                            clien.clicod = int(contrato.clicod) 
                            no-lock no-error.
    
                vnum-lanca = vnum-lanca + 1.
                run put-emissao.
            end.        
        end.    
        for each opctbval where opctbval.etbcod = estab.etbcod and
                                opctbval.datref = vdata  and
               opctbval.t1 = "CONTRATO" and
               opctbval.t2 = "A-PRAZO" and
               opctbval.t3 = "CRE" and
               opctbval.t4 = "LEBES" and
               opctbval.t5 = "PRINCIPAL" AND /*
               opctbval.t6 = "FISCAL" and
               opctbval.t7 = ""  and
               opctbval.t8 = ""  and */
               opctbval.t9 <> ""  /*and
               opctbval.t0 = ""     */
               no-lock:
            run message-reg(input opctbval.t1 + " " + opctbval.t5).

            find contrato where contrato.contnum = int(opctbval.t9) 
                    no-lock no-error.
            if avail contrato
            then do:        
                find first   clien where 
                            clien.clicod = int(contrato.clicod) 
                            no-lock no-error.
    
                vnum-lanca = vnum-lanca + 1.
        
                run put-emissao.
            end. 
        end.       
        for each opctbval where opctbval.etbcod = estab.etbcod and
                                opctbval.datref = vdata  and
               opctbval.t1 = "CONTRATO" and
               opctbval.t2 = "A-PRAZO" and
               opctbval.t3 = "CRE" and
               opctbval.t4 = "LEBES" and
               opctbval.t5 = "PRINCIPAL" AND
               opctbval.t6 = "OUTRAS" and
               opctbval.t7 = ""  and
               opctbval.t8 = ""  and
               opctbval.t9 <> ""  /*and
               opctbval.t0 = ""*/
               no-lock:
            run message-reg(input opctbval.t1 + " " + opctbval.t5).

            find contrato where contrato.contnum = int(opctbval.t9) 
                    no-lock no-error.
            if avail contrato
            then do:        
                find first   clien where 
                            clien.clicod = int(contrato.clicod) 
                            no-lock no-error.
    
                vnum-lanca = vnum-lanca + 1.
        
                run put-emissao.
            end. 
        end.        
        for each opctbval where opctbval.etbcod = estab.etbcod and
                                opctbval.datref = vdata  and
               opctbval.t1 = "CONTRATO" and
               opctbval.t2 = "A-PRAZO" and
               opctbval.t3 = "CRE" and
               opctbval.t4 = "LEBES" and
               opctbval.t5 = "PRINCIPAL" AND
               opctbval.t6 = "SERVICO" and
               opctbval.t7 = ""  and
               opctbval.t8 = ""  and
               opctbval.t9 <> "" /* and
               opctbval.t0 = ""    */
               no-lock:
            run message-reg(input opctbval.t1 + " " + opctbval.t5).

            find contrato where contrato.contnum = int(opctbval.t9) 
                    no-lock no-error.
            if avail contrato
            then do:        
                find first   clien where 
                            clien.clicod = int(contrato.clicod) 
                            no-lock no-error.
    
                vnum-lanca = vnum-lanca + 1.
        
                run put-emissao.
            end. 
        end.               
        for each opctbval where opctbval.etbcod = estab.etbcod and
                                opctbval.datref = vdata  and
               opctbval.t1 = "CONTRATO" and
               opctbval.t2 = "A-PRAZO" and
               opctbval.t3 = "CRE" and
               opctbval.t4 = "LEBES" and
               opctbval.t5 = "ENTRADA" and
               opctbval.t6 = "" and
               opctbval.t7 = ""  and
               opctbval.t8 = ""  and
               opctbval.t9 <> "" /* and
               opctbval.t0 = ""    */
               no-lock:
            run message-reg(input opctbval.t1 + " " + opctbval.t5).

            find contrato where contrato.contnum = int(opctbval.t9) 
                    no-lock no-error.
            if avail contrato
            then do:        
                find first   clien where 
                            clien.clicod = int(contrato.clicod) 
                            no-lock no-error.
    
                vnum-lanca = vnum-lanca + 1.
        
                run put-emissao.
            end. 
        end.               

         ************************************************/
         
        /**VLR ACRESCIMO FINANCEIRO N/DATA**/
        
        for each opctbval where opctbval.etbcod = estab.etbcod and
                        opctbval.datref = vdata  and
                        opctbval.t1 = "CONTRATO" and
                        opctbval.t2 = "A-PRAZO"  and
                        opctbval.t3 = "CRE"      and
                        opctbval.t4 = "LEBES"    and
                        opctbval.t5 = "ACRESCIMO" and
                        opctbval.t6 = "" /*"FISCAL"*/ and
                        opctbval.t7 = "" and
                        opctbval.t8 = "" and
                        opctbval.t9 <> "" and
                        opctbval.t0 = ""
                     no-lock.
            
            run message-reg(input opctbval.t1 + " " + opctbval.t5).

            find contrato where contrato.contnum = int(opctbval.t9) 
                    no-lock no-error.
            if avail contrato
            then do:        
                find first   clien where 
                            clien.clicod = int(contrato.clicod) 
                            no-lock no-error.
    
                vnum-lanca = vnum-lanca + 1.
        
                run put-acrescimo.
            end. 
            
        end.
        for each opctbval where opctbval.etbcod = estab.etbcod and
                        opctbval.datref = vdata   and
                        opctbval.t1 = "CONTRATO"  and
                        opctbval.t2 = "A-PRAZO"   and
                        opctbval.t3 = "CRE"       and
                        opctbval.t4 = "LEBES"     and
                        opctbval.t5 = "PRINCIPAL" and /*
                        opctbval.t6 = "" /*"FISCAL"*/ and
                        opctbval.t7 = "" and
                        opctbval.t8 = "" and  */
                        opctbval.t9 <> ""         and
                        opctbval.t0 = ""
                     no-lock.

            run message-reg(opctbval.t1 + " " + opctbval.t5).

            find contrato where contrato.contnum = int(opctbval.t9) 
                    no-lock no-error.
            if avail contrato
            then do:        
                find first   clien where 
                            clien.clicod = int(contrato.clicod) 
                            no-lock no-error.
    
                vnum-lanca = vnum-lanca + 1.
        
                run put-emissao.
            end.    
        end.
        /**************/
        for each opctbval where opctbval.etbcod = estab.etbcod and
                                opctbval.datref = vdata  and
               opctbval.t1 = "CONTRATO" and
               opctbval.t2 = "A-PRAZO" and
               opctbval.t3 = "CRE" and
               opctbval.t4 = "LEBES" and
               opctbval.t5 = "ABATE" AND /*
               opctbval.t6 = "" and
               opctbval.t7 = "TROCA"  and
               opctbval.t8 = ""  and  */
               opctbval.t9 <> "" and
               opctbval.t0 = ""  
               no-lock:
            run message-reg(opctbval.t1 + " " + opctbval.t5).

            find contrato where contrato.contnum = int(opctbval.t9) 
                    no-lock no-error.
            if avail contrato
            then do:        
                find first   clien where 
                            clien.clicod = int(contrato.clicod) 
                            no-lock no-error.
    
                vnum-lanca = vnum-lanca + 1.
        
                run put-emissao.
            end. 
         end.
         for each opctbval where opctbval.etbcod = estab.etbcod and
                                opctbval.datref = vdata  and
               opctbval.t1 = "CONTRATO" and
               opctbval.t2 = "A-PRAZO" and
               opctbval.t3 = "CRE" and
               opctbval.t4 = "LEBES" and
               opctbval.t5 = "ENTRADA" and /*
               opctbval.t6 = "" and
               opctbval.t7 = ""  and
               opctbval.t8 = ""  and */
               opctbval.t9 <> ""  and
               opctbval.t0 = ""    
               no-lock:
            run message-reg(input opctbval.t1 + " " + opctbval.t5).

            find contrato where contrato.contnum = int(opctbval.t9) 
                    no-lock no-error.
            if avail contrato
            then do:        
                find first   clien where 
                            clien.clicod = int(contrato.clicod) 
                            no-lock no-error.
    
                vnum-lanca = vnum-lanca + 1.
        
                run put-emissao.
            end. 
         end. 
         
         /*****************/
         
         for each opctbval where opctbval.etbcod = estab.etbcod and
                        opctbval.datref = vdata   and
                        opctbval.t1 = "CONTRATO"  and
                        opctbval.t2 = "OUTROS"   and
                        opctbval.t3 = "CRE"       and
                        opctbval.t4 = "NOVACAO"     and
                        opctbval.t5 = "LEBES" and
                        opctbval.t6 = "ACRESCIMO"    and
                        opctbval.t7 = "" and
                        opctbval.t8 = "" and
                        opctbval.t9 <> ""         and
                        opctbval.t0 <> ""
                     no-lock.
            
            run message-reg(input opctbval.t1 + " " + opctbval.t5).
            
            find contrato where contrato.contnum = int(opctbval.t9) 
                    no-lock no-error.
            if avail contrato
            then do:        
                find first   clien where 
                            clien.clicod = int(contrato.clicod) 
                            no-lock no-error.
    
                vnum-lanca = vnum-lanca + 1.
        
                run put-acrescimo.
            end. 

        end.
        for each opctbval where opctbval.etbcod = estab.etbcod and
                        opctbval.datref = vdata   and
                        opctbval.t1 = "CONTRATO"  and
                        opctbval.t2 = "OUTROS"   and
                        opctbval.t3 = "CRE"       and
                        opctbval.t4 = "NOVACAO"     and
                        opctbval.t5 = "LEBES" and
                        opctbval.t6 = "PRINCIPAL"    and
                        opctbval.t7 = "" and
                        opctbval.t8 = "" and
                        opctbval.t9 <> ""         and
                        opctbval.t0 <> ""
                     no-lock.

            run message-reg(input opctbval.t1 + " " + opctbval.t5).

            find contrato where contrato.contnum = int(opctbval.t9) 
                    no-lock no-error.
            if avail contrato
            then do:        
                find first   clien where 
                            clien.clicod = int(contrato.clicod) 
                            no-lock no-error.
    
                vnum-lanca = vnum-lanca + 1.
        
                run put-emissao.
          
            end. 
        
        end.
        for each opctbval where opctbval.etbcod = estab.etbcod and
                        opctbval.datref = vdata   and
                        opctbval.t1 = "CONTRATO"  and
                        opctbval.t2 = "OUTROS"   and
                        opctbval.t3 = "CRE"       and
                        opctbval.t4 = "OUTROS"     and
                        opctbval.t5 = "LEBES" and
                        opctbval.t6 = "ACRESCIMO"    and
                        opctbval.t7 = "" and
                        opctbval.t8 = "" and
                        opctbval.t9 <> ""         and
                        opctbval.t0 <> ""
                     no-lock.

            run message-reg(input opctbval.t1 + " " + opctbval.t5).
            
            find contrato where contrato.contnum = int(opctbval.t9) 
                    no-lock no-error.
            if avail contrato
            then do:        
                find first   clien where 
                            clien.clicod = int(contrato.clicod) 
                            no-lock no-error.
    
                vnum-lanca = vnum-lanca + 1.
        
                run put-acrescimo.

            end. 

        end.
        for each opctbval where opctbval.etbcod = estab.etbcod and
                        opctbval.datref = vdata   and
                        opctbval.t1 = "CONTRATO"  and
                        opctbval.t2 = "OUTROS"   and
                        opctbval.t3 = "CRE"       and
                        opctbval.t4 = "OUTROS"     and
                        opctbval.t5 = "LEBES" and
                        opctbval.t6 = "PRINCIPAL"    and
                        opctbval.t7 = "" and
                        opctbval.t8 = "" and
                        opctbval.t9 <> ""         and
                        opctbval.t0 <> ""
                     no-lock.

            run message-reg(input opctbval.t1 + " " + opctbval.t5).
            
            find contrato where contrato.contnum = int(opctbval.t9) 
                    no-lock no-error.
            if avail contrato
            then do:        
                find first   clien where 
                            clien.clicod = int(contrato.clicod) 
                            no-lock no-error.
    
                vnum-lanca = vnum-lanca + 1.
        
                run put-emissao.
            end. 
        
        end.
        for each opctbval where opctbval.etbcod = estab.etbcod and
                                opctbval.datref = vdata   and
               opctbval.t1 = "RECEBIMENTO" and
               opctbval.t2 = "CRE" and
               opctbval.t3 = "" and
               opctbval.t4 = "" and
               opctbval.t5 = "" and
               opctbval.t6 = "LEBES" and
               opctbval.t7 = "ENTRADA" and
               opctbval.t8 = "" and
               opctbval.t9 <> ""  and
               opctbval.t0 <> "" 
               no-lock:
            run message-reg(input opctbval.t1 + " " + opctbval.t5).
            
            find contrato where contrato.contnum = int(opctbval.t9) 
                    no-lock no-error.
            if avail contrato
            then do:        
                find first   clien where 
                            clien.clicod = int(contrato.clicod) 
                            no-lock no-error.
    
                vnum-lanca = vnum-lanca + 1.
        
                run put-recebimento.
                
            end. 
          
         end.      
         for each opctbval where opctbval.etbcod = estab.etbcod and
                        opctbval.datref = vdata   and
                        opctbval.t1 = "RECEBIMENTO"  and
                        opctbval.t2 = "CRE"   and
                        opctbval.t3 = ""       and
                        opctbval.t4 = ""     and
                        opctbval.t5 = "" and
                        opctbval.t6 = "LEBES"    and
                        opctbval.t7 = "ACRESCIMO" and
                        opctbval.t8 = "" and
                        opctbval.t9 <> ""         and
                        opctbval.t0 <> ""
                     no-lock.

            run message-reg(input opctbval.t1 + " " + opctbval.t5).
            
            find contrato where contrato.contnum = int(opctbval.t9) 
                    no-lock no-error.
            if avail contrato
            then do:        
                find first   clien where 
                            clien.clicod = int(contrato.clicod) 
                            no-lock no-error.
    
                vnum-lanca = vnum-lanca + 1.
        
                run put-recebimento.
                
            end. 

        end.
        for each opctbval where opctbval.etbcod = estab.etbcod and
                        opctbval.datref = vdata   and
                        opctbval.t1 = "RECEBIMENTO"  and
                        opctbval.t2 = "CRE"   and
                        opctbval.t3 = ""       and
                        opctbval.t4 = ""     and
                        opctbval.t5 = "" and
                        opctbval.t6 = "LEBES"    and
                        opctbval.t7 = "PRINCIPAL" and
                        opctbval.t8 = "" and
                        opctbval.t9 <> ""         and
                        opctbval.t0 <> ""
                     no-lock.

            run message-reg(input opctbval.t1 + " " + opctbval.t5).
            
            find contrato where contrato.contnum = int(opctbval.t9) 
                    no-lock no-error.
            if avail contrato
            then do:        
                find first   clien where 
                            clien.clicod = int(contrato.clicod) 
                            no-lock no-error.
    
                vnum-lanca = vnum-lanca + 1.
        
                run put-recebimento.
                
            end. 
            
        end.
        for each opctbval where opctbval.etbcod = estab.etbcod and
                        opctbval.datref = vdata   and
                        opctbval.t1 = "DEVOLUCAO"  and
                        opctbval.t2 = "VENDA"   and
                        opctbval.t3 = "A-PRAZO"   and
                        opctbval.t4 = ""     and
                        opctbval.t5 = "" and
                        opctbval.t6 = ""    and
                        opctbval.t7 = "" and
                        opctbval.t8 = "" and
                        opctbval.t9 <> ""         and
                        opctbval.t0 <> ""
                     no-lock.

            run message-reg(input opctbval.t1 + " " + opctbval.t5).

            find contrato where contrato.contnum = int(opctbval.t9) 
                    no-lock no-error.
            if avail contrato
            then do:        
                find first   clien where 
                            clien.clicod = int(contrato.clicod) 
                            no-lock no-error.
    
                vnum-lanca = vnum-lanca + 1.
        
                run put-devolucao.
            end. 

        end.
        for each opctbval where opctbval.etbcod = estab.etbcod and
                        opctbval.datref = vdata   and
                        opctbval.t1 = "DEVOLUCAO"  and
                        opctbval.t2 = "VENDA"   and
                        opctbval.t3 = "ACERTO"   and
                        opctbval.t4 = "DEVOLVIDO-PAG"     and
                        opctbval.t5 = "" and
                        opctbval.t6 = ""    and
                        opctbval.t7 = "" and
                        opctbval.t8 = "" and
                        opctbval.t9 <> ""         and
                        opctbval.t0 <> ""
                     no-lock.

            run message-reg(input opctbval.t1 + " " + opctbval.t5).

            find contrato where contrato.contnum = int(opctbval.t9) 
                    no-lock no-error.
            if avail contrato
            then do:        
                find first   clien where 
                            clien.clicod = int(contrato.clicod) 
                            no-lock no-error.
    
                vnum-lanca = vnum-lanca + 1.
        
                run put-estorno.
                
            end. 
            
        end.
        for each opctbval where opctbval.etbcod = estab.etbcod and
                        opctbval.datref = vdata   and
                        opctbval.t1 = "ESTORNO"  and
                        opctbval.t2 = "FINANCEIRA"   and
                        opctbval.t3 = "ACRESCIMO"   and
                        opctbval.t4 = ""     and
                        opctbval.t5 = "" and
                        opctbval.t6 = ""    and
                        opctbval.t7 = "" and
                        opctbval.t8 = "" and
                        opctbval.t9 <> ""         and
                        opctbval.t0 <> ""
                     no-lock.

            run message-reg(input opctbval.t1 + " " + opctbval.t5).
            
            find contrato where contrato.contnum = int(opctbval.t9) 
                    no-lock no-error.
            if avail contrato
            then do:        
                find first   clien where 
                            clien.clicod = int(contrato.clicod) 
                            no-lock no-error.
    
                vnum-lanca = vnum-lanca + 1.
        
                run put-acrescimo.
                
            end. 

        end.
        for each opctbval where opctbval.etbcod = estab.etbcod and
                        opctbval.datref = vdata   and
                        opctbval.t1 = "ESTORNO"  and
                        opctbval.t2 = "FINANCEIRA"   and
                        opctbval.t3 = "PRINCIPAL"   and
                        opctbval.t4 = ""     and
                        opctbval.t5 = "" and
                        opctbval.t6 = ""    and
                        opctbval.t7 = "" and
                        opctbval.t8 = "" and
                        opctbval.t9 <> ""         and
                        opctbval.t0 <> ""
                     no-lock.

            run message-reg(input opctbval.t1 + " " + opctbval.t5).

            find contrato where contrato.contnum = int(opctbval.t9) 
                    no-lock no-error.
            if avail contrato
            then do:        
                find first   clien where 
                            clien.clicod = int(contrato.clicod) 
                            no-lock no-error.
    
                vnum-lanca = vnum-lanca + 1.
        
                run put-emissao.
            end. 
            
        end.
        **********************************************************/
        
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
    
    put unformatted 
        tt-resumo.data ";"
        tt-resumo.tipo ";"
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
    /*varqres */
    view-as alert-box.
      
procedure diauxcli-emissao.


    run resumo(input diauxcli.data, 
               input "EMISSAO",
               input diauxcli.valor,
               input 0).
               
    put unformat
     diauxcli.etbcod format ">>9"           /* 01-16 */
     "C" + string(diauxcli.clicod,"9999999999") format "x(18)" /* 04-21 */
     "TIT "  format "x(5)"                /* 22-26 */
     " " format "X(5)"                    /* 27-31 */ 
     dec(diauxcli.numero) format "999999999999"  /* 32-43 */
     year(diauxcli.data) format "9999"          /* 44-51 */
     month(diauxcli.data) format "99"          
     day(diauxcli.data)   format "99"
     "C  "     format "x(3)"             /* 52-54 */
     diauxcli.valor    format "9999999999999.99" /* 55-70 */
     "+"                 format "x(1)"             /* 71 */
     year(diauxcli.data)  format "9999" /* 72-79 */
     month(diauxcli.data) format "99"  
     day(diauxcli.data)   format "99"
     diauxcli.valor format "9999999999999.99"  /* 80-95 */
     year(diauxcli.data) format "9999"  /* 96-103 */
     month(diauxcli.data) format "99"  
     day(diauxcli.data) format "99"
     ""   format "x(12)" /* 104-115 nro arquivamento */
     "1.1.02.01.001" format "x(28)"        /* 116-143 cod.contabil */
     "EMISSAO "  format "x(250)"      /* 144-393  Histórico */ 
     skip
     .
end procedure.

procedure diauxcli-recebimento:
    
    run resumo(input diauxcli.data, 
               input "RECEBIMENTO",  
               input 0,
               input diauxcli.valor).

    put unformat skip
     diauxcli.etbcod format ">>9"           /* 01-03 */
     "C" + string(diauxcli.clicod,"9999999999") format "x(18)" /* 04-21 */
     "TIT "  format "x(5)"                /* 22-26 */
     " " format "X(5)"                    /* 27-31 */ 
     dec(diauxcli.numero) format "999999999999"  /* 32-43 */
     year(diauxcli.data) format "9999"          /* 44-51 */
     month(diauxcli.data) format "99"          
     day(diauxcli.data)   format "99"
     "R  "     format "x(3)"             /* 52-54 */
     diauxcli.valor        format "9999999999999.99" /* 55-70 */
     "-"                 format "x(1)"             /* 71 */
     year(diauxcli.data)  format "9999" /* 72-79 */
     month(diauxcli.data) format "99"  
     day(diauxcli.data)   format "99"
     diauxcli.valor format "9999999999999.99"  /* 80-95 */
     year(diauxcli.data) format "9999"  /* 96-103 */
     month(diauxcli.data) format "99"  
     day(diauxcli.data) format "99"
     " "   format "x(12)" /* 104-115 nro arquivamento */   
     "1.1.02.01.001" format "x(28)"                  /* 116-143 cod.contabil */
     "RECEBIMENTO" format "x(250)"    /* 144-393  Histórico */ 
     skip
     .
end procedure.

procedure put-emissao.


    run resumo(input opctbval.datref, 
               input "EMISSAO",
               input opctbval.valor,
               input 0).
               
    put unformat
     estab.etbcod format ">>9"           /* 01-16 */
     "C" + string(contrato.clicod,"9999999999") format "x(18)" /* 04-21 */
     "TIT "  format "x(5)"                /* 22-26 */
     " " format "X(5)"                    /* 27-31 */ 
     dec(opctbval.t9) format "999999999999"  /* 32-43 */
     year(opctbval.datref) format "9999"          /* 44-51 */
     month(opctbval.datref) format "99"          
     day(opctbval.datref)   format "99"
     "C  "     format "x(3)"             /* 52-54 */
     opctbval.valor    format "9999999999999.99" /* 55-70 */
     "+"                 format "x(1)"             /* 71 */
     year(opctbval.datref)  format "9999" /* 72-79 */
     month(opctbval.datref) format "99"  
     day(opctbval.datref)   format "99"
     opctbval.valor format "9999999999999.99"  /* 80-95 */
     year(opctbval.datref) format "9999"  /* 96-103 */
     month(opctbval.datref) format "99"  
     day(opctbval.datref) format "99"
     ""   format "x(12)" /* 104-115 nro arquivamento */
     "1.1.02.01.001" format "x(28)"        /* 116-143 cod.contabil */
     "EMISSAO"  format "x(250)"               /* 144-393  Histórico */ 
     skip
     .
end procedure.

procedure put-estorno:

    run resumo(input opctbval.datref, 
               input "ESTORNO", 
               input opctbval.valor,
               input 0).
    
    put unformat
        opctbval.etbcod format ">>9"           /* 01-03 */
        "C" + string(contrato.clicod,"9999999999") format "x(18)" /* 04-21 */
        "EST"  format "x(5)"                /* 22-26 */
        " " format "X(5)"                    /* 27-31 */ 
        dec(opctbval.t9) format "999999999999"  /* 32-43 */
        year(opctbval.datref) format "9999"          /* 44-51 */
        month(opctbval.datref) format "99"          
        day(opctbval.datref)   format "99"
        "A  "     format "x(3)"             /* 52-54 */
        opctbval.valor    format "9999999999999.99" /* 55-70 */
        "+"                 format "x(1)"             /* 71 */
        year(opctbval.datref)  format "9999" /* 72-79 */
        month(opctbval.datref) format "99"  
        day(opctbval.datref)   format "99"
        opctbval.valor format "9999999999999.99"  /* 80-95 */
        year(opctbval.datref) format "9999"  /* 96-103 */
        month(opctbval.datref) format "99"  
        day(opctbval.datref) format "99"
        ""  format "x(12)" /* 104-115 nro arquivamento */
        "1.1.02.01.001" format "x(28)"   /* 116-143 cod.contabil */
        "ESTORNO" format "x(250)"               /* 144-393  Histórico */ 
        skip
        .
end procedure.
procedure put-acrescimo:

    run resumo(input opctbval.datref, 
               input "ACRESCIMO", 
               input opctbval.valor,
               input 0).

    put unformat
        opctbval.etbcod format ">>9"           /* 01-03 */
        "C" + string(contrato.clicod,"9999999999") format "x(18)" /* 04-21 */
        "ACR "  format "x(5)"                /* 22-26 */
        " " format "X(5)"                    /* 27-31 */ 
        dec(opctbval.t9) format "999999999999"  /* 32-43 */
        year(opctbval.datref) format "9999"          /* 44-51 */
        month(opctbval.datref) format "99"          
        day(opctbval.datref)   format "99"
        "A  "     format "x(3)"             /* 52-54 */
        opctbval.valor    format "9999999999999.99" /* 55-70 */
        "+"                 format "x(1)"             /* 71 */
        year(opctbval.datref)  format "9999" /* 72-79 */
        month(opctbval.datref) format "99"  
        day(opctbval.datref)   format "99"
        opctbval.valor format "9999999999999.99"  /* 80-95 */
        year(opctbval.datref) format "9999"  /* 96-103 */
        month(opctbval.datref) format "99"  
        day(opctbval.datref) format "99"
        ""  format "x(12)" /* 104-115 nro arquivamento */
        "1.1.02.01.001" format "x(28)"   /* 116-143 cod.contabil */
        "ACRESCIMO" format "x(250)"               /* 144-393  Histórico */
        skip 
         .
end procedure.
procedure put-devolucao:

    run resumo(input opctbval.datref, 
               input "DEVOLUCAO", 
               input 0,
               input opctbval.valor).
    
    put unformat
     opctbval.etbcod format ">>9"           /* 01-03 */
     "C" + string(contrato.clicod,"9999999999") format "x(18)" /* 04-21 */
     "TIT "  format "x(5)"                /* 22-26 */
     " " format "X(5)"                    /* 27-31 */ 
     dec(opctbval.t9) format "999999999999"  /* 32-43 */
     year(opctbval.datref) format "9999"          /* 44-51 */
     month(opctbval.datref) format "99"          
     day(opctbval.datref)   format "99"
     "C  "     format "x(3)"             /* 52-54 */
     opctbval.valor    format "9999999999999.99" /* 55-70 */
     "-"                 format "x(1)"             /* 71 */
     year(opctbval.datref)  format "9999" /* 72-79 */
     month(opctbval.datref) format "99"  
     day(opctbval.datref)   format "99"
     opctbval.valor format "9999999999999.99"  /* 80-95 */
     year(opctbval.datref) format "9999"  /* 96-103 */
     month(opctbval.datref) format "99"  
     day(opctbval.datref) format "99"
     ""   format "x(12)" /* 104-115 nro arquivamento */
     "1.1.02.01.001" format "x(28)"        /* 116-143 cod.contabil */
     "DEVOLUCAO" format "x(250)"               /* 144-393  Histórico */ 
     skip
     .
end procedure.

procedure put-recebimento:
    
    run resumo(input opctbval.datref, 
               input "RECEBIMENTO",  
               input 0,
               input opctbval.valor).

    put unformat skip
     opctbval.etbcod format ">>9"           /* 01-03 */
     "C" + string(contrato.clicod,"9999999999") format "x(18)" /* 04-21 */
     "TIT "  format "x(5)"                /* 22-26 */
     " " format "X(5)"                    /* 27-31 */ 
     dec(opctbval.t9) format "999999999999"  /* 32-43 */
     year(opctbval.datref) format "9999"          /* 44-51 */
     month(opctbval.datref) format "99"          
     day(opctbval.datref)   format "99"
     "R  "     format "x(3)"             /* 52-54 */
     opctbval.valor        format "9999999999999.99" /* 55-70 */
     "-"                 format "x(1)"             /* 71 */
     year(opctbval.datref)  format "9999" /* 72-79 */
     month(opctbval.datref) format "99"  
     day(opctbval.datref)   format "99"
     opctbval.valor format "9999999999999.99"  /* 80-95 */
     year(opctbval.datref) format "9999"  /* 96-103 */
     month(opctbval.datref) format "99"  
     day(opctbval.datref) format "99"
     " "   format "x(12)" /* 104-115 nro arquivamento */   
     "1.1.02.01.001" format "x(28)"                  /* 116-143 cod.contabil */
     "RECEBIMENTO" format "x(250)"    /* 144-393  Histórico */ 
     skip
     .
end procedure.

procedure resumo:
    
    def input parameter p-data as date.
    def input parameter p-tipo as char.
    def input parameter p-debito as dec.
    def input parameter p-credito as dec.

    find first tt-resumo where
               tt-resumo.data = p-data and
               tt-resumo.tipo = p-tipo  no-error.
    if not avail tt-resumo
    then do:
        create tt-resumo.
        tt-resumo.data = p-data.
        tt-resumo.tipo = p-tipo.
    end.
    assign
        tt-resumo.debito = tt-resumo.debito + p-debito
        tt-resumo.credito = tt-resumo.credito + p-credito.        
end procedure.

procedure message-reg:
    def input parameter p-tipo as char format "x(20)".
    vreg = vreg + 1.
    if vreg mod 1000 = 0
    then do:
        disp stream sdisp  "Aguarde processamento " p-tipo no-label 
        vreg no-label
                "registros processados"
                with frame f-disp1 1 down no-box color message row 15
                 width 80 .
                pause 0.      
       end. 
end.            
