{gerxmlnfe.i}   

def var p-valor as char.
def var arq_retorno as char.
def var arq_erro as char.
def var arq_temp as char.
def var arq_envio as char.

def var vmetodo as char.
def var vretorno as char.

def var vtime   as int.

def temp-table tt-retorno
    field varq as char.
def temp-table tt-erro
    field varq as char.
def temp-table tt-temp
    field varq as char.
def temp-table tt-envio
    field varq as char.

def stream str-log.    
    
FUNCTION pega_xml returns character
    (input par-oque as char,
     input par-onde as char).
         
    def var vx as int.
    def var vret as char.  
    
    vret = ?.  
    
    do vx = 1 to num-entries(par-onde,"<"). 
        if entry(1,entry(vx,par-onde,"<"),">") = par-oque 
        then do: 
            vret = entry(2,entry(vx,par-onde,"<"),">"). 
            leave. 
        end. 
    end.
    return vret. 
END FUNCTION.
def var v-tpamb as int format "9" init 2. 

def buffer bA01_infnfe for A01_infnfe.

def var varquivo as char format "x(70)".
def var varqsai as char format "x(70)".
def var varqlog as char format "x(70)".
def var varq as char format "x(70)".
varqlog = "/admcom/nfe/erp/arq.log".
def var vret as char format "x(14)".
def var v-cstat as char.
def var v-chnfe as char.
def var v-xmotivo as char.

def temp-table tt-infnfe like A01_infnfe
    field rec-id as recid
    field rowid as rowid.
/*
output to value("/admcom/logs/proc-nfe-cron.sh.log") append.
*/

/*
if time < 39600
then do:
    
    assign vtime = 39600 - time.
        
    message string(today,"99/99/9999")
            " - "
            string(time,"HH:MM:SS")
            " Start da CRON aguardando para iniciar as 11:00h, intervalo : "
            string(vtime,"HH:MM:SS").
        
    pause vtime no-message.

end.
*/

