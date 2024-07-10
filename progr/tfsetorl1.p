{admcab.i}                  

def var vfuncod like func.funcod.
def var vfunfol like func.usercod label "Matricula".

def var vfuncionario like func.usercod.
def var vfuncionario1 like func.usercod.
 
def var ii as i.
def var vt   as dec format "->>>,>>>,>>9.99".
def var vtot as dec format "->>>,>>>,>>9.99".
def var vforcod like forne.forcod.
def var i as i.
def var vtotal  as dec format "->>>,>>>,>>9.99".
def var vsenha  like func.senha.
def var vfunc   like func.funcod.
def var vmatricula like func.usercod.
def var vtitnum like banfin.titulo.titnum.

def var vnumtit as int.
def var vtitpar like banfin.titulo.titpar.
def var vtitdtemi like banfin.titulo.titdtemi.
def var vcobcod   like banfin.titulo.cobcod.
def var vbancod   like banco.bancod.
def var vagecod   like agenc.agecod.
def var vevecod   like banfin.event.evecod.
def var vtitdtven like banfin.titulo.titdtven.
def var vtitvljur as dec format "->>>,>>>,>>9.99" label "Valor Cobrado".
def var vtitdtdes like banfin.titulo.titdtdes.
def var vtitvldes like banfin.titulo.titvlcob.
def var vtitobs   like banfin.titulo.titobs.
def var vmeta     as char format "x(35)".
def var vmeta1    as char format "x(35)".
def var vrealizada as char format "x(35)".
def var vrealizada2 as char format "x(35)".
def var vcampanha as char format "x(35)".
def var vcampanha2 as char format "x(35)".
def buffer xtitulo for banfin.titulo.
def workfile wtit field wrec as recid.
def var vvenc  like banfin.titulo.titdtven.
def var vdia   as int.
def var vpar   like banfin.titulo.titpar.
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

def shared var vtipo-documento as int.

def shared var vsetcod like setaut.setcod.
if sfuncod = 224 or sfuncod = 89
then vsetcod = 0.
def buffer btitulo      for banfin.titulo.
def buffer ctitulo      for banfin.titulo.
def buffer b-titu       for banfin.titulo.
def shared var vempcod         like banfin.titulo.empcod.
def shared var vetbcod         like banfin.titulo.etbcod.
def shared var vmodcod         like banfin.titulo.modcod initial "PEA".
def shared var vtitnat         like banfin.titulo.titnat.
def var vcliforlab      as char format "x(12)".
def var vclifornom      as char format "x(30)".
def shared var vclifor         like banfin.titulo.clifor.
def var wperdes         as dec format "->9.99 %" label "Perc. Desc.".
def var wperjur         as dec format "->9.99 %" label "Perc. Juros".
def var vtitvlpag       as dec format "->>>,>>>,>>9.99".
def var vtitvlcob       as dec format "->>>,>>>,>>9.99".
def var vdtpag          like banfin.titulo.titdtpag.
def var vdate           as   date.
def var vetbcobra       like banfin.titulo.etbcobra initial 0.
def var vcontrola       as   log initial no.
form esqcom1
    with frame f-com1
    row 6 no-box no-labels side-labels column 1.
form esqcom2
    with frame f-com2
        row screen-lines - 1 /*title " OPERACOES " */
        no-labels side-labels column 1
        no-box centered.

FORM banfin.titulo.clifor    colon 15 label "Fornec."
    banfin.titulo.titnum     colon 15
    banfin.titulo.titpar     colon 15
/***    banfin.titulo.titdtemi   colon 15***/
    banfin.titulo.titdtven   colon 15
    banfin.titulo.titvlcob   colon 15 format "->>>,>>>,>>9.99"
/*    banfin.titulo.cobcod     colon 15*/
    with frame ftitulo
        overlay row 7 color
        white/cyan side-label width 39.

FORM vforcod     colon 15 label "Fornecedor"
     vclifornom  no-label format "x(25)"
     vfunfol     label "Matricula" colon 15
     func.funnom no-label
     vmeta       label "Meta"
     vrealizada  label "Realizada"
     vcampanha   label "Campanha"
     vtitnum     colon 15
     vtitpar     colon 15
/***     vtitdtemi   colon 15***/
     vtitdtven   colon 15
     vtitvlcob   colon 15 format "->>>,>>>,>>9.99" 
     /***
     vcobcod     colon 15
     banfin.cobra.cobnom no-label format "x(15)"
     banfin.titulo.modcod colon 15
     banfin.modal.modnom no-label format "x(15)"
     banfin.titulo.evecod colon 15
     banfin.event.evenom no-label format "x(15)"
     ***/
     with frame ftit overlay row 7 color white/cyan side-label width 60.

FORM vforcod     colon 15
     vclifornom  no-label format "x(25)"
     vfunfol     label "Matricula" colon 15
     func.funnom no-label colon 15 format "x(20)"
     vmeta       colon 15 label "Meta"
     vrealizada  colon 15 label "Realizada"
     vcampanha   colon 15 label "Campanha"
     vtitnum     colon 15
     vtitpar     colon 15
/***     vtitdtemi   colon 15***/
     vtotal      colon 15
     /***
     vcobcod     colon 15
     banfin.cobra.cobnom no-label format "x(15)"
     vevecod colon 15
     banfin.event.evenom no-label format "x(15)"
     ***/
     with frame ftit2 overlay row 7 color white/cyan side-label width 60.

form banfin.titulo.titbanpag colon 15
    banco.bandesc no-label
    banfin.titulo.titagepag colon 15
    agenc.agedesc no-label
    banfin.titulo.titchepag colon 15
    with frame fbancpg centered
         side-labels 1 down overlay
         color white/cyan row 16
         title " Banco Pago " width 80.

form banfin.titulo.bancod   colon 15
    banco.bandesc           no-label
    banfin.titulo.agecod   colon 15
    agenc.agedesc         no-label
    with frame fbanco centered
         side-labels 1 down
         color white/cyan row 16 .

form vbancod   colon 15
    banco.bandesc           no-label
    vagecod   colon 15
    agenc.agedesc         no-label
    with frame fbanco2 centered
         side-labels 1 down
         color white/cyan row 16 .
         /***
form wperjur         colon 16
    banfin.titulo.titvljur colon 16 skip(1)
    banfin.titulo.titdtdes colon 16
    wperdes         colon 16
    banfin.titulo.titvldes colon 16
    with frame fjurdes
         overlay row 7 column 41 side-label
         color white/cyan  width 40.
         ***/

form wperjur         colon 16
    vtitvljur colon 16 skip(1)
    vtitdtdes colon 16
    wperdes         colon 16
    vtitvldes colon 16 with frame fjurdes2
         overlay row 7 column 41 side-label
         color white/cyan  width 40.

form
    vtitobs[1] at 1
    vtitobs[2] at 1
    with no-labels width 80 row 16
         title " Observacoes " frame fobs2
         color white/cyan .

form
    banfin.titulo.titobs[1] at 1
    banfin.titulo.titobs[2] at 1
    with no-labels width 80 row 16
         title " Observacoes " frame fobs
         color white/cyan .

form
    banfin.titulo.titdtpag colon 15 label "Dt.Pagam"
    banfin.titulo.titvlpag  colon 15 format "->>>,>>>,>>9.99"
    /***
    banfin.titulo.cobcod    colon 15
    banfin.titulo.titvljur  colon 15 column-label "Juros"
    banfin.titulo.titvldes  colon 15 column-label "Desconto"
    ***/
    with frame fpag1 side-label
         row 10 color white/cyan
         overlay column 42 width 39 title " Pagamento " .

esqcom1[5] = "".
if sfuncod <> 89 and sfuncod <> 224
then esqcom2 = "".
/*esqcom2 = "".*/

def var v-agendado as char format "x" label "A".
def var taxa-ante as dec format ">>9.99".
def var deletou-lancxa as log.
def var vfrecod as int.
def var vv as int.
def var vlfrete like plani.platot.
def var vfre as int format "9" initial 1.
def buffer ftitulo for banfin.titulo.
def buffer ztitulo for banfin.titulo.
def var vdt like plani.pladat.
def var vcompl like lancxa.comhis format "x(50)".
def var vlanhis like lancxa.lanhis.
def var vnumlan as int.
def buffer blancxa for lancxa.
def var vlancod like lancxa.lancod.
esqpos1  = 1. esqpos2  = 1.
def var vtitle  as char.
if avail setaut
then vtitle = setaut.setnom.
else vtitle = "FINANCEIRO".
form with frame ff1 title "   " + vtitle  + "   ".
do:
    for each wtit:
        delete wtit.
    end.
    clear frame ff1 all.
    assign recatu1  = ?.
    hide frame f-com1 no-pause.
    hide frame f-com2 no-pause.

form with frame f-par  down
    centered row 7 overlay  color message.

/*find forne where forne.forcod = vclifor no-lock.*/

/****  
def var vtipo-documento as int init 0.
*/
procedure tipo-documento:
  /********  
    def var vsel-sit1 as char format "x(15)" extent 5
          init["Nota Fiscal","Recibo Completo","RPA","Recibo Comum","Nenhum"].
    def var vmarca-sit1 as char format "x" extent 5.
    format skip(1)
           "[" space(0) vmarca-sit1[1] space(0) "]" vsel-sit1[1]             
           skip
           "[" space(0) vmarca-sit1[2] space(0) "]" vsel-sit1[2]
           skip
           "[" space(0) vmarca-sit1[3] space(0) "]" vsel-sit1[3]
           skip
           "[" space(0) vmarca-sit1[4] space(0) "]" vsel-sit1[4]
           skip
           "[" space(0) vmarca-sit1[5] space(0) "]" vsel-sit1[5]
           skip(1)
           with frame f-sel-sit1
                   1 down  centered no-label row 10 overlay
                    width 30 title " Tipo de Documento ".

        def var vi as in init 0.
        def var va as int init 0.
        /*
        i = 1.
        if vi = 0
        then next.
        */
        vmarca-sit1 = "".
        disp     vmarca-sit1      
                 vsel-sit1 with frame f-sel-sit1.
        pause 0.    
        va = 1.
    repeat:                                                 
        repeat :
            message "TECLE ENTER PARA MARCAR O TIPO DE DOCUMENTO E F4 PARA CONT~INUAR                             " .
            choose field vsel-sit1 with frame f-sel-sit1.
            vmarca-sit1[va] = "".
            vmarca-sit1[frame-index] = "*".
            va = frame-index.
            disp vmarca-sit1 with frame f-sel-sit1.
            pause 0.
            vtipo-documento = va.
        end.
        if vtipo-documento = 0
        then  next.
        else leave.
    end.
    hide frame f-sel-sit1 no-pause.
    hide message no-pause.
****/    
end procedure.

def shared temp-table tt-lj like estab.
def var vqtd-lj as int init 0.
for each tt-lj where etbcod > 0 no-lock:
    vqtd-lj = vqtd-lj + 1.
end.
if vqtd-lj > 1
then do:
  /*  run tipo-documento. */
    run rateio-cria-titulo.
end.
bl-princ:
repeat :
    disp esqcom1 with frame f-com1.
    disp esqcom2 with frame f-com2.
    pause 0.
    /***
    for each banfin.titulo where banfin.titulo.empcod = wempre.empcod
                             and banfin.titulo.titnat = vtitnat
                             and banfin.titulo.modcod = "PEA"
                             and banfin.titulo.etbcod = 1
                             and (if vsetcod = 0
                                  then true
                                  else banfin.titulo.titbanpag = vsetcod)
                                 no-lock.
        disp banfin.titulo.clifor.                             
    end.                             
    ***/
    
    if  recatu1 = ? then
        if vclifor = ?
        then
        find first banfin.titulo use-index titdtven
                    where banfin.titulo.empcod   = wempre.empcod and
            banfin.titulo.titnat   = vtitnat       and
            banfin.titulo.modcod   = vmodcod       and
            banfin.titulo.etbcod   = vetbcod       and
            (if vsetcod = 0
                                  then true
                                  else banfin.titulo.titbanpag = vsetcod)
            and banfin.titulo.titsit <> "PAG"                                  
            no-error.
        else
        find first banfin.titulo use-index titdtven
                    where banfin.titulo.empcod   = wempre.empcod and
            banfin.titulo.titnat   = vtitnat       and
            banfin.titulo.modcod   = vmodcod       and
            banfin.titulo.etbcod   = vetbcod       and
            /*banfin.titulo.clifor   = vclifor       and*/
            (if vsetcod = 0
             then true
             else banfin.titulo.titbanpag = vsetcod) 
             and banfin.titulo.titsit <> "PAG" no-error.
    else find banfin.titulo where recid(banfin.titulo) = recatu1.
    vinicio = no.
    if  not available banfin.titulo then do:
        message "Cadastro de banfin.titulos Vazio".
        message "Deseja Incluir " update sresp.
        if not sresp then undo.
        do with frame ftit2:
                /* vtitnum = "". */
