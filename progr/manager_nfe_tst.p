{admcab.i}

def var v-idamb as int format "9".

{gerxmlnfe.i}.

def input  parameter par-operacao       as char.
def input  parameter p-recid            as recid.
def output parameter v-ok               as log.
def var              vrec-nota          as recid.
def var varquivo                       as char.
def var vmsg-retorno             as char.

def var vcont    as integer.

def var vchave-aux  as char.

def var arq_envio as char.
def var vmetodo as char.

def stream str-log.

def var varq-log  as char.

def var mail-dest as char.
def var opc-dest as char.
def var mail-tran as char.
def var opc-tran as char initial "".
def var vretorno as char.
def var p-valor as char.
def var vnotamax as log.
def var vnum-erro as integer.

def shared temp-table tt-plani    like plani.
def shared temp-table tt-movim    like movim.

if par-operacao <> "envio"
then run nfe_monta_nfe.p.


find first tt-plani no-lock no-error.

if avail tt-plani and tt-plani.etbcod = 200
then do:

    message "A Filial 200 somente pode emitir NFE pelo Sistema Ábacos!"            "Impossível Continuar."
                        view-as alert-box.

    undo, return.

end.

case par-operacao:
    when "5929"     /*** Nota Acobertada  ***/
    then do:
        run nfe_5929.p(/*p-recid,*/
                       output sresp,
                       output vrec-nota) no-error.
    end.

    when "5102_j"   /*** Venda Pessoa Juridica  ***/ or
    when "5910"     /*** Remessa em Bonificacao ***/
    then do:
        run nfe_5102_j.p(output sresp,
                         output vrec-nota) no-error.
    end.

    when "1202"   /*** DEVOLUCAO DE VENDA  ***/  /*[[]]*/
    then do:
        run nfe_1202.p(output sresp,
                       output vrec-nota) no-error.    
    end.

    when "5949_e"   /*** ESTORNO DE NF OUTRAS ENTRADAS  ***/  /*[[]]*/
    then do:
        run nfe_5949_e.p(output sresp,
                         output vrec-nota) no-error.
    end.

    when "5949_c"   /*** ESTORNO DE NF OUTRAS ENTRADAS  ***/
    then do:
        run nfe_5949_c.p(output sresp,
                         output vrec-nota) no-error.
    end.

    when "1949_e"   /*** ESTORNO DE NF OUTRAS SAIDAS  ***/      /*[[]]*/
    then do:
        run nfe_1949_e.p(output sresp,
                         output vrec-nota) no-error.
    end.

    when "5152"   /*** TRANSFERENCIAS  ***/
    then do:
        run nfe_5152.p(output sresp,
                       output vrec-nota) no-error.
    end.

    when "5949"   /*** OUTRAS SAÍDAS  ***/
    then do:
        run nfe_5949.p(output sresp,
                       output vrec-nota) no-error.
    end.
    
    when "1949_l"   /*** OUTRAS ENTRADAS  ***/
    then do:
        run nfe_1949_l.p(output sresp,
                         output vrec-nota) no-error.
    
    end.

    when "1949_c"   /*** OUTRAS ENTRADAS  ***/
    then do:
        run nfe_1949_c.p(output sresp,
                         output vrec-nota) no-error.
    end.

    when "1915"   /*** RETORNO DE CONSERTO   ***/
    then do:
        run nfe_1915.p(output sresp,
                       output vrec-nota) no-error.
    end.
    
    when "1949"   /*** OUTRAS ENTRADAS   ***/
    then do:
        run nfe_1949.p(output sresp,
                       output vrec-nota) no-error.
    end.

    when "5102"   /*** NF DE VENDA   ***/
    then do:
        run nfe_5102.p(output sresp,
                       output vrec-nota) no-error.
    end.

    when "5202"   /*** DEVOLUCAO DE COMPRAS  ***/
    then do:
        run nfe_5202.p(output sresp,
                       output vrec-nota) no-error.
    end.

    when "5552"   /*** TRANSFERENCIA DE ATIVO IMOBILIZADO  ***/
    then do:
        run nfe_5552.p(output sresp,
                       output vrec-nota) no-error.
    end.
    when "5555"
    then do:
        run nfe_5555.p(output sresp,
                       output vrec-nota) no-error.
    end.
    
    when "5557"   /*** TRANSFERENCIA DE USO E CONSUMO  ***/
    then do:
        run nfe_5557.p(output sresp,
                       output vrec-nota) no-error.
    end.
    
    when "5602"   /*** TRANSFERENCIA DE SALDO CREDOR DE ICMS  ***/
    then do:
        run nfe_5602.p(output sresp,
                       output vrec-nota) no-error.
    end.
    
    when "5901"   /*** REMESSA PARA INDUSTRIALIZAÇÃO ***/
    then do:
        run nfe_5901.p(output sresp,
                       output vrec-nota) no-error.
    end.

    when "5915"   /*** REMESSA PARA CONSERTO ***/
    then do:
        run nfe_5915.p(output sresp,
                       output vrec-nota) no-error.
    end.

    when "os_5915"   /*** REMESSA PARA CONSERTO ***/
    then do:
        run nfe_os_5915.p(output sresp,
                          output vrec-nota) no-error.
    end.
     
    when "os_5152"   /*** TRANSFERENCIA - OS ***/
    then do:
         run nfe_os_5152.p(output sresp,
                           output vrec-nota) no-error.
    end.

    when "5411"   /*** ??? ***/
    then do:
         run nfe_5411.p(output sresp,
                          output vrec-nota) no-error.
                                          
    end.
    when "1603"   /*** ??? ***/
    then do:
         
         run nfe_1603.p(output sresp,
                          output vrec-nota) no-error.
                                          
    end.
    when "5603"   /*** ??? ***/
    then do:
         
         run nfe_5603.p(output sresp,
                          output vrec-nota) no-error.
                                          
    end.
    when "devipi_5202" /*** DEVOLUÇÃO IPI ***/
    then do:
    
         run nfe_devipi_5202.p(output sresp,
                               output vrec-nota) no-error.
    
    end.
    when "devipi_5411" /*** DEVOLUÇÃO IPI ***/
    then do:
    
         run nfe_devipi_5411.p(output sresp,
                               output vrec-nota) no-error.
    
    end.
    when "devipi_1603" /*** DEVOLUÇÃO IPI ***/
    then do:
    
         run nfe_devipi_1603.p(output sresp,
                               output vrec-nota) no-error.
    
    end.

    when "wms_5152" /*** ???? ***/
    then do:
         run nfe_wms_5152.p(output sresp,
                            output vrec-nota) no-error.
    end.

    when "5905" /*** ???? ***/
    then do:
         run nfe_5905.p(output sresp,
                        output vrec-nota) no-error.
    end.
    
    when "devipi_5603" /*** DEVOLUÇÃO IPI ***/
    then do:
         run nfe_devipi_5603.p(output sresp,
                               output vrec-nota) no-error.
    end.
    
    when "5551_j" /*** VENDA ATIVO IMOBILIZADO PESSOAO JURIDICA ***/
    then do:
         run nfe_5551_j.p(output sresp,
                          output vrec-nota) no-error.
    end.
    
    when "995_5152" /***  ***/
    then do:
         run nfe_995_5152.p(output sresp,
                            output vrec-nota) no-error.
    end.
    
    when "envio"
    then do:
         assign vrec-nota = p-recid.    
         /* Nao e necessario acao, apenas deixa passar */
         
    end.
    
