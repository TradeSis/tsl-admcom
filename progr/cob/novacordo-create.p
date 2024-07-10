{admcab.i}

def input parameter p-clicod like clien.clicod.
def input parameter vparcelas as int.
def input parameter vcond-plano as char.
def input parameter ventrada as dec.
def input parameter vdtvalid as date.
def input parameter par-feirao as log.
def input parameter vtitobs as char.
def output parameter ret-ok as log.

def var nov31 as log init yes.

def var vday as int.
def var vmes as int.
def var vano as int.
def var vi as int.

def temp-table tj-titulo like titulo.

def shared temp-table tp-contrato like contrato
    field exportado as log
    field atraso as int
    field vlpago as dec
    field vlpendente as dec
    field origem as char
    field destino as char
     .
    
def shared temp-table tp-titulo like titulo
    index dt-ven titdtven
    index titnum empcod titnat modcod etbcod clifor titnum titpar.

def buffer b-tp-titulo for tp-titulo.

def shared var vtot like titulo.titvlcob.
def shared var vjuro-ac as dec.
def var vtotal as dec.
def var vpend as dec.
def var vpago as dec.
def var val-ori as dec.
def var vchar1 as char.
def var vp1 as int.
def var vp2 as int.

def var vbanco as int init 1.

def var p-juro as dec extent 25
    init[0,3,3,3,4,5,6.25,7.50,8.75,10,11,12,13,14,15,19,23,27,31,35,36,37,
    38,39,40].
 
val-ori = 0.
vchar1 = "".
def var vtot-ori as dec.
def var vdtven as date.
vdtven = today.
def var lp-ok as log.
lp-ok = no.

for each tp-contrato where 
         tp-contrato.clicod = p-clicod and
         tp-contrato.exportado no-lock:
    assign vpend = 0 vp1 = 0 vp2 = 0.

    vtot-ori = vtot-ori + tp-contrato.vlpendente.
    
    for each tp-titulo where
             tp-titulo.clifor = tp-contrato.clicod and
             tp-titulo.titnum = string(tp-contrato.contnum) and
             tp-titulo.titsit = "LIB"
             no-lock by tp-titulo.titpar :
        vpend = vpend + tp-titulo.titvlcob.
        val-ori = val-ori + tp-titulo.titvlcob.
        if vp1 = 0 or tp-titulo.titpar < vp1
        then vp1 = tp-titulo.titpar.
        if tp-titulo.titpar > vp2
        then vp2 = tp-titulo.titpar.
        if tp-titulo.titdtven < vdtven
                then vdtven = tp-titulo.titdtven.
                
        if tp-titulo.tpcontrato = "L" /***titpar > 50***/
        then do:
            find first b-tp-titulo where
                       b-tp-titulo.clifor = tp-contrato.clicod and
                       b-tp-titulo.titnum = string(tp-contrato.contnum) and
                       b-tp-titulo.tpcontrato <> "L" /***titpar < 50***/
                       no-lock no-error.
            if not avail b-tp-titulo           
            then lp-ok = yes.
        end.
    end.
    if tp-contrato.vltotal > 0
    then vpago = vpago + (tp-contrato.vltotal - vpend).

    /*if tp-contrato.banco = 10
    then*/ vbanco = 10.

    vi = vi + 1.
    vchar1 = vchar1 + "CONTRATO" + string(vi) + "=" +
             string(tp-contrato.contnum) + ";" + string( tp-contrato.vlpendente) + 
             ";" + string(vp1) + ";" + string(vp2) + "|".
             

end.

if vtot-ori <> val-ori
then do:
    ret-ok = no.
    return.
end.        

def var vdia as int.
vdia = (today - vdtven).

nov31 = no.
if  vdia >= 30  and
    vdia <= 270 and
    lp-ok = no
then nov31 = yes.
                              
def var val-juro as dec.
def var vliquido as dec.
def var valorparc as dec.
def var vtitdtven as date.

if vjuro-ac = 0 and not par-feirao
then do:
    run cal-juro-atraso.
    vtot = vtot + vjuro-ac.
end.
else val-juro = vtot - vtot-ori - vjuro-ac.
if par-feirao
then do:
    vjuro-ac = 0 /*vjuro-ac + val-juro*/ .
    val-juro = 0.
end.

def var vokj as log.
def var juro-alt as dec.
def var vjuro-ori as dec.

