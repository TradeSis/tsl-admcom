/* #18082022 helio - ID 145143 arquivo por parcelas e adicionar campos seguro/iof */

/* helio 09122021 Melhorias CR II */
/* 17/09/2021 helio*/

def var vtitvltot as dec.
def var vnro_parcela as int.
def var vvlseguro as dec.
def var vvliof  as dec.
def buffer xtitulo for titulo.


{/admcom/progr/admcab-batch.i new}

def var pdtiniproc  as date.
def var phriniproc  as int.
def buffer pctbprzmprod for ctbprzmprod.

def var vdtref  as   date format "99/99/9999" .
def var vdtrefini as date.

    find first pctbprzmprod where pctbprzmprod.pstatus = "PROCESSAR"  and pctbprzmprod.pparametros = "CARTEIRA"
        no-lock no-error.
    if not avail pctbprzmprod
    then do:
            message "NADA PARA PROCESSAR" today string(time,"HH:MM:SS").
            quit.
    end.

    vdtref         = pctbprzmprod.dtfimper.
    vdtrefini = date(month(vdtref),01,year(vdtref)).
        
    do on error undo:
        find current pctbprzmprod 
            exclusive no-wait no-error.
        if not avail pctbprzmprod
        then do:
            message "LOCADO " 
                vdtrefini vdtref .
            quit.
        end.    
    end.
    find current pctbprzmprod no-lock.
    vdtref         = pctbprzmprod.dtfimper.
    vdtrefini = date(month(vdtref),01,year(vdtref)).

    pdtiniproc     = today.
    phriniproc     = time.

    hide message no-pause.
    message color normal "fazendo calculos... aguarde..."
        pctbprzmprod.dtiniper pctbprzmprod.dtfimper vdtrefini vdtref pctbprzmprod.pparametros.
    
    for each ctbprzmprod where 
            ctbprzmprod.pparametros = pctbprzmprod.pparametros and
            ctbprzmprod.dtiniper     = pctbprzmprod.dtiniper and
            ctbprzmprod.dtfimper     = pctbprzmprod.dtfimper and
            ctbprzmprod.pstatus <> "PROCESSAR":
        delete ctbprzmprod.
    end.     

    do on error undo:
    
        find first ctbprzmprod where 
                    ctbprzmprod.pstatus = "PROCESSAR" and
                    ctbprzmprod.pparametros = pctbprzmprod.pparametros and
                    ctbprzmprod.dtiniper = pctbprzmprod.dtiniper and 
                    ctbprzmprod.dtfimper = pctbprzmprod.dtfimper and 
                    ctbprzmprod.campo = "TOTAL" and 
                    ctbprzmprod.valor = "" no-error. 
        if not avail ctbprzmprod
        then do:
            message "nao encontrei parametros".
            return.
        end.    
            
            ctbprzmprod.dtrefSAIDA = vdtref.
            ctbprzmprod.vlrPago    = 0.
            ctbprzmprod.qtdPC      = 0.
            ctbprzmprod.PrzMedio   = 0.
            ctbprzmprod.pstatus    = "PROCESSANDO".
            ctbprzmprod.dtiniproc  = pdtiniproc.
            ctbprzmprod.hriniproc  = phriniproc.
            ctbprzmprod.dtfimproc  = ?.
            ctbprzmprod.hrfimproc  = ?.

    end.
    release ctbprzmprod.

for each ctbposcart where ctbposcart.dtref = vdtrefini.
    delete ctbposcart.
end.
for each ctbposprod where ctbposprod.dtref = vdtrefini.
    delete ctbposprod.
end.


def var vconta as int column-label "registros" format ">>>>>>>>>>>>>>>>>>9".
def var vproduto as char.
def var vtpcontrato as char.
def temp-table ttcontrato no-undo
    field titnum like titulo.titnum
    field titdtemi like titulo.titdtemi
    field titdtpag like titulo.titdtpag
    field titvlcob like titulo.titvlcob
    field cobcod    like titulo.cobcod
    field modcod    like titulo.modcod
    field tpcontrato like titulo.tpcontrato
    field etbcod    like titulo.etbcod
    field vencini         like titulo.titdtven
    field vencfim         like titulo.titdtven
    field produto as char
    field vlf_principal     like titulo.vlf_principal
    field vlf_acrescimo     like titulo.vlf_acrescimo
    field vlseguro          like contrato.vlseguro /* helio 09122021 Melhorias CR II */
    index x is unique primary titnum asc cobcod asc.

    
def var vdt as date.
def var v-abreporanoemi as log format "Sim/Nao".
def var vtime as int.

def var vpdf as char no-undo.
/* #2 */
def var par-parcial as log column-label "Par!cial" format "Par/Ori".
def var par-parorigem like titulo.titpar column-label "Par!Ori".
def var par-titvlcob as dec column-label "VlCarteira".
def var par-titdtpag as date column-label "DtPag".
def var par-titvlpag as dec column-label "VlPago".
def var par-saldo as dec column-label "VlSaldo".
def var par-tpcontrato as char format "x(1)" column-label "Tp".
def var par-titdtemi as date column-label "Dtemi".
def var par-titdesc as dec column-label "VlDesc".
def var par-titjuro as dec column-label "VlJuro".
/* #2 */

