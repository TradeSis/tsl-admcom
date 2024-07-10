{admcab.i}

def temp-table tt-lancxa like lancxa.

def buffer titulo for banfin.titulo.

def temp-table tt-titulo like fin.titulo.
def temp-table tt-titudesp like titudesp.

def buffer btitudesp for titudesp.

procedure cal-dia-util:
    def input parameter dias-util as int.
    def output parameter data-util as date.
    def var vdt as date.
    def var vdi as int.
    data-util = today.
    if weekday(data-util) = 1 
    then data-util = data-util + 1.
    else if weekday(data-util) = 7
        then data-util = data-util + 2.
       
    do vdi = 1 to dias-util:
        data-util = data-util + 1.
        if weekday(data-util) = 7
        then data-util = data-util + 2.
    end. 
end procedure.

def var data-util as date.
run cal-dia-util(input 7, output data-util).

def var vfatnum as int.
def var ii as i.
def var vt      as dec format "->>>,>>>,>>9.99".
def var vtot like titulo.titvlcob.
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
def var vevecod   like fin.event.evecod.
def var vtitdtven like titulo.titdtven.
def var vtitvljur like titulo.titvlcob.
def var vtitdtdes like titulo.titdtdes.
def var vtitvldes like titulo.titvlcob.
def var vtitobs   like titulo.titobs.
def buffer xtitulo for banfin.titulo.
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
/*
def var esqcom1         as char format "x(14)" extent 5
        initial ["Inclusao","Alteracao","Exclusao","Consulta","Agendamento"].
def var esqcom2         as char format "x(22)" extent 3
            initial ["Pagamento/Cancelamento", "Bloqueio/Liberacao",
                        "Data Exportacao"].
*/

def var esqcom1         as char format "x(14)" extent 5
        initial ["Inclusao","Alteracao","","Consulta",""].
def var esqcom2         as char format "x(22)" extent 3
            initial ["","",""].


def temp-table tt-nfser
    field documento as int    label "Documento" format ">>>>>>>>9"
    field emissao as date     label "Emissao  " format "99/99/9999"
    field inclusao as date    label "Inclusao " format "99/99/9999"
    field val-ir as dec       label "IR "
    field val-iss as dec      label "ISS"
    field val-inss as dec     label "INSS"
    field val-pis as dec      label "PIS"
    field val-cofins as dec   label "COFINS"
    field val-csll as dec     label "CSLL"
    field val-total as dec    label "Valor da despesa"
    field val-liq as dec      label "Valor liquido " 
    field qtd-par as int      label "Quant. parcelas" 
    field val-icms as dec     label "ICMS"
    field val-ipi  as dec     label "IPI"
    field val-des  as dec     label "Desconto"
    field val-acr  as dec     label "Acrescimo"
    field val-juro as dec     label "Juro"
    field situacao as char
    .
    
def shared var vsetcod like setaut.setcod.
def buffer btitulo      for banfin.titulo.
def buffer ctitulo      for banfin.titulo.
def buffer b-titu       for banfin.titulo.
def shared var vempcod         like titulo.empcod.
def shared var vetbcod         like titulo.etbcod.
def shared var vmodcod         like titulo.modcod.
def shared var vmod-ctb        like titulo.modcod. 
def shared var vtitnat         like titulo.titnat.
def var vcliforlab      as char format "x(12)".
def var vclifornom      as char format "x(30)".
def shared var vclifor         like titulo.clifor.
vforcod = vclifor.
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
    row 4 no-box no-labels side-labels column 1.

form esqcom2
    with frame f-com2
        row screen-lines - 1 /*title " OPERACOES " */
        no-labels side-labels column 1
        no-box centered.

{forfrm.i}

esqcom1[5] = "".
esqcom2 = "".

def shared var vtipo-documento as int.
def new shared var vsel-sit1 as char format "x(15)" extent 10
          init["Nota Fiscal",
               "Folha Pagamento",
               "Drebes Financeira",
               "Drebes Promotora",
               "Aluguel",
               "DARF",
               "RPA",
               "Recibo Completo",
               "Recibo Comum",
               "Nenhum"].

def var v-agendado as char format "x" label "A".
def var taxa-ante as dec format ">>9.99".
def var deletou-lancxa as log.
def var vfrecod like frete.frecod.
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

find forne where forne.forcod = vclifor no-lock.

def shared temp-table tt-lj like estab.
def var vqtd-lj as int init 0.
vqtd-lj = 0.
for each tt-lj where etbcod > 0 no-lock:
    vqtd-lj = vqtd-lj + 1.
