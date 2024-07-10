/*
#1 04/19 - Projeto ICMS Efetivo
*/
/* Calcular ICMS de uma NFE/CTE */

{cabec.i}

def shared temp-table tt-plani like plani.
def shared temp-table tt-movim like movim.
def shared temp-table tt-movimimp like movimimp.

def var vmovsubst   like movim.movsubst.
def var vmovalicms  like movim.movalicms.
def var vmovicms    like movim.movicms.
def var vbaseicms   like movim.movbicms.
def var vbsubst     as dec.
def var vopfcod     as int.
def var vtbtptrib-cod as char.

find first tt-plani.

find opcom where opcom.opccod = string(tt-plani.opccod) no-lock no-error.
if not avail opcom or opcom.opcgia = no
then return.

if tt-plani.plaufemi = ""
then return.

assign
    tt-plani.bicms = 0
    tt-plani.icms  = 0.

for each tt-movim.
    run icms.p (input  tt-movim.procod,
              input  tt-plani.plaufemi,
              input  tt-plani.plaufdes,
              input  today,
              input  (tt-movim.movpc * tt-movim.movqtm) +
                      tt-movim.movacf - tt-movim.movdes,
              input  no,
              input  tt-plani.opccod,
              output vtbtptrib-cod,
              output vopfcod,
              output vbaseicms,
              output vmovalicms,
              output vmovicms,
              output vbsubst,
              output vmovsubst).

    if vtbtptrib-cod = ""
    then vtbtptrib-cod = "51".

    assign
        tt-movim.movbicms  = vbaseicms
        tt-movim.movalicms = vmovalicms
        tt-movim.movicms   = vmovicms
        tt-movim.opfcod    = if tt-plani.plaufemi = tt-plani.plaufdes
                             then vopfcod else vopfcod + 1000
        tt-movim.movcsticms = vtbtptrib-cod.
    assign
        tt-plani.bicms = tt-plani.bicms + tt-movim.movbicms
        tt-plani.icms  = tt-plani.icms  + tt-movim.movicms.

    if tt-plani.opccod = 5152 and
       tt-plani.plaufemi = tt-plani.plaufdes
    then run icms_retido.

    if tt-plani.opccod = 5152 and
       tt-plani.plaufemi <> tt-plani.plaufdes
    then run icms_st.
end.

if tt-plani.plaufemi <> tt-plani.plaufdes
then tt-plani.opccod = tt-plani.opccod + 1000.



procedure icms_retido. /*#1 Transferencia */

    def var vqtde  as dec decimals 8.
    def var valiq  as dec.

    find produ where produ.procod = tt-movim.procod no-lock.
    if tt-plani.plaufdes = "RS"
    then do:
        if produ.proipiper <> 99
        then return.
    end.
    else return.

    /* #1 */
    find last movim where movim.procod = tt-movim.procod
                      and movim.movtdc = 4
                    no-lock no-error.
    if not avail movim
    then return.

    vqtde = tt-movim.movqtm / movim.movqtm.

    if movim.movbsubst > 0 /* Compra com CST original 10 */
    then do.
        create tt-movimimp.
        assign
            tt-movimimp.etbcod    = tt-movim.etbcod
            tt-movimimp.placod    = ?
            tt-movimimp.movseq    = tt-movim.movseq
            tt-movimimp.procod    = tt-movim.procod
            tt-movimimp.impcodigo = 25
            tt-movimimp.impbasec  = movim.movbsubst * vqtde
            tt-movimimp.impaliq   = produ.al_icms_efet + produ.al_fcp
            tt-movimimp.impvalor  = movim.movsubst * vqtde.
    end.

    for each movimimp where movimimp.etbcod = movim.etbcod
                        and movimimp.placod = movim.placod
                        and movimimp.movseq = movim.movseq
                        and movimimp.procod = tt-movim.procod
                        and (movimimp.impcodigo = 25 or
                             movimimp.impcodigo = 27)
                        and movimimp.impbasec > 0
                   no-lock.
        if movimimp.impcodigo = 25
        then valiq = produ.al_icms_efet + produ.al_fcp.
        else valiq = movimimp.impaliq.
        
        create tt-movimimp.
        assign
            tt-movimimp.etbcod    = tt-movim.etbcod
            tt-movimimp.placod    = ?
            tt-movimimp.movseq    = tt-movim.movseq
            tt-movimimp.procod    = tt-movim.procod
            tt-movimimp.impcodigo = movimimp.impcodigo
            tt-movimimp.impbasec  = movimimp.impbasec * vqtde
            tt-movimimp.impaliq   = valiq
            tt-movimimp.impvalor  = movimimp.impvalor * vqtde
            tt-movimimp.impvlraux1 = movimimp.impvlraux1 * vqtde.
    end.
    /* #1 */

