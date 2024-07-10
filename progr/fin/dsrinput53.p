def input param parquivo as char.

def var vconta as int.
def var vdata as char.
def var vlinha as char format "x(150)".
/* 
Header/body;cpf;idAgrupamentoB3;CNPJCredor;idContratoCredorOriginal;FeeOperador;FeeAF;valorlancamento;dataMovimento;idPagamento;CNPJAF;motivo;descontoAVista
*/
    
input from value(parquivo).
repeat.

    import vlinha.
    vconta = vconta + 1.
    if vconta <= 3 then next.

    find first desenr53 where desenr53.cpf = entry(2,vlinha,";") and
                              desenr53.idAgrupamentoB3 = entry(3,vlinha,";") and
                              desenr53.contnum = int(entry(5,vlinha,";"))
            no-error.
    if avail desenr53 
    then next.
    
    create desenr53.
    desenr53.cpf = entry(2,vlinha,";").
    desenr53.idAgrupamentoB3    = entry(3,vlinha,";").
    desenr53.contnum = int(entry(5,vlinha,";")).
    desenr53.FeeOperador    = dec(entry(6,vlinha,";")).
    desenr53.FeeAF    = dec(entry(7,vlinha,";")).
    desenr53.valorlancamento    = dec(entry(8,vlinha,";")).
    vdata = entry(9,vlinha,";").
    desenr53.dataMovimento    = date(int(substring(vdata,5,2)),
                                 int(substring(vdata,7,2)),
                                 int(substring(vdata,1,4))).                                 

    desenr53.motivo = entry(12,vlinha,";").
    if num-entries(vlinha,";") >= 13
    then desenr53.descontoAVista    = dec(entry(13,vlinha,";")).
     
end.