end.
/*
if vqtd-lj > 1
then do:
    run rateio-cria-titulo.
end.
*/
bl-princ:
repeat :
    disp esqcom1 with frame f-com1.
    disp esqcom2 with frame f-com2.
    pause 0.
    if recatu1 = ?
    then
        find first titulo use-index titdtven
                    where titulo.empcod   = 19 and
            titulo.titnat   = vtitnat       and
            titulo.modcod   = vmodcod       and
            titulo.etbcod   = vetbcod       and
            titulo.clifor   = vclifor       and
            titulo.titbanpag = vsetcod NO-LOCK no-error.
    else find titulo where recid(titulo) = recatu1 NO-LOCK.
    vinicio = no.
    if not available titulo
    then do:
        /*
        message "Cadastro de Titulos Vazio".
        message "Deseja Incluir ?" update sresp.
        if not sresp then leave bl-princ.
        */
        run inclusao.
        if keyfunction(lastkey) = "END-ERROR"
        THEN leave bl-princ.
        vinicio = yes.
        next.
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
        titulo.titvlpag when titulo.titvlpag > 0 format "->>,>>9.99"
                                            column-label "Valor Pago"
        titulo.titvljur column-label "Juros" format ">,>>9.9"
        titulo.titvldes column-label "Desc"  format ">>,>>9.9"
        titulo.titsit column-label "S" format "X"
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
                               titulo.titbanpag = vsetcod NO-LOCK no-error.
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
                titulo.titvljur
                titulo.titvldes format "->>,>>9.99"
                titulo.titsit 
                v-agendado with frame frame-a.
        pause 0.
    end.
    up frame-line(frame-a) - 1 with frame frame-a.
    repeat with frame frame-a:
        find titulo where recid(titulo) = recatu1 NO-LOCK.
        color display messages titulo.titnum titulo.titpar.
        pause 0.
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
            vdt = data-util.
            update vdt validate(vdt >= data-util and
                        weekday(vdt) <> 7 and
                        weekday(vdt) <> 1,"Data invalida")
                label "Vencimento".
                
            find first titulo where titulo.empcod   = wempre.empcod and
                                    titulo.titnat   = vtitnat       and
                                    titulo.modcod   = vmodcod       and
                                    titulo.etbcod   = vetbcod       and
                                    titulo.clifor   = vclifor       and
                                    titulo.titdtven >= vdt          and
                                    titulo.titbanpag = vsetcod NO-LOCK no-error.
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
                                 titulo.titbanpag = vsetcod NO-LOCK no-error.
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
                                 titulo.titbanpag = vsetcod NO-LOCK no-error.
                    if avail titulo
                    then recatu1 = recid(titulo).
                    else recatu1 = ?.
                end.    
            end.   
            leave.
        end. 
        
        if keyfunction(lastkey) = "TAB"
        then do:
            if esqregua
            then do:
                color display normal esqcom1[esqpos1] with frame f-com1.
                color display message esqcom2[esqpos2] with frame f-com2.
            end.
            else do:
                color display normal esqcom2[esqpos2] with frame f-com2.
                color display message esqcom1[esqpos1] with frame f-com1.
            end.
            esqregua = not esqregua.
        end.
        if keyfunction(lastkey) = "cursor-right"
        then do:
            if esqregua
            then do:
                color display normal esqcom1[esqpos1] with frame f-com1.
                esqpos1 = if esqpos1 = 5 then 5 else esqpos1 + 1.
                color display messages esqcom1[esqpos1] with frame f-com1.
            end.
            else do:
                color display normal esqcom2[esqpos2] with frame f-com2.
                esqpos2 = if esqpos2 = 3 then 3 else esqpos2 + 1.
                color display messages esqcom2[esqpos2] with frame f-com2.
            end.
            next.
        end.
        if keyfunction(lastkey) = "cursor-left"
        then do:
            if esqregua
            then do:
                color display normal esqcom1[esqpos1] with frame f-com1.
                esqpos1 = if esqpos1 = 1 then 1 else esqpos1 - 1.
                color display messages esqcom1[esqpos1] with frame f-com1.
            end.
            else do:
                color display normal esqcom2[esqpos2] with frame f-com2.
                esqpos2 = if esqpos2 = 1 then 1 else esqpos2 - 1.
                color display messages esqcom2[esqpos2] with frame f-com2.
            end.
            next.
        end.
        if keyfunction(lastkey) = "cursor-down"
        then do:
            find next titulo use-index titdtven
                             where titulo.empcod   = wempre.empcod and
                                   titulo.titnat   = vtitnat       and
                                   titulo.modcod   = vmodcod       and
                                   titulo.etbcod   = vetbcod   and
                                   titulo.clifor   = vclifor  and
                                   titulo.titbanpag = vsetcod NO-LOCK no-error.
            if not avail titulo
            then next.
            color display normal titulo.titnum titulo.titpar.
            if frame-line(frame-a) = frame-down(frame-a)
            then scroll with frame frame-a.
            else down with frame frame-a.
        end.
        if  keyfunction(lastkey) = "cursor-up"
        then do:
            find prev titulo use-index titdtven
                             where titulo.empcod   = wempre.empcod and
                                   titulo.titnat   = vtitnat       and
                                   titulo.modcod   = vmodcod       and
                                   titulo.etbcod   = vetbcod       and
                                   titulo.clifor   = vclifor and
                                   titulo.titbanpag = vsetcod NO-LOCK no-error.
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
          if esqcom2[esqpos2] <> "Pagamento/Cancelamento" or
             esqcom2[esqpos2] <> "Bloqueio/Liberacao"
          then hide frame frame-a no-pause.
          /*
          display vcliforlab at 6 vclifornom
                with frame frame-b 1 down centered color blue/gray
                width 81 no-box no-label row 5 overlay.
            */
          if esqregua
          then do:
            if esqcom1[esqpos1] = "Inclusao"
            then do:
                run inclusao.
                leave.
            end.
            if esqcom1[esqpos1] = "Alteracao"
            then do ON ERROR UNDO with frame ftitulo:
                hide frame f-senha no-pause.
                hide frame f-fre2 no-pause.
                find current titulo exclusive.

                disp titulo.clifor column-label "Fornecedor"
                       titulo.titnum
                       titulo.titpar
                       titulo.titdtemi
                       titulo.titdtven 
                       titulo.titvlcob
                       titulo.cobcod .
                       
                 /***
                vtitvlcob = titulo.titvlcob .
                titulo.datexp = today.
                update titulo.clifor column-label "Fornecedor"
                       titulo.titnum
                       titulo.titpar
                       titulo.titdtemi
                       titulo.titdtven 
                        validate(titulo.titdtven >= data-util and
                        weekday(titulo.titdtven) <> 7 and
                        weekday(titulo.titdtven) <> 1,"Data invalida")
                       titulo.titvlcob
                       titulo.cobcod with no-validate.
                find fin.cobra where cobra.cobcod = titulo.cobcod NO-LOCK.
                display cobra.cobnom.
                if cobra.cobban
                then do with frame fbanco:
                    update titulo.bancod.
                    find banco where banco.bancod = titulo.bancod NO-LOCK.
                    display banco.bandesc .
                    update titulo.agecod.
                    find agenc of banco where agenc.agecod = titulo.agecod
                               NO-LOCK.
                    display agedesc.
                end.
                update titulo.modcod colon 15.
                find fin.modal where modal.modcod = titulo.modcod no-lock.
                display modal.modnom no-label.
                update titulo.evecod colon 15.
                find fin.event where event.evecod = titulo.evecod no-lock.
                display event.evenom no-label.
                update titulo.titvljur with frame fjurdes .
                update titulo.titdtdes with frame fjurdes.
                update titulo.titvldes format ">>>,>>9.99"
                        with frame fjurdes no-validate.
                */
                update text(titulo.titobs) with frame fobs.
                /*
                if titulo.titvlcob <> vtitvlcob
                then do:
                    if titulo.titvlcob < vtitvlcob
                    then do:
                    assign sresp = yes.
                    display "  Confirma GERACAO DE NOVO TITULO ?"
                                with frame fGERT color messages
                                width 60 overlay row 10 centered.
                    update sresp no-label with frame fGERT.
                    if sresp
                    then do:
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
                                  ctitulo.titvlcob = vtitvlcob - titulo.titvlcob
                                   ctitulo.titnumger = titulo.titnum
                                   ctitulo.titparger = titulo.titpar
                                   ctitulo.datexp    = today.
                            display ctitulo.titnum
                                    ctitulo.titpar
                                    ctitulo.titdtemi
                                    ctitulo.titdtven
                                    ctitulo.titvlcob
                                    with frame fmos width 40 1 column
                                              title " Titulo Gerado " overlay
                                              centered row 10.
                            recatu1 = recid(ctitulo).
                            if ctitulo.modcod = "LIK" 
                            then run pi-vincula-circui.
                            leave.
                        end.
                     end.
                     else do:
                        display "  Confirma AUMENTO NO VALOR DO TITULO?"
                                with frame faum color messages
                                width 60 overlay row 10 centered.
                        update sresp no-label with frame faum.
                        if not sresp then undo, leave.
                    end.
                end.
                message "Confirma Titulo" update sresp.
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
                */
            end.

            if esqcom1[esqpos1] = "Consulta" or
               esqcom1[esqpos1] = "Exclusao"
            then do:
                find fin.modal of titulo no-lock no-error.
                disp titulo.modcod
                     modal.modnom when available modal no-label
                     titulo.titnum
                     titulo.titpar
                     titulo.titdtemi
                     titulo.titdtven
                     titulo.titvlcob
                     titulo.cobcod with frame ftitulo.

                disp titulo.titvljur
                     titulo.titjuro
                     titulo.titdtdes
                     titulo.titvldes
                     titulo.titdtpag
                     titulo.titvlpag with frame fjurdes.

                disp titulo.titobs[1] label "Obs. " format "x(70)"
                     titulo.titobs[2] no-label at 5 format "x(70)"
                     with frame f-obs side-label row 19
                     width 80 color message no-box
                     overlay.
                pause.     
 
            end.
            if esqcom1[esqpos1] = "Exclusao"
            then do ON ERROR UNDO
                with frame f-exclui overlay row 6 1 column centered.
                if titulo.titsit = "CON" or
                   titulo.titsit = "PAG"
                then do:
                    message "Titulo nao pode ser excluido". pause.
                    undo, retry.
                end.
                
                
                message "Confirma Exclusao da Despesa"
                            titulo.titnum .
                update sresp.
                if not sresp
                then leave.
             
                run exclui-titulo.
                
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
            if esqcom2[esqpos2] = "Pagamento/Cancelamento"
            then 
              if titulo.titsit = "LIB" or titulo.titsit = "IMP" or
                 titulo.titsit = "CON"
              then do ON ERROR UNDO
                   with frame f-Paga overlay row 6 1 column centered.
                 find current titulo.
                 display titulo.titnum    colon 13
                        titulo.titpar    colon 33 label "Pr"
                        titulo.titdtemi  colon 13
                        titulo.titdtven  colon 13
                        titulo.titvlcob  colon 13 label "Vl.Cobr."
                        titulo.titvljur  colon 13 label "Vl.Juro"
                        titulo.titvldes  format ">>>,>>9.99"
                                colon 13 label "Vl.Desc"
                        with frame fdadpg side-label
                        overlay row 6 color white/cyan width 40
                        title " Titulo ".
                 titulo.datexp = today.
               if titulo.modcod = "CRE"
               then do:
                   {titpagb4.i}
                   update titulo.titvljur  colon 13 label "Vl.Juro"
                          titulo.titvldes  colon 13 label "Vl.Desc"
                                format ">>>,>>9.99"
                                            with frame fdadpg side-label
                                    overlay row 6 color white/cyan width 40
                                          title " Titulo " no-validate.
               end.
               else do:
                   hide frame lanca no-pause.
                   assign titulo.titdtpag = today.
                   display titulo.titdtdes colon 13 label "Dt.Desc"
                           titulo.titvldes colon 13 label "Vl.Desc"
                                           format ">>>,>>9.99"
                           titulo.titvljur colon 13 label "Vl.Juro"
                                      with frame fdadpg.
                   update titulo.titdtpag with frame fpag1.
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
                update titulo.titvlpag with frame fpag1.
                update titulo.cobcod with frame fpag1.
                update titulo.titvljur column-label "Juros"
                       titulo.titvldes format ">>>,>>9.99"
                            with frame fpag1 no-validate.
                
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
                    hide frame f-obs no-pause.

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
                        then lancxa.comhis = titulo.titnum + " " + forne.fornom.
                        
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
                                    ctitulo.titvlcob
                                    with frame fmos width 40 1 column
                                              title " Titulo Gerado " overlay
                                              centered row 10.
                        end.
                        else titulo.titdesc = titulo.titvlcob - titulo.titvlpag.
                end.
                assign titulo.titsit = "PAG".
                {ctb01.i}
               end.
               recatu1 = recid(titulo).
               leave.
              end.
              else
                if titulo.titsit = "PAG"
                then do on error undo:
                    find current titulo.
                    display titulo.titnum
                        titulo.titpar
                        titulo.titdtemi
                        titulo.titdtven
                        titulo.titvlcob
                        titulo.cobcod with frame ftitulo.
                    titulo.datexp = today.
                    titulo.cxmdat = ?.
                    titulo.cxacod = 0.
                    display titulo.titdtpag titulo.titvlpag titulo.cobcod
                            with frame fpag1.
                    message "Pagemento ja efetuado !" skip 
                            "Confirma o Cancelamento do Pagamento ?"
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
                        display "Verifique Titulo Gerado do Pagamento Parcial"
                                with frame fver color messages
                                width 50 overlay row 10 centered.
                            pause.
                        end.
                   end.
                   recatu1 = recid(titulo).
                   next bl-princ.
                end.
            if esqcom2[esqpos2] = "Bloqueio/Liberacao" and
               titulo.titsit    <> "PAG"
            then do on error undo:
                if titulo.titsit <> "BLO"
                then do:
                    message "Confirma o Bloqueio do Titulo ?" update sresp.
                    if  sresp then do:
                        find current titulo.
                        titulo.titsit = "BLO".
                        titulo.datexp = today.
                    end.
                end.
                else
                    if titulo.titsit = "BLO"
                    then do:
                        message "Confirma a Liberacao do Titulo ?" update sresp.
                        if  sresp then do:
                            find current titulo.
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
                titulo.titvlcob
                titulo.titdtven
                titulo.titdtpag
                titulo.titvlpag when titulo.titvlpag > 0
                titulo.titvljur
                titulo.titvldes
                titulo.titsit 
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
    def buffer btitulo for banfin.titulo.
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
    disp qtd-titag   label "Titulos"
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
         vl-total  to 35 label "   Valor  Atual" 
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
        then do ON ERROR UNDO:
            find current titulo.
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
end procedure.

