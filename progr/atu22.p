disable triggers for load of finloja.titulo.
disable triggers for load of finloja.contrato.
disable triggers for load of finloja.contnf.
def input parameter vetbcod like estab.etbcod.
def input parameter vdti    like com.plani.pladat.
def input parameter vdtf    like com.plani.pladat.
def input parameter exptit  as log.
def input parameter expcon  as log.


if expcon
then do:
for each fin.contrato where fin.contrato.etbcod = vetbcod  and
                            fin.contrato.dtinicial >= vdti and
                            fin.contrato.dtinicial <= vdtf no-lock.
                                
    display "Atualizando Contratos...."
                 fin.contrato.contnum
                 fin.contrato.dtinicial format "99/99/9999" no-label
                        with frame f1 1 down centered.
    pause 0.         

    
    find finloja.contrato where 
         finloja.contrato.contnum = fin.contrato.contnum no-error.
    if not avail finloja.contrato
    then do transaction:
        
        create finloja.contrato.
        {contrato.i finloja.contrato fin.contrato}.
        finloja.contrato.exportado = yes.
        
    end.  
    
    for each fin.contnf where fin.contnf.etbcod  = fin.contrato.etbcod and
                              fin.contnf.contnum = fin.contrato.contnum no-lock:
        
        find finloja.contnf where 
                     finloja.contnf.etbcod  = fin.contnf.etbcod and
                     finloja.contnf.placod  = fin.contnf.placod and
                     finloja.contnf.contnum = fin.contnf.contnum no-error.
                     
        
        if not avail finloja.contnf
        then do transaction:
            
            create finloja.contnf.
            {contnf.i finloja.contnf fin.contnf}.
            
        end.
        
    end.    
    
end.    
end.

if exptit
then do:


/******************** TITULO ABERTOS *************************/
for each fin.titulo where fin.titulo.empcod = 19      and
                          fin.titulo.titnat = no      and
                          fin.titulo.modcod = "CRE"   and
                          fin.titulo.etbcod = vetbcod and
                          fin.titulo.titsit = "LIB" no-lock:
                          
                                
    display "Atualizando Titulos Abertos...."
                 fin.titulo.clifor
                 fin.titulo.titdtven format "99/99/9999" no-label
                        with frame f2 1 down centered.
    pause 0.         

    find finloja.titulo where finloja.titulo.empcod = fin.titulo.empcod and
                              finloja.titulo.titnat = fin.titulo.titnat and
                              finloja.titulo.modcod = fin.titulo.modcod and
                              finloja.titulo.etbcod = fin.titulo.etbcod and
                              finloja.titulo.clifor = fin.titulo.clifor and
                              finloja.titulo.titnum = fin.titulo.titnum and
                              finloja.titulo.titpar = fin.titulo.titpar
                                                no-error.
    if not avail finloja.titulo
    then do transaction:
        create finloja.titulo.
        {titulo.i finloja.titulo fin.titulo}.
        finloja.titulo.exportado = yes.
    end.
end.


/******************** TITULO PAGOS *************************/
for each fin.titulo where fin.titulo.etbcobra = vetbcod and
                          fin.titulo.titdtpag >= vdti   and
                          fin.titulo.titdtpag <= vdtf no-lock:
                          
    if fin.titulo.clifor = 1
    then next.
                                

    
    display "Atualizando Titulos Pagos...."
                 fin.titulo.clifor
                 fin.titulo.titdtven format "99/99/9999" no-label
                        with frame f3 1 down centered.
    pause 0.         

    find finloja.titulo where finloja.titulo.empcod = fin.titulo.empcod and
                              finloja.titulo.titnat = fin.titulo.titnat and
                              finloja.titulo.modcod = fin.titulo.modcod and
                              finloja.titulo.etbcod = fin.titulo.etbcod and
                              finloja.titulo.clifor = fin.titulo.clifor and
                              finloja.titulo.titnum = fin.titulo.titnum and
                              finloja.titulo.titpar = fin.titulo.titpar
                                                no-error.
    if not avail finloja.titulo
    then do transaction:
        create finloja.titulo.
        {titulo.i finloja.titulo fin.titulo}.
        finloja.titulo.exportado = yes.
    end.
    else do:
        if finloja.titulo.titsit = "LIB"
        then do transaction:
        
            {titulo.i finloja.titulo fin.titulo}.
            finloja.titulo.exportado = yes.
        
        end.
    end.
end.
end.

    



         

                       
