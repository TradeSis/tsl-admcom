{admcab.i}
{setbrw.i}

disp "Processando..." with frame f-pro no-label no-box . 

def temp-table pdvd2022
    field data_visao as date
    field tipo_visao as char
    field modo_visao as char
    field cobcod     like titulo.cobcod
    field categoria  like produ.catcod
    field modalidade like titulo.modcod
    field faixa_risco as char
    field etbcod     like titulo.etbcod
    field clifor     like titulo.clifor
    field documento  like titulo.titnum
    field parcela like titulo.titpar
    field principal as dec
    field renda     as dec
    field valor_perda_parcela as dec
    field vencidos as dec
    field vencer as dec
    field saldo_curva as dec
    field descricao_faixa as char
    field provisao as dec
    field pctprovisao as dec
    index i1  data_visao tipo_visao
                   modo_visao 
                   cobcod 
                   categoria 
                   modalidade 
                   faixa_risco 
                   etbcod 
                   clifor
                   documento
                   parcela   .
 
input from /admcom/claudir/carteira2022/pdvd2022.dadosokultimo.
repeat:
    create  pdvd2022.
    import  pdvd2022.
end.
input close.  

def temp-table cart22
    field codigo as char        format "x(15)"
    field nome as char          format "x(40)"
    field cpf as char           format "x(16)"
    field contrato as char      format "x(15)"
    field carteira as char      format "x(15)"
    field valorab as char       format "x(15)"
    field emissao as char       format "x(15)"
    field vencimentoi as char   format "x(15)"
    field vencimentof as char   format "x(15)"
    field modalidade as char    format "x(15)"
    field filial as char        format "x(15)"
    field tipo as char          format "x(15)"
    field datref as char        format "x(15)"
    field xdias as char         format "x(15)"
    field aging as char         format "x(15)"
    field produto as char       format "x(15)"
    field principal as char     format "x(15)"
    field acrescimo as char     format "x(15)"
    field seguro as char        format "x(15)"
    field plano as char         format "x(15)"
    field entrada as char       format "x(15)"
    field vlcred as char        format "x(15)"
    field obs as char           format "x(40)"
    field faixa as char         format "x"
    field risco_cliente as char format "x"
    field val-vencido as dec
    field val-vencer as dec
    index i1 contrato
    index i2 codigo risco_cliente.
 
input from /admcom/claudir/carteira2022/carteira2022.dadosokultimo.
repeat:
    create cart22.
    import cart22.    
end.
input close.

def temp-table sqmesavp
    field tpvisao as char
    field dtvisao as date
    field ano              as int
    field mes              as int
    field seq              as int
    field pctmes           as dec
    field avpdia           as dec
    field vencido          as dec
    field avencer          as dec
    field avencer-sacr     as dec
    field principal as dec
    field acrescimo as dec
    field principal_emissao_mes as dec
    field acrescimo_emissao_mes as dec
    field principal_vencido as dec
    field acrescimo_vencido as dec
    field principal_vencer  as dec
    field acrescimo_vencer  as dec
    field principal_competencia as dec
    field acrescimo_competencia as dec
    field principal_realizado as dec
    field acrescimo_realizado as dec
    index i1 tpvisao
          dtvisao
          ano
          mes
          seq.
 

input from /admcom/claudir/carteira2022/sqmesavp22.dados.
repeat:
    create sqmesavp.
    import sqmesavp.
end.
input close. 

hide frame f-pro no-pause.

def temp-table tt-pdvd2022 like pdvd2022.

def var vi as int.
def var vdatref as date format "99/99/9999".
def var vcobcod as int.
def var vtipo_visao as char.
def var vmodo_visao as char.
vtipo_visao = "GERENCIAL".
vmodo_visao = "CLIENTE".
vcobcod = 2.

vdatref = 12/31/2022.

update vdatref label "Data referencia" with frame f-dat side-label 1 down
width 80 row 4.

if vdatref < 01/01/22 or
   vdatref > 12/31/22
then return.
  
def var vtipo as char extent 3 format "x(15)". 
def var vcobra as char extent 4 format "x(15)".
def var vcateg as char extent 5 format "x(14)".
vtipo[1] = "  CONTRATO".
vtipo[2] = "  CLIENTE".

if vdatref = 12/31/2022
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

vtipo = "".
vtipo[1] = "OUTROS".
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