end procedure.


procedure icms_st.

def var vpasso1        as dec.
def var vpasso2        as dec.
def var valicms-ie     like movim.movalicms.
def var vmvaajust      as dec decimals 4.

    def var vbicms    as dec decimals 2.
    def var valicms-int as dec.
    def var valicms-des as dec.
    def var valicms-ext as dec.
    def var valicms-efe as dec.
    def var vicms     as dec decimals 2.
    def var vbicms-st as dec decimals 2.
    def var vicms-st  as dec decimals 2.
    def var valmva    as dec.

    find produ where produ.procod = tt-movim.procod no-lock.

    if tt-plani.plaufdes = "RS" and
       produ.proipiper = 99 and
       produ.al_fcp > 0
    then do.
        create tt-movimimp.
        assign
            tt-movimimp.etbcod    = tt-movim.etbcod
            tt-movimimp.placod    = ?
            tt-movimimp.movseq    = tt-movim.movseq
            tt-movimimp.procod    = tt-movim.procod
            tt-movimimp.impcodigo = 23
            tt-movimimp.impbase   = tt-movim.movpc * tt-movim.movqtm
            tt-movimimp.impaliq   = produ.al_fcp
            tt-movimimp.impvalor  = tt-movim.movpc * tt-movim.movqtm
                                    * produ.al_fcp / 100.
    end.

    /* Passo 1 - Verificar se o produto e´ ST na UF DESTINO */    

    /* Buscar Aliquota INTERNA e MVA */
    {valtribu.i
        &pais-ori    = ""BRA""
        &unfed-ori   = tt-plani.plaufdes
        &pais-dest   = ""BRA""
        &unfed-dest  = tt-plani.plaufdes
        &procod      = tt-movim.procod
        &opfcod      = 0
        &ncm         = produ.codfis /* NCM */
        &agfis-dest  = 0 
        &dativig     = today
        &nextlabel   = "next." }

    tt-movim.movcsticms = "00".
    
    if tt-plani.plaufdes  = "RS"
    then do:
        if produ.proipiper <> 99 then return.
    end.
    else if tribicms.pcticmspdv <> 99 then return.
                                        
    valmva = tribicms.PctMgSubst.

    run aliquota_icms.p (0, 0, tt-plani.plaufemi, tt-plani.plaufdes,
                         output valicms-ie, output valicms-efe).

    /* aliquota interna no destino */
    run aliquota_icms.p (0, 0, tt-plani.plaufdes, tt-plani.plaufdes,
                         output valicms-int, output valicms-efe).

    run aliquota_icms.p (0,tt-plani.opccod,tt-plani.plaufdes,tt-plani.plaufdes,
                         output valicms-ext, output valicms-efe).

    /* MVA ajustado */
    vpasso1 = (1 + valmva / 100).
/***
    vpasso2 = (1 - (valicms-ie / 100) ) / (1 - (valicms-int / 100)).

    if tt-plani.plaufemi = tt-plani.plaufdes
    then vmvaajust = valmva / 100.
    else vmvaajust = (vpasso1 * vpasso2) - 1.

    vbicms = (tt-movim.movpc * tt-movim.movqtm) - tt-movim.movdes.
    vicms  = vbicms * valicms-ext / 100.

    vbicms-st = vbicms * (1 + vmvaajust).
    vicms-st  = (vbicms-st * valicms-int / 100) - vicms.
***/
    vmvaajust = valmva / 100.

    vbicms = (tt-movim.movpc * tt-movim.movqtm) - tt-movim.movdes.
    vicms  = vbicms * valicms-ie  / 100.

    vbicms-st = vbicms * (1 + vmvaajust).
    vicms-st  = (vbicms-st * valicms-int / 100) - vicms.

    assign
        tt-movim.movcsticms = "10"
        tt-movim.movbsubst = vbicms-st
        tt-movim.movsubst  = vicms-st
        tt-movim.ocnum[1]  = valicms-int
        tt-plani.bsubst    = tt-plani.bsubst + vbicms-st
        tt-plani.icmssubst = tt-plani.icmssubst + vicms-st
        tt-plani.platot    = tt-plani.platot + vicms-st.

end procedure.

