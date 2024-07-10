propath = "/admcom/progr,/usr/dlc".
    
    
{/admcom/progr/admcab-batch.i new}

def var vetbcod like estab.etbcod.
def var vhora   as   int.
def var vdata   as   date format "99/99/9999".

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
               vhora    = gerarel.hora.
        
        
        run value(gerarel.programa)
                 (
                     input (gerarel.parametros),
                     output varquivo
                 ).
        
        vfilial = " filial" + string(gerarel.etbcod,"999").
        vfilial = vfilial + ":/usr/admcom/connect/gerarel".
        
        os-command silent gzip -f value(varquivo).

        varquivo = varquivo + ".gz".
        
        os-command silent rcp value(varquivo) value(vfilial).

        do transaction:
            find gerarel where gerarel.etbcod = vetbcod
                           and gerarel.data   = vdata
                           and gerarel.hora   = vhora no-error.
            if avail gerarel
            then delete gerarel.
        end.

    end.
end. 
