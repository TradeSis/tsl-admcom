{admcab.i}
{setbrw.i}

def temp-table tt-pdvd2019 like pdvd2019.

def var vi as int.
def var vdatref as date format "99/99/9999".
def var vcobcod as int.
def var vtipo_visao as char.
def var vmodo_visao as char.
vtipo_visao = "GERENCIAL".
vmodo_visao = "CLIENTE".
vcobcod = 2.

find last pdvd2019 no-lock no-error.
if avail pdvd2019
then vdatref = pdvd2019.data_visao.

update vdatref label "Data referencia" with frame f-dat side-label 1 down
width 80 row 4.
if vdatref < 01/01/21 or
   vdatref > 12/31/21
then return.
  
def var vtipo as char extent 3 format "x(15)". 
def var vcobra as char extent 4 format "x(15)".
def var vcateg as char extent 5 format "x(14)".
vtipo[1] = "  CONTRATO".
vtipo[2] = "  CLIENTE".

if vdatref = 12/31/2021
then vtipo[3] = "  OUTROS".

vcobra[1] = "  GERAL".
vcobra[2] = "  DREBES".
vcobra[3] = "  FINANCEIRA".
vcobra[4] = "  FIDC".
  
vcateg[1] = "  GERAL".
vcateg[2] = "  MOVEIS".
vcateg[3] = "  MODA".
vcateg[4] = "" /*"  NOVACAO"*/.
vcateg[5] = "" /*"  OUTROS"*/
.

repeat:
disp vtipo with frame f-tipo no-label centered.
choose field vtipo with frame f-tipo.

vmodo_visao = trim(vtipo[frame-index]).

def var vindex as int.

if vmodo_visao = "OUTROS"
then assign
        vindex = 1
        vcobcod = ?
        .
        
else do:
disp vcobra with frame f-cobra no-label centered.
choose field vcobra with frame f-cobra.
if trim(vcobra[frame-index]) = "GERAL"
then assign
        vindex = 1
        vcobcod = ?.
else if trim(vcobra[frame-index]) = "DREBES"
    then assign
            vindex = 2
            vcobcod = 2.
    else if trim(vcobra[frame-index]) = "FINANCEIRA"
        THEN assign
                vindex = 3
                vcobcod = 10.
        else if trim(vcobra[frame-index]) = "FIDC"
            then assign
                    vindex = 4
                    vcobcod = 14.

disp vcateg with frame f-categ no-label centered.
end.

repeat:
view frame f-dat.
view frame f-tipo.
view frame f-cobra.
def var vcatcod as int init 0.
def var vplano as int init 0.
vcatcod = ?.
vplano  = 0.

if vmodo_visao = "OUTROS"
then.
else do:
disp vcateg with frame f-categ no-label centered.
choose field vcateg with frame f-categ.
if frame-index = 1
then vcatcod = ?.
else if frame-index = 2
    then vcatcod = 31.
    else if frame-index = 3
        then vcatcod = 41.
        else if frame-index = 4
            then vcatcod = 500.
            else if frame-index = 5
                then vcatcod = 99.    

end.
assign
    a-seeid = -1 a-recid = -1 a-seerec = ?.
if vmodo_visao = "OUTROS"
THEN assign
        vtipo_visao = "CTBOUTROS"
        vmodo_visao = "CONTRATO".
ELSE vtipo_visao = "GERENCIAL".

form pdvd2019.Faixa_risco column-label "Faixa" format "x(5)"
     pdvd2019.descricao_faixa no-label format "x(12)"  
     pdvd2019.saldo_curva column-label "Curva"      format ">>>>>>>>9.99"
     pdvd2019.pctprovisao column-label "%"          format ">>>9.99"
     pdvd2019.provisao    column-label "Provisao"   format ">>>>>>>>9.99"
     pdvd2019.principal   column-label "Principal"  format ">>>>>>>>9.99"
     pdvd2019.renda       column-label "Renda"      format ">>>>>>>>9.99"
     with frame frame-a 13 down width 80
     overlay row 4  
     title " " + string(vdatref,"99/99/9999") + " - " + vtipo_visao + " - " +
            vmodo_visao + " - " + trim(vcobra[vindex]) + " - " +
            trim(vcateg[frame-index]) + " ".

def var tsaldo_curva as dec.
def var tprovisao as dec.
def var tprincipal as dec.
def var trenda as dec.

assign tsaldo_curva = 0 tprovisao    = 0 tprincipal   = 0 trenda = 0.

for each pdvd2019 where pdvd2019.data_visao = vdatref     and
                        pdvd2019.tipo_visao = vtipo_visao and
                        pdvd2019.modo_visao = vmodo_visao and
                        /*pdvd2019.modalidade = "CRE" and*/
                        pdvd2019.cobcod     = vcobcod and
                        pdvd2019.categoria  = vcatcod and
                        pdvd2019.etbcod = 0               
                        no-lock:
    assign
        tsaldo_curva = tsaldo_curva + pdvd2019.saldo_curva
        tprovisao    = tprovisao + pdvd2019.provisao
        tprincipal   = tprincipal + pdvd2019.principal
        trenda       = trenda + pdvd2019.renda
        
         .                
end.                    

def var recatu1         as recid.
def var recatu2         as recid.
def var reccont         as int.
def var esqpos1         as int.
def var esqpos2         as int.
def var esqregua        as log.
def var esqvazio        as log.
def var esqascend     as log initial yes.
def var esqcom1         as char format "x(15)" extent 5
    initial [" ","Imprime TELA","Analitico FAIXA","Analitico GERAL","Acrescimo AVP"].
def var esqcom2         as char format "x(12)" extent 5
            initial [" "," ","","",""].
def var esqhel1         as char format "x(80)" extent 5
    initial [" Inclusao  de pdvd2019 ",
             " Alteracao da pdvd2019 ",
             " Exclusao  da pdvd2019 ",
             " Consulta  da pdvd2019 ",
             " Listagem  Geral de pdvd2019 "].
def var esqhel2         as char format "x(12)" extent 5
   initial ["  ",
            " ",
            " ",
            " ",
            " "].

assign
    esqcom1[3] = ""
    esqcom1[2] = "Imprime TELA"
    esqcom1[3] = "Analitico FAIXA"
    esqcom1[4] = "Analitico GERAL"
    esqcom1[5] = "Acrescimo AVP"
    .

if vcatcod <> ?
then assign
        esqcom1[3] = ""
        esqcom1[4] = ""
        esqcom1[5] = "".

def buffer bpdvd2019       for pdvd2019.


form
    esqcom1
    with frame f-com1
                 row 3 no-box no-labels side-labels column 1 centered.


disp esqcom1 with frame f-com1.

/*form
    esqcom2
    with frame f-com2
                 row screen-lines no-box no-labels side-labels column 1
                 centered.
                 */
assign
    esqregua = yes
    esqpos1  = 1
    esqpos2  = 1
    recatu1 = ?.

disp "TOTAL" to 15
         tsaldo_curva to 32 format ">>>>>>>>9.99"
         tprovisao to 53 format ">>>>>>>>9.99"
         tprincipal format ">>>>>>>>9.99"
         trenda format ">>>>>>>>9.99"
         with frame f-tot 1 down no-label no-box
         row 21  overlay color message width 80.
    
    pause 0.

