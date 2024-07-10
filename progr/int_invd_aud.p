def var vconsolidado as log format "Sim/Nao".
def var vmovtdc like tipmov.movtdc.

def temp-table tt-inven no-undo
    field etbcod like estab.etbcod
    field valor as dec
    index i1 etbcod
    .

def temp-table tt-exp no-undo
    field etbcod like estab.etbcod
    field procod like produ.procod
    field custou as dec decimals 6
    field quanti as dec decimals 3
    field custot as dec decimals 2
    index i1 etbcod procod
    .

def temp-table tt-exp1 no-undo
    field etbcod like estab.etbcod
    field procod like produ.procod
    field custou as dec decimals 6
    field quanti as dec decimals 3
    field custot as dec decimals 2
    field custot1 as dec decimals 2
    index i1 etbcod procod
    .

def var vlinha as char.
/*
input from /admcom/custom/Claudir/inventario/salestoq2011.csv.
repeat:
    import vlinha.
    create tt-inven.
    tt-inven.etbcod = int(entry(1,vlinha,";")).
    tt-inven.valor  = dec(entry(2,vlinha,";")).
end.
input close.
*/
def var aux-custo as dec decimals 6. 
def var aux-icms  as dec.
def var aux-liq  as dec. 
def var aux-pis  as dec.  
def var aux-cofins  as dec.
def var aux-econt   as dec.

def var tetb-custo as dec. 
def var tetb-icms  as dec.
def var tetb-liq  as dec. 
def var tetb-pis  as dec.  
def var tetb-cofins  as dec.
def var tetb-econt   as dec.

def var tmov-custo as dec. 
def var tmov-icms  as dec.
def var tmov-liq  as dec. 
def var tmov-pis  as dec.  
def var tmov-cofins  as dec.
def var tmov-econt   as dec.

def var vmapicm     as dec.
def var vmapvda     as dec.
def var vlimicm     as dec.
def var vlimvda    as dec.
def var vfim5     as log .
def var vmap12   as dec.
def var vend12   as dec.
def var vmapsub as dec.
def var vendsub as dec.
def var aux-uf as char.


def temp-table tt-produ no-undo 
    field procod like produ.procod
    index i1 procod.

def temp-table tt-custo no-undo    
    field movtdc as int 
    field etbcod as int COLUMN-Label "FIL"
    field estcusto like estoq.estcusto   COLUMN-Label "CUSTO"
    field alipis as dec 
    field cusicm      like estoq.estcusto  COLUMN-Label "ICMS"
    field cusliq like estoq.estcusto      COLUMN-Label "CUSTO LIQ"
    field cuspis like estoq.estcusto      COLUMN-Label "PIS"
    field cuscofins like estoq.estcusto    COLUMN-Label "COFINS"
    field cuscont  like estoq.estcusto    COLUMN-Label "EST.CONTABIL"
    field procod    like estoq.procod   
    field estatual  like estoq.estatual
    field ano-cto   as int
    field cto-med as dec
    index ind1 is primary unique
        etbcod
        procod
        movtdc
        alipis.

def temp-table tt-estab no-undo
       field etbcod as int
       index ind1 etbcod.

def var obs-cod as char.
def var sal-val-icms as dec.
def var qtd-est-periodo as dec.
def var custo-unitario-periodo as dec.
def var val-icms-periodo as dec.

def var  vopc      as log format "Fechamento/Mensal".
vopc = no.

def var vestcusto as dec.
def var vestatual as dec.
def var varquivo as char.
def var vdti    as date format "99/99/9999".
def var vdtf    as date format "99/99/9999".
def var vetbi   like estab.etbcod.
def var vcatcod     like produ.catcod.
def var vicms      as dec label "%ICMS".
def var vpis       as dec label "%PIS".
def var vcofins    as dec label "%COFINS".
def var vanalitico as log label "Analitico/Sintetico"
                   format "Analitico/Sintetico" init no.
def var vsoma     as char format "x(1)" initial "N"
                         label "Opcao ICMS". 

def var vmovqt-5 like estoq.estatual.
def var vmovpc-5 like estoq.estcusto.
def var vmovqt-4 like estoq.estatual.
def var vmovpc-4 like estoq.estcusto.
def var vmovqt-12 like estoq.estatual.
def var vmovpc-12 like estoq.estcusto.
def var vhiestf   like hiest.hiestf.
def var aux-atual like estoq.estatual.

def var vmes like hiest.hiemes.
def var vano like hiest.hieano.
def var v-desc as char.

def var v-i as int.
def var vy as int.

def var vtipo as log format "Saldo/Movimento" init yes.
def var aux-subst as dec.

def var vpronom like produ.pronom.

def new shared temp-table tt-movest
    field etbcod like estab.etbcod
    field procod like produ.procod
    field data as date
    field movtdc like tipmov.movtdc
    field tipmov as char
    field numero as char
    field serie like plani.serie
    field emite like plani.emite
    field desti like plani.desti
    field movqtm like movim.movqtm
    field movpc like movim.movpc
    field sal-atu as dec
    index i1 procod
    .
     
def new shared temp-table tt-saldo
    field etbcod like estab.etbcod 
    field procod like produ.procod
    field codfis as int
    field sal-ant as dec
    field qtd-ent as dec
    field qtd-sai as dec
    field sal-atu as dec
    field cto-med as dec
    field ano-cto as int
    index i1 etbcod procod
    .

def temp-table tt-mov no-undo
    field etbcod like estab.etbcod
    field tipodoc  as char
    field natudoc as char
    field movtdc like tipmov.movtdc
    field serie as char
    field numdoc as char format "x(15)"
    field movdat as date
    field procod like produ.procod
    field movqtm as dec
    field unmed as char
    field p-unitario as dec
    field p-total as dec
    field c-unitario as dec
    field c-total as dec
    field tp-mov as char
    field part-mov as char
    .

def var vetbcod like estab.etbcod.
def var vdesdt as char format "x(30)".

def var sparam as char.
sparam = SESSION:PARAMETER.
if num-entries(sparam,";") > 1
then sparam = entry(2,sparam,";").
 
