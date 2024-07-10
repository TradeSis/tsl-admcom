def var hmetaRealizadoCobrancaEntrada as handle.
def var lcJsonSaida as longchar.
def var lokJson as log.
def var vano as int.
def var vmes as int.
def var vdata as date.
def var vdata1 as date.

{/admcom/barramento/functions.i}

def var vdataExecucao as char.
def var vcodigoEstabelecimento  as char.
def var vdataInicialVencimento   as char.
def var vdataFinalVencimento as char.
def var vmesAtraso  as int.
def var vmodalidade as char.
def var vcarteira   as char.
def var vtipoContrato    as char.

def shared temp-table ttposicao no-undo
    field mesvenc   as int format "99"
    field anovenc   as int format "9999"
    field etbcod    like estab.etbcod
    field modcod    like titulo.modcod
    field tpcontrato like titulo.tpcontrato
    field cobcod    like titulo.cobcod
    field emissao   like poscart.emissao
    field pagamento like poscart.pagamento
    field saldo     like poscart.saldo
    index idx is unique primary anovenc asc mesvenc asc etbcod asc modcod asc tpcontrato asc cobcod asc.

DEFINE TEMP-TABLE ttstatus NO-UNDO serialize-name 'metaRealizadoCobranca'
    field dataExecucao  as char /*": "2020-04-28", */
    field codigoEstabelecimento as char     /*": "188", */
    field dataInicialVencimento as char     /*": "2020-03-01", */
    field dataFinalVencimento   as char     /*": "2020-03-31", */
    field mesAtraso             as char     /*": "1", */
    field valorPrevisto         as char     /*": "150000.00", */
    field valorPago             as char     /*": "97000.00", */
    field valorEmAbertoVencer   as char /*": "0.00", */
    field valorEmAbertoVencido  as char /*": "53000.00", */

    field hvalorPrevisto         as dec serialize-hidden
    field hvalorPago             as dec serialize-hidden
    field hsaldo                 as dec serialize-hidden
    
    field modalidade            as char     /*": "CP0", */ 
    field carteira              as char     /*": "FINANCEIRA", */
    field tipoContrato          as char     /*": "REGULAR"*/
                                                                                            
    index x is unique primary dataExecucao asc 
                              codigoEstabelecimento asc
                              dataInicialVencimento asc 
                              modalidade asc 
                              carteira asc
                              tipoContrato asc.


DEFINE DATASET metaRealizadoCobrancaEntrada FOR ttstatus.

hmetaRealizadoCobrancaEntrada = DATASET metaRealizadoCobrancaEntrada:HANDLE.



for each ttposicao. 
    
    vdataExecucao = enviadata(today). 
    vcodigoEstabelecimento = string(ttposicao.etbcod). 
    vdataInicialVencimento = enviadata(date(ttposicao.mesvenc,01,ttposicao.anovenc)). 
    
    vmes = ttposicao.mesvenc.
    vano = ttposicao.anovenc.
    assign
        vdata1   = date(vmes,01,vano)
        vano     = year(vdata1) + if month(vdata1) = 12 then 1 else 0
        vmes     = if month(vdata1) = 12 then 1 else month(vdata1) + 1
        vdata    = date(vmes,01,vano) - 1

    vdataFinalVencimento = enviadata(vdata).
    
    vmodalidade            = ttposicao.modcod.
    find cobra where cobra.cobcod = ttposicao.cobcod no-lock no-error.
    vcarteira              = if avail cobra
                             then cobra.cobnom
                             else "".    
    vtipoContrato          = ttposicao.tpcontrato.

    vmesAtraso             = round( (date(month(today),01,year(today)) - date(ttposicao.mesvenc,01,ttposicao.anovenc)) / 30,0).
     
      
    find first ttstatus where
            ttstatus.dataExecucao   = vdataExecucao and
            ttstatus.codigoEstabelecimento  = vcodigoEstabelecimento and
            ttstatus.dataInicialVencimento  = vdataInicialVencimento and
            ttstatus.modalidade = vmodalidade and
            ttstatus.carteira = vcarteira and
            ttstatus.tipoContrato = vtipoContrato
             no-error.
    if not avail ttstatus
    then do:             
        create ttstatus. 
        ttstatus.dataExecucao   = vdataExecucao.
        ttstatus.codigoEstabelecimento  = vcodigoEstabelecimento.
        ttstatus.dataInicialVencimento  = vdataInicialVencimento.
        ttstatus.modalidade = vmodalidade.
        ttstatus.carteira = vcarteira.
        ttstatus.tipoContrato = vtipoContrato.
    end.

    assign
        ttstatus.mesAtraso  = string(vmesAtraso)
        ttstatus.dataFinalVencimento = vdataFinalVencimento.
    ttstatus.hvalorPrevisto = ttstatus.hvalorPrevisto + ttposicao.emissao.
    ttstatus.hvalorPago     = ttstatus.hvalorPago     + ttposicao.pagamento.
    ttstatus.hsaldo         = ttstatus.hsaldo         + (ttposicao.emissao - ttposicao.pagamento).

    ttstatus.valorPrevisto  = trim(string(ttstatus.hvalorPrevisto,"->>>>>>>>>>>>>>>>>>9.99")).
    ttstatus.valorPago      = trim(string(ttstatus.hvalorpago,"->>>>>>>>>>>>>>>>>>9.99")).
    if vmesatraso <= 0
    then  ttstatus.valorEmAbertoVencer  = trim(string(ttstatus.hsaldo,"->>>>>>>>>>>>>>>>>>9.99")).
    else  ttstatus.valorEmAbertoVencido = trim(string(ttstatus.hsaldo,"->>>>>>>>>>>>>>>>>>9.99")).
                        
end.


lokJson = hmetaRealizadoCobrancaEntrada:WRITE-JSON("LONGCHAR", lcJsonSaida, TRUE) no-error.

if lokJson
then do: 
      create verusjsonout.
      ASSIGN
        verusjsonout.interface     = "metaRealizadoCobranca".
        verusjsonout.jsonStatus    = "NP".
        verusjsonout.dataIn        = today.
        verusjsonout.horaIn        = time.
    
        copy-lob from lcJsonSaida to verusjsonout.jsondados.
    
  hmetaRealizadoCobrancaEntrada:WRITE-JSON("FILE","metaRealizadoCobrancaEntrada.json", true).
    
end.    