bl-princ:
repeat:

    assign
    esqregua = yes
    esqpos1  = 1
    esqpos2  = 1.

    disp esqcom1 with frame f-com1.
    /*disp esqcom2 with frame f-com2.
    */
    pause 0.
    if recatu1 = ?
    then
        run leitura (input "pri").
    else
        find pdvd2019 where recid(pdvd2019) = recatu1 no-lock.
    if not available pdvd2019
    then esqvazio = yes.
    else esqvazio = no.
    clear frame frame-a all no-pause.
    if not esqvazio
    then do:
        run frame-a.
    end.
    else do:
        message color red/with
        "Nenhum registro encontrado."
        view-as alert-box.
        leave bl-princ.
    end.

    recatu1 = recid(pdvd2019).
    if esqregua
    then color display message esqcom1[esqpos1] with frame f-com1.
    else color display message esqcom2[esqpos2] with frame f-com2.
    
    pause 0.
    if not esqvazio
    then repeat:
        run leitura (input "seg").
        if not available pdvd2019
        then leave.
        
        if frame-line(frame-a) = frame-down(frame-a)
        then leave.
        down
            with frame frame-a.
        run frame-a.
        pause 0.
    end.
    if not esqvazio
    then up frame-line(frame-a) - 1 with frame frame-a.

    pause 0.
    repeat with frame frame-a:
        if not esqvazio
        then do:
            find pdvd2019 where recid(pdvd2019) = recatu1 no-lock.

            
            status default
                if esqregua
                then esqhel1[esqpos1] + if esqpos1 > 1 and
                                           esqhel1[esqpos1] <> ""
                                        then  string(pdvd2019.faixa_risco)
                                        else ""
                else esqhel2[esqpos2] + if esqhel2[esqpos2] <> ""
                                        then string(pdvd2019.faixa_risco)
                                        else "".
            
            run color-message.
            pause 0.
            choose field pdvd2019.faixa_risco help ""
                go-on(cursor-down cursor-up
                      cursor-left cursor-right
                      page-down   page-up
                      tab PF4 F4 ESC return) .
            run color-normal.
            pause 0.
            status default "".
            pause 0.
        end.
            if keyfunction(lastkey) = "TAB"
            then do:
                if esqregua
                then do:
                    color display normal esqcom1[esqpos1] with frame f-com1.
                    color display message esqcom2[esqpos2] with frame f-com2.
                end.
                else do:
                    color display normal esqcom2[esqpos2] with frame f-com2.
                    color display message esqcom1[esqpos1] with frame f-com1.
                end.
                esqregua = not esqregua.
            end.
            if keyfunction(lastkey) = "cursor-right"
            then do:
                if esqregua
                then do:
                    color display normal esqcom1[esqpos1] with frame f-com1.
                    esqpos1 = if esqpos1 = 5 then 5 else esqpos1 + 1.
                    color display messages esqcom1[esqpos1] with frame f-com1.
                end.
                else do:
                    color display normal esqcom2[esqpos2] with frame f-com2.
                    esqpos2 = if esqpos2 = 5 then 5 else esqpos2 + 1.
                    color display messages esqcom2[esqpos2] with frame f-com2.
                end.
                next.
            end.
            if keyfunction(lastkey) = "cursor-left"
            then do:
                if esqregua
                then do:
                    color display normal esqcom1[esqpos1] with frame f-com1.
                    esqpos1 = if esqpos1 = 1 then 1 else esqpos1 - 1.
                    color display messages esqcom1[esqpos1] with frame f-com1.
                end.
                else do:
                    color display normal esqcom2[esqpos2] with frame f-com2.
                    esqpos2 = if esqpos2 = 1 then 1 else esqpos2 - 1.
                    color display messages esqcom2[esqpos2] with frame f-com2.
                end.
                next.
            end.
            if keyfunction(lastkey) = "page-down"
            then do:
                do reccont = 1 to frame-down(frame-a):
                    run leitura (input "down").
                    if not avail pdvd2019
                    then leave.
                    recatu1 = recid(pdvd2019).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "page-up"
            then do:
                do reccont = 1 to frame-down(frame-a):
                    run leitura (input "up").
                    if not avail pdvd2019
                    then leave.
                    recatu1 = recid(pdvd2019).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "cursor-down"
            then do:
                run leitura (input "down").
                if not avail pdvd2019
                then next.
                color display white/red pdvd2019.faixa_risco with frame frame-a.
                if frame-line(frame-a) = frame-down(frame-a)
                then scroll with frame frame-a.
                else down with frame frame-a.
            end.
            if keyfunction(lastkey) = "cursor-up"
            then do:
                run leitura (input "up").
                if not avail pdvd2019
                then next.
                color display white/red pdvd2019.faixa_risco with frame frame-a.
                if frame-line(frame-a) = 1
                then scroll down with frame frame-a.
                else up with frame frame-a.
            end.
 
        if keyfunction(lastkey) = "end-error"
        then leave bl-princ.

        if keyfunction(lastkey) = "return" or esqvazio
        then do:
            form pdvd2019
                 with frame f-pdvd2019 color black/cyan
                      centered side-label row 5 .
            hide frame frame-a no-pause.
            if esqregua
            then do:
                display caps(esqcom1[esqpos1]) @ esqcom1[esqpos1]
                        with frame f-com1.

                if esqcom1[esqpos1] = "Imprime TELA" 
                then do:
                    sresp = no.
                    message "Confirma relatorio " esqcom1[esqpos1] "?"
                    update sresp.
                    if sresp
                    then run relatorio-tela.
                    recatu1 = recid(pdvd2019).
                    color display normal esqcom1[esqpos1] with frame f-com1.
                    leave.
                end.
                if esqcom1[esqpos1] = "Analitico FAIXA"
                then do:
                    sresp = no.
                    message "Confirma arquivo " esqcom1[esqpos1] 
                    pdvd2019.faixa_risco "?"
                    update sresp.
                    if sresp
                    then run relatorio-analitico-FAIXA(pdvd2019.faixa_risco).
                    recatu1 = recid(pdvd2019).
                    color display normal esqcom1[esqpos1] with frame f-com1.
                    leave.
                end.
                if esqcom1[esqpos1] = "Analitico GERAL"
                then do:
                    sresp = no.
                    message "Confirma arquivo " vcobra[vindex] 
                        " " esqcom1[esqpos1] "?"
                    update sresp.
                    if sresp
                    then run relatorio-analitico-GERAL.
                    recatu1 = recid(pdvd2019).
                    color display normal esqcom1[esqpos1] with frame f-com1.
                    leave.
                end.
                if esqcom1[esqpos1] = "Acrescimo AVP"
                then do:
                    sresp = no.
                    message "Confirma relatorio " esqcom1[esqpos1] "?"
                    update sresp.
                    if sresp
                    then run relatorio-avp-txt.
                    recatu1 = recid(pdvd2019).
                    color display normal esqcom1[esqpos1] with frame f-com1.
                    leave.
                end.
            end.
            else do:
                display caps(esqcom2[esqpos2]) @ esqcom2[esqpos2]
                        with frame f-com2.
                if esqcom2[esqpos2] = "  "
                then do:
                    hide frame f-com1  no-pause.
                    hide frame f-com2  no-pause.
                    /* run programa de relacionamento.p (input ). */
                    view frame f-com1.
                    view frame f-com2.
                end.
                leave.
            end.
        end.
        if not esqvazio
        then do:
            run frame-a.
        end.
        if esqregua
        then display esqcom1[esqpos1] with frame f-com1.
        else display esqcom2[esqpos2] with frame f-com2.
        recatu1 = recid(pdvd2019).
    end.
    if keyfunction(lastkey) = "end-error"
    then do:
        view frame fc1.
        view frame fc2.
    end.
