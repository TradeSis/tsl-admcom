/*****
connect ninja -H 10.2.0.29 -S 60002 -N tcp.
connect sensei -H 10.2.0.29 -S 60000 -N tcp.
connect nissei -H 10.2.0.29 -S 60001 -N tcp.
****/

{admcab.i}
{setbrw.i}

message "Verso Atual". pause.

def temp-table tt-faidev2018 like faidev2018.

def var vi as int.
def var vdatref as date format "99/99/9999".
def var vcobcod as int.
def var vtipo_visao as char.
def var vmodo_visao as char.
vtipo_visao = "GERENCIAL".
vmodo_visao = "CLIENTE".
vcobcod = 2.

find last faidev2018 no-lock no-error.
if avail faidev2018
then vdatref = faidev2018.data_visao.

update vdatref label "Data referencia" with frame f-dat side-label 1 down
width 80 row 4.
if vdatref > 01/01/19 or
   vdatref < 12/01/17
then return.

  
def var vtipo as char extent 3 format "x(15)". 
def var vcobra as char extent 3 format "x(15)".
def var vcateg as char extent 5 format "x(14)".
vtipo[1] = "  CONTRATO".
vtipo[2] = "  CLIENTE".
vtipo[3] = "  OUTROS".

vcobra[1] = "  GERAL".
vcobra[2] = "  DREBES".
vcobra[3] = "  FINANCEIRA".
  
vcateg[1] = "  GERAL".
vcateg[2] = "  MOVEIS".
vcateg[3] = "  MODA".
vcateg[4] = "  NOVACAO".
vcateg[5] = "  OUTROS"
.

repeat:
disp vtipo with frame f-tipo no-label centered.
choose field vtipo with frame f-tipo.
vmodo_visao = trim(vtipo[frame-index]).

def var vindex as int.

if vmodo_visao = "OUTROS"
then assign
        vindex = 1
        vcobcod = 2
        vtipo_visao = "KPMG"
        vmodo_visao = "CONTRATO".
else do:
disp vcobra with frame f-cobra no-label centered.
choose field vcobra with frame f-cobra.
if trim(vcobra[frame-index]) = "GERAL"
then assign
        vindex = 1
        vcobcod = ?.
else if trim(vcobra[frame-index]) = "DREBES"
    then assign
            vindex = 1
            vcobcod = 2.
    else if trim(vcobra[frame-index]) = "FINANCEIRA"
        THEN assign
                vindex = 2
                vcobcod = 10.

disp vcateg with frame f-categ no-label centered.
end.

repeat:
view frame f-dat.
view frame f-tipo.
view frame f-cobra.
def var vcatcod as int init 0.
def var vplano as int init 0.
vcatcod = 0.
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
/*if vmodo_visao = "OUTROS"
THEN assign
        vtipo_visao = "CONTABIL"
        vmodo_visao = "CLIENTE".
ELSE vtipo_visao = "GERENCIAL".
*/
form faidev2018.Faixa_risco column-label "Faixa" format "x(5)"
     faidev2018.descricao_faixa no-label format "x(12)"  
     faidev2018.saldo_curva column-label "Curva"      format ">>>>>>>>9.99"
     faidev2018.pctprovisao column-label "%"          format ">>>9.99"
     faidev2018.provisao    column-label "Provisao"   format ">>>>>>>>9.99"
     faidev2018.principal   column-label "Principal"  format ">>>>>>>>9.99"
     faidev2018.renda       column-label "Renda"      format ">>>>>>>>9.99"
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

for each faidev2018 where faidev2018.data_visao = vdatref     and
                        faidev2018.tipo_visao = vtipo_visao and
                        faidev2018.modo_visao = vmodo_visao and
                        faidev2018.modalidade = "CRE" and
                        faidev2018.cobcod     = vcobcod and
                        faidev2018.categoria  = vcatcod and
                        faidev2018.etbcod = 0
                        no-lock:
    assign
        tsaldo_curva = tsaldo_curva + faidev2018.saldo_curva
        tprovisao    = tprovisao + faidev2018.provisao
        tprincipal   = tprincipal + faidev2018.principal
        trenda       = trenda + faidev2018.renda
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
initial[" ","Imprime TELA","Contrato FAIXA","Vencimento FAIXA","Acrescimo AVP"].
def var esqcom2         as char format "x(12)" extent 5
            initial [" "," ","","",""].