/*                run tipo-documento. */
                vtitpar = 1.

            update vforcod with frame ftit2.
            find forne where forne.forcod = vforcod.
            vclifor = forne.forcod.
            vclifornom = forne.fornom.
            disp vclifornom.
            hide frame ftit2 no-pause.
            
            /* Funcionario */
            vfuncod = 0.
                vfunfol = "".
                if vmodcod = "PEA"
                then do on error undo, retry:
                    update vfunfol with frame ftit2
                        1 down side-label centered.
                    find first func where func.usercod = vfunfol
                    /*func.usercod = vfunfol */
                            no-lock no-error.
                    if not avail func
                    then do:
                        message color red/with
                        "Nao cadastrado. Certifique-se que o codigo da folha es~teja preenchido no cadastro de funcionario do estab 996, campo Usuario" view-as~ alert-box.
                        undo, retry.
                    end.    
                    disp func.funnom  no-label with frame ftit2.
                    pause 0.
                    vfuncod = func.funcod.
                    update vmeta vrealizada vcampanha with frame ftit2.
                    vtitobs[1] =  "FUNCIONARIO=" + string(vfuncod) + "|" +
                    "NOME=" + func.funnom + "|FUNFOLHA=" + vfunfol + "|" 
                    + "META=" + vmeta + "|".
                    vtitobs[2] = vtitobs[2] + "REALIZADA=" + vrealizada + "|CAMPANHA=" + vcampanha + "|".
                end.            

            find last btitulo where btitulo.empcod = wempre.empcod
                                and btitulo.titnat = vtitnat
                                and btitulo.modcod = vmodcod
                                and btitulo.etbcod = vetbcod
                                and btitulo.clifor = vclifor
                                and btitulo.titpar = 1 no-lock no-error.

                if avail btitulo
                then assign vnumtit = integer(btitulo.titnum) no-error.
                else assign vnumtit = 1 + setbcod.
                if error-status:error or vnumtit = ?
                then vnumtit = 1 + setbcod.
                vnumtit = vnumtit + 1.
                
                vtitnum = string(vnumtit).
                vtitpar = 1.

                update vtitnum vtitpar.
                IF KEYFUNCTION(LASTKEY) = "END-ERROR"
                THEN LEAVE BL-PRINC.
                find first btitulo where btitulo.empcod   = wempre.empcod and
                                         btitulo.titnat   = vtitnat       and
                                         btitulo.modcod   = vmodcod       and
                                         btitulo.etbcod   = vetbcod       and
                                         btitulo.clifor   = vclifor       and
                                         btitulo.titnum   = vtitnum       and
                                         btitulo.titpar   = vtitpar no-error.
                if avail btitulo
                then do:
                    message "banfin.titulo ja Existe".
                    undo, retry.
                end.
                vtitdtemi = today.
                /***
                disp vtitdtemi.
                ***/
                update /*vtitdtemi validate(vtitdtemi >= today - 30,
                           
                                    "Data invalida para emissao.")*/
                       vtotal label "Total".
                i = 0.
                vt = 0.
                ii = 0. vtot = 0.
                do i = 1 to vtitpar:
                    vdia = 0.
                    display i column-label "Par" with frame f-par.
                    update vdia column-label "Dias"
                                with frame f-par .
                    vvenc = /*vtitdtemi + vdia*/ today + 3.
                    update vvenc validate((vvenc >= (today + 3)),  
                            "Data invalida")
                    with frame f-par.
                    create banfin.titulo.
                    assign banfin.titulo.exportado = yes
                           banfin.titulo.empcod = wempre.empcod
                           banfin.titulo.titsit = "lib"
                           banfin.titulo.titnat = vtitnat
                           banfin.titulo.modcod = vmodcod
                           banfin.titulo.etbcod = vetbcod
                           banfin.titulo.datexp = today
                           banfin.titulo.clifor = vclifor
                           banfin.titulo.titnum = vtitnum
                           banfin.titulo.titpar  = i
                           banfin.titulo.titdtemi = vtitdtemi
                           banfin.titulo.titdtven = vvenc
                           banfin.titulo.titbanpag = vsetcod
                           banfin.titulo.titagepag = string(vtipo-documento)
                           banfin.titulo.vencod = sfuncod.
                    assign                           
                           banfin.titulo.titobs[1] = vtitobs[1]
                           banfin.titulo.titobs[2] = vtitobs[2] .
                           
                    banfin.titulo.titvlcob = (vtotal - vt) / (vtitpar - ii).
                    
                    ii = ii + 1.
                    do on error undo:
                        update banfin.titulo.titvlcob format "->>>,>>>,>>9.99"
                        with frame f-par no-validate.
                        if banfin.titulo.titvlcob = 0
                        then do:
                          message "Valor Parcela nao pode ser zero".
                            undo, retry.
                        end.
                        vt = vt + banfin.titulo.titvlcob.
                        assign                           
                           banfin.titulo.titobs[1] = vtitobs[1]
                           banfin.titulo.titobs[2] = vtitobs[2].
                        if vt <> vtotal and ii = vtitpar
                        then do:
                        message "Valor das prestacoes nao confere com o total".
                            undo, retry.
                        end.
                    end.
                    create wtit.
                    assign wtit.wrec = recid(banfin.titulo).
                    down with frame f-par.
                end.
                vcobcod = 1.
                /***
                update vcobcod.
                ***/
                find banfin.cobra where cobra.cobcod = vcobcod.
                /**
                display cobra.cobnom  no-label.
                if  cobra.cobban then do with frame fbanco2.
                    update vbancod.
                    find banco where banco.bancod = vbancod.
                    display banco.bandesc .
                    update vagecod.
                    find agenc of banco where agenc.agecod = vagecod.
                    display agedesc.
                end.
                **/
                wperjur = 0.
                vevecod = 0.
                /***
                update vevecod.
                ***/
                find banfin.event where event.evecod = vevecod no-lock.
                /**/
                /***
                display event.evenom no-label.
                update wperjur with frame fjurdes2.
                vtitvljur = 0.
                update vtitvljur column-label "Juros" with frame fjurdes2.
                wperdes = 0.
                update vtitdtdes
                       wperdes
                       vtitvldes format "->>>,>>9.99"
                        with frame fjurdes2 no-validate.
                ***/                
                /***
                vfuncod = 0.
                vfunfol = "".
                if vmodcod = "PEA"
                then do on error undo, retry:
                    update vfunfol with frame f-func
                        1 down side-label centered.
                    find first func where func.usercod = vfunfol
                            no-lock no-error.
                    if not avail func
                    then do:
                        message color red/with
                        "Nao cadastrado. Certifique-se que o codigo da folha esteja preenchido no cadastro de funcionario do estab 996, campo Usuario" view-as alert-box.
                        undo, retry.
                    end.    
                    disp func.funnom no-label with frame f-func.
                    pause 0.
                    vfuncod = func.funcod.
                    
                    update vmeta vrealizada vcampanha with frame f-func.
                    vtitobs[1] =  "FUNCIONARIO=" + string(vfuncod) + "|" +
                    "NOME=" + func.funnom + "|FUNFOLHA=" + vfunfol + "|"
                    "META=" + vmeta + "|".
                    vtitobs[2] = vtitobs[2] + "REALIZADA=" + vrealizada 
                               + "|CAMPANHA=" + vcampanha + "|".
                end.
                ***/
                /**/
                update text(vtitobs) with frame fobs2. pause 0.
                  /***********/
                vlancod = 0.
                vlanhis = 0.
                vcompl  = "".
                if vtitnat = yes
                then do on error undo, retry:
                
                    hide frame ff no-pause.
                    hide frame ff1 no-pause.
                    hide frame fdadpg no-pause.
                    hide frame f-com1 no-pause.
                    hide frame f-com2 no-pause.
                    hide frame ftitulo no-pause.
                    hide frame ftit    no-pause.
                    hide frame ftit2   no-pause.
                    hide frame fbancpg no-pause.
                    hide frame fbanco  no-pause.
                    hide frame fbanco2 no-pause.
                    hide frame fjurdes no-pause.
                    hide frame fjurdes2 no-pause.
                    hide frame fobs2  no-pause.
                    hide frame fobs   no-pause.
                    hide frame fpag1  no-pause.


                    if vclifor = 533
                    then vlanhis = 5.
                    
                    if vclifor = 100071
                    then vlanhis = 4.

                    if vclifor = 100072
                    then vlanhis = 3.

                    if banfin.titulo.modcod = "DUP"
                    then assign vlancod = 100
                                vlanhis = 1.
                    /*
                    find first lanaut where 
                               lanaut.etbcod = ? and
                               lanaut.forcod = ? and
                               lanaut.modcod = banfin.titulo.modcod
                               no-lock no-error.
                    if avail lanaut
                    then do:
                        assign
                            vlancod = lanaut.lancod
                            vlanhis = lanaut.lanhis
                            .
                    end. 
                    */          
                    else do:   
       
                        find last blancxa where blancxa.forcod = forne.forcod
                                            and  blancxa.etbcod = banfin.titulo.etbcod
                                            and  blancxa.lantip = "C"
                                            no-lock no-error.
                        if avail blancxa
                        then assign vlancod = blancxa.lancod
                                    vlanhis = blancxa.lanhis
                                    vcompl  = blancxa.comhis.
                     
                        if vclifor = 533
                        then vlanhis = 5.
                    
                        if vclifor = 100071
                        then vlanhis = 4.

                        if vclifor = 100072
                        then vlanhis = 3.
                        
                        find lanaut where lanaut.etbcod = banfin.titulo.etbcod and
                                           lanaut.forcod = banfin.titulo.clifor
                                                no-lock no-error.
                        if avail lanaut
                        then do:
                            assign vlancod = lanaut.lancod
                                   vlanhis = lanaut.lanhis.
                        end.