def var v-cont as integer.
def var v-cod as char.
def var vmod-sel as char.

def buffer btitulo   for titulo.
def buffer bf-titulo for titulo.

def NEW SHARED temp-table tt-modalidade-selec /* #4 */
    field modcod as char.
    
def var par-paga as int.
def var pag-atraso as log.
def buffer ctitulo for titulo.

def var varquivo as char format "x(20)".
def var vdti as date.
def var vdtf as date.
def var vdisp   as   char format "x(8)".
def var vtotal  like titulo.titvlcob.
def var vmes    as   char format "x(3)" extent 12 initial
                        ["JAN","FEV","MAR","ABR","MAI","JUN",
                         "JUL","AGO","SET","OUT","NOV","DEZ"] .

def var vtot1   like titulo.titvlcob.
def var vtot2   like titulo.titvlcob.

/**def var vtotcatger  like vtot1.
def var vtotcat31   like vtot1.
def var vtotcat41  like vtot1.
def var vtotcat81   like vtot1. /* seguros */**/


def var v-consulta-parcelas-LP as logical format "Sim/Nao" initial no.
def var v-parcela-lp as log.
def var v-feirao-nome-limpo as log format "Sim/Nao" initial no.
def var v-novacao as log format "Sim/Nao" initial no.


def temp-table wf no-undo /* #1 */
    field cobcod    like cobra.cobcod
    field vencido like titulo.titvlcob label "Vencido" format ">>>>>>>>>>>>>>>>>>>9.99"
    field vencer  like titulo.titvlcob label "Vencer"  format ">>>>>>>>>>>>>>>>>>>9.99"
    index cobcod is unique primary cobcod asc.
/**    field catvencidoger     like wf.vencido
    field catvencido31     like wf.vencido
    field catvencido41     like wf.vencido
    field catvencido81     like wf.vencido
    
    field catvencerger     like wf.vencer
    field catvencer31     like wf.vencer
    field catvencer41     like wf.vencer  
    field catvencer81     like wf.vencer.
   **/
   
def temp-table wfano no-undo /* #1 */
    field cobcod        like cobra.cobcod
    field vencidoano like titulo.titvlcob label "Vencido"
    field vencerano  like titulo.titvlcob label "Vencer"
    field cartano    like titulo.titvlcob label "Carteira".

def var vindex as int. 

def var wvencidoano like titulo.titvlcob label "Vencido".
def var wvencerano  like titulo.titvlcob label "Vencer".
def var wcartano    like titulo.titvlcob label "Carteira".

def var wcrenov  like titulo.titvlcob. /* #1 */

def var vmodais as char.
def var vmodcod as char.

        run /admcom/progr/le_tabini.p (0, 0, "Filtro-Modal-REC", OUTPUT vmodais).
        do v-cont = 1 to num-entries(vmodais).
            vmodcod = entry(v-cont, vmodais).
            create tt-modalidade-selec.
            assign tt-modalidade-selec.modcod = vmodcod.
        end.

assign vmod-sel = "  ".
for each tt-modalidade-selec.
    assign vmod-sel = vmod-sel + tt-modalidade-selec.modcod + "  ".
end.



