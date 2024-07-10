{admcab.i}

def var vsep as char.
     vsep = ";".
     
def var cst-piscofins as char.
def var cst-icms as char.
def var nat-receita as char.
def var icm-item like movim.movicms.
def var vicms like movim.movalicms. 
def var base-icms like plani.platot.
def var vdatexp like plani.datexp.
def var vdti like plani.pladat.
def var vdtf like plani.pladat.
def var vetbcod like estab.etbcod.
def var vopccod as char.
def var varq    as char. 

def temp-table tt-icm
field valor as dec.

def var tot-icms-item as dec.
def var tot-icms-ecf as dec.
def var tot-dif-icms as dec.
def var tot-des-item as dec.

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

def stream arq-csv.
def var varq-csv as char.
def var vnom as char.
def var vdir as char.
vdir = "/admcom/relat/".
def var varquivo as char format "x(60)".

repeat:
    do on error undo: 
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
    vnom = "cupom_MTP_" + trim(string(vetb,"x(3)")) + "_" +
                string(day(vdti),"99") +  
                string(month(vdti),"99") +  
                string(year(vdti),"9999") + "_" + 
                string(day(vdtf),"99") +  
                string(month(vdtf),"99") +  
                string(year(vdtf),"9999") + ".csv".
                 
    varquivo = vdir + vnom.
    update varquivo label "Arquivo"
        with frame f2 1 down side-label width 80.
    

    output to value(varquivo).
    
    put "Filial;Numero;Data;CFOP;Produto;Descrição;NCM;Val.Unit;Quant.
;Total;B.Calculo;AliqICMS;val.ICMS;B.Reduzida;ST;MVA.Interna;MVA.InerEstadual;
Aliq.PIS;Aliq.COFINS;BaseIPI;Aliq.IPI;Val.IPI" skip.

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

                    run piscofins2.p (recid(plani)).
                        
                    for each movim where movim.etbcod = plani.etbcod and
                                     movim.placod = plani.placod and
                                     movim.movtdc = plani.movtdc and
                                     movim.movdat = plani.pladat
                                     no-lock:

                        find first produ where produ.procod = movim.procod 
                                no-lock no-error.
                        if not avail produ then next.        
               
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
 
                    for each movim where movim.etbcod = plani.etbcod and
                                     movim.placod = plani.placod and
                                     movim.movtdc = plani.movtdc and
                                     movim.movdat = plani.pladat
                                     no-lock:

                        find first produ where produ.procod = movim.procod 
                                no-lock no-error.
                        if not avail produ then next.        
               
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

    message color red/with
            "Arquivo gerado:" skip
                varquivo
                    view-as alert-box.
                    
end.    

