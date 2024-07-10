/* Gestao de Boletos   - processo batch
   bol/importaboleto.p
   importa arquivo em format CSV
*/


def var vpropath as char.
input from /admcom/linux/propath no-echo.  /* Seta Propath */
import vpropath.
input close.

propath = vpropath.

run bol/importaboleto_v2101.p.

return.
