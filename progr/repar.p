/***
#1-TP33066562 - marcação tpcontrato
***/

{admcab.i}
define buffer wcontrato for contrato.
define variable wpar as integer format ">9" label "Num.Parcelas".
define variable wcon as integer format ">9" label "Parc.".
define variable wval as decimal format ">>>,>>>,>>9.99".
define variable rsp as logical format "Sim/Nao" initial yes.

def var vano as int.
def var vmes as int.
def var vdata   like plani.pladat.
def var vetbcod like estab.etbcod .
def var vday    as   int format "99".
def var i       as   int .
def var vvaltit like titulo.titvlcob.
def var vtitdtven as date.
def var vdia-aux as int.

l0:
repeat:
    assign wpar = 0.
    do with frame f1:
        do with width 80 frame f1 title " Cliente " side-label:
            prompt-for clien.clicod colon 13 validate(true,"").
            find clien using clien.clicod no-error.
            if not avail clien
            then do:
                sresp = no.
                message "Cliente nao Cadastrado. Cadastrar ?" update sresp.
                if sresp = no
                then next.
                run clien.p.
                next.
            end.
            display clien.clinom no-label.
            if clien.situacao = no
            then do:
                message "Cliente inativo, efetivacao de Contrato negada.".
                undo,retry.
            end.

        prompt-for contrato.contnum colon 13.
        find numcont where numcont.contnum = input contrato.contnum no-error.
        if avail numcont
        then do:
            if numcont.numsit
            then do:
                bell.
                message "Numero de Contrato ja Existe".
            end.
            numcont.numsit = yes.
            numcont.datexp = today.
        end.
        create contrato.
        assign contrato.contnum.
            assign contrato.clicod    = clien.clicod
                   contrato.dtinicial = vdata
                   contrato.etbcod    = vetbcod
                   contrato.datexp    = today
                   contrato.banco     = 99.
            update contrato.dtinicial colon 13 format "99/99/9999"
                   contrato.etbcod    colon 13.
            assign vdata   = contrato.dtinicial
                   vetbcod = contrato.etbcod.
            if month(contrato.dtinicial) <> month(today) and
               day(contrato.dtinicial) < 5
            then do:
                bell. bell. bell.
                message "Mes Digitado Difere do Mes Atual" .
                pause 2 no-message.
            end.
        end.
        do with 1 column width 39 frame f2 title " Valores " on error undo:
            update vltotal skip(1).
            update vlentra skip(1).
            display
                vltotal - vlentra label "Valor liquido" format ">>>,>>>,>>9.99".
            update skip(1)
                   wpar validate(wpar > 0,"Numero de Parcelas nao deve ser 0")
                    help "Informe o Numero de Parcelas do Contrato.".
            if vlentra > 0
            then do:
                create titulo.
                assign titulo.empcod = wempre.empcod
                       titulo.modcod = "CRE"
                       titulo.cliFOR = contrato.clicod
                       titulo.titnum = string(contrato.contnum)
                       titulo.titpar = 0
                       titulo.titsit = "PAG"
                       titulo.titnat = no
                       titulo.etbcod = contrato.etbcod
                       titulo.etbcobra = contrato.etbcod
                       titulo.titdtemi = contrato.dtinicial
                       titulo.titdtven = titulo.titdtemi
                       titulo.titdtpag = titulo.titdtemi
                       titulo.titvlcob = contrato.vlentra
                       titulo.titvlpag = contrato.vlentra
                       titulo.cobcod   = 2
                       titulo.datexp   = today
               /*#1*/  titulo.tpcontrato = "N".
            end.
        end.
    end.
    assign wcon = /*51*/ 31
           wval = 0.
    repeat with column 41 width 40 frame f3 5 down title " Parcelas "
            on endkey undo l0,retry l0:
        clear frame f3 all.
        create titulo.
        assign titulo.empcod   = wempre.empcod
               titulo.modcod   = "CRE"
               titulo.cliFOR   = contrato.clicod
               titulo.titnum   = string(contrato.contnum)
               titulo.titpar   = wcon
               titulo.titnat   = no
               titulo.etbcod   = contrato.etbcod
               titulo.titdtemi = contrato.dtinicial
               titulo.cobcod   = 2
               titulo.titsit   = "LIB"
               titulo.datexp   = today
               /*#1*/  titulo.tpcontrato = "N".

        display wcon            column-label "PC"
                titulo.titdtemi column-label "Emissao".
        update  titulo.titdtven column-label "Vencimento"
                validate(titulo.titdtven <= contrato.dtinicial + 45,
                         "Data de Vencimento Invalida").
        if titulo.titdtven < contrato.dtinicial
        then do:
            message "Data de vencimento invalida".
            undo.
        end.
        update titulo.titvlcob format ">,>>>,>>9.99" column-label "Vl.Cob".
        if titulo.titvlcob >= contrato.vltotal and
           wpar > 1
        then do:
            message "Valor da Parcela e' maior que o Total do Contrato".
            undo.
        end.
        assign wval = wval + titulo.titvlcob
               vday = day(titulo.titdtven)

        vtitdtven = titulo.titdtven.
        vdia-aux  = 0. 
        /**/
        vmes = month (titulo.titdtven) + 1.
        vano = year (titulo.titdtven).
        if vday = 31
        then
            vday = day(date(vmes,01,vano) - 1).

        if vmes = 13
        then assign vano = vano + 1
                    vmes = 1 .
        do i = 2 to wpar .
            wcon = wcon + 1.
            create titulo.
            assign
                titulo.empcod = wempre.empcod
                titulo.modcod = "CRE"
                titulo.cliFOR = contrato.clicod
                titulo.titnum = string(contrato.contnum)
                titulo.titpar = wcon
                titulo.titnat = no
                titulo.etbcod = contrato.etbcod
                titulo.titdtemi = contrato.dtinicial
                /*#1*/  titulo.tpcontrato = "N".
            
            run data-vencimento.
            titulo.titdtven = vtitdtven.
            
            /**
            if vday = 31
            then
                assign
                    titulo.titdtven = date(vmes + 1,01,vano) - 1.
            else
                assign
                    titulo.titdtven = date(vmes,
                                       IF VMES = 2
                                       THEN IF VDAY > 28
                                            THEN 28
                                            ELSE VDAY
                                        ELSE VDAY,
                                       vano).
            **/
            assign
                titulo.titvlcob = (contrato.vltotal -
                                   contrato.vlentra - wval) /
                                   (wpar - i + 1)
                titulo.cobcod = 2
                titulo.titsit = "LIB"
                titulo.datexp = today.
            down with frame f3.
            display /*i @*/ wcon column-label "PC"
                    titulo.titdtemi column-label "Emissao"
                    titulo.titdtven column-label "Vencimento"
                    titulo.titvlcob format ">,>>>,>>9.99" column-label "Vl.Cob".
            if i = 2
            then do:
                vvaltit = titulo.titvlcob.
                titulo.titvlcob = 0.
                do on error undo:
                    update titulo.titvlcob.
                    if titulo.titvlcob <> vvaltit
                    then do:
                        bell.
                        message "Valor Digitado na Segunda Parcela Invalido".
                        undo.
                    end.
                end.
            end.
            down with frame f3.
            assign wval = wval + titulo.titvlcob.
                   vmes = vmes + 1.
                   if vmes = 13
                   then assign vano = vano + 1
                               vmes = 1.
         end.


        if wval = contrato.vltotal - contrato.vlentra
        then leave.
        if wval > contrato.vltotal - contrato.vlentra
        then do:
            message "Valor das Parcelas ultrapassa valor do Saldo liquido.".
            undo,retry.
        end.
        if wcon = wpar and wval <> contrato.vltotal - contrato.vlentra
        then do:
            message "Valor das Parcelas nao confere com Saldo liquido.".
            undo,retry.
        end.
    end.
    pause 0.
    repeat with column 52 width 29 5 down frame f5 title " Notas Fiscais "
            on endkey undo l0, retry l0:

        prompt-for contnf.notanum contnf.notaser.
        if input contnf.notanum <> 0
        then do:
            create contnf.
            assign contnf.contnum = contrato.contnum
                   contnf.notanum = input contnf.notanum
                   contnf.notaser = input contnf.notaser.
        end.
        else leave.
    end.

    /*** Cria flag ***/

    find first flag where flag.clicod = clien.clicod no-error.
    if avail flag 
    then do:
        if flag.flag1 = no
        then do: 
            flag.flag1 = yes.
            flag.datexp1 = today.
        end.
    end.
    else do:
        create flag.
        flag.clicod  = clien.clicod.
        flag.flag1   = yes.
        flag.datexp1 = today.
    end.
    /*****************/
    
    message "Contrato " contrato.contnum " incluido.".
end.

procedure data-vencimento:
    def var vdia as int.
    def var vmes as int.
    def var vano as int.
    def var dias-mes as int extent 12
        init[31,28,31,30,31,30,31,31,30,31,30,31].
    
    assign
        vdia = day(vtitdtven)
        vmes = month(vtitdtven)
        vano = year(vtitdtven)
        .
    
    if vdia-aux > 0
    then vdia = vdia-aux.
    
    if vmes = 12
    then assign
             vmes = 1
             vano = vano + 1.
    else vmes = vmes + 1.
                
    if vmes = 2 and vdia > 28
    then do:
        vdia-aux = vdia.
        IF vano MOD 4 = 0 
        then vdia = 29. 
        else vdia = 28.
    end.
    else if vdia > 30 
        then do:
            vdia-aux = vdia.
            if dias-mes[vmes] = 30
            then vdia = 30.
        end.    

    vtitdtven = date(vmes,vdia,vano).

end.