def var varq as char.
/*
if opsys = "unix" and sparam <> "AniTA"
then do:
        vtipo = no.
        input from /file_server/param_mov.
        repeat:
            import varq.
            vetbcod = int(substring(varq,1,3)).
            vdti    = date(int(substring(varq,6,2)),
                           int(substring(varq,4,2)),
                           int(substring(varq,8,4))).
            vdtf    = date(int(substring(varq,14,2)),
                           int(substring(varq,12,2)),
                           int(substring(varq,16,4))).
                       
            varq = "/file_server/mov_" + 
                    trim(string(vetbcod,"x(3)")) + "_" +
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
else*/ do:
    
    def var vetbcod1 like estab.etbcod.
    update vetbcod at 5 label "Filial" vetbcod1
       with frame f1 1 down side-label width 80.
    update vmes at 8 label "Mes"
           vano  label "Ano"
           vtipo label "Saldo/Movimento"
           with frame f1.

    vdti = date(vmes,01,vano).
    
    vdtf = date(if vmes = 12
                then 1 else vmes + 1,
                01,
                if vmes = 12
                then vano + 1 else vano)
                .

    vdtf = vdtf - 1.
    
    vdesdt = "       De: " + string(vdti,"99/99/9999")
             + " Ate: " + string(vdtf,"99/99/9999")
             .
    /*
    disp vdesdt no-label format "x(40)"
         with frame f1.
         
    disp "Processando... AGUARDE! "
        with frame f-disp 1 down centered row 10 
        no-box color message.
    */
end.       
def var vetbf like estab.etbcod.
vetbi = vetbcod.
vetbf = vetbcod1.
if opsys = "unix" /*and sparam = "AniTA"*/
then varquivo = "/admcom/decision/mov_" + trim(string(vetbi,"999")) + "_" +
                trim(string(vetbf,"999")) + "_" +
                string(day(vdti),"99") +  
                string(month(vdti),"99") +  
                string(year(vdti),"9999") + "_" + 
                string(day(vdtf),"99") +  
                string(month(vdtf),"99") +  
                string(year(vdtf),"9999") + ".txt".

for each estab where   (if vetbcod > 0
            then estab.etbcod >= vetbcod else true)
             and (if vetbcod1 > 0
                  then estab.etbcod <= vetbcod1 else true)
             no-lock.
    
    
    disp estab.etbcod vdtf with frame f-disp.
    pause 0.
    

    for each produ no-lock:
        if produ.prodtcad > vdtf then next.
         
        disp produ.procod format ">>>>>>>>9" with frame f-disp.
        pause 0.
        
        find first hiest where hiest.etbcod = estab.etbcod and
                               hiest.procod = produ.procod
                               no-lock no-error.
        if not avail hiest then next.
                               
        if not vtipo
        then
        run movestoq.p(estab.etbcod, produ.procod, vdti, vdtf).
        
        run salestoq.p(estab.etbcod, produ.procod, vdti, vdtf).
    
    end.  
end.

/***
if not vtipo
then do:
run processamento.


for each tt-custo:
    find produ where produ.procod = tt-custo.procod no-lock no-error.
    if not avail produ
    then next.

    /*
    disp tt-custo.procod tt-custo.estatual.
    */
     
    create tt-saldo.
    assign
        tt-saldo.etbcod = tt-custo.etbcod
        tt-saldo.procod = tt-custo.procod
        tt-saldo.codfis = produ.codfis
        tt-saldo.sal-ant = 0
        tt-saldo.qtd-ent = 0
        tt-saldo.qtd-sai = 0
        tt-saldo.sal-atu = tt-custo.estatual
        .

end.
end.
***/

def var vnatdoc as char.
def var vtipdoc as char.

for each tt-movest where tt-movest.procod > 0:
    find estoq where estoq.etbcod = tt-movest.etbcod and
                     estoq.procod = tt-movest.procod 
                     no-lock no-error.
 
    if tt-movest.serie <> "U" and
       tt-movest.serie <> "V" and
       tt-movest.serie <> "55" and
       tt-movest.serie <> "1"
    then assign
         vnatdoc = "I"
         vtipdoc = "AJ".
    else assign
         vnatdoc = "F"
         vtipdoc = "NF".
       

    create tt-mov.
    assign
    tt-mov.etbcod     = tt-movest.etbcod
    tt-mov.tipodoc    = vtipdoc 
    tt-mov.natudoc    = vnatdoc
    tt-mov.movtdc     = tt-movest.movtdc
    tt-mov.serie      = tt-movest.serie
    tt-mov.numdoc     = tt-movest.numero
    tt-mov.movdat     = tt-movest.data
    tt-mov.procod     = tt-movest.procod
    tt-mov.movqtm     = tt-movest.movqtm
    tt-mov.unmed      = "UN"
    tt-mov.p-unitario = tt-movest.movpc
    tt-mov.p-total    = (tt-movest.movpc * tt-movest.movqtm)
    tt-mov.c-unitario = estoq.estcusto
    tt-mov.c-total    = estoq.estcusto * tt-movest.movqtm
    .
    if tt-movest.emite = tt-movest.etbcod and
       tt-movest.desti <> tt-movest.etbcod 
    then tt-mov.tp-mov     = "S".
    else tt-mov.tp-mov     = "E".

    if  tt-mov.tp-mov = "S"
    then do:
        if tt-movest.serie = "v"
        then tt-mov.part-mov =
             "C" + string(tt-movest.desti,"9999999999") + "       ".
        else if tt-movest.emite = tt-movest.etbcod and
                tt-movest.desti <> tt-movest.etbcod
        then tt-mov.part-mov =
             "E" + string(tt-movest.desti,"9999999") + "          ".   
        else tt-mov.part-mov =
             "F" + string(tt-movest.desti,"9999999") + "          ".   
    end.
    else do:
        if tt-movest.desti = tt-movest.etbcod and
                tt-movest.emite <> tt-movest.etbcod
        then tt-mov.part-mov =
             "E" + string(tt-movest.emite,"9999999") + "          ".   
        else tt-mov.part-mov =
             "F" + string(tt-movest.emite,"9999999") + "          ".  
    end.

end.
if not vtipo
then do:

create tt-mov.

output to value(varquivo).

for each tt-mov:
    if tt-mov.etbcod = 0 or
       tt-mov.serie = "" or
       tt-mov.numdoc = "?" or
       tt-mov.numdoc = ""
    then next.   
    run movimento.
end.
    
output close.
end.