end.
end.
end.
hide frame f-com1  no-pause.
hide frame f-com2  no-pause.
hide frame frame-a no-pause.

procedure frame-a.
display pdvd2019.faixa_risco 
        pdvd2019.descricao_faixa
                    pdvd2019.saldo_curva
                    pdvd2019.pctprovisao
                    pdvd2019.provisao
                    pdvd2019.principal
                    pdvd2019.renda
        with frame frame-a .
end procedure.
procedure color-message.
color display message
        pdvd2019.descricao_faixa
                    pdvd2019.saldo_curva
                    pdvd2019.pctprovisao
                    pdvd2019.provisao
                    pdvd2019.principal
                    pdvd2019.renda
        with frame frame-a.
end procedure.
procedure color-normal.
color display normal
        pdvd2019.descricao_faixa
                    pdvd2019.saldo_curva
                    pdvd2019.pctprovisao
                    pdvd2019.provisao
                    pdvd2019.principal
                    pdvd2019.renda
        with frame frame-a.
end procedure.

procedure leitura . 
def input parameter par-tipo as char.
        
if par-tipo = "pri" 
then  
    if esqascend  
    then  
        find first pdvd2019 where 
                    pdvd2019.data_visao = vdatref and
                    pdvd2019.tipo_visao = vtipo_visao and
                    pdvd2019.modo_visao = vmodo_visao and 
                    pdvd2019.modalidade = "CRE" and
                    pdvd2019.cobcod = vcobcod and
                    pdvd2019.categoria = vcatcod and
                    pdvd2019.etbcod = 0 

                                                no-lock no-error.
    else  
        find last pdvd2019  where
                    pdvd2019.data_visao = vdatref and
                    pdvd2019.tipo_visao = vtipo_visao and
                    pdvd2019.modo_visao = vmodo_visao and 
                    pdvd2019.modalidade = "CRE" and
                    pdvd2019.cobcod = vcobcod and
                    pdvd2019.categoria = vcatcod and
                    pdvd2019.etbcod = 0 

                                                 no-lock no-error.
                                             
if par-tipo = "seg" or par-tipo = "down" 
then  
    if esqascend  
    then  
        find next pdvd2019  where 
                    pdvd2019.data_visao = vdatref and
                    pdvd2019.tipo_visao = vtipo_visao and
                    pdvd2019.modo_visao = vmodo_visao and 
                    pdvd2019.modalidade = "CRE" and
                    pdvd2019.cobcod = vcobcod and
                    pdvd2019.categoria = vcatcod and
                    pdvd2019.etbcod = 0 

                                                no-lock no-error.
    else  
        find prev pdvd2019   where 
                    pdvd2019.data_visao = vdatref and
                    pdvd2019.tipo_visao = vtipo_visao and
                    pdvd2019.modo_visao = vmodo_visao and 
                    pdvd2019.modalidade = "CRE" and
                    pdvd2019.cobcod = vcobcod and
                    pdvd2019.categoria = vcatcod and
                    pdvd2019.etbcod = 0 

                                                no-lock no-error.
             
if par-tipo = "up" 
then                  
    if esqascend   
    then   
        find prev pdvd2019 where 
                    pdvd2019.data_visao = vdatref and
                    pdvd2019.tipo_visao = vtipo_visao and
                    pdvd2019.modo_visao = vmodo_visao and 
                    pdvd2019.modalidade = "CRE" and
                    pdvd2019.cobcod = vcobcod and
                    pdvd2019.categoria = vcatcod and
                    pdvd2019.etbcod = 0 

                                        no-lock no-error.
    else   
        find next pdvd2019 where 
                    pdvd2019.data_visao = vdatref and
                    pdvd2019.tipo_visao = vtipo_visao and
                    pdvd2019.modo_visao = vmodo_visao and 
                    pdvd2019.modalidade = "CRE" and
                    pdvd2019.cobcod = vcobcod and
                    pdvd2019.categoria = vcatcod and
                    pdvd2019.etbcod = 0 

                                        no-lock no-error.
        
end procedure.
         
