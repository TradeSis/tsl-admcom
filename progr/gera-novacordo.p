{admcab.i}

def input parameter p-clicod like clien.clicod.
def input parameter vplano as int.
def input parameter vcond-plano as char.
def output parameter ret-ok as log.

def var nov31 as log init yes.

def temp-table tj-titulo like titulo.

def shared temp-table tpb-contrato like contrato
    field exportado as log
    field atraso as int
    field vlpago as dec
    field vlpendente as dec
    field origem as char
    field destino as char
     .
    
def shared temp-table tpb-titulo like fin.titulo
    index dt-ven titdtven
    index titnum empcod titnat modcod etbcod clifor titnum titpar.

def buffer b-tpb-titulo for tpb-titulo.

def shared var vtot like titulo.titvlcob.
def shared var vjuro-ac as dec.
def var vtotal as dec.
def var vpend as dec.
def var vpago as dec.
def var val-ori as dec.
def var vchar1 as char.
def var vi as int.
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

for each tpb-contrato where 
         tpb-contrato.clicod = p-clicod and
         tpb-contrato.exportado no-lock:
    assign vpend = 0 vp1 = 0 vp2 = 0.

    vtot-ori = vtot-ori + tpb-contrato.vlpendente.
    
    for each tpb-titulo where
             tpb-titulo.clifor = tpb-contrato.clicod and
             tpb-titulo.titnum = string(tpb-contrato.contnum) and
             tpb-titulo.titsit = "LIB"
             no-lock by tpb-titulo.titpar :
        vpend = vpend + tpb-titulo.titvlcob.
        val-ori = val-ori + tpb-titulo.titvlcob.
        if vp1 = 0 or tpb-titulo.titpar < vp1
        then vp1 = tpb-titulo.titpar.
        if tpb-titulo.titpar > vp2
        then vp2 = tpb-titulo.titpar.
        if tpb-titulo.titdtven < vdtven
                then vdtven = tpb-titulo.titdtven.
                
        if tpb-titulo.tpcontrato = "L" /***titpar > 50***/
        then do:
            find first b-tpb-titulo where
                       b-tpb-titulo.clifor = tpb-contrato.clicod and
                       b-tpb-titulo.titnum = string(tpb-contrato.contnum) and
                       b-tpb-titulo.tpcontrato <> "L" /***titpar < 50***/
                       no-lock no-error.
            if not avail b-tpb-titulo           
            then lp-ok = yes.
        end.
    end.
    if tpb-contrato.vltotal > 0
    then vpago = vpago + (tpb-contrato.vltotal - vpend).

    /*if tpb-contrato.banco = 10
    then*/ vbanco = 10.

    vi = vi + 1.
    vchar1 = vchar1 + "CONTRATO" + string(vi) + "=" +
             string(tpb-contrato.contnum) + ";" + string(val-ori) + 
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
def var ventrada as dec.
def var vliquido as dec.
def var vparcelas as dec.
def var valorparc as dec.
def var vdtvalid as date.


if vjuro-ac = 0
then do:
    run cal-juro-atraso.
    vtot = vtot + vjuro-ac.
end.
else val-juro = vtot - vtot-ori - vjuro-ac.

    if vplano = 1 
    then vparcelas = 6.  
    if vplano = 2  
    then vparcelas = 10.  
    if vplano = 3  
    then vparcelas = 15.  
    if vplano = 4  
    then vparcelas = 20.
    if vplano = 5
    then vparcelas = 25.

def var vokj as log.
def var juro-alt as dec.
def var vjuro-ori as dec.

