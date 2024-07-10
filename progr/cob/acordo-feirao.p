/* #1 26.06.2020 https://trello.com/c/uKaXTpjY/52-feir%C3%A3o-nome-limpo-condi%C3%A7%C3%A3o
*/

{admcab.i}


def input parameter p-clicod like clien.clicod.
def output parameter p-ok as log.

def var par-valor as char.
def var vef_dataemi as date.
def var vef_dias as int.

def var vtitobs as char.
def var vfator as dec.

def var vcont as int.

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
/*   setbcod = 189 or*/
   setbcod = 01 or
   setbcod = 23                  
then vplano6 = yes.
else vplano6 = no.   
def var vlibera-plano11 as char.
vlibera-plano11 = "01;02;03;04;05;06;07;08;09;10;11;12;13;14;15;16;17;18;19;20;21;22;23;24;25;26;27;28;29;30;31;32;33;34;35;36;37;38;39;40;41;42;43;44;45;46;47;48;49;50;51;52;53;54;55;56;57;58;59;60;61;62;63;64;65;66;67;68;69;70;71;72;73;74;75;76;77;78;79;80;81;82;83;84;85;86;87;88;89;90;91;92;93;94;95;96;97;98;99;100;101;102;103;104;105;105;107;108;109;110;111;112;113;114;115;116;117;118;119;120;121;122;123;124;125;126;127;128;129;130;131;132;133;134;135;136;137;138;139;140;141;142;143;144;145;146;147~;148;149;150;151;152;153;154;155;156;157;158;159;160;161;162;163;164;165;301;302;303;304;305;306;307;189".


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


def var recid-contrato as recid.
def var i as int.            
find clien where clien.clicod = p-clicod no-lock.

def  shared temp-table tp-contrato like contrato
    field exportado as log
    field atraso as int
    field vlpago as dec
    field vlpendente as dec
    field origem as char
    field destino as char.
    
def temp-table bkp-tp-contrato like tp-contrato.    
    
def  shared temp-table tp-titulo like titulo
    index dt-ven titdtven
    index titnum empcod titnat modcod etbcod clifor titnum titpar.

def new shared temp-table tt-recib
        field rectit as recid
        field titnum like titulo.titnum
        field ordpre as int.
 
def new shared var vtot like titulo.titvlcob.
def new shared var vjuro-ac as dec.
def new shared var vparcela like titulo.titvlcob.
def new shared var vplano as int format "99".

def temp-table wf-tit like titulo.
def new shared temp-table wf-titulo like titulo.
def new shared temp-table wf-contrato like contrato.
def var vokj as log.
def var vgera like contrato.contnum.
def var wcon as int.
def var vday as int.
def var vmes as int.
def var vano as int.
def var vezes as int format ">9".
def var vdtven like titulo.titdtven init today.
def var ventrada as dec.
def var juro-alt as dec.
def var vjuro-ori as dec.
def var vcond as char format "x(26)"  extent 11.
def var valor_cobrado as dec extent 11.
def var valor_juro    as dec extent 11.
def var valor_acre    as dec extent 11.

def var valor_novacao as dec extent 11.
def var vdata as date.

def var vtit as char.
def var ljuros as log.
def var vnumdia as int.
def var per_acr as dec.
def var per_des as dec.
def var per_cor as dec.
def var vtitj as dec.
def var vtitvlp as dec.
def var val-origem as dec.
def var vok as log.
def var lp-ok as log.
def var nov31 as log.
def var vdia as int.
def var vdata-futura as date init today.
def var vv as int.
def var vbanco as int init 1.

for each tp-contrato.
        create bkp-tp-contrato.
        buffer-copy tp-contrato to bkp-tp-contrato.
