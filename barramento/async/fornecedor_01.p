DEFINE INPUT  PARAMETER lcJsonEntrada      AS LONGCHAR.
def    output param     verro as char no-undo.
verro = "".

DEFINE var lcJsonsaida      AS LONGCHAR.

{/admcom/barramento/functions.i}
{/admcom/barramento/async/fornecedor_01.i}

/* LE ENTRADA */
lokJSON = hfornecedorEntrada:READ-JSON("longchar",lcJsonEntrada, "EMPTY").

/**def var vsaida as char.
find first ttfornecedor.        
vsaida = "./json/fornecedor/" + string(recid(ttfornecedor)) + "_" 
                           + trim(ttfornecedor.codigo)  + "_"
                           + "fornecedor.json".
**hfornecedorEntrada:WRITE-JSON("FILE",vsaida, true).
**/



for each ttfornecedor.

    /*
    field inscricaoMunicipal as char
    */
    
    find forne where forne.fornom = ttfornecedor.razaoSocial no-lock no-error.
    if avail forne
    then do:
        if forne.forcod <> int(ttfornecedor.codigo)
        then do: 
            ttfornecedor.razaoSocial = ttfornecedor.razaoSocial + " - " + ttfornecedor.codigo.
            find forne where forne.fornom = ttfornecedor.razaoSocial no-lock no-error.
            if avail forne
            then do:
                if forne.forcod <> int(ttfornecedor.codigo)
                then do: 
                    verro = "FORNECEDOR EXISTENTE COM OUTRO CODIGO " + string(forne.forcod).
                    return.
                end.
            end.                
        end.
    end.        
                                     

    
    find forne where forne.forcod = int(ttfornecedor.codigo) exclusive no-wait no-error.
    if not avail forne
    then do:
        if locked forne
        then do:
            verro = "LOCADO".
            return.
        end.
        create forne.
        forne.livcod = ?.
        forne.forcod = int(ttfornecedor.codigo).
    end.
    forne.fornom    = ttfornecedor.razaoSocial.
    forne.forfant   = ttfornecedor.nomeFantasia.
    
    forne.fordtcad  = aaaa-mm-dd_todate(ttfornecedor.dataCadastro).
    forne.forinest  = ttfornecedor.inscricaoEstadual. 
    forne.forpai    = int(ttfornecedor.codigoPai).
    forne.forcgc    = ttfornecedor.cnpj.
    forne.ativo     = true_tolog(ttfornecedor.ativo).
    forne.fornacionalidade = ttfornecedor.origem.

    find first ttendereco no-error.
    if avail ttendereco
    then do:
        /*
        field pontoReferencia as char
        field codIbgeCidade as char
        */
        
        forne.forrua = ttendereco.rua.
        forne.fornum = int(ttendereco.numero).
        forne.forcomp = ttendereco.complemento.
        forne.forbairro =  ttendereco.bairro.
        forne.formunic = ttendereco.cidade.
        forne.ufecod = ttendereco.uf.
        forne.forpais =  ttendereco.pais.   
        forne.forcep = ttendereco.cep.
    end.  
    find first ttcontato  no-error.
    if avail ttcontato
    then do:
        forne.email = ttcontato.email.
        find first tttelefones  no-error.
        if avail tttelefones
        then do:
            forne.forfone = tttelefones.numero.            
        end.
    end.

    if forne.forpai = 0
    then do:
        find fabri where fabri.fabcod = forne.forcod exclusive no-wait no-error.
        if not avail fabri
        then do:
            if not locked fabri
            then do:
                create fabri.
                assign 
                    fabri.fabcod = forne.forcod
                    fabri.fabnom = forne.fornom
                    fabri.fabfant = forne.fornom
                    .
            end.    
        end.   
        else assign 
                 fabri.fabnom = forne.fornom 
                 fabri.fabfant = forne.fornom
                 forne.repcod = fabri.repcod.
    end.

end.    


