{admcab.i}                  

def var ii as i.
def var vt   as dec format "->>>,>>>,>>9.99".
def var vtot as dec format "->>>,>>>,>>9.99".
def var vforcod like forne.forcod.
def var i as i.
def var vtotal  as dec format "->>>,>>>,>>9.99".
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
def var vtitvljur as dec format "->>>,>>>,>>9.99" label "Valor Cobrado".
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

def shared var vtipo-documento as int.

def  shared var vsetcod like setaut.setcod.
def buffer btitulo      for titulo.
def buffer ctitulo      for titulo.
def buffer b-titu       for titulo.
def shared var vempcod         like titulo.empcod.
def shared var vetbcod         like titulo.etbcod.
def shared var vmodcod         like titulo.modcod initial "DUP".
def shared var vtitnat         like titulo.titnat.
def var vcliforlab      as char format "x(12)".
def var vclifornom      as char format "x(30)".
def shared var vclifor         like titulo.clifor.
def var wperdes         as dec format "->9.99 %" label "Perc. Desc.".
def var wperjur         as dec format "->9.99 %" label "Perc. Juros".
def var vtitvlpag       as dec format "->>>,>>>,>>9.99".
def var vtitvlcob       as dec format "->>>,>>>,>>9.99".
def var vdtpag          like titulo.titdtpag.
def var vdate           as   date.
def var vetbcobra       like titulo.etbcobra initial 0.
def var vcontrola       as   log initial no.
form esqcom1
    with frame f-com1
    row 6 no-box no-labels side-labels column 1.
form esqcom2
    with frame f-com2
        row screen-lines - 1 /*title " OPERACOES " */
        no-labels side-labels column 1
        no-box centered.

FORM titulo.clifor    colon 15 label "Fornec."
    titulo.titnum     colon 15
    titulo.titpar     colon 15
    titulo.titdtemi   colon 15
    titulo.titdtven   colon 15
    titulo.titvlcob   colon 15 format "->>>,>>>,>>9.99"
    titulo.cobcod     colon 15
    with frame ftitulo
        overlay row 7 color
        white/cyan side-label width 39.

FORM vtitnum     colon 15
     vtitpar     colon 15
     vtitdtemi   colon 15
     vtitdtven   colon 15
     vtitvlcob   colon 15 format "->>>,>>>,>>9.99" 
     /*vcobcod     colon 15
     cobra.cobnom no-label format "x(15)"*/
     titulo.modcod colon 15
     modal.modnom no-label format "x(15)"
     /*titulo.evecod colon 15
     event.evenom no-label format "x(15)"*/
     with frame ftit overlay row 7 color white/cyan side-label width 39.

FORM vtitnum     colon 15
     vtitpar     colon 15
     vtitdtemi   colon 15
     vtotal      colon 15
     /*vcobcod     colon 15
     cobra.cobnom no-label format "x(15)"
     vevecod colon 15
     event.evenom no-label format "x(15)"
     */
     with frame ftit2 overlay row 7 color white/cyan side-label width 39.

form titulo.titbanpag colon 15
    banco.bandesc no-label
    titulo.titagepag colon 15
    agenc.agedesc no-label
    titulo.titchepag colon 15
    with frame fbancpg centered
         side-labels 1 down overlay
         color white/cyan row 16
         title " Banco Pago " width 80.

form titulo.bancod   colon 15
    banco.bandesc           no-label
    titulo.agecod   colon 15
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
form /*wperjur         colon 16*/
/*    titulo.titvljur colon 16 skip(1)
    titulo.titdtdes colon 16
    wperdes         colon 16
    titulo.titvldes colon 16
    */
    with frame fjurdes
         overlay row 7 column 41 side-label
         color white/cyan  width 40.

form /*wperjur         colon 16*/
/*    vtitvljur colon 16 skip(1)
    /*vtitdtdes colon 16*/
    wperdes         colon 16
    */
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
    titulo.titobs[1] at 1
    titulo.titobs[2] at 1
    with no-labels width 80 row 16
         title " Observacoes " frame fobs
         color white/cyan .

form
    titulo.titdtpag colon 15 label "Dt.Pagam"
    titulo.titvlpag  colon 15 format "->>>,>>>,>>9.99"
    titulo.cobcod    colon 15
/*    titulo.titvljur  colon 15 column-label "Juros"
    titulo.titvldes  colon 15 column-label "Desconto"
    */
    with frame fpag1 side-label
         row 10 color white/cyan
         overlay column 42 width 39 title " Pagamento " .

esqcom1[5] = "".
esqcom2 = "".

def var v-agendado as char format "x" label "A".
def var taxa-ante as dec format ">>9.99".
def var deletou-lancxa as log.
def var vfrecod like frete.frecod.
def var vv as int.
def var vlfrete like plani.platot.
def var vfre as int format "9" initial 1.
def buffer ftitulo for titulo.
def buffer ztitulo for titulo.
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

find forne where forne.forcod = vclifor no-lock.

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

def var vfuncod like func.funcod.
def var vfunfol like func.usercod label "Funcionario".

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
    if  recatu1 = ? then
        find first titulo use-index titdtven
                    where titulo.empcod   = wempre.empcod and
            titulo.titnat   = vtitnat       and
            titulo.modcod   = vmodcod       and
            titulo.etbcod   = vetbcod       and
            titulo.clifor   = vclifor       and
            titulo.titbanpag = vsetcod no-error.
    else find titulo where recid(titulo) = recatu1.
    vinicio = no.
    if  not available titulo then do:
        message "Cadastro de titulos Vazio".
        message "Deseja Incluir " update sresp.
        if not sresp then undo.
        do with frame ftit2:
                /* vtitnum = "". */