def stream tttitulo.            
def var varquivoparcelas as char.
varquivoparcelas = "parcelas_" + string(vdtref,"99999999").
output stream tttitulo to value("/admcom/helio/ctb/carteira/" + varquivoparcelas + ".csv").
            put stream tttitulo unformatted 
                "Codigo do Cliente" ";"
                "CPF;"
                "Nome do cliente;"
                "Contrato" ";"
                "Parcela" ";"
                "Emissao" ";"
                "Pagamento" ";"
                "Valor Nominal" ";"
                "Carteira" ";"
                "Modalidade" ";"
                "Tp" ";"
                "Filial" ";"
                "Produto" ";"
                "Vencimento" ";"
                "Principal" ";"                
                "Acrescimo" ";"
                "Seguro;"
                "IOF;"
                skip.


        vtime = time.
        for each estab no-lock.
        for each tt-modalidade-selec no-lock,
            each titulo where titnat = no and titdtpag = ? and titulo.modcod = tt-modalidade-selec.modcod 
                    and titulo.etbcod = estab.etbcod
                no-lock.
            if titulo.titsit <> "LIB" then next.
            if titulo.titdtven = ? then next.
            if titulo.titdtemi > vdtref then next.  

            vconta = vconta + 1.
            if vconta = 1 or vconta mod 8000 = 0
            then do:
                hide message no-pause.
                message "1.a1 Processando... Filial : " titulo.etbcod
                        string(time - vtime ,"HH:MM:SS")  vconta.
                pause 1.
                run processando.
            end.

            
            
            find first wf where 
                    wf.cobcod = titulo.cobcod
                    /*
                    wf.vdt = date(month(titulo.titdtven), 01,
                             year(titulo.titdtven)) 
                             */
                             no-error.
            if not available wf
            then create wf.
            wf.cobcod = titulo.cobcod.
            /*
            assign wf.vdt = 
                date(month(titulo.titdtven), 01, year(titulo.titdtven)).
                */

            vtitvltot = if titulo.titvltot <> 0 then titulo.titvltot else titulo.titvlcob.

            if titulo.titdtven <= vdtref
            then do:
                wf.vencido = wf.vencido + vtitvltot.
            end.     
            else do:
                wf.vencer  = wf.vencer + vtitvltot.
            end.   
            
             if   acha("FEIRAO-NOME-LIMPO",titulo.titobs[1]) <> ? and acha("FEIRAO-NOME-LIMPO",titulo.titobs[1]) = "SIM" and titulo.tpcontrato <> "L"
             then vtpcontrato = "F". 
             else vtpcontrato = titulo.tpcontrato.
            find ctbpostitprod where ctbpostitprod.contnum = int(titulo.titnum) no-lock no-error.
            if avail ctbpostitprod
            then vproduto = ctbpostitprod.produto.
            else run pegaproduto.
                                                         
            find first ttcontrato where 
                    ttcontrato.titnum = titulo.titnum and 
                    ttcontrato.cobcod = titulo.cobcod 
                no-error.
            if not avail ttcontrato
            then do:     
                create ttcontrato.
                    ttcontrato.titnum = titulo.titnum.
                    ttcontrato.cobcod = titulo.cobcod.
                    ttcontrato.etbcod = titulo.etbcod.
                    ttcontrato.modcod = titulo.modcod.
                    ttcontrato.tpcontrato = vtpcontrato.
                    ttcontrato.titdtemi = titulo.titdtemi.
                    ttcontrato.produto  = vproduto.
            end.     
            ttcontrato.titdtpag = if titulo.titdtpag = ?
                                  then ?
                                  else max(ttcontrato.titdtpag,titulo.titdtpag).
            ttcontrato.titvlcob = ttcontrato.titvlcob + vtitvltot.
            ttcontrato.vlf_principal = ttcontrato.vlf_principal + if titulo.vlf_principal = 0 then vtitvltot else titulo.vlf_principal  .
            ttcontrato.vlf_acrescimo = ttcontrato.vlf_acrescimo + titulo.vlf_acrescimo.
            ttcontrato.vlseguro = ttcontrato.vlseguro + titulo.titdesc.  /* helio 09122021 Melhorias CR II */            
            
                    ttcontrato.vencini    = if ttcontrato.vencini = ?
                                              then titulo.titdtven
                                              else min(ttcontrato.vencini,titulo.titdtven).
                    ttcontrato.vencfim    = if ttcontrato.vencfim = ?
                                              then titulo.titdtven
                                              else max(ttcontrato.vencfim,titulo.titdtven).

            find clien where clien.clicod = titulo.clifor no-lock no-error.

    vnro_parcela = 0.
    vvlseguro   = 0.
    vvliof      = 0.
    
    find contrato where contrato.contnum = int(titulo.titnum) no-lock no-error.
    if avail contrato
    then do:
        vnro_parcela = contrato.nro_parcela.
        if vnro_parcela = 0
        then do: 
            for each  xtitulo where
                        xtitulo.empcod = 19 and
                        xtitulo.titnat = no and
                        xtitulo.etbcod = contrato.etbcod and
                        xtitulo.clifor = contrato.clicod and
                        xtitulo.modcod = contrato.modcod and
                        xtitulo.titnum = string(contrato.contnum) and
                        xtitulo.titdtemi = contrato.dtinicial
                        no-lock.
                        vnro_parcela = vnro_parcela + 1.    
            end.                        
        end.

        vvlseguro = if contrato.vlseguro > 0
                    then contrato.vlseguro / vnro_parcela
                    else 0.  
        vvliof = if contrato.vliof > 0
                 then contrato.vliof / vnro_parcela
                 else 0.
    end.

        vtitvltot = if titulo.titvltot <> 0 then titulo.titvltot else titulo.titvlcob.
            
            put stream tttitulo unformatted 
                titulo.clifor ";"
                (if avail clien then clien.ciccgc  else "" ) ";"
                (if avail clien then clien.clinom  else "" ) ";"
                
                titulo.titnum ";"
                titulo.titpar ";"
                string(titulo.titdtemi,"99/99/9999")  ";"
                string(titulo.titdtpag,"99/99/9999")  ";"
                trim(string(vtitvltot,"->>>>>>>>>>>>>>>>>>>>9.99")) ";"
                titulo.cobcod ";"
                titulo.modcod ";"
                vtpcontrato ";"
                titulo.etbcod ";"
                vproduto ";"
                string(titulo.titdtven,"99/99/9999")  ";"
                trim(string(if titulo.vlf_principal = 0 then vtitvltot else titulo.vlf_principal,"->>>>>>>>>>>>>>>>>>>>9.99"))  ";"
                trim(string(titulo.vlf_acrescimo,"->>>>>>>>>>>>>>>>>>>>9.99")) ";"

        trim(string(vvlseguro,"->>>>>>>>>>>>>>9.99")) ";"  
        trim(string(vvliof,"->>>>>>>>>>>>>>9.99")) ";"  
                
                skip.

            
            find first ctbposprod use-index ctbposprod where 
                ctbposprod.cobcod = titulo.cobcod and
                ctbposprod.modcod = titulo.modcod and
                ctbposprod.tpcontrato = vtpcontrato and
                ctbposprod.etbcod = titulo.etbcod and
                ctbposprod.produto = vproduto and
                ctbposprod.dtref  = vdtrefini 
             no-error.
            if not avail ctbposprod
            then do:
                create ctbposprod.
                ctbposprod.dtref  = vdtrefini.
                ctbposprod.etbcod = titulo.etbcod .
                ctbposprod.modcod = titulo.modcod .
                ctbposprod.tpcontrato = vtpcontrato.
                ctbposprod.cobcod = titulo.cobcod.
                ctbposprod.produto = vproduto .
                
            end. 
            ctbposprod.saldo   = ctbposprod.saldo   + vtitvltot.
            
            
                        
        end.
        do vdt = vdtref + 1 to today .
        for each tt-modalidade-selec no-lock,
            each titulo where titulo.titnat = no and titdtpag = vdt and titulo.modcod = tt-modalidade-selec.modcod and
                titulo.etbcod = estab.etbcod no-lock.
            if titulo.titsit <> "PAG" then next.
            if titulo.titdtpag = ? then next.
            if titulo.titdtven = ? then next.
            if titulo.titdtemi > vdtref then next. 

            vconta = vconta + 1.
            if vconta = 1 or vconta mod 8000 = 0
            then do:
                hide message no-pause.
                message "1.a2 Processando... Filial : " titulo.etbcod
                        string(time - vtime ,"HH:MM:SS")  vconta.
                pause 1.
                run processando.
            end.

            vtitvltot = if titulo.titvltot <> 0 then titulo.titvltot else titulo.titvlcob.
            
            find first wf where 
                    wf.cobcod = titulo.cobcod
                             no-error.
            if not available wf
            then create wf.
                    wf.cobcod = titulo.cobcod.
            if titulo.titdtven <= vdtref
            then do:
                wf.vencido = wf.vencido + vtitvltot.
            end.     
            else do:
                wf.vencer  = wf.vencer + vtitvltot.
            end.          
            

             if   acha("FEIRAO-NOME-LIMPO",titulo.titobs[1]) <> ? and acha("FEIRAO-NOME-LIMPO",titulo.titobs[1]) = "SIM" and titulo.tpcontrato <> "L"
             then vtpcontrato = "F". 
             else vtpcontrato = titulo.tpcontrato.
            find ctbpostitprod where ctbpostitprod.contnum = int(titulo.titnum) no-lock no-error.
            if avail ctbpostitprod
            then vproduto = ctbpostitprod.produto.
            else run pegaproduto.
                                                         
            find first ttcontrato where 
                    ttcontrato.titnum = titulo.titnum and 
                    ttcontrato.cobcod = titulo.cobcod 
                no-error.
            if not avail ttcontrato
            then do:     
                create ttcontrato.
                    ttcontrato.titnum = titulo.titnum.
                    ttcontrato.cobcod = titulo.cobcod.
                    ttcontrato.etbcod = titulo.etbcod.
                    ttcontrato.modcod = titulo.modcod.
                    ttcontrato.tpcontrato = vtpcontrato.
                    ttcontrato.titdtemi = titulo.titdtemi.
                    ttcontrato.produto  = vproduto.
            end.     
            ttcontrato.titdtpag = if titulo.titdtpag = ?
                                  then ?
                                  else max(ttcontrato.titdtpag,titulo.titdtpag).
            ttcontrato.titvlcob = ttcontrato.titvlcob + vtitvltot.
            ttcontrato.vlf_principal = ttcontrato.vlf_principal + if titulo.vlf_principal = 0 then vtitvltot else titulo.vlf_principal.
            ttcontrato.vlf_acrescimo = ttcontrato.vlf_acrescimo + titulo.vlf_acrescimo.
            
                    ttcontrato.vencini    = if ttcontrato.vencini = ?
                                              then titulo.titdtven
                                              else min(ttcontrato.vencini,titulo.titdtven).
                    ttcontrato.vencfim    = if ttcontrato.vencfim = ?
                                              then titulo.titdtven
                                              else max(ttcontrato.vencfim,titulo.titdtven).

            find clien where clien.clicod = titulo.clifor no-lock no-error. 
    vnro_parcela = 0.
    vvlseguro   = 0.
    vvliof      = 0.
    
    find contrato where contrato.contnum = int(titulo.titnum) no-lock no-error.
    if avail contrato
    then do:
        vnro_parcela = contrato.nro_parcela.
        if vnro_parcela = 0
        then do: 
            for each  xtitulo where
                        xtitulo.empcod = 19 and
                        xtitulo.titnat = no and
                        xtitulo.etbcod = contrato.etbcod and
                        xtitulo.clifor = contrato.clicod and
                        xtitulo.modcod = contrato.modcod and
                        xtitulo.titnum = string(contrato.contnum) and
                        xtitulo.titdtemi = contrato.dtinicial
                        no-lock.
                        vnro_parcela = vnro_parcela + 1.    
            end.                        
        end.

        vvlseguro = if contrato.vlseguro > 0
                    then contrato.vlseguro / vnro_parcela
                    else 0.  
        vvliof = if contrato.vliof > 0
                 then contrato.vliof / vnro_parcela
                 else 0.
    end.
    
        vtitvltot = if titulo.titvltot <> 0 then titulo.titvltot else titulo.titvlcob.
            
            put stream tttitulo unformatted 
                titulo.clifor   ";"
                (if avail clien then clien.ciccgc  else "" ) ";"
                (if avail clien then clien.clinom  else "" ) ";"
                
                titulo.titnum ";"
                titulo.titpar ";"
                string(titulo.titdtemi,"99/99/9999")  ";"
                string(titulo.titdtpag,"99/99/9999")  ";"
                trim(string(vtitvltot,"->>>>>>>>>>>>>>>>>>>>9.99")) ";"
                titulo.cobcod ";"
                titulo.modcod ";"
                vtpcontrato ";"
                titulo.etbcod ";"
                vproduto ";"
                string(titulo.titdtven,"99/99/9999") ";" 
                trim(string(if titulo.vlf_principal = 0 then vtitvltot else titulo.vlf_principal,"->>>>>>>>>>>>>>>>>>>>9.99"))  ";"
                trim(string(titulo.vlf_acrescimo,"->>>>>>>>>>>>>>>>>>>>9.99")) ";"
        trim(string(vvlseguro,"->>>>>>>>>>>>>>9.99")) ";"  
        trim(string(vvliof,"->>>>>>>>>>>>>>9.99")) ";"  
                
                skip.
            

            
            find first ctbposprod use-index ctbposprod where 
                ctbposprod.cobcod = titulo.cobcod and
                ctbposprod.modcod = titulo.modcod and
                ctbposprod.tpcontrato = vtpcontrato and
                ctbposprod.etbcod = titulo.etbcod and
                ctbposprod.produto = vproduto and
                ctbposprod.dtref  = vdtrefini 
             no-error.
             
            if not avail ctbposprod
            then do:
                create ctbposprod.
                ctbposprod.dtref  = vdtrefini.
                ctbposprod.etbcod = titulo.etbcod .
                ctbposprod.modcod = titulo.modcod .
                ctbposprod.tpcontrato = vtpcontrato.
                ctbposprod.cobcod = titulo.cobcod.
                ctbposprod.produto = vproduto .
                
            end. 
            ctbposprod.saldo   = ctbposprod.saldo   + vtitvltot.
            
            
        end.
        end.
        

        