def var esqhel1         as char format "x(80)" extent 5
    initial [" Inclusao  de faidev2018 ",
             " Alteracao da faidev2018 ",
             " Exclusao  da faidev2018 ",
             " Consulta  da faidev2018 ",
             " Listagem  Geral de faidev2018 "].
def var esqhel2         as char format "x(12)" extent 5
   initial ["  ",
            " ",
            " ",
            " ",
            " "].
if vtipo_visao = "KPMG"
then assign
        esqcom1[4] = ""
        /*esqcom1[5] = ""*/.
else
if vmodo_visao <> "CLIENTE" or
    vcobcod <> 2 /*or
    vcatcod <> ? */
then esqcom1[5] = "".

def buffer bfaidev2018       for faidev2018.


form
    esqcom1
    with frame f-com1
                 row 3 no-box no-labels side-labels column 1 centered.
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
        find faidev2018 where recid(faidev2018) = recatu1 no-lock.
    if not available faidev2018
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
    recatu1 = recid(faidev2018).
    if esqregua
    then color display message esqcom1[esqpos1] with frame f-com1.
    else color display message esqcom2[esqpos2] with frame f-com2.
    
    pause 0.
    if not esqvazio
    then repeat:
        run leitura (input "seg").
        if not available faidev2018
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
            find faidev2018 where recid(faidev2018) = recatu1 no-lock.

            
            status default
                if esqregua
                then esqhel1[esqpos1] + if esqpos1 > 1 and
                                           esqhel1[esqpos1] <> ""
                                        then  string(faidev2018.faixa_risco)
                                        else ""
                else esqhel2[esqpos2] + if esqhel2[esqpos2] <> ""
                                        then string(faidev2018.faixa_risco)
                                        else "".
            
            run color-message.
            pause 0.
            choose field faidev2018.faixa_risco help ""
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
                    if not avail faidev2018
                    then leave.
                    recatu1 = recid(faidev2018).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "page-up"
            then do:
                do reccont = 1 to frame-down(frame-a):
                    run leitura (input "up").
                    if not avail faidev2018
                    then leave.
                    recatu1 = recid(faidev2018).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "cursor-down"
            then do:
                run leitura (input "down").
                if not avail faidev2018
                then next.
                color display white/red faidev2018.faixa_risco 
                with frame frame-a.
                if frame-line(frame-a) = frame-down(frame-a)
                then scroll with frame frame-a.
                else down with frame frame-a.
            end.
            if keyfunction(lastkey) = "cursor-up"
            then do:
                run leitura (input "up").
                if not avail faidev2018
                then next.
                color display white/red faidev2018.faixa_risco 
                with frame frame-a.
                if frame-line(frame-a) = 1
                then scroll down with frame frame-a.
                else up with frame frame-a.
            end.
 
        if keyfunction(lastkey) = "end-error"
        then leave bl-princ.

        if keyfunction(lastkey) = "return" or esqvazio
        then do:
            form faidev2018
                 with frame f-faidev2018 color black/cyan
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
                    recatu1 = recid(faidev2018).
                    color display normal esqcom1[esqpos1] with frame f-com1.
                    leave.
                end.
                if esqcom1[esqpos1] = "Contrato FAIXA"
                then do:
                    sresp = no.
                    message "Confirma arquivo " esqcom1[esqpos1] "?"
                    update sresp.
                    if sresp
                    then run relatorio-contrato-FAIXA(faidev2018.faixa_risco).
                    recatu1 = recid(faidev2018).
                    color display normal esqcom1[esqpos1] with frame f-com1.
                    leave.
                end.
                if esqcom1[esqpos1] = "Analitico FAIXA" 
                then do:
                    sresp = no.
                    message "Confirma arquivo " esqcom1[esqpos1] "?"
                    update sresp.
                    if sresp
                    then run relatorio-analitico-FAIXA(faidev2018.faixa_risco).
                    recatu1 = recid(faidev2018).
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
                    recatu1 = recid(faidev2018).
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
        recatu1 = recid(faidev2018).
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
display faidev2018.faixa_risco 
        faidev2018.descricao_faixa
                    faidev2018.saldo_curva
                    faidev2018.pctprovisao
                    faidev2018.provisao
                    faidev2018.principal
                    faidev2018.renda
        with frame frame-a .