form pdvd2022.Faixa_risco column-label "Faixa" format "x(5)"
     pdvd2022.descricao_faixa no-label format "x(12)"  
     pdvd2022.saldo_curva column-label "Curva"      format ">>>>>>>>9.99"
     pdvd2022.pctprovisao column-label "%"          format ">>>9.99"
     pdvd2022.provisao    column-label "Provisao"   format ">>>>>>>>9.99"
     pdvd2022.principal   column-label "Principal"  format ">>>>>>>>9.99"
     pdvd2022.renda       column-label "Renda"      format ">>>>>>>>9.99"
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

/*
for each pdvd2022 where pdvd2022.data_visao = 12/31/22
                        no-lock:
    disp
                            pdvd2022.tipo_visao 
                                                pdvd2022.modo_visao
.
end.
*/
vmodo_visao = "CONTRATO".
/*vmodo_visao = "OUTROS".
*/
for each pdvd2022 where pdvd2022.data_visao = vdatref     and
                        pdvd2022.tipo_visao = vtipo_visao and
                        pdvd2022.modo_visao = vmodo_visao and
                        pdvd2022.modalidade = "CRE" and
                        pdvd2022.cobcod     = ? and
                        pdvd2022.categoria  = ? and
                        pdvd2022.etbcod = 0               
                        no-lock:
    
    assign
        tsaldo_curva = tsaldo_curva + pdvd2022.saldo_curva
        tprovisao    = tprovisao + pdvd2022.provisao
        tprincipal   = tprincipal + pdvd2022.principal
        trenda       = trenda + pdvd2022.renda
        
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
esqcom1[4] = "".
/*esqcom1[5] = "".*/

def var esqcom2         as char format "x(12)" extent 5
            initial [" "," ","","",""].
def var esqhel1         as char format "x(80)" extent 5
    initial [" Inclusao  de pdvd2022 ",
             " Alteracao da pdvd2022 ",
             " Exclusao  da pdvd2022 ",
             " Consulta  da pdvd2022 ",
             " Listagem  Geral de pdvd2022 "].
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
    esqcom1[4] = "" /*"Analitico GERAL"*/
    esqcom1[5] = "Acrescimo AVP"
    .

if vcatcod <> ?
then assign
        esqcom1[3] = ""
        esqcom1[4] = ""
        esqcom1[5] = "".

def buffer bpdvd2022       for pdvd2022.


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
        find pdvd2022 where recid(pdvd2022) = recatu1 no-lock.
    if not available pdvd2022
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

    recatu1 = recid(pdvd2022).
    if esqregua
    then color display message esqcom1[esqpos1] with frame f-com1.
    else color display message esqcom2[esqpos2] with frame f-com2.
    
    pause 0.
    if not esqvazio
    then repeat:
        run leitura (input "seg").
        if not available pdvd2022
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
            find pdvd2022 where recid(pdvd2022) = recatu1 no-lock.

            
            status default
                if esqregua
                then esqhel1[esqpos1] + if esqpos1 > 1 and
                                           esqhel1[esqpos1] <> ""
                                        then  string(pdvd2022.faixa_risco)
                                        else ""
                else esqhel2[esqpos2] + if esqhel2[esqpos2] <> ""
                                        then string(pdvd2022.faixa_risco)
                                        else "".
            
            run color-message.
            pause 0.
            choose field pdvd2022.faixa_risco help ""
                go-on(cursor-down cursor-up
                      cursor-left cursor-right
                      page-down   page-up
                      tab PF4 F4 ESC return) .
    
            if keyfunction(lastkey) = "END-ERROR"
            then leave bl-princ. 
            
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
                    if not avail pdvd2022
                    then leave.
                    recatu1 = recid(pdvd2022).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "page-up"
            then do:
                do reccont = 1 to frame-down(frame-a):
                    run leitura (input "up").
                    if not avail pdvd2022
                    then leave.
                    recatu1 = recid(pdvd2022).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "cursor-down"
            then do:
                run leitura (input "down").
                if not avail pdvd2022
                then next.
                color display white/red pdvd2022.faixa_risco with frame frame-a.
                if frame-line(frame-a) = frame-down(frame-a)
                then scroll with frame frame-a.
                else down with frame frame-a.
            end.
            if keyfunction(lastkey) = "cursor-up"
            then do:
                run leitura (input "up").
                if not avail pdvd2022
                then next.
                color display white/red pdvd2022.faixa_risco with frame frame-a.
                if frame-line(frame-a) = 1
                then scroll down with frame frame-a.
                else up with frame frame-a.
            end.
 
        if keyfunction(lastkey) = "end-error"
        then leave bl-princ.

        if keyfunction(lastkey) = "return" or esqvazio
        then do:
            form pdvd2022
                 with frame f-pdvd2022 color black/cyan
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
                    recatu1 = recid(pdvd2022).
                    color display normal esqcom1[esqpos1] with frame f-com1.
                    leave.
                end.
                if esqcom1[esqpos1] = "Analitico FAIXA"
                then do:
                    sresp = no.
                    message "Confirma arquivo " esqcom1[esqpos1] 
                    pdvd2022.faixa_risco "?"
                    update sresp.
                    if sresp
                    then run relatorio-analitico-FAIXA(pdvd2022.faixa_risco).
                    recatu1 = recid(pdvd2022).
                    /*color display normal esqcom1[esqpos1] with frame f-com1.
                    */
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
                    recatu1 = recid(pdvd2022).
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
                    recatu1 = recid(pdvd2022).
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
        recatu1 = recid(pdvd2022).
    end.

    if keyfunction(lastkey) = "end-error"
    then do:
        view frame fc1.
        view frame fc2.
    end.