/*                run tipo-documento. */
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
                    message "titulo ja Existe".
                    undo, retry.
                end.
                update vtitdtemi /***validate(vtitdtemi >= today - 30,
                                    "Data invalida para emissao.")***/
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
                    create titulo.
                    assign titulo.exportado = yes
                           titulo.empcod = wempre.empcod
                           titulo.titsit = "lib"
                           titulo.titnat = vtitnat
                           titulo.modcod = vmodcod
                           titulo.etbcod = vetbcod
                           titulo.datexp = today
                           titulo.clifor = vclifor
                           titulo.titnum = vtitnum
                           titulo.titpar  = i
                           titulo.titdtemi = vtitdtemi
                           titulo.titdtven = vvenc
                           titulo.titbanpag = vsetcod
                           titulo.titagepag = string(vtipo-documento).
                           
                    titulo.titvlcob = (vtotal - vt) / (vtitpar - ii).
                    ii = ii + 1.
                    do on error undo:
                        update titulo.titvlcob format "->>>,>>>,>>9.99"
                        with frame f-par no-validate.
                        if titulo.titvlcob = 0
                        then do:
                          message "Valor Parcela nao pode ser zero".
                            undo, retry.
                        end.
                        vt = vt + titulo.titvlcob.
                        if vt <> vtotal and ii = vtitpar
                        then do:
                        message "Valor das prestacoes nao confere com o total".
                            undo, retry.
                        end.
                    end.
                    create wtit.
                    assign wtit.wrec = recid(titulo).
                    down with frame f-par.
                end.
                /*
                update vcobcod.
                */
                vcobcod = 3.
                find cobra where cobra.cobcod = vcobcod.
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
                vevecod = 3.
                /*
                update vevecod.
                */
                find event where event.evecod = vevecod no-lock.
                /**/
                display event.evenom no-label.
/*                update wperjur with frame fjurdes2.*/
                vtitvljur = 0.
/*                update vtitvljur column-label "Juros" with frame fjurdes2.
                wperdes = 0.
                update /*vtitdtdes*/
                       wperdes
                       vtitvldes format "->>>,>>9.99"
                        with frame fjurdes2 no-validate.
*/                
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
                    
                    vtitobs[1] =  "FUNCIONARIO=" + string(vfuncod) + "|" +
                    "NOME=" + func.funnom + "|FUNFOLHA=" + vfunfol + "|".
                end.
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

                    if titulo.modcod = "DUP"
                    then assign vlancod = 100
                                vlanhis = 1.
                    /*
                    find first lanaut where 
                               lanaut.etbcod = ? and
                               lanaut.forcod = ? and
                               lanaut.modcod = titulo.modcod
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
                                            and  blancxa.etbcod = titulo.etbcod
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
                        
                        find lanaut where lanaut.etbcod = titulo.etbcod and
                                           lanaut.forcod = titulo.clifor
                                                no-lock no-error.
                        if avail lanaut
                        then do:
                            assign vlancod = lanaut.lancod
                                   vlanhis = lanaut.lanhis.
                        end.

                     
                        if vlancod = 0 or
                           vlanhis = 0
                        then
                        
                        update vlancod label "Lancamento"
                               vlanhis label "Historico"
                                      with frame lanca centered side-label
                                                row 15 overlay.
                    end.                            
                    find tablan where tablan.lancod = vlancod no-lock no-error.
                    if vlanhis = 150
                    then vcompl = tablan.landes.
                    else if vlanhis <> 2
                         then vcompl = titulo.titnum 
                                        + "-" + string(titulo.titpar)
                                        + " " + forne.fornom.
                         else vcompl = forne.fornom.

                    find lanaut where lanaut.etbcod = titulo.etbcod and
                                      lanaut.forcod = titulo.clifor
                                                no-lock no-error.
                    if avail lanaut 
                    then do: 
                        assign vlanhis = lanaut.lanhis
                               vcompl  = lanaut.comhis
                               vlancod = lanaut.lancod.
                    end.
     
                         
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
                     
                end.
                titulo.vencod = vlancod.
                titulo.titnumger = vcompl.
                titulo.titparger = vlanhis.
                /***********/
                
                for each wtit:
                    find titulo where recid(titulo) = wtit.wrec.
                    assign titulo.cobcod   = cobra.cobcod
                           titulo.bancod   = vbancod
                           titulo.agecod   = vagecod
                           titulo.evecod   = event.evecod
                           titulo.titvljur = vtitvljur
                           titulo.titdtdes = vtitdtdes
                           titulo.titvldes = vtitvldes
                           titulo.titobs[1] = vtitobs[1]
                           titulo.titobs[2] = vtitobs[2].
                end.
                vinicio = yes.
                recatu1 = recid(titulo).
                next.

        end.
    end.
    clear frame frame-a all no-pause.
    view frame ff.
    if acha("AGENDAR",titulo.titobs[2]) <> ? and
       titulo.titdtven <> date(acha("AGENDAR",titulo.titobs[2])) 
    then v-agendado = "*".
    else v-agendado = "".
    display titulo.titnum format "x(7)"
            titulo.titpar   format ">9"
        titulo.titvlcob format "->>,>>9.99" column-label "Vl.Cobrado"
        titulo.titdtven format "99/99/9999"   column-label "Dt.Vecto"
        titulo.titdtpag format "99/99/9999"   column-label "Dt.Pagto"
        titulo.titvlpag 
        when titulo.titvlpag > 0 format "->>,>>9.99"
                                            column-label "Valor Pago"
/*        titulo.titvljur column-label "Juros" format "->,>>9.9"
        titulo.titvldes column-label "Desc"  format ">>,>>9.9"
        titulo.titsit column-label "S" format "X"
        */
        v-agendado
            with frame frame-a 10 down centered color white/red
            title " " + vcliforlab + " " + forne.fornom + " "
                    + " Cod.: " + string(vclifor) + " " width 80.
    pause 0.
    recatu1 = recid(titulo).
    if  esqregua then do:
        display esqcom1[esqpos1] with frame f-com1.
        color  display message esqcom1[esqpos1] with frame f-com1.
    end.
    else do:
        display esqcom2[esqpos2] with frame f-com2.
        color display message esqcom2[esqpos2] with frame f-com2.
    end.
    repeat:
        find next titulo use-index titdtven   
                    where titulo.empcod   = wempre.empcod and
                               titulo.titnat   = vtitnat       and
                               titulo.modcod   = vmodcod       and
                               titulo.etbcod   = vetbcod       and
                               titulo.clifor   = vclifor and
                               titulo.titbanpag = vsetcod no-error.
        if not available titulo
        then leave.
        if frame-line(frame-a) = frame-down(frame-a)
        then leave.
        if not vinicio
        then down with frame frame-a.
        view frame ff.
        if acha("AGENDAR",titulo.titobs[2]) <> ? and
           titulo.titdtven <> date(acha("AGENDAR",titulo.titobs[2])) 
        then v-agendado = "*".
        else v-agendado = "".
        display titulo.titnum
                titulo.titpar
                titulo.titvlcob format "->>,>>9.99"
                titulo.titdtven
                titulo.titdtpag
                titulo.titvlpag format "->>,>>9.99" 
                when titulo.titvlpag > 0
