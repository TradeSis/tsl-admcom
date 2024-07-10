/*
    Motor de Credito: julho/2017
    _06 - Melhorias Neurotech Pacote 01
#1 ago/2018 - Novo log
*/
def input parameter p-etbcod    as int.
def input parameter p-cxacod    as int.
def input parameter p-PROPS as char.
def input parameter p-tipoconsulta as char.
def input parameter p-time as int.
def input parameter p-recid-neuclien as recid.
def input-output parameter p-ori-operacao as char.  /* #1 */
def input parameter p-valorcompra as dec.    /* #1 */
def output parameter vvlrlimite as dec.
def output parameter vvctolimite as date.
def output parameter p-neuro-sit as char.
def output parameter p-neuro-mens as char.
def output parameter p-status    as char.
def output parameter p-mensagem_erro as char.

def var par-recid-neuproposta as recid.

def var vvlrlimitecompl as dec.
def var r-status as char.
def var r-mensagem_erro as char.        
def var vclientephp as char.
def var varquivo as char. 

def var p-ret-PROPS as char.
 
/* TEMP DE RETORNO */
def temp-table tt-retorno no-undo
    field PARAMETRO as char format "x(30)"
    field RESPOSTA  as char format "x(40)"
    index par  PARAMETRO asc.
    
def var p-neuro-operacao as char.
 
 
    p-status = "S".
    p-mensagem_erro = "". 

    find neuclien where recid(neuclien) = p-recid-neuclien no-lock
        no-error.  
    if not avail neuclien
    then do:
        p-status  = "E".
        p-mensagem_erro = "Erro no cadastramento Cliente".
        return.
    end.         
    
    /* Cria NeuClienLog */ 
    run log("INI neuro/gravaneuclilog " + neuclien.sit_credito).
    run neuro/gravaneuclilog_v1802.p 
                    (neuclien.cpfcnpj,
                     p-tipoconsulta,
                     p-time, 
                     p-etbcod,
                     p-cxacod,
                     neuclien.sit_credito,
                     p-mensagem_erro). 
    run log("FIM neuro/gravaneuclilog").
    
    /** Cria NeuProposta **/
    run log("INI neuro/gravaneuproposta_v1802").
    run neuro/gravaneuproposta_v1802.p
              (string(neuclien.cpfcnpj), 
               p-tipoconsulta,
               p-props, 
               "" /* #1 */,
               p-etbcod,
               p-cxacod,
               input p-ori-operacao /* #1 */,
               input ?,
               input "",
               input "",
               input 0,
               input 0,
               input ?,
               input p-recid-neuclien,
               input p-valorcompra /* #1 */,
               input-output par-recid-neuproposta,
               output p-status,
               output p-mensagem_erro).
    run log("FIM neuro/gravaneuproposta_v1802").     
 
    if p-status = "E"
    then return.

    if p-PROPS = ? or p-PROPS = "?"
    then do:
        p-status = "E".
        return.
    end.
