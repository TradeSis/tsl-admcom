/* Gestao de Boletos   - batchs
   cyb/enviapgtoboleto.p
    Envia para o CYBER as efetivacoes/pagamentos por Boleto
*/


def var vpropath as char.
input from /admcom/linux/propath no-echo.  /* Seta Propath */
import vpropath.
input close.

propath = vpropath.


run cyb/enviapgtoboleto_v1701.p.

return.
