{admcab.i}

def var tot-pla like fiscal.platot format "->>,>>>,>>9.99".
def var tot-bic like fiscal.platot format "->>,>>>,>>9.99".
def var tot-icm like fiscal.platot format "->>,>>>,>>9.99".
def var tot-ipi like fiscal.platot format "->>,>>>,>>9.99". 
def var tot-out like fiscal.platot format "->>,>>>,>>9.99".
def var vetbcod like estab.etbcod.
def var vdti as date format "99/99/9999".
def var vdtf as date format "99/99/9999".
def var varquivo as char.
def var tot-valor as dec.    
def var tot-base  as dec.   
def var tot-icms  as dec.  
def var tot-outras as dec.
def var tot-sub    as dec.
def var vise       as dec.
def var val07 as dec.
def var outras-icms as dec.
def var vuf like forne.ufecod.





def var vopfcod like fiscal.opfcod.
def var vali    like fiscal.alicms.


def new shared temp-table tt-opf 
    field opfcod like fiscal.opfcod 
    field alicms like fiscal.alicms 
    field ufecod like forne.ufecod
    field totpla as dec format ">>>,>>>,>>9.99" 
    field totbic as dec format ">>>,>>>,>>9.99"
    field toticm as dec format ">>>,>>>,>>9.99"
    field totipi as dec format ">>>,>>>,>>9.99"
    field totout as dec format ">>>,>>>,>>9.99".
                


 

