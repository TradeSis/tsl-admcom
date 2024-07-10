

def temp-table tt_Prof_1701
    like Prof_1701.
    
def var v as int.
def var par-arq as char.
update par-arq.
input from value(par-arq).
repeat.
    create tt_Prof_1701.
    import delimiter "|" tt_Prof_1701.
    v = v + 1.
end.

for each tt_Prof_1701.
    find first Prof_1701 
        where Prof_1701.PRICE_KEY = tt_Prof_1701.PRICE_KEY
        no-lock no-error.
    
    if not avail Prof_1701
    then do:
        create Prof_1701.
        buffer-copy tt_Prof_1701 to Prof_1701.
    end.
    delete tt_Prof_1701.
end.