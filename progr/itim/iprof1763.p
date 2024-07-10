

def temp-table tt_Prof_1763
    like Prof_1763.
    
def var v as int.
def var par-arq as char.
update par-arq.
input from value(par-arq).
repeat.
    create tt_Prof_1763.
    import delimiter "|" tt_Prof_1763.
    v = v + 1.
end.

for each tt_Prof_1763.
    find first Prof_1763 where Prof_1763.OFFER_ID = tt_Prof_1763.OFFER_ID
                           and Prof_1763.PLAN_ID  = tt_Prof_1763.PLAN_ID
        no-lock no-error.
    
    if not avail Prof_1763
    then do:
        create Prof_1763.
        buffer-copy tt_Prof_1763 to Prof_1763.
    end.
    delete tt_Prof_1763.
end.