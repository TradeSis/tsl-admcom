def var cst-piscofins as char.
def var cst-icms as char.
def var nat-receita as char.
def var icm-item like plani.platot.
def var vicms like movim.movalicms. 
def var base-icms like plani.platot.
def var vdatexp like plani.datexp.
def var vdti like plani.pladat.
def var vdtf like plani.pladat.
def var vetbcod like estab.etbcod.
def var vopccod as char.
def var varq    as char. 
def var ali_icms_interna as dec format "999.99".

def var movim-movseq like movim.movseq.

def temp-table tt-icm
field valor as dec.

def var capa-pis as dec.
def var capa-cofins as dec. 

def var tot-icms-item like plani.platot.
def var tot-icms-ecf  like plani.platot.
def var tot-dif-icms  like plani.platot.
def var tot-des-item  like plani.platot.

def var v-qcu as dec.

def var vclafis as char.
def var vpis    like clafis.pisent.
def var vcofins like clafis.cofinsent.
def var val-pis    as dec.
def var val-cofins as dec.
def var base-liq   as dec.

def var tot-cofins as dec.
def var tot-pis as dec.

 def var vmovpc  like movim.movpc .

def var vmapicm     as dec. 
def var vmapvda     as dec. 
def var vlimicm     as dec. 
def var vlimvda    as dec.  
def var vmap12   as dec.    
def var vend12   as dec.    
def var vmapsub as dec.     
def var vendsub as dec.     

def var vcooini like mapctb.cooini.
def var vser as char.
def var vcont as int.

def var vetb as char. 
def var vfim as log.

def stream stela.        

def buffer bmovim for movim.
def buffer bplani for plani.
def buffer bmapctb for mapctb.

def var sparam as char.
sparam = SESSION:PARAMETER.
if num-entries(sparam,";") > 1
then sparam = entry(2,sparam,";").

/*
if opsys = "unix"
then do:
    run /admcom/progr/cupom-dif-serial.p.
end.
*/ 

def stream arq-csv.
def var varq-csv as char.