procedure relatorio-tela:
    def var varquivo as char.
    def var varqcsv as char .
    def var sld-curva as dec.
    def var vprovisao as dec.
    def var vencidos as dec.
    def var vencer90 like pdvd2019.vencer_90 .
    def var vencer360 like pdvd2019.vencer_360.
    def var vencer1080 like pdvd2019.vencer_1080.
    def var vencer1900 like pdvd2019.vencer_1800 .
    def var vencer5400 like pdvd2019.vencer_5400  .
    def var vencer9999 like pdvd2019.vencer_9999   .
     
    varquivo = "/admcom/relat/bga-cliente-" 
                + string(vdatref,"99999999") + "-" + string(time).
    varqcsv = "l:\relat\bga-cliente-"
                    + string(vdatref,"99999999") + "-" + string(time).

    {mdadmcab.i 
        &Saida     = "value(varquivo)" 
        &Page-Size = "64" 
        &Cond-Var  = "80"  
        &Page-Line = "66"
        &Nom-Rel   = ""pdvd2019v""  
        &Nom-Sis   = """SISTEMA ADMCOM CONTABIL"""
        &Tit-Rel   = """RELATORIO DEVEDORES"""
        &Width     = "80"
        &Form      = "frame f-cabcab"}

    put unformatted string(vdatref,"99/99/9999") + " - " + vtipo_visao + " - " +
                vmodo_visao + " - " + trim(vcobra[vindex]) + " "
                skip.
                
    vi = 0. 

    for each pdvd2019 where 
             pdvd2019.data_visao = vdatref and
             pdvd2019.tipo_visao = vtipo_visao and
             pdvd2019.modo_visao = vmodo_visao and
             pdvd2019.modalidade = "CRE" and
             pdvd2019.cobcod     = vcobcod and
             pdvd2019.categoria  = vcatcod and
             pdvd2019.faixa_risco <> "" no-lock:
        
        /*
        find first tbcntgen where
                   tbcntgen.tipcon = 13 and
                   tbcntgen.campo1[1] = pdvd2019.faixa_risco 
                   no-lock no-error.
        if avail tbcntgen
        then pdvd2019.descricao_faixa = tbcntgen.numini + "-" +
                            tbcntgen.numfim.
        */

        if pdvd2019.faixa_risco < "H"
        then assign
            vencidos = pdvd2019.vencido
            vencer90 = pdvd2019.vencer_90
            vencer360 = pdvd2019.vencer_360
            vencer1080 = pdvd2019.vencer_1080
            vencer1900 = pdvd2019.vencer_1800
            vencer5400 = pdvd2019.vencer_5400 
            vencer9999 = pdvd2019.vencer_9999
            .
        else assign
            vencidos = pdvd2019.vencido +
                       pdvd2019.vencer_90 + pdvd2019.vencer_360 +
                       pdvd2019.vencer_1080 + pdvd2019.vencer_1800 +
                       pdvd2019.vencer_5400 + pdvd2019.vencer_9999
            vencer90 = 0
            vencer360 = 0
            vencer1080 = 0
            vencer1900 = 0
            vencer5400 = 0
            vencer9999 = 0
            .

        disp pdvd2019.faixa_risco column-label "Faixa"
             pdvd2019.descricao_faixa no-label   format "x(12)"
             /*
             vencidos column-label "Vencidos"
             format ">>>,>>>,>>9.99" (total)
             vencer90  column-label "Vencer!Ate 3 meses"
             format ">>>,>>>,>>9.99" (total)
             vencer360 column-label "Vencer!3 a 12 meses"
             format ">>>,>>>,>>9.99"  (total)
             vencer1080 column-label "Vencer!1 a 3 anos"
             format ">>>,>>>,>>9.99"  (total) 
             vencer1900 column-label "Vencer!3 a 5 anos"
             format ">>>,>>>,>>9.99"  (total)
             vencer5400 column-label "Vencer!5 a 15 anos"
             format ">>>,>>>,>>9.99"  (total)
             vencer9999 column-label "Vencer!+ 15 anos"
             format ">>>,>>>,>>9.99"  (total)
             */
             pdvd2019.saldo_curva  column-label "Saldo Curva"
             format ">>,>>>,>>>,>>9.99"  (total)
             pdvd2019.pctprovisao column-label "%"
             pdvd2019.provisao  column-label "Provisao"
             format ">>>,>>>,>>9.99"  (total)
             pdvd2019.principal(total) column-label "Principal"
             format ">>>,>>>,>>9.99"
             pdvd2019.renda(total) column-label "Renda"
             format ">>>,>>>,>>9.99"
             
             with frame f-disp1 down width 220.
            .
        down with frame f-disp1.
    end.
    vi = 0.
    /**************
    put skip(1) "CARTEIRA FINANCEIRA" skip.
    for each fn-risco NO-LOCK:
        find first tt-tbcntgen where
                   tt-tbcntgen.nivel = fn-risco.risco 
                   no-error.
        if avail tt-tbcntgen
        then fn-risco.des = tt-tbcntgen.numini + "-" +
                            tt-tbcntgen.numfim.
        fn-risco.total = fn-risco.vencido + fn-risco.vencer.
        /***
        disp fn-risco.risco column-label "Faixa"
             fn-risco.des no-label   format "x(12)"
             fn-risco.vencido(total) column-label "Vencidos"
             fn-risco.vencer(total)  column-label "Vencer"
             fn-risco.total(total)   column-label "Total"
             fn-risco.principal(total) column-label "Principal"
             fn-risco.acrescimo(total) column-label "Renda"
             with frame f-disp2 down width 120.
        ****/
        vi = vi + 1.    
        sld-curva = fn-risco.vencido +
                    fn-risco.ven-90 + fn-risco.ven-360 +
                    fn-risco.ven-1080 + fn-risco.ven-1900 +
                    fn-risco.ven-5400 + fn-risco.ven-9999
                    .
        vprovisao = sld-curva * (v-pct[vi] / 100).
        disp fn-risco.risco column-label "Faixa"
             fn-risco.des no-label   format "x(12)"
             fn-risco.vencido column-label "Vencidos"
             format ">>>,>>>,>>9.99" (total)
             /*fn-risco.ven-90  column-label "Vencer!Ate 3 meses"
             format ">>>,>>>,>>9.99" (total)
             fn-risco.ven-360 column-label "Vencer!3 a 12 meses"
             format ">>>,>>>,>>9.99"  (total)
             fn-risco.ven-1080 column-label "Vencer!1 a 3 anos"
             format ">>>,>>>,>>9.99"  (total) 
             fn-risco.ven-1900 column-label "Vencer!3 a 5 anos"
             format ">>>,>>>,>>9.99"  (total)
             fn-risco.ven-5400 column-label "Vencer!5 a 15 anos"
             format ">>>,>>>,>>9.99"  (total)
             fn-risco.ven-9999 column-label "Vencer!+ 15 anos"
             format ">>>,>>>,>>9.99"  (total) */
             sld-curva  column-label "Sld Curva"
             format ">>,>>>,>>>,>>9.99"  (total)
             vprovisao  column-label "Provisao"
             format ">>>,>>>,>>9.99"  (total)
             v-pct[vi] column-label "%"
             fn-risco.principal(total) column-label "Principal"
             format ">>>,>>>,>>9.99"
             fn-risco.acrescimo(total) column-label "Renda"
             format ">>>,>>>,>>9.99"
             with frame f-disp2 down width 220.
            .
        down with frame f-disp2.

    end.   
    vi = 0.  
    put skip(1) "CARTEIRA GERAL" skip.
    for each tt-risco where tt-risco.risco <> "" NO-LOCK:
        find first tt-tbcntgen where
                   tt-tbcntgen.nivel = tt-risco.risco 
                   no-error.
        if avail tt-tbcntgen
        then tt-risco.des = tt-tbcntgen.numini + "-" +
                            tt-tbcntgen.numfim.
        tt-risco.total = tt-risco.vencido + tt-risco.vencer.
        
        /*******
        disp tt-risco.risco column-label "Faixa"
             tt-risco.des no-label   format "x(12)"
             tt-risco.vencido(total) column-label "Vencidos"
             tt-risco.vencer(total)  column-label "Vencer"
             tt-risco.total(total)   column-label "Total"
             tt-risco.principal(total) column-label "Principal"
             tt-risco.acrescimo(total) column-label "Renda"
             with frame f-disp3 down width 120.
        ***********/
        
        vi = vi + 1.    
        sld-curva = tt-risco.vencido + 
                    tt-risco.ven-90 + tt-risco.ven-360 +
                    tt-risco.ven-1080 + tt-risco.ven-1900 +
                    tt-risco.ven-5400 + tt-risco.ven-9999
                    .
        vprovisao = sld-curva * (v-pct[vi] / 100).
        disp tt-risco.risco column-label "Faixa"
             tt-risco.des no-label   format "x(12)"
             tt-risco.vencido column-label "Vencidos"
             format ">>>,>>>,>>9.99" (total)
             tt-risco.ven-90  column-label "Vencer!Ate 3 meses"
             format ">>>,>>>,>>9.99" (total)
             tt-risco.ven-360 column-label "Vencer!3 a 12 meses"
             format ">>>,>>>,>>9.99"  (total)
             tt-risco.ven-1080 column-label "Vencer!1 a 3 anos"
             format ">>>,>>>,>>9.99"  (total) 
             tt-risco.ven-1900 column-label "Vencer!3 a 5 anos"
             format ">>>,>>>,>>9.99"  (total)
             tt-risco.ven-5400 column-label "Vencer!5 a 15 anos"
             format ">>>,>>>,>>9.99"  (total)
             tt-risco.ven-9999 column-label "Vencer!+ 15 anos"
             format ">>>,>>>,>>9.99"  (total)
             sld-curva  column-label "Sld Curva"
             format ">>,>>>,>>>,>>9.99"  (total)
             vprovisao  column-label "Provisao"
             format ">>>,>>>,>>9.99"  (total)
             v-pct[vi] column-label "%"
             tt-risco.principal(total) column-label "Principal"
             format ">>>,>>>,>>9.99"
             tt-risco.acrescimo(total) column-label "Renda"
             format ">>>,>>>,>>9.99"
             with frame f-disp3 down width 220.
            .
        down with frame f-disp3.

    end.     
    ****************/
    output close.

    run visurel.p(varquivo,"").
    
