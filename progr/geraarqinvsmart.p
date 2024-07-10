{admcab.i}

def var vtotal as dec.

def var vetbcod like estab.etbcod.
def var vetb1 like estab.etbcod.
def var vcusto as dec.
def var vmes as int format ">9".
def var vano as int format ">>>9".
def var varquivo as char.
def stream vdisp .

update vetb1 label "Filial"
    with frame f1 width 80 side-label.
if vetb1 > 0
then do:
    find first estab where estab.etbcod = vetb1 no-lock.
    disp estab.etbnom no-label with frame f1. 
end.
else disp "TODAS AS FILIAIS" @ estab.etbnom with frame f1.

update vmes at 1 label "Mes"
       vano      label "Ano"
with frame f1.

def var vdti as date.
def var vdtf as date.
vdti = date(if vmes = 12 then 01 else vmes + 1,01,
            if vmes = 12 then vano + 1 else vano) - 1.
vdtf = vdti.

varquivo = "/admcom/audit/inv_smt_" + trim(string(vetb1,"999")) + "_" +
                string(day(vdti),"99") +  
                string(month(vdti),"99") +  
                string(year(vdti),"9999") + "_" + 
                string(day(vdtf),"99") +  
                string(month(vdtf),"99") +  
                string(year(vdtf),"9999") + ".txt".
/*
varquivo = "/admcom/work/inv_smt_" + trim(string(vetb1,"999")) + "_" +
                string(day(vdti),"99") +  
                string(month(vdti),"99") +  
                string(year(vdti),"9999") + "_" + 
                string(day(vdtf),"99") +  
                string(month(vdtf),"99") +  
                string(year(vdtf),"9999") + ".txt".
*/

def var vicms as dec.
def var vpis as dec.
def var vcofins as dec.
def var aux-liq as dec.
def var aux-icms as dec.
def var aux-pis as dec.
def var aux-cofins as dec.
def var aux-custo as dec.
def var aux-subst as dec.
def var obs-cod as char.
def var sal-val-icms as dec.
def var qtd-est-periodo as dec.
def var custo-unitario-periodo as dec.
def var val-icms-periodo as dec.
def var vtot-custo as dec format ">>>,>>>,>>9.99".
output stream vdisp to terminal.
output to value(varquivo).
for each estab where (if vetb1 > 0
                then estab.etbcod = vetb1 else true) no-lock:
        disp stream vdisp estab.etbcod 
            estab.etbnom with 1 down frame f no-label width 80 color message
            no-box.
        pause 0.
    vetbcod = estab.etbcod.
    
    if vano = 2014
    then do:
        run inventario-2014.
    end.
    else do:    
    find first ger.ctbhie where ctbhie.etbcod = estab.etbcod and
                          ctbhie.ctbmes = vmes    and
                          ctbhie.ctbano = vano    no-lock no-error.
    if not avail ger.ctbhie
    then next.                      
 
    vtot-custo = 0.
    for each ger.ctbhie where ctbhie.etbcod = estab.etbcod and
                          ctbhie.ctbmes = vmes    and
                          ctbhie.ctbano = vano    no-lock:
        if ctbhie.ctbcus <= 0
        then next.
        find produ where produ.procod = ctbhie.procod no-lock no-error.
        if not avail produ
        then next.

        vcusto = ctbhie.ctbmed.
        aux-custo = ctbhie.ctbmed.
        
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
            if avail plani
            then assign
                    vicms = movim.movalicms
                    vpis = movim.movalpis
                    vcofins = movim.movalcofins
                    .
        end.
        if vicms = 17                            
        then aux-icms  = trunc(aux-custo * (vicms / 100),2).
        else aux-subst = trunc(aux-custo * (vicms / 100),2). 
              
        assign 
            aux-liq  = aux-custo - aux-icms
            aux-pis  = aux-liq * (vpis / 100)
            aux-cofins = aux-liq * (vcofins / 100).

        if ger.ctbhie.etbcod = 113
          or ger.ctbhie.etbcod = 901
          or ger.ctbhie.etbcod = 902
          or ger.ctbhie.etbcod = 903
          or ger.ctbhie.etbcod = 905
          or ger.ctbhie.etbcod = 906
          or ger.ctbhie.etbcod = 907
          or ger.ctbhie.etbcod = 910
          or ger.ctbhie.etbcod = 919
          or ger.ctbhie.etbcod = 920
          or ger.ctbhie.etbcod = 921
          or ger.ctbhie.etbcod = 923
          or ger.ctbhie.etbcod = 924
          or ger.ctbhie.etbcod = 990
          or ger.ctbhie.etbcod = 991 
        then do:
      
            put unformatted /* 001-003 */ "995"  at 01.
      
        end.
        else if ger.ctbhie.etbcod = 806
               or ger.ctbhie.etbcod = 998
               or ger.ctbhie.etbcod = 999
               or ger.ctbhie.etbcod = 981
        then do:    
          
           put unformatted /* 001-003 */ "993"  at 01.
      
        end.
        else do:
      
            put unformatted
        /* 001-003 */ string(ger.ctbhie.etbcod,">>9") at 1.
      
        end.
      
        put unformatted
