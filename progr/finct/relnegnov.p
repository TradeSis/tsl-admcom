{admcab.i}
def var vcp as char init ";".
def var pordem as int.
def buffer bcontrato for contrato.

def new shared temp-table ttnovs
    field ordem     as int
    field contnum   like contrato.contnum format ">>>>>>>>>>9"
    field CONTRATO  as char format "x(40)"
    field valor     like contrato.vltotal format "->>>>>>>>>>9.99"
    field saldoabe  like titulo.titvlcob format "->>>>>>>>>>9.99".
    
def new shared temp-table ttanteriores
    field final    like contrato.contnum format ">>>>>>>>>>9"
    field contnum  like contrato.contnum format ">>>>>>>>>>9"
    field ordem    as int
    field anterior like contrato.contnum format ">>>>>>>>>>9"
    field valor     like contrato.vltotal format "->>>>>>>>>>9.99"
    field saldoabe  like titulo.titvlcob format "->>>>>>>>>>9.99". 
    
def new shared temp-table ttnovacao no-undo
    field tipo      as char
    field contnum   like contrato.contnum format ">>>>>>>>>>9"
    field valor     like contrato.vltotal 
    field saldoabe  like titulo.titvlcob  
    index idx is unique primary tipo desc contnum asc.
def var vvlrpago as dec format "->>>>>>>>>>9.99".    
def new shared temp-table ttcontrato
    field contnum   like contrato.contnum
    index x is unique primary contnum asc.
 
def var wdti as date format "99/99/9999".
def var wdtf as date format "99/99/9999".
def var wqtd as int format ">9".
def var vcsv as log format "Sim/Nao".
def var varqcsv as char format "x(65)".
wdti = today.
wdtf = today.
wqtd = 1.
update 
     wdti    label "de"       colon 18  
     wdtf    label "a"       colon 35  
/*     wqtd           colon 18 label "min renegociacoes" */
    vcsv colon 18 label "gerar csv?"
                    with side-labels width 80 frame f1.
if vcsv
then do:
    varqcsv = "/admcom/relat/relnegnov" + string(time) + ".csv".
    update varqcsv
        with no-labels
        width 70
        centered no-box.
end.

message "Aguarde...".
for each contrato 
    where 
    dtinicial >= wdti and
    dtinicial <= wdtf and contrato.tpcontrato = "N" 
    no-lock.
    
    find first contnf where contnf.etbcod = contrato.etbcod and contnf.contnum = contrato.contnum no-lock no-error.
    if avail contnf then next. 
    find first tit_novacao where tit_novacao.ger_contnum = contrato.contnum
                             and tit_novacao.etbnova     = contrato.etbcod
                           no-lock no-error.


            find first pdvmoeda where pdvmoeda.modcod = contrato.modcod                and
    
                                    pdvmoeda.titnum = string(contrato.contnum)
                                    no-lock no-error.
    
    if avail pdvmoeda
    then do:
                find first pdvmov of pdvmoe no-lock no-error.
                
                    if not avail pdvmov then next.
                    find pdvtmov of pdvmov no-lock.
                    if pdvtmov.novacao = no
                    then next.

                        
        run fin/montattnov.p (recid(pdvmov),no).
        find first ttnovacao no-error.
                                    
        for each ttnovacao where ttnovacao.contnum <> contrato.contnum.             
            create ttanteriores.
            ttanteriores.final   = contrato.contnum.
            ttanteriores.ordem   = 1. 
            ttanteriores.contnum = contrato.contnum.
            ttanteriores.anterior = ttnovacao.contnum.
            ttanteriores.valor = ttnovacao.valor.
            ttanteriores.saldoabe = ttnovacao.saldoabe.
        end            .
      
    end.
    else do:
        next.
        /*ttnovs.contrato = string(contrato.contnum).*/
    end.

    pordem = 2.    
    run finct/relnegnov6a.p (contrato.contnum,
                           contrato.contnum, 
                           input-output pordem).
    find last ttanteriores where ttanteriores.final = contrato.contnum no-error.
    if avail ttanteriores  and ttanteriores.ordem >= wqtd
    then do:
         pordem = ttanteriores.ordem.
        create ttnovs.
        ttnovs.contnum= contrato.contnum.
         
        ttnovs.ordem = pordem + 1.
        ttnovs.contnum= contrato.contnum.
        ttnovs.contrato = fill(" ",(pordem) * 2) + string(contrato.contnum).
        find first ttnovacao where ttnovacao.contnum = contrato.contnum.             
            ttnovs.valor = ttnovacao.valor.
            ttnovs.saldoabe = ttnovacao.saldoabe.
        
        for each ttanteriores where ttanteriores.final = contrato.contnum
                break by ttanteriores.ordem desc.
            ttanteriores.ordem = ttanteriores.ordem * 10.
        end.
        for each ttanteriores where ttanteriores.final = contrato.contnum
                break by ttanteriores.ordem.
            ttanteriores.ordem = pordem.
            if last-of(ttanteriores.ordem)
            then pordem = pordem - 1.    
        end.
        
        for each ttanteriores where ttanteriores.final = contrato.contnum
                break by ttanteriores.ordem desc.
                
            create ttnovs.
            ttnovs.ordem = ttanteriores.ordem /*(ttanteriores.ordem - 1) * 2*/.
            ttnovs.contnum= contrato.contnum.
            ttnovs.contrato = fill(" ",(ttanteriores.ordem - 1) * 2) + string(ttanteriores.anterior).
            ttnovs.valor = ttanteriores.valor.
            ttnovs.saldoabe = ttanteriores.saldoabe.

        end.
    end.
            