repeat on error undo:

    if keyfunction(lastkey) = "END-ERROR"
    then leave.
    if vcond-plano = ""
    then if vparcelas > 1
         then assign
              valorparc = vtot / (vparcelas)
              val-juro = (vtot-ori + vjuro-ac) * (p-juro[int(vparcelas)] / 100).
            
    ventrada  = if ventrada = 0
                then valorparc
                else ventrada.
    vliquido  = vtot - ventrada.

    disp vtot-ori   format "zzz,zzz,zz9.99" label "        Valor original"
         vparcelas  format "zzzzzzzzzzzzz9" label "Quantidade de parcelas"
         vjuro-ac   format "zzz,zzz,zz9.99" label "        Juro do Atraso"   
         val-juro   format "zzz,zzz,zz9.99" label "        Juro do Acordo"
         vtot       format "zzz,zzz,zz9.99" label "       Valor do Acordo"
         ventrada   format "zzz,zzz,zz9.99" label "      Valor da Entrada"
         valorparc  format "zzz,zzz,zz9.99" label "      Valor da Parcela"
         vliquido   format "zzz,zzz,zz9.99" label "         Valor Liquido"
         vdtvalid   format "99/99/9999"     label "      Primeira parcela"
         with frame f-ef 1 down centered  row 8 width 60
         title " Valores ACORDO - " + vcond-plano
         .
    
    vjuro-ori = val-juro.
    
    if vparcelas = 0
    then update vparcelas validate(vparcelas > 1 and
               vparcelas < 26, "Informe numero de parcelas entre 1 e 25.")
            with frame f-ef.
 
    
    if not par-feirao
    then val-juro = (vtot-ori + vjuro-ac) * (p-juro[int(vparcelas)] / 100).
    disp val-juro with frame f-ef.

    juro-alt = vjuro-ac.
    disp vjuro-ac with frame f-ef.
    
    if vcond-plano = ""
    then repeat :
        update vjuro-ac with frame f-ef.
        if vjuro-ac = juro-alt
        then leave.

        vokj = yes.
        /*
        if vdia >= 60 and vdia <= 360 and 
            vjuro-ac < juro-alt - (juro-alt * .100)
        then  vokj = no.
        else if vdia >= 361 and vdia <= 600 and
                                vjuro-ac < juro-alt - (juro-alt * .100)
        then  vokj = no.
        else if vdia > 600 and vjuro-ac < juro-alt / 1
        then vokj = no.
        */
        
        if vokj = no
        then do:
            bell.
            message color red/with
                "Alteração no valor de juro não permitida." 
                view-as alert-box.
            next.
        end.
        leave.
    end.    
    if keyfunction(lastkey) = "END-ERROR"
    then next.

    if not par-feirao
    then vtot = vtot-ori + val-juro + vjuro-ac.
    disp vtot with frame f-ef.
             
    disp val-juro with frame f-ef.
    
    if setbcod = 999 and vcond-plano = "" 
    then update val-juro with frame f-ef.

    /*
    if vjuro-ori <> val-juro
    then do:
        vtot = vtot-ori + val-juro + vjuro-ac.
        next.
    end.
    */
        
    if not par-feirao
    then vtot = vtot-ori + val-juro + vjuro-ac.
    disp vtot with frame f-ef.

    if vcond-plano = ""
    then ventrada = vtot / vparcelas.
    disp ventrada with frame f-ef.
    
    if vcond-plano = ""
    then  repeat:
        update ventrada with frame f-ef
                 side-label centered.
        if ventrada < valorparc
        then do:
            bell.
            message color red/with
            "Valor da entrada menor que o valor da parcela."
            view-as alert-box.
            ventrada = valorparc.
            next.
        end.  
        leave.  
    end.

    if keyfunction(lastkey) = "END-ERROR"
    then leave.
    
    vliquido = vtot - ventrada.

    if vliquido <> vtot
    then valorparc = vliquido / (vparcelas - 1).
    else valorparc = vtot / vparcelas.
    
    disp valorparc  with frame f-ef.

    disp vliquido vdtvalid with frame f-ef.

    if vcond-plano = ""
    then update vdtvalid with frame f-ef.
        
    if  vdtvalid = ? or
        vdtvalid < today 
    then do:
        bell.
        message color red/with
        "Problema na data de validade do acordo."
        view-as alert-box.
        undo.
    end.
            
    sresp = no.
    message "Confirma os valores do ACORDO?" update sresp.
    if not sresp
    then do:
        ret-ok = no.
        leave.
    end.    
    else do:
        ret-ok = yes.
        leave.
    end.
