{admcab.i}

def shared var vdti as date.
def shared var vdtf as date.
def new shared var vacrescimo as dec.

def temp-table tt-vp
            field etbcod like estab.etbcod
            field data as date
            field valor as dec
            field acre as dec.
 
def shared temp-table tt-venda
        field etbcod like estab.etbcod
        field data as date
        field vl-prazo as dec 
        field vl-vista as dec
        field avista as dec
        field aprazo as dec
        index i1 etbcod data.
 
def shared temp-table tt-estab
    field etbcod like estab.etbcod
    .
/*
for each tt-estab:
    find first ctcartcl where
               ctcartcl.etbcod = tt-estab.etbcod and
               ctcartcl.datref = vdtf
               no-lock no-error.
    if avail ctcartcl and
       ctcartcl.acrescimo > 0
    then delete tt-estab.
end.
find first tt-estab no-error.
if not avail tt-estab
*/
find first ctcartcl where
           ctcartcl.datref >= vdti and
           ctcartcl.datref <= vdtf and
           ctcartcl.ecfprazo > 0  and
           ctcartcl.etbcod > 0
           no-lock no-error.
if not avail ctcartcl                                             
then do:
    message "PROCESSAR VENDAS." .
    PAUSE.
    return.               
end.
/*
find first ctcartcl where
           ctcartcl.datref >= vdti and
           ctcartcl.datref <= vdtf and
           ctcartcl.acrescimo > 0 and
           ctcartcl.etbcod > 0
           no-lock no-error.
if avail ctcartcl                                             
then do:
    message "JA PROCESSADO." .
    PAUSE.
    return.               
end.
*/
find first ctcartcl where
           ctcartcl.datref >= vdti and
           ctcartcl.datref <= vdtf and
           ctcartcl.etbcod = 0
           no-lock no-error.
if avail ctcartcl
then vacrescimo = ctcartcl.acrescimo.

def var v-perc as dec.
do on error undo, retry:
update vacrescimo label "Acrescimo"  format ">>,>>>,>>9.99"
       v-perc     label "% Susbt."   format ">>9.99%"
    with frame f-crescimo column 30 row 9 overlay side-label.
end.
if vacrescimo = 0
then return.    
sresp = no.
message "Confirma Processamento? " update sresp. 
if not sresp
then return.
def shared temp-table tt-acretb
    field etbcod like estab.etbcod
    field valor as dec
    field valpr as dec.

def var val-venda as dec.
val-venda = 0.
for each tt-estab :
    for each  ctcartcl where
          ctcartcl.etbcod = tt-estab.etbcod and
          ctcartcl.datref >= vdti and
          ctcartcl.datref <= vdtf
          no-lock .
        val-venda = val-venda + ctcartcl.ecfprazo.
    end.
end.    
def var vpra-z as dec.
for each tt-estab no-lock:
    vpra-z = 0.
    for each ctcartcl where 
             ctcartcl.etbcod = tt-estab.etbcod and
             ctcartcl.datref >= vdti and
             ctcartcl.datref <= vdtf
              no-lock :
        vpra-z = vpra-z + ctcartcl.ecfprazo.
    end.
                 
    if vpra-z <= 0
    then next.

    create tt-acretb.
    tt-acretb.etbcod = tt-estab.etbcod.
    tt-acretb.valor  = vacrescimo * (vpra-z / val-venda).
end.
    
def var totacr  like plani.platot.
def var acutot  like plani.platot.
def var minacr  like plani.platot.
def var varquivo as char format "x(30)".
def var v-sai    as log. 

def temp-table wplani
    field   wclicod  like clien.clicod
    field   wclinom  like clien.clinom
    field   wven     like plani.platot
    field   wacr     like plani.platot
        index ind-1 wclinom
        index ind-2 wclicod
        index ind-3 wven.

def temp-table wmovim
    field   wprocod  like produ.procod
    field   wpronom  like produ.pronom
    field   wven     like plani.platot
    field   wacr     like plani.platot
    field   wali     as dec
        index ind-1 wpronom
        index ind-2 wprocod
        index ind-3 wven.
 