repeat:
    if opsys = "unix" and sparam <> "AniTA"
    then do:
        
        input from /file_server/param_ecf.
        repeat:
            import varq.
            vetbcod = int(substring(varq,1,3)).
            vdti    = date(int(substring(varq,6,2)),
                           int(substring(varq,4,2)),
                           int(substring(varq,8,4))).
            vdtf    = date(int(substring(varq,14,2)),
                           int(substring(varq,12,2)),
                           int(substring(varq,16,4))).
            if vetbcod = 0
            then varq = "/file_server/ven_" + 
                    trim(string(vetb,"x(3)")) + "_" + 
                         string(day(vdti),"99") +  
                         string(month(vdti),"99") +  
                         string(year(vdti),"9999") + "_" +  
                         string(day(vdtf),"99") +  
                         string(month(vdtf),"99") +  
                         string(year(vdtf),"9999") + ".txt".
            else varq = "/file_server/ven_" + 
                    trim(string(vetbcod,"999")) + "_" +
                         string(day(vdti),"99") +  
                         string(month(vdti),"99") +  
                         string(year(vdti),"9999") + "_" +  
                         string(day(vdtf),"99") +  
                         string(month(vdtf),"99") +  
                         string(year(vdtf),"9999") + ".txt".
         end.
        input close.
    
        if vetbcod = 999
        then return.
    
    end.
    else do: 
        update vetbcod with frame f1.
        if vetbcod = 0
        then display "GERAL" @ estab.etbnom with frame f1.
        else do:
            find estab where estab.etbcod = vetbcod no-lock.
            display estab.etbnom no-label with frame f1.
        
        end.

        update vdti label "Data Inicial" colon 16 
               vdtf label "Data Final" with frame f1 side-label width 80.
    end.
    
    def var vaux as dec.
    /*
    if vetbcod = 0
    then vetb = "".
    else vetb = string(vetbcod,"999").
    */
    if opsys = "unix" and sparam = "AniTA"
    then do:
        if vetbcod = 0
        then varq = "/admcom/decision/ven_" + 
                    trim(string(vetb,"x(3)")) + "_" +
                string(day(vdti),"99") +  
                string(month(vdti),"99") +  
                string(year(vdti),"9999") + "_" + 
                string(day(vdtf),"99") +  
                string(month(vdtf),"99") +  
                string(year(vdtf),"9999") + ".txt".
        else varq = "/admcom/decision/ven_" + 
                    trim(string(vetbcod,"999")) + "_" +
                string(day(vdti),"99") +  
                string(month(vdti),"99") +  
                string(year(vdti),"9999") + "_" + 
                string(day(vdtf),"99") +  
                string(month(vdtf),"99") +  
                string(year(vdtf),"9999") + ".txt".

        varq-csv = "/admcom/decision/ven_" + trim(string(vetbcod,"999")) 
        + "_" +
                string(day(vdti),"99") +  
                string(month(vdti),"99") +  
                string(year(vdti),"9999") + "_" + 
                string(day(vdtf),"99") +  
                string(month(vdtf),"99") +  
                string(year(vdtf),"9999") + ".csv".
    end.
    
    output to value(varq) .
    for each tipmov where tipmov.movtdc = 5 
                           no-lock:
        for each estab where if vetbcod = 0
                             then true 
                             else estab.etbcod = vetbcod no-lock:

            assign vfim = no
                   vmapicm = 0
                   vmap12  = 0
                   vmapsub = 0   
                   vmapvda = 0
                   vendsub = 0
                   vend12  = 0
                   vlimicm = 0
                   vlimvda = 0
                   VCONT = 0.
                             
            for each mapctb where mapctb.etbcod = estab.etbcod and  
                                  mapctb.datmov >= vdti        and
                                  mapctb.datmov <= vdtf        and     
                                  mapctb.ch2 <> "E" /*and
                                  mapctb.cxacod = 5 */                  
                           no-lock:                             
                             
            assign vfim = no
                   vmapicm = 0
                   vmap12  = 0
                   vmapsub = 0
                   vmapvda = 0
                   vendsub = 0
                   vend12  = 0
                   vlimicm = 0
                   vlimvda = 0
                   VCONT = 0
                   tot-pis = 0
                   tot-cofins = 0
                   vaux = 0.
                                                             
                 assign vmapicm = vmapicm  +                           
                        ( ( (mapctb.t02 * 0.705889) +             
                            (mapctb.t01)) * 0.17 +                
                             mapctb.t03 * 0.07 +
                             mapctb.t05 * 0.18)                   
                        vmap12 = vmap12 + mapctb.t02 + mapctb.t03      
                        vmapsub = vmapsub + mapctb.vlsub               
                        vmapvda = vmapvda + (mapctb.t01 +              
                                          mapctb.t02 +               
                                          mapctb.t03 +
                                          mapctb.t05 +               
                                          mapctb.vlsub ) .

                 vser = mapctb.ch1.
                 if vser = ""
                 then do: 
                        find first tabecf where 
                                   tabecf.etbcod   = mapctb.etbcod and
                                   tabecf.equipa   = mapctb.cxacod no-lock 
                            no-error.
                        if avail tabecf 
                        then assign vser = tabecf.serie.
                  end.      

                vfim = no.

                tot-icms-item = 0.
                
                run cal-icms.
                
                for each plani where plani.movtdc = 5  and
                                 plani.etbcod = estab.etbcod and
                                 plani.pladat = mapctb.datmov /*and
                                 plani.ufemi = vser /*and
                                 plani.cxacod =  mapctb.de1 
                                 plani.ufemi = mapctb.ch1*/
                                 */
                                 no-lock:
                    
                    if plani.ufemi = vser then. else next.
                    
                    if substr(plani.notped,1,1) = "C"
                    then.
                    else next.
                    
                    if vfim = yes 
                    then leave.

                    if plani.platot = 0
                    then next.
                    vcont = vcont + 1.
                    vcooini = 0.
                    if length(plani.notped) > 4 and
                       substr(plani.notped,2,1) = "|" and
                       substr(plani.notped,3,1) <> "|"
                    then vcooini = int(entry(2,plani.notped,"|")).
                    
                    if vcooini = 0
                    then do:
                        if length(string(plani.numero)) > 6
                        then vcooini = 
                        int(substr(string(plani.numero,"999999999"),4,6)).
                        else vcooini = plani.numero .
                    end.

                    run /admcom/progr/piscofins2.p (recid(plani)).
                    
                    capa-pis = plani.notpis.
                    capa-cofins = plani.notcofins.
                        
                    movim-movseq = 0.
                    for each movim where movim.etbcod = plani.etbcod and
                                     movim.placod = plani.placod and
                                     movim.movtdc = plani.movtdc and
                                     movim.movdat = plani.pladat
                                     no-lock:

                        find first produ where produ.procod = movim.procod 
                                no-lock no-error.
                        if not avail produ then next.        
               
                        if produ.proipiper = 98 /* Servicos */
                            /***and movim.etbcod <> 24 12/01/2016 ***/
                        then next.

                        if movim.movpc = 0 or
                           movim.movqtm = 0
                        then next.   
                
                        find clafis where clafis.codfis = produ.codfis 
                            no-lock no-error. 
                        /*
                        if not avail clafis or produ.codfis = 0  
                        then do:
                          if produ.pronom matches "*vivo*" or
                             produ.pronom matches "*tim*" or
                             produ.pronom matches "*claro*"
                         then next.
                        end.     
                        */
                        
                        if produ.pronom matches "*RECARGA*"
                        THEN NEXT. 
                        
                        vaux = vaux + (movim.movqt * movim.movpc).

                        find first opcom where opcom.movtdc = plani.movtdc
                                no-lock no-error.
                        if avail opcom 
                        then vopccod = string(opcom.opccod). 
                        else vopccod = "0".
                        
                        run p-calc-tributo.

                        if vmovpc > 0
                        then run p-gera-linha.
                    
                        if vfim = yes then leave.
                    end. 
                end.  
                for each plani where plani.movtdc = 45  and
                                 plani.etbcod = estab.etbcod and
                                 plani.pladat = mapctb.datmov /*and
                                 plani.cxacod = mapctb.cxacod
                                 /*
                                 plani.cxacod = mapctb.de1
                                 plani.ufemi = vser 
                                 */
                                 */
                                 no-lock:
                                 
                    if plani.cxacod = mapctb.cxacod then. else next.
                    
                    if substr(plani.notped,1,1) = "C"
                    then.
                    else next.
 
                    if vfim = yes 
                    then leave.

                    if plani.platot = 0
                    then next.
                    vcont = vcont + 1.
                    vcooini = 0.
                    if length(plani.notped) > 4 and
                       substr(plani.notped,2,1) = "|" and
                       substr(plani.notped,3,1) <> "|"
                    then vcooini = int(entry(2,plani.notped,"|")).
                    if vcooini = 0
                    then do:
                        if length(string(plani.numero)) > 6
                        then vcooini = 
                        int(substr(string(plani.numero,"999999999"),4,6)).
                        else vcooini = plani.numero .
                    end.
                    movim-movseq = 0.
                    for each movim where movim.etbcod = plani.etbcod and
                                     movim.placod = plani.placod and
                                     movim.movtdc = plani.movtdc and
                                     movim.movdat = plani.pladat
                                     no-lock:

                        find first produ where produ.procod = movim.procod 
                                no-lock no-error.
                        if not avail produ then next.        

                        if produ.proipiper = 98 /* Servicos */
                            /***and movim.etbcod <> 24 12/01/2016 ***/
                        then next.

                        if movim.movpc = 0 or
                           movim.movqtm = 0
                        then next.   

                        find clafis where clafis.codfis = produ.codfis 
                            no-lock no-error. 
                        /*
                        if not avail clafis or produ.codfis = 0  
                        then do:
                          if produ.pronom matches "*vivo*" or
                             produ.pronom matches "*tim*" or
                             produ.pronom matches "*claro*"
                         then next.
                        end.     
                        */
                        if produ.pronom matches "*RECARGA*"
                        THEN NEXT. 
                                             
                        vaux = vaux + (movim.movqt * movim.movpc).

                        find first opcom where opcom.movtdc = 5
                                no-lock no-error.
                        if avail opcom 
                        then vopccod = string(opcom.opccod). 
                        else vopccod = "0".
                        /*
                        run p-calc-tributo.
                        */
                        vmovpc = movim.movpc.
                        if vmovpc > 0
                        then run p-gera-linha.
                        /*
                        if vfim = yes then leave.
                        */
                    end. 
                end. 

                find bmapctb where rowid(bmapctb) = rowid(mapctb)
                            exclusive-lock no-error.
                if avail bmapctb
                then assign bmapctb.t12 = tot-pis
                        bmapctb.t13 = tot-cofins.
            end. 
        end. 
    end.
    output close.

    if opsys = "unix"
    then do.
         if search(varq) <> ?
         then unix silent chmod 777 value(varq).
    end.
    
    /*
    output to tt.
    for each tt-icm.
    put valor skip.
    end.
    output close.
    */
    
    if opsys = "unix"
    then return.
    
