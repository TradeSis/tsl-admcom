{/admcom/progr/admbatch.i new}

output to baixalp.log.
put "Conectando" skip.
output close.

connect banfin -H erp.lebes.com.br -S sbanfin -N tcp -ld banfin
no-error.

connect dragao -N tcp -S sdragao -H "erp.lebes.com.br" -ld d
no-error. 

def var vpropath as char format "x(50)".
input from /admcom/propath1 no-echo.  /* Seta Propath */
set vpropath with width 200 no-box frame ff.
input close.
propath = vpropath .

run baixalp.p.

output to baixalp.log append.
put "Desconectando" skip.
output close.

disconnect d.

disconnect banfin.

