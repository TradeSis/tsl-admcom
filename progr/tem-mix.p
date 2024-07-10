{admcab.i}
def input parameter p-procod like com.produ.procod.
def output parameter p-mix as log.

def var vmedia as dec.
def var vcobertura as int.

def buffer e-tabmix for tabmix.
def buffer p-tabmix for tabmix.
def var qtd-mix as dec.
def var qtd-min as dec.
def var tem-mix as log.
def var tem-min as log.
def var pro-mix as log.
def var pro-min as log.
def var dat-mix as date init ?.
def var dat-min as date init ?.
tem-mix = no.
tem-min = no.
pro-mix = no.
pro-min = no.
qtd-mix = 0.
qtd-min = 0.
find com.produ where 
     com.produ.procod = p-procod no-lock.
for each tabmix where tabmix.tipomix = "M" and
                      tabmix.codmix  <> 99 and
                      tabmix.etbcod = setbcod no-lock:
    find first e-tabmix where e-tabmix.tipomix = "F" and
                       e-tabmix.codmix  = tabmix.codmix and
                       e-tabmix.promix  = com.produ.clacod and
                       e-tabmix.etbcod  = setbcod
                       no-lock no-error.
    if avail e-tabmix and
        e-tabmix.campodat1 <= today
    then do:
         tem-mix = yes.
         
         dat-mix = e-tabmix.campodat1.
         find first p-tabmix where p-tabmix.tipomix = "P" and
                             p-tabmix.codmix  = e-tabmix.codmix and
                             p-tabmix.promix  = com.produ.procod and
                             p-tabmix.etbcod = 0 
                             no-lock no-error.
         if avail p-tabmix
         then do:
           /* if p-tabmix.qtdmix = 0 and
               p-tabmix.mostruario = no and
              (e-tabmix.campodat1 + e-tabmix.campoint1) <= today
            then pro-mix = no.
            else pro-mix = yes.
            qtd-mix = p-tabmix.qtdmix.
            if p-tabmix.sazonal and
               p-tabmix.dtsazonali <= today and
               p-tabmix.dtsazonalf >= today
            then qtd-mix = p-tabmix.qtdsazonal.*/
            if p-tabmix.mostruario 
            then  pro-mix = yes.
        end.
        else  pro-mix = no.
        leave.
    end.
    else tem-mix = no.
end.
if tem-mix = no or
   (tem-mix = yes and pro-mix = no) 
then do: 
    qtd-mix = 1.
    for each tabmix where tabmix.tipomix = "M" and
                      tabmix.codmix  = 99 and
                      tabmix.etbcod = setbcod no-lock:
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
                             p-tabmix.promix  = com.produ.procod
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
         end.
        end.
    end.
    if tem-min = no
    then qtd-min = 1.
end.
p-mix = no.
if tem-mix = yes and pro-mix = yes 
then p-mix = yes.
else if tem-mix = no then p-mix = no.
   

