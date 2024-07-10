{admcab.i}

def var i as int.

def temp-table tt-titulo
    field etbcod like titulo.etbcod
    field clifor like titulo.clifor
    field titnum like titulo.titnum
    field titpar like titulo.titpar
    field rectit as recid
        index ind01 clifor titnum titpar
        index ind02 rectit.
        
def temp-table tt-estab
    field etbcod like estab.etbcod
    field etbcodtot as int
    field etbcodval as dec format ">>>,>>>,>>9.99"
    field clifortot as int
    field cliforval as dec format ">>>,>>>,>>9.99"
    field contratot as int
    field contraval as dec format ">>>,>>>,>>9.99"
    field parceltot as int
    field parcelval as dec format ">>>,>>>,>>9.99".

for each tt-titulo.
    delete tt-titulo.
end.    

for each tt-estab.
    delete tt-estab.
end.    

i = 0.
for each estab no-lock.
for each titulo where titulo.titnat = no
                  and titulo.modcod = "CRE"
                  and titulo.titsit = "LIB"
                  and titulo.etbcod = estab.etbcod no-lock.
                  
                  
    if titulo.titpar < 31
    then next.
    
    find first tt-titulo where tt-titulo.rectit = recid(titulo) no-error.
    if not avail tt-titulo
    then do:
        create tt-titulo.
        tt-titulo.rectit = recid(titulo).
        tt-titulo.etbcod = titulo.etbcod.
        tt-titulo.clifor = titulo.clifor.
        tt-titulo.titnum = titulo.titnum.
        tt-titulo.titpar = titulo.titpar.
        i = i + 1.
        if i mod 100 = 0
        then do:
            hide message no-pause.
            message i tt-titulo.etbcod tt-titulo.clifor tt-titulo.titnum tt-titulo.titpar.
        end.
    end.
    
end.    
end.

for each tt-titulo break by tt-titulo.etbcod
                         by tt-titulo.clifor
                         by tt-titulo.titnum
                         by tt-titulo.titpar.
                         
    find titulo where recid(titulo) = tt-titulo.rectit no-lock.
                   
    find first tt-estab where tt-estab.etbcod = tt-titulo.etbcod
        no-error.
    if not avail tt-estab
    then do:
        create tt-estab.
        tt-estab.etbcod = tt-titulo.etbcod.
    end.
    tt-estab.etbcodtot = tt-estab.etbcodtot + 1.
    tt-estab.etbcodval = tt-estab.etbcodval + titulo.titvlcob.
    
    if first-of(tt-titulo.clifor)
    then do:
        tt-estab.clifortot = tt-estab.clifortot + 1.
        tt-estab.cliforval = tt-estab.cliforval + titulo.titvlcob.
    end.

    if first-of(tt-titulo.titnum)
    then do:
        tt-estab.contratot = tt-estab.contratot + 1.
        tt-estab.contraval = tt-estab.contraval + titulo.titvlcob.
    end.    
    
    tt-estab.parceltot = tt-estab.parceltot + 1.
    tt-estab.parcelval = tt-estab.parcelval + titulo.titvlcob.    
    
end.

for each tt-estab.
    disp tt-estab.
end.
