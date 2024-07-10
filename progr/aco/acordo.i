def var p-temacordo as log.
def var vtpcontrato    like contrato.tpcontrato.
def var  vvlr_aberto    as dec.
def var vvlr_vencido as dec.
def var vvlr_vencer as dec.
def var  vvlr_divida   as dec.
def var vvlpresente     as dec.

def var  vvlr_parcela   as dec.
def var  vdt_venc       as date.
def var  vdias_atraso   as int.
def var  vqtd_pagas     as int.
def var  vqtd_parcelas  as int.
def var  vperc_pagas    as dec.
def var vqtd_parcvencida as int.
def var vqtd_parcvencer  as int.

def {1} shared temp-table ttcontrato no-undo
    field marca     as log format "*/ "
    field negcod       like aconegoc.negcod
    field contnum       like contrato.contnum
    field tpcontrato    like contrato.tpcontrato
    field vlr_aberto    as dec
    field vlr_divida    as dec
    field vlr_parcela   as dec
    field dt_venc       as date
    field dias_atraso   as int
    field qtd_pagas     as int
    field qtd_parcelas  as int
    field perc_pagas    as dec
    field vlr_vencido   as dec
    field vlr_vencer    as dec
    field trectitprotesto as recid
    index idx is unique primary  negcod asc contnum asc.

def {1} shared temp-table ttnegociacao no-undo
    field negcod    like aconegoc.negcod
    field qtd       as int 
    field vlr_aberto like ttcontrato.vlr_aberto
    field vlr_divida like ttcontrato.vlr_divida
    field qtd_selecionado as int 
    field vlr_selaberto   like ttcontrato.vlr_aberto
/*    field vlr_seldivida   like ttcontrato.vlr_divida */
    field vlr_selecionado like ttcontrato.vlr_divida
    
    field dt_venc        like ttcontrato.dt_venc
    field dias_atraso   like ttcontrato.dias_atraso 
    index idx is unique primary  negcod asc.



def {1} shared temp-table ttcondicoes no-undo
    field negcod        like aconegoc.negcod
    field planom        like acoplanos.planom
    field placod        like acoplanos.placod
    field vlr_entrada   as dec
    field min_entrada    as dec
    field vlr_acordo    as dec
    field vlr_juroacordo as dec
    field dtvenc1       as date
    field vlr_parcela   as dec
    field especial as log
    index idx is unique primary negcod asc placod asc planom asc.

def {1} shared temp-table ttparcelas no-undo
    field negcod        like aconegoc.negcod
    field planom        like acoplanos.planom
    field placod        like acoplanos.placod
    field titpar        as int format ">>9" label "parc"
    field perc_parcela  as dec decimals 6 format ">>>9.999999%" label "perc"
    field dtvenc        as date format "99/99/9999"
    field vlr_parcela   as dec format ">>>>>9.99" label "vlr parcela"
    index idx is unique primary negcod asc placod asc planom asc titpar asc.
    





procedure calcelegiveis.

def input param ptpnegociacao as char. 
def input param pclicod as int.
def input param pnegcod as int.

if vmessage
then do:
    hide message no-pause. message color normal "fazendo calculos... aguarde...".
end.    

for each ttcontrato.
    delete ttcontrato.
end.

