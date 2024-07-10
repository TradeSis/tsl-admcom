{admcab.i}
def var vtot like com.plani.platot.
def var vdti like com.plani.pladat.
def var vdtf like com.plani.pladat.
def var vetbcod like estab.etbcod.
def var vip     as char.
def var vrec    as recid.
def var vnumero like com.plani.numero.
def var vtot1   like com.plani.platot.
repeat:

    vdti = today.
    vdtf = today.

    if connected ("comloja")
    then disconnect comloja.
    
    update vetbcod label "Filial"
                with frame f1 side-label width 80.
    find estab where estab.etbcod = vetbcod no-lock no-error.
    if not avail estab
    then do:
        message "Filial nao Cadastrada".
        undo, retry.
    end.
    display estab.etbnom no-label with frame f1.
    
    if month(vdti) = 1
    then vdti = date(12,1,year(today) - 1).
    else vdti = date(month(vdti) - 1,1,year(today)).
   
    if month(vdti) = 12
    then vdtf = date(12,31,year(vdti)).
    else vdtf = date(month(vdti) + 1,1,year(vdti)) - 1.
    

    update vdti label "Periodo" at 1
           vdtf no-label with frame f1.
    
    vtot = 0.
    for each fiscal where fiscal.emite  = 100071        and
                          fiscal.desti  = estab.etbcod and 
                          fiscal.movtdc = 12            and 
                          fiscal.plarec >= vdti         and 
                          fiscal.plarec <= vdtf no-lock:
                              
        vtot = vtot + fiscal.platot.
    
    end. 
    
    vtot1 = 0.
    for each fiscal where fiscal.emite  = 100071        and
                          fiscal.desti  = estab.etbcod and 
                          fiscal.movtdc = 04            and 
                          fiscal.plarec >= vdti         and 
                          fiscal.plarec <= vdtf no-lock:
                              
        vtot1 = vtot1 + fiscal.platot.
    
    end. 

                           
               
         
    if vtot = 0 and
       vtot1 = 0
    then do:    
        message "Nenhum lancamento encontrado".
        pause.
        undo, retry.
    end.
    disp vtot  label "Total 12" 
         vtot1 label "Total 04" with frame f1.


    vip = "filial" + string(estab.etbcod,"99").
    
    if vetbcod < 900 and
     {conv_difer.i estab.etbcod} and
       vetbcod <> 22
    then do:
                       
        message "Conectando " estab.etbnom ".....". 
        connect com -H value(vip) -S sdrebcom -N tcp -ld comloja no-error.
    
        if not connected ("comloja")
        then do:
            message "Filial nao conectada".
            pause.
            undo, retry.
        end.    
        hide message no-pause.
        vrec = ?. 
    
        message "Confirma nota fiscal" update sresp.
        if sresp
        then run nfene01.p(input vetbcod,
                           input vtot,
                           input vdtf,
                           output vrec,
                           output vnumero).
        if vrec = ?  
        then do: 
            message "nota nao foi criada". 
            pause. 
            undo, retry.
        end.    
        else do:
            message "Nota fiscal" vnumero " Criada".
            pause.
        end.    
                                   
                           
    end.
    else do:
    
        message "Confirma nota fiscal" update sresp.
        if sresp
        then do:
            if vtot <> 0
            then do:
                run nfene02.p(input vetbcod,
                              input vtot,
                              input vdtf,
                              output vrec,
                              output vnumero).
                if vrec = ?  
                then do: 
                    message "nota nao foi criada". 
                    pause. 
                    undo, retry. 
                end.     
                else do: 
                    message "Nota fiscal" vnumero " Criada". 
                    pause. 
                end.    
            end.
            /**
            if vtot1 <> 0 
            then do:
            
                run nfene02.p(input vetbcod,
                              input vtot1, 
                              input vdtf, 
                              output vrec, 
                              output vnumero).
                if vrec = ?  
                then do: 
                    message "nota nao foi criada". 
                    pause. 
                    undo, retry. 
                end.     
                else do: 
                    message "Nota fiscal" vnumero " Criada". 
                    pause. 
                end. 
            
            end.
            **/
        end.                  
    end.
    
               
   
    if connected ("comloja")
    then disconnect comloja.
    
    sresp = no.  
    message "Confirma Emissao da Nota " update sresp.  
    if sresp  
    then run imptra_e.p (input vrec).

         
end.        