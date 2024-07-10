/** 16/05/2017 - #1 Projeto Moda no ecommerce */

def var vpack as int. /* #1 */
def var varredonda as int. /* #1 */
def var vporcao as dec. /* #1 */
def var vinteiro as int. /* #1 */

def temp-table tt-proven
    field procod like produ.procod
    field qtdven like movim.movqtm
    field qtdres like movim.movqtm
    field mesven as int
    field anoven as int
    index i1 procod mesven anoven
     .
def var vqtd-ven as dec.
for each plani where plani.etbcod = 200 and
                     plani.movtdc = 5 and
                     plani.pladat >= today - 90 and
                     plani.pladat <= today - 1  and
                     plani.modcod = "FIN" and
                     plani.notsit = no
                     no-lock:
    for each movim where
             movim.etbcod = plani.etbcod and
             movim.movtdc = plani.movtdc and
             movim.placod = plani.placod and
             movim.movdat = plani.pladat 
        no-lock.

        find first tt-proven where
                   tt-proven.procod = movim.procod /*and
                   tt-proven.anoven = year(movim.movdat) and
                   tt-proven.mesven = month(movim.movdat)*/
                   no-error.
        if not avail tt-proven
        then do:
            create tt-proven.
            assign
                tt-proven.procod = movim.procod
                tt-proven.anoven = year(movim.movdat)
                tt-proven.mesven = month(movim.movdat)
                .
        end.
        tt-proven.qtdven = tt-proven.qtdven + movim.movqtm.           
    end.    
end.

def var vqtd as dec.
def var v-cobertura as dec.
def var v-disponivel as dec.
assign
    v-cobertura  = 0
    v-disponivel = 0
    .
find last tbcntgen where
              tbcntgen.tipcon = 12 no-lock no-error.
if avail tbcntgen
then
    assign
        v-cobertura  = tbcntgen.valor
        v-disponivel = tbcntgen.quantidade
        .
if v-cobertura = 0 or v-disponivel = 0
then return.
def var v-reserva as dec.
for each tt-proven:
    
    v-reserva = (tt-proven.qtdven / 3) 
    
    /** (v-cobertura))
                     v-disponivel)**/.
                    
    /*
    v-reserva = (((tt-proven.qtdven / 3) * (v-cobertura / 30))
                    * v-disponivel).
    */
    /*
    message ((tt-proven.qtdven / 3) * 30 / 30) * (1 / 100)
            v-reserva 
          int(substr(string(v-reserva,"9999999999.99"),12,2))
          int(substr(string(v-reserva,"9999999999.99"),1,10))
                 .
                */
    /* #1 */
    find produ where produ.procod = tt-proven.procod no-lock no-error.
    if avail produ
    then do:
        if produ.catcod = 41
        then do: 
            vpack = 0. 
            find produaux where      
                produaux.procod = produ.procod and 
                produaux.nome_campo = "Pack" 
                no-lock no-error. 
            if avail produaux                 
            then vpack = int(produaux.valor_campo).
            if vpack > 0
            then do:
                do:
                    vinteiro   =  truncate(tt-proven.qtdven / vpack,0).
                    vporcao    =  truncate(tt-proven.qtdven / vpack,2) -                                         vinteiro.
                    varredonda = vinteiro + if vporcao <> 0 then 1 else 0.
                    vqtd = varredonda * vpack.
                end. 
            end.                
        end.
    end.
    else do:
                
       if int(substr(string(v-reserva,"9999999999.99"),12,2)) <> 0
        then vqtd = int(substr(string(v-reserva,"9999999999.99"),1,10)) 
                + 1.
        else vqtd = v-reserva.
    end.
    tt-proven.qtdres = vqtd.
end.

def temp-table tt-prodistr like prodistr
        index i1 procod.
