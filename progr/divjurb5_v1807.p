/* helio 28022022 - iepro - ajuste relatorio divergencia de juros */


{admcab.i}

run fin/reldivjur.p (no,yes). /* nova versao */

/*****DESCONTINUADO
{setbrw.i}

def var v-cont as integer.
def var v-cod  as char.
def var vmod-sel as char.

def temp-table tt-modalidade-padrao
    field modcod as char
    index pk modcod.
             
def temp-table tt-modalidade-selec
    field modcod as char
    index pk modcod.

form
   a-seelst format "x" column-label "*"
   tt-modalidade-padrao.modcod no-label
   with frame f-nome
       centered down title "Modalidades"
       color withe/red overlay.    
                                                        
create tt-modalidade-padrao.
assign tt-modalidade-padrao.modcod = "CRE".

for each profin no-lock.
    create tt-modalidade-padrao.
    assign tt-modalidade-padrao.modcod = profin.modcod.
end.

def var ljuros as l.
def buffer btitulo for titulo.
def var vlimite as dec format ">,>>9.99".
def var vclinom like clien.clinom.
def var    wdti like titulo.titdtven label "Periodo".
def var    wdtf like titulo.titdtven.
def var ndias as int format ">>9".
def var wjuro   like titulo.titjuro.
def var vldev   like titulo.titjuro.
def var vdif    like titulo.titjuro format "->,>>>,>>9.9".
def var vljur   like titulo.titjuro format ">>,>>9.9".
def var vlmul   like titulo.titjuro format ">>,>>9.9".
def var jucob   like titulo.titjuro format ">>,>>9.9".
def var vlcob   like titulo.titjuro format ">>,>>9.9".
def var wvlpri  like titulo.titvlcob.
def var vetbcod like estab.etbcod.
def var wvlpag like titulo.titvlpag.
def var stbjur as log format "Sim/Nao".
def var varquivo as char.
def stream stela.
form with down frame fdet.

form vetbcod colon 18
     estab.etbnom   no-label colon 30
     wdti           colon 18  " A"
     wdtf           colon 35  no-label
     with side-labels width 80 frame f1.
                    
def temp-table tt-etb
    field etbcod like estab.etbcod
    field pre01  like plani.platot format "->,>>>,>>9.9"
    field pre02  like plani.platot format "->,>>>,>>9.9"
    field cob01  like plani.platot format "->,>>>,>>9.9"
    field cob02  like plani.platot format "->,>>>,>>9.9"
    field cal01  like plani.platot format "->,>>>,>>9.9"
    field cal02  like plani.platot format "->,>>>,>>9.9"
    field dif01  as dec format "->>>>9.9"
    field dif02  as dec format "->>>>9.9"
    field etbcob like titulo.etbcod
    index idx1 etbcod.
    
def temp-table tt-tit
    field etbcod like titulo.etbcod
    field clinom like clien.clinom
    field clicod like clien.clicod
    field contnum like contrato.contnum  
    field titvlcob like titulo.titvlcob format "->,>>>,>>9.99"
    field jucob    like titulo.titvlcob format "->,>>>,>>9.99"
    field vdif     as dec format "->,>>>,>>9.99"
    field titdtpag like titulo.titdtpag
    field titdtven like titulo.titdtven
    field titpar   like titulo.titpar
    field etbcobra like titulo.etbcobra
    index idx1 etbcod.

wdti = today.
wdtf = wdti + 30.
repeat:
 
 wjuro = 0.
 vldev    = 0.
 vdif     = 0.
 vljur     = 0.
 vlmul     = 0.
 jucob     = 0.
 vlcob     = 0.
 wvlpri    = 0.
 wvlpag = 0.

    for each tt-etb:
        delete tt-etb.
    end.

    update vetbcod with frame f1.

    if vetbcod <> 0 then do:
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
    then do:
        bl_sel_filiais:
        repeat:
            run p-seleciona-modal.
                                                      
            if keyfunction(lastkey) = "end-error"
            then do: 
                leave bl_sel_filiais.
            end.   
        end.
    end.
    else do:
        create tt-modalidade-selec.
        assign tt-modalidade-selec.modcod = "CRE".
    end.
    
    assign vmod-sel = "  ".
    for each tt-modalidade-selec.
        assign vmod-sel = vmod-sel + tt-modalidade-selec.modcod + "  ".
    end.
      
    display vmod-sel format "x(40)" no-label with frame f1.
    
    stbjur = no.
    message "Usar tabela de juros GERAL ? " UPDATE stbjur.
    
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
        &Width     = "158"
        &Form      = "frame f-cab"}

    for each estab where if vetbcod = 0
                         then true
                         else estab.etbcod = vetbcod no-lock:
                         
            wjuro = 0. 
            vldev    = 0. 
            vdif     = 0. 
            vljur     = 0. 
            vlmul     = 0. 
            jucob     = 0. 
            vlcob     = 0. 
            wvlpri    = 0. 
            wvlpag = 0. 
 
    for each tt-modalidade-selec,
    
        each titulo use-index etbcod  where
             titulo.etbcobra  = estab.etbcod    and 
             titulo.titdtpag >=  input wdti     and
             titulo.titdtpag <=  input wdtf     and
             titulo.modcod    =  tt-modalidade-selec.modcod and
             titulo.titdtpag > titulo.titdtven  no-lock.
       
        if titulo.etbcobra = ? or
           titulo.moecod   = "NOV"
        then next.

        if titulo.titdtpag > titulo.titdtven
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
                                                        
        if ndias = 0 then next.                                              

        v-cont = v-cont + 1.
        if v-cont mod 250 = 0
        then display stream stela titulo.etbcobra
                             titulo.titdtpag
                             titulo.titnum with 1 down centered. pause 0.

        find first btitulo where
             btitulo.empcod    = wempre.empcod and
             btitulo.titnat    = no            and
             btitulo.modcod    = "CRE"         and
             btitulo.etbcod    = titulo.etbcod and
             btitulo.clifor    = titulo.clifor and
             btitulo.titnum    = titulo.titnum and
             btitulo.titnumger = titulo.titnum and
             btitulo.titparger = titulo.titpar
             no-lock no-error.

        wvlpag = titulo.titvlpag.
        if available btitulo
        then
            if btitulo.titnumger = titulo.titnum
            then assign
                    wvlpri = if titulo.titvlcob > btitulo.titvlcob
                             then titulo.titvlcob - btitulo.titvlcob
                             else btitulo.titvlcob - titulo.titvlcob
                    wvlpag = wvlpri + btitulo.titvlcob.
            else wvlpri = titulo.titvlcob.
        else
            wvlpri = titulo.titvlcob.
        find clien where clien.clicod = titulo.clifor no-lock no-error.
        if avail clien
        then vclinom = clien.clinom.
        else vclinom = " ".
       
        ndias = titulo.titdtpag - titulo.titdtven.
        /*********************  ************************/

        if ndias > 0
        then do:
            if stbjur
            then do:
                {sel-tabjur.i 0 ndias}. 
            end.
            else do:
                {sel-tabjur.i estab.etbcod ndias}.
            end.
            if avail tabjur
            then assign
                     jucob = (wvlpri * tabjur.fator) - wvlpri.
        end.
        wjuro = wvlpag - titulo.titvlcob.

        find first tt-etb where tt-etb.etbcod = titulo.etbcobra no-error.
        if not avail tt-etb
        then do:
            create tt-etb.
            assign tt-etb.etbcod = titulo.etbcobra.
        end.

        if ndias >= 0
        then do:
            assign
                vldev = wvlpri + (titulo.titdtpag - titulo.titdtven) * wjuro
                vdif  = (titulo.titvlpag - (wvlpri + jucob)).
            vdif = wjuro - JUCOB.

            if ndias > 0 and ndias <= 180
            then assign
                    tt-etb.pre01  = tt-etb.pre01 + wvlpri
                    tt-etb.cob01  = tt-etb.cob01 + wjuro
                    tt-etb.cal01  = tt-etb.cal01 + jucob
                    tt-etb.dif01  = tt-etb.dif01 + vdif.
            else assign
                    tt-etb.pre02  = tt-etb.pre02 + wvlpri
                    tt-etb.cob02  = tt-etb.cob02 + wjuro
                    tt-etb.cal02  = tt-etb.cal02 + jucob
                    tt-etb.dif02  = tt-etb.dif02 + vdif.
        end.

        find first contrato where contrato.contnum = int(titulo.titnum)
                   no-lock no-error.
        if not avail contrato then next.
        
            create tt-tit.
            assign tt-tit.etbcod   = titulo.etbcod
                   tt-tit.clinom   = clien.clinom
                   tt-tit.clicod   = clien.clicod
                   tt-tit.contnum  = contrato.contnum
                   tt-tit.titvlcob = titulo.titvlcob
                   tt-tit.jucob    = tt-tit.titvlcob + jucob
                   tt-tit.vdif     = vdif
                   tt-tit.titdtpag = titulo.titdtpag
                   tt-tit.titdtven = titulo.titdtven
                   tt-tit.titpar   = titulo.titpar
                   tt-tit.etbcobra = titulo.etbcobra.
    end.
    end.      

    for each tt-etb no-lock break by tt-etb.etbcod.
        display
            tt-etb.etbcod column-label "Fl."  
            tt-etb.pre01(total) column-label "Vlr.Prest!<= 180"
            tt-etb.cob01(total) column-label "Jur.Cob.!<= 180"
            tt-etb.cal01(total) column-label "Jur.Cal.!<= 180"
            tt-etb.dif01(total) column-label "Dif.!<= 180" format "->>>>>>>9.9"
            tt-etb.pre02(total) column-label "Vlr.Prest!> 180"
            tt-etb.cob02(total) column-label "Jur.Cob!> 180"
            tt-etb.cal02(total) column-label "Jur.Cal!> 180"
            tt-etb.dif02(total) column-label "Dif.!> 180" format "->>>>>>>9.9"
            (pre01 + pre02)(total) column-label "Total!Prest." format "->,>>>,>>9.99"
            (cob01 + cob02)(total) column-label "Total!Cob." 
            (cal01 + cal02)(total) column-label "Total!Cal." format "->,>>>,>>9.99" 
            (dif01 + dif02)(total) column-label "Total!Dif." format "->>>,>>9.99"
            with frame f3 down width 170.  

        if last-of(tt-etb.etbcod)
        then do:
            for each tt-tit where tt-tit.etbcobra = tt-etb.etbcod no-lock:
                disp tt-tit.clinom   column-label "Nome" 
                     tt-tit.clicod   column-label "Cod.Clien" format "9999999999"
                     tt-tit.contnum  column-label "Contrato" format "99999999999"
                     tt-tit.titvlcob column-label "Valor !Prest" format "->>>,>>9.99"
                     tt-tit.jucob    column-label "Valor Prest! Com Juros" format "->>>,>>9.99"
                     tt-tit.vdif     column-label "Juros Disp." format "->>>,>>9.99" (total)
                     tt-tit.titdtpag column-label "Data Pagto"
                     tt-tit.titdtven column-label "Data Venc.! Prest"
                     tt-tit.titpar   column-label "Par"
                     tt-tit.etbcobra column-label "EtbCobra"
                     with frame f4 down width 155.  
            end.
        end.            
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



