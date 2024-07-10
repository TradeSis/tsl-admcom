def var vpagas as int.
def var i as int.

def temp-table tt-pagas
    field clicod like clien.clicod
    field pagas as int
    index ind01 clicod.

for each tt-pagas.
    delete tt-pagas.
end.

i = 0.
for each clilig no-lock.

    if clilig.clicod = 1
    then next.
    
    /***
    hide message no-pause.
    message 111 clilig.clicod.

    ***/
    /* Cliente Novo */
    vpagas = 0.    
    for each titulo where titulo.titnat = no
                      and titulo.clifor = clilig.clicod
                      and titulo.titdtpag <> ?
                      and titulo.titsit = "PAG"
                          no-lock.
            if titulo.modcod = "DEV" or
               titulo.modcod = "BON" or
               titulo.modcod = "CHP"
            then next.                          
        vpagas = vpagas + 1.
        /***
        hide message no-pause.
        message 222 vpagas titulo.clifor titulo.titnum titulo.titpar.
        ***/
     end.
     
     find first tt-pagas where tt-pagas.clicod = clilig.clicod no-error.
     if not avail tt-pagas
     then do:
        create tt-pagas.
        tt-pagas.clicod = clilig.clicod.
        tt-pagas.pagas = vpagas.
        i = i + 1.
        /***
        hide message no-pause.
        message 333 i tt-pagas.clicod tt-pagas.pagas.
        ***/
     end.
                
    /**/                
end.

for each tt-pagas.
    find first clilig where clilig.clicod = tt-pagas.clicod exclusive-lock.
    
    if tt-pagas.pagas <= 30
    then clilig.tipo = "N".
    else clilig.tipo = "".
    
end.
