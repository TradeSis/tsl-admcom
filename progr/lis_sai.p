{admcab.i}


/****************** Notas Fiscais de Saida ********************/
def var v-alicota as dec.
def var base_icms like plani.platot.
def var vdatexp like plani.datexp.
def var vcod as char format "x(18)".
def var vemite like plani.emite.
def var vdesti like plani.desti.
def var vdti like plani.pladat.
def var vdtf like plani.pladat.
def var vetbcod like estab.etbcod.
def var vopccod as char.
def var vali    as int.
def var varquivo    as char. 
def var val_contabil like plani.platot.
def var visenta like plani.platot.
def var voutras like plani.platot.
def temp-table tt-fiscal
    field etbcod  like estab.etbcod
    field opfcod  as char
    field alicota as dec format ">>9.99"
    field totsai  like plani.platot 
    field base    like plani.platot 
    field icms    like plani.icms 
    field ipi     like plani.ipi 
    field valcon  like plani.platot.
                       
 
 


repeat:


    for each tt-fiscal:
        delete tt-fiscal.
    end.        
    
    update vetbcod with frame f1.
    if vetbcod = 0
    then display "GERAL" @ estab.etbnom with frame f1.
    else do:
    
        find estab where estab.etbcod = vetbcod no-lock.

        display estab.etbnom no-label with frame f1.
        
    end.
    
    update vdti label "Data Inicial" colon 16
           vdtf label "Data Final" with frame f1 side-label width 80.
 

    for each tipmov where tipmov.movtnota = yes and 
                          tipmov.movtdeb  = yes no-lock:

        if tipmov.movtdc = 5
        then next.
        for each estab where if vetbcod = 0
                             then true 
                             else estab.etbcod = vetbcod no-lock:
            for each plani where plani.etbcod = estab.etbcod  and
                                 plani.movtdc = tipmov.movtdc and
                                 plani.datexp >= vdti         and
                                 plani.datexp <= vdtf no-lock:
               
                if plani.platot = 0
                then next.
                                
                if plani.serie = "U" or
                   plani.serie = "1"
                then. 
                else next.
          
                if plani.emite = 995 and
                   plani.desti = 998 
                then next.
                if plani.emite = 998 and
                   plani.desti = 995
                then next.   
                
                vdatexp = plani.datexp.
                if plani.movtdc = 13 and
                   plani.datexp >= 01/01/2005 and
                   plani.datexp <= 05/31/2005
                then vdatexp = date(07,
                                    day(plani.datexp),
                                    year(plani.datexp)).
        

             
             
                vemite = plani.emite.  
                if vemite = 998  
                then vemite = 995.
            
                vdesti = plani.desti.  
                if vdesti = 998  
                then vdesti = 995.
               
               
                assign visenta      = 0 
                       voutras      = 0.

               


             
                if plani.movtdc = 6 or
                   plani.movtdc = 9
                then do:   
                    if plani.protot = 0 
                    then next. 
                    vopccod = "5152". 
                    vcod = "E" + string(vdesti,"9999999") + "          ". 
                end.    
                else do: 
                    find forne where forne.forcod = vdesti no-lock no-error.
                    if not avail forne 
                    then next.

                    vcod = "F" + string(forne.forcod,"9999999") + 
                            "          ". 
                
                    if forne.ufecod = "RS"
                    then find first opcom where 
                                    opcom.movtdc = plani.movtdc no-lock.
                    else find last opcom where 
                                   opcom.movtdc = plani.movtdc no-lock.
                
                    vopccod = string(opcom.opccod). 
                
                end.


                if plani.bicms > 0
                then vali = int((plani.icms * 100) / plani.bicms).
                else vali = 0. 
             
                base_icms = 0.
                    
                if vopccod = "5202" or 
                   vopccod = "6202"
                then base_icms = plani.platot.
                                 
                val_contabil = plani.platot. 
                visenta = 0.

                voutras = val_contabil.
 
  
                if vopccod = "6901"   
                then assign visenta = val_contabil   
                                      - (plani.platot) 
                                      - plani.ipi.
                            voutras = val_contabil  
                                      - (plani.platot)  
                                      - plani.ipi - visenta.
                                      
                find first movim where movim.etbcod = plani.etbcod and
                                       movim.placod = plani.placod and
                                       movim.movtdc = plani.movtdc and
                                       movim.movdat = plani.pladat  
                                            no-lock no-error.
                if avail movim
                then v-alicota = movim.movalicms.
                else v-alicota = 0.
                
                
                find first tt-fiscal where tt-fiscal.etbcod  = estab.etbcod and
                                           tt-fiscal.opfcod  = vopccod and
                                           tt-fiscal.alicota = v-alicota
                                                no-error.
                if not avail tt-fiscal
                then do:
                
                    create tt-fiscal.
                    assign tt-fiscal.etbcod  = estab.etbcod
                           tt-fiscal.opfcod  = vopccod
                           tt-fiscal.alicota = v-alicota.
                           
                end.

                assign tt-fiscal.totsai = tt-fiscal.totsai + plani.platot
                       tt-fiscal.base   = tt-fiscal.base   + base_icms
                       tt-fiscal.icms   = tt-fiscal.icms   + plani.icms
                       tt-fiscal.ipi    = tt-fiscal.ipi    + plani.ipi
                       tt-fiscal.valcon = tt-fiscal.valcon + val_contabil.
                       
            end.                                 
        end.
    end.
    
    for each estab where if vetbcod = 0
                         then true 
                         else estab.etbcod = vetbcod no-lock:

        for each mapctb where mapctb.etbcod = estab.etbcod and
                              mapctb.datmov >= vdti        and
                              mapctb.datmov <= vdtf  no-lock:
                              
            
            if mapctb.t01 > 0
            then do:
                find first tt-fiscal where tt-fiscal.etbcod  = estab.etbcod and
                                           tt-fiscal.opfcod  = "5102" and
                                           tt-fiscal.alicota = 17
                                                no-error.
                if not avail tt-fiscal 
                then do:
                
                    create tt-fiscal. 
                    assign tt-fiscal.etbcod  = estab.etbcod
                           tt-fiscal.opfcod  = "5102"
                           tt-fiscal.alicota = 17.
                           
                end.
                assign tt-fiscal.totsai = tt-fiscal.totsai + mapctb.t01
                       tt-fiscal.base   = tt-fiscal.base   + mapctb.t01
                       tt-fiscal.icms   = tt-fiscal.icms   + 
                                          (mapctb.t01 * 0.17)
                       tt-fiscal.valcon = tt-fiscal.valcon + mapctb.t01.
            end.           
            
            if mapctb.t02 > 0
            then do:
                find first tt-fiscal where tt-fiscal.etbcod  = estab.etbcod and
                                           tt-fiscal.opfcod  = "5102" and
                                           tt-fiscal.alicota = 12
                                                no-error.
                if not avail tt-fiscal 
                then do:
                
                    create tt-fiscal. 
                    assign tt-fiscal.etbcod  = estab.etbcod
                           tt-fiscal.opfcod  = "5102"
                           tt-fiscal.alicota = 12.
                           
                end.
                assign tt-fiscal.totsai = tt-fiscal.totsai + mapctb.t02
                       tt-fiscal.base   = tt-fiscal.base   + mapctb.t02
                       tt-fiscal.icms   = tt-fiscal.icms   + 
                                          ((mapctb.t02 * 0.705889) * 0.17).
                       tt-fiscal.valcon = tt-fiscal.valcon + mapctb.t02.
            end.           
            
            if mapctb.t03 > 0
            then do:
                find first tt-fiscal where tt-fiscal.etbcod  = estab.etbcod and
                                           tt-fiscal.opfcod  = "5102" and
                                           tt-fiscal.alicota = 7 no-error.
                if not avail tt-fiscal 
                then do:
                
                    create tt-fiscal. 
                    assign tt-fiscal.etbcod  = estab.etbcod
                           tt-fiscal.opfcod  = "5102"
                           tt-fiscal.alicota = 7.
                           
                end.
                assign tt-fiscal.totsai = tt-fiscal.totsai + mapctb.t03
                       tt-fiscal.base   = tt-fiscal.base   + mapctb.t03
                       tt-fiscal.icms   = tt-fiscal.icms   + 
                                          (mapctb.t03 * 0.7)
                       tt-fiscal.valcon = tt-fiscal.valcon + mapctb.t03.
            end.           
        end.
    end.    

    
    varquivo = "l:\relat\sai" + string(vetbcod,">>9") + ".txt".

    
    {mdad.i
        &Saida     = "value(varquivo)"
        &Page-Size = "0"
        &Cond-Var  = "80"
        &Page-Line = "0"
        &Nom-Rel   = """lis_sai"""
        &Nom-Sis   = """SISTEMA DE CONTABILIDADE"""
        &Tit-Rel   = """RESUMO DE SAIDAS  "" +
                    ""FILIAL "" + string(vetbcod)"  
        &Width     = "140"
        &Form      = "frame f-cab2"}
        
        
    for each tt-fiscal break by tt-fiscal.etbcod.

        disp tt-fiscal.etbcod column-label "Fl"
             tt-fiscal.opfcod 
             tt-fiscal.alicota 
             tt-fiscal.totsai(total by tt-fiscal.etbcod) 
                    column-label "Total" format ">>>,>>>,>>9.99"  
             tt-fiscal.base(total by tt-fiscal.etbcod)
                    column-label "Base Calculo" format ">>>,>>>,>>9.99"
             tt-fiscal.icms(total by tt-fiscal.etbcod)
                    column-label "ICMS" format ">>>,>>>,>>9.99" 
             tt-fiscal.ipi(total  by tt-fiscal.etbcod)
                    format ">>>,>>>,>>9.99"
                    with frame f2 down width 140.
                     

    end.            
    output close.
    /*{mrod.i} 
    */
    run visurel.p (input varquivo, input "").
    
end.    
