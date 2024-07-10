/*************************INFORMA€OES DO PROGRAMA******************************
***** Nome do Programa             : selestab.i
***** Diretorio                    : gener
***** Autor                        : Claudir Santolin
***** Descri‡ao Abreviada da Funcao: Seleciona Estab
***** Data de Criacao              : 07/12/2000

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
/*** {1} = variavel do codigo do estab
     {2} = nome do frame ***/

def var vdesloja like estab.etbnom init "".
def new shared temp-table tt-lj like estab.
     
for each tt-lj:
    delete tt-lj.
end.
{1} = setbcod.
IF estab.etbcod > 0  /* cat <> "LOJA" */
THEN DO:
    {1} = 0.
    update {1} with frame {2}.
    if {1} > 0
    then do:
        find estab where estab.etbcod = {1} no-lock no-error.
        if not avail estab
        then do:
            message color red/white "Estabelecimento nao Cadastrado"
            view-as alert-box title "Menssagem".
            undo, retry.
        end.
        disp {1} estab.etbnom no-label skip with frame {2}. 
        create tt-lj.
        tt-lj.etbcod = estab.etbcod.
    end.
    else do:
        run seletbgr.p.
        for each tt-lj break by tt-lj.etbcod:
            vdesloja = vdesloja + " * " + string(tt-lj.etbcod).
        end.
        if vdesloja <> ""
        then  disp vdesloja @ estab.etbnom with frame {2}.
        else do:
            disp {1} "EMPRESA" @ estab.etbnom with frame {2}.
            find first tt-lj no-error.
            for each estab no-lock:
                create tt-lj.
                tt-lj.etbcod = estab.etbcod.
            end.
        end.
    end.
END.
else disp {1} estab.etbnom with frame {2}.
