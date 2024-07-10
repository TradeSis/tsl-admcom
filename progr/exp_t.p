{admcab.i}
def var vetbcod like estab.etbcod.
def var vdti    like com.plani.pladat.
def var vdtf    like com.plani.pladat.
def var exptit  as log format "Sim/Nao".
def var expcon  as log format "Sim/Nao".
def var expdep  as log format "Sim/Nao".
def var expchq  as log format "Sim/Nao".
def stream scontrato.
def stream scontnf.
def stream stitulo.

def var vdiretorio as char format "x(50)".




repeat:

    update  vetbcod label "Filial"
            vdti    label "Data Inicial"
            vdtf    label "Data Final" 
            exptit  label "Exportar Titulos"
            expcon  label "Exportar Contratos"
            expdep  label "Exportar Depositos"
            expchq  label "Exportar Cheques" 
                with frame f0 side-label width 80 1 column
                    title "ATUALIZACAO DE CONTRATOS".
    
    if opsys = "UNIX"
    then vdiretorio = "/admcom/dados/".
    else vdiretorio = "l:~\dados~\".      
          
    update vdiretorio label "Diretorio"            
            with frame fdiretorio width 80 side-label .
        
        
    if expcon
    then do:

        output stream scontrato to value(vdiretorio + "contrato.d").
        output stream scontnf   to value(vdiretorio + "contnf.d").
        
        for each contrato where contrato.etbcod = vetbcod  and
                                contrato.dtinicial >= vdti and
                                contrato.dtinicial <= vdtf no-lock.
                                
            display "Atualizando Contratos...."
                     contrato.contnum
                     contrato.dtinicial format "99/99/9999" no-label
                        with frame f1 1 down centered.
            pause 0.         

    
            for each contnf where contnf.etbcod  = contrato.etbcod and
                                  contnf.contnum = contrato.contnum no-lock:
        
                export stream scontnf contnf.            
        
            end.

            export stream scontrato contrato.
            
        end.    
        output stream scontrato close.
        output stream scontnf   close.
    
    end.    
    

    if exptit
    then do:


    /******************** TITULO ABERTOS *************************/
        output stream stitulo to value(vdiretorio + "titulo.d").
        for each titulo where titulo.empcod = 19      and
                              titulo.titnat = no      and 
                              titulo.modcod = "CRE"   and 
                              titulo.etbcod = vetbcod and 
                              titulo.titsit = "LIB" no-lock:
                          
                                
            display "Atualizando Titulos Abertos...."
                     titulo.clifor
                     titulo.titdtven format "99/99/9999" no-label
                        with frame f2 1 down centered.
            pause 0.         

            export stream stitulo titulo. 
            
        end.


        /******************** TITULO PAGOS *************************/
        for each titulo where titulo.etbcobra = vetbcod and
                              titulo.titdtpag >= vdti   and
                              titulo.titdtpag <= vdtf no-lock:
                          
        
            if titulo.clifor = 1
            then next.
                                

    
            display "Atualizando Titulos Pagos...."
                     titulo.clifor
                     titulo.titdtven format "99/99/9999" no-label
                            with frame f3 1 down centered.
            pause 0.         

            export stream stitulo titulo.
    
        end.
        output stream stitulo close.

    end.
    
    if expdep
    then do:
        output to value(vdiretorio + "depban.d").
        for each depban where depban.datexp >= vdti and
                              depban.datexp <= vdtf no-lock:
                              
            export depban.
                                  
                                  
        end.
        output close.
        
    end.
    
    if expchq
    then do:
        output to value(vdiretorio + "chq.d").
        for each chq where chq.datemi >= vdti and
                           chq.datemi <= vdtf no-lock:
                           
            export chq.
                           
        end.
        output close.
        
        output to value(vdiretorio + "chqtit.d").
        for each chq where chq.datemi >= vdti and
                           chq.datemi <= vdtf no-lock:
                    
            for each chqtit of chq no-lock:
            
            
                export chqtit.
                
            end.                           
        end.
        output close.
    
    end.
    
end.
    



         

                       