end.
leave.
end.
leave.
end.
hide frame f-com1  no-pause.
hide frame f-com2  no-pause.
hide frame frame-a no-pause.

procedure frame-a.
display pdvd2022.faixa_risco 
        pdvd2022.descricao_faixa
                    pdvd2022.saldo_curva
                    pdvd2022.pctprovisao
                    pdvd2022.provisao
                    pdvd2022.principal
                    pdvd2022.renda
        with frame frame-a .
end procedure.
procedure color-message.
color display message
        pdvd2022.descricao_faixa
                    pdvd2022.saldo_curva
                    pdvd2022.pctprovisao
                    pdvd2022.provisao
                    pdvd2022.principal
                    pdvd2022.renda
        with frame frame-a.
end procedure.
procedure color-normal.
color display normal
        pdvd2022.descricao_faixa
                    pdvd2022.saldo_curva
                    pdvd2022.pctprovisao
                    pdvd2022.provisao
                    pdvd2022.principal
                    pdvd2022.renda
        with frame frame-a.
end procedure.

procedure leitura . 
def input parameter par-tipo as char.
        
if par-tipo = "pri" 
then  
    if esqascend  
    then  
        find first pdvd2022 where 
                    pdvd2022.data_visao = vdatref and
                    pdvd2022.tipo_visao = vtipo_visao and
                    pdvd2022.modo_visao = vmodo_visao and 
                    pdvd2022.modalidade = "CRE" and
                    pdvd2022.cobcod = ? and
                    pdvd2022.categoria = ? and
                    pdvd2022.etbcod = 0 

                                                no-lock no-error.
    else  
        find last pdvd2022  where
                    pdvd2022.data_visao = vdatref and
                    pdvd2022.tipo_visao = vtipo_visao and
                    pdvd2022.modo_visao = vmodo_visao and 
                    pdvd2022.modalidade = "CRE" and
                    pdvd2022.cobcod = ? and
                    pdvd2022.categoria = ? and
                    pdvd2022.etbcod = 0 

                                                 no-lock no-error.
                                             
if par-tipo = "seg" or par-tipo = "down" 
then  
    if esqascend  
    then  
        find next pdvd2022  where 
                    pdvd2022.data_visao = vdatref and
                    pdvd2022.tipo_visao = vtipo_visao and
                    pdvd2022.modo_visao = vmodo_visao and 
                    pdvd2022.modalidade = "CRE" and
                    pdvd2022.cobcod = ? and
                    pdvd2022.categoria = ? and
                    pdvd2022.etbcod = 0 

                                                no-lock no-error.
    else  
        find prev pdvd2022   where 
                    pdvd2022.data_visao = vdatref and
                    pdvd2022.tipo_visao = vtipo_visao and
                    pdvd2022.modo_visao = vmodo_visao and 
                    pdvd2022.modalidade = "CRE" and
                    pdvd2022.cobcod = ? and
                    pdvd2022.categoria = ? and
                    pdvd2022.etbcod = 0 

                                                no-lock no-error.
             