end procedure.
procedure color-message.
color display message
        faidev2018.descricao_faixa
                    faidev2018.saldo_curva
                    faidev2018.pctprovisao
                    faidev2018.provisao
                    faidev2018.principal
                    faidev2018.renda
        with frame frame-a.
end procedure.
procedure color-normal.
color display normal
        faidev2018.descricao_faixa
                    faidev2018.saldo_curva
                    faidev2018.pctprovisao
                    faidev2018.provisao
                    faidev2018.principal
                    faidev2018.renda
        with frame frame-a.
end procedure.




procedure leitura . 
def input parameter par-tipo as char.
        
if par-tipo = "pri" 
then  
    if esqascend  
    then  
        find first faidev2018 where 
                    faidev2018.data_visao = vdatref and
                    faidev2018.tipo_visao = vtipo_visao and
                    faidev2018.modo_visao = vmodo_visao and 
                    faidev2018.modalidade = "CRE" and
                    faidev2018.cobcod = vcobcod and
                    faidev2018.categoria = vcatcod and
                    faidev2018.etbcod = 0 

                                                no-lock no-error.
    else  
        find last faidev2018  where
                    faidev2018.data_visao = vdatref and
                    faidev2018.tipo_visao = vtipo_visao and
                    faidev2018.modo_visao = vmodo_visao and 
                    faidev2018.modalidade = "CRE" and
                    faidev2018.cobcod = vcobcod and
                    faidev2018.categoria = vcatcod and
                    faidev2018.etbcod = 0 

                                                 no-lock no-error.
                                             
if par-tipo = "seg" or par-tipo = "down" 
then  
    if esqascend  
    then  
        find next faidev2018  where 
                    faidev2018.data_visao = vdatref and
                    faidev2018.tipo_visao = vtipo_visao and
                    faidev2018.modo_visao = vmodo_visao and 
                    faidev2018.modalidade = "CRE" and
                    faidev2018.cobcod = vcobcod and
                    faidev2018.categoria = vcatcod and
                    faidev2018.etbcod = 0 

                                                no-lock no-error.
    else  
        find prev faidev2018   where 
                    faidev2018.data_visao = vdatref and
                    faidev2018.tipo_visao = vtipo_visao and
                    faidev2018.modo_visao = vmodo_visao and 
                    faidev2018.modalidade = "CRE" and
                    faidev2018.cobcod = vcobcod and
                    faidev2018.categoria = vcatcod and
                    faidev2018.etbcod = 0 

                                                no-lock no-error.
             
if par-tipo = "up" 
then                  
    if esqascend   
    then   
        find prev faidev2018 where 
                    faidev2018.data_visao = vdatref and
                    faidev2018.tipo_visao = vtipo_visao and
                    faidev2018.modo_visao = vmodo_visao and 
                    faidev2018.modalidade = "CRE" and
                    faidev2018.cobcod = vcobcod and
                    faidev2018.categoria = vcatcod and
                    faidev2018.etbcod = 0 

                                        no-lock no-error.
    else   
        find next faidev2018 where 
                    faidev2018.data_visao = vdatref and
                    faidev2018.tipo_visao = vtipo_visao and
                    faidev2018.modo_visao = vmodo_visao and 
                    faidev2018.modalidade = "CRE" and
                    faidev2018.cobcod = vcobcod and
                    faidev2018.categoria = vcatcod and
                    faidev2018.etbcod = 0 

                                        no-lock no-error.
        
end procedure.
         
