def var vjuro as dec. 
def var vpaga as dec.
def var vvend as dec.
def var vdt   as date.
def var vdti  as date format "99/99/9999" initial 12/01/2001. 
def var vdtf  as date format "99/99/9999" initial 12/10/2001.

def var vsobra as dec.
def temp-table tt-dif
    field data   as date
    field difjur as dec
    field difpag as dec
    field difven as dec
        index ind-1 data.
    
    
repeat:

    update vdti vdtf with frame f1 side-label.
    


    do vdt = vdti to vdtf:

        message vdt. pause 0. 

        vjuro = 0.
        vvend = 0.
        vpaga = 0.
        vsobra = 0.

        find finctb.diario where diario.data = vdt no-lock no-error.
        if not avail diario
        then next.
 
        for each lanca where lanca.landat = vdt no-lock:


            if lanca.lannat = "V"
            then vvend = vvend + lanca.lanval.


            if lanca.lannat = "P"
            then vpaga = vpaga + lanca.lanval.


            if lanca.lannat = "J"
            then vjuro = vjuro + lanca.lanval.

            vsobra = vsobra + lanca.lanobs.


        end.


        find first tt-dif where tt-dif.data = diario.data no-error.
        if not avail tt-dif 
        then do: 
            create tt-dif.
            assign tt-dif.data = diario.data.
        end.
        if diario.venda <> vvend
        then difven = diario.venda -  vvend.
        if diario.pagamento <> vpaga
        then difpag = diario.pagamento - vpaga.
        if diario.juro <> vjuro
        then difjur = diario.juro - vjuro.
 
        if difpag = 0 
        then next.
    
        def var vdif as dec.
        def var vtot as dec.
        def var vacr  as dec.
        def var vdti2 as date.
        def var vdtf2 as date.
        def var vdata as date.
        def var vtotacr as dec.
        def var vsaldoacr as dec.
               
        vdti2 = date(month(vdt),
                    1, 
                    2001).
        
        if month(vdt) < 12
        then
            vdtf2 = date(month(vdt) + 1,1,2001) - 1. 
        else        
            vdtf2 = 12/31/2001.
        
        
        vtotacr = 0.

        vsaldoacr = difpag.
        
        for each plani where plani.movtdc = 12 and
                             plani.pladat >= vdti2 and
                             plani.pladat <= vdtf2 no-lock /* by plani.desti desc */ :

            /*                 
            find first lanca where lanca.empcod = 19 and
                                   lanca.titnat = no and
                                   lanca.modcod = "CRE" and
                                   lanca.etbcod = plani.etbcod and
                                   lanca.clifor = plani.desti and
                                   lanca.landat >= plani.pladat no-lock no-error.
            if not avail lanca
            then next.      
            */
            
            find first lanca where lanca.empcod = 19
                           and lanca.titnat = no  
                           and    lanca.modcod = "DEV"  
                           and    lanca.etbcod = plani.etbcod  
                           and    lanca.clifor = plani.desti
                           and    lanca.titnum = string(plani.numero)  
                           and    lanca.titpar = plani.placod  
                           and    lanca.lannat = "P"            
                           and    lanca.landat = diario.data no-lock no-error.
            if avail lanca
            then next.                   
                                         
                             
                             
            if vsaldoacr < (plani.platot * 2)
            then leave.                

            create lanca.
            assign lanca.empcod = 19
                               lanca.titnat = no  
                               lanca.modcod = "DEV"  
                               lanca.etbcod = plani.etbcod  
                               lanca.clifor = plani.desti
                               lanca.titnum = string(plani.numero)  
                               lanca.titpar = plani.placod  
                               lanca.lannat = "P"            
                               lanca.landat = diario.data
                               lanca.lanval = (plani.platot * 2).    
                                    
            vsaldoacr = vsaldoacr - lanca.lanval.                        
                        
                        
        end.
       
        /*
        for each lanca where lanca.landat = vdt and
                             lanca.lannat = "P" by lanca.lanval desc:
            
            display diario.data
                    difpag
                    lanca.lanval.
             
            vacr = difpag.
            update vacr.
        
            lanca.lanval = lanca.lanval + vacr.
            difpag = difpag - vacr.
        
            if difpag = 0
            then leave.

        end.            
        */
        

        display vdt
                difpag
                vtotacr.

        pause 0.
        
        /*
       
        display diario.data
                diario.venda   column-label "Venda Ctb"
                when difven > 0    
                vvend          column-label "Venda Inf"
                when difven > 0
                tt-dif.difven  column-label "DIF"
                when difven > 0
    /*         ((vvend / diario.venda) * 100) format ">>9.99%  " */
        
                diario.pagamento column-label "Pagto Ctb"
                when difpag > 0
                vpaga            column-label "Pagto Inf"
                when difpag > 0
                tt-dif.difpag    column-label "DIF"
                when difpag > 0
    /*          ((vpaga / diario.pagamento) * 100) format ">>9.99%  "  */

                diario.juro      column-label "Juro Ctb"
                when difjur > 0
                vjuro            column-label "Juro Inf"
                when difjur > 0
                tt-dif.difjur    column-label "DIF"
                when difjur > 0
       
    /*          ((vjuro / diario.juro) * 100) format ">>9.99%"   */

                    with frame f2 down width 130.
            down with frame f2.
         */
         
    end.
end.