repeat:
    

    release A01_infnfe.
    
    /*****
    ***** New Free emite notas pelo LINX   *****
    if search("/admcom/progr/predevcmp_nfe.p") <> ?
    then run predevcmp_nfe.p .
    ****/
    
    for each tt-infnfe: delete tt-infnfe. end.
    
    for each A01_infnfe where A01_infnfe.solicitacao <> ""
                        /*and A01_infnfe.etbcod = 200*/   no-lock,
                        
        first B01_IdeNFe of A01_infnfe
                    where B01_IdeNFe.demi >= today - 30 no-lock:

        /*
        if A01_infnfe.etbcod < 200 and
           A01_infnfe.etbcod <> 22
        then next.
        */
                                                 /*
        if a01_infnfe.aguardando matches ("*Erro parser*")
        then next.
                                                   */
                                                   
        find first tab_log where tab_log.etbcod = A01_InfNFe.etbcod and
                                 tab_log.nome_campo = "NFe-Solicitacao" and
                                 tab_log.valor_campo = A01_InfNFe.chave
                                      no-lock no-error.
        if avail tab_log
            and tab_log.dtinclu = today
            and tab_log.hrinclu >= time - 600
        then do:
        
            message "A NF: " A01_InfNFe.numero " esta aguardando autorizacao!"
              " Aguarde alguns minutos e verifique se"
              "realmente é necessário reenvia-la. "
                            view-as alert-box.
                            
            next.
            
        end.
                                                   
        create tt-infnfe.
        buffer-copy A01_infnfe to tt-infnfe.
        assign tt-infnfe.rowid = rowid(A01_infnfe). 

        
        message A01_infnfe.etbcod
                A01_infnfe.numero
                A01_infnfe.situacao
                A01_infnfe.solicitacao.      
        
    end.
    
    message "TT-Criada.".
    
    
    for each a01_infnfe where a01_infnfe.situacao = "autorizada"
                          and length(a01_infnfe.id) <> 44 no-lock,
                          
        first B01_IdeNFe of A01_infnfe
                   where B01_IdeNFe.demi >= today - 60 no-lock:

        /*
        if A01_infnfe.etbcod < 200 and
        A01_infnfe.etbcod <> 22
        then next.
        */
        
        find first tt-infnfe where tt-infnfe.chave = a01_infnfe.chave
                            no-lock no-error.

        if not avail tt-infnfe
        then do:

            create tt-infnfe.
            buffer-copy A01_infnfe to tt-infnfe.
            assign tt-infnfe.rowid = rowid(A01_infnfe). 
            
        end.    
                              
    end.
    
    message "Iniciando Consultas.".
        
    for each tt-infnfe:
    
        p-valor = "".
        run /admcom/progr/le_tabini.p (tt-infnfe.emite, 0,
                    "NFE - DIRETORIO ENVIO ARQUIVO", OUTPUT p-valor) .
        arq_envio = p-valor.

        p-valor = "".
        run /admcom/progr/le_tabini.p (tt-infnfe.emite, 0,
                    "NFE - DIRETORIO RETORNO ARQUIV", OUTPUT p-valor) .
        arq_retorno = p-valor.

        p-valor = "".
        run /admcom/progr/le_tabini.p (tt-infnfe.emite, 0,
                    "NFE - DIRETORIO ERRO ARQUIVO", OUTPUT p-valor) .
        arq_erro = p-valor.

        p-valor = "".
        run /admcom/progr/le_tabini.p (tt-infnfe.emite, 0,
                    "NFE - DIRETORIO TEMP ARQUIV", OUTPUT p-valor) .
        arq_temp = p-valor.

        p-valor = "".
        run /admcom/progr/le_tabini.p (tt-infnfe.emite, 0,
                    "NFE - AMBIENTE", OUTPUT p-valor) .
        
        if p-valor = "PRODUCAO"
        then v-tpamb = 1.
        else v-tpamb = 2.
        
        /*
        message "Rodando... Hora: " string(time,"HH:MM")
                " Nota: " tt-infnfe.numero.
        */
        
        pause 5 no-message.
        
        assign
            varquivo = "" 
            varqsai = "".
        /*
        message tt-infnfe.solicitacao. pause.
        */
    
        /**************** Laureano  *******************/
        
        /*Consulta as notas que foram enviadas para solicitar autorização */
        
        if tt-infnfe.solicitacao = "Autorizacao" 
            or tt-infnfe.solicitacao = "Inutilizacao"
            or tt-infnfe.solicitacao = "Consulta"
            or tt-infnfe.solicitacao = "Cancelamento"
            or tt-infnfe.solicitacao = "Emvio" 
            or tt-infnfe.solicitacao = "Envio"
        then do:

            message "Consultando... " tt-infnfe.etbcod " - " tt-infnfe.numero.
        
            find bA01_infnfe where rowid(bA01_infnfe) = tt-infnfe.rowid
                                no-lock no-error.
                                
            find B01_IdeNFe of bA01_infnfe no-lock.

            find C01_Emit of bA01_infnfe no-lock.
            
            assign vmetodo = "ConsultarNfe".

            assign varquivo = arq_envio + vmetodo + "_"
                                  + string(tt-infnfe.numero) + "_"
                                  + string(time,"HH:MM").

            assign varquivo = replace(varquivo,":","").

            output to value(varquivo).
        
            geraXmlNfe(yes,
                       "cnpj_emitente",
                       C01_Emit.cnpj,
                       no). 
                       
            geraXmlNfe(no,
                       "numero_nota",
                       string(tt-infnfe.numero),
                       no).
                       
            geraXmlNfe(no,
                       "serie_nota",
                       string(B01_IdeNFe.serie),
                       yes).
                       
            output close.
    
            run chama-ws.p(input tt-infnfe.emite,
                           input tt-infnfe.numero,
                           input "NotaMax",
                           input vmetodo,
                           input varquivo,
                           output vretorno).

            assign p-valor = "".
            run /admcom/progr/le_xml_cron.p(input vretorno,
                                       input "chave_nfe",
                                       output p-valor).
                                           
            if tt-infnfe.id <> p-valor
            then do:
                                           
                run p-grava-chave-nfe-sefaz(input tt-infnfe.rowid,
                                      input p-valor).
                                           
            end.
            
            run p-trata-retorno (input tt-infnfe.rowid,
                                 input vretorno).

            run ultimo-evento.
            
        end.
    
    end.

    pause 1 no-message.
    do transaction:
    find first tab_log where tab_log.etbcod = 0 and
                        tab_log.nome_campo = "NFe" and
                        tab_log.valor_campo = "polling" and
                        tab_log.dtinclu = today
                        exclusive no-wait no-error.
    if not avail tab_log
    then do :
        if not locked tab_log
        then do:
            create tab_log.
            assign
                tab_log.nome_campo = "NFe"
                tab_log.valor_campo = "polling"
                tab_log.dtinclu = today
            .
        end.
    end.
    if avail tab_log
    then tab_log.hrinclu = time.
    end.
      
    if time >= 39600 and time <= 68400
    then do:
        
        message string(today,"99/99/9999")
                " - "
                string(time,"HH:MM:SS")
                " Final de ciclo de consultas, Intervalo de: "
                string(7200,"HH:MM:SS").
        
        pause 7200 no-message. /* Intervalo de 2hs entre 11:00 e 19:00 */
        
    end.    
    else if time > 68400 and time < 84600
    then do: 
        
        assign vtime = 84600 - time.
        
        message string(today,"99/99/9999")
                " - "
                string(time,"HH:MM:SS")
                " Final de ciclo de consultas, Intervalo de: "
                string(vtime,"HH:MM:SS").
        
        pause vtime no-message.

    end.
    else if time > 84600 and time <= 86400 
    then do:
    
        assign vtime = (86400 - time) + 39600.  
        
        message string(today,"99/99/9999")
                " - "
                string(time,"HH:MM:SS")
                " Final de ciclo de consultas, Intervalo de: "
                string(vtime,"HH:MM:SS").
        
        pause vtime no-message.
    
    end.
    else if time < 39600
    then do:
    
        assign vtime = 39600 - time.
        
        message string(today,"99/99/9999")
                " - "
                string(time,"HH:MM:SS")
                " Final de ciclo de consultas, Intervalo de: "
                string(vtime,"HH:MM:SS").
        
        pause vtime no-message.

    end.

