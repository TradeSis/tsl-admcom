
def var vpropath as char.
input from /admcom/linux/propath no-echo.  /* Seta Propath */
import vpropath.
input close.

propath = vpropath.


    message "iep/bautomatiza_iep_remessa.p" today string(time,"HH:MM:SS") "remessa".
    run iep/biepremessa.p ("REMESSA").
    message "iep/bautomatiza_iep_remessa.p" today string(time,"HH:MM:SS") "remessa FIM".
    

