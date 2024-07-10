/*****
#2 - 12/12/2019 - Claudir - Sequencia alfabetic dos itens
****/

/*      alcis/conf_acao_nf.p                */
{admcab.i}
{alcis/tpalcis.i}

def input parameter par-rec as recid.

def var par-npedid as char.
def var par-etbdes like estab.etbcod.


/*def var vdiretorio-ant  as char.
vdiretorio-ant = "/admcom/tmp/alcis/INS/".
def var vdiretorio-apos as char.
vdiretorio-apos = "/usr/ITF/dat/in/".
def var varquivo as char.
varquivo = alcis-diretorio + "/" + par-arq.
def var varq-dep as char.
def var varq-ant as char.
varq-ant = varquivo.
varq-dep = "/admcom/tmp/alcis/bkp/" + par-arq.
*/

/* NFE */
def new shared temp-table tt-pedid like pedid.
def new shared temp-table tt-liped like liped.
def new shared temp-table tt-plani like plani.
def new shared temp-table tt-movim like movim.
def new shared temp-table tt-movimimp like movimimp.

def new shared temp-table tt-sel
    field rec    as   recid
    field desti  like tdocbase.etbdes.
 
find first tt-sel no-lock no-error.


for each tt-plani: delete tt-plani. end. 
for each tt-movim: delete tt-movim. end.
for each tt-movimimp. delete tt-movimimp. end.

def buffer bestab for estab.
def buffer xestoq for estoq.

def var vnumero         like plani.numero.
def var vserie          like plani.serie.
def var vplacod         like plani.placod.
def var vprotot         like plani.protot.
def var vmovseq         as i.
def var vctotransf as dec.

do.    

    find abasintegracao where recid(abasintegracao) = par-rec no-lock.
    setbcod     = abasintegracao.etbcd.
    par-etbdes  = abasintegracao.etbcod.
    par-npedid  = string(abasintegracao.dcbcod).
    
    find estab where estab.etbcod   = abasintegracao.etbcd  no-lock.
    find bestab where bestab.etbcod = abasintegracao.etbcod no-lock.


    find tipmov where tipmov.movtdc = 6 no-lock.
    vplacod = ?.
    vnumero = ?.
    vserie  = "1".
    create tt-plani.
    assign tt-plani.etbcod   = setbcod
           tt-plani.placod   = vplacod
           tt-plani.emite    = setbcod
           tt-plani.plaufemi = estab.ufecod
           tt-plani.serie    = vserie
           tt-plani.numero   = vnumero
           tt-plani.movtdc   = 6
           tt-plani.desti    = bestab.etbcod
           tt-plani.plaufdes = bestab.ufecod
           tt-plani.hiccod   = 5152
           tt-plani.opccod   = 5152
           tt-plani.pladat   = today
           tt-plani.datexp   = today
           tt-plani.modcod   = tipmov.modcod
           tt-plani.notfat   = bestab.etbcod
           tt-plani.dtinclu  = today
           tt-plani.horincl  = time
           tt-plani.notsit   = no
           tt-plani.notobs[3] = "P".
       
    vprotot = 0.
    vmovseq = 0.
    for each abasCARGAprod of abasintegracao 
                where abasCARGAprod.qtd > 0 no-lock,
        /*#2*/  first produ where
                      produ.procod = abasCARGAprod.procod
                      no-lock by produ.pronom:

        
        find xestoq where xestoq.etbcod = abasintegracao.etbcd and
                      xestoq.procod = abasCARGAprod.procod no-lock
                                            no-error.
    
        if avail xestoq
        then vctotransf = xestoq.estcusto.
        else vctotransf = 1.
        if vctotransf = 0
        then vctotransf = 1.

        find first tt-movim where tt-movim.etbcod = tt-plani.etbcod and
                                  tt-movim.procod = abasCARGAprod.procod no-error.
        
        if not avail tt-movim
        then do.
            vmovseq = vmovseq + 1.
            create tt-movim.
            assign tt-movim.PlaCod = tt-plani.placod 
                   tt-movim.etbcod = tt-plani.etbcod 
                   tt-movim.movseq = vmovseq 
                   tt-movim.procod = abasCARGAprod.procod .
        end.
        ASSIGN tt-movim.movtdc = tt-plani.movtdc
               tt-movim.movqtm = tt-movim.movqtm + abasCARGAprod.qtdcarga
               tt-movim.movdat = tt-plani.pladat
               tt-movim.MovHr  = int(time)
               tt-movim.desti  = tt-plani.desti
               tt-movim.emite  = tt-plani.emite
               tt-movim.movpc  = vctotransf
               .
    end.
                    
    def var p-ok as log.
    p-ok = no.
    tt-plani.platot = 0.
    tt-plani.protot = 0.
    for each tt-movim .
        tt-plani.platot = tt-plani.platot + (tt-movim.movpc * tt-movim.movqtm).
        tt-plani.protot = tt-plani.protot + (tt-movim.movpc * tt-movim.movqtm).
    end.        
    if par-npedid <> ""
    then tt-plani.notobs[1] = "REF PED.: " + par-npedid. 

    sresp = no.
    message "Confirma emisao NFE de ORDEM DE VENDA " par-npedid
            "para loja" bestab.etbcod "?" update sresp.
    if not sresp
    then next.

    
    run manager_nfe.p (input "995_5152",
                       input ?,
                       output p-ok).



        do on error undo:
            
            find current abasintegracao exclusive.
            find current tt-plani.
            
            abasintegracao.placod = tt-plani.placod.
            
        end. 

        find current abasintegracao no-lock.
        
        run abas/transffecha.p (recid(abasintegracao)).



end.

