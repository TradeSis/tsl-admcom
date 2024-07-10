{admcab.i}

/****
IP: 10.2.0.29
Diretório dos bancos de dados: /u01/bancos
Diretório de administração dos bancos (ativa.sh e desativa.sh): /u01/scripts
Diretório de backup: /u02/backup
sensei - 60000 (faltou migrar)
nissei - 60001
ninja -   60002
mov -    60003
*********/

connect sensei -H 10.2.0.109 -S 60000 -N tcp.
connect nissei -H 10.2.0.109 -S 60001 -N tcp.
connect ninja  -H 10.2.0.109 -S 60002 -N tcp.

def var vsano as char extent 4 FORMAT "x(18)"
    init["  CLIENTES 2018","  CLIENTES 2019","  CLIENTES 2020"]   .
    
vsano[4] = "  CLIENTES 2021" .

disp vsano with frame f-es 1 down no-label centered.
choose field vsano with frame f-es.
    
if frame-index = 1
then run ctb/bg-salcart-v0219.p.
else  if frame-index = 2
then run ctb/bg-salcart-v0319.p.
else if frame-index = 3
then run ctb/bg-salcart-v0120.p.
else run ctb/bg-salcart-v0121.p.

if connected("ninja") then disconnect "ninja".
if connected("sensei") then disconnect "sensei".
if connected("nissei") then disconnect "nissei".