/***                     
                        if vlancod = 0 or
                           vlanhis = 0
                        then
                        
                        update vlancod label "Lancamento"
                               vlanhis label "Historico"
                                      with frame lanca centered side-label
                                                row 15 overlay.
***/                                                
                    end.                            
                    find tablan where tablan.lancod = vlancod no-lock no-error.
                    if vlanhis = 150
                    then vcompl = tablan.landes.
                    else if vlanhis <> 2
                         then vcompl = banfin.titulo.titnum + " " + forne.fornom.
                         else vcompl = forne.fornom.

                    find lanaut where lanaut.etbcod = banfin.titulo.etbcod and
                                      lanaut.forcod = banfin.titulo.clifor
                                                no-lock no-error.
                    if avail lanaut 
                    then do: 
                        assign vlanhis = lanaut.lanhis
                               vcompl  = lanaut.comhis
                               vlancod = lanaut.lancod.
                    end.
     
                         
                   /***                              
                    if vlancod <> 100
                    then update vcompl  label "Complemento"
                             with frame lanca centered side-label
                                   row 15 overlay.
                    if vlancod = 0
                    then do:
                        message "Lancamento Invalido".
                        undo, retry.
                    end.
                    if vlanhis = 6
                    then vcompl = "".
                    ***/
                     
                end.
                banfin.titulo.vencod = vlancod.
                banfin.titulo.titnumger = vcompl.
                banfin.titulo.titparger = vlanhis.
                /***********/
                
                for each wtit:
                    find banfin.titulo where recid(banfin.titulo) = wtit.wrec.
                    assign banfin.titulo.cobcod   = cobra.cobcod
                           banfin.titulo.bancod   = vbancod
                           banfin.titulo.agecod   = vagecod
                           banfin.titulo.evecod   = event.evecod
                           banfin.titulo.titvljur = vtitvljur
                           banfin.titulo.titdtdes = vtitdtdes
                           banfin.titulo.titvldes = vtitvldes
                           banfin.titulo.titobs[1] = vtitobs[1]
                           banfin.titulo.titobs[2] = vtitobs[2].
                end.
                vinicio = yes.
                recatu1 = recid(banfin.titulo).
                next.

        end.
    end.
    clear frame frame-a all no-pause.
    view frame ff.
    /***
    display banfin.titulo.titnum format "x(7)"
            banfin.titulo.titpar   format ">9"
        banfin.titulo.titvlcob format "->>,>>9.99" column-label "Vl.Cobrado"
        banfin.titulo.titdtven format "99/99/9999"   column-label "Dt.Vecto"
        banfin.titulo.titdtpag format "99/99/9999"   column-label "Dt.Pagto"
        banfin.titulo.titvlpag 
        when banfin.titulo.titvlpag > 0 format "->>,>>9.99"
                                            column-label "Valor Pago"
        banfin.titulo.titvljur column-label "Juros" format "->,>>9.9"
        banfin.titulo.titvldes column-label "Desc"  format ">>,>>9.9"
        banfin.titulo.titsit column-label "S" format "X"
        v-agendado
    ***/
    
    find forne where forne.forcod = banfin.titulo.clifor
            no-lock no-error.
    
    if acha("AGENDAR",banfin.titulo.titobs[2]) <> ? and
       banfin.titulo.titdtven <> date(acha("AGENDAR",banfin.titulo.titobs[2])) 
    then v-agendado = "*".
    else v-agendado = "".
    if acha("FUNCIONARIO",banfin.titulo.titobs[1]) <> ?
    then vmatricula = acha("FUNCIONARIO",banfin.titulo.titobs[1]).
    else vmatricula = "".
    find first func where func.funcod = int(vmatricula)
                            no-lock no-error.

    display 
            banfin.titulo.clifor label "Forne"
            vmatricula label "Matric."
            func.funnom when  avail func no-label format "x(10)"
           banfin.titulo.titnum format "x(7)"
            banfin.titulo.titpar   format ">9"
        banfin.titulo.titvlcob format "->>,>>9.99" column-label "Vl.Cobrado"
        banfin.titulo.titdtven format "99/99/9999"   column-label "Dt.Vecto"
        banfin.titulo.titsit column-label "Sit" format "x(3)"
            with frame frame-a  down centered color white/red
            title " " + vcliforlab + " " + forne.fornom + " "
                    + " Cod.: " + string(vclifor) + " " width 80.
    pause 0.
    recatu1 = recid(banfin.titulo).
    if  esqregua then do:
        display esqcom1[esqpos1] with frame f-com1.
        color  display message esqcom1[esqpos1] with frame f-com1.
    end.
    else do:
        display esqcom2[esqpos2] with frame f-com2.
        color display message esqcom2[esqpos2] with frame f-com2.
    end.
    repeat:
            if vclifor = ?
            then
            find next banfin.titulo use-index titdtven
                             where banfin.titulo.empcod   = wempre.empcod and
                                   banfin.titulo.titnat   = vtitnat       and
                                   banfin.titulo.modcod   = vmodcod       and
                                   banfin.titulo.etbcod   = vetbcod   and
                                 /*  banfin.titulo.clifor   = vclifor  and */
                                 recid(banfin.titulo) <> recatu1 and
                                   (if vsetcod = 0
                                  then true
                                  else banfin.titulo.titbanpag = vsetcod)  
                                  and banfin.titulo.titsit <> "PAG"
                                  no-error.
                                                else      
            find next banfin.titulo use-index titdtven
                             where banfin.titulo.empcod   = wempre.empcod and
                                   banfin.titulo.titnat   = vtitnat       and
                                   banfin.titulo.modcod   = vmodcod       and
                                   banfin.titulo.etbcod   = vetbcod   and
                 /*                  banfin.titulo.clifor   = vclifor  and*/
                                   (if vsetcod = 0
                                  then true
                                  else banfin.titulo.titbanpag = vsetcod)
                                  and banfin.titulo.titsit <> "PAG"
                                    no-error.
        if not available banfin.titulo
        then leave.
        if frame-line(frame-a) = frame-down(frame-a)
        then leave.
        if not vinicio
        then down with frame frame-a.
        view frame ff.
        if acha("AGENDAR",banfin.titulo.titobs[2]) <> ? and
           banfin.titulo.titdtven <> date(acha("AGENDAR",banfin.titulo.titobs[2])) 
        then v-agendado = "*".
        else v-agendado = "".
    find forne where forne.forcod = banfin.titulo.clifor
            no-lock no-error.
    
    if acha("AGENDAR",banfin.titulo.titobs[2]) <> ? and
       banfin.titulo.titdtven <> date(acha("AGENDAR",banfin.titulo.titobs[2])) 
    then v-agendado = "*".
    else v-agendado = "".
    if acha("FUNCIONARIO",banfin.titulo.titobs[1]) <> ?
    then vmatricula = acha("FUNCIONARIO",banfin.titulo.titobs[1]).
    else vmatricula = "".
    
    display 
            banfin.titulo.clifor label "Forne"
            vmatricula label "Matric."
           banfin.titulo.titnum format "x(7)"
            banfin.titulo.titpar   format ">9"
        banfin.titulo.titvlcob format "->>,>>9.99" column-label "Vl.Cobrado"
        banfin.titulo.titdtven format "99/99/9999"   column-label "Dt.Vecto"
        banfin.titulo.titsit column-label "Sit" format "x(3)"
            with frame frame-a 9 down centered color white/red
            title " " + vcliforlab + " " + forne.fornom + " "
                    + " Cod.: " + string(vclifor) + " " width 80.
        
        pause 0.
    end.
    up frame-line(frame-a) - 1 with frame frame-a.
    repeat with frame frame-a:
        find banfin.titulo where recid(banfin.titulo) = recatu1.
        color display messages banfin.titulo.titnum banfin.titulo.titpar.
        
        on f7 recall.
        choose field banfin.titulo.titnum banfin.titulo.titpar
            go-on(cursor-down cursor-up cursor-left cursor-right F7 PF7
                  page-up page-down tab PF4 F4 ESC return v V ).
        {pagtit.i}
       if  keyfunction(lastkey) = "RECALL"
       then do with frame fproc centered row 5 overlay color message side-label:
            prompt-for banfin.titulo.titnum colon 10.
            find first banfin.titulo where banfin.titulo.empcod   = wempre.empcod and
                                    banfin.titulo.titnat   = vtitnat       and
                                    banfin.titulo.modcod   = vmodcod       and
                                    banfin.titulo.etbcod   = vetbcod       and
                                    banfin.titulo.clifor   = vclifor       and
                                    (if vsetcod = 0
                                  then true
                                  else banfin.titulo.titbanpag = vsetcod)      and
                                  banfin.titulo.titnum >= input banfin.titulo.titnum 
and banfin.titulo.titsit <> "PAG" no-error.
            recatu1 = if avail banfin.titulo
                      then recid(banfin.titulo) else ?. leave.
       end. on f7 help.
       if  keyfunction(lastkey) = "V" or
           keyfunction(lastkey) = "v"
       then do with frame fdt centered row 5 overlay color message side-label:
            vdt = today.
            update vdt label "Vencimento".
            if vclifor = ?
            then 
            find first banfin.titulo use-index titdtven
                              where banfin.titulo.empcod   = wempre.empcod and
                                    banfin.titulo.titnat   = vtitnat       and
                                    banfin.titulo.modcod   = vmodcod       and
                                    banfin.titulo.titsit   = "LIB"         and 
                                    banfin.titulo.etbcod   = vetbcod       and
             /*               banfin.titulo.clifor   = vclifor       and */
                                    recid(banfin.titulo) <> recatu1 and
                                    (if vsetcod = 0
                                  then true
                                  else banfin.titulo.titbanpag = vsetcod) 
                                  and banfin.titulo.titsit <> "PAG"
no-error.                                     else 
            find first banfin.titulo use-index titdtven
                              where banfin.titulo.empcod   = wempre.empcod and
                                    banfin.titulo.titnat   = vtitnat       and
                                    banfin.titulo.modcod   = vmodcod       and
                                    banfin.titulo.titsit   = "LIB"         and                                     banfin.titulo.etbcod   = vetbcod       and
                     /*           banfin.titulo.clifor   = vclifor       and*/
                                    (if vsetcod = 0
                                  then true
                                  else banfin.titulo.titbanpag = vsetcod) no-error.
            if avail banfin.titulo
            then recatu1 = recid(banfin.titulo). 
            else do:
                if vclifor = ?
                then
                find next banfin.titulo use-index titdtven where 
                                 banfin.titulo.empcod = wempre.empcod   and
                                 banfin.titulo.titnat   = vtitnat       and
                                 banfin.titulo.modcod   = vmodcod       and
                                 banfin.titulo.titsit   = "LIB"         and                                      banfin.titulo.etbcod   = vetbcod       and
                                /* banfin.titulo.clifor   = vclifor       and*/
                                 recid(banfin.titulo) <> recatu1 and
                                 /*banfin.titulo.titdtven >= vdt          and*/
                                 (if vsetcod = 0
                                  then true
                                  else banfin.titulo.titbanpag = vsetcod) no-error.                
                else 
                find next banfin.titulo use-index titdtven where 
                                 banfin.titulo.empcod = wempre.empcod   and
                                 banfin.titulo.titnat   = vtitnat       and
                                 banfin.titulo.modcod   = vmodcod       and
                                 banfin.titulo.titsit   = "LIB"         and                                     banfin.titulo.etbcod   = vetbcod       and
            /*         banfin.titulo.clifor   = vclifor       and*/
/*                                 banfin.titulo.titdtven >= vdt          and*/
                                 (if vsetcod = 0
                                  then true
                                  else banfin.titulo.titbanpag = vsetcod) no-error.
                             
                if avail banfin.titulo
                then recatu1 = recid(banfin.titulo).
                else do:
                    if vclifor = ?
                    then 
                    find prev banfin.titulo use-index titdtven where 
                                 banfin.titulo.empcod = wempre.empcod   and
                                 banfin.titulo.titnat   = vtitnat       and
                                 banfin.titulo.modcod   = vmodcod       and
                                 banfin.titulo.titsit   = "LIB"         and                                      banfin.titulo.etbcod   = vetbcod       and
                                 /*banfin.titulo.clifor   = vclifor       and*/
                                 /*banfin.titulo.titdtven <= vdt          and*/
                                 recid(banfin.titulo) <> recatu1 and
                                 (if vsetcod = 0
                                  then true
                                  else banfin.titulo.titbanpag = vsetcod) no-error.
                    else                                                      
                     find prev banfin.titulo use-index titdtven                               where banfin.titulo.empcod   = wempre.empcod and
                                     banfin.titulo.titnat   = vtitnat       and
                                     banfin.titulo.modcod   = vmodcod       and
                                     banfin.titulo.titsit   = "LIB"         and                                     banfin.titulo.etbcod   = vetbcod   /*  and
                                banfin.titulo.clifor   = vclifor */ and
                                     (if vsetcod = 0
                                  then true
                                  else banfin.titulo.titbanpag = vsetcod)no-error. 
                 
                    if avail banfin.titulo
                    then recatu1 = recid(banfin.titulo).
                    else recatu1 = ?.
                end.    
                      
            end.   
            leave.
        end. 
        
        if  keyfunction(lastkey) = "TAB" then do:
            if  esqregua then do:
                color display normal
                    esqcom1[esqpos1]
                    with frame f-com1.
                color display message
                    esqcom2[esqpos2]
                    with frame f-com2.
            end.
            else do:
                color display normal
                    esqcom2[esqpos2]
                    with frame f-com2.
                color display message
                    esqcom1[esqpos1]
                    with frame f-com1.
            end.
            esqregua = not esqregua.
        end.
        if keyfunction(lastkey) = "cursor-right" then do:
            if  esqregua then do:
                color display normal
                    esqcom1[esqpos1]
                    with frame f-com1.
                esqpos1 = if esqpos1 = 5
                          then 5
                          else esqpos1 + 1.
                color display messages
                    esqcom1[esqpos1]
                    with frame f-com1.
            end.
            else do:
                color display normal
                    esqcom2[esqpos2]
                    with frame f-com2.
                esqpos2 = if esqpos2 = 3
                          then 3
                          else esqpos2 + 1.
                color display messages
                    esqcom2[esqpos2]
                    with frame f-com2.
            end.
            next.
        end.
        if keyfunction(lastkey) = "cursor-left" then do:
            if esqregua then do:
                color display normal
                    esqcom1[esqpos1]
                    with frame f-com1.
                esqpos1 = if esqpos1 = 1
                          then 1
                          else esqpos1 - 1.
                color display messages
                    esqcom1[esqpos1]
                    with frame f-com1.
            end.
            else do:
                color display normal
                    esqcom2[esqpos2]
                    with frame f-com2.
                esqpos2 = if esqpos2 = 1
                          then 1
                          else esqpos2 - 1.
                color display messages
                    esqcom2[esqpos2]
                    with frame f-com2.
            end.
            next.
        end.
        if keyfunction(lastkey) = "cursor-down" then do:
            if vclifor = ?
            then
            find next banfin.titulo use-index titdtven
                             where banfin.titulo.empcod   = wempre.empcod and
                                   banfin.titulo.titnat   = vtitnat       and
                                   banfin.titulo.modcod   = vmodcod       and
                                   banfin.titulo.etbcod   = vetbcod   and
                                 /*  banfin.titulo.clifor   = vclifor  and */
                                 recid(banfin.titulo) <> recatu1 and
                                  (if vsetcod = 0
                                  then true
                                  else banfin.titulo.titbanpag = vsetcod)  no-error.              else      
            find next banfin.titulo use-index titdtven
                             where banfin.titulo.empcod   = wempre.empcod and
                                   banfin.titulo.titnat   = vtitnat       and
                                   banfin.titulo.modcod   = vmodcod       and
                                   banfin.titulo.etbcod   = vetbcod   and
                /*                   banfin.titulo.clifor   = vclifor  and*/
                                   (if vsetcod = 0
                                  then true
                                  else banfin.titulo.titbanpag = vsetcod)  no-error.
            if  not avail banfin.titulo
            then next.
            color display normal banfin.titulo.titnum banfin.titulo.titpar.
            if frame-line(frame-a) = frame-down(frame-a)
            then scroll with frame frame-a.
            else down with frame frame-a.
        end.
        if  keyfunction(lastkey) = "cursor-up" then do:
            if vclifor = ?
            then
            find prev banfin.titulo use-index titdtven
                             where banfin.titulo.empcod   = wempre.empcod and
                                   banfin.titulo.titnat   = vtitnat       and
                                   banfin.titulo.modcod   = vmodcod       and
                                   banfin.titulo.etbcod   = vetbcod       and
                                   /*banfin.titulo.clifor   = vclifor and */
                                   recid(banfin.titulo) <> recatu1 and
                                   (if vsetcod = 0
                                  then true
                                  else banfin.titulo.titbanpag = vsetcod) no-error.               else
            find prev banfin.titulo use-index titdtven
                             where banfin.titulo.empcod   = wempre.empcod and
                                   banfin.titulo.titnat   = vtitnat       and
                                   banfin.titulo.modcod   = vmodcod       and
                                   banfin.titulo.etbcod   = vetbcod       and
                /*                   banfin.titulo.clifor   = vclifor and*/
                                   (if vsetcod = 0
                                  then true
                                  else banfin.titulo.titbanpag = vsetcod) no-error.
            if not avail banfin.titulo
            then next.
            color display normal banfin.titulo.titnum banfin.titulo.titpar.
            if frame-line(frame-a) = 1
            then scroll down with frame frame-a.
            else up with frame frame-a.
        end.
        if keyfunction(lastkey) = "end-error"
        then leave bl-princ.
        if keyfunction(lastkey) = "return"
        then do on error undo, retry on endkey undo, leave.
          if keyfunction(lastkey) = "END-ERROR"
          THEN NEXT BL-PRINC.
          if esqcom2[esqpos2] <> "Pagamento/Cancelamento" or
             esqcom2[esqpos2] <> "Bloqueio/Liberacao"
          then hide frame frame-a no-pause.
          /*
          display vcliforlab at 6 vclifornom
                with frame frame-b 1 down centered color blue/gray
                width 81 no-box no-label row 5 overlay.
            */
          if  esqregua then do:
            if  esqcom1[esqpos1] = "Inclusao" then do with frame ftit2:
                /* vtitnum = "". */