end.


vtotal = 0.

    
for each wf .

    find first wfano where wfano.cobcod = wf.cobcod no-error.
    if not avail wfano
    then do:
        create wfano.
        assign wfano.cobcod = wf.cobcod.
    end.

    wfano.vencidoano = wfano.vencidoano + wf.vencido.
    wfano.vencerano  = wfano.vencerano  + wf.vencer.
    wfano.cartano    = wfano.cartano + wf.vencido + wf.vencer.
end.
/****
for each wf where year(wf.vdt) > (year(vdtref) + 1) break by wf.vdt
                                                       by year(wf.vdt):


    find first wfano where wfano.vano = year(wf.vdt) no-error.
    if not avail wfano
    then do:
        create wfano.
        assign wfano.vano = year(wf.vdt).
    end.

    wfano.vencidoano = wfano.vencidoano + wf.vencido.
    wfano.vencerano  = wfano.vencerano  + wf.vencer.
    
    /**wfano.catvencidoger = wfano.catvencidoger + wf.catvencidoger.
    wfano.catvencido31 = wfano.catvencido31 + wf.catvencido31.
    wfano.catvencido41 = wfano.catvencido41 + wf.catvencido41.
    wfano.catvencido81 = wfano.catvencido81 + wf.catvencido81.
    

    wfano.catvencerger = wfano.catvencerger + wf.catvencerger.
    wfano.catvencer31 = wfano.catvencer31 + wf.catvencer31.
    wfano.catvencer41 = wfano.catvencer41 + wf.catvencer41.
    wfano.catvencer81 = wfano.catvencer81 + wf.catvencer81.
    **/

    for each tt-modalidade-selec,
        each carteira
        where carteira.carano = year(wf.vdt) and
              carteira.titnat = no and
              carteira.modcod = tt-modalidade-selec.modcod 
                    no-lock.
                    
        wcartano = wcartano + carteira.carval[month(wf.vdt)].
    end.
