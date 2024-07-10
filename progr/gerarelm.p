propath = "/admcom/progr,/usr/dlc".
    
    
{/admcom/progr/admcab-batch.i new}

def var vetbcod like estab.etbcod.
def var vhora   as   int.
def var vdata   as   date format "99/99/9999".
def var vparam as char.
def var vprogr as char.
def var vfilial    as   char.
def var varquivo   as   char.

repeat:
        
    pause 1 no-message.

    assign vfilial = "" vhora = 0 vetbcod  = 0 varquivo = "" vdata = today.

    find first gerarel /*where gerarel.data = today
                         and gerarel.hora <= time*/ 
            where gerarel.programa <> ""                         
                         no-lock no-error.
    if avail gerarel
    then do:
    
        assign vetbcod  = gerarel.etbcod
               vdata    = gerarel.data
               vhora    = gerarel.hora
               vparam   = gerarel.parametros
               vprogr   = gerarel.programa.
        
        do transaction:
            find gerarel where gerarel.etbcod = vetbcod
                           and gerarel.data   = vdata
                           and gerarel.hora   = vhora no-error.
            if avail gerarel
            then delete gerarel.
        end.
        
        run value(vprogr)
                 (
                     input (vparam),
                     output varquivo
                 ).
        
        vfilial = " filial" + string(vetbcod,"999").
        
        
        if vetbcod <> 1 and vetbcod <> 6 and vetbcod <> 17 and vetbcod <> 15
            and vetbcod <> 34
        then vfilial = vfilial + ":/usr/admcom/connect/gerarel".
        
        if vetbcod = 1
        then vfilial = vfilial + ":/usr/admcom/connect/gerarel/filial01".
        else
        if vetbcod = 6
        then vfilial = vfilial + ":/usr/admcom/connect/gerarel/filial06".
        else
        if vetbcod = 17
        then vfilial = vfilial + ":/usr/admcom/connect/gerarel/filial17".
        
        else
        if vetbcod = 15
        then vfilial = vfilial + ":/usr/admcom/connect/gerarel/filial15".
        else
        if vetbcod = 34
        then vfilial = vfilial + ":/usr/admcom/connect/gerarel/filial34".


        os-command silent gzip -f value(varquivo).

        varquivo = varquivo + ".gz".
        /*pause 1 no-message.*/
        os-command silent rcp value(varquivo) value(vfilial).

    end.
end. 
