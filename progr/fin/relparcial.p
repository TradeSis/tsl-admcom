/* helio 25052022 - pacote melhorias cobranca */
/* helio 28022022 - iepro - ajuste relatorio divergencia de juros */

{admcab.i}

{setbrw.i}
def var smodal as log format "Sim/Nao".

def var vdispensa   like pdvdoc.desconto column-label "dispensa".
def var vjuros      as dec column-label "juros!calculado". 
def var vjurocobrado as dec.

def buffer opdvdoc for pdvdoc.
def buffer xpdvdoc for pdvdoc.
def buffer bpdvdoc for pdvdoc.

def var precestorno as recid.

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
create tt-modalidade-padrao.
assign tt-modalidade-padrao.modcod = "CPN".

for each profin no-lock.
    find modal of profin no-lock no-error.
    if not avail modal
    then next.
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
def var psomenteparcial as log format "Sim/Nao" init yes.

form vetbcod colon 25
     estab.etbnom   no-label colon 30
     wdti           colon 25  " A"
     wdtf           colon 25  no-label
     psomenteparcial colon 25 label "Somente pgto Parcial?"
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
    update psomenteparcial with frame f1.
    assign sresp = false.

        update smodal label "Seleciona Modalidades?" colon 25
               help "Não = Modalidade CRE Padrão / Sim = Seleciona Modalidades"
               with side-label width 80 frame f1.
        if smodal
        then do:
            bl_sel_filiais:
            repeat:
                run p-seleciona-modal.
                                                      
                if keyfunction(lastkey) = "end-error"
                then leave bl_sel_filiais.
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
           
    
    
    varquivo = "../relat/relparcial_" + string(today,"99999999") + "_" + replace(string(time,"HH:MM:SS"),":","") + ".txt".
        
    {mdadmcab.i
        &Saida     = "value(varquivo)"
        &Page-Size = "0"
        &Cond-Var  = "110"
        &Page-Line = "0"
        &Nom-Rel   = """RELPARCIAL"""
        &Nom-Sis   = """SISTEMA CREDIARIO"""
        &Tit-Rel   = """LISTAGEM DE CONFERENCIA DE BAIXAS "" + string(psomenteparcial,""PARCIAIS/TOTAIS"")  + "" - PERIODO DE "" +
                        STRING(WDTI) + "" A "" + STRING(WDTF) +
                        "" FILIAL "" + STRING(vetbcod) "
        &Width     = "110"
        &Form      = "frame f-cab"}
    for each estab where if vetbcod = 0
                         then true
                         else estab.etbcod = vetbcod no-lock,
                         
        each pdvtmov no-lock, 
        each pdvdoc where pdvdoc.ctmcod = pdvtmov.ctmcod and
        /*pdvdoc.pago_parcial = "S" and*/ pdvdoc.pstatus = yes and pdvdoc.etbcod = estab.etbcod and 
            pdvdoc.datamov >= wdti and
            pdvdoc.datamov <= wdtf 
            and (if psomenteparcial then pdvdoc.pago_parcial = "S" else true)
            no-lock 
        break by pdvdoc.ctmcod by pdvdoc.pstatus by pdvdoc.datamov by pdvdoc.etbcod by pdvdoc.contnum by pdvdoc.titpar.
            find first tt-modalidade-selec no-error.
            if avail tt-modalidade-selec
            then do:
                find first tt-modalidade-selec where tt-modalidade-selec.modcod  = pdvdoc.modcod no-lock no-error.
                if not avail tt-modalidade-selec
                then next.
            end.
            if pdvdoc.ctmcod = "P48" then next.

            if contnum = ? then next.
            find contrato where contrato.contnum = int(pdvdoc.contnum) no-lock.
            find first  titulo where
                titulo.empcod = 19 and titulo.titnat = no and titulo.modcod = contrato.modcod and titulo.etbcod = contrato.etbcod and
                    titulo.clifor = contrato.clicod and
                titulo.titnum = string(contrato.contnum) and
                 titulo.titpar = pdvdoc.titpar
                 no-lock.


            find cmon of pdvdoc no-lock. 
            precestorno = ?. 
            run pesquisaEstorno (recid(pdvdoc), output precestorno). 
            if precestorno = ? and pdvdoc.valor > 0
            then.
            else next.
                                                            
            if psomenteparcial
            then do:
                if pdvdoc.pago_parcial = "S"
                then.
                else next.
                
                /*if titulo.titvltot = pdvdoc.titvlcob and titulo.titdtpag = pdvdoc.datamov
                then do:
                    next.
                end.*/
            end.    
            /*
            if titulo.titvltot = pdvdoc.titvlcob * -1
            then next.
            */
            /*find pdvtmov of pdvdoc no-lock.    */
            find cmon of pdvdoc no-lock. 
                vjurocobrado = 0.
                if pdvdoc.desconto > 0
                then do:
                    vjurocobrado = pdvdoc.valor_encargo - pdvdoc.desconto.
                    vjuros    = pdvdoc.valor_encargo.
                    vdispensa = pdvdoc.desconto.
                end.    
                else do:
                    run juro_titulo_data.p (titulo.etbcod, titulo.titdtven, pdvdoc.titvlcob,
                                            pdvdoc.datamov, output vjuros).
                    vjurocobrado = pdvdoc.valor_encargo.
                    vdispensa = vjuros - pdvdoc.valor_encargo.
                    if vdispensa < 0
                    then vdispensa = 0. 
                end.
            find pdvmov of pdvdoc no-lock.
            def var vhora as char.
            disp 
                pdvdoc.etbcod column-label "Fil"
                cmon.cxacod format "99" column-label "Cx" 
                pdvdoc.datamov 
                string(pdvmov.HoraMov,"HH:MM:SS") @ vhora format "x(8)" column-label "hora"
                pdvtmov.ctmcod column-label "TBai"
                pdvtmov.ctmnom format "x(10)" column-label "Oper"
                pdvdoc.clifor column-label "Cliente"
                titulo.etbcod  column-label "Fil!Cnt"
                pdvdoc.contnum column-label "Contrato"
                pdvdoc.titpar
                
                    pdvdoc.titvlcob column-label "vlr!nominal"     format "->>>>>>>9.99"  (total)    /*(total by estab.etbcod by pdvdoc.datamov)*/

                    
                    vjurocobrado column-label "juro!cobrado"     format "->>>>>>>9.99"   (total)   /*(total by estab.etbcod by pdvdoc.datamov)*/
                    vjuros            format "->>>>>9.99" (total) /*(total by estab.etbcod ~ by pdvdoc.datamov)*/
                    
                    vdispensa         format "->>>>>9.99" (total) /*(total by estab.etbcod ~ by pdvdoc.datamov)*/
                    pdvdoc.pago_parcial column-label "P" format "x(1)" when pdvdoc.pago_parcial = "S"
                    pdvdoc.valor   column-label "total!pago" format "->>>>>>>9.99" (total) /*(total by estab.etbcod by pdvdoc.datamov)*/
                
                with width 200.            
                
        
    end.


    
    /***
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
             titulo.titdtpag >=  input  wdti     and
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
    **/

    view frame f1.       

    output close.
    run visurel.p(varquivo,"").
    
end.


procedure p-seleciona-modal:
          
for each tt-modalidade-selec: delete tt-modalidade-selec. end.
release tt-modalidade-padrao.
clear frame f-nome all.
hide frame f-nome no-pause.            
            
assign
    a-seeid = -1
    a-recid = -1
    a-seerec = ?
    a-seelst = "".

l1: repeat:
    
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
            a-seelst = """".
            for each tt-modalidade-padrao no-lock:
                a-seelst = a-seelst + "","" + tt-modalidade-padrao.modcod.
                v-cont = v-cont + 1.
                disp ""* "" @ a-seelst
                    tt-modalidade-padrao.modcod
                    with frame f-nome.
                down with frame f-nome.
                
            end.
            message ""                         SELECIONADAS "" 
            V-CONT ""FILIAIS                                   ""
            .
            pause .
            a-recid = -1.
            next .
        end. 
        if keyfunction(lastkey) = ""end-error""    
        then leave keys-loop.
            "
    &Form = " frame f-nome" 
}. 

    leave l1.
end.
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





procedure pesquisaEstorno.
def input  param pmeurec as recid.
def output param pestrec as recid.
find bpdvdoc where recid(bpdvdoc) = pmeurec no-lock.
for each xpdvdoc where xpdvdoc.contnum = bpdvdoc.contnum and
                      xpdvdoc.titpar   = bpdvdoc.titpar and
                      xpdvdoc.pstatus  = yes
                no-lock:
    find pdvmov of xpdvdoc no-lock.
    
          if xpdvdoc.orig_loja <> 0
          then do:
                find first opdvdoc where
                    opdvdoc.etbcod = xpdvdoc.orig_loja and
                    opdvdoc.cmocod = xpdvdoc.orig_componente and
                    opdvdoc.datamov = xpdvdoc.orig_data and
                    opdvdoc.sequencia = xpdvdoc.orig_nsu and
                    opdvdoc.seqreg   = xpdvdoc.orig_vencod
                    no-lock no-error.
                if avail opdvdoc
                then do:
                    if recid(opdvdoc) = pmeurec
                    then pestrec  = recid(opdvdoc).
                end.                       
           end.
      
end.
end procedure.