def temp-table wicms
       field wali as dec
       field wven as dec
       field wacr as dec
       index i1 wali
       .
       
def var dt     like plani.pladat.

form with frame f-ind1.
def var vtotal as dec.
def var totn as dec.
def var tots as dec.
def var vacrn as dec.
def var vacrs as dec.
def var v99 as log.
def var vout as log.
def var vretornar as log.
def var v-descarta as log init no.
form with frame f-dd.
def var t-acr as dec init 0.
for each tt-estab  no-lock:
    find first tt-acretb where
               tt-acretb.etbcod = tt-estab.etbcod
               no-error.
    if not avail tt-acretb
    then next.
    tots = tt-acretb.valor * (v-perc / 100).
    totn = tt-acretb.valor - tots.
    t-acr = t-acr + tots + totn.
end.
find last tt-acretb where 
          tt-acretb.valor > 0.
if t-acr < vacrescimo
then tt-acretb.valor = vacrescimo - t-acr.

def var n-acr as dec.
def var d-acr as dec.             

for each tt-estab  no-lock:
    find first tt-acretb where
               tt-acretb.etbcod = tt-estab.etbcod
               no-error.
    if not avail tt-acretb
    then next.
    tots = tt-acretb.valor * (v-perc / 100).
    totn = tt-acretb.valor - tots.
    /*
    t-acr = t-acr + tots + totn.
    */
    v-sai = no.

    display "Processando acrescimo... "
            tt-estab.etbcod
            with frame f-dd 1 down centered no-label no-box
            color message. 
    pause 0.

    vacrn = 0.
    vacrs = 0.
    do dt = vdti to vdtf:
        disp dt no-label with frame f-dd.
        pause 0.
        for each plani use-index pladat 
                         where plani.movtdc = 5 and
                               plani.etbcod = tt-estab.etbcod and
                               plani.pladat = dt no-lock.

            if substr(string(plani.notped),1,1) <> "C"
            then next.
            if plani.desti  = 1  or
               (plani.biss <= (plani.platot /*- plani.vlserv*/))
            then next.
            if plani.crecod = 1
            then next.
            
            find clien where clien.clicod = plani.desti no-lock no-error.
            if not avail clien
            then next.
            
            if (plani.biss - (plani.platot /* - plani.vlserv*/)) < 2
            then next.

            v-descarta = no.
            for each movim where movim.etbcod = plani.etbcod and
                                     movim.placod = plani.placod and
                                     movim.movtdc = plani.movtdc
                                     no-lock:

                        find first produ where produ.procod = movim.procod 
                                no-lock.
               
                        if movim.movpc = 0 or
                            movim.movqtm = 0
                        then next.   
                    
                
                        find clafis where clafis.codfis = produ.codfis 
                            no-lock no-error. 

                        if not avail clafis or produ.codfis = 0  
                        then do:
                          if produ.pronom matches "*vivo*" or
                             produ.pronom matches "*tim*" or
                             produ.pronom matches "*claro*"
                         then v-descarta = yes.
                        end.     
            end.     
            if v-descarta = yes
            then next.
 
            find first contnf where contnf.etbcod = plani.etbcod
                           and contnf.placod = plani.placod no-lock
                           no-error.
            if  avail contnf 
            then do:
                find contrato where 
                     contrato.contnum = contnf.contnum
                     no-lock no-error.
                if avail contrato
                then do:
                    find first envfinan where  envfinan.empcod = 19
                                    and envfinan.titnat = no
                                    and envfinan.modcod = "CRE"
                                    and envfinan.etbcod = contrato.etbcod
                                    and envfinan.clifor = contrato.clicod
                                  and envfinan.titnum = string(contrato.contnum)
                                    no-lock no-error.
                            if  avail envfinan
                            then next.

                    find cpcontrato where
                                 cpcontrato.contnum = contrato.contnum
                                 no-error.
                    if not avail cpcontrato or
                        cpcontrato.indecf = no
                    then next.
                end.
            end.            
            
            if plani.biss <= plani.platot - plani.vlserv
            then next.
            
            v99 = no.
            vout = no. 
            vretornar = no.
            for each movim where movim.etbcod = plani.etbcod and
                                 movim.placod = plani.placod and
                                 movim.movtdc = plani.movtdc
                                 no-lock:
                find produ where produ.procod = movim.procod no-lock.
                if produ.pronom = "SALDO"
                then vretornar = yes. 
                if produ.proipiper = 99
                then v99 = yes.
                else vout = yes. 
            end. 
            if vretornar = yes
            then next.
            
            /****
            if vout = yes and
               vacrn >= totn
            then next.
            if v99 = yes and
               vacrs >= tots
            then next.   
            
            if (vacrn + vacrs + (plani.biss - 
                            (plani.platot - plani.vlserv))) > 
               (totn + tots + 1) 
            then next. 
 
            for each movim where movim.etbcod = plani.etbcod and
                                 movim.placod = plani.placod and
                                 movim.movtdc = plani.movtdc
                                 no-lock:
                find produ where produ.procod = movim.procod no-lock.

                find first wmovim where
                           wmovim.wprocod = movim.procod no-error.
                if not avail wmovim
                then do:
                    create wmovim.
                    assign
                        wmovim.wprocod = movim.procod 
                        wmovim.wpronom = produ.pronom
                        wmovim.wali = produ.proipiper.
                end.
                wmovim.wven = wmovim.wven +
                        ((plani.platot - plani.vlserv) * 
                        ((movim.movpc * movim.movqtm) /
                        (plani.platot - plani.vlserv)))
                        .
                if wmovim.wali = 99
                then vacrs = vacrs +
                        (((plani.biss) * 
                        ((movim.movpc * movim.movqtm) /
                        (plani.platot - plani.vlserv)))
                        - ((plani.platot - plani.vlserv) * 
                        ((movim.movpc * movim.movqtm) /
                        (plani.platot - plani.vlserv))))
                    .
                else vacrn = vacrn +
                        (((plani.biss) * 
                        ((movim.movpc * movim.movqtm) /
                        (plani.platot - plani.vlserv)))
                        - ((plani.platot - plani.vlserv) * 
                        ((movim.movpc * movim.movqtm) /
                        (plani.platot - plani.vlserv))))
                    .         

                wmovim.wacr = wmovim.wacr + 
                        (((plani.biss) * 
                        ((movim.movpc * movim.movqtm) /
                        (plani.platot - plani.vlserv)))
                        - ((plani.platot - plani.vlserv) * 
                        ((movim.movpc * movim.movqtm) /
                        (plani.platot - plani.vlserv))))
                    .    

            end.
            *****/
            
            vacrn = vacrn + (plani.biss - (plani.platot - plani.vlserv)).                     
            create wplani.
            assign wplani.wclicod = clien.clicod
                   wplani.wclinom = clien.clinom
                   wplani.wven    = plani.platot - plani.vlserv
                   wplani.wacr    = plani.biss - 
                            (plani.platot - plani.vlserv).
                   
            if cpcontrato.indacr = no
            then cpcontrato.indacr = yes.
            /****
            if vacrn + vacrs >= tots + totn
            then do:
                v-sai = yes.                     
                leave.
            end.
            ****/       
        end.
        /***
        if v-sai = yes
        then leave.   
        ***/
    end.
    tt-acretb.valpr = vacrn + vacrs .
