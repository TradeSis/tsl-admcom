
def var vpropath as char.
input from /admcom/linux/propath no-echo.  /* Seta Propath */
import vpropath.
input close.

propath = vpropath.


    message time string(time,"HH:MM:SS") "outras remessas - cancelamento/desistencia.".

        run iep/biepremessa.p ("desistencia"). 
        run iep/biepremessa.p ("AUT.DESISTENCIA").  
        run iep/biepremessa.p ("CANCELAMENTO").  
        run iep/biepremessa.p ("AUT.CANCELAMENTO"). 
    message time string(time,"HH:MM:SS") "outras remessas - cancelamento/desistencia. FIM".


