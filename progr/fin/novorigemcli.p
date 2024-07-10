/* acha contratos com novacao do cliente */ 
{admcab.i}

def input param par-clicod  like contrato.clicod.


def new shared temp-table ttcontrato
    field contnum   like contrato.contnum
    index x is unique primary contnum asc.


for each contrato where contrato.clicod = par-clicod no-lock.
    create ttcontrato.
    ttcontrato.contnum = contrato.contnum.
end.

run fin/fqanadocorinov.p ("Origem",yes).



