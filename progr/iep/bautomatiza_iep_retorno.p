
def var vpropath as char.
input from /admcom/linux/propath no-echo.  /* Seta Propath */
import vpropath.
input close.

propath = vpropath.


    message time string(time,"HH:MM:SS") "retorno.".
        run iep/biepretorno.p ("RETORNO").
    message time string(time,"HH:MM:SS") "retorno. FIM".

