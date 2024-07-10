

def temp-table tt_Prof_1775
    like Prof_1775.
    
def var v as int.
def var par-arq as char format "x(70)".
def var vdir as char init "/admcom/tmp/itim/output/".
def var varq as char format "x(30)".
update varq.
par-arq = vdir + varq. .
update par-arq.
disp par-arq.


    
input from value(par-arq).
repeat.
    create tt_Prof_1775.
    import delimiter "|" tt_Prof_1775.
    v = v + 1.
end.

for each tt_Prof_1775.
    find first Prof_1775 
        where Prof_1775.BRAND_PRICE_IMAGE_ID = tt_Prof_1775.BRAND_PRICE_IMAGE_ID
        no-lock no-error.
    
    if not avail Prof_1775
    then do:
        create Prof_1775.
        buffer-copy tt_Prof_1775 to Prof_1775.
    end.
    delete tt_Prof_1775.
end.
for each Prof_1775.
disp Prof_1775.
end.