DEFINE INPUT  PARAMETER lcJsonEntrada      AS LONGCHAR.
def    output param     verro as char no-undo.
verro = "".

DEFINE var lcJsonsaida      AS LONGCHAR.


{/admcom/barramento/async/estabelecimento_01.i}

/* LE ENTRADA */
lokJSON = hestabelecimentoEntrada:READ-JSON("longchar",lcJsonEntrada, "EMPTY") no-error.
if not lokJSON
then return.

/**def var vsaida as char.
find first ttestabelecimento.        
vsaida = "./json/estab/" + string(recid(ttestabelecimento)) + "_" 
                           + trim(ttestabelecimento.codigo)  + "_"
                           + "estabelecimento.json".
**hestabelecimentoEntrada:WRITE-JSON("FILE",vsaida, true).
**/


for each ttestabelecimento on error undo , return.

    /*
    field ativo as char 
    field dataCadastro as char
    field razaoSocial as char
    */
    
    find estab where estab.etbcod = int(ttestabelecimento.codigo) exclusive no-wait no-error.
    if not avail estab
    then do:
        if locked estab
        then return.
        create estab.
        estab.etbcod = int(codigo).
    end.

    estab.etbnom = ttestabelecimento.nomefantasia.
    estab.etbcgc = cnpj.
    estab.etbinsc = inscricaoEstadual.
    estab.tamanho = ttestabelecimento.tamanho    .
    estab.regcod  = int(regiao).
    estab.tipoloja = ttestabelecimento.tipo.
    
    for each ttendereco where ttendereco.idpai =  ttestabelecimento.id.
        /*
        field numero as char
        field pontoReferencia as char
        field complemento as char
        field codIbgeCidade as char
        field pais as char
        */
        estab.endereco = ttendereco.rua + "," + ttendereco.numero.
        estab.munic    = ttendereco.cidade.
        estab.ufecod   = ttendereco.uf.

                find tabaux where 
                     tabaux.tabela = "ESTAB-" + string(estab.etbcod,"999") and
                     tabaux.nome_campo = "CEP" no-error.
                if avail tabaux and
                    tabaux.valor_campo <> string(ttendereco.cep)
                then tabaux.valor_campo = string(ttendereco.cep).
                else if not avail tabaux 
                     then do:
                       create tabaux.
                        assign
                            tabaux.tabela  = "ESTAB-" + string(estab.etbcod,"999") 
                            tabaux.nome_campo  = "CEP" 
                            tabaux.valor_campo = ttendereco.cep
                            tabaux.tipo_campo  = "Int"
                            tabaux.datexp  = today
                            tabaux.exporta = yes.
                    end.

                find tabaux where 
                     tabaux.tabela = "ESTAB-" + string(estab.etbcod,"999") and
                     tabaux.nome_campo = "BAIRRO" no-error.
                if avail tabaux and
                    tabaux.valor_campo <> string(ttendereco.bairro)
                then tabaux.valor_campo = string(ttendereco.bairro).
                else if not avail tabaux 
                     then do:
                       create tabaux.
                        assign
                            tabaux.tabela  = "ESTAB-" + string(estab.etbcod,"999") 
                            tabaux.nome_campo  = "BAIRRO" 
                            tabaux.valor_campo = ttendereco.bairro
                            tabaux.tipo_campo  = "Char"
                            tabaux.datexp  = today
                            tabaux.exporta = yes.
                    end.
                    
                
    end.
    for each ttcontato where ttcontato.idpai =  ttestabelecimento.id.
        /*
            field email as char 
        */
        for each tttelefones where tttelefones.idpai =  ttcontato.id.
            /*
                field tipo as char
            */
            estab.etbserie = tttelefones.numero.
        end.
    end.            
    for each expedientes where expedientes.idpai =  ttestabelecimento.id.
        for each ttturnos where ttturnos.idpai =  expedientes.id.
        end.
    end.            

end.    




