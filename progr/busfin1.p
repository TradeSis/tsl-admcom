
def input parameter vdti as date.
def input parameter vdtf as date.
def input parameter vetbcod like estab.etbcod.
def input parameter vclicod like clien.clicod. 

def var vdes as char format "x(30)".
def var vqtd-l as int.
def var vqtd-a as int.
form vdes no-label
    vqtd-l no-label
    vqtd-a no-label
    with frame f-disp no-box down.

def var vcobcod like fin.titulo.cobcod.    
vdes = "BUSCANDO TITULOS".
vqtd-a = 0.
vqtd-l = 0.
disp vdes with frame f-disp.  

def buffer etitulo for finloja.titulo.
def var vd as log.

if vclicod = 0
then do:
           
    for each finloja.caixa no-lock:
        find first fin.caixa where
                   fin.caixa.etbcod = finloja.caixa.etbcod and
                   fin.caixa.cxacod = finloja.caixa.cxacod
                   no-lock no-error.
        if not avail fin.caixa
        then do:
            create fin.caixa.
            buffer-copy finloja.caixa to fin.caixa.
        end.           
    end.

for each finloja.titulo where finloja.titulo.datexp >= vdti and
                              finloja.titulo.datexp <= vdtf no-lock:
                       
    vqtd-l = vqtd-l + 1.   
                    
    disp vqtd-l  with frame f-disp.
                             
    if finloja.titulo.etbcod <> vetbcod and
       finloja.titulo.etbcobra <> vetbcod
    then next.   
    vd = no.
    if vd = no 
    then do transaction:  
        vcobcod = 2.
        find fin.titulo 
             where fin.titulo.empcod = finloja.titulo.empcod and
                   fin.titulo.titnat = finloja.titulo.titnat and 
                   fin.titulo.modcod = finloja.titulo.modcod and 
                   fin.titulo.etbcod = finloja.titulo.etbcod and 
                   fin.titulo.clifor = finloja.titulo.clifor and 
                   fin.titulo.titnum = finloja.titulo.titnum and 
                   fin.titulo.titpar = finloja.titulo.titpar no-error.
        if not avail fin.titulo 
        then create fin.titulo. 
        else vcobcod = fin.titulo.cobcod.
        
        if fin.titulo.titsit <> "PAG"  
        then do: 
            {tt-titulo.i fin.titulo finloja.titulo}. 
            if finloja.titulo.cobcod <> vcobcod
            then fin.titulo.cobcod = vcobcod.
            
        end.
        vqtd-a = vqtd-a + 1.    
    end.  
    disp  vqtd-a  with frame f-disp.
end.
pause 0.
vdes = "BUSCANDO CONTRATOS".
vqtd-l = 0.
vqtd-a = 0.
  
down with frame f-disp.

disp vdes with frame f-disp.

for each finloja.contrato 
         where finloja.contrato.dtinicial >= vdti and
               finloja.contrato.dtinicial <= vdtf:  
                
    vqtd-l = vqtd-l + 1.   
                    
    disp vqtd-l  with frame f-disp.
 
    if finloja.contrato.etbcod <> vetbcod
    then next.            
                
    find fin.contrato 
         where fin.contrato.contnum = finloja.contrato.contnum no-error.
    if not avail fin.contrato
    then do transaction:
    
        create fin.contrato.
        {tt-contrato.i fin.contrato finloja.contrato}.
    
        vqtd-a = vqtd-a + 1.
    end.

    disp vqtd-a with frame f-disp.
    
end.

pause 0.

vdes = "BUSCANDO CONTNF".
vqtd-l = 0.
vqtd-a = 0.
 
down with frame f-disp.

disp vdes with frame f-disp row 10 color message overlay.

for each finloja.contrato 
         where finloja.contrato.dtinicial >= vdti and
               finloja.contrato.dtinicial <= vdtf:
                
    vqtd-l = vqtd-l + 1.   
                    
    disp vqtd-l  with frame f-disp.
 
    if finloja.contrato.etbcod <> vetbcod
    then next.            

    for each finloja.contnf 
        where finloja.contnf.etbcod  = finloja.contrato.etbcod and
              finloja.contnf.contnum = finloja.contrato.contnum:
                
        find fin.contnf 
            where fin.contnf.etbcod  = finloja.contnf.etbcod  and
                  fin.contnf.placod  = finloja.contnf.placod  and
                  fin.contnf.contnum = finloja.contnf.contnum no-error.
        
        if not avail fin.contnf
        then do transaction:
    
            create fin.contnf.
            {tt-contnf.i fin.contnf finloja.contnf}.
            vqtd-a = vqtd-a + 1.
        end.
        
    end.
    disp vqtd-a with frame f-disp.
end.
pause 0.