end.

for each ttnovs break by ttnovs.contnum by ttnovs.ordem.
    if first-of(ttnovs.contnum) and last-of(ttnovs.contnum)
    then delete ttnovs.
end.    
def var varquivo as char.    
    varquivo = "/admcom/relat/relnegnov" + string(time) + ".txt".

    sresp = yes.
    if vcsv then do:
        output to value(varqcsv).
            
        put unformatted skip
            "Contrato;Qtd;Vlr Negociado;Sld Aberto;Emissao;Cliente;Nome Clente;Total;Pago;" skip.
        for each ttnovs break by ttnovs.contnum by ttnovs.ordem.
            if first-of(ttnovs.contnum) and not first(ttnovs.contnum)
            then put skip(1).
            put  ttnovs.CONTRATO format "x(30)" vcp.
            put unformatted
                ttnovs.ordem  vcp
                ttnovs.valor  vcp
                saldoabe      vcp.
            find bcontrato where bcontrato.contnum = int(ttnovs.contrato) no-lock.
            find clien of bcontrato no-lock.
            put unformatted
                bcontrato.dtinicial vcp
                bcontrato.clicod  vcp
                clien.clinom vcp
                bcontrato.vltotal vcp
                bcontrato.vltotal - saldoabe vcp
                skip.
        end.
        output close.
        hide message no-pause.
        message "Arquivo csv gerado " varqcsv.
        message "Deseja olhar relatorio na tela tambem?" update sresp.
    end.
    
   if sresp 
   then do:
    {mdadmcab.i
        &Saida     = "value(varquivo)"
        &Page-Size = "0"
        &Cond-Var  = "250"
        &Page-Line = "0"
        &Nom-Rel   = """RELNEGNOV"""
        &Nom-Sis   = """SISTEMA CREDIARIO"""
        &Tit-Rel   = """LISTAGEM RENEGOCIACOE DE NOVACAO  - PERIODO DE "" +
                        STRING(WDTI) + "" A "" + STRING(WDTF)"
        &Width     = "250"
        &Form      = "frame f-cab"}
 

    for each ttnovs break by ttnovs.contnum by ttnovs.ordem.
        if first-of(ttnovs.contnum)
        then down 1.
        disp  ttnovs.CONTRATO 
            ttnovs.ordem format ">>9"
             column-label "Qtd" /*when last-of(ttnovs.contnum)*/
            
            ttnovs.valor column-label "Vlr!Negociado"
                saldoabe column-label "Sld!Aberto".
        find bcontrato where bcontrato.contnum = int(ttnovs.contrato) no-lock.
        find clien of bcontrato no-lock. 
        disp bcontrato.dtinicial bcontrato.clicod clien.clinom
                bcontrato.vltotal
                column-label "Vlr!Contrato"
         bcontrato.vltotal - saldoabe @ vvlrpago    column-label "Pago"
            with width 250.
        
    end.

    output close.
    message "gerado arquivo" varquivo.
    run visurel.p(varquivo,"").
   end.
   
