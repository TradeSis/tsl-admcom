{admcab.i}   
def var vicms like movim.movicms.
def buffer bmovim for movim.
def var vmovpc  like movim.movpc.
def var ali_icm  as dec.
def var val_icm  as dec.
def var val_bas as dec.
def var val_ise as dec.
def var val_out as dec.
def var sittri  like clafis.sittri.
def var valicm  as dec.
def var totsai  like plani.platot.
def var tottot  like plani.platot.
def var recpla as recid.


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
    field valcon  like plani.platot
    field outras  like plani.outras
    field isentas like plani.isenta.
                       

def temp-table tt-uf
    field ufecod  like forne.ufecod
    field uftotal like plani.platot format ">>,>>>,>>9.99".
    
    
def var vemi like fiscal.plaemi.
def var vrec like fiscal.plarec.
def var vopf like fiscal.opfcod.

 def var tot-pla like fiscal.platot format "->>,>>>,>>9.99".
 def var tot-bic like fiscal.platot format "->>,>>>,>>9.99".
 def var tot-icm like fiscal.platot format "->>,>>>,>>9.99".
 def var tot-ipi like fiscal.platot format "->>,>>>,>>9.99". 
 def var tot-out like fiscal.platot format "->>,>>>,>>9.99".
 


def var vnumero like fiscal.numero.
def var vforcod like forne.forcod.
def var totpla like plani.platot. 
def var totbic like plani.platot.
def var toticm like plani.platot.
def var totipi like plani.platot.
def var totout like plani.platot.
    

def var vmovtdc like tipmov.movtdc.

