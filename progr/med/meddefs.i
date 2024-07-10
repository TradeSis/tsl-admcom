/* medico na tela 042022 - helio */ 

def {1} shared var pvencod     like func.funcod.
def {1} shared var pprocod     like produ.procod.
def {1} shared var pfincod     as int.
def {1} shared var pcpf        as dec format "99999999999" label "CPF".
def {1} shared var pclicod     as int.
 
def {1} shared temp-table ttpropostaLebes no-undo serialize-name "propostaLebes"
    field idPropostaLebes   as char.

def {1} shared temp-table ttproposta no-undo serialize-name "proposta"
    field codigoLoja    as char
    field dataProposta  as char
    field cpf           as char
    field tipoServico   as char /*DOC24*/
    field valorServico  as char 
    field procod        as char    serialize-name "codigoProdutoLebes"
    field idmedico      as char         serialize-name "codigoProdutoExterno"
    field idPropostaLebes   as char serialize-hidden.

def {1} shared temp-table ttpropostacliente no-undo 
    field clinom    as char
    field endereco  as char
    field numero    as char
    field compl     as char
    field bairro    as char
    field cidade    as char
    field ufecod    as char
    field cep       as char.

def {1} shared temp-table ttrespostas no-undo serialize-name "dadosAdicionais"
    field idcampo         as char   serialize-name "chave" 
    field CONTEUDO        as char   serialize-name "valor".

def {1} shared temp-table ttmedprodu no-undo serialize-name "produto"
    field procod    as int  format ">>>>>>>>>9"
    field pronom    as char format "x(35)"
    field idmedico  as char format "x(20)"
    field idPerfil  as int
    field valorServico     as char
    field tipoServico   as char.

def  {1} shared temp-table ttcampos no-undo serialize-name "campos"
      FIELD IDPerfil        AS INTEGER 
      FIELD idcampo         AS CHARACTER
      FIELD ID              as char
      FIELD nomecampo       AS CHARACTER 
      FIELD ordem           AS INTEGER
      FIELD TIPO            AS CHARACTER
      FIELD OBRIGATORIEDADE AS LOGICAL     FORMAT "true/false"
      FIELD MAXIMO          AS INTEGER
      FIELD MINIMO          AS INTEGER
      field VLRMINIMO       as int
      field VLRMAXIMO       as int
      FIELD PERIODO_MAXIMO  AS CHARACTER
      FIELD PERIODO_MINIMO  AS CHARACTER
      field CONTEUDO        as char
      index x IDPerfil asc ordem asc.
    
def  {1} shared temp-table ttopcoes no-undo serialize-name "opcoes"
    FIELD IDPAI      as char
    FIELD idcampo    AS CHARACTER 
    FIELD nomeOpcao  AS CHARACTER 
    FIELD valorOpcao AS CHARACTER.

def  {1} shared temp-table ttplanos no-undo serialize-name "planos"
  FIELD procod AS INTEGER 
  FIELD fincod AS INTEGER 
  field finnom  as char
  field qtdvezes  as int.


def dataset medicoSaida for ttmedprodu, ttcampos, ttopcoes, ttplanos
/*    DATA-RELATION rel1 for ttmedprodu , ttcampos RELATION-FIELDS (ttmedprodu.idPerfil,ttcampos.IDPerfil) NESTED*/
    DATA-RELATION rel2 for ttcampos   , ttopcoes RELATION-FIELDS (ttcampos.ID,ttopcoes.IDPAI) nested
    DATA-RELATION rel3 for ttmedprodu , ttplanos RELATION-FIELDS (ttmedprodu.procod,ttplanos.procod).
     
DEFINE DATASET dadosProposta FOR ttproposta, ttrespostas.

def  {1} shared temp-table ttadesao no-undo serialize-name "adesao"
  field idPropostaAdesaoLebes as char
  field etbcod               as char serialize-name "codigoLoja"
  field dataTransacao       as char
  field numeroComponente    as char
  field nsuTransacao        as char
  field dataProposta        as char
  field tipoServico         as char
  field valorServico        as char
  field procod              as char serialize-name "codigoProdutoLebes"
  field idmedico            as char serialize-name "codigoProdutoExterno".

def {1} shared temp-table ttdados no-undo serialize-name "dadosAdicionais"
    field idcampo         as char   serialize-name "chave" 
    field CONTEUDO        as char   serialize-name "valor".
  
DEFINE DATASET dadosAdesao FOR ttadesao, ttdados.

def  {1} shared temp-table ttadesaoLebes no-undo serialize-name "adesaoLebes"
  field idAdesao as char.

def  {1} shared temp-table ttcancelaadesao no-undo serialize-name "adesao"
  field idAdesaoLebes       as char  
  field idPropostaAdesaoLebes as char
  field etbcod               as char serialize-name "codigoLoja"
  field dataTransacao       as char
  field numeroComponente    as char
  field nsuTransacao        as char
  field dataProposta        as char
  field tipoServico         as char
  field valorServico        as char
  field procod              as char serialize-name "codigoProdutoLebes"
  field idmedico            as char serialize-name "codigoProdutoExterno".

def {1} shared temp-table ttcanceladados no-undo serialize-name "dadosAdicionais"
    field idcampo         as char   serialize-name "chave" 
    field CONTEUDO        as char   serialize-name "valor".
  
DEFINE DATASET cancelaAdesao FOR ttcancelaadesao, ttcanceladados.

  
def  {1} shared temp-table ttadesaoCancelamentoStatus no-undo serialize-name "cancelamentoParceirosStatus"
    field codigoParceiro    as char
    field statusParceiro    as char
    field mensagemParceiro  as char.
