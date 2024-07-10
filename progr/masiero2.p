for each credscor:
    delete credscor.
end.    



def var vexp as log.
def var vtotal as int.
def var vexportado as int.
def var vnaoexportado as int.
def var tot as dec.
def temp-table ttacu
    field mes like credscor.mesacu
    field ano like credscor.anoacu
    field val like credscor.valacu.
    

pause 0 before-hide.     

form with frame f.                         

for each clien no-lock:

    disp clien.clicod with 1 down. pause 0.

    for each ttacu:
        delete ttacu.
    end.    
                       
    for each contrato where contrato.clicod = clien.clicod no-lock:

        vtotal = vtotal + 1.
    
        vexp = no.
    
        if contrato.dtinicial >= 01/01/2002
        then next.
    
        for each titulo where titulo.empcod = 19 and
                              titulo.titnat = no and
                              titulo.modcod = "CRE"and
                              titulo.etbcod = contrato.etbcod and
                              titulo.clifor = contrato.clicod and
                              titulo.titnum = string(contrato.contnum) no-lock.
            
            if titulo.titsit = "LIB"
            then vexp = yes.
        end.

        if vexp = yes
        then next.
    
        find first credscor where credscor.clicod = clien.clicod no-error.
        if not avail credscor
        then do:
            create credscor.
            assign credscor.clicod = clien.clicod
                   credscor.dtultc = 01/01/1980.
        end.
    
        credscor.numcon = credscor.numcon + 1.
        credscor.valcon = credscor.valcon + contrato.vltotal.
        
        if contrato.dtinicial > credscor.dtultc
        then credscor.dtultc = contrato.dtinicial.  
        
        for each titulo where titulo.empcod = 19 and
                               titulo.titnat = no and
                               titulo.modcod = "CRE"and
                               titulo.etbcod = contrato.etbcod and
                               titulo.clifor = contrato.clicod and
                               titulo.titnum = string(contrato.contnum) 
                               no-lock.

            credscor.numpcp = credscor.numpcp + 1.
            
            find first ttacu where ttacu.mes = month(titulo.titdtven) and
                                   ttacu.ano = year(titulo.titdtven) no-error.
            if not avail ttacu
            then do:
                create ttacu.
                assign ttacu.mes = month(titulo.titdtven)
                       ttacu.ano = year(titulo.titdtven).                
            end.
            ttacu.val = ttacu.val + titulo.titvlcob.
            
            if (titulo.titdtpag - titulo.titdtven) <= 15
            then do:
                credscor.numa15 = credscor.numa15 + 1.
                credscor.vala15 = credscor.vala15 + titulo.titvlcob.
            end.    

            if (titulo.titdtpag - titulo.titdtven) > 15 and
               (titulo.titdtpag - titulo.titdtven) <= 45
            then do:
                credscor.numa16 = credscor.numa16 + 1.
                credscor.vala16 = credscor.vala16 + titulo.titvlcob.
            end.    

            if (titulo.titdtpag - titulo.titdtven) > 45
            then do:
                credscor.numa45 = credscor.numa45 + 1.
                credscor.vala45 = credscor.vala45 + titulo.titvlcob.
            end.                                

        end.

    end.

    find first ttacu no-error.
    if not avail ttacu
    then next.
    
    tot = 0.    
    for each ttacu:
        if ttacu.val <= tot
        then delete ttacu.
        else tot = ttacu.val.
    end.     
    
    find first credscor where credscor.clicod = clien.clicod no-error.
    if avail credscor
    then do:
    
        find first ttacu no-error.
        if avail ttacu
        then do:
            credscor.mesacu = ttacu.mes.
            credscor.anoacu = ttacu.ano.
            credscor.valacu = ttacu.val.    
        end.
    end.
                                                 
                                                 
end.            