procedure rateio-cria-titulo:
    def var vok as log.
    def var vetb like estab.etbcod.
    def var vtot-tit as dec.
    def var vdtini as date.
    def var vdtfin as date.
    def var vtotmodal as dec.
    
    find first tt-nfser.
    
    assign
        vtitpar = tt-nfser.qtd-par
        vtitnum = string(tt-nfser.documento)
        vtitdtemi = tt-nfser.inclusao
        vtotal = tt-nfser.val-liq
        .
        
    disp "                DADOS PARA RATEIO *** " +
            STRING(VQTD-LJ) +
            " FILIAIS SELECIONADAS      "
            format "x(80)"
    WITH frame f-rat width 80 color message
              no-box no-label 1 down.
    do on error undo with frame frtit2 centered side-label 1 column:
        assign
            vok = yes
            vtitpar = tt-nfser.qtd-par
            vtitnum = string(tt-nfser.documento)
            vtitdtemi = tt-nfser.inclusao
            vtotal = tt-nfser.val-liq
            .
        for each tt-lj no-lock:
            find first btitulo where btitulo.empcod   = wempre.empcod and
                                         btitulo.titnat   = vtitnat       and
                                         btitulo.modcod   = vmodcod       and
                                         btitulo.etbcod   = tt-lj.etbcod  and
                                         btitulo.clifor   = vclifor       and
                                         btitulo.titnum   = vtitnum       and
                                         btitulo.titpar   = vtitpar
                               NO-LOCK no-error.
            if avail btitulo
            then do:
                find first btitudesp where 
                           btitudesp.empcod   = wempre.empcod and
                           btitudesp.titnat   = vtitnat       and
                           btitudesp.modcod   = vmodcod       and
                           btitudesp.etbcod   = tt-lj.etbcod  and
                           btitudesp.clifor   = vclifor       and
                           btitudesp.titnum   = vtitnum       and
                           btitudesp.titpar   = vtitpar and
                           btitudesp.titbanpag = vsetcod
                           NO-LOCK no-error.
                if avail btitudesp
                then do:
                    vok = no.
                    vetb = tt-lj.etbcod.
                    leave.
                end.
            end.
        end.    
        if vok = no
        then do:
                message "Titulo ja Existe para FILIAL " VETB.
                PAUSE.
                undo, retry.
        end.

        vvenc = data-util.
        disp vtitdtemi
             vvenc
             vtotal.
        update  
               vvenc validate(vvenc >= data-util and
                        weekday(vvenc) <> 7 and
                        weekday(vvenc) <> 1,
                            "Data invalida") label "Vencimento" 
                .
        /*
        update text(vtitobs) with frame fobs2. pause 0.
        */
        sresp = no.
        message "Confirma Rateio de R$" string(vtotal,">>,>>>,>>9.99")
         " ?" update sresp.
        if not sresp
        then undo.
        
        hide frame fobs2 no-pause.
        vtot-tit = 0.
        for each tt-lj no-lock:
            create tt-titudesp.
            assign 
                tt-titudesp.exportado = yes
                tt-titudesp.empcod = 19
                tt-titudesp.titsit = "LPA"
                tt-titudesp.titnat = vtitnat
                tt-titudesp.modcod = vmodcod
                tt-titudesp.etbcod = tt-lj.etbcod
                tt-titudesp.datexp = today
                tt-titudesp.clifor = vclifor
                tt-titudesp.titnum = vtitnum
                tt-titudesp.titpar  = 1
                tt-titudesp.titdtemi = vtitdtemi
                tt-titudesp.titdtven = vvenc
                tt-titudesp.titvlcob = vtotal / vqtd-lj
                tt-titudesp.titbanpag = vsetcod
                tt-titudesp.titobs[1] = vtitobs[1]
                tt-titudesp.titobs[2] = vtitobs[2].

            vtot-tit = vtot-tit + tt-titudesp.titvlcob.
        end.
        if vtot-tit <> vtotal
        then do:
            for each tt-lj:
                find first tt-titudesp where
                           tt-titudesp.etbcod = tt-lj.etbcod and
                           tt-titudesp.titnum = vtitnum and
                           tt-titudesp.clifor = vclifor
                           no-error.
                if avail tt-titudesp
                then do:
                    tt-titudesp.titvlcob = tt-titudesp.titvlcob + 
                                    (vtotal - vtot-tit).
                    leave.
                end.           
            end. 
            
        end.
    end.
end procedure.

Procedure pi-vincula-circui.
          /*
def var vnumcircui like titcircui.ncircuito.

find first titcircui where titcircui.empcod    = titulo.empcod and
                           titcircui.etbcod    = titulo.etbcod and
                           titcircui.modcod    = titulo.modcod and
                           titcircui.titnum    = titulo.titnum and
                           titcircui.titpar    = titulo.titpar no-lock no-error.
if avail titcircui then leave.

message "Informe N.Circuito ou F4: " update vnumcircui.

find first titcircui where titcircui.empcod    = titulo.empcod and
                           titcircui.etbcod    = 0 and
                           titcircui.ncircuito = vnumcircui and
                           titcircui.titnum    = "0" and
                           titcircui.titpar    =  0 no-error.
if not avail titcircui 
then do:
       message "Circuito Inexistente" view-as alert-box.
       undo, retry.
end.
find last titcircui exclusive.
create titcircui.
assign titcircui.empcod    = titulo.empcod
       titcircui.etbcod    = titulo.etbcod
       titcircui.titnat    = yes
       titcircui.modcod    = titulo.modcod
       titcircui.ncircuito = vnumcircui
       titcircui.clifor    = titulo.clifor
       titcircui.titnum    = titulo.titnum
       titcircui.parcela   = titulo.titpar.
            */
