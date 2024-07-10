def temp-table tt_Prof_1770
    like Prof_1770.
    
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
    create tt_Prof_1770.
    import delimiter "|" tt_Prof_1770.
    v = v + 1.
end.

for each tt_Prof_1770.
    find first Prof_1770 where Prof_1770.SKU_ID = tt_Prof_1770.SKU_ID
        no-lock no-error.
    
    if not avail Prof_1770
    then do:
        create Prof_1770.
        buffer-copy tt_Prof_1770 to Prof_1770.
    end.
    delete tt_Prof_1770.
end.
for each Prof_1770.
disp Prof_1770. pause 0.
end.