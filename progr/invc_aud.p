def var aux-liq as dec.
def var aux-pis as dec.
def var aux-cofins as dec.
def var aux-icms as dec.
def var aux-subst as dec.
def var vicms as dec.
def var vpis as dec.
def var vcofins as dec.
def var vano as int.
def var vmes as int.
def var vdtf as date.
def var vcodfis as int.
def var obs-cod as char     .
def var sal-val-icms as dec.
def var qtd-est-periodo as dec.
def var custo-unitario-periodo as dec.
def var val-icms-periodo as dec.
def var vtot-custo as dec.
def temp-table tt-inv
    field etbcod like estab.etbcod
    field valor as dec
    index i1 etbcod.

update vmes vano.

vdtf = date(if vmes = 12 then 01 else vmes + 1,01,
            if vmes = 12 then vano + 1 else vano) - 1.
message vdtf. pause.

def var vetbi like estab.etbcod.
def var varquivo as char.

if opsys = "unix"
then varquivo = "/admcom/audit/inventario/inv_" 
                + trim(string(vetbi,"999")) + "_" +
                /*string(day(vdti),"99") +  
                string(month(vdti),"99") +  
                string(year(vdti),"9999") + "_" +*/ 
                string(day(vdtf),"99") +  
                string(month(vdtf),"99") +  
                string(year(vdtf),"9999") + ".txt".

def var vetbinv like estab.etbcod.

output to value(varquivo).

for each estab no-lock:

     if estab.etbcod > 200 and
       estab.etbcod <> 988 and
       estab.etbcod <> 993 and
       estab.etbcod <> 995 and
       estab.etbcod <> 996 and
       estab.etbcod <> 900
    then next.
       
    if estab.etbcod = 10 then next.
   
    for each ctbhie where
             ctbhie.etbcod = estab.etbcod and
             ctbhie.ctbano = vano and
             ctbhie.ctbmes = vmes
             no-lock:
        find produ where produ.procod = ctbhie.procod no-lock no-error.
        if not avail produ then next.
        
        vcodfis = produ.codfis.
        
        run busca-ali.
        run inventario.
    end.
end.
output close.

def var vtotal-geral as dec.
varquivo = "/admcom/audit/inventario/totinv_" 
            + trim(string(vetbi,"999")) + "_" +
                /*string(day(vdti),"99") +  
                string(month(vdti),"99") +  
                string(year(vdti),"9999") + "_" +*/ 
                string(day(vdtf),"99") +  
                string(month(vdtf),"99") +  
                string(year(vdtf),"9999") + ".txt".

output to value(varquivo).
for each tt-inv.
    put tt-inv.etbcod ";"
        tt-inv.valor format "->>>>>>>>>>>9.99"
        skip.
    vtotal-geral = vtotal-geral + tt-inv.valor.
end.
output close.
        
disp vtotal-geral format ">>>,>>>,>>9.99".
pause.

procedure busca-ali:

       def var vali as char.
        
       if produ.proipiper = 17 or
          produ.proipiper = 0
       then vali = "01".
       if produ.proipiper = 12.00 or
          produ.pronom begins "Computa"
       then vali = "FF".
       if produ.pronom begins "Pneu" or
          produ.proipiper = 999
       then vali = "FF".
       if produ.proseq = 1
          then vali = "03".
    
        if vali = "01"
        then vicms = 17.
        else if vali = "02"
             then vicms = 12.
             else if vali = "03"
                  then vicms = 7.
                  else if vali = "04"
                       then vicms = 25.
                       else vicms = 0.
                                    
end procedure.

procedure cto-med:
    find last movim where movim.movtdc = 4 and
                         movim.procod = produ.procod and
                         movim.movdat <= vdtf
                         no-lock no-error.
    if avail movim
    then do:
        find first plani where plani.etbcod = movim.etbcod and
                         plani.placod = movim.placod and
                         plani.movtdc = movim.movtdc
                         no-lock no-error.
                         
        vicms = movim.MovAlICMS.
    
        assign 
                vpis = 0.65  
                vcofins = 3.0.

        if avail plani
        then do:
                find forne where 
                     forne.forcod = plani.emite no-lock no-error.
                if avail forne and
                   forne.ufecod = "AM"
                then  assign vpis    = 1
                      vcofins = 4.6.     
                else if produ.codfis = 0
                then assign vpis = 1.65
                         vcofins = 7.6.  
                else do:
                  find clafis where clafis.codfis = produ.codfis 
                        no-lock no-error.
                  if not avail clafis
                  then assign vpis = 0
                              vcofins = 0.
                  else do:
                       assign vpis    = clafis.pisent
                              vcofins = clafis.cofinsent.
                  end.                 
             end.
        end.
      
      /*** Tatamento para Monofásico ***/
        
            if substr(string(produ.codfis),1,4) = "4013"
            then assign vpis = 0 vcofins = 0.
            if substr(string(produ.codfis),1,5) = "85272"
            then assign vpis = 0 vcofins = 0.
            if produ.codfis = 85071000
            then assign vpis = 0 vcofins = 0.

            if avail clafis and clafis.log1 /* Monofasico */
            then assign vpis = 0 vcofins = 0. 
      
           
    end.
                             
