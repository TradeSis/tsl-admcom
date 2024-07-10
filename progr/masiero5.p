def var vdat as date format "99/99/9999".
def var i as i.
def var iexp as i.
for each estab no-lock:

    i = 0.
    iexp = 0.
    
    do vdat = 01/01/2002 to today:

        for each titulo where titulo.empcod = 19 and
                              titulo.titnat = no and
                              titulo.modcod = "CRE" and
                              titulo.titdtpag = vdat and
                              titulo.etbcod = estab.etbcod no-lock.

            if titulo.etbcobra <> titulo.etbcod
            then iexp = iexp + 1.
            
            i = i + 1.
                
            disp estab.etbcod vdat i iexp with 1 down. pause 0.
        
        end.

    end.
end.