
def input parameter par-rec as recid.
def input parameter par-operacao as char.
def input parameter vdtref  as date.
def input parameter vtpcontrato as char.
def input parameter par-valor as dec.
def input parameter par-oricobcod as int.
def input parameter par-cobcod as int.

def buffer bposcart  for poscart.
vdtref = date(month(vdtref),01,year(vdtref)).

def var vrec1 as recid.
def var vrec  as recid.
        
    find titulo where recid(titulo) = par-rec no-lock.
    if titulo.contnum = ? 
    then do on error undo.
        find current titulo exclusive no-wait no-error.
        if avail titulo
        then do:
            titulo.contnum = int(titulo.titnum).
            find current titulo no-lock.
        end.    
        else do:
            find titulo where recid(titulo) = par-rec no-lock.
        end.
    end.    
    
    
    vrec1 = ?.    
    if par-oricobcod <> par-cobcod
    then do on error undo:
        create poshiscart.
        poshiscart.contnum = titulo.contnum.
        poshiscart.titpar  = titulo.titpar.
        poshiscart.dtinc  = today.
        poshiscart.hrinc  = time.
        poshiscart.opera = "SAIDA".
        poshiscart.dtref  = vdtref.
        poshiscart.valor  = par-valor.
        poshiscart.cobcod = par-oricobcod.
        
        vrec1 = recid(poshiscart).
    end. 
    do on error undo:
    create poshiscart. 
    poshiscart.contnum = titulo.contnum. 
    poshiscart.titpar  = titulo.titpar.
    poshiscart.dtinc  = today. 
    poshiscart.hrinc  = time.
    poshiscart.opera  = par-operacao. 
    poshiscart.dtref  = vdtref. 
    poshiscart.valor  = par-valor. 
    poshiscart.cobcod = par-cobcod.
    vrec = recid(poshiscart).
    end.
        
    if vrec1 <> ?
    then do:
        run geraposcart (vrec1).
    end.
    run geraposcart (vrec).                        
                     


procedure geraposcart.

def input parameter par-rec as recid.

find poshiscart where recid(poshiscart) = par-rec no-lock. 

vdtref = date(month(vdtref),01,year(vdtref)).

    find first poscart where 
            poscart.dtref  = vdtref 
        no-lock no-error.
    if not avail poscart
    then do:
        /**
        hide message no-pause.
        message "carteira, gerando saldos deste mes... Aguarde.....".
        
        for each bposcart where 
          bposcart.dtref = date(month(vdtref - 1),01,year(vdtref - 1)) 
          and bposcart.saldo <> 0
          no-lock
          on error undo.
           find first poscart where 
                poscart.dtref  = vdtref and
                poscart.dtvenc = bposcart.dtvenc and
                poscart.etbcod = bposcart.etbcod and
                poscart.modcod = bposcart.modcod and
                poscart.tpcontrato = bposcart.tpcontrato and
                poscart.cobcod = bposcart.cobcod
            no-lock no-error.
            if not avail poscart
            then do:
                create poscart.
                poscart.dtref  = vdtref.
                poscart.dtvenc = bposcart.dtvenc.
                poscart.etbcod = bposcart.etbcod .
                poscart.modcod = bposcart.modcod .
                poscart.tpcontrato = bposcart.tpcontrato.
                poscart.cobcod = bposcart.cobcod.
                poscart.saldoanterior = bposcart.saldo.
                poscart.saldo         = bposcart.saldo.
            end.
        end.
        **/
    end.   
do on error undo:
   find first poscart where 
        poscart.dtref  = vdtref and
        poscart.dtvenc = date(month(titulo.titdtven),01,year(titulo.titdtven)) and
        poscart.etbcod = titulo.etbcod and
        poscart.modcod = titulo.modcod and
        poscart.tpcontrato = vtpcontrato and
        poscart.cobcod  = poshiscart.cobcod
    exclusive no-wait no-error.
    if not avail poscart
    then do:
        if locked poscart
        then return.
        create poscart.
        poscart.dtref  = vdtref.
        poscart.dtvenc = date(month(titulo.titdtven),01,year(titulo.titdtven)).
        poscart.etbcod = titulo.etbcod.
        poscart.modcod = titulo.modcod.
        poscart.tpcontrato = vtpcontrato.
        poscart.cobcod  = poshiscart.cobcod.
        
    end.
    
    if poshiscart.operacao = "emissao"
    then  poscart.emissao       = poscart.emissao + par-valor.
    if poshiscart.operacao = "pagamento"
    then poscart.pagamento      = poscart.pagamento + par-valor.

    if poshiscart.operacao = "ENTRADA"
    then  poscart.entradas       = poscart.entradas + par-valor.
    if poshiscart.operacao = "SAIDA"
    then poscart.saida      = poscart.saida + par-valor.
                                                  
    poscart.saldo         =   poscart.saldoanterior 
                            + poscart.emissao 
                            - poscart.pagamento 
                            + poscart.entradas 
                            - poscart.saidas.
    
end.

end procedure.

