/* 05012022 helio iepro */

def input param poperacao as char.
def input-output param vsel as dec.
def input-output param vabe as dec.
def input param pmessage as log. 

{iep/tfilsel.i}

def var vcidcod like munic.cidcod.            
find first ttfiltros.
            
pause 0 before-hide.
hide message no-pause.
def var vtpcontrato as char.

if pmessage then message "filtrando contratos...".

empty temp-table ttcontrato.
empty temp-table ttparcela.    

if ttfiltros.clicod <> 0
then do:
    for each contrato where contrato.clicod = ttfiltros.clicod no-lock.
        find first ttcontrato where 
                       ttcontrato.clicod  = contrato.clicod and
            ttcontrato.contnum = contrato.contnum no-lock no-error.
        if avail ttcontrato then next. 
        find first titprotesto where
            titprotesto.operacao = poperacao and
            titprotesto.contnum  = contrato.contnum 
            no-lock no-error.
        if avail titprotesto then next.

        run iep/pavalctrsel.p (poperacao,
                            contrato.contnum,no,input-output vsel, input-output vabe).
    end.
end.
else do:
    
 if ttfiltros.dtemiini = ?
 then for each titulo where 
            titulo.titnat = no and 
            titulo.titdtpag = ? and  
            titulo.titdtven >= today - ttfiltros.diasatrasmax and
            titulo.titdtven <= today - ttfiltros.diasatrasmin
            no-lock.
    
    find contrato where contrato.contnum = int(titulo.titnum) no-lock no-error.
    if not avail contrato
    then next.
    /* teste comarca */
    
        if ttfiltros.comarca <> 0
        then do:
        
            find clien of contrato no-lock.
            
            find first munic where munic.cidnom = clien.cidade[1] no-lock no-error.
            if not avail munic
            then find first munic where munic.cidnom = "PORTO ALEGRE" no-lock no-error.
        
            if avail munic and munic.cidcod <> ? 
            then vcidcod = munic.cidcod.
            else vcidcod = 4314902.
            if vcidcod <> ttfiltros.comarca
            then next.
                
        end.
        
    /**/
    vtpcontrato = if contrato.modcod = "CRE"
                  then if contrato.tpcontrato = "" then "C" else contrato.tpcontrato
                  else "".

    if (contrato.modcod = (if ttfiltros.modcod = ""  
                          then contrato.modcod
                          else if  lookup(contrato.modcod,ttfiltros.modcod) = 0
                               then ?
                               else entry(lookup(contrato.modcod,ttfiltros.modcod),ttfiltros.modcod))) and
       (vtpcontrato = (if ttfiltros.tpcontrato = "" or contrato.modcod  <> "CRE" 
                       then vtpcontrato
                       else if  lookup(vtpcontrato,ttfiltros.tpcontrato) = 0
                            then ?
                            else entry(lookup(vtpcontrato,ttfiltros.tpcontrato),ttfiltros.tpcontrato))) 
    then.
    else next.


    if ttfiltros.dtemiini <> ?
    then do:
        if contrato.dtinicial >= ttfiltros.dtemiini and 
           contrato.dtinicial <= ttfiltros.dtemimax 
        then.
        else next.
    end.

    find first ttcontrato where 
                       ttcontrato.clicod  = contrato.clicod and
            ttcontrato.contnum = contrato.contnum no-lock no-error.
    if avail ttcontrato then next. 
    find first titprotesto where
        titprotesto.operacao = poperacao and
        titprotesto.contnum  = contrato.contnum 
        no-lock no-error.
    if avail titprotesto then next.

    run iep/pavalctrsel.p (poperacao,
                            contrato.contnum,no,input-output vsel, input-output vabe).
            hide message no-pause.
            message "filtrando contratos..." vsel "max: " ttfiltros.qtdsel " - filtrado:" vabe.

    find first ttcontrato where 
                ttcontrato.clicod  = contrato.clicod and
                ttcontrato.contnum = int(titulo.titnum)
                        no-lock no-error.

    if avail ttcontrato and (vsel = 1 or (vsel < 100 and vsel mod 10 = 0) or (vsel > 100 and vsel mod 100  = 0))
    then do:
        if pmessage
        then do:
            hide message no-pause.
            message "filtrando contratos..." vsel "max: " ttfiltros.qtdsel " - filtrado:" vabe.
        end.            
    end.
    
    if vsel >= ttfiltros.qtdsel then leave.

        
 end.
 else do:
  for each modal where modal.modcod = "CRE" or modal.modcod = "CP0" or modal.modcod = "CP1" or modal.modcod = "CPN" no-lock. 
     
  for each titulo use-index Por-Mod-emi where titulo.titnat = no and 
        titulo.titdtpag = ? and 
        titulo.modcod = modal.modcod and 
        titulo.titdtemi >= ttfiltros.dtemiini and
        titulo.titdtemi <= ttfiltros.dtemimax and
        titulo.titdtven >= today - ttfiltros.diasatrasmax and
        titulo.titdtven <= today - ttfiltros.diasatrasmin 
        no-lock.
    find contrato where contrato.contnum = int(titulo.titnum) no-lock no-error.
    if not avail contrato
    then next.
    vtpcontrato = if contrato.modcod = "CRE"
                  then if contrato.tpcontrato = "" then "C" else contrato.tpcontrato
                  else "".

        if ttfiltros.comarca <> 0
        then do:
        
            find clien of contrato no-lock.
            
            find first munic where munic.cidnom = clien.cidade[1] no-lock no-error.
            if not avail munic
            then find first munic where munic.cidnom = "PORTO ALEGRE" no-lock no-error.
        
            if avail munic and munic.cidcod <> ? 
            then vcidcod = munic.cidcod.
            else vcidcod = 4314902.
            if vcidcod <> ttfiltros.comarca
            then next.
                
        end.

    if (contrato.modcod = (if ttfiltros.modcod = ""  
                          then contrato.modcod
                          else if  lookup(contrato.modcod,ttfiltros.modcod) = 0
                               then ?
                               else entry(lookup(contrato.modcod,ttfiltros.modcod),ttfiltros.modcod))) and
       (vtpcontrato = (if ttfiltros.tpcontrato = "" or contrato.modcod  <> "CRE" 
                       then vtpcontrato
                       else if  lookup(vtpcontrato,ttfiltros.tpcontrato) = 0
                            then ?
                            else entry(lookup(vtpcontrato,ttfiltros.tpcontrato),ttfiltros.tpcontrato))) 
    then.
    else next.

    
    find first ttcontrato where ttcontrato.contnum = contrato.contnum no-lock no-error.
    if avail ttcontrato then next. 
    
    find first titprotesto where
        titprotesto.operacao = poperacao and
        titprotesto.contnum  = contrato.contnum 
        no-lock no-error.
    if avail titprotesto then next.
    
    run iep/pavalctrsel.p (poperacao,
                            contrato.contnum,no,input-output vsel, input-output vabe).

    find first ttcontrato where ttcontrato.contnum = int(titulo.titnum)
                        no-lock no-error.

    if avail ttcontrato and (vsel = 1 or (vsel < 100 and vsel mod 10 = 0) or (vsel > 100 and vsel mod 100  = 0))
    then do:
        if pmessage
        then do:
            hide message no-pause.
            message "filtrando contratos..." vsel "max: " ttfiltros.qtdsel " - filtrado:" vabe.
        end.
    end.
    if vsel >= ttfiltros.qtdsel then leave.
        
  end.
  end.
 end.
end.
