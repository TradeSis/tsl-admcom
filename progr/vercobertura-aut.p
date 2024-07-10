/*{admdisparo.i}    */

def new global shared var setbcod    like ger.estab.etbcod.
def input parameter p-procod like produ.procod.
def input parameter p-pede like liped.lipqtd.
def output parameter p-ok as log.
def output parameter p-sugerido as int.
def output parameter vmovqtm like movim.movqtm.
def output parameter qtd-conjunto as int.
def var vmedia as dec.
def var vcobertura as int.

def buffer e-tabmix for tabmix.
def buffer p-tabmix for tabmix.
def buffer c-tabmix for tabmix.

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

find produ where 
     produ.procod = p-procod no-lock.

find first c-tabmix where c-tabmix.tipomix = "F" and
                          c-tabmix.codmix  <> 99 and
                          c-tabmix.promix  = produ.clacod and
                          c-tabmix.etbcod  = setbcod
                          no-lock no-error.
if avail c-tabmix
then do:
                                              
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
        end.
    end.
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
         end.
        end.
    end.
    if tem-min = no
    then qtd-min = 1.
end.
if tem-mix = no and
   tem-min = no
then qtd-mix = 1.
if tem-mix = yes and
   pro-mix = no
then qtd-mix = 0.   
if tem-min = yes and 
   pro-min = yes
then qtd-mix = qtd-min.
   

find estoq where estoq.etbcod = setbcod and
                 estoq.procod = p-procod
                 no-lock.

def var vestatual like estoq.estatual.
vestatual = estoq.estatual.

/*if vestatual + p-pede <= 0 
then p-sugerido = p-pede.
else p-sugerido = p-pede - ((vestatual + p-pede) - qtd-mix).
*/

p-sugerido = qtd-mix - vestatual .

if p-sugerido < 0
then p-sugerido = 0.

/*
if tem-mix = no and
   tem-min = no
then p-sugerido = qtd-mix.
*/   
def buffer ctbcntgen for tbcntgen.   
def var vconjunto as int format "zzz".        
def var c-i as int.
def var c-a as dec.
def var c-v as dec.
qtd-conjunto = 0.
if tem-mix = no and
   pro-min = no
then do:   
find first ctbcntgen where
           ctbcntgen.tipcon = 5 and
           ctbcntgen.etbcod = 0 and
           ctbcntgen.numfim = string(p-procod) no-lock no-error.
if avail ctbcntgen and ctbcntgen.valor > 0
then do:

    qtd-conjunto = ctbcntgen.quantidade.
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
        if vestatual = 0
        then p-sugerido = ctbcntgen.quantidade.
        else p-sugerido = ctbcntgen.quantidade * vconjunto.    
    end.
    if p-sugerido <= 0
    then p-ok = no.   
end. 
end.

def buffer ppedid for pedid.
def buffer pliped for liped.

def var p-pedid as int init 0.
if p-sugerido > 0
then do:
    for each pliped where 
             pliped.procod = produ.procod and
             pliped.etbcod = setbcod and
             pliped.pedtdc = 3 
             no-lock,
        first ppedid where
              ppedid.pedtdc = pliped.pedtdc and
              ppedid.etbcod = pliped.etbcod and
              ppedid.pednum = pliped.pednum and
              ppedid.peddat >= today - 30
              no-lock:
              
        if ppedid.sitped = "F" or
           ppedid.sitped = "C"
        then next.
           
        if ppedid.modcod = "PED0"
        then next.
        
        p-pedid = p-pedid + pliped.lipqtd.             
    end.
    p-ok = yes.  
    if qtd-conjunto = 0  and p-pede > 0
    then do:
        if pro-mix = yes and 
            p-sugerido > p-pede + p-pedid
        then run ajuste-mix.
        else do:
            if pro-min = yes and
               p-sugerido > p-pede + p-pedid
            then run ajuste-min.   
        end.    
    end.
end.        
           