/*                titulo.titvljur format "->>,>>9.99"
                titulo.titvldes
                titulo.titsit 
                */
                v-agendado with frame frame-a.
        pause 0.
    end.
    up frame-line(frame-a) - 1 with frame frame-a.
    repeat with frame frame-a:
        find titulo where recid(titulo) = recatu1.
        color display messages titulo.titnum titulo.titpar.
        
        on f7 recall.
        choose field titulo.titnum titulo.titpar
            go-on(cursor-down cursor-up cursor-left cursor-right F7 PF7
                  page-up page-down tab PF4 F4 ESC return v V ).
        {pagtit.i}
       if  keyfunction(lastkey) = "RECALL"
       then do with frame fproc centered row 5 overlay color message side-label:
            prompt-for titulo.titnum colon 10.
            find first titulo where titulo.empcod   = wempre.empcod and
                                    titulo.titnat   = vtitnat       and
                                    titulo.modcod   = vmodcod       and
                                    titulo.etbcod   = vetbcod       and
                                    titulo.clifor   = vclifor       and
                                    titulo.titbanpag = vsetcod      and
                                  titulo.titnum >= input titulo.titnum no-error.
            recatu1 = if avail titulo
                      then recid(titulo) else ?. leave.
       end. on f7 help.
       if  keyfunction(lastkey) = "V" or
           keyfunction(lastkey) = "v"
       then do with frame fdt centered row 5 overlay color message side-label:
            vdt = today.
            update vdt label "Vencimento".
            find first titulo where titulo.empcod   = wempre.empcod and
                                    titulo.titnat   = vtitnat       and
                                    titulo.modcod   = vmodcod       and
                                    titulo.etbcod   = vetbcod       and
                                    titulo.clifor   = vclifor       and
                                    titulo.titdtven >= vdt          and
                                    titulo.titbanpag = vsetcod no-error.
            if avail titulo
            then recatu1 = recid(titulo). 
            else do:
                find next titulo use-index titdtven where 
                                 titulo.empcod = wempre.empcod   and
                                 titulo.titnat   = vtitnat       and
                                 titulo.modcod   = vmodcod       and
                                 titulo.etbcod   = vetbcod       and
                                 titulo.clifor   = vclifor       and
                                 titulo.titdtven >= vdt          and
                                 titulo.titbanpag = vsetcod no-error.
                             
                if avail titulo
                then recatu1 = recid(titulo).
                else do:
                     find prev titulo use-index titdtven where 
                                 titulo.empcod = wempre.empcod   and
                                 titulo.titnat   = vtitnat       and
                                 titulo.modcod   = vmodcod       and
                                 titulo.etbcod   = vetbcod       and
                                 titulo.clifor   = vclifor       and
                                 titulo.titdtven <= vdt          and
                                 titulo.titbanpag = vsetcod no-error.
                 
                    if avail titulo
                    then recatu1 = recid(titulo).
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
            find next titulo use-index titdtven
                             where titulo.empcod   = wempre.empcod and
                                   titulo.titnat   = vtitnat       and
                                   titulo.modcod   = vmodcod       and
                                   titulo.etbcod   = vetbcod   and
                                   titulo.clifor   = vclifor  and
                                   titulo.titbanpag = vsetcod  no-error.
            if  not avail titulo
            then next.
            color display normal titulo.titnum titulo.titpar.
            if frame-line(frame-a) = frame-down(frame-a)
            then scroll with frame frame-a.
            else down with frame frame-a.
        end.
        if  keyfunction(lastkey) = "cursor-up" then do:
            find prev titulo use-index titdtven
                             where titulo.empcod   = wempre.empcod and
                                   titulo.titnat   = vtitnat       and
                                   titulo.modcod   = vmodcod       and
                                   titulo.etbcod   = vetbcod       and
                                   titulo.clifor   = vclifor and
                                   titulo.titbanpag = vsetcod no-error.
            if not avail titulo
            then next.
            color display normal titulo.titnum titulo.titpar.
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
                vtitpar = 1.
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
                update vtitdtemi vtotal label "Total".
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
                    create titulo.
                    assign titulo.exportado = yes
                           titulo.empcod = wempre.empcod
                           titulo.titsit = "lib"
                           titulo.titnat = vtitnat
                           titulo.modcod = vmodcod
                           titulo.etbcod = vetbcod
                           titulo.datexp = today
                           titulo.clifor = vclifor
                           titulo.titnum = vtitnum
                           titulo.titpar  = i
                           titulo.titdtemi = vtitdtemi
                           titulo.titdtven = vvenc
                           titulo.titvlcob = (vtotal - vt) / (vtitpar - ii)
                           ii = ii + 1
                           titulo.titbanpag = vsetcod
                           titulo.titagepag = string(vtipo-documento).

                    do on error undo:
                        update titulo.titvlcob format "->>>,>>>,>>9.99"
                        with frame f-par no-validate.
                        if titulo.titvlcob = 0
                        then do:
                          message "Valor Parcela nao pode ser zero".
                            undo, retry.
                        end.
                        vt = vt + titulo.titvlcob.
                        if vt <> vtotal and ii = vtitpar
                        then do:
                        message "Valor das prestacoes nao confere com o total".
                            undo, retry.
                        end.
                    end.
                    create wtit.
                    assign wtit.wrec = recid(titulo).
                    vtot = vtot + titulo.titvlcob.
                    down with frame f-par.
                end.
                hide frame f-par no-pause.
                vcobcod = 1.
                /*
                update vcobcod.
                */
                find cobra where cobra.cobcod = vcobcod.
                display cobra.cobnom  no-label.
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
                /*wperjur = 0.*/
                vevecod = 3. 
                /*
                update vevecod.
                */
                find event where event.evecod = vevecod no-lock.
                /*display event.evenom no-label.*/
                
                /*wperjur = 0.*/
                vtitvljur = 0.
                wperdes = 0.
                vtitobs = "".
                vtitvldes = 0.
                vtitdtdes = ?.
