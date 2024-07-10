def temp-table tt_Prof_1504
    like Prof_1504.
     
def  var v as int.
def var par-arq as char format "x(70)".
def var vdir as char init "/admcom/tmp/itim/output/".
def var varq as char format "x(30)".
update varq.
par-arq = vdir + varq. .
update par-arq.
disp par-arq.

input from value(par-arq).
repeat.
    create tt_Prof_1504.
    import delimiter "|" tt_Prof_1504.
    v = v + 1.
end.

for each tt_Prof_1504.
    find first Prof_1504 where Prof_1504.EVENT_ID = tt_Prof_1504.EVENT_ID
        no-lock no-error.
    
    if not avail Prof_1504
    then do:
        create Prof_1504.
        buffer-copy tt_Prof_1504 to Prof_1504.
    end.
    delete tt_Prof_1504.
end.

for each Prof_1504.
disp Prof_1504 except EVENT_DESC. pause 0.
end.