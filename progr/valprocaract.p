def input parameter p-procod like produ.procod.
def input parameter p-carcod like caract.carcod.
def input parameter p-subcod like subcaract.subcod.
def output parameter p-retorno as log.

p-retorno = no.

def buffer n-produ for produ.

if p-procod > 0
then do:
    find first n-produ where n-produ.procod = p-procod no-lock. 
    if p-subcod > 0
    then do:
        for each subcaract where
                 subcaract.subcar = p-subcod and
                 subcaract.carcod = p-carcod no-lock:
            find first procaract where
                       procaract.procod = n-produ.procod and
                       procaract.subcod = subcaract.subcar
                       no-lock no-error.
            if avail procaract
            then do:
                p-retorno = yes.           
                leave.
            end.    
        end.
    end.
    else if p-carcod > 0
    then do:
        for each subcaract where
                 subcaract.carcod = p-carcod no-lock:
            find first procaract where
                       procaract.procod = n-produ.procod and
                       procaract.subcod = subcaract.subcar
                       no-lock no-error.
            if avail procaract
            then do:
                p-retorno = yes.
                leave.
            end.
        end.                   
    end.

end.        


