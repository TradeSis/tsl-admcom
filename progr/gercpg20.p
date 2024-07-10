{admcab.i}                                                

def var vpromo-comp as log.
def var vcadeira-405249 as log.
def var vcadeira-405249q as int.
def var vqtdcomp as int.
def var valorparcela   like plani.platot.
def var plano-especial as log.
def var vv like plani.platot.
def var vcat like produ.catcod.
def var vk as log.
def var v-down as log.
def var wpar            as integer format ">9" label "Num.Parcelas".
def var wcon            as integer format ">9" label "Parc.".
def var wval            as decimal format ">>>,>>>,>>9.99".
def var rsp             as logical format "Sim/Nao" initial yes.
def var vtprcod         like comis.tprcod.
def var vreccont        as recid.
def var vlrtot          like contrato.vltotal.
def var vgera            as int.
def var vok             as log.
def var wnp             as int.
def var vval as dec.
def var vval1 as dec decimals 1.
def var vsal as dec.
def var vdtentra        like titulo.titdtven label "Data da Entrada".
def var vdtven          like titulo.titdtven.
def var vano            as int.
def var vmes            as int.
def var vday            as   int format "99".
def var i               as   int .
def var cont            as   int.
def var vnotas          as char format "x(60)" label "Nota(s) Fiscal(is)".
def var vcrecod         like plani.crecod.
def var vvencod         like plani.vencod.
def var vvaltit         like titulo.titvlcob.
def var vdata           like contrato.dtinicial.
def var vetbcod         like estab.etbcod .
def var vvltotal        like contrato.vltotal.
def var vpladat         like contrato.dtinicial.
def var vlfrete         like contrato.vltotal label "Valor Frete".
def var vlfinan         like contrato.vltotal label "Vlr Financiamento".
def var vorient         like contrato.vlentra.
def var dd as i.
def var mm as i.
def var datafim like plani.pladat.

def workfile wf-titulo   like titulo.
/***
def shared workfile wf-movim
    field wrec    as   recid
    field movqtm like movim.movqtm
    field lipcor like liped.lipcor
    field movalicms like movim.movalicms
    field desconto like movim.movdes
    field movpc like movim.movpc
    field precoori like movim.movpc
    field vencod  like func.funcod.
***/    
def input  parameter vfincod    like finan.fincod.
def input  parameter wfplatot   like plani.platot.
def input  parameter wfvlserv   like plani.platot.
def input  parameter wfdescprod like plani.platot.
def output parameter vliqui     as dec.
def output parameter ventra     as dec.
def output parameter vparce     as dec.
def var wfvlentra  like contrato.vlentra.
def var wfvltotal  like contrato.vltotal.
def var vpassa     as log.

vvltotal = 0.
mm = month(today) + 1.
datafim = date(1,mm,year(today)) - 1.
dd = day(datafim).

find finan where finan.fincod = vfincod no-lock.
def var parametro-in as char.
def var parametro-out as char .

def var p-dtentra as date.
def var p-dtparcela as date.
/*
if search("/usr/admcom/progr/promo-venda.p") <> ?
then do:
            parametro-in = "GERA-CPG=S|PLANO="
                    + string(finan.fincod) + "|".
            run promo-venda.p(input parametro-in ,
                              output parametro-out).
            if acha("DATA-ENTRADA",parametro-out) <> ?
            then p-dtentra = date(acha("DATA-ENTRADA",parametro-out)).
end.
message parametro-out. pause.
**/ 

plano-especial = no.
valorparcela   = 0.

def var vcadeira-1383 as log init no.
def var vcadeira-402820 as log init no.


/*def var vcadeira-402820 as log init no.*/

def var vqtdcad as int.

vpromo-comp = no.