procedure ajuste-min:
    def buffer bpedid for pedid.
    def var vpednum like pedid.pednum.
    def var v-min as log.
    v-min = no.
    for each  pedid where 
              pedid.pedtdc = 3 and
              pedid.sitped = "E" and
              pedid.etbcod = setbcod and
              pedid.pednum >= 100000 and
              pedid.modcod = "PEDI"
               no-lock.
        find first liped where
                   liped.etbcod = pedid.etbcod and
                   liped.pedtdc = pedid.pedtdc and
                   liped.pednum = pedid.pednum and
                   liped.procod = p-procod and
                   liped.lipsit = "Z"
                   no-lock no-error.
        if avail liped  and
                 liped.lipent = 0 
        then v-min = yes.
    end.
    if v-min = no       
    then do:
        find last pedid where 
                          pedid.pedtdc = 3 and
                          pedid.sitped = "E" and
                          pedid.etbcod = setbcod and
                          pedid.pednum >= 100000 and
                          pedid.peddat = today and
                          pedid.modcod = "PEDI"
                          no-lock no-error.
        if not avail pedid 
        then do: 
            find last bpedid where bpedid.pedtdc = 3 and
                                   bpedid.etbcod = setbcod  and
                                   bpedid.pednum >= 100000 no-error.
            if avail bpedid 
            then vpednum = bpedid.pednum + 1. 
            else vpednum = 100000.
    
            create pedid. 
            assign pedid.etbcod = setbcod
                   pedid.pedtdc = 3 
                   pedid.peddat = today 
                   pedid.pednum = vpednum 
                   pedid.sitped = "E"  
                   pedid.modcod = "PEDI"
                   pedid.pedsit = yes.
        
        end.
        find first liped where
                   liped.etbcod = pedid.etbcod and
                   liped.pedtdc = pedid.pedtdc and
                   liped.pednum = pedid.pednum and
                   liped.procod = p-procod no-lock no-error.
        if not avail liped
        then do:
            create liped.
            assign liped.pedtdc    = pedid.pedtdc
                   liped.pednum    = pedid.pednum
                   liped.procod    = p-procod
                   liped.lippreco  = estoq.estvenda
                   liped.lipsit    = "Z"
                   liped.predtf    = pedid.peddat
                   liped.predt     = pedid.peddat
                   liped.etbcod    = pedid.etbcod
                   liped.protip    = "0"
                   liped.lipqtd    = p-sugerido - (p-pede + p-pedid).
        end. 
    end.      
end procedure.

procedure ajuste-mix:
    def buffer bpedid for pedid.
    def var vpednum like pedid.pednum.
    def var v-mix as log.
    v-mix = no.
    for each  pedid where 
               pedid.pedtdc = 3 and
               pedid.sitped = "E" and
               pedid.etbcod = setbcod and
               pedid.pednum >= 100000 and
               pedid.modcod = "PEDX"
               no-lock.
        find first liped where
                   liped.etbcod = pedid.etbcod and
                   liped.pedtdc = pedid.pedtdc and
                   liped.pednum = pedid.pednum and
                   liped.procod = p-procod and
                   liped.lipsit = "Z"
                   no-lock no-error.
        if avail liped  and
                 liped.lipent = 0 
        then v-mix = yes.
    end.
    if v-mix = no       
    then do:
        find last pedid where 
                          pedid.pedtdc = 3 and
                          pedid.sitped = "E" and
                          pedid.etbcod = setbcod and
                          pedid.pednum >= 100000 and
                          pedid.peddat = today and
                          pedid.modcod = "PEDX"
                          no-lock no-error.
        if not avail pedid 
        then do: 
            find last bpedid where bpedid.pedtdc = 3 and
                                   bpedid.etbcod = setbcod  and
                                   bpedid.pednum >= 100000 no-error.
            if avail bpedid 
            then vpednum = bpedid.pednum + 1. 
            else vpednum = 100000.
    
            create pedid. 
            assign pedid.etbcod = setbcod
                   pedid.pedtdc = 3 
                   pedid.peddat = today 
                   pedid.pednum = vpednum 
                   pedid.sitped = "E"  
                   pedid.modcod = "PEDX"
                   pedid.pedsit = yes.
        
        end.
        find first liped where
                   liped.etbcod = pedid.etbcod and
                   liped.pedtdc = pedid.pedtdc and
                   liped.pednum = pedid.pednum and
                   liped.procod = p-procod no-lock no-error.
        if not avail liped
        then do:
            create liped.
            assign liped.pedtdc    = pedid.pedtdc
                   liped.pednum    = pedid.pednum
                   liped.procod    = p-procod
                   liped.lippreco  = estoq.estvenda
                   liped.lipsit    = "Z"
                   liped.predtf    = pedid.peddat
                   liped.predt     = pedid.peddat
                   liped.etbcod    = pedid.etbcod
                   liped.protip    = "0"
                   liped.lipqtd    = p-sugerido - (p-pede + p-pedid).
        end. 
    end.  
end procedure.

    

