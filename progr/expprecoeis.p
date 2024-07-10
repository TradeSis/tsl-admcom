/*#1 - helio.neto - 13.08.19 - envio campo data_inclu, e colocacao do use-index correto */
/*#2 - helio.neto - 12.09.19 - refeita a logica de envio, para enviar apenas o vigente no dia */
/*#3 - helio.neto - 03.10.19 - desconsiderar remarcacoes quando tem promocao ativa */

def var vcp as char init ";".

def var varquivo as char init "/admcom/lebesintel/precoeis.csv".

def stream PRECO.
output stream PRECO to value(varquivo).

def var vestatual as int format ">>>>9".
def buffer sclase   for clase.
def buffer grupo    for clase.
def buffer setclase for clase.
def buffer depto    for clase.

def var vdata_inicio as date.

def var vtoday as date.
vtoday = today.
/*update vtoday.*/
def var vdata as date.
vdata = today - 1.
def var vtime as int.
vtime = time.

message "#1 INICIO" today string(vtime,"HH:MM:SS") "PROCESSANDO DESDE " vdata " para " varquivo.
def temp-table tt-preco-tabela
    field data_inclu    as date
    field preco       as dec.

def temp-table tt-preco no-undo
    field etbcod    like hisprpro.etbcod
    field procod    like hisprpro.procod
    field data_inicio   like hisprpro.data_inicio
    field preco_valor   like hisprpro.preco_valor
    field data_fim      like hisprpro.data_fim
    field datafimREAL   as date format "99/99/9999"
    field data_etq      as date
    field preco_tipo    like hisprpro.preco_tipo    
    field dias          as int
    field vigente       as log
    field exportar      as log
    index idx is unique primary
            etbcod asc procod asc data_inicio asc. 

def buffer btt-preco for tt-preco.

