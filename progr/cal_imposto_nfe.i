assign
    fre-item = 0
    vbc-item = 0
    icm-item = 0
    .
    
if tt-plani.frete > 0
then do:
    fre-item = tt-plani.frete * 
        ((tt-movim.movqtm * tt-movim.movpc) / tt-plani.protot)  .
end.
if produ.proipiper = 99 and
    fre-item > 0
then assign
         vbc-item = fre-item
         ali-item = 17
         icm-item = vbc-item * (ali-item / 100).
else assign         
        vbc-item = fre-item + (tt-movim.movqtm * tt-movim.movpc)
        ali-item = tt-movim.movalicms
        icm-item = vbc-item * (tt-movim.movalicms / 100).

assign
    tt-movim.movicms = icm-item
    vbc-total = vbc-total + vbc-item
    icm-total = icm-total + icm-item
    .
    

