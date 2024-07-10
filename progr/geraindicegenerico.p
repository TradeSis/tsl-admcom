/*PRPK - helio 21042022 - nova tabela */

/* helio 12/11/2021 novos campos fase 2 */

def input parameter par-procod  like produ.procod.
def input parameter par-outros  as char.               /* helio 03/09/2021 */

def var vindicegenerico as char.

def var vsubclasse as char. 
def var vindicemix as char.
def var vmixloja   as char.
def var vmix as log.
def var vgrade as int.
def var vclasses as char.
def var vclanom as char.
def var vagrupado   as char.
def var vfilhos as char.
def buffer depto for clase.
def buffer grupo for clase.
def buffer sclase for clase.
def buffer setclase for clase.
def var vzoom as log.

/* indice generico - multimix*/
def var vmmixgrade as char.
def var vtamcod as char.
def buffer bprodu for produ.

    find produ where produ.procod = par-procod exclusive no-wait no-error.
    if avail produ
    then do:
        if produ.indicegenerico = ?
        then produ.indicegenerico = "".
        vindicegenerico = produ.indicegenerico.
        
        vzoom = yes. /* para agrupadores que nao pode aparecer no zoom */
                
        vindicemix = "".
        vmixloja   = "".
        for each estab no-lock.
        
            /* mix */
            vmix = no. 
            find abasgrade where 
                    abasgrade.etbcod = estab.etbcod and
                    abasgrade.procod = produ.procod
                    no-lock no-error.
            vgrade = if avail abasgrade
                     then abasgrade.abgqtd
                     else 0.
            if vgrade > 0 
            then vmix = yes.
            
            if vmix
            then do:
                vindicemix = vindicemix + "MIX#" + string(estab.etbcod) + "|". 
                vmixloja   = vmixloja   + "MIX" + string(estab.etbcod) + "#" + string(vgrade) + "|". 
            end.    
        end.
    
        find fabri of produ no-lock no-error.

        find sclase of produ no-lock no-error.
        vclanom    = if avail sclase and produ.clacod <> ?
                     then "SUBCLASSE#" + string(produ.clacod)
                     else "".
        vclasses = vclanom.
        
        find clase where clase.clacod = sclase.clasup no-lock no-error.
        vclanom    = if avail clase and clase.clacod <> ?
                     then "CLASSE#" + string(clase.clacod)
                     else "".

        vclasses   = vclasses + (if vclasses <> ""
                                 then "|"
                                 else "") 
                              +   vclanom.

        find grupo where grupo.clacod = clase.clasup no-lock no-error.
        vclanom    = if avail grupo and grupo.clacod <> ?
                     then "GRUPO#" + string(grupo.clacod)
                     else "".

        vclasses   = vclasses + (if vclasses <> ""
                                 then "|"
                                 else "") 
                              +   vclanom.

        find setclase where setclase.clacod = grupo.clasup no-lock no-error.
        vclanom    = if avail setclase and setclase.clacod <> ?
                     then "SETOR#" + string(setclase.clacod)
                     else "".

        vclasses   = vclasses + (if vclasses <> ""
                                 then "|"
                                 else "") 
                              +   vclanom.

        find depto where depto.clacod = setclase.clasup no-lock no-error.
        vclanom    = if avail depto and depto.clacod <> ? 
                     then "DEPTO#" + string(depto.clacod)
                     else "".

        vclasses   = vclasses + (if vclasses <> ""
                                 then "|"
                                 else "") 
                              +   vclanom.
        vagrupado = "TIPOSAP#" + produ.tipoSAP.                     
        
        find prodagru where prodagru.procod = produ.procod no-lock no-error.
        if avail prodagru
        then do:
            find bprodu where bprodu.procod = prodagru.proagr no-lock.
            if bprodu.tipoSAP = "PRPK"
            then do:
                /* nada , alterado em 19042022  */
            end.
            else do:    
                if produ.tipoSAP <> ""
                then do:
                    if produ.tipoSAP = "ZCOM"
                    then vzoom = no.
                end. 
                vagrupado = vagrupado + "|KIT#SIM|COMPONENTE#FILHO|AGRUPADOR#" + string(prodagru.proagr) + "|" +
                                "VENDAAVULSA#" + string(prodagr.permitevendaavulsa,"SIM/NAO") + "|" +
                                "QTDVENDA#" + string(if prodagr.qtdvenda <> ? then prodagr.qtdvenda else 0) + "|". 
            end.
        end.  
        else do:
            find first prodagru where prodagru.proagr = produ.procod no-lock no-error.
            if avail prodagru
            then do:
                if produ.tipoSAP <> ""
                then do:
                    if produ.tipoSAP = "MODE" or
                       produ.tipoSAP = "ZMOD" or
                       produ.tipoSAP = "ZGEN"
                    then vzoom = no.
                end.

                if produ.tipoSAP = "PRPK"
                then do:
                    /* nada */
                end.
                else do:
            
                    vagrupado = vagrupado + "|KIT#SIM|COMPONENTE#AGRUPADOR|FILHOS#".
                    vfilhos = "".
                    for each prodagru where prodagru.proagr = produ.procod no-lock.
                        vfilhos = vfilhos + 
                                (if vfilhos = ""
                                 then ""
                                 else ",") +  string(prodagru.procod).
                    end.
                    if vfilhos = ? then vfilhos = "".
                    vagrupado = vagrupado + vfilhos + "|".
                end.
            end.                
        end.
        
        
        /*PRPK - helio 21042022 - nova tabela */
                /* nao ha o que atualizar para os filhos */            
                if produ.tipoSAP = "PRPK"
                then do:
                    vzoom = no.
                    vmmixgrade = "GRADE#".
                    for each prodagpk where prodagpk.proagr = produ.procod no-lock.
                        find bprodu where bprodu.procod = prodagpk.procod no-lock.
                        if prodagpk.QtdVenda <= 999 and prodagpk.QtdVenda > 0
                        then do:
                            vtamcod = "".
                            for each procaract of bprodu no-lock.
                                find first caract where caract.cardes = "TAMANHO" or
                                                        caract.cardes = "TAMANHO_CALCADO"    
                                        no-lock no-error. /* helio 29062022, era so "TAMANHO_CALCADO" */
                                if not avail caract
                                then next.
                                find  subcaract of procaract.
                                if subcaract.carcod <> caract.carcod
                                then next.
                                vtamcod = subcaract.subdes.
                            end.
                            if vtamcod <> ""
                            then  vmmixgrade = vmmixgrade + 
                                  substring(trim(vtamcod),1,3) + "=" +
                                 trim(string(prodagpk.QtdVenda,">>9")) + " ".
                        end.
                    end.
                    if vmmixgrade = "GRADE#"
                    then vmmixgrade = "".
                end.
        /**/
        
        
        if par-outros = ?
        then do:
            par-outros = entry(2,produ.indicegenerico,"@") no-error.
            if par-outros = ? then par-outros = "".
            par-outros = "|@" + par-outros.
        end.
        else do:
            par-outros = "|@|" + par-outros.
        end.

        produ.indicegenerico = "CATEGORIA#" + string(if produ.catcod = ? then 0 else produ.catcod) + "|"  +
                      "ZOOM#" + trim(string(vzoom,"SIM/NAO")) + "|" +
        
                        "PRONOM#" + trim(produ.pronom) + "|" +
                      "SITUACAO#" + trim(string(produ.proseq = 0,"ATIVO/INATIVO")) + "|" +
                           "VEX#" + trim(string(produ.ind_vex,"SIM/NAO")) + "|" +
                            "PE#" + trim(string(produ.proipival = 1,"SIM/NAO")) + "|" +
                 "DESCONTINUADO#" + trim(string(produ.descontinuado,"SIM/NAO")) + "|" +
                        "FABRI#"  + string(if produ.fabcod <> ? then produ.fabcod else 0) + "|" +
                     vclasses     + "|" +              
                     vindicemix   + "|" +
                     vmixloja     + "|" + /* helio 11/11/2021 fase II */
                     
                     vmmixgrade   + "|" + /* multimix 09/03/2022 */
                     
                     vagrupado    + 
                     par-outros. /* helio 03/09/2021 */
        
        if vindicegenerico <> produ.indicegenerico
        then produ.datexp = today.
        
    end.

