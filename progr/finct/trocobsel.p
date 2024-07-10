/* helio 11072023 - 527008 ARQUIVO CESSÃO FIDC */
/* 26112021 helio venda carteira */
{admcab.i}

def input   param vcobcodori  like cobra.cobcod.
def input   param vcobcoddes  like cobra.cobcod.

def var vnfe-chave  as char.

def buffer btitulo for titulo.

def shared temp-table ttfiltros no-undo
    field percdesagio   as dec
    field valormax      as dec format ">>>>,>>>,>>9.99" init 9999999999.99
    field vlf_acrescimo as dec
    field txjuroini     as dec
    field txjurofim     as dec
    field dtemiini      as date format "99/99/9999"
    field dtemifim      as date format "99/99/9999"
    field modcod        as char format "x(25)"
    field tpcontrato    as char format "x(12)"
    field qtdparcpag    as int format "99" init 99
    field diasatraso    as int format "999"
    field somentenfe    as log format "Sim/Nao" init yes
    /* helio 11072023 */
    field vendacnpj     as log format "Sim/Nao" init no
    field valormincompra  as dec init 10
    field cpfzerado     as log format "Sim/Nao" init no .

def shared temp-table ttcontrato no-undo
    field marca     as log format "*/ "
    field contnum   like contrato.contnum    format ">>>>>>>>9"
    field dtemi     like contrato.dtinicial
    field vlabe     as dec
    field vlatr     as dec
    field vlpag     as dec
    field cobcod    like titulo.cobcod
    field vlf_principal as dec
    field vlf_acrescimo as dec
    field vlpre     as dec
    field qtdpag    as int
    field diasatraso    as int format "999"
    index contnum is unique primary contnum asc.

find first ttfiltros.

update
    valormax        label "Valor Maximo de Pesquisa" colon 35
    ttfiltros.vlf_acrescimo   label "valor Minimo de Acrescimo" colon 35    
    percdesagio     label "Perc Desagio (Simulacao)" colon 35
    txjuroini      label "Juros Contrato de" colon 35 txjurofim label "ate"
    dtemiini       label "emissao de" colon 35 dtemifim label "ate"
    ttfiltros.diasatraso      label "dias de atraso maximo pesquisado" colon 35
    qtdparcpag       label "qtd parcelas pagas no contrato" colon 35 
        
        with frame fcab
        row 4 centered
        side-labels
        title " FILTRO ".

    update ttfiltros.modcod colon 35 label "modalidades"
        help "informe modalidades separadas por virgula"
        with frame fcab.
    if lookup ("CRE",ttfiltros.modcod) > 0
    then update ttfiltros.tpcontrato colon 35 label "tp"
                help "C - CDC NORMAL, N - NOVACAO"  /* , FA - FEIRAO ANTIGO, F - FEIRAO , L - L&P*/
                with frame fcab.
    else ttfiltros.tpcontrato = "".
    
    update
        ttfiltros.somentenfe label "somente contratos com chave nfe" colon 35
        ttfiltros.vendacnpj label "Venda para cnpj" colon 35
        ttfiltros.valormincompra label "Valor de compra maior que" colon 35
        ttfiltros.cpfzerado label "Cadastrado com CPF zerado" colon 35
            with frame fcab.
                
                
    /**/                
            
def var vsel as int.
def var vabe as dec.
pause 0 before-hide.
hide message no-pause.
def var vtpcontrato as char.
message "filtrando contratos...".
empty temp-table ttcontrato.

