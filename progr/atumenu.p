def input parameter vip as char format "x(15)".
def output parameter vstatus as char format "x(40)".



find gerloja.aplicativo
    where gerloja.aplicativo.aplinom = "SISTEMA" no-error.
if avail gerloja.aplicativo
then do:
         
    vstatus = "MENU JA EXISTENTE NESSA FILIAL".
    return.
end.



find first gerloja.aplicativo 
     where gerloja.aplicativo.aplicod begins "zcorr" no-error.
if avail gerloja.aplicativo
then assign gerloja.aplicativo.aplinom = "SISTEMA"
            gerloja.aplicativo.aplicod = "zcorr".
else do:
    create gerloja.aplicativo.
    assign gerloja.aplicativo.aplicod = "zcorr"
           gerloja.aplicativo.aplinom = "SISTEMA".

end.
for each gerloja.menu where gerloja.menu.aplicod begins "zcorr".
    gerloja.menu.aplicod = "zcorr".
end.

find gerloja.menu where gerloja.menu.aplicod begins "zcorr" and
                        gerloja.menu.mentit = "CORREIO" and 
                        gerloja.menu.ordsup = 0 no-error.
if avail gerloja.menu
then
    gerloja.menu.mentit = "SISTEMA".

for each gerloja.menu where gerloja.menu.aplicod begins "zcorr" and gerloja.menu.ordsup = 1 and gerloja.menu.menniv = 2.
delete gerloja.menu.
end.
    
vstatus = "FILIAL ATUALIZADA COM SUCESSO!!!!"

/* display "FILIAL " vip no-label " ATUALIZADA!!" with frame f-1.
pause 3 no-message.
clear frame f-1.  */



