{admcab.i}
def var vescolha as char extent 3 format "x(15)".
assign
    vescolha[1] = "ORDEM SERVICO"
    vescolha[2] = "ENVIO POSTO"
    vescolha[3] = "ENVIO FILIAL"
    .
     
disp " Escolha uma opção " with frame f1 1 down no-box no-label
        color message.
disp vescolha with frame f-escolha 1 down 1 column no-label.
choose field vescolha with frame f-escolha. 

if frame-index = 1
then  run asstec.p.
else if frame-index = 2
    then run asstec_e.p.
    else if frame-index = 3
        then run assfil_e.p.
        