end procedure.


procedure relatorio-faixa-filial:
    def var vindex as int.
    vindex = 2.
    for each tt-pdvd2019: delete tt-pdvd2019. end.
    for each pdvd2019 where pdvd2019.data_visao = vdatref     and
                        pdvd2019.tipo_visao = vtipo_visao and
                        pdvd2019.modo_visao = vmodo_visao and
                        pdvd2019.modalidade = "CRE" and
                        pdvd2019.cobcod     = vcobcod and
                        pdvd2019.categoria  = vcatcod and
                        pdvd2019.etbcod > 0
                        no-lock:
        find first tt-pdvd2019 where
                   tt-pdvd2019.data_visao = pdvd2019.data_visao and
                   tt-pdvd2019.tipo_visao = pdvd2019.tipo_visao and
                   tt-pdvd2019.modo_visao = pdvd2019.modo_visao and
                   tt-pdvd2019.modalidade = pdvd2019.modalidade and
                   tt-pdvd2019.cobcod     = pdvd2019.cobcod and 
                   tt-pdvd2019.categoria  = pdvd2019.categoria and
                   tt-pdvd2019.etbcod     = pdvd2019.etbcod 
                   no-error.
        if not avail tt-pdvd2019
        then do:
            create tt-pdvd2019.
            assign
                tt-pdvd2019.data_visao = pdvd2019.data_visao
                tt-pdvd2019.tipo_visao = pdvd2019.tipo_visao
                tt-pdvd2019.modo_visao = pdvd2019.modo_visao
                tt-pdvd2019.modalidade = pdvd2019.modalidade
                tt-pdvd2019.cobcod     = pdvd2019.cobcod
                tt-pdvd2019.categoria  = pdvd2019.categoria
                tt-pdvd2019.etbcod     = pdvd2019.etbcod
                .
        end.
        assign
            tt-pdvd2019.saldo_curva = tt-pdvd2019.saldo_curva +
                                        pdvd2019.saldo_curva
            tt-pdvd2019.provisao    = tt-pdvd2019.provisao +
                                        pdvd2019.provisao
            tt-pdvd2019.principal   = tt-pdvd2019.principal +
                                        pdvd2019.principal
            tt-pdvd2019.renda       = tt-pdvd2019.renda +
                                        pdvd2019.renda
            .
    end.     
    def var varquivo as char.
    varquivo = "/admcom/relat/" + lc(vtipo_visao) + "-" + lc(vmodo_visao) + "-"
                + lc(trim(vcobra[vindex])) + "-"
                + string(vdatref,"99999999") 
                + ".txt".   
    {md-adm-cab.i 
        &Saida     = "value(varquivo)" 
        &Page-Size = "64" 
        &Cond-Var  = "100"  
        &Page-Line = "66"
        &Nom-Rel   = ""pdvd2019v""  
        &Nom-Sis   = """SISTEMA ADMCOM CONTABIL"""
        &Tit-Rel   = """RELATORIO DEVEDORES"""
        &Width     = "100"
        &Form      = "frame f-cabcab"}

    put unformatted string(vdatref,"99/99/9999") + " - " + vtipo_visao + " - " +
                vmodo_visao + " - " + trim(vcobra[vindex])
                 + " - " trim(esqcom1[esqpos1])
                skip.

    for each tt-pdvd2019 where tt-pdvd2019.etbcod > 0 no-lock:
        disp tt-pdvd2019.etbcod column-label "Filial" 
        tt-pdvd2019.saldo_curva(total) format ">>>,>>>,>>9.99"
        tt-pdvd2019.provisao(total)  format ">>>,>>>,>>9.99"
        tt-pdvd2019.principal(total) format ">>>,>>>,>>9.99"
        tt-pdvd2019.renda(total)     format ">>>,>>>,>>9.99"
            with down width 100.
            . 
    end.  
    output close.
    
    run visurel.p(input varquivo,"").
                      
end procedure.

