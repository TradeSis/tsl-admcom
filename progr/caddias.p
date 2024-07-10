/* by dias */

{admcab.i}

def var cliente like clien.ciccgc.

form cliente label "CPF do cliente"
with frame f01 title "Por favor, informe o codigo do cliente:" with 1 col width 80.

update cliente with frame f01.

for each clien where clien.ciccgc = cliente.
disp clien.mae label "Nome da mae" 
     clien.endereco[1] label "Rua" 
     clien.numero[1] label "Numero"
     clien.bairro[1] label "Bairro"
     clien.cidade[1] label "Cidade"
     clien.dtnas format "99/99/9999"
     clien.ciinsc label "Identidade" 
     clien.cep[1] label "CEP" 
     clien.fax label "Celular"
     clien.zona label "E-mail" format "x(60)" with 1 col.

message "Por favor, informe os dados atualizados do cliente".

update cep[1] fax zona.
disp cep[1] fax zona.

clien.datexp = today.

Message "Cliente atualizado com sucesso!".

end.
