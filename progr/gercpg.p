/***************************************************************************
**  Programa        :fecconb4.p
**  Objetivo        : Vendas para o 13. Salario
**  Ultima Alteracao: 04/11/98
***************************************************************************/

{admcab-batch.i}

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
def var vgera           like geranum.contnum.
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

def shared workfile wf-movim
    field wrec    as   recid
    field movqtm like movim.movqtm
    field movalicms like movim.movalicms
    field desconto like movim.movdes
    field movpc like movim.movpc
    field precoori like movim.movpc
    field vencod  like func.funcod.

def input parameter wfplatot   like plani.platot.
def input parameter wfvlserv   like plani.platot.
def input parameter wfdescprod like plani.platot.
def var wfvlentra  like contrato.vlentra.
def var wfvltotal  like contrato.vltotal.
def var vfincod    like finan.fincod.
def var vpassa     as log.



vvltotal = 0.
mm = month(today) + 1.
datafim = date(1,mm,year(today)) - 1.
dd = day(datafim).
repeat:
update vfincod label "Plano " with frame f1 row 4
    side-label width 80.
    

find finan where finan.fincod = vfincod no-lock.

display finan.finnom no-label with frame f1.

vpassa = yes.  
for each wf-movim: 
    
    find produ where recid(produ) = wf-movim.wrec no-lock.

    if (produ.catcod = 31 or 
        produ.catcod = 35) and 
       (finan.fincod <> 72 and 
        finan.fincod <> 73 and 
        finan.fincod <> 74 and 
        finan.fincod <> 75 and 
        finan.fincod <> 76 and
        finan.fincod <> 77 and 
        finan.fincod <> 97 and 
        finan.fincod <> 59)
    then do: 
        if finan.fincod >= 50
        then vpassa = no. 
    end. 
    if (produ.catcod = 41 or 
        produ.catcod = 45) and 
       (finan.fincod <> 72 and
        finan.fincod <> 73 and 
        finan.fincod <> 74 and 
        finan.fincod <> 75 and
        finan.fincod <> 97)
    then do: 
        if finan.fincod < 50 or
           finan.fincod = 77 or
           finan.fincod = 76
        then vpassa = no. 
    end.
    if finan.fincod = 14 
    then do: 
        if produ.procod <> 401796 and
           produ.procod <> 401380 and 
           produ.procod <> 401610 and 
           produ.procod <> 401446 and 
           produ.procod <> 400388 and 
           produ.procod <> 401408 and 
           produ.procod <> 400109 and 
           produ.procod <> 401711 and 
           produ.procod <> 400077 and 
           produ.procod <> 401720 and
           produ.procod <> 401664 and 
           produ.procod <> 400092 and
           produ.procod <> 400388 and
           produ.procod <> 401918
        then vpassa = no.
    end.
    if finan.fincod = 59 
    then do: 
        if produ.procod <> 401515 and
           produ.procod <> 402179 and 
           produ.procod <> 402409 and 
           produ.procod <> 402069
        then vpassa = no.    
    end.
end. 
if vpassa = no 
then do: 
    bell.
    message "Plano Invalido". 
    undo, retry. 
end.
 



plano-especial = no.
valorparcela   = 0.
for each wf-movim:
    find produ where recid(produ) = wf-movim.wrec no-lock no-error.
    if not avail produ
    then next.
    

    find estoq where estoq.procod = produ.procod and
                     estoq.etbcod = setbcod no-lock no-error.
    if not avail estoq
    then next.
    
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
assign vvltotal = vvltotal + wfplatot - wfvlserv - wfdescprod.

