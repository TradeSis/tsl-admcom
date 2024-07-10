/*
#1 01.06.2017 Mudanca de regra
#2 07.07.2017 Revisao - Entrada estava com titdtpag = today
#3 26.07.2017 Alterada data default do titdtemi para 07/31/2016
#4 19.09.2017 Alterada data default do titdtemi para 08/31/2016
#5 06.11.2017 Alterada data default do titdtemi para 09/30/2016
#6 20.11.2017 Alterada data default do titdtemi para 10/31/2016
#7 01.12.2017 Alterado de 120 para 90 dias o parametro de dias para contratos do feriao nome limpo
#8 01.01.2018 Alterada data de validade do feirao de 01/01/18 para 01/01/19
#9 25.06.2018 Alterada data do feirao para 04/2017
#10 28.08.2018 Alterado de 120 para 90 dias o parametro de dias para contratos do feriao nome limpo
#11 19.11.2018 Incluido o plano 11 para todas as lojas - Black Friday Cobranca
#12 21.12.2018 Alterado para "FEIRAO-NOVO"
*/
{admcab.i}

hide message.

{dftempWG.i new}
def input parameter vclicod like clien.clicod.

def var vlibera-plano11 as char.
vlibera-plano11 = "01;02;03;04;05;06;07;08;09;10;11;12;13;14;15;16;17;18;19;20;21;22;23;24;25;26;27;28;29;30;31;32;33;34;35;36;37;38;39;40;41;42;43;44;45;46;47;48;49;50;51;52;53;54;55;56;57;58;59;60;61;62;63;64;65;66;67;68;69;70;71;72;73;74;75;76;77;78;79;80;81;82;83;84;85;86;87;88;89;90;91;92;93;94;95;96;97;98;99;100;101;102;103;104;105;105;107;108;109;110;111;112;113;114;115;116;117;118;119;120;121;122;123;124;125;126;127;128;129;130;131;132;133;134;135;136;137;138;139;140;141;142;143;144;145;146;147;148;149;150;151;152;153;154;155;156;157;158;159;160;161;162;163;164;165;301;302;303;304;305;306;307;189".
def temp-table tt-lib11
    field etbcod like estab.etbcod
    index i1 etbcod.
def var vc as int.
do vc = 1 to num-entries(vlibera-plano11,";"):
    if entry(vc,vlibera-plano11,";") <> ""
    then do:
        create tt-lib11.
        tt-lib11.etbcod = int(entry(vc,vlibera-plano11,";")).
    end.
end.
for each tt-lib11 where tt-lib11.etbcod = 0:
    delete tt-lib11.
end.    

def buffer novacordo for tp-novacordo.

def var recid-contrato as recid.

def var vtitobs as char.
def var vdesc-cpf as char.
def var vbanco as int.
def var juro-alt as dec.
def var vjuro-ori as dec.
def var vcond as char format "x(40)"  extent 11.
def var valor_cobrado as dec extent 11. 
def var valor_juro    as dec extent 11.
def var valor_acre    as dec extent 11.
def var valor_novacao as dec extent 11.
def var vok as log.
def var vtit as char format "x(30)". 
def var vv as int.
def var per_cor as dec.
def var nov31 as log.
def var vfeirao like sresp.

/***
def temp-table ttservidor
    field etbcod like estab.etbcod
    field servidor like estab.etbcod.
def buffer bttservidor for ttservidor.

def new shared temp-table tt-recib
        field rectit as recid
        field titnum like titulo.titnum
        field ordpre as int.

input from /usr/admcom/progr/servidor.txt.
    repeat :
        create ttservidor.
        import ttservidor.
    end.
input close.
***/

/* Seguro Prestamista */
def var vsegprocod like produ.procod init 0.
def var vsegvalor  as dec.
def var vsegdtivig as date.
def var vsegdtfvig as date.
def var vsegrecid  as recid.
def var vende-seguro as log.
def var par-valor as char.
def var par-feirao as log.

vende-seguro = no.
run lemestre.p (input "VENDE-SEGURO", output par-valor).     
vende-seguro = par-valor = "SIM".

par-valor = "".
run lemestre.p (input "FEIRAO-NOME-LIMPO", output par-valor).
par-feirao = par-valor = "SIM".

def var per_acr as dec.
def var per_des as dec.
def var vdia as int.
def var vdesc as dec.
def var vdata like plani.pladat.
def var ventrada like contrato.vlentra.
def var i as int.
def var vtot  like titulo.titvlcob.
def var vtitvlp like titulo.titvlcob.
def var vtitj like titulo.titvlcob.
def var vnumdia as i.
def var ljuros  as l.

def var vdata-futura as date format "99/99/9999".

def temp-table wf-tit like titulo.
def new shared temp-table wf-titulo like titulo.
def new shared temp-table wf-contrato like contrato.
def var vokj as log.
def var vplano as int format "99".
def var vgera like contrato.contnum.
def var wcon as int.
def var vday as int.
def var vmes as int.
def var vano as int.
def var vezes as int format ">9".
def var vdtven like titulo.titdtven.
def var lp-ok as log.
def var p4-semjuro as log.
def var vclifor like titulo.clifor.

def var vplano6 as log.
if setbcod = 34 or
   setbcod = 52 or
   setbcod = 80 or
   setbcod = 100 or
   setbcod = 101 or
   setbcod = 103 or
   setbcod = 104 or
   setbcod = 113 or
   setbcod = 130 or
   setbcod = 108 or
   setbcod = 189 or
   setbcod = 01 or
   setbcod = 23                  
then vplano6 = yes.
else vplano6 = no.   

if par-feirao /*and today < 01/01/2020 03.01.2020 helio retirado */
then do /*on error undo on endkey undo*/ :
    update vfeirao label "Feirão Nome Limpo Lebes?"
           with frame f-f side-label width 80 no-box
           row 6 15 down.
end.
else do:

    disp "" with frame f-f1 side-label width 80 no-box
               row 6 15 down.
    pause 0.
end.    
               
if keyfunction(lastkey) = "end-error"
then return.

def var vcont as int.