if ttfiltros.dtemiini = ?
then for each titulo where titnat = no and titdtpag = ? and titulo.titdtven > today - ttfiltros.diasatraso and cobcod = vcobcodori no-lock.
    
    find contrato where contrato.contnum = int(titulo.titnum) no-lock no-error.
    if not avail contrato
    then next.
    
    /* ID 55941 - Contratos filial 200 - Exportador. */
    if contrato.etbcod = 200 then next.
    /* helio 15022024 - PROJETO REFIN - Retirar Filial 982 */
    if contrato.etbcod = 982 then next.
    
    
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

    vnfe-chave  = "".
    find first contnf where contnf.contnum = contrato.contnum
                  AND contnf.etbcod  = contrato.etbcod 
                  no-lock no-error.
    if avail contnf
    then do:
        find first plani where plani.placod = contnf.placod
                       and plani.etbcod = contnf.etbcod
                       and plani.serie  = contnf.notaser
                     no-lock no-error.
        if avail plani
        then             
        if plani.ufdes <> "" and length(plani.ufdes) = 44
        then do:
            vnfe-chave = plani.ufdes.
        end.        
    end.
    if ttfiltros.somentenfe
    then do:
        if vnfe-chave = ""
        then next.
    end.    

    if ttfiltros.dtemiini <> ?
    then do:
        if contrato.dtinicial >= ttfiltros.dtemiini and 
           contrato.dtinicial <= ttfiltros.dtemifim 
        then.
        else next.
    end.
    if ttfiltros.txjuroini <> ? and ttfiltros.txjurofim > 0 
    then do:
       if contrato.txjuro >= ttfiltros.txjuroini and
          contrato.txjuro <= ttfiltros.txjurofim
       then.
       else next.
    end.
    if ttfiltros.vendacnpj = no
    then do:
        find clien where clien.clicod = contrato.clicod no-lock.
        if clien.tippes = no
        then next.
    end.

    if ttfiltros.valormincompra > 0
    then do:
        if contrato.vltotal <= ttfiltros.valormincompra
        then next.
    end.

    if ttfiltros.cpfzerado = no
    then do:
        find clien where clien.clicod = contrato.clicod no-lock.
        if clien.ciccgc = ? or clien.ciccgc = ""
        then next.
    end.
    
    find first ttcontrato where ttcontrato.contnum = int(titulo.titnum) no-lock no-error.
    if avail ttcontrato then next.

    run avaliaContrato.

    find first ttcontrato where ttcontrato.contnum = int(titulo.titnum) no-lock no-error.
    if vabe >= ttfiltros.valormax
    then leave.

    if avail ttcontrato and (vsel = 1 or (vsel < 100 and vsel mod 10 = 0) or (vsel > 100 and vsel mod 100  = 0))
    then do:
        hide message no-pause.
        message "filtrando contratos..." vsel "Valor Maximo" ttfiltros.valormax " - filtrado:" vabe.
    end.
        
end.
else do:
 for each modal where modal.modcod = "CRE" or modal.modcod = "CP0" or modal.modcod = "CP1" or modal.modcod = "CPN" no-lock. 
     
 for each titulo use-index Por-Mod-emi where titulo.titnat = no and 
        titulo.titdtpag = ? and 
        titulo.modcod = modal.modcod and 
        titulo.titdtemi >= ttfiltros.dtemiini and
        titulo.titdtemi <= ttfiltros.dtemifim and
        titulo.titdtven > today - ttfiltros.diasatraso and 
        titulo.cobcod = vcobcodori no-lock.
    find contrato where contrato.contnum = int(titulo.titnum) no-lock no-error.
    if not avail contrato
    then next.
    
    /* ID 55941 - Contratos filial 200 - Exportador. */
    if contrato.etbcod = 200 then next.

    if ttfiltros.vendacnpj = no
    then do:
        find clien where clien.clicod = contrato.clicod no-lock.
        if clien.tippes = no
        then next.
    end.

    if ttfiltros.valormincompra > 0
    then do:
        if contrato.vltotal <= ttfiltros.valormincompra
        then next.
    end.

    if ttfiltros.cpfzerado = no
    then do:
        find clien where clien.clicod = contrato.clicod no-lock.
        if clien.ciccgc = ? or clien.ciccgc = ""
        then next.
    end.
    
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

    if ttfiltros.txjuroini > 0 and ttfiltros.txjurofim > 0 
    then do:
       if contrato.txjuro >= ttfiltros.txjuroini and
          contrato.txjuro <= ttfiltros.txjurofim
       then.
       else next.
    end.
    
    find first ttcontrato where ttcontrato.contnum = int(titulo.titnum) no-lock no-error.
    if avail ttcontrato then next.

    run avaliaContrato.

    find first ttcontrato where ttcontrato.contnum = int(titulo.titnum) no-lock no-error.
    if vabe >= ttfiltros.valormax
    then leave.

    if avail ttcontrato and (vsel = 1 or (vsel < 100 and vsel mod 10 = 0) or (vsel > 100 and vsel mod 100  = 0))
    then do:
        hide message no-pause.
        message "filtrando contratos..." vsel "Valor Maximo" ttfiltros.valormax " - filtrado:" vabe.
    end.
        
 end.
 end.
