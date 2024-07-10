
{admcab.i}
def var prec as recid.
def var vvlseguro as dec.
def input param par-vndseguro as recid.
def var vnro_parcela as int.

find vndseguro where recid(vndseguro) = par-vndseguro no-lock.

find contrato where contrato.contnum = vndseguro.contnum no-lock no-error.
if not avail contrato
    /*https://trello.com/c/zPYyknk5/19-cancelamento-seguro*/
    or contrato.contnum = 0
then do: 
    find plani where plani.etbcod = vndseguro.etbcod 
                 and plani.placod = vndseguro.placod
                               no-lock no-error.
    if avail plani
    then do:
        find contnf where contnf.etbcod = plani.etbcod and
                          contnf.placod = plani.placod
            no-lock no-error.
        if avail contnf
        then do:
            find contrato where contrato.contnum = contnf.contnum no-lock no-error.
        end.
    end.
    if not avail contrato
    then do:
        message "Contrato nao encontrato".
        pause 1 no-message.
        next.
    end.        
end.    

vnro_parcela = contrato.nro_parcela.
if vnro_parcela = ?
then vnro_parcela  = 0.

find first pdvtmov where pdvtmov.ctmcod = "CSE" no-lock.
 
find cmon where cmon.etbcod = setbcod and cmon.cxacod = 99 no-lock.
 
run fin/cmdinc.p (recid(cmon), recid(pdvtmov), output prec).

find pdvmov where recid(pdvmov) = prec no-lock.

def var vseqreg as int.

def temp-table ttparcela
    field prec as recid.

/*https://trello.com/c/zPYyknk5/19-cancelamento-seguro
for each titulo where titulo.contnum = contrato.contnum no-lock.
    create ttparcela.
        ttparcela.prec = recid(titulo).
    if contrato.nro_parcela = 0
    then vnro_parcela = vnro_parcela + 1.    
end.
find first ttparcela no-error.
if not avail ttparcela
then*/ do:
                for each  titulo where
                        titulo.empcod = 19 and
                        titulo.titnat = no and
                        titulo.etbcod = contrato.etbcod and
                        titulo.clifor = contrato.clicod and
                        titulo.modcod = contrato.modcod and
                        titulo.titnum = string(contrato.contnum) /**and
                        titulo.titdtemi = contrato.dtinicial **/
                        no-lock.
                        create ttparcela.
                        ttparcela.prec = recid(titulo).
                        if contrato.nro_parcela = 0
                        then vnro_parcela = vnro_parcela + 1.    
                        
                end.                        
end.

    vvlseguro = vndseguro.prseguro / vnro_parcela.
    
    if vvlseguro = 0 or vvlseguro = ?
    then next.

for each ttparcela no-lock.
    find titulo where recid(titulo) = ttparcela.prec no-lock.

    if titulo.titdtpag = ?
    then.
    else next.
    
    vseqreg = vseqreg + 1.
    
    create pdvdoc.
  ASSIGN
    pdvdoc.etbcod            = pdvmov.etbcod
    pdvdoc.cmocod            = pdvmov.cmocod
    pdvdoc.DataMov           = pdvmov.DataMov
    pdvdoc.Sequencia         = pdvmov.Sequencia
    pdvdoc.ctmcod            = pdvmov.ctmcod
    pdvdoc.COO               = pdvmov.COO
    pdvdoc.seqreg            = vseqreg
    pdvdoc.CliFor            = titulo.CliFor
    pdvdoc.ContNum           = string(contrato.contnum)
    pdvdoc.titpar            = titulo.titpar
    pdvdoc.titdtven          = titulo.titdtven.

  ASSIGN
    pdvdoc.pago_parcial      = "N"
    pdvdoc.modcod            = titulo.modcod
    pdvdoc.Desconto_Tarifa   = 0
    pdvdoc.Valor_Encargo     = 0
    pdvdoc.hispaddesc        = "CANCELAMENTO SEGURO".

    pdvdoc.Valor             = vvlseguro.
    pdvdoc.titvlcob          = vvlseguro.

    run fin/baixatitulo.p (recid(pdvdoc),
                           recid(titulo)).


end.
