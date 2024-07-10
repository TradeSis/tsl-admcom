/*      alcis/conf_acao_nf.p                */
{admcab.i}
{alcis/tpalcis.i}

def input parameter par-arq as char.
def input parameter par-npedid as char.
def input parameter par-etbdes like estab.etbcod.

def var vdiretorio-ant  as char.
vdiretorio-ant = "/admcom/tmp/alcis/INS/".
def var vdiretorio-apos as char.
vdiretorio-apos = "/usr/ITF/dat/in/".
def var varquivo as char.
varquivo = alcis-diretorio + "/" + par-arq.
def var varq-dep as char.
def var varq-ant as char.
varq-ant = varquivo.
varq-dep = "/admcom/tmp/alcis/bkp/" + par-arq.

def shared temp-table tt-pedid like pedid.
def shared temp-table tt-liped like liped.
def shared temp-table tt-plani like plani.
def shared temp-table tt-movim like movim.
def shared temp-table tt-movimimp like movimimp.

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
find estab where estab.etbcod = setbcod no-lock.
find bestab where bestab.etbcod = par-etbdes no-lock.

do.    
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
    for each tt-liped.
        
        find xestoq where xestoq.etbcod = 7 and
                      xestoq.procod = tt-liped.procod no-lock
                                            no-error.
    
        if avail xestoq
        then vctotransf = xestoq.estcusto.
        else vctotransf = 1.
        if vctotransf = 0
        then vctotransf = 1.
        /***
        if today > 08/15/2016
        then do:
            find last mvcusto where mvcusto.procod = tt-liped.procod
                no-lock no-error.
            if avail mvcusto and
                     mvcusto.valctotransf > vctotransf
            then vctotransf = mvcusto.valctotransf.         
        end.
        ***/
        find first tt-movim where tt-movim.etbcod = tt-plani.etbcod and
                                  tt-movim.procod = tt-liped.procod no-error.
        
        if not avail tt-movim
        then do.
            vmovseq = vmovseq + 1.
            create tt-movim.
            assign tt-movim.PlaCod = tt-plani.placod 
                   tt-movim.etbcod = tt-plani.etbcod 
                   tt-movim.movseq = vmovseq 
                   tt-movim.procod = tt-liped.procod .
        end.
        ASSIGN tt-movim.movtdc = tt-plani.movtdc
               tt-movim.movqtm = tt-movim.movqtm + tt-liped.lipsep
               tt-movim.movdat = tt-plani.pladat
               tt-movim.MovHr  = int(time)
               tt-movim.desti  = tt-plani.desti
               tt-movim.emite  = tt-plani.emite
               tt-movim.movpc  = vctotransf
               .
        /***         
        if avail xestoq
        then tt-movim.movpc  = xestoq.estcusto.
        if xestoq.estcusto = 0
        then tt-movim.movpc = 1.
        ****/
        
        tt-liped.lipent = tt-liped.lipent + tt-liped.lipsep. 
        tt-liped.lipsep = 0.  
        if tt-liped.lipent >= tt-liped.lipqtd 
        then tt-liped.lipsit = "F". 

        find first tt-pedid of tt-liped no-error.
        tt-pedid.sitped = "F". 
    end.
    for each tt-liped:
        tt-liped.lipsit = "F".
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

    output to erro.rr.
    unix silent value("cp " + varq-ant + " " + varq-dep).
    unix silent value("rm -rf " + varq-ant).
    output close.
    unix silent value("chmod 777 erro.rr").
    
    run manager_nfe.p (input "995_5152",
                       input ?,
                       output p-ok).

end.

