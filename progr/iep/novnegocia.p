/* helio 23022022 - iepro */

{admcab.i}

def var ptpcampanha as char init "PRO".         /* helio 23022022 - iepro */
def input param par-clicod like clien.clicod .

/**def var vhostname as char.
input through hostname.
import vhostname.
input close.**/


def var p-temacordo as log.
def var vtpcontrato    like contrato.tpcontrato.
def var  vvlr_aberto    as dec.
def var vvlr_vencido as dec.
def var vvlr_vencer as dec.
def var  vvlr_divida   as dec.
def var vvlr_custas    as dec.
def var vvlpresente     as dec.

def var  vvlr_parcela   as dec.
def var  vdt_venc       as date.
def var  vdias_atraso   as int.
def var  vqtd_pagas     as int.
def var  vqtd_parcelas  as int.
def var  vperc_pagas    as dec.
def var vqtd_parcvencida as int.
def var vqtd_parcvencer  as int.
 
 
def var xtime as int.
def var vconta as int.


def var recatu1         as recid.
def var recatu2     as reci.
def var reccont         as int.
def var esqpos1         as int.
def var esqcom1         as char format "x(11)" extent 6
    initial [" acordos"," condicoes "," contratos","  "," "," "].


form
    esqcom1
    with frame f-com1 row 6 no-box no-labels column 1 centered.

assign
    esqpos1  = 1.


{fin/novcamp.i new}

def buffer bttcampanha for ttcampanha.


    form  
        novcampanha.camnom column-label "companha" format "x(26)"
        ttcampanha.qtd_selecionado format ">>>>"    column-label "sel"  
        
        ttcampanha.vlr_selaberto   format    ">>>>>9.99" column-label "aberto"
        ttcampanha.vlr_seldivida   format    ">>>>>9.99" column-label "divida"
        ttcampanha.vlr_selcustas   format    ">>>>9.99" column-label "custas"
        ttcampanha.pagaCustas       
        ttcampanha.vlr_selecionado format    ">>>>>9.99" column-label "total"
        
        with frame frame-a 8 down centered row 8
        no-box.


    if par-clicod = ?
    then update par-clicod label "Conta"
        with frame fcli.
    else do:
        if keyfunction(lastkey) = "END-ERROR"
        then leave.
        disp par-clicod with frame fcli.
    end.    
    find clien where clien.clicod = par-clicod no-lock.
    find neuclien where neuclien.clicod = clien.clicod no-lock no-error.
    /*
    disp clien.clinom no-label format "x(35)"
         neuclien.cpf format "zzzzzzzzzzzzzzz" no-label when avail neuclien  
         clien.dtcad no-label format "99/99/99"
         with frame fcli.
      */




def var ptitle as char.
ptitle =  if ptpcampanha = "PRO"
          then "NEGOCIACOES de PROTESTO - FILIAL " + string(setbcod)
          else "CAMPANHAS PARA FILIAL " + string(setbcod).
          
    disp par-clicod label "Cli" clien.clinom no-label format "x(36)"
         clien.dtcad no-label format "99/99/9999"
         clien.etbcad label "Fil Cad "
            with frame fcli row 3 side-labels width 80 
        title ptitle 1 down.


run cob/ajustanovacordo.p (input clien.clicod, output p-temacordo).

if not p-temacordo
then esqcom1[1] = "".
 
run buscacontratos.



