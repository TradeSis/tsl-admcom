def input parameter p-s as char.
def output parameter p-ok as log.

p-ok = yes.

if length(p-s) <> 8  and
   length(p-s) <> 11 and
   length(p-s) <> 15 and
   length(p-s) <> 18
then p-ok = no.
else  
    if  substr(p-s,1,1) <> "0" and
        substr(p-s,1,1) <> "1" and
        substr(p-s,1,1) <> "2" and
        substr(p-s,1,1) <> "3" and
        substr(p-s,1,1) <> "4" and
        substr(p-s,1,1) <> "5" and
        substr(p-s,1,1) <> "6" and
        substr(p-s,1,1) <> "7" and
        substr(p-s,1,1) <> "8" and
        substr(p-s,1,1) <> "9" 
    then p-ok = no.
    else 
        if  substr(p-s,2,1) <> "0" and
            substr(p-s,2,1) <> "1" and
            substr(p-s,2,1) <> "2" and
            substr(p-s,2,1) <> "3" and
            substr(p-s,2,1) <> "4" and
            substr(p-s,2,1) <> "5" and
            substr(p-s,2,1) <> "6" and
            substr(p-s,2,1) <> "7" and
            substr(p-s,2,1) <> "8" and
            substr(p-s,2,1) <> "9" 
        then p-ok = no.

   
def var v1 as int init 0.
def var v2 as int init 0.
def var v3 as char init "".
def var v4 as char init "".
v3 = substr(p-s,1,1).
do v1 = 1 to 8:
    v4 = substr(p-s,v1,1).
    if v4 = v3
    then v2 = v2 + 1.
end.

if v2 > 4
then p-ok = no.