/*                run tipo-documento. */
/***/
            update vforcod.
            find forne where forne.forcod = vforcod.
            vclifor = forne.forcod.
            vclifornom = forne.fornom.
            disp vclifornom.
            hide frame ftit2 no-pause.
            
            /* Funcionario */
/*                vfunfol = "".*/
                if vmodcod = "PEA"
                then do on error undo, retry:
                    update vfunfol.
                    find first func where func.usercod = vfunfol
                            no-lock no-error.
                    if not avail func
                    then do:
                        message color red/with
                        "Nao cadastrado. Certifique-se que o codigo da folha es~~teja preenchido no cadastro de funcionario do estab 996, campo Usuario" view-a~s~ alert-box.
                        undo, retry.
                    end.    
                    disp func.funnom  no-label with frame ftit2.
                    pause 0.
                    vfuncod = func.funcod.
                    update vmeta vrealizada vcampanha with frame ftit2.
                    vtitobs[1] =  "FUNCIONARIO=" + string(vfuncod) + "|" +
                    "NOME=" + func.funnom + "|FUNFOLHA=" + vfunfol + "|" 
                    + "META=" + vmeta + "|".
                    vtitobs[2] = vtitobs[2] + "REALIZADA=" + vrealizada 
                               + "|CAMPANHA=" + vcampanha + "|".
                end.            

            find last btitulo where btitulo.empcod = wempre.empcod
                                and btitulo.titnat = vtitnat
                                and btitulo.modcod = vmodcod
                                and btitulo.etbcod = vetbcod
                                and btitulo.clifor = vclifor
                                and btitulo.titpar = 1 no-lock no-error.
     
                if avail btitulo
                then assign vnumtit = integer(btitulo.titnum) no-error.
                else assign vnumtit = 1 + setbcod.
                if error-status:error or vnumtit = ?
                then vnumtit = 1 + setbcod.
                vnumtit = vnumtit + 1.
                
                vtitnum = string(vnumtit).
                vtitpar = 1.

/***/                
                update vtitnum vtitpar.
                find first btitulo where btitulo.empcod   = wempre.empcod and
                                         btitulo.titnat   = vtitnat       and
                                         btitulo.modcod   = vmodcod       and
                                         btitulo.etbcod   = vetbcod       and
                                         btitulo.clifor   = vclifor       and
                                         btitulo.titnum   = vtitnum       and
                                         btitulo.titpar   = vtitpar no-error.
                if avail btitulo
                then do:
                    message "btitulo ja Existe".
                    undo, retry.
                end.
                update /*vtitdtemi*/ vtotal label "Total".
                i = 0. ii = 0. vt = 0. vtot = 0.
                do i = 1 to vtitpar:
                    vdia = 0.
                    display i column-label "Par" with frame f-par.
                    update vdia column-label "Dias"
                                with frame f-par.
                    vvenc = /*vtitdtemi + vdia*/ today + 3.
                    update vvenc validate((vvenc >= (today + 3)),  
                            "Data invalida")
                    with frame f-par.
                    do on error undo:
                    create banfin.titulo.
                    assign banfin.titulo.exportado = yes
                           banfin.titulo.empcod = wempre.empcod
                           banfin.titulo.titsit = "lib"
                           banfin.titulo.titnat = vtitnat
                           banfin.titulo.modcod = vmodcod
                           banfin.titulo.etbcod = vetbcod
                           banfin.titulo.datexp = today
                           banfin.titulo.clifor = vclifor
                           banfin.titulo.titnum = vtitnum
                           banfin.titulo.titpar  = i
                           banfin.titulo.titdtemi = vtitdtemi
                           banfin.titulo.titdtven = vvenc
                           banfin.titulo.titvlcob = (vtotal - vt) 
                                                  / (vtitpar - ii)
                           ii = ii + 1
                           banfin.titulo.titbanpag = vsetcod
                           banfin.titulo.titagepag = string(vtipo-documento)
                           banfin.titulo.vencod   = sfuncod
                           banfin.titulo.titobs[1] = vtitobs[1]
                           banfin.titulo.titobs[2] = vtitobs[2].
                    end.

                    do on error undo:
                        update banfin.titulo.titvlcob format "->>>,>>>,>>9.99"
                        with frame f-par no-validate.
                        if banfin.titulo.titvlcob = 0
                        then do:
                          message "Valor Parcela nao pode ser zero".
                            undo, retry.
                        end.
                        vt = vt + banfin.titulo.titvlcob.
                        if vt <> vtotal and ii = vtitpar
                        then do:
                        message "Valor das prestacoes nao confere com o total".
                            undo, retry.
                        end.
                    end.
                    assign 
                           banfin.titulo.titobs[1] = vtitobs[1]
                           banfin.titulo.titobs[2] = vtitobs[2].                 
                    create wtit.
                    assign wtit.wrec = recid(banfin.titulo).
                    vtot = vtot + banfin.titulo.titvlcob.
                    down with frame f-par.
                end.
                hide frame f-par no-pause.
                vcobcod = 1.
                /***
                update vcobcod.
                ***/
                find cobra where cobra.cobcod = vcobcod.
                /***
                display cobra.cobnom  no-label.
                ***/
                /**
                if  cobra.cobban then do with frame fbanco2.
                    update vbancod.
                    find banco where banco.bancod = vbancod.
                    display banco.bandesc .
                    update vagecod.
                    find agenc of banco where agenc.agecod = vagecod.
                    display agedesc.
                end.
                **/
                wperjur = 0.
                vevecod = 0. 
                /***
                update vevecod.
                ***/
                find event where event.evecod = vevecod no-lock.
                /***
                display event.evenom no-label.
                ***/
                
                wperjur = 0.
                vtitvljur = 0.
                wperdes = 0.
/*                vtitobs = "".*/
                vtitvldes = 0.
                vtitdtdes = ?.
                /***
                update wperjur with frame fjurdes2.
                update vtitvljur column-label "Juros" with frame fjurdes2.
                wperdes = 0.
                update vtitdtdes
                       wperdes
                       vtitvldes format "->>>,>>9.99"
                            with frame fjurdes2 no-validate.
                ***/                            
                vfuncod = 0.
                vfunfol = "".
                /***
                if vmodcod = "PEA"
                then do on error undo, retry:
                    update vfunfol with frame f-func
                        1 down side-label centered.
                    find first func where func.usercod = vfunfol
                                    no-lock no-error.
                    if not avail func
                    then do:
                        message color red/with
                        "Nao cadastrado. Certifique-se que o codigo da folha esteja preenchido no cadastro de funcionario do estab 996, campo Usuario." view-as alert-box.
                        undo, retry.
                    end.    
                    disp func.funnom no-label with frame f-func.
                    pause.
                    vfuncod = func.funcod.
                    update vmeta vrealizada vcampanha with frame f-func.
                    vtitobs[1] =  "FUNCIONARIO=" + string(vfuncod) + "|" +
                    "NOME=" + func.funnom + "|" + "FUNFOLHA=" + vfunfol
                    + "|META=" + vmeta + "|".
                    vtitobs[2] = vtitobs[2] + "REALIZADA=" + vrealizada 
                               + "|CAMPANHA=" + vcampanha + "|".
                end.
                ***/

                update text(vtitobs) with frame fobs2. pause 0.

                /******* frete *********/
                /***
                    vv = 0.
                    update vfre label "Frete" with frame f-fre
                            centered side-label row 8.
                    if vfre = 2
                    then do:
                        vv = 0.            
                        for each ftitulo use-index cxmdat where 
                                        ftitulo.etbcod = btitulo.etbcod and
                                        ftitulo.cxacod = btitulo.clifor and
                                        ftitulo.titnumger = 
                                                        string(btitulo.titnum) 
                                          no-lock.
                            find first frete where frete.forcod = 
                                      ftitulo.clifor no-lock.
                            display ftitulo.etbcod
                                    ftitulo.titdtven
                                    ftitulo.titnum column-label "Conhec."
                                                 format "x(10)"
                                    ftitulo.titnumger column-label "NF.Fiscal"
                                                 format "x(07)"
                                    frete.frenom format "x(20)"
                                    ftitulo.titvlcob column-label "Vl.Cobrado" 
                                           format "->>>,>>>,>>9.99"
                                           with frame ffrete  1 down row 15
                                            width 80 centered color white/cyan.
                            vv = vv + 1.
                            pause.
                        end.    
                        if vv = 0
                        then do:
                            update  vfrecod with frame f-frete2.
                            find frete where frete.frecod = vfrecod no-lock.
                            display frete.frenom no-label with frame f-frete2.
                            vlfrete = 0.
                            update vlfrete label "Valor Frete"
                                        with frame f-frete2.

                            create btitulo.
                            assign btitulo.exportado = yes
                                   btitulo.etbcod   = banfin.titulo.etbcod
                                   btitulo.titnat   = yes
                                   btitulo.modcod   = "NEC"
                                   btitulo.clifor   = frete.forcod
                                   btitulo.cxacod   = forne.forcod
                                   btitulo.titsit   = "lib"
                                   btitulo.empcod   = banfin.titulo.empcod
                                   btitulo.titdtemi = banfin.titulo.titdtemi
                                   btitulo.titnum   = banfin.titulo.titnum
                                   btitulo.titpar   = 1
                                   btitulo.titnumger = banfin.titulo.titnum
                                   btitulo.titvlcob = vlfrete
                                   btitulo.vencod   = sfuncod.
                                   
                            update btitulo.titdtven label "Venc.Frete"
                                   btitulo.titnum   label "Controle"
                                with frame f-frete2 centered color white/cyan
                                                side-label row 15 no-validate.

                        end.    
                            
                    end. 
                    hide frame ffrete no-pause.
                    
                    ***/
                
                /**********************/
                
                vlancod = 0.
                vlanhis = 0.
                if vtitnat = yes
                then do on error undo, retry:
                    hide frame ff no-pause.
                    hide frame ff1 no-pause.
                    hide frame fdadpg no-pause.
                    hide frame f-com1 no-pause.
                    hide frame f-com2 no-pause.
                    hide frame ftitulo no-pause.
                    hide frame ftit    no-pause.
                    hide frame ftit2   no-pause.
                    hide frame fbancpg no-pause.
                    hide frame fbanco  no-pause.
                    hide frame fbanco2 no-pause.
                    hide frame fjurdes no-pause.
                    hide frame fjurdes2 no-pause.
                    hide frame fobs2  no-pause.
                    hide frame fobs   no-pause.
                    hide frame fpag1  no-pause.

                    if vclifor = 533
                    then vlanhis = 5.
                    
                    if vclifor = 100071
                    then vlanhis = 4.

                    if vclifor = 100072
                    then vlanhis = 3.

                    if banfin.titulo.modcod = "DUP"
                    then assign vlancod = 100
                                vlanhis = 1.
                    /*
                    find first lanaut where 
                               lanaut.etbcod = ? and
                               lanaut.forcod = ? and
                               lanaut.modcod = banfin.titulo.modcod
                               no-lock no-error.
                    if avail lanaut
                    then do:
                        assign
                            vlancod = lanaut.lancod
                            vlanhis = lanaut.lanhis
                            .
                    end.
                    */             
                    else do:
                        find last blancxa where 
                                     blancxa.forcod = forne.forcod  and
                                     blancxa.etbcod = banfin.titulo.etbcod and
                                     blancxa.lantip = "C"
                                             no-lock no-error.
                        if avail blancxa
                        then assign vlancod = blancxa.lancod
                                    vlanhis = blancxa.lanhis
                                    vcompl  = blancxa.comhis.
                        
                        if vclifor = 533
                        then vlanhis = 5.
                    
                        if vclifor = 100071
                        then vlanhis = 4.

                        if vclifor = 100072
                        then vlanhis = 3.
                        
                        find lanaut where lanaut.etbcod = banfin.titulo.etbcod and
                                          lanaut.forcod = banfin.titulo.clifor
                                                no-lock no-error.
                        if avail lanaut  
                        then do:  
                            assign vlanhis = lanaut.lanhis 
                                   vcompl  = lanaut.comhis 
                                   vlancod = lanaut.lancod.
                        end.
     
 