repeat on error undo:

    if keyfunction(lastkey) = "END-ERROR"
    then leave.
    if vparcelas > 1
    then assign
            valorparc = vtot / (vparcelas)
            val-juro = (vtot-ori + vjuro-ac) * (p-juro[int(vparcelas)] / 100).
            
    ventrada  = valorparc.
    vliquido  = vtot - ventrada.
    vdtvalid  = today.

    disp vtot-ori   format "zzz,zzz,zz9.99" label "        Valor original"
         vparcelas  format "zzzzzzzzzzzzz9" label "Quantidade de parcelas"
         vjuro-ac   format "zzz,zzz,zz9.99" label "        Juro do Atraso"   
         val-juro   format "zzz,zzz,zz9.99" label "        Juro do Acordo"
         vtot       format "zzz,zzz,zz9.99" label "       Valor do Acordo"
         ventrada   format "zzz,zzz,zz9.99" label "      Valor da Entrada"
         valorparc  format "zzz,zzz,zz9.99" label "      Valor da Parcela"
         vliquido   format "zzz,zzz,zz9.99" label "         Valor Liquido"
         vdtvalid   format "99/99/9999" label "    Validade do acordo"
         with frame f-ef 1 down centered  row 8 width 60
         title " Valores ACORDO - " + vcond-plano
         .
    
    
    vjuro-ori = val-juro.
    
    /*if vparcelas = 0
    then */
    update vparcelas validate(vparcelas > 1 and
               vparcelas < 26, "Informe numero de parcelas entre 1 e 25.")
            with frame f-ef.
 
    val-juro = (vtot-ori + vjuro-ac) * (p-juro[int(vparcelas)] / 100).
    disp val-juro with frame f-ef.

    juro-alt = vjuro-ac.
    repeat :
        update vjuro-ac with frame f-ef.
        if vjuro-ac = juro-alt
        then leave.
        /***
        if vjuro-ac > juro-alt
        then do:
            bell.
            message color red/with "Alteração no valor de juro não permitida." 
            view-as alert-box.
            next.
        end.
        ****/
        vokj = yes.
        if vdia >= 60 and vdia <= 360 and 
            vjuro-ac < juro-alt - (juro-alt * .33)
        then  vokj = no.
        else if vdia >= 361 and vdia <= 600 and
                                vjuro-ac < juro-alt - (juro-alt * .66)
        then  vokj = no.
        else if vdia > 600 and vjuro-ac < juro-alt / 20
        then vokj = no.
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

    vtot = vtot-ori + val-juro + vjuro-ac.
    disp vtot with frame f-ef.
             
    if setbcod = 999
    then update val-juro with frame f-ef.

    /*
    if vjuro-ori <> val-juro
    then do:
        vtot = vtot-ori + val-juro + vjuro-ac.
        next.
    end.
    */
        
    vtot = vtot-ori + val-juro + vjuro-ac.
    disp vtot with frame f-ef.

    ventrada = vtot / vparcelas.
    
    repeat:
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

    disp vliquido with frame f-ef.

    update vdtvalid with frame f-ef.
        
    if  vdtvalid = ? or
        vdtvalid < today 
    then do:
        bell.
        message color red/with
        "Problema na data de validade do acordo."
        view-as alert-box.
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
vint = 10.
repeat:
    vid_acordo = dec(string(vint,"99") + string(today,"99999999") +
            string(p-clicod,"9999999999"))
            .
    find novacordo where novacordo.id_acordo = vid_acordo no-lock no-error.
    if avail novacordo
    then vint = vint + 1.
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
        novacordo.Motivo5 = "JUROATRASO=" + string(vjuro-ac) +
                            "|JUROACORDO=" + string(val-juro) + 
                            "|VALORPARCELA=" + string(valorparc) +
                            "|"
        .
        if nov31 then novacordo.tipnova = 31.
                 else novacordo.tipnova = 51.
    
    for each tpb-contrato where 
         tpb-contrato.clicod = p-clicod and
         tpb-contrato.exportado no-lock:
        for each tpb-titulo where
             tpb-titulo.clifor = tpb-contrato.clicod and
             tpb-titulo.titnum = string(tpb-contrato.contnum) and
             tpb-titulo.titsit = "LIB"
             no-lock by tpb-titulo.titpar :

             create tit_novacao.
             assign
                 tit_novacao.tipo = ""
                 tit_novacao.ger_contnum = ?
                 tit_novacao.id_acordo = string(novacordo.id_acordo)
                 tit_novacao.ori_empcod = tpb-titulo.empcod
                 tit_novacao.ori_titnat = tpb-titulo.titnat
                 tit_novacao.ori_modcod = tpb-titulo.modcod
                 tit_novacao.ori_etbcod = tpb-titulo.etbcod
                 tit_novacao.ori_clifor = tpb-titulo.clifor
                 tit_novacao.ori_titnum = tpb-titulo.titnum
                 tit_novacao.ori_titpar = tpb-titulo.titpar
                 tit_novacao.ori_titdtemi = tpb-titulo.titdtemi
                 tit_novacao.ori_titvlcob = tpb-titulo.titvlcob
                 tit_novacao.ori_titdtpag = tpb-titulo.titdtpag
                 tit_novacao.ori_titdtven = tpb-titulo.titdtven
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
    for each tpb-contrato where 
         tpb-contrato.clicod = p-clicod and
         tpb-contrato.exportado no-lock:
        for each tpb-titulo where
                 tpb-titulo.clifor = tpb-contrato.clicod and
                 tpb-titulo.titnum = string(tpb-contrato.contnum) and
                 tpb-titulo.titsit = "LIB"
                 no-lock:
            create tj-titulo.
            buffer-copy tpb-titulo to tj-titulo.
            if vdata-futura > tpb-titulo.titdtven
            then do:
                 ljuros = yes.

                if vdata-futura - tpb-titulo.titdtven = 3
                then do:
                    find dtextra where exdata = vdata-futura - 3 no-error.
                    if weekday(vdata-futura - 3) = 1 or avail dtextra
                    then do:
                        find dtextra where exdata = vdata-futura - 1 no-error.
                        if weekday(vdata-futura - 1) = 1 or avail dtextra
                        then ljuros = no.
                    end.
                end.


                if vdata-futura - tpb-titulo.titdtven = 2
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
                    if vdata-futura - tpb-titulo.titdtven = 1
                    then do:
                        find dtextra where exdata = vdata-futura - 1 no-error.
                        if weekday(vdata-futura - 1) = 1 or avail dtextra
                        then ljuros = no.
                    end.
                end.
                vnumdia = if not ljuros
                          then 0
                          else vdata-futura - tpb-titulo.titdtven.

                if vnumdia > 1766
                then vnumdia = 1766.

                find first tabjur where 
                        tabjur.nrdias = vnumdia no-lock no-error.
                if  not avail tabjur
                then do:
                    message "Fator para" vnumdia
                    "dias de atraso, nao cadastrado". pause. undo.
                end.
                assign vtot-tit    = vtot-tit    + tpb-titulo.titvlcob
                       vtitvlp = vtitvlp + 
                                (tpb-titulo.titvlcob * tabjur.fator)
                     tj-titulo.titvljur = (tpb-titulo.titvlcob * tabjur.fator)
                                - tpb-titulo.titvlcob
                                .
                                 
        
            end.
            else do:

                do:   
                    vnumdia = tpb-titulo.titdtven - today.
                
                    assign vtot-tit    = vtot-tit    + tpb-titulo.titvlcob.   
                           vtitvlp = vtitvlp + tpb-titulo.titvlcob.
                end.
            end.                    
        end.            
    end.
    vjuro-ac = truncate(vtitvlp - vtot-tit,3) .
    vjuro-ac = 0.
    for each tj-titulo:
        vjuro-ac = vjuro-ac + tj-titulo.titvljur.
    end.    
end procedure.