end case.    

/**
run /admcom/progr/grava_log_nfe.p (input p-recid) no-error.
**/

find first a01_infnfe where recid(a01_infnfe) = vrec-nota no-lock no-error.

find first E01_Dest of A01_infnfe no-lock no-error.

if avail E01_Dest
then do:

    if E01_Dest.email <> ""
    then do:
    
        assign mail-dest = E01_Dest.email
               opc-dest  = "3" .          
    
    end.
    else do:
    
        find first forne where forne.forcgc = E01_Dest.cnpj no-lock no-error.
    
        if avail forne then
        find first cpforne where cpforne.forcod = forne.forcod
                                    no-lock no-error.

        if avail cpforne and cpforne.char-2 <> ""
        then assign mail-dest = cpforne.char-2
                    opc-dest  = "3" .

    end.

end.

assign varq-log = "/admcom/nfe/logs/log_nfe_" 
                            + string(a01_infnfe.emite)
                            + "_"
                            + string(a01_infnfe.numero)
                            + ".log".
                                                        
output stream str-log to value (varq-log) append.

put stream str-log unformatted
    string(today)
    ";"
    string(time,"HH:MM:SS")
    ";".

put stream str-log unformatted
    a01_infnfe.etbcod
    ";"
    a01_infnfe.emite
    ";"
    a01_infnfe.numero
    ";"
    string(time,"HH:MM:SS")
    ";".
    