for each contrato where
    contrato.clicod = pclicod
        no-lock.

    vvlr_aberto     = 0.
    vvlr_vencido = 0.
    vvlr_vencer  = 0.
    vvlr_divida     = 0.
    vvlr_parcela    = 0.
    vdt_venc        = ?.
    vdias_atraso    = 0.
    vqtd_pagas      = 0.
    vqtd_parcelas   = 0.
    vtpcontrato     = ?.
    
    /*helio 27112020 find titulo where titulo.contnum = contrato.contnum and
                      titulo.titpar  = 1
                      no-lock no-error.  
    if avail titulo 
    then do:
        for each titulo where titulo.contnum = contrato.contnum no-lock.
            if titulo.titpar = 0 then next.
            if titulo.titsit = "LIB" or titulo.titsit = "PAG" 
            then. 
            else next.
            
            vqtd_parcelas = vqtd_parcelas + 1.
            run ptitulo.
                        
        end.    
    end.
    else**/ do: 
        for each titulo where
                    titulo.empcod     = 19 and
                    titulo.titnat     = no and
                    titulo.modcod     = contrato.modcod and
                    titulo.etbcod     = contrato.etbcod and
                    titulo.clifor     = contrato.clicod and
                    titulo.titnum     = string(contrato.contnum) 
                    no-lock.
            if titulo.titpar = 0 then next.
            if titulo.titsit = "LIB" or titulo.titsit = "PAG" 
            then. 
            else next.
            vqtd_parcelas = vqtd_parcelas + 1.
            run ptitulo.                    
        end.
    end.

    if vvlr_aberto <> 0
    then do:       
        vperc_pagas = vqtd_pagas / vqtd_parcelas * 100.
        
        for each aconegoc 
                where
                aconegoc.tpnegociacao = ptpnegociacao     and /* helio 23022022 - iepro */
                (aconegoc.dtfim = ? or
                 aconegoc.dtfim >= today) and
                 aconegoc.dtini <= today
                 and
                 (if pnegcod <> ?
                  then aconegoc.negcod = pnegcod
                  else true) 
                no-lock.

            if aconegoc.tpnegociacao = "" /* normal */
            then do:    
                if not aconegoc.PermiteTitProtesto
                then do:
                    find first titprotesto where 
                        titprotesto.operacao = "IEPRO" and
                        titprotesto.clicod   = contrato.clicod and
                        titprotesto.contnum  = contrato.contnum and
                        titprotest.ativo = "ATIVO"
                        no-lock no-error.
                    if not avail titprotesto
                    then
                    find first titprotesto where 
                        titprotesto.operacao = "IEPRO" and
                        titprotesto.clicod   = contrato.clicod and
                        titprotesto.contnum  = contrato.contnum and
                        titprotest.ativo = "" 
                        no-lock no-error.
                        
                    if avail titprotesto
                    then next.
                end.
            end.  
            
                      
            if aconegoc.parcvencidaso or
               aconegoc.parcvencidaqtd >= 0 or
               aconegoc.parcvencerqtd >= 0
            then do:   
                vqtd_parcvencida = 0.
                vqtd_parcvencer  = 0. 
                vvlr_divida = 0.
                vvlr_aberto = 0.
                for each titulo where
                            titulo.empcod     = 19 and
                            titulo.titnat     = no and
                            titulo.modcod     = contrato.modcod and
                            titulo.etbcod     = contrato.etbcod and
                            titulo.clifor     = contrato.clicod and
                            titulo.titnum     = string(contrato.contnum) 
                            no-lock
                            by titulo.titpar.
                    if titulo.titpar = 0 then next.
                    if titulo.titsit = "LIB" 
                    then. 
                    else next.
                    if titulo.titdtven < today then vqtd_parcvencida = vqtd_parcvencida + 1.
                                               else vqtd_parcvencer  = vqtd_parcvencer  + 1.


                    run ptitulo_novo.                    
                end.
            end.
                    
                              
            if (contrato.modcod = (if aconegoc.modcod = ""  
                        then contrato.modcod
                                else if  lookup(contrato.modcod,aconegoc.modcod) = 0
                                     then ?
                                     else entry(lookup(contrato.modcod,aconegoc.modcod),aconegoc.modcod))) and
               (vtpcontrato = (if aconegoc.tpcontrato = "" or contrato.modcod  <> "CRE" 
                               then vtpcontrato
                                else if  lookup(vtpcontrato,aconegoc.tpcontrato) = 0
                                     then ?
                                     else entry(lookup(vtpcontrato,aconegoc.tpcontrato),aconegoc.tpcontrato))) and
                              
               vvlr_aberto >= aconegoc.vlr_aberto and
               contrato.vltotal  >= aconegoc.vlr_total and
               vperc_pagas >= aconegoc.perc_pagas and
               vqtd_pagas  >= aconegoc.qtd_pagas and
               vdias_atraso >= aconegoc.dias_atraso and                     
               contrato.dtinicial >= (if aconegoc.dtemissao_de = ?
                                      then contrato.dtinicial
                                      else aconegoc.dtemissao_de) and
               contrato.dtinicial <= (if aconegoc.dtemissao_ate = ?
                                      then contrato.dtinicial
                                      else aconegoc.dtemissao_ate) and
                                      
               vvlr_parcela >= aconegoc.vlr_parcela
            then do:
                create ttcontrato.
                ttcontrato.marca       = yes.
                ttcontrato.contnum     = contrato.contnum.
                ttcontrato.negcod      = aconegoc.negcod.
                ttcontrato.tpcontrato  = vtpcontrato.
                ttcontrato.vlr_aberto  = vvlr_aberto.
                ttcontrato.vlr_divida  = vvlr_divida.
                ttcontrato.vlr_vencido = vvlr_vencido.
                ttcontrato.vlr_vencer  = vvlr_vencer.
                                
                ttcontrato.vlr_parcela = vvlr_parcela.
                ttcontrato.dt_venc     = vdt_venc.  
                ttcontrato.dias_atraso = vdias_atraso. 
                ttcontrato.qtd_parcelas = vqtd_parcelas.
                ttcontrato.qtd_pagas   = vqtd_pagas.
                ttcontrato.perc_pagas  = vperc_pagas.
                                
            end.
        end.                                     
                       
        
    end.
            
