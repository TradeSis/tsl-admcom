{admcab.i }.

def var vdata as date .
def var vfuncod like func.funcod.
def buffer sfunc for func.

update vdata vfuncod.

for each correio where correio.funcod = vfuncod 
    and correio.dtmens >= vdata
    and correio.situacao <> "E" 
    and correio.situacao <> "L" : 
    find first sfunc where sfunc.funcod = correio.funemi no-lock.
    clear frame f-qa  all.
    disp                                                    
        correio.situacao 
        skip
         correio.funemi 
         skip
         sfunc.funape
         skip
         correio.assunto 
         skip
         correio.dtmens
         with frame f-qa 
            column 25  row 4
            3 columns side-labels.    pause 2.
         
    disp
            correio.mens[1] correio.mens[2] correio.mens[3] 
            correio.mens[4]
                correio.mens[5] correio.mens[6] correio.mens[7] correio.mens[8]
                correio.mens[9] correio.mens[10] correio.mens[11] 
                correio.mens[12]  with frame f-linha centered
                    1 down no-labels title "MENSAGEM" row 12.
    update correio.situacao with frame f-qa.

end.    
    