
FUNCTION acha returns character
    (input par-oque as char,
     input par-onde as char).
         
    def var vx as int.
    def var vret as char.  
    
    vret = ?.  
    
    do vx = 1 to num-entries(par-onde,"|"). 
        if entry(1,entry(vx,par-onde,"|"),"=") = par-oque 
        then do: 
            vret = entry(2,entry(vx,par-onde,"|"),"="). 
            leave. 
        end. 
    end.
    return vret. 
END FUNCTION.

def new shared temp-table tt-proped
    field etbcod like estab.etbcod
    field pladat like plani.pladat
    field placod like plani.placod
    field numero like plani.numero
    field procod like produ.procod
    field movqtm like movim.movqtm
    field sugere like movim.movqtm
    field tipo   as char  
    field whr as int
    field pednum as int
    . 
 
def input parameter p-procod like produ.procod.
def input parameter p-etbcod like ger.estab.etbcod.
def output parameter p-ok as log.
def output parameter p-mix as int.
def output parameter p-pedido as int.
def output parameter p-sugerido as int.
def output parameter vmovqtm like movim.movqtm.
def output parameter qtd-conjunto as int.
def output parameter vaj-min as dec.
def output parameter vaj-mix as dec.
def output parameter ventrega-out as dec.

def var vmedia as dec.
def var vcobertura as int.

def buffer e-tabmix for tabmix.
def buffer p-tabmix for tabmix.
def buffer c-tabmix for tabmix.
def var vmix-diferenciado as log.
def var qtd-mix as dec.
def var qtd-min as dec.
def shared var tem-mix as log.
def var tem-min as log.
def shared var pro-mix as log.
def var pro-min as log.
def var dat-mix as date init ?.
def var dat-min as date init ?.
tem-mix = no.
tem-min = no.
pro-mix = no.
pro-min = no.
qtd-mix = 0.
qtd-min = 0.

def var p-no-mix as log init no.
def var ajusta-mix as log init no.
find produ where 
     produ.procod = p-procod no-lock.

find clase where clase.clacod = produ.clacod no-lock.
 
find first c-tabmix where c-tabmix.tipomix = "F" and
                          c-tabmix.codmix  <> 99 and
                          c-tabmix.promix  = produ.clacod and
                          c-tabmix.etbcod  = p-etbcod
                          no-lock no-error.
if not avail c-tabmix  and
    clase.clasup > 0
then find first c-tabmix where c-tabmix.tipomix = "F" and
                          c-tabmix.codmix  <> 99 and
                          c-tabmix.promix  = clase.clasup and
                          c-tabmix.etbcod  = p-etbcod
                          no-lock no-error.


if avail c-tabmix
then do:
                                 
ajusta-mix = c-tabmix.campolog2.

for each tabmix where tabmix.tipomix = "M" and
                      tabmix.codmix  = c-tabmix.codmix no-lock:
    find first e-tabmix where e-tabmix.tipomix = "F" and
                       e-tabmix.codmix  = tabmix.codmix and
                       e-tabmix.promix  = produ.clacod and
                       e-tabmix.etbcod  = p-etbcod
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
            then  qtd-mix = p-tabmix.qtdsazonal.
        end.
    end.
end.
end.

vmix-diferenciado = no.
if tem-mix = no or
   pro-mix = no
then do:
    find first c-tabmix where c-tabmix.tipomix = "F" and
                          c-tabmix.codmix  <> 99 and
                          c-tabmix.etbcod  = p-etbcod
                          no-lock no-error.
    if avail c-tabmix
    then do:
        find first tabmix where tabmix.tipomix = "M" and
                      tabmix.codmix = c-tabmix.codmix
                      no-lock no-error.
        if avail tabmix and
                 tabmix.campolog1 = yes
        then do:
            vmix-diferenciado = yes.
            p-no-mix = no.
            run pro-no-mix.
        end.
    end.
end.                      
p-mix = qtd-mix.   
if tem-mix = no or
   (tem-mix = yes and pro-mix = no) 
then do: 
    qtd-mix = 1.
    for each tabmix where tabmix.tipomix = "M" and
                      tabmix.codmix  = 99 no-lock:
        find e-tabmix where e-tabmix.tipomix = "F" and
                       e-tabmix.codmix  = tabmix.codmix and
                       /*e-tabmix.promix  = commatriz.produ.clacod and*/
                       e-tabmix.etbcod  = p-etbcod
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
find estoq where estoq.etbcod = p-etbcod and
                 estoq.procod = p-procod
                 no-lock.
                 
def var vestatual like estoq.estatual.
vestatual = estoq.estatual.

if tem-mix = yes and
   pro-mix = no
then do:
    if vmix-diferenciado = yes and
       vestatual < 0
    then qtd-mix = (-1 * vestatual).
    else qtd-mix = 0.   
end.
if tem-min = yes and 
   pro-min = yes
then qtd-mix = qtd-min.


p-sugerido = 0.
if pro-min = yes or
   pro-mix = yes
then p-sugerido = qtd-mix - vestatual .
else if vmix-diferenciado = yes
    then do:
        if p-no-mix
        then p-sugerido = 0.
        else if vestatual > 0
        then p-sugerido = 0.
        else if vestatual = 0
            then p-sugerido = 1.
        else if vestatual < 0
            then p-sugerido =  (-1 * vestatual).
    end.
    else if vestatual < 0 and tem-mix
    then p-sugerido = (-1 * vestatual).
    else if vestatual < 0 and tem-mix = no
    then p-sugerido = (-1 * vestatual) + 1.
    else if vestatual = 0 and tem-mix = no
    then p-sugerido = 1.

if p-sugerido < 0
then p-sugerido = 0.

