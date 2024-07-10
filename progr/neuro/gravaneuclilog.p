/* #1 QUANDO P-TIME for zero ENTAO FORCA UM PAUSE PARA CRIAR NOVO LOG */
 
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
        pause 1 no-message.
        p-time = time.
    END. 
    
    do on error undo.    
        find first neuclienlog where
            neuclienlog.cpfcnpj = dec(p-cpf) and /** int64 **/
            neuclienlog.dtinclu = today        and
            neuclienlog.hrini   = p-time
        exclusive     
        no-wait
        no-error.
        if avail neuclienlog
        then do:
            neuclienlog.hrfim = time.
            neuclienlog.descricao = neuclienlog.descricao + 
                                    if p-mensagem <> ""
                                    then (if neuclienlog.descricao = ""
                                          then ""
                                          else " / ") + p-mensagem
                                    else "".
            neuclienlog.sit_credito = p-sit_credito. 
        end.
        else do:
            create NeuClienLog.
            assign
                NeuClienLog.etbcod    = p-etbcod
                NeuClienLog.dtinclu   = today
                NeuClienLog.hrini     = p-time
                neuclienlog.hrfim     = p-time
                NeuClienLog.cpfcnpj   = dec(p-cpf) /** int64 **/
                NeuClienLog.cxacod    = p-cxacod
                NeuClienLog.tipoconsulta = p-tipoconsulta
                NeuClienLog.Descricao = p-mensagem.
                neuclienlog.sit_credito = p-sit_credito. 
        end.
    end.