end.    

procedure p-calc-tributo.
                                          
    def var vestcusto like estoq.estcusto.
    def var vopc as log init no. 
    def var aux-uf as char init "".
  
    def var vx as char.     
    
    vmovpc = movim.movpc.    
   
    if movim.movtdc = 4
    then do:
         if can-find(first forne where forne.forcod = bplani.emit 
                                   and forne.ufecod = "AM")
         then aux-uf = "AM".
         else aux-uf = "".                          

    end.

    vpis = 0.
    vcofins = 0.
    
    if movim.movtdc = 4 and aux-uf = "AM"
    then assign vpis    = 1
                vcofins = 4.6.     
    else do: 
        if avail produ and produ.codfis = 0 
        then assign vpis = 1.65
                    vcofins = 7.6.  
        else if avail clafis
            then do:
                if tipmov.movtdc = 5
                then assign vpis    = clafis.pissai
                            vcofins = clafis.cofinssai.
                else assign vpis    = clafis.pisent
                             vcofins = clafis.cofinsent.
            end.
            else if not avail clafis
                then assign vpis = 1.65
                            vcofins = 7.6.
                            
    end.                                                
    /*                          
    assign vicms = movim.movalicms 
           vestcusto =  movim.movpc * movim.movqtm.
           icm-item = ((movim.movpc * movim.movqtm) * 
                            (movim.movalicms / 100)).
    */

    assign vicms = movim.movalicms 
           vestcusto =  (vmovpc * movim.movqtm).
           icm-item = ((vmovpc * movim.movqtm) * 
                            (movim.movalicms / 100)).

    if tipmov.movtdc = 5 and vicms <> 17 and vicms <> 18                             then do:                                                 
         if vmapsub > vendsub and vicms = 0                  
         then do:                                            
              if vmapsub < (vendsub + vestcusto)             
              then vestcusto = (vmapsub - vendsub).          
              vendsub = vendsub + vestcusto. 
              
              vx = "p0 " + string(vmapsub < (vendsub + vestcusto)  ).    

         end.                                                
         else do:                                            
               if vmap12 > vend12 and vicms > 0                   
               then if vmap12 < (vend12 + vestcusto)              
                    then vestcusto = (vmap12 - vend12).           
                    else.

           vx = "p1 " + string(vmap12 < (vend12 + vestcusto)) .

               /*vicms = 17.                                              
               */
               vend12 = vend12 + vestcusto.                       
         end.                                
                              
      end.                                                        
                                                                  
      assign base-icms =  vestcusto
             icm-item  = base-icms * (vicms / 100).
             /*
             trunc(
             base-icms * (vicms / 100),2). 
             */
     /****        
     if tipmov.movtdc = 5 and                                             
        (vmapicm < (vlimicm + (base-icms * (vicms / 100))) or       
         vmapvda < (vlimvda + base-icms))
     then do:                                     

          assign icm-item  = (vmapicm - vlimicm)   
                 base-icms = vmapvda - vlimvda.
/*
message '(' vmapicm "< (" vlimicm "+ (" base-icms "* (" vicms "/" 100 ")))" skip
         " or" vmapvda "< (" vlimvda "+" base-icms "))" skip
          "icm:" (vmapicm - vlimicm) 
          "Base:" (vmapvda - vlimvda) "custo:" vestcusto "alIcm:" icm-item
          skip "vmopc:" vmovpc movim.movpc vmovpc * movim.movqt
          "bicm" base-icms
          view-as alert-box.
  */               
           if icm-item < 0 or base-icms < 0
           then assign icm-item = 0 
                       
                       
                       base-icms = 0
                       vfim = yes.
             
          if base-icms > (vestcusto * 2)                            
          then do:
               assign base-icms = (vestcusto * 1.5)
                        icm-item =  base-icms * (vicms / 100).
                      /*
                      icm-item =  trunc(base-icms * (vicms / 100),2).
                    */
                 /*                                                                              (base-icms * (vicms / 100)).
                 */
          end.       
          else do:
               vfim = yes.             
          end.

          assign  vmovpc   =  base-icms / movim.movqtm. 
            icm-item =  base-icms * (vicms / 100).
            /*
          icm-item =  trunc(base-icms * (vicms / 100),2).
              */                      
     end.                                                          
     ****/
                                                                    
     assign base-liq  = (base-icms /*- icm-item*/).
      if base-liq < 0
      then assign base-liq = 0   
                  val-pis = 0
                  val-cofins = 0
                  vpis = 0
                  vcofins = 0.
      else assign val-pis  = base-liq * (vpis / 100)
                  val-cofins = (base-liq * (vcofins / 100)).  
       
       if tipmov.movtdc = 5
       then assign vlimicm = vlimicm + icm-item 
                   vlimvda = vlimvda + base-icms.
      
