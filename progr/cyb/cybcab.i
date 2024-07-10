/* #1 - Projeto Boletos - Parametro associado a boleto */
/** #6 **/ /** 02.2019 Helio.Neto - Versao 4 - Inlcui Elegiveis Feirao */

def shared var v-etbcod as int.

def var vef_elegivelfeirao as log . /* #6 */
def var vi as int format ">>>>>>>>>>>9".
def var vat as int.
def var vvlraberto as dec.
def var vvlratrasado as dec.
def var vvlrultpag as dec.
def var vdtultpag as date.
def var vparpg as char format "x(40)".
def var vparab as char format "x(40)".
def var vlp as log.
def var vnovacao as log.
def var vboleto as log. /* #1 */
def var vdtini as date.
def var vultvencab as date.

def var vqtdatrasado as int.
def var vvlravencer as dec.
def var vqtdavencer as int.
def var vvlrjuros as dec.
def var par-juros as dec.
def var vprivencab as date.
def var vqtdpagas as int.

FUNCTION acha returns character
    (input par-oque as char,
     input par-onde as char).
         
    def var vx as int.
    def var vret as char.  
    
    vret = ?.  
    
    do vx = 1 to num-entries(par-onde,"|"). 
        if entry(1,entry(vx,par-onde,"|"),"=") = par-oque 
        then do: 
            vret = entry(2,entry(vx,par-onde,"|"),"="). 
            leave. 
        end. 
    end.
    return vret. 
END FUNCTION.

