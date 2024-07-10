/* helio 14042023 Qualitor ID 21258 - Cancelamento de contratos Chama Doutor.*/

def input param precidmedadesao as recid.
def  shared variable sfuncod  like func.funcod.
def var vtime as int.
vtime = time.
 
find medadesao where recid(medadesao) = precidmedadesao no-lock.
if medadesao.dtcanc <> ?
then do:
    message "ja cancelado".
    pause 1.
    return.
end.    
find cmon of medadesao no-lock. 


        
do on error undo:  
    create medadecanc.
     medadecanc.idAdesao         = medadesao.idAdesao. 
     medadecanc.dtcanc           = today. 
     medadecanc.funcod           = sfuncod. 
     medadecanc.hrcanc           = vtime. 
     /*
     medadecanc.codigoParceiro   = ttadesaoCancelamentoStatus.codigoParceiro. 
     medadecanc.statusParceiro   = ttadesaoCancelamentoStatus.statusParceiro. 
     medadecanc.mensagemParceiro = ttadesaoCancelamentoStatus.mensagemParceiro.
     */

    find current medadesao exclusive no-wait no-error.
    if avail medadesao
    then do: 
        medadesao.dtcanc = today.
        for each medaderepasse of medadesao where
                medaderepasse.dtvenc >= today .
            medaderepasse.rstatus = no. /* cancelado*/        
        end.        
        run med/pgerabaixacnt.p (input recid(medadesao)).    
    end.
    
        
    
end.    