procedure p-calc-tributo.
                                          
    def var vestcusto like estoq.estcusto.
    def var vopc as log init no. 
    def var aux-uf as char init "".
  
    def var vx as char.     
    
    vmovpc = movim.movpc.    
   
    run aredonda-10-pl17.
    
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
           vestcusto =  round(vmovpc * movim.movqtm,2).
           icm-item = (round(vmovpc * movim.movqtm,2) * 
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

               /*vicms = 17.                                              
               */
               vend12 = vend12 + vestcusto.                       
         end.                                
                              
      end.                                                        
                                                                  
      assign base-icms =  vestcusto
             icm-item  = base-icms * (vicms / 100).
             /*
             trunc(base-icms * (vicms / 100),2). 
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

     if tot-dif-icms > 0 and
        substr(string(icm-item,"9999999.99"),9,2) <= "10" and
        movim.movalicms > 0
     then do:
        icm-item = icm-item + tot-des-item.
        tot-dif-icms = tot-dif-icms - tot-des-item.
     end. 
     
     if movim.movicms > 0
     then icm-item = movim.movicms.
        
     create tt-icm.
     valor = icm-item.
     
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
    def var s-movpc as char.
    def var s-movqt as char.
    def var s-total as char.
    def var s-bicms as char.
    def var s-aicms as char.
    def var s-vicms as char.
    def var s-apis  as char.
    def var s-acofins as char.
    
    
    assign
        s-movpc = string(vmovpc,">>>,>>>,>>9.99")
        s-movpc = replace(s-movpc,",","")
        s-movpc = replace(s-movpc,".",",")
        s-movqt = string(movim.movqtm,">>>,>>>,>>9.99")
        s-movqt = replace(s-movqt,",","")
        s-movqt = replace(s-movqt,".",",")
        s-total = string(movpc * movim.movqtm,">>>,>>>,>>9.99")
        s-total = replace(s-total,",","")
        s-total = replace(s-total,".",",")
        s-bicms = string(base-icms,">>>,>>>,>>9.99")
        s-bicms = replace(s-bicms,",","")
        s-bicms = replace(s-bicms,".",",")
        s-aicms = string(vicms,">>>,>>>,>>9.99")
        s-aicms = replace(s-aicms,",","")
        s-aicms = replace(s-aicms,".",",")
        s-vicms = string(icm-item,">>>,>>>,>>9.99")
        s-vicms = replace(s-vicms,",","")
        s-vicms = replace(s-vicms,".",",")
        s-apis    = string(vpis,">>>,>>>,>>9.99")
        s-apis    = replace(s-apis,",","")
        s-apis    = replace(s-apis,".",",")
        s-acofins = string(vcofins,">>>,>>>,>>9.99")
        s-acofins = replace(s-acofins,",","")
        s-acofins = replace(s-acofins,".",",")
        vclafis   = replace(vclafis,".","")
        .
    
                

        put unformatted
plani.etbcod
vsep
plani.numero
vsep
string(plani.pladat,"99999999")
vsep
vopccod
vsep
movim.procod format ">>>>>>>>>9"
vsep
produ.pronom
vsep
vclafis
vsep
s-movpc
vsep
s-movqt
vsep
s-total
vsep
s-bicms
vsep
s-aicms
vsep
s-vicms
vsep
vsep
vsep
vsep
vsep
s-apis
vsep
s-acofins
vsep
vsep
vsep
skip.
 
end procedure.


procedure aredonda-10-pl17:
    
    /* Comentado por Nede em 20/04/2012*/
    /***
    def var vare as log.
    vare = no.
    if movim.etbcod = 6 
    then vare = yes.
    else if movim.etbcod = 52
    then do:
        if movim.movdat = 03/16/12 or
           movim.movdat = 03/29/12
        then.
        else vare = yes.
    end.
    else if movim.etbcod = 8
    then do:
        if movim.movdat <> 03/06/12
        then.
        else vare = yes.
    end.
    else if movim.etbcod = 12
    then do:
        if  movim.movdat <> 03/07/12 and
            movim.movdat <> 03/06/12
        then.
        else vare = yes.
    end.
    else if movim.etbcod = 15
    then do:
        if  movim.movdat <> 03/07/12 and
            movim.movdat <> 03/06/12
        then.
        else vare = yes.
    end.
    else if movim.etbcod = 35
    then do:
        if movim.movdat = 03/12/12
        then.
        else vare = yes.
    end.
    else if movim.etbcod = 39
    then do:
        if movim.movdat = 03/13/12 or
           movim.movdat = 03/17/12 or
           movim.movdat = 03/24/12 or
           movim.movdat = 03/29/12
        then.
        else vare = yes.
    end.
    else if movim.etbcod = 51
    then do:
        if movim.movdat = 03/01/12 or
           movim.movdat = 03/10/12 or
           movim.movdat = 03/19/12 or
           movim.movdat = 03/27/12 
        then.    
        else vare = yes.
    end.
    else if movim.etbcod = 52
    then do:
        if movim.movdat = 03/16/12 or
           movim.movdat = 03/29/12 
        then.
        else vare = yes.
    end.
    else if movim.etbcod = 59
    then do:
        if movim.movdat = 03/02/12 or
           movim.movdat = 03/31/12
        then.
        else vare = yes.
    end.
    else if movim.etbcod = 60
    then do:
        if movim.movdat = 03/12/12
        then.
        else vare = yes.
    end.
    /*
    else if movim.etbcod = 65
    then do:
        if movim.movdat <> 03/27/12
        then.
        else vare = yes.
    end.*/
    else if movim.etbcod = 70
    then do:
        if movim.movdat = 03/13/12 or
           movim.movdat = 03/22/12 or
           movim.movdat = 03/29/12
        then.   
        else vare = yes.
    end.
    else if movim.etbcod = 77
    then do:
        if movim.movdat <> 03/07/12 and
           movim.movdat <> 03/03/12 and
           movim.movdat <> 03/04/12
        then.   
        else vare = yes.
    end.
    else if movim.etbcod = 87
    then do:
        if movim.movdat <> 03/07/12 and
           movim.movdat <> 03/06/12
        then.
        else vare = yes.
    end.
    else if movim.etbcod = 95
    then do:
        if movim.movdat <> 03/07/12 and
           movim.movdat <> 03/02/12 and
           movim.movdat <> 03/03/12 
        then.
        else vare = yes.
    end.
    else if movim.etbcod = 96
    then do:
        if movim.movdat <> 03/07/12 and
           movim.movdat <> 03/01/12 and
           movim.movdat <> 03/02/12 and
           movim.movdat <> 03/03/12 and
           movim.movdat <> 03/06/12 
        then.
        else vare = yes.
    end.
    else if movim.etbcod = 100
    then do:
        if movim.movdat <> 03/07/12 and
           movim.movdat <> 03/02/12
        then.
        else vare = yes.
    end.
    else if movim.etbcod = 101
    then do:
        if movim.movdat <> 03/07/12
        then.
        else vare = yes.
    end.
    else if movim.etbcod = 102
    then do:
        if movim.movdat = 03/05/12 or
           movim.movdat = 03/20/12 or
           movim.movdat = 03/21/12 
        then.
        else vare = yes.
    end.
    else if movim.etbcod = 110
    then do:
        if movim.movdat <> 03/06/12 and
           movim.movdat <> 03/07/12
        then.
        else vare = yes.
    end.
    else if movim.etbcod >= 66 and
            movim.etbcod <= 112 and
            movim.etbcod <> 110 and
            movim.etbcod <> 99 and
            movim.etbcod <> 93 
    then do:
        if movim.movdat < 03/07/2012
        then vare = yes.
        else vare = no.
    end.
    else vare = no.        
    if vare then do: 
        if movim.movdat >= 01/01/2012
        then do:
            find finesp where finesp.fincod = plani.pedcod no-lock no-error.
            if avail finesp
            then do:
                if finesp.finarr > 0
                then  vmovpc = vmovpc - ( vmovpc * (finesp.finarr / 100)).
            end.
        end.
    end.
    ***/
end.


procedure cal-icms:
        v-qcu = 0.
        for each plani where plani.movtdc = 5  and
                                 plani.etbcod = estab.etbcod and
                                 plani.pladat = mapctb.datmov
                                 /* 
                                  and
                                 plani.ufemi = vser /*and
                                 plani.cxacod =  mapctb.de1 
                                 plani.ufemi = mapctb.ch1*/
                                 */
                                 no-lock:

            if plani.ufemi = vser
            then. else next.
            
                    if substr(plani.notped,1,1) = "C"
                    then.
                    else next.
                    
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
               
                        if movim.movpc = 0 or
                            movim.movqtm = 0
                        then next.   
                    
                
                        find clafis where clafis.codfis = produ.codfis 
                            no-lock no-error. 
                        
                        if produ.pronom matches "*RECARGA*"
                        THEN NEXT. 
                        
                        vmovpc = movim.movpc.    
   
                        run aredonda-10-pl17.

                        if movim.movalicms > 0
                        then do:
                            tot-icms-item = tot-icms-item +
                                round((vmovpc * movim.movqtm) * 
                                (movim.movalicms / 100),2).
                        
                            v-qcu = v-qcu + 1.
                        end.
                    end. 
                end. 

                tot-icms-ecf  = (mapctb.t01 * 0.17) +
                                (mapctb.t03 * 0.07) +
                                ((mapctb.t02 * 0.705889) * 0.17).
                
                if tot-icms-item > 0
                then assign
                        tot-dif-icms = round(tot-icms-ecf - tot-icms-item,2)
                        tot-des-item = tot-dif-icms / 2
                        
                        .
                

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



