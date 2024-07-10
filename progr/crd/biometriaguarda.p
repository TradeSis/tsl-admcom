def input param pclicod as int.
def input param pidbiometria as char.
def var vtoday as date.
def var vtime  as int.
vtoday = today.
vtime  = time.

find last clibiometria where clibiometria.clicod = pclicod and
                        clibiometria.data   = vtoday   
        no-lock no-error.
if avail clibiometria
then do:
    if clibiometria.idbiometria = pidbiometria
    then return.
end.
find clibiometria where clibiometria.clicod = pclicod and
                        clibiometria.data   = vtoday   and
                        clibiometria.hora   = vtime
    exclusive-lock no-wait no-error.                        
if not avail clibiometria 
then do:
    create clibiometria.
    clibiometria.clicod = pclicod.
    clibiometria.data   = vtoday.
    clibiometria.hora   = vtime.
end.    
    
if avail clibiometria
then do:
    clibiometria.idbiometria = pidbiometria.
end.
    