if opsys = "unix"
then varquivo = "/admcom/decision/inv_" + trim(string(vetbi,"999")) + "_" +
                trim(string(vetbf,"999")) + "_" +
                string(day(vdti),"99") +  
                string(month(vdti),"99") +  
                string(year(vdti),"9999") + "_" + 
                string(day(vdtf),"99") +  
                string(month(vdtf),"99") +  
                string(year(vdtf),"9999") + ".txt".

else varquivo = "l:\descision\inv_" + trim(string(vetbi,"999")) + "_" + 
                string(day(vdti),"99") +   
                string(month(vdti),"99") +   
                string(year(vdti),"9999") + "_" +  
                string(day(vdtf),"99") +   
                string(month(vdtf),"99") +   
                string(year(vdtf),"9999") + ".txt".

def var vtot-custo as dec decimals 2 /*format "->>,>>>,>>>,>>9.99"*/.
def var vt1 as dec decimals 2.
def var vt2 as dec decimals 2.
def var vt3 as dec decimals 2.
def var vt4 as dec decimals 2.

def buffer btt-saldo for tt-saldo.
for each tt-saldo.
     if  tt-saldo.etbcod = 901
          or tt-saldo.etbcod = 902
          or tt-saldo.etbcod = 903
          or tt-saldo.etbcod = 905
          or tt-saldo.etbcod = 906
          or tt-saldo.etbcod = 907
          or tt-saldo.etbcod = 910
          or tt-saldo.etbcod = 919
          or tt-saldo.etbcod = 920
          or tt-saldo.etbcod = 921
          or tt-saldo.etbcod = 923
          or tt-saldo.etbcod = 924
          or tt-saldo.etbcod = 990
          or tt-saldo.etbcod = 991 
      then do:
          find first btt-saldo where btt-saldo.etbcod =  995 and
                                     btt-saldo.procod = tt-saldo.procod
                                     no-error.
          if not avail btt-saldo 
          then tt-saldo.etbcod = 995.
          else do:
              btt-saldo.sal-atu = btt-saldo.sal-atu + tt-saldo.sal-atu.
              delete tt-saldo.
          end.                          
      end.
      else if tt-saldo.etbcod = 806 or
              tt-saldo.etbcod = 500 or
              tt-saldo.etbcod = 501 or
              tt-saldo.etbcod = 600 or
              tt-saldo.etbcod = 700 or
              tt-saldo.etbcod = 981 or
              tt-saldo.etbcod = 998 
      then do:    
           find first btt-saldo where btt-saldo.etbcod =  900 and
                                     btt-saldo.procod = tt-saldo.procod
                                     no-error.
          if not avail btt-saldo 
          then tt-saldo.etbcod = 900.
          else do:
              btt-saldo.sal-atu = btt-saldo.sal-atu + tt-saldo.sal-atu.
              delete tt-saldo.
          end. 
     end.
end.

/*** tirei

for each tt-inven where
         tt-inven.etbcod > 0 and
         tt-inven.valor > 0.

vt1 = 0.
vt2 = 0.
vt3 = 0.
vt4 = 0.
         
if vetbcod > 0 and
         tt-inven.etbcod <> vetbcod
then next.
         
for each tt-saldo where tt-saldo.etbcod = tt-inven.etbcod:
    if  tt-saldo.etbcod = 0 or
        tt-saldo.sal-atu = 0 
    then next .
    if tt-saldo.procod >= 2000000
    then next.
    
    find estoq where estoq.etbcod = tt-saldo.etbcod and
                     estoq.procod = tt-saldo.procod 
                     no-lock no-error.

    if avail estoq
    then assign aux-custo = estoq.estcusto.
    else assign aux-custo = 0.
      
    find last ctbhie where
                 ctbhie.etbcod = 0 and
                 ctbhie.procod = tt-saldo.procod and
                 ctbhie.ctbmes <= vmes and
                 ctbhie.ctbano = vano
                 no-lock no-error.
    if not avail ctbhie
    then find last ctbhie where
              ctbhie.etbcod = 0 and
              ctbhie.procod = tt-saldo.procod and
              ctbhie.ctbano < vano
                 no-lock no-error.
      
    if avail ctbhie
    then do:
        tt-saldo.ano-cto = ctbhie.ctbano.
        
          if ctbhie.ctbano <= 2009
          then do:
            aux-custo = ctbhie.ctbcus /*/ tt-saldo.sal-atu*/.
            vtot-custo = vtot-custo + (tt-saldo.sal-atu * aux-custo).
          end.
          else do:
            aux-custo = ctbhie.ctbcus.
            if ctbhie.ctbano < 2011
            then vtot-custo = vtot-custo + (tt-saldo.sal-atu * aux-custo).
          end.
    end.  
    else do:
        tt-saldo.ano-cto = 2012.
            aux-custo = 0.
            run cto-med.
    
    end.  
    if aux-custo = 0
    then do:
          if tt-saldo.sal-atu > 1
          then aux-custo = estoq.estcusto / (tt-saldo.sal-atu - 1) /*1.3554*/.
          else aux-custo = estoq.estcusto / tt-saldo.sal-atu. 
    end.

    tt-saldo.cto-med = aux-custo.
    
    create tt-exp1.
    assign
            tt-exp1.etbcod = tt-saldo.etbcod
            tt-exp1.procod = tt-saldo.procod
            tt-exp1.custou = aux-custo
            tt-exp1.custot = tt-saldo.sal-atu * aux-custo
            tt-exp1.quanti = tt-saldo.sal-atu
            .

    if tt-saldo.ano-cto < 2011
    then tt-exp1.custot1 = tt-saldo.sal-atu * aux-custo.
    
                                                                  
    vt2 = vt2 + (tt-saldo.cto-med * tt-saldo.sal-atu).
    if tt-saldo.ano-cto < 2011
    then vt1 = vt1 + (tt-saldo.cto-med * tt-saldo.sal-atu).
    

end.

vt3 = vt2 - tt-inven.valor.

/*
for each tt-exp1:
    vt2 = vt2 + tt-exp1.custot.
    vt1 = vt1 + tt-exp1.custot1.
end.    
*/
/*
message vt2 vt1 tt-inven.valor vt3 vt3 / vt1. pause.
*/
vt4 = 0.
for each tt-saldo where tt-saldo.etbcod = tt-inven.etbcod:
    if  tt-saldo.etbcod = 0 or
        tt-saldo.sal-atu = 0 
    then next .
    if tt-saldo.procod >= 2000000
    then next.
    if tt-saldo.ano-cto >= 2011
    then next.
    vt4 = vt4 + ((tt-saldo.cto-med * (vt3 / vt1)) * tt-saldo.sal-atu).
    tt-saldo.cto-med = tt-saldo.cto-med - (tt-saldo.cto-med * (vt3 / vt1)).