repeat:
    for each tp-titulo:
        delete tp-titulo.
    end.

    for each wf-titulo.
        delete wf-titulo.
    end.

    for each wf-tit.
        delete wf-tit.
    end.

    assign vtot    = 0
           vtitj   = 0
           vtitvlp = 0
           vtitobs = "".

    vdtven = today.
    vdata-futura = today.
            
    find clien where clien.clicod = vclicod no-lock no-error.
    if not avail clien
    then do:
        message "Cliente nao cadastrado".
        undo, retry.
    end.

    vclifor = vclicod.
    
    conecta-ok = no.
    run agil4_WG.p(input "novacao2", input vclifor).
    if conecta-ok = no
    then return.

    /*if vfeirao
    then*/ do:
    find first tp-cyber where tp-cyber.clicod   = clien.clicod and
                              tp-cyber.situacao = yes
                              no-lock no-error.
    if avail tp-cyber 
    then do.
        sretorno = "NOVACAO". 
        run cyber_acordo.i(input vclicod). 
        sretorno = "". 
    end.      

    for each novacordo where
        novacordo.clicod = vclicod and
        novacordo.situacao = "PENDENTE".
        find first tit_novacao where 
                   tit_novacao.tipo begins "RENEGOCIACAO"
               and tit_novacao.id_acordo = string(novacordo.id_acordo)
               no-lock no-error.
        if avail tit_novacao
        then novacordo.situacao = "EFETIVADO".       
                
    end.
        
    find last novacordo where
               novacordo.clicod = vclicod and
               novacordo.situacao = "PENDENTE"
               no-lock no-error.
    if avail novacordo and
        not can-find(first tit_novacao where 
                           tit_novacao.tipo begins "RENEGOCIACAO"
                    and tit_novacao.id_acordo = string(novacordo.id_acordo))
                
    then do:
        /*
        if setbcod = 13
        then. 
        else do on error undo:
            for each novacordo:
                novacordo.destino = 0.
            end.    
        end.*/
        run novacordo-filial.p(input vclicod, input "PENDENTE").
        return.
    end.
    end.
    
    update vdata-futura at 40 label "Data Futura"
           with frame f0 side-label width 80.
    
    hide frame f0 no-pause.

    if par-feirao /**and today < 01/01/2019 03.01.2020 helio **/
    then do:
        disp vfeirao label "Feirão Nome Limpo Lebes?"
           vdata-futura at 40 label "Data Futura"
           with frame f1 side-label width 80 no-box
           row 6 1 down.
        pause 0.
    end.
    else do:
        disp vdata-futura at 40 label "Data Futura"
           with frame f2 side-label width 80 no-box
           row 6 1 down.
        pause 0.
    end.
    vbanco = 10.
    
    for each tp-titulo where tp-titulo.modcod <> "CRE":
        delete tp-titulo.
    end.    
    for each tp-titulo:
        if tp-titulo.titsit = "PAG" or
           tp-titulo.titsit = "EXC" or
           (vfeirao and tp-titulo.titdtemi > 12/31/2017) or
           tp-titulo.titdtemi = today
        then delete tp-titulo.
        else do:
            if tp-titulo.cobcod = 10
            then vbanco = 10.
            find first tp-contrato where
                       tp-contrato.contnum = int(tp-titulo.titnum)
                       no-error.
            if not avail tp-contrato
            then do:            
                create tp-contrato.
                tp-contrato.clicod  = tp-titulo.clifor.
                tp-contrato.contnum = int(tp-titulo.titnum).
            end.
            
            if tp-titulo.titdtven > today - 30
            then vplano6 = no.
        end. 
    end.

    run sel-contrato.

    if keyfunction(lastkey) = "end-error"
    then leave.

    find first tp-contrato no-error.
    if not avail tp-contrato
    then leave.

    p4-semjuro = no.
    for each tp-titulo:
        find first tp-contrato where
                   tp-contrato.contnum = int(tp-titulo.titnum)
                and tp-contrato.exportado = yes   no-error.
        if not avail tp-contrato
        then delete tp-titulo.
        else if  (tp-titulo.etbcod = 100 or
                     tp-titulo.etbcod = 101) 
                and setbcod = tp-titulo.etbcod
        then p4-semjuro = yes. 
    end. 
                                  
    lp-ok = no.
    for each tp-titulo use-index dt-ven:
        if tp-titulo.titpar > 50 or
           tp-titulo.tpcontrato = "L"
        then lp-ok = yes.
        if tp-titulo.titdtven < vdtven
        then vdtven = tp-titulo.titdtven.        
    end.
    
    nov31 = no.
    vdia = (today - vdtven).
    vdia = (vdata-futura - vdtven).

    if vdia < 60 
    then do:
        if vdia < 30 or not vplano6
        then do:
        message "-- Cliente com " vdia " de atraso, operacao negada".
        pause.
        undo, retry.
        end.
    end.
    if not vfeirao 
    then do:
        /*** SEM Feirao ***/
    do vv = 1 to 6:
        if vv = 6 and not vplano6
        then next.
        
        vok = yes.
        
        assign per_acr = 0  
               per_des = 0  
               per_cor = 0  
               vtot    = 0 
               vtitj   = 0 
               vtitvlp = 0.
        
        vplano = vv.

        for each tp-titulo use-index dt-ven:     
            
            if vdata-futura > tp-titulo.titdtven
            then do:
                 ljuros = yes.

                if vdata-futura - tp-titulo.titdtven = 3
                then do:
                    find dtextra where exdata = vdata-futura - 3
                                 NO-LOCK no-error.
                    if weekday(vdata-futura - 3) = 1 or avail dtextra
                    then do:
                        find dtextra where exdata = vdata-futura - 1
                                     NO-LOCK no-error.
                        if weekday(vdata-futura - 1) = 1 or avail dtextra
                        then ljuros = no.
                    end.
                end.

                if vdata-futura - tp-titulo.titdtven = 2
                then do:
                    find dtextra where exdata = vdata-futura - 2
                                 NO-LOCK no-error.
                    if weekday(vdata-futura - 2) = 1 or avail dtextra
                    then do:
                        find dtextra where exdata = vdata-futura - 1
                                     NO-LOCK no-error.
                        if weekday(vdata-futura - 1) = 1 or avail dtextra
                        then ljuros = no.
                    end.
                end.
                else do:
                    if vdata-futura - tp-titulo.titdtven = 1
                    then do:
                        find dtextra where exdata = vdata-futura - 1
                                     NO-LOCK no-error.
                        if weekday(vdata-futura - 1) = 1 or avail dtextra
                        then ljuros = no.
                    end.
                end.
                vnumdia = if not ljuros
                          then 0
                          else vdata-futura - tp-titulo.titdtven.

                if vnumdia > 1766
                then vnumdia = 1766.

                find tabjur where tabjur.nrdias = vnumdia no-lock no-error.
                if not avail tabjur
                then do:
                    message "Fator para" vnumdia
                    "dias de atraso, nao cadastrado". pause. undo.
                end.
                assign vtot    = vtot    + tp-titulo.titvlcob
                       vtitvlp = vtitvlp + (tp-titulo.titvlcob * tabjur.fator). 
                
                /** arredondamento */
                def var dd like titulo.titvlcob.
                dd = ( (int(vtitvlp) -  
                                    vtitvlp) ) 
                                    - round(( (int(vtitvlp) - 
                                                  (vtitvlp)) ),1).
                        if dd < 0 
                        then dd = 0.10 - (dd * -1).

                        vtitvlp = vtitvlp + dd.
                /***/
                if tp-titulo.titpar > 30
                then 
            end.
            else do:
                /*if vdia <= 90 
                then. 
                else*/ do:   
                    vnumdia = tp-titulo.titdtven - today.
                    assign vtot    = vtot    + tp-titulo.titvlcob.   
                           vtitvlp = vtitvlp + tp-titulo.titvlcob.
                end.
            end.                    
        end.
        
        if vdia >= 30  and
           vdia <= 270  /*promocao 150*/ and
           lp-ok = no
        then nov31 = yes.
    
        vtitvlp = vtitvlp + (vtitvlp * per_acr).
    
        vtitj = vtitvlp - vtot.
 
        if vv = 1
        then vtit = "[ 1 ]  6  vezes(1+5) ".
        if vv = 2
        then vtit = "[ 2 ]  10 vezes(1+9) ".
        if vv = 3
        then vtit = "[ 3 ]  15 vezes(1+14)".
        if vv = 4
        then vtit = "[ 4 ]  20 vezes(1+19)".
        if vv = 5
        then vtit = "[ 5 ]  25 vezes(1+24)".
        if vv = 6
        then vtit = "[ 6 ]  10 vezes(1+9) ".
 
        if vok 
        then assign vcond[vv]         = vtit
                    valor_cobrado[vv] = vtot 
                    valor_juro[vv]    = vtitj  
                    valor_novacao[vv] = vtitvlp.
        else assign vcond[vv]         = vtit + " - NAO DISPONIVEL"   
                    valor_cobrado[vv] = 0
                    valor_juro[vv]    = 0
                    valor_novacao[vv] = 0.
    end.
    run cal-juro.

    display vdtven   label "Maior Atraso" 
            vdia     label "Dias de atraso" 
            with frame f-dias side-label centered. 
    pause.
    hide frame f-dias no-pause.

    display vcond[1] label "Plano" at 10 
            valor_cobrado[1]       at 17 label "Valor Cobrado...."
            valor_novacao[1]       at 17 label "Novacao Calculada" skip

            vcond[2] label "Plano" at 10 
            valor_novacao[2]       at 17 label "Novacao Calculada" skip 
            
            vcond[3] label "Plano" at 10 
            valor_novacao[3]       at 17 label "Novacao Calculada" skip 
            
            vcond[4] label "Plano" at 10 
            valor_novacao[4]       at 17 label "Novacao Calculada" skip
            
            vcond[5] label "Plano" at 10 
            valor_novacao[5]       at 17 label "Novacao Calculada"
                with frame f-plano side-label 
                    centered title " CONDICOES " width 80
                    row 6. 
     
    if vplano6
    then disp vcond[6] label "Plano" at 10 
            valor_novacao[6]  at 17 label "Novacao Calculada"
                with frame f-plano side-label.

    assign
        vjuro-ori = vtitj 
        vtitj = valor_juro[1]
        vtitj = vjuro-ori.
    
    disp vtitj with frame f-cond.   
    
    juro-alt = vtitj.     
    repeat :            
        update vtitj label "JURO" with frame f-cond .
        if vtitj = juro-alt
        then leave.

        if vtitj > vjuro-ori
        then do:
             message "Alteração no valor de juro não permitida." .
             pause.
             next.
        end.
        vokj = yes.
        if vdia >= 60 and
           vdia <= 360 and
           vtitj < vjuro-ori - (vjuro-ori * .33)
        then vokj = no.
        else if vdia >= 361 and
                vdia <= 600 and
                vtitj < vjuro-ori - (vjuro-ori * .66)
             then vokj = no.
             else if vdia > 600 and
                     vtitj < vjuro-ori / 20
                  then vokj = no.
         if vokj = no
         then do:
             message "Alteração no valor de juro não permitida.".
             pause.
             next.
         end.
         hide frame f-cond no-pause.
         do vv = 1 to 6:
            valor_juro[vv] = vtitj.
         end.
         juro-alt = vtitj.
         run cal-juro.
         display vcond[1] label "Plano" at 10 
            valor_cobrado[1]       at 17 label "Valor Cobrado...."
            valor_novacao[1]       at 17 label "Novacao Calculada" skip

            vcond[2] label "Plano" at 10 
            valor_novacao[2]       at 17 label "Novacao Calculada" skip 
            
            vcond[3] label "Plano" at 10 
            valor_novacao[3]       at 17 label "Novacao Calculada" skip 
            
            vcond[4] label "Plano" at 10 
            valor_novacao[4]       at 17 label "Novacao Calculada" skip
            
            vcond[5] label "Plano" at 10 
            valor_novacao[5]       at 17 label "Novacao Calculada"
                with frame f-plano side-label 
                    centered title " CONDICOES " width 80. 
        if vplano6
        then disp vcond[6] label "Plano" at 10 
            valor_novacao[6]       at 17 label "Novacao Calculada"
                with frame f-plano side-label .
    end.
    do on error undo, retry:
        vplano = 0.
        update vplano label "Plano" 
            with frame f-cond side-label centered no-box color message
            overlay.
            
        if vplano = 0 or
           vplano > 6 or
           valor_novacao[vplano] = 0
        then do: 
            message "Plano Invalido".
            undo, retry.
        end.
        display vcond[vplano] no-label with frame f-cond.
    end.                    
    
    hide frame f-plano no-pause.
    
    display vcond[1] label "Plano" at 10 
            valor_cobrado[1]       at 17 label "Valor Cobrado...."
            valor_novacao[1]       at 17 label "Novacao Calculada" skip

            vcond[2] label "Plano" at 10 
            valor_novacao[2]       at 17 label "Novacao Calculada" skip 
            
            vcond[3] label "Plano" at 10 
            valor_novacao[3]       at 17 label "Novacao Calculada" skip 
            
            vcond[4] label "Plano" at 10 
            valor_novacao[4]       at 17 label "Novacao Calculada" skip
            
            vcond[5] label "Plano" at 10 
            valor_novacao[5]       at 17 label "Novacao Calculada"
                with frame f-plano.
    
    if vplano6
    then disp vcond[6] label "Plano" at 10 
              valor_novacao[6]       at 17 label "Novacao Calculada"
                with frame f-plano.
        
    assign vtot    = valor_novacao[vplano]
           vtitj   = valor_juro[vplano]
           vtitvlp = valor_novacao[vplano].
                        
    if vplano = 1 
    then vezes = 6.  
    if vplano = 2  
    then vezes = 10.  
    if vplano = 3  
    then vezes = 15.  
    if vplano = 4  
    then vezes = 20.
    if vplano = 5
    then vezes = 25.
    if vplano = 6
    then vezes = 10.
    
    if vdata-futura <> today
    then do:
        message "Operacao negada, alterar data para HOJE.".
        pause 3 no-message.
        next.
    end.
    
    hide frame fpag99 no-pause.

    do on error undo, retry:
        ventrada = vtot / vezes.
        disp ventrada with frame f3.
        /*
        if vplano <> 4 and vplano <> 5
        then*/ do:
            update ventrada label "Entrada"  
                with frame f3 side-label centered.

            if ventrada < (vtot / vezes) - ((vtot / vezes) * .20)
            then do:
                message "VALOR DE ENTRADA NAO AUTORIZADO".
                undo, retry.
            end.
        end.
        
        vdata = today + 30.
        do on error undo:
            update vdata label "1o Vencimento" with frame f3.
            if vdata > today + 40 or
               vdata < today
            then do:
                message "DATA DE VENCIMENTO NAO AUTORIZADO.".
                undo.
            end.
        end.
        
        if nov31
        then do:
            if vdata > today + 35
            then do:
                message "Vencimento deve ser menor que 35 dias".
                undo, retry.
            end.
        end.
        else do:
            if vdata > today + 45
            then do:
                message "Vencimento deve ser menor que 45 dias".
                undo, retry.
            end.
        end.
    end.
    end.
    else do:
        
        /*** COM Feirao ***/

        /*#12*/
        if today > 01/01/19 or setbcod = 189
        then vtitobs = vtitobs + "FEIRAO-NOVO=SIM|".
        else vtitobs = vtitobs + "FEIRAO-NOME-LIMPO=SIM|".
        /*#12*/
        
        run planos-feirao.

        if vplano = 10 or
           vplano = 11
        then do:
            sresp = no.
            vcont = 0.
            repeat on endkey undo:
                if keyfunction(lastkey) = "END-ERROR"
                then do:
                    hide frame fsenauto no-pause.
                    leave.
                end. 
                run libera-plano-token.
                if setbcod = 189 then sresp = yes.
                if sresp then leave.
                if vcont = 3
                then leave.
                vcont = vcont + 1.
            end.
            if sresp = no
            then do:
                disp skip(1) 
                "            OPERAÇÃO NÃO AUTORIZADA          "
                skip(1)
                WITH frame f-libpla centered.
                pause.
                hide frame f-libpla no-pause.
                next.
            end.
            hide frame f-libpla no-pause.
        end.

        if vdata-futura <> today
        then do:
            message "Operacao negada, alterar data para HOJE.".
            pause 3 no-message.
            next.
        end.
    
        hide frame fpag99 no-pause.
        
        ventrada = 0.
        
        if vezes > 1
        then do:

        do on error undo, retry:
            if vplano > 6
            then ventrada = vtot * .20.
            else ventrada = vtot / vezes.
            disp ventrada with frame f3.

            update ventrada label "Entrada"  
                with frame f3 side-label centered.

            if vplano > 6
            then do:
            if ventrada < (vtot / vezes) or
               ventrada > vtot
            then do:
                message "VALOR DE ENTRADA NAO AUTORIZADO".
                undo, retry.
            end.
            end. 
            else do:
                if ventrada < (vtot / vezes) - ((vtot / vezes) * .20)
                then do:
                    message "VALOR DE ENTRADA NAO AUTORIZADO".
                    undo, retry.
                end.
            end.
        end.
        
        vdata = today + 30.
        if vplano = 7
        then do:
            vdata = today.
            disp vdata label "1o Vencimento" with frame f3.
        end.
        else    
        do on error undo:
            update vdata label "1o Vencimento" with frame f3.
            if vdata > today + 40 or
               vdata < today
            then do:
                message "DATA DE VENCIMENTO NAO AUTORIZADO.".
                undo.
            end.
        end.
        
        if nov31
        then do:
            if vdata > today + 35
            then do:
                message "Vencimento deve ser menor que 35 dias".
                undo, retry.
            end.
        end.
        else do:
            if vdata > today + 45
            then do:
                message "Vencimento deve ser menor que 45 dias".
                undo, retry.
            end.
        end.
        end.
        else do:
            ventrada = 0.
            vdata = today.
            disp vdata label "1o Vencimento" with frame f3.
        end.
    end. 

    do on endkey undo.
        message "Confirma gerar novacao?" update sresp.
    end.
    if sresp = no
    then next.

    if vplano > 6  
    then do:
        sresp = no.
        repeat on error undo on endkey undo:
            if keyfunction(lastkey) = "END-ERROR"
            then do:
                hide frame f-cpf.
                sresp = no.
                leave.
            end.
            update vcpf-cre as char format "x(11)" 
                        label "CPF Crediarista"
                   with frame f-cpf 1 down side-label
                   row 16 centered.
            vdesc-cpf = "".
            color disp message  
            vdesc-cpf format "x(40)" no-label with frame f-cpf.
            run cpf.p(input vcpf-cre, output vok).
            if vok = no or vcpf-cre = ? or vcpf-cre = "" 
            then do:
                vdesc-cpf = "CPF Invalido".
                disp skip vdesc-cpf with frame f-cpf.
                undo, retry.
            end.
            
            empty temp-table tt-descfunc.
            conecta-ok = no.
            run agil4_WG.p (input "descfunc",
                            input vcpf-cre).
            if conecta-ok = yes
            then do:                
                find first tt-descfunc no-lock no-error.
                if avail tt-descfunc
                    and tt-descfunc.tem_cadastro = no
                    or  tt-descfunc.tipo_funcionario = no 
                then do:
                    vdesc-cpf = "CPF informado não é de funcionário".
                    disp vdesc-cpf with frame f-cpf.
                    undo, retry.
                end.            
            end.
            else do:
                vdesc-cpf = "Filial sem conexão.".
                disp vdesc-cpf with frame f-cpf.
                undo, retry.
            end.
            sresp = yes.
            leave.
        end.               
        if sresp = no
        then do:
            disp skip(1) 
                "            OPERAÇÃO CANCELADA         "
                skip(1)
                WITH frame f-libcpf centered.
                pause.
                hide frame f-libcpf no-pause.
                next.
        end.
        hide frame f-libcpf no-pause.

        vtitobs = vtitobs + "CPF-AUTORIZA=" + vcpf-cre + "|".
    end.

    vtitobs = vtitobs + "JURO-ATU=" + string(valor_juro[vplano]) +
                        "|JURO-ACR=" + string(valor_acre[vplano]) + "|" .
                        
    /****** BLOCO DE SEGURO ******/
    for each tp-contrato where tp-contrato.exportado = yes:
        find first tp-vndseguro where 
                        tp-vndseguro.contnum = tp-contrato.contnum
                   no-error.
        if avail tp-vndseguro
        then do:
            /* CANCELAMENTO DO SEGURO*/
            find vndseguro where vndseguro.tpseguro = tp-vndseguro.tpseguro
                             and vndseguro.etbcod   = tp-vndseguro.etbcod
                             and vndseguro.certifi  = tp-vndseguro.certifi
                             no-error.
            if avail vndseguro
            then assign
                    vndseguro.dtcanc = today
                    vndseguro.datexp = today
                    vndseguro.exportado = no.
            else do:
                create vndseguro.
                buffer-copy tp-vndseguro to vndseguro.
                assign
                    vndseguro.dtcanc = today
                    vndseguro.datexp = today
                    vndseguro.exportado = no.
            end.
            find vndseguro where vndseguro.tpseguro = tp-vndseguro.tpseguro
                             and vndseguro.etbcod   = tp-vndseguro.etbcod
                             and vndseguro.certifi  = tp-vndseguro.certifi
                             no-lock no-error.
            if avail vndseguro
            then run qbesegprest.p (recid(vndseguro),2).
        end.
    end.

    sresp = no.
    vsegvalor = 0.
    if vende-seguro and
       vezes > 1
    then do:
        do on endkey undo.
            message "Manter vantagens da PARCELA PROTEGIDA LEBES?"
                    update sresp.
        end.
        if sresp
        then do:
            /***vsegprocod = 559910.***/
            /***
            if vezes <= 15
            then vsegprocod = 579359. /* moveis */
            else vsegprocod = 559911. /* moda */
            ***/
            if vtot <= 300
            then vsegprocod = 578790.
            else vsegprocod = 579359.
            
            find produ where produ.procod = vsegprocod no-lock no-error.
            if avail produ
            then do:
                find estoq where estoq.etbcod = setbcod and
                                 estoq.procod = vsegprocod
                           no-lock no-error.
                if avail estoq
                then vsegvalor = estoq.estvenda.
