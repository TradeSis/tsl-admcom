
def input parameter p-etbcod like estab.etbcod.
def input parameter p-pedtdc like com.pedid.pedtdc.
def output parameter p-ok as log.

def buffer mpedid for com.pedid.
def buffer lpedid for comloja.pedid.

disable triggers for load of comloja.pedid.
def var vpednum as int.

vpednum = int(string(p-etbcod,"999") + "000001").

p-ok = no.

if p-pedtdc <> 6
then do.
    find last mpedid where
          mpedid.etbcod = p-etbcod and
          mpedid.pedtdc = p-pedtdc 
          no-lock no-error.
    if avail mpedid
    then do:
        find last lpedid where
              lpedid.etbcod = p-etbcod and
              lpedid.pedtdc = p-pedtdc 
              no-lock no-error.
    
        if not avail lpedid or
           lpedid.pednum < mpedid.pednum
        then do:
            create comloja.pedid.
            buffer-copy mpedid to comloja.pedid.
            p-ok = yes.
        end.
    end.
end.
else do.
    find last mpedid where
          mpedid.etbcod = p-etbcod and
          mpedid.pedtdc = p-pedtdc and
          mpedid.pednum < vpednum
          no-lock no-error.
    if avail mpedid
    then do:
        find last lpedid where
              lpedid.etbcod = p-etbcod and
              lpedid.pedtdc = p-pedtdc and
              lpedid.pednum < vpednum
              no-lock no-error.
    
        if not avail lpedid or
           lpedid.pednum < mpedid.pednum
        then do:
            create comloja.pedid.
            buffer-copy mpedid to comloja.pedid.
            p-ok = yes.
        end.
    end.
end.