end procedure.                                                               

procedure p-gera-linha.
  
  def var vciccgc as char.
  
  if base-liq < 0 then  base-liq = 0.
  if vcofins < 0 then vcofins = 0.
  if val-cofins < 0 then val-cofins = 0.
  if vpis < 0 then vpis = 0.
  if val-pis < 0 then val-pis = 0.
  
  if vicms  <=  0 or icm-item <= 0 or base-icms <= 0  
  then assign vicms = 0
              icm-item = 0
              base-icms = 0.

    if movim.movalicms = 0
    then vopccod = "5405".
  
  if base-icms = .01
  then icm-item = .01 .
          
  if vpis = ? then vpis = 0.
  if vcofins = ? then vcofins = 0.
  if vpis = 0 and vcofins = 0
  then assign
            /*base-liq = 0*/ 
            val-pis = 0
            val-cofins = 0
            .
    /*
    if  vpis = 0 and vcofins = 0
    then do:
        cst-piscofins = "0606".
        if substr(string(produ.codfis),1,4) = "4013"
        then cst-piscofins = "0404".
        if substr(string(produ.codfis),1,5) = "85272"
        then cst-piscofins = "0404".
        if produ.codfis = 85071000
        then cst-piscofins = "0404".
    end.
    else 
    */
    
    cst-piscofins = "0101".
    
    if avail clafis and
             clafis.log1 /* Monofasico */
    then cst-piscofins = "0404".         

    vclafis = "".
    
    if produ.codfis > 0
    then vclafis = substring(string(produ.codfis),1,4) + 
                                       "." +   
                                       substring(string(produ.codfis),5,2) +  
                                       "." +  
                                       substring(string(produ.codfis),7,2).

     
     if movim.movalicms > 0
     then do:
        icm-item = (movim.movpc * movim.movqtm) * (movim.movalicms / 100).
     end.
     /*   
     create tt-icm.
     valor = icm-item.
     */
    vciccgc = "".
    find clien where clien.clicod = plani.desti no-lock no-error.
    if avail clien
    then do:
        vciccgc = clien.ciccgc.
        run Pi-cic-number(input-output vciccgc).
    end.

    if movim.movalicms = 0
    then cst-icms = "060" .
    else cst-icms = "000" .
    
    nat-receita = "".
    
    if avail clafis
    then do:
    /*
    if clafis.sittri > 0
    then cst-icms = string(clafis.sittri,"999").
    */
    if clafis.int2 > 0
    then cst-piscofins = string(clafis.int2,"99") + string(clafis.int2,"99").
             
    nat-receita = string(clafis.int3,"999").
             
    if clafis.log1 
    then assign
             vpis = 0
             val-pis = 0
             vcofins = 0
             val-cofins = 0
             .
    
    /*** lei-do-bem extinta
    
    if clafis.codfis = 84715010 and
       movim.movpc   <= 2000
    then assign
            cst-piscofins = "0606"
            nat-receita   = "401"
            vpis = 0
             val-pis = 0
             vcofins = 0
             val-cofins = 0
             .

    if (clafis.codfis = 84713012 or
       clafis.codfis = 84713019 or
       clafis.codfis = 84713090) and 
       movim.movpc <= 4000
    then assign
             cst-piscofins = "0606"
             nat-receita   = "402"
             vpis = 0
             val-pis = 0
             vcofins = 0
             val-cofins = 0
             .

    if clafis.codfis = 847141 and
       movim.movpc <= 2500
    then assign
             cst-piscofins = "0606"
             nat-receita   = "407"
             vpis = 0
             val-pis = 0
             vcofins = 0
             val-cofins = 0
             .

    if (clafis.codfis = 85176255 or
       clafis.codfis = 85176262 or
       clafis.codfis = 85176272) and
       movim.movpc <= 200
    then assign
             cst-piscofins = "0606"
             nat-receita   = "408"
             vpis = 0
             val-pis = 0
             vcofins = 0
             val-cofins = 0
             .

    if clafis.codfis = 85171231 and
       movim.movpc <= 1500
    then assign
            cst-piscofins = "0606"
            nat-receita   = "409"
            vpis = 0
             val-pis = 0
             vcofins = 0
             val-cofins = 0
             .
    lei-do-bem extinta ****/
    
    if substr(string(clafis.codfis),1,4) = "4011" or
       substr(string(clafis.codfis),1,4) = "4013"
    then assign
            cst-piscofins = "0404"
            nat-receita   = "304".
    if substr(string(clafis.codfis),1,6) = "850710" 
    then assign
             cst-piscofins = "0404"
             nat-receita   = "302".
    if substr(string(clafis.codfis),1,5) = "85272"
    then assign
            cst-piscofins = "0404"
            nat-receita   = "302".
    if string(clafis.codfis) = "85365090"
    then assign
             cst-piscofins = "0404"
             nat-receita   = "302".
    end.
    if movim.movalicms > 0
    then do:
        icm-item = (movim.movpc * movim.movqtm) * (movim.movalicms / 100).
        vicms = movim.movalicms.
        run dif-icms.
    end.
    if icm-item < 0 then icm-item = 0.
    
    if cst-icms = "004"
    then base-liq = 0.
    if cst-piscofins = "0404"
    then base-liq = 0.

    movim-movseq = movim-movseq + 1.

    if base-liq = .01 and base-icms = 0
    then base-icms = base-liq.
    if base-liq = .02 and base-icms = 0
    then base-icms = base-liq.
    
        ali_icms_interna = 0.
        /*cod_cest_nat = "".*/
        if avail movim
        then do:
            find produ where produ.procod = movim.procod  no-lock no-error.
            if avail produ 
            then do:
                if produ.al_Icms_Efet <> 0
                then ali_icms_interna = produ.al_Icms_Efet.
                else ali_icms_interna = produ.proipiper.
                if estab.ufecod <> "RS"
                then run aliq-icms-interna(output ali_icms_interna).

                find clafis where clafis.codfis = produ.codfis 
                no-lock no-error.
                /*if avail clafis
                then cod_cest_nat = clafis.char1.
                */
            end. 
        end. 

