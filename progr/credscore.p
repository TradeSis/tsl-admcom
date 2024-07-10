{admcab.i}

def var vescopc as char extent 4.

vescopc[1] = "Parametros Gerais".
vescopc[2] = "Compras e Pagamentos".
vescopc[3] = "Estabelecimentos dos Clientes".
vescopc[4] = "Notas".

repeat on endkey undo, leave.
    disp vescopc format "x(30)"
         help "Escolha a opcao desejada"
         with frame fchoose-opcao row 6 col 5 no-label 1 down
         1 col overlay.
         choose field vescopc auto-return 
         with frame fchoose-opcao.
    if frame-index = 1
    then run cadcredscore.p.
    if frame-index = 2
    then run agfilcre.p. /*run cadcredscore1.p.*/
    if frame-index = 3
    then run cadcredscore2.p.
    if frame-index = 4
    then run cadcredscore3.p.
end.     
 