end.
/*
message vt2 vt1 tt-inven.valor vt3 vt3 / vt1 vt4. pause.
*/
end.

output to ./saldo-inv.txt.
for each tt-saldo.
export tt-saldo.
end.
output close.

tirei***/

output to value(varquivo).

vtot-custo = 0.

for each tt-saldo /*where tt-saldo.cto-med > 0*/:
    
    
    if  tt-saldo.etbcod = 0 or
        tt-saldo.sal-atu = 0 
    then next .
    if tt-saldo.procod >= 2000000
    then next.
    
    /** 
    find estoq where estoq.etbcod = tt-saldo.etbcod and
                     estoq.procod = tt-saldo.procod 
                     no-lock no-error.

    if avail estoq
    then assign aux-custo = estoq.estcusto.
    else assign aux-custo = 0.
      
    find last ctbhie where
                 ctbhie.etbcod = 0 and
                 ctbhie.procod = tt-saldo.procod and
                 ctbhie.ctbmes <= vmes and
                 ctbhie.ctbano = vano
                 no-lock no-error.
    if not avail ctbhie
    then find last ctbhie where
              ctbhie.etbcod = 0 and
              ctbhie.procod = tt-saldo.procod and
              ctbhie.ctbano < vano
                 no-lock no-error.
      
    if avail ctbhie
    then do:
        tt-custo.ano-cto = ctbhie.ctbano.
        
          if ctbhie.ctbano <= 2009
          then do:
            aux-custo = ctbhie.ctbcus /*/ tt-saldo.sal-atu*/.
            vtot-custo = vtot-custo + (tt-saldo.sal-atu * aux-custo).
          end.
          else do:
            aux-custo = ctbhie.ctbcus.
            if ctbhie.ctbano < 2011
            then vtot-custo = vtot-custo + (tt-saldo.sal-atu * aux-custo).
          end.
    end.  
    else do:
        tt-custo.ano-cto = 2012.
            aux-custo = 0.
            run cto-med.
    
    end.  
    if aux-custo = 0
    then do:
          if tt-saldo.sal-atu > 1
          then aux-custo = estoq.estcusto / (tt-saldo.sal-atu - 1) /*1.3554*/.
          else aux-custo = estoq.estcusto / tt-saldo.sal-atu. 
    end.

    tt-custo.cto-med = aux-custo.
     
    **/
    
    aux-custo = tt-saldo.cto-med.
    
    find produ where produ.procod = tt-saldo.procod no-lock.

    find estoq where estoq.etbcod = tt-saldo.etbcod and
                     estoq.procod = tt-saldo.procod 
                     no-lock no-error.

    run inventario.
    
end.
output close.

def var vcusto1-tot as dec decimals 2 /*format ">>,>>>,>>9.99"*/.
.

for each tt-exp:
    vcusto1-tot = vcusto1-tot + tt-exp.custot.
end.
/*    
message "DDDDD" vtot-custo  vcusto1-tot. pause.
*/
procedure movimento:
    put unformatted
    /* 1-3     */ tt-mov.etbcod  format ">>9"
    /* 4-8     */ tt-mov.tipodoc format "x(5)"
    /* 9-9     */ tt-mov.natudoc format "x"
    /* 10-14   */ tt-mov.serie   format "x(5)"
    /* 15-26   */ tt-mov.numdoc  format "x(12)"
    /* 27-34   */ day(tt-mov.movdat) format "99"
                  month(tt-mov.movdat) format "99"
                  year(tt-mov.movdat) format "9999"
    /* 35-54   */ string(tt-mov.procod) format "x(20)"
    /* 55-70   */ tt-mov.movqtm format "99999999999.9999"
    /* 71-73   */ tt-mov.unmed  format "x(3)"
    /* 74-89   */ tt-mov.p-unitario  format "-999999999.999999"
    /* 90-105  */ tt-mov.p-total format "99999999999.9999"
    /* 106-121 */ tt-mov.c-unitario format "-999999999.999999"
    /* 122-137 */ tt-mov.c-total format "99999999999.9999"
    /* 138-138 */ tt-mov.tp-mov format "x"
    /* 139-388 */ " " format "x(250)"
    /* 389-406 */ tt-mov.part-mov format "x(18)"
    /* 407-434 */ "1.1.04.01.001" format "x(28)"
    /* 435-437 */ "00"
    /* 438-443 */ string(tt-mov.movtdc,">>>>99") format "x(6)"
    skip
    .

end procedure.


