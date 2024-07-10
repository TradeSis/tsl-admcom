def  var v as int.
def var par-arq as char format "x(70)".
def var vdir as char init "/admcom/tmp/itim/output/".
def var varq as char format "x(30)".
update varq.
par-arq = vdir + varq. .
update par-arq.
disp par-arq.

def temp-table tt_Prof_1521
    like Prof_1521.
    
input from value(par-arq).
repeat transaction.
    create tt_Prof_1521.
    import delimiter "|" tt_Prof_1521.
    v = v + 1.
end.

for each tt_Prof_1521.
    find first Prof_1521 
        where Prof_1521.SUB_EVENT_ID = tt_Prof_1521.SUB_EVENT_ID
        no-lock no-error.
    
    if not avail Prof_1521
    then do:
        create Prof_1521.
        buffer-copy tt_Prof_1521 to Prof_1521.
    end.
    delete tt_Prof_1521.
end.

for each Prof_1521 .
disp Prof_1521 except SUB_EVENT_DESC. pause 0.
end.