find B01_IdeNFe of A01_infnfe no-lock no-error.

v-idamb = 2.
p-valor = "".
run le_tabini.p (A01_infnfe.emite, 0,
            "NFE - AMBIENTE", OUTPUT p-valor) .
            if p-valor = "PRODUCAO"
            THEN v-idamb = 1.
        
run gera_xml_nfe_tst_cl1.p (input recid(A01_infnfe),
                   input v-idamb, 
                   output varquivo).                       

disp skip(1)
    "NFE " a01_infnfe.numero no-label "   GERADA NO SISTEMA!!" skip(1)
    "AGUARDE ENQUANTO A AUTORIZAÇÃO É SOLICITADA!" skip(1)
    "CASO NAO VISUALIZE A MENSAGEM DE AUTORIZAÇÃO DA NFE"
    "ENTRE EM CONTATO COM O SETOR FISCAL/CONTABIL." skip(1)
     with frame f-mens 1 down centered row 7 color message
     overlay title "  A T E N Ç Ã O  !!!" .
pause 0.

message "ENVIANDO SOLICITAÇÃO DE AUTORIZAÇÃO .... AGUARDE!" .
PAUSE 1 no-message.

run chama-wsnfe.p(input A01_InfNFe.emite,
               input A01_InfNFe.numero,
               input "NotaMax",
               input "AutorizarNfe",
               input varquivo, 
               input mail-dest,
               input opc-dest,
               input mail-tran,
               input opc-tran,
               output vretorno).

assign p-valor = "".
run le_xml.p(input vretorno,
             input "status_notamax",
             output p-valor).

assign vnum-erro = integer(p-valor).

if vnum-erro = 0
then vnotamax = yes.

if vnum-erro = 1 /**** Erro no Arquivo ****/
then do:
    
    
    assign p-valor = "".
    run le_xml.p(input vretorno,
                 input "mensagem_erro",
                 output p-valor).
         
    run trata-retorno-nfe.p (input vretorno,
                             input recid(A01_InfNFe),
                             input 9999,
                             input p-valor,
                             input v-idamb,
                             output vmsg-retorno).
                      
    message "NF COM ERRO NO ARQUIVO, VERIFIQUE A SITUAÇÃO DA NFE!"
    view-as alert-box title "ATENÇÃO!".                             
                             
                                /* Manda 9999 para não conflitar com
                                   retorno "1 - Aguardando Geracao da NFE" */
                             