procedure inventario:
      /* */
      assign aux-custo = (if vopc = no then vestcusto
                          else ((if avail movim then movim.movpc 
                                 else vestcusto) *  vestatual)).
      /* */
      
      /**** descomentei **/
      if avail estoq
      then assign aux-custo = estoq.estcusto.
      else assign aux-custo = 0.
      
      find last ctbhie where
                 ctbhie.etbcod = 0 and
                 ctbhie.procod = tt-saldo.procod and
                 ctbhie.ctbmes <= vmes and
                 ctbhie.ctbano = vano
                 no-lock no-error.
      if not avail ctbhie
      then find last ctbhie where
              ctbhie.etbcod = 0 and
              ctbhie.procod = tt-saldo.procod and
              ctbhie.ctbano < vano
                 no-lock no-error.
      
      if avail ctbhie
      then do:
          if ctbhie.ctbano <= 2009
          then do:
            aux-custo = ctbhie.ctbcus /*/ tt-saldo.sal-atu*/.
            vtot-custo = vtot-custo + (tt-saldo.sal-atu * aux-custo).
          end.
          else do:
            aux-custo = ctbhie.ctbcus.
            if ctbhie.ctbano < 2011
            then vtot-custo = vtot-custo + (tt-saldo.sal-atu * aux-custo).
          end.
      end.  
      else do:
            aux-custo = 0.
            run cto-med.
      end.  
      if aux-custo = 0
      then do:
          if tt-saldo.sal-atu > 1
          then aux-custo = estoq.estcusto / (tt-saldo.sal-atu - 1) /*1.3554*/.
          else aux-custo = estoq.estcusto / tt-saldo.sal-atu. 
      end.
      /** descomentei ***/
      
      if aux-custo = ?
      then aux-custo = estoq.estcusto.
                                 
      if vicms = 18                            
      then aux-icms  = trunc(aux-custo * (vicms / 100),2).
      else aux-subst = trunc(aux-custo * (vicms / 100),2). 
              
      assign aux-liq  = aux-custo - aux-icms
              aux-pis  = ((if vopc then aux-liq else aux-custo)
                             * (vpis / 100))
              aux-cofins = ((if vopc then aux-liq else aux-custo) 
                                 * (vcofins / 100)).
      
      
   /* Estabelecimentos Virtuais nao tem inventario portanto exporta 995 fixo*/
   
    /***
      if /*tt-saldo.etbcod = 113
          or*/ tt-saldo.etbcod = 901
          or tt-saldo.etbcod = 902
          or tt-saldo.etbcod = 903
          or tt-saldo.etbcod = 905
          or tt-saldo.etbcod = 906
          or tt-saldo.etbcod = 907
          or tt-saldo.etbcod = 910
          or tt-saldo.etbcod = 919
          or tt-saldo.etbcod = 920
          or tt-saldo.etbcod = 921
          or tt-saldo.etbcod = 923
          or tt-saldo.etbcod = 924
          or tt-saldo.etbcod = 990
          or tt-saldo.etbcod = 991 
      then do:
      
            put unformatted
        /* 001-003 */ "995"  at 01.
      
      end.
      else if tt-saldo.etbcod = 806
               or tt-saldo.etbcod = 998
               or tt-saldo.etbcod = 999
      then do:    
          
           put unformatted
        /* 001-003 */ "900"  at 01.
      
      end.
      /****
      else if tt-saldo.etbcod = 10
      then do:
          
           put unformatted
        /* 001-003 */ "23"  at 01.
           
      end.
      *****/
      else***/
       
       do:
      
            put unformatted
        /* 001-003 */ string(tt-saldo.etbcod,">>9") at 01.
      
      end.
      
      put unformatted
/* 004-031 */  "1.1.04.01.001" format "x(28)"  /* código c. contabil */
/* 032-059 */  " " format "x(28)"   /* Centro de custo */
/* 060-067 */ string(year(vdtf),"9999")
              string(month(vdtf),"99") 
              string(day(vdtf),"99")
/* 068-087 */ string(tt-saldo.procod) format "x(20)"
/* 088-097 */ string(tt-saldo.codfis) format "x(10)"
/* 098-100 */ /*"UN "*/ produ.prounven format "x(3)"
/* 101-116 */ tt-saldo.sal-atu format "999999999999.999"
/* 117-132 */ tt-saldo.sal-atu * aux-custo format "-9999999999999.99"
/* 133-148 */ aux-custo format "-999999999.999999"
/* 149-151 */ "PR "
/* 152-152 */ "0"    /*tipo de estoque*/
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

        create tt-exp.
        assign
            tt-exp.etbcod = tt-saldo.etbcod
            tt-exp.procod = tt-saldo.procod
            tt-exp.custou = aux-custo
            tt-exp.custot = tt-saldo.sal-atu * aux-custo
            tt-exp.quanti = tt-saldo.sal-atu
            .

vtot-custo = vtot-custo + (tt-saldo.sal-atu * aux-custo).

end procedure.


procedure processamento:

def buffer cmovim for movim.
def var vopc      as log format "Fechamento/Mensal".
vopc = yes.
def var varquivo as char.
def var vdti    as date format "99/99/9999".
def var vdtf    as date format "99/99/9999".
def var vetbi   like estab.etbcod.
def var vcatcod     like produ.catcod.
def var vicms      as dec label "%ICMS".
def var vpis       as dec label "%PIS".
def var vcofins    as dec label "%COFINS".
def var vanalitico as log label "Analitico/Sintetico"
                   format "Analitico/Sintetico" init yes.
def var vsoma     as char format "x(1)" initial "N"
                         label "Opcao ICMS". 

def var vmovqt-5 like estoq.estatual.
def var vmovpc-5 like estoq.estcusto.
def var vmovqt-4 like estoq.estatual.
def var vmovpc-4 like estoq.estcusto.
def var vmovqt-12 like estoq.estatual.
def var vmovpc-12 like estoq.estcusto.
def var vmovqt-13 like estoq.estatual.
def var vmovpc-13 like estoq.estcusto.

def var v-desc as char.

def var v-i as int.

def var vpronom like produ.pronom.

def buffer bmovim for movim.

def var vmovtdc like tipmov.movtdc.
def buffer btipmov for tipmov.
    
find first tt-custo no-lock NO-ERROR.

vetbi = 1.

def var vconsolidado as log format "Sim/Nao".