/*
if today = 12/24/2007
then do:
    if finan.fincod = 21 or
       finan.fincod = 24 or
       finan.fincod = 88
    then do:
        for each wf-movim:
            find produ where recid(produ) = wf-movim.wrec no-lock no-error.
            if produ.procod = 406723 or
               produ.procod = 406724
            then do:
                wf-movim.movpc = 2475.
                vpromo-comp = yes.
            end.                
        end.
    end.
end.
**/
vcadeira-405249  = no.
vcadeira-405249q = 0.
/*
if today <= 06/30/2008
then do:
if finan.fincod = 42 or
   finan.fincod = 43 or
   finan.fincod = 87
then do:
    for each wf-movim:
        find produ where recid(produ) = wf-movim.wrec no-lock no-error.
        if produ.procod = 405248
        then do:
            vcadeira-405249 = yes.  
            vcadeira-405249q = vcadeira-405249q + wf-movim.movqtm.
        end.
    end.
end.    
end. 
if  finan.fincod = 42   and 
   (setbcod      = 81   or setbcod = 82 or setbcod = 42) and
   (today >= 09/19/2007 and
    today <= 10/20/2007)
then do:
    vcadeira-405249  = no.
    vcadeira-405249q = 0.

    for each wf-movim:

        find produ where recid(produ) = wf-movim.wrec no-lock no-error.
        
        if produ.procod = 405248
        then do:
            vcadeira-405249 = yes.
            vcadeira-405249q = vcadeira-405249q + wf-movim.movqtm.
        end.
    end.
end.



for each wf-movim:
    find produ where recid(produ) = wf-movim.wrec no-lock no-error.
    if not avail produ
    then next.
    
    find estoq where estoq.procod = produ.procod and
                     estoq.etbcod = setbcod no-lock no-error.
    if not avail estoq
    then next.
    
    if estoq.estbaldat <> ?
    then do:
        if estoq.estmin > 0            and
           estoq.tabcod = finan.fincod and
           estprodat <> ?              and
           estbaldat <= today          and
           estprodat >= today          and
           wfvlserv   = 0       and
           wfdescprod = 0
        then assign plano-especial = yes
                    valorparcela   = valorparcela + 
                                     (estoq.estmin * wf-movim.movqtm).   
        else do:
            plano-especial = no.
            valorparcela   = 0.
            leave.
        end.
    end.
    else do: 
        if estoq.estmin > 0            and
           estoq.tabcod = finan.fincod and
           estprodat <> ?              and
           estprodat >= today          and
           wfvlserv   = 0              and
           wfdescprod = 0
        then assign plano-especial = yes
                    valorparcela   = valorparcela + 
                                     (estoq.estmin * wf-movim.movqtm).   
        else do:
            plano-especial = no.
            valorparcela   = 0.
            leave.
        end. 
    end.   
       
end.
***/
assign vvltotal = vvltotal + wfplatot - wfvlserv - wfdescprod.