end.
else if vnum-erro = 0 /**** Arquivo Ok, aguardando envio para a receita ****/
then do:
        
    assign vcont = 0.
           vnotamax = no.
           
    repeat on endkey undo:
        
        message "NFE: " A01_InfNFe.numero " enviada, "
                "aguardando retorno da SEFAZ (" vcont ")".
                
        pause 7 no-message .
    
        if vcont > 10
        then do:
            if vnotamax = yes
            then do:
                message COLOR RED/WITH
                      "NFe NUMERO : " A01_INFNFE.NUMERO SKIP
                      "Nota enviada ao NOTAMAX, verifique a situação no Cockpit"
                            VIEW-AS ALERT-BOX.
            end.
            ELSE DO:
                message COLOR RED/WITH
                       "NFe NUMERO : " A01_INFNFE.NUMERO SKIP
                        "Nota não enviada ao NOTAMAX, verifique a situação no "
                        "Cockpit"
                            VIEW-AS ALERT-BOX.
            end.    
            leave.
            
        end.

        p-valor = "".
        run le_tabini.p (A01_infnfe.emite, 0,
                         "NFE - DIRETORIO ENVIO ARQUIVO", OUTPUT p-valor) .
                         arq_envio = p-valor.

        find C01_Emit of A01_infnfe no-lock.
           
        assign vmetodo = "ConsultarNfe".
        assign varquivo = arq_envio + vmetodo + "_"
                                    + string(A01_infnfe.numero) + "_"
                                    + string(time).

        output to value(varquivo).
        
        geraXmlNfe(yes,
                   "cnpj_emitente",
                   C01_Emit.cnpj,
                   no). 
                     
        geraXmlNfe(no,
                   "numero_nota",
                   string(A01_infnfe.numero),
                   no).
                       
        geraXmlNfe(no,
                   "serie_nota",
                   string(B01_IdeNFe.serie),
                   yes).
                       
        output close.
    
        /* Apos esperar, realiza uma consulta ao NotaMax */ 
        run chama-wsnfe.p(input A01_infnfe.emite,
                       input A01_InfNFe.numero,
                       input "NotaMax",
                       input vmetodo,
                       input varquivo,
                       input "",
                       input "",
                       input "",
                       input "",
                      output vretorno).
                      
        assign p-valor = "".
        run le_xml.p(input vretorno,
                     input "status_nfe_notamax",
                     output p-valor).
                               
        assign vnum-erro = integer(p-valor).

        if p-valor = ""
        then do:
        
            assign vcont = vcont + 1.
                        
            next.
        
        end.
        else
        case vnum-erro:
            when 1 or  /**   AGUARDA GERAÇÃO DE NF-E                **/
            when 3 or  /**   AGUARDA ASSINATURA                     **/
            when 5 or  /**   AGUARDA ENVIO PARA RECEITA             **/
            when 6 or  /**   AGUARDA AUTORIZAÇÃO DA SEFAZ           **/
            when 11 or /**   AGUARDANDO HOMOLOGAÇÃO DA INUTILIZAÇÃO **/
            when 13 or /**   AGUARDA CANCELAMENTO                   **/
            when 22    /**   AGUARDANDO DESCARTE                    **/
            then do:
            
                assign vcont = vcont + 1.
            
                next.
            
            end.
            otherwise do:

                run trata-retorno-nfe.p (input vretorno,
                                         input recid(A01_InfNFe),
                                         input vnum-erro,
                                         input p-valor,
                                         input v-idamb,
                                         output vmsg-retorno).
            
                if vnum-erro = 7  /* NFE Autorizada imprime Danfe */
                then do:
                    
                    run p-imprime-danfe (input recid(A01_InfNFe)).
                    
                end.    

                message vmsg-retorno view-as alert-box.

                leave.
            
            end.
        end.
    end.

end.
else do:
    
    run trata-retorno-nfe.p (input vretorno,
                             input recid(A01_InfNFe),
                             input vnum-erro,
                             input p-valor,
                             input v-idamb,
                             output vmsg-retorno).
                             
    message vmsg-retorno view-as alert-box.                         
    
end.    
put stream str-log unformatted
    string(time,"HH:MM:SS")
    ";"
    program-name(1)
    ";"
    program-name(2)
    ";"
    program-name(3)
    ";"
    program-name(4)
    ";"
    program-name(5)
    ";"
    program-name(6)
    ";"                                                      
    skip.
                      

output stream str-log close.

procedure p-imprime-danfe:
            
    def input parameter p-recid as recid.
    
    def buffer a01_infnfe for a01_infnfe.

    def var vchave-aux as char.
                
    find first a01_infnfe where recid(a01_infnfe) = p-recid no-lock no-error.
                
    assign vmetodo = "ConsultarPdfNfe".

    assign vchave-aux = A01_infnfe.id.

    assign varquivo = arq_envio + vmetodo + "_"
                             + string(A01_infnfe.numero) + "_"
                             + string(time).
    output to value(varquivo).
        
    geraXmlNfe(yes,
               "chave_nfe",
               vchave-aux,
               yes). 
                       
    output close.
    
    /* Apos esperar, realiza uma consulta ao NotaMax */ 
    run chama-ws.p(input A01_infnfe.emite,
                   input A01_InfNFe.numero,
                   input "NotaMax",
                   input vmetodo,
                   input varquivo,
                   output vretorno).
            
    run visurel.p(vretorno,"").

end procedure.
          
         
hide frame f-mens.
hide message.
    
    
    
    