l0:
repeat:
    assign wpar = 0.
    do with frame f1:
        pause 0.
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
            if finan.fincod <> 41
            then do:
                if (finan.fincod < 50  or 
                    finan.fincod >= 90 or
                    finan.fincod = 75  or
                    finan.fincod = 86 or
                    finan.fincod = 76) and
                    finan.fincod <> 40 and
                    finan.fincod <> 14 and
                    finan.fincod <> 92 and 
                    finan.fincod <> 96 and
                    finan.fincod <> 97
                then do:
                    vsal = vval - int(vval).
                    if vsal > 0
                    then vval = vval + (0.50 - vsal).
                    if vsal < 0 and vsal <> -0.50
                    then vval = ((vval - int(vval)) * -1) + vval.
                    vlfinan = vval * wnp.
                end.
                else do:
                    vval1 = vval.
                    if vval1 > vval
                    then vval1 = vval1 - 0.10.
                    vlfinan = vvltotal.
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
                               ( (wfplatot   -  wfdescprod -  wfvlserv)  *                                   finan.finnpc * finan.finfat)
                 vlfinan = wfvltotal - wfvlentra.                      
            
            
            display vlfinan skip.

            vdtentra = today.
            
            if finan.finent = yes and plano-especial = no
            then do:
                if (finan.fincod < 50  or 
                    finan.fincod >= 90 or
                    finan.fincod = 75  or
                    finan.fincod = 76) and
                    finan.fincod <> 40 and
                    finan.fincod <> 92 and finan.fincod <> 96 and
                    finan.fincod <> 14 and
                    finan.fincod <> 97
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

                if finan.fincod <> 77 
                then do:
                    update wfvlentra skip.
                    if wfvlentra <= 0
                    then do:
                        message "Entrada Invalida".
                        undo, retry.
                    end.
                end.
                else display wfvlentra.
                
                vdtentra = today.
                if day(vdtentra) >= 20 and
                   day(vdtentra) <= 31
                then do:
                    update vdtentra.
                    if vdtentra > (today + 10) or vdtentra < today
                    then do:
                        message "Data da Entrada Invalida". pause.
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
                    update vdtentra.

                    if vdtentra > (today + 5) or vdtentra < today 
                    then do:
                        message "Data da Entrada Invalida". pause.
                        undo,retry.
                    end.
                end.

            end.
            else wfvlentra = 0.
            if plano-especial and finan.finent = yes
            then wfvlentra = valorparcela.
            disp wfvlentra skip.

            vval = 0.
            vval1 = 0.
            vsal = 0.

            vval = (vlfinan - wfvlentra) / finan.finnpc.

            if finan.fincod <> 41
            then do:
            if (finan.fincod < 50  or 
                finan.fincod >= 90 or
                finan.fincod = 75  or
                finan.fincod = 86  or
                finan.fincod = 76) and
                finan.fincod <> 40 and
                finan.fincod <> 14 and
                finan.fincod <> 92 and finan.fincod <> 96 and
                finan.fincod <> 97
            then do:
                vsal = vval - int(vval).
                if vsal > 0
                then vval = vval + (0.50 - vsal).
                if vsal < 0 and vsal <> -0.50
                then vval = ((vval - int(vval)) * -1) + vval.
            end.
            else do:
                vval1 = vval.
                if vval1 > vval
                then vval1 = vval1 - 0.10.
                vval = vval1.
            end.
            end.

            if (finan.fincod < 50 or 
                finan.fincod >= 90 or
                finan.fincod = 75  or
                finan.fincod = 76) and
                finan.fincod <> 40 and
                finan.fincod <> 92 and finan.fincod <> 96 and
                finan.fincod <> 14 and
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
            disp vlfinan.
            
            

            update vlfrete when vtprcod <> 1 skip.

            if plano-especial = no
            then vlfrete = 0.
            
            
            display vlfinan label "Valor liquido" format ">>>,>>>,>>9.99".


            wpar = finan.finnpc.
            disp  skip
                   wpar validate(wpar > 0,"Numero de Parcelas nao deve ser 0")
                    help "Informe o Numero de Parcelas do Contrato.".
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
                       wf-titulo.datexp = today.
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

    repeat with column 41 width 40 frame f3 down title " Parcelas " row 6
                    color white/cyan on endkey undo l0,retry l0:

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

        pause 0.

        display wcon            column-label "PC"
                wf-titulo.titdtemi column-label "Emissao".


         /******* promocao aniversario ******/

            if today >= 03/28/2003 and
               today <= 04/30/2003 and
               (finan.fincod = 17)
            then wf-titulo.titdtven = 05/30/2003.

            if today >= 08/29/2003 and
               today <= 09/30/2003 and
               (finan.fincod = 22  or
                finan.fincod = 94  or
                finan.fincod = 60  or
                finan.fincod = 97)
            then wf-titulo.titdtven = 11/10/2003.

            
         /*************************************/
   

        if finan.fincod = 59
        then wf-titulo.titdtven = 02/05/2003.
        
        
        
        
        vdtven = wf-titulo.titdtven.

        if day(today) >= 20 and
           day(today) <= 31
        then do on error undo, retry:
            update wf-titulo.titdtven.
            if wf-titulo.titdtven > (vdtven + 10) or
               wf-titulo.titdtven < today
            then do:
                message "Data de Vencimento Invalida". pause.
                undo,retry.
            end.
            if wf-titulo.titdtven <> vdtven
            then do:
                vok = yes.
                run senha.p(output vok).
                if vok = no
                then undo,retry.
            end.

            /******* promocao aniversario ******/
           
            if today >= 03/28/2003 and
               today <= 04/30/2003 and
               (finan.fincod = 17) and
               wf-titulo.titdtven > 05/30/2003
            then do:
                message "Data de vencimento invalida".
                pause.
                undo,retry.
            end.
            
            if today >= 08/29/2003 and
               today <= 09/30/2003 and
               (finan.fincod = 22  or
                finan.fincod = 94  or
                finan.fincod = 60  or
                finan.fincod = 97) and
               wf-titulo.titdtven > 11/10/2003
            then do:
                message "Data de vencimento invalida".
                pause.
                undo,retry.
            end.
            

            
            if finan.fincod = 59 and
               wf-titulo.titdtven > 02/05/2003
            then do:
                message "Data de vencimento invalida".
                pause.
                undo, retry.
            end.
                   
            /****************************************/
            

            
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
                            message "Data de vencimento invalida".
                            pause.
                            undo, retry.
                        end.
                    end.    
                end.
            end.
            
            if finan.fincod = 59 and
               wf-titulo.titdtven > 02/05/2003
            then do:
                message "Data de vencimento invalida".
                pause.
                undo, retry.
            end.
                         
            
        end.
        else do on error undo, retry:
            update wf-titulo.titdtven.
            if wf-titulo.titdtven > (vdtven + 5) or
               wf-titulo.titdtven < today
            then do:
                message "Data da Entrada Invalida". pause.
                undo,retry.
            end.
            
            /********* promocao aniversario ********/
            
            if today >= 03/28/2003 and
               today <= 04/30/2003 and
               finan.fincod = 17   and
               wf-titulo.titdtven > 05/30/2003
            then do:
                message "Data de vencimento invalida".
                pause.
                undo,retry.
            end.
            
            
            if today >= 08/29/2003 and
               today <= 09/30/2003 and
               (finan.fincod = 22  or
                finan.fincod = 94  or
                finan.fincod = 60  or
                finan.fincod = 97) and
               wf-titulo.titdtven > 11/10/2003
            then do:
                message "Data de vencimento invalida".
                pause.
                undo,retry.
            end.
            
            
            if finan.fincod = 59 and
               wf-titulo.titdtven > 02/05/2003
            then do:
                message "Data de vencimento invalida".
                pause.
                undo, retry.
            end.
            /****************************************/

            
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
                            message "Data de vencimento invalida".
                            pause.
                            undo, retry.
                        end.    
                    end.    
                end.
                
                if finan.fincod = 59 and
                   wf-titulo.titdtven > 02/05/2003
                then do:
                    message "Data de vencimento invalida".
                    pause.
                    undo, retry.
                end.
             
            
            end.
            
        end.

        if wf-titulo.titdtven < vdtentra
        then do:
            message "Data de vencimento invalida".
            undo.
        end.
        if finan.finent = yes or
           ((finan.fincod < 50  or 
             finan.fincod >= 90 or
             finan.fincod = 75  or
             finan.fincod = 76) and
             finan.fincod <> 40 and
             finan.fincod <> 92 and finan.fincod <> 96 and
             finan.fincod <> 14 and
             finan.fincod <> 97)
        then do:
            wf-titulo.titvlcob = vlfinan / wpar.
        end.
        else do:
            wf-titulo.titvlcob = (vvltotal - (vval1 * finan.finnpc)) + vval1 .
        end.

        disp wf-titulo.titvlcob format ">,>>>,>>9.99" column-label "Vl.Cob".

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
                         finan.fincod = 76) and
                         finan.fincod <> 92 and finan.fincod <> 96 and
                         finan.fincod <> 40 and
                         finan.fincod <> 14 and
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
            display i @ wcon column-label "PC"
                    wf-titulo.titdtemi column-label "Emissao"
                    wf-titulo.titdtven column-label "Vencimento"
                    wf-titulo.titvlcob format ">,>>>,>>9.99"
                        column-label "Vl.Cob".
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
    pause 0.
    cont = 0.
    leave.
end.
end.

hide frame f1 no-pause.
hide frame f2 no-pause.
hide frame f3 no-pause.
