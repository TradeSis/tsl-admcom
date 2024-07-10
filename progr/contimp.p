/******************************************************************************
 Programa           : Consulta as importacoes que faltam
 Nome do Programa   : ComtImp.p
 Programador        : Cristiano Borges Brasil
 Criacao            : 29/11/1996
*****************************************************************************/

{admcab.i}
def var vdtimp                  as date.
def var vsem                    as char format "x(03)" extent 7
                                initial ["Dom","Seg","Ter","Qua","Qui","Sex",
                                         "Sab"].
def buffer bimporta             for importa.
def temp-table wf-atu
             field etbcod       like estab.etbcod
             field imp          like importa.importa.

def var vetb like estab.etbcod.

repeat:

    update vetb with frame ffffff centered color white/cyan side-labels row 6.
    find estab where estab.etbcod = vetb no-lock.
    disp estab.etbnom no-label with frame ffffff.

    if keyfunction(lastkey) = "End-Error"
    then leave.

    if estab.etbcod = 999
    then next.

    find last importa where importa.etbcod = estab.etbcod no-lock no-error.
    if avail importa
    then vdtimp = importa.importa - 1.
    else next.

    if avail importa
    then repeat:
        vdtimp = vdtimp + 1.
        if vdtimp = today
        then leave.
        if weekday(vdtimp) = 1
        then next.
        find dtextra where dtextra.exdata  = vdtimp no-error.
        if avail dtextra
        then do:
            find next importa where importa.etbcod = estab.etbcod no-lock
                                                        no-error.
            next.
        end.

        find bimporta where bimporta.etbcod  = estab.etbcod and
                            bimporta.importa = vdtimp no-lock no-error.
        if not avail bimporta
        then do:
            create wf-atu.
            assign  wf-atu.etbcod = estab.etbcod
                    wf-atu.imp    = vdtimp.
        end.
        find next importa where importa.etbcod = estab.etbcod no-lock no-error.
    end.

    bell.
    for each wf-atu:
        display wf-atu.etbcod
                wf-atu.imp
                vsem[weekday(wf-atu.imp)] label "Dia"
                with color white/red centered title " IMPORTACOES A FAZER "
                10 down row 9.
        delete wf-atu.
    end.
    pause.
end.