/**
 ** run neuro/chamaclient_neuro.p (p-props).
**/
    run log("INI WS").
 
    /* CHAMARA CLIENT PHP SOAP */   
    vclientephp = "http://localhost/bsweb/ws/neurotech/client_neuro.php".
    
    /* ARQUIVO DE SAIDA DO RETORNO NEURO */    
    varquivo = "/ws/log/wsretorno.neuro." + 
            string(today,"99999999") +
            string(p-etbcod) +
            string(p-cxacod) +
            string(mtime) + 
            ".neuro_ret".          

    /** GERA ARQUIVO SH */
    output to value(varquivo + ".sh").
    put unformatted "wget \"" + vclientephp + "?" + p-PROPS  +  "\"" +
                 " -O " + varquivo + " -q --timeout=120" .
    output close.

    /* EXECUTA ARQUIVO SH CHAMANDOo NEUROTECH */
    unix silent value("sh " + varquivo + ".sh").

    run log("FIM WS").
    
    /* IMPORTA ARQUIVO RETORNO DO WGET PARA TT-RETORNO */    
    input from value(varquivo) no-echo.
    repeat transaction:
        create tt-retorno.
        import delimiter "=" tt-retorno.
        if tt-retorno.PARAMETRO = "" or
           tt-retorno.parametro = ?
        then delete tt-retorno.
    end.
    input close.

    for each tt-retorno where tt-retorno.PARAMETRO = ? or
                              tt-retorno.PARAMETRO = "" or
                              tt-retorno.RESPOSTA  = "" or
                              tt-retorno.RESPOSTA  = ?.
        if tt-retorno.parametro = "Resultado"
        then next. 
        delete tt-retorno.
    end.    

    /* ELIMITE ARQUIVO SH E RETORNO */
    /**
HML tirei    unix silent value("rm -f " + varquivo + " " + varquivo + ".sh").
    **/

    p-ret-PROPS = "".
    for each tt-retorno.
        p-ret-PROPS = p-ret-PROPS + 
                      (if p-ret-PROPS = ""
                       then "" 
                       else "&") +
                      tt-retorno.PARAMETRO + "=" + tt-retorno.RESPOSTA.
    end.
    
    p-neuro-sit  = "".
    p-neuro-mens = "".
    vvlrlimite  = neuclien.vlrlimite.
    vvctolimite = neuclien.vctolimite.
    vvlrlimitecompl = 0.
    
    find first tt-retorno where tt-retorno.parametro = "Resultado" no-error.
    if avail tt-retorno
    then do:
        p-neuro-sit = if tt-retorno.resposta = "APROVADO" or
                         tt-retorno.resposta = "A"
                      then "A"
                      else  if tt-retorno.resposta = "PENDENTE" or
                               tt-retorno.resposta = "P" 
                            then "P"
                            else "R".
        /* #1 */
        if p-neuro-sit = ""
        then p-neuro-sit = "P".
    end.
    else do:
        p-neuro-sit = "R". 
        p-status    = "P".
        p-mensagem_erro = "".  
    end.    
        
    find first tt-retorno where tt-retorno.parametro = "DsMensagem" no-error.
    if avail tt-retorno
    then do:
        if tt-retorno.resposta <> "OK"
        then do:
            p-neuro-mens = tt-retorno.resposta.
        end.    
    end.

    find first tt-retorno where tt-retorno.parametro = "RET_MOTIVOS" no-error.
    if avail tt-retorno
    then do:
        if tt-retorno.resposta <> ""
        then do:
            p-neuro-mens = p-neuro-mens + 
                        (if p-neuro-mens = ""
                         then ""
                         else "/ ") + tt-retorno.resposta.
        end.    
    end.

    find first tt-retorno where tt-retorno.parametro = "Operacao" no-error.
    if avail tt-retorno
    then do:  
        p-neuro-operacao = tt-retorno.resposta.
        /* #1 */
        if p-ori-operacao = ""
        then p-ori-operacao = p-neuro-operacao.
        /**    
        if p-mensagem_erro = ""
        then p-mensagem_erro = "cdOperacao=" + p-neuro-operacao.
        **/
    end.        
    else do:
        p-status = "E".
        p-mensagem_Erro = "".
        p-neuro-sit = "P".
    end.        
   
    find first tt-retorno where tt-retorno.parametro = "RET_NOVOLIMITE"
             no-error.
    if avail tt-retorno
    then do:
        if tt-retorno.resposta <> ""
        then vvlrlimite = if dec(tt-retorno.resposta) <> 0
                          then dec(tt-retorno.resposta)
                          else neuclien.vlrlimite.
    end.

    find first tt-retorno where tt-retorno.parametro = "RET_LIMITECOMPL"
             no-error.
    if avail tt-retorno
    then do:
        if tt-retorno.resposta <> ""
        then vvlrlimitecompl = if dec(tt-retorno.resposta) <> 0
                               then dec(tt-retorno.resposta)
                               else 0.
    end.
    
    find first tt-retorno where tt-retorno.parametro = "RET_DTLIMITEVAL"
             no-error.
    if avail tt-retorno
    then do:
        if tt-retorno.resposta <> ""
        then vvctolimite = if date(tt-retorno.resposta) <> ?
                           then date(tt-retorno.resposta)
                           else neuclien.vctolimite.
    end.
           
    /** Atualiza NeuProposta **/
    run log("INI neuro/gravaneuproposta_v1802 Sit=" + p-neuro-sit +
            " Id=" + p-ori-operacao).
    run neuro/gravaneuproposta_v1802.p 
              (string(neuclien.cpfcnpj), 
               p-tipoconsulta,
               p-props /* #1 */,
               p-ret-PROPS, 
               p-etbcod,
               p-cxacod,
               input p-ori-operacao /* #1 */,
               input p-neuro-operacao,
               input p-neuro-sit,
               input p-neuro-mens,
               input vvlrlimite,
               input vvlrlimitecompl,
               input vvctolimite,
               input p-recid-neuclien,
               input p-valorcompra /* #1 */,
               input-output par-recid-neuproposta,
               output r-status,
               output r-mensagem_erro).

    run log("FIM neuro/gravaneuproposta_v1802 " + r-status).
               
        /**
        if r-status = "E"
        then do:
            p-status = "E".
            p-mensagem_erro = r-mensagem_erro.
        end.
        **/

    if p-status = "S"
    then do:
        run log("INI neuro/gravaneuclihist").
            run neuro/gravaneuclihist.p 
                (p-recid-neuclien,  
                 p-tipoconsulta,
                 p-etbcod, 
                 neuclien.clicod, 
                 vvctolimite, 
                 vvlrlimite, 
                 vvlrlimitecompl,
                 p-neuro-sit).
        run log("FIM neuro/gravaneuclihist").
    end. 

    /* Atualiza NeuClienLog */
    run log("INI neuro/gravaneuclilog " + p-mensagem_erro).
    run neuro/gravaneuclilog_v1802.p 
                    (neuclien.cpfcnpj,
                     p-tipoconsulta,
                     p-time, 
                     p-etbcod,
                     p-cxacod,
                     p-neuro-sit,
                     p-mensagem_erro + "_" +
                     "OP=" + p-neuro-operacao).
    run log("FIM neuro/gravaneuclilog").

    vvlrlimite = vvlrlimite + vvlrlimitecompl.
    if vvlrlimitecompl <> 0 and (vvctolimite < today or vvctolimite = ?)
    then vvctolimite = today.


procedure log.

    def input parameter par-texto as char.

    def var varquivo as char.

    varquivo = "/ws/log/VerificaCreditoVenda_07_" + 
                        string(today, "99999999") +
                        string(p-etbcod) + 
                        string(p-cxacod) + ".log".

    output to value(varquivo) append.
    put unformatted
        string(time,"HH:MM:SS") " "
        par-texto
        skip.
    output close.

end procedure.


    
