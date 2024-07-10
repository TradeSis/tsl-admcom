def {1} shared var pvencod     like func.funcod.
def {1} shared var pprocod     like produ.procod.
def {1} shared var pfincod     as int.
def {1} shared var pcpf        as dec format "99999999999" label "CPF".
def {1} shared var pclicod     as int.
 
def {1} shared temp-table ttproposta no-undo serialize-name "adesao"
    field idPropostaAdesaoLebes     as char
    field valorTotal                as dec serialize-hidden
    field cpf                       like pcpf
    field clinom        as char
    field endereco      as char
    field numero        as char
    field compl         as char
    field cep           as char
    field bairro        as char 
    field cidade        as char
    field ufecod        as char.

def {1} shared temp-table ttadesao no-undo serialize-name "adesao"
    field codigoLoja    as char
    field dataTransacao as char
    field canal         as char
    field id            as char serialize-name "produto"
    field modalidade    as char
    field CPF           as char serialize-name "idReferenciaCliente" .

def {1} shared temp-table ttrespostas no-undo serialize-name "respostas"
    field idPai           as char serialize-hidden
    field campoCodigo     as char
    field valor           as char.

def {1} shared temp-table ttsegprodu no-undo serialize-name "produto"
    field procod    as int  format ">>>>>>>>>9"
    field pronom    as char format "x(35)"
    field idseguro  as char format "x(20)".


def {1} shared temp-table ttseguro no-undo serialize-name "seguro"
    field id    as char format "x(20)"
    field ativo as logical
    field codigo as char
    field nome as char
    field tipo as char
    field categoria as char
    field provedor as char
    field PerfilTitularId as char
    field PerfilTitularCodigo as char
    field PerfilTitularAtivo as log
    field coberturaValor    as dec.


def {1} shared temp-table ttperfil no-undo serialize-name "perfil"
    field id    as char format "x(20)"
    field ativo as logical
    field codigo as char.
    
def  {1} shared temp-table ttcampos no-undo serialize-name "campos"
    field id    as char
    field codigo as char format "x(45)"
    field nome   as char format "x(25)"
    field descricao as char    
    field ativo as logical
    field idPai   as char
    field conteudo as char .
    
def  {1} shared temp-table ttatributos no-undo serialize-name "atributos"
    field id    as char
    field contexto as char
    field propriedade as char format "x(20)" 
    field valor as char    
    field ativo as log
    field idPai as char.
    
def  {1} shared temp-table ttopcoes no-undo serialize-name "opcoes"
    field id    as char
    field nome as char
    field valor as char    
    field ativo as log
    field idPai as char.

