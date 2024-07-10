/** Programa original ven_aud.p **/

def var icm-item like movim.movicms.
def var vicms like movim.movalicms. 
def var base-icms like plani.platot.
def var vdatexp like plani.datexp.
def var vdti like plani.pladat.
def var vdtf like plani.pladat.
def var vetbcod like estab.etbcod.
def var vopccod as char.
def var varq    as char. 

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
 
repeat:
    if opsys = "unix" and sparam <> "AniTA"
    then do:
        
        input from /admcom/audit/param_mr.
        repeat:
            import varq.
            vetbcod = int(substring(varq,1,3)).
            vdti    = date(int(substring(varq,6,2)),
                           int(substring(varq,4,2)),
                           int(substring(varq,8,4))).
            vdtf    = date(int(substring(varq,14,2)),
                           int(substring(varq,12,2)),
                           int(substring(varq,16,4))).
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

    if vetbcod = 0
    then vetb = "".
    else vetb = string(vetbcod,"999").
    if opsys = "unix"
    then varq = "/admcom/audit/ven_" + trim(string(vetb,"x(3)")) + "_" +
                string(day(vdti),"99") +  
                string(month(vdti),"99") +  
                string(year(vdti),"9999") + "_" + 
                string(day(vdtf),"99") +  
                string(month(vdtf),"99") +  
                string(year(vdtf),"9999") + ".txt".

    else varq = "l:\audit\ven_" + trim(string(vetb,"x(3)")) + "_" + 
                string(day(vdti),"99") +   
                string(month(vdti),"99") +   
                string(year(vdti),"9999") + "_" +  
                string(day(vdtf),"99") +   
                string(month(vdtf),"99") +   
                string(year(vdtf),"9999") + ".txt".

    output to value(varq) .

        
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
                                  mapctb.ch2 <> "E"                    
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
                             mapctb.t03 * 0.07)                   
                        vmap12 = vmap12 + mapctb.t02 + mapctb.t03      
                        vmapsub = vmapsub + mapctb.vlsub               
                        vmapvda = vmapvda + (mapctb.t01 +              
                                          mapctb.t02 +               
                                          mapctb.t03 +               
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

            for each plani where plani.movtdc = 5 /* tipmov.movtdc */ and
                                 plani.etbcod = estab.etbcod and
                                 plani.pladat = mapctb.datmov and
                                 plani.ufemi = vser and
                                 plani.notped = "C"
                            /*     plani.pladat >= vdti and
                                 plani.pladat <= vdtf */

                                 no-lock:
                                 
                    if vfim = yes 
                    then leave.

                    if plani.platot = 0
                    then next.
                    vcont = vcont + 1.
                
                    vcooini = plani.numero /*mapctb.cooini*/.
                        
                for each movim where movim.etbcod = plani.etbcod and
                                     movim.placod = plani.placod and
                                     movim.movtdc = plani.movtdc and
                                     movim.movdat = plani.pladat
                                     no-lock:

                        find first produ where produ.procod = movim.procod 
                                no-lock.
               
                        if movim.movpc = 0 or
                            movim.movqtm = 0
                        then next.   
                    
                
                        find clafis where clafis.codfis = produ.codfis 
                            no-lock no-error. 

                        if not avail clafis or produ.codfis = 0  
                        then do:
                          if produ.pronom matches "*vivo*" or
                             produ.pronom matches "*tim*" or
                             produ.pronom matches "*claro*"
                         then next.
                        end.     
                     
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
                                 plani.pladat = mapctb.datmov and
                                 plani.ufemi = vser and
                                 plani.notped = "C"
                                 no-lock:
                                 
                    if vfim = yes 
                    then leave.

                    if plani.platot = 0
                    then next.
                    vcont = vcont + 1.
                
                    vcooini = plani.numero /*mapctb.cooini*/.
                        
                for each movim where movim.etbcod = plani.etbcod and
                                     movim.placod = plani.placod and
                                     movim.movtdc = plani.movtdc and
                                     movim.movdat = plani.pladat
                                     no-lock:

                        find first produ where produ.procod = movim.procod 
                                no-lock.
               
                        if movim.movpc = 0 or
                            movim.movqtm = 0
                        then next.   
                    
                
                        find clafis where clafis.codfis = produ.codfis 
                            no-lock no-error. 

                        if not avail clafis or produ.codfis = 0  
                        then do:
                          if produ.pronom matches "*vivo*" or
                             produ.pronom matches "*tim*" or
                             produ.pronom matches "*claro*"
                         then next.
                        end.     
                     
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
            find bmapctb where rowid(bmapctb) = rowid(mapctb)
                            exclusive-lock no-error.
            if avail bmapctb
            then assign bmapctb.t12 = tot-pis
                        bmapctb.t13 = tot-cofins.
            
        end. 
    end.
    output close.

    if opsys = "unix"
    then do.
         if search(varq) <> ?
         then unix silent chmod 777 value(varq).
    end.
  
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

    if movim.movtdc = 4 and aux-uf = "AM"
    then assign vpis    = 1
                vcofins = 4.6.     
    else 
        if avail produ and produ.codfis = 0 
        then assign vpis = 1.65
                    vcofins = 7.6.  
        else do:    
             if not avail clafis
             then assign vpis = 0
                         vcofins = 0.
             else if tipmov.movtdc = 5
                  then assign vpis    = clafis.pissai
                             vcofins = clafis.cofinssai.
                  else assign vpis    = clafis.pisent
                              vcofins = clafis.cofinsent.
    end.                                                
                              
    assign vicms = movim.movalicms 
           vestcusto =  movim.movpc * movim.movqtm.
           icm-item = ((movim.movpc * movim.movqtm) * 
                            (movim.movalicms / 100)).
    
    if tipmov.movtdc = 5 and vicms <> 17                           
    then do:                                                 
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

               vicms = 17.                                              
               vend12 = vend12 + vestcusto.                       
         end.                                
                              
      end.                                                        
                                                                  
      assign base-icms =  vestcusto
             icm-item  = base-icms * (vicms / 100).
             /*
             trunc(base-icms * (vicms / 100),2). 
             */
     /****/        
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
     /****/
                                                                    
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
          
       put unformatted
/* 001-003 */  string(plani.etbcod,">>9") at 01
/* 004-006 */  string(mapctb.cxacod,"999")
/* 007-026 */  vser format "x(20)"
/* 027-028 */  "2D" format "x(02)"
/* 029-034 */  vopccod format "x(06)" 
/* 035-038 */  string(year(plani.pladat),"9999")  
/* 039-040 */  string(month(plani.pladat),"99") 
/* 041-042 */  string(day(plani.pladat),"99")
/* 043-049 */  vcooini format "9999999"
/* 050-051 */  (if movim.movtdc = 5 then "00" else "05")
/* 052-054 */  movim.movseq format "999"
/* 055-074 */  string(movim.procod) format "x(20)"
/* 075-077 */  "UN "
/* 078-093 */  movim.movqt format "999999999999.999"
/* 094-109 */  vmovpc format "999999999999.999"
/* 110-125 */  (movim.movqt *  vmovpc ) format "9999999999999.99" 
/* 126-141 */  movim.movpdesc format "9999999999999.99"
/* 142-157 */  "0000000000000.00"
/* 158-173 */  base-icms        format "9999999999999.99"
/* 174-180 */  vicms            format "9999.99"
/* 181-196 */  icm-item         format "9999999999999.99"
/* 197-212 */ "0000000000000.00"
/* 213-219 */ "0000.00" 
/* 220-235 */ "0000000000000.00"
/* 236-237 */ "01"  /* Número de 01 a 15 que corresponde ao acumulador 
            em que a Situação Tributária ou Alíquota do Item é armazenado */
/* 238-240 */ 
            if movim.movalicms = 0
            then "060" else "000"
            
            /*
            (if avail clafis 
               then string(clafis.sittri,"999")
               else "010") /* Código da Sit Trib 
                           conforme Tabela 4.3.1 do Ato COTEPE 70;
                          010 = nacional */*/             

/* 241-244 */ (if movim.movalicms = 0
              then "F   " 
              else if movim.movalicms = 17 or
                      movim.movalicms = 12
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
             skip.

tot-pis = tot-pis + val-pis.
tot-cofins = tot-cofins + val-cofins.
 
end procedure.