/***
                    if vezes <= 15
                    then vsegvalor = estoq.estvenda.
                    else vsegvalor = estoq.estvenda * vezes.
***/
            end.
        end.
    end.
     
    vtot = vtot + vsegvalor.
    
    /***** CRIA TEMP-TABLE PARA PAGAR PRESTACOES ANTIGAS NO FINAL **********/
    
    for each tp-titulo:
        assign tp-titulo.titdtpag = today /*** <== ***/
               tp-titulo.etbcobra = setbcod 
               tp-titulo.datexp   = today 
               tp-titulo.cxmdata  = today 
               tp-titulo.cxacod   = scxacod 
               tp-titulo.moecod   = "NOV" 
               tp-titulo.titsit   = "PAG" 
               tp-titulo.titvlpag = tp-titulo.titvlcob
               tp-titulo.titjuro  = 0
               tp-titulo.exportado = no.
        create wf-tit.
        {tt-titulo.i wf-tit tp-titulo}.
    end.   

    /********************* GERA TITULOS DE NOVACAO ***********************/
    
    do for geranum on error undo on endkey undo:
        find geranum where geranum.etbcod = setbcod exclusive.
        vgera = geranum.contnum.
        geranum.contnum = geranum.contnum + 1.
        find current geranum no-lock.
    end.
                            
    create wf-contrato.

    if setbcod >= 100
    then wf-contrato.contnum = int("1" + string(setbcod,"999") +
                                         string(vgera,"999999")).
    else wf-contrato.contnum = int(string(string(vgera,"99999999") +
                                   string(setbcod,"99"))).

    assign wf-contrato.clicod    = clien.clicod
           wf-contrato.dtinicial = today 
           wf-contrato.etbcod    = setbcod 
           wf-contrato.datexp    = today 
           wf-contrato.vltotal   = vtot 
           wf-contrato.vlentra   = ventrada
           wf-contrato.crecod    = 500
           wf-contrato.banco     = vbanco.
    recid-contrato = recid(wf-contrato).

    /*******************************  ENTRADA *************************/
    if ventrada > 0
    then do on error undo: 
        create wf-titulo.
        assign wf-titulo.empcod   = wempre.empcod
               wf-titulo.modcod   = "CRE"
               wf-titulo.cxacod   = scxacod
               wf-titulo.cliFOR   = clien.clicod
               wf-titulo.titnum   = string(wf-contrato.contnum) 
               wf-titulo.titpar   = 0
               wf-titulo.titnat   = no
               wf-titulo.etbcod   = setbcod
               wf-titulo.titdtemi = today
               wf-titulo.titdtven = today
               wf-titulo.titdtpag = ?
               wf-titulo.titvlpag = 0
               wf-titulo.titvlcob = ventrada
               wf-titulo.cobcod   = 2
               wf-titulo.titsit   = "LIB"
               wf-titulo.etbcobra = ?
               wf-titulo.datexp   = today
               /*wf-titulo.moecod = "NOV"*/
               wf-titulo.tpcontrato = "N" /* #1 "L" */.

        if nov31 = no 
        then assign
                wf-titulo.titobs[1] = "RENOVACAO=SIM|".
        else assign
                wf-titulo.titobs[1] = "NOVACAO=SIM|".

        if vtitobs <> ""
        then wf-titulo.titobs[1] = wf-titulo.titobs[1] + vtitobs.

        down with frame f4.
        display wf-titulo.titpar   column-label "PC"
                wf-titulo.titnum   column-label "Contrato"
                wf-titulo.titdtemi column-label "Emissao"
                wf-titulo.titdtven column-label "Vencimento"
                wf-titulo.titvlcob format ">,>>>,>>9.99"
                wf-titulo.titsit   column-label "Vl.Cob"
                with frame f4 down centered 
                    title " Pagar ENTRADA na tela de Caixa ".
        down with frame f4.
    end.
    else if vezes = 1
    then do on error undo:
        create wf-titulo.
        assign wf-titulo.empcod   = wempre.empcod
               wf-titulo.modcod   = "CRE"
               wf-titulo.cxacod   = scxacod
               wf-titulo.cliFOR   = clien.clicod
               wf-titulo.titnum   = string(wf-contrato.contnum) 
               wf-titulo.titpar   = 1
               wf-titulo.titnat   = no
               wf-titulo.etbcod   = setbcod
               wf-titulo.titdtemi = today
               wf-titulo.titdtven = today
               wf-titulo.titdtpag = ?
               wf-titulo.titvlpag = 0 
               wf-titulo.titvlcob = vtot
               wf-titulo.cobcod   = 2
               wf-titulo.titsit   = "LIB"
               wf-titulo.etbcobra = ?
               wf-titulo.datexp   = today
               wf-titulo.tpcontrato = "N" /* #1 "L" */.

        if nov31 = no 
        then assign
                wf-titulo.titobs[1] = "RENOVACAO=SIM|".
        else assign
                wf-titulo.titobs[1] = "NOVACAO=SIM|".

        if vtitobs <> ""
        then wf-titulo.titobs[1] = wf-titulo.titobs[1] + vtitobs.

        down with frame f4.
        display wf-titulo.titpar   column-label "PC"
                wf-titulo.titnum   column-label "Contrato"
                wf-titulo.titdtemi column-label "Emissao"
                wf-titulo.titdtven column-label "Vencimento"
                wf-titulo.titvlcob format ">,>>>,>>9.99"
                wf-titulo.titsit   column-label "Vl.Cob"
                with frame f4 down centered
                 title " Pagar VALOR A VISTA na tela de Caixa ".
        down with frame f4.
    end.

    /******************************************************************/
    /**
    if nov31
    then wcon = 30.
    else wcon = 50.
    **/
    wcon = 30.
    vtot = vtot - ventrada.
    
    vday = day(vdata).
    vmes = month(vdata).
    vano = year(vdata).
    
    if vmes = 1
    then assign vmes = 12
                vano = year(vdata) - 1.
    else assign vmes = month(vdata) - 1
                vano = year(vdata).
    
    if vmes = 2
    then vdata = date(vmes,28,vano). 
    else vdata = date(vmes,30,vano). 

    vano = year(vdata).
    
    if vezes > 1
    then do i = 1 to vezes - 1:
        assign wcon = wcon + 1
               vmes = vmes + 1.
                 
        if vmes > 12 
        then assign vano = vano + 1
                    vmes = 1.
        
        do on error undo: 
            create wf-titulo.
            assign wf-titulo.empcod   = wempre.empcod
                   wf-titulo.modcod   = "CRE"
                   wf-titulo.cxacod   = scxacod
                   wf-titulo.cliFOR   = clien.clicod
                   wf-titulo.titnum   = string(wf-contrato.contnum) 
                   wf-titulo.titpar   = wcon
                   wf-titulo.titnat   = no
                   wf-titulo.etbcod   = setbcod
                   wf-titulo.titdtemi = today
                   wf-titulo.titdtven = date(vmes,
                                        IF VMES = 2
                                        THEN IF VDAY > 28
                                             THEN 28
                                             ELSE VDAY
                                        ELSE if VDAY > 30
                                             then 30
                                             else vday,
                                        vano)
                   wf-titulo.titdes   = vsegvalor / ( vezes - 1)
                   wf-titulo.titvlcob = vtot / ( vezes - 1)
                   wf-titulo.cobcod   = 2
                   wf-titulo.titsit   = "LIB"
                   wf-titulo.datexp   = today
                   wf-titulo.tpcontrato = "N" /* #1 "L" */.

            if nov31 = no
            then assign
                    wf-titulo.titobs[1] = "RENOVACAO=SIM|".
            else assign
                    wf-titulo.titobs[1] = "NOVACAO=SIM|".
        
            if vtitobs <> ""
            then wf-titulo.titobs[1] = wf-titulo.titobs[1] + vtitobs.
        end.

        down with frame f4.
        display wf-titulo.titpar   column-label "PC"
                wf-titulo.titnum   column-label "Contrato"
                wf-titulo.titdtemi column-label "Emissao"
                wf-titulo.titdtven column-label "Vencimento"
                wf-titulo.titvlcob format ">,>>>,>>9.99"
                wf-titulo.titsit   column-label "Vl.Cob"
                with frame f4 down centered.
        down with frame f4.
    end.

    for each tp-titulo:
        delete tp-titulo.
    end.

    /*** #2
        ENTRADA - novfil-novacao.p A BAIXO VAI LER WF-TITULO E CRIAR TITULO
    find first wf-titulo where wf-titulo.titpar = 0 no-error.
    if avail wf-titulo
    then do:
        create tp-titulo.
        {tt-titulo.i tp-titulo wf-titulo}.
    end.

    for each tp-titulo:
        find titulo where titulo.empcod = tp-titulo.empcod
                      and titulo.titnat = tp-titulo.titnat
                      and titulo.modcod = tp-titulo.modcod
                      and titulo.clifor = tp-titulo.clifor
                      and titulo.etbcod = tp-titulo.etbcod
                      and titulo.titnum = tp-titulo.titnum
                      and titulo.titpar = tp-titulo.titpar no-error.
        if avail titulo
        then do transaction:
            assign titulo.titsit    = tp-titulo.titsit
                   titulo.titdtpag  = tp-titulo.titdtpag
                   titulo.titvlpag  = tp-titulo.titvlpag
                   titulo.titvlcob  = tp-titulo.titvlcob
                   titulo.titjuro   = tp-titulo.titjuro
                   titulo.titdesc   = tp-titulo.titdesc
                   titulo.titvljur  = tp-titulo.titvljur
                   titulo.cxacod    = tp-titulo.cxacod
                   titulo.cxmdata   = tp-titulo.cxmdata
                   titulo.etbcobra  = tp-titulo.etbcobra
                   titulo.datexp    = tp-titulo.datexp
                   titulo.moecod    = tp-titulo.moecod
                   titulo.titobs[1] = tp-titulo.titobs[1].
        end.
        else do transaction:
            create titulo.
            assign titulo.empcod    = tp-titulo.empcod
                   titulo.modcod    = tp-titulo.modcod
                   titulo.clifor    = tp-titulo.clifor
                   titulo.titnum    = tp-titulo.titnum 
                   titulo.titpar    = tp-titulo.titpar 
                   titulo.titsit    = tp-titulo.titsit 
                   titulo.titnat    = tp-titulo.titnat 
                   titulo.etbcod    = tp-titulo.etbcod 
                   titulo.titdtemi  = tp-titulo.titdtemi 
                   titulo.titdtven  = tp-titulo.titdtven 
                   titulo.titdtpag  = today 
                   titulo.titvlcob  = tp-titulo.titvlcob 
                   titulo.cobcod    = tp-titulo.cobcod 
                   titulo.titvlpag  = tp-titulo.titvlpag 
                   titulo.titvljur  = tp-titulo.titvljur 
                   titulo.etbcobra  = tp-titulo.etbcobra 
                   titulo.titjuro   = tp-titulo.titjuro 
                   titulo.titdesc   = tp-titulo.titdesc 
                   titulo.cxacod    = tp-titulo.cxacod 
                   titulo.cxmdata   = tp-titulo.cxmdata 
                   titulo.datexp    = tp-titulo.datexp
                   titulo.moecod    = tp-titulo.moecod
                   titulo.titobs[1] = tp-titulo.titobs[1]
                   titulo.tpcontrato = tp-titulo.tpcontrato.
        end.

        find first tt-recib where tt-recib.titnum = tp-titulo.titnum and
                                  tt-recib.ordpre = tp-titulo.titpar
                            no-error.
        if not avail tt-recib and tp-titulo.titpar <> 0 
        then do:
             create tt-recib.
             assign tt-recib.rectit = recid(tp-titulo)
                    tt-recib.ordpre = tp-titulo.titpar
                    tt-recib.titnum = tp-titulo.titnum.
        end.
    end.    
    
    find first tt-recib no-error.
    if avail tt-recib
    then do:
         run value(srecibo) (input tt-recib.rectit,
                             input tt-recib.titnum).
    end.

    if vezes = 1
    then do:
        find first wf-titulo where wf-titulo.titpar = 1 no-error.
        if avail wf-titulo
        then do:
            create tp-titulo.
            {tt-titulo.i tp-titulo wf-titulo}.
        end.
    end.
#2 *** ***/

    if ERROR-STATUS:ERROR
    THEN run gera-arquivo-log(sretorno).

    run novfil-novacao.p. /*novfil.p.*/
    if ERROR-STATUS:ERROR
    THEN run gera-arquivo-log(sretorno).
    
    /************ PAGAMENTO DE PRESTACOES ANTIGAS *************/
    
    for each wf-tit:
        find FIRST titulo where titulo.empcod = wf-tit.empcod
                            and titulo.titnat = wf-tit.titnat
                            and titulo.modcod = wf-tit.modcod
                            and titulo.clifor = wf-tit.clifor
                            and titulo.etbcod = wf-tit.etbcod
                            and titulo.titnum = wf-tit.titnum
                            and titulo.titpar = wf-tit.titpar
                          use-index titnum no-error.
        if avail titulo
        then do transaction:
            assign titulo.titsit    = wf-tit.titsit
                   titulo.titdtpag  = wf-tit.titdtpag
                   titulo.titvlpag  = wf-tit.titvlpag
                   titulo.moecod    = wf-tit.moecod
                   titulo.titvlcob  = wf-tit.titvlcob
                   titulo.titjuro   = wf-tit.titjuro
                   titulo.titdesc   = wf-tit.titdesc
                   titulo.titvljur  = wf-tit.titvljur
                   titulo.cxacod    = wf-tit.cxacod
                   titulo.cxmdata   = wf-tit.cxmdata
                   titulo.etbcobra  = wf-tit.etbcobra
                   titulo.datexp    = wf-tit.datexp
                   titulo.titobs[1] = wf-tit.titobs[1].
        end.
        else do transaction:
            create titulo.
            {tt-titulo.i titulo wf-tit} /*** #2 ***/
        end.
        do on error undo:
            create tit_novacao.
            assign
                 tit_novacao.tipo         = "RENEGOCIACAO"
                 tit_novacao.ger_contnum  = wf-contrato.contnum
                 tit_novacao.id_acordo    = ""
                 tit_novacao.ori_empcod   = wf-tit.empcod
                 tit_novacao.ori_titnat   = wf-tit.titnat
                 tit_novacao.ori_modcod   = wf-tit.modcod
                 tit_novacao.ori_etbcod   = wf-tit.etbcod
                 tit_novacao.ori_clifor   = wf-tit.clifor
                 tit_novacao.ori_titnum   = wf-tit.titnum
                 tit_novacao.ori_titpar   = wf-tit.titpar
                 tit_novacao.ori_titdtemi = wf-tit.titdtemi
                 tit_novacao.ori_titvlcob = wf-tit.titvlcob
                 tit_novacao.ori_titdtpag = wf-tit.titdtpag
                 tit_novacao.ori_titdtven = wf-tit.titdtven
                 tit_novacao.dtnovacao  = today
                 tit_novacao.hrnovacao  = time
                 tit_novacao.etbnovacao = setbcod
                 tit_novacao.funcod     = sfuncod 
                 tit_novacao.datexp     = today
                 tit_novacao.exportado  = no.
        end.
    end.    
    
    if ERROR-STATUS:ERROR
    THEN run gera-arquivo-log(sretorno).
 
    find first wf-contrato no-error.
    if avail wf-contrato
    then do:
        do on endkey undo.
            message "Confirma a Emissao do Controle de Vencimentos?"
                    update sresp.
        end.
        hide message no-pause.
        if sresp 
        then do:
            find caixa where caixa.etbcod = setbcod and
                             caixa.cxacod = scxacod no-lock no-error.
            if caixa.moecod = "bar"
            then run carne_n.p.
            
            if ERROR-STATUS:ERROR
            THEN run gera-arquivo-log(sretorno).
            
            if wf-contrato.banco = 10
            then run contratoimp-novacao.p(recid-contrato, vezes).
            
            if ERROR-STATUS:ERROR
            THEN run gera-arquivo-log(sretorno).
 
            if vsegvalor > 0
            then do.
                for each wf-titulo.
                    if vsegdtivig = ? or vsegdtivig > wf-titulo.titdtven
                    then vsegdtivig = wf-titulo.titdtven.

                    if vsegdtfvig = ? or vsegdtfvig < wf-titulo.titdtven
                    then vsegdtfvig = wf-titulo.titdtven.
                end.

                run vndseguro.p (?, vsegvalor, vsegprocod,
                             clien.clicod,
                             wf-contrato.contnum,
                             vsegdtivig, vsegdtfvig,
                             sfuncod,
                             output vsegrecid).
                if vsegrecid <> ?
                then run qbesegprest.p (vsegrecid,2). 
            end.
            if ERROR-STATUS:ERROR
            THEN run gera-arquivo-log(sretorno).
        end.  
    end.
    leave.
