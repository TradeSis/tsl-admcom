/* helio 07062023 Desconto de funcionário no Lebes Bag. */
def new global shared var spid as int.
def new global shared var spidseq as int.

def {1} shared temp-table ttbaglistagem no-undo serialize-name "bag"
    field estabOrigem    as int
    field cpf       as dec format "99999999999" decimals 0
    field nome      as char
    field idbag     as int    format ">>>9"
    field consultor   as int
    field catcod    as int    
    field pid    as int
    field dtalt     as date
    field hralt     as int
    field dtfec     as date
    field datacriacao   as char
    field datasaida as char
    index x cpf asc.

def {1} shared temp-table ttbag no-undo serialize-name "bag"
    field estabOrigem as int
    field idbag       as int format ">>>9"
    field cpf       as dec format "99999999999" decimals 0
    field consultor   as int
    field categoria     as int
    field pid           as int
    field nome      as char
    field dtfec     as date
    field datacriacao   as char
    field datasaida as char.

def {1} shared temp-table ttitens no-undo serialize-name "itens"
    field sequencial as int
    field codigoProduto   as int
    field descricao     as char
    field quantidade    as int
    field valorUnitario as dec
    field descontoProduto as dec
    field valorTotal    as dec
    field mercadologico as char
    field quantidadeConvertida  as int init ?
    field valorTotalConvertida as dec serialize-hidden
    field catcod    as int serialize-hidden.

                                                                           
def temp-table tterro no-undo serialize-name "return"
    field pstatus as char serialize-name "status"
    field retorno  as char.


def {1} shared temp-table ttcliente no-undo serialize-name "cliente"
    field clicod    as int serialize-name "codigoCliente"
    field nome      as char
    field cpf       as dec format "99999999999" decimals 0
    field cep       as char
    field logradouro as char
    field numero as int
    field complemento   as char    
    field bairro as char
    field cidade as char
    field estado as char
    field email as char
    field celular as char.


