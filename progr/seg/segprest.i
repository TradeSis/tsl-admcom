
def {1} shared temp-table ttcontrato no-undo
    field rec as recid
    field catnom       as char
    /*
    field valortotal   as dec
    field placod       as int
    field valorTotalSeguroPrestamista as dec
    */
    field codigoSeguro as int
    field tpseguro     as int
    field contnum      as int 
    field certifi      as char 
    field SeguroPrestamistaAutomatico as log
    field prseguro  as dec.

def buffer bttcontrato    for ttcontrato.
function EnviaData returns character
    (input par-data as date).

    if par-data <> ?
    then return string(year(par-data),"9999") + "-" +
                string(month(par-data),"99") + "-" + 
                string(day(par-data),"99").
    else return "1900-01-01".

end function.

 
def temp-table ttjsonContratos no-undo serialize-name "segurosAutomatizados"
    field contnum       as char serialize-name "contrato"
    field etbcod        as char serialize-name "filial"  
    field certifi       as char serialize-name "certificado"
    field dataEmissao   as char 
    field valorContrato as char 
    field valorLiquido  as char 
    field valorSeguroContrato as char
    field codigoSeguro  as char
    field nomeSeguro    as char
    field valorSeguro   as char
    field codigoCliente as char
    field cpfCliente    as char
    field plano         as char
    field descPlano     as char
    field automatico    as char
    field modalidade    as char
    field filialOrigem  as char.

