def var vDTULTCPA as date format "99/99/9999".

def input  parameter vlcentrada as longchar.
def output parameter vlcsaida   as longchar.

def var vsaida as char.
def var hentrada as handle.
def var hsaida   as handle.

{/admcom/progr/api/acentos.i}

def temp-table ttentrada no-undo serialize-name "clientes"
    field cpfCnpj as char.

def var vconta as int.
def var vx as int.
/* Cartoes de loja */
def var vcartoes as char.
def var vct  as int.
def var auxcartao as char extent 7 format "x(20)"
      init ["Visa","Master","Banricompras","Hipercard",
            "Cartoes de Loja","American Express","Dinners"].
/* */
{/admcom/progr/acha.i}
{/admcom/barramento/functions.i}

/* SAIDA */

DEFINE TEMP-TABLE ttclien NO-UNDO       serialize-name 'creditoCliente'
    field tipo    as char format "x(18)"
    field clicod    as int serialize-name 'codigoCliente'
    field cpfCNPJ    as char format "x(18)"    serialize-name 'cpfCNPJ'
    field clinom    as char format "x(40)" serialize-name 'nomeCliente'
    field limite      as dec
    field vctoLimite  as date
    field saldoLimite  as dec
    field comprometido as dec
    field comprometidoTotal as dec
    field comprometidoPrincipal as dec
    field comprometidoNormal as dec
    field comprometidoNovacao as dec
    /* #092022 */
    field dataUltimaCompra as date
    field quantidadeContratos as int
    field quantidadeParcelasPagas as int
    field quantidadeParcelasEmAberto as int
    field valorParcelasAtraso as dec
    field quantidadeAte15Dias as int
    field quantidadeAte45Dias as int
    field quantidadeAcima45Dias as int
    /* #092022 */
       /* helio replicacao de dados do cliente */
           field cep       as char 
           field logradouro as char 
           field numero as int 
           field complemento   as char 
           field bairro as char 
           field cidade as char 
           field estado as char 
           field email as char 
           field celular as char
                                           
    index cli is unique primary clicod asc tipo desc.


DEFINE DATASET conteudoSaida FOR ttclien.

hSaida = DATASET conteudoSaida:HANDLE.
def var lokjson as log.

{/admcom/progr/neuro/achahash.i}  /* 03.04.2018 helio */
{/admcom/progr/neuro/varcomportamento.i} /* 03.04.2018 helio */

def temp-table ttsaida  no-undo serialize-name "conteudoSaida"
    field tstatus        as int serialize-name "status"
    field descricaoStatus      as char.
def var var-valorParcelasAtraso as dec.
def var vvlrlimite  as dec.
def var vvlrdisponivel as dec.
def var vvctolimite as date.

def var var-comprometidoHUBSEG as dec.

def var var-comprometidoPrincipal as dec.
def var var-comprometidoTotal     as dec.
def var var-comprometidoNovacao     as dec.
def var var-comprometidoNormal     as dec.
def var var-comprometidoEPPrincipal as dec.
def var var-comprometidoEPTotal     as dec.
def var var-comprometidoEPNovacao     as dec.
def var var-comprometidoEPNormal     as dec.



hEntrada = temp-table ttentrada:HANDLE.

lokJSON = hentrada:READ-JSON("longchar",vlcentrada, "EMPTY").


find first ttentrada no-error.
if not avail ttentrada
then do:
  create ttsaida.
  ttsaida.tstatus = 400.
  ttsaida.descricaoStatus = "Sem dados de Entrada".

  hsaida  = temp-table ttsaida:handle.

  lokJson = hsaida:WRITE-JSON("LONGCHAR", vlcSaida, TRUE).
  /*message string(vlcSaida).*/
  return.

end.

find neuclien where neuclien.cpfCnpj =  dec(ttentrada.cpfCnpj) no-lock no-error.
if not avail neuclien
then do:
    find clien where clien.ciccgc = trim(ttentrada.cpfCnpj) no-lock no-error.
end.
else do:
  find clien where clien.clicod = neuclien.clicod no-lock no-error.
end.

if not avail clien
then do:

  create ttsaida.
  ttsaida.tstatus = 404.
  ttsaida.descricaoStatus = "Cliente com CPF " +
          (if ttentrada.cpfCnpj = ?
           then ""
           else ttentrada.cpfCnpj) + " Não encontrado.".

  hsaida  = temp-table ttsaida:handle.

  lokJson = hsaida:WRITE-JSON("LONGCHAR", vlcSaida, TRUE).
  /*message string(vlcSaida).*/
  return.

end.


create ttclien.
ttclien.tipo   = "Global".
ttclien.clicod = if avail clien then clien.clicod else ?.
ttclien.clinom = removeacento(if avail clien then clien.clinom else neuclien.nome_pessoa).
ttclien.cpfCnpj = string(neuclien.cpf).

if avail clien
then do:    
    ttclien.cep             = clien.cep[1].
    ttclien.logradouro      = removeacento(clien.endereco[1]).
    ttclien.numero          = clien.numero[1].
    ttclien.complemento     = removeacento(clien.compl[1]).
    ttclien.bairro          = removeacento(clien.bairro[1]).
    ttclien.cidade          = removeacento(clien.cidade[1]).
    ttclien.estado          = clien.ufecod[1].
    ttclien.email           = clien.zona.
    ttclien.celular         = clien.fax.
end.
    
vvlrlimite = 0.
vvctolimite = ?.
vvlrdisponivel = 0.

if avail neuclien
then do:
    vvlrlimite = /* helio 17052023
                *if neuclien.vctolimite < today
                *then 0
                *else*/ neuclien.vlrlimite.
    vvctolimite = neuclien.vctolimite.
end.
    ttclien.vctoLimite  =  vvctolimite.
    ttclien.Limite      =  vvlrLimite.

    var-propriedades = "" .

      for each contrato where contrato.clicod = clien.clicod no-lock,
                each titulo where titulo.empcod = 19        and
                           titulo.titnat = no        and
                           titulo.modcod = contrato.modcod and
                           titulo.etbcod = contrato.etbcod and
                           titulo.clifor = contrato.clicod and
                           titulo.titnum = string(contrato.contnum)
                           no-lock:
        
            if titulo.modcod = "CHQ" or
               titulo.modcod = "DEV" or
               titulo.modcod = "BON" or
               titulo.modcod = "VVI" or   /* #5 Sujeira de banco */
               length(titulo.titnum) > 11 /* Sujeira de banco */
            then next. /*** ***/

            if titulo.titsit <> "LIB"
            then next.
        
            if titulo.titdtven < today - 15 then do:
                var-valorParcelasAtraso   = var-valorParcelasAtraso + titulo.titvlcob.
            end.
   end.                
    ttclien.valorParcelasAtraso = var-valorParcelasAtraso.
   
   
lokJson = hSaida:WRITE-JSON("LONGCHAR", vlcsaida, TRUE) no-error.
if lokJson
then do:
        
        /* put unformatted string(vlcsaida).*/
        
end.
else do:
    create ttsaida.
    ttsaida.tstatus = 500.
    ttsaida.descricaoStatus = "Erro na Geração do JSON de SAIDA".

    hsaida  = temp-table ttsaida:handle.

    lokJson = hsaida:WRITE-JSON("LONGCHAR", vlcSaida, TRUE).
    /*message string(vlcSaida).*/
    return.
end.
