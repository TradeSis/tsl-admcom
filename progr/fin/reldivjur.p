/* helio 07072022 - ajuste performance e leitura somente LP */
/* helio 25052022 - pacote melhorias cobranca */
/* helio 28022022 - iepro - ajuste relatorio divergencia de juros */

{admcab.i}


def var smodal as log format "Sim/Nao".
def input param psintetico  as log.
def input param pporfilial  as log.

{setbrw.i}
def var ndias as int format ">>>>9".

def buffer opdvdoc for pdvdoc.
def buffer xpdvdoc for pdvdoc.
def buffer bpdvdoc for pdvdoc.

def var precestorno as recid.
def var vdispensa   like pdvdoc.desconto column-label "dispensa".
def var vjuros      as dec column-label "juros!calculado". 
def var vjurocobrado as dec.

def var v-cont as integer.
def var v-cod as char.
def var vmod-sel as char.


def temp-table tt-modalidade-padrao no-undo
    field modcod as char
    index pk modcod.
             
def temp-table tt-modalidade-selec no-undo
    field modcod as char
    index pk modcod.

def temp-table ttpdvdoc no-undo 
    field etbcod as int
    field datamov as date
    field recid_pdvdoc as recid
    field recid_titulo as recid
    field dias as int
    field jurocobrado as dec
    field juros as dec
    field dispensa as dec.

def temp-table tt-sint no-undo
    field etbcod like estab.etbcod
    field titvlcob01  as dec
    field titvlcob02  as dec
    field jurocobrado01  as dec
    field jurocobrado02  as dec
    field juros01  as dec
    field juros02  as dec
    field dispensa01  as dec format "->>>>9.9"
    field dispensa02  as dec format "->>>>9.9"
    field custas        like pdvdoc.titvlrcustas
    index etbcod is unique primary etbcod asc.

def var vval-carteira as dec.                                
form with frame fx down.                                
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
         
                    with side-labels width 80 frame f1
                    title " DIVERGENCIA DE JUROS " + string(psintetico,"SINTETICO/") + " " + string(pporfilial,"POR FILIAL/").
disp psintetico label "Sintetico" colon 25 format "Sim/Nao" with frame f1.
disp pporfilial label "por Filial" colon 25 format "Sim/Nao" with frame f1.
def var psomentecomjuros as log init yes.
disp psomentecomjuros  format "Sim/Nao" label "Somente com juros" colon 25 with frame f1.