procedure relatorio-tela:
    def var varquivo as char.
    def var varqcsv as char .
    def var sld-curva as dec.
    def var vprovisao as dec.
    def var vencidos as dec.
    def var vencer90 like faidev2018.vencer_90 .
    def var vencer360 like faidev2018.vencer_360.
    def var vencer1080 like faidev2018.vencer_1080.
    def var vencer1800 like faidev2018.vencer_1800 .
    def var vencer5400 like faidev2018.vencer_5400  .
    def var vencer9999 like faidev2018.vencer_9999   .
     
    varquivo = "/admcom/relat/bga-cliente-" 
                + string(vdatref,"99999999") + "-" + string(time).
    varqcsv = "l:\relat\bga-cliente-"
                    + string(vdatref,"99999999") + "-" + string(time).

    {mdadmcab.i 
        &Saida     = "value(varquivo)" 
        &Page-Size = "64" 
        &Cond-Var  = "80"  
        &Page-Line = "66"
        &Nom-Rel   = ""faidev2018v""  
        &Nom-Sis   = """SISTEMA ADMCOM CONTABIL"""
        &Tit-Rel   = """RELATORIO DEVEDORES"""
        &Width     = "80"
        &Form      = "frame f-cabcab"}

    put unformatted string(vdatref,"99/99/9999") + " - " + vtipo_visao + " - " +
                vmodo_visao + " - " + trim(vcobra[vindex]) + " "
                skip.
                
    vi = 0. 

    for each faidev2018 where 
             faidev2018.data_visao = vdatref and
             faidev2018.tipo_visao = vtipo_visao and
             faidev2018.modo_visao = vmodo_visao and
             faidev2018.modalidade = "CRE" and
             faidev2018.cobcod     = vcobcod and
             faidev2018.categoria  = vcatcod and
             faidev2018.faixa_risco <> "" no-lock:
        
        /*
        find first tbcntgen where
                   tbcntgen.tipcon = 13 and
                   tbcntgen.campo1[1] = faidev2018.faixa_risco 
                   no-lock no-error.
        if avail tbcntgen
        then faidev2018.descricao_faixa = tbcntgen.numini + "-" +
                            tbcntgen.numfim.
        */

        if faidev2018.faixa_risco < "H"
        then assign
            vencidos = faidev2018.vencido
            vencer90 = faidev2018.vencer_90
            vencer360 = faidev2018.vencer_360
            vencer1080 = faidev2018.vencer_1080
            vencer1800 = faidev2018.vencer_1800
            vencer5400 = faidev2018.vencer_5400 
            vencer9999 = faidev2018.vencer_9999
            .
        else assign
            vencidos = faidev2018.vencido +
                       faidev2018.vencer_90 + faidev2018.vencer_360 +
                       faidev2018.vencer_1080 + faidev2018.vencer_1800 +
                       faidev2018.vencer_5400 + faidev2018.vencer_9999
            vencer90 = 0
            vencer360 = 0
            vencer1080 = 0
            vencer1800 = 0
            vencer5400 = 0
            vencer9999 = 0
            .

        disp faidev2018.faixa_risco column-label "Faixa"
             faidev2018.descricao_faixa no-label   format "x(12)"
             /*
             vencidos column-label "Vencidos"
             format ">>>,>>>,>>9.99" (total)
             vencer90  column-label "Vencer!Ate 3 meses"
             format ">>>,>>>,>>9.99" (total)
             vencer360 column-label "Vencer!3 a 12 meses"
             format ">>>,>>>,>>9.99"  (total)
             vencer1080 column-label "Vencer!1 a 3 anos"
             format ">>>,>>>,>>9.99"  (total) 
             vencer1800 column-label "Vencer!3 a 5 anos"
             format ">>>,>>>,>>9.99"  (total)
             vencer5400 column-label "Vencer!5 a 15 anos"
             format ">>>,>>>,>>9.99"  (total)
             vencer9999 column-label "Vencer!+ 15 anos"
             format ">>>,>>>,>>9.99"  (total)
             */
             faidev2018.saldo_curva  column-label "Saldo Curva"
             format ">>,>>>,>>>,>>9.99"  (total)
             faidev2018.pctprovisao column-label "%"
             faidev2018.provisao  column-label "Provisao"
             format ">>>,>>>,>>9.99"  (total)
             faidev2018.principal(total) column-label "Principal"
             format ">>>,>>>,>>9.99"
             faidev2018.renda(total) column-label "Renda"
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
                    fn-risco.ven-1080 + fn-risco.ven-1800 +
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
             fn-risco.ven-1800 column-label "Vencer!3 a 5 anos"
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
                    tt-risco.ven-1080 + tt-risco.ven-1800 +
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
             tt-risco.ven-1800 column-label "Vencer!3 a 5 anos"
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
    for each tt-faidev2018: delete tt-faidev2018. end.
    for each faidev2018 where faidev2018.data_visao = vdatref     and
                        faidev2018.tipo_visao = vtipo_visao and
                        faidev2018.modo_visao = vmodo_visao and
                        faidev2018.modalidade = "CRE" and
                        faidev2018.cobcod     = vcobcod and
                        faidev2018.categoria  = vcatcod and
                        faidev2018.etbcod > 0
                        no-lock:
        find first tt-faidev2018 where
                   tt-faidev2018.data_visao = faidev2018.data_visao and
                   tt-faidev2018.tipo_visao = faidev2018.tipo_visao and
                   tt-faidev2018.modo_visao = faidev2018.modo_visao and
                   tt-faidev2018.modalidade = faidev2018.modalidade and
                   tt-faidev2018.cobcod     = faidev2018.cobcod and 
                   tt-faidev2018.categoria  = faidev2018.categoria and
                   tt-faidev2018.etbcod     = faidev2018.etbcod 
                   no-error.
        if not avail tt-faidev2018
        then do:
            create tt-faidev2018.
            assign
                tt-faidev2018.data_visao = faidev2018.data_visao
                tt-faidev2018.tipo_visao = faidev2018.tipo_visao
                tt-faidev2018.modo_visao = faidev2018.modo_visao
                tt-faidev2018.modalidade = faidev2018.modalidade
                tt-faidev2018.cobcod     = faidev2018.cobcod
                tt-faidev2018.categoria  = faidev2018.categoria
                tt-faidev2018.etbcod     = faidev2018.etbcod
                .
        end.
        assign
            tt-faidev2018.saldo_curva = tt-faidev2018.saldo_curva +
                                        faidev2018.saldo_curva
            tt-faidev2018.provisao    = tt-faidev2018.provisao +
                                        faidev2018.provisao
            tt-faidev2018.principal   = tt-faidev2018.principal +
                                        faidev2018.principal
            tt-faidev2018.renda       = tt-faidev2018.renda +
                                        faidev2018.renda
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
        &Nom-Rel   = ""faidev2018v""  
        &Nom-Sis   = """SISTEMA ADMCOM CONTABIL"""
        &Tit-Rel   = """RELATORIO DEVEDORES"""
        &Width     = "100"
        &Form      = "frame f-cabcab"}

    put unformatted string(vdatref,"99/99/9999") + " - " + vtipo_visao + " - " +
                vmodo_visao + " - " + trim(vcobra[vindex])
                 + " - " trim(esqcom1[esqpos1])
                skip.

    for each tt-faidev2018 where tt-faidev2018.etbcod > 0 no-lock:
        disp tt-faidev2018.etbcod column-label "Filial" 
        tt-faidev2018.saldo_curva(total) format ">>>,>>>,>>9.99"
        tt-faidev2018.provisao(total)  format ">>>,>>>,>>9.99"
        tt-faidev2018.principal(total) format ">>>,>>>,>>9.99"
        tt-faidev2018.renda(total)     format ">>>,>>>,>>9.99"
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
             sqmesavp.tpvisao = /*"CTBKPMG"*/ vtipo_visao and
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
             sqmesavp.tpvisao = vtipo_visao and
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
             .
       
        if sqmesavp.mes = 0
        then do:
            ven-cido = ven-cido + 37218947.12.
            disp sqmesavp.ano
                  sqmesavp.mes  
                  ven-cido 
                  tven-cersa
                  tven-cerca
                  tavp-dia
                  with frame f-disp.
        end.
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
    if vtipo_visao <> "KPMG"
    then do:
    down(1) with frame f-disp.
    disp "      Principal" format "x(15)" @ tven-cersa
         "      Acrescimo" format "x(15)" @ tven-cerca
         with frame f-disp.
    down with frame f-disp.     
    disp "Emissao" @ ven-cido 
         principal-emissao  @ tven-cersa
         acrescimo-emissao  @ tven-cerca
         with frame f-disp.
    down with frame f-disp.
    disp "Vencidos" @ ven-cido
         principal-vencido @ tven-cersa
         acrescimo-vencido @ tven-cerca
         with frame f-disp.
    down with frame f-disp.
    disp "A Vencer" @ ven-cido
         principal-vencer @ tven-cersa
         acrescimo-vencer @ tven-cerca
         with frame f-disp.
    down with frame f-disp.
    end.
    output close.

    run visurel.p(varquivo,"").
    