put unformatted
/* 001-003 */  string(plani.etbcod,">>9") at 01
/* 004-006 */  string(mapctb.cxacod,"999")
/* 007-026 */  vser format "x(20)"
/* 027-028 */  "2D" format "x(02)"
/* 029-034 */  vopccod format "x(06)" 
/* 035-038 */  string(year(plani.pladat),"9999")  
/* 039-040 */  string(month(plani.pladat),"99") 
/* 041-042 */  string(day(plani.pladat),"99")
/* 043-048 */  vcooini format "999999"
/* 049-050 */  (if movim.movtdc = 5 then "00" else "02")
/* 051-053 */  movim-movseq format "999"
/* 054-073 */  string(movim.procod) format "x(20)"
/* 074-076 */  "UN "
/* 077-092 */  movim.movqt format "999999999999.999"
/* 093-108 */  vmovpc format "999999999999.999"
/* 109-124 */  (movim.movqt *  vmovpc ) format "9999999999999.99" 
/* 125-140 */  movim.movpdesc format "9999999999999.99"
/* 141-156 */  "0000000000000.00"
/* 157-172 */  base-icms        format "9999999999999.99"
/* 173-179 */  vicms            format "9999.99"
/* 180-195 */  icm-item         format "9999999999999.99"
/* 196-211 */ "0000000000000.00"
/* 212-218 */ "0000.00" 
/* 219-234 */ "0000000000000.00"
/* 235-236 */ "01"  /* Número de 01 a 15 que corresponde ao acumulador 
            em que a Situação Tributária ou Alíquota do Item é armazenado */
            
            /*
            if movim.movalicms = 0
            then "060" else "000"
            */
            
            cst-icms format "x(3)"
            
            /*
            (if avail clafis 
               then string(clafis.sittri,"999")
               else "010") /* Código da Sit Trib 
                           conforme Tabela 4.3.1 do Ato COTEPE 70;
                          010 = nacional */*/             

