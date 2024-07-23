def temp-table ttmnemos
    field mnemo as char format "x(25)"
    field nome   as char format "x(25)"
    index x is unique primary mnemo asc.
    
create ttmnemos.
ttmnemos.mnemo = "~{codigoCliente~}".
ttmnemos.nome  = "Codigo do cliente".

create ttmnemos.
ttmnemos.mnemo = "~{nomeCliente~}".
ttmnemos.nome  = "Nome do cliente".
create ttmnemos.
ttmnemos.mnemo = "~{cpfCnpjCliente~}".
ttmnemos.nome  = "CPF/CNPJdo cliente".
create ttmnemos.
ttmnemos.mnemo = "~{rg~}".
ttmnemos.nome  = "RG do cliente".

create ttmnemos.
ttmnemos.mnemo = "~{endereco.logradouro~}".
ttmnemos.nome  = "Endereco do cliente".
create ttmnemos.
ttmnemos.mnemo = "~{endereco.numero~}".
ttmnemos.nome  = "Numero do Endereco do cliente".
create ttmnemos.
ttmnemos.mnemo = "~{endereco.complemento~}".
ttmnemos.nome  = "Complemento do Endereco do cliente".
create ttmnemos.
ttmnemos.mnemo = "~{endereco.bairro~}".
ttmnemos.nome  = "Bairro do Endereco do cliente".
create ttmnemos.
ttmnemos.mnemo = "~{endereco.cidade~}".
ttmnemos.nome  = "Cidade do Endereco do cliente".
create ttmnemos.
ttmnemos.mnemo = "~{endereco.estado~}".
ttmnemos.nome  = "Estado do Endereco do cliente".
create ttmnemos.
ttmnemos.mnemo = "~{endereco.cep~}".
ttmnemos.nome  = "Endereco do cliente".
create ttmnemos.
ttmnemos.mnemo = "~{email~}".
ttmnemos.nome  = "Email do cliente".
create ttmnemos.
ttmnemos.mnemo = "~{telefone~}".
ttmnemos.nome  = "Telefone do cliente".


create ttmnemos.
ttmnemos.mnemo = "~{numeroContrato~}".
ttmnemos.nome  = "Numero do Contrato".
create ttmnemos.
ttmnemos.mnemo = "~{codigoLoja~}".
ttmnemos.nome  = "Filial do Contrato".

create ttmnemos.
ttmnemos.mnemo = "~{dataTransacao~}".
ttmnemos.nome  = "Data de Emissao do Contrato".
create ttmnemos.
ttmnemos.mnemo = "~{codigoVendedor~}".
ttmnemos.nome  = "Vendedor do Contrato".
create ttmnemos.
ttmnemos.mnemo = "~{numeroNotaFiscal~}".
ttmnemos.nome  = "Numero da NF do Contrato".
create ttmnemos.
ttmnemos.mnemo  = "~{numeroComponente~}".
ttmnemos.nome   = "Caixa da Emissao do Contrato".
create ttmnemos.
ttmnemos.mnemo  = "~{valorTotal~}".
ttmnemos.nome   = "valor total do contrato".
create ttmnemos.
ttmnemos.mnemo  = "~{valorEntrada~}".
ttmnemos.nome   = "valor da entrada do contrato".

create ttmnemos.
ttmnemos.mnemo  = "~{principal~}".
ttmnemos.nome   = "valor do principal do contrato".

create ttmnemos.
ttmnemos.mnemo  = "~{valorAcrescimo~}".
ttmnemos.nome   = "valor do acrescimo do contrato".


create ttmnemos.
ttmnemos.mnemo  = "~{valorIof~}".
ttmnemos.nome   = "valor IOF do contrato".

create ttmnemos.
ttmnemos.mnemo  = "~{iof.perc~}".
ttmnemos.nome   = "percentual IOF do contrato".

create ttmnemos.
ttmnemos.mnemo  = "~{cet~}".
ttmnemos.nome   = "CET do contrato".

create ttmnemos.
ttmnemos.mnemo  = "~{cetAno~}".
ttmnemos.nome   = "CET Anual do contrato".

create ttmnemos.
ttmnemos.mnemo  = "~{taxaMes~}".
ttmnemos.nome   = "Taxa de Juros do contrato".

create ttmnemos.
ttmnemos.mnemo  = "~{parcelas.lista}~}".
ttmnemos.nome   = "Listagem das parcelas do Contrato ".


create ttmnemos.
ttmnemos.mnemo  = "~{qtdParcelas}~}".
ttmnemos.nome   = "Qtd de parcelas do Contrato ".

create ttmnemos.
ttmnemos.mnemo  = "~{parcelas.valor}~}".
ttmnemos.nome   = "Valor das parcelas do Contrato ".


create ttmnemos.
ttmnemos.mnemo  = "~{dataPrimeiroVencimento~}".
ttmnemos.nome   = "Primeiro vencimento do Contrato ".

create ttmnemos.
ttmnemos.mnemo  = "~{dataUltimoVencimento~}".
ttmnemos.nome   = "Ultimo vencimento do Contrato ".


create ttmnemos.
ttmnemos.mnemo  = "~{produtos.lista}~}".
ttmnemos.nome   = "Listagem dos produtos do Contrato ".



create ttmnemos.
ttmnemos.mnemo = "~{numeroBilheteSeguroPrestamista~}".
ttmnemos.nome  = "Numero Bilhete Seguro Prestamista".