end procedure.

Procedure pi-elimina-titcircui.
              /*
def input parameter p-recatu1 as recid.

find first btitulo where recid(btitulo) = p-recatu1 no-lock no-error.

for each titcircui where titcircui.titnum = titulo.titnum:
    delete titcircui.
end.
                */
end procedure.

procedure inclusao.

    def var vdtini    as date.
    def var vdtfin    as date.
    def var vtotmodal as dec.

    do on error undo:
        run dd-nfser.

    end.
    if keyfunction(lastkey) = "END-ERROR"
    then return.
    sresp = no.
    message "Deseja incluir observação?" update sresp.
    if sresp
    then do:
        run informa-obs.
    end.
    if fatudesp.situacao = "A"
    then do:
        sresp = yes.
        message "Deseja emitir relatorio da despesa?" update sresp.
        if sresp
        then do:
            run relatorio.
        end.
    end.
end procedure.

procedure informa-obs:
    def var vobs like titulo.titobs.
    
    update vobs no-label
            WITH FRAME F-titobs 1 down row 16 title " OBSERVAÇÃO ".
            
    if vobs[1] <> "" or
       vobs[2] <> ""
    then do :         
        for each titulo where
             titulo.empcod = 19 and
             titulo.clifor = fatudesp.clicod and
             titulo.titnum = string(fatudesp.fatnum) and
             titulo.titdtemi = fatudesp.inclusao
             :
                     
            titulo.titobs = vobs.
        end.
        for each titudesp where
             titudesp.empcod = 19 and
             titudesp.clifor = fatudesp.clicod and
             titudesp.titnum = string(fatudesp.fatnum) and
             titudesp.titdtemi = fatudesp.inclusao
             :
            titudesp.titobs = vobs.
        end. 
        for each tituctb where
             tituctb.empcod = 19 and
             tituctb.clifor = fatudesp.clicod and
             tituctb.titnum = string(fatudesp.fatnum) and
             tituctb.titdtemi = fatudesp.inclusao
             :
                     
            tituctb.titobs = vobs.
        end.
    
    end.         
end procedure.


procedure relatorio:
    /*
    def var vdata as date.
    def var vdti  as date.
    def var vdtf  as date.
    def var vsetcod like setaut.setcod.
    def var vetbcod like estab.etbcod.
    def var vforcod like forne.forcod.
    def var vfatnum like fatudesp.fatnum format ">>>>>>>>9".
    */

    def var vtotal-tit as dec.
    
    def var vetbfun as int.
    def var vfuncod as int.
    def var varquivo as char.

    varquivo = "/admcom/relat/infds010." + string(time).

    {mdad.i &Saida     = "value(varquivo)" 
                        &Page-Size = "0" 
                        &Cond-Var  = "80" 
                        &Page-Line = "0" 
                        &Nom-Rel   = ""tablan"" 
                        &Nom-Sis   = """SISTEMA CONTABILIDADE""" 
                        &Tit-Rel   = """LISTAGEM DESPESAS SETOR"""
                        &Width     = "80"  
                        &Form      = "frame f-cabcab"}
                        .
 
    for each fatudesp where 
         /*fatudesp.setcod = vsetcod and
         fatudesp.etbcod = vetbcod and*/
         fatudesp.clicod = vforcod and
         int(fatudesp.fatnum) = int(vfatnum) 
         no-lock:

        find forne where forne.forcod = fatudesp.clicod no-lock.    
        find fin.modal where modal.modcod = fatudesp.modcod no-lock. 
    
        vetbfun = int(acha("FILIAL", fatudesp.char1)).
        vfuncod = int(acha("FUNC", fatudesp.char1)). 
        
        find first func where 
                   func.etbcod = vetbfun and
                   func.funcod = vfuncod
                   no-lock no-error.
        disp fill("=",80) format "x(80)"
         fatudesp.etbcod to 40 label "Filial"
         fatudesp.setcod to 40
         func.funcod to 40 when avail func
         func.funnom no-label when avail func
         fatudesp.modcod to 40 label "Modalidade FIN"
         fatudesp.modctb to 40 label "Modalidade CTB"
         fatudesp.fatnum  to 40
         fatudesp.clicod  to 40
         forne.fornom    no-label
         forne.forcgc     to 50 label "CNPJ/CPF" format "x(20)"
         fatudesp.emissao   to 40
         fatudesp.inclusao  to 40 label "Data Inclusao"
         fatudesp.val-total to 40 label "Valor Total"
         fatudesp.val-icms  to 40 label "Valor ICMS"
         fatudesp.val-ipi   to 40 label "Valor IPI"
         fatudesp.val-acr   to 40 label "Valor Acrescimo"
         fatudesp.val-des   to 40 label "Valor Desconto"
         fatudesp.val-ir    to 40 label "Valor IRRF"
         fatudesp.val-iss   to 40 label "Valor ISS" 
         fatudesp.val-inss  to 40 label "Valor INSS"
         fatudesp.val-pis   to 40 label "Valor PIS" 
         fatudesp.val-cofins to 40 label "Valor COFINS"
         fatudesp.val-csll   to 40  label "Valor CSLL"
         fatudesp.val-liquido to 40 label "Valor Liquido" 
         fatudesp.qtd-parcela to 40 label "Quantidade Parcelas"
         with frame f-disp  side-label
         width 100
             .
        
        for each tituctb where
             tituctb.clifor = fatudesp.clicod and
             tituctb.titnum = string(int(fatudesp.fatnum)) and
             tituctb.titdtemi = fatudesp.inclusao
             no-lock:
            disp tituctb.titnum
                         tituctb.titdtemi
                         tituctb.titdtven
                         tituctb.modcod
                         tituctb.titvlcob  format ">,>>>,>>9.99"
                         tituctb.etbcod column-label "Fil"
                         tituctb.titbanpag column-label "Set"
                    with frame ftit-tctb width 100 down
                    .
                    down with frame ftit-tctb.
        end.
    
        put skip(3).
 
        vtotal-tit = 0.
        for each titulo where
             titulo.empcod = 19 and
             /*titulo.titnat = yes and
             titulo.modcod = fatudesp.modcod and
             titulo.etbcod = fatudesp.etbcod and*/
             titulo.clifor = fatudesp.clicod and
             titulo.titnum = string(fatudesp.fatnum) and
             titulo.titdtemi = fatudesp.inclusao
             no-lock break by titulo.titnum by titulo.titpar:

             vtotal-tit = vtotal-tit + titulo.titvlcob.
            
            if last-of(titulo.titpar)
            then do:  
                for each titudesp where
                         titudesp.clifor = fatudesp.clicod and
                         titudesp.titnum = string(fatudesp.fatnum) and
                         titudesp.titpar = titulo.titpar
                         no-lock:
                    disp titudesp.titnum
                         titudesp.titpar
                         titudesp.titdtemi
                         titudesp.titdtven
                         titudesp.modcod
                         titudesp.titvlcob  format ">,>>>,>>9.99"
                    with frame ftit-t width 100 down
                    .
                    down with frame ftit-t.
            
                end.
                vtotal-tit = 0.
            end.
        end.         
    end.             
    /*
    put skip(60).
    page.
    */
    put skip(10).
    put skip(5).
    for each fatudesp where 
         /*fatudesp.setcod = vsetcod  and
         fatudesp.etbcod = vetbcod  and*/
         fatudesp.clicod = vforcod  and
         int(fatudesp.fatnum) = int(vfatnum) 
         no-lock:
        
        find forne where forne.forcod = fatudesp.clicod no-lock.    
        find modal where modal.modcod = fatudesp.modcod no-lock. 
        
        vetbfun = int(acha("FILIAL", fatudesp.char1)).
        vfuncod = int(acha("FUNC", fatudesp.char1)). 
        find first func where 
                   func.etbcod = vetbfun and
                   func.funcod = vfuncod
                   no-lock no-error.
        
        vtotal-tit = 0.
        
        for each titulo where
             titulo.empcod = 19 and
             /*titulo.titnat = yes and
             titulo.modcod = fatudesp.modcod and
             titulo.etbcod = fatudesp.etbcod and*/
             titulo.clifor = fatudesp.clicod and
             titulo.titnum = string(fatudesp .fatnum) and
             titulo.titdtemi = fatudesp.inclusao
             no-lock break by titulo.titnum by titulo.titpar:
             
             vtotal-tit = vtotal-tit + titulo.titvlcob.
             
             if last-of(titulo.titpar)
             then do:
                disp 
                fatudesp.etbcod at 1 label "Filial"
                fatudesp.setcod
                func.funcod when avail func
                func.funnom no-label when avail func
                fatudesp.modcod
                modal.modnom no-label 
                fatudesp.fatnum
                fatudesp.clicod
                forne.fornom    no-label
                forne.forcgc     
                fatudesp.emissao   
                fatudesp.inclusao  
                with frame f-disp1  side-label
                width 100
                .
                disp titulo.titnum
                    titulo.titpar
                    titulo.titdtemi
                    titulo.titdtven
                    vtotal-tit  format ">,>>>,>>9.99"
                     with frame ftit1 width 100 down
                 .
                down with frame ftit1.
                vtotal-tit = 0.
                put skip(10).
            end.
        end.         
    end.  
    OUTPUT CLOSE.
    run visurel.p(varquivo,"").
 