bl-princ:
repeat:


    disp esqcom1 with frame f-com1.
    if recatu1 = ?
    then run leitura (input "pri").
    else find ttcampanha where recid(ttcampanha) = recatu1 no-lock.
    if not available ttcampanha
    then do.
        message "nenhum registro encontrato".
        pause.
        return.
        /*
        if pfiltro = ""
        then do: 
            return.
        end.    
        pfiltro = "".
        recatu1 = ?.
        next.
        */
        
    end.
    clear frame frame-a all no-pause.
    run frame-a.

    recatu1 = recid(ttcampanha).
    color display message esqcom1[esqpos1] with frame f-com1.
    repeat:
        run leitura (input "seg").
        if not available ttcampanha
        then leave.
        if frame-line(frame-a) = frame-down(frame-a)
        then leave.
        down with frame frame-a.
        run frame-a.
    end.
    up frame-line(frame-a) - 1 with frame frame-a.

    repeat with frame frame-a:

        find ttcampanha where recid(ttcampanha) = recatu1 no-lock.
        find novcampanha of ttcampanha no-lock.

        status default "".
        
                        
                     
        def var vx as int.
        def var va as int.
        va = 1.
        do vx = 1 to 6.
            if esqcom1[vx] = ""
            then next.
            esqcom1[va] = esqcom1[vx].
            va = va + 1.  
        end.
        vx = va.
        do vx = va to 6.
            esqcom1[vx] = "".
        end.     
        
        
        
        disp esqcom1 with frame f-com1.
        
        run color-message.
            
        choose field novcampanha.camnom

                go-on(cursor-down cursor-up
                      cursor-left cursor-right
                      page-down   page-up
                      L l
                      tab PF4 F4 ESC return).

                run color-normal.
        hide message no-pause.
                 
        pause 0. 

                                                                
            if keyfunction(lastkey) = "cursor-right"
            then do:
                color display normal esqcom1[esqpos1] with frame f-com1.
                esqpos1 = if esqpos1 = 6 then 6 else esqpos1 + 1.
                color display messages esqcom1[esqpos1] with frame f-com1.
                next.
            end.
            if keyfunction(lastkey) = "cursor-left"
            then do:
                color display normal esqcom1[esqpos1] with frame f-com1.
                esqpos1 = if esqpos1 = 1 then 1 else esqpos1 - 1.
                color display messages esqcom1[esqpos1] with frame f-com1.
                next.
            end.
            if keyfunction(lastkey) = "page-down"
            then do:
                do reccont = 1 to frame-down(frame-a):
                    run leitura (input "down").
                    if not avail ttcampanha
                    then leave.
                    recatu1 = recid(ttcampanha).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "page-up"
            then do:
                do reccont = 1 to frame-down(frame-a):
                    run leitura (input "up").
                    if not avail ttcampanha
                    then leave.
                    recatu1 = recid(ttcampanha).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "cursor-down"
            then do:
                run leitura (input "down").
                if not avail ttcampanha
                then next.
                if frame-line(frame-a) = frame-down(frame-a)
                then scroll with frame frame-a.
                else down with frame frame-a.
            end.
            if keyfunction(lastkey) = "cursor-up"
            then do:
                run leitura (input "up").
                if not avail ttcampanha
                then next.
                if frame-line(frame-a) = 1
                then scroll down with frame frame-a.
                else up with frame frame-a.
            end.
 
        if keyfunction(lastkey) = "end-error"
        then leave bl-princ.
                
                
                /**
            if keyfunction(lastkey) = "L" or
               keyfunction(lastkey) = "l"
            then do:
                hide frame fcab no-pause.
                hide frame f-com1 no-pause.
                hide frame frame-a no-pause.                
                run fin/fqanadoc.p 
                        (   vtitle + "/" + pfiltro,
                            poldfiltro, 
                            pfiltro,
                            ttcampanha.ctmcod,
                            ttcampanha.modcod,
                            ttcampanha.tpcontrato,
                            ttcampanha.etbcod,
                            ttcampanha.cobcod).

                leave.
            end.

                **/
                
        if keyfunction(lastkey) = "return"
        then do:
            
            if esqcom1[esqpos1] = " acordos "
            then do:
                hide frame frame-a no-pause.
                hide frame f-com1 no-pause.  
                run cob/mostraacordo.p(input clien.clicod, input "PENDENTE").
            end.
            if esqcom1[esqpos1] = " contratos "
            then do:
                hide frame frame-a no-pause.
                hide frame f-com1 no-pause.
                recatu2 = recatu1.
                run iep/novnegctr.p (ttcampanha.camcod). 
                run montacampanha.
                recatu1 = recatu2. 
                leave.
                
            end.
            if esqcom1[esqpos1] = " condicoes "
            then do:
                hide frame frame-a no-pause.
                hide frame f-com1 no-pause.
                recatu2 = recatu1.
                run fin/novelecond.p (ttcampanha.camcod, par-clicod). 
                recatu1 = recatu2. 
                leave.
                
            end. 
            if esqcom1[esqpos1] = " parametros "
            then do:
                disp
                    novcampanha with 1 col row 9 centered
                    overlay
                    frame fpar.
                pause.
                hide frame fpar no-pause.    
            end.
            
                
             
        end.
        run frame-a.
        display esqcom1[esqpos1] with frame f-com1.
        recatu1 = recid(ttcampanha).
    end.
    if keyfunction(lastkey) = "end-error"
    then do:
        view frame fc1.
        view frame fc2.
    end.