end.

hide message no-pause.
message "filtrados contratos..." vsel "Valor Maximo" ttfiltros.valormax " - valor:" vabe.

hide frame fcab no-pause.


procedure avaliaContrato.

do on error undo:

    create ttcontrato.
    ttcontrato.contnum  = contrato.contnum.
    ttcontrato.dtemi    = contrato.dtinicial.
    ttcontrato.cobcod   = titulo.cobcod.
    ttcontrato.marca    = ?.

    for each btitulo where btitulo.empcod = 19 and btitulo.titnat = no and     
            btitulo.etbcod = contrato.etbcod and btitulo.modcod = contrato.modcod and
            btitulo.clifor = contrato.clicod and btitulo.titnum = string(contrato.contnum)
            no-lock.
        if btitulo.titpar = 0 then next.
        if vcobcodori = 1 
        then do:
            if btitulo.cobcod = 1 or btitulo.cobcod = 2
            then.
            else ttcontrato.marca = no.
        end. 
        else if btitulo.cobcod <> vcobcodori
             then ttcontrato.marca = no. 

        if btitulo.titsit = "PAG"
        then do:
            ttcontrato.vlpag = ttcontrato.vlpag + btitulo.titvlcob.
            ttcontrato.qtdpag = ttcontrato.qtdpag + 1.
        end.
        if btitulo.titsit = "LIB"
        then do:
            ttcontrato.vlf_principal = ttcontrato.vlf_principal + btitulo.vlf_principal.
            ttcontrato.vlf_acrescimo = ttcontrato.vlf_acrescimo + btitulo.vlf_acrescimo.
            ttcontrato.vlabe = ttcontrato.vlabe + btitulo.titvlcob.
            ttcontrato.vlpre = ttcontrato.vlpre + (btitulo.titvlcob -
                                                    (btitulo.titvlcob * ttfiltros.percdesagio / 100)).
            if btitulo.titdtven < today
            then do:
                ttcontrato.vlatr = ttcontrato.vlatr + btitulo.titvlcob.
                ttcontrato.diasatraso = max(ttcontrato.diasatraso,today - btitulo.titdtven) .
            end.    
        end.      
    end.
    
    if ttfiltros.qtdparcpag = 0 or ttfiltros.qtdparcpag = 99
    then do:
        if ttfiltros.qtdparcpag = 0
        then if ttcontrato.vlpag > 0 
             then ttcontrato.marca = no.
    end.    
    else do:
        if ttfiltros.qtdparcpag > 0 and ttcontrato.vlpag = 0
        then ttcontrato.marca = no.
        else do:
            if ttfiltros.qtdparcpag > 0 and ttcontrato.qtdpag /*<= helio 050122 alterado para >=*/ >= ttfiltros.qtdparcpag
            then. 
            else ttcontrato.marca = no.
        end.
    end.
    if ttfiltros.diasatraso = 0
    then do:
        if ttcontrato.diasatraso > 0
        then ttcontrato.marca = no.
    end.
    else do:
        if ttfiltros.diasatraso > 0 and ttcontrato.diasatraso > ttfiltros.diasatraso
        then ttcontrato.marca = no.
    end.    
        
    
            
    if ttcontrato.vlabe > 0 and
       ttcontrato.vlf_acrescimo >= ttfiltros.vlf_acrescimo and
       ttcontrato.marca = ? 
    then ttcontrato.marca = yes.   

    
    if ttcontrato.marca = no or
       ttcontrato.marca = ?
    then delete ttcontrato.
    else do:
        vsel = vsel + 1.
        vabe = vabe + ttcontrato.vlabe.
    end.    

end.

end procedure.