/* 241-244 */ (if plani.movtdc = 45
                then "CANC"
              else if movim.movalicms = 0
              then "F   " 
              else if movim.movalicms = 17 or
                      movim.movalicms = 12 or
                      movim.movalicms = 7  or
                      movim.movalicms = 18
                   then replace(string(movim.movalicms,"99.99"),".","")
                   else "F   ")
                   /* Identificador da Situação Tributária / 
                               Alíquota do ICMS (com 2 decimais). 
                       Se Alíquota = 18,00 informar 1800; 
                       Se Isento, informar "I "; 
                       Se Não Tributado informar "N "; 
                       Se Subst Tributária, informar "F "; 
                       Se Cancelado, informar "CANC"; 
                       Se Desconto, informar "DESC";
                       Se Serviço, informar "ISS ";
                     */
/* 245-261 */ base-liq    format "99999999999999.99"
/* 262-268 */ vcofins     format "99.9999"
/* 269-285 */ val-cofins  format  "99999999999999.99"
/* 286-302 */ base-liq    format "99999999999999.99"
/* 303-309 */ vpis        format "99.9999"
/* 310-326 */ val-pis     format  "99999999999999.99"
/* 329-    */ cst-piscofins format "x(4)"
.             
/* 334 ??? */ put vclafis format "x(10)"
/* 340     */   "4.1.03.02" format "x(28)"
/* 368     */   "4.1.03.02" format "x(28)"
/* 396     */   string(plani.placod,">>>>>>>>>>>9") format "x(20)".
/* 416     */
if length(vciccgc) = 11 or
   length(vciccgc) = 14
