DEFINE VARIABLE lokJSON                  AS LOGICAL.
def var hclienteEntrada          as handle.
def var hclienteSaida            as handle.

DEFINE TEMP-TABLE ttcliente NO-UNDO SERIALIZE-NAME "cliente"
        field id as char
        field tipoPessoa as char
        field canalOrigem as char
        field codigoSistema as char
        field dataCadastro as char
        field tipoCadastro as char
        field lojaCadastro as char
        field codigoCliente as char
        field razaoSocial as char
        field inscricaoEstadual as char
        field nome as char
        field cpfCnpj as char
        field dataNascimento as char
        field identidade as char
        field orgaoEmissor as char
        field nacionalidade as char
        field estadoCivil as char
        field naturalidade as char
        field sexo as char
        field nomePai as char
        field nomeMae as char
        field codigoMae as char
        field planoSaude as char
        field possuiSeguroVida as char
        field possuiSeguroSaude as char
        field numeroDependente as char
        field observacoes as char
        field documentosApresentados as char
        field bandeirasCartoesCredito as char
        field grauInstrucao as char
        field situacaoGrauInstrucao as char
 index x is unique primary id asc.

DEFINE TEMP-TABLE ttemprego NO-UNDO SERIALIZE-NAME "emprego"
        field id as char
        field idPai as char
        field dataAdmissao as char
        field renda as char
        field categoriaProfissional as char
 index x is unique primary idpai asc id asc.

DEFINE TEMP-TABLE ttempresa NO-UNDO SERIALIZE-NAME "empresa"
        field id as char
        field idPai as char
        field cnpj as char
        field razaoSocial as char
        field nomeFantasia as char
 index x is unique primary idpai asc id asc.

DEFINE TEMP-TABLE tttelefoneEmpresa NO-UNDO SERIALIZE-NAME "telefoneEmpresa"
        field id as char
        field idPai as char
        field numero as char
        field tipo as char
 index x is unique primary idpai asc id asc.
        
DEFINE TEMP-TABLE ttenderecoEmpresa NO-UNDO SERIALIZE-NAME "enderecoEmpresa"
        field id as char
        field idPai as char
        field numero as char
        field rua as char
        field bairro as char
        field pontoReferencia as char
        field complemento as char
        field cep as char
        field cidade as char
        field codIbgeCidade as char
        field uf as char
        field pais as char
 index x is unique primary idpai asc id asc.
        
DEFINE TEMP-TABLE ttprofissao NO-UNDO SERIALIZE-NAME "profissao"
        field id as char
        field idPai as char
        field codigoProfissao as char
        field profissao as char
        field rendaMedia as char
 index x is unique primary idpai asc id asc.

DEFINE TEMP-TABLE ttcontato NO-UNDO SERIALIZE-NAME "contato"
        field id as char
        field idPai as char
        field email as char
        field desejaReceberEmail as char
 index x is unique primary idpai asc id asc.

DEFINE TEMP-TABLE tttelefone NO-UNDO SERIALIZE-NAME "telefone"
        field id as char
        field idPai as char
        field numero as char
        field tipo as char
 index x is unique primary idpai asc id asc.

DEFINE TEMP-TABLE ttendereco NO-UNDO SERIALIZE-NAME "endereco"
        field id as char
        field idPai as char
        field numero as char
        field rua as char
        field bairro as char
        field pontoReferencia as char
        field complemento as char
        field cep as char
        field cidade as char
        field codIbgeCidade as char
        field uf as char
        field pais as char
 index x is unique primary idpai asc id asc.
        
DEFINE TEMP-TABLE ttresidencia NO-UNDO SERIALIZE-NAME "residencia"
        field id as char
        field idPai as char
        field tipoResidencia as char
        field tempoResidencia as char
        field possuiSeguro as char
 index x is unique primary idpai asc id asc.

DEFINE TEMP-TABLE ttveiculo NO-UNDO SERIALIZE-NAME "veiculo"
        field id as char
        field idPai as char
        field possuiVeiculo as char
        field marca as char
        field modelo as char
        field ano as char
        field possuiSeguro as char
 index x is unique primary idpai asc id asc.
        
DEFINE TEMP-TABLE ttreferenciasComerciais NO-UNDO SERIALIZE-NAME "referenciasComerciais"
        field id as char
        field idPai as char
        field referenciasComerciais as char
        field situacaoReferenciasComerciais as char
 index x is unique primary idpai asc id asc.

DEFINE TEMP-TABLE ttreferenciasPessoais NO-UNDO SERIALIZE-NAME "referenciasPessoais"
        field id as char
        field idPai as char
        field nome as char
        field parentesco as char
        field documentosApresentados as char
 index x is unique primary idpai asc id asc.

DEFINE TEMP-TABLE tttelefoneReferencia NO-UNDO SERIALIZE-NAME "telefoneReferencia"
        field id as char
        field idPai as char
        field numero as char
        field tipo as char
 index x is unique primary idpai asc id asc.

DEFINE TEMP-TABLE ttdadosBancarios NO-UNDO SERIALIZE-NAME "dadosBancarios"
        field id as char
        field idPai as char
        field banco as char
        field tipoConta as char
        field anoConta as char
 index x is unique primary idpai asc id asc.

DEFINE TEMP-TABLE ttconjuge NO-UNDO SERIALIZE-NAME "conjuge"
        field id as char
        field idPai as char
        field nome as char
        field cpf as char
        field dataNascimento as char
        field naturalidade as char
        field nomePai as char
        field nomeMae as char
 index x is unique primary idpai asc id asc.

