/***********************~**INFORMA€OES DO PROGRAMA******************************
***** Nome do Programa             : cadclasm.p
***** Diretorio                    : cadas
***** Autor                        : Caludir Santolin
***** Descri‡ao Abreviada da Funcao: Classificacao de Mercadorias
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

{admcab.i}
{setbrw.i}
{anset.i}

def var p-etiqope     like etiqope.etopecod.

form
    etiqope.etopecod
    etiqope.etopenom help "ENTER=Nivel" 
    etiqope.sigla
    with frame f-etiqope
        column 5 
        row 4
        down
        overlay 
        no-labels.

l1: repeat :
    hide frame f-etiqseqsup no-pause.
    clear frame f-etiqope all.
    assign
        a-seeid = -1
        a-recid = -1
        a-seerec = ?.

    {sklcls.i
        &color = withe
        &color1 = red
        &file       = etiqope
        &Cfield     = etiqope.etopenom
        &OField     = "etiqope.etopecod etiqope.sigla" 
        &Where      = "true" 
        &AftSelect1 = "p-etiqope = etiqope.etopecod.
                       leave keys-loop."
        &LockType  = " no-lock"
        &form       = "frame f-etiqope"
    }

    if keyfunction(lastkey) = "END-ERROR" 
    then leave.

    view frame f-etiqope.
    pause 0.
    
    run not_cdetiqseqd.p (p-etiqope,0,0).
end.

