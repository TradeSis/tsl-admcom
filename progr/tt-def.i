
def var ii as i.
def var vt like tt-titulo.titvlcob.
def var vtot like tt-titulo.titvlcob.
def var vforcod like forne.forcod.
def var i as i.
def var vtotal  like tt-titulo.titvlcob.
def var vsenha  like func.senha.
def var vfunc   like func.funcod.
def var vtitnum like tt-titulo.titnum.
def var vtitpar like tt-titulo.titpar.
def var vtitdtemi like tt-titulo.titdtemi.
def var vcobcod   like tt-titulo.cobcod.
def var vbancod   like banco.bancod.
def var vagecod   like agenc.agecod.
def var vevecod   like event.evecod.
def var vtitdtven like tt-titulo.titdtven.
def var vtitvljur like tt-titulo.titvlcob.
def var vtitdtdes like tt-titulo.titdtdes.
def var vtitvldes like tt-titulo.titvlcob.
def var vtitobs   like tt-titulo.titobs.
def buffer xtt-titulo for tt-titulo.
def workfile wtit field wrec as recid.
def var vvenc  like tt-titulo.titdtven.
def var vdia   as int.
def var vpar   like tt-titulo.titpar.
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
            initial ["Inclusao","Alteracao","Exclusao","Consulta",""].
def var esqcom2         as char format "x(22)" extent 3
            initial ["Pagamento/Cancelamento", "Bloqueio/Liberacao",
                        "Data Exportacao"].
def buffer b-titu       for tt-titulo.
def var vempcod         like tt-titulo.empcod.
def var vetbcod         like tt-titulo.etbcod.
def var vmodcod         like tt-titulo.modcod initial "DUP".
def var vtitnat         like tt-titulo.titnat.
def var vcliforlab      as char format "x(12)".
def var vclifornom      as char format "x(30)".
def var vclifor         like tt-titulo.clifor.
def var wperdes         as dec format ">9.99 %" label "Perc. Desc.".
def var wperjur         as dec format ">9.99 %" label "Perc. Juros".
def var vtitvlpag       like tt-titulo.titvlpag.
def var vtitvlcob       like tt-titulo.titvlcob.
def var vdtpag          like tt-titulo.titdtpag.
def var vdate           as   date.
def var vetbcobra       like tt-titulo.etbcobra initial 0.
def var vcontrola       as   log initial no.
form esqcom1
    with frame f-com1
    row 5 no-box no-labels side-labels column 1.
form esqcom2
    with frame f-com2
        row screen-lines - 2 title " OPERACOES " no-labels side-labels column 1
        centered.
{forfrm.i}