end.

for each wf:
    find first wfano where wfano.vano = year(wf.vdt) no-error.
    if avail wfano
    then delete wf.
end.
***/

hide message no-pause.
message "Gerando o csv ".
def var vqtdtotal as int init 0.
def var vqtdarq   as dec.  

def var vqtdarqint as int.
for each ttcontrato.
    vqtdtotal = vqtdtotal + 1.
end.    
vqtdarq = vqtdtotal / 1048570.
vqtdarqint = int(round(vqtdarq,0)).
vqtdarq = vqtdarq - vqtdarqint.
if vqtdarq > 0
then vqtdarqint = vqtdarqint + 1.
message vqtdtotal "Contratos" vqtdarqint "Arquivos Csv".

run processando.

def var varquivos as char.
    def var ccarteira as char.
    def var cmodnom   as char.
   def var vi as int. def var ctpcontrato as char.
    
   def var varq as char format "x(76)".
   def var vcp  as char init ";".
    varq = ("/admcom/helio/ctb/carteira/posicao_analitica_" + string(vdtref,"99999999") + ".csv").
   
/*    pause 0.
    update skip(2) varq skip(2)
        with
        centered 
        overlay
        color messages
        no-labels
        row 8
        title string(vqtdarqint) + " arquivo de saida".
  */
  
