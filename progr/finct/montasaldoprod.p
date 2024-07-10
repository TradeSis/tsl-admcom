/*26042021 helio*/
def input param vdtreffim as date.
def var vdtref as date.
def var vdtant as date.
def buffer bctbposprod for ctbposprod.
def var vproduto as char.

vdtref = date(month(vdtreffim),01,year(vdtreffim)).
message vdtref. pause 1.
for each ctbposprod where ctbposprod.dtref = vdtref.
    delete ctbposprod.
end.
        vdtant = date(month(vdtref),01,year(vdtref)) - 1.
        vdtant = date(month(vdtant),01,year(vdtant)).

def var vt as int.
pause 0 before-hide.
vt = 0.    
    
        hide message no-pause.
        message "carteira, gerando saldos deste mes... Aguarde....." vdtant "ref" vdtref.
        pause 2.    
        for each bctbposprod where 
          bctbposprod.dtref = vdtant
          no-lock.

           find first ctbposprod where 
                ctbposprod.dtref  = vdtref and
                /*ctbposprod.dtvenc = bctbposprod.dtvenc and**/
                ctbposprod.etbcod = bctbposprod.etbcod and
                ctbposprod.modcod = bctbposprod.modcod and
                ctbposprod.tpcontrato = bctbposprod.tpcontrato and
                ctbposprod.cobcod = bctbposprod.cobcod and
                ctbposprod.produto = bctbposprod.produto
             no-error.
            if not avail ctbposprod
            then do:
                create ctbposprod.
                ctbposprod.dtref  = vdtref.
                /**ctbposprod.dtvenc = bctbposprod.dtvenc.**/
                ctbposprod.etbcod = bctbposprod.etbcod .
                ctbposprod.modcod = bctbposprod.modcod .
                ctbposprod.tpcontrato = bctbposprod.tpcontrato.
                ctbposprod.cobcod = bctbposprod.cobcod.
                ctbposprod.produto = bctbposprod.produto.
            end. 
            ctbposprod.saldo         = ctbposprod.saldo + bctbposprod.saldo.
    end.

for each ctbposhiscart where ctbposhiscart.dtref = vdtref /*and ctbposhiscart.dtrefsaida = ?*/  no-lock.

                   if vt = 14249121 or vt = 1 or vt mod 10000 = 0 then   disp vt ctbposhiscart.dtref ctbposhiscart.dtrefsaida 1.
            vt = vt + 1.
            
           run pegaproduto. 
    
           find first ctbposprod where 
                ctbposprod.dtref  = vdtref and
                ctbposprod.etbcod = ctbposhiscart.etbcod and
                ctbposprod.modcod = ctbposhiscart.modcod and
                ctbposprod.tpcontrato = ctbposhiscart.tpcontrato and
                ctbposprod.cobcod = ctbposhiscart.cobcod and
                ctbposprod.produto = vproduto
                
             no-error.
            if not avail ctbposprod
            then do:
                create ctbposprod.
                ctbposprod.dtref  = vdtref.
                ctbposprod.etbcod = ctbposhiscart.etbcod .
                ctbposprod.modcod = ctbposhiscart.modcod .
                ctbposprod.tpcontrato = ctbposhiscart.tpcontrato.
                ctbposprod.cobcod = ctbposhiscart.cobcod.
                ctbposprod.produto = vproduto.
            end. 
            ctbposprod.saldo   = ctbposprod.saldo   + ctbposhiscart.valor.
end.

/*
for each ctbposhiscart where ctbposhiscart.dtref = vdtref and ctbposhiscart.dtrefsaida > vdtref and ctbposhiscart.dtrefsaida <> ? no-lock.
                   if vt = 14249121 or vt = 1 or vt mod 10000 = 0 then   disp vt.
            vt = vt + 1.
 
           run pegaproduto. 

           find first ctbposprod where 
                ctbposprod.dtref  = vdtref and
                ctbposprod.etbcod = ctbposhiscart.etbcod and
                ctbposprod.modcod = ctbposhiscart.modcod and
                ctbposprod.tpcontrato = ctbposhiscart.tpcontrato and
                ctbposprod.cobcod = ctbposhiscart.cobcod and
                ctbposprod.produto = vproduto
             no-error.
            if not avail ctbposprod
            then do:
                create ctbposprod.
                ctbposprod.dtref  = vdtref.
                ctbposprod.etbcod = ctbposhiscart.etbcod .
                ctbposprod.modcod = ctbposhiscart.modcod .
                ctbposprod.tpcontrato = ctbposhiscart.tpcontrato.
                ctbposprod.cobcod = ctbposhiscart.cobcod.
                ctbposprod.produto = vproduto.
                
            end. 
            ctbposprod.saldo   = ctbposprod.saldo   + ctbposhiscart.valor.
end.
*/