/*                update wperjur with frame fjurdes2.*/
/*                update vtitvljur column-label "Juros" with frame fjurdes2.*/
                wperdes = 0.
/*                update /*vtitdtdes*/
                       wperdes
                       vtitvldes format "->>>,>>9.99"
                            with frame fjurdes2 no-validate.
*/                            
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
                        "Nao cadastrado. Certifique-se que o codigo da folha esteja preenchido no cadastro de funcionario do estab 996, campo Usuario." view-as alert-box.
                        undo, retry.
                    end.    
                    disp func.funnom no-label with frame f-func.
                    pause.
                    vfuncod = func.funcod.
                    vtitobs[1] =  "FUNCIONARIO=" + string(vfuncod) + "|" +
                    "NOME=" + func.funnom + "|" + "FUNFOLHA=" + vfunfol
                    + "|".
                end.

                update text(vtitobs) with frame fobs2. pause 0.
                /******* frete *********/
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
                                   btitulo.etbcod   = titulo.etbcod
                                   btitulo.titnat   = yes
                                   btitulo.modcod   = "NEC"
                                   btitulo.clifor   = frete.forcod
                                   btitulo.cxacod   = forne.forcod
                                   btitulo.titsit   = "lib"
                                   btitulo.empcod   = titulo.empcod
                                   btitulo.titdtemi = titulo.titdtemi
                                   btitulo.titnum   = titulo.titnum
                                   btitulo.titpar   = 1
                                   btitulo.titnumger = titulo.titnum
                                   btitulo.titvlcob = vlfrete.
                                   
                            update btitulo.titdtven label "Venc.Frete"
                                   btitulo.titnum   label "Controle"
                                with frame f-frete2 centered color white/cyan
                                                side-label row 15 no-validate.

                        end.    
                            
                    end. 
                    hide frame ffrete no-pause.
                    
                
                
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

                    if titulo.modcod = "DUP"
                    then assign vlancod = 100
                                vlanhis = 1.
                    /*
                    find first lanaut where 
                               lanaut.etbcod = ? and
                               lanaut.forcod = ? and
                               lanaut.modcod = titulo.modcod
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
                                     blancxa.etbcod = titulo.etbcod and
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
                        
                        find lanaut where lanaut.etbcod = titulo.etbcod and
                                          lanaut.forcod = titulo.clifor
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

                    find lanaut where lanaut.etbcod = titulo.etbcod and
                                      lanaut.forcod = titulo.clifor
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
                         then vcompl = titulo.titnum 
                                + "-" + string(titulo.titpar)
                                + " " + forne.fornom.
                         else vcompl = forne.fornom.
                    
                  
                    
                    
                    
                    
                    if vlancod = 100
                    then assign vlanhis = 1
                                vcompl = titulo.titnum 
                                    + "-" + string(titulo.titpar)
                                    + " " + forne.fornom.
                                
                                
                    
                    else if
                         vlanhis = 0 or
                         vcompl  = ""
                         then update vlanhis label "Historico"
                                     vcompl  label "Complemento"
                                        with frame lanca centered side-label
                                               row 15 overlay.
                    if vlanhis = 6
                    then vcompl = "".
                end.
                titulo.vencod = vlancod.
                titulo.titnumger = vcompl.
                titulo.titparger = vlanhis. 
                /***********/
                
                for each wtit:
                    find titulo where recid(titulo) = wtit.wrec.
                    assign titulo.cobcod   = cobra.cobcod
                           titulo.bancod   = vbancod
                           titulo.agecod   = vagecod
                           titulo.evecod   = event.evecod
                           titulo.titvljur = vtitvljur
                           titulo.titdtdes = vtitdtdes
                           titulo.titvldes = vtitvldes
                           titulo.titobs[1] = vtitobs[1]
                           titulo.titobs[2] = vtitobs[2].
                    delete wtit.
                end.
                
                recatu1 = recid(titulo).
                leave.
            end.
            if esqcom1[esqpos1] = "Alteracao"
            then do with frame ftitulo:
                vtitvlcob = titulo.titvlcob .
                titulo.datexp = today.
                hide frame f-senha no-pause.
                hide frame f-fre2 no-pause.
                update titulo.clifor column-label "Fornecedor"
                       titulo.titnum
                       titulo.titpar
                       titulo.titdtemi
                       titulo.titdtven
                       titulo.titvlcob format "->>>,>>>,>>9.99"
                       titulo.cobcod with no-validate.
                find cobra where cobra.cobcod = titulo.cobcod.
                display cobra.cobnom.
                if cobra.cobban
                then do with frame fbanco:
                    update titulo.bancod.
                    find banco where banco.bancod = titulo.bancod.
                    display banco.bandesc .
                    update titulo.agecod.
                    find agenc of banco where agenc.agecod = titulo.agecod.
                    display agedesc.
                end.
                update titulo.modcod colon 15.
                find fin.modal where modal.modcod = titulo.modcod no-lock.
                display fin.modal.modnom no-label.
                update titulo.evecod colon 15.
                find event where event.evecod = titulo.evecod no-lock.
                display event.evenom no-label.