DEFINE TEMP-TABLE tttelefoneConjuge NO-UNDO SERIALIZE-NAME "telefoneConjuge"
        field id as char
        field idPai as char
        field numero as char
        field tipo as cha
 index x is unique primary idpai asc id asc.

DEFINE TEMP-TABLE ttempregoConjuge NO-UNDO SERIALIZE-NAME "empregoConjuge"
        field id as char
        field idPai as char
        field dataAdmissao as char
        field renda as char
        field empresaRazaoSocial as char
        field profissaoCodigo as char
        field profissao as char
 index x is unique primary idpai asc id asc.

DEFINE TEMP-TABLE ttcredito NO-UNDO SERIALIZE-NAME "credito"
        field id as char
        field idPai as char
        field statusCliente as char
        field statusClienteMsg as char
        field limite as char
        field limiteDisponivel as char
        field validadeLimite as char
        field nota as char
 index x is unique primary idpai asc id asc.

DEFINE TEMP-TABLE ttrestricoes NO-UNDO SERIALIZE-NAME "restricoes"
        field id as char
        field idPai as char
        field rStatus as char SERIALIZE-NAME "Status"
        field dataUltmaConsulta as char
        field filialConsulta as char
        field localConsulta as char
        field qtdConsulta as char
        field regAlertas as char
        field regCheque as char
        field regCredito as char
        field regNacional as char
        field cpfConsulta as char
 index x is unique primary idpai asc id asc.
        
DEFINE DATASET clienteEntrada FOR ttcliente, ttemprego, ttempresa, tttelefoneempresa, ttenderecoempresa , ttprofissao,
                ttcontato, tttelefone, ttendereco, ttresidencia, ttveiculo, ttreferenciascomerciais,
                ttreferenciaspessoais, tttelefonereferencia, ttdadosbancarios, ttconjuge,
                tttelefoneconjuge, ttempregoconjuge, ttcredito, ttrestricoes
  DATA-RELATION for1 FOR ttcliente, ttemprego         RELATION-FIELDS(ttcliente.id,ttemprego.idpai) NESTED
   DATA-RELATION for11 FOR ttemprego, ttempresa         RELATION-FIELDS(ttemprego.id,ttempresa.idpai) NESTED
    DATA-RELATION for111 FOR ttempresa, tttelefoneempresa         RELATION-FIELDS(ttempresa.id,tttelefoneempresa.idpai) NESTED
    DATA-RELATION for112 FOR ttempresa, ttenderecoempresa         RELATION-FIELDS(ttempresa.id,ttenderecoempresa.idpai) NESTED
   DATA-RELATION for12 FOR ttemprego, ttprofissao         RELATION-FIELDS(ttemprego.id,ttprofissao.idpai) NESTED
  DATA-RELATION for2 FOR ttcliente, ttcontato         RELATION-FIELDS(ttcliente.id,ttcontato.idpai) NESTED
   DATA-RELATION for21 FOR ttcontato, tttelefone        RELATION-FIELDS(ttcontato.id,tttelefone.idpai) NESTED
   DATA-RELATION for3 FOR ttcliente, ttendereco       RELATION-FIELDS(ttcliente.id,ttendereco.idpai) NESTED
   DATA-RELATION for4 FOR ttcliente, ttresidencia       RELATION-FIELDS(ttcliente.id,ttresidencia.idpai) NESTED
   DATA-RELATION for5 FOR ttcliente, ttveiculo      RELATION-FIELDS(ttcliente.id,ttveiculo.idpai) NESTED
   DATA-RELATION for6 FOR ttcliente, ttreferenciascomerciais      RELATION-FIELDS(ttcliente.id,ttreferenciascomerciais.idpai) NESTED
   DATA-RELATION for7 FOR ttcliente, ttreferenciaspessoais       RELATION-FIELDS(ttcliente.id,ttreferenciaspessoais.idpai) NESTED
   DATA-RELATION for71 FOR ttreferenciaspessoais, tttelefonereferencia     RELATION-FIELDS(ttreferenciaspessoais.id,tttelefonereferencia.idpai) NESTED
   DATA-RELATION for8 FOR ttcliente, ttdadosbancarios       RELATION-FIELDS(ttcliente.id,ttdadosbancarios.idpai) NESTED
   DATA-RELATION for9 FOR ttcliente, ttconjuge       RELATION-FIELDS(ttcliente.id,ttconjuge.idpai) NESTED
   DATA-RELATION for91 FOR ttconjuge, tttelefoneconjuge       RELATION-FIELDS(ttconjuge.id,tttelefoneconjuge.idpai) NESTED
   DATA-RELATION for91 FOR ttconjuge, ttempregoconjuge       RELATION-FIELDS(ttconjuge.id,ttempregoconjuge.idpai) NESTED
   DATA-RELATION fora FOR ttcliente, ttcredito       RELATION-FIELDS(ttcliente.id,ttcredito.idpai) NESTED
   DATA-RELATION forb FOR ttcliente, ttrestricoes       RELATION-FIELDS(ttcliente.id,ttrestricoes.idpai) NESTED     .
   
    
  

hclienteEntrada = DATASET clienteEntrada:HANDLE.

/*
/* SAIDA */
DEFINE TEMP-TABLE ttstatus NO-UNDO serialize-name 'clienteSaida'
    FIELD chave as char     serialize-hidden  
    field situacao   as char  serialize-name 'status'
    index cli is unique primary situacao asc.

DEFINE DATASET conteudoSaida FOR ttstatus.

hclienteSaida = DATASET conteudoSaida:HANDLE.
*/

