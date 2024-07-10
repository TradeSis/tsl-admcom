/* helio 28022022 - iepro - ajuste relatorio divergencia de juros */


{admcab.i}

run fin/reldivjur.p (yes,no). /* nova versao */

/*****DESCONTINUADO
def var vmod-sel as char.

def var ljuros as l.
def buffer btitulo for titulo.
def var vlimite as dec format ">,>>9.99".
def var wvlparcial as dec.
def var vclinom like clien.clinom.
def var    wdti like titulo.titdtven label "Periodo".
def var    wdtf like titulo.titdtven.
def buffer wtitulo for titulo.
def var ndias as int format ">>9".
def var wjuro   like titulo.titjuro.
def var wjuromen like titulo.titjuro.
def var wjuromai like titulo.titjuro.
def var vldev   like titulo.titjuro.
def var vdif    like titulo.titjuro format "->,>>>,>>9.9".
def var vdifmen like titulo.titjuro format "->,>>>,>>9.9".
def var vdifmai like titulo.titjuro format "->,>>>,>>9.9".
def var vljur   like titulo.titjuro format ">>,>>9.9".
def var vlmul   like titulo.titjuro format ">>,>>9.9".
def var jucob   like titulo.titjuro format ">>,>>9.9".
def var jucobmen like titulo.titjuro format ">>,>>9.9".
def var jucobmai like titulo.titjuro format ">>,>>9.9".
def var vlcob   like titulo.titjuro format ">>,>>9.9".
def var wvlpri  like titulo.titvlcob.
def var wvlpag  like titulo.titvlpag. 
def var wvlprimen like titulo.titvlcob.
def var wvlprimai like titulo.titvlcob.
def var vetbcod like estab.etbcod.
def stream stela.
form with down frame fdet.

form vetbcod colon 18
     estab.etbnom   no-label colon 30
     wdti           colon 18  " A"
     wdtf           colon 35  no-label
                    with side-labels width 80 frame f1.
                    
def temp-table tt-tit
    field etbcod like estab.etbcod
    field pre01  like plani.platot format "->,>>>,>>9.9"
    field pre02  like plani.platot format "->,>>>,>>9.9"
    field cob01  like plani.platot format "->,>>>,>>9.9"
    field cob02  like plani.platot format "->,>>>,>>9.9"
    field cal01  like plani.platot format "->,>>>,>>9.9"
    field cal02  like plani.platot format "->,>>>,>>9.9"
    field dif01  as dec format "->>>>9.9"
    field dif02  as dec format "->>>>9.9".

def NEW SHARED temp-table tt-modalidade-selec /* #1 */
    field modcod as char.

wdti = today.
wdtf = wdti + 30.

repeat: 
 wjuro = 0.
 wjuromen = 0.
 wjuromai = 0.
 vldev    = 0.
 vdif     = 0.
 vdifmen   = 0.
 vdifmai   = 0.
 vljur     = 0.
 vlmul     = 0.
 jucob     = 0.
 jucobmen  = 0.
 jucobmai  = 0.
 vlcob     = 0.
 wvlpri    = 0.
 wvlprimen = 0.
 wvlprimai = 0.
 wvlpag = 0.