/*                update titulo.titvljur with frame fjurdes .*/
/*                update titulo.titdtdes with frame fjurdes.
                update titulo.titvldes format ">>>,>>9.99"
                        with frame fjurdes no-validate.
*/                        
                update text(titulo.titobs) with frame fobs.
                if  titulo.titvlcob <> vtitvlcob then do:
                   if  titulo.titvlcob < vtitvlcob then do:
                    assign sresp = yes.
                    display "  Confirma GERACAO DE NOVO titulo ?"
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
                            btitulo.titnum   = titulo.titnum.
                            create ctitulo.
                            assign ctitulo.exportado = yes
                                   ctitulo.empcod = btitulo.empcod
                                   ctitulo.modcod = btitulo.modcod
                                   ctitulo.clifor = btitulo.clifor
                                   ctitulo.titnat = btitulo.titnat
                                   ctitulo.etbcod = btitulo.etbcod
                                   ctitulo.titnum = btitulo.titnum
                                   ctitulo.cobcod = titulo.cobcod
                                   ctitulo.titpar   = btitulo.titpar + 1
                                   ctitulo.titdtemi = today
                                   ctitulo.titdtven = titulo.titdtven
                                   ctitulo.titvlcob = 
                                   vtitvlcob - titulo.titvlcob
                                   ctitulo.titnumger = titulo.titnum
                                   ctitulo.titparger = titulo.titpar
                                   ctitulo.datexp    = today.
                            display ctitulo.titnum
                                    ctitulo.titpar
                                    ctitulo.titdtemi
                                    ctitulo.titdtven
                                    ctitulo.titvlcob format "->>>,>>>,>>9.99"
                                    with frame fmos width 40 1 column
                                              title " titulo Gerado " 
                                              overlay
                                              centered row 10.
                            recatu1 = recid(ctitulo).
                            leave.
                        end.
                     end.
                     else do:
                        display "  Confirma AUMENTO NO VALOR DO titulo?"
                                with frame faum color messages
                                width 60 overlay row 10 centered.
                        update sresp no-label with frame faum.
                        if not sresp then undo, leave.
                    end.
                end.
                message "Confirma titulo" update sresp.
                if sresp
                then do on error undo:
                    /*
                    for each ztitulo use-index titdtven where
                                            ztitulo.clifor = titulo.clifor and
                                            ztitulo.titnat = yes no-lock:
                        if ztitulo.titnum begins "A"
                        then do:
                            display ztitulo.etbcod
                                    ztitulo.titnum
                                    ztitulo.titpar
                                    ztitulo.titdtven
                                    ztitulo.titdtpag
                                    ztitulo.titvlpag 
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
                    update vfre label "Frete" with frame f-fre2
                            centered side-label row 8.
                    if vfre = 2
                    then do:
                        vv = 0.            
                        for each ftitulo use-index cxmdat where 
                                        ftitulo.etbcod = titulo.etbcod and
                                        ftitulo.cxacod = titulo.clifor and
                                        ftitulo.titnumger = 
                                                        string(titulo.titnum) 
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
                                   btitulo.etbcod   = titulo.etbcod
                                   btitulo.titnat   = yes
                                   btitulo.modcod   = "NEC"
                                   btitulo.clifor   = frete.forcod
                                   btitulo.cxacod   = forne.forcod
                                   btitulo.titsit   = "lib"
                                   btitulo.empcod   = titulo.empcod
                                   btitulo.titdtemi = titulo.titdtemi
                                   btitulo.titnum   = titulo.titnum
                                   btitulo.titpar   = 1
                                   btitulo.titnumger = titulo.titnum
                                   btitulo.titvlcob = vlfrete.
                                   
                            update btitulo.titdtven label "Venc.Frete"
                                   btitulo.titnum   label "Controle"
                                with frame f-frete22 centered color white/cyan
                                                side-label row 15 no-validate.

                        end.    
                            
                    end. 
                    hide frame ffrete2 no-pause.
                    
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
                    if titulo.titsit = "CON"
                    then assign
                            titulo.titdtdes = ?
                            titulo.titsit = "LIB".
                    else assign 
                            titulo.titdtdes = today
                            titulo.titsit = "CON".
                    
                    message "Confirma Frete" update sresp.
                    if sresp
                    then do:
                        for each btitulo use-index cxmdat where 
                                   btitulo.etbcod    = titulo.etbcod and
                                   btitulo.cxacod    = titulo.clifor and
                                   btitulo.titnumger = string(titulo.titnum): 
                        
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
                find modal of titulo no-lock no-error.
                disp titulo.modcod
                     modal.modnom when available modal no-label
                     titulo.titnum
                     titulo.titpar
                     titulo.titdtemi
                     titulo.titdtven
                     titulo.titvlcob format "->>>,>>>,>>9.99"
                     titulo.cobcod with frame ftitulo.
/*                     
                disp titulo.titvljur
                     titulo.titjuro
                     titulo.titdtdes
                     titulo.titvldes
                     titulo.titdtpag
                     titulo.titvlpag 
                     format "->>>,>>>,>>9.99"
                     with frame fjurdes.
*/                     
            end.
            if esqcom1[esqpos1] = "Exclusao"
            then do with frame f-exclui overlay row 6 1 column centered.
                if titulo.titsit = "CON"
                then do:
                    message "titulo nao pode ser excluido". pause.
                    undo, retry.
                end.
                message "Confirma Exclusao de titulo"
                            titulo.titnum ",Parcela" titulo.titpar
                update sresp.
                if not sresp
                then leave.
                find next titulo use-index titdtven
                                 where titulo.empcod   = wempre.empcod and
                                       titulo.titnat   = vtitnat       and
                                       titulo.modcod   = vmodcod       and
                                       titulo.etbcod   = vetbcod       and
                                       titulo.clifor   = vclifor no-error.
                if not available titulo
                then do:
                    find titulo where recid(titulo) = recatu1.
                    find prev titulo use-index titdtven
                                     where titulo.empcod   = wempre.empcod and
                                           titulo.titnat   = vtitnat       and
                                           titulo.modcod   = vmodcod       and
                                           titulo.etbcod   = vetbcod       and
                                           titulo.clifor   = vclifor no-error.
                end.
                recatu2 = if available titulo
                          then recid(titulo)
                          else ?.
                find titulo where recid(titulo) = recatu1.
                
                deletou-lancxa = no.
                for each lancxa where lancxa.datlan = titulo.titdtpag and
                                      lancxa.forcod = titulo.clifor   and
                                      lancxa.titnum = titulo.titnum   and
                                      lancxa.lancod = titulo.vencod:
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
                
                delete titulo.
                recatu1 = recatu2.
                hide frame fitulo no-pause.
                leave.
            end.
            if esqcom1[esqpos1] = "Agendamento"
            then do:
                if titulo.titsit = "LIB" or
                   titulo.titsit = "CON"
                then do:
                    run agendamento.
                end.
                leave.   
            end.
          end.
          else do:
            hide frame f-com2 no-pause.
            if  esqcom2[esqpos2] = "Pagamento/Cancelamento"
            then if  titulo.titsit = "LIB" or titulo.titsit = "IMP" or
                     titulo.titsit = "CON"
              then do with frame f-Paga overlay row 6 1 column centered.
                 display titulo.titnum    colon 13
                        titulo.titpar    colon 33 label "Pr"
                        titulo.titdtemi  colon 13
                        titulo.titdtven  colon 13
                        titulo.titvlcob  colon 13 label "Vl.Cobr."
                        format "->>>,>>>,>>9.99"