repeat:
    
    for each tt-opf:
        delete tt-opf.
    end.
    
    update vetbcod colon 16 with frame f1 side-label width 80.
    find estab where estab.etbcod = vetbcod no-lock.
    display estab.etbnom no-label with frame f1.
    update vdti label "Data Inicial" colon 16
           vdtf label "Data Final" with frame f1.
        

                    
    assign tot-pla = 0 
           tot-bic = 0 
           tot-icm = 0 
           tot-ipi = 0 
           tot-out = 0.  
           

                
    
                     
    for each fiscal where fiscal.desti = vetbcod and
                          fiscal.plarec >= vdti and 
                          fiscal.plarec <= vdtf no-lock:
                    
        vuf = "RS".
        if fiscal.movtdc = 04
        then do:
            find forne where forne.forcod = fiscal.emite 
                                    no-lock no-error.
            if not avail forne
            then next.
            vuf = forne.ufecod.
        end.
        
                        
        find first tt-opf where tt-opf.opfcod = fiscal.opfcod and
                                tt-opf.alicms = fiscal.alicms and
                                tt-opf.ufecod = vuf no-error.
        if not avail tt-opf 
        then do: 
            create tt-opf. 
            assign tt-opf.opfcod = fiscal.opfcod 
                   tt-opf.alicms = fiscal.alicms
                   tt-opf.ufecod = vuf.
        end.
        assign tt-opf.totpla = tt-opf.totpla + fiscal.platot  
               tt-opf.totbic = tt-opf.totbic + fiscal.bicms  
               tt-opf.toticm = tt-opf.toticm + fiscal.icms   
               tt-opf.totipi = tt-opf.totipi + fiscal.ipi  
               tt-opf.totout = tt-opf.totout + fiscal.out.
                                    
    end.

    for each tipmov no-lock:
    
        if tipmov.movtdc = 04 or
           tipmov.movtdc = 01 or
           tipmov.movtdc = 05 or
           tipmov.movtdc = 12
        then next.
           
        for each plani where plani.desti  = vetbcod and
                             plani.movtdc = tipmov.movtdc and
                             plani.datexp >= vdti   and
                             plani.datexp <= vdtf no-lock:
                             
            vopfcod = 0.
            vali = 0.
            vuf  = "RS".
                        

            
            if plani.emite = 995 and
               plani.desti = 998 
            then next.
            if plani.emite = 998 and
               plani.desti = 995
            then next.   
        

        
            if tipmov.movtdc = 6
            then assign vopfcod = 1152
                        vali    = 0.
            
            if tipmov.movtdc = 12
            then assign vopfcod = 1202
                        vali    = 17.
                     
            if vopfcod = 0
            then next.

            find first tt-opf where tt-opf.opfcod = vopfcod and
                                    tt-opf.alicms = vali    and
                                    tt-opf.ufecod = vuf no-error.
            if not avail tt-opf
            then do:
                create tt-opf.
                assign tt-opf.opfcod = vopfcod
                       tt-opf.alicms = vali
                       tt-opf.ufecod = vuf.
            end.            

            assign tt-opf.totpla = tt-opf.totpla + plani.platot 
                   tt-opf.totbic = tt-opf.totbic + plani.bicms
                   tt-opf.toticm = tt-opf.toticm + plani.icms
                   tt-opf.totipi = tt-opf.totipi + plani.ipi
                   tt-opf.totout = tt-opf.totout + plani.outras.
                   
             
        
        end.  
        
        for each plani where plani.emite  = vetbcod and
                             plani.movtdc = tipmov.movtdc and
                             plani.datexp >= vdti  and
                             plani.datexp <= vdtf no-lock:
        

                            
            vopfcod = 0.
            vali = 0.
            vuf  = "RS".
              
            if plani.emite = 995 and
               plani.desti = 998 
            then next.
            if plani.emite = 998 and
               plani.desti = 995
            then next.   
        

                        
            if tipmov.movtdc = 6
            then assign vopfcod = 5152
                        vali    = 0.
                        

            if tipmov.movtdc = 16
            then assign vopfcod = 5915
                        vali    = 0.
                        

            if tipmov.movtdc = 13 or
               tipmov.movtdc = 14
            then do:
                
                find forne where forne.forcod = plani.desti no-lock no-error.
                if not avail forne
                then next.
        
                
                if tipmov.movtdc = 14
                then do:
                    if forne.ufecod = "RS"
                    then vopfcod = 5902.
                    else assign vopfcod = 6902
                                vuf     = forne.ufecod.
                end.
                
                
                if tipmov.movtdc = 13
                then do:
                    if forne.ufecod = "RS"
                    then assign vali = 17
                                vopfcod = 5202.
                    else assign vali = 12
                                vopfcod = 6202
                                vuf     = forne.ufecod.
                end.
                
            end.
        
            
            if vopfcod = 0
            then next.
            
            find first tt-opf where tt-opf.opfcod = vopfcod and
                                    tt-opf.alicms = vali    and
                                    tt-opf.ufecod = vuf no-error.
            if not avail tt-opf
            then do:
                create tt-opf.
                assign tt-opf.opfcod = vopfcod
                       tt-opf.alicms = vali
                       tt-opf.ufecod = vuf.
            end.            

            assign tt-opf.totpla = tt-opf.totpla + plani.platot 
                   tt-opf.totbic = tt-opf.totbic + plani.bicms
                   tt-opf.toticm = tt-opf.toticm + plani.icms
                   tt-opf.totipi = tt-opf.totipi + plani.ipi
                   tt-opf.totout = tt-opf.totout + plani.outras.
             
        
        end.     
    end.


    run giaven.p (input vetbcod,
                  input vdti,
                  input vdtf).
                  
             
    varquivo = "l:\relat\ctb98" + string(time).
     
    {mdad.i &Saida     = "value(varquivo)" 
            &Page-Size = "0" 
            &Cond-Var  = "130" 
            &Page-Line = "0" 
            &Nom-Rel   = ""manfis1"" 
            &Nom-Sis   = """SISTEMA DE CONTABILIDADE""" 
            &Tit-Rel   = """LISTAGEM DE NOTAS DE ENTRADA  "" + 
                          ""ESTABELECIMENTO:  "" + string(vetbcod) + 
                          "" "" + string(vdti,""99/99/9999"") + "" ate "" +
                                  string(vdtf,""99/99/9999"")"
            &Width     = "130" 
            &Form      = "frame f-cabcab3"}

     

    
    
    for each tt-opf break by tt-opf.ufecod:
        
        display tt-opf.opfcod format "9999" 
                tt-opf.alicms 
                tt-opf.ufecod column-label "UF"
                tt-opf.totpla(total by tt-opf.ufecod) column-label "Total" 
                tt-opf.totbic(total by tt-opf.ufecod) column-label "Base ICMS" 
                tt-opf.toticm(total by tt-opf.ufecod) column-label "ICMS" 
                tt-opf.totipi(total by tt-opf.ufecod) column-label "IPI" 
                tt-opf.totout(total by tt-opf.ufecod) column-label "Outras"
                       with frame flista1 width 200 down.
         
    end.
    
    output close.             
    {mrod.i}
    
end.
 