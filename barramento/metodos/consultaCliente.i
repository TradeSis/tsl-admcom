DEFINE VARIABLE lokJSON                  AS LOGICAL.
def var hclienteEntrada     as handle.
def var hclienteSaida            as handle.
/* ENTRADA */
DEFINE TEMP-TABLE ttclienteEntrada NO-UNDO SERIALIZE-NAME "clienteEntrada"
    FIELD codigo_cpfcnpj as char
    index x is unique primary codigo_cpfcnpj asc.
    
DEFINE DATASET conteudoEntrada FOR ttclienteEntrada.
hclienteEntrada = DATASET conteudoEntrada:HANDLE.

/* SAIDA */
DEFINE TEMP-TABLE ttstatus NO-UNDO serialize-name 'clienteSaida'
    FIELD codigo_cpfcnpj as char     serialize-hidden  
    field situacao   as char  serialize-name 'status'
    index cli is unique primary codigo_cpfcnpj asc.

DEFINE TEMP-TABLE ttclien NO-UNDO       serialize-name 'Cliente'
    field codigoCpfcnpj as char serialize-hidden
    field nomeCliente   as char
    field codigo_cliente as char
    field cpf_cnpj       as char
    field celular       as char
    field telefone_profissional as char
    field tipo as char
    field rua as char
    field bairro as char
    field cidade as char
    field estado as char
    field numero as char
    field cep as char
    field email as char
    index cli is unique primary codigoCpfcnpj asc.

DEFINE DATASET conteudoSaida FOR ttstatus, ttclien
  DATA-RELATION sitcli FOR ttstatus, ttclien 
        RELATION-FIELDS(ttstatus.codigo_cpfcnpj,ttclien.codigocpfcnpj) NESTED.

    
hclienteSaida = DATASET conteudoSaida:HANDLE.

