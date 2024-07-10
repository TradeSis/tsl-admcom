{admcab.i new}

def var vmovtot as dec.
def var vmovfre as dec.
def var vmovseg as dec.
def var vmovacre as dec.
def var vmovipi as dec.
def var vmovdacess as dec.
def var vmovdes as dec.
def var vpis as dec.
def var vcofins as dec.
def var vsubst as dec.
def var vicms as dec.
def var vqtd-ant as dec.
def var vqtd-atu as dec.
def var vcto-ant as dec.
def var vcto-atu as dec.
def var vmovcusto as dec.
def var vcustom as dec.
def var vcusto_medio_anterior as dec.
def var vcusto_medio_atual as dec.
def temp-table tt-produ
    field procod like produ.procod
    index i1 procod.
def var vcatcod like produ.catcod.
def var vprocod like produ.procod.
def var vdata as date.
vdata = today - 3.
vdata = date(month(vdata),01,year(vdata)).

/**
update vprocod.
update vcatcod when vprocod = 0 .
update vdata.
**/

def buffer bmovim for movim.
def buffer bmvcusto for mvcusto.

if vprocod > 0
then
for each produ where produ.procod = vprocod no-lock:

    vmovcusto = 0.

    find first bmvcusto where bmvcusto.procod = produ.procod and
                              bmvcusto.dativig >= vdata
                              no-lock no-error.
    if not avail bmvcusto and
        not can-find(first bmovim where
                          bmovim.movtdc = 4 and
                          bmovim.procod = produ.procod and
                          bmovim.datexp >= vdata)
    then next.
    
    assign
        vmovcusto = 0
        vcusto_medio_anterior = 0
        vcusto_medio_atual = 0
        .

    run ver-mvcusto.
    
    if  vmovcusto = ? or 
        vmovcusto = 0 or
        vcusto_medio_anterior = ? or
        vcusto_medio_anterior = 0 or
        vcusto_medio_atual = ? or
        vcusto_medio_atual = 0
     then do:    
          
        for each mvcusto where
                 mvcusto.procod = produ.procod and
                 mvcusto.dativig >= vdata and
                 mvcusto.dativig <= today:
            delete mvcusto.
        end.
        find first bmovim where
               bmovim.movtdc = 4 and
               bmovim.procod = produ.procod and
               bmovim.datexp >= vdata
               no-lock no-error.
        if avail bmovim 
        then 
        run /admcom/progr/calctom-pro.p(input produ.procod, 
                          input vdata,
                          input today,
                          input "REPROCESSAMENTO").
        
    end.
end.             
else do:
    for each produ  where
        (if vcatcod > 0 then produ.catcod = vcatcod else true) 
        no-lock:

        output to ./pro-cal-ctom.ult.
        put produ.procod format ">>>>>>>>>9"
        " " vcatcod.
        output close.
    
        vmovcusto = 0.

        find first bmvcusto where bmvcusto.procod = produ.procod and
                              bmvcusto.dativig >= vdata
                              no-lock no-error.
        if not avail bmvcusto and 
            not can-find(first bmovim where
                          bmovim.movtdc = 4 and
                          bmovim.procod = produ.procod and
                          bmovim.datexp >= vdata)
        then next.
    
        assign
            vmovcusto = 0
            vcusto_medio_anterior = 0
            vcusto_medio_atual = 0
            .

        run ver-mvcusto.
    
        if  vmovcusto = ? or 
            vmovcusto = 0 or
            vcusto_medio_anterior = ? or
            vcusto_medio_anterior = 0 or
            vcusto_medio_atual = ? or
            vcusto_medio_atual = 0
        then do:  
        
            for each mvcusto where
                 mvcusto.procod = produ.procod and
                 mvcusto.dativig >= vdata and
                 mvcusto.dativig <= today:
                delete mvcusto.
            end.
 
            find first bmovim where
               bmovim.movtdc = 4 and
               bmovim.procod = produ.procod and
               bmovim.datexp >= vdata
               no-lock no-error.
            if avail bmovim 
            then 
            run /admcom/progr/calctom-pro.p(input produ.procod, input vdata,
                                              input today,
                                              input "REPROCESSAMENTO").
        end.
    end. 
    for each tt-produ: delete tt-produ. end.
    for each plani where    plani.movtdc = 4 and
                            plani.desti = 900 and
                            plani.dtinclu >= vdata 
                            no-lock:
        find first mvcusto where mvcusto.etbcod = plani.etbcod and
                                 mvcusto.placod = plani.placod and
                                 mvcusto.serie  = plani.serie
                                 no-lock no-error.
        if avail mvcusto
        then next.
                                 
        for each movim where movim.etbcod = plani.etbcod and
                             movim.placod = plani.placod and
                             movim.movtdc = plani.movtdc
                             no-lock:
            find produ where produ.procod = movim.procod no-lock no-error.
            if not avail produ then next.
            if vcatcod > 0 and produ.catcod <> vcatcod
            then next.
            find first tt-produ where 
                       tt-produ.procod = movim.procod no-lock no-error.
            if avail tt-produ
            then next.
            find first mvcusto where mvcusto.procod = movim.procod and
                                     mvcusto.etbcod = movim.etbcod and
                                     mvcusto.placod = movim.placod and
                                     mvcusto.serie  = plani.serie
                                     no-lock no-error.
            if not avail mvcusto
            then do:                         
                create tt-produ.
                tt-produ.procod = movim.procod.
            end.
        end.
    end.
    for each tt-produ where tt-produ.procod > 0 no-lock:
        find produ where produ.procod = tt-produ.procod no-lock no-error.
        run /admcom/progr/calctom-pro.p
            (input produ.procod, input vdata,
                                              input today,
                                              input "REPROCESSAMENTO").
    end.         