end.
    
/***
if keyfunction(lastkey) = "END-ERROR"
then.
else
***/

if ERROR-STATUS:ERROR
THEN run gera-arquivo-log(sretorno).
 
procedure gera-arquivo-log:
    def input parameter p-msg as char.
    def var varqlog-gerpla as char.
    varqlog-gerpla = "log-novacao22-" + string(scxacod,"999") + "-" +
                        string(today,"99999999") + ".log".
    def var v-numerror as char.
    def var v-deserror as char.
    def var ix as int no-undo.
    if p-msg <> ""
    then do:
        DO ix = 1 TO ERROR-STATUS:NUM-MESSAGES:
            v-numerror = string(ERROR-STATUS:GET-NUMBER(ix)).
            v-deserror = ERROR-STATUS:GET-MESSAGE(ix).
        END.
        
        output to value(varqlog-gerpla) append.
            put unformatted string(time,"hh:mm:ss") " ** " .
            if avail wf-contrato
            then put unformatted wf-contrato.contnum .
            put  unformatted " ** "  skip.
            put unformatted v-numerror v-deserror skip.
        output close.
    end.
    else do:
        output to value(varqlog-gerpla) append.
            put unformatted string(time,"hh:mm:ss") " ** ".
            if avail wf-contrato
            then put unformatted wf-contrato.contnum.
            put unformatted " ** " skip.
            put unformatted p-msg skip.
        output close.
    end.
