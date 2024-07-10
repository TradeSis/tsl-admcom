/* connect crm -H "sv-mat-db1" -S sdrebcrm -N tcp -ld crm no-error. */
{/u/bsweb/progr/acha.i}

def input param v-clicod as int.

def var vnome as char.

def shared temp-table ttbonus
    field numero_bonus as char
    field etbcod as int
    field nome_bonus as char
    field venc_bonus as date
    field vlr_bonus as dec.

def temp-table ttetb
    field etbcod as int.

if v-clicod = 1
then do:
    create ttbonus.
    ttbonus.nome_bonus = "".
    ttbonus.numero_bonus = "".
    ttbonus.venc_bonus = 01/01/1900.
    ttbonus.vlr_bonus = 0.
    return.
end.
           
for each estab no-lock.    
    create ttetb.
    ttetb.etbcod = estab.etbcod.
end.
create ttetb.
ttetb.etbcod = 0.
    
for each ttetb no-lock.
    for each titulo where 
            titulo.empcod = 19        and 
            titulo.titnat = yes       and 
            titulo.modcod = "BON"     and 
            titulo.titdtpag = ? and
            titulo.clifor = v-clicod and
            titulo.titsit = "LIB" and
            titulo.etbcod = ttetb.etbcod and
            titulo.titdtven >= today /*** 28.12.2016 ***/
            no-lock . 

        create ttbonus.
        ttbonus.etbcod = titulo.etbcod.
        ttbonus.venc_bonus = titulo.titdtven.
        ttbonus.vlr_bonus  = titulo.titvlcob.
        ttbonus.numero_bonus = titulo.titnum.
            
        if titulo.titobs[1] <> "" 
        then do: 
            find acao where acao.acaocod = int(titulo.titobs[1])
                      no-lock no-error. 
            if avail acao 
            then ttbonus.nome_bonus = acao.descricao. 
        end.
        else if titulo.titobs[2] <> ""
        then do.
            vnome = acha("bonus", titulo.titobs[2]).
            if vnome <> ?
            then ttbonus.nome_bonus = vnome.
         end.
    end.
end.

find first ttbonus no-lock no-error.
if not avail ttbonus
then do:
    create ttbonus.
    ttbonus.nome_bonus = "".
    ttbonus.numero_bonus = "".
    ttbonus.venc_bonus = 01/01/1900.
    ttbonus.vlr_bonus  = 0.
end.