end.
hide frame f-com1  no-pause.
hide frame frame-a no-pause.

procedure frame-a.
    find novcampanha of ttcampanha no-lock.
    display  
        novcampanha.camnom
        ttcampanha.qtd_selecionado
        ttcampanha.vlr_selecionado
        ttcampanha.vlr_selaberto
        ttcampanha.vlr_selcustas
        ttcampanha.pagaCustas        
        ttcampanha.vlr_seldivida
        with frame frame-a.


end procedure.

procedure color-message.
    color display message
        novcampanha.camnom
        
        ttcampanha.qtd_selecionado
        ttcampanha.vlr_selecionado
        ttcampanha.vlr_selaberto
        ttcampanha.vlr_selcustas
        ttcampanha.vlr_seldivida
        
        with frame frame-a.
end procedure.


procedure color-input.
    color display input
        novcampanha.camnom
        ttcampanha.qtd_selecionado
        ttcampanha.vlr_selecionado
        ttcampanha.vlr_selaberto
        ttcampanha.vlr_selcustas
        ttcampanha.vlr_seldivida
        
        with frame frame-a.
end procedure.


procedure color-normal.
    color display normal
        novcampanha.camnom
        ttcampanha.qtd_selecionado
        ttcampanha.vlr_selecionado
        ttcampanha.vlr_selaberto
        ttcampanha.vlr_selcustas
                ttcampanha.vlr_seldivida

        with frame frame-a.
end procedure.

procedure leitura . 
def input parameter par-tipo as char.
        
if par-tipo = "pri" 
then do:
        find first ttcampanha  where
                no-lock no-error.
end.    
                                             
if par-tipo = "seg" or par-tipo = "down" 
then do:
        find next ttcampanha  where
                no-lock no-error.

end.    
             
if par-tipo = "up" 
then do:
        find prev ttcampanha  where
                no-lock no-error.

end.    
        
end procedure.


procedure buscacontratos.
hide message no-pause.
message color normal "fazendo calculos... aguarde...".

for each ttcontrato.
    delete ttcontrato.
end.

