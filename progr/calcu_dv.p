def input parameter p-tipo as char.
def input parameter p-numero as char format "x(12)".
def output parameter p-digito as int.

if p-tipo = "MOD10"
then run dvmod10.p(input p-numero, output p-digito).
else if p-tipo = "MOD11"
    then run dvmod11.p(input p-numero, output p-digito).
    
    