end procedure.
                              

procedure relatorio-vencimento-FAIXA:
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
 

    varquivo = "/admcom/relat/saldo-clientes-vencimento" 
                + string(vdatref,"99999999") + "-risco-" 
                + p-risco + ".txt".   

    def var valchar as char.
    def var varq as char.
    def var vok as log.
    
    varq = "/admcom/relat/saldo-clientes-vencimento" 
                + string(vdatref,"99999999") + "-risco-" 
                + p-risco + ".csv". 
    
    vtotal = 0.
    
    output to value(varq).
    put "Nome;CPF;Numero;Valor;Vencimento;Atraso" skip.
    vtotal = 0.                  
    
    for each visdev18 where visdev18.data_visao = vdatref  and
                            visdev18.tipo_visao = vtipo_visao and
                            visdev18.risco_contrato = p-risco 
                            no-lock:

        vclinom = visdev18.nome.
        vciccgc = visdev18.cpf.
        
        for each titulo where
                 titulo.empcod = visdev18.empcod and
                 titulo.titnat = visdev18.titnat and
                 titulo.modcod = visdev18.modcod and
                 titulo.titdtemi = visdev18.titdtemi and
                 titulo.etbcod = visdev18.etbcod and
                 titulo.clifor = visdev18.clifor and
                 titulo.titnum = visdev18.titnum and
                 (titulo.titsit = "LIB" or
                 (titulo.titsit = "PAG" and
                  titulo.titdtpag > vdatref)) 
                  and titulo.titpar > 0
                 no-lock: 
            if titulo.titvlcob > 0  and
               titulo.titdtven <> ?  /*and
               titulo.titdtven < 01/01/2030 and
               titulo.titdtven > 01/01/1990*/
            then do:                         
                /****     
                if visdev18.qtdatr > 0 /*220*/
                then vdtven = titulo.titdtven - visdev18.qtdat.
                else vdtven = titulo.titdtven.
                ****/

                if visdev18.cobcod = 10
                then valchar = string(titulo.titdesc).
                else valchar = string(titulo.titvlcob).
                vtotal = vtotal + dec(valchar).
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
                else put "0" 
                    .

                put skip.

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

