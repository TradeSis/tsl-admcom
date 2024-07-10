/* #1 QUANDO P-TIME for zero ENTAO FORCA UM PAUSE PARA CRIAR NOVO LOG */
/* #2 Agilizacao */
 
    def input   parameter p-cpf             as char.
    def input   parameter p-tipoconsulta    as char.
    def input   parameter p-time            as int.
    def input   parameter p-etbcod          as int.
    def input   parameter p-cxacod          as int.
    def input   parameter p-sit_credito     as char.
    def input   parameter p-mensagem        as char.

    /* #1 */
    IF P-TIME = 0
    THEN DO:
        /* #2 pause 1 no-message. */
        p-time = mtime.
    END. 
    
    do on error undo.    
        /*
        find first neuclienlog where
            neuclienlog.cpfcnpj = dec(p-cpf) and
            neuclienlog.dtinclu = today      and
            neuclienlog.hrini   = p-time
        exclusive     
        no-wait
        no-error.
        if avail neuclienlog
        then do:
            neuclienlog.hrfim = mtime. /* #2 */
            neuclienlog.descricao = neuclienlog.descricao + 
                                    if p-mensagem <> ""
                                    then (if neuclienlog.descricao = ""
                                          then ""
                                          else " / ") + p-mensagem
                                    else "".
            neuclienlog.sit_credito = p-sit_credito. 
        end.
        else */
        
        do:
            create NeuClienLog.
            assign
                NeuClienLog.etbcod    = p-etbcod
                NeuClienLog.dtinclu   = today
                NeuClienLog.hrini     = ? /*p-time helio 28032022 */
                neuclienlog.hrfim     = p-time
                NeuClienLog.cpfcnpj   = dec(p-cpf) /** int64 **/
                NeuClienLog.cxacod    = p-cxacod
                NeuClienLog.tipoconsulta = p-tipoconsulta
                NeuClienLog.Descricao = p-mensagem
                neuclienlog.sit_credito = p-sit_credito. 
        end.
    end.

