
def var ii as i.
def var vt like titulo.titvlcob.
def var vtot like titulo.titvlcob.
def var vforcod like forne.forcod.
def var i as i.
def var vtotal  like titulo.titvlcob.
def var vsenha  like func.senha.
def var vfunc   like func.funcod.
def var vtitnum like titulo.titnum.
def var vtitpar like titulo.titpar.
def var vtitdtemi like titulo.titdtemi.
def var vcobcod   like titulo.cobcod.
def var vbancod   like banco.bancod.
def var vagecod   like agenc.agecod.
def var vevecod   like event.evecod.
def var vtitdtven like titulo.titdtven.
def var vtitvljur like titulo.titvlcob.
def var vtitdtdes like titulo.titdtdes.
def var vtitvldes like titulo.titvlcob.
def var vtitobs   like titulo.titobs.
def buffer xtitulo for titulo.
def workfile wtit field wrec as recid.
def var vvenc  like titulo.titdtven.
def var vdia   as int.
def var vpar   like titulo.titpar.
def var vlog   as log.
def var vok as log.
def var vinicio         as  log initial no.
def var reccont         as  int.
def var recatu1         as recid.
def var recatu2         as recid.
def var esqpos1         as int.
def var esqpos2         as int.
def var esqregua        as log initial yes.
def var esqcom1         as char format "x(14)" extent 5
        initial ["Inclusao","Alteracao","Exclusao","Consulta","Agendamento"].
def var esqcom2         as char format "x(22)" extent 3
            initial ["Pagamento/Cancelamento", "Bloqueio/Liberacao",
                        "Data Exportacao"].

/**
def var vsetcod like setaut.setcod.
find first func where func.funcod = sfuncod and
                      func.etbcod = setbcod no-lock no-error.
if avail func and func.funfunc = "FINANCEIRO"
then.
else do:
    esqcom1[2] = "".
    esqcom1[3] = "".
    esqcom1[4] = "".
    esqcom2 = "".
    update vsetcod with frame f-set 1 down no-box color message
            side-label width 80.
    find setaut where setaut.setcod = vsetcod no-lock no-error.
    if not avail setaut
    then do:
        message "Setor nao cadastrado".
        undo, retry.
    end.
    disp setaut.setnom no-label with frame f-set .
    if not avail func or func.aplicod <> string(setaut.setcod)
    then do:
        message "Operacao nao permitida".
        undo.
    end.
end.
hide frame f-set no-pause.    
**/
def buffer btitulo      for titulo.
def buffer ctitulo      for titulo.
def buffer b-titu       for titulo.
def var vempcod         like titulo.empcod.
def var vetbcod         like titulo.etbcod.
def var vmodcod         like titulo.modcod initial "DUP" format "x(4)".
def var vtitnat         like titulo.titnat.
def var vcliforlab      as char format "x(12)".
def var vclifornom      as char format "x(30)".
def var vclifor         like titulo.clifor.
def var wperdes         as dec format ">9.99 %" label "Perc. Desc.".
def var wperjur         as dec format ">9.99 %" label "Perc. Juros".
def var vtitvlpag       like titulo.titvlpag.
def var vtitvlcob       like titulo.titvlcob.
def var vdtpag          like titulo.titdtpag.
def var vdate           as   date.
def var vetbcobra       like titulo.etbcobra initial 0.
def var vcontrola       as   log initial no.
form esqcom1
    with frame f-com1
    row 5 no-box no-labels side-labels column 1.
form esqcom2
    with frame f-com2
        row screen-lines - 1 /*title " OPERACOES " */
        no-labels side-labels column 1
        no-box centered.
{forfrm.i}