end.
 
procedure ultimo-evento:
    find first tab_log where tab_log.etbcod = tt-InfNFe.etbcod and
                        tab_log.nome_campo = "NFe-UltimoEvento" and
                        tab_log.valor_campo = tt-InfNFe.chave
                         no-error.
                if not avail tab_log
                then do:
                    create tab_log.
                    assign
                        tab_log.etbcod = tt-InfNFe.etbcod
                        tab_log.nome_campo = "NFe-UltimoEvento"
                        tab_log.valor_campo = tt-InfNFe.chave
                        .
                end.
                assign
                    tab_log.dtinclu = today
                    tab_log.hrinclu = time.
 
end procedure.


procedure p-grava-chave-nfe-sefaz:

    def input parameter par-rowid as rowid.
    def input parameter par-chave as char.
    
    def buffer bA01_infnfe for A01_infnfe.

    find bA01_infnfe where rowid(bA01_infnfe) = par-rowid
                                 exclusive-lock no-error.
                                 
    if avail bA01_infnfe
    then assign bA01_infnfe.id = par-chave.

end procedure.

procedure p-trata-retorno:

    def input parameter par-rowid       as rowid.
    def input parameter par-arq-retorno as char.
    
    def buffer bA01_infnfe for A01_infnfe.

    assign p-valor = "".
    run /admcom/progr/le_xml_cron.p(input par-arq-retorno,
                               input "status_nfe_notamax",
                               output p-valor).
          
    find last bA01_infnfe where rowid(bA01_infnfe) = par-rowid
                    exclusive-lock no-error.
   
    case p-valor:
    
    when "7" then do:

        if avail bA01_infnfe
            and bA01_infnfe.situacao <> "Autorizada"
            and v-tpamb = 1
        then do:
        
            run /admcom/progr/alt_mov_nfe.p(input "Cria",
                                            input rowid(bA01_infnfe)).
        
        end.
                                        
        if avail bA01_infnfe
        then assign bA01_infnfe.sitnfe = integer(p-valor)  
                    bA01_infnfe.situacao = "Autorizada"
                    bA01_infnfe.solicitacao = "".
    
    end.
    
    when "8" then do:
        
        if avail bA01_infnfe
        then assign bA01_infnfe.sitnfe = integer(p-valor)  
                    bA01_infnfe.situacao = ""
                    bA01_infnfe.solicitacao = "Autorizacao"
                    bA01_infnfe.aguardando = "Intervenção-Rejeição SEFAZ".
    
    end.
    when "9" then do:
        if avail bA01_infnfe
        then assign bA01_infnfe.sitnfe = integer(p-valor)  
                    bA01_infnfe.situacao = "Denegada"
                    bA01_infnfe.solicitacao = "".

        
    end.
    when "12" then do:
        
        if avail bA01_infnfe
        then assign bA01_infnfe.sitnfe = integer(p-valor)  
                    bA01_infnfe.situacao = "Inutilizada"
                    bA01_infnfe.solicitacao = "".
    
    end.
    

    when "14" then do:
    
        if avail bA01_infnfe
        then assign bA01_infnfe.sitnfe = integer(p-valor)
                    bA01_infnfe.situacao = "Cancelada"
                    bA01_infnfe.solicitacao = "".

        if v-tpamb = 1
        then run /admcom/progr/alt_mov_nfe.p(input "Cancela",
                                        input rowid(bA01_infnfe)).

    end.
    
    when " " then do:
        assign p-valor = "".
        run /admcom/progr/le_xml_cron.p(input par-arq-retorno,
                               input "mensagem_erro",
                               output p-valor).
         if p-valor <> ""
         then do :
            find B01_IdeNFe of bA01_infnfe.
            B01_IdeNFe.temite = p-valor.
         end.
    end.
    
    end case.
    
end procedure.



