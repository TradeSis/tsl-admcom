{admcab.i}
def input parameter p-procod like produ.procod.
def input parameter p-pede like liped.lipqtd.
def output parameter p-ok as log.
def output parameter p-sugerido as int.
def output parameter vmovqtm like movim.movqtm.
def output parameter p-conjunto as dec.

p-ok = yes.
def var vmedia as dec.
def var vcobertura as int.
def buffer cestoq for estoq.
def var cestoq-estatual like estoq.estatual.
find produ where produ.procod = p-procod no-lock.
find cestoq where cestoq.etbcod = 993 and
                  cestoq.procod = produ.procod
                  no-lock no-error.
if not avail cestoq or cestoq.estatual <= 0
then find cestoq where cestoq.etbcod = 981 and 
                       cestoq.procod = produ.procod
                       no-lock no-error.
                       
if avail cestoq and cestoq.estatual > 0
then cestoq-estatual = cestoq.estatual.

def var vcatcod like produ.catcod.
if produ.catcod < 40
then vcatcod = 31.
else vcatcod = 41.
find first tbcntgen where
           tbcntgen.tipcon = 3 and 
           tbcntgen.etbcod = setbcod and
           tbcntgen.numfim = string(vcatcod) and
           tbcntgen.numini = string(produ.clacod) and
           (tbcntgen.validade = ? or
           tbcntgen.validade >= today)
           no-lock no-error.
if not avail tbcntgen
then find first tbcntgen where
           tbcntgen.tipcon = 3 and 
           tbcntgen.etbcod = 0 and
           tbcntgen.numfim = string(vcatcod) and
           tbcntgen.numini = string(produ.clacod) and
           (tbcntgen.validade = ? or
           tbcntgen.validade >= today)
           no-lock no-error.
if not avail tbcntgen
then find first tbcntgen where
           tbcntgen.tipcon = 3 and 
           tbcntgen.etbcod = setbcod and
           tbcntgen.numfim = string(vcatcod) and
           tbcntgen.numini = string(0) and
           (tbcntgen.validade = ? or
           tbcntgen.validade >= today)
           no-lock no-error.
if not avail tbcntgen
then find first tbcntgen where
           tbcntgen.tipcon = 3 and 
           tbcntgen.etbcod = 0 and
           tbcntgen.numfim = string(vcatcod) and
           tbcntgen.numini = string(0) and
           (tbcntgen.validade = ? or
           tbcntgen.validade >= today)
           no-lock no-error.
def var vdiasvenda as int.
def var vdiascob   as int.

if avail tbcntgen
then do:
find first movim where movim.procod = produ.procod 
                   and movim.etbcod = setbcod
                   and movim.movdat <  today - tbcntgen.quantidade
                   no-lock no-error. 
if avail movim
then vdiasvenda = tbcntgen.quantidade.
else do:
    find first movim where movim.procod = produ.procod 
                       and movim.etbcod = setbcod
                   no-lock no-error. 
    if avail movim
    then vdiasvenda = today - movim.movdat.
    else vdiasvenda = tbcntgen.quantidade.
end.
end.
else vdiasvenda = 90.
vmovqtm = 0.
for each movim where 
         movim.etbcod = setbcod and
         movim.movtdc = 5 and
         movim.procod = p-procod and
         movim.movdat >= (if cestoq.estatual > 0
                         then today - vdiasvenda
                         else cestoq.estinvdat - vdiasvenda)
                  no-lock:
    vmovqtm = vmovqtm + movim.movqtm .                    
end.
def var vestatual like estoq.estatual.
find estoq where estoq.etbcod = setbcod and
                 estoq.procod = p-procod
                 no-lock.
vestatual = estoq.estatual.
p-pede = p-pede + 
    (if estoq.estatual > 0 then estoq.estatual else 0).                  

vmedia = vmovqtm / 26 /*vdiasvenda*/.
if vmedia = ?
then vmedia = 0.
vcobertura = p-pede / vmedia .
if vcobertura = ?
then vcobertura = 0.

p-ok = yes.
if avail tbcntgen  and
   vcobertura > int(tbcntgen.valor) 
