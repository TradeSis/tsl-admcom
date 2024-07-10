{admcab.i new}

def var filial as int.
def var dtini as date init today.
def var dtfim as date init today.
def var vpagas as int.
def var ult-compra like plani.pladat.

/* Formulario */
form filial label "Filial"
     dtini label "Data inicial"
     dtfim label "Data final"
with frame f01 title "Informe os dados abaixo:" with 1 col width 80.

/* Atualiza a variavel */
update filial
       dtini
       dtfim
with frame f01.

find clien where clien.clicod = contrato.clicod no-lock.

for each contrato where contrato.clicod = clien.clicod no-lock by contrato.dtinicial.
ult-compra = contrato.dtinicial.
end.

disp contrato.etbcod contrato.clicod contrato.contnum contrato.dtinicial
contrato.vltotal with width 200.
