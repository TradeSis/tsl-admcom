{admcab.i}
def var vpreco like estoq.estvenda.
def var vprecoc like estoq.estvenda.
def temp-table tterr no-undo
    field procod like produ.procod
    field etbcod like estoq.etbcod
    field preco like estoq.estvenda column-label "PV"
    index idx is unique primary procod asc etbcod asc.
def var vi as int.    

   def var varq as char format "x(60)".
   def var vcp  as char init ";".
   varq = "/admcom/relat/" + "precoerro_" +
                             "id"   + string(today,"999999")  + replace(string(time,"HH:MM:SS"),":","") +
                             ".csv" .
                               
    pause 0.
    update skip(2) varq skip(2)
        with
        centered 
        overlay
        color messages
        no-labels
        row 8
        title "arquivo csv de erros de precos nas filiais".
  pause 0 before-hide.

for each produ no-lock.
                    if produ.catcod = 41 or
                       produ.catcod = 31 
                    then.
                    else next.
                    if produ.proseq = 0
                    then.
                    else next.

    vpreco = 0.
    vi = vi + 1.
    if vi = 1 or vi mod 100 = 0 then disp vi with centered 1 down no-labels.
    
    find estoq where estoq.etbcod = 1 and estoq.procod = produ.procod no-lock no-error.
    vpreco = if avail estoq then estoq.estvenda else 0.
    for each estab 
            where estab.etbcod < 500
            no-lock.
        find estoq where estoq.etbcod = estab.etbcod and estoq.procod = produ.procod no-lock no-error.
        vprecoc = if avail estoq then estoq.estvenda else 0.
        if vprecoc <> vpreco
        then do:
            find first tterr where tterr.procod = produ.procod and tterr.etbcod = 1 no-error.
            if not avail tterr
            then do:
                create tterr.
                tterr.procod = produ.procod.
                tterr.etbcod = 1.
                tterr.preco  = vpreco.
            end.
            create tterr.
            tterr.procod = produ.procod.
            tterr.etbcod = estab.etbcod.
            tterr.preco  = vprecoc.
        end.            
    end.
    if vi > 1000
    then leave.
    
end.

pause before-hide.

       
    output to value(varq).    
            
        put unformatted
        "Produto" vcp
        "Filial" vcp
        "Preco" vcp
        "Promocao" vcp
        "Dt Ult Alt" vcp
        "Categoria"  vcp
        skip.


for each tterr.
    find produ where produ.procod = tterr.procod no-lock. 
    find estoq  where estoq.etbcod = tterr.etbcod and
                      estoq.procod = produ.procod
                       no-lock no-error.
    put unformatted 
    produ.procod vcp
    tterr.etbcod vcp
    tterr.preco vcp
    if avail estoq then estoq.estproper else 0 vcp /* Promocao */
    produ.datexp format "99/99/9999"     vcp             /* Ultima alteracao */
    produ.catcod vcp
    skip.
    
    
    
end.


    
    output close.
    message varq "gerado com sucesso.".
    pause 2 no-message.


