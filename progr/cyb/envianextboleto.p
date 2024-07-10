/* Gestao de Boletos   - batchs
   cyb/envianextboleto.p
    Envia para o CYBER as proximo vencimento de Boleto
*/


def var vpropath as char.
input from /admcom/linux/propath no-echo.  /* Seta Propath */
import vpropath.
input close.

propath = vpropath.


run cyb/envianextboleto_v1701.p.

return.