vdes = "BUSCANDO CHQ".
vqtd-a = 0.
vqtd-l = 0.
 
down with frame f-disp.
disp vdes with frame f-disp.

for each finloja.chq 
         where finloja.chq.datemi >= vdti and
               finloja.chq.datemi <= vdtf no-lock:
               
    vqtd-l = vqtd-l + 1.   
                    
    disp vqtd-l  with frame f-disp.
          
               
    find fin.chq where fin.chq.banco   = finloja.chq.banco   and
                       fin.chq.agencia = finloja.chq.agencia and
                       fin.chq.conta   = finloja.chq.conta   and
                       fin.chq.numero  = finloja.chq.numero no-error.
    if not avail fin.chq
    then do transaction:

        create fin.chq.
        {tt-chq.i fin.chq finloja.chq}
        vqtd-a = vqtd-a + 1.
    end.
    disp vqtd-a with frame f-disp.
end.
pause 0.
vdes = "BUSCANDO CHQTIT".
vqtd-l = 0.
vqtd-a = 0.

down with frame f-disp.
disp vdes with frame f-disp.
 
for each finloja.chq 
         where finloja.chq.datemi >= vdti and
               finloja.chq.datemi <= vdtf no-lock:
               
    vqtd-l = vqtd-l + 1.   
                    
    disp vqtd-l  with frame f-disp.
            
    for each finloja.chqtit of finloja.chq no-lock:

        if finloja.chqtit.etbcod <> vetbcod
        then next.
        
        find fin.chqtit 
             where fin.chqtit.titnat  = finloja.chqtit.titnat  and
                   fin.chqtit.modcod  = finloja.chqtit.modcod  and
                   fin.chqtit.etbcod  = finloja.chqtit.etbcod  and
                   fin.chqtit.clifor  = finloja.chqtit.clifor  and
                   fin.chqtit.titnum  = finloja.chqtit.titnum  and
                   fin.chqtit.titpar  = finloja.chqtit.titpar  and
                   fin.chqtit.banco   = finloja.chqtit.banco   and
                   fin.chqtit.agencia = finloja.chqtit.agencia and 
                   fin.chqtit.conta   = finloja.chqtit.conta   and 
                   fin.chqtit.numero  = finloja.chqtit.numero no-error.
                   
        if not avail fin.chqtit
        then do transaction:
            create fin.chqtit.
            {tt-chqtit.i fin.chqtit finloja.chqtit}
            vqtd-a = vqtd-a + 1.    
        end.
        
    end.
    disp vqtd-a with frame f-disp.
        
end.
pause 0.
vdes = "BUSCANDO DEPOSITO BANCARIO".
vqtd-l = 0.
vqtd-a = 0.

down with frame f-disp.
disp vdes with frame f-disp.

for each finloja.depban where finloja.depban.datexp >= vdti and
                              finloja.depban.datexp <= vdtf no-lock:
                              
    vqtd-l = vqtd-l + 1.   
                    
    disp vqtd-l  with frame f-disp.
    
    if finloja.depban.etbcod <> vetbcod
    then next.                          
                              
    find fin.depban where fin.depban.etbcod  = finloja.depban.etbcod  and
                          fin.depban.dephora = finloja.depban.dephora and
                          fin.depban.datexp  = finloja.depban.datexp no-error.
                          
                          
                          
    if not avail fin.depban
    then do transaction:

        create fin.depban.
        {tt-depban.i fin.depban finloja.depban}
    
        vqtd-a = vqtd-a + 1.
    end.

    disp vqtd-a with frame f-disp.

end.

pause 0.
vdes = "BUSCANDO DESPESAS/PREMIOS".
vqtd-l = 0.
vqtd-a = 0.

down with frame f-disp.
disp vdes with frame f-disp.


for each finloja.titluc where finloja.titluc.datexp >= vdti and
                              finloja.titluc.datexp <= vdtf
                                no-lock:
    
    vqtd-l = vqtd-l + 1.
    disp vqtd-l with frame f-disp.
    
    if finloja.titluc.etbcod <> vetbcod
    then next.
            if finloja.titluc.titsit = "PAG" or
               finloja.titluc.titsit = "AUT"
               or finloja.titluc.titsit = "BLO" 
            then
            do transaction:
                find fin.titluc where 
                     fin.titluc.empcod = finloja.titluc.empcod and
                     fin.titluc.titnat = finloja.titluc.titnat and
                     fin.titluc.modcod = finloja.titluc.modcod and
                     fin.titluc.etbcod = finloja.titluc.etbcod and
                     fin.titluc.clifor = finloja.titluc.clifor and
                     fin.titluc.titnum = finloja.titluc.titnum and
                     fin.titluc.titpar = finloja.titluc.titpar
                       no-error.
                if not avail fin.titluc
                then do:
                    create fin.titluc.
                    buffer-copy finloja.titluc to fin.titluc.
                end.
                else if finloja.titluc.titsit = "PAG" and
                        fin.titluc.titsit <> "PAG"
                then do:
                    buffer-copy finloja.titluc to fin.titluc.
                end.
                find current fin.titluc no-lock no-error.
                vqtd-a = vqtd-a + 1.
            end.
            
            disp vqtd-a with frame f-disp.
        end.
