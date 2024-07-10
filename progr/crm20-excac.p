{admcab.i}


def var iacaocod    like acao.acaocod              no-undo.
def var lconfirma   as logi             init no    no-undo.

def frame f-upd
    iacaocod        label  "Acao"
    acao.descricao  label  "Nome"
    with side-labels width 80 title "Exclusao de Acao".
    
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

    message "Confirma a exclusao da acao: " + string(acao.acaocod)
            view-as alert-box buttons yes-no  title "EXCLUSAO"
            update lconfirma.
    if lconfirma = yes
    then do:        
            for each acao-cli where
                     acao-cli.acaocod = iacaocod exclusive-lock:

                delete acao-cli.

                disp "Excluindo Acao"
                     with frame f-exc no-label row 12 col 15.
                pause 0 no-message.                               

            end.

            delete acao.
    end.
    
    hide frame f-exc.
    
    assign iacaocod  = 0
           lconfirma = no.
           
end.