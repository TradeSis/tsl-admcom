
def temp-table tt_Prof_1720
    like Prof_1720.
    
def var v as int.
def var par-arq as char.
update par-arq.
input from value(par-arq).
repeat.
    create tt_Prof_1720.
    import delimiter "|" tt_Prof_1720.
    v = v + 1.
end.

for each tt_Prof_1720.
    find first Prof_1720 
        where Prof_1720.OFFER_ID = tt_Prof_1720.OFFER_ID
          and Prof_1720.PROD_ID  = tt_Prof_1720.PROD_ID
          and Prof_1720.STORE_ID = tt_Prof_1720.STORE_ID
        no-lock no-error.
    
    if not avail Prof_1720
    then do:
        create Prof_1720.
        buffer-copy tt_Prof_1720 to Prof_1720.
    end.
    delete tt_Prof_1720.
end.