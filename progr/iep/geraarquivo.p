def input param poperacao as char.
def input param pacao     as char.
def output param parquivorecid as recid.
def output param parquivo as char.
def output param premessa as int.

def var vseqdia as int.
def var pdtretorno  as date.

def var vano as char.
vano = substring(string(year(today),"9999"),3,2).


if pacao = "REMESSA" 
then do on error undo: 
    find last titprotremessa where 
            titprotremessa.operacao = poperacao and
            titprotremessa.acao     = "REMESSA" and
            titprotremessa.dtinc    = today
        no-lock no-error.
    if avail titprotremessa
    then vseqdia = titprotremessa.seqdia + 1.
    else vseqdia = 1.
    if vseqdia = 10 
    then return.    
                        
    parquivo    = "BY74" + string(day(today),"99") + string(month(today),"99") + "." + vano + string(vseqdia).
    
    
    find last titprotremessa use-index titprotremessaPRI where 
            titprotremessa.operacao = poperacao 
        no-lock no-error.
    if avail titprotremessa
    then premessa = titprotremessa.remessa + 1.
    else premessa = 1.

    create titprotremessa.
    parquivorecid = recid(titprotremessa).
    titprotremessa.operacao = poperacao.
    titprotremessa.dtinc    = today.
    titprotremessa.hrinc    = time.
    titprotremessa.seqdia   = vseqdia.
    titprotremessa.acao     = pacao.
    titprotremessa.remessa  = premessa.
    parquivorecid = recid(titprotremessa). 
end.    

if pacao = "DESISTENCIA"
then do on error undo: 
    find last titprotremessa where 
            titprotremessa.operacao = poperacao and
            titprotremessa.acao     = pacao     and
            titprotremessa.dtinc    = today
        no-lock no-error.
    if avail titprotremessa
    then vseqdia = titprotremessa.seqdia + 1.
    else vseqdia = 1.
    if vseqdia = 10
    then return.    
                        
    parquivo    = "DPY74" + string(day(today),"99") + string(month(today),"99") + "." + vano + string(vseqdia).

end.
if pacao = "AUT.DESISTENCIA"
then do on error undo: 
    find last titprotremessa where 
            titprotremessa.operacao = poperacao and
            titprotremessa.acao     = pacao     and
            titprotremessa.dtinc    = today
        no-lock no-error.
    if avail titprotremessa
    then vseqdia = titprotremessa.seqdia + 1.
    else vseqdia = 1.
    if vseqdia = 10
    then return.    
                        
    parquivo    = "ADY74" + string(day(today),"99") + string(month(today),"99") + "." + vano + string(vseqdia).

end.

if pacao = "CANCELAMENTO"
then do on error undo: 
    find last titprotremessa where 
            titprotremessa.operacao = poperacao and
            titprotremessa.acao     = pacao     and
            titprotremessa.dtinc    = today
        no-lock no-error.
    if avail titprotremessa
    then vseqdia = titprotremessa.seqdia + 1.
    else vseqdia = 1.
    if vseqdia = 10
    then return.    
                        
    parquivo    = "CPY74" + string(day(today),"99") + string(month(today),"99") + "." + vano + string(vseqdia).

end.
if pacao = "AUT.CANCELAMENTO"
then do on error undo: 
    find last titprotremessa where 
            titprotremessa.operacao = poperacao and
            titprotremessa.acao     = pacao     and
            titprotremessa.dtinc    = today
        no-lock no-error.
    if avail titprotremessa
    then vseqdia = titprotremessa.seqdia + 1.
    else vseqdia = 1.
    if vseqdia = 10
    then return.    
                        
    parquivo    = "ACY74" + string(day(today),"99") + string(month(today),"99") + "." + vano + string(vseqdia).

end.


                                              


if pacao = "confirmacao"
then do on error undo:

    find last titprotretorno where 
            titprotretorno.operacao = poperacao and
            titprotretorno.acao     = pacao     
        no-lock no-error.
    if avail titprotretorno
    then pdtretorno = if titprotretorno.dtretorno = today
                      then today 
                      else titprotretorno.dtretorno + 1.
    else pdtretorno = today.
 
    if avail titprotretorno
    then message pacao titprotretorno.dtretorno pdtretorno.
    else message pacao pdtretorno.

    
    find last titprotretorno where 
            titprotretorno.operacao = poperacao and
            titprotretorno.acao     = pacao     and
            titprotretorno.dtretorno    = pdtretorno
        exclusive-lock no-error.
    if avail titprotretorno
    then  vseqdia = 1. /*titprotretorno.seqdia + 1. */
    else do:
        create titprotretorno.
        
        titprotretorno.operacao = poperacao.
        titprotretorno.dtretorno = pdtretorno.
        vseqdia = 1.
        titprotretorno.seqdia   = vseqdia.
        titprotretorno.acao     = pacao.
        
    end.        
    if vseqdia = 10
    then return.    
                        
    parquivo    = "CY74" + string(day(pdtretorno),"99") + string(month(pdtretorno),"99") + "." + vano + string(vseqdia).

    titprotretorno.dtinc    = today.
    titprotretorno.hrinc    = time.
    parquivorecid = recid(titprotretorno).
end.
                                              

if pacao = "RETORNO"
then do on error undo: 

    find last titprotretorno where 
            titprotretorno.operacao = poperacao and
            titprotretorno.acao     = pacao     
        no-lock no-error.
    if avail titprotretorno
    then pdtretorno = if titprotretorno.dtretorno = today
                      then today 
                      else titprotretorno.dtretorno + 1.
    else pdtretorno = today.
 
    if avail titprotretorno
    then message pacao titprotretorno.dtretorno pdtretorno.
    else message pacao pdtretorno.

        
    find last titprotretorno where 
            titprotretorno.operacao = poperacao and
            titprotretorno.acao     = pacao     and
            titprotretorno.dtretorno    = pdtretorno
        exclusive-lock no-error.
    if avail titprotretorno
    then  vseqdia = 1. /*titprotretorno.seqdia + 1. */
    else do:
        create titprotretorno.
        
        titprotretorno.operacao = poperacao.
        titprotretorno.dtretorno = pdtretorno.
        vseqdia = 1.
        titprotretorno.seqdia   = vseqdia.
        titprotretorno.acao     = pacao.
        
    end.        
    if vseqdia = 10
    then return.    
                        
    parquivo    = "RY74" + string(day(pdtretorno),"99") + string(month(pdtretorno),"99") + "." + vano + string(vseqdia).

    titprotretorno.dtinc    = today.
    titprotretorno.hrinc    = time.
    parquivorecid = recid(titprotretorno).
                        

end.
 
