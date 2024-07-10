
def input parameter par-param as char.

def shared temp-table tt-retorno no-undo
    field PARAMETRO as char format "x(30)"
    field RESPOSTA  as char format "x(40)"
    index par PARAMETRO asc.
    
def var vclientephp as char.
def var varquivo as char. 
def var vparam  as char.    
def var vcomando as char.
def var vPOLITICA as char.
  

    /* CHAMARA CLIENT PHP SOAP */   
    vclientephp = "http://localhost/bsweb/ws/neurotech/client_neuro.php".
    
    /* ARQUIVO DE SAIDA DO RETORNO NEURO */    
    varquivo = "/u/bsweb/log/wsretorno.neuro." + string(time) + ".neuro_ret".          

    /** GERA ARQUIVO SH */
    output to value(varquivo + ".sh").
    put unformatted "wget \"" + vclientephp + "?" + par-param  +  "\"" +            
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
        delete tt-retorno.
    end.    

    /* ELIMITE ARQUIVO SH E RETORNO */
/**
    unix silent value("rm -f " + varquivo + " " + varquivo + ".sh").
 **/     

