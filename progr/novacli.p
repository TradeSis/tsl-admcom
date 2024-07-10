{admcab.i new}

def var i as int.
def var varquivo as char.
def var vtem as log.

def var vdtini as date.
def var vdtfin as date.

def temp-table tt-dados
    field clicod like clien.clicod
        index ind01 clicod.
        
/***
update vdtini label "Periodo" vdtfin no-label with frame f-escolhe side-labels.
***/

for each tt-dados.
    delete tt-dados.
end.    

i = 0.
for each estab no-lock.
    for each clien no-lock.
        vtem = no.
        for each titulo where titulo.titnat = no
                          and titulo.modcod = "CRE"
                          and titulo.titsit = "LIB"
                          and titulo.clifor = clien.clicod
                          /***
                          and titulo.titdtemi >= vdtini
                          and titulo.titdtemi <= vdtfin
                          ***/
                          and titulo.etbcod = estab.etbcod no-lock.

            if titulo.titpar < 31
            then next.
            
            vtem = yes.
            leave.
        
        end.
        hide message no-pause.
        message clien.clicod.

        if vtem = yes
        then do:

            find first tt-dados where tt-dados.clicod = clien.clicod no-error.
            if not avail tt-dados
            then do:
                create tt-dados.
                tt-dados.clicod = clien.clicod.
                i = i + 1.
                if i mod 1000 = 0
                then do:
                    hide message no-pause.
                    message i " Registros Lidos".
                end.        
            end.
    
        end.
    end.
end.