procedure relatorio-AVP-csv:
    def var ven-cido as char.
    def var ven-cer  as char.
    def var ven-cersa  as char.
    def var tven-cersa  as char.
    def var ttven-cersa  as dec.
    def var ven-cerca  as char.
    def var tven-cerca  as char.
    def var ttven-cerca  as dec.
    def var avp-dia  as char.
    def var tavp-dia  as char.
    def var ttavp-dia  as dec.
    def var varquivo as char.
    def var prin-cipal as char.
    def var acres-cimo as char.
    def var principal-emissao as char.
    def var tprincipal-emissao as dec.
    def var acrescimo-emissao as char.
    def var tacrescimo-emissao as dec.
    def var principal-vencido as char.
    def var tprincipal-vencido as dec.
    def var acrescimo-vencido as char.
    def var tacrescimo-vencido as dec.
    def var principal-vencer  as char.
    def var tprincipal-vencer  as dec.
    def var acrescimo-vencer  as char.
    def var tacrescimo-vencer  as dec.
 
    varquivo = "/admcom/relat/saldo-devedores-avp-dia"
           + string(vdatref,"99999999") + "_" +
            string(time) + ".csv".
    
    output to value(varquivo).    

    disp with frame f-top .

    put skip.
    put "Ano;Mes;Vencido;Vencer s/a;Vencer c/a;Valor AVP" skip.
    for each sqmesavp where
             sqmesavp.tpvisao = vtipo_visao and
             sqmesavp.dtvisao = vdatref 
             no-lock:
        if sqmesavp.ano = 0 
        then next.
        if sqmesavp.avencer = 0 and
           sqmesavp.avpdia = 0
        then next.
        if sqmesavp.mes = 0 then next.
        assign
            ttven-cersa = ttven-cersa + sqmesavp.avencer-sacr
            ttven-cerca = ttven-cerca + sqmesavp.avencer
            ttavp-dia   = ttavp-dia   + sqmesavp.avpdia
            .
    end.
    assign
        tven-cersa = string(ttven-cersa,">>>>>>>>9.99")
        tven-cersa = replace(tven-cersa,".",",")
        tven-cerca = string(ttven-cerca,">>>>>>>>9.99")
        tven-cerca = replace(tven-cerca,".",",")
        tavp-dia   = string(ttavp-dia,">>>>>>>>9.99")
        tavp-dia   = replace(tavp-dia,".",",")
        .            

    for each sqmesavp where
             sqmesavp.tpvisao = vtipo_visao and
             sqmesavp.dtvisao = vdatref 
             no-lock:
        if sqmesavp.ano = 0 
        then next.
        if sqmesavp.avencer = 0 and
           sqmesavp.avpdia = 0
        then next.
    
        assign
            ven-cido = string(sqmesavp.vencido,">>>>>>>>9.99")
            ven-cido = replace(ven-cido,".",",").
        if sqmesavp.mes = 0   
        then assign 
            ven-cer  = string(sqmesavp.avencer,">>>>>>>>9.99")
            ven-cer  = replace(ven-cer,".",",")
            .
        else assign    
            ven-cer  = "0,00"
            ven-cersa = string(sqmesavp.avencer-sacr,">>>>>>>>9.99")
            ven-cersa  = replace(ven-cersa,".",",")
            ven-cerca = string(sqmesavp.avencer,">>>>>>>>9.99")
            ven-cerca  = replace(ven-cerca,".",",")
            avp-dia  = string(sqmesavp.avpdia,">>>>>>>>9.99")
            avp-dia  = replace(avp-dia,".",",")
            .
        assign
            prin-cipal = string(sqmesavp.principal,">>>>>>>>9.99")
            prin-cipal = replace(prin-cipal,".",",")
            acres-cimo = string(sqmesavp.acrescimo,">>>>>>>>9.99")
            acres-cimo = replace(acres-cimo,".",",")
            tprincipal-emissao = tprincipal-emissao +
                                 sqmesavp.principal_emissao_mes
            tacrescimo-emissao = tacrescimo-emissao +
                                 sqmesavp.acrescimo_emissao_mes
            /*                     
            principal-emissao =
                      string(sqmesavp.principal_emissao_mes,">>>>>>>>9.99")
            principal-emissao = replace(principal-emissao,".",",")
            acrescimo-emissao =
                      string(sqmesavp.acrescimo_emissao_mes,">>>>>>>>9.99")
            acrescimo-emissao = replace(acrescimo-emissao,".",",")
            */
            tprincipal-vencido = tprincipal-vencido +
                                 sqmesavp.principal_vencido
            tacrescimo-vencido = tacrescimo-vencido +
                                 sqmesavp.acrescimo_vencido
            /*                     
            principal-vencido =
                      string(sqmesavp.principal_vencido,">>>>>>>>9.99")
            principal-vencido = replace(principal-vencido,".",",")
            acrescimo-vencido =
                      string(sqmesavp.acrescimo_vencido,">>>>>>>>9.99")
            acrescimo-vencido = replace(acrescimo-vencido,".",",")
            */
            tprincipal-vencer = tprincipal-vencer +
                                sqmesavp.principal_vencer
            tacrescimo-vencer = tacrescimo-vencer +
                                sqmesavp.acrescimo_vencer
            /*                    
            principal-vencer =
                      string(sqmesavp.principal_vencer,">>>>>>>>9.99")
            principal-vencer = replace(principal-vencer,".",",")
            acrescimo-vencer =
                      string(sqmesavp.acrescimo_vencer,">>>>>>>>9.99")
            acrescimo-vencer = replace(acrescimo-vencer,".",",")
            */
             .

        put unformatted 
            sqmesavp.ano format ">>>9" ";"
            sqmesavp.mes ";"
            .

        if sqmesavp.mes = 0
        then put ven-cido format "x(15)" ";"
                 tven-cersa format "x(15)" ";"
                 tven-cerca  format "x(15)" ";"
                 tavp-dia  format "x(15)"
                 .
        else put ";"
             ven-cersa format "x(15)" ";"
             ven-cerca  format "x(15)" ";"
             avp-dia  format "x(15)" 
             .
        put skip.
       
        prin-cipal = "".
        acres-cimo = "".
    end.
    
    assign                     
        principal-emissao = string(tprincipal-emissao,">>>>>>>>9.99")
        principal-emissao = replace(principal-emissao,".",",")
        acrescimo-emissao = string(tacrescimo-emissao,">>>>>>>>9.99")
        acrescimo-emissao = replace(acrescimo-emissao,".",",")
        principal-vencido = string(tprincipal-vencido,">>>>>>>>9.99")
        principal-vencido = replace(principal-vencido,".",",")
        acrescimo-vencido = string(tacrescimo-vencido,">>>>>>>>9.99")
        acrescimo-vencido = replace(acrescimo-vencido,".",",")
        principal-vencer  = string(tprincipal-vencer,">>>>>>>>9.99")
        principal-vencer = replace(principal-vencer,".",",")
        acrescimo-vencer = string(tacrescimo-vencer,">>>>>>>>9.99")
        acrescimo-vencer = replace(acrescimo-vencer,".",",")
             .

    put skip(1).
    put ";;;Principal;Acrescimo;;" skip.
    put ";;Emissao;" principal-emissao format "x(15)"
        ";" acrescimo-emissao format "x(15)"
        ";;" skip.
    put ";;Vencidos;" principal-vencido format "x(15)"
        ";" acrescimo-vencido format "x(15)"
        ";;" skip.
    put ";;A Vencer;" principal-vencer format "x(15)"
        ";" acrescimo-vencer format "x(15)"
        ";;" skip.

    output close.
    message color red/with
    varquivo
    view-as alert-box
    .
    
end procedure.