repeat:

    for each tt-fiscal:
        delete tt-fiscal.
    end.        
    
    
    vmovtdc = 0.
    display vmovtdc colon 16 label "Tipo Movimento"
                        with frame f1.
                        
    find tipmov where tipmov.movtdc = vmovtdc no-lock no-error.
    if not avail tipmov
    then display "GERAL" @ tipmov.movtnom no-label with frame f1.
    else display movtnom no-label with frame f1.

    update vetbcod label "Filial" colon 15
            with frame f1 side-label width 80.
    if vetbcod = 0
    then display "GERAL" @ estab.etbnom no-label with frame f1.
    else do:
        find estab where estab.etbcod = vetbcod no-lock no-error.
        display estab.etbnom no-label with frame f1.
    end.
                
                
    update vdti label "Data Inicial" colon 15
           vdtf label "Data Final" 
                with frame f1 side-label width 80.
                
                
                         
    for each estab where if vetbcod = 0
                         then true
                         else estab.etbcod = vetbcod no-lock:  
        for each tipmov where if vmovtdc = 0
                              then true
                              else tipmov.movtdc = vmovtdc no-lock.
        if tipmov.movtdc = 4 or
           tipmov.movtdc = 12
        then.
        else next.
            
        for each fiscal where fiscal.desti = estab.etbcod   and
                              fiscal.movtdc = tipmov.movtdc and  
                              fiscal.plarec >= vdti    and
                              fiscal.plarec <= vdtf no-lock:

            if fiscal.platot = 0  
            then next.
           
            recpla = ?.

              
            
            vopccod = string(fiscal.opfcod). 
            if tipmov.movtdc = 4  
            then do:   
                find plani where plani.etbcod = estab.etbcod 
                             and plani.emite  = fiscal.emite   
                             and plani.movtdc = tipmov.movtdc  
                             and plani.serie  = fiscal.serie   
                             and plani.numero = fiscal.numero 
                                            no-lock no-error.                                    if not avail plani   
                then do:
                
                    find plani where plani.etbcod = estab.etbcod 
                                and plani.emite  = fiscal.emite 
                                and plani.movtdc = 15 
                                and plani.serie  = fiscal.serie 
                                and plani.numero = fiscal.numero 
                                             no-lock no-error.
                    if avail plani
                    then recpla = recid(plani).
                end.
                else recpla = recid(plani).
            end.     
            else do: 
                find first plani where plani.etbcod = estab.etbcod 
                                   and plani.emite  = fiscal.emite 
                                   and plani.movtdc = 12 
                                   and plani.serie  = fiscal.serie 
                                   and plani.nottran = fiscal.numero 
                                            no-lock no-error.                                    if not avail plani 
                then do:

                    find first plani where plani.etbcod = estab.etbcod 
                                       and plani.emite  = fiscal.emite 
                                       and plani.movtdc = 12 
                                       and plani.serie  = fiscal.serie 
                                       and plani.numero = fiscal.numero 
                                            no-lock no-error.
                    if avail plani
                    then recpla = recid(plani).

                end. 
                else recpla = recid(plani).
            end. 
                
            if recpla <> ?
            then find plani where recid(plani) = recpla no-lock no-error. 
                    
            if avail plani
            then do:

                find first bmovim where 
                           bmovim.etbcod = plani.etbcod and
                           bmovim.placod = plani.placod and
                           bmovim.movtdc = plani.movtdc and
                           bmovim.movdat = plani.pladat no-lock no-error.
                if avail bmovim 
                then do:
                                    
                    for each movim where movim.etbcod = plani.etbcod and
                                         movim.placod = plani.placod and
                                         movim.movtdc = plani.movtdc and
                                         movim.movdat = plani.pladat no-lock:
                   
                    
                        vicms =  ((movim.movpc * movim.movqtm) * 
                                  (movim.movalicms / 100)).

                        v-alicota = movim.movalicms. 
                        
                        /*
                        if vopccod = "1202"
                        then v-alicota = 17.
                        */
                    
                        run trata_cfop.p (input vopccod, 
                                          input movim.procod,
                                          input (movim.movpc *
                                                 movim.movqtm),
                                          input v-alicota,   
                                          input vicms,   
                                          input 0,   
                                          output val_bas,  
                                          output val_ise,  
                                          output val_out,  
                                          output sittri,
                                          output valicm).
                    
                          
                        find first tt-fiscal where 
                                   tt-fiscal.etbcod  = estab.etbcod and
                                   tt-fiscal.opfcod  = vopccod and
                                   tt-fiscal.alicota = v-alicota no-error.
                        if not avail tt-fiscal
                        then do:
                
                            create tt-fiscal.
                            assign tt-fiscal.etbcod  = estab.etbcod
                                   tt-fiscal.opfcod  = vopccod
                                   tt-fiscal.alicota = v-alicota.
                           
                        end.

                          
                        assign tt-fiscal.totsai  = tt-fiscal.totsai + 
                                                   (movim.movpc * movim.movqtm)
                               tt-fiscal.base    = tt-fiscal.base   + val_bas
                               tt-fiscal.icms    = tt-fiscal.icms   + valicm
                               tt-fiscal.ipi     = tt-fiscal.ipi    + 
                                               ((movim.movpc * movim.movqtm) * 
                                                (movim.movalipi / 100))
                               tt-fiscal.valcon  = tt-fiscal.valcon + 
                                               (movim.movpc * movim.movqtm)
                               tt-fiscal.outras  = tt-fiscal.outras + val_out
                               tt-fiscal.isentas = tt-fiscal.isenta + val_ise.
                 
                     
                    
                    end.
                end.    
                else do:
                    
                    assign v-alicota = fiscal.alicms.
                  
                    run trata_cfop.p (input vopccod, 
                                      input 0,
                                      input plani.platot, 
                                      input v-alicota,    
                                      input plani.icms,    
                                      input 0,    
                                      output val_bas,   
                                      output val_ise,   
                                      output val_out,   
                                      output sittri,
                                      output valicm).
        
                
                    
                    find first tt-fiscal where 
                            tt-fiscal.etbcod  = estab.etbcod and
                            tt-fiscal.opfcod  = vopccod and
                            tt-fiscal.alicota = v-alicota no-error.
                    if not avail tt-fiscal
                    then do:
                
                        create tt-fiscal.
                        assign tt-fiscal.etbcod  = estab.etbcod
                               tt-fiscal.opfcod  = vopccod
                               tt-fiscal.alicota = v-alicota.
                           
                    end.

                    assign tt-fiscal.totsai  = tt-fiscal.totsai + plani.platot
                           tt-fiscal.base    = tt-fiscal.base   + val_bas
                           tt-fiscal.icms    = tt-fiscal.icms   + valicm
                           tt-fiscal.ipi     = tt-fiscal.ipi    + plani.ipi
                           tt-fiscal.valcon  = tt-fiscal.valcon + plani.platot
                           tt-fiscal.outras  = tt-fiscal.outras + val_out
                           tt-fiscal.isentas = tt-fiscal.isenta + val_ise.
                 
                    
                end.
            end.
            else do:
                
                assign v-alicota = 0.

               
                run trata_cfop.p (input vopccod, 
                                  input 0,
                                  input fiscal.platot, 
                                  input fiscal.alicms,    
                                  input fiscal.icms,     
                                  input 0,     
                                  output val_bas,    
                                  output val_ise,    
                                  output val_out,    
                                  output sittri,
                                  output valicm).
        
                
                    
                    find first tt-fiscal where 
                            tt-fiscal.etbcod  = estab.etbcod and
                            tt-fiscal.opfcod  = vopccod and
                            tt-fiscal.alicota = v-alicota no-error.
                    if not avail tt-fiscal
                    then do:
                
                        create tt-fiscal.
                        assign tt-fiscal.etbcod  = estab.etbcod
                               tt-fiscal.opfcod  = vopccod
                               tt-fiscal.alicota = v-alicota.
                           
                    end.

                    assign tt-fiscal.totsai  = tt-fiscal.totsai + fiscal.platot
                           tt-fiscal.base    = tt-fiscal.base   + val_bas
                           tt-fiscal.icms    = tt-fiscal.icms   + valicm
                           tt-fiscal.ipi     = tt-fiscal.ipi    + fiscal.ipi
                           tt-fiscal.valcon  = tt-fiscal.valcon + fiscal.platot
                           tt-fiscal.outras  = tt-fiscal.outras + val_out
                           tt-fiscal.isentas = tt-fiscal.isenta + val_ise.
                
            end.
        end.
        end.           
    end.        
           
    for each estab where if vetbcod = 0
                         then true
                         else estab.etbcod = vetbcod no-lock:
        for each tipmov where tipmov.movtdc = 06 or
                              tipmov.movtdc = 09 or
                              tipmov.movtdc = 11 or 
                              tipmov.movtdc = 22 no-lock,
            each plani where plani.datexp >= vdti     and
                             plani.datexp <= vdtf     and
                             plani.movtdc = tipmov.movtdc  and
                             plani.desti  = estab.etbcod no-lock:
        
        
            if plani.serie = "U"  
            then.  
            else next.

         
            if plani.emite = 995 and
               plani.desti = 998 
            then next.
            if plani.emite = 998 and
               plani.desti = 995
            then next.   

 
            vemite = plani.emite.
            if vemite = 998
            then vemite = 995.
            
            vdesti = plani.desti.
            if vdesti = 998
            then vdesti = 995.


            
            
            if tipmov.movtdc = 06 or
               tipmov.movtdc = 09 or
               tipmov.movtdc = 22 
            then assign vopccod = "1152"
                        v-alicota = 17.
            else assign vopccod = "1949"            
                        v-alicota = 17.
            
                            
            find first bmovim where bmovim.etbcod = plani.etbcod and
                                    bmovim.placod = plani.placod and
                                    bmovim.movtdc = plani.movtdc and
                                    bmovim.movdat = plani.pladat 
                                                no-lock no-error.
            if avail bmovim
            then do:
            for each movim where movim.etbcod = plani.etbcod and
                                 movim.placod = plani.placod and
                                 movim.movtdc = plani.movtdc and
                                 movim.movdat = plani.pladat no-lock:
                   
                    

                vicms =  ((movim.movpc * movim.movqtm) * 
                          (v-alicota / 100)).


                    
                run trata_cfop.p (input vopccod, 
                                  input movim.procod,
                                  input (movim.movpc *
                                         movim.movqtm),
                                  input v-alicota,   
                                  input vicms,   
                                  input 0,   
                                  output val_bas,  
                                  output val_ise,  
                                  output val_out,  
                                  output sittri,
                                  output valicm).
                    
                          
                find first tt-fiscal where 
                           tt-fiscal.etbcod  = vdesti and
                           tt-fiscal.opfcod  = vopccod and
                           tt-fiscal.alicota = v-alicota no-error.
                if not avail tt-fiscal
                then do:
               
                    create tt-fiscal.
                    assign tt-fiscal.etbcod  = vdesti
                           tt-fiscal.opfcod  = vopccod
                           tt-fiscal.alicota = v-alicota.
                         
                end.

                          
                assign tt-fiscal.totsai  = tt-fiscal.totsai + 
                                           (movim.movpc * movim.movqtm)
                       tt-fiscal.base    = tt-fiscal.base   + val_bas
                       tt-fiscal.icms    = tt-fiscal.icms   + valicm
                       tt-fiscal.ipi     = tt-fiscal.ipi    + 
                                          ((movim.movpc * movim.movqtm) * 
                                           (movim.movalipi / 100))
                       tt-fiscal.valcon  = tt-fiscal.valcon + 
                                           (movim.movpc * movim.movqtm)
                       tt-fiscal.outras  = tt-fiscal.outras + val_out
                       tt-fiscal.isentas = tt-fiscal.isenta + val_ise.
                 
            end.
            end.
            else do:
                    
                          
                find first tt-fiscal where 
                           tt-fiscal.etbcod  = vdesti and
                           tt-fiscal.opfcod  = vopccod and
                           tt-fiscal.alicota = 0 no-error.
                if not avail tt-fiscal
                then do:
               
                    create tt-fiscal.
                    assign tt-fiscal.etbcod  = vdesti
                           tt-fiscal.opfcod  = vopccod
                           tt-fiscal.alicota = 0.
                         
                end.

                          
                assign tt-fiscal.totsai  = tt-fiscal.totsai + 0
                       tt-fiscal.base    = tt-fiscal.base   + 0
                       tt-fiscal.icms    = tt-fiscal.icms   + plani.icms
                       tt-fiscal.ipi     = tt-fiscal.ipi    + 0
                       tt-fiscal.valcon  = tt-fiscal.valcon + 0
                       tt-fiscal.outras  = tt-fiscal.outras + 0
                       tt-fiscal.isentas = tt-fiscal.isenta + 0.

            
            
            end.
        end.
    end.

           

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
                                
                if plani.serie = "U" 
                then. 
                else next.
          
                if plani.emite = 995 and
                   plani.desti = 998 
                then next.
                if plani.emite = 998 and
                   plani.desti = 995
                then next.   
                
                vemite = plani.emite. 
                if vemite = 998 
                then vemite = 995.
            
                vdesti = plani.desti. 
                if vdesti = 998 
                then vdesti = 995.


                
                vdatexp = plani.datexp.
             
             
                vemite = plani.emite.  
                if vemite = 998  
                then vemite = 995.
            
                vdesti = plani.desti.  
                if vdesti = 998  
                then vdesti = 995.
               
                            
                if plani.movtdc = 6 or
                   plani.movtdc = 9 or
                   plani.movtdc = 22
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


                val_contabil = plani.platot. 
                
                                      
                find first bmovim where bmovim.etbcod = plani.etbcod and
                                        bmovim.placod = plani.placod and
                                        bmovim.movtdc = plani.movtdc and
                                        bmovim.movdat = plani.pladat  
                                            no-lock no-error.
                if avail bmovim
                then do:
                                    
                    for each movim where movim.etbcod = plani.etbcod and
                                         movim.placod = plani.placod and
                                         movim.movtdc = plani.movtdc and
                                         movim.movdat = plani.pladat
                                                no-lock:

                        v-alicota = movim.movalicms.
                                
                        
                        vicms =  ((movim.movpc * movim.movqtm) * 
                                  (movim.movalicms / 100)).

                         
                        
                        run trata_cfop.p (input vopccod, 
                                          input movim.procod,
                                          input (movim.movpc *
                                                 movim.movqtm),
                                          input movim.movalicm,   
                                          input vicms,   
                                          input 0,   
                                          output val_bas,  
                                          output val_ise,  
                                          output val_out,  
                                          output sittri,
                                          output valicm).
                                          
                          
                        find first tt-fiscal where 
                                   tt-fiscal.etbcod  = vemite  and
                                   tt-fiscal.opfcod  = vopccod and
                                   tt-fiscal.alicota = v-alicota no-error.
                        if not avail tt-fiscal
                        then do:
                
                            create tt-fiscal.
                            assign tt-fiscal.etbcod  = vemite
                                   tt-fiscal.opfcod  = vopccod
                                   tt-fiscal.alicota = v-alicota.
                           
                        end.

                    assign tt-fiscal.totsai  = tt-fiscal.totsai + 
                                               (movim.movpc * movim.movqtm)
                           tt-fiscal.base    = tt-fiscal.base   + val_bas
                           tt-fiscal.icms    = tt-fiscal.icms   + valicm
                           tt-fiscal.ipi     = tt-fiscal.ipi    + 
                                               ((movim.movpc * movim.movqtm) * 
                                                (movim.movalipi / 100))
                           tt-fiscal.valcon  = tt-fiscal.valcon + 
                                               (movim.movpc * movim.movqtm)
                           tt-fiscal.outras  = tt-fiscal.outras + val_out
                           tt-fiscal.isentas = tt-fiscal.isenta + val_ise.
                 
                    end.
                end.
                else do:
                    
                    assign v-alicota = 0.
                  
                    run trata_cfop.p (input vopccod, 
                                      input 0,
                                      input plani.platot, 
                                      input 17,    
                                      input plani.icms,    
                                      input 0,    
                                      output val_bas,   
                                      output val_ise,   
                                      output val_out,   
                                      output sittri,
                                      output valicm).
        
                
                    
                    find first tt-fiscal where 
                            tt-fiscal.etbcod  = vemite and
                            tt-fiscal.opfcod  = vopccod and
                            tt-fiscal.alicota = v-alicota no-error.
                    if not avail tt-fiscal
                    then do:
                
                        create tt-fiscal.
                        assign tt-fiscal.etbcod  = vemite
                               tt-fiscal.opfcod  = vopccod
                               tt-fiscal.alicota = v-alicota.
                           
                    end.

                    assign tt-fiscal.totsai  = tt-fiscal.totsai + plani.platot
                           tt-fiscal.base    = tt-fiscal.base   + val_bas
                           tt-fiscal.icms    = tt-fiscal.icms   + valicm
                           tt-fiscal.ipi     = tt-fiscal.ipi    + plani.ipi
                           tt-fiscal.valcon  = tt-fiscal.valcon + plani.platot
                           tt-fiscal.outras  = tt-fiscal.outras + val_out
                           tt-fiscal.isentas = tt-fiscal.isenta + val_ise.
                 
                    

                end.
  
                
                       
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

 
    
    
    
    varquivo = "l:\audit\tot" + string(vetbcod,">>9") + "_" +
               string(day(vdti),"99") +  
               string(month(vdti),"99") +  
               string(year(vdti),"9999") + "_" +  
               string(day(vdtf),"99") +  
               string(month(vdtf),"99") +  
               string(year(vdtf),"9999") + ".txt".

                   
                   
    output to value(varquivo).


    for each tt-fiscal break by tt-fiscal.etbcod.

        put tt-fiscal.etbcod format "999" 
            month(vdti) format "99"
            year(vdti) format "9999"
            tt-fiscal.opfcod   format "9999"
            tt-fiscal.alicota  format "99999"
            tt-fiscal.totsai   format "9999999999999.99"
            tt-fiscal.base     format "9999999999999.99"
            tt-fiscal.icms     format "9999999999999.99"
            tt-fiscal.isentas  format "9999999999999.99" 
            tt-fiscal.outras   format "9999999999999.99"
            tt-fiscal.ipi     format "9999999999999.99" skip.
                     

    end.            

    output close.

end.    
                           