end procedure.

procedure p-verifica-senha:

    def input  parameter ipsenha  as character.
/*    def input  parameter ipprocod as integer.*/
    def output parameter opresp   as logical init no.
    
    find first tabaux where tabaux.Tabela = 
                                string(setbcod) + string(vsetcod) + (vmodcod)
                            no-lock no-error.
    if not avail tabaux
    then do:
        message "Entre em contato com o financeiro e solicite uma senha.".
        return.
    end.
    
    if tabaux.Valor_Campo <> ipsenha
    then do:
        message "Senha incorreta, digite novamente.".
        return.
    end.
    
    if tabaux.datexp < today - 1
    then do:
        message "Senha expirada, Solicite uma nova senha".
        return.
    end.
    
    assign opresp = yes.

end procedure.

procedure dd-nfser:
    def var vtot-tit as dec.
    def var t-impostos as log init no.
    def var v-extra as log.
    for each tt-nfser: delete tt-nfser. end.
    create tt-nfser.
    tt-nfser.inclusao = today.
    disp tt-nfser.documento 
         tt-nfser.emissao
         tt-nfser.val-total  format ">>>>>>>>9.99" label "Val. Documento"
         tt-nfser.val-icms   format ">>>>>>>>9.99"
         tt-nfser.val-ipi    format ">>>>>>>>9.99"
         tt-nfser.val-acr    format ">>>>>>>>9.99"
         tt-nfser.val-des    format ">>>>>>>>9.99"
         tt-nfser.val-iR     format ">>>>>>>>9.99"
         tt-nfser.val-iss    format ">>>>>>>>9.99"
         tt-nfser.val-inss   format ">>>>>>>>9.99"
         tt-nfser.val-pis    format ">>>>>>>>9.99"
         tt-nfser.val-cofins format ">>>>>>>>9.99"
         tt-nfser.val-csll   format ">>>>>>>>9.99"
         tt-nfser.val-liq    format ">>>>>>>>9.99" label "Val. Liquido"
         tt-nfser.qtd-par
         with frame f-doc 1 down side-label 1 column
         row 5 title " " + vsel-sit1[vtipo-documento] + " "
         .

    repeat on endkey undo, return:
        update tt-nfser.documento 
           tt-nfser.emissao
           with frame f-doc.
           
        find first fatudesp where 
            /*fatudesp.etbcod = vetbcod and*/
            fatudesp.fatnum = int(tt-nfser.documento) and
            fatudesp.clicod = vclifor
            no-error.
        if avail fatudesp
        then do:
            find first titulo where
                       titulo.clifor = fatudesp.clicod and
                       titulo.titnum = string(int(fatudesp.fatnum))
                       no-lock no-error.
            if avail titulo and fatudesp.situacao <> "P"
            then do:
                bell.
                message color red/with
                "Documento ja existe com"
                " Filial " fatudesp.etbcod
                " Fornecedor " fatudesp.clicod
                " Documento " fatudesp.fatnum
                view-as alert-box.
                return.
            end.           
            assign         
                tt-nfser.inclusao   = fatudesp.inclusao
                tt-nfser.val-icms   = fatudesp.val-icms
                tt-nfser.val-ipi    = fatudesp.val-ipi
                tt-nfser.val-acr    = fatudesp.val-acr
                tt-nfser.val-des    = fatudesp.val-des
                tt-nfser.val-total  = fatudesp.val-total 
                tt-nfser.val-ir     = fatudesp.val-ir
                tt-nfser.val-iss    = fatudesp.val-iss
                tt-nfser.val-inss   = fatudesp.val-inss
                tt-nfser.val-pis    = fatudesp.val-pis
                tt-nfser.val-cofins = fatudesp.val-cofins
                tt-nfser.val-csll   = fatudesp.val-csll
                tt-nfser.val-liq    = fatudesp.val-liquido
                tt-nfser.qtd-par    = fatudesp.qtd-parcela
                tt-nfser.situacao   = fatudesp.situacao
                .
            
            disp
                tt-nfser.val-total
                tt-nfser.val-icms
                tt-nfser.val-ipi
                tt-nfser.val-acr
                tt-nfser.val-des
                tt-nfser.val-iR    
                tt-nfser.val-iss
                tt-nfser.val-inss
                tt-nfser.val-pis
                tt-nfser.val-cofins
                tt-nfser.val-csll
                tt-nfser.val-liq
                tt-nfser.qtd-par
                with frame f-doc 
                       .
        
            if tt-nfser.qtd-par = 0
            then update tt-nfser.qtd-par with frame f-doc.
        end.
        else do:
            
            find first titulo where
                       titulo.clifor = fatudesp.clicod and
                       titulo.titnum = string(int(tt-nfser.documento))
                       no-lock no-error.
            if avail titulo 
            then do:
                bell.
                message color red/with
                "Documento ja existe com Numero " tt-nfser.documento
                view-as alert-box.
                return.
            end. 
            
            update tt-nfser.val-total 
                tt-nfser.val-icms
                tt-nfser.val-ipi
                tt-nfser.val-acr
                tt-nfser.val-des
                tt-nfser.val-iR    
                tt-nfser.val-iss
                tt-nfser.val-inss
                tt-nfser.val-pis
                tt-nfser.val-cofins
                tt-nfser.val-csll
                tt-nfser.val-liq
                with frame f-doc.
        
            update tt-nfser.qtd-par with frame f-doc.
        end.
        
        if tt-nfser.val-liq <> (tt-nfser.val-total - (tt-nfser.val-iR +
            tt-nfser.val-iss + tt-nfser.val-inss + tt-nfser.val-pis +
            tt-nfser.val-cofins + tt-nfser.val-csll + tt-nfser.val-des)
            + tt-nfser.val-acr)
        THEN DO:
            bell.
            message color red/with
                "Valor liquido diverge de valor total menos impostos"
                .
            pause.
        END.  
        else do:
            for each tt-titudesp: delete tt-titudesp. end.
            if tt-nfser.situacao = "P"
            then do:
                run gera-titulo-parcial.
            end.
            else 
            if vqtd-lj > 1
            then do:
                run rateio-cria-titulo.
            end.    
            else do:
                sresp = no.
                message "Lançamento parcial?" update sresp.
                if sresp
                then do:
                    run gera-titulo-parcial.
                    tt-nfser.situacao = "P".
                end.
                else do:
                    run gera-titulo.
                end.
            end.
            
            hide frame f-par no-pause.
            clear frame f-par all.
            if keyfunction(lastkey) = "end-error"
            then.
            else leave.   
        end.
    end.
    message "Gravando dados AGUARDE...".
    PAUSE 0.
    find first tt-nfser where
               tt-nfser.documento <> 0 no-error.
    if avail tt-nfser
    then do on error undo:
        find first fatudesp where
                   /*fatudesp.etbcod = vetbcod and*/
                   fatudesp.clicod = vclifor and
                   fatudesp.fatnum = int(tt-nfser.documento)
                   no-error.
        if not avail fatudesp
        then do:
            create fatudesp.
            assign
                fatudesp.etbcod     = vetbcod
                fatudesp.fatnum     = int(tt-nfser.documento)
                fatudesp.clicod     = vclifor
                fatudesp.situacao   = "F" 
                fatudesp.setcod = vsetcod
                fatudesp.modcod = vmodcod
                fatudesp.modctb = vmod-ctb
                .

        end.
        assign
            fatudesp.emissao    = tt-nfser.emissao
            fatudesp.inclusao   = tt-nfser.inclusao
            fatudesp.val-total  = tt-nfser.val-total
            fatudesp.val-icms   = tt-nfser.val-icms
            fatudesp.val-ipi    = tt-nfser.val-ipi
            fatudesp.val-acr    = tt-nfser.val-acr
            fatudesp.val-des    = tt-nfser.val-des
            fatudesp.val-ir     = tt-nfser.val-ir
            fatudesp.val-iss    = tt-nfser.val-iss 
            fatudesp.val-inss   = tt-nfser.val-inss
            fatudesp.val-pis    = tt-nfser.val-pis 
            fatudesp.val-cofins = tt-nfser.val-cofins
            fatudesp.val-csll   = tt-nfser.val-csll
            fatudesp.val-liquido = tt-nfser.val-liq 
            fatudesp.qtd-parcela = tt-nfser.qtd-par
            fatudesp.situacao    = tt-nfser.situacao
            fatudesp.char1 = "FILIAL=" + string(setbcod,"999") +
                             "|FUNC=" + string(sfuncod,"9999999999")
                             .
           
        vfatnum = fatudesp.fatnum.
        v-extra = no.
        vtot-tit = 0.
        for each tt-titudesp where
                 tt-titudesp.titnum = string(int(fatudesp.fatnum))
                 :
               
            tt-titudesp.titsit = "LIB".
            
            create titudesp.
            buffer-copy tt-titudesp to titudesp.
            
            find first titulo where 
                       titulo.empcod = wempre.empcod and
                       titulo.titnat = vtitnat         and
                       titulo.modcod = fatudesp.modcod and
                       titulo.etbcod = fatudesp.etbcod and
                       titulo.clifor = fatudesp.clicod       and
                       titulo.titnum = string(int(fatudesp.fatnum)) and
                       titulo.titpar = titudesp.titpar
                        no-error.
            if not avail titulo
            then do:
                create titulo.
                buffer-copy titudesp to titulo.

                create wtit.
                assign wtit.wrec = recid(titulo).
                if titulo.modcod = "LIK"
                then run pi-vincula-circui.

                if month(titulo.titdtemi) <> month(titulo.titdtven)
                then v-extra = yes.
                vtot-tit =  vtot-tit + titulo.titvlcob .
            end.
            else do:
                assign
                    titulo.titvlcob = 
                        titulo.titvlcob + titudesp.titvlcob
                    vtot-tit =  vtot-tit + titudesp.titvlcob .    
                        . 
                
            end.
            find first tituctb where 
                       tituctb.empcod = wempre.empcod and
                       tituctb.titnat = vtitnat         and
                       tituctb.modcod = vmod-ctb and
                       tituctb.etbcod = fatudesp.etbcod and
                       tituctb.clifor = fatudesp.clicod       and
                       tituctb.titnum = string(int(fatudesp.fatnum)) and
                       tituctb.titpar = titudesp.titpar
                        no-error.
            if not avail tituctb
            then do:
                create tituctb.
                buffer-copy titudesp to tituctb.
                tituctb.modcod = vmod-ctb.
            end.
            else  tituctb.titvlcob = 
                        tituctb.titvlcob + titudesp.titvlcob  .
             
            
        end.
        
        if fatudesp.situacao = "P"
        then do:
            vtot-tit = 0.
            for each btitulo where 
                     btitulo.clifor = vclifor       and
                     btitulo.titnum = vtitnum       and
                     btitulo.titsit = "LPA"
                     no-lock:
                vtot-tit =  vtot-tit + btitulo.titvlcob .         
            end.
            if fatudesp.val-liq = vtot-tit
            then do:
                for each btitulo where 
                     btitulo.clifor = vclifor       and
                     btitulo.titnum = vtitnum       and
                     btitulo.titsit = "LPA"
                     :
                     btitulo.titsit = "LIB".
                end.
                for each btitudesp where 
                     btitudesp.clifor = vclifor       and
                     btitudesp.titnum = vtitnum       and
                     btitudesp.titsit = "LPA"
                     :
                     btitudesp.titsit = "LIB".
                end.
            end.
        end.

        if fatudesp.val-liq = vtot-tit
        then do:
            fatudesp.situacao = "F".
        
            find forne where forne.forcod = fatudesp.clicod no-lock.
            vcompl = string(int(fatudesp.fatnum)) + " " +
                    forne.fornom.
            find first  lancactb where
                                lancactb.id = 0  and
                                lancactb.etbcod = 0 and
                                lancactb.forcod = 0 and
                                lancactb.modcod = vmod-ctb
                                no-lock no-error.
 
            for each tt-lancxa: delete tt-lancxa. end.
        
 
            t-impostos = no.

            /*** Nao gera extra-caixa para LP
            if fatudesp.val-ir > 0
            then do:
                run lan-contabil("EXTRA-CAIXA",lancactb.contadeb,"93",
                    vmod-ctb,today,fatudesp.val-ir, "101262",fatudesp.fatnum,
                    vetbcod,"331",vcompl).
                     t-impostos = yes.                        
            end.
            if fatudesp.val-iss > 0
            then do:
                run lan-contabil("EXTRA-CAIXA",lancactb.contadeb,"40",
                        vmod-ctb,today,fatudesp.val-iss,
                              "100655",fatudesp.fatnum,vetbcod,"371"
                              ,vcompl).
                t-impostos = yes.
            end.
            if fatudesp.val-inss > 0
            then do:
                run lan-contabil("EXTRA-CAIXA",lancactb.contadeb,"102",
                        vmod-ctb,today,fatudesp.val-inss,
                              "104093",fatudesp.fatnum,vetbcod,"373",vcompl).
                t-impostos = yes.
            end.
            if fatudesp.val-pis > 0
            then do:
                run lan-contabil("EXTRA-CAIXA",lancactb.contadeb,"101",
                        vmod-ctb,today,fatudesp.val-pis,
                              "103632",fatudesp.fatnum,vetbcod,"374",vcompl).
                t-impostos = yes.
            end.
            if fatudesp.val-cofins > 0
            then do:
                run lan-contabil("EXTRA-CAIXA",lancactb.contadeb,"101",
                    vmod-ctb,today,fatudesp.val-cofins,
                              "103632",fatudesp.fatnum,vetbcod,"374",vcompl).
                t-impostos = yes.
            end.
            if fatudesp.val-csll > 0
            then do:
                run lan-contabil("EXTRA-CAIXA",lancactb.contadeb,"101",
                               vmod-ctb,today,fatudesp.val-csll,
                              "103632",fatudesp.fatnum,vetbcod,"374",vcompl).
                t-impostos = yes.
            end.
            if fatudesp.val-des > 0
            then do:
                run lan-contabil("EXTRA-CAIXA",lancactb.contadeb,"235",
                               vmod-ctb,today,fatudesp.val-des,
                        fatudesp.clicod,fatudesp.fatnum,vetbcod,"12",vcompl).
                t-impostos = yes.
            end.
            if fatudesp.val-acr > 0
            then do:
                run lan-contabil("EXTRA-CAIXA",lancactb.contadeb,"228",
                               vmod-ctb,today,fatudesp.val-acr,
                        fatudesp.clicod,fatudesp.fatnum,vetbcod,"13",vcompl).
                t-impostos = yes.
            end.

            if vtitnat = yes and (v-extra or t-impostos)
            then do:
 
                run  lan-contabil ("EXTRA-CAIXA",lancactb.contadeb,
                            lancactb.contacre,vmod-ctb,today,fatudesp.val-liq,
                   fatudesp.clicod,int(fatudesp.fatnum),fatudesp.etbcod,
                              lancactb.int1,vcompl).
 
            end.
            ****/
            
        end.
    end.
