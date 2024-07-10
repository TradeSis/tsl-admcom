
/* 05012022 helio iepro */

def input param poperacao as char.
def input param pacao as char.
def var vjuros as dec.

{iep/tfilsel.i}

{api/acentos.i}

function testanull returns character
    (input par-char as char).
   
    def var par-ret as char.
    par-ret = par-char.
    
    if par-ret = ?
    then par-ret = "".

    return par-ret.
    
end.    
    
function trata-numero returns character
    (input par-num as char).

    def var par-ret as char init "".
    def var vletra  as char.
    def var vi      as int.

    if par-num = ?
    then par-num = "".

    do vi = 1 to length(par-num).
        vletra = substr(par-num, vi, 1).
        if (asc(vletra) >= 48 and asc(vletra) <= 57) /* 0-9 */
        then par-ret = par-ret + substring(par-num,vi,1).
    end.

    return par-ret.

end function.


function formatadata returns character
    (input par-data  as date). 
    
    def var vdata as char.  

    if par-data <> ? 
    then vdata = string(par-data, "999999").
    else vdata = "000000". 

    return vdata. 

end function. 
    

def var varquivo  as char.
    
    find first ttfiltros.

        for each ttcontrato where ttcontrato.marca = yes
                break by ttcontrato.clicod by ttcontrato.contnum.

            find contrato where contrato.contnum = ttcontrato.contnum no-lock.
            find clien of contrato no-lock.
            
            find first titprotesto where 
                    titprotesto.operacao = poperacao and
                    titprotesto.remessa  = ?  and
                    titprotesto.clicod   = contrato.clicod   and
                    titprotesto.contnum  = contrato.contnum
                    exclusive no-error.
            if not avail titprotesto
            then do:
                create titprotesto. 
                titprotesto.operacao = poperacao.
                titprotesto.remessa  = ?.
                titprotesto.clicod   = contrato.clicod.
                titprotesto.contnum  = contrato.contnum.
                
                titprotesto.acao     = pacao.
                titprotesto.DtAcao      = ?.
                titprotesto.pagaCustas = YES. /* LEBES */                
                titprotesto.ativo       = "".
                titprotesto.titdtven  = ttcontrato.titdtven.
                titprotesto.VlCobrado   = 0.
                titprotesto.nossonumero = ttcontrato.nossonumero.                
            end.

            for each ttparcela where ttparcela.contnum = ttcontrato.contnum
                break by ttparcela.titpar.
                
                find titulo where recid(titulo) = ttparcela.trecid no-lock.
                
                create titprotparc.    
                titprotparc.operacao = poperacao.
                titprotparc.remessa  = ?. /* ainda nao tem remessa */
                titprotparc.clicod   = clien.clicod. 
                titprotparc.contnum  = contrato.contnum.
                titprotparc.titpar   = ttparcela.titpar.
                titprotparc.dtinc    = today.
                titprotparc.hrinc    = time.
            
                titprotparc.titvlcob = titulo.titvlcob.
            
                titprotparc.titvljur = ttparcela.titvljur.
            
                /* helio 11012022 - IEPRO */
                run juro_titulo.p (if clien.etbcad = 0 then titulo.etbcod else clien.etbcad,
                                   titulo.titdtven,
                                   titulo.titvlcob,
                                   output vjuros).

                titprotparc.titdescjur = vjuros - titprotparc.titvljur.            
                titprotesto.vlcobrado = titprotesto.vlcobrado + 
                                                titulo.titvlcob + ttparcela.titvljur.
            end.
                    
                                        
    end.
    