def var vregistros as int.     
   
    for each ttcontrato.
        if vregistros = 0
        then do:
            vi = vi + 1.
            varquivos = replace(varq,".csv","_arq") + string(vi) + ".csv".
            
            output to value(varquivos).    
                vregistros = vregistros + 1.    
                put unformatted
                "Codigo" vcp
                "Nome"   vcp
                "CPF"    vcp 
                "Contrato" vcp    
                "Carteira" vcp    
                "Valor Aberto"   vcp
                "Emissão" vcp
                "Vencimento_inicial"  vcp
                "Vencimento_final"    vcp
                "Modalidade"  vcp
                "Filial"  vcp
                "Tipo de cobrança" vcp
                "Data Referencia" vcp
                "Produto" vcp
                "Principal" vcp
                "Acrescimo" vcp
                "Seguro"    vcp
                "Plano"     vcp /* helio 09/12/2021 Melhorias CR II */
                "Entrada"   vcp /* helio 09/12/2021 Melhorias CR II */
                "Vlr Crediario" vcp /* helio 09/12/2021 Melhorias CR II */
                
                skip.
                vregistros = vregistros + 1.    
        end.
        
        find contrato where contrato.contnum = int(ttcontrato.titnum) no-lock no-error.
            if not avail contrato then next.
        find clien where clien.clicod = contrato.clicod no-lock no-error.
        
        
        find cobra where cobra.cobcod = ttcontrato.cobcod no-lock no-error.
        find modal where modal.modcod = contrato.modcod no-lock no-error.
        ccarteira = (if ttcontrato.cobcod <> ? 
                 then string(ttcontrato.cobcod) + if avail cobra 
                                           then ("-" + cobra.cobnom)
                                           else ""
                 else "-").

        ctpcontrato = ttcontrato.tpcontrato.

        cmodnom = if contrato.modcod <> ? 
                then contrato.modcod + if avail modal then "-" + modal.modnom else ""
                else "-".
        
        put unformatted
            
            contrato.clicod     vcp
            if avail clien then clien.clinom else "-"       vcp
            if avail clien then clien.ciccgc else "-"       vcp
            contrato.contnum    vcp
            ccarteira           vcp
            trim(string(ttcontrato.titvlcob,"->>>>>>>>>>>>>>>>>>>>9.99"))    vcp
            string(contrato.dtinicial,"99/99/9999")   vcp
            string(ttcontrato.vencini,"99/99/9999")     vcp
            string(ttcontrato.vencfim,"99/99/9999")    vcp    
            cmodnom             vcp
            contrato.etbcod     vcp
            ctpcontrato         vcp
            vdtref              vcp
            ttcontrato.produto vcp 
            trim(string(ttcontrato.vlf_principal,"->>>>>>>>>>>>>>>>>>>>9.99")) vcp
            trim(string(ttcontrato.vlf_acrescimo,"->>>>>>>>>>>>>>>>>>>>9.99")) vcp
            trim(string(ttcontrato.vlseguro,"->>>>>>>>>>>>>>>>>>>>9.99")) vcp
            
            contrato.crecod     vcp /* helio 09/12/2021 Melhorias CR II */
            trim(string(contrato.vlentra,"->>>>>>>>>>>>>>>>>>>>9.99"))    vcp /* helio 09/12/2021 Melhorias CR II */
            trim(string(contrato.vltotal - contrato.vlentra,"->>>>>>>>>>>>>>>>>>>>9.99"))    vcp /* helio 09/12/2021 Melhorias CR II */
                        
               skip.
        vregistros = vregistros + 1.
        if vregistros = 1048570
        then do:
            output  close.
            vregistros = 0.
        end.
    end.
    
    output close.



