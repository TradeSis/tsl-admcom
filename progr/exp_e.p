/* #14102022 helio - exportacao para inauguracao exclui inativos */
{admcab.i}
def var vinauguracao as log format "sim/nao".
def var vt as int.
def var vp as int.
def var ve as int.
def var vetbcod like estab.etbcod.
def stream sprodu.
def stream sestoq.
def var varqprodu as char.
def var varqestoq as char.

repeat:
    update  vetbcod label "Filial" colon 30
                with frame f0 side-label width 80 
                    title "EXPORTACAO DE PRODUTOS".
    update vinauguracao label "Inauguracao?" colon 30
        with frame f0. 
    varqprodu = "/admcom/dados/produ_" + string(vetbcod) + ".d".
    varqestoq = "/admcom/dados/estoq_" + string(vetbcod) + ".d".
        
    output stream sprodu to value(varqprodu).
    output stream sestoq to value(varqestoq).
    
    message "exportando" varqprodu "e" varqestoq "..." string(vinauguracao,"inauguracao/").
    vp = 0.
    ve = 0.
    vt = 0.
    for each produ no-lock.
        vt = vt + 1.
        if vt = 1 or vt mod 5000 = 0 then do:
            hide message no-pause.
            message "exportando" varqprodu vp "e" varqestoq ve "..." string(vinauguracao,"inauguracao/") vt.
            
        end.    
        if produ.itecod = 0 and
           produ.corcod = "" and
           produ.protam = ""
        then next.                     
      
        if vinauguracao
        then do:
            if produ.proseq = 99
            then next.
        end.
        
        export stream sprodu 
    produ.procod       
    produ.pronom   
    produ.pronomc  
    produ.fabcod    
    produ.clacod     
    produ.prouncom    
    produ.prounven    
    produ.proabc   
    produ.prodtcad    
    produ.propag  
    produ.proseq   
    produ.proipiper    
    produ.proipival   
    produ.proclafis   
    produ.procvven   
    produ.procvcom    
    produ.prorefter   
    produ.protam    
    produ.corcod    
    produ.itecod
    produ.etccod  
    produ.prozort   
    produ.procar   
    produ.catcod   
    produ.proindice   
    produ.datexp   
    produ.exportado  
    produ.codfis     
    produ.codori
    produ.codtri  
    produ.descRevista    
    produ.pvp     
    produ.descontinuado 
    produ.datFimVida  
    produ.opentobuy     
    produ.temp-cod  
    produ.IndiceGenerico.
        vp = vp + 1.
        for each estoq where estoq.etbcod = vetbcod and
                             estoq.procod = produ.procod
                    no-lock.
    
            export stream sestoq 
  estoq.etbcod
  estoq.procod
  estoq.pronomc
  estoq.fabfant
  estoq.estatual
  estoq.estmin
  estoq.estrep
  estoq.estideal
  estoq.estloc
  estoq.estmgoper
  estoq.estmgluc
  estoq.estcusto
  estoq.estvenda
  estoq.estdtcus
  estoq.estdtven
  estoq.estreaj
  estoq.estimp
  estoq.estinvqtd
  estoq.estinvdat
  estoq.ctrcod
  estoq.estinvctm
  estoq.tabcod
  estoq.estbaldat
  estoq.estbalqtd
  estoq.estprodat
  estoq.estproper
  estoq.estpedcom
  estoq.estpedven
  estoq.datexp
  estoq.cst
  estoq.aliquotaIcms.

            
            ve = ve + 1.

        end.
        
    
    end.    
    output stream sprodu close.
    output stream sestoq close.
    hide message no-pause.
    message "exportados" varqprodu vp "e" varqestoq ve "..." string(vinauguracao,"inauguracao/") vt.
      
end.

    



         

                       