then do:
    put vciccgc format "x(18)"
        clien.clinom format "x(32)"
        .
end.
else put "" format "x(50)".
put /* 466 */ nat-receita format "x(3)".

/********  não esta usando
put /*425   */ (movim.movqt *  vmovpc )  format "9999999999999.99"
    /*441   */ capa-pis                  format "9999999999999.99"
    /*457   */ capa-cofins               format "9999999999999.99"
**********/

put /*469   */ ali_icms_interna          format "999.99"
      .

put skip.


tot-pis = tot-pis + val-pis.
tot-cofins = tot-cofins + val-cofins.
 
end procedure.


procedure cal-icms:
        tot-icms-item = 0.
        tot-dif-icms = 0.
        for each plani where plani.movtdc = 5  and
                                 plani.etbcod = estab.etbcod and
                                 plani.pladat = mapctb.datmov 
                                 no-lock:
                    
                    if plani.ufemi = vser then. else next.
                    
                    if substr(plani.notped,1,1) = "C"
                    then.
                    else next.
                    
                    if vfim = yes 
                    then leave.

                    if plani.platot = 0
                    then next.

                    for each movim where movim.etbcod = plani.etbcod and
                                     movim.placod = plani.placod and
                                     movim.movtdc = plani.movtdc and
                                     movim.movdat = plani.pladat
                                     no-lock:

                        find first produ where produ.procod = movim.procod 
                                no-lock no-error.
                        if not avail produ then next.        
               
                        if produ.proipiper = 98 
                        then next.

                        if movim.movpc = 0 or
                           movim.movqtm = 0
                        then next.   
                
                        if produ.pronom matches "*RECARGA*"
                        THEN NEXT. 
                        
                        if movim.movalicms > 0
                        then do:
                        tot-icms-item = tot-icms-item +
                            ((movim.movpc * movim.movqtm) *
                            (movim.movalicms / 100)).
                            /**
                            output to /admcom/relat/tetse.cl append.
                            put ((movim.movpc * movim.movqtm) *
                                                        (movim.movalicms / 
                            100)) format "9999999999999.99" skip.
                            output close.
                            **/
                        end.
                    end. 
                end.  
                for each plani where plani.movtdc = 45  and
                                 plani.etbcod = estab.etbcod and
                                 plani.pladat = mapctb.datmov 
                                 no-lock:
                                 
                    if plani.cxacod = mapctb.cxacod then. else next.
                    
                    if substr(plani.notped,1,1) = "C"
                    then.
                    else next.
 
                    if vfim = yes 
                    then leave.

                    if plani.platot = 0
                    then next.
 
                    for each movim where movim.etbcod = plani.etbcod and
                                     movim.placod = plani.placod and
                                     movim.movtdc = plani.movtdc and
                                     movim.movdat = plani.pladat
                                     no-lock:

                        find first produ where produ.procod = movim.procod 
                                no-lock no-error.
                        if not avail produ then next.        

                        if produ.proipiper = 98 
                        then next.

                        if movim.movpc = 0 or
                           movim.movqtm = 0
                        then next.   

                        if produ.pronom matches "*RECARGA*"
                        THEN NEXT. 
                        if movim.movalicms > 0
                        then do:
                        tot-icms-item = tot-icms-item +
                            ((movim.movpc * movim.movqtm) *
                            (movim.movalicms / 100)).
                            /*
                            output to /admcom/relat/tetse.cl append.
                            put ((movim.movpc * movim.movqtm) *
                                                        (movim.movalicms / 
                            100)) format "9999999999999.99" skip.
                            output close.
                            */
                        end.
                    end. 
                end. 

                tot-icms-ecf  = (mapctb.t01 * 0.17) +
                                (mapctb.t03 * 0.07) +
                                ((mapctb.t02 * 0.705889) * 0.17) +
                                (mapctb.t05 * 0.18).
                
                if tot-icms-item <> 0
                then tot-dif-icms = tot-icms-ecf - tot-icms-item.
                if tot-dif-icms < (- 1.00) or tot-dif-icms > 1.00
                then tot-dif-icms = 0.   
                    

        /***
        def var vt as dec decimals 2.
        def var va as char.
        input from /admcom/relat/tetse.cl.
        repeat:
            import va.
            vt = vt + dec(va).    
        end.
        input close.
        message vt.
        ***/
