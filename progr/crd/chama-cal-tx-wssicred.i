

def var vEmpresa      as integer.
def var vAgencia      as integer.
def var vLojista      as integer.

def var vret-Empresa             as char.
def var vret-Agencia             as char.
def var vret-Lojista             as char.
def var vret-Loja                as char.
def var vret-Produto             as char.
def var vret-Plano               as char.
def var vret-Prazo               as char.
def var vret-Emissao             as char.
def var vret-PrimeiroVencimento  as char.
def var vret-PMT                 as char.
def var vret-ValorTAC            as char.
def var vret-ValorTfc            as char.
def var vret-Seguro              as char.
def var vret-ValorIOF            as char.
def var vret-ValorFinanciado     as char.
def var vret-Taxa                as char.
def var vret-Coeficiente         as char.
def var vret-IRR                 as char.
def var vret-ValorLiberar        as char.
def var vret-CET                 as char.
def var vret-CETAnual            as char.
def var vret-PST                 as char.
def var vret-TFC                 as char.
def var vret-Tac                 as char.
def var vret-ValorTotal          as char.

assign vEmpresa      = 1
       vAgencia      = 1
       /***
       vProduto      = 1
       vPlano        = 326
       ***/
       vLojista      = 1.

if vetbcod = 189 then vloja = 1.

run /admcom/progr/crd/cal-tx-wssicred2.p
                     (input vEmpresa,
                      input vAgencia,
                      input vProduto,
                      input vLojista,
                      input vLoja,
                      input vPlano,
                      input vPrazo,
                      input vValorCompra,
                      input vValorPMT,
                      input vDiasParaPgto,
                      input vTaxa,
                      input vSeguro,
                      output vret-Empresa,
                      output vret-Agencia,
                      output vret-Lojista,
                      output vret-Loja,
                      output vret-Produto,
                      output vret-Plano,
                      output vret-Prazo,
                      output vret-Emissao,
                      output vret-PrimeiroVencimento,
                      output vret-PMT,
                      output vret-ValorTAC,
                      output vret-ValorTfc,
                      output vret-Seguro,
                      output vret-ValorIOF,
                      output vret-ValorFinanciado,
                      output vret-Taxa,
                      output vret-Coeficiente,
                      output vret-IRR,
                      output vret-ValorLiberar,
                      output vret-CET,
                      output vret-CETAnual,
                      output vret-PST,
                      output vret-TFC,
                      output vret-Tac,
                      output vret-ValorTotal).