end.
find first ttcontrato no-error.
if avail ttcontrato
then do:
    run arrasto (input ptpnegociacao, input pclicod).
    
    run montacampanha.
end.

hide message no-pause.
           
end procedure.


procedure ptitulo.
def var vjuros as dec.

    if titulo.titpar = 1 or vtpcontrato = ?
    then do:
        vvlr_parcela = if titulo.dtultpgparcial <> ? 
                        then titulo.titvltot    /* Controle Parcial 07/01/2020 */
                        else titulo.titvlcob. 
        vtpcontrato    = if acha("FEIRAO-NOME-LIMPO",titulo.titobs[1]) = "SIM"
                         then "FA"
                         else if acha("FEIRAO-NOVO",titulo.titobs[1])       = "SIM"
                              then "F"
                              else if titulo.tpcontrato = "" and titulo.modcod = "CRE"
                                   then "C"
                                   else titulo.tpcontrato.
        /*message titulo.titpar titulo.tpcontrato titulo.titnum vtpcontrato.*/
        
    end.
    
    if titulo.titdtpag = ?
    then do:
        vvlpresente = titulo.titvlcob.
        vjuros = 0.
        if titulo.titdtven > today
        then do:
            if contrato.txjuro > 0
            then do.
               /**29092020 desabilitei
               if vhostname = "SV-CA-DB-DEV" or
                  vhostname = "SV-CA-DB-QA"
               then vvlpresente = titulo.titvlcob / exp(1 + contrato.txjuro / 100,(titulo.titdtven - today) / 30). /* so nos servidores  de hml */
               **/
            end.
        end.
        
        vvlr_aberto = vvlr_aberto + vvlpresente.
        
        vvlr_divida = vvlr_divida + vvlpresente.
        
        
        if titulo.titdtven < today
        then do:
            run juro_titulo.p (if clien.etbcad = 0 then titulo.etbcod else clien.etbcad,
                           titulo.titdtven,
                           titulo.titvlcob,
                           output vjuros).
        
            vvlr_divida = vvlr_divida + vjuros.
            vvlr_vencido = vvlr_vencido + vvlpresente.
        end.
        else vvlr_vencer = vvlr_vencer + vvlpresente.
                
        vdt_venc    = if vdt_venc = ?
                      then titulo.titdtven
                      else min(vdt_venc,titulo.titdtven).
        vdias_atraso = today - vdt_venc.               
    end.    
    else do:
        vqtd_pagas = vqtd_pagas + 1. 
    end.