output stream tttitulo close.

run processando.
run montasaldo.


hide message no-pause.

message "Gerando o Relatorio ".
run processando.

def buffer bestab for estab.
pause 0 .    
    varquivo = "/admcom/helio/ctb/carteira/resumo_carteira_" + string(vdtref,"99999999") + ".txt".

    if vdtref = ?
    then vdtref = vdtf.
    
    /*
    64
    66
    */
    {/admcom/progr/mdad.i
            &Saida     = "value(varquivo)" 
            &Page-Size = "0"
            &Cond-Var  = "140"
            &Page-Line = "0"
            &Nom-Rel   = ""frsalcarth2002""
            &Nom-Sis   = """SISTEMA DE CREDIARIO"""
            &Tit-Rel   = """ POSICAO DA CARTEIRA - "" + 
                               "" DATA BASE: "" + 
                              string(vdtref,""99/99/9999"")" 
            &Width     = "140"
            &Form      = "frame f-cabcab"}
vtot1 = 0.
vtot2 = 0.
vtotal = 0.
/**
vtotcatger = 0.
vtotcat31 = 0.
vtotcat41 = 0.
vtotcat81 = 0.
**/

for each wfano by wfano.cobcod:

    find cobra where cobra.cobcod = wfano.cobcod no-lock.
    
    vdisp = string(wfano.cobcod,"999") + "-" + cobra.cobnom.

    disp vdisp          column-label "Carteira"  format "x(20)"
         wfano.cartano  column-label "Carteira"
         wfano.vencidoano     column-label "Vencido" (TOTAL)
         wfano.vencerano      column-label "A Vencer" (TOTAL)
         wfano.cartano      column-label "Saldo" (TOTAL)
         
         with centered width 240.

        vtot1  = vtot1  +  wfano.vencidoano.
        vtot2  = vtot2  +  wfano.vencerano.
        vtotal = vtotal + (wfano.vencerano + wfano.vencidoano).
        /**vtotcatger  = vtotcatger  +  wfano.catvencidoger + wfano.catvencerger.
        vtotcat31  = vtotcat31  +  wfano.catvencido31 + wfano.catvencer31.
        vtotcat41  = vtotcat41  +  wfano.catvencido41 + wfano.catvencer41.
        vtotcat81  = vtotcat81  +  wfano.catvencido81 + wfano.catvencer81.
        **/
end.

    display ((vtot1 / vtotal) * 100) format ">>9.99 %" at 39
            ((vtot2 / vtotal) * 100) format ">>9.99 %" at 64 skip(1)
            with frame fsub.

    display vtot1 label  "Total Vencido"  skip
            vtot2 label  " Total Vencer"   skip
            vtotal label "  Total Geral"   skip(2)
            /**
            vtotcatger label "Cat Geral" skip
            vtotcat31 label  "   Moveis"    skip
            vtotcat41 label  "     Moda" skip
            vtotcat81 label  "   Seguro"
            **/
            with side-labels frame ftot.
output close.


    varquivo = "/admcom/helio/ctb/carteira/resumo_carteira_" + string(vdtref,"99999999") + ".txt".
    unix silent value("mv " + varquivo         + " /admcom/tmp/ctb/carteira/.").

    /* #18082022 split parcelas 800000 regs */
    unix silent value("/admcom/progr/finct/splitcsv.sh " + varquivoparcelas + ".csv /admcom/helio/ctb/carteira /admcom/helio/ctb/carteira/saida").
    unix silent value("mv /admcom/helio/ctb/carteira/saida/" + varquivoparcelas + "*.csv /admcom/tmp/ctb/carteira/.").
    
    
    do vqtdarq = 1 to 10:
        varquivo = "/admcom/helio/ctb/carteira/posicao_analitica_" + string(vdtref,"99999999") + "_arq" + string(vqtdarq) + ".csv".
        if search(varquivo) <> ?
        then unix silent value("mv " + varquivo + " /admcom/tmp/ctb/carteira/.").
    end.

for each ctbprzmprod where 
            ctbprzmprod.pparametros = pctbprzmprod.pparametros and
            ctbprzmprod.dtiniper = pctbprzmprod.dtiniper and
            ctbprzmprod.dtfimper = pctbprzmprod.dtfimper:

    ctbprzmprod.dtfimproc  = today.
    ctbprzmprod.hrfimproc  = time.
    ctbprzmprod.pstatus    = "PRONTO".

end.
message "FIM" today string(time,"HH:MM:SS").


procedure pegaproduto.

    find ctbpostitprod where ctbpostitprod.contnum = int(titulo.titnum) no-lock no-error.
    if avail ctbpostitprod
    then do:
        vproduto = ctbpostitprod.produto.
        return.
    end.
    if vtpcontrato <> ""
    then do:
        vproduto =  if vtpcontrato = "F"
                    then "FEIRAO "
                    else if vtpcontrato = "N"
                         then "NOVACAO"
                         else if vtpcontrato = "L"
                              then "LP     "
                              else "".
        if vproduto <> ""
        then return.   
    end.    
    vproduto = "DESCONHECIDO".
    def var vcatcod as int.        
    find contrato where contrato.contnum = int(titulo.titnum) no-lock no-error.
    if avail contrato
    then do:
        find contrsite where contrsite.contnum = int(titulo.titnum) no-lock no-error.
        if avail contrsite
        then do:
            vproduto = "Cre Digital".
        end.
        else do:
            if contrato.modcod begins "CP"
            then do:
                vproduto = "Emprestimos".
            end.
            else do:    
                find first contnf where 
                    contnf.etbcod = contrato.etbcod and
                    contnf.contnum = contrato.contnum 
                    no-lock no-error.
                if avail contnf 
                then do:
                    find first plani where
                        plani.etbcod = contnf.etbcod and
                        plani.placod = contnf.placod 
                        no-lock no-error. 
                    if avail plani
                    then do:
                        vcatcod = 0.
                        for each movim where movim.etbcod = plani.etbcod and
                                             movim.placod = plani.placod
                                             no-lock.
                            find produ of movim no-lock no-error.
                            if avail produ
                            then do:                    
                                if produ.catcod = 31 or produ.catcod = 41
                                then do:
                                    find categoria of produ no-lock.
                                    vproduto = caps(categoria.catnom).
                                    leave.
                                end.
                                else vcatcod = produ.catcod. 
                            end.
                        end.
                        if vproduto = "DESCONHECIDO"
                        then do:
                            find categoria where categoria.catcod = vcatcod no-lock no-error.
                            if avail categoria
                            then do:
                                vproduto = caps(categoria.catnom).
                            end.     
                        end.        
                    end.                                   
                end.          
            end.
        end.                     
    end.    
    if not avail ctbpostitprod
    then do on error undo:
        create ctbpostitprod.
        ctbpostitprod.contnum = int(titulo.titnum) .
        ctbpostitprod.produto = vproduto.
    end.    
    
end procedure.    



procedure montasaldo.


    for each ctbposprod where ctbposprod.dtref = vdtrefini.

                    find first ctbposcart use-index ctbposcart where 
                        ctbposcart.cobcod = ctbposprod.cobcod and
                        ctbposcart.modcod = ctbposprod.modcod and
                        ctbposcart.tpcontrato = ctbposprod.tpcontrato and
                        ctbposcart.etbcod = ctbposprod.etbcod and
                        ctbposcart.dtref  = ctbposprod.dtref 
                     no-error.
                    if not avail ctbposcart
                    then do:
                        create ctbposcart.
                        ctbposcart.dtref  = ctbposprod.dtref.
                        ctbposcart.etbcod = ctbposprod.etbcod.
                        ctbposcart.modcod = ctbposprod.modcod.
                        ctbposcart.tpcontrato = ctbposprod.tpcontrato.
                        ctbposcart.cobcod = ctbposprod.cobcod.
                    end. 
                    ctbposcart.saldo   = ctbposcart.saldo   + ctbposprod.saldo.
    end.


end procedure.


procedure processando:
    
    do on error undo:
        find first ctbprzmprod where 
                    ctbprzmprod.pparametros = pctbprzmprod.pparametros and
                    ctbprzmprod.dtiniper = pctbprzmprod.dtiniper and 
                    ctbprzmprod.dtfimper = pctbprzmprod.dtfimper and 
                    ctbprzmprod.campo = "TOTAL" and 
                    ctbprzmprod.valor = "" no-error. 
        if not avail ctbprzmprod
        then do:
            create ctbprzmprod.        
            ctbprzmprod.pparametros = pctbprzmprod.pparametros.
            ctbprzmprod.dtiniper   = pctbprzmprod.dtiniper.
            ctbprzmprod.dtfimper   = pctbprzmprod.dtfimper.
            ctbprzmprod.campo      = "TOTAL".
            ctbprzmprod.valorcampo = "".
            ctbprzmprod.dtrefSAIDA = vdtref.
            ctbprzmprod.vlrPago    = 0.
            ctbprzmprod.qtdPC      = 0.
            ctbprzmprod.PrzMedio   = 0.
            ctbprzmprod.dtinc      = today.
            ctbprzmprod.hrinc      = time.
            ctbprzmprod.dtiniproc  = pdtiniproc.
            ctbprzmprod.hriniproc  = phriniproc.
            ctbprzmprod.dtfimproc  = ?.
            ctbprzmprod.hrfimproc  = ?.
        end.  
        ctbprzmprod.hrfimproc  = time.
        ctbprzmprod.pstatus    = "PROCESSANDO".
        ctbprzmprod.qtdpc      = vconta.
                                                        
        message ctbprzmprod.pstatus ctbprzmprod.hrfimproc string(ctbprzmprod.hrfimproc,"HH:MM:SS").
         
    end.
    release ctbprzmprod.
        
end procedure.