def var vt as int.
def var vp as int.
def var vr as int.
def var ve as int.
pause 0 before-hide.
for each produ 
    no-lock.
    vt = vt + 1.

    /* filtros */
    if produ.catcod = 31 or
       produ.catcod = 41
    then.
    else next.
    if produ.proseq = 0
    then.
    else next.
    vp = vp + 1.

    for each tt-preco. delete tt-preco. end.
    
    for each estab 
        no-lock.
        if estab.tipoLOJA <> "NORMAL"
        then next.
        vr = vr + 1.
        if vr < 2 or vr mod 30000 = 0
        then message "      " today string(vtime,"HH:MM:SS") "PROCESSANDO... " 
                            vt vp  vr ve string(time - vtime,"HH:MM:SS") " para " varquivo.
                            
        for each tt-preco-tabela. delete tt-preco-tabela. end.

        /* Pega Preco Tabela */
        for last hisprpro where hisprpro.procod = produ.procod and 
                                hisprpro.etbcod = estab.etbcod and 
                                (hisprpro.preco_tipo =  "T"  or
                                 hisprpro.preco_tipo = "R"   or
                                 hisprpro.preco_tipo = "C"
                                 )  and 
                                
                                hisprpro.data_inicio <= vtoday and 
                               (hisprpro.data_fim = ? or 
                                hisprpro.data_fim >= vtoday)
                                no-lock.
            create tt-preco-tabela.
            tt-preco-tabela.preco = hisprpro.preco_valor.
            tt-preco-tabela.data_inclu = hisprpro.data_inclu.
            vdata = hisprpro.data_inicio. /* Inicio tabela */
        end.
        /* Promocoes */
        for each hisprpro where hisprpro.procod = produ.procod and  
                                hisprpro.etbcod = estab.etbcod and 
                                hisprpro.preco_tipo <> "T"
                                no-lock.

            create tt-preco.
            tt-preco.etbcod      = hisprpro.etbcod.
            tt-preco.procod      = hisprpro.procod.
            tt-preco.data_inicio = hisprpro.data_inicio.
            tt-preco.data_fim    = hisprpro.data_fim.
            tt-preco.datafimREAL    = hisprpro.data_fim.
            tt-preco.preco_valor = hisprpro.preco_valor.
            tt-preco.preco_tipo  = hisprpro.preco_tipo. 
            tt-preco.data_etq    = hisprpro.data_inclu.
        end.
        for each tt-preco where tt-preco.etbcod = estab.etbcod.
            if vdata < tt-preco.data_inicio
            then do:
                find first btt-preco where btt-preco.etbcod = estab.etbcod and
                                           btt-preco.procod = produ.procod and
                                           btt-preco.data_inicio = vdata
                                           no-error.
                if not avail btt-preco
                then do:                           
                    create btt-preco.
                    btt-preco.etbcod      = estab.etbcod.
                    btt-preco.procod      = produ.procod.  
                    btt-preco.data_inicio = vdata.
                end.
                find first tt-preco-tabela no-error.
                if avail tt-preco-tabela
                then do:
                    btt-preco.preco_valor = tt-preco-tabela.preco.
                    btt-preco.preco_tipo = "T".
                    btt-preco.data_etq   = tt-preco-tabela.data_inclu.
                end.
            end.
            vdata = tt-preco.datafimREAL + 1.
        end.
        find last tt-preco where tt-preco.etbcod = estab.etbcod no-error.
        if avail tt-preco and 
           tt-preco.preco_tipo <> "T" and 
           tt-preco.datafimREAL <> ?
        then do:
            find first btt-preco where
                btt-preco.etbcod      = estab.etbcod and
                btt-preco.procod      = produ.procod and  
                btt-preco.data_inicio = tt-preco.datafimREAL + 1
                no-error.
            if not avail btt-preco
            then do:
                create btt-preco.
                btt-preco.etbcod      = estab.etbcod.
                btt-preco.procod      = produ.procod.  
                btt-preco.data_inicio = tt-preco.datafimREAL + 1.
            end.                
            find first tt-preco-tabela no-error.
            if avail tt-preco-tabela
            then do:
                btt-preco.preco_valor = tt-preco-tabela.preco.
                btt-preco.preco_tipo = "T".
                btt-preco.data_etq   = tt-preco-tabela.data_inclu.
            end.     
        end.

        for each tt-preco where (tt-preco.preco_tipo = "R" or tt-preco.preco_tipo = "C")
                    and tt-preco.etbcod = estab.etbcod by tt-preco.data_inicio.
            find btt-preco where recid(btt-preco) = recid(tt-preco).
            find prev btt-preco where 
                    btt-preco.etbcod = estab.etbcod and
                    btt-preco.data_ini < tt-preco.data_inicio no-error.
            if avail btt-preco 
            then do:
                if btt-preco.data_fim >= vtoday
                then do:
                    if btt-preco.preco_tipo = "P"
                    then delete tt-preco.
                end.    
           end.     
        end.
        
        for each tt-preco where tt-preco.etbcod = estab.etbcod by tt-preco.data_inicio.
            find btt-preco where recid(btt-preco) = recid(tt-preco).
            find prev btt-preco where 
                    btt-preco.etbcod = estab.etbcod and
                    btt-preco.data_ini < tt-preco.data_inicio no-error.
            if avail btt-preco 
            then btt-preco.datafimREAL = tt-preco.data_inicio - 1.
        end.
        for each tt-preco 
                where tt-preco.etbcod = estab.etbcod
                by tt-preco.data_inicio.
            tt-preco.dias = vtoday - tt-preco.data_inicio.
            if tt-preco.data_ini <= vtoday and 
                (tt-preco.datafimREAL >= vtoday or
                 tt-preco.datafimREAL = ?)
            then tt-preco.vigente = yes.         
            if tt-preco.vigente and tt-preco.dias = 0
            then tt-preco.exportar = yes.
            else do:
                if tt-preco.vigente and
                    (tt-preco.dias <=7 and tt-preco.dias > 0)
                then do:
                    /** teste do proximo dia
                    find btt-preco where recid(btt-preco) = recid(tt-preco).
                    find next btt-preco where 
                                btt-preco.etbcod = estab.etbcod and
                                btt-preco.data_ini > tt-preco.data_inicio no-error.
                    if avail btt-preco and
                       btt-preco.data_inicio = vtoday + 1
                      and btt-preco.preco_tipo <> "T"
                    then do:
                        tt-preco.exportar = no.
                        btt-preco.exportar = yes.
                    end.    
                    else */ tt-preco.exportar = yes.
                end. 
                else do:
                    /* teste do proximo dia
                    find btt-preco where recid(btt-preco) = recid(tt-preco).
                    find next btt-preco where 
                            btt-preco.etbcod = estab.etbcod and
                            btt-preco.data_ini > tt-preco.data_inicio no-error.
                    if avail btt-preco and
                       btt-preco.data_inicio = vtoday + 1
                    then do:
                        tt-preco.exportar = no.
                        btt-preco.exportar = yes.
                    end.    
                    */
                end.
            end. 
        end.
    end.

    find sClase     where sClase.clacod   = produ.clacod    no-lock no-error.
    if avail sClase 
    then do on error undo.  
        find Clase      where Clase.clacod    = sClase.clasup   no-lock no-error.
        if avail clase 
        then do on error undo.
            find grupo      where grupo.clacod    = Clase.clasup    no-lock no-error.
            if avail grupo 
            then do on error undo.
                find setClase   where setClase.clacod = grupo.clasup    no-lock no-error.  
                if avail setclase 
                then do on error undo.
                    find depto   where depto.clacod = setclase.clasup    no-lock no-error.   
                end.
            end.
        end.
    end.                
 
    for each tt-preco where tt-preco.exportar = no.
        delete tt-preco.
    end.    
    for each tt-preco:
        ve = ve + 1.
 
        
        find estoq where estoq.etbcod = tt-preco.etbcod and
                         estoq.procod = tt-preco.procod
                         no-lock no-error.
        vestatual = if avail estoq and estoq.estatual > 0 
                    then estoq.estatual
                    else 0.       
                          
    
        put stream PRECO unformatted 
            produ.procod        vcp
            tt-preco.etbcod     vcp
            string(tt-preco.data_inicio,"99/99/9999")    vcp
            if tt-preco.data_fim = ? then "NULL" else string(tt-preco.data_fim,"99/99/9999")       vcp
            tt-preco.preco_valor    vcp
            tt-preco.preco_tipo     vcp /*COMMENT 'P para promo; \nR para remarcação;\nFP para fim de promoção;\nT para tabela',*/
            string(tt-preco.data_etq,"99/99/9999")        vcp /*data_etq DATE NOT NULL,*/
            produ.pronom            vcp
            if avail setclase then setclase.clanom else "" vcp
            if avail grupo    then grupo.clanom    else "" vcp
            vestatual               vcp
        skip.     
        delete tt-preco.
        
    end.
    
end.                                       

message "FINAL " today string(vtime,"HH:MM:SS") "TEMPO:" string(time - vtime,"HH:MM:SS") "Exportados " Ve " para " varquivo.


