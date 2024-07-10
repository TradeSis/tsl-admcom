{/var/www/drebes/progress/admcab.i new}

def var vsequencia like ctpromoc.sequencia.
def var vdata as date.
vdata = date(SESSION:PARAMETER).

message vdata.

if vdata = ?   then undo.
run /var/www/drebes/progress/etqpromov-31.p(vsequencia, vdata).