end.
/****
t-acr = 0.
for each tt-acretb where tt-acretb.etbcod > 0 no-lock:
    if tt-acretb.valpr = 0
    then next.

    t-acr = t-acr + tt-acretb.valpr.
end.
n-acr = 0 .

d-acr = vacrescimo - t-acr.
message t-acr d-acr. pause.
/*I
run acrescimo.
*/

if d-acr > 10
then do:
    do dt = vdti to vdtf:
        for each plani use-index pladat 
                         where plani.movtdc = 5 and
                               plani.etbcod = 20 and
                               plani.pladat = dt
                               no-lock:

            if substr(string(plani.notped),1,1) <> "C"
            then next.
            if plani.desti  = 1  or
               (plani.biss <= (plani.platot - plani.vlserv))
            then next.
            if plani.crecod = 1
            then next.
            
            find clien where clien.clicod = plani.desti no-lock no-error.
            if not avail clien
            then next.
            
            if (plani.biss - (plani.platot - plani.vlserv)) < 2
            then next.

            v-descarta = no.
            for each movim where movim.etbcod = plani.etbcod and
                                     movim.placod = plani.placod and
                                     movim.movtdc = plani.movtdc
                                     no-lock:

                        find first produ where produ.procod = movim.procod 
                                no-lock.
               
                        if movim.movpc = 0 or
                            movim.movqtm = 0
                        then next.   
                    
                
                        find clafis where clafis.codfis = produ.codfis 
                            no-lock no-error. 

                        if not avail clafis or produ.codfis = 0  
                        then do:
                          if produ.pronom matches "*vivo*" or
                             produ.pronom matches "*tim*" or
                             produ.pronom matches "*claro*"
                         then v-descarta = yes.
                        end.     
            end.     
            if v-descarta = yes
            then next.
 
            find first contnf where contnf.etbcod = plani.etbcod
                           and contnf.placod = plani.placod no-lock
                           no-error.
            if  avail contnf 
            then do:
                find contrato where 
                     contrato.contnum = contnf.contnum
                     no-lock no-error.
                if avail contrato
                then do:
                    find first envfinan where  envfinan.empcod = 19
                                    and envfinan.titnat = no
                                    and envfinan.modcod = "CRE"
                                    and envfinan.etbcod = contrato.etbcod
                                    and envfinan.clifor = contrato.clicod
                                  and envfinan.titnum = string(contrato.contnum)
                                    no-lock no-error.
                            if  avail envfinan
                            then next.

                    find cpcontrato where
                                 cpcontrato.contnum = contrato.contnum
                                 no-error.
                    if not avail cpcontrato or
                        cpcontrato.indecf = no
                    then next.
                    if cpcontrato.indacr = yes
                    then next.
                end.
            end.            
            /*
            display  plani.pladat
                    plani.biss column-label "Valor" 
                        with frame f-dd. 
            pause 0.
            */
            if plani.biss <= plani.platot - plani.vlserv
            then next.
            if n-acr + (plani.biss - (plani.platot - plani.vlserv))
                > d-acr
            then next.    
            n-acr = n-acr + (plani.biss - (plani.platot - plani.vlserv)).
            
            if cpcontrato.indacr = no
            then cpcontrato.indacr = yes.
            
            if n-acr > d-acr
            then do:
                v-sai = yes.                     
                leave.
            end.
                   
        end.
        if v-sai = yes
        then leave.   
    end.
