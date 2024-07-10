def input param pclicod as int. 
def input param ptabini as char.
def input param pidstatuscad as int.

def var vchar as char.        

    if ptabini <> ""
    then do:
        run le_tabini.p (0, 0, ptabini, OUTPUT vchar).
        if vchar <> ?
        then pidstatuscad = int(vchar).
    end.
    
    find clien where clien.clicod = pclicod exclusive no-wait no-error.

    if avail clien
    then do:
        find last clienstahist where 
                clienstahis.clicod = clien.clicod and
                clienstahist.dataalt = today and 
                clienstahist.horaalt = time
          no-lock  no-error.
        if avail clienstahist
        then do:
            pause 1 no-message.
        end.
        create clienstahist.
        clienstahis.clicod = clien.clicod.
        clienstahist.dataalt = today.
        clienstahist.horaalt = time.
        clienstahist.idstatuscad-antigo = clien.idstatuscad.
        clienstahist.idstatuscad-novo = pidstatuscad.
        clien.idstatuscad             = pidstatuscad.
    
        if ptabini = "STATUSCAD_FALECIDO"    
        then do:
            clien.falecido = yes.
        end.
    end.