procedure relatorio-AVP-txt:
    def var ven-cido as dec.
    def var ven-cer  as dec.
    def var ven-cersa  as dec.
    def var tven-cersa  as dec.
    def var ven-cerca  as dec.
    def var tven-cerca  as dec.
    def var avp-dia  as dec.
    def var tavp-dia  as dec.
    def var varquivo as char.
    def var prin-cipal as dec.
    def var acres-cimo as dec.
    def var principal-emissao as dec.
    def var acrescimo-emissao as dec.
    def var principal-vencido as dec.
    def var acrescimo-vencido as dec.
    def var principal-vencer  as dec.
    def var acrescimo-vencer  as dec.
    def var acrescimo-competencia as dec.
    def var principal-competencia as dec.
    def var acrescimo-realizado as dec.
    def var principal-realizado as dec.
    form 
        sqmesavp.ano format ">>>9" column-label "Ano"
        sqmesavp.mes               column-label "Mes"
        ven-cido   format ">>>,>>>,>>9.99" column-label "Vencido"
        tven-cersa  format ">>>,>>>,>>9.99" column-label "Vencer!S/Acrescimo"
        tven-cerca  format ">>>,>>>,>>9.99" column-label "Vencer!C/Acrescimo"
        tavp-dia    format ">>>,>>>,>>9.99" column-label "Vencer!AVP"
        with frame f-disp down width 80 
            .
 
    varquivo = "/admcom/relat/saldo-devedores-avp-dia"
           + string(vdatref,"99999999") + "_" +
            string(time) + ".txt".
    
    output to value(varquivo).    

    disp "Sistema ADMCOM - " wempre.emprazsoc  format "x(40)"
         today string(time,"hh:mm:ss")
         "Data de Referencia:" vdatref with frame f-top no-label.
    
    for each sqmesavp where
             sqmesavp.tpvisao = "CONTABILIDADE" /*vtipo_visao*/ and
             sqmesavp.dtvisao = vdatref 
             no-lock:
        if sqmesavp.ano = 0 
        then next.
        if sqmesavp.avencer = 0 and
           sqmesavp.avpdia = 0
        then next.
        if sqmesavp.mes = 0 then next.
        assign
            tven-cersa = tven-cersa + sqmesavp.avencer-sacr
            tven-cerca = tven-cerca + sqmesavp.avencer
            tavp-dia   = tavp-dia   + sqmesavp.avpdia
            .
    end.
    for each sqmesavp where
             sqmesavp.tpvisao = "CONTABILIDADE" /*vtipo_visao*/ and
             sqmesavp.dtvisao = vdatref 
             no-lock by ano by mes:
        if sqmesavp.ano = 0 
        then next.
        if sqmesavp.avencer = 0 and
           sqmesavp.avpdia = 0
        then next.
    
        ven-cido = sqmesavp.vencido.
        if sqmesavp.mes = 0   
        then ven-cer  = sqmesavp.avencer.
        else assign    
            ven-cer  = 0
            ven-cersa = sqmesavp.avencer-sacr
            ven-cerca = sqmesavp.avencer
            avp-dia  = sqmesavp.avpdia
            .

        assign
            prin-cipal = prin-cipal + sqmesavp.principal
            acres-cimo = acres-cimo + sqmesavp.acrescimo
            principal-emissao = principal-emissao +
                                sqmesavp.principal_emissao_mes
            acrescimo-emissao = acrescimo-emissao +
                                sqmesavp.acrescimo_emissao_mes
            principal-vencido = principal-vencido +
                                sqmesavp.principal_vencido
            acrescimo-vencido = acrescimo-vencido + 
                                sqmesavp.acrescimo_vencido
            principal-vencer  = principal-vencer +
                                sqmesavp.principal_vencer
            acrescimo-vencer  = acrescimo-vencer +
                                sqmesavp.acrescimo_vencer
            principal-competencia = principal-competencia +
                                    sqmesavp.principal_competencia
            acrescimo-competencia = acrescimo-competencia +
                                sqmesavp.acrescimo_competencia
            principal-realizado = principal-realizado +
                                sqmesavp.principal_realizado
            acrescimo-realizado = acrescimo-realizado +
                                sqmesavp.acrescimo_realizado
             .
       
        if sqmesavp.mes = 0
        then disp sqmesavp.ano
                  sqmesavp.mes  
                  ven-cido
                  tven-cersa
                  tven-cerca
                  tavp-dia
                  with frame f-disp.
        else disp           
              sqmesavp.ano
              sqmesavp.mes
              ven-cido
              ven-cersa @ tven-cersa
              ven-cerca @ tven-cerca
              avp-dia   @ tavp-dia
              with frame f-disp 
              .

        down with frame f-disp.
        prin-cipal = 0.
        acres-cimo = 0.
    end.

    /********
    down(1) with frame f-disp.

    disp string(vdatref) @ ven-cido
         "      Principal" format "x(15)" @ tven-cersa
         "      Acrescimo" format "x(15)" @ tven-cerca
         with frame f-disp.
    down with frame f-disp. 
    disp "Vencido" @ ven-cido
         principal-vencido @ tven-cersa
         acrescimo-vencido @ tven-cerca
         with frame f-disp.
    down with frame f-disp.
    disp "A Vencer" @ ven-cido
         principal-vencer @ tven-cersa
         acrescimo-vencer @ tven-cerca
         with frame f-disp.
    down(2) with frame f-disp.
 
    disp "1 a " + string(vdatref) format "x(12)" @ ven-cido
         "      Principal" format "x(15)" @ tven-cersa
         "      Acrescimo" format "x(15)" @ tven-cerca
         with frame f-disp.
    down with frame f-disp.     
    disp "Emissao" @ ven-cido 
         principal-emissao  @ tven-cersa
         acrescimo-emissao  @ tven-cerca
         with frame f-disp.
    down with frame f-disp.
    disp "Competencia" @ ven-cido
         principal-competencia @ tven-cersa
         acrescimo-competencia @ tven-cerca
         with frame f-disp.
    down with frame f-disp.  
    disp "Realizado" @ ven-cido
         principal-realizado @ tven-cersa
         acrescimo-realizado @ tven-cerca
         with frame f-disp.
    down with frame f-disp.  
    *********/
    
    output close.

    run visurel.p(varquivo,"").
    
end procedure.
                              

procedure relatorio-analitico-FAIXA:
    def input parameter p-risco as char.
    def var varquivo as char.
    def var varqcsv as char.
    def var sld-curva as dec.
    def var vprovisao as dec.
    def var vtotal as dec.
    def var vindex as int.
    def var valaberto as dec.
    def var vclinom like clien.clinom.
    def var vciccgc like clien.ciccgc.
    def var vdtven as date.
    if vmodo_visao = "CONTRATO"
    then vindex = 1.
    else vindex = 2.
    
    disp "Gerando relatorio... Aguarde!" skip
         varquivo format "x(70)"
        with frame f-dd 1 down centered overlay color message
        row 10 no-label .
    pause 0.
 

    varquivo = "/admcom/relat/saldo-clientes-" 
                + string(vdatref,"99999999") + "-risco-" 
                + p-risco + ".txt".   

    def var valchar as char.
    def var varq as char.
    def var vok as log.
    
    varq = "/admcom/relat/saldo-clientes-" 
                + string(vdatref,"99999999") + "-risco-" 
                + p-risco + ".csv". 
    
    output to value(varq).
    put "Codigo;Nome;CPF;Contrato; Valor ;Emiss�o;Vencimento_inicial;Vencimento_final;Filial;