/*                        titulo.titvljur  colon 13 label "Vl.Juro"
                        titulo.titvldes  format ">>>,>>9.99"
                                colon 13 label "Vl.Desc"*/
                        with frame fdadpg side-label
                        overlay row 6 color white/cyan width 40
                        title " titulo ".
                 titulo.datexp = today.
               if  titulo.modcod = "CRE" then do:
                   {titpagb4.i}
/*                   update titulo.titvljur  colon 13 label "Vl.Juro"
                          titulo.titvldes  colon 13 label "Vl.Desc"
                                format ">>>,>>9.99"
                                            with frame fdadpg side-label
                                    overlay row 6 color white/cyan width 40
                                          title " titulo " no-validate.
            */                                          
               end.
               else do:
                   hide frame lanca no-pause.
                   assign titulo.titdtpag = today.
                   display titulo.titdtdes colon 13 label "Dt.Desc"
                           titulo.titvldes colon 13 label "Vl.Desc"
                                           format ">>>,>>9.99"
/*                           titulo.titvljur colon 13 label "Vl.Juro"
*/
                                      with frame fdadpg.
  /*                 update titulo.titdtpag with frame fpag1.*/
                   
                   /**
                   if titulo.titdtpag < titulo.titdtven
                   then do:
                        message  "Informe a taxa para pagamento antecipado %"
                                 update taxa-ante.
                                                 
                        if taxa-ante > 0
                        then do:
                            titulo.titvlpag = titulo.titvlcob -
                            (titulo.titvlcob * (taxa-ante / 100)).
                            titulo.titdesc = taxa-ante.
                        end.
                        else titulo.titvlpag = titulo.titvlcob.   
                         
                   end.
                   else
                   **/
                   titulo.titvlpag = titulo.titvlcob.
                   
                   /*
                   if titulo.titdtpag > titulo.titdtven 
                   then assign titulo.titvlpag = titulo.titvlcob
                                                 + titulo.titvljur.
                                                  /* *
                                        (titulo.titdtpag - titulo.titdtven)).
                                                  */
                   else if titulo.titdtpag <= titulo.titdtdes
                   then assign titulo.titvlpag = titulo.titvlcob -
                                          titulo.titvldes. /* *
                                     ((titulo.titdtdes - titulo.titdtpag) + 1)).
                                                   */
                   */
                   
                titulo.titvlpag = titulo.titvlcob + titulo.titvljur
                                     - titulo.titvldes.
                assign vtitvlpag = titulo.titvlpag.
                update titulo.titvlpag format "->>>,>>>,>>9.99"
                            with frame fpag1.
                update titulo.cobcod with frame fpag1.