if par-tipo = "up" 
then                  
    if esqascend   
    then   
        find prev pdvd2022 where 
                    pdvd2022.data_visao = vdatref and
                    pdvd2022.tipo_visao = vtipo_visao and
                    pdvd2022.modo_visao = vmodo_visao and 
                    pdvd2022.modalidade = "CRE" and
                    pdvd2022.cobcod = ? and
                    pdvd2022.categoria = ? and
                    pdvd2022.etbcod = 0 

                                        no-lock no-error.
    else   
        find next pdvd2022 where 
                    pdvd2022.data_visao = vdatref and
                    pdvd2022.tipo_visao = vtipo_visao and
                    pdvd2022.modo_visao = vmodo_visao and 
                    pdvd2022.modalidade = "CRE" and
                    pdvd2022.cobcod = ? and
                    pdvd2022.categoria = ? and
                    pdvd2022.etbcod = 0 

                                        no-lock no-error.
        
end procedure.
   
procedure relatorio-tela:
    def var varquivo as char.
    def var varqcsv as char .
    def var sld-curva as dec.
    def var vprovisao as dec.
    def var vencidos as dec.
    /*def var vencer90 like pdvd2022.vencer_90 .
    def var vencer360 like pdvd2022.vencer_360.
    def var vencer1080 like pdvd2022.vencer_1080.
    def var vencer1900 like pdvd2022.vencer_1800 .
    def var vencer5400 like pdvd2022.vencer_5400  .
    def var vencer9999 like pdvd2022.vencer_9999   .
    */
     
    varquivo = "/admcom/relat/bga-cliente-" 
                + string(vdatref,"99999999") + "-" + string(time).
    varqcsv = "l:\relat\bga-cliente-"
                    + string(vdatref,"99999999") + "-" + string(time).

    {mdadmcab.i 
        &Saida     = "value(varquivo)" 
        &Page-Size = "64" 
        &Cond-Var  = "80"  
        &Page-Line = "66"
        &Nom-Rel   = ""pdvd2022v""  
        &Nom-Sis   = """SISTEMA ADMCOM CONTABIL"""
        &Tit-Rel   = """RELATORIO DEVEDORES"""
        &Width     = "80"
        &Form      = "frame f-cabcab"}

    put unformatted string(vdatref,"99/99/9999") + " - " + vtipo_visao + " - " +
                vmodo_visao + " - " + trim(vcobra[vindex]) + " "
                skip.
                
    vi = 0. 

    for each pdvd2022 where 
             pdvd2022.data_visao = vdatref and
             pdvd2022.tipo_visao = vtipo_visao and
             pdvd2022.modo_visao = vmodo_visao and
             pdvd2022.modalidade = "CRE" and
             pdvd2022.cobcod     = vcobcod and
             pdvd2022.categoria  = vcatcod and
             pdvd2022.faixa_risco <> "" no-lock:
        
    
        display pdvd2022.faixa_risco 
            pdvd2022.descricao_faixa 
                    pdvd2022.saldo_curva format ">>>,>>>,>>9.99" (total)
                    pdvd2022.pctprovisao
                    pdvd2022.provisao    format ">>>,>>>,>>9.99" (total)
                    pdvd2022.principal   format ">>>,>>>,>>9.99" (total)
                    pdvd2022.renda       format ">>>,>>>,>>9.99" (total)
        with frame frame-r width 120 down .
    end.
    
    output close.

    run visurel.p(varquivo,"").
    
end procedure.

