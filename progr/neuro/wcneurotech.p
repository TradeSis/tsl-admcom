/*
    Motor de Credito: julho/2017
*/
def input parameter p-etbcod    as int.
def input parameter p-cxacod    as int.
def input parameter p-PROPS as char.
def input parameter p-tipoconsulta as char.
def input parameter p-time as int.
def input parameter p-recid-neuclien as recid.
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
    run neuro/gravaneuclilog.p 
                    (neuclien.cpfcnpj,
                     p-tipoconsulta,
                     p-time, 
                     p-etbcod,
                     p-cxacod,
                     neuclien.sit_credito,
                     p-mensagem_erro). 
    
    
    /** Cria NeuProposta **/
    run neuro/gravaneuproposta.p 
              (string(neuclien.cpfcnpj), 
               p-tipoconsulta,
               p-props, 
               p-etbcod,
               p-cxacod,
               p-time, 
               input ?,
               input "",
               input "",
               input 0,
               input 0,
               input ?,
               input p-recid-neuclien,  
               input-output par-recid-neuproposta,
               output p-status,
               output p-mensagem_erro).
     
 
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
 

    /* CHAMARA CLIENT PHP SOAP */   
    vclientephp = "http://localhost/bsweb/ws/neurotech/client_neuro.php".
    
    /* ARQUIVO DE SAIDA DO RETORNO NEURO */    
    varquivo = "/u/bsweb/log/wsretorno.neuro." + 
            string(today,"99999999") +
            string(time) + 
            ".neuro_ret".          

    /** GERA ARQUIVO SH */
    output to value(varquivo + ".sh").
    put unformatted "wget \"" + vclientephp + "?" + p-PROPS  +  "\"" +            
                 " -O " + varquivo + " -q --timeout=120" .
    output close.

    /* EXECUTA ARQUIVO SH CHAMANDOo NEUROTECH */
    unix silent value("sh " + varquivo + ".sh").
    
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
                       else "&")
                       +
                        tt-retorno.PARAMETRO + "=" + tt-retorno.RESPOSTA.
    end.
    
    p-neuro-sit  = "".
    p-neuro-mens = "".
    vvlrlimite = neuclien.vlrlimite.
    vvctolimite = neuclien.vctolimite.
    vvlrlimitecompl = 0.
    
    find first tt-retorno where
            tt-retorno.parametro = "Resultado"
             no-error.
    if avail tt-retorno
    then do:
        p-neuro-sit = if tt-retorno.resposta = "APROVADO" or
                         tt-retorno.resposta = "A"
                      then "A"
                      else  if tt-retorno.resposta = "PENDENTE" or
                               tt-retorno.resposta = "P" 
                            then "P"
                            else "R".
    end.
    else do:
        p-neuro-sit = "R". 
        p-status    = "P".
        p-mensagem_erro = "".  
    end.    
        
    find first tt-retorno where
            tt-retorno.parametro = "DsMensagem"
             no-error.
    if avail tt-retorno
    then do:
        if tt-retorno.resposta <> "OK"
        then do:
            p-neuro-mens = tt-retorno.resposta.
        end.    
    end.

    find first tt-retorno where
            tt-retorno.parametro = "Operacao"
             no-error.
    if avail tt-retorno
    then do:  
        p-neuro-operacao = tt-retorno.resposta.
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
   
    find first tt-retorno where
            tt-retorno.parametro = "RET_NOVOLIMITE"
             no-error.
    if avail tt-retorno
    then do:
        if tt-retorno.resposta <> ""
        then vvlrlimite = if dec(tt-retorno.resposta) <> 0
                          then dec(tt-retorno.resposta)
                          else neuclien.vlrlimite.
    end.

    find first tt-retorno where
            tt-retorno.parametro = "RET_LIMITECOMPL"
             no-error.
    if avail tt-retorno
    then do:
        if tt-retorno.resposta <> ""
        then vvlrlimitecompl = if dec(tt-retorno.resposta) <> 0
                               then dec(tt-retorno.resposta)
                               else 0.
    end.

    
    find first tt-retorno where
            tt-retorno.parametro = "RET_DTLIMITEVAL"
             no-error.
    if avail tt-retorno
    then do:
        if tt-retorno.resposta <> ""
        then vvctolimite = if date(tt-retorno.resposta) <> ?
                               then date(tt-retorno.resposta)
                               else neuclien.vctolimite.
        if vvctolimite = ? and 
           vvlrlimite <> 0
        then vvctolimite = today.
         
    end.

           
    /** Atualiza NeuProposta **/
    run neuro/gravaneuproposta.p 
              (string(neuclien.cpfcnpj), 
               p-tipoconsulta,
               p-ret-PROPS, 
               p-etbcod,
               p-cxacod,
               p-time, 
               input p-neuro-operacao,
               input p-neuro-sit,
               input p-neuro-mens,
               input vvlrlimite,
               input vvlrlimitecompl,
               input vvctolimite,
               input p-recid-neuclien,  
               input-output par-recid-neuproposta,
               output r-status,
               output r-mensagem_erro).
               
        /**
        if r-status = "E"
        then do:
            p-status = "E".
            p-mensagem_erro = r-mensagem_erro.
        end.
        **/

    if p-status = "S"
    then do:
            run neuro/gravaneuclihist.p 
                (p-recid-neuclien,  
                 p-tipoconsulta,
                 p-etbcod, 
                 neuclien.clicod, 
                 vvctolimite, 
                 vvlrlimite, 
                 vvlrlimitecompl,
                 p-neuro-sit).
    end. 

    /* Atualiza NeuClienLog */
    run neuro/gravaneuclilog.p 
                    (neuclien.cpfcnpj,
                     p-tipoconsulta,
                     p-time, 
                     p-etbcod,
                     p-cxacod,
                     p-neuro-sit,
                     p-mensagem_erro + "_" +
                     "OP=" + p-neuro-operacao).

     
    vvlrlimite = vvlrlimite + vvlrlimitecompl.
    if vvlrlimitecompl <> 0
    then vvctolimite = today.