end procedure.



procedure ptitulo_novo.
def var vjuros as dec.

    if titulo.titdtpag = ?
    then do:
        vvlpresente = titulo.titvlcob.
        vjuros = 0.
        if titulo.titdtven > today
        then do:
            if contrato.txjuro > 0
            then do.
               /**29092020 desabilitei
               if vhostname = "SV-CA-DB-DEV" or
                  vhostname = "SV-CA-DB-QA"
               then vvlpresente = titulo.titvlcob / exp(1 + contrato.txjuro / 100,(titulo.titdtven - today) / 30). /* so nos servidores  de hml */
               **/
            end.
        end.
       
        if titulo.titdtven < today
        then do:        
            if aconegoc.parcvencidaqtd = 0 or
               vqtd_parcvencida <= aconegoc.parcvencidaqtd 
            then do:    
                vvlr_aberto = vvlr_aberto + vvlpresente.
                vvlr_divida = vvlr_divida + vvlpresente.
                run juro_titulo.p (if clien.etbcad = 0 then titulo.etbcod else clien.etbcad,
                               titulo.titdtven,
                               titulo.titvlcob,
                               output vjuros).
                vvlr_divida = vvlr_divida + vjuros.
            end.
            
        end.
        else do:
            if aconegoc.parcvencidaso = no and (aconegoc.parcvencerqtd = 0 or vqtd_parcvencer <= aconegoc.parcvencerqtd) 
            then do: 
                vvlr_aberto = vvlr_aberto + vvlpresente.
                vvlr_divida = vvlr_divida + vvlpresente.
            end.    
        end.
    end.                

end procedure.




procedure montacampanha.

for each ttnegociacao.
    delete ttnegociacao.
end.    
for each ttcontrato.
        find contrato where contrato.contnum = ttcontrato.contnum no-lock. 
                find first ttnegociacao where
                        ttnegociacao.negcod = ttcontrato.negcod
                        no-error.
                if not avail ttnegociacao        
                then do:
                    create ttnegociacao.
                    ttnegociacao.negcod  = ttcontrato.negcod.
                    ttnegociacao.dt_venc = ttcontrato.dt_venc.
                end.
                ttnegociacao.vlr_aberto  = ttnegociacao.vlr_aberto + ttcontrato.vlr_aberto.
                ttnegociacao.vlr_divida  = ttnegociacao.vlr_divida + ttcontrato.vlr_divida.
                ttnegociacao.qtd         = ttnegociacao.qtd + 1.
                if ttcontrato.marca
                then do:
                    ttnegociacao.vlr_selecionado = ttnegociacao.vlr_selecionado + ttcontrato.vlr_divida.
                    ttnegociacao.vlr_selaberto   = ttnegociacao.vlr_selaberto   + ttcontrato.vlr_aberto. 
                    
                    ttnegociacao.qtd_selecionado = ttnegociacao.qtd_selecionado + 1.
                end.    
                
                ttnegociacao.dt_venc = min(ttnegociacao.dt_venc,ttcontrato.dt_venc).
                ttnegociacao.dias_atraso = max(ttnegociacao.dias_atraso,ttcontrato.dias_atraso).
                
end.
end procedure.




procedure arrasto.
def input param ptpnegociacao as char.
def input param pclicod as int.
if vmessage
then do:
    hide message no-pause. message color normal "arrastando... aguarde...".
end.
    