end.
 
if keyfunction(lastkey) = "END-ERROR"
then do:
    ret-ok = no.
    return.
end.
if ret-ok = no
then return.




def var vid_acordo as dec.
def var vint as int.
vint = 1.
repeat:
    vid_acordo = dec(string(vint,"9") + 
                string(today - 08/05/1985,"99999") +
                string(int(replace(string(time,"HH:MM"),":","")),"9999") +
            string(p-clicod,"9999999999"))
            .
    find novacordo where novacordo.id_acordo = vid_acordo no-lock no-error.
    if avail novacordo
    then do:
        vint = vint + 1.
        pause 1 no-message.
    end.    
    else leave.            
     
end.

do on error undo:
    create novacordo.
    assign
        novacordo.etb_acordo = setbcod
        novacordo.clicod = p-clicod
        novacordo.id_acordo = vid_acordo
        novacordo.dtinclu = today
        novacordo.valor_ori = val-ori
        novacordo.valor_acordo = ventrada + vliquido
        novacordo.valor_entrada = ventrada
        novacordo.valor_liquido = vliquido
        novacordo.qtd_parcelas = vparcelas
        novacordo.user_inclu = sfuncod
        novacordo.horinclu = time
        novacordo.situacao = "PENDENTE"
        novacordo.char1 = vchar1
        novacordo.destino = vbanco
        novacordo.dtvalidade = vdtvalid
        novacordo.motivo1 = vtitobs
        novacordo.Motivo5 = "JUROATRASO=" + string(vjuro-ac) +
                            "|JUROACORDO=" + string(val-juro) + 
                            "|VALORPARCELA=" + string(valorparc) +
                            "|"
        .
        if nov31 then novacordo.tipnova = 31.
                 else novacordo.tipnova = 51.
    
    create tit_acordo.
    tit_acordo.id_acordo = novacordo.id_acordo.
    tit_acordo.titpar    = 0.
    tit_acordo.titdtven  = today.
    tit_acordo.titvlcob  = ventrada.
    tit_acordo.titobs    = vtitobs.
    tit_acordo.tpcontrato = "N".
    tit_acordo.modcod    = "CRE".
     
    vday = day(vdtvalid).
    vmes = month(vdtvalid).
    vano = year(vdtvalid).
    
    
    
    do vi = 1 to (vparcelas - 1): 
        vtitdtven = date(vmes, 
                         IF VMES = 2 
                         THEN IF VDAY > 28 
                              THEN 28 
                              ELSE VDAY 
                         ELSE if VDAY > 30 
                              then 30 
                              else vday, 
                         vano).
        
        create tit_acordo.
        tit_acordo.id_acordo = novacordo.id_acordo.
        tit_acordo.titpar    = vi.
        tit_acordo.titdtven  = vtitdtven.
        tit_acordo.titvlcob  = round(vliquido / (vparcelas - 1),2) .

        tit_acordo.titobs    = vtitobs.
        tit_acordo.tpcontrato = "N".
        tit_acordo.modcod    = "CRE".
        
        vtotal = vtotal + tit_acordo.titvlcob.

        vmes = vmes + 1.
        if vmes > 12 
        then assign vano = vano + 1
                    vmes = 1.
        
        
    end.
    if vtotal < vliquido
    then do:
        find tit_acordo of novacordo where tit_acordo.titpar = 1 no-error.
        if not avail tit_acordo
        then find first tit_acordo of novacordo.
        tit_acordo.titvlcob = tit_acordo.titvlcob + (vliquido - vtotal).
    end.
    
    for each tp-contrato where 
         tp-contrato.clicod = p-clicod and
         tp-contrato.exportado no-lock:
        for each tp-titulo where
             tp-titulo.clifor = tp-contrato.clicod and
             tp-titulo.titnum = string(tp-contrato.contnum) and
             tp-titulo.titsit = "LIB"
             no-lock by tp-titulo.titpar :

             create tit_novacao.
             assign
                 tit_novacao.tipo = ""
                 tit_novacao.ger_contnum = ?
                 tit_novacao.id_acordo = string(novacordo.id_acordo)
                 tit_novacao.ori_empcod = tp-titulo.empcod
                 tit_novacao.ori_titnat = tp-titulo.titnat
                 tit_novacao.ori_modcod = tp-titulo.modcod
                 tit_novacao.ori_etbcod = tp-titulo.etbcod
                 tit_novacao.ori_clifor = tp-titulo.clifor
                 tit_novacao.ori_titnum = tp-titulo.titnum
                 tit_novacao.ori_titpar = tp-titulo.titpar
                 tit_novacao.ori_titdtemi = tp-titulo.titdtemi
                 tit_novacao.ori_titvlcob = tp-titulo.titvlcob
                 tit_novacao.ori_titdtpag = tp-titulo.titdtpag
                 tit_novacao.ori_titdtven = tp-titulo.titdtven
                 tit_novacao.dtnovacao = ?
                 tit_novacao.hrnovacao = ?
                 tit_novacao.etbnovacao = ?
                 tit_novacao.funcod = ?       
                 .
        end.
    end.
    
    

    ret-ok = yes.                          

    