then p-ok = no.

sretorno = string(vcobertura).

def var vqtd as int init 0.
p-sugerido = 0.  
 /***
disp    produ.procod 
        produ.pronom
        produ.catcod
        produ.clacod
        vmovqtm label "Venda 90"
        vdiasvenda
     vmedia  label "Media 90"
     estoq.estatual label "Estoque"
     p-pede - estoq.estatual label "Pedido"
     vcobertura label "Cobertura"
     with centered row 8 side-label 1 column overlay.
      pause.
 ***/
/**
find revista where
     revista.etbcod = setbcod and
     revista.procod = produ.procod and
     revista.datini = date(month(today),01,year(today)) and   
     revista.datfim = date(if month(today) = 12 then 1 else 
        month(today) + 1,01,if month(today) = 12 then year(today) + 1 else
        year(today)) - 1
     no-lock no-error.
if not avail revista
then find revista where
     revista.etbcod = 0 and
     revista.procod = produ.procod and
     revista.datini = date(month(today),01,year(today)) and   
     revista.datfim = date(if month(today) = 12 then 1 else 
        month(today) + 1,01,if month(today) = 12 then year(today) + 1 else
        year(today)) - 1
     no-lock no-error.
**/

find last revista where
     revista.etbcod = setbcod and
     revista.procod = produ.procod and
     revista.datini <= today and   
     revista.datfim >= today
     no-lock no-error.
if not avail revista
then find last revista where
     revista.etbcod = 0 and
     revista.procod = produ.procod and
     revista.datini <= today and
     revista.datfim >= today
     no-lock no-error.

if vmedia > 0 and avail tbcntgen
then do:
repeat:

    vqtd = vqtd + 1.
    vcobertura = (p-pede + vqtd) / vmedia .
    
    if not avail tbcntgen
    then do:
         message "Não existe Parametro de Cobertura para Loja".
         leave.
    end.

    if vcobertura = ?
    then vcobertura = 0.
    if avail tbcntgen  and
        vcobertura > int(tbcntgen.valor) 
    then do:
        if vqtd > 1
        then p-sugerido = vqtd - 1.
        else p-sugerido = vqtd. 
        if avail revista
        then p-sugerido = p-sugerido * ((revista.tolerancia / 100) + 1).
        leave.
    end.
end.    
end.
else do:
    p-ok = no.
    if vestatual = 0
    then do:
        p-sugerido = 1.
        if avail revista
        then  p-sugerido = p-sugerido * ((revista.tolerancia / 100) + 1).
    end.
    else do:
        if avail revista
        then p-sugerido = p-sugerido +
            (p-sugerido * (revista.tolerancia / 100)).
    end.
end.       
def buffer ctbcntgen for tbcntgen.   
def var vconjunto as int format "zzz".        
def var c-i as int.
def var c-a as dec.
def var c-v as dec.
find first ctbcntgen where
           ctbcntgen.tipcon = 5 and
           ctbcntgen.etbcod = 0 and
           ctbcntgen.numfim = string(produ.procod)  no-error.
if avail ctbcntgen and ctbcntgen.valor > 0
then do:
    p-conjunto = ctbcntgen.quantidade.
    if p-sugerido >= 1
    then do:
        c-v = int(substr(string(
            p-sugerido / ctbcntgen.quantidade,">>>>>>>>9.99"),1,9)).
        if c-v = 0
        then do:
            c-a = (p-sugerido / ctbcntgen.quantidade) * 100.
            if c-a >= ctbcntgen.valor
            then vconjunto = 1.
        end.
        else do:
            c-a = p-sugerido - (ctbcntgen.quantidade * c-v).
            c-a = (c-a / ctbcntgen.quantidade) * 100.
            if c-a >= ctbcntgen.valor
            then vconjunto = c-v + 1.
            else vconjunto = c-v.
        end.
        if vconjunto = 0 /*and vestatual <= 0*/
        then vconjunto = 1.
        if vconjunto > 0
        then p-sugerido = ctbcntgen.quantidade * vconjunto. 
        else p-sugerido = 0.  
    end.
    else p-sugerido = ctbcntgen.quantidade.
    
    /**
    if p-sugerido = 0
    then p-sugerido = ctbcntgen.quantidade.   
    **/
    p-sugerido = p-sugerido + (p-sugerido * (revista.tolerancia / 100)).