end. 

/*
run venda-prazo.
*/

find first tt-acretb where tt-acretb.etbcod = 20
        no-error.
tt-acretb.valpr = tt-acretb.valpr + n-acr.
*****/

for each tt-acretb where tt-acretb.etbcod > 0 no-lock:
    if tt-acretb.valpr = 0
    then next.
    find first ctcartcl where
               ctcartcl.etbcod = tt-acretb.etbcod and
               ctcartcl.datref = vdtf
               no-error.
    if not avail ctcartcl
    then do:
        create ctcartcl.
        assign
            ctcartcl.etbcod = tt-acretb.etbcod 
            ctcartcl.datref = vdtf
            .
    end.
    ctcartcl.acrescimo = tt-acretb.valpr.
end.

/*****
def var indice as char.
    indice = "ind-1".
    /***    
    display vlista no-label with frame f-lista centered no-label.
    choose field vlista with frame f-lista.
    if frame-index = 1
    then indice = "ind-1".
    if frame-index = 2
    then indice = "ind-2". 
    if frame-index = 3
    then indice = "ind-3".
    **/
    if opsys = "UNIX"
    then varquivo = "/admcom/relat/acfinpro" + string(time).
    else varquivo = "l:/relat/acfinpro" + string(time).

    {mdad_l.i
        &Saida     = "value(varquivo)"
        &Page-Size = "0"
        &Cond-Var  = "130"
        &Page-Line = "66"
        &Nom-Rel   = ""acr_fin""
        &Nom-Sis   = """SISTEMA CONTABIL"""
        &Tit-Rel   = """ACRESCIMO SOBRE A VENDA A PRAZO "" +
                        string(vdti,""99/99/9999"") + "" A "" +
                        string(vdtf,""99/99/9999"") "
        &Width     = "130"
        &Form      = "frame f-cabcab"}

        
        if indice = "ind-1"
        then do:
            vtotal = 0.
            for each wmovim use-index ind-1:
                find first wicms where 
                           wicms.wali = wmovim.wali no-error.
                if not avail wicms
                then do:
                    create wicms.
                    wicms.wali = wmovim.wali.
                end.
                assign
                    wicms.wven = wicms.wven + wmovim.wven
                    wicms.wacr = wicms.wacr + wmovim.wacr
                    .
                vtotal = wmovim.wven + wmovim.wacr.           
                display wmovim.wprocod column-label "Produto"
                        wmovim.wpronom column-label "Descricao"
                        wmovim.wali    column-label "ICMS"
                        wmovim.wven    column-label "Valor!Venda"
                            format ">>,>>>,>>9.99"
                        wmovim.wacr    column-label "Valor!Acrescimo"
                        vtotal(total) column-label "Valor!Total"
                            format ">>,>>>,>>9.99"
                            with frame f-ind1 down width 120.
                down with frame f-ind1.    
 
            end.
        end.
        
        if indice = "ind-2"
        then do:
            vtotal = 0.
            for each wmovim use-index ind-2:
                find first wicms where 
                           wicms.wali = wmovim.wali no-error.
                if not avail wicms
                then do:
                    create wicms.
                    wicms.wali = wmovim.wali.
                end.
                assign
                    wicms.wven = wicms.wven + wmovim.wven
                    wicms.wacr = wicms.wacr + wmovim.wacr
                    .
                vtotal = wmovim.wven + wmovim.wacr.
                display wmovim.wprocod column-label "Produto"
                        wmovim.wpronom column-label "Descricao"
                        wmovim.wali    column-label "ICMS"
                        wmovim.wven    column-label "Valor!Venda"
                        wmovim.wacr    column-label "Valor!Acrescimo"
                        vtotal(total) column-label "Valor!Total"
                            with frame f-ind1 down width 120.
                down with frame f-ind1.    
 
            end.
        end.
        
        if indice = "ind-3"
        then do:
            vtotal = 0.
            for each wmovim use-index ind-3:
                find first wicms where 
                           wicms.wali = wmovim.wali no-error.
                if not avail wicms
                then do:
                    create wicms.
                    wicms.wali = wmovim.wali.
                end.
                assign
                    wicms.wven = wicms.wven + wmovim.wven
                    wicms.wacr = wicms.wacr + wmovim.wacr
                    .

                vtotal = wmovim.wven + wmovim.wacr.
                display wmovim.wprocod column-label "Produto"
                        wmovim.wpronom column-label "Descricao"
                        wmovim.wali    column-label "ICMS"
                        wmovim.wven    column-label "Valor!Venda"
                        wmovim.wacr    column-label "Valor!Acrescimo"
                        vtotal(total) column-label "Valor!Total"
                            with frame f-ind1 down width 120.
              down with frame f-ind1.
            end.
        end.
        
        down(1) with frame f-ind1.
        vtotal = 0.
        for each wicms use-index i1:
            vtotal = wicms.wven + wicms.wacr.
            display "Totais ICMS" @ wmovim.wpronom column-label "Descricao"
                    wicms.wali    @ wmovim.wali  column-label "ICMS"
                    wicms.wven(total)  column-label "Valor!Venda"
                        format ">>,>>>,>>9.99"
                    wicms.wacr(total)  column-label "Valor!Acrescimo"
                    vtotal(total) column-label "Valor!Total"
                        format ">>,>>>,>>9.99"
                            with frame f-ind2 down width 120.
 
            down with frame f-ind2.
        end.
    output close.

    if opsys = "UNIX"
    then do:
        run visurel.p(varquivo,"").
    end.
    else do:    
        {mrod.i}
    end.
    
*****/    
    
procedure venda-prazo:
    def var vdata as date.
    def var vtitvlcob as dec.
    vacrescimo = 0.
    for each tt-vp:
        delete tt-vp.
    end.    
    for each estab no-lock:       
         
        disp "Reprocessando VENDA A PRAZO... "
            estab.etbcod no-label
            with frame f-vp 1 down centered color message
            side-label no-box.
        pause 0.
             
        do vdata = vdti to vdtf:
            disp vdata no-label with frame f-vp.
            pause 0.
            for each contrato where contrato.etbcod = estab.etbcod and
                                    contrato.dtinicial = vdata
                                    no-lock:
                if contrato.vltotal <= 0
                then next.
                find first contnf where 
                            contnf.etbcod = contrato.etbcod and
                            contnf.contnum = contrato.contnum
                        no-lock no-error.
                if not avail contnf
                then next.
                find first plani where plani.etbcod = contnf.etbcod and
                                 plani.placod = contnf.placod and
                                 plani.serie  = "V"
                                 no-lock no-error.
                if avail plani and
                   substr(string(plani.notped),1,1) <> "C"
                then next.                 

                find first envfinan where 
                                       envfinan.empcod = 19
                                    and envfinan.titnat = no
                                    and envfinan.modcod = "CRE"
                                    and envfinan.etbcod = contrato.etbcod
                                    and envfinan.clifor = contrato.clicod
                                  and envfinan.titnum = string(contrato.contnum)
                                    no-lock no-error.
                if  avail envfinan
                then next.

                find cpcontrato where 
                     cpcontrato.contnum = contrato.contnum
                      no-error.
                if not avail cpcontrato or
                    cpcontrato.indecf = no 
                then next.
                
                if cpcontrato.financeira <> 0 
                then next.
                
                find first tt-vp where tt-vp.etbcod = estab.etbcod and
                                       tt-vp.data = vdata
                                       no-error.
                if not avail tt-vp
                then do:
                    create tt-vp.
                    assign
                        tt-vp.etbcod = estab.etbcod
                        tt-vp.data   = vdata
                        .
                end. 
                
                if cpcontrato.indacr = yes
                then assign
                         vtitvlcob = vtitvlcob + cpcontrato.dec3
                         vacrescimo = vacrescimo +
                                (contrato.vltotal - cpcontrato.dec3)
                         tt-vp.acr = tt-vp.acr + 
                                (contrato.vltotal - cpcontrato.dec3)
                         tt-vp.valor = tt-vp.valor + cpcontrato.dec3 .
                
                else assign
                        vtitvlcob = vtitvlcob + contrato.vltotal
                        tt-vp.valor = tt-vp.valor + contrato.vltotal
                    .     
            end.
        end.
    end.

    for each ctcartcl where
             ctcartcl.etbcod > 0 and
             ctcartcl.datref >= vdti and
             ctcartcl.datref <= vdtf
             :
        ctcartcl.ecfprazo = 0.
        ctcartcl.acrescimo = 0.
    end.             
    for each tt-vp where tt-vp.etbcod > 0:
        find first ctcartcl where
               ctcartcl.etbcod = tt-vp.etbcod and
               ctcartcl.datref = tt-vp.data
               no-error.
        if not avail ctcartcl
        then do:
            create ctcartcl.
            assign
                ctcartcl.etbcod = tt-vp.etbcod 
                ctcartcl.datref = tt-vp.data
                .
        end.
        assign
            ctcartcl.ecfprazo = tt-vp.valor
            ctcartcl.acrescimo = tt-vp.acr 
            .
    end.
end procedure.

procedure acrescimo:
    def var vdata as date.
    def var vval as dec.
    vval = 0.
    for each estab no-lock:       
             
        disp "Ajustando acrescimo... "
            estab.etbcod no-label
            with frame f-acr 1 down centere no-box color message
            side-label. 
        pause 0.
             
        do vdata = vdti to vdtf:

             disp vdata no-label with frame f-acr.
             pause 0.
             for each contrato where contrato.etbcod = estab.etbcod and
                                    contrato.dtinicial = vdata
                                    no-lock:
                if contrato.vltotal <= 0
                then next.
                find first contnf where 
                            contnf.etbcod = contrato.etbcod and
                            contnf.contnum = contrato.contnum
                        no-lock no-error.
                if not avail contnf
                then next.
                find first plani where plani.etbcod = contnf.etbcod and
                                 plani.placod = contnf.placod and
                                 plani.serie  = "V"
                                 no-lock no-error.
                if avail plani and
                   substr(string(plani.notped),1,1) <> "C" 
                then next.                 

                find first envfinan where 
                                       envfinan.empcod = 19
                                    and envfinan.titnat = no
                                    and envfinan.modcod = "CRE"
                                    and envfinan.etbcod = contrato.etbcod
                                    and envfinan.clifor = contrato.clicod
                                  and envfinan.titnum = string(contrato.contnum)
                                    no-lock no-error.
                if  avail envfinan
                then next.

                find cpcontrato where 
                     cpcontrato.contnum = contrato.contnum
                      no-error.
                if not avail cpcontrato or
                    cpcontrato.indecf = no 
                then next.
                
                if cpcontrato.financeira <> 0 
                then  next.
                
                if d-acr > 0 
                then do:
                    if cpcontrato.indacr = no
                        and contrato.vltotal - cpcontrato.dec3 > 0
                        and vval + (contrato.vltotal - cpcontrato.dec3) 
                            <= d-acr
                    then do:
                        vval = vval + (contrato.vltotal - cpcontrato.dec3).
                        cpcontrato.indacr = yes.
                    end.
                end.
                
                /**
                else if vsinal = "-"
                then do:
                if cpcontrato.indacr = yes
                   and contrato.vltotal - cpcontrato.dec3 > 0
                   and vval + (contrato.vltotal - cpcontrato.dec3) 
                        <= val-somdim
                then do:
                        vval = vval + (contrato.vltotal - cpcontrato.dec3).
                        cpcontrato.indacr = no.
                end.

                end.
                end.
                
                find first tt-vp where tt-vp.etbcod = estab.etbcod and
                                       tt-vp.data = vdata
                                       no-error.
                if not avail tt-vp
                then do:
                    create tt-vp.
                    assign
                        tt-vp.etbcod = estab.etbcod
                        tt-vp.data   = vdata
                        .
                end. 
                
                if cpcontrato.indacr = yes
                then assign
                         vtitvlcob = vtitvlcob + cpcontrato.dec3
                         vacrescimo = vacrescimo +
                                (contrato.vltotal - cpcontrato.dec3)
                         tt-vp.acr = tt-vp.acr + 
                                (contrato.vltotal - cpcontrato.dec3)
                         tt-vp.valor = tt-vp.valor + cpcontrato.dec3 .
                
                else assign
                        vtitvlcob = vtitvlcob + contrato.vltotal
                        tt-vp.valor = tt-vp.valor + contrato.vltotal
                    .
                **/         
            end.
            /**
            if vval < val-somdim
            then val-sobra = val-somdim - vval.
 
            end.
            **/
        end.
    end.
end procedure.
