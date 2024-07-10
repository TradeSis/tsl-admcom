/* #0 - helio.neto - 08.2019 - fase 1 - apenas preenche as tabelas neoitem e neoitefil, com os produtos elegiveis e dados cadastras */

def var vqtdestabs as int.  
def var t900    like estoq.estatual.
def var vproindice like produ.proindice. 
def var vpack as int.
def var vleadtime like abasresoper.leadtime.
def var vleadtimeINFO like abasresoper.leadtimeINFO.
def var vemite    like abasresoper.emite.
def var vtot as int.
def var vtemcompra as log.
def var vtemvenda  as log.
def var vtemestoq  as log.
def var vtemtempo  as log.
def var vtemtransf as log.
def buffer estoq900 for estoq.
def var vgrade as int.
def var vcar1 as char.
def var vsub1 as char.
def var vcar2 as char.
def var vsub2 as char.

def var xtime as int.
xtime = time.
def var vconta as int init 0.

function retira-acento returns character(input texto as character):

    define variable c-retorno as character no-undo.
    define variable c-letra   as character no-undo case-sensitive.
    define variable i-conta         as integer   no-undo.
    def var i-asc as int.
    def var c-caracter as char.

    do i-conta = 1 to length(texto):
        
        c-letra = substring(texto,i-conta,1).
        i-asc = asc(c-letra).
        
        if i-asc <= 160                         then c-caracter = c-letra.
        else if i-asc >= 161 and i-asc <= 191  or
                i-asc >= 215 and i-asc <= 216  or
                i-asc >= 222 and i-asc <= 223  or
                i-asc >= 247 and i-asc <= 248       then c-caracter = " ".
        else if i-asc >= 192 and i-asc <= 198       then c-caracter = "A".
        else if i-asc = 199                     then c-caracter = "C".
        else if i-asc >= 200 and i-asc <= 203       then c-caracter = "E".
        else if i-asc >= 204 and i-asc <= 207       then c-caracter = "I".
        else if i-asc =  208                     then c-caracter = "D".
        else if i-asc = 209                     then c-caracter = "N".
        else if i-asc >= 210 and i-asc <= 214       then c-caracter = "O".
        else if i-asc >= 217 and i-asc <= 220       then c-caracter = "U".
        else if i-asc = 221                     then c-caracter = "Y".
        else if i-asc >= 192 and i-asc <= 198       then c-caracter = "A".
        else if i-asc >= 224 and i-asc <= 230       then c-caracter = "a".
        else if i-asc = 231                     then c-caracter = "c".
        else if i-asc >= 223 and i-asc <= 235       then c-caracter = "e".
        else if i-asc >= 236 and i-asc <= 239       then c-caracter = "i".
        else if i-asc = 240                     then c-caracter = "o".
        else if i-asc = 241                     then c-caracter = "n".
        else if i-asc >= 242 and i-asc <= 246       then c-caracter = "o".
        else if i-asc >= 249 and i-asc <= 252       then c-caracter = "u".
        else if i-asc >= 253 and i-asc <= 255       then c-caracter = "y".
        else c-caracter = c-letra.
        c-retorno = c-retorno + c-caracter.

    end.
    if c-retorno = "" then c-retorno = "NULO".
    return c-retorno.
end function.

def buffer sclase   for clase.
def buffer grupo    for clase.
def buffer setclase for clase.
def buffer depto    for clase.

def var vestatual as dec.

vconta = 0.
vtot = 0.