procedure relatorio-contrato-FAIXA:
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
    def var val-vencido as dec format ">>>>>>>>9.99".
    def var val-vencer as dec format ">>>>>>>>9.99".
    def var val-total as dec format ">>>>>>>>9.99".
    def var val-avp as dec format ">>>>>>>>9.99".
    if vmodo_visao = "CONTRATO"
    then vindex = 1.
    else vindex = 2.
    
    disp "Gerando relatorio... Aguarde!" skip
         varquivo format "x(70)"
        with frame f-dd 1 down centered overlay color message
        row 10 no-label .
    pause 0.
 

    varquivo = "/admcom/Contabilidade/relat/saldo-clientes-contrato" 
                + string(vdatref,"99999999") + "-risco-" 
                + p-risco + ".txt".   

    def var valchar as char.
    def var varq as char.
    def var vok as log.
    
    varq = "/admcom/Contabilidade/relat/saldo-clientes-contrato" 
                + string(vdatref,"99999999") + "-risco-" 
                + p-risco + ".csv". 
    
    output to value(varq).
    put "Filial;Cliente;CPF;Nome;Contrato;Emissao;Vencimento Inicial;"
        "Vencimento Final;Total Aberto;Faixa"
    skip.
    for each visdev2018 where
         visdev2018.data_visao  = 12/31/18  and
         visdev2018.tipo_visao  = vtipo_visao and
         visdev2018.risco_contrato = p-risco and
         visdev2018.situacao <> "EXC"
         no-lock:
        val-vencido = 0.
        val-vencer  = 0.
        /*if visdev2018.cobcod = 10
        then assign
            val-vencido = visdev2018.seguro_vencido 
            val-vencer  = visdev2018.seguro_vencer.
        else*/ assign
            val-vencido = visdev2018.total_vencido 
            val-vencer  = visdev2018.total_vencer.
        vtotal = vtotal + val-vencido + val-vencer.
    
        val-total = val-vencido + val-vencer.
        val-avp   = visdev2018.avp_total.
        
        if val-vencido > 0 or
           val-vencer  > 0
        then do:
            put visdev2018.etbcod
             ";"
             visdev2018.clifor
             ";"
             visdev2018.CPF
             ";"
             visdev2018.Nome
             ";"
             visdev2018.titnum format "x(15)"
             ";"
             visdev2018.titdtemi
             ";"
             visdev2018.vencimento_arquivo
             ";"
             visdev2018.vencimento_final
             ";"
             replace(string(val-total),".",",")
             ";"
             visdev2018.risco_contrato
             skip. 
        end.
    end. 
    output close.    

    message color red/with
    "Arquivo gerado"
    varq skip
    "Total:" vtotal
    view-as alert-box
    .

end procedure.


