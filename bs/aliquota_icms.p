/*
#1 04/19 - Projeto ICMS Efetivo
*/

def input parameter par-procod as int.
def input parameter par-opccod as int.
def input parameter par-ufeemi as char.
def input parameter par-ufedes as char.
def output parameter p-pctimpos as dec decimals 2 init 0.
def output parameter p-aliqefet as dec decimals 2 init 0. /* #1 */

def var vcodfis    as int. /* NCM */
def buffer xprodu  for produ.

if par-procod > 0
then do.
    find xprodu where xprodu.procod = par-procod no-lock.
    vcodfis = xprodu.codfis.
    if par-ufeemi = "RS" and
       par-ufedes = "RS"
    then do.
        assign
            p-pctimpos = xprodu.proipiper
            p-aliqefet = xprodu.al_Icms_Efet.
        return.
    end.            
end.

{valtribu.i
    &pais-ori    = ""BRA""
    &unfed-ori   = par-ufeemi
    &pais-dest   = ""BRA""
    &unfed-dest  = par-ufedes
    &procod      = par-procod
    &opfcod      = par-opccod
    &ncm         = vcodfis /* NCM */
    &agfis-dest  = 0 
    &dativig     = today
    &nextlabel   = "next." }
   
if avail tribicms
then do:
    find first tbtptrib of tribicms no-lock.
    p-pctimpos = (if tbtptrib.partbaseicms
                  then tribicms.pcticmspdv *
                     ( 1 - (tribicms.pctredutor / 100))        
                  else 0).
    p-aliqefet = tribicms.al_Icms_Efet.
end.