end.    

procedure cal-juro-atraso:
    
    def var vdata-futura as date init today.
    def var ljuros as log.
    def var vnumdia as int.
    def var vtitvlp as dec.
    def var vtot-tit as dec.

    for each tj-titulo: delete tj-titulo. end.
    for each tp-contrato where 
         tp-contrato.clicod = p-clicod and
         tp-contrato.exportado no-lock:
        for each tp-titulo where
                 tp-titulo.clifor = tp-contrato.clicod and
                 tp-titulo.titnum = string(tp-contrato.contnum) and
                 tp-titulo.titsit = "LIB"
                 no-lock:
            create tj-titulo.
            buffer-copy tp-titulo to tj-titulo.
            if vdata-futura > tp-titulo.titdtven
            then do:
                 ljuros = yes.

                if vdata-futura - tp-titulo.titdtven = 3
                then do:
                    find dtextra where exdata = vdata-futura - 3 no-error.
                    if weekday(vdata-futura - 3) = 1 or avail dtextra
                    then do:
                        find dtextra where exdata = vdata-futura - 1 no-error.
                        if weekday(vdata-futura - 1) = 1 or avail dtextra
                        then ljuros = no.
                    end.
                end.


                if vdata-futura - tp-titulo.titdtven = 2
                then do:
                    find dtextra where exdata = vdata-futura - 2 no-error.
                    if weekday(vdata-futura - 2) = 1 or avail dtextra
                    then do:
                        find dtextra where exdata = vdata-futura - 1 no-error.
                        if weekday(vdata-futura - 1) = 1 or avail dtextra
         
                        then ljuros = no.
                    end.
                end.
                else do:
                    if vdata-futura - tp-titulo.titdtven = 1
                    then do:
                        find dtextra where exdata = vdata-futura - 1 no-error.
                        if weekday(vdata-futura - 1) = 1 or avail dtextra
                        then ljuros = no.
                    end.
                end.
                vnumdia = if not ljuros
                          then 0
                          else vdata-futura - tp-titulo.titdtven.

                if vnumdia > 1766
                then vnumdia = 1766.

                find first tabjur where 
                        tabjur.nrdias = vnumdia no-lock no-error.
                if  not avail tabjur
                then do:
                    message "Fator para" vnumdia
                    "dias de atraso, nao cadastrado". pause. undo.
                end.
                assign vtot-tit    = vtot-tit    + tp-titulo.titvlcob
                       vtitvlp = vtitvlp + 
                                (tp-titulo.titvlcob * tabjur.fator)
                     tj-titulo.titvljur = (tp-titulo.titvlcob * tabjur.fator)
                                - tp-titulo.titvlcob
                                .
                                 
        
            end.
            else do:

                do:   
                    vnumdia = tp-titulo.titdtven - today.
                
                    assign vtot-tit    = vtot-tit    + tp-titulo.titvlcob.   
                           vtitvlp = vtitvlp + tp-titulo.titvlcob.
                end.
            end.                    
        end.            
    end.
    vjuro-ac = truncate(vtitvlp - vtot-tit,3) .
    vjuro-ac = 0.
    for each tj-titulo:
        vjuro-ac = vjuro-ac + tj-titulo.titvljur.
    end.    
    
    if vjuro-ac < 0 
    then vjuro-ac = 0.
end procedure.