end.
else do:
for each finloja.titulo where 
         finloja.titulo.clifor = vclicod no-lock:
                       
    vqtd-l = vqtd-l + 1.   
                    
    disp vqtd-l  with frame f-disp.
                             
    if finloja.titulo.etbcod <> vetbcod and
       finloja.titulo.etbcobra <> vetbcod
    then next.   
    vd = no.
    if vd = no 
    then do transaction:  
        vcobcod = 2.
        find fin.titulo 
             where fin.titulo.empcod = finloja.titulo.empcod and
                   fin.titulo.titnat = finloja.titulo.titnat and 
                   fin.titulo.modcod = finloja.titulo.modcod and 
                   fin.titulo.etbcod = finloja.titulo.etbcod and 
                   fin.titulo.clifor = finloja.titulo.clifor and 
                   fin.titulo.titnum = finloja.titulo.titnum and 
                   fin.titulo.titpar = finloja.titulo.titpar no-error.
        if not avail fin.titulo 
        then create fin.titulo. 
        else vcobcod = fin.titulo.cobcod.
        
        if fin.titulo.titsit <> "PAG"  
        then do: 
            {tt-titulo.i fin.titulo finloja.titulo}. 
            if finloja.titulo.cobcod <> vcobcod
            then fin.titulo.cobcod = vcobcod.
            
        end.
        vqtd-a = vqtd-a + 1.    
    end.  
    disp  vqtd-a  with frame f-disp.
end.
pause 0.
vdes = "BUSCANDO CONTRATOS".
vqtd-l = 0.
vqtd-a = 0.
  
down with frame f-disp.

disp vdes with frame f-disp.

for each finloja.contrato where contrato.clicod = vclicod no-lock:
                
    vqtd-l = vqtd-l + 1.   
                    
    disp vqtd-l  with frame f-disp.
 
    if finloja.contrato.etbcod <> vetbcod
    then next.            
                
    find fin.contrato 
         where fin.contrato.contnum = finloja.contrato.contnum no-error.
    if not avail fin.contrato
    then do transaction:
    
        create fin.contrato.
        {tt-contrato.i fin.contrato finloja.contrato}.
    
        vqtd-a = vqtd-a + 1.
    end.

    disp vqtd-a with frame f-disp.
    
end.

pause 0.

vdes = "BUSCANDO CONTNF".
vqtd-l = 0.
vqtd-a = 0.
 
down with frame f-disp.

disp vdes with frame f-disp.

for each finloja.contrato where contrato.clicod = vclicod no-lock:
                
    vqtd-l = vqtd-l + 1.   
                    
    disp vqtd-l  with frame f-disp.
 
    if finloja.contrato.etbcod <> vetbcod
    then next.            

    for each finloja.contnf 
        where finloja.contnf.etbcod  = finloja.contrato.etbcod and
              finloja.contnf.contnum = finloja.contrato.contnum:
                
        find fin.contnf 
            where fin.contnf.etbcod  = finloja.contnf.etbcod  and
                  fin.contnf.placod  = finloja.contnf.placod  and
                  fin.contnf.contnum = finloja.contnf.contnum no-error.
        
        if not avail fin.contnf
        then do transaction:
    
            create fin.contnf.
            {tt-contnf.i fin.contnf finloja.contnf}.
            vqtd-a = vqtd-a + 1.
        end.
        
    end.
    disp vqtd-a with frame f-disp.
end.
pause 0.

vdes = "BUSCANDO CHQ".
vqtd-a = 0.
vqtd-l = 0.
 
down with frame f-disp.
disp vdes with frame f-disp.

for each finloja.chq 
         where finloja.chq.datemi >= vdti and
               finloja.chq.datemi <= vdtf no-lock:
               
    vqtd-l = vqtd-l + 1.   
                    
    disp vqtd-l  with frame f-disp.
          
               
    find fin.chq where fin.chq.banco   = finloja.chq.banco   and
                       fin.chq.agencia = finloja.chq.agencia and
                       fin.chq.conta   = finloja.chq.conta   and
                       fin.chq.numero  = finloja.chq.numero no-error.
    if not avail fin.chq
    then do transaction:

        create fin.chq.
        {tt-chq.i fin.chq finloja.chq}
        vqtd-a = vqtd-a + 1.
    end.
    disp vqtd-a with frame f-disp.
end.
pause 0.


end.