for each contrato where
    contrato.clicod = pclicod
        no-lock on error undo , return.

    vvlr_aberto     = 0.
    vvlr_vencido    = 0.
    vvlr_vencer     = 0.
    vvlr_divida     = 0.
    vvlr_parcela    = 0.
    vdt_venc        = ?.
    vdias_atraso    = 0.
    vqtd_pagas      = 0.
    vqtd_parcelas   = 0.
    vtpcontrato     = ?.
    
    /**find titulo where titulo.contnum = contrato.contnum and
                      titulo.titpar  = 1
                      no-lock no-error.  
    if avail titulo 
    then do:
        for each titulo where titulo.contnum = contrato.contnum no-lock.
            if titulo.titpar = 0 then next.
            if titulo.titsit = "LIB" or titulo.titsit = "PAG" 
            then. 
            else next.
            
            vqtd_parcelas = vqtd_parcelas + 1.
            run ptitulo.
                        
        end.    
    end.
    else**/ 
    do: 
        for each titulo where
                    titulo.empcod     = 19 and
                    titulo.titnat     = no and
                    titulo.modcod     = contrato.modcod and
                    titulo.etbcod     = contrato.etbcod and
                    titulo.clifor     = contrato.clicod and
                    titulo.titnum     = string(contrato.contnum) 
                    no-lock.
            if titulo.titpar = 0 then next.
            if titulo.titsit = "LIB" or titulo.titsit = "PAG" 
            then. 
            else next.
            vqtd_parcelas = vqtd_parcelas + 1.
            run ptitulo.                    
        end.
    end.
    
    if vvlr_aberto <> 0
    then do:        
    
        vperc_pagas = vqtd_pagas / vqtd_parcelas * 100.

        
        for each aconegoc where
                aconegoc.tpnegociacao = ptpnegociacao     and /* helio 23022022 - iepro */
                (aconegoc.dtfim = ? or
                 aconegoc.dtfim >= today) and
                 aconegoc.dtini <= today
                no-lock.

            if aconegoc.arrasta /* ARRASTA OUTROS CONTRATOS SOMENTE SE FOR SIM */  
            then.
            else next.
                

                vqtd_parcvencida = 0.
                vqtd_parcvencer  = 0. 
                vvlr_divida = 0.
                vvlr_aberto = 0.
                for each titulo where
                            titulo.empcod     = 19 and
                            titulo.titnat     = no and
                            titulo.modcod     = contrato.modcod and
                            titulo.etbcod     = contrato.etbcod and
                            titulo.clifor     = contrato.clicod and
                            titulo.titnum     = string(contrato.contnum) 
                            no-lock
                            by titulo.titpar.
                    if titulo.titpar = 0 then next.
                    if titulo.titsit = "LIB" 
                    then. 
                    else next.
                    if titulo.titdtven < today then vqtd_parcvencida = vqtd_parcvencida + 1.
                                               else vqtd_parcvencer  = vqtd_parcvencer  + 1.

                    run ptitulo_novo.                    
                end.

            /* tem um contrato elegivel nesta campanha */  
            find first ttcontrato where 
                        ttcontrato.negcod = aconegoc.negcod no-error.
            if not avail ttcontrato
            then next.

            /* ja estou ai? */
            find first ttcontrato where 
                        ttcontrato.contnum = contrato.contnum and
                        ttcontrato.negcod = aconegoc.negcod no-error.
            if avail ttcontrato
            then next.
            
            /***
            if (contrato.modcod = (if aconegoc.modcod = ""  
                        then contrato.modcod
                                else if  lookup(contrato.modcod,aconegoc.modcod) = 0
                                     then ?
                                     else entry(lookup(contrato.modcod,aconegoc.modcod),aconegoc.modcod))) 
                                                         
                                     /*and
               (vtpcontrato = (if aconegoc.tpcontrato = "" or contrato.modcod  <> "CRE" 
                               then vtpcontrato
                                else if  lookup(vtpcontrato,aconegoc.tpcontrato) = 0
                                     then ?
                                     else entry(lookup(vtpcontrato,aconegoc.tpcontrato),aconegoc.tpcontrato))) **/
                                     
            then ***/
            
            /* iepro */
            if aconegoc.tpnegociacao = "" /* normal */
            then do:    
                if not aconegoc.PermiteTitProtesto
                then do:
                    find first titprotesto where 
                        titprotesto.operacao = "IEPRO" and
                        titprotesto.clicod   = contrato.clicod and
                        titprotesto.contnum  = contrato.contnum and
                        titprotest.ativo = "ATIVO"
                        no-lock no-error.
                    if not avail titprotesto
                    then
                    find first titprotesto where 
                        titprotesto.operacao = "IEPRO" and
                        titprotesto.clicod   = contrato.clicod and
                        titprotesto.contnum  = contrato.contnum and
                        titprotest.ativo = "" 
                        no-lock no-error.
                        
                    if avail titprotesto
                    then next.
                end.
            end.  
            
            if vvlr_aberto > 0
            then do:    
                create ttcontrato.
                ttcontrato.marca       = no.
                ttcontrato.contnum     = contrato.contnum.
                ttcontrato.negcod      = aconegoc.negcod.
                ttcontrato.tpcontrato  = vtpcontrato.
                ttcontrato.vlr_aberto  = vvlr_aberto.
                ttcontrato.vlr_divida  = vvlr_divida.
                ttcontrato.vlr_vencido  = vvlr_vencido.
                ttcontrato.vlr_vencer   = vvlr_vencer.
                
                ttcontrato.vlr_parcela = vvlr_parcela.
                ttcontrato.dt_venc     = vdt_venc.  
                ttcontrato.dias_atraso = vdias_atraso. 
                ttcontrato.qtd_parcelas = vqtd_parcelas.
                ttcontrato.qtd_pagas   = vqtd_pagas.
                ttcontrato.perc_pagas  = vperc_pagas.

                if aconegoc.arrasta
                then ttcontrato.marca = yes.
                
                else do:
                        /*
                    message contrato.contnum 
                            skip
                            "emissao" contrato.dtinicial arrast_dtemissao_de arrast_dtemissao_ate contrato.dtinicial >= (if arrast_dtemissao_de = ?
                                                                          then contrato.dtinicial
                                                                                                                        else arrast_dtemissao_de)
                                                                                                                        
                            skip
                            "emissao ate" arrast_dtemissao_ate contrato.dtinicial <= (if arrast_dtemissao_ate = ?
                                                                                                                                                                       ~~                           then contrato.dtinicial
                                                                        else arrast_dtemissao_ate)
                            skip
                            "dias_atraso" ttcontrato.dias_atraso Arrast_dias_atraso  ttcontrato.dias_atraso >= Arrast_dias_atraso
                            skip
                            "dias_vencer" today - ttcontrato.dt_venc arrast_dias_vencer  today - ttcontrato.dt_venc  >= arrast_dias_vencer
                            skip
                            "vlr_vencido" ttcontrato.vlr_vencido Arrast_vlr_vencido ttcontrato.vlr_vencido >= Arrast_vlr_vencido
                            skip 
                            "vlr_vencer" ttcontrato.vlr_vencer Arrast_vlr_vencer ttcontrato.vlr_vencer  >= Arrast_vlr_vencer
                            
                            view-as alert-box. 
                            **/
                            
                    /****
                    if (ttcontrato.dias_atraso >= Arrast_dias_atraso) and
                       (today - ttcontrato.dt_venc >= arrast_dias_vencer) and
                       (ttcontrato.vlr_vencido >= Arrast_vlr_vencido) and
                       (ttcontrato.vlr_vencer  >= Arrast_vlr_vencer) and
                       contrato.dtinicial >= (if arrast_dtemissao_de = ?
                                              then contrato.dtinicial
                                              else arrast_dtemissao_de) and
                       contrato.dtinicial <= (if arrast_dtemissao_ate = ?
                                              then contrato.dtinicial
                                              else arrast_dtemissao_ate) 
                    
                    then  ttcontrato.marca = yes.
                    ***/
                    
                end.
            end.
                
        end.                        
    end.