for each titprotesto where titprotesto.operacao = "IEPRO" and
                           titprotesto.clicod   = par-clicod
                           no-lock.
    if titprotesto.ativo = "BAIXADO"
    then next.

    find contrato of titprotesto no-lock.

    vvlr_aberto     = 0.
    vvlr_vencido = 0.
    vvlr_vencer  = 0.
    vvlr_divida     = 0.
    vvlr_custas = 0.
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

        for each novcampanha 
                where
                novcampanha.tpcampanha = ptpcampanha     and /* helio 23022022 - iepro */
                (novcampanha.dtfim = ? or
                 novcampanha.dtfim >= today) and
                 novcampanha.dtini <= today
                no-lock.
                
            find first novestab of novcampanha no-lock no-error.
            if avail novestab
            then do:
                find novestab of novcampanha where 
                        novestab.etbcod = setbcod
                        no-lock no-error.
                if not avail novestab
                then next.        
            end.   
            
            /* helio 23022022 - iepro */
            find first novcampctr of novcampanha no-lock no-error.
            if avail novcampctr
            then do:
                find novcampctr of novcampanha where 
                        novcampctr.clicod = contrato.clicod and
                        novcampctr.contnum = 0
                        no-lock no-error.
                if avail novcampctr
                then.
                else do:
                    find novcampctr of novcampanha where 
                            novcampctr.clicod = contrato.clicod and
                            novcampctr.contnum = contrato.contnum
                            no-lock no-error.
                    if avail novcampctr
                    then.
                    else next.
                end.
            end.   

            vvlr_custas = 0.

                if novcampanha.pagaCustas
                then do:
                    vvlr_custas = titprotesto.vlCustas.
                end.      
                    
                       
                      
                      
            do:   
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
                    
            do:
                create ttcontrato.
                ttcontrato.marca       = yes.
                ttcontrato.contnum     = contrato.contnum.
                ttcontrato.camcod      = novcampanha.camcod.
                ttcontrato.tpcontrato  = vtpcontrato.
                ttcontrato.vlr_aberto  = vvlr_aberto.
                ttcontrato.vlr_divida  = vvlr_divida.
                ttcontrato.vlr_custas  = vvlr_custas. 
                ttcontrato.vlr_vencido = vvlr_vencido.
                ttcontrato.vlr_vencer  = vvlr_vencer.
                                
                ttcontrato.vlr_parcela = vvlr_parcela.
                ttcontrato.dt_venc     = vdt_venc.  
                ttcontrato.dias_atraso = vdias_atraso. 
                ttcontrato.qtd_parcelas = vqtd_parcelas.
                ttcontrato.qtd_pagas   = vqtd_pagas.
                ttcontrato.perc_pagas  = vperc_pagas.
                ttcontrato.pagaCustas  = novcampanha.pagaCustas.                
                ttcontrato.trectitprotesto = recid(titprotesto).
            end.
            
        end.                                     
                       
        
    end.
            
end.
find first ttcontrato no-error.
if avail ttcontrato
then do:
    
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
            if novcampanha.parcvencidaqtd = 0 or
               vqtd_parcvencida <= novcampanha.parcvencidaqtd 
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
            if novcampanha.parcvencidaso = no and (novcampanha.parcvencerqtd = 0 or vqtd_parcvencer <= novcampanha.parcvencerqtd) 
            then do: 
                vvlr_aberto = vvlr_aberto + vvlpresente.
                vvlr_divida = vvlr_divida + vvlpresente.
            end.    
        end.
    end.                

end procedure.




procedure montacampanha.

for each ttcampanha.
    delete ttcampanha.
end.    
for each ttcontrato.
        find contrato where contrato.contnum = ttcontrato.contnum no-lock. 
                find first ttcampanha where
                        ttcampanha.camcod = ttcontrato.camcod
                        no-error.
                if not avail ttcampanha        
                then do:
                    create ttcampanha.
                    ttcampanha.camcod  = ttcontrato.camcod.
                    ttcampanha.dt_venc = ttcontrato.dt_venc.
                end.
                ttcampanha.vlr_aberto  = ttcampanha.vlr_aberto + ttcontrato.vlr_aberto.
                ttcampanha.vlr_divida  = ttcampanha.vlr_divida + ttcontrato.vlr_divida.
                ttcampanha.qtd         = ttcampanha.qtd + 1.
                ttcampanha.pagacustas  = ttcontrato.pagacustas.
                if ttcontrato.marca
                then do:
                    ttcampanha.vlr_selecionado = ttcampanha.vlr_selecionado + ttcontrato.vlr_divida + ttcontrato.vlr_custas. 
                    ttcampanha.vlr_seldivida   = ttcampanha.vlr_seldivida   + ttcontrato.vlr_divida. 
                    ttcampanha.vlr_selcustas   = ttcampanha.vlr_selcustas   + ttcontrato.vlr_custas. 
                    
                    ttcampanha.vlr_selaberto   = ttcampanha.vlr_selaberto   + ttcontrato.vlr_aberto. 
                    
                    ttcampanha.qtd_selecionado = ttcampanha.qtd_selecionado + 1.
                end.    
                
                ttcampanha.dt_venc = min(ttcampanha.dt_venc,ttcontrato.dt_venc).
                ttcampanha.dias_atraso = max(ttcampanha.dias_atraso,ttcontrato.dias_atraso).
                
end.
end procedure.