Tipo de cobran�a;Data Referencia" skip.

    /*
    "Nome;CPF;Numero;Valor;Vencimento;Atraso" skip.
    */
    vtotal = 0.                  
    if vindex = 1
    then do:
    for each visdev19 where visdev19.data_visao = vdatref  and
                            visdev19.tipo_visao = vtipo_visao and
                            visdev19.risco_contrato = p-risco and
                            visdev19.cobcod = vcobcod and
                            /*visdev19.catcod = vcatcod and*/
                            visdev19.situacao = ""
                            no-lock:

        if visdev19.total_vencido = 0 and
           visdev19.total_vencer = 0
        then next.    
        assign
                vclinom = visdev19.nome
                vciccgc = visdev19.cpf.
        vok = no.
        
        /*************
        for each titulo where
                 titulo.empcod = visdev19.empcod and
                 titulo.titnat = visdev19.titnat and
                 titulo.modcod = visdev19.modcod and
                 titulo.titdtemi = visdev19.titdtemi and
                 titulo.etbcod = visdev19.etbcod and
                 titulo.clifor = visdev19.clifor and
                 titulo.titnum = visdev19.titnum and
                 (titulo.titsit = "LIB" or
                 (titulo.titsit = "PAG" and
                  titulo.titdtpag > vdatref)) 
                  and titulo.titpar > 0
                 no-lock: 
            if titulo.titvlcob > 0  and
               titulo.titdtven <> ?  and
               titulo.titdtven < 01/01/2030 and
               titulo.titdtven > 01/01/1990
            then do:                                  
                if visdev19.qtdatr > 0 /*220*/
                then vdtven = titulo.titdtven - visdev19.qtdat.
                else vdtven = titulo.titdtven.
                valchar = string(titulo.titvlcob).
                valchar = replace(valchar,",","").
                valchar = replace(valchar,".",",").
                put unformatted 
                vclinom 
                ";"
                vciccgc 
                ";"
                titulo.titnum 
                ";"
                valchar
                ";"
                vdtven 
                ";"
                .
                if vdatref - vdtven > 0
                then put vdatref - vdtven .
                else put "" 
                    .

                put skip.

                vtotal = vtotal + titulo.titvlcob.
                vok = yes.
            end.
        end.
        *****/

        valchar = string(visdev19.total_vencid + visdev19.total_vencer).
        valchar = replace(valchar,",","").
        valchar = replace(valchar,".",",").
                                        
        put unformatted 
                visdev19.clifor
                ";"
                vclinom 
                ";"
                vciccgc 
                ";"
                visdev19.titnum 
                ";"
                valchar
                ";"
                visdev19.titdtemi
                ";"
                visdev19.vencimento_inicial
                ";"
                visdev19.vencimento_final
                ";"
                visdev19.etbcod
                ";"
                ";"
                visdev19.data_visao 
                ";"
                .
                if vdatref - vdtven > 0
                then put vdatref - vdtven .
                else put "" 
                    .

                put skip.

                vtotal = vtotal + 
                        (visdev19.total_vencid + visdev19.total_vencer).
                vok = yes.
    end. 
    end.
    else do:
    for each visdev19 where visdev19.data_visao = vdatref  and
                            visdev19.tipo_visao = vtipo_visao and
                            visdev19.titnat = no and
                            visdev19.risco_cliente = p-risco and
                            visdev19.cobcod = vcobcod and
                            /*visdev19.catcod = vcatcod and*/
                            visdev19.situacao = ""
                            no-lock:

        if visdev19.clifor = 0 then next.
        if visdev19.clifor = 1 then next.
        if visdev19.clifor = ? then next.
 
        if visdev19.total_vencido = 0 and
           visdev19.total_vencer = 0
        then next.    
        assign
                vclinom = visdev19.nome
                vciccgc = visdev19.cpf.
        vok = no.
        for each titulo where
                 titulo.empcod = visdev19.empcod and
                 titulo.titnat = visdev19.titnat and
                 titulo.modcod = visdev19.modcod and
                 titulo.titdtemi = visdev19.titdtemi and
                 titulo.etbcod = visdev19.etbcod and
                 titulo.clifor = visdev19.clifor and
                 titulo.titnum = visdev19.titnum and
                 (titulo.titsit = "LIB" or
                 (titulo.titsit = "PAG" and
                  titulo.titdtpag > vdatref)) 
                  and titulo.titpar > 0
                 no-lock: 
            if titulo.titvlcob > 0  and
               titulo.titdtven <> ?  and
               titulo.titdtven < 01/01/2030 and
               titulo.titdtven > 01/01/1990
            then do:                                  
                if visdev19.qtdatr > 0 /*220*/
                then vdtven = titulo.titdtven - visdev19.qtdat.
                else vdtven = titulo.titdtven.
                valchar = string(titulo.titvlcob).
                valchar = replace(valchar,",","").
                valchar = replace(valchar,".",",").
                put unformatted 
                vclinom 
                ";"
                vciccgc 
                ";"
                titulo.titnum 
                ";"
                valchar
                ";"
                vdtven 
                ";"
                .
                if vdatref - vdtven > 0
                then put vdatref - vdtven .
                else put "" 
                    .

                put skip.

                vtotal = vtotal + titulo.titvlcob.
                vok = yes.
            end.
        end.
    end. 
    end.
    output close.

    message color red/with
    "Arquivo gerado"
    varq skip
    "Total:" vtotal
    view-as alert-box
    .
    
    /**********
    run visurel.p(input varquivo,"").
    *********/

end procedure.

procedure relatorio-analitico-GERAL:
    def var varquivo as char.
    def var varqcsv as char.
    def var sld-curva as dec.
    def var vprovisao as dec.
    def var vtotal as dec.
    /*def var vindex as int.
    */
    def var valaberto as dec.
    def var vclinom like clien.clinom.
    def var vciccgc like clien.ciccgc.
    def var vdtven as date.
    /*if vmodo_visao = "CONTRATO"
    then vindex = 1.
    else vindex = 2.
    */
 
    def var valchar as char.
    def var vok as log.
    def var vqa as int.
    def var varq as char.
    def var vqr as int.
    
    vqa = 1.
    varq = "/admcom/Contabilidade/relat/saldoclientes-" +
                trim(vcobra[vindex]) + "-"
                + string(vdatref,"99999999") 
                + "-arquivo-" + string(vqa,"9") 
                + ".csv". 

    disp "Gerando relatorio... Aguarde!" skip
              varq format "x(75)"
                      with frame f-dd 1 down centered overlay color message
                              row 10 no-label .
                                  pause 0.
                                  
    output to value(varq).
  
    put "Codigo;Nome;CPF;Contrato;Valor;Emissao;Vencimento_inicial;Vencimento_final;Risc o Cliente;Risco Contrato;Modalidade;Filial"
                    skip.
    
    vtotal = 0.                  

    for each visdev19 where visdev19.data_visao = vdatref  and
                            visdev19.tipo_visao = vtipo_visao and
                            (if vcobcod <> ? 
                             then visdev19.cobcod = vcobcod else true) and
                            visdev19.situacao = ""
                            no-lock:

        if visdev19.clifor = 0 then next.
        /*if visdev19.clifor = 1 then next.*/
        if visdev19.clifor = ? then next.
 
        if visdev19.total_vencido = 0 and
           visdev19.total_vencer = 0
        then next.    
        assign
                vclinom = visdev19.nome
                vciccgc = visdev19.cpf.
        vok = no.
     
                valchar = string(visdev19.total_vencido 
                                    + visdev19.total_vencer).
                valchar = replace(valchar,",","").
                valchar = replace(valchar,".",",").
                put unformatted 
                visdev19.clifor format ">>>>>>>>>9"
                ";"
                vclinom 
                ";"
                vciccgc 
                ";"
                visdev19.titnum 
                ";"
                valchar
                ";"
                visdev19.titdtemi format "99/99/9999"
                ";"
                visdev19.Vencimento_inicial format "99/99/9999"
                ";"
                visdev19.Vencimento_final format "99/99/9999"
                ";"
                visdev19.risco_cliente
                ";"
                visdev19.risco_contrato
                ";"
                visdev19.modcod
                ";"
                visdev19.etbcod
                skip
                .

    
        vqr = vqr + 1.
        if vqr >= 600000
        then do:
            output close.
            
            vqr = 0.
            vqa = vqa + 1.

            varq = "/admcom/Contabilidade/relat/saldoclientes-" +
                trim(vcobra[vindex]) + "-" 
                + string(vdatref,"99999999") 
                + "-arquivo-" + string(vqa,"9") 
                + ".csv". 
    
            output to value(varq).
            put "Codigo;Nome;CPF;Contrato;Valor;Emissao;Vencimento_inicial;Vencimento_final;Risc o Cliente;Riscao Contrato;Modalidade;Filial"
            skip.
         
        end.
                
        vtotal = vtotal + 
                 (visdev19.total_vencido + visdev19.total_vencer).
        
    end. 
    output close.
    
    message color red/with
    "Arquivo gerado"
    varq skip
    "Total:" vtotal
    view-as alert-box
    .
    
    /**********
    run visurel.p(input varquivo,"").
    *********/

end procedure.