end.        
    
    assign
        vbanco = 1 .
    
    /* 16.01.2020 - Testes Elegivel Feirao */
    
        par-valor = "".
        run le_tabini.p (setbcod, 0, 
                               "CYBER_DATAEMI_EF", OUTPUT par-valor) . 
        vef_dataemi = date(int(entry(2,par-valor,"/")),
                           int(entry(1,par-valor,"/")),
                           int(entry(3,par-valor,"/")))
                               no-error.
        if vef_dataemi = ?
        then vef_dataemi = today.

        par-valor = "".
        run le_tabini.p (setbcod, 0, 
                               "CYBER_NDIAS_EF", OUTPUT par-valor) . 
        vef_dias = int(par-valor) no-error.
        if vef_dias = ?
        then vef_dias = 0.
    /* 16.01.2020 */

    
    vdia = 0.
    for each tp-titulo:
        find first tp-contrato where
                   tp-contrato.contnum = int(tp-titulo.titnum)
                and tp-contrato.exportado = yes   no-error.
        if not avail tp-contrato
        then do:
            /*delete tp-titulo.*/
            next.
        end.    
        else do:
            if tp-titulo.titdtemi > vef_dataemi
            then do:
                tp-contrato.exportado = no.
                /*delete tp-titulo.*/
            end.
        end.
    end.
    
    /* 17.01.2020 */
    def var velegivel as log.
    for each tp-titulo break by tp-titulo.titnum.
        if first-of(tp-titulo.titnum)
        then do:
            velegivel = no.
        end.    
        vdia = today - tp-titulo.titdtven.
        if vdia >= vef_dias
        then do:
            velegivel = yes.
        end.
        if last-of(tp-titulo.titnum)
        then  do:
            find first tp-contrato where 
                    tp-contrato.contnum = int(tp-titulo.titnum).
            if tp-contrato.exportado = yes
            then do:
                tp-contrato.exportado = velegivel.
            end.    
        end.
    end.
    
    for each tp-titulo:
        
        find first tp-contrato where
                   tp-contrato.contnum = int(tp-titulo.titnum)
                and tp-contrato.exportado = yes   no-error.
        if not avail tp-contrato
        then do:
            /*delete tp-titulo.*/
            next.
        end.    
    end.

    find first tp-contrato where tp-contrato.exportado = yes no-error.
    if not avail tp-contrato
    then do on endkey undo, retry:
        for each tp-contrato .
            delete tp-contrato.
        end.     
        for each bkp-tp-contrato.
            create tp-contrato.
            buffer-copy bkp-tp-contrato to tp-contrato.
        end.    
        message "Cliente Sem Contratos Elegiveis"
            view-as alert-box.
        return.
    end.    

    
    lp-ok = no.
    nov31 = no.
    
    do:
        
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
        disp vtitj label "JURO" colon 20 with frame f-cond.
        disp vplano colon 20  with frame f-cond.
        if vplano > 0
        then display vcond[vplano] no-label with frame f-cond.

        
        if vezes > 1
        then do:

        do on error undo, retry:
            if vplano > 6
            then ventrada = vtot * .20.
            else ventrada = vtot / vezes.
            disp ventrada label "Entrada" colon 20 with frame f-cond.

            update ventrada 
                with frame f-cond.

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
            disp vdata label "1o Vencimento"  colon 20 with frame f-cond.
        end.
        else    
        do on error undo:
            update vdata with frame f-cond.
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
            disp vdata  with frame f-cond.
        end.
    end. 
 
    
        hide frame f-cond no-pause.
        hide frame f-plano no-pause.
        p-ok = no.
        if vplano > 0
        then do:
            vparcela = vezes.
            run cob/novacordo-create.p(input p-clicod, 
                             input vparcela, 
                             input vcond[vplano],
                             input ventrada,
                             input vdata,
                             input yes,
                             input vtitobs,
                             output p-ok). 
        end.                             
        if p-ok
        then do:
            bell.
            message color red/with
            "ACORDO GERADO COM SUCESSO!"
            view-as alert-box.
            leave.
        end.      
    
