/* helio 18/05/2022 https://trello.com/c/W3un7Tn8/347-thalis-exportador-titulos-unione */
def var vpropath as char.

input from /admcom/linux/propath no-echo.  /* Seta Propath */
import vpropath.
input close.
propath = vpropath + ",\dlc".

message "Integracao Uni One" today
        "INICIO:" string(time,"HH:MM:SS").

def var vqtd as int.

vqtd =  100.
for each estab where estab.etbcod >= 249 and estab.etbcod < 900 no-lock:
    message "Integracao Uni One" today
         "inicio estab" estab.etbcod string(time,"HH:MM:SS").

    run fin/expunione.p (input estab.etbcod).

    message "Integracao Uni One" today
         "final estab" estab.etbcod string(time,"HH:MM:SS") "restam " vqtd "lojas".
    vqtd = vqtd - 1.
    if vqtd <= 0 
    then leave.   
end.

message "Integracao Uni One" today
 "FIM:" string(time,"HH:MM:SS").
