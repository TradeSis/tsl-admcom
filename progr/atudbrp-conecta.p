def input parameter p-banco as char.
def input parameter p-processo as char.
def output parameter p-ok as log.

def shared var vlog as char.

def var i as int init 0.


output to value(vlog) append.
put string(time,"HH:MM:SS") + " " + p-processo format "x(25)"
                " - Conectando Banco " + p-banco  format "x(30)" skip.
output close.

if p-banco = "COM"
then repeat:
    connect com -H dbrp -S sdrebcom_h -N tcp -ld comdbrp.
    if not connected ("comdbrp")
    then do:
        if i = 3
        then leave.
        i = i + 1.
        next.
    end.
    else do:
        p-ok = yes.
        leave.
    end.
end.
else if p-banco = "FIN"
then repeat:
    connect fin -H dbrp -S sdrebfin_h -N tcp -ld findbrp.
        
    if not connected ("findbrp")
    then do:
        if i = 5
        then leave.
        i = i + 1.
        next.
    end.
    else do:
        p-ok = yes.
        leave.
    end.
end.
else if p-banco = "GER"
then repeat:
        
    connect ger -H dbrp -S sdrebger_h -N tcp -ld gerdbrp.
   
    if not connected ("gerdbrp")
    then do:
        if i = 5
        then leave.
        i = i + 1.
        next.
    end.
    else do:
        p-ok = yes.
        leave.
    end.
end.
else if p-banco = "ADM"
then repeat:
        
    connect adm -H dbrp -S sdrebadm_h -N tcp -ld admdbrp.
    if not connected ("admdbrp")
    then do:
        if i = 5
        then leave.
        i = i + 1.
        next.
    end.
    else do:
        p-ok = yes.
        leave.
    end.
end.
else if p-banco = "DRAGAO"
then repeat:
        
    connect dragao -H dbrp -S sdragao_h -N tcp -ld dradbrp.
   
    if not connected ("dradbrp")
    then do:
        if i = 5
        then leave.
        i = i + 1.
        next.
    end.
    else do:
        p-ok = yes.
        leave.
    end.
end.
else if p-banco = "BANFIN"
then repeat:
   
    connect banfin -H dbrp -S sbanfin_h -N tcp  -ld bandbrp.    
   
    if not connected ("bandbrp")
    then do:
        if i = 5
        then leave.
        i = i + 1.
        next.
    end.
    else do:
        p-ok = yes.
        leave.
    end.
end.
else if p-banco = "SUPORTE"
then repeat:
   
    connect suporte -H dbrp -S sdrebsup_h -N tcp -ld supdbrp.
   
    if not connected ("supdbrp")
    then do:
        if i = 5
        then leave.
        i = i + 1.
        next.
    end.
    else do:
        p-ok = yes.
        leave.
    end.
end.