end.
procedure ver-mvcusto:

    def var vplani as log.
    def var vmovim as log.
    def buffer smvcusto for mvcusto.
    find last smvcusto where 
              smvcusto.procod = produ.procod and
              smvcusto.dativig < vdata
              no-lock no-error.
    if avail smvcusto
    then vcusto_medio_anterior = smvcusto.valctomedio.
    vplani = no.
    vmovim = no.
    for each mvcusto where 
                   mvcusto.procod = produ.procod and
                   mvcusto.dativig >= vdata 
                   no-lock.
        find plani where plani.movtdc = 4 and
                     plani.etbcod = mvcusto.etbcod and
                     plani.placod = mvcusto.placod and
                     plani.serie  = mvcusto.serie
                     no-lock no-error.
        if avail plani
        then do:
            vplani = yes.
            find forne where forne.forcod = plani.emite no-lock no-error.
            find movim where movim.procod = mvcusto.procod and
                     movim.etbcod = mvcusto.etbcod and
                     movim.placod = mvcusto.placod and
                     movim.movtdc = 4
                     no-lock no-error.
            if not avail movim
            then do:
                vmovim = no.
                vmovcusto = ?.
                leave.
            end.
            else vmovim = yes.
        end.
        else do:
            vplani = no.
            vmovcusto = ?.
            leave.
        end.
        if vcusto_medio_anterior > 0 and 
           mvcusto.custo1 <> vcusto_medio_anterior
        then vcusto_medio_anterior = 0.
        else vcusto_medio_anterior = mvcusto.valctomedio.
        
        vcusto_medio_atual    = mvcusto.valctomedio. 

        vmovtot = dec(acha("valprodu",mvcusto.char2)).
        vmovfre = dec(acha("valfrete",mvcusto.char2)).
        vmovseg = dec(acha("valseg",mvcusto.char2)).
        vmovacre = dec(acha("valacre",mvcusto.char2)).
        vmovipi = dec(acha("valipi",mvcusto.char2)).
        vmovdacess = dec(acha("valdesp",mvcusto.char2)).
        vmovdes = dec(acha("valdes",mvcusto.char2)).
        vpis = dec(acha("valpis",mvcusto.char2)).
        vcofins = dec(acha("valcofins",mvcusto.char2)).
        vsubst = dec(acha("valsubst",mvcusto.char2)).
        vicms = dec(acha("valicms",mvcusto.char2)).

        vqtd-ant = dec(acha("qtdestant",mvcusto.char1)).
        vqtd-atu = dec(acha("qtdestatu",mvcusto.char1)).
        vcto-ant = dec(acha("ctomedant",mvcusto.char1)).
        vcto-atu = dec(acha("ctomedatu",mvcusto.char1)).
        
        def var vmovqtm as dec.
        vmovqtm = 0.
        if avail movim
        then vmovqtm = movim.movqtm.
        else vmovqtm = vqtd-atu.

        def var vmovii as dec.

        vmovii = dec(acha("valii",mvcusto.char2)).
        if vmovii = ? then vmovii = 0.
        
        assign
            vmovcusto = vmovtot + vmovfre + vmovseg + vmovacre + vmovii
             + vmovipi + vmovdacess - vmovdes - vpis - vcofins 
             + vsubst - vicms
            vcustom = ((vcto-ant * vqtd-ant) + (vmovcusto * vmovqtm))
            / vqtd-atu.
    
        if round(vcustom,2) <> mvcusto.valctomedio
        then vmovcusto = 0.

        if vcto-ant = 0 or
           vcto-ant = ?
        then do:
            find first bmvcusto where
                      bmvcusto.procod = produ.procod and
                      bmvcusto.dativig < mvcusto.dativig
                      no-lock no-error.
            if avail bmvcusto
            then vmovcusto = 0.
        end.

        if vplani = no or vmovim = no 
        then vmovcusto = ?.
        
        if  vmovcusto = ? or 
            vmovcusto = 0 or
            vcusto_medio_anterior = ? or
            vcusto_medio_anterior = 0 or
            vcusto_medio_atual = ? or
            vcusto_medio_atual = 0
        then leave. 

    end.
end procedure.

message "FIM" today string(time,"hh:mm:ss").
pause 0.

return.