def temp-table ctt-prodistr like tt-prodistr .
def var vestoq_depos as dec.
def var vreservas as dec.
def var vdisponivel as dec.
def var vreserv-ecom as dec.
for each tt-proven .
    find produ where produ.procod = tt-proven.procod no-lock no-error.
    if not avail produ then next.
    
    

    assign
        vdisponivel = 0
        vestoq_depos = 0
        vreservas = 0
        .

    find first prodistr where 
                     prodistr.etbabast      = 200           and
                     prodistr.lipsit        = "A"           and
                     prodistr.tipo          = "ECOM"        and
                     prodistr.procod        = produ.procod  and
                     prodistr.predt        <= today         and 
                     prodistr.SimbEntregue >= today 
                     no-lock no-error.
    if avail prodistr
    then next. 
 
    run /admcom/progr/reserv_ecom.p (input produ.procod, 
                                     output vreserv-ecom).
                                     
    if tt-proven.qtdres < vreserv-ecom
       or 
       produ.catcod = 41 /* #1 */
    then do on error undo:
    
        if produ.catcod = 41 /* #1 */
        then do: 
            
            find com.estoq where com.estoq.etbcod = 900
                 and com.estoq.procod = produ.procod  
                         no-lock no-error.
            vestoq_depos = vestoq_depos + (if avail com.estoq 
                                       then com.estoq.estatual 
                                       else 0).
            vdisponivel = vestoq_depos - vreserv-ecom.
            vqtd = tt-proven.qtdres.
            
            if vdisponivel - vqtd < 0
            then do:
                vpack = 0. 
                find produaux where      
                    produaux.procod = produ.procod and 
                    produaux.nome_campo = "Pack" 
                    no-lock no-error. 
                if avail produaux                 
                then vpack = int(produaux.valor_campo).
                if vpack > 0
                then do:
                    varredonda = truncate(vdisponivel / vpack,0).
                    vqtd = varredonda * vpack.
                    
                end. 
                else do:
                    vqtd = vdisponivel.
                end.
            end.                
            tt-proven.qtdres = vqtd + vreserv-ecom.    
            
        end.
        if tt-proven.qtdres > 0
        then run cria-reserva-ECM.            
    end.
    else if tt-proven.qtdres > vreserv-ecom
        then do:
            run /admcom/progr/corte_disponivel_wms.p (input  produ.procod, 
                                     output vestoq_depos, 
                                     output vreservas,  
                                     output vdisponivel). 
            if vdisponivel > 0 and
                (vdisponivel * v-disponivel) > tt-proven.qtdres - vreserv-ecom
            then do: 
                run cria-reserva-ECM.
            end.
            else if vdisponivel > 0
                then do:
                    tt-proven.qtdres = (vdisponivel * v-disponivel) +
                                vreserv-ecom.
                    run cria-reserva-ECM.
                end.
                                
        end.       
end.
def var varquivo as char.
varquivo = "/admcom/relat/reserva-automatica-ECM-" + string(time) + ".csv".

output to value(varquivo).
put "Produto;Descricao;Reserva;DtIni;DtFim;Disponivel;Venda90;Media3" skip.
for each tt-prodistr:
    find produ where produ.procod = tt-prodistr.procod no-lock no-error.
    if not avail produ then next.
    put tt-prodistr.procod   ";"
        produ.pronom         ";"
        tt-prodistr.lipqtd   ";"
        tt-prodistr.predt    ";"
        tt-prodistr.SimbEntregue ";"
        tt-prodistr.int1         ";"
        tt-prodistr.int2     ";"
        tt-prodistr.dec1     ";"
        skip.
end.
output close.
/***** CRIA NOVAS RESERVAS *****/           
for each tt-prodistr:
    create prodistr.
    tt-prodistr.numero   = next-value(prodistr).
    tt-prodistr.lipseq   = tt-prodistr.numero .
    buffer-copy tt-prodistr to prodistr.
end.    

/***** CANCELA RESERVAS INATIVAS *******/
for each ctt-prodistr:
    find prodistr where prodistr.etbabast = ctt-prodistr.etbabast and
                        prodistr.lipseq   = ctt-prodistr.lipseq
                        exclusive no-error.
    if avail prodistr
    then do:
        if ctt-prodistr.lipsit = "C"
        then prodistr.lipsit = "C".
        else if prodistr.predt = today
            then assign
                    prodistr.SimbEntregue = today
                    prodistr.lipsit = "C".
            else prodistr.SimbEntregue = today - 1.
    end.    
end.  
procedure cria-reserva-ECM:
    for each prodistr where 
                     prodistr.etbabast      = 200           and
                     prodistr.lipsit        = "A"           and
                    (prodistr.tipo          = "ECOM" or        
                     prodistr.tipo          = "ECMA")       and
                     prodistr.procod        = produ.procod  and
                     prodistr.SimbEntregue < today - 30 no-lock.
        create ctt-prodistr.
        buffer-copy prodistr to ctt-prodistr.        
        ctt-prodistr.lipsit = "C".
    end.
    
    for each prodistr where 
                     prodistr.etbabast      = 200           and
                     prodistr.lipsit        = "A"           and
                     prodistr.tipo          = "ECMA"        and
                     prodistr.procod        = produ.procod  and
                     prodistr.SimbEntregue  > today
                     no-lock:
        create ctt-prodistr.
        buffer-copy prodistr to ctt-prodistr.
    end.
    
    create tt-prodistr.
    assign
            tt-prodistr.etbabast = 200
            tt-prodistr.etbcod   = 200
            tt-prodistr.tipo     = "ECMA"
            tt-prodistr.procod   = produ.procod
            tt-prodistr.lipqtd   = tt-proven.qtdres
            tt-prodistr.predt    = today
            tt-prodistr.SimbEntregue = today + v-cobertura
            tt-prodistr.int1     = vdisponivel
            tt-prodistr.int2     = tt-proven.qtdven
            tt-prodistr.dec1     = tt-proven.qtdven / 3
            .
end procedure.
