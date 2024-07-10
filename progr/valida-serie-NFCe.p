def input parameter p-serie like plani.serie.
def input parameter p-ufemi like plani.ufemi.
def input parameter p-notped like plani.ufdes.
def output parameter p-sresp as log init no.
def var vi as int.
if substr(p-serie,1,1) = "V"
then p-sresp = no.
else if p-serie = "3"
then p-sresp = yes.
else do vi = 30 to 99:
        if p-serie = string(vi)
        then do:
            p-sresp = yes.
            leave.
        end.
    end.
if substr(p-ufemi,1,1) = "B" or
   substr(p-ufemi,1,1) = "E" or
   num-entries(p-notped,"|") > 1
then p-sresp = no.
    
