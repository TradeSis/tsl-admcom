/*************************INFORMA€OES DO PROGRAMA******************************
***** Nome do Programa             : cadcaram.p
***** Diretorio                    : cadas
***** Autor                        : Claudir Santolin
***** Descri‡ao Abreviada da Funcao: Cadastro de Caracteristicas
***** Data de Criacao              : 28/08/2000

                                ALTERACOES
***** 1) Autor     :
***** 1) Descricao : 
***** 1) Data      :

***** 2) Autor     :
***** 2) Descricao : 
***** 2) Data      :

***** 3) Autor     :
***** 3) Descricao : 
***** 3) Data      :
*******************************************************************************/

{admcab.i new}
{setbrw.i}

def new shared buffer caract for caract.
def buffer bcaract for caract.

form    caract.carcod column-label "Codigo"
        caract.cardes column-label "Descricao"
        /*
        caract.ordem  column-label "Ordem"
        help "Informe a Ordem da Caracteristica na Descricao do Produto"
        caract.logcli column-label "Descricao"
        help "Informe se Caracteristica faz parte da Descricao do Produto"
        */
        with frame f-linha down row 04   overlay
          title " Caracteristicas do produto "
          color white/red.

form with frame f-le row 04 overlay column 01 01 down.

l1: repeat on endkey undo, leave with frame f-linha:
    hide frame f-linha no-pause.
    assign 
        a-seeid = -1.

    {stdfman.i}   /* Manutencao */
    
    /*ofield                          caract.ordem
                         caract.logcli*/

    {sklcls.i
        &help = 
        "ENTER=Altera F1=Sub-Caract F4=Retorna I=Inclui E=Exclui"
        &file         = caract
        &cfield       = caract.cardes
        &ofield       = " 
                         caract.cardes
                         caract.carcod
                         
                        " 
        &where        = "true"
        &color        = withe
        &color1       = red
        &procura1     = " 
        repeat with frame f-le:
            prompt-for 
                caract.cardes
                with no-validate.
            find first caract where 
                       caract.cardes        >= input frame f-le caract.cardes
                       no-lock no-error.
            if not available caract
            then do:        
                bell.
                message "" Nenhum registro encontrado. "". 
                undo.
            end.
            leave.
        end. 
        hide  frame f-le no-pause.
        clear frame f-le all." 
        &locktype     = " use-index cardes " 
        &aftselect    = " cadcaram.al " 
        &abrelinha    = " cadcaram.in " 
        &naoexiste    = " cadcaram.in " 
        &form         = " frame f-linha " } 

    if keyfunction(lastkey) = "end-error" 
    then leave l1.

end.
