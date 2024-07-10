def temp-table tt-format
    field banco as char
    field tabela as char
    . 
form with frame f1.
form with frame f2.

disp " " at 1
     " ALTERACAO DO FORMATO DO CAMPO ETBCOD PARA TRES DIGITOS  " at 1
     " " at 1
     with frame f10 centered row 10 no-box color message .
     
def var sresp as log format "Sim/Nao" init no.
message "Confirma inicio da alteracao?" update sresp.
if not sresp then return.

if connected("WMS")
then do:
for each WMS._file no-lock:
    disp "WMS" _file._file-name with frame f1.  pause 0.
    for each WMS._field of _file where
             WMS._field._field-name = "etbcod" .
        disp _field._field-name _field._format with frame f2. 
        if WMS._field._format = ">9"
        then do transaction: 
            create tt-format.
            tt-format.banco = "WMS".
            tt-format.tabela = WMS._file._file-name.
            WMS._field._format = ">>9".
        end.
    end.
end.
end.
/*else do:
    message color red/with
        "Banco WMS nao esta conectado." skip
        "Nao foi possivel efetuar alteracao de formato do campo estab" skip
          "nas tabelas do banco WMS."
         view-as alert-box.
end.*/

output to ./alt_format.txt.
for each tt-format.
    export tt-format.
end.
output close.

disp " ALTERACAO CONCLUIDA " at 1
     " " at 1
    
    WITH FRAME F10.

pause.
quit.