/* 004-031 */  "1.1.04.01.001" format "x(28)"  /* código c. contabil */
/* 032-059 */  " " format "x(28)"   /* Centro de custo */
/* 060-067 */ string(year(vdtf),"9999")
              string(month(vdtf),"99") 
              string(day(vdtf),"99")
/* 068-087 */ string(ger.ctbhie.procod) format "x(20)"
/* 088-097 */ string(produ.codfis) format "x(10)"
/* 098-100 */ /*"UN "*/ produ.prounven format "x(3)"
/* 101-116 */ ger.ctbhie.ctbqtd format "999999999999.999"
/* 117-132 */ ger.ctbhie.ctbqtd * ger.ctbhie.ctbmed 
                            format "-9999999999999.99"
/* 133-148 */ ger.ctbhie.ctbmed format "-999999999.999999"
/* 149-151 */ "PR "
/* 152-152 */ "1"    /*tipo de estoque*/
/* 153-170 */ " " format "x(18)"
/* 171-188 */ " " format "x(18)"
/* 189-208 */ " " format "x(20)"
/* 209-210 */ " "  format "x(2)"
/* 211-226 */ /*tt-saldo.sal-ant*/ "0000000000000.000"
            format "-9999999999999.999" /* qtde inicial do estoque */
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


/*
        create tt-exp.
        assign
            tt-exp.etbcod = ger.ctbhie.etbcod
            tt-exp.procod = ger.ctbhie.procod
            tt-exp.custou = ger.ctbhie.aux-custo
            tt-exp.custot = ger.ctbhie.sal-atu * ger.ctbhie.aux-custo
            tt-exp.quanti = ger.ctbhie.sal-atu
            .

    */
    
        vtot-custo = vtot-custo + 
                    (ger.ctbhie.ctbmed * ger.ctbhie.ctbqtd).
    
    end.
 
    disp stream vdisp vtot-custo  with frame f  no-box.
    pause 0.
 
    end.
 end .

output stream vdisp close.
output close.
message color red/with
    "Arquivo gerado:" varquivo
    view-as alert-box.
    

