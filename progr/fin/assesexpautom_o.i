ttstream.aberta  = yes.
ttstream.arquivo = "/admcom/import/cdlpoa/" + ttasses.assessoria +  
            "-G1-EMI-" + string(asses_param.dtiniultproc,"99999999") + replace(string(asses_param.hriniultproc,"HH:MM:SS"),":","") + ".csv".
            
output {1} to value(ttstream.arquivo).
put {1} unformatted
    "cpf;tipocliente;codigocliente;nome;datanasc;pai;mae;email;rg;"
    "estadocivil;;conjuge;endereco;numero;compl;bairro;cep;cidade;estado;celular;telfixo;tel aux1"     ";telaux2;telaux3;telaux4;telaux5;contrato;modalidade;numparcela;dividaoriginal;"
    "dividaatualizada;datavencimento;situacao;datapagamento;;;;juros;empresa;" 
    "convenio;" 
    /* novos campos */
    "emissao;"
    "segmento produto;" 
    "filial contrato;"
    "renda presumida;"
    "parcelas pagas;"
    "qtd contratos abertos;"
    "FPD;"
    "tempo cadastro;"
    
    /* novos campos */
    "escolaridade;"
    "profissao;"
    "limite cliente;"
    "categoria profissional;"
    "tipo de residencia;"
    "possui veiculo;"
    "carteira;"
    skip.
