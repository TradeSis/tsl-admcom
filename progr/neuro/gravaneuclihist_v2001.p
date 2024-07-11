/* #1 24.09.2018 agilizacao */

def input parameter p-recid-neuclien  as recid.
def input parameter p-tipoconsulta    as char.
def input parameter p-etbcod          as int.
def input parameter p-clicod          as int.
def input parameter p-liacod          as char. /* AREA */  
def input parameter p-vctolimite      as date.
def input parameter p-vlrlimite       as dec.
def input parameter p-complvlrlimite  as dec.
def input parameter p-sit_credito     as char.

if p-complvlrlimite = ? then p-complvlrlimite = 0.

find neuclien where recid(neuclien) = p-recid-neuclien no-lock no-error.
if avail neuclien
then do. 
    find limclien where  
            limclien.clicod = p-clicod and 
            limclien.liacod = p-liacod
        no-lock no-error.    
    
    if neuclien.sit_credito <> p-sit_credito or
       neuclien.clicod      <> p-clicod  or
       (avail limclien and limclien.vctolimite <> p-vctolimite) or
       (avail limclien and limclien.vlrlimite  <> p-vlrlimite) or
       p-complvlrlimite     <> 0
       or not avail limclien
    then do on error undo.
        find neuclien where recid(neuclien) = p-recid-neuclien
            exclusive
            no-wait 
            no-error.
        if avail neuclien
        then do.
            find limclien where 
                    limclien.clicod = p-clicod and
                    limclien.liacod = p-liacod
                    exclusive no-wait no-error.
            if not avail limclien
            then do:
                if not locked limclien
                then do:
                    create limclien.
                    limclien.clicod = p-clicod.
                    limclien.liacod = p-liacod.
                end.
            end.
            if avail limclien
            then do:
                limclien.VlrLimite  = p-VlrLimite.
                limclien.VctoLimite = p-VctoLimite.
                limclien.DtAtual    = today.
            END.        
            
            assign
                neuclien.clicod        = p-clicod
                neuclien.sit_credito   = p-sit_credito.
                /* AGORA POR AREA 
                neuclien.VlrLimite     = p-VlrLimite
                neuclien.VctoLimite    = p-VctoLimite.
                **/
            if p-complvlrlimite <> 0
            then assign
                    neuclien.complvlrlimite  = p-complvlrlimite
                    neuclien.complvctolimite = today.

                        if can-find(neuclienhist where
                   neuclienhist.cpfcnpj = neuclien.cpfcnpj and
                   neuclienhist.data = today and
                   neuclienhist.hora = time and
                   neuclienhist.etbcod = p-etbcod)
            then pause 1 no-message.
                            
            create neuclienhist. 
            ASSIGN 
                neuclienhist.CpfCnpj       = neuclien.CpfCnpj 
                neuclienhist.Data          = today
                neuclienhist.Hora          = mtime /* #1 time */
                neuclienhist.liacod        = p-liacod /* AREA */
                neuclienhist.tipoconsulta  = p-tipoconsulta 
                neuclienhist.Sit_Credito   = p-Sit_Credito 
                neuclienhist.EtbCod        = p-EtbCod 
                neuclienhist.vlrlimite     = p-vlrlimite
                neuclienhist.vctolimite    = p-vctolimite.
            if p-complvlrlimite <> 0
            then assign
                    neuclienhist.complvlrlimite  = p-complvlrlimite
                    neuclienhist.complvctolimite = today.
        end.
    end.
end.

