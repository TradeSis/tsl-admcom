def new global shared var spid as int.
def new global shared var spidseq as int.

def {1} shared var pvencod     like func.funcod.
def {1} shared var pprocod     like produ.procod.
def {1} shared var pfincod     as int.
def {1} shared var pmoedapdv     as int.

def {1} shared var pcpf        as dec format "99999999999" label "CPF".
def {1} shared var pclicod     as int.
def {1} shared var pbaucarne   as dec format "9999999999" label "Carne".

 /*    {"status":400,"erro":"Carn\u00ea n\u00e3o encontrado para esse codigo de barras.\n"} */
def temp-table tterro no-undo serialize-name "return"
    field pstatus as char serialize-name "status"
    field erro  as char.
    
def {1} shared temp-table ttbauprodu no-undo serialize-name "produto"
    field procod    as int  format ">>>>>>>>>9"
    field pronom    as char format "x(35)"
    field tipoServico   as char.

def  {1} shared temp-table ttplanos no-undo serialize-name "planos"
  FIELD tipoServico AS char 
  FIELD fincod AS INTEGER 
  field finnom  as char
  field qtdvezes  as int
  field moedaspdv as char.


def dataset bauSaida for ttbauprodu, ttplanos
    DATA-RELATION rel3 for ttbauprodu , ttplanos RELATION-FIELDS (ttbauprodu.tipoServico,ttplanos.tipoServico).
     


def {1} shared temp-table ttgetcliente serialize-name "getCliente"
    field nome  as char
    field sobrenome as char
    field cpf   as char
    field nascimento as char
    field cep as char
    field estado as char
    field cidade as char
    field bairro as char
    field endereco as char
    field numero as int
    field email as char
    field celular as char
    field senha as char
    field dataNascimento  as char
    field dtnasc    as date format "99/99/9999" label "Dt Nascimento" serialize-hidden.

def {1} shared temp-table ttpostcliente serialize-name "postCliente"
    field nome  as char
    field sobrenome as char
    field cpf   as char
    field nascimento as char
    field cep as char
    field estado as char
    field cidade as char
    field bairro as char
    field endereco as char
    field numero as int
    field email as char
    field celular as char
    field senha as char
    field dtNasc as date format "99/99/9999" label "Dt Nascimento" serialize-hidden.
  


def {1} shared temp-table ttgetcarne no-undo serialize-name "carne" 
    field id as char serialize-hidden
    field codBarrasCarne as char
    field nomeCli   as char
    field telefoneCli as char
    field cpfClie   as char
    field situacaoCarne as char
    field recorrenciaCarne    as char
    field codCarne as dec serialize-hidden init ? format "99999999999".

def temp-table ttgetLEcarne no-undo serialize-name "carne" 
    field id as char serialize-hidden
    field codBarrasCarne as char
    field nomeCli   as char
    field telefoneCli as char
    field cpfClie   as char
    field situacaoCarne as char
    field recorrenciaCarne    as char.


def  temp-table ttgetLeparcelas no-undo serialize-name "parcelas" 
    field id as char serialize-hidden
    field valor as char
    field codigoBarras as char
    field dataVencimento    as char
    field pagamento as char 
    field numero    as int format ">>9"
    field idCarne   as char.

def  {1} shared temp-table ttgetparcelas no-undo serialize-name "parcelas" 
    field id as char serialize-hidden
    field valor as char
    field codigoBarras as char
    field dataVencimento    as char
    field pagamento as char 
    field numero    as int format ">>9"
    field idCarne   as char
    field marca     as log serialize-hidden
    field codCarne as dec serialize-hidden init ? format "99999999999"
    field titvlcob  as dec format ">>>>>9.99" column-label "valor" serialize-hidden.


def dataset getParcelas for ttgetlecarne, ttgetleparcelas
    DATA-RELATION rel3 for ttgetlecarne, ttgetleparcelas RELATION-FIELDS (ttgetlecarne.id, ttgetleparcelas.id).


def  {1} shared temp-table ttcarnes no-undo serialize-name "getCarnes"
    field serie as char
    field numero    as char
    field digito as char
    field codigoBarras as char
    field pstatus as char serialize-name "status"
    field quantidadeParcelas as int
    field valorResgate as dec
    field valorCredito as dec
    field statusAtualizacao as char
    field possuiAssinatura as log
    field carneQuitado as log
    field codCarne as dec serialize-hidden init ? format "99999999999"
    field SelecPar as int format ">9" serialize-hidden
    field vlrSelec as dec format ">>>9.99" serialize-hidden.
    

def {1} shared temp-table ttproposta no-undo serialize-name "proposta"
    field codigoLoja    as char
    field dataProposta  as char
    field tipoServico   as char /*DOC24*/
    field valorServico  as char 
    field procod        as char    serialize-name "codigoProdutoLebes"
    field idbau         as char         serialize-name "codigoProdutoExterno"
    field idPropostaLebes as char serialize-hidden
    field cpf           as char serialize-hidden.
  
def {1} shared temp-table ttrespostas no-undo serialize-name "dadosAdicionais"
    field idcampo         as char   serialize-name "chave" 
    field CONTEUDO        as char   serialize-name "valor".

def {1} shared temp-table ttpostParcelas no-undo serialize-name "parcelasJequiti"
    field recorrente as log
    field data      as char /*": "2022-08-29T15:30:00.000-03:00", */
    field codigoBarrasParcela   as char /*": "898000000002150001041781800000000001960151862614", */
    field valor as dec     /*": 15.0, */
    field numeroParcela as int /*": 1, */
    field codigoBarras  as char /*": "0965186261", */
    field numeroTransacao   as char /*": null, */
    field codeLocalPagamento    as char. /*": "LEBES-188" */
      
DEFINE DATASET dadosProposta FOR ttproposta, ttrespostas, ttpostParcelas.

def {1} shared temp-table ttpropostaLebes no-undo serialize-name "propostaLebes"
    field idPropostaLebes   as char.

def  {1} shared temp-table ttefetivaPagamento no-undo serialize-name "pagamento"
  field idPropostaLebes as char
  field etbcod               as char serialize-name "codigoLoja"
  field dataTransacao       as char
  field numeroComponente    as char
  field nsuTransacao        as char
  field dataProposta        as char
  field tipoServico         as char
  field valorServico        as char
  field procod              as char serialize-name "codigoProdutoLebes"
  field idBau               as char serialize-name "codigoProdutoExterno".

def {1} shared temp-table ttefetivaPagamentoDados no-undo serialize-name "dadosAdicionais"
    field idcampo         as char   serialize-name "chave" 
    field CONTEUDO        as char   serialize-name "valor".

def {1} shared temp-table ttefetivaPagamentoParcelas no-undo serialize-name "parcelasJequiti"
    field recorrente as char
    field data      as char /*": "2022-08-29T15:30:00.000-03:00", */
    field codigoBarrasParcela   as char /*": "898000000002150001041781800000000001960151862614", */
    field valor as char     /*": 15.0, */
    field numeroParcela as char /*": 1, */
    field codigoBarras  as char /*": "0965186261", */
    field numeroTransacao   as char /*": null, */
    field codeLocalPagamento    as char. /*": "LEBES-188" */

DEFINE DATASET dadosEfetivaPagamento FOR ttefetivapagamento, ttefetivaPagamentodados, ttefetivaPagamentoParcelas.

def  {1} shared temp-table ttefetivaPagamentoRetorno no-undo serialize-name "PagamentoLebes"
  field idPagamento as char
  field tipoPagamento as char.