procedure p-disp-planos:

 
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
            valor_juro[vv] = (vprincipal + vjuro) * .05.
            valor_novacao[vv] = vprincipal + vjuro + valor_juro[vv].
        end.
        if vv = 2 
        then do: 
            vjuro       = valor_juro[vv].
            vprincipal  = valor_cobrado[2].    
            valor_juro[vv] = (vprincipal + vjuro) * .10.
            valor_novacao[vv] = vprincipal + vjuro + valor_juro[vv].
        end.
        if vv = 3 
        then do: 
            vjuro       = valor_juro[vv].
            vprincipal  = valor_cobrado[3].    
            valor_juro[vv] = (vprincipal + vjuro) * .15.
            valor_novacao[vv] = vprincipal + vjuro + valor_juro[vv].
        end.
        if vv = 4 
        then do: 
            vjuro       = valor_juro[vv].
            vprincipal  = valor_cobrado[4].    
            valor_juro[vv] = (vprincipal + vjuro) * .35.
            valor_novacao[vv] = vprincipal + vjuro + valor_juro[vv].
        end.
        if vv = 5 
        then do: 
            vjuro       = valor_juro[vv].
            vprincipal  = valor_cobrado[5].    
            valor_juro[vv] = (vprincipal + vjuro) * .40.
            valor_novacao[vv] = vprincipal + vjuro + valor_juro[vv].
        end.
        if vv = 6
        then do:
            vjuro       = valor_juro[vv].
            vprincipal  = valor_cobrado[vv].
            valor_juro[vv] = (vprincipal /*+ vjuro*/) * .10.
            valor_novacao[vv] = vprincipal + /*vjuro +*/ valor_juro[vv].
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
            find first tp-contrato where
                       tp-contrato.contnum = int(tp-titulo.titnum)
                    and tp-contrato.exportado = yes   no-error.
            if not avail tp-contrato
            then next.
            
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

                    find tabjur where tabjur.nrdias = vnumdia and
                                      tabjur.etbcod = 0
                                no-lock no-error.
                    if not avail tabjur
                    then do:
                        hide message no-pause. message "Fator para" vnumdia
                        "dias de atraso, nao cadastrado".
                    end.

                assign vtot    = vtot    + tp-titulo.titvlcob
                       vtitvlp = vtitvlp + (tp-titulo.titvlcob * tabjur.fator ) 
                       
                       vtitvlpf = vtitvlpf + tp-titulo.titvlcob 
                       vtitvlpf-vencido = vtitvlpf-vencido 
                                            + tp-titulo.titvlcob
                       vtitvlpf30   = vtitvlpf30 + tp-titulo.titvlcob .

                    /* #1 26.06.20 */
                if tp-titulo.tpcontrato <> ""
                then vtitvlpf = vtitvlpf - (tp-titulo.titvlcob  * .20).
                else vtitvlpf = vtitvlpf + (tp-titulo.titvlcob  * .30).

                vjuro-ac = vtitvlpf - vtot.
                
                if vjuro-ac < 0
                then vjuro-ac = 0.
                         
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
                        /*
                        vtitvlpf = vtitvlpf + dd.
                        */
                        
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
                    /* #1 26.06.20 */
                    if tp-titulo.tpcontrato <> ""
                    then vtitvlpf = vtitvlpf - (tp-titulo.titvlcob * .20).
                    else vtitvlpf = vtitvlpf + (tp-titulo.titvlcob * .30).
                    
                    
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
                 vtit = "[ 1]  6  vezes(1+5) "
                 n-par = 6.
        if vv = 2
        then assign
                 vtit = "[ 2] 10 vezes(1+9) "
                 n-par = 10.
        if vv = 3
        then assign
                 vtit = "[ 3] 15 vezes(1+14)"
                 n-par = 15.
        if vv = 4
        then assign
                 vtit = "[ 4] 20 vezes(1+19)"
                 n-par = 20.
        if vv = 5
        then assign
                 vtit = "[ 5] 25 vezes(1+24)"
                 n-par = 25.
        if vv = 6
        then assign
                 vtit = "[ 6] 10 vezes(1+9) "
                 n-par = 10.
        if vv = 7
        then assign
                 vtit = "[ 7]  1 vez(A Vista) "
                 n-par = 1.
        if vv = 8
        then assign
                 vtit = "[ 8]  5 vezes(1+4 s/juro) "
                 n-par = 5.
        if vv = 9
        then assign
                 vtit = "[ 9] 10 vezes(1+9 s/juro) "
                 n-par = 10.
        if vv = 10
        then assign
                 vtit = "[10] 15 vezes(1+14 s/juro) "
                 n-par = 15.
        if vv = 11
        then assign
                 vtit = "[11] 20 vezes(1+19 s/juro)"
                 n-par = 20.
        if vok 
        then assign vcond[vv]         = vtit
                    valor_cobrado[vv] = vtot 
                    valor_juro[vv]    = if true /*par-feirao*/
                                        then 0
                                        else  vtitj  
                    valor_acre[vv]    = if vv < 7 then 0
                                    else if vtitvlpf - vtot >= 0
                                         then vtitvlpf - vtot
                                         else 0
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
    
    
    find first tt-lib11 where tt-lib11.etbcod = setbcod no-lock no-error.
    
        display 
           vdtven label  "Maior Atraso" 
           vdia label "Dias" colon 40
                valor_cobrado[1]       label "Divida" colon 60
                 skip
            "           PLANOS        Calculada" 
                        "              FEIRAO        Calculada" skip

            vcond[1] no-label colon 2 valor_novacao[1] no-label 
                vcond[7] colon 40 no-label valor_novacao[7] no-label 
            
            vcond[2] no-label colon 2 valor_novacao[2]       no-label
                vcond[8] colon 40 no-label valor_novacao[8] no-label 
            vcond[3] no-label colon 2 valor_novacao[3]     no-label

                vcond[9] colon 40 no-label valor_novacao[9] no-label 
            
            vcond[4] no-label colon 2 valor_novacao[4]      no-label
                vcond[10] colon 40 no-label valor_novacao[10] no-label 
            
            vcond[5] no-label colon 2
            valor_novacao[5] no-label
                vcond[11] colon 40 no-label valor_novacao[11] no-label 

                with frame f-plano side-label 
                    centered title " CONDICOES ACORDO FEIRAO " width 80
                    row 6 overlay. 
     
        if vplano6
        then disp vcond[6] no-label   colon 2
            valor_novacao[6]  no-label
                with frame f-plano.

    assign
        vjuro-ori = vtitj 
        vtitj = valor_juro[1]
        vtitj = vjuro-ori.

    do on error undo, retry:
        vplano = 0.
        disp vtitj with frame f-cond.
        update vplano label "Plano" colon 20
            with frame f-cond row 16 side-label centered no-box color message.
            
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
    end.                    
    
    assign vtot    = valor_novacao[vplano]
           vtitj   = valor_juro[vplano]
           vtitvlp = valor_novacao[vplano].
        disp vtitj with frame f-cond.
                        
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
               "jeane|732891",
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
    
    run cob/p-valida-senha-token.p (input par-user,
                                    input vsenauto,
                                    output sresp).


    if sresp
    then vtitobs = vtitobs + "LIBERA-PLANO-NOVACAO-TOKEN=" + 
                     replace(par-user,"|","_") + "|".

    hide frame fsenauto no-pause.
    hide frame fvuser no-pause.

end procedure.