for each ctbposhiscart where ctbposhiscart.dtrefsaida = vdtref no-lock.
                      
                    if vt = 14249121 or vt = 1 or vt mod 10000 = 0 then   disp vt ctbposhiscart.dtref ctbposhiscart.dtrefsaida 2.
            vt = vt + 1.
            
           run pegaproduto. 

           find first ctbposprod where 
                ctbposprod.dtref  = vdtref and
                ctbposprod.etbcod = ctbposhiscart.etbcod and
                ctbposprod.modcod = ctbposhiscart.modcod and
                ctbposprod.tpcontrato = ctbposhiscart.tpcontrato and
                ctbposprod.cobcod = ctbposhiscart.cobcod and
                ctbposprod.produto = vproduto
             no-error.
            if not avail ctbposprod
            then do:
                create ctbposprod.
                ctbposprod.dtref  = vdtref.
                ctbposprod.etbcod = ctbposhiscart.etbcod .
                ctbposprod.modcod = ctbposhiscart.modcod .
                ctbposprod.tpcontrato = ctbposhiscart.tpcontrato.
                ctbposprod.cobcod = ctbposhiscart.cobcod.
                ctbposprod.produto = vproduto.
            end. 
            ctbposprod.saldo   = ctbposprod.saldo   - ctbposhiscart.valorsaida.
            
    if ctbposhiscart.produto = ""
    then run ppp.
                     
end.

for each ctbposprod where ctbposprod.dtref = vdtref and saldo = 0.
    delete ctbposprod.
end    .



procedure pegaproduto.

    find ctbpostitprod where ctbpostitprod.contnum = ctbposhiscart.contnum no-lock no-error.
    if avail ctbpostitprod
    then do:
        vproduto = ctbpostitprod.produto.
        return.
    end.
    if ctbposhiscart.tpcontrato <> ""
    then do:
        vproduto =  if ctbposhiscart.tpcontrato = "F"
                    then "FEIRAO "
                    else if ctbposhiscart.tpcontrato = "N"
                         then "NOVACAO"
                         else if ctbposhiscart.tpcontrato = "L"
                              then "LP     "
                              else "".
        if vproduto <> ""
        then return.   
    end.    
    vproduto = "DESCONHECIDO".
    def var vcatcod as int.        
    find contrato where contrato.contnum = ctbposhiscart.contnum no-lock no-error.
    if avail contrato
    then do:
        find contrsite where contrsite.contnum = contrato.contnum no-lock no-error.
        if avail contrsite
        then do:
            vproduto = "Cre Digital".
        end.
        else do:
            if contrato.modcod begins "CP"
            then do:
                vproduto = "Emprestimos".
            end.
            else do:    
                find first contnf where 
                    contnf.etbcod = contrato.etbcod and
                    contnf.contnum = contrato.contnum 
                    no-lock no-error.
                if avail contnf 
                then do:
                    find first plani where
                        plani.etbcod = contnf.etbcod and
                        plani.placod = contnf.placod 
                        no-lock no-error. 
                    if avail plani
                    then do:
                        vcatcod = 0.
                        for each movim where movim.etbcod = plani.etbcod and
                                             movim.placod = plani.placod
                                             no-lock.
                            find produ of movim no-lock no-error.
                            if avail produ
                            then do:                    
                                if produ.catcod = 31 or produ.catcod = 41
                                then do:
                                    find categoria of produ no-lock.
                                    vproduto = caps(categoria.catnom).
                                    leave.
                                end.
                                else vcatcod = produ.catcod. 
                            end.
                        end.
                        if vproduto = "DESCONHECIDO"
                        then do:
                            find categoria where categoria.catcod = vcatcod no-lock no-error.
                            if avail categoria
                            then do:
                                vproduto = caps(categoria.catnom).
                            end.     
                        end.        
                    end.                                   
                end.          
            end.
        end.                     
    end.    
    if not avail ctbpostitprod
    then do on error undo:
        create ctbpostitprod.
        ctbpostitprod.contnum = ctbposhiscart.contnum.
        ctbpostitprod.produto = vproduto.
    end.    
    
end procedure.    


procedure ppp.

    do on error undo:
        find current  ctbposhiscart exclusive      no-error.
        if avail ctbposhiscart
        then ctbposhiscart.produto = vproduto. 
    
    end.

end.
