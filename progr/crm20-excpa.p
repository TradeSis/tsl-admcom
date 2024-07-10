{admcab.i}


def var iacaocod    like acao.acaocod              no-undo.
def var iclicod     like clien.clicod              no-undo.    
def var lconfirma   as logi             init no    no-undo.

def frame f-upd
    iacaocod        label  "Acao"
    acao.descricao  label  "Nome"
    iclicod         label  "Codigo"
    clien.clinom    label  "Participante" 
    with side-labels width 80 1 col title "Exclusao de Acao".
    
    def buffer bf-acao-cli for acao-cli.

/* -------------------------------------------------------------------- */    
repeat:

    update iacaocod
           with frame f-upd.

    find first acao where
               acao.acaocod = iacaocod exclusive-lock no-error.
    if not avail acao
    then do:
            disp "Acao nao encontrada!" @ acao.descricao
                 with frame f-upd.
            undo, retry.   
    end.

    disp acao.descricao
         with frame f-upd.

    update iclicod
           with frame f-upd.
            
    find first clien where
               clien.clicod = input iclicod no-lock no-error.
    if not avail clien
    then do:
            disp "Cliente nao encontrado!" @ clien.clinom
                 with frame f-upd.
            undo, retry.        
    end.
    
    disp clien.clinom
         with frame f-upd.
                     
    find first bf-acao-cli where
               bf-acao-cli.acaocod = input iacaocod and
               bf-acao-cli.clicod  = input iclicod  no-lock no-error.
    if not avail bf-acao-cli
    then do:
             message "Cliente nao e participante desta acao" skip
                     "favor verificar!" view-as alert-box. 
             undo, retry.        
    end.           
                     

    message "Confirma a exclusao do participante: " + 
            string(bf-acao-cli.clicod)
            view-as alert-box buttons yes-no  title "EXCLUSAO PARTICIPANTE"
            update lconfirma.
    if lconfirma = yes
    then do:        
            find first acao-cli where
                       acao-cli.acaocod = input iacaocod and
                       acao-cli.clicod  = input iclicod  exclusive-lock.
            if avail acao-cli
            then do:    
                    delete acao-cli.

                    disp "Excluindo Participante da Acao"
                         with frame f-exc no-label row 12 col 15.
                    pause 0 no-message.                               
            end.
    end.
    
    hide frame f-exc.
    
    assign iacaocod  = 0
           iclicod   = 0 
           lconfirma = no.
           
end.