do:
    for each tt-custo:
        delete tt-custo.
    end.
    release tt-custo.
    
    vetbi = vetbcod.
         
  if vopc = no
  then assign vpis = 1.65
              vcofins = 7.6.
  else assign vpis = .65
              vcofins = 3. 

  for each tt-estab: delete tt-estab. end.
   
  for each estab  where if vetbi = 0 
                         then true
                     else (estab.etbcod = vetbi) 
                     no-lock:
        if vetbi =  0
        then . /* if estab.etbcod = 22 or 
                estab.etbcod > 995 then next.
                */
                     
        create tt-estab.
        assign tt-estab.etbcod = estab.etbcod.             
   end.

  assign v-i =  0
         vmapicm = 0
         vmapvda = 0
         vlimicm = 0
         vlimvda = 0
         vmap12 = 0
         vmapsub = 0
         vend12 = 0
         vfim5 = no.
    
   if vmovtdc = 0 or
      vmovtdc = 5
   then   
   for each tt-estab no-lock,
       each mapctb where mapctb.etbcod = tt-estab.etbcod and
                         mapctb.datmov >= vdti        and
                         mapctb.datmov <= vdtf        and
                         mapctb.ch2 <> "E" 
                         no-lock:

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
    end.

    for each tt-produ: delete tt-produ. end.
    if vmovtdc > 0
    then run sel-produto.
    
    for each produ no-lock:
       if vmovtdc > 0 and
                 not can-find(tt-produ where tt-produ.procod = produ.procod)
       then next.          
       
       /*
       if vmovtdc > 0 and
          not can-find(cmovim use-index datsai
                       where    cmovim.procod = produ.procod and
                                cmovim.etbcod = tt-estab.etbcod and
                                cmovim.movtdc = vmovtdc and
                                cmovim.movdat >= vdti   and
                                cmovim.movdat <= vdtf
                                )
       then next.
       */                     
       v-i = v-i + 1 .   /* if v-i > 10000 then leave. */

       run busca-ali.

       find last movim where movim.procod = produ.procod
                               and movim.movtdc = 4
                               and movim.movdat <= vdtf
                            no-lock no-error.
      
       if v-i modulo 100 = 0
       then do: 
            
            /***
            disp /* stream stela */ produ.procod  format ">>>>>>>>>>9" 
                  /*v-i format ">>>>>>9" Label "Lidos"*/
                    with frame f-disp no-label 
                 centered color white/red.
            pause 0.
            ***/
            
       end. 
       if vopc = yes
       then do:
            for each tt-estab no-lock,
              first  estoq fields (estatual estcusto)
                           where estoq.procod = produ.procod
                             and estoq.etbcod = tt-estab.etbcod
                             NO-LOCK .
               if avail estoq and estoq.estatual > 0
               then run p-grava-tt(input 0,
                               input estoq.estatual, 
                               input estoq.estcusto).
            end.                   
       end.
       else do:
                assign vmovqt-4 = 0
                       vmovqt-5 = 0
                       vmovqt-12 = 0
                       vmovqt-13 = 0
                       vmovpc-4 = 0 
                       vmovpc-5 = 0
                       vmovpc-12 = 0
                       vmovpc-13 = 0
                       aux-uf = "".

                for each tipmov no-lock:
                    if tipmov.movtdc <> 5 and
                       tipmov.movtdc <> 12 /* and tipmov.movtdc <> 13 */
                    then next.
                    
                    if vmovtdc > 0 and
                       tipmov.movtdc <> vmovtdc
                    then next.   

                    for each bmovim use-index datsai
                                where bmovim.procod = produ.procod 
                                  and bmovim.movtdc = tipmov.movtdc
                                  and bmovim.movdat >= vdti 
                                  and bmovim.movdat <= vdtf
                            no-lock,
                    first tt-estab where 
                          tt-estab.etbcod = bmovim.etbcod no-lock :
                    assign
                    vmovqt-4 = 0
                       vmovqt-5 = 0
                       vmovqt-12 = 0
                       vmovqt-13 = 0
                       vmovpc-4 = 0 
                       vmovpc-5 = 0
                       vmovpc-12 = 0
                       vmovpc-13 = 0
                       aux-uf = "".
   
                    if bmovim.movtdc = 5 or bmovim.movtdc = 12
                    or bmovim.movtdc = 13
                    then assign vicms = bmovim.MovAlICMS.
                    else do:
                         find plani where plani.etbcod = bmovim.etbcod
                                      and plani.movtdc = bmovim.movtdc
                                      and plani.placod = bmovim.placod
                                      and plani.pladat = bmovim.movdat
                                      no-lock no-error.
                         IF not AVAIL plani
                         then next.
                         if plani.modcod = "CAN"
                         then next.
                         if plani.opccod <> 2102 and
                            plani.opccod <> 1102
                         then next.
                           
                         if plani.numero = 0
                         then next.
                    
                         if plani.emite = 5027
                         then next.
                         
                         find forne where forne.forcod = plani.emit 
                                    no-lock no-error.  
                         if avail forne  
                         then if aux-uf <> "AM"
                              then assign aux-uf = forne.ufecod.  

                         /* if not avail forne or
                            forne.ufecod = "RS" */
                            
                         if aux-uf = "RS"    
                         then vicms = 18.
                         else vicms = 12.

                         assign vmovqt-4 = vmovqt-4 + bmovim.movqt
                                vmovpc-4 = vmovpc-4 + 
                                          (bmovim.movpc * bmovim.movqt).
                    end.
                    if bmovim.movtdc = 12 /* "Devolucao */
                    then assign vmovqt-12 = vmovqt-12 + bmovim.movqt
                                vmovpc-12 = vmovpc-12 + 
                                           (bmovim.movpc * bmovim.movqt).
                                           
                    if bmovim.movtdc = 13 /* "Devolucao compra */
                    then assign vmovqt-13 = vmovqt-13 + bmovim.movqt
                                vmovpc-13 = vmovpc-13 + 
                                           (bmovim.movpc * bmovim.movqt).
                                           
                    if bmovim.movtdc = 5  /* saida */
                    then assign vmovqt-5 = vmovqt-5 + bmovim.movqt
                                vmovpc-5 = vmovpc-5 + 
                                          (bmovim.movpc * bmovim.movqt).
                if vmovqt-12 > 0
                then run p-grava-tt(input 12,
                                    input vmovqt-12, 
                                    input vmovpc-12).
                if vmovqt-13 > 0
                then run p-grava-tt(input 13,
                                    input vmovqt-13, 
                                    input vmovpc-13).
                                    
                if vmovqt-5 > 0
                then  run p-grava-tt(input 5,
                                         input vmovqt-5, 
                                         input vmovpc-5).
                if vmovqt-4 > 0
                then run p-grava-tt(input 4,
                                    input vmovqt-4, 
                                    input vmovpc-4).
                end.
                end.
        end. 
  end.
  def var vtotpro like plani.platot.
  def var aux-movpc as dec. 
  def var vliga as log .
  if vopc = no
  then do:
       DEF VAR VXY AS DEC.
       def var xxx as dec.

       /* devolução de compra */

       if vmovtdc = 13
       then
       for each tt-estab no-lock,  
            each plani where plani.etbcod = tt-estab.etbcod and
                             plani.emite  = tt-estab.etbcod and
                             plani.movtdc = 13 and
                             plani.datexp >= vdti and
                             plani.datexp <= vdtf no-lock:
               
               if plani.modcod = "CAN"
               then next.              
               vtotpro = 0.
               for each bmovim where bmovim.etbcod = plani.etbcod
                            and bmovim.placod = plani.placod
                            and bmovim.movtdc = plani.movtdc
                            and bmovim.movdat = plani.pladat
                            no-lock.
                            
                     find first produ where produ.procod = bmovim.procod
                                no-lock no-error.
                     if not avail produ 
                     then find first produ where produ.procod = 360
                                no-lock no-error.

                     assign vmovqt-13 = bmovim.movqt
                            vmovpc-13 = (bmovim.movpc * bmovim.movqt)
                            vicms = bmovim.movalicm.

                     assign vtotpro = vtotpro + vmovpc-13
                            aux-movpc = bmovim.movpc.
      
                     if vtotpro > plani.platot
                     then assign vmovpc-13 = vmovpc-13 - 
                                          (vtotpro - plani.platot).
                  
                     run p-grava-tt(input 13,
                                   input vmovqt-13, 
                                   input vmovpc-13).
                     
                     if vtotpro > plani.platot
                     then leave.
                         
               end. 
               if vtotpro < plani.platot
               then do:
                   if aux-movpc = 0 then aux-movpc = 1.
                   vmovqt-13 = round((plani.platot - vtotpro) / aux-movpc,0).
                   vmovpc-13 = (plani.platot - vtotpro).
 
                   if not avail produ 
                   then find first produ where produ.procod = 360
                                no-lock no-error.
                   
                  run p-grava-tt(input 13,
                                   input vmovqt-13, 
                                   input vmovpc-13).
               end.                  
        end.
       /* entradas */
       /**
       if vmovtdc = 4
       then
       for each tipmov where movtdc = 4 no-lock:
           for each tt-estab,
               each fiscal where fiscal.desti = tt-estab.etbcod   and
                              fiscal.movtdc = tipmov.movtdc and  
                              fiscal.plarec >= vdti    and
                              fiscal.plarec <= vdtf no-lock:
                              
               if fiscal.opfcod <> 2101 and
                  fiscal.opfcod <> 1101 and 
                  fiscal.opfcod <> 2102 and 
                  fiscal.opfcod <> 1102 
                  then next.   
                          
               find first plani where plani.etbcod = fiscal.dest
                            and plani.emite  = fiscal.emite   
                            and plani.movtdc = tipmov.movtdc  
                            and plani.serie  = fiscal.serie   
                            and plani.numero = fiscal.numero 
                            no-lock no-error.
               if not avail plani
               then find first plani where plani.etbcod = fiscal.dest
                            and plani.emite  = fiscal.emite 
                            and plani.movtdc = 28 
                            and plani.serie  = fiscal.serie 
                            and plani.numero = fiscal.numero 
                             no-lock no-error.
               if not avail plani  
               then find first plani where plani.etbcod = fiscal.dest 
                                     and plani.emite  = fiscal.emite 
                                     and plani.movtdc = 15 
                                     and plani.serie  = fiscal.serie 
                                     and plani.numero = fiscal.numero 
                                             no-lock no-error.
               if not avail plani
               then find first plani where plani.etbcod = fiscal.dest 
                            and plani.emite  = fiscal.emite 
                            and plani.movtdc = 23 
                            and plani.serie  = fiscal.serie 
                            and plani.numero = fiscal.numero 
                             no-lock no-error.
                             

               if not avail plani
               then do:
             /*     disp "Nao existe:"
                       fiscal.platot (total) fiscal.emite fiscal.serie 
                           fiscal.numero fiscal.dest.
               */            
                  next. 

               end.

               if plani.modcod = "CAN"
               then next.
                VXY = VXY + pLANI.PLATOT.
                /*             
                disp plani.etbcod plani.pladat plani.dtinclu 
                     vxy format ">>>,>>>,>>9.99" with frame fx1. pause 0.
                  */        
                if plani.numero = 0
                then next.
                    
                if plani.emite = 5027
                then next. 
                         
                find forne where forne.forcod = plani.emit 
                                    no-lock no-error.  
                IF PLANI.MOVTDC <> 13
                then do:
                         if avail forne  
                         then /* if aux-uf <> "AM"
                              then */ assign aux-uf = forne.ufecod.  

                         if aux-uf = "RS"    
                         then vicms = 18.
                         else vicms = 12.
                end.


               assign vtotpro = 0
                      vliga = no.
              
               for each bmovim where bmovim.etbcod = plani.etbcod
                            and bmovim.placod = plani.placod
                            and bmovim.movtdc = plani.movtdc
                            and bmovim.movdat = plani.pladat

                            no-lock.
                            
                     find first produ where produ.procod = bmovim.procod
                                no-lock no-error.
                     if not avail produ 
                     then find first produ where produ.procod = 360
                                no-lock no-error.

                     assign vmovqt-4 = bmovim.movqt
                            vmovpc-4 = (bmovim.movpc * bmovim.movqt)
                                       /*  - (bmovim.movdes * bmovim.movqtm)
                                       */
                                       .
                     assign vtotpro = vtotpro + vmovpc-4
                            aux-movpc = bmovim.movpc.
      
                     if vtotpro > plani.platot
                     then assign vmovpc-4 = vmovpc-4 - (vtotpro - plani.platot).
                  
                     run p-grava-tt(input (if plani.movtdc = 13 then 13
                                        else 4),
                                   input vmovqt-4, 
                                   input vmovpc-4).
                    
                     xxx = xxx + vmovpc-4.               
                     
                     if vtotpro > plani.platot
                     then leave.
                         
               end. 
               if vtotpro < plani.platot
               then do:
                   if aux-movpc = 0 then aux-movpc = 1.
                   vmovqt-4 = round((plani.platot - vtotpro) / aux-movpc,0).
                   vmovpc-4 = (plani.platot - vtotpro).
 
                   if not avail produ 
                   then find first produ where produ.procod = 360
                                no-lock no-error.
                   
                  run p-grava-tt(input (if plani.movtdc = 13 then 13 else 4),
                                   input vmovqt-4, 
                                   input vmovpc-4).
                                   
                 xxx = xxx + vmovpc-4.               
                                   
               end.     

           end.
       end. 
       **/
   end.
   hide frame fx1 no-pause.
   hide frame fffpla no-pause.