procedure invetario-2014.
    find first ninja.ctbhie where ctbhie.etbcod = estab.etbcod and
                          ctbhie.ctbmes = vmes    and
                          ctbhie.ctbano = vano    no-lock no-error.
    if not avail ninja.ctbhie
    then next.                      
 
    vtot-custo = 0.
    for each ninja.ctbhie where ctbhie.etbcod = estab.etbcod and
                          ctbhie.ctbmes = vmes    and
                          ctbhie.ctbano = vano    no-lock:
        if ctbhie.ctbcus <= 0
        then next.
        find produ where produ.procod = ctbhie.procod no-lock no-error.
        if not avail produ
        then next.
        vcusto = ctbhie.ctbcus.
        aux-custo = ctbhie.ctbcus.
        
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
            if avail plani
            then assign
                    vicms = movim.movalicms
                    vpis = movim.movalpis
                    vcofins = movim.movalcofins
                    .
        end.
        if vicms = 17                            
        then aux-icms  = trunc(aux-custo * (vicms / 100),2).
        else aux-subst = trunc(aux-custo * (vicms / 100),2). 
              
        assign 
            aux-liq  = aux-custo - aux-icms
            aux-pis  = aux-liq * (vpis / 100)
            aux-cofins = aux-liq * (vcofins / 100).

        if ninja.ctbhie.etbcod = 113
          or ninja.ctbhie.etbcod = 901
          or ninja.ctbhie.etbcod = 902
          or ninja.ctbhie.etbcod = 903
          or ninja.ctbhie.etbcod = 905
          or ninja.ctbhie.etbcod = 906
          or ninja.ctbhie.etbcod = 907
          or ninja.ctbhie.etbcod = 910
          or ninja.ctbhie.etbcod = 919
          or ninja.ctbhie.etbcod = 920
          or ninja.ctbhie.etbcod = 921
          or ninja.ctbhie.etbcod = 923
          or ninja.ctbhie.etbcod = 924
          or ninja.ctbhie.etbcod = 990
          or ninja.ctbhie.etbcod = 991 
        then do:
      
            put unformatted /* 001-003 */ "995"  at 01.
      
        end.
        else if ninja.ctbhie.etbcod = 806
               or ninja.ctbhie.etbcod = 998
               or ninja.ctbhie.etbcod = 999
               or ninja.ctbhie.etbcod = 981
        then do:    
          
           put unformatted /* 001-003 */ "993"  at 01.
      
        end.
        else do:
      
            put unformatted
        /* 001-003 */ string(ninja.ctbhie.etbcod,">>9") at 1.
      
        end.
      
        put unformatted
/* 004-031 */  "1.1.04.01.001" format "x(28)"  /* código c. contabil */
/* 032-059 */  " " format "x(28)"   /* Centro de custo */
/* 060-067 */ string(year(vdtf),"9999")
              string(month(vdtf),"99") 
              string(day(vdtf),"99")
/* 068-087 */ string(ninja.ctbhie.procod) format "x(20)"
/* 088-097 */ string(produ.codfis) format "x(10)"
/* 098-100 */ /*"UN "*/ produ.prounven format "x(3)"
/* 101-116 */ ninja.ctbhie.ctbest format "999999999999.999"
/* 117-132 */ ninja.ctbhie.ctbest * ninja.ctbhie.ctbcus 
                            format "-9999999999999.99"
/* 133-148 */ ninja.ctbhie.ctbcus format "-999999999.999999"
/* 149-151 */ "PR "
/* 152-152 */ "1"    /*tipo de estoque*/
/* 153-170 */ " " format "x(18)"
/* 171-188 */ " " format "x(18)"
/* 189-208 */ " " format "x(20)"
/* 209-210 */ " "  format "x(2)"
/* 211-226 */ /*tt-saldo.sal-ant*/ "0000000000000.000"
            format "-9999999999999.999" /* qtde inicial do estoque */
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


/*
        create tt-exp.
        assign
            tt-exp.etbcod = ninja.ctbhie.etbcod
            tt-exp.procod = ninja.ctbhie.procod
            tt-exp.custou = ninja.ctbhie.aux-custo
            tt-exp.custot = ninja.ctbhie.sal-atu * ninja.ctbhie.aux-custo
            tt-exp.quanti = ninja.ctbhie.sal-atu
            .

    */
    
        vtot-custo = vtot-custo + 
                    (ninja.ctbhie.ctbcus * ninja.ctbhie.ctbest).
    
    end.
 
    disp stream vdisp vtot-custo  with frame f  no-box.
    pause 0.
end procedure.