end procedure.


Procedure Pi-cic-number.

def input-output  parameter p-ciccgc  like clien.ciccgc.
def var v-ciccgc like clien.ciccgc.
def var jj          as int.
def var ii          as int.
def var v-carac     as char format "x(1)".

assign v-ciccgc = "".
do ii = 1 to length(p-ciccgc):
   assign v-carac = string(substr(p-ciccgc,ii,1)).
      do jj = 1 to 10:
        if string(jj - 1) = v-carac then assign v-ciccgc = v-ciccgc + v-carac.
      end.
end.
assign p-ciccgc = v-ciccgc.

end procedure.

def var vdig as int.
def var vdif as int.
procedure dif-icms:
    if tot-dif-icms > 0
            then do:
                if tot-dif-icms <= .02
                then assign
                    icm-item = icm-item + tot-dif-icms
                    tot-dif-icms = 0.
                else assign
                    icm-item = icm-item + .02
                    tot-dif-icms = tot-dif-icms - .02
                    .
            end.
            else if tot-dif-icms < 0
            then do:
                if (-1) * tot-dif-icms <= .02
                then assign
                    icm-item = icm-item + tot-dif-icms
                    tot-dif-icms = 0.
                else assign
                    icm-item = icm-item - .02
                    tot-dif-icms = tot-dif-icms + .02
                    .
            end.
end procedure.

procedure aliq-icms-interna:

    def output parameter pct-icms as dec.

    find first tribicms where tribicms.pais-sigla   = "BRA"
                      and tribicms.ufecod       = estab.ufecod
                      and tribicms.pais-dest    = "BRA"
                      and tribicms.unfed-dest   = estab.ufecod
                      and tribicms.procod       = 0
                      and tribicms.cfop         = 0
                      and tribicms.agfis-cod    = 0
                      and tribicms.agfis-dest   = 0
                      and tribicms.dativig     <= today
                      and ( tribicms.datfvig    = ? or
                            tribicms.datfvig   >= today )
                            use-index tribicms no-error.
    if not avail tribicms
    then find first tribicms where tribicms.pais-sigla   = "BRA"
                      and tribicms.ufecod       = estab.ufecod
                      and tribicms.pais-dest    = "BRA"
                      and tribicms.unfed-dest   = estab.ufecod
                      and tribicms.procod       = 0
                      and tribicms.cfop         = 0
                      and tribicms.agfis-cod    = produ.codfis
                      and tribicms.agfis-dest   = 0
                      and tribicms.dativig     <= today
                      and ( tribicms.datfvig    = ? or
                            tribicms.datfvig   >= today )
                            use-index tribicms no-error.

    if avail tribicms  
    then if tribicms.al_icms_efet > 0
        then pct-icms = tribicms.al_icms_efet.
        else pct-icms = tribicms.pcticms. 

end procedure.
