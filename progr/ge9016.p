def input parameter par-arquivo as char.
def input parameter par-dtini   as date.
def input parameter par-dtfim   as date.
def var vdg as char.

{/admcom/progr/cntgendf.i}
find first tbcntgen where tbcntgen.tipcon = 9016 no-lock no-error.
if not avail tbcntgen  or 
    (tbcntgen.validade <> ? and
     tbcntgen.validade < today)
then do:
    message "Controle para DG nao cadastrado ou desativado".
    pause 0.
    return.
end.


def buffer npedid for pedid.

def temp-table tt-pedid
    field pednum like pedid.pednum
    field peddat like pedid.peddat
    field forcod like pedid.clfcod
    field fornom like forne.fornom
    field peddti like pedid.peddti
    field peddtf like pedid.peddtf
    field qtdped as dec
    field qtdpen as dec
    field especial as int
    field etbcod like pedid.etbcod
    field compra as char
    field situacao as char
    field npednum like pedid.pednum
    index i1 situacao .
def var vesp as int.    
def var vped as int.
def var vpen as int.
def var vcomp as character.

for each pedid where pedid.pedtdc = 1 and 
         pedid.etbcod = 999 and 
         pedid.sitped = "A" and pedid.peddat >= today - 365
         :

    if pedid.peddti <= today - 365 then next.
    if pedid.peddtf >= today + 15 then next.
      
    find first npedid where 
                npedid.etbcod = 999 and
               (npedid.pedtdc = 4 or
                npedid.pedtdc = 6) and
                /*npedid.pedsit = yes and*/
                npedid.comcod = pedid.pednum
                no-lock no-error.
    if avail npedid
    then next.

/*
    if today - pedid.peddtf > 32
    then do transaction:
        pedid.sitped = "F".
    end.
  */

    
    if pedid.sitped = "F"
    then next.
    
    assign vcomp = "".
    
    release compr.
    find first compr where compr.comcod = pedid.comcod no-lock no-error.
    
    if avail compr
    then vcomp = caps(string(compr.comnom,"x(01)")).
    vesp = 0.
    vped = 0.
    vpen = 0.
    for each liped of pedid no-lock .
        find produ where produ.procod = liped.procod no-lock no-error.
        if not avail produ then next.
        if produ.catcod >= 41
        then next.
        if produ.proipival > 0 and vesp < 1  then
        vesp = vesp + 1.


        vped = vped + liped.lipqtd.
        vpen = vpen + (liped.lipqtd - liped.lipent).    
    end. 
    if vped = 0 then next.
    
        find first forne where 
        forne.forcod = pedid.clfcod no-lock NO-ERROR.
        if not avail forne
        then next.
        
    create tt-pedid.
    assign
        tt-pedid.pednum = pedid.pednum
        tt-pedid.peddat = pedid.peddat
        tt-pedid.forcod = pedid.clfcod
        tt-pedid.fornom = forne.forfant
        tt-pedid.peddti = pedid.peddti
        tt-pedid.peddtf = pedid.peddtf
        tt-pedid.qtdped = vped
        tt-pedid.qtdpen = vpen
        tt-pedid.especial = vesp
        tt-pedid.etbcod = pedid.etbcod
        tt-pedid.compra = vcomp
        tt-pedid.npednum = pedid.comcod 
        .
    if today - tt-pedid.peddti <= 10
    then tt-pedid.situacao = "Vencer".
    else tt-pedid.situacao = "Vencido". 
         
end.

vdg = "9016".
output to value(par-arquivo) append.  



for each tt-pedid where tt-pedid.situacao = "Vencido":
    put unformatted
        par-dtini ";"
        vdg ";"
        tt-pedid.pednum       "|"
        tt-pedid.npednum      "|"
        tt-pedid.forcod    "|"
        tt-pedid.fornom    "|"
                            /*"<TD>" npedid.peddti format "99/99/9999" " a " */
        tt-pedid.peddtf    "|"
        today - tt-pedid.peddtf "|" tt-pedid.especial 
        skip.

end.
output close.




/***************************





vdg = "9016".
output to value(par-arquivo) append.  
def buffer npedid for pedid.
for each pedid where pedtdc = 6 and 
    pedid.peddat >= par-dtini - (30 * 6) and
    sitped = "P" and comcod <> 0 no-lock,
    first npedid where npedid.pedtdc = 1 and
                      npedid.etbcod = 999 and
                      npedid.pednum = pedid.comcod
                      no-lock by npedid.peddti.
    if not avail npedid
    then next. 
    if npedid.sitped = "F"
    then.
    else next. 

    /* a regra era esta 
    if npedid.peddtf >= today  and
        npedid.peddtf - today <= 3
    then do:
    */
    
    if npedid.peddtf <  par-dtini
    then do:

    

    find first forne where forne.forcod = npedid.clfcod no-lock NO-ERROR.
    if not avail forne
    then next.
    
    put unformatted
        par-dtini ";"
        vdg ";"
        pedid.pednum       "|"
        npedid.pednum      "|"
        forne.forcod       "|"
        forne.fornom       "|"
                            /*"<TD>" npedid.peddti format "99/99/9999" " a " */
        npedid.peddtf      "|"
        today - npedid.peddtf 
        skip.
    end.
end.
output close.[A


****************************/
