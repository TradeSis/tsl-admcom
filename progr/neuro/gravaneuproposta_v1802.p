     /**         
     #1 v1802 ago/2018 - Novo log
     **/
     
     def input parameter par-cpf                as char.
     def input parameter par-tipoconsulta       as char.
     def input parameter par-props              as char.
     def input parameter par-retprops           as char. /* #1 */
     def input parameter par-etbcod             as int.
     def input parameter par-cxacod             as int.
     def input parameter par-ori-operacao       as char. /* #1 */
     /* #1 def input parameter par-time               as int. */
     
     def input parameter par-neuro-operacao       as char.
     def input parameter par-neuro-sit            as char.
     def input parameter par-neuro-mens           as char.

     def input parameter par-vlrlimite as dec.
     def input parameter par-complvlrlimite as dec.
     def input parameter par-vctolimite as date.
     def input parameter par-recid-neuclien     as recid.
     def input parameter par-valorcompra as dec. /* #1 */
     def input-output parameter par-recid-neuproposta    as recid.

     def output param p-status as char.
     def output param p-mensagem_erro as char.
    
     def buffer bneupropostaoper for neupropostaoper. 

    p-status = "S".
    p-mensagem_erro = "".

    if par-complvlrlimite = ? then par-complvlrlimite = 0.

    find neuclien      where recid(neuclien) = par-recid-neuclien 
        no-lock no-error.

    if not avail neuclien
    then do:  
        p-status = "E". 
        p-mensagem_erro = if par-neuro-operacao = ?
                          then "Erro ao Pegar Cliente Para Gravar Proposta"
                          else "Erro ao Pegar Cliente Para Atualizar Proposta".
        return.
    end.
             
    find neuproposta   where recid(neuproposta) = par-recid-neuproposta 
        no-lock no-error.
    if not avail neuproposta
    then do on error undo:
        find neuproposta where 
                neuproposta.etbcod    = par-etbcod and
                neuproposta.cxacod    = par-cxacod and /* #1 */
                neuproposta.dtinclu   = today and
                neuproposta.cpfcnpj   = neuclien.cpfcnpj and
                neuproposta.neu_cdoperacao = par-ori-operacao /* #1 */
            exclusive
            no-wait
            no-error.
        if not avail neuproposta            
        then do:
            if locked neuproposta
            then do:
                p-status = "E".
                p-mensagem_erro = if par-neuro-operacao = ?
                                  then "LOCK Para Gravar Proposta"
                                  else "LOCK Para Atualizar Proposta".

                return.
            end.
            else do:
                create neuproposta.
                par-recid-neuproposta = recid(neuproposta).    
                ASSIGN
                    neuproposta.EtbCod         = par-EtbCod
                    neuproposta.cxacod         = par-cxacod /* #1 */
                    neuproposta.DtInclu        = today
                    neuproposta.HrInclu        = time /* #1 par-time */
                    neuproposta.CpfCnpj        = neuclien.CpfCnpj
                    neuproposta.neu_cdoperacao = par-ori-operacao /* #1 */
                    neuproposta.TipoConsulta   = par-TipoConsulta
                    neuproposta.neuprops       = par-props
                    neuproposta.valorcompra    = par-valorcompra /* #1 */.
            end.   
        end.
        else do: 
            par-recid-neuproposta = recid(neuproposta).    
        end.    
    end.
    
    if par-neuro-operacao <> ?
    then do for neupropostaoper on error undo.
        find neuproposta where recid(neuproposta) = par-recid-neuproposta
            exclusive-lock
            no-wait
            no-error.
        if not avail neuproposta
        then do:
            p-status = "E".
            p-mensagem_erro = "ERRO Para Atualizar Proposta".
            return.
        end.

        /* #1
        if  (par-tipoconsulta = "P2" or
             par-tipoconsulta = "P5") and
            par-neuro-sit = "P" and   /* 25.10.17 */ /* retornou PENDENTE */
           neuproposta.neu_resultado = "P" and      /* e ja estava pendente */
           (neuproposta.tipoconsulta  = "P5" or     /* e operacao o P5 ou P2 */
            neuproposta.tipoconsulta  = "P2")
            and
            neuproposta.hrinclu >= time - (5 * 60)
        then.    /* Nao atualiza os campos neuro, para poder reenvia-los */
        else do:
            assign
                NeuProposta.neu_resultado  = par-neuro-sit
                NeuProposta.neu_cdoperacao = par-neuro-operacao. 
                neuproposta.TipoConsulta   = par-TipoConsulta.

        end. 
        */
            /* #1 */
            NeuProposta.neu_resultado  = par-neuro-sit.
            if par-neuro-sit = "A" or
               par-neuro-sit = "R"
            then assign
                    neuproposta.dtlibera = today
                    neuproposta.hrlibera = time.

            if neuproposta.neu_cdoperacao = "" or
               neuproposta.neu_cdoperacao = ?
            then NeuProposta.neu_cdoperacao = par-neuro-operacao.
            /* #1 */

            /* #1 neuproposta.HrInclu        = par-time. */
            neuproposta.neuprops       = par-props.
            neuproposta.vlrlimite      = par-vlrlimite.
            neuproposta.vlrlimitecompl = par-complvlrlimite.
            neuproposta.vctolimite     = par-vctolimite.
                    
        find last bNeuPropostaOper where
                                 bNeuPropostaOper.etbcod  = neuproposta.etbcod
                    /* #1 */ and bNeupropostaoper.cxacod  = neuproposta.cxacod
                             and bNeuPropostaOper.dtinclu = neuproposta.dtinclu
                             and bNeuPropostaOper.cpfcnpj = neuproposta.cpfcnpj
                    /* #1 */ and bNeuPropostaOper.neu_cdoperacao =
                                                    neuproposta.neu_cdoperacao
                                   no-lock no-error.
        create NeuPropostaOper.
        assign
            NeuPropostaOper.etbcod  = neuproposta.etbcod
            NeuPropostaOper.dtinclu = neuproposta.dtinclu
            NeuPropostaOper.hrinclu = neuproposta.hrinclu
/**            Neupropostaoper.hrretorno = time **/
            NeuPropostaOper.cpfcnpj = neuproposta.cpfcnpj
            NeuPropostaOper.seq     = if avail bNeuPropostaOper
                                      then bNeuPropostaOper.seq + 1
                                      else 1
            neupropostaoper.neu_cdoperacao = neuproposta.neu_cdoperacao 
            /* #1 par-neuro-operacao*/
            
            neupropostaoper.ret_cdoperacao = par-neuro-operacao /* #1 */
            NeuPropostaOper.cxacod  = par-cxacod
        /**    NeuPropostaOper.funcod  = vfuncod **/
            NeuPropostaOper.tipoconsulta   = par-tipoconsulta
            NeuPropostaoper.neuprops       = par-props
            NeuPropostaoper.retprops       = par-retprops /* #1 par-props */.
            neupropostaoper.vlrlimite      = par-vlrlimite.
            neupropostaoper.vlrlimitecompl = par-complvlrlimite.
            neupropostaoper.vctolimite     = par-vctolimite.
            neupropostaoper.valorcompra    = if neupropostaoper.valorcompra = 0
                                             then par-valorcompra
                                             else neupropostaoper.valorcompra.
    end.