end.  

procedure gera-titulo:

    def var vdtini as date.
    def var vdtfin as date.
    def var vtotmodal as dec.
    
    find first tt-nfser.
    
    assign
        vtitpar = tt-nfser.qtd-par
        vtitnum = string(tt-nfser.documento)
        vtitdtemi = tt-nfser.inclusao
        vtotal = tt-nfser.val-liq
        .
        
    repeat:
        
        find first btitulo where btitulo.empcod = wempre.empcod and
                                 btitulo.titnat = vtitnat       and
                                 btitulo.modcod = vmodcod       and
                                 btitulo.etbcod = vetbcod       and
                                 btitulo.clifor = vclifor       and
                                 btitulo.titnum = vtitnum       and
                                 btitulo.titpar = vtitpar
                           NO-LOCK no-error.
        if avail btitulo
        then do:
            find first btitudesp where btitudesp.empcod = wempre.empcod and
                                     btitudesp.titnat = vtitnat       and
                                     btitudesp.modcod = vmodcod       and
                                     btitudesp.etbcod = vetbcod       and
                                     btitudesp.clifor = vclifor       and
                                     btitudesp.titnum = vtitnum       and
                                     btitudesp.titpar = vtitpar       and
                                     btitudesp.titbanpag = vsetcod
                                     NO-LOCK no-error.
            if avail btitudesp
            then do:                         
                message "Titulo ja Existe".
                pause.
                return.
            end.
        end.
        
        i = 0.
        ii = 0.
        vt = 0.
        vtot = 0.
        do i = 1 to vtitpar with frame f-par 9 down column 35 row 8
                    title " Parcelas ":
            vdia = 0.
            display i column-label "Par" with frame f-par.
            vvenc = data-util.
            update vvenc validate(vvenc >= data-util and
                        weekday(vvenc) <> 7 and
                        weekday(vvenc) <> 1,"Data invalida")
                                                with frame f-par.

            vtitvlcob = (vtotal - vt) / (vtitpar - ii).
            
            do on error undo:
                
                update vtitvlcob format ">>>,>>>,>>9.99"
                                with frame f-par.
                vt = vt + vtitvlcob.
                if vt <> vtotal and ii = vtitpar
                then do:
                    message "Valor das prestacoes nao confere com o total".
                    undo, retry.
                end.

                /*** Controle de metas ***/
                vdtini = date(month(vvenc), 1, year(vvenc)).
                vdtfin = date(if month(vvenc) = 12
                              then 1 else month(vvenc) + 1,
                              1,
                              if month(vvenc) = 12
                              then year(vvenc) + 1 else year(vvenc) ) - 1.
                vtotmodal = 0.
                find metadesp where metadesp.etbcod = vetbcod
                                and metadesp.setcod = vsetcod
                                and metadesp.modgru = ""
                                and metadesp.modcod = vmodcod
                                and metadesp.metano = year(vvenc)
                                and metadesp.metmes = month(vvenc)
                             no-lock no-error.
                if avail metadesp
                then do.
                    for each btitulo where btitulo.empcod = wempre.empcod
                                       and btitulo.titnat = vtitnat
                                       and btitulo.modcod = vmodcod
                                       and btitulo.etbcod = vetbcod
                                       and btitulo.titdtven >= vdtini
                                       and btitulo.titdtven <= vdtfin
                                     no-lock.  
                        vtotmodal = vtotmodal + btitulo.titvlcob.
                    end.
                    if vtotmodal + vtitvlcob > metadesp.metval * 0.9
                    then do.
                        /* retirado pela corretiva 429032
                        vsenha = "".
                        message "Meta atingida em mais de 90%. " 
                                "Solicite uma senha ao setor Financeiro".
                        update vsenha format "x(25)" no-label
                                     with frame f-inf-senha centered overlay
                                     row 12 title "Informe a senha" width 30.
                        sresp = no.
                        run p-verifica-senha (input vsenha,
                                              output sresp).
                        if not sresp
                        then undo, retry.
                        */
                    end.
                end.
            end.
            do on error undo:
            
                create tt-titudesp.
                assign tt-titudesp.exportado = yes
                   tt-titudesp.empcod = wempre.empcod
                   tt-titudesp.titsit = "BLO"
                   tt-titudesp.titnat = vtitnat
                   tt-titudesp.modcod = vmodcod
                   tt-titudesp.etbcod = vetbcod
                   tt-titudesp.datexp = today
                   tt-titudesp.clifor = vclifor
                   tt-titudesp.titnum = vtitnum
                   tt-titudesp.titpar = i
                   tt-titudesp.titdtemi = vtitdtemi
                   tt-titudesp.titdtven = vvenc
                   tt-titudesp.titvlcob = vtitvlcob
                   tt-titudesp.titbanpag = vsetcod
                   ii = ii + 1.
            
                
            end.
            vtot = vtot + tt-titudesp.titvlcob.
            down with frame f-par.
        end.
        hide frame f-par no-pause.
        leave.
    end.
    hide frame f-par no-pause.       
 
 end procedure.
 
 procedure lan-contabil:
    def input parameter l-tipo as char.
    def input parameter l-landeb like lancactb.contadeb.
    def input parameter l-lancre like lancactb.contacre.
    def input parameter l-modcod like lancxa.modcod.
    def input parameter l-datlan as date.
    def input parameter l-vallan as dec.
    def input parameter l-forcod like titulo.clifor.
    def input parameter l-titnum like titulo.titnum.
    def input parameter l-etbcod like estab.etbcod.
    def input parameter l-hiscod as char.
    def input parameter l-hiscomp as char.

    if l-tipo = "CAIXA"
    THEN
    do on error undo:
    
            find first lancxa where 
                       lancxa.datlan = l-datlan and
                       lancxa.cxacod = l-landeb and
                       lancxa.lancod = l-lancre and
                       lancxa.modcod = l-modcod and
                       lancxa.vallan = l-vallan and
                       lancxa.forcod = l-forcod and
                       lancxa.titnum = l-titnum and
                       lancxa.lantip = "C"
                        no-error.
            if not avail lancxa
            then do:            
            
            find last blancxa use-index ind-1
                where blancxa.numlan <> ? no-lock no-error.
            if not avail blancxa
            then vnumlan = 1.
            else vnumlan = blancxa.numlan + 1.
            
            create lancxa.
            assign lancxa.cxacod = l-landeb
                   lancxa.datlan = l-datlan
                   lancxa.lancod = l-lancre
                   lancxa.modcod = l-modcod
                   lancxa.numlan = vnumlan
                   lancxa.vallan = l-vallan
                   lancxa.comhis = l-hiscomp
                   lancxa.lantip = "C"
                   lancxa.forcod = l-forcod
                   lancxa.titnum = l-titnum
                   lancxa.etbcod = l-etbcod
                   lancxa.lanhis = int(l-hiscod).
            end.                    
    end.
    else if l-tipo = "EXTRA-CAIXA"
    THEN
    DO ON ERROR UNDO:
            
            find first lancxa where 
                       lancxa.datlan = l-datlan and
                       lancxa.cxacod = l-landeb and
                       lancxa.lancod = l-lancre and
                       lancxa.modcod = l-modcod and
                       lancxa.vallan = l-vallan and
                       lancxa.forcod = l-forcod and
                       lancxa.titnum = l-titnum and
                       lancxa.lantip = "X"
                        no-error.
            if not avail lancxa
            then do: 
            find last blancxa use-index ind-1
                where blancxa.numlan <> ? no-lock no-error.
            if not avail blancxa
            then vnumlan = 1.
            else vnumlan = blancxa.numlan + 1.
             
                create lancxa.
                assign
                    lancxa.numlan = blancxa.numlan + 1
                    lancxa.lansit = "F"
                    lancxa.datlan = l-datlan
                    lancxa.cxacod = l-landeb
                    lancxa.lancod = l-lancre
                    lancxa.modcod = l-modcod
                    lancxa.vallan = l-vallan
                    lancxa.lanhis = int(l-hiscod)
                    lancxa.forcod = l-forcod
                    lancxa.titnum = l-titnum
                    lancxa.etbcod = l-etbcod
                    lancxa.lantip = "X"
                    lancxa.livre1 = "" 
                    lancxa.comhis = l-hiscomp 
                    .
            end.
       end.
 end procedure.
 
 procedure exclui-titulo:
    def buffer btitulo for banfin.titulo.
    find first fatudesp where  
               int(fatudesp.fatnum) = int(titulo.titnum) and
               fatudesp.clicod = titulo.clifor
                              no-error.

    if not avail fatudesp
    then do:
                  /*
                message "Confirma Exclusao de Titulo"
                            titulo.titnum ",Parcela" titulo.titpar
                update sresp.
                if not sresp
                then leave.
                */
                
                find next titulo use-index titdtven
                                 where titulo.empcod   = wempre.empcod and
                                       titulo.titnat   = vtitnat       and
                                       titulo.modcod   = vmodcod       and
                                       titulo.etbcod   = vetbcod       and
                                       titulo.clifor   = vclifor
                                 NO-LOCK no-error.
                if not available titulo
                then do:
                    find titulo where recid(titulo) = recatu1 NO-LOCK.
                    find prev titulo use-index titdtven
                                     where titulo.empcod   = wempre.empcod and
                                           titulo.titnat   = vtitnat       and
                                           titulo.modcod   = vmodcod       and
                                           titulo.etbcod   = vetbcod       and
                                           titulo.clifor   = vclifor
                                     NO-LOCK no-error.
                end.
                recatu2 = if available titulo
                          then recid(titulo)
                          else ?.
                
                find titulo where recid(titulo) = recatu1.
                {ctb02.i}
                
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
                    message "Nao Excluiu lancamento na contabilidade".
                    pause.
                end.
                run pi-elimina-titcircui(input recatu1).
                delete titulo.
                recatu1 = recatu2.
                hide frame fitulo no-pause.
    end.    
    else do:
        for each titulo where
                 titulo.empcod = 19 and
                 titulo.titnat = yes and
                 titulo.clifor = fatudesp.clicod and
                 titulo.titnum = string(int(fatudesp.fatnum)) and
                 titulo.titdtemi = fatudesp.inclusao
                 :

                {ctb02.i}
                
                /*****
                deletou-lancxa = no.
                for each lancxa where lancxa.datlan = titulo.titdtemi and
                                      lancxa.titnum = titulo.titnum   and
                                      lancxa.modcod = fatudesp.vmodctb and
                                      lancxa.etbcod = fatudesp.etbcod
                                      :
                    delete lancxa.
                    deletou-lancxa = yes.
                end.
                if deletou-lancxa = no
                then do:
                    message "Nao Excluiu lancamento na contabilidade".
                    pause.
                end.
                *****/
                run pi-elimina-titcircui(recid(titulo)).
                delete titulo.
                recatu1 = recatu2.
                hide frame fitulo no-pause.
        end.
        for each titudesp where
                 titudesp.clifor = fatudesp.clicod and
                 titudesp.titnum = string(int(fatudesp.fatnum))
                 :
        
                delete titudesp.
        end.

        deletou-lancxa = no.
        for each lancxa where 
                 lancxa.datlan = fatudesp.inclusao and
                 lancxa.titnum = string(int(fatudesp.fatnum))    and
                 lancxa.modcod = fatudesp.modctb :
            delete lancxa.
            deletou-lancxa = yes.
        end.
        
        delete fatudesp.

        if deletou-lancxa = no
        then do:
            message color red/with
                "Nao Excluiu lancamento na contabilidade"
                view-as alert-box.
        end.

    end.    
 
 end procedure.
 