end. 

def buffer e-tabmix for tabmix.
def buffer p-tabmix for tabmix.
def var qtd-mix as dec.
def var qtd-min as dec.
def var tem-mix as log.
def var tem-min as log.
def var pro-mix as log.
def var pro-min as log.
def var p-ajuste as log.
def var dat-mix as date init ?.
def var dat-min as date init ?.
tem-mix = no.
tem-min = no.
pro-mix = no.
pro-min = no.
qtd-mix = 0.
qtd-min = 0.
p-ajuste = no.
for each tabmix where tabmix.tipomix = "M" and
                      tabmix.codmix  < 99 no-lock:
    find first e-tabmix where e-tabmix.tipomix = "F" and
                       e-tabmix.codmix  = tabmix.codmix and
                       e-tabmix.promix  = produ.clacod and
                       e-tabmix.etbcod  = setbcod
                       no-lock no-error.
    if avail e-tabmix and
        e-tabmix.campodat1 <= today
    then do:
         tem-mix = yes.
         dat-mix = e-tabmix.campodat1.
         find p-tabmix where p-tabmix.tipomix = "P" and
                             p-tabmix.codmix  = e-tabmix.codmix and
                             p-tabmix.promix  = produ.procod
                             no-lock no-error.
         if avail p-tabmix
         then do:
            if p-tabmix.qtdmix = 0 and
               p-tabmix.mostruario = no and
              (e-tabmix.campodat1 + e-tabmix.campoint1) <= today
            then pro-mix = no.
            else pro-mix = yes.
            qtd-mix = p-tabmix.qtdmix.
            if p-tabmix.sazonal and
               p-tabmix.dtsazonali <= today and
               p-tabmix.dtsazonalf >= today
            then qtd-mix = p-tabmix.qtdsazonal.
            if (e-tabmix.campodat1 + e-tabmix.campoint1) >= today
            then p-ajuste = yes.
        end.
        else if (e-tabmix.campodat1 + e-tabmix.campoint1) >= today
        then pro-mix = yes.
    end.
end.
if tem-mix = no or
   (tem-mix = yes and pro-mix = no) 
then do: 
    qtd-mix = 1.
    for each tabmix where tabmix.tipomix = "M" and
                      tabmix.codmix  = 99 no-lock:
        find e-tabmix where e-tabmix.tipomix = "F" and
                       e-tabmix.codmix  = tabmix.codmix and
                       /*e-tabmix.promix  = commatriz.produ.clacod and*/
                       e-tabmix.etbcod  = setbcod
                       no-lock no-error.
        if avail e-tabmix and
            e-tabmix.campodat1 <= today
        then do:
         tem-min = yes.
         dat-min = e-tabmix.campodat1.
         qtd-min = 1.
         find p-tabmix where p-tabmix.tipomix = "P" and
                             p-tabmix.codmix  = e-tabmix.codmix and
                             p-tabmix.promix  = produ.procod
                             no-lock no-error.
         if avail p-tabmix
         then do:
            if p-tabmix.qtdmix = 0 and
               p-tabmix.mostruario = no and
              (e-tabmix.campodat1 + e-tabmix.campoint1) <= today
            then pro-min = no.
            else pro-min = yes.
            qtd-min = p-tabmix.qtdmix.
            if p-tabmix.sazonal and
               p-tabmix.dtsazonali <= today and
               p-tabmix.dtsazonalf >= today
            then qtd-min = p-tabmix.qtdsazonal.
            /*
            if (e-tabmix.campodat1 + e-tabmix.campoint1) >= today
            then p-ajuste = yes.
            */
         end.
        end.
    end.
    if tem-min = no
    then qtd-min = 1.
end.
if tem-mix = yes and
   pro-mix = no  and 
   p-ajuste = no
then p-sugerido = -1.   
if tem-min = yes and
   pro-min = yes
then p-sugerido = qtd-min.