/***                         
                        if vlancod = 0
                        then update vlancod label "Lancamento"
                                      with frame lanca centered side-label
                                         row 15 overlay.
***/                                         
                                         
                    end.
                    
                    find tablan where tablan.lancod = vlancod no-lock no-error.
                    if not avail tablan
                    then do:
                        message "Lancamento Invalido".
                        undo, retry.
                    end.

                    if vlanhis = 0
                    then vlanhis = tablan.lanhis.

                    find lanaut where lanaut.etbcod = banfin.titulo.etbcod and
                                      lanaut.forcod = banfin.titulo.clifor
                                                no-lock no-error.
                    if avail lanaut 
                    then do: 
                        assign vlanhis = lanaut.lanhis
                               vcompl  = lanaut.comhis
                               vlancod = lanaut.lancod.
                    end.
     
                    
                    
                    if vlanhis = 150
                    then vcompl = tablan.landes.
                    else if vlanhis <> 2
                         then vcompl = banfin.titulo.titnum + " " + forne.fornom.
                         else vcompl = forne.fornom.
                    
                  
                    
                    
                    
/***                    
                    if vlancod = 100
                    then assign vlanhis = 1
                                vcompl = banfin.titulo.titnum + " " + forne.fornom.
                                
                                
                    
                    else if
                         vlanhis = 0 or
                         vcompl  = ""
                         then update vlanhis label "Historico"
                                     vcompl  label "Complemento"
                                        with frame lanca centered side-label
                                               row 15 overlay.
***/                                               
                    if vlanhis = 6
                    then vcompl = "".
                end.
                banfin.titulo.vencod = vlancod.
                banfin.titulo.titnumger = vcompl.
                banfin.titulo.titparger = vlanhis. 
                /***********/
                
                for each wtit:
                    find banfin.titulo where recid(banfin.titulo) = wtit.wrec.
                    assign banfin.titulo.cobcod   = cobra.cobcod
                           banfin.titulo.bancod   = vbancod
                           banfin.titulo.agecod   = vagecod
                           banfin.titulo.evecod   = event.evecod
                           banfin.titulo.titvljur = vtitvljur
                           banfin.titulo.titdtdes = vtitdtdes
                           banfin.titulo.titvldes = vtitvldes
                           banfin.titulo.titobs[1] = vtitobs[1]
                           banfin.titulo.titobs[2] = vtitobs[2].
                    delete wtit.
                end.
                
                recatu1 = recid(banfin.titulo).
                leave.
            end.
            if esqcom1[esqpos1] = "Alteracao"
            then do with frame ftitulo:
                vtitvlcob = banfin.titulo.titvlcob .
                banfin.titulo.datexp = today.
                hide frame f-senha no-pause.
                hide frame f-fre2 no-pause.

        if acha("FUNCIONARIO",banfin.titulo.titobs[1]) <> ?
        then vfuncionario = acha("FUNCIONARIO",banfin.titulo.titobs[1]).
        else vfuncionario = "".
        if acha("META",banfin.titulo.titobs[1]) <> ?
        then vmeta = acha("META",banfin.titulo.titobs[1]).
        else vmeta = "".
        if acha("REALIZADA",banfin.titulo.titobs[2]) <> ?
        then vrealizada = acha("REALIZADA",banfin.titulo.titobs[2]).
        else vrealizada = "".                
        if acha("CAMPANHA",banfin.titulo.titobs[2]) <> ?
        then vcampanha = acha("CAMPANHA",banfin.titulo.titobs[2]).
        else vcampanha = "".
                vfuncionario1 = "FUNCIONARIO=" + vfuncionario.
                vmeta1 = "META=" + vmeta.
                vrealizada2 = "REALIZADA=" + vrealizada.
                vcampanha2 = "CAMPANHA=" + vcampanha.
                        
                update banfin.titulo.clifor column-label "Fornecedor"
                       banfin.titulo.titnum
                       banfin.titulo.titpar
                       banfin.titulo.titdtemi
                       banfin.titulo.titdtven
                       banfin.titulo.titvlcob format "->>>,>>>,>>9.99"
                       vmeta
                       vrealizada
                       vcampanha
                       /*banfin.titulo.cobcod*/ with no-validate.
                       
                       
                  if acha("META",banfin.titulo.titobs[2]) <> ?
                  then vtitobs[2] = replace(vtitobs[2],vrealizada2,vrealizada).
                  else vtitobs[2] = vtitobs[2] + "|REALIZADA=" + vrealizada.                      if acha("REALIZADA",banfin.titulo.titobs[2]) <> ?
                  then vtitobs[2] = replace(vtitobs[2],vrealizada2,vrealizada).
                  else vtitobs[2] = vtitobs[2] + "|REALIZADA=" + vrealizada.
                  if acha("CAMPANHA",banfin.titulo.titobs[2]) <> ?
                  then vtitobs[2] = replace(vtitobs[2],vcampanha2,vcampanha).
                  else vtitobs[2] = vtitobs[2] + "|CAMPANHA=" + vcampanha.
          
                find cobra where cobra.cobcod = banfin.titulo.cobcod.
                display cobra.cobnom.
                if cobra.cobban
                then do with frame fbanco:
                    update banfin.titulo.bancod.
                    find banco where banco.bancod = banfin.titulo.bancod.
                    display banco.bandesc .
                    update banfin.titulo.agecod.
                    find agenc of banco where agenc.agecod = banfin.titulo.agecod.
                    display agedesc.
                end.
                update banfin.titulo.modcod colon 15.
                find fin.modal where modal.modcod = banfin.titulo.modcod no-lock.
                display fin.modal.modnom no-label.
                /***
                update banfin.titulo.evecod colon 15.
                find event where event.evecod = banfin.titulo.evecod no-lock.
                display event.evenom no-label.
                update banfin.titulo.titvljur with frame fjurdes .
                update banfin.titulo.titdtdes with frame fjurdes.
                update banfin.titulo.titvldes format ">>>,>>9.99"
                        with frame fjurdes no-validate.
                ***/        
                update 123 text(banfin.titulo.titobs) with frame fobs.
                if  banfin.titulo.titvlcob <> vtitvlcob then do:
                   if  banfin.titulo.titvlcob < vtitvlcob then do:
                    assign sresp = yes.
                    display "  Confirma GERACAO DE NOVO TITULO ? " /* banfin.titulo ?"*/
                                with frame fGERT color messages
                                width 60 overlay row 10 centered.
                    update sresp no-label with frame fGERT.
                    if  sresp then do:
                        find last btitulo where
                            btitulo.empcod   = wempre.empcod and
                            btitulo.titnat   = vtitnat       and
                            btitulo.modcod   = vmodcod       and
                            btitulo.etbcod   = vetbcod       and
                            btitulo.clifor   = vclifor       and
                            btitulo.titnum   = banfin.titulo.titnum.
                            create ctitulo.
                            assign ctitulo.exportado = yes
                                   ctitulo.empcod = btitulo.empcod
                                   ctitulo.modcod = btitulo.modcod
                                   ctitulo.clifor = btitulo.clifor
                                   ctitulo.titnat = btitulo.titnat
                                   ctitulo.etbcod = btitulo.etbcod
                                   ctitulo.titnum = btitulo.titnum
                                   ctitulo.cobcod = banfin.titulo.cobcod
                                   ctitulo.titpar   = btitulo.titpar + 1
                                   ctitulo.titdtemi = today
                                   ctitulo.titdtven = banfin.titulo.titdtven
                                   ctitulo.titvlcob = 
                                   vtitvlcob - banfin.titulo.titvlcob
                                   ctitulo.titnumger = banfin.titulo.titnum
                                   ctitulo.titparger = banfin.titulo.titpar
                                   ctitulo.datexp    = today
                                   ctitulo.vencod    = sfuncod.
                            display ctitulo.titnum
                                    ctitulo.titpar
                                    ctitulo.titdtemi
                                    ctitulo.titdtven
                                    ctitulo.titvlcob format "->>>,>>>,>>9.99"
                                    with frame fmos width 40 1 column
                                              title " banfin.titulo Gerado " 
                                              overlay
                                              centered row 10.
                            recatu1 = recid(ctitulo).
                            leave.
                        end.
                     end.
                     else do:
                        display "  Confirma AUMENTO NO VALOR ?" 
                        /*DO banfin.titulo?"*/
                                with frame faum color messages
                                width 60 overlay row 10 centered.
                        update sresp no-label with frame faum.
                        if not sresp then undo, leave.
                    end.
               
                end.
                message "Confirma ? " /*banfin.titulo"*/ update sresp.
                if sresp
                then do on error undo:
                    /*
                    for each zbanfin.titulo use-index titsit where
                                            zbanfin.titulo.clifor = banfin.titulo.clifor and
                                            zbanfin.titulo.titnat = yes no-lock:
                        if zbanfin.titulo.titnum begins "A"
                        then do:
                            display zbanfin.titulo.etbcod
                                    zbanfin.titulo.titnum
                                    zbanfin.titulo.titpar
                                    zbanfin.titulo.titdtven
                                    zbanfin.titulo.titdtpag
                                    zbanfin.titulo.titvlpag 
                                                    format "->>>,>>>,>>9.99" 
                                        with frame f-alerta down
                                                centered overlay row 10
                                                    color black/yellow.
                            pause.
                        end.
                    end. 
                    */
                    hide frame f-alerta no-pause.
                    vv = 0.
                    /****
                    update vfre label "Frete" with frame f-fre2
                            centered side-label row 8.
                    if vfre = 2
                    then do:
                        vv = 0.            
                        for each ftitulo use-index cxmdat where 
                                        ftitulo.etbcod = banfin.titulo.etbcod and
                                        ftitulo.cxacod = banfin.titulo.clifor and
                                        ftitulo.titnumger = 
                                                        string(banfin.titulo.titnum) 
                                          no-lock.
                            find first frete where frete.forcod = 
                                                        ftitulo.clifor
                                                                    no-lock.
                            display ftitulo.etbcod
                                    ftitulo.titdtven
                                    ftitulo.titnum column-label "Conhec."
                                                 format "x(10)"
                                    ftitulo.titnumger column-label "NF.Fiscal"
                                                 format "x(07)"
                                    frete.frenom format "x(20)"
                                    ftitulo.titvlcob column-label "Vl.Cobrado" 
                                           format "->>>,>>>,>>9.99"
                                           with frame ffrete2 1 down row 15
                                            width 80 centered color white/cyan.
                            vv = vv + 1.
                            pause.
                        end.    
                        if vv = 0
                        then do:
                            update  vfrecod with frame f-frete22.
                            find frete where frete.frecod = vfrecod no-lock.
                            display frete.frenom no-label with frame f-frete22.
                            vlfrete = 0.
                            update vlfrete label "Valor Frete"
                                        with frame f-frete22.

                            create btitulo.
                            assign btitulo.exportado = yes
                                   btitulo.etbcod   = banfin.titulo.etbcod
                                   btitulo.titnat   = yes
                                   btitulo.modcod   = "NEC"
                                   btitulo.clifor   = frete.forcod
                                   btitulo.cxacod   = forne.forcod
                                   btitulo.titsit   = "lib"
                                   btitulo.empcod   = banfin.titulo.empcod
                                   btitulo.titdtemi = banfin.titulo.titdtemi
                                   btitulo.titnum   = banfin.titulo.titnum
                                   btitulo.titpar   = 1
                                   btitulo.titnumger = banfin.titulo.titnum
                                   btitulo.titvlcob = vlfrete
                                   btitulo.vencod   = sfuncod.
                                   
                            update btitulo.titdtven label "Venc.Frete"
                                   btitulo.titnum   label "Controle"
                                with frame f-frete22 centered color white/cyan
                                                side-label row 15 no-validate.

                        end.    
                            
                    end. 
                    hide frame ffrete2 no-pause.
                    ***/
                    
                    vsenha = "".
                    update vfunc
                           vsenha blank
                           with frame f-senha side-label overlay centered.
                    if vfunc <> 29 and
                       vfunc <> 30
                    then do:
                        message "Funcionario nao autorizado".
                        undo, retry.
                    end.
                    find func where func.etbcod = 999 and
                                    func.funcod = vfunc and
                                    func.senha  = vsenha no-lock no-error.
                    if not avail func
                    then do:
                        message "Senha Invalida".
                        undo, retry.
                    end.
                    if banfin.titulo.titsit = "CON"
                    then assign
                            banfin.titulo.titdtdes = ?
                            banfin.titulo.titsit = "LIB".
                    else assign 
                            banfin.titulo.titdtdes = today
                            banfin.titulo.titsit = "CON".
                    
                    message "Confirma Frete" update sresp.
                    if sresp
                    then do:
                        for each btitulo use-index cxmdat where 
                                   btitulo.etbcod    = banfin.titulo.etbcod and
                                   btitulo.cxacod    = banfin.titulo.clifor and
                                   btitulo.titnumger = string(banfin.titulo.titnum): 
                        
                            if btitulo.titsit = "CON"
                            then assign
                                    btitulo.titdtdes = ?
                                    btitulo.titsit = "LIB".
                            else assign
                                    btitulo.titdtdes = today
                                    btitulo.titsit = "CON".

                        end.
                    end.
                    

                end.
            end.
            if esqcom1[esqpos1] = "Consulta" or esqcom1[esqpos1] = "Exclusao"
            then do:
                find modal of banfin.titulo no-lock no-error.
                
        if acha("FUNCIONARIO",banfin.titulo.titobs[1]) <> ?
        then vfuncionario = acha("FUNCIONARIO",banfin.titulo.titobs[1]).
        else vfuncionario = "".
        if acha("META",banfin.titulo.titobs[1]) <> ?
        then vmeta = acha("META",banfin.titulo.titobs[1]).
        else vmeta = "".
        if acha("REALIZADA",banfin.titulo.titobs[2]) <> ?
        then vrealizada = acha("REALIZADA",banfin.titulo.titobs[2]).
        else vrealizada = "".                
        if acha("CAMPANHA",banfin.titulo.titobs[2]) <> ?
        then vcampanha = acha("CAMPANHA",banfin.titulo.titobs[2]).
        else vcampanha = "".
                disp banfin.titulo.clifor
                     banfin.titulo.modcod colon 15
                     modal.modnom when available modal no-label colon 15
                     vfuncionario  colon 15
                     vmeta label "Meta" format "x(20)" colon 15
                     vrealizada label "Realizada" format "x(20)" colon 15
                     vcampanha label "Campanha" format "x(20)" colon 15
                     banfin.titulo.titnum colon 15
                     banfin.titulo.titpar colon 15
                     banfin.titulo.titdtemi
                     banfin.titulo.titdtven colon 15
                     banfin.titulo.titvlcob format "->>>,>>>,>>9.99" colon 15
                     /***
                     banfin.titulo.cobcod ***/ with frame ftitulo.
