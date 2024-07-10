


def temp-table tt-tit like titulo.
def var ii as int.
def var vv as int.

input from /ctb-dados/titant.d.
repeat:

    vv = vv + 1.
    if vv <= 640000
    then next.
    
    for each tt-tit:
        delete tt-tit.
    end.
         
    create tt-tit.
    import tt-tit.
    
    find titulo where titulo.empcod = tt-tit.empcod and
                      titulo.titnat = tt-tit.titnat and
                      titulo.modcod = tt-tit.modcod and
                      titulo.etbcod = tt-tit.etbcod and
                      titulo.clifor = tt-tit.clifor and
                      titulo.titnum = tt-tit.titnum and
                      titulo.titpar = tt-tit.titpar no-error.
    if not avail titulo
    then do:
    
        create titulo.
        buffer-copy tt-tit to titulo.
        
    end.
    
    ii = ii + 1.
    
    if ii mod 5000 = 0
    then display ii with 1 down. pause 0.
    
end.
input close.
        
                       
                       
         
         