hide message no-pause.
message today string(time,"HH:MM:SS") string(time - xtime,"HH:MM:SS") "Calculando Produtos,Estoques,mix...".
for each produ no-lock.
    
    find neoitem where neoitem.procod = produ.procod no-error.
    
        vtot = vtot + 1.
    /* filtros */
    if produ.catcod = 31 or
       produ.catcod = 41
    then.
    else do:
        if avail neoitem
        then neoitem.situacao = no.
        next.
    end.    
    
    if produ.proseq = 0
    then.
    else do:
        if avail neoitem
        then neoitem.situacao = no.
        next.
    end.    

    /* 08.04.19 Nova regra */
    vtemtempo = produ.prodtcad >= today - (15 * 30).
    
                   
    vconta = vconta + 1.
    if vconta mod 100 = 0 or vtot mod 100 = 0
    then do:
        hide message no-pause.
        message today string(time,"HH:MM:SS") string(time - xtime,"HH:MM:SS") "Exportando Produtos,Estoques..." vtot vconta.
        if vconta mod 1000 = 0 then pause 1.
    end.    

         
    
    find sClase     where sClase.clacod   = produ.clacod    no-lock no-error.
    if not avail sClase 
    then do on error undo.  
        next.
    end.        
    find Clase      where Clase.clacod    = sClase.clasup   no-lock no-error.
    if not avail clase 
    then do on error undo.
        next.
    end.
    find grupo      where grupo.clacod    = Clase.clasup    no-lock no-error.
    if not avail grupo 
    then do on error undo.
        next.
    end.
    find setClase   where setClase.clacod = grupo.clasup    no-lock no-error.  
    if not avail setclase 
    then do on error undo.
        next.
    end.
    find depto   where depto.clacod = setclase.clasup    no-lock no-error.   
    if not avail depto 
    then do on error undo.
        next.                  
    end.        
        
    if setClase.clacod = 0 
    then do on error undo.
        next.      
    end.
    if grupo.clacod = 0 
    then do on error undo.
        next.         
    end.
    if depto.clacod = 0 
    then do on error undo.
        next.         
    end.
    if Clase.clacod = 0 
    then do on error undo.
        next.         
    end.
    if sClase.clacod = 0 
    then do on error undo.
        next.        
    end.
    find categoria of produ no-lock no-error.
    find fabri of produ no-lock no-error.
    if avail fabri
    then find forne where forne.forcod = fabri.fabcod no-lock no-error.
    find estac where estac.etccod = produ.etccod no-lock no-error.
    find temporada where temporada.temp-cod = produ.temp-cod 
            /**and temporada.dtini <= today and
               (temporada.dtfim >= today or
                temporada.dtfim = ?)**/
            no-lock no-error.
    

        /* CRIA TEMP PARA COMPATIBILIDADE  COM PROGRAMA ANTERIOR */
        
    vproindice = retira-acento(produ.proindice).
    

        if not avail NEOITEM
        then do:
            create NEOITEM.
            neoitem.procod = produ.procod.
        end.
        assign 
           NEOITEM.ean     = if vproindice <> ?
                               then if trim(vproindice) = "SEM GTIN"
                                    then ""
                                    else vproindice                               
                               else "".
           NEOITEM.descr   = retira-acento(produ.pronom).
           NEOITEM.fornecedor = (if avail forne then string(forne.forcod) else "N/A").
           NEOITEM.unidade = "UN" /*if avail produ
                                  then produ.prouncom
                                  else "" */ .
           NEOITEM.emb     = "1"                .

           NEOITEM.categoria = string(produ.catcod) + "-" +
                                (if avail categoria then retira-acento(categoria.catnom) else "").

           /**NEOITEM.dgrupo1 = (if avail depto then string(depto.clacod) else "N/A" ) + 
                               (if avail depto then ("-" + retira-acento(depto.clanom)) else "").**/
           
           NEOITEM.clasetor = (if avail setclase then string(setclase.clacod) else "") + "-" +
                               (if avail setclase then retira-acento(setclase.clanom) else ""). 
           
           NEOITEM.clagrupo = (if avail grupo then string(grupo.clacod) else "") + "-" +
                               (if avail grupo then retira-acento(grupo.clanom) else "").
           
           NEOITEM.claclase = (if avail clase then string(clase.clacod) else "") + "-" +
                                (if avail clase then retira-acento(clase.clanom) else "").

           NEOITEM.clasclase = (if avail sclase then string(sclase.clacod) else "") + "-" +
                                (if avail sclase then retira-acento(sclase.clanom) else "").
                                

           if NEOITEM.categoria = "" or NEOITEM.categoria = "-"
           then NEOITEM.categoria  = "N/A".
           /**if NEOITEM.dgrupo1 = "" or NEOITEM.dgrupo1 = "-"
           then NEOITEM.dgrupo1  = "N/A".**/
           if NEOITEM.clasetor = "" or NEOITEM.clasetor = "-"
           then NEOITEM.clasetor  = "N/A".
           if NEOITEM.clagrupo  = "" or NEOITEM.clagrupo = "-"
           then NEOITEM.clagrupo  = "N/A".
           if NEOITEM.claclase = "" or NEOITEM.claclase = "-"
           then NEOITEM.claclase  = "N/A".
           if NEOITEM.clasclase = "" or NEOITEM.clasclase = "-"
           then NEOITEM.clasclase = "N/A".
            

           NEOITEM.estacao = string(produ.etccod) + "-" + (if avail estac then  retira-acento(estac.etcnom) else "N/A") .
           NEOITEM.temporada = string(produ.temp-cod)  + "-" + (if avail temporada then retira-acento(temporada.tempnom) else "N/A") .
             
        /*#1 caracteristicass */
        vcar1 = "VOLTAGEM".
        vsub1 = "NULO".
        find caract where caract.cardes = vcar1 no-lock no-error.
        if avail caract
        then do:
            for each subcaract of caract no-lock.
                find procaract of produ where
                    procarac.subcod = subcaract.subcod
                    no-lock no-error.
                if avail procaract
                then vsub1 = retira-acento(subcaract.subdes).
            end.
        end.
        /* 10.05.19
        vcar2 = "Modelo Geral".
        vsub2 = "N/A".
        find caract where caract.cardes = vcar2 no-lock no-error.
        if avail caract
        then do:
            for each subcaract of caract no-lock.
                find procaract of produ where
                    procarac.subcod = subcaract.subcod
                    no-lock no-error.
                if avail procaract
                then vsub2 = retira-acento(subcaract.subdes).
            end.
        end.
        */
        
        if vcar1 = "" then vcar1 = "N/A".
        if vsub1 = "" then vsub1 = "N/A". 
        /* 10.05.19
        if vcar2 = "" then vcar2 = "N/A".
        if vsub2 = "" then vsub2 = "N/A". 
        */
 
           NEOITEM.caract1   = if produ.catcod = 41
                                 then "REFERENCIA"
                                 else if vcar1 <> ""
                                      then vcar1
                                      else "N/A".
           NEOITEM.subcaract1   = if produ.catcod = 41
                                 then if produ.prorefter = ""
                                      then "N/A"
                                      else produ.prorefter
                                 else if vsub1 <> ""
                                      then vsub1
                                      else "N/A".
           NEOITEM.caract2   = /* 10.05.19 - sempre vai  descontinuado
                                 if produ.catcod = 41
                                 then*/ "Descontinuado"
                                 /* 10.05.19
                                 else if vcar2 <> ""
                                      then vcar2
                                      else "N/A"*/ .
           NEOITEM.subcaract2   = /* 10.05.19 - sempre vai descontinuado
                                 if produ.catcod = 41
                                 then*/ string(produ.descontinuado,"SIM/NAO")
                                 /* 10.05.19
                                 else if vsub2 <> ""
                                      then vsub2
                                      else "N/A"*/ .
                                 
                                 
         /*#1*/
                                 
           NEOITEM.tipo       = if produ.proipival = 1 then "PE"
                                 else if produ.ind_vex  then "VEX"
                                                        else "NORMAL". 
           
    find first produaux of produ where produaux.nome_campo = "PACK"
                no-lock no-error.

    vpack = (if avail produaux
             then int(produaux.valor_campo)
             else 0)
                no-error.
    if vpack = ? or vpack = 0 
    then vpack = 1.
    
        /* 22.06.19 retirado
        /* total_estoq eh apenas para final de regra se tem estoq geral ou nao*/
        total_estoq = 0.
        for each testoq where testoq.procod = produ.procod no-lock.
            total_estoq = total_estoq + if testoq.estatual < 0
                                        then 1  /* apenas para finas de regra */
                                        else testoq.estatual.
        end.               
        **/
    vqtdestabs = 0.
    for each estab no-lock.

        
        if estab.tipoLoja = "Virtual" then next.
        if estab.tipoLoja = "escritorio" then next.
        
        if    estab.etbcod = 995 
           or estab.etbcod = 988 /* 01.07.2019 */
        then next. 
            
        find first NEOitefil where NEOitefil.procod = produ.procod and
                                       NEOitefil.etbcod = estab.etbcod
                                no-error.
        if not avail NEOitefil
        then do:  
            create NEOitefil.  
            NEOitefil.etbcod = estab.etbcod.  
            NEOitefil.procod = produ.procod.  
        end. 

        NEOitefil.situacao = no. 
        NEOitefil.mix-grade = ?.

        find estoq900 where estoq900.etbcod = 900 and
                            estoq900.procod = produ.procod
                        no-lock no-error.
        t900 = if avail estoq900 
               then estoq900.estatual
               else 0.
        find estoq where estoq.etbcod = estab.etbcod and
                         estoq.procod = produ.procod
                    no-lock no-error.
        vestatual   = if avail estoq and estoq.estatual > 0
                      then estoq.estatual
                      else 0.

        vtemestoq   = t900 <> 0 or vestatual <> 0.
    
        /*24.04.2019 Nova regra */
        find last movim use-index icurva
            where movim.etbcod = estab.etbcod and
                  movim.procod = produ.procod and
                  movim.movtdc = 5            and
                  movim.movdat >= today - (15 * 30)
                  no-lock no-error.
        vtemvenda = avail movim.
        find last movim use-index icurva
                where movim.etbcod = estab.etbcod and
                      movim.procod = produ.procod and
                      movim.movtdc = 4            and
                      movim.movdat >= today - (15 * 30)
                      no-lock no-error.
        vtemcompra = avail movim.
        /*30.05.2019 Nova regra */
        find last movim use-index icurva
            where movim.etbcod = estab.etbcod and
                  movim.procod = produ.procod and
                  movim.movtdc = 6            and
                  movim.movdat >= today - (15 * 30)
                  no-lock no-error.
        vtemtransf = avail movim.
   
        if not vtemtempo and
           not vtemestoq and
           not vtemcompra and
           not vtemvenda and
           not vtemtransf
        then next.    
        
        vqtdestabs = vqtdestabs +  1.

                 
        /* Nova Regra */     
        
            /* mix */
            find temporada where temporada.temp-cod = produ.temp-cod 
                    and temporada.dtini <= today and
                       (temporada.dtfim >= today or
                        temporada.dtfim = ?)
                    no-lock no-error.
        
            for each mixmprod where mixmprod.procod = produ.procod and
                            mixmprod.situacao = YES no-lock. /* ENVIA */
        
                find first mixmgrupo where 
                                mixmgrupo.codgrupo = mixmprod.codgrupo 
                            and mixmgrupo.situacao = yes
                no-lock no-error.
                if not avail mixmgrupo
                then next.    
                find first mixmgruetb of mixmgrupo where 
                                    mixmgruetb.etbcod = estab.etbcod and
                                    mixmgruetb.situacao = yes
                no-lock no-error.
                if not avail mixmgruetb
                then next.
            
                if mixmgrupo.codgrupo = 147 /* ITIM */ 
                then next.
                                        
                /*300419*/            
                find abasgrade where 
                    abasgrade.etbcod = estab.etbcod and
                    abasgrade.procod = produ.procod
                    no-lock no-error.
                vgrade = if avail abasgrade
                         then abasgrade.abgqtd
                         else 0.
                if produ.catcod = 41
                then do:
                    if not avail temporada
                    then next. /*02.05.19 */
                end.

                NEOitefil.mix-grade = vgrade.
                NEOitefil.situacao  = yes.
            end.      
            /* mix Grade */


            find last abasresoper where
                abasresoper.etbcod = estab.etbcod and
                abasresoper.procod = produ.procod
                no-lock no-error.

            find abasLT where abasLT.emite = (if estab.etbcod >= 500
                                              then produ.fabcod 
                                              else 900) and
                              abasLT.etbcod = estab.etbcod
                    no-lock no-error.
                                
            vleadtimeINFO = if avail abasresoper
                            then if abasresoper.leadtimeINFO < 1 and
                                    abasresoper.leadtimeINFO > 0
                                 then 1 
                                 else round(abasresoper.leadtimeINFO,0)
                            else 0 .
            vleadtimeINFO = if vleadtimeINFO >= 1
                            then vleadtimeINFO
                            else if avail abasLT
                                 then round(if produ.catcod = 31
                                            then abasLT.leadtimeINFO
                                            else abasLT.modaleadtimeINFO,0) /*#31*/
                                 else 1 /*300419*/ .

            vleadtime = if avail abasresoper
                        then if abasresoper.leadtime < 1 
                             then 1 
                             else round(abasresoper.leadtime,0)
                        else 1 /*300419*/ .

            if vleadtimeINFO <> ? and vleadtimeINFO >= 1
            then vleadtime = vleadtimeINFO.

            vemite    = if estab.etbcod < 500
                        then 900
                        else if avail abasresoper
                             then abasresoper.emite
                             else produ.fabcod. 
            
            assign  
                    NEOitefil.sku-item-origem = if estab.etbcod >= 500
                                           then ""
                                           else string(produ.procod).
                    NEOitefil.sku-local-origem = if estab.etbcod >= 500
                                            then ""
                                            else string(vemite).
                    NEOitefil.sku-empresa-origem = if estab.etbcod >= 500
                                              then ""
                                              else string(1).
                    NEOitefil.sku-forne-origem = if estab.etbcod >= 500
                                            then string(vemite)
                                            else "".
                    NEOitefil.sku-LEADTIME       = replace(string(vleadtime,">>>>>9.999"),".",",").
                    NEOitefil.sku-LEADTIMEDP     = replace(string(if (vleadtime * 0.10) < 1 then 1 
                                                           else (vleadtime * 0.10),">>>>>9.999"),".",",").

                    NEOitefil.sku-lote           = replace(string(
                                                    (if estab.etbcod >= 500
                                                     then if produ.loteMinimo = 0 or 
                                                             produ.loteMinimo = ?
                                                          then vpack
                                                          else produ.loteMinimo
                                                     else vpack /* lojas */ ) ,">>>>>>>>>>9.999"),".",",").
            
                    NEOitefil.sku-unitizacao     =              replace(string(vpack,">>>>>>>>9.999"),".",",").
                
                NEOitefil.situacao = yes.                                      
                
    end. /* for each estab ... */

    
    neoitem.situacao = yes.
    
    
end.

hide message no-pause.

message today string(time,"HH:MM:SS") string(time - xtime,"HH:MM:SS") "Encerrando FASE 1".


