/*************************INFORMA€OES DO PROGRAMA*****************************
***** Nome do Programa             : cadtribm.p
***** Autor                        : Claudir Santolin
***** Descri‡ao Abreviada da Funcao: Cadastro de Tributacao
***** Data de Criacao              : 05/10/2000

                                ALTERACOES
***** 1) Autor     : 2016
***** 1) Descricao : Versão para Admcom
***** 1) Data      :

***** 2) Autor     :
***** 2) Descricao : 
***** 2) Data      :

***** 3) Autor     :
***** 3) Descricao : 
***** 3) Data      :
******************************************************************************/
{cabec.i}

def var vopccod like plani.opccod init 0.
def var vprocod like produ.procod.
def var vncm    like clafis.codfis.
def var vufemi  like plani.ufemi.
def var vufdes  like plani.ufdes.
def var mmenu   as char extent 2 format "x(20)"
    initial ["Operacao Comercial","Produtos"].

disp mmenu with frame m-menu no-label centered.
choose field mmenu with frame m-menu.

pause 0 before-hide.

if frame-index = 1
then repeat with frame f-opcom 1 down side-label.
    update vopccod colon 15 format "9999".
    if vopccod > 0
    then do.
        find opcom where opcom.opccod = string(vopccod) no-lock no-error.
        if not avail opcom
        then do.
            message "Operacao comercial" view-as alert-box.
            undo.
        end.
        disp opcom.opcnom no-label format "x(50)".
    end.
    update
        vufemi format "!!" colon 15
        vufdes format "!!".
    hide frame f-opcom no-pause.
    if vopccod = 0
    then vopccod = 9999. /* Para ver todas as CFOP */
    run tribicms.p(input 0, 0, vopccod, vufemi, vufdes).
end.
else repeat with frame f1:
    update vmercacod colon 15  with frame f1
            1 down side-label.
    if vmercacod <> ""
    then do:
/***Admcom
        {validapai.i vmercacod} 
        if avail produpai
        then find first produ where produ.itecod = produpai.itecod no-lock.
        else
   ***/ do.
            {validame.i vmercacod}
            if not avail produ
            then undo.
        end.
        vprocod = produ.procod.
        display string(vprocod) @ vmercacod
            produ.pronom no-label format "x(45)".
    end.
    else do:
        update vncm colon 15 label "NCM" format "99999999".
        if vncm <> 0
        then do.
        end.
        else display "TRIBUTACAO PADRAO" @ produ.pronom with frame f1.
        vprocod = 0.
    end.
    update
        vufemi format "!!" colon 15
        vufdes format "!!".
    hide frame f1 no-pause.
                                            
    run tribicms.p(input vprocod, vncm, 0, vufemi, vufdes).
end.