end.            
hide message no-pause.
           
end procedure.


/*
        form  
        aconegoc.negnom no-label
        ttnegociacao.qtd_selecionado format ">>>>"    column-label "sel"  
        
        ttnegociacao.vlr_selaberto   format    ">>>>>9.99" column-label "aberto"
        ttnegociacao.vlr_seldivida   format    ">>>>>9.99" column-label "divida"

        ttnegociacao.vlr_selecionado format    ">>>>>9.99" column-label "total"

        
        with frame frame-b 1 down centered row 5 overlay  no-underline title aconegoc.negnom.

  */

procedure montacondicoes.

def input param par-negcod as int.
def input param par-placod as int.

def var vvlr_entrada as dec.
    find aconegoc where aconegoc.negcod = par-negcod no-lock.
        find current ttnegociacao.
    
    /*
    if vmessage
    then        
     display  
        aconegoc.negnom 
        ttnegociacao.qtd_selecionado
        
        ttnegociacao.vlr_selaberto 
        ttnegociacao.vlr_seldivida 


        ttnegociacao.vlr_selecionado 


        with frame frame-b.
    */
    
for each ttcondicoes.
    delete ttcondicoes.
end.
for each ttparcelas.
    delete ttparcelas.
end.        

for each acoplanos where acoplanos.negcod = par-negcod 
        and (if par-placod <> ?
             then acoplanos.placod = par-placod
              else true)
        no-lock.

    create ttcondicoes.
    ttcondicoes.negcod  = acoplanos.negcod.
    ttcondicoes.placod  = acoplanos.placod.
    ttcondicoes.planom  = acoplanos.planom.

    
    if acoplanos.perc_desconto > 0 or
       acoplanos.valor_desc > 0
    then do:
        if acoplanos.calc_juro
        then do: 
            if acoplanos.perc_desc > 0
            then
            ttcondicoes.vlr_acordo =  ttnegociacao.vlr_selecionado - (ttnegociacao.vlr_selecionado * acoplanos.perc_desconto / 100).
            else             
            ttcondicoes.vlr_acordo =  ttnegociacao.vlr_selecionado - (
                            acoplanos.valor_desc ).

        end.    
        else do:
        
            if acoplanos.perc_desc > 0
            then
            ttcondicoes.vlr_acordo =  ttnegociacao.vlr_selaberto   - (ttnegociacao.vlr_selaberto   * acoplanos.perc_desconto / 100).
            else 
            ttcondicoes.vlr_acordo =  ttnegociacao.vlr_selaberto   - (
                            acoplanos.valor_desc ).

        end.    
    end.    
    else do:
        if acoplanos.calc_juro
        then do:
            ttcondicoes.vlr_acordo =  ttnegociacao.vlr_selecionado. 
        end.    
        else do:
            ttcondicoes.vlr_acordo =  ttnegociacao.vlr_selaberto. 
        end.    
    end.        
    
    if acoplanos.perc_acres > 0
    then do:
        ttcondicoes.vlr_juroacordo = (ttcondicoes.vlr_acordo * (acoplanos.perc_acres) / 100).
        ttcondicoes.vlr_acordo     =  ttcondicoes.vlr_acordo + ttcondicoes.vlr_juroacordo.
    end.    
    else
        if acoplanos.valor_acres > 0
        then do:
            ttcondicoes.vlr_juroacordo =  acoplanos.valor_acres.
            ttcondicoes.vlr_acordo     =  ttcondicoes.vlr_acordo + ttcondicoes.vlr_juroacordo.
        end.    
    
    
    vvlr_entrada = 0.
    ttcondicoes.min_entrada = 0.
    ttcondicoes.vlr_entrada = 0.
    if acoplanos.com_entrada
    then do:
        vvlr_entrada            = round(ttcondicoes.vlr_acordo / (acoplanos.qtd_vezes + 1),2).
        ttcondicoes.min_entrada = round(ttcondicoes.vlr_acordo * acoplanos.perc_min_entrada / 100,2). 
        if ttcondicoes.min_entrada > 0 /* helio 12/11/2021 ajuste erro calculo entrada ID 97282 - Tela de campanha */
        then  ttcondicoes.vlr_entrada = ttcondicoes.min_entrada.
        else  ttcondicoes.vlr_entrada = vvlr_entrada.
    end.
    
    ttcondicoes.dtvenc1     = today + acoplanos.dias_max_primeira.
    
    
    ttcondicoes.vlr_acordo  = ttcondicoes.vlr_acordo - ttcondicoes.vlr_entrada.
    
    find first acoplanparcel of acoplanos where
                acoplanparcel.titpar = 1
                no-lock no-error.
    if avail acoplanparcel
    then do:
        vvlr_parcela = round(ttcondicoes.vlr_acordo / acoplanos.qtd_vezes,2).

        ttcondicoes.vlr_parcela = round((ttcondicoes.vlr_acordo) * acoplanparcel.perc_parcel / 100,2). 
        ttcondicoes.especial    = vvlr_parcela <> ttcondicoes.vlr_parcela.

    end.
    else do:
        ttcondicoes.vlr_parcela = ttcondicoes.vlr_acordo / acoplanos.qtd_vezes.
    end.
    if ttcondicoes.vlr_parcela = ? 
    then ttcondicoes.vlr_parcela = 0.
    
    ttcondicoes.vlr_acordo  = ttcondicoes.vlr_acordo + ttcondicoes.vlr_entrada.
    if ttcondicoes.vlr_entrada > 0
    then do:
        find first ttparcelas where
             ttparcelas.placod = ttcondicoes.placod and 
             ttparcelas.titpar = acoplanparcel.titpar
             no-error.
        if avail ttparcelas then next.                     
        create ttparcelas.
        ttparcelas.negcod = ttcondicoes.negcod.
        ttparcelas.planom = acoplanos.planom.
        ttparcelas.placod = ttcondicoes.placod.

        /* helio 27042023 - fixo today + 3, cuidando se for final de semana */
        ttparcelas.dtven  = today +  7. /*Helio 27/05/2024 */ 
        if weekday(ttparcelas.dtven) = 7 /* sabado */ 
        then ttparcelas.dtven = ttparcelas.dtven + 2.
        if weekday(ttparcelas.dtven) = 1 /* domingo */ 
        then ttparcelas.dtven = ttparcelas.dtven + 1.
        
        ttparcelas.titpar = 0.
        ttparcelas.vlr_parcela = ttcondicoes.vlr_entrada.
    end.
    run pparcelas (input recid(ttcondicoes)).
     