/***                     
                disp banfin.titulo.titvljur
                     banfin.titulo.titjuro
                     banfin.titulo.titdtdes
                     banfin.titulo.titvldes
                     banfin.titulo.titdtpag
                     banfin.titulo.titvlpag 
                     format "->>>,>>>,>>9.99"
                     with frame fjurdes.
***/                     
            end.
            if esqcom1[esqpos1] = "Exclusao"
            then do with frame f-exclui overlay row 6 1 column centered.
                if banfin.titulo.titsit = "CON"
                then do:
                    message "banfin.titulo nao pode ser excluido". pause.
                    undo, retry.
                end.
                message "Confirma Exclusao ? " /*de banfin.titulo"*/
                            banfin.titulo.titnum ",Parcela" banfin.titulo.titpar
                update sresp.
                if not sresp
                then leave.
                
            if vclifor = ?
            then
            find next banfin.titulo use-index titsit
                             where banfin.titulo.empcod   = wempre.empcod and
                                   banfin.titulo.titnat   = vtitnat       and
                                   banfin.titulo.modcod   = vmodcod       and
                                   banfin.titulo.etbcod   = vetbcod   and
                                 /*  banfin.titulo.clifor   = vclifor  and */
                                 recid(banfin.titulo) <> recatu1 and
                                   (if vsetcod = 0
                                  then true
                                  else banfin.titulo.titbanpag = vsetcod)  no-error.              else      
            find next banfin.titulo use-index titsit
                             where banfin.titulo.empcod   = wempre.empcod and
                                   banfin.titulo.titnat   = vtitnat       and
                                   banfin.titulo.modcod   = vmodcod       and
                                   banfin.titulo.etbcod   = vetbcod   and
                /*                   banfin.titulo.clifor   = vclifor  and*/
                                   (if vsetcod = 0
                                  then true
                                  else banfin.titulo.titbanpag = vsetcod)  no-error.
                                   
                if not available banfin.titulo
                then do:
                    find banfin.titulo where recid(banfin.titulo) = recatu1.
                    if vclifor = ?
                    then 
                        find prev banfin.titulo use-index titsit
                               where banfin.titulo.empcod   = wempre.empcod and
                                     banfin.titulo.titnat   = vtitnat       and
                                     banfin.titulo.modcod   = vmodcod       and
                                     recid(banfin.titulo) <> recatu1 and
                                   banfin.titulo.etbcod   = vetbcod       /*and
                                     banfin.titulo.clifor   = vclifor*/ and
                                      (if vsetcod = 0
                                  then true
                                  else banfin.titulo.titbanpag = vsetcod)
no-error.                    
                    else 
                    find prev banfin.titulo use-index titsit
                    
                    
                               where banfin.titulo.empcod   = wempre.empcod and
                                     banfin.titulo.titnat   = vtitnat       and
                                     banfin.titulo.modcod   = vmodcod       and
                                     banfin.titulo.etbcod   = vetbcod  /*   and
                                     banfin.titulo.clifor   = vclifor*/
                                   no-error.
                end.
                recatu2 = if available banfin.titulo
                          then recid(banfin.titulo)
                          else ?.
                find banfin.titulo where recid(banfin.titulo) = recatu1.
                
                deletou-lancxa = no.
                for each lancxa where lancxa.datlan = banfin.titulo.titdtpag and
                                      lancxa.forcod = banfin.titulo.clifor   and
                                      lancxa.titnum = banfin.titulo.titnum   and
                                      lancxa.lancod = banfin.titulo.vencod:
                    delete lancxa.
                    deletou-lancxa = yes.
                    
                end.
                if deletou-lancxa = no
                then do:
                    /*
                    message "Nao Excluiu lancamento na contabilidade".
                    pause.
                    */
                end.
                
                delete banfin.titulo.
                recatu1 = recatu2.
                hide frame fitulo no-pause.
                leave.
            end.
            if esqcom1[esqpos1] = "Agendamento"
            then do:
                if banfin.titulo.titsit = "LIB" or
                   banfin.titulo.titsit = "CON"
                then do:
                    run agendamento.
                end.
                leave.   
            end.
          end.
          else do:
            hide frame f-com2 no-pause.
            if  esqcom2[esqpos2] = "Pagamento/Cancelamento"
            then if  banfin.titulo.titsit = "LIB" or banfin.titulo.titsit = "IMP" or
                     banfin.titulo.titsit = "CON"
              then do with frame f-Paga overlay row 6 1 column centered.
                 display banfin.titulo.titnum    colon 13
                        banfin.titulo.titpar    colon 33 label "Pr"
