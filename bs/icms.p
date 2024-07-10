                                                   /* PARAMETROS DE ENTRADA */
def input parameter par-procod  like produ.procod.    /* PRODUTO            */
def input parameter par-ufemi   like plani.ufemi.     /* UF DO EMITENTE     */
def input parameter par-ufdes   like plani.ufdes.     /* UF DO DESTINATARIO */
def input parameter par-data    as date.              /* DATA               */
def input parameter par-valor   like movim.movpc.     /* VALOR DOS PRODUTOS */
def input parameter par-indctr  as log.               /* clifor CONTRIBUINTE */
def input parameter par-opccod  like opcom.opccod.    /* OPER.COMERCIAL     */
                                                   /* PARAMETROS DE SAIDA   */

def output parameter par-tbtptrib-cod like tribicms.tbtptrib-cod.              
def output parameter par-cfop   as int.               /* CFOP               */
def output parameter par-bicms  like plani.bicms.     /* BASE DO ICMS       */
def output parameter par-alicms like movim.movalicms. /* ALIQUOTA DO ICMS   */
def output parameter par-icms   like movim.movicms.   /* VALOR DO ICMS      */
def output parameter par-bsubs  like plani.bsubs.     /* BASE ICMS SUBST    */
def output parameter par-subst  like movim.movsubst.  /* VALOR ICMS SUBST   */

def var sys-venda as log.
def var sys-ni    as log.
def var valiquota as dec.
def buffer xopcom  for opcom.
def buffer xprodu  for produ.
def buffer xtipmov for tipmov.

find xprodu where xprodu.procod = par-procod no-lock.
find xopcom where xopcom.opccod = par-opccod no-lock.
find xtipmov of xopcom no-lock.

if par-ufemi = ""
then par-ufemi = "RS".
if par-ufdes = ""
then par-ufdes = "RS".

if xprodu.itecod > 0
then par-procod = xprodu.itecod.

    {valtribu.i
            &pais-ori    = ""BRA""
            &unfed-ori   = par-ufemi
            &pais-dest   = ""BRA""
            &unfed-dest  = par-ufdes
            &procod      = par-procod
            &ncm         = xprodu.codfis   /* NCM */
            &agfis-dest  = 0
            &opfcod      = int(par-opccod) /* CFOP */
            &dativig     = par-data
            &nextlabel   = " " }

/*  produto NI na obino tem base reduzida sempre    */
/* ja tinha feito isto,  mas   tiraram              */
/* se esta aqui nao e para tirar                    */
/* ou se forem tirar,  perguntar                    */ 

sys-venda = no.
sys-ni    = no.
/***
if xprodu.tprocod = 5
then sys-ni = yes.

    /* helio,24102006 modificado apos reuniao com a cloris */
    /* nao modifique sem ter certeza */
    
    if xtipmov.movtdc = 2
    then find cer-itr where cer-itr.codtrib = xprodu.tbpreco-cod no-lock.
    else find cer-itr where cer-itr.codtrib = xprodu.ctpreco-cod no-lock.
***/
    if xtipmov.movtvenda = yes and
       xtipmov.movtdev   = no
    then sys-venda = yes.

assign 
    par-tbtptrib-cod = tribicms.cst
    par-alicms  = if xtipmov.movtvenda /*** and  
                     xopcom.opcecf ***/
                  then if tribicms.pcticmspdv = 0 and 
                          tribicms.pcticms <> 0  
                       then 17 
                       else tribicms.pcticmspdv 
                  else tribicms.pcticms.

    /*  produto NI na obino tem base reduzida sempre    */
    /* ja tinha feito isto,  mas   tiraram              */
    /* se esta aqui nao e para tirar                    */
    /* ou se forem tirar,  perguntar                    */
    if sys-venda and
       sys-ni
    then par-alicms = 3.40.

    if par-alicms > 0
    then par-bicms   =  
            if not xopcom.opcgia 
            then 0
            else
                /***if xopcom.opcred /* Reducao na operacao */
                then par-valor * (1 - ((100 - xopcom.opcper) / 100))
                else***/ if (xtipmov.movttra and par-ufemi <> par-ufdes) or
                     /* transf.entre estados tributa integralmente */
                        (xtipmov.movtvenda /***and 
                         xopcom.opcecf and
                         cer-itr.pertrib <> 0***/)
                     then par-valor
                     else par-valor /*** (1 - ((100 - cer-itr.pertrib) / 100))
                                    ***/.

    par-icms    = par-bicms * par-alicms / 100.

    par-alicms  = if par-icms = 0
                  then 0
                  else par-alicms.

    /*** Determinar o CFOP: ***/
    par-cfop = int(xopcom.opccod).
    if xopcom.opfcod-st > 0
    then do.
        if par-ufdes = "RS"
        then do.
            if xprodu.proipiper = 99
            then assign
                    par-tbtptrib-cod = "60"
                    par-cfop = xopcom.opfcod-st.
        end.
        else do.
            run aliquotaicms.p (par-procod, 0, par-ufdes, par-ufdes,
                                output valiquota).
            if valiquota = 99
            then assign
                    par-tbtptrib-cod = "60"
                    par-cfop = xopcom.opfcod-st.
        end.
    end.
