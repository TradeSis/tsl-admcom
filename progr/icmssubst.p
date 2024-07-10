def var vbsubst as dec.
def var vsubst as dec.

run icmsst (418646,
            "RS",
            "SP",
            today,
            28.85,
            0,
            0,
            output vbsubst,
            output vsubst).

procedure icmsst.
                                                                    /* PARAMETROS DE ENTRADA */
def input parameter par-procod  like produ.procod.     /* PRODUTO            */
def input parameter par-ufemi   like plani.ufemi.      /* UF DO EMITENTE     */
def input parameter par-ufdes   like plani.ufdes.      /* UF DO DESTINATARIO */
def input parameter par-data    as date.               /* DATA               */
def input parameter par-bicms   as dec.
def input parameter par-movipi  as dec.
def input parameter par-opccod  like opcom.opccod.     /* OPER.COMERCIAL     */

                                                                               /* PARAMETROS DE SAIDA   */
def output parameter par-bsubst like movim.movbsubs.   /* BASE ICMS SUBST    */
def output parameter par-subst  like movim.movsubst.   /* VALOR ICMS SUBST   */

def var vpasso1        as dec.
def var vpasso2        as dec.
def var valicms-ie     like movim.movalicms.
def var valicms-in     like movim.movalicms.
def var vmvaajust      as dec decimals 4.
def var vicms-proprio  as dec.
def var vicms-st       as dec.

valicms-ie = 12.
valicms-in = 17.

find clafis 85167910 no-lock.

/* MVA ajustado */
vpasso1 = (1 + clafis.mva_estado1 / 100).
vpasso2 = (1 - (valicms-ie / 100) ) / (1 - (valicms-in / 100)).


if par-ufemi = par-ufdes
then vmvaajust = clafis.mva_estado1 / 100.
else vmvaajust = (vpasso1 * vpasso2) - 1.

message vmvaajust.

    par-bsubst    = (par-bicms + par-movipi) * (1 + vmvaajust).
    vicms-proprio = par-bicms * valicms-ie / 100.
    vicms-st      = par-bsubst * valicms-in / 100.
    par-subst     = vicms-st - vicms-proprio.

message par-bsubst vicms-proprio vicms-st par-subst.
end procedure.