/*                        banfin.titulo.titdtemi  colon 13*/
                        banfin.titulo.titdtven  colon 13
                        banfin.titulo.titvlcob  colon 13 label "Vl.Cobr."
                        format "->>>,>>>,>>9.99"
                        banfin.titulo.titvljur  colon 13 label "Vl.Juro"
                        banfin.titulo.titvldes  format ">>>,>>9.99"
                                colon 13 label "Vl.Desc"
                        with frame fdadpg side-label
                        overlay row 6 color white/cyan width 40
                        title " banfin.titulo ".
                 banfin.titulo.datexp = today.
               if  banfin.titulo.modcod = "CRE" then do:
                   {titpagb4.i}
                   update banfin.titulo.titvljur  colon 13 label "Vl.Juro"
                          banfin.titulo.titvldes  colon 13 label "Vl.Desc"
                                format ">>>,>>9.99"
                                            with frame fdadpg side-label
                                    overlay row 6 color white/cyan width 40
                                          title " banfin.titulo " no-validate.
               end.
               else do:
                   hide frame lanca no-pause.
                   assign banfin.titulo.titdtpag = today.
                   display banfin.titulo.titdtdes colon 13 label "Dt.Desc"
                           banfin.titulo.titvldes colon 13 label "Vl.Desc"
                                           format ">>>,>>9.99"
                           banfin.titulo.titvljur colon 13 label "Vl.Juro"
                                      with frame fdadpg.
                   update banfin.titulo.titdtpag with frame fpag1.
                   /**
                   if banfin.titulo.titdtpag < banfin.titulo.titdtven
                   then do:
                        message  "Informe a taxa para pagamento antecipado %"
                                 update taxa-ante.
                                                 
                        if taxa-ante > 0
                        then do:
                            banfin.titulo.titvlpag = banfin.titulo.titvlcob -
                            (banfin.titulo.titvlcob * (taxa-ante / 100)).
                            banfin.titulo.titdesc = taxa-ante.
                        end.
                        else banfin.titulo.titvlpag = banfin.titulo.titvlcob.   
                         
                   end.
                   else
                   **/
                   banfin.titulo.titvlpag = banfin.titulo.titvlcob.
                   
                   /*
                   if banfin.titulo.titdtpag > banfin.titulo.titdtven 
                   then assign banfin.titulo.titvlpag = banfin.titulo.titvlcob
                                                 + banfin.titulo.titvljur.
                                                  /* *
                                        (banfin.titulo.titdtpag - banfin.titulo.titdtven)).
                                                  */
                   else if banfin.titulo.titdtpag <= banfin.titulo.titdtdes
                   then assign banfin.titulo.titvlpag = banfin.titulo.titvlcob -
                                          banfin.titulo.titvldes. /* *
                                     ((banfin.titulo.titdtdes - banfin.titulo.titdtpag) + 1)).
                                                   */
                   */
                   
                banfin.titulo.titvlpag = banfin.titulo.titvlcob + banfin.titulo.titvljur
                                     - banfin.titulo.titvldes.
                assign vtitvlpag = banfin.titulo.titvlpag.
                update banfin.titulo.titvlpag format "->>>,>>>,>>9.99"
                            with frame fpag1.
                update banfin.titulo.cobcod with frame fpag1.
                update banfin.titulo.titvljur column-label "Juros"
                       banfin.titulo.titvldes format ">>>,>>9.99"
                            with frame fpag1 no-validate.
                
                
                banfin.titulo.titvlpag = banfin.titulo.titvlcob + banfin.titulo.titvljur -
                                  banfin.titulo.titvldes.
                
                
                vlancod = 0.
                if vtitnat = yes
                then do on error undo, retry:
                    hide frame ff no-pause.
                    hide frame ff1 no-pause.
                    hide frame fdadpg no-pause.
                    hide frame f-com1 no-pause.
                    hide frame f-com2 no-pause.
                    hide frame ftitulo no-pause.
                    hide frame ftit    no-pause.
                    hide frame ftit2   no-pause.
                    hide frame fbancpg no-pause.
                    hide frame fbanco  no-pause.
                    hide frame fbanco2 no-pause.
                    hide frame fjurdes no-pause.
                    hide frame fjurdes2 no-pause.
                    hide frame fobs2  no-pause.
                    hide frame fobs   no-pause.
                    hide frame fpag1  no-pause.

                    vlancod = banfin.titulo.vencod.
                    vlanhis = banfin.titulo.titparger.
                    vcompl  = banfin.titulo.titnumger.

                    if vclifor = 533
                    then vlanhis = 5.
                    
                    if vclifor = 100071
                    then vlanhis = 4.

                    if vclifor = 100072
                    then vlanhis = 3.

                    find lanaut where lanaut.etbcod = banfin.titulo.etbcod and
                                      lanaut.forcod = banfin.titulo.clifor
                                                no-lock no-error.
                    if avail lanaut 
                    then do: 
                        assign vlanhis = lanaut.lanhis
                               vcompl  = lanaut.comhis
                               vlancod = lanaut.lancod.
                    end.
                    
                    if banfin.titulo.modcod = "DUP"
                    then assign vlancod = 100
                                vlanhis = 1
                                vcompl  = banfin.titulo.titnum + " " + forne.fornom.
                    /*
                    find first lanaut where 
                               lanaut.etbcod = ? and
                               lanaut.forcod = ? and
                               lanaut.modcod = banfin.titulo.modcod
                               no-lock no-error.
                    if avail lanaut
                    then do:
                        assign
                            vlancod = lanaut.lancod
                            vlanhis = lanaut.lanhis
                            vcompl  = banfin.titulo.titnum + " " + forne.fornom.
                            .
                    end. 
                    */
                    else do:

                        
                        
                        find last blancxa where blancxa.forcod = forne.forcod
                                            and  blancxa.etbcod = banfin.titulo.etbcod
                                            and  blancxa.lantip = "C"
                                            no-lock no-error.
                        if avail blancxa
                        then assign vlancod = blancxa.lancod
                                    vlanhis = blancxa.lanhis
                                    vcompl  = blancxa.comhis.
   
                        if vclifor = 533
                        then vlanhis = 5.
                    
                        if vclifor = 100071
                        then vlanhis = 4.

                        if vclifor = 100072
                        then vlanhis = 3.
                        
                        find lanaut where lanaut.etbcod = banfin.titulo.etbcod and
                                          lanaut.forcod = banfin.titulo.clifor
                                                no-lock no-error.
                        if avail lanaut 
                        then do: 
                            assign vlanhis = lanaut.lanhis
                                   vcompl  = lanaut.comhis
                                   vlancod = lanaut.lancod.
                        end.
     
 

                        if vcompl  = "" or
                           vlancod = 0  or
                           vlanhis = 0
                        then

                        update vlancod label "Lancamento"
                               vlanhis label "Historico" format ">99"
                               vcompl  label "Complemento"
                                    with frame lanca centered side-label
                                            row 15 overlay.
                                            
                    end.
                    
                    if vlanhis = 6
                    then vcompl = "".
                    
                    run his-complemento.
                    
                    if vlancod <> 0 and vtitnat = yes
                    then do:
                        find tablan where tablan.lancod = vlancod 
                                                    no-lock no-error.
                        if not avail tablan
                        then do:
                            message "Lancamento nao cadastrado".
                            undo, retry.
                        end.
                        display tablan.landes no-label with frame lanca.
                        
                        find last blancxa use-index ind-1
                                where blancxa.numlan <> ? no-lock no-error.
                        if not avail blancxa
                        then vnumlan = 1.
                        else vnumlan = blancxa.numlan + 1.
                        create lancxa.
                        assign lancxa.cxacod = 13
                               lancxa.datlan = banfin.titulo.titdtpag
                               lancxa.lancod = vlancod
                               lancxa.numlan = vnumlan
                               lancxa.vallan = banfin.titulo.titvlcob
                               lancxa.comhis = vcompl
                               lancxa.lantip = "C"
                               lancxa.forcod = banfin.titulo.clifor
                               lancxa.titnum = banfin.titulo.titnum
                               lancxa.etbcod = banfin.titulo.etbcod
                               lancxa.modcod = banfin.titulo.modcod
                               lancxa.lanhis = vlanhis.
                        
                        if lancxa.lanhis = 1
                        then lancxa.comhis = banfin.titulo.titnum + " " + forne.fornom.
                        
                        find lanaut where lanaut.etbcod = banfin.titulo.etbcod and
                                          lanaut.forcod = banfin.titulo.clifor
                                                no-lock no-error.
                        if avail lanaut
                        then do:
                            assign lancxa.lanhis = lanaut.lanhis
                                   lancxa.comhis = lanaut.comhis
                                   lancxa.lancod = lanaut.lancod.
                        end.
                                                

                        if banfin.titulo.titvljur > 0 and vtitnat = yes
                        then do:
                            vlanhis = 13.
                            
                            run his-complemento.
                            
                            find last lancxa use-index ind-1
                                    where lancxa.numlan <> ? no-lock no-error.
                            if not avail lancxa
                            then vnumlan = 1.
                            else vnumlan = lancxa.numlan + 1.

                            create blancxa.
                            ASSIGN blancxa.cxacod = 13
                                   blancxa.datlan = banfin.titulo.titdtpag
                                   blancxa.lancod = 110
                                   blancxa.numlan = vnumlan
                                   blancxa.vallan = banfin.titulo.titvljur
                                   blancxa.comhis = vcompl
                                   blancxa.lantip = "C"
                                   blancxa.forcod = banfin.titulo.clifor
                                   blancxa.titnum = banfin.titulo.titnum
                                   blancxa.etbcod = banfin.titulo.etbcod
                                   blancxa.modcod = banfin.titulo.modcod
                                   blancxa.lanhis = vlanhis.
                                   
                        end.    
                        
                        if banfin.titulo.titvldes > 0 and vtitnat = yes
                        then do:
                            find last lancxa use-index ind-1
                                 where lancxa.numlan <> ? no-lock no-error.
                            if not avail lancxa
                            then vnumlan = 1.
                            else vnumlan = lancxa.numlan + 1.
                            create blancxa.
                            if banfin.titulo.clifor = 100090 or
                               banfin.titulo.clifor = 101463
                            then find tablan where tablan.lancod = 111 no-lock.
                            else find tablan where tablan.lancod = 439 no-lock.
                            vlanhis = tablan.lanhis.
                            run his-complemento.
                            ASSIGN blancxa.cxacod = 13
                                   blancxa.datlan = banfin.titulo.titdtpag
                                   blancxa.lancod = tablan.lancod
                                   blancxa.numlan = vnumlan
                                   blancxa.vallan = banfin.titulo.titvldes
                                   blancxa.comhis = vcompl
                                   blancxa.lantip = "D"
                                   blancxa.forcod = banfin.titulo.clifor
                                   blancxa.titnum = banfin.titulo.titnum
                                   blancxa.etbcod = banfin.titulo.etbcod
                                   blancxa.modcod = banfin.titulo.modcod
                                   blancxa.lanhis = tablan.lanhis.
                            
                            if tablan.lanhis = 12
                            then blancxa.comhis = 
                                 banfin.titulo.titnum + " " + forne.fornom.

                        end.    

                    end.
                    else do:
                        message "Lancamento nao cadastrado".
                        undo, retry.
                    end.
                end.
                hide frame lanca no-pause.
  
                if banfin.titulo.titvlpag >= banfin.titulo.titvlcob
                then. /* banfin.titulo.titjuro = banfin.titulo.titvlpag - banfin.titulo.titvlcob. */
                else do:
                   assign sresp = no.
                   display "  Confirma PAGAMENTO PARCIAL ?"
                     with frame fpag color messages
                                width 40 overlay row 10 centered.
                    update sresp no-label with frame fpag.
                    if  sresp then do:
                        find last btitulo where
                            btitulo.empcod   = wempre.empcod and
                            btitulo.titnat   = vtitnat       and
                            btitulo.modcod   = vmodcod       and
                            btitulo.etbcod   = vetbcod       and
                            btitulo.clifor   = vclifor       and
                            btitulo.titnum   = banfin.titulo.titnum.
                            create ctitulo.
                            assign 
                                ctitulo.exportado = yes
                                ctitulo.empcod = btitulo.empcod
                                ctitulo.modcod = btitulo.modcod
                                ctitulo.clifor = btitulo.clifor
                                ctitulo.titnat = btitulo.titnat
                                ctitulo.etbcod = btitulo.etbcod
                                ctitulo.titnum = btitulo.titnum
                                ctitulo.cobcod = banfin.titulo.cobcod
                                ctitulo.titpar   = btitulo.titpar + 1
                                ctitulo.titdtemi = banfin.titulo.titdtemi
                                ctitulo.titdtven = if banfin.titulo.titdtpag <
                                                      banfin.titulo.titdtven
                                                   then banfin.titulo.titdtven
                                                   else banfin.titulo.titdtpag
                                ctitulo.titvlcob = vtitvlpag - banfin.titulo.titvlpag
                                ctitulo.titnumger = banfin.titulo.titnum
                                ctitulo.titparger = banfin.titulo.titpar
                                ctitulo.datexp    = today
                                 banfin.titulo.titnumger = ctitulo.titnum
                                 banfin.titulo.titparger = ctitulo.titpar.
                            display ctitulo.titnum
                                    ctitulo.titpar
/*                                    ctitulo.titdtemi*/
                                    ctitulo.titdtven
                                    ctitulo.titvlcob format "->>>,>>>,>>9.99"
                                    with frame fmos width 40 1 column
                                              title " banfin.titulo Gerado " 
                                              overlay
                                              centered row 10.
                        end.
                        else banfin.titulo.titdesc = banfin.titulo.titvlcob - banfin.titulo.titvlpag.
                end.
                assign banfin.titulo.titsit = "PAG".
               end.
               do:
               recatu1 = recid(banfin.titulo).
               leave.
               end.
              end.
              else
                if  banfin.titulo.titsit = "PAG" then do:
                display banfin.titulo.titnum
                        banfin.titulo.titpar
/*                        banfin.titulo.titdtemi*/
                        banfin.titulo.titdtven
                        banfin.titulo.titvlcob format "->>>,>>>,>>9.99"
                        /*banfin.titulo.cobcod*/ with frame ftitulo.
                    banfin.titulo.datexp = today.
                    banfin.titulo.cxmdat = ?.
                    banfin.titulo.cxacod = 0.
                    display banfin.titulo.titdtpag banfin.titulo.titvlpag banfin.titulo.cobcod
                            with frame fpag1.
                    do:
                    message "Pagemento ja efetuado ". pause.
                    undo, retry.
                    end.
                    message "Confirma o Cancelamento do Pagamento ?"
                            update sresp.
                    if sresp then do:
                        for each lancxa where lancxa.datlan = banfin.titulo.titdtpag
                                        and   lancxa.forcod = banfin.titulo.clifor 
                                        and   lancxa.titnum = banfin.titulo.titnum
                                        and   lancxa.lancod = banfin.titulo.vencod:
                            delete lancxa.
                        end.
                        assign banfin.titulo.titsit  = "LIB"
                               banfin.titulo.titdtpag  = ?
                               banfin.titulo.titvlpag  = 0
                               banfin.titulo.titbanpag = 0
                               banfin.titulo.titagepag = ""
                               banfin.titulo.titchepag = ""
                               banfin.titulo.titvljur  = 0
                               banfin.titulo.datexp    = today.
                        find first b-titu where
                                   b-titu.empcod    =  banfin.titulo.empcod and
                                   b-titu.titnat    =  banfin.titulo.titnat and
                                   b-titu.modcod    =  banfin.titulo.modcod and
                                   b-titu.etbcod    =  banfin.titulo.etbcod and
                                   b-titu.clifor    =  banfin.titulo.clifor and
                                   b-titu.titnum    =  banfin.titulo.titnum and
                                   b-titu.titpar    <> banfin.titulo.titpar and
                                   b-titu.titparger =  banfin.titulo.titpar
                                   no-lock no-error.
                        if  avail b-titu then do:
                        display "Verifique titulo Gerado do Pagamento Parcial"
                                with frame fver color messages
                                width 50 overlay row 10 centered.
                            pause.
                        end.
                   
                   end.
                   do:
                   recatu1 = recid(banfin.titulo).
                   next bl-princ.
                   end. 
                end.
            if esqcom2[esqpos2]  = "Bloqueio/Liberacao" and
               banfin.titulo.titsit    <> "PAG"
            then do:
                if banfin.titulo.titsit <> "BLO"
                then do:
                    message "Confirma o Bloqueio ?" /*do banfin.titulo ?"*/ update sresp.
                    if  sresp then do:
                        banfin.titulo.titsit = "BLO".
                        banfin.titulo.datexp = today.
                    end.
                end.
                else
                    if banfin.titulo.titsit = "BLO"
                    then do:
                        message "Confirma a Liberacao ? " /*do banfin.titulo ?"*/ update sresp.
                        if  sresp then do:
                            banfin.titulo.titsit = "LIB".
                            banfin.titulo.datexp = today.
                        end.
                     end.
            end.
          end.
          view frame frame-a.
          view frame f-com2 .
        end.
          if keyfunction(lastkey) = "end-error"
          then view frame frame-a.
        if acha("AGENDAR",banfin.titulo.titobs[2]) <> ? and
            banfin.titulo.titdtven <> date(acha("AGENDAR",banfin.titulo.titobs[2])) 
        then v-agendado = "*".
        else v-agendado = "".

    find forne where forne.forcod = banfin.titulo.clifor
            no-lock no-error.
    
    if acha("AGENDAR",banfin.titulo.titobs[2]) <> ? and
       banfin.titulo.titdtven <> date(acha("AGENDAR",banfin.titulo.titobs[2])) 
    then v-agendado = "*".
    else v-agendado = "".
    if acha("FUNCIONARIO",banfin.titulo.titobs[1]) <> ?
    then vmatricula = acha("FUNCIONARIO",banfin.titulo.titobs[1]).
    else vmatricula = "".
    
    display 
            banfin.titulo.clifor label "Forne"
            vmatricula label "Matric."
           banfin.titulo.titnum format "x(7)"
            banfin.titulo.titpar   format ">9"
        banfin.titulo.titvlcob format "->>,>>9.99" column-label "Vl.Cobrado"
        banfin.titulo.titdtven format "99/99/9999"   column-label "Dt.Vecto"
        banfin.titulo.titsit column-label "Sit" format "x(3)"
            with frame frame-a 9 down centered color white/red
            title " " + vcliforlab + " " + forne.fornom + " "
                    + " Cod.: " + string(vclifor) + " " width 80.
    pause 0.
    
        if esqregua
        then display esqcom1[esqpos1] with frame f-com1.
        else display esqcom2[esqpos2] with frame f-com2.
        recatu1 = recid(banfin.titulo).
   end.