end procedure.

procedure cal-juro:
    def var vjuro       as dec.
    def var vprincipal  as dec.
    do vv = 1 to 6.
        
        if vv = 6 and not vplano6
        then next.
        
        if vv = 1 
        then do: 
            vjuro       = valor_juro[vv].
            vprincipal  = valor_cobrado[1].    
            valor_acre[vv] = (vprincipal + vjuro) * .05.
            valor_novacao[vv] = vprincipal + vjuro + valor_acre[vv].
        end.
        if vv = 2 
        then do: 
            vjuro       = valor_juro[vv].
            vprincipal  = valor_cobrado[2].    
            valor_acre[vv] = (vprincipal + vjuro) * .10.
            valor_novacao[vv] = vprincipal + vjuro + valor_acre[vv].
        end.
        if vv = 3 
        then do: 
            vjuro       = valor_juro[vv].
            vprincipal  = valor_cobrado[3].    
            valor_acre[vv] = (vprincipal + vjuro) * .15.
            valor_novacao[vv] = vprincipal + vjuro + valor_acre[vv].
        end.
        if vv = 4 
        then do: 
            vjuro       = valor_juro[vv].
            vprincipal  = valor_cobrado[4].    
            valor_acre[vv] = (vprincipal + vjuro) * .35.
            valor_novacao[vv] = vprincipal + vjuro + valor_acre[vv].
        end.
        if vv = 5 
        then do: 
            vjuro       = valor_juro[vv].
            vprincipal  = valor_cobrado[5].    
            valor_acre[vv] = (vprincipal + vjuro) * .40.
            valor_novacao[vv] = vprincipal + vjuro + valor_acre[vv].
        end.
        if vv = 6
        then do:
            vjuro       = valor_juro[vv].
            vprincipal  = valor_cobrado[vv].
            valor_acre[vv] = (vprincipal /*+ vjuro*/) * .10.
            valor_novacao[vv] = vprincipal + /*vjuro +*/ valor_acre[vv].
        end.
    end.