def buffer ctbcntgen for tbcntgen.   
def var vconjunto as int format "zzz".        
def var c-i as int.
def var c-a as dec.
def var c-v as dec.
qtd-conjunto = 0.
def var per-conjunto as dec.
per-conjunto = 0.

if /*tem-mix = no and
   pro-min = no and*/
   p-sugerido > 0
then do:   
find first ctbcntgen where
           ctbcntgen.tipcon = 5 and
           ctbcntgen.etbcod = 0 and
           ctbcntgen.numfim = string(p-procod) no-lock no-error.
if avail ctbcntgen and ctbcntgen.valor > 0
then do:
    qtd-conjunto = ctbcntgen.quantidade.
    per-conjunto = ctbcntgen.valor.
    if not tem-mix or
       not pro-mix 
    then do:
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
    end.
    else do:
        /*
        if p-sugerido < qtd-conjunto
        then p-sugerido = qtd-conjunto.
        else p-sugerido = qtd-conjunto * int((p-mix / qtd-conjunto)).
        */
    end.
    
    if p-sugerido <= 0
    then p-ok = no.   
end. 
end.

def buffer ppedid for pedid.
def buffer pliped for liped.

if p-sugerido > 0
then do:

    if tem-mix
    then do:
    ventrega-out = 0.
    
    if vmix-diferenciado = no
    then do:
        run entrega-outra-filial.
        p-sugerido = p-sugerido - ventrega-out.

        p-pedido = 0.
        for each pliped where 
             pliped.procod = produ.procod and
             pliped.etbcod = p-etbcod and
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
           
            if ppedid.modcod = "PEDO"
            then next.
        
            p-pedido = p-pedido + pliped.lipqtd.             
        end.
        p-sugerido = p-sugerido - p-pedido.
    end.
    if p-sugerido < 0
    then p-sugerido = 0.
    
    p-ok = yes.  
    if qtd-conjunto > 0 and p-sugerido > 0
    then do:
        if p-sugerido <= qtd-conjunto * (per-conjunto / 100)
        then p-sugerido = qtd-conjunto.
        
    end.
    end.
    else p-ok = yes.     
end.        
if p-sugerido < 0
then p-sugerido = 0.

procedure entrega-outra-filial:
    def var vetb-entrega as int.
    def var vdat-entrega as date.
    def var vok as log.
    def buffer bliped for com.liped.
    def buffer bpedid for com.pedid.

    for each com.liped where
               com.liped.etbcod = p-etbcod and
               com.liped.procod = p-procod and
               com.liped.pedtdc = 32 and                      
               com.liped.lipsit = "A" and
               com.liped.predt >= today - 60
                              no-lock .

        vetb-entrega = int(ACHA("ETB-ENTREGA",com.liped.lipcor)).
        vdat-entrega = date(ACHA("DAT-ENTREGA",com.liped.lipcor)).
        if vdat-entrega < today - 30
        then next.
        vok = no.
        for each  movim where
                movim.etbcod = vetb-entrega and
                movim.procod = com.liped.procod and
                movim.movtdc = 6 and
                movim.desti = com.liped.etbcod  and
                movim.movdat >= vdat-entrega - 30
                no-lock .
            find last com.pedid where
              com.pedid.pedtdc = 3 and
              (com.pedid.sitped = "F" or
               com.pedid.sitped = "C") and
              com.pedid.etbcod = movim.etbcod and
              com.pedid.pednum = movim.ocnum[1] and
              com.pedid.peddat = vdat-entrega and
              com.pedid.modcod = "PEDO" 
              no-lock no-error.
            if avail com.pedid
            then do:
                if com.pedid.sitped = "C"
                then vok = yes.
                else do:
                find bliped of pedid where
                        bliped.procod = movim.procod
                        no-lock no-error.
                if avail bliped /*and
                        bliped.lipent >= bliped.lipqtd*/
                then vok = yes.
                end.
            end.
        end.
        if vok = no
        then do:
            vok = yes.
            for each bliped where bliped.etbcod = vetb-entrega and
                             bliped.pednum > 100000 and
                             bliped.procod = com.liped.procod   and
                             bliped.pedtdc = 3
                             no-lock .
                find first bpedid where 
                       bpedid.etbcod = bliped.etbcod and
                       bpedid.pednum = bliped.pednum and
                       bpedid.vencod = com.liped.etbcod  and
                       bpedid.pedtdc = bliped.pedtdc and
                       bpedid.peddat = vdat-entrega  and
                       bpedid.modcod = "PEDO"
                       no-lock no-error.
                if avail bpedid 
                then vok = no.
            end.
        end.
        if vok = no
        then ventrega-out = ventrega-out + com.liped.lipqtd.
    end.  
end procedure.

procedure pro-no-mix:
for each tabmix where tabmix.tipomix = "M" and
                      tabmix.codmix  = c-tabmix.codmix no-lock:
    find first e-tabmix where e-tabmix.tipomix = "F" and
                       e-tabmix.codmix  = tabmix.codmix and
                       e-tabmix.promix  = produ.clacod and
                       e-tabmix.campodat1 <= today
                       no-lock no-error.
    if avail e-tabmix                        
    then do:
         find p-tabmix where p-tabmix.tipomix = "P" and
                             p-tabmix.codmix  = e-tabmix.codmix and
                             p-tabmix.promix  = produ.procod
                             no-lock no-error.
         if avail p-tabmix
         then do:
            if p-tabmix.qtdmix = 0 and
               p-tabmix.mostruario = no and
              (e-tabmix.campodat1 + e-tabmix.campoint1) <= today
            then p-no-mix = no.
            else p-no-mix = yes.
        end.
    end.
    if p-no-mix then leave.
end.
end procedure. 