/*                update titulo.titvljur column-label "Juros"
                       titulo.titvldes format ">>>,>>9.99"
                            with frame fpag1 no-validate.*/
                
                
                titulo.titvlpag = titulo.titvlcob + titulo.titvljur -
                                  titulo.titvldes.
                
                
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

                    vlancod = titulo.vencod.
                    vlanhis = titulo.titparger.
                    vcompl  = titulo.titnumger.

                    if vclifor = 533
                    then vlanhis = 5.
                    
                    if vclifor = 100071
                    then vlanhis = 4.

                    if vclifor = 100072
                    then vlanhis = 3.

                    find lanaut where lanaut.etbcod = titulo.etbcod and
                                      lanaut.forcod = titulo.clifor
                                                no-lock no-error.
                    if avail lanaut 
                    then do: 
                        assign vlanhis = lanaut.lanhis
                               vcompl  = lanaut.comhis
                               vlancod = lanaut.lancod.
                    end.
                    
                    if titulo.modcod = "DUP"
                    then assign vlancod = 100
                                vlanhis = 1
                                vcompl  = titulo.titnum 
                                    + "-" + string(titulo.titpar)
                                    + " " + forne.fornom.
                    /*
                    find first lanaut where 
                               lanaut.etbcod = ? and
                               lanaut.forcod = ? and
                               lanaut.modcod = titulo.modcod
                               no-lock no-error.
                    if avail lanaut
                    then do:
                        assign
                            vlancod = lanaut.lancod
                            vlanhis = lanaut.lanhis
                            vcompl  = titulo.titnum 
                                    + "-" + string(titulo.titpar)
                                    + " " + forne.fornom.
                            .
                    end. 
                    */
                    else do:

                        
                        
                        find last blancxa where blancxa.forcod = forne.forcod
                                            and  blancxa.etbcod = titulo.etbcod
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
                        
                        find lanaut where lanaut.etbcod = titulo.etbcod and
                                          lanaut.forcod = titulo.clifor
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
                               lancxa.datlan = titulo.titdtpag
                               lancxa.lancod = vlancod
                               lancxa.numlan = vnumlan
                               lancxa.vallan = titulo.titvlcob
                               lancxa.comhis = vcompl
                               lancxa.lantip = "C"
                               lancxa.forcod = titulo.clifor
                               lancxa.titnum = titulo.titnum
                               lancxa.etbcod = titulo.etbcod
                               lancxa.modcod = titulo.modcod
                               lancxa.lanhis = vlanhis.
                        
                        if lancxa.lanhis = 1
                        then lancxa.comhis = titulo.titnum 
                                + "-" + string(titulo.titpar)
                                + " " + forne.fornom.
                        
                        find lanaut where lanaut.etbcod = titulo.etbcod and
                                          lanaut.forcod = titulo.clifor
                                                no-lock no-error.
                        if avail lanaut
                        then do:
                            assign lancxa.lanhis = lanaut.lanhis
                                   lancxa.comhis = lanaut.comhis
                                   lancxa.lancod = lanaut.lancod.
                        end.
                                                

                        if titulo.titvljur > 0 and vtitnat = yes
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
                                   blancxa.datlan = titulo.titdtpag
                                   blancxa.lancod = 110
                                   blancxa.numlan = vnumlan
                                   blancxa.vallan = titulo.titvljur
                                   blancxa.comhis = vcompl
                                   blancxa.lantip = "C"
                                   blancxa.forcod = titulo.clifor
                                   blancxa.titnum = titulo.titnum
                                   blancxa.etbcod = titulo.etbcod
                                   blancxa.modcod = titulo.modcod
                                   blancxa.lanhis = vlanhis.
                                   
                        end.    
                        
                        if titulo.titvldes > 0 and vtitnat = yes
                        then do:
                            find last lancxa use-index ind-1
                                 where lancxa.numlan <> ? no-lock no-error.
                            if not avail lancxa
                            then vnumlan = 1.
                            else vnumlan = lancxa.numlan + 1.
                            create blancxa.
                            if titulo.clifor = 100090 or
                               titulo.clifor = 101463
                            then find tablan where tablan.lancod = 111 no-lock.
                            else find tablan where tablan.lancod = 439 no-lock.
                            vlanhis = tablan.lanhis.
                            run his-complemento.
                            ASSIGN blancxa.cxacod = 13
                                   blancxa.datlan = titulo.titdtpag
                                   blancxa.lancod = tablan.lancod
                                   blancxa.numlan = vnumlan
                                   blancxa.vallan = titulo.titvldes
                                   blancxa.comhis = vcompl
                                   blancxa.lantip = "D"
                                   blancxa.forcod = titulo.clifor
                                   blancxa.titnum = titulo.titnum
                                   blancxa.etbcod = titulo.etbcod
                                   blancxa.modcod = titulo.modcod
                                   blancxa.lanhis = tablan.lanhis.
                            
                            if tablan.lanhis = 12
                            then blancxa.comhis = 
                                 titulo.titnum + " " + forne.fornom.

                        end.    

                    end.
                    else do:
                        message "Lancamento nao cadastrado".
                        undo, retry.
                    end.
                end.
                hide frame lanca no-pause.
  
                if titulo.titvlpag >= titulo.titvlcob
                then. /* titulo.titjuro = titulo.titvlpag - titulo.titvlcob. */
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
                            btitulo.titnum   = titulo.titnum.
                            create ctitulo.
                            assign 
                                ctitulo.exportado = yes
                                ctitulo.empcod = btitulo.empcod
                                ctitulo.modcod = btitulo.modcod
                                ctitulo.clifor = btitulo.clifor
                                ctitulo.titnat = btitulo.titnat
                                ctitulo.etbcod = btitulo.etbcod
                                ctitulo.titnum = btitulo.titnum
                                ctitulo.cobcod = titulo.cobcod
                                ctitulo.titpar   = btitulo.titpar + 1
                                ctitulo.titdtemi = titulo.titdtemi
                                ctitulo.titdtven = if titulo.titdtpag <
                                                      titulo.titdtven
                                                   then titulo.titdtven
                                                   else titulo.titdtpag
                                ctitulo.titvlcob = vtitvlpag - titulo.titvlpag
                                ctitulo.titnumger = titulo.titnum
                                ctitulo.titparger = titulo.titpar
                                ctitulo.datexp    = today
                                 titulo.titnumger = ctitulo.titnum
                                 titulo.titparger = ctitulo.titpar.
                            display ctitulo.titnum
                                    ctitulo.titpar
                                    ctitulo.titdtemi
                                    ctitulo.titdtven
                                    ctitulo.titvlcob format "->>>,>>>,>>9.99"
                                    with frame fmos width 40 1 column
                                              title " titulo Gerado " 
                                              overlay
                                              centered row 10.
                        end.
                        else titulo.titdesc = titulo.titvlcob - titulo.titvlpag.
                end.
                assign titulo.titsit = "PAG".
               end.
               do:
               recatu1 = recid(titulo).
               leave.
               end.
              end.
              else
                if  titulo.titsit = "PAG" then do:
                display titulo.titnum
                        titulo.titpar
                        titulo.titdtemi
                        titulo.titdtven
                        titulo.titvlcob format "->>>,>>>,>>9.99"
                        titulo.cobcod with frame ftitulo.
                    titulo.datexp = today.
                    titulo.cxmdat = ?.
                    titulo.cxacod = 0.
                    display titulo.titdtpag titulo.titvlpag titulo.cobcod
                            with frame fpag1.
                    do:
                    message "Pagemento ja efetuado ". pause.
                    undo, retry.
                    end.
                    message "Confirma o Cancelamento do Pagamento ?"
                            update sresp.
                    if sresp then do:
                        for each lancxa where lancxa.datlan = titulo.titdtpag
                                        and   lancxa.forcod = titulo.clifor 
                                        and   lancxa.titnum = titulo.titnum
                                        and   lancxa.lancod = titulo.vencod:
                            delete lancxa.
                        end.
                        assign titulo.titsit  = "LIB"
                               titulo.titdtpag  = ?
                               titulo.titvlpag  = 0
                               titulo.titbanpag = 0
                               titulo.titagepag = ""
                               titulo.titchepag = ""
                               titulo.titvljur  = 0
                               titulo.datexp    = today.
                        find first b-titu where
                                   b-titu.empcod    =  titulo.empcod and
                                   b-titu.titnat    =  titulo.titnat and
                                   b-titu.modcod    =  titulo.modcod and
                                   b-titu.etbcod    =  titulo.etbcod and
                                   b-titu.clifor    =  titulo.clifor and
                                   b-titu.titnum    =  titulo.titnum and
                                   b-titu.titpar    <> titulo.titpar and
                                   b-titu.titparger =  titulo.titpar
                                   no-lock no-error.
                        if  avail b-titu then do:
                        display "Verifique titulo Gerado do Pagamento Parcial"
                                with frame fver color messages
                                width 50 overlay row 10 centered.
                            pause.
                        end.
                   
                   end.
                   do:
                   recatu1 = recid(titulo).
                   next bl-princ.
                   end. 
                end.
            if esqcom2[esqpos2]  = "Bloqueio/Liberacao" and
               titulo.titsit    <> "PAG"
            then do:
                if titulo.titsit <> "BLO"
                then do:
                    message "Confirma o Bloqueio do titulo ?" update sresp.
                    if  sresp then do:
                        titulo.titsit = "BLO".
                        titulo.datexp = today.
                    end.
                end.
                else
                    if titulo.titsit = "BLO"
                    then do:
                        message "Confirma a Liberacao do titulo ?" update sresp.
                        if  sresp then do:
                            titulo.titsit = "LIB".
                            titulo.datexp = today.
                        end.
                     end.
            end.
          end.
          view frame frame-a.
          view frame f-com2 .
        end.
          if keyfunction(lastkey) = "end-error"
          then view frame frame-a.
        if acha("AGENDAR",titulo.titobs[2]) <> ? and
            titulo.titdtven <> date(acha("AGENDAR",titulo.titobs[2])) 
        then v-agendado = "*".
        else v-agendado = "".

        display titulo.titnum
                titulo.titpar
                titulo.titvlcob format "->>,>>9.99"
                titulo.titdtven
                titulo.titdtpag
                titulo.titvlpag format "->>,>>9.99" 
                when titulo.titvlpag > 0