l0:
repeat:
    assign wpar = 0.
    do with frame f1:
        do on error undo with 1 column width 39 frame f2 title " Valores "
                                color white/cyan overlay row 6:

            
            for each wf-titulo:
                delete wf-titulo.
            end.

            wfvltotal = wfplatot - wfvlserv - wfdescprod.
            wnp = finan.finnpc + if finan.finent = yes
                                 then 1
                                 else 0.
            vval = 0.
            vval1 = 0.
            vsal = 0.

            vval = (wfvltotal * finan.finfat).
            
            if finan.fincod <> 94 and
               finan.fincod <> 89 and 
               finan.fincod <> 96 and
               finan.fincod <> 95 and
               finan.fincod <> 92 
            then do:
                if (finan.fincod < 50 or 
                    finan.fincod >= 90 or
                    finan.fincod = 75  or
                    finan.fincod = 85  or
                    
                    finan.fincod = 81 or
                    finan.fincod = 82 or
                    finan.fincod = 83 or
                    finan.fincod = 84 or
                    finan.fincod = 87 or
                    finan.fincod = 88 or
                    finan.fincod = 86 or
                    finan.fincod = 76) and
                    finan.fincod <> 40 and
                    finan.fincod <> 97 and
                    finan.fincod <> 94
                    
                then do:
                
                  if (finan.fincod    = 42 or
                      finan.fincod    = 43 or
                      finan.fincod    = 87) and
                     vcadeira-405249 = yes
                  then do:
                              
                    vval1 = vval.
                    if vval1 > vval
                    then vval1 = vval1 - 0.10.
                    vlfinan = vvltotal.

                  end.
                  else do:
                  
                    vsal = vval - int(vval).
                    if vsal > 0
                    then vval = vval + (0.50 - vsal).
                    if vsal < 0 and vsal <> -0.50
                    then vval = ((vval - int(vval)) * -1) + vval.
                    vlfinan = vval * wnp.

                  end.
                end.
                else do:
                    vval1 = vval.
                    if vval1 > vval
                    then vval1 = vval1 - 0.10.
                    
                    vlfinan = vvltotal.
                
                
                end.
                
                if finan.fincod = 38 or
                   finan.fincod = 39 or
                   finan.fincod = 17 or
                   finan.fincod = 90 or
                   finan.fincod = 91 or
                   finan.fincod = 36 or
                   /*finan.fincod = 43 or*/
                   finan.fincod = 15 or
                   finan.fincod = 35 or
                   /*finan.fincod = 86 or*/
                   
                   finan.fincod = 62 or
                   
                   finan.fincod = 14
                then do:
                

                    vval = (vvltotal * finan.finfat).
                    
                    
                    vv = ( (int(vval) - vval ) ) - 
                            round(( (int(vval) - (vval)) ),1).
                            
                    if vv < 0
                    then vv = 0.10 - (vv * -1). 
                    
                    if finan.fincod = 17
                    then.
                    else vval = vval + vv.
                    
                    
                    vlfinan = vval * wnp.
                    
                end.   
            
            end.
            else do:

                vv = ( (int(vvltotal * finan.finfat) -
                       (vvltotal * finan.finfat)) )  -
                      round(( (int(vvltotal * finan.finfat) -
                            (vvltotal * finan.finfat)) ),1).

                if vv < 0
                then vv = 0.10 - (vv * -1).

                vval = (vvltotal * finan.finfat) + vv.
                vlfinan = vval * wnp.

            end.
            
            if finan.fincod = 77
            then assign 
                 wfvltotal = ( (wfplatot   - 
                                wfdescprod - 
                                wfvlserv) * 0.35) +
                               ( (wfplatot   -  wfdescprod -  wfvlserv)  *  
                                 finan.finnpc * finan.finfat)
                 vlfinan = wfvltotal - wfvlentra.                      
            if p-dtentra = ?
            then  vdtentra = today.
            else vdtentra = p-dtentra.
            
            if finan.finent = yes and plano-especial = no
            then do:
                if (finan.fincod < 50 or 
                    finan.fincod >= 90 or
                    finan.fincod = 75  or
                    finan.fincod = 89  or 
                    finan.fincod = 85  or
                    finan.fincod = 81 or
                    finan.fincod = 82 or
                    finan.fincod = 83 or
                    finan.fincod = 84 or
                    finan.fincod = 87 or
                    finan.fincod = 88 or
                    finan.fincod = 86 or
                    finan.fincod <> 40 and
                    finan.fincod <> 97)
                then do:
                    assign wfvlentra = vval.
                end.
                else do:
                    assign wfvlentra = vvltotal - (vval1 * finan.finnpc).
                end.
             
                if finan.fincod = 77
                then wfvlentra = ( ( wfplatot   - 
                                     wfvlserv   -
                                     wfdescprod) * 0.35).
                                   
                
                vorient = wfvlentra.
                /****
                if finan.fincod <> 77 
                then do:
                    
                    if wfvlentra <= 0
                    then do:
                        message "Entrada Invalida(1)".
                        undo, retry.
                    end.
                end.
                ***/
                vdtentra = today.
                if day(vdtentra) >= 20 and
                   day(vdtentra) <= 31
                then do:
                    vdtentra = today.
                    /* update vdtentra. */
                    if vdtentra > (today + 10) or vdtentra < today
                    then do:
                        message "Data da Entrada Invalida(1)". pause.
                        undo,retry.
                    end.
                    if vdtentra <> today
                    then do:
                        vok = yes.
                        run senha.p(output vok).
                        if vok = no
                        then undo,retry.
                    end.
                end.
                else do:
                    vdtentra = today.
                    /* update vdtentra. */

                    if vdtentra > (today + 5) or vdtentra < today 
                    then do:
                        message "Data da Entrada Invalida(2)". pause.
                        undo,retry.
                    end.
                end.

            end.
            else wfvlentra = 0.
            
            if plano-especial and finan.finent = yes
            then wfvlentra = valorparcela.

            
            vval = 0.
            vval1 = 0.
            vsal = 0.

            
            vval = (vlfinan - wfvlentra) / finan.finnpc.

                         
            if finan.fincod <> 94 and
               finan.fincod <> 89 and /*
               finan.fincod <> 88 and*/
               finan.fincod <> 96 and
               finan.fincod <> 95 and 
               finan.fincod <> 92
            then do:
                if (finan.fincod < 50 or 
                    finan.fincod >= 90 or
                    finan.fincod = 75  or
                    finan.fincod = 85  or
                    finan.fincod = 81 or
                    finan.fincod = 82 or
                    finan.fincod = 83 or
                    finan.fincod = 84 or
                    finan.fincod = 87 or
                    finan.fincod = 88 or
                    finan.fincod = 86 or
                    finan.fincod = 76) and
                    finan.fincod <> 40 and
                    finan.fincod <> 97 and
                    finan.fincod <> 94
                then do:
                  if (finan.fincod    = 42 or
                      finan.fincod    = 43 or
                      finan.fincod    = 87) and
                     vcadeira-405249 = yes
                  then do:
                              
                    vval1 = vval.
                    if vval1 > vval
                    then vval1 = vval1 - 0.10.
                    vlfinan = vvltotal.

                  end.
                  else do:
                    
                    vsal = vval - int(vval).
                    if vsal > 0
                    then vval = vval + (0.50 - vsal).
                    if vsal < 0 and vsal <> -0.50
                    then vval = ((vval - int(vval)) * -1) + vval.
                  end.  
                  
                end.
                else do:
                    vval1 = vval.
                    if vval1 > vval
                    then vval1 = vval1 - 0.10.
                    vval = vval1.
                end.
                
                if finan.fincod = 38 or
                   finan.fincod = 39 or
                   finan.fincod = 17 or
                   finan.fincod = 90 or
                   finan.fincod = 91 or
                   finan.fincod = 36 or
                   /*finan.fincod = 43 or*/
                   finan.fincod = 86 or
                   finan.fincod = 15 or
                   finan.fincod = 35 or  
                   
                   finan.fincod = 62 or

                   
                   finan.fincod = 14
                then do:

                    vval = (vvltotal * finan.finfat).
                    
                    vv = ( (int(vval) - vval ) ) - 
                            round(( (int(vval) - (vval)) ),1).
                            
                    if vv < 0  
                    then vv = 0.10 - (vv * -1).
                    
                    if finan.fincod = 17
                    then.
                    else vval = vval + vv.
                    
                    vlfinan = vval * wnp.

                end.   
                
            end.

             
            
            
            if (finan.fincod < 50 or 
                finan.fincod >= 90 or
                finan.fincod = 75  or
                finan.fincod = 89  or 
                finan.fincod = 85  or
                
                finan.fincod = 81 or
                finan.fincod = 82 or
                finan.fincod = 83 or
                finan.fincod = 84 or
                finan.fincod = 87 or
                finan.fincod = 88 or
                finan.fincod = 86 or
                                      
                finan.fincod = 62 or
                
                finan.fincod = 76) and
                finan.fincod <> 40 and
                finan.fincod <> 97
            then do:

                wfvltotal = wfvlentra + (vval * finan.finnpc).
                
            end.
            else do:
                wfvltotal = vvltotal.
            end.

            vlfinan = wfvltotal - wfvlentra.
            
            
            if finan.fincod = 77
            then assign 
                 wfvltotal = ( (wfplatot   - 
                                wfdescprod - 
                                wfvlserv) * 0.35) +
                               ( (wfplatot - wfdescprod - wfvlserv)  *
                                  finan.finnpc * finan.finfat)
                 vlfinan = wfvltotal - wfvlentra.                         

            if plano-especial
            then vlfinan = finan.finnpc * valorparcela.

            if plano-especial = no
            then vlfrete = 0.
            
            
            /*if vcadeira-402820 = yes 
            then do:
            
                wfvlentra = (1.49 * vqtdcad).
                vlfinan = finan.finnpc * (1.49 * vqtdcad).

            end.*/

            if today = 12/24/2007
            then do:
                if finan.fincod = 21 or 
                   finan.fincod = 88
                then do:
                    if vpromo-comp
                    then do:
                        wfvlentra = 0. 
                        vlfinan   = 25 * 99.
                    end.                        
                end.
                
                if finan.fincod = 24
                then do: 
                    if vpromo-comp
                    then do:
                        wfvlentra = 99. 
                        vlfinan   = 24 * 99.
                    end.                        
                end.

            end.
            
            if finan.fincod = 38 or finan.fincod = 39
            then do:
                if setbcod = 76 or setbcod = 77 or setbcod = 78
                then do:
                
                    if vcadeira-1383 = yes
                    then do:
                        wfvlentra = (1.29 * vqtdcad).
                        vlfinan = finan.finnpc * (1.29 * vqtdcad).
                    end.
                    else
                    if vcadeira-402820 = yes
                    then do:
                        wfvlentra = (1.49 * vqtdcad).
                        vlfinan = finan.finnpc * (1.49 * vqtdcad).
                    end.

                end.
                else do:
                
                    if vcadeira-1383 = yes
                    then do:
                        wfvlentra = (1.99 * vqtdcad).
                        vlfinan = finan.finnpc * (1.99 * vqtdcad).
                    end.
                
                end.

            end.
            if finan.fincod = 42 or
               finan.fincod = 43 or
               finan.fincod = 87
            then do:
                if vcadeira-405249 = yes 
                then do:
            
                    wfvlentra = (0.90 * vcadeira-405249q ).
                    vlfinan = finan.finnpc * (0.90 * vcadeira-405249q ).

                end.
            end.
            
            vliqui = vlfinan + wfvlentra.
            
            wpar = finan.finnpc.

            if finan.fincod = 1
            then do:
                wfvlentra = vvltotal - vlfinan.
            end.
            /****************************************************************
             VENDA COM ENTRADA
            ****************************************************************/
            if wfvlentra > 0
            then do:
                create wf-titulo.
                assign wf-titulo.empcod   = wempre.empcod
                       wf-titulo.modcod   = "CRE"
                       wf-titulo.cxacod   = scxacod
                       wf-titulo.clifor   = 1
                       wf-titulo.titnum   = "1"
                       wf-titulo.titpar   = (if vdtentra = today
                                          then 0
                                          else 1)
                       wf-titulo.titsit   = "LIB"
                       wf-titulo.titnat   = no
                       wf-titulo.etbcod   = setbcod
                       wf-titulo.titdtemi = today
                       wf-titulo.titdtven = vdtentra /*wf-titulo.titdtemi*/
                       wf-titulo.titvlcob = wfvlentra + vlfrete
                       wf-titulo.cobcod = 2
                       wf-titulo.datexp = today
                       ventra           = wfvlentra.
                    
            end.
        end.
    end.
    assign wcon = (if vdtentra = today
                   then 0
                   else 1)
    wval = 0
    vday = day(vdtentra).
    
    
    assign vmes = month (vdtentra) + 1.
    assign vano = year (vdtentra).
    if  vmes > 12 then
        assign vano = vano + 1
               vmes = vmes - 12. 

    repeat on endkey undo l0,retry l0:

        clear frame f3 all.

        assign wcon = wcon + 1.


        find first wf-titulo
            where wf-titulo.empcod = 19                          and
                  wf-titulo.titnat = no                          and
                  wf-titulo.modcod = "cre"                       and
                  wf-titulo.clifor = 1                           and
                  wf-titulo.etbcod = setbcod                     and
                  wf-titulo.titnum = "1"                         and
                  wf-titulo.titpar = wcon no-error.
        if avail wf-titulo
        then leave.
        create wf-titulo.
        assign wf-titulo.empcod = wempre.empcod
               wf-titulo.modcod = "CRE"
               wf-titulo.cxacod = scxacod
               wf-titulo.cliFOR = 1
               wf-titulo.titnum = "1"
               wf-titulo.titpar = wcon
               wf-titulo.titnat = no
               wf-titulo.etbcod = setbcod
               wf-titulo.titdtemi = today
               wf-titulo.titdtven = date(vmes,
                                       IF  VMES = 2 THEN
                                           IF  VDAY > 28 THEN
                                               28
                                            ELSE VDAY
                                       ELSE
                                            if vday = 31 then
                                                30
                                            else VDAY,
                                       vano)
               wf-titulo.cobcod = 2
               wf-titulo.titsit  = "LIB"
               wf-titulo.datexp  = today.


        vdtven = wf-titulo.titdtven.

        if day(today) >= 20 and
           day(today) <= 31
        then do on error undo, retry:
            if wf-titulo.titdtven > (vdtven + 10) or
               wf-titulo.titdtven < today
            then do:
                message "Data de Vencimento Invalida(1)". pause.
                undo, return.
            end.
            if wf-titulo.titdtven <> vdtven
            then do:
                vok = yes.
                run senha.p(output vok).
                if vok = no
                then undo,retry.
            end.
            /**
            if finan.fincod = 59 and
               wf-titulo.titdtven > 02/05/2003
            then do:
                message "Data de vencimento invalida(2)".
                pause.
                undo, return.
            end.
            **/       
            if wf-titulo.titdtven > today + 60
            then do:
                if today >= 03/28/2003 and
                   today <= 04/30/2003 and
                   finan.fincod = 17
                then.
                else do:
                    if finan.fincod = 59
                    then.
                    else do:
                        if today >= 08/29/2003 and
                           today <= 09/30/2003 and
                           (finan.fincod = 22  or
                            finan.fincod = 94  or
                            finan.fincod = 60  or
                            finan.fincod = 97)
                        then.
                        else do:
                            message "Data de vencimento invalida(3)".
                            pause.
                            undo, return.
                        end.
                    end.    
                end.
            end.
            /*
            if finan.fincod = 59 and
               wf-titulo.titdtven > 02/05/2003
            then do:
                message "Data de vencimento invalida(4)".
                pause.
                undo, return.
            end.
            */             
            
        end.
        else do on error undo, retry:
            wf-titulo.titdtven - today.
            if wf-titulo.titdtven > (vdtven + 5) or
               wf-titulo.titdtven < today
            then do:
                message "Data da Entrada Invalida(3)". pause.
                undo,retry.
            end.
            
            if finan.fincod = 59 and
               wf-titulo.titdtven > 02/05/2003
            then do:
                message "Data de vencimento invalida(5)".
                pause.
                undo, return.
            end.
            
            if wf-titulo.titdtven > today + 60
            then do:
                if today >= 03/28/2003 and
                   today <= 04/30/2003 and
                   finan.fincod = 17
                then.
                else do:
                    if finan.fincod = 59
                    then.
                    else do:
                        if today >= 08/29/2003 and
                           today <= 09/30/2003 and
                           (finan.fincod = 22  or
                            finan.fincod = 94  or
                            finan.fincod = 60  or
                            finan.fincod = 97)
                        then.
                        else do:
                            message "Data de vencimento invalida(6)".
                            pause.
                            undo, return.
                        end.    
                    end.    
                end.
                
                if finan.fincod = 59 and
                   wf-titulo.titdtven > 02/05/2003
                then do:
                    message "Data de vencimento invalida(7)".
                    pause.
                    undo, return.
                end.
             
            
            end.
            
        end.

        if wf-titulo.titdtven < vdtentra
        then do:
            message "Data de vencimento invalida(8)".
            undo, return.
        end.
        if finan.finent = yes or
           ((finan.fincod < 50  or 
             finan.fincod >= 90 or
             finan.fincod = 75  or
             finan.fincod = 89  or 
             finan.fincod = 85  or
             
             finan.fincod = 81 or
             finan.fincod = 82 or
             finan.fincod = 83 or
             finan.fincod = 84 or
             finan.fincod = 87 or
             finan.fincod = 88 or
             finan.fincod = 86 or
             
             finan.fincod = 62 or
             
             finan.fincod = 76) and
             finan.fincod <> 40 and
             finan.fincod <> 97)
        then do:
            wf-titulo.titvlcob = vlfinan / wpar.
        end.
        else do:
            wf-titulo.titvlcob = (vvltotal - (vval1 * finan.finnpc)) + vval1 .
        end.


        vparce = wf-titulo.titvlcob.
        
        vmes = month(wf-titulo.titdtven) + 1.
        vano = year (wf-titulo.titdtven).
        if  vmes > 12 then
            assign vano = vano + 1
                   vmes = vmes - 12.

        if wfvlentra  = 0
        then vlrtot = (wfvltotal - vlfrete).
        else vlrtot = (wfvltotal - wfvlentra - vlfrete).

        vday = day(wf-titulo.titdtven).
        view frame f3.
        v-down = no.
        do i = wcon + 1 to (if vdtentra = today
                             then wpar
                             else wpar + 1).

            assign wcon = 0
                   vmes = month(wf-titulo.titdtven) + 1
                   vano = year (wf-titulo.titdtven).

            if  vmes > 12 then
                assign vano = vano + 1
                       vmes = vmes - 12.
            do on error undo:
                create wf-titulo.
                assign
                    wf-titulo.empcod = wempre.empcod
                    wf-titulo.modcod = "CRE"
                    wf-titulo.cxacod = scxacod
                    wf-titulo.cliFOR = 1
                    wf-titulo.titnum = "1"
                    wf-titulo.titpar = i
                    wf-titulo.titnat = no
                    wf-titulo.etbcod = setbcod
                    wf-titulo.titdtemi = today
                    wf-titulo.titdtven = date(vmes,
                                       IF VMES = 2
                                       THEN IF VDAY > 28
                                            THEN 28
                                            ELSE VDAY
                                        ELSE if VDAY > 30
                                             then 30
                                             else vday,
                                       vano).


                    /*****/
                    if finan.finent = yes or
                       ((finan.fincod < 50  or 
                         finan.fincod >= 90 or
                         finan.fincod = 75  or
                         finan.fincod = 89  or 
                         finan.fincod = 85  or
                         
                         finan.fincod = 81 or
                         finan.fincod = 82 or
                         finan.fincod = 83 or
                         finan.fincod = 84 or
                         finan.fincod = 87 or
                         finan.fincod = 88 or
                         finan.fincod = 86 or
                         
                         finan.fincod = 62 or
                         
                         finan.fincod = 76) and
                         finan.fincod <> 40 and
                         finan.fincod <> 97)
                    then do:
                        wf-titulo.titvlcob = vlfinan / wpar.
                    end.

                    else
                    if finan.finent <> yes
                    then do:
                        wf-titulo.titvlcob = (vvltotal -
                                           (vval1 * finan.finnpc)).
                        wf-titulo.titvlcob = ((wfvltotal - wfvlentra) / wpar) -
                                          (wf-titulo.titvlcob / finan.finnpc).
                    end.
                    else wf-titulo.titvlcob = (wfvltotal - wfvlentra) / wpar.

                    assign
                    wf-titulo.cobcod = 2
                    wf-titulo.titsit = "LIB"
                    wf-titulo.datexp = today.

            end.
            down with frame f3.
            
            vparce = wf-titulo.titvlcob.
            down with frame f3.
            assign wval = wval + wf-titulo.titvlcob.
                   vmes = vmes + 1.
                   if  vmes > 12 then
                        assign vano = vano + 1
                               vmes = vmes - 12.
        end.

        if wcon = (if vdtentra = today
                   then wpar
                   else wpar + 1)
        then leave.
    end.
    cont = 0.
    leave.
end.

hide frame f1 no-pause.
hide frame f2 no-pause.
hide frame f3 no-pause.                
