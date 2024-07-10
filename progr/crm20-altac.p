{admcab.i}


def var iacaocod    like acao.acaocod              no-undo.
def var cdescric    like acao.descricao            no-undo.
def var vdtini      like acao.dtini                no-undo.
def var vdtfin      like acao.dtfin                no-undo.
def var dvalor      like acao.valor                no-undo.
             
def var lconfirma   as logi             init no    no-undo.

def buffer bf-acao   for acao.

def frame f-upd
    iacaocod           label  "Acao"
    bf-acao.descricao  label  "Nome"
    with side-labels width 80 title "Exclusao de Acao".

/* -------------------------------------------------------------------- */    
repeat:

    update iacaocod
           with frame f-upd.

    find first bf-acao where
               bf-acao.acaocod = iacaocod no-lock no-error.
    if not avail bf-acao
    then do:
            disp "Acao nao encontrada!" @ bf-acao.descricao
                 with frame f-upd.
            undo, retry.   
    end.
    
    disp bf-acao.descricao
         with frame f-upd.

    assign cdescric = bf-acao.descricao
           vdtini   = bf-acao.dtini
           vdtfin   = bf-acao.dtfin  
           dvalor   = bf-acao.valor.

    update cdescric label "Nome"
           vdtini   label "Data Inicio"
           vdtfin   label "Data Final"
           dvalor   label "Valor"
           with frame f-upd1 side-labels 1 col.

    message "Confirma a alteracao da acao: " + string(bf-acao.acaocod)
            view-as alert-box buttons yes-no  title "ALTERACAO"
            update lconfirma.
    if lconfirma = yes
    then do:        
            find first acao where
                       acao.acaocod = iacaocod exclusive-lock no-error.
            if avail acao
            then do:
                     assign acao.descricao = cdescric
                            acao.dtini     = vdtini
                            acao.dtfin     = vdtfin
                            acao.valor     = dvalor. 
            end.
    end.
    
    hide frame f-alt.
    
    assign iacaocod  = 0
           lconfirma = no.
           
end.