end procedure.

procedure inventario:
      /*          
      if vicms = 17                            
      then aux-icms  = trunc(ctbhie.ctbcus * (vicms / 100),2).
      else aux-subst = trunc(ctbhie.ctbcus * (vicms / 100),2). 
              
      assign aux-liq  = ctbhie.ctbcus - aux-icms
             aux-pis  = (aux-liq * (vpis / 100))
             aux-cofins = (aux-liq * (vcofins / 100)).
      */

      vetbinv = ctbhie.etbcod.
      
      if ctbhie.etbcod = 113
          or ctbhie.etbcod = 901
          or ctbhie.etbcod = 902
          or ctbhie.etbcod = 903
          or ctbhie.etbcod = 904
          or ctbhie.etbcod = 905
          or ctbhie.etbcod = 906
          or ctbhie.etbcod = 907
          or ctbhie.etbcod = 910
          or ctbhie.etbcod = 919
          or ctbhie.etbcod = 920
          or ctbhie.etbcod = 921
          or ctbhie.etbcod = 923
          or ctbhie.etbcod = 924
          or ctbhie.etbcod = 990
          or ctbhie.etbcod = 991 
      then do:
      
            put unformatted
        /* 001-003 */ "995"  at 01.
      
        vetbinv = 995.
        
      end.
      else if ctbhie.etbcod = 806
               or ctbhie.etbcod = 998
               or ctbhie.etbcod = 999
      then do:    
          
           put unformatted
        /* 001-003 */ "900"  at 01.
        vetbinv = 900.
      end.
      else if ctbhie.etbcod = 10
      then do:
          
           put unformatted
        /* 001-003 */ " 23"  at 01.
          vetbinv = 23. 
      end.
      else do:
      
            put unformatted
        /* 001-003 */ string(ctbhie.etbcod,">>9") at 01.
          vetbinv = ctbhie.etbcod.
      end.
      
      put unformatted
/* 004-031 */  "1.1.04.01.001" format "x(28)"  /* código c. contabil */
/* 032-059 */  " " format "x(28)"   /* Centro de custo */
/* 060-067 */ string(year(vdtf),"9999")
              string(month(vdtf),"99") 
              string(day(vdtf),"99")
/* 068-087 */ string(ctbhie.procod) format "x(20)"
/* 088-097 */ string(vcodfis) format "x(10)"
/* 098-100 */ /*"UN "*/ produ.prounven format "x(3)"
/* 101-116 */ ctbhie.ctbest format "999999999999.999"
/* 117-132 */ ctbhie.ctbest * ctbhie.ctbcus format "-9999999999999.99"
/* 133-148 */ ctbhie.ctbcus format "-999999999.999999"
/* 149-151 */ "PR "
/* 152-152 */ "1"    /*tipo de estoque*/
/* 153-170 */ " " format "x(18)"
/* 171-188 */ " " format "x(18)"
/* 189-208 */ " " format "x(20)"
/* 209-210 */ " "  format "x(2)"
/* 211-226 */ /*ctbhie.ctbant*/ "0000000000000.000"
/* 227-242 */ aux-icms
                    format "-99999999999999.99" /* icms proprio */
/* 243-258 */ aux-subst
                    format "-99999999999999.99" /* icms subst trib. */
/* 259-264 */ obs-cod format "x(6)"
/* 265-280 */ sal-val-icms           format "-99999999999999.99"
/* 281-296 */ qtd-est-periodo        format "9999999999999.999"
/* 297-312 */ custo-unitario-periodo format "9999999999.999999"
/* 313-328 */ val-icms-periodo       format "-99999999999999.99"
 skip .


    find first tt-inv where
               tt-inv.etbcod = vetbinv
               no-error.
    if not avail tt-inv
    then do:
        create tt-inv.
        tt-inv.etbcod = vetbinv.
    end.
    tt-inv.valor = tt-inv.valor + (ctbhie.ctbest * ctbhie.ctbcus).
                
    vtot-custo = vtot-custo + (ctbhie.ctbest * ctbhie.ctbcus).

end procedure.
