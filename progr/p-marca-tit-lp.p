{admcab.i}

def input parameter par-etbcod     as integer.

def buffer bf-titulo for fin.titulo.

def var v-tem-parc-31 as logical.
def var v-tem-parc-51 as logical.

for each fin.titulo where fin.titulo.etbcod = par-etbcod
                      and fin.titulo.modcod = "CRE"
                      and fin.titulo.titnat = false
                         no-lock.

    if fin.titulo.titpar > 0 and fin.titulo.titpar <= 50
    then next.
    
    if acha("RENOVACAO",fin.titulo.titobs[1]) = "SIM" then next.

    assign v-tem-parc-31 = no
           v-tem-parc-51 = no.
    
    release bf-titulo.
    find first bf-titulo where bf-titulo.empcod = titulo.empcod
                           and bf-titulo.titnat = titulo.titnat
                           and bf-titulo.modcod = titulo.modcod
                           and bf-titulo.etbcod = titulo.etbcod
                           and bf-titulo.CliFor = titulo.CliFor
                           and bf-titulo.titnum = titulo.titnum
                           and bf-titulo.titdtemi = titulo.titdtemi
                           and bf-titulo.titpar = 31
                                     no-lock no-error.
                                     
    if avail bf-titulo
    then v-tem-parc-31 = yes.
    

    release bf-titulo.
    find first bf-titulo where bf-titulo.empcod = titulo.empcod
                           and bf-titulo.titnat = titulo.titnat
                           and bf-titulo.modcod = titulo.modcod
                           and bf-titulo.etbcod = titulo.etbcod
                           and bf-titulo.CliFor = titulo.CliFor
                           and bf-titulo.titnum = titulo.titnum
                           and bf-titulo.titdtemi = titulo.titdtemi
                           and bf-titulo.titpar = 51
                                     no-lock no-error.
                                     
    if avail bf-titulo
    then v-tem-parc-51 = yes.
            
    if v-tem-parc-31 = no and v-tem-parc-51 = yes
    then run p-grava-obs-titnum (input rowid(fin.titulo)).

            
end.




procedure p-grava-obs-titnum:

    def input parameter p-rowid-titulo as rowid.
    
    def buffer aj-titulo for fin.titulo.
    
    
    find first aj-titulo
         where rowid(aj-titulo) = p-rowid-titulo
                exclusive-lock no-wait no-error.
    
    if avail aj-titulo
    then do:
    
        if trim(aj-titulo.titobs[1]) = ""
        then do:

           assign aj-titulo.titobs[1] = "RENOVACAO=SIM|". 
                    
        end.
        else do:
    
            if substring(string(length(trim(aj-titulo.titobs[1]))),1) = "|"
            then assign aj-titulo.titobs[1]
                          = aj-titulo.titobs[1] +  "RENOVACAO=SIM|".
            else assign aj-titulo.titobs[1]
                          = aj-titulo.titobs[1] + "|RENOVACAO=SIM|".

        end.
    
    end.

end procedure.