/*                titulo.titvljur format "->>,>>9.99"
                titulo.titvldes
                titulo.titsit */
                v-agendado with frame frame-a.
        if esqregua
        then display esqcom1[esqpos1] with frame f-com1.
        else display esqcom2[esqpos2] with frame f-com2.
        recatu1 = recid(titulo).
   end.
end.
end.


procedure his-complemento:

    find hispad where hispad.hiscod = vlanhis no-lock no-error.
    if avail hispad and hispad.hiscom
    then do:
        if hispad.hisnum
        then vcompl = vcompl + " " + titulo.titnum.
        if hispad.hisfor
        then vcompl = vcompl + " " + forne.fornom .
        if hispad.hisdat
        then vcompl = vcompl + " " + string(titulo.titdtpag).
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
    def var val-titag like titulo.titvlcob.
    def var des-titag like titulo.titvlcob.
    def var jur-titag like titulo.titvlcob.
    def var atu-titag like titulo.titvlcob.
    def var jur-dia as dec.
    def buffer btitulo for titulo.
    for each btitulo where btitulo.empcod = titulo.empcod and
                           btitulo.titnat = titulo.titnat and
                           btitulo.modcod = titulo.modcod and
                           btitulo.clifor = titulo.clifor and
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
    disp qtd-titag   label "titulos"
         val-titag   label "Valor"      
         jur-titag   label "Juro"
         des-titag   label "Desconto"
         atu-titag   label "Total"
         with frame f-disp11 no-box row 18 centered.
         
    dt-agenda = date(acha("AGENDAR",titulo.titobs[2])).
    pct-jd    = dec(acha("PCTJD",titulo.titobs[2])).
    vl-juro   = dec(acha("VALJURO",titulo.titobs[2])).
    vl-desc   = dec(acha("VALDESC",titulo.titobs[2])).
    if vl-juro = ? then vl-juro = 0.
    if vl-desc = ? then vl-desc = 0.
    vl-total = titulo.titvlcob - vl-desc + vl-juro.
    vl-juroc = vl-juroc + titulo.titvljur.
    vl-descc = vl-descc + titulo.titvldes.
    disp titulo.titnum   to 37
         /*titulo.titpar to 45*/
         titulo.titvlcob to 41 
         titulo.titdtven to 35
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
        if dt-agenda < titulo.titdtven
        then vl-desc = ((titulo.titvlcob - titulo.titvldes) * (jur-dia / 100))
                * ( titulo.titdtven - dt-agenda ) .
        else if dt-agenda > titulo.titdtven
            then vl-juro = ((titulo.titvlcob + titulo.titvljur) 
                            * (jur-dia / 100))
                    * ( dt-agenda - titulo.titdtven) .
            
        disp vl-juro vl-desc with frame f-agenda.
        vl-total = titulo.titvlcob + vl-juro + vl-juroc 
                        - vl-desc - vl-descc.
        
        disp vl-total with frame f-agenda.
        sresp = no.
        message "Confirma agendamento ?" update sresp.
        if sresp
        then do:
            titulo.titobs[2] = "|AGENDAR=" + string(dt-agenda,"99/99/9999") +
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
            create titulo.
            assign 
                titulo.exportado = yes
                titulo.empcod = wempre.empcod
                titulo.titsit = "LIB"
                titulo.titnat = vtitnat
                titulo.modcod = vmodcod
                titulo.etbcod = tt-lj.etbcod
                titulo.datexp = today
                titulo.clifor = vclifor
                titulo.titnum = vtitnum
                titulo.titpar  = 1
                titulo.titdtemi = vtitdtemi
                titulo.titdtven = vvenc
                titulo.titvlcob = vtotal / vqtd-lj
                titulo.titbanpag = vsetcod
                titulo.titagepag = string(vtipo-documento)
                titulo.titobs[1] = vtitobs[1]
                titulo.titobs[2] = vtitobs[2] .
                           

            /***
            if vclifor = 533
            then vlanhis = 5.
                    
            if vclifor = 100071
            then vlanhis = 4.

            if vclifor = 100072
            then vlanhis = 3.

            if titulo.modcod = "DUP"
            then assign vlancod = 100
                        vlanhis = 1.

            else do:
                        find last blancxa where 
                                     blancxa.forcod = forne.forcod  and
                                     blancxa.etbcod = titulo.etbcod and
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
                                lanaut.etbcod = titulo.etbcod and
                                lanaut.forcod = titulo.clifor
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

                    find lanaut where lanaut.etbcod = titulo.etbcod and
                                      lanaut.forcod = titulo.clifor
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
                         then vcompl = titulo.titnum + " " + 
                                forne.fornom.
                         else vcompl = forne.fornom.
                    
                    if vlancod = 100
                    then assign 
                            vlanhis = 1
                            vcompl = titulo.titnum + " " + 
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
            titulo.vencod = vlancod.
            titulo.titnumger = vcompl.
            titulo.titparger = vlanhis. 
            **/
        end.
    end.
end procedure.