def var varquivo as char.
    for each tt-tit:
        delete tt-tit.
    end.

    update vetbcod with frame f1.

    if vetbcod <> 0
    then do:
        find estab where estab.etbcod = vetbcod no-lock.
        display estab.etbnom with frame f1.
    end.
    else disp "Geral" @ estab.etbnom with frame f1.

    update wdti validate(input wdti <> ?, "Data deve ser Informada")
           with frame f1.

    update wdtf validate(input wdtf >= input wdti, "Data Invalida")
           with frame f1.
    update vlimite label "Dif.Limite" with frame f1.
    
    assign sresp = false.
    update sresp label "Seleciona Modalidades?" colon 25
           help "Não = Modalidade CRE Padrão / Sim = Seleciona Modalidades"
           with side-label
           width 80 frame f1.
              
    if sresp
    then run selec-modal.p ("REC"). /* #1 */
    else do:
        create tt-modalidade-selec.
        assign tt-modalidade-selec.modcod = "CRE".
    end.

    assign vmod-sel = "  ".
    for each tt-modalidade-selec.
        assign vmod-sel = vmod-sel + tt-modalidade-selec.modcod + "  ".
    end.      
    display vmod-sel format "x(40)" no-label with frame f1.

    output stream stela to terminal.
    
    {confir.i 1 "Listagem Previsao"}

    if opsys = "UNIX"
    then varquivo = "/admcom/relat/divjurb5l." + string(time).
    else varquivo = "l:~\relat~\divjurb5w." + string(time). 
    
    {mdadmcab.i
        &Saida     = "value(varquivo)"
        &Page-Size = "64"
        &Cond-Var  = "150"
        &Page-Line = "66"
        &Nom-Rel   = """DIVJURB5"""
        &Nom-Sis   = """SISTEMA CREDIARIO"""
        &Tit-Rel   = """LISTAGEM DE CONFERENCIA DE JUROS - PERIODO DE "" +
                        STRING(WDTI) + "" A "" + STRING(WDTF) +
                        "" FILIAL "" + STRING(vetbcod)"
        &Width     = "150"
        &Form      = "frame f-cab"}
    for each estab where if vetbcod = 0
                         then true
                         else estab.etbcod = vetbcod no-lock:
            wjuro = 0. 
            wjuromen = 0. 
            wjuromai = 0. 
            vldev    = 0. 
            vdif     = 0. 
            vdifmen   = 0. 
            vdifmai   = 0. 
            vljur     = 0. 
            vlmul     = 0. 
            jucob     = 0. 
            jucobmen  = 0. 
            jucobmai  = 0. 
            vlcob     = 0. 
            wvlpri    = 0. 
            wvlprimen = 0. 
            wvlprimai = 0. 
            wvlpag = 0.
 
    for each tt-modalidade-selec no-lock,
        each titulo use-index etbcod  where
             titulo.etbcobra  = estab.etbcod    and 
             titulo.titdtpag >=  input wdti     and
             titulo.titdtpag <=  input wdtf     and
             titulo.modcod    =  tt-modalidade-selec.modcod no-lock.
    
    /*
    for each titulo where 
            clifor = 1101111751 and
            titnum = "1101136766" and
            titdtpag = 04/22/2016 no-lock.
      */
      
        if titulo.etbcobra = ? or
           titulo.moecod   = "NOV" or
           titulo.moecod   = "DEV" /* 19022021 helio*/
        then next.
        /*
        if acha("PAGAMENTO-PARCIAL",titulo.titobs[1]) <> ?
        then next.
        if acha("PARCIAL",titulo.titobs[1]) <> ?
                then next.
        */        
        display stream stela titulo.etbcobra
                             titulo.titdtpag
                             titulo.titnum with 1 down centered. pause 0.
        find first btitulo where
             btitulo.empcod    =  wempre.empcod       and
             btitulo.titnat    =  no                  and
             btitulo.modcod    =  "CRE"               and
             btitulo.etbcod    = titulo.etbcod        and
             btitulo.clifor    =  titulo.clifor       and
             btitulo.titnum    =  titulo.titnum       and
             btitulo.titnumger = titulo.titnum and
             btitulo.titparger = titulo.titpar
             no-lock no-error.

        wvlpag = titulo.titvlpag.
        if available btitulo
        then do:
            if btitulo.titnumger = titulo.titnum
            then assign
                    wvlpri = if titulo.titvlcob > btitulo.titvlcob
                          then titulo.titvlcob - btitulo.titvlcob
                          else btitulo.titvlcob - titulo.titvlcob
                    wvlpag = wvlpri + btitulo.titvlcob.
            else wvlpri = titulo.titvlcob.
        end.
        else wvlpri = titulo.titvlcob.

        find clien where clien.clicod = titulo.clifor no-lock no-error.
        if avail clien
        then vclinom = clien.clinom.
        else vclinom = " ".

        ndias = titulo.titdtpag - titulo.titdtven.

        /*********************  ************************/

        if  titulo.titdtpag > titulo.titdtven
        then do:
            ljuros = yes.
            if titulo.titdtpag - titulo.titdtven = 2
            then do:
                find dtextra where exdata = titulo.titdtpag - 2 
                        no-lock no-error.
                if weekday(titulo.titdtpag - 2) = 1 or avail dtextra
                then do:
                    find dtextra where exdata = titulo.titdtpag - 1 
                            no-lock no-error.
                    if weekday(titulo.titdtpag - 1) = 1 or avail dtextra
                    then ljuros = no.
                end.
            end.
            else do:
                if titulo.titdtpag - titulo.titdtven = 1
                then do:
                    find dtextra where exdata = titulo.titdtpag - 1 
                                no-lock no-error.
                    if weekday(titulo.titdtpag - 1) = 1 or avail dtextra
                    then ljuros = no.
                end.
            end.
            ndias = if not ljuros
                    then 0
                    else titulo.titdtpag - titulo.titdtven.
        end.
        else ndias = 0.

        if  ndias > 0 then do:
            {sel-tabjur.i titulo.etbcobra ndias}.
            /*
            find tabjur where
                 tabjur.nrdias = ndias no-lock no-error.
            */     
            if  avail tabjur then do:
                assign
                 jucob = (wvlpri * tabjur.fator) - wvlpri.
            end.
        end.
        /*
        message titulo.titvlpag titulo.titvlcob wvlpri wvlpag. pause.
        wjuro = titulo.titvlpag - titulo.titvlcob.
        */
        
        wjuro = wvlpag - titulo.titvlcob.

        if ndias >= 0
        then do:
            assign
                vldev = wvlpri + (titulo.titdtpag - titulo.titdtven)
                        * wjuro
                vdif  = (titulo.titvlpag - (wvlpri + jucob)).
        vdif = wjuro - JUCOB.

        if ndias > 0 and ndias <= 180
        /*
        /*chamado 38429*/
        and titulo.titpar < 30
        */
        then assign wvlprimen = wvlprimen + wvlpri
                    wjuromen  = wjuromen  + wjuro
                    jucobmen  = jucobmen  + jucob
                    vdifmen   = vdifmen   + vdif.
        if ndias > 180
        then assign wvlprimai = wvlprimai + wvlpri
                    wjuromai  = wjuromai  + wjuro
                    jucobmai  = jucobmai  + jucob
                    vdifmai   = vdifmai   + vdif.
        end.
        
        find first tt-tit where tt-tit.etbcod = titulo.etbcobra no-error.
        if not avail tt-tit
        then do:
            create tt-tit.
            assign tt-tit.etbcod = titulo.etbcobra.
        end.
        
        assign tt-tit.pre01  = wvlprimen 
               tt-tit.cob01  = wjuromen 
               tt-tit.cal01  = jucobmen 
               tt-tit.dif01  = vdifmen   
               tt-tit.pre02  = wvlprimai  
               tt-tit.cob02  = wjuromai    
               tt-tit.cal02  = jucobmai    
               tt-tit.dif02  = vdifmai.    
    end.
    end.      
    for each tt-tit by tt-tit.etbcod.
        
        display tt-tit.etbcod column-label "Fl."  
                tt-tit.pre01(total)  column-label "Vlr.Prest!<= 180"
                tt-tit.cob01(total)  column-label "Jur.Cob.!<= 180"
                tt-tit.cal01(total)  column-label "Jur.Cal.!<= 180"
                tt-tit.dif01(total)  column-label "Dif.!<= 180"
                tt-tit.pre02(total)  column-label "Vlr.Prest!> 180"
                tt-tit.cob02(total)  column-label "Jur.Cob!> 180"
                tt-tit.cal02(total)  column-label "Jur.Cal!> 180"
                tt-tit.dif02(total)  column-label "Dif.!> 180"
                (pre01 + pre02)(total) column-label "Total!Prest." 
                (cob01 + cob02)(total) column-label "Total!Cob." 
                (cal01 + cal02)(total) column-label "Total!Cal."  
                (dif01 + dif02)(total) column-label "Total!Dif."
                    with frame f3 down width 155.  
   
    end.
    output close.
    output stream stela close.
    if opsys = "UNIX"
    then do:
        run visurel.p(varquivo,"").
    end.
    else do:
        {mrod.i}.
    end.
end.
*****/

