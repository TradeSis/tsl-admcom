

def input parameter par-rec as recid.
def input-output param mdfe_forma_emissao as int.
def output param mdfe_dv as char.
def output param mdfe_chave as char.
  
def var mdfe_versao as char.
def var modelo-documento as char.

def var vemite_cnpj as char.

modelo-documento = "58".

run le_tabini.p (0, 0, "MDFE - VERSAO", OUTPUT mdfe_versao).
if mdfe_versao = "" or mdfe_versao = ?
then mdfe_versao = "3.00".
 
        
find mdfe where recid(mdfe) = par-rec no-lock.
        
find estab where estab.etbcod = mdfe.etbcod no-lock.

    vemite_cnpj = estab.etbcgc.
    vemite_cnpj = replace(vemite_cnpj,".","").
    vemite_cnpj = replace(vemite_cnpj,"/","").
    vemite_cnpj = replace(vemite_cnpj,"-","").
                                      

function modulo11 returns integer
    (input par-numeron as char).

   def var vdivisao as int.
   def var vdigito as int.
    
   def var vct    as int.
   def var vparc  as int.
   def var vsoma  as int.
   def var vresto as int.
   def var vpeso  as int.
   def var vtam   as int.
   
   vpeso = 2.
   vtam  = length(par-numeron).
   do vct = vtam to 1 by -1.
        vparc = (int(substr(par-numeron, vct, 1)) * vpeso).
        vsoma = vsoma + vparc.
        vpeso = vpeso + 1.
        if vpeso > 9
        then vpeso = 2.
    end.
    vdivisao = truncate(vsoma / 11,0).
    vresto = vsoma - (vdivisao * 11).

    /** 03.05 helio */
    
    if vresto < 2 
    then vdigito = 0.
    else vdigito = 11 - vresto.
    /**
    if vdigito = 1 or vdigito >= 10
    then vdigito = 0.
    **/
    
    return vdigito.
end function.


/**
disp mdfe.ibge-ufemi mdfe.mdfedtemissao
                                       vemite_cnpj
                                       modelo-documento
                                       mdfe.mdfeserie
                                       mdfe.mdfenumero
                                       mdfe_forma_emissao
                                       mdfe.mdfecod
                                       with 2 col.
                                       pause.
**/

mdfe_chave = 
            string(mdfe.ibge-ufemi,"99") + 
            substring(
            string(year(mdfe.mdfedtemissao),"9999"),3,2)             + 
            string(month(mdfe.mdfedtemissao),"99") + 
            string(vemite_cnpj,"99999999999999") + 
            string(modelo-documento,"99") + 
            string(int(mdfe.mdfeserie),"999") + 
            string(mdfe.mdfenumero,   "999999999") +
            string(mdfe_forma_emissao,"9") +
            string(mdfe.mdfecod,"99999999").

/**
message mdfe_chave. pause.
**/

/**mdfe_chave =  "5206043300991100250655012000000780026730161". **/
mdfe_dv =  string(modulo11(mdfe_chave),"9").
mdfe_chave = mdfe_chave + mdfe_dv.



