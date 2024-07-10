propath = "/admcom/progr,/usr/dlc".
    
    
{/admcom/progr/admcab-batch.i new}

def var vetbcod like estab.etbcod.
def var vhora   as   int.
def var vdata   as   date format "99/99/9999".
def var vparam as char.
def var vprogr as char.
def var vfilial    as   char.
def var varquivo   as   char.
def var vlinha as char.

def temp-table tt-linha
    field linha as char
    field vparam as char
    field etbcod as int
    field programa as char.

repeat:
        
    pause 1 no-message.
    for each tt-linha. delete tt-linha. end.
    assign vfilial = "" vhora = 0 vetbcod  = 0 varquivo = "" vdata = today.

    unix silent ls /admcom/connect/busca-rel/* >
                /admcom/work/busca-rel.txt 2> /dev/null.
    
    /*
    unix silent rm -f `cat /usr/admcom/work/procura2.txt` 2> /dev/null.
    */
    
    input from /admcom/work/busca-rel.txt.
        repeat:
            import unformatted vlinha.

            if vlinha <> ""
            then do:
        
                find tt-linha where
                     tt-linha.linha = vlinha no-error.
                if not avail tt-linha
                then do:
                
                    create tt-linha.
                    assign tt-linha.linha = vlinha.

                end.
                
            end.
        
        end.
    input close.    

    for each tt-linha:

        input from value(tt-linha.linha).
            repeat:
                import vparam.
            end.
        input close.
        tt-linha.vparam = vparam.        
        tt-linha.etbcod = (int(acha("ETBCOD",tt-linha.vparam))).
        tt-linha.programa = "/admcom/progr/"
                          + (acha("PROGRAMA",tt-linha.vparam)).
        tt-linha.vparam = chr(34) + tt-linha.vparam + chr(34).
        
    end.
    
    for each tt-linha.
        
      unix silent /usr/dlc/bin/mbpro -pf /admcom/bases/connect3a.pf -p
                value(tt-linha.programa) -param value(tt-linha.vparam) " &".
        
    end.

    unix silent rm -f `cat /admcom/work/busca-rel.txt` 2> /dev/null.
    
end. 