end.
end.


procedure his-complemento:

    find hispad where hispad.hiscod = vlanhis no-lock no-error.
    if avail hispad and hispad.hiscom
    then do:
        if hispad.hisnum
        then vcompl = vcompl + " " + banfin.titulo.titnum.
        if hispad.hisfor
        then vcompl = vcompl + " " + forne.fornom .
        if hispad.hisdat
        then vcompl = vcompl + " " + string(banfin.titulo.titdtpag).
    end.

end procedure.

procedure agendamento:
    def var dt-agenda as date.
    def var vl-juro as dec.
    def var vl-juroc as dec.
    def var vl-desc as dec.
    def var vl-descc as dec.
    def var vl-total as dec.
    def var tit-des as dec.
    def var pct-jd as dec.
    def var qtd-titag as int.
    def var val-titag like banfin.titulo.titvlcob.
    def var des-titag like banfin.titulo.titvlcob.
    def var jur-titag like banfin.titulo.titvlcob.
    def var atu-titag like banfin.titulo.titvlcob.
    def var jur-dia as dec.
    def buffer btitulo for banfin.titulo.
    for each btitulo where btitulo.empcod = banfin.titulo.empcod and
                           btitulo.titnat = banfin.titulo.titnat and
                           btitulo.modcod = banfin.titulo.modcod and
                           btitulo.clifor = banfin.titulo.clifor and
                           btitulo.titsit <> "PAG"
                           no-lock.
        if acha("AGENDAR",btitulo.titobs[2]) <> ? and
           btitulo.titdtven <> date(acha("AGENDAR",btitulo.titobs[2])) 
        then do:
            if acha("VALJURO",btitulo.titobs[2]) <> "?"
            then vl-juro   = dec(acha("VALJURO",btitulo.titobs[2])).
            else vl-juro   = 0.
            if acha("VALDESC",btitulo.titobs[2]) <> "?"
            then vl-desc   = dec(acha("VALDESC",btitulo.titobs[2])).
            else vl-desc = 0.
            if vl-juro = ? then vl-juro = 0.
            if vl-desc = ? then vl-desc = 0.
            if vl-juro <> ?
            then jur-titag = jur-titag + vl-juro + btitulo.titvljur.
            if vl-desc <> ?
            then des-titag = des-titag + vl-desc + btitulo.titvldes.
            qtd-titag = qtd-titag + 1.
            val-titag = val-titag + btitulo.titvlcob.
        end.
    end.  
    atu-titag = val-titag - des-titag + jur-titag.
    disp qtd-titag   label "banfin.titulos"
         val-titag   label "Valor"      
         jur-titag   label "Juro"
         des-titag   label "Desconto"
         atu-titag   label "Total"
         with frame f-disp11 no-box row 18 centered.
         
    dt-agenda = date(acha("AGENDAR",banfin.titulo.titobs[2])).
    pct-jd    = dec(acha("PCTJD",banfin.titulo.titobs[2])).
    vl-juro   = dec(acha("VALJURO",banfin.titulo.titobs[2])).
    vl-desc   = dec(acha("VALDESC",banfin.titulo.titobs[2])).
    if vl-juro = ? then vl-juro = 0.
    if vl-desc = ? then vl-desc = 0.
    vl-total = banfin.titulo.titvlcob - vl-desc + vl-juro.
    vl-juroc = vl-juroc + banfin.titulo.titvljur.
    vl-descc = vl-descc + banfin.titulo.titvldes.
    disp banfin.titulo.titnum   to 37
         /*banfin.titulo.titpar to 45*/
         banfin.titulo.titvlcob to 41 
         banfin.titulo.titdtven to 35
         dt-agenda to 35 label "Agendado   para"    format "99/99/9999"
         pct-jd    to 32 label "% Juro/Desconto" format ">>9.99%"
         vl-juro   to 35 label "JURO calculado"
         vl-juroc  label "JURO informado"
         vl-desc   to 35 label "DESCONTO calculado"
         vl-descc  label "DESCONTO informado"
         vl-total  to 35 label "   Valor  Atual" format "->>>,>>>,>>9.99"
         with frame f-agenda 1 down row 7
         side-label color message overlay width 80.
    update dt-agenda label "Agendar para"
                    with frame f-agenda.
    if dt-agenda <> ? /*and
       dt-agenda >= today*/ 
    then do:
        update pct-jd with frame f-agenda.
        jur-dia = pct-jd / 30.
        vl-desc = 0 . vl-juro = 0.
        if dt-agenda < banfin.titulo.titdtven
        then vl-desc = ((banfin.titulo.titvlcob - banfin.titulo.titvldes) * (jur-dia / 100))
                * ( banfin.titulo.titdtven - dt-agenda ) .
        else if dt-agenda > banfin.titulo.titdtven
            then vl-juro = ((banfin.titulo.titvlcob + banfin.titulo.titvljur) 
                            * (jur-dia / 100))
                    * ( dt-agenda - banfin.titulo.titdtven) .
            
        disp vl-juro vl-desc with frame f-agenda.
        vl-total = banfin.titulo.titvlcob + vl-juro + vl-juroc 
                        - vl-desc - vl-descc.
        
        disp vl-total with frame f-agenda.
        sresp = no.
        message "Confirma agendamento ?" update sresp.
        if sresp
        then do:
            banfin.titulo.titobs[2] = "|AGENDAR=" + string(dt-agenda,"99/99/9999") +
                       "|PCTJD="   + string(pct-jd,">>9.99")        + 
                       "|VALJURO=" + 
                       string(vl-juro,">,>>>,>>9.99") +
                       "|VALDESC=" + 
                       string(vl-desc,">,>>>,>>9.99") +
                       "|" .
        end.
    end.                 
    else do:
        message "Agendamento nao permitido, CONFIRA A DATA INFORMADA. ".
        pause. 
    end.
end.

procedure rateio-cria-titulo:
    def var vok as log.
    def var vetb like estab.etbcod.
    disp "                DADOS PARA RATEIO *** " +
            STRING(VQTD-LJ) +
            " FILIAIS SELECIONADAS      "
            format "x(80)"
    WITH frame f-rat width 80 color message
              no-box no-label 1 down.
    do on error undo with frame frtit2 centered side-label 1 column:
            find last btitulo where btitulo.empcod = wempre.empcod
                                and btitulo.titnat = vtitnat
                                and btitulo.modcod = vmodcod
                                and btitulo.etbcod = vetbcod
                                and btitulo.clifor = vclifor
                                and btitulo.titpar = 1 no-lock no-error.
                if avail btitulo
                then assign vnumtit = integer(btitulo.titnum) no-error.
                else assign vnumtit = 1 + setbcod.
                if error-status:error or vnumtit = ?
                then vnumtit = 1 + setbcod.
                vnumtit = vnumtit + 1.
                
                vtitnum = string(vnumtit).
                vtitpar = 1.
        update vtitnum .
        disp vtitpar.
        vok = yes.
        for each tt-lj no-lock:
            find first btitulo where btitulo.empcod   = wempre.empcod and
                                         btitulo.titnat   = vtitnat       and
                                         btitulo.modcod   = vmodcod       and
                                         btitulo.etbcod   = tt-lj.etbcod  and
                                         btitulo.clifor   = vclifor       and
                                         btitulo.titnum   = vtitnum       and
                                         btitulo.titpar   = vtitpar no-error.
            if avail btitulo
            then do:
                vok = no.
                vetb = tt-lj.etbcod.
                leave.
            end.
        end.    
        if vok = no
        then do:
                message "Titulo ja Existe para FILIAL " VETB.
                PAUSE.
                undo, retry.
        end.


        update vtitdtemi 
               vvenc validate((vvenc >= (today + 3)),  
                            "Data invalida") label "Vencimento" 
                vtotal label "Valor Total"
                .
        update text(vtitobs) with frame fobs2. pause 0.
        sresp = no.
        message "Confirma Rateio de R$" string(vtotal,">>,>>>,>>9.99")
         " ?" update sresp.
        hide frame fobs2 no-pause.
        if not sresp
        then undo.

        for each tt-lj no-lock:
            create banfin.titulo.
            assign 
                banfin.titulo.exportado = yes
                banfin.titulo.empcod = wempre.empcod
                banfin.titulo.titsit = "LIB"
                banfin.titulo.titnat = vtitnat
                banfin.titulo.modcod = vmodcod
                banfin.titulo.etbcod = tt-lj.etbcod
                banfin.titulo.datexp = today
                banfin.titulo.clifor = vclifor
                banfin.titulo.titnum = vtitnum
                banfin.titulo.titpar  = 1
                banfin.titulo.titdtemi = vtitdtemi
                banfin.titulo.titdtven = vvenc
                banfin.titulo.titvlcob = vtotal / vqtd-lj
                banfin.titulo.titbanpag = vsetcod
                banfin.titulo.titagepag = string(vtipo-documento)
                banfin.titulo.titobs[1] = vtitobs[1]
                banfin.titulo.titobs[2] = vtitobs[2] 
                banfin.titulo.vencod = sfuncod.
                           
            /***
            if vclifor = 533
            then vlanhis = 5.
                    
            if vclifor = 100071
            then vlanhis = 4.

            if vclifor = 100072
            then vlanhis = 3.

            if banfin.titulo.modcod = "DUP"
            then assign vlancod = 100
                        vlanhis = 1.

            else do:
                        find last blancxa where 
                                     blancxa.forcod = forne.forcod  and
                                     blancxa.etbcod = banfin.titulo.etbcod and
                                     blancxa.lantip = "C"
                                             no-lock no-error.
                        if avail blancxa
                        then assign vlancod = blancxa.lancod
                                    vlanhis = blancxa.lanhis
                                    vcompl  = blancxa.comhis.
                        
                        if vclifor = 533
                        then vlanhis = 5.
                    
                        if vclifor = 100071
                        then vlanhis = 4.

                        if vclifor = 100072
                        then vlanhis = 3.
                        
                        find lanaut where 
                                lanaut.etbcod = banfin.titulo.etbcod and
                                lanaut.forcod = banfin.titulo.clifor
                                                no-lock no-error.
                        if avail lanaut  
                        then do:  
                            assign vlanhis = lanaut.lanhis 
                                   vcompl  = lanaut.comhis 
                                   vlancod = lanaut.lancod.
                        end.
                         
                        if vlancod = 0
                        then update vlancod label "Lancamento"
                                      with frame lanca centered side-label
                                         row 15 overlay.
                                         
              end.
                    
                    find tablan where tablan.lancod = vlancod no-lock no-error.
                    if not avail tablan
                    then do:
                        message "Lancamento Invalido".
                        undo, retry.
                    end.

                    if vlanhis = 0
                    then vlanhis = tablan.lanhis.

                    find lanaut where lanaut.etbcod = banfin.titulo.etbcod and
                                      lanaut.forcod = banfin.titulo.clifor
                                                no-lock no-error.
                    if avail lanaut 
                    then do: 
                        assign vlanhis = lanaut.lanhis
                               vcompl  = lanaut.comhis
                               vlancod = lanaut.lancod.
                    end.
     
                    
                    
                    if vlanhis = 150
                    then vcompl = tablan.landes.
                    else if vlanhis <> 2
                         then vcompl = banfin.titulo.titnum + " " + 
                                forne.fornom.
                         else vcompl = forne.fornom.
                    
                    if vlancod = 100
                    then assign 
                            vlanhis = 1
                            vcompl = banfin.titulo.titnum + " " + 
                                        forne.fornom.
                    
                    else if
                         vlanhis = 0 or
                         vcompl  = ""
                         then update vlanhis label "Historico"
                                     vcompl  label "Complemento"
                                        with frame lanca centered side-label
                                               row 15 overlay.
                    if vlanhis = 6
                    then vcompl = "".
            banfin.titulo.vencod = vlancod.
            banfin.titulo.titnumger = vcompl.
            banfin.titulo.titparger = vlanhis. 
            **/
        end.
    end.
end procedure.