end.

end procedure.

procedure p-grava-tt.
    def input parameter vmovtdc    as int.
    def input parameter vestatual like estoq.estatual.
    def input parameter vestcusto like estoq.estcusto.
          
    if (vopc = yes and avail movim and movim.movalicms <> ?)
    then assign vicms = movim.MovAlICMS.
    
    if vopc = yes
    then assign vpis = 0.65  
                vcofins = 3.0.
    else do:           
        if vmovtdc = 4 and aux-uf = "AM"
        then assign vpis    = 1
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
                       if vmovtdc <> 5
                       then assign vpis    = clafis.pisent
                                   vcofins = clafis.cofinsent.
                       else assign vpis    = clafis.pissai
                                   vcofins = clafis.cofinssai.
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
      
      /*****************/
           
      if vpis = 0 then vcofins = 0.
      
      if vmovtdc = 5 and vicms <> 18 
      then do:
           if vmapsub > vendsub and vicms = 0
           then do:
                if vmapsub < (vendsub + vestcusto)
                then vestcusto = (vmapsub - vendsub).
                vendsub = vendsub + vestcusto.    
                
           end.
           else do:
               if vmap12 > vend12 and vicms > 0
               then if vmap12 < (vend12 + vestcusto)
                    then vestcusto = (vmap12 - vend12).
                    else.
               else vicms = 18.

               vend12 = vend12 + vestcusto.
           end.
      end.
           
      assign aux-custo = (if vopc = no then vestcusto
                          else ((if avail movim then movim.movpc 
                                 else vestcusto) *  vestatual))
             aux-icms  = trunc(aux-custo * (vicms / 100),2).   
             
      if vmovtdc = 5 and 
         (vmapicm < (vlimicm + (aux-custo * (vicms / 100))) or
          vmapvda < (vlimvda + aux-custo))
      then do:
           assign aux-icms  = (vmapicm - vlimicm) 
                  aux-custo = vmapvda - vlimvda.
           if aux-custo > (vestcusto * 3)
           then assign aux-icms = 0 
                       vicms = 0
                       aux-custo = (vestcusto * 1.5).
                  
       end.

       assign aux-liq  = aux-custo - aux-icms
              aux-pis  = ((if vopc then aux-liq else aux-custo)
                             * (vpis / 100))
              aux-cofins = ((if vopc then aux-liq else aux-custo) 
                                 * (vcofins / 100)).

       if (vmovtdc = 5 and vmapicm >= (vlimicm + aux-icms)
           and aux-custo > 0)
       or vmovtdc <> 5
       then do:
     
            if vmovtdc = 5
            then assign vlimicm = vlimicm + aux-icms
                        vlimvda = vlimvda + aux-custo.

            if vanalitico = no 
            then do:
                if vconsolidado
                then  find first tt-custo where tt-custo.etbcod = 0 
                                       and tt-custo.procod = 0
                                       and tt-custo.movtdc = vmovtdc
                                       and tt-custo.alipis = vpis
                            no-error.
                else  find first tt-custo where tt-custo.etbcod = 
                                                    tt-estab.etbcod 
                                       and tt-custo.procod = 0
                                       and tt-custo.movtdc = vmovtdc
                            no-error.
            end.
            else find first tt-custo where tt-custo.etbcod = /*vetbi*/                                                               tt-estab.etbcod 
                                       and tt-custo.procod = produ.procod
                                       and tt-custo.movtdc = vmovtdc
                            no-error.
            if not avail tt-custo
            then do:
                 create tt-custo.
                 if vanalitico = NO 
                 then do:
                    if vconsolidado
                    then assign tt-custo.etbcod = 0
                             tt-custo.procod = 0
                             tt-custo.movtdc = vmovtdc
                             tt-custo.alipis = vpis.
                    else assign tt-custo.etbcod = tt-estab.etbcod
                                tt-custo.procod = 0
                             tt-custo.movtdc = vmovtdc.
                end.
                else assign tt-custo.etbcod = tt-estab.etbcod /*vetbi*/
                             tt-custo.procod = produ.procod 
                             tt-custo.movtdc = vmovtdc.            
            
            end.
            
            assign 
                   tt-custo.estatual = tt-custo.estatual + vestatual
                   tt-custo.estcusto = tt-custo.estcusto + aux-custo +
                                      (if vsoma = "A" then aux-icms
                                       else if vsoma = "D" 
                                            then (aux-icms * -1)
                                            else 0)
                   tt-custo.cusicm  = tt-custo.cusicm + aux-icms
                   tt-custo.cusliq  = tt-custo.cusliq + aux-liq
                   tt-custo.cuspis  = tt-custo.cuspis + aux-pis
                   tt-custo.cuscofins = tt-custo.cuscofins + aux-cofins
                   tt-custo.cuscont  = tt-custo.cuscont 
                                     + (aux-custo - aux-icms - 
                                       aux-pis - aux-cofins)
                                    + (if vsoma = "A" then aux-icms 
                                      else if vsoma = "D" then (aux-icms * -1)
                                           else  0).
        /*
        find first ctbhie where
                   ctbhie.etbcod = 0 and
                   ctbhie.ctbmes = vmes and
                   ctbhie.ctbano = vano and
                   ctbhie.procod = produ.procod
                   no-lock.
                   
        disp ctbhie. pause.
        message tt-custo.procod tt-custo.estatual.
        pause.
        */
      end.                                     

end procedure.

procedure busca-ali:
   /*** copia do gerpla.p (grava-ali) */

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
        then vicms = 18.
        else if vali = "02"
             then vicms = 12.
             else if vali = "03"
                  then vicms = 7.
                  else if vali = "04"
                       then vicms = 25.
                       else vicms = 0.
                                    
end procedure.

procedure sel-produto:
    for each tt-produ: delete tt-produ. end.
    def buffer cmovim for movim.
    
    for each tt-estab no-lock:
    for each cmovim 
                                where cmovim.etbcod = tt-estab.etbcod 
                                  and cmovim.movtdc = vmovtdc
                                  and cmovim.movdat >= vdti 
                                  and cmovim.movdat <= vdtf 
                                  no-lock:
        find first tt-produ where tt-produ.procod = cmovim.procod no-error.
        if not avail tt-produ
        then do:
            create tt-produ.
            tt-produ.procod = cmovim.procod.
        end.    
    end.
    end.
     
end.

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
      
           
      assign aux-custo = movim.movpc
             aux-icms  = trunc(aux-custo * (vicms / 100),2)
             aux-custo = (aux-custo - aux-icms -    
                         aux-pis - aux-cofins)
                         .
                         
    end.
                             
end procedure.
