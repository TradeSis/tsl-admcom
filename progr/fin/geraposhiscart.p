
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
    if titulo.titcod = ? 
    then do on error undo.
        find current titulo exclusive.
        titulo.titcod = next-value(titcod).
        find current titulo no-lock.
    end.    
    
    vrec1 = ?.    
    if par-oricobcod <> par-cobcod
    then do on error undo:
        create poshiscart.
        poshiscart.titcod = titulo.titcod.
        poshiscart.dtinc  = today.
        poshiscart.hrinc  = time.
        poshiscart.opera = "SAIDA".
        poshiscart.dtref  = vdtref.
        poshiscart.valor  = par-valor.
        poshiscart.cobcod = par-oricobcod.
        
        vrec1 = recid(poshiscart).
    end. 
    
    create poshiscart. 
    poshiscart.titcod = titulo.titcod.  
    poshiscart.dtinc  = today. 
    poshiscart.hrinc  = time.
    poshiscart.opera  = par-operacao. 
    poshiscart.dtref  = vdtref. 
    poshiscart.valor  = par-valor. 
    poshiscart.cobcod = par-oricobcod.
    vrec = recid(poshiscart).
        
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
        for each bposcart where 
          bposcart.dtref = date(month(vdtref - 1),01,year(vdtref - 1)) no-lock.
           find first poscart where 
                poscart.dtref  = vdtref and
                poscart.dtvenc = bposcart.dtvenc and
                poscart.etbcod = bposcart.etbcod and
                poscart.modcod = bposcart.modcod and
                poscart.tpcontrato = bposcart.tpcontrato and
                poscart.cobcod = bposcart.cobcod
            no-error.
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
       
    end.   

   find first poscart where 
        poscart.dtref  = vdtref and
        poscart.dtvenc = date(month(titulo.titdtven),01,year(titulo.titdtven)) and
        poscart.etbcod = titulo.etbcod and
        poscart.modcod = titulo.modcod and
        poscart.tpcontrato = vtpcontrato 
    no-error.
    if not avail poscart
    then do:
        create poscart.
        poscart.dtref  = vdtref.
        poscart.dtvenc = date(month(titulo.titdtven),01,year(titulo.titdtven)).
        poscart.etbcod = titulo.etbcod.
        poscart.modcod = titulo.modcod.
        poscart.tpcontrato = vtpcontrato.
        
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
    

end procedure.