/**********
procedure relatorio-faixa-filial:
    def var vindex as int.
    vindex = 2.
    for each tt-pdvd2022: delete tt-pdvd2022. end.
    for each pdvd2022 where pdvd2022.data_visao = vdatref     and
                        pdvd2022.tipo_visao = vtipo_visao and
                        pdvd2022.modo_visao = vmodo_visao and
                        pdvd2022.modalidade = "CRE" and
                        pdvd2022.cobcod     = vcobcod and
                        pdvd2022.categoria  = vcatcod and
                        pdvd2022.etbcod > 0
                        no-lock:
        find first tt-pdvd2022 where
                   tt-pdvd2022.data_visao = pdvd2022.data_visao and
                   tt-pdvd2022.tipo_visao = pdvd2022.tipo_visao and
                   tt-pdvd2022.modo_visao = pdvd2022.modo_visao and
                   tt-pdvd2022.modalidade = pdvd2022.modalidade and
                   tt-pdvd2022.cobcod     = pdvd2022.cobcod and 
                   tt-pdvd2022.categoria  = pdvd2022.categoria and
                   tt-pdvd2022.etbcod     = pdvd2022.etbcod 
                   no-error.
        if not avail tt-pdvd2022
        then do:
            create tt-pdvd2022.
            assign
                tt-pdvd2022.data_visao = pdvd2022.data_visao
                tt-pdvd2022.tipo_visao = pdvd2022.tipo_visao
                tt-pdvd2022.modo_visao = pdvd2022.modo_visao
                tt-pdvd2022.modalidade = pdvd2022.modalidade
                tt-pdvd2022.cobcod     = pdvd2022.cobcod
                tt-pdvd2022.categoria  = pdvd2022.categoria
                tt-pdvd2022.etbcod     = pdvd2022.etbcod
                .
        end.
        assign
            tt-pdvd2022.saldo_curva = tt-pdvd2022.saldo_curva +
                                        pdvd2022.saldo_curva
            tt-pdvd2022.provisao    = tt-pdvd2022.provisao +
                                        pdvd2022.provisao
            tt-pdvd2022.principal   = tt-pdvd2022.principal +
                                        pdvd2022.principal
            tt-pdvd2022.renda       = tt-pdvd2022.renda +
                                        pdvd2022.renda
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
        &Nom-Rel   = ""pdvd2022v""  
        &Nom-Sis   = """SISTEMA ADMCOM CONTABIL"""
        &Tit-Rel   = """RELATORIO DEVEDORES"""
        &Width     = "100"
        &Form      = "frame f-cabcab"}

    put unformatted string(vdatref,"99/99/9999") + " - " + vtipo_visao + " - " +
                vmodo_visao + " - " + trim(vcobra[vindex])
                 + " - " trim(esqcom1[esqpos1])
                skip.

    for each tt-pdvd2022 where tt-pdvd2022.etbcod > 0 no-lock:
        disp tt-pdvd2022.etbcod column-label "Filial" 
        tt-pdvd2022.saldo_curva(total) format ">>>,>>>,>>9.99"
        tt-pdvd2022.provisao(total)  format ">>>,>>>,>>9.99"
        tt-pdvd2022.principal(total) format ">>>,>>>,>>9.99"
        tt-pdvd2022.renda(total)     format ">>>,>>>,>>9.99"
            with down width 100.
            . 
    end.  
    output close.
    
    run visurel.p(input varquivo,"").
                      
end procedure.
*****/

/*******************************
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
***********************/

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
 
    /*****
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
    ***/
    
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
    put "Codigo;Nome;CPF;Contrato; Valor ;Emissão;Vencimento_inicial;
    Vencimento_final;Risco_clientes;Risco_contrato" skip.

    for each cart22 where cart22.aging = p-risco
                          no-lock:  

 
        if cart22.val-vencido = 0 and
           cart22.val-vencer = 0
        then next.    
        assign
                vclinom = cart22.nome
                vciccgc = cart22.cpf.
        vok = no.
        vdtven = ? .
        valchar = "".

        /**
        for each titulo where
             titulo.clifor = int(cart22.codigo) and
             titulo.titnum = cart22.contrato and
             (titulo.titsit = "LIB" or
              titulo.titdtpag > vdatref)
             no-lock:
        
             vdtven = titulo.titdtven.
             valchar = string(titulo.titvlcob).
             valchar = replace(valchar,",","").
             valchar = replace(valchar,".",",").

             if valchar <> ""
             then do:
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
        ***/
        /***
        if valchar = ""
        then
        for each titulo where titulo.contnum = int(cart22.contrato) and
                          (titulo.titsit = "LIB" or
                           titulo.titdtpag >= 01/01/23) no-lock.

             vdtven = titulo.titdtven.
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
        ***/
        
        /*
        valchar = string(cart22.val-vencido + cart22.val-vencer).
        valchar = replace(valchar,",","").
        valchar = replace(valchar,".",",").
        */
        valchar = replace(cart22.valorab,".","").
        valchar = replace(valchar,",",".").
        
        put unformatted 
                cart22.codigo
                ";"
                vclinom 
                ";"
                vciccgc 
                ";"
                cart22.contrato 
                ";"
                cart22.valorab
                ";"
                cart22.emissao
                ";"
                cart22.vencimentoi
                ";"
                cart22.vencimentof
                ";"
                cart22.risco_cliente
                ";"
                cart22.faixa
                .

                put skip.
                /*
                vtotal = vtotal + (cart22.val-vencido + cart22.val-vencer).
                */
                vtotal = vtotal + dec(valchar). 
                vok = yes.
            

                           
        
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

/********
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

************/
