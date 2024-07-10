/* Gestao de Boletos   - processo batch
   bol/enviaboleto.p
   gera arquivo em format CSV
   
*/

def var vpropath as char.
input from /admcom/linux/propath no-echo.  /* Seta Propath */
import vpropath.
input close.

propath = vpropath.

run bol/enviaboleto_v1701.p.

return.