procedure gera-titulo-parcial:

    def var vdtini as date.
    def var vdtfin as date.
    def var vtotmodal as dec.
    def var par-etbcod like estab.etbcod.
    def var par-setcod like setor.setcod.
    def var par-modcod like fin.modal.modcod.
    def var q-par like titulo.titpar.
    def var val-parcial as dec format ">>>,>>9.99".
    find first tt-nfser.

    def var v-tt  as dec.
    
    assign
        vtitpar = tt-nfser.qtd-par
        vtitnum = string(tt-nfser.documento)
        vtitdtemi = tt-nfser.inclusao
        vtotal = tt-nfser.val-liq
        par-setcod = vsetcod
        par-modcod = vmodcod
        .

    disp par-setcod
         par-modcod
         vtitpar
         val-parcial
         with frame f-par0 1 down no-box color message row 5
         column 35.
         
         .
    pause 0.
    update val-parcial with frame f-par0.
    
    do on error undo:
        for each tt-titudesp:
            delete tt-titudesp.
        end.
        q-par = 0.
        v-tt = 0.
        clear frame f-par1 all.
            
    repeat  with frame f-par1 9 down column 35 row 8
                    title " Parcial ":
    
        q-par = q-par + 1.
        
        vtitvlcob = val-parcial / vtitpar.
        
        vvenc = data-util.
        disp 
            par-setcod
            par-modcod
            q-par
            vvenc
            vtitvlcob
            .

        update
            vvenc validate(vvenc >= data-util and
                        weekday(vvenc) <> 7 and
                        weekday(vvenc) <> 1,"Data invalida")
            vtitvlcob
            .
            
        find first btitulo where btitulo.empcod = wempre.empcod and
                                 btitulo.titnat = vtitnat       and
                                 btitulo.modcod = par-modcod    and
                                 btitulo.etbcod = vetbcod       and
                                 btitulo.clifor = vclifor       and
                                 btitulo.titnum = vtitnum       and
                                 btitulo.titpar = q-par   
                           NO-LOCK no-error.
        if avail btitulo
        then do:
            find first btitudesp where btitudesp.empcod = wempre.empcod and
                                     btitudesp.titnat = vtitnat       and
                                     btitudesp.modcod = par-modcod    and
                                     btitudesp.etbcod = vetbcod       and
                                     btitudesp.clifor = vclifor       and
                                     btitudesp.titnum = vtitnum       and
                                     btitudesp.titpar = q-par         and
                                     btitudesp.titbanpag = par-setcod
                                     no-lock no-error.
            if avail btitudesp
            then do:                          
                message "Titulo ja Existe".
                pause.
                undo.
            end.
        end.

     
                /*** controle de metas ***/
                
                vdtini = date(month(vvenc), 1, year(vvenc)).
                vdtfin = date(if month(vvenc) = 12
                              then 1 else month(vvenc) + 1,
                              1,
                              if month(vvenc) = 12
                              then year(vvenc) + 1 else year(vvenc) ) - 1.
                vtotmodal = 0.
                find metadesp where metadesp.etbcod = vetbcod
                                and metadesp.setcod = par-setcod
                                and metadesp.modgru = ""
                                and metadesp.modcod = par-modcod
                                and metadesp.metano = year(vvenc)
                                and metadesp.metmes = month(vvenc)
                             no-lock no-error.
                if avail metadesp
                then do.
                    for each btitulo where btitulo.empcod = wempre.empcod
                                       and btitulo.titnat = vtitnat
                                       and btitulo.modcod = par-modcod
                                       and btitulo.etbcod = vetbcod
                                       and btitulo.titdtven >= vdtini
                                       and btitulo.titdtven <= vdtfin
                                     no-lock.  
                        vtotmodal = vtotmodal + btitulo.titvlcob.
                    end.
                    if vtotmodal + vtitvlcob > metadesp.metval * 0.9
                    then do.
                        /*
                        vsenha = "".
                        message "Meta atingida em mais de 90%. " 
                                "Solicite uma senha ao setor Financeiro".
                        update vsenha format "x(25)" no-label
                                     with frame f-inf-senha centered overlay
                                     row 12 title "Informe a senha" width 30.
                        sresp = no.
                        run p-verifica-senha (input vsenha,
                                              output sresp).
                        if not sresp
                        then undo, retry.
                        */
                    end.
                end.
                do on error undo:
                    create tt-titudesp.
                    assign tt-titudesp.exportado = yes
                        tt-titudesp.empcod = wempre.empcod
                        tt-titudesp.titsit = "LPA"
                        tt-titudesp.titnat = vtitnat
                        tt-titudesp.modcod = par-modcod
                        tt-titudesp.etbcod = vetbcod
                        tt-titudesp.datexp = today
                        tt-titudesp.clifor = vclifor
                        tt-titudesp.titnum = vtitnum
                        tt-titudesp.titpar = q-par
                        tt-titudesp.titdtemi = vtitdtemi
                        tt-titudesp.titdtven = vvenc
                        tt-titudesp.titvlcob = vtitvlcob
                        tt-titudesp.titbanpag = par-setcod
                   .
            end.
            v-tt = v-tt + tt-titudesp.titvlcob.
            down with frame f-par1.
            if q-par = vtitpar
            then leave.
        end.
      
        if v-tt = val-parcial
        then vtot = vtot + v-tt.
        else do:
            message color red-with
            "Total parcelado" v-tt "difere de total parcial" val-parcial
            view-as alert-box.
            undo.
        end.
    
    end.
    hide frame f-par1 no-pause.       
end procedure.
