

def temp-table tt_Prof_1776
    like Prof_1776.
    
def var v as int.
def var par-arq as char.
update par-arq.
input from value(par-arq).
repeat.
    create tt_Prof_1776.
    import delimiter "|" tt_Prof_1776.
    v = v + 1.
end.

for each tt_Prof_1776.
    find first Prof_1776 
        where Prof_1776.BRAND_PRICE_IMAGE_ID = tt_Prof_1776.BRAND_PRICE_IMAGE_I
          and Prof_1776.MERCH_LEVEL          = tt_Prof_1776.MERCH_LEVEL
          and Prof_1776.MERCH_LEVEL_ID       = tt_Prof_1776.MERCH_LEVEL_ID
        no-lock no-error.

    if not avail Prof_1776
    then do:
        create Prof_1776.
        buffer-copy tt_Prof_1776 to Prof_1776.
    end.
    delete tt_Prof_1776.
end.