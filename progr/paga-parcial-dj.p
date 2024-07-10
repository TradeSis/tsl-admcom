/***************************************************************************
** Programa        : paga-parcial-dj.p
** Objetivo        : Listagem de Conferencia de pagamento parcial
** Ultima Alteracao: 30/10/2015
**
****************************************************************************/

{admcab.i}

{setbrw.i}

def var v-cont as integer.
def var v-cod as char.
def var vmod-sel as char.

def temp-table tt-modalidade-padrao
    field modcod as char
    index pk modcod.
             
def temp-table tt-modalidade-selec
    field modcod as char
    index pk modcod.

def var vval-carteira as dec.                                
                                
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
def var wvlprimen like titulo.titvlcob.
def var wvlprimai like titulo.titvlcob.
def var vetbcod like estab.etbcod.
def stream stela.
form with down frame fdet.

def var valorcomjuro as dec.

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
    field dif02  as dec format "->>>>9.9"
    field etbcob like titulo.etbcod
    index idx1 etbcod.
    
    
def temp-table tt-clien
    field etbcod like titulo.etbcod
    field clinom like clien.clinom
    field clicod like clien.clicod
    field contnum like contrato.contnum  
    field titvlcob like titulo.titvlcob format "->,>>>,>>9.99"
    field jucob    like titulo.titvlcob format "->,>>>,>>9.99"
    field vdif     as dec format "->,>>>,>>9.99"
    field titdtpag like titulo.titdtpag
    field titdtven like titulo.titdtven
    field titpar like titulo.titpar
    field etbcob like titulo.etbcob
    index idx1 etbcod.


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

def var juro-dispensado as dec.

def var vpercent-dispensa as dec.

def buffer bestab for estab.
find bestab where bestab.etbcod = setbcod no-lock.
def var stbjur as log format "Sim/Nao".
def var varquivo as char.
    for each tt-tit:
        delete tt-tit.
    end.

    update vetbcod colon 25 with frame f1 .

    if  vetbcod <> 0 then do:
        find estab where estab.etbcod = vetbcod no-lock.
        display estab.etbnom with frame f1.
    end.
    else disp "Geral" @ estab.etbnom with frame f1.

    update wdti validate(input wdti <> ?, "Data deve ser Informada")
            colon 25 with frame f1.

    update wdtf validate(input wdtf >= input wdti, "Data Invalida")
           colon 40 with frame f1.

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
                pause.
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
    
    /*
    update vlimite label "Dif.Limite" with frame f1.
    
    stbjur = no.
    message "Usar tabela de juros GERAL ? " UPDATE stbjur.
    
    output stream stela to terminal.
    

    if opsys = "UNIX"
    then varquivo = "/admcom/relat/divjurb5l." + string(time).
    else varquivo = "l:~\relat~\divjurb5w." + string(time). 
    */
    
    varquivo = "/admcom/relat/paga-parcial-dj." + string(time).
    
    {mdadmcab.i
        &Saida     = "value(varquivo)"
        &Page-Size = "64"
        &Cond-Var  = "130"
        &Page-Line = "66"
        &Nom-Rel   = """DIVJURB5"""
        &Nom-Sis   = """SISTEMA CREDIARIO"""
        &Tit-Rel   = """LISTAGEM DE CONFERENCIA DE JUROS - PERIODO DE "" +
                        STRING(WDTI) + "" A "" + STRING(WDTF) +
                        "" FILIAL "" + STRING(vetbcod)"
        &Width     = "130"
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

 
    for each tt-modalidade-selec,
    
        each titulo use-index etbcod  where
             titulo.etbcobra  = estab.etbcod    and 
             titulo.titdtpag >=  input wdti     and
             titulo.titdtpag <=  input wdtf     and
             titulo.modcod    =  tt-modalidade-selec.modcod  and
             titulo.titdtpag > titulo.titdtven  no-lock.
       
        if titulo.etbcobra = ? or
           titulo.moecod   = "NOV"
        then next.

        if acha("PAGAMENTO-PARCIAL",titulo.titobs[1]) <> ?
        then.
        else next.

        find first btitulo where
             btitulo.empcod    =  wempre.empcod       and
             btitulo.titnat    =  no                  and
             btitulo.modcod    =  titulo.modcod       and
             btitulo.etbcod    = titulo.etbcod        and
             btitulo.clifor    =  titulo.clifor       and
             btitulo.titnum    =  titulo.titnum       and
             btitulo.titnumger = titulo.titnum and
             btitulo.titparger = titulo.titpar
             no-lock no-error.

        find last autoriz where
                autoriz.etbcod = titulo.etbcobra and
                autoriz.data   = titulo.titdtpag and
                autoriz.clicod = titulo.clifor and
                autoriz.motivo = "Dispensa de Juros PP" and
                autoriz.valor1 = int(titulo.titnum)
                no-lock no-error.
        if avail autoriz
        then assign
                valorcomjuro = titulo.titvlcob + autoriz.valor2
                vpercent-dispensa = (autoriz.valor3 / autoriz.valor2) * 100.
        else assign
                valorcomjuro = titulo.titvlcob
                vpercent-dispensa = 0.

        if acha("DISPENSA-JURO",titulo.titobs[1]) <> ?
        then juro-dispensado = dec(acha("DISPENSA-JURO",titulo.titobs[1])).
        else juro-dispensado = 0. 
        disp titulo.etbcod     column-label "Fil"
             titulo.titnum     column-label "Numero"
             titulo.titdtpag   column-label "Data"
             titulo.titvlcob   column-label "Valor!cobrado"
                                format ">>,>>9.99"
             valorcomjuro      column-label "Valor!total" 
             titulo.titvlpag   column-label "Valor!pago"
                                format ">>,>>9.99"
             btitulo.titvlcob  column-label "Nova!parcela"
                                format ">>,>>9.99" when avail btitulo
             /*dec(acha("DISPENSA-JURO",titulo.titobs[1])) 
             */
             juro-dispensado
             column-label "Juro!Dispensado"
             vpercent-dispensa column-label "%Dispensa"
             with frame f3 down width 150
             .
        find last autoriz where
                autoriz.etbcod = titulo.etbcobra and
                autoriz.data   = titulo.titdtpag and
                autoriz.clicod = titulo.clifor and
                autoriz.motivo = "Dispensa de Juros PP" and
                autoriz.valor1 = int(titulo.titnum)
                no-lock no-error.
                
        if avail autoriz
        then do:
            find first func where func.funcod = autoriz.funcod and
                            func.etbcod = autoriz.etbcod
                            no-lock no-error.
            disp autoriz.funcod no-label
                 func.funnom when avail func column-label "Responsavel"
                 with frame f3.
        end.    
    end.
    end.
    
    output close.
    run visurel.p(varquivo,"").
    
end.


procedure p-seleciona-modal:
            
{sklcls.i
    &File   = tt-modalidade-padrao
    &help   = "                ENTER=Marca F4=Retorna F8=Marca Tudo"
    &CField = tt-modalidade-padrao.modcod    
    &Ofield = " tt-modalidade-padrao.modcod"
    &Where  = " true"
    &noncharacter = /*
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
            V-CONT ""FILIAIS                                   ""
            .
                         a-seeid = -1.
            a-recid = -1.
            next keys-loop.
        end. "
    &Form = " frame f-nome" 
}. 

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


end.





