/*por Lucas Leote*/

{admcab.i}

def var vclicod like clien.clicod.

/* Formulario */
form vclicod label "Codigo"

with frame f01 title "Informe os dados abaixo:" with 1 col width 80.

/* Atualiza variaveis */
update vclicod
with frame f01.

/*hide frame f01 no-pause.*/

/* -------------------------------------------------------------------------------------- */

for each clien where clicod = vclicod.

find tipo_clien where tipo_clien.tipocod = clien.tipocod no-lock no-error.

disp
    clien.clicod label "Codigo"
    clien.ciccgc label "CPF"
    clien.clinom
    clien.cidade[1] label "Cidade"
    clien.tipocod label "Cod. tipo"
    tipo_clien.tipodes label "Nome tipo"
    clien.tippes label "Tipo de pessoa"
with 1 col.

message "1-VAREJO 2-ATACADO 3-FUNCIONARIO".

update clien.tipocod.

message "ALTERADO COM SUCESSO!" view-as alert-box.

end.