wdti = today.
wdtf = wdti + 30.
repeat:
 
    empty temp-table tt-modalidade-selec.
    empty temp-table ttpdvdoc.
    empty temp-table tt-sint.    
    
    
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
    if not psintetico
    then update psintetico with frame f1.                    
    else pporfilial = yes.
    disp pporfilial with frame f1.
    if not pporfilial and not psintetico
    then update pporfilial with frame f1.                    
    
    assign sresp = false.
    update psomentecomjuros with frame f1.          
           
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
    
    varquivo = "../relat/reldivjur_" + string(today,"99999999") + "_" + replace(string(time,"HH:MM:SS"),":","") + ".txt".
    message "gerando relatorio" varquivo.
      
    {mdadmcab.i
        &Saida     = "value(varquivo)"
        &Page-Size = "1000"
        &Cond-Var  = "110"
        &Page-Line = "0"
        &Nom-Rel   = """RELDIVJUR"""
        &Nom-Sis   = """SISTEMA CREDIARIO"""
        &Tit-Rel   = """DIVERGENCIA DE JUROS "" + string(psintetico,"\"SINTETICO/\"") + "" - PERIODO DE "" +
                        STRING(WDTI) + "" A "" + STRING(WDTF) +
                        "" "" + string(pporfilial,"\"POR FILIAL/\"")                        
                        + "" - FILIAL "" + STRING(vetbcod)"
        &Width     = "110"
        &Form      = "frame f-cab"}
           
    for each estab where if vetbcod = 0
                         then true
                         else estab.etbcod = vetbcod no-lock,
                         
        each pdvtmov no-lock,
        each pdvdoc where pdvdoc.ctmcod = pdvtmov.ctmcod and
            pdvdoc.pstatus = yes and 
            pdvdoc.etbcod = estab.etbcod and 
            pdvdoc.datamov >= wdti and
            pdvdoc.datamov <= wdtf no-lock:
            
        
            find first tt-modalidade-selec no-error.
            if avail tt-modalidade-selec
            then do:
                find first tt-modalidade-selec where tt-modalidade-selec.modcod  = pdvdoc.modcod no-lock no-error.
                if not avail tt-modalidade-selec
                then next.
            end.
            if pdvdoc.ctmcod = "P48" then next.

            if contnum = ? then next.
            find contrato where contrato.contnum = int(pdvdoc.contnum) no-lock no-error.
            if not avail contrato then next.
            find first  titulo where
                titulo.empcod = 19 and titulo.titnat = no and
                 titulo.clifor = contrato.clicod and titulo.modcod = contrato.modcod and titulo.etbcod = contrato.etbcod and
                 titulo.titnum = string(contrato.contnum) and
                 titulo.titpar = pdvdoc.titpar
                 no-lock no-error.
            if not avail titulo then next.
                 
            /*
            if titulo.titvltot = pdvdoc.titvlcob and titulo.titdtpag = pdvdoc.datamov
            then do:
                next.
            end.
            if titulo.titvltot = pdvdoc.titvlcob * -1
            then next.
            */
               
            find cmon of pdvdoc no-lock. 
            precestorno = ?.
            run pesquisaEstorno (recid(pdvdoc), output precestorno).
            if precestorno = ? and pdvdoc.valor > 0
            then do: 
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
                if psomentecomjuros = no or (psomentecomjuros = yes and (vjuros <> vjurocobrado or vjurocobrado > 0 or vjuros > 0))
                then do:        
                   
                    find clien where clien.clicod = titulo.clifor no-lock no-error.
                    ndias = pdvdoc.datamov - titulo.titdtven.
                    if ndias < 0 then ndias = 0.

                        find first tt-sint where tt-sint.etbcod = pdvdoc.etbcod no-error.
                        if not avail tt-sint
                        then do:
                            create tt-sint.
                            tt-sint.etbcod = pdvdoc.etbcod.
                        end.
                        if ndias <= 180
                        then do:
                            tt-sint.titvlcob01      = tt-sint.titvlcob01        + pdvdoc.titvlcob.
                            tt-sint.jurocobrado01   = tt-sint.jurocobrado01     + vjurocobrado.
                            tt-sint.juros01         = tt-sint.juros01           + vjuros.
                            tt-sint.dispensa01      = tt-sint.dispensa01        + vdispensa.
                        end.
                        else do:
                            tt-sint.titvlcob02      = tt-sint.titvlcob02        + pdvdoc.titvlcob.
                            tt-sint.jurocobrado02   = tt-sint.jurocobrado02     + vjurocobrado.
                            tt-sint.juros02         = tt-sint.juros02           + vjuros.
                            tt-sint.dispensa02      = tt-sint.dispensa02        + vdispensa.
                        end.
                    if not psintetico
                    then do:
                        create ttpdvdoc.
                        ttpdvdoc.etbcod = estab.etbcod.
                        ttpdvdoc.datamov    = pdvdoc.datamov.
                        ttpdvdoc.recid_pdvdoc   = recid(pdvdoc).
                        ttpdvdoc.recid_titulo  = recid(titulo).
                        ttpdvdoc.dias           = ndias.
                        ttpdvdoc.jurocobrado   = vjurocobrado.
                        ttpdvdoc.juros         = vjuros.
                        ttpdvdoc.dispensa      = vdispensa.
                    end.
                end.
                
            end.    
    end.
    if not psintetico
    then do:
       for each tt-sint break by tt-sint.etbcod.
        if true /*pporfilial*/
        then
        display tt-sint.etbcod column-label "Fl."  
                tt-sint.titvlcob01(total)  column-label "Vlr.Prest!<= 180" format "->>>>>>>>9.99"
                tt-sint.jurocobrado01(total)  column-label "Jur.Cob.!<= 180" format "->>>>>9.99"
                tt-sint.juros01(total)  column-label "Jur.Cal.!<= 180" format "->>>>>9.99"
                tt-sint.dispensa01(total)  column-label "Dif.!<= 180"               format "->>>>>9.99"
                tt-sint.titvlcob02(total)  column-label "Vlr.Prest!> 180" format "->>>>>9.99"
                tt-sint.jurocobrado02(total)  column-label "Jur.Cob!> 180" format "->>>>>9.99"
                tt-sint.juros02(total)  column-label "Jur.Cal!> 180" format "->>>>>9.99"
                tt-sint.dispensa02(total)  column-label "Dif.!> 180" format "->>>>>9.99"
                space(5)
                /*
                (tt-sint.titvlcob01 + tt-sint.titvlcob02)(total) column-label "Total!Prest."        format "->>>>>>>>9.99"
                (tt-sint.jurocobrado01 + tt-sint.jurocobrado02)(total) column-label "Total!Cob."    format "->>>>>9.99"
                (tt-sint.juros01 + tt-sint.juros02)(total) column-label "Total!Cal."                format "->>>>>9.99"
                (tt-sint.dispensa01 + tt-sint.dispensa02)(total) column-label "Total!Dif."          format "->>>>>9.99"
                */
                            (tt-sint.titvlcob01 + tt-sint.titvlcob02) column-label "vlr!prest."     format "->>>>>>>>9.99"    (total)
                    
                            (tt-sint.jurocobrado01 + tt-sint.jurocobrado02) column-label "juros!cobrado"     format "->>>>>9.99" (total)
                            
                            (tt-sint.juros01 + tt-sint.juros02)     column-label "juros"     format "->>>>>9.99" (total)
                        
                            (tt-sint.dispensa01 + tt-sint.dispensa02) column-label "dispensa"  format "->>>>>9.99" (total)
                            space(3)
                            tt-sint.custas column-label "protesto!custas" (total)
                        (tt-sint.titvlcob01 + tt-sint.titvlcob02)                            +
                        (tt-sint.jurocobrado01 + tt-sint.jurocobrado02)                        
                        
                              column-label "total!pago" format "->>>>>>>>9.99" (total)

                    with frame f2 down width 200.  
        else down 1 with frame fx.
        for each ttpdvdoc where ttpdvdoc.etbcod = tt-sint.etbcod,
                    pdvdoc where recid(pdvdoc) = ttpdvdoc.recid_pdvdoc no-lock

                break by ttpdvdoc.etbcod by ttpdvdoc.datamov by pdvdoc.contnum by pdvdoc.titpar.
                /*
            if first-of (ttpdvdoc.etbcod)
            then do:
                    if not first(ttpdvdoc.etbcod)
                    then page.
                /*
                    pause 0.
                    message "Filial " estab.etbcod.
                */    
            end.    
                  */
            find pdvtmov of pdvdoc no-lock. 
            find titulo where recid(titulo) = ttpdvdoc.recid_titulo no-lock.
            find clien where clien.clicod = titulo.clifor no-lock.
            
            disp 
                            clien.clinom    column-label  "Cliente" format "x(20)"        when avail clien
                            pdvdoc.clifor column-label "Cliente"
            
                            pdvtmov.ctmnom format "x(10)" column-label "ope"
        
                    
                            titulo.etbcod  column-label "fil!Cnt"
                            titulo.modcod
                            titulo.tpcontrato column-label "tp"
                            pdvdoc.contnum column-label "Contrato"
                            
                            pdvdoc.titpar
                            titulo.titdtven column-label "venc."   format "99/99/9999"
                            ttpdvdoc.dias           column-label "dias" format "->>>>9"
                            
                            pdvdoc.datamov column-label "data!pagto"
                            pdvdoc.etbcod column-label "fil!cobra"
                            
                    
                            pdvdoc.titvlcob column-label "vlr!prest."     format "->>>>>>>>9.99"      (total /*by ttpdvdoc.etbcod*/ )
                    
                            ttpdvdoc.jurocobrado column-label "juros!cobrado"     format "->>>>>9.99"      (total /*by ttpdvdoc.etbcod*/)
                            ttpdvdoc.juros            format "->>>>>9.99" (total /*by ttpdvdoc.etbcod*/ )
                        
                            ttpdvdoc.dispensa         format "->>>>>9.99" (total /*by ttpdvdoc.etbcod*/ )
                            pdvdoc.pago_parcial column-label "P" format "x(1)" when pdvdoc.pago_parcial = "S"
                            pdvdoc.titvlrcustas column-label "protesto!custas" (total /*by ttpdvdoc.etbcod*/)
                            pdvdoc.valor   column-label "total!pago" format "->>>>>>>>9.99" (total /*by ttpdvdoc.etbcod*/)
                            
                    
                            with width 200.
            
        end.
       end. 
    end.
    if psintetico
    then do.
        for each tt-sint break by tt-sint.etbcod.
            display tt-sint.etbcod column-label "Fl."  
                tt-sint.titvlcob01(total)  column-label "Vlr.Prest!<= 180" format "->>>>>>>>9.99"
                tt-sint.jurocobrado01(total)  column-label "Jur.Cob.!<= 180" format "->>>>>9.99"
                tt-sint.juros01(total)  column-label "Jur.Cal.!<= 180" format "->>>>>9.99"
                tt-sint.dispensa01(total)  column-label "Dif.!<= 180"               format "->>>>>9.99"
                tt-sint.titvlcob02(total)  column-label "Vlr.Prest!> 180" format "->>>>>9.99"
                tt-sint.jurocobrado02(total)  column-label "Jur.Cob!> 180" format "->>>>>9.99"
                tt-sint.juros02(total)  column-label "Jur.Cal!> 180" format "->>>>>9.99"
                tt-sint.dispensa02(total)  column-label "Dif.!> 180" format "->>>>>9.99"
                space(5)
                /*
                (tt-sint.titvlcob01 + tt-sint.titvlcob02)(total) column-label "Total!Prest." format "->>>>>>>>9.99"
                (tt-sint.jurocobrado01 + tt-sint.jurocobrado02)(total) column-label "Total!Cob."  format "->>>>>9.99"
                (tt-sint.juros01 + tt-sint.juros02)(total) column-label "Total!Cal."   format "->>>>>9.99"
                (tt-sint.dispensa01 + tt-sint.dispensa02)(total) column-label "Total!Dif." format "->>>>>9.99"
                */
                            (tt-sint.titvlcob01 + tt-sint.titvlcob02) column-label "vlr!prest."     format "->>>>>>>>9.99"    (total)
                    
                            (tt-sint.jurocobrado01 + tt-sint.jurocobrado02) column-label "juros!cobrado"     format "->>>>>9.99" (total)
                            
                            (tt-sint.juros01 + tt-sint.juros02)     column-label "juros"     format "->>>>>9.99" (total)
                        
                            (tt-sint.dispensa01 + tt-sint.dispensa02) column-label "dispensa"  format "->>>>>9.99" (total)
                            space(3)
                            tt-sint.custas column-label "protesto!custas" (total)
                        (tt-sint.titvlcob01 + tt-sint.titvlcob02)                            +
                        (tt-sint.jurocobrado01 + tt-sint.jurocobrado02)                        
                        
                              column-label "total!pago" format "->>>>>>>>9.99" (total)

 
                    with frame f3 down width 200.  
   
        end.
    end.

    view frame f1.

    output close.
    pause 0 before-hide.
    run visurel0.p(varquivo,"").
    pause before-hide.
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