procedure p-seleciona-modal:
            
{sklcls.i
    &File   = tt-modalidade-padrao
    &help   = "                ENTER=Marca F4=Retorna F8=Marca Tudo"
    &CField = tt-modalidade-padrao.modcod    
    &Ofield = " tt-modalidade-padrao.modcod"
    &Where  = " true"
    &noncharacter = / *
    &LockType = "NO-LOCK"
    &UsePick = "*"          
    &PickFld = "tt-modalidade-padrao.modcod" 
    &PickFrm = "x(4)" 
    &otherkeys1 = "
        if keyfunction(lastkey) = ""CLEAR""
        then do:
            V-CONT = 0.
            for each tt-modalidade-padrao no-lock:
                a-seelst = a-seelst + "","" + tt-modalidade-padrao.modcod.
                v-cont = v-cont + 1.
            end.
            message ""                         SELECIONADAS "" 
            V-CONT ""FILIAIS                                   "" .
                         a-seeid = -1.
            a-recid = -1.
            next keys-loop. 
        end. "
    &Form = " frame f-nome" 
}

hide frame f-nome.
v-cont = 2.
repeat :
    v-cod = "".
    if num-entries(a-seelst) >= v-cont
    then v-cod = entry(v-cont,a-seelst).

    v-cont = v-cont + 1.

    if v-cod = ""
    then leave.
    create tt-modalidade-selec.
    assign tt-modalidade-selec.modcod = v-cod.
end.

end procedure.
 ****/
