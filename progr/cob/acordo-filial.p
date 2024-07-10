{admcab.i}

def input parameter p-clicod like clien.clicod.
def output parameter p-ok as log.

def var vtitobs as char.
def var vfator as dec.

def var vfeirao as log.
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


def var recid-contrato as recid.
def var i as int.

find clien where clien.clicod = p-clicod no-lock.

def  shared temp-table tp-contrato like contrato
    field exportado as log
    field atraso as int
    field vlpago as dec
    field vlpendente as dec
    field origem as char
    field destino as char
    .
    
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
def var vcond as char format "x(22)"  extent 6.
def var valor_cobrado as dec extent 6.
def var valor_juro    as dec extent 6.
def var valor_novacao as dec extent 6.
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

    
    
    assign
        vbanco = 1 .
    
    
    find first tp-contrato no-error.
    if not avail tp-contrato
    then leave.
    for each tp-titulo:
        find first tp-contrato where
                   tp-contrato.contnum = int(tp-titulo.titnum)
                and tp-contrato.exportado = yes   no-error.
        if not avail tp-contrato
        then do:
            delete tp-titulo.
        end.    
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

                    find tabjur where tabjur.nrdias = vnumdia and
                                      tabjur.etbcod = 0
                                no-lock no-error.
                    if not avail tabjur
                    then do:
                        hide message no-pause. message "Fator para" vnumdia
                        "dias de atraso, nao cadastrado".
                    end.
                    vfator = if avail tabjur
                              then  tabjur.fator
                              else 1.
                    assign vtot    = vtot    + tp-titulo.titvlcob
                           vtitvlp = vtitvlp + (tp-titulo.titvlcob * vfator). 
                
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
        
        /**
        display vdtven   label "Maior Atraso" 
                vdia     label "Dias de atraso" 
                with frame f-dias side-label centered. 
        pause.
        hide frame f-dias no-pause.
        */
    
        display 
           vdtven label  "Maior Atraso" 
           vdia label "Dias" colon 40
                valor_cobrado[1]       label "Divida" colon 60
                 skip
            "          PLANOS         Calculada" skip
            vcond[1] no-label colon 2
            valor_novacao[1] no-label 
            vcond[2] no-label colon 2
            valor_novacao[2]       no-label
            vcond[3] no-label colon 2
            valor_novacao[3]     no-label
            vcond[4] no-label colon 2
            valor_novacao[4]      no-label
            vcond[5] no-label colon 2
            valor_novacao[5] no-label
                with frame f-plano side-label 
                    centered title " CONDICOES ACORDO LOJA " width 80
                    row 6 overlay. 
     
        if vplano6
        then disp vcond[6] no-label   colon 2
            valor_novacao[6]  no-label
                with frame f-plano.

        assign
            vjuro-ori = vtitj 
            vtitj = valor_juro[1]
            vtitj = vjuro-ori.
    
        disp vtitj colon 20 with frame f-cond 
                row 16 color messages.   
    
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
             display vcond[1] 
                valor_cobrado[1]  
                valor_novacao[1]     
                vcond[2] 
                valor_novacao[2]
                vcond[3] 
                valor_novacao[3]      
                
                vcond[4]
                valor_novacao[4]  
                
                vcond[5]
                valor_novacao[5]  
                with frame f-plano.
            if vplano6
            then disp vcond[6] 
                valor_novacao[6]     
                    with frame f-plano.
        end.
        do on error undo, retry:
            vplano = 0.
            update vplano label "Plano" colon 20
                with frame f-cond side-label centered no-box
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
        display vcond[1] 
            valor_cobrado[1]  
            valor_novacao[1]     
            vcond[2] 
            valor_novacao[2]
            vcond[3] 
            valor_novacao[3]      
            
            vcond[4]
            valor_novacao[4]  
            
            vcond[5]
            valor_novacao[5]  
                with frame f-plano.
        if vplano6
        then disp vcond[6] 
            valor_novacao[6]     
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
            disp ventrada label "Entrada" colon 20
                with frame f-cond.
            do:
                update ventrada 
                    with frame f-cond.

                if ventrada < (vtot / vezes) - ((vtot / vezes) * .20)
                then do:
                    message "VALOR DE ENTRADA NAO AUTORIZADO".
                    undo, retry.
                end.
            end.
        
            vdata = today + 30.
            do on error undo:
                update vdata colon 20 
                        label "1o Vencimento" with frame f-cond.
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
    
     


        hide frame f-cond no-pause.
        hide frame f-plano no-pause.
        vparcela = vezes.
        run cob/novacordo-create.p(input p-clicod, 
                             input vparcela, 
                             input vcond[vplano],
                             input ventrada,
                             input vdata,
                             input no,
                             input vtitobs,
                             output p-ok). 
        
        if p-ok
        then do:
            bell.
            message color red/with
            "ACORDO GERADO COM SUCESSO!"
            view-as alert-box.
            leave.
        end.      
    
procedure p-disp-planos:

    display vcond[1] 
            valor_cobrado[1]
            valor_novacao[1] 
            vcond[2] 
            valor_novacao[2]    
            vcond[3]
            valor_novacao[3]
            vcond[4] 
            valor_novacao[4]  
            vcond[5]
            valor_novacao[5] 
                with frame f-plano.
 
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