end procedure.

procedure sel-contrato:

    {setbrw.i}
    {esqcom.def}
    assign
        esqcom1[1] = "Marca/Desmarca"
        esqcom1[2] = "Confirma".

    def var vmarca as char.
    disp esqcom1 with frame f-esqcom1.
    disp esqcom2 with frame f-esqcom2.     
    assign
        a-seeid = -1
        a-recid = -1
        a-seerec = ? 
        esqpos1 = 1
        esqpos2 = 1
        esqregua = yes.

    color disp message esqcom1[esqpos1] with frame f-esqcom1.    
    pause 0.
    def var vpago as dec.
    def var vpend as dec.

    for each tp-contrato:
        find first tp-titulo where
            tp-titulo.titnum = string(tp-contrato.contnum)
            no-error.
        if avail tp-titulo
        then tp-contrato.exportado = yes.
        else delete tp-contrato.
    end.
    if vfeirao
    then
    for each tp-contrato:
        find first tp-titulo where
                 tp-titulo.titnum = string(tp-contrato.contnum) and
                 tp-titulo.titdtven <= today - 90
            no-error.
        if not avail tp-titulo
        then delete tp-contrato.
    end.

    def var vdown as int.
    
    form vmarca no-label format "x"
         tp-contrato.contnum format ">>>>>>>>>9"
         tp-contrato.etbcod  column-label "Fil"
         tp-contrato.vltotal format ">>>>>,>>9.99" 
                             column-label "Valor Contrato"
         vpago column-label "Valor Pago"  format ">>>>>,>>9.99"
         vpend column-label "Valor Pendente"  format ">>>>>,>>9.99"
         tp-contrato.dtinicial
         with frame f-linha screen-lines - 13 down width 80.

    l1: repeat:    
    {sklcls.i
        &file = tp-contrato
        &cfield = tp-contrato.contnum
        &noncharacter = /*
        &ofield = " vmarca
                    tp-contrato.etbcod
                    tp-contrato.vltotal
                    vpago
                    vpend
                    tp-contrato.dtinicial" 
        &aftfnd1 = " if tp-contrato.exportado
                     then vmarca = ""*"".
                     else vmarca = """".
                     vpend = 0.
                     for each tp-titulo where
                        tp-titulo.titnum = string(tp-contrato.contnum):
                        vpend = vpend + tp-titulo.titvlcob.
                    end.
                    if tp-contrato.vltotal > 0
                    then vpago = tp-contrato.vltotal - vpend.
                    else vpago = 0. 
                    if vpago < 0 then vpago = 0.
                    "         
        &where = true
        &naoexiste1 = "
            message color red/with
            SKIP ""Nenhum registro encontrado""
            skip
            view-as alert-box.
            leave l1. "
        &aftselect1 = " 
                    if keyfunction(lastkey) = ""RETURN""
                    then do:
                        if esqcom1[esqpos1] = ""Marca/Desmarca""
                        then do:
                            if tp-contrato.exportado = yes
                            then    assign
                                tp-contrato.exportado = no
                                vmarca = """".
                            else    assign
                                tp-contrato.exportado = yes
                                vmarca = ""*"".
                            disp vmarca with frame f-linha.
                            next keys-loop. 
                        end.
                        else leave keys-loop.
                    end. "
        &otherkeys = " esqcom.i "
        &form  = " frame f-linha "
    }         
    if keyfunction(lastkey) = "end-error"
    then leave l1.
    if keyfunction(lastkey) = "TAB"
    then do:
        {esqcom.i}
        next.
    end.
    if esqcom1[esqpos1] = "Confirma"
    then do:
        find first tp-contrato where 
            tp-contrato.exportado no-error.
        if not avail tp-contrato
        then do:
            message color red/with
                skip
                "   NECESSARIO MARCAR CONTRATO   "
                skip
                view-as alert-box.
            next l1.
        end.
        leave l1.
    end.
    end.
end procedure.   
procedure planos-feirao:
    def var vparcela as dec extent 11. 
    def var n-par as int.
    def var vtitvlpf as dec.
    def var vtitvlpf30 as dec.
    def var vtitvlpf-vencido as dec.
    def var vtitvlpf-vencer as dec.
    
    do vv = 1 to 11:
        
        if vv = 6 and not vplano6
        then next.
        
        vok = yes.
        
        assign per_acr = 0  
               per_des = 0  
               per_cor = 0  
               vtot    = 0 
               vtitj   = 0 
               vtitvlp = 0
               vtitvlpf = 0
               vtitvlpf30 = 0
               vtitvlpf-vencido = 0
               vtitvlpf-vencer  = 0
               .
        
        vplano = vv.

        for each tp-titulo use-index dt-ven:     
            
            if vdata-futura > tp-titulo.titdtven
            then do:
                 ljuros = yes.

                if vdata-futura - tp-titulo.titdtven = 3
                then do:
                    find dtextra where exdata = vdata-futura - 3
                                 NO-LOCK no-error.
                    if weekday(vdata-futura - 3) = 1 or avail dtextra
                    then do:
                        find dtextra where exdata = vdata-futura - 1
                                     NO-LOCK no-error.
                        if weekday(vdata-futura - 1) = 1 or avail dtextra
                        then ljuros = no.
                    end.
                end.

                if vdata-futura - tp-titulo.titdtven = 2
                then do:
                    find dtextra where exdata = vdata-futura - 2
                                 NO-LOCK no-error.
                    if weekday(vdata-futura - 2) = 1 or avail dtextra
                    then do:
                        find dtextra where exdata = vdata-futura - 1
                                     NO-LOCK no-error.
                        if weekday(vdata-futura - 1) = 1 or avail dtextra
                        then ljuros = no.
                    end.
                end.
                else do:
                    if vdata-futura - tp-titulo.titdtven = 1
                    then do:
                        find dtextra where exdata = vdata-futura - 1
                                     NO-LOCK no-error.
                        if weekday(vdata-futura - 1) = 1 or avail dtextra
                        then ljuros = no.
                    end.
                end.
                vnumdia = if not ljuros
                          then 0
                          else vdata-futura - tp-titulo.titdtven.

                if vnumdia > 1766
                then vnumdia = 1766.

                find tabjur where tabjur.nrdias = vnumdia no-lock no-error.
                if not avail tabjur
                then do:
                    message "Fator para" vnumdia
                    "dias de atraso, nao cadastrado". pause. undo.
                end.
                assign vtot    = vtot    + tp-titulo.titvlcob
                       vtitvlp = vtitvlp + (tp-titulo.titvlcob * tabjur.fator) 
                       vtitvlpf = vtitvlpf + tp-titulo.titvlcob 
                       vtitvlpf-vencido = vtitvlpf-vencido 
                                            + tp-titulo.titvlcob
                       vtitvlpf30   = vtitvlpf30 + tp-titulo.titvlcob
                       .
                if tp-titulo.titpar > 30
                then vtitvlpf = vtitvlpf - (tp-titulo.titvlcob  * .20).
                else vtitvlpf = vtitvlpf + (tp-titulo.titvlcob  * .30).

                /** arredondamento */
                def var dd like titulo.titvlcob.
                dd = ( (int(vtitvlp) -  
                                    vtitvlp) ) 
                                    - round(( (int(vtitvlp) - 
                                                  (vtitvlp)) ),1).
                        if dd < 0 
                        then dd = 0.10 - (dd * -1).

                        vtitvlp = vtitvlp + dd.
                dd = ( (int(vtitvlpf) -  
                                    vtitvlpf) ) 
                                    - round(( (int(vtitvlpf) - 
                                                  (vtitvlpf)) ),1).
                        if dd < 0 
                        then dd = 0.10 - (dd * -1).

                        vtitvlpf = vtitvlpf + dd.
                 /***/
            end.
            else do:

                /*if vdia <= 90 
                then. 
                else*/ do:   
                    vnumdia = tp-titulo.titdtven - today.
                
                    assign vtot    = vtot    + tp-titulo.titvlcob   
                           vtitvlp = vtitvlp + tp-titulo.titvlcob
                           vtitvlpf = vtitvlpf + tp-titulo.titvlcob
                           vtitvlpf-vencer = vtitvlpf-vencer +
                                                tp-titulo.titvlcob
                           vtitvlpf30 = vtitvlpf30 + tp-titulo.titvlcob
                           .
                    if tp-titulo.titpar > 30
                    then vtitvlpf = vtitvlpf - (tp-titulo.titvlcob * .20).
                end.
            end.                    
        end.
        
        if vdia >= 30  and
           vdia <= 270  /*promocao 150*/ and
           lp-ok = no
        then nov31 = yes.
    
        vtitvlp = vtitvlp + (vtitvlp * per_acr).
    
        vtitj = vtitvlp - vtot.
 
        if vv = 1
        then assign
                 vtit = " [ 1 ]  6  vezes(1+5) "
                 n-par = 6.
        if vv = 2
        then assign
                 vtit = " [ 2 ]  10 vezes(1+9) "
                 n-par = 10.
        if vv = 3
        then assign
                 vtit = " [ 3 ]  15 vezes(1+14)"
                 n-par = 15.
        if vv = 4
        then assign
                 vtit = " [ 4 ]  20 vezes(1+19)"
                 n-par = 20.
        if vv = 5
        then assign
                 vtit = " [ 5 ]  25 vezes(1+24)"
                 n-par = 25.
        if vv = 6
        then assign
                 vtit = " [ 6 ]  10 vezes(1+9) "
                 n-par = 10.
        if vv = 7
        then assign
                 vtit = " [ 7 ]  1 vez(A Vista) "
                 n-par = 1.
        if vv = 8
        then assign
                 vtit = " [ 8 ]  5 vezes(1+4 s/juro) "
                 n-par = 5.
        if vv = 9
        then assign
                 vtit = " [ 9 ]  10 vezes(1+9 s/juro) "
                 n-par = 10.
        if vv = 10
        then assign
                 vtit = "[ 10 ]  15 vezes(1+14 s/juro) "
                 n-par = 15.
        if vv = 11
        then assign
                 vtit = "[ 11 ]  20 vezes(1+19 s/juro) "
                 n-par = 20.
        if vok 
        then assign vcond[vv]         = vtit
                    valor_cobrado[vv] = vtot 
                    valor_juro[vv]    = vtitj  
                    valor_acre[vv]    = if vv < 7 then 0
                                    else vtitvlpf - vtot
                    valor_novacao[vv] = if vv < 7 then vtitvlp
                                                  else vtitvlpf.
        else assign vcond[vv]         = vtit + " - NAO DISPONIVEL"   
                    valor_cobrado[vv] = 0
                    valor_juro[vv]    = 0
                    valor_acre[vv]    = 0
                    valor_novacao[vv] = 0.
        vparcela[vv] = valor_novacao[vv] / n-par.
    end.
    
    run cal-juro.
    
    display  vdtven   label "Maior Atraso" 
             vdia     label "Dias de atraso" 
                with frame f-dias side-label centered.
    pause .

    hide frame f-dias no-pause.
    
    find first tt-lib11 where tt-lib11.etbcod = setbcod no-lock no-error.
    
    display valor_cobrado[1]       at 7 label "Valor Cobrado...." skip
            vcond[1]            label "Plano" at 1 format "x(30)"
            /*vparcela[1]         label "de"*/
            valor_novacao[1]    label "Valor calculado" skip

            vcond[2]            label "Plano" at 1 format "x(30)"
            /*vparcela[2]         label "de"*/
            valor_novacao[2]    label "Valor calculado" skip 
            
            vcond[3]            label "Plano" at 1 format "x(30)"
            /*vparcela[3]         label "de"*/
            valor_novacao[3]    label "Valor calculado" skip 
            
            vcond[4]            label "Plano" at 1 format "x(30)"
            /*vparcela[4]         label "de"*/
            valor_novacao[4]    label "Valor calculado" skip
            
            vcond[5]            label "Plano" at 1 format "x(30)"
            /*vparcela[5]         label "de"*/
            valor_novacao[5]    label "Valor calculado"
                with frame f-planof side-label 
                    centered title " CONDICOES PARA NOVACAO DE DIVIDA " width 80
                    row 7. 
     
    if vplano6
    then disp vcond[6]          label "Plano" at 1 format "x(30)"
              /*vparcela[6]       label "de"*/
            valor_novacao[6]    label "Valor calculado"
                with frame f-planof side-label 
                .

    display "------- PLANOS FEIRAO NOME LIMPO LEBES -------" skip
            vcond[7]            label "Plano" at 1 format "x(30)"
            /*vparcela[7]         label "de"*/
            valor_novacao[7]    label "Valor calculado" skip

            vcond[8]            label "Plano" at 1 format "x(30)"
            /*vparcela[8]         label "de"*/
            valor_novacao[8]    label "Valor calculado" skip 
            
            vcond[9]            label "Plano" at 1 format "x(30)"
            /*vparcela[9]         label "de"*/
            valor_novacao[9]    label "Valor calculado" skip 
            
            vcond[10]            label "Plano" at 1 format "x(30)"
            /*vparcela[10]         label "de"*/
            valor_novacao[10]    label "Valor calculado" skip

            vcond[11]            label "Plano" at 1 format "x(30)"
            when avail tt-lib11
            valor_novacao[11]    label "Valor calculado" 
            when avail tt-lib11
            skip

             
                with frame f-planof .
        
    pause 0.
    
    assign
        vjuro-ori = vtitj 
        vtitj = valor_juro[1]
        vtitj = vjuro-ori.

    do on error undo, retry:
        vplano = 0.
        update vplano label "Plano" 
            with frame f-cond side-label centered no-box color message.
            
        if vplano = 0 or
           vplano > 11 or
           valor_novacao[vplano] = 0
        then do: 
            message "Plano Invalido.".
            undo, retry.
        end.
        else if vplano = 11 and
            not avail tt-lib11
        then do:
            message "Plano Invalido.".
            undo, retry.
        end.    
        

        display vcond[vplano] no-label with frame f-cond.
        pause 0.
    end.                    
    
    assign vtot    = valor_novacao[vplano]
           vtitj   = valor_juro[vplano]
           vtitvlp = valor_novacao[vplano].
                        
    if vplano = 1 
    then vezes = 6.  
    if vplano = 2  
    then vezes = 10.  
    if vplano = 3  
    then vezes = 15.  
    if vplano = 4  
    then vezes = 20.
    if vplano = 5
    then vezes = 25.
    if vplano = 6
    then vezes = 10.
    if vplano = 7
    then vezes = 1.
    if vplano = 8
    then vezes = 5.
    if vplano = 9
    then vezes = 10.
    if vplano = 10
    then vezes = 15.
    if vplano = 11
    then vezes = 20.
end procedure.

procedure libera-plano-token:
    def var vlista-user as char extent 13 FORMAT "X(25)"
          init["Debora_swat|352500",
               "Jeane|732891",
               "Tamara|247691",
               "",
               "",
               "",
               "",
               "",
               "",
               "",
               "",
               "",
               ""].
          /***
          init["Debora_swat|352500","Rita_cre|317600","Priscila_cre|578124",
               "Fernanda_cre|236438","credito1|298479","credito2|908230",
               "credito3|376508","credito4|723697","credito5|194834",
               "credito6|356754","credito7|238962","credito8|435389",
               "credito9|039383"].
          ***/

    def var vsenauto as char.
    def var par-user as char.

    display vlista-user with frame fvuser 1 column centered no-labels row 10
                    title " Escolha o outorizador "
                    overlay width 30 .
    pause 0.                
    choose field vlista-user with frame fvuser.
    par-user = vlista-user[frame-index].
 
    update  space(2)
      vsenauto label "Código de autorização"
            with frame fsenauto overlay side-label
                  title " Informe o código de autorizacão "
                                    row 19 centered
                                    width 60.
    
    run p-valida-senha-token.p (input par-user,
                                    input vsenauto,
                                    output sresp).


    if sresp
    then vtitobs = vtitobs + "LIBERA-PLANO-NOVACAO-TOKEN=" + 
                     replace(par-user,"|","_") + "|".

    hide frame fsenauto no-pause.
    hide frame fvuser no-pause.

end procedure.