end.
   
end procedure.




procedure pparcelas.
def input param prec as recid.

def var vtitdtven as date.
def var vmes as int.
def var vdia as int.
def var vano as int.

    find ttcondicoes where recid(ttcondicoes) = prec.
    find acoplanos where acoplanos.negcod = ttcondicoes.negcod and 
                acoplanos.placod =  ttcondicoes.placod no-lock.

    vdia = day(ttcondicoes.dtvenc).
    vmes = month(ttcondicoes.dtvenc).
    vano = year(ttcondicoes.dtvenc).

    for each acoplanparcel of acoplanos no-lock
        by acoplanparcel.titpar.
        vtitdtven = date(vmes, 
                         IF VMES = 2 
                         THEN IF Vdia > 28 
                              THEN 28 
                              ELSE Vdia 
                         ELSE if Vdia > 30 
                              then 30 
                              else vdia, 
                         vano).
        
        find first ttparcelas where
             ttparcelas.placod = ttcondicoes.placod and 
             ttparcelas.titpar = acoplanparcel.titpar
             no-error.
        if avail ttparcelas then next.                     
        create ttparcelas.
        ttparcelas.negcod = ttcondicoes.negcod.
        ttparcelas.planom = acoplanos.planom.
        ttparcelas.placod = ttcondicoes.placod.
        ttparcelas.titpar = acoplanparcel.titpar.
        
        ttparcelas.dtven = vtitdtven.
        
        ttparcelas.perc_parcela = acoplanparcel.perc_parcel.
        ttparcelas.vlr_parcela = round((ttcondicoes.vlr_acordo - ttcondicoes.vlr_entrada) * acoplanparcel.perc_parcel / 100,2). 
        vmes = vmes + 1.
        if vmes > 12 
        then assign vano = vano + 1
                    vmes = 1.

    end.
    


end procedure.



