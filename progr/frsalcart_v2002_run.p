/* #1 06.06.17 Helio - Alteracao incluindo colunas por tipo de carteira */
/* #2 16.06.17 Helio - Procedure que retorno rpcontrato vlnominla e saldo */
/* #3 12.07.17 Ricardo - Acesso remoto nao selecionar estab */
/* #4 31.08.17 - Nova novacao - novo filtro de modaildades */
/* #5 Helio 04.04.18 - Versionamento v1801 com Regra definida 
    TITOBS[1] contem FEIRAO = YES - NAO PERTENCE A CARTEIRA 
    ou
    TPCONTRATO = "L" - NAO PERTENCE A CARTEIRA
*/
{admcab-batch.i}
DEF INPUT  PARAM    lcJsonEntrada AS LONGCHAR.
DEF INPUT  PARAM    ptela         AS log.
DEF OUTPUT PARAM    varquivo1     AS CHAR.
DEF OUTPUT PARAM    vpdf          AS CHAR.

{tsr/tsrelat.i}

DEF VAR hentrada AS HANDLE.

def temp-table ttparametros NO-UNDO serialize-name "parametros"
    field cre               as log
    field codigoFilial      as int
    field mod-sel           as char
    field dataInicial       as char
    field dataFinal         as char
    field dataReferencia    as char
    field consulta-parcelas-LP   as log
    field feirao-nome-limpo      as log
    field abreporanoemi          as log
    field clinovos          as log
    field porestab          as log
    field vindex            as INT.

hEntrada = temp-table ttparametros:HANDLE.

hentrada:READ-JSON("longchar",lcjsonentrada, "EMPTY").
                        
find first ttparametros no-error.
if not avail ttparametros then return.

def var vdt as date.
def var v-abreporanoemi as log format "Sim/Nao".
def var vtime as int.

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

def var vclinovos as log format "Sim/Nao".
def var v-cont as integer.
def var v-cod as char.
def var vmod-sel as char.

def buffer btitulo   for titulo.
def buffer bf-titulo for titulo.

def temp-table tt-clien NO-UNDO 
    field clicod like clien.clicod
    field mostra as log init no
    index ind01 clicod.

def temp-table tt-clinovo NO-UNDO 
    field clicod like clien.clicod
    index i1 clicod.

def NEW SHARED temp-table tt-modalidade-selec NO-UNDO /* #1 */
    field modcod as char.

def var vconta as int.
    
def var par-paga as int.
def var pag-atraso as log.
def buffer ctitulo for titulo.

def var vdti as date.
def var vdtf as date.
def var vporestab as log format "Sim/Nao".
def var vcre as log format "Geral/Facil" initial yes.
def var vtipo as log format "Nova/Antiga".
def var vdtref  as   date format "99/99/9999" .
def var vetbcod     like estab.etbcod.
def var vdisp   as   char format "x(8)".
def var vtotal  like titulo.titvlcob.
def var vmes    as   char format "x(3)" extent 12 initial
                        ["JAN","FEV","MAR","ABR","MAI","JUN",
                         "JUL","AGO","SET","OUT","NOV","DEZ"] .

def var vtot1   like titulo.titvlcob.
def var vtot2   like titulo.titvlcob.



def var v-consulta-parcelas-LP as logical format "Sim/Nao" initial no.
def var v-parcela-lp as log.
def var v-feirao-nome-limpo as log format "Sim/Nao" initial no.
def var v-novacao as log format "Sim/Nao" initial no.


def temp-table wf no-undo /* #1 */
    field vdt   as date
    field vencido like titulo.titvlcob label "Vencido" format ">>>>>>>>>>>>>>>>>>>9.99"
    field vencer  like titulo.titvlcob label "Vencer"  format ">>>>>>>>>>>>>>>>>>>9.99".

   
def temp-table wfano no-undo /* #1 */
    field vano    as i format "9999"
    field vencidoano like titulo.titvlcob label "Vencido"
    field vencerano  like titulo.titvlcob label "Vencer"
    field cartano    like titulo.titvlcob label "Carteira" .

def var v-fil17 as char extent 2 format "x(15)"
    init ["Nova","Antiga"].
def var vindex as int. 
def var etb-tit like titulo.etbcod.

def temp-table tt-cli NO-UNDO 
    field clicod like clien.clicod.

def var wvencidoano like titulo.titvlcob label "Vencido".
def var wvencerano  like titulo.titvlcob label "Vencer".
def var wcartano    like titulo.titvlcob label "Carteira".

def var wcrenov  like titulo.titvlcob. /* #1 */
def temp-table tt-etbtit no-undo
    field etbcod like estab.etbcod
    field titvlcob like titulo.titvlcob
    field fei    like titulo.titvlcob
    field lp     like titulo.titvlcob
    field nov    like titulo.titvlcob
    field cre    like titulo.titvlcob
    
    /* #1 */
    
    index i1 is unique primary etbcod asc.

def temp-table tt-etbtitfeirao no-undo
    field etbcod like estab.etbcod
    field anoemi as int format "9999"
    field fei    like titulo.titvlcob
    field nov    like titulo.titvlcob
    
    index i1 is unique primary etbcod asc anoemi asc.


def var vval-carteira as dec.

        /* parametrois vem do ttparametros */

        vcre = ttparametros.cre.
        v-consulta-parcelas-LP = ttparametros.consulta-parcelas-LP.
        v-feirao-nome-limpo = ttparametros.feirao-nome-limpo.
        v-abreporanoemi = ttparametros.abreporanoemi.
        vclinovos = ttparametros.clinovos.
        vporestab = ttparametros.porestab.
        vindex = ttparametros.vindex.
        vetbcod = ttparametros.codigoFilial.
        vmod-sel = ttparametros.mod-sel. 
        do vconta = 1 to num-entries(vmod-sel,",").
            if entry(vconta,vmod-sel,",") = "" then next.
            create tt-modalidade-selec.
            tt-modalidade-selec.modcod = entry(vconta,vmod-sel,",").
        end.


        if ttparametros.dataFinal BEGINS "#" then do:
            vdtf = calculadata(ttparametros.dataFinal,TODAY).
        end.
        ELSE DO:
            vdtf =convertedata(ttparametros.dataFinal).
        END.
        if ttparametros.dataInicial BEGINS "#" then do:
            vdti = calculadata(ttparametros.dataInicial,TODAY).
        end.
        ELSE DO:
            vdti  = convertedata(ttparametros.dataInicial).
        END.
        if ttparametros.dataReferencia BEGINS "#" then do:
            vdtref = calculadata(ttparametros.dataReferencia,TODAY).
        end.
        ELSE DO:
            vdtref  = convertedata(ttparametros.dataReferencia).
        END.
        /* ajuste mesmo que as datas venham erradas */
        if vporestab
        then vdtref = ?.
        else do:
            vdti = ?.
            vdtf = ?.
        end.
        /* */
   

if vcre = no
then do:    
    for each tt-cli:
        delete tt-cli.
    end.      
      
    for each clien where clien.classe = 1 no-lock:
        create tt-cli.
        assign tt-cli.clicod = clien.clicod.
    end.
end.



if vporestab = no
then do:
    if vcre
    then do:
        vtime = time.
        for each estab where if vetbcod = 0 then true else estab.etbcod = vetbcod no-lock.
        for each tt-modalidade-selec no-lock,
            each titulo where titnat = no and titdtpag = ? and titulo.modcod = tt-modalidade-selec.modcod 
                    and titulo.etbcod = estab.etbcod
                no-lock.
            if titulo.titsit <> "LIB" then next.
            if titulo.titdtven = ? then next.
            if titulo.titdtemi > vdtref then next.  
            if ptela
            then do:
                disp "1.a1 Processando... Filial : " titulo.etbcod
                        string(time - vtime ,"HH:MM:SS") 
                with 1 down.
                pause 0.
            
            end.
            if titulo.etbcod = 17 and
               vindex = 2 and
               titulo.titdtemi >= 10/20/2010
            then next.  
            else if titulo.etbcod = 17 and
                vindex = 1 and
                titulo.titdtemi < 10/20/2010
            then next.            
            
            if avail titulo
                    and titulo.tpcontrato = "L"
                then assign v-parcela-lp = yes.
                else assign v-parcela-lp = no.

                if v-consulta-parcelas-LP = no
                    and v-parcela-lp = yes
                then next.
                                                   
                if v-consulta-parcelas-LP = yes
                   and v-parcela-lp = no
                then next.

                {filtro-feiraonl.i}

            etb-tit = titulo.etbcod.
            run muda-etb-tit.

            if vclinovos 
            then do:
                run cli-novo.
            end.

            find first tt-clinovo where 
                       tt-clinovo.clicod = titulo.clifor
                       no-error.
            if not avail tt-clinovo 
                and vclinovos
            then next.  
            
            find first wf where 
                    wf.vdt = date(month(titulo.titdtven), 01,
                             year(titulo.titdtven)) no-error.
            if not available wf
            then create wf.
            assign wf.vdt = 
                date(month(titulo.titdtven), 01, year(titulo.titdtven)).
            if titulo.titdtven <= vdtref
            then do:
                wf.vencido = wf.vencido + titulo.titvlcob.
            end.     
            else do:
                wf.vencer  = wf.vencer + titulo.titvlcob.
            end.          
            
        end.
        end.
        for each estab where if vetbcod = 0 then true else estab.etbcod = vetbcod no-lock.
        do vdt = vdtref + 1 to today .
        for each tt-modalidade-selec no-lock,
            each titulo where titulo.titnat = no and titdtpag = vdt and titulo.modcod = tt-modalidade-selec.modcod and
                titulo.etbcod = estab.etbcod no-lock.
            if titulo.titsit <> "PAG" then next.
            if titulo.titdtpag = ? then next.
            if titulo.titdtven = ? then next.
            if titulo.titdtemi > vdtref then next. 
            if ptela
            then do:
                disp "1.a2 Processando... Filial : " titulo.etbcod
                        string(time - vtime ,"HH:MM:SS") 
                with 1 down.
                pause 0.

            end.
            if titulo.etbcod = 17 and
               vindex = 2 and
               titulo.titdtemi >= 10/20/2010
            then next.  
            else if titulo.etbcod = 17 and
                vindex = 1 and
                titulo.titdtemi < 10/20/2010
            then next.            
            
            if avail titulo
                    and titulo.tpcontrato = "L"
                then assign v-parcela-lp = yes.
                else assign v-parcela-lp = no.

                if v-consulta-parcelas-LP = no
                    and v-parcela-lp = yes
                then next.
                                                   
                if v-consulta-parcelas-LP = yes
                   and v-parcela-lp = no
                then next.

                {filtro-feiraonl.i}

            etb-tit = titulo.etbcod.
            run muda-etb-tit.

            if vclinovos 
            then do:
                run cli-novo.
            end.

            find first tt-clinovo where 
                       tt-clinovo.clicod = titulo.clifor
                       no-error.
            if not avail tt-clinovo 
                and vclinovos
            then next.  
            
            find first wf where 
                    wf.vdt = date(month(titulo.titdtven), 01,
                             year(titulo.titdtven)) no-error.
            if not available wf
            then create wf.
            assign wf.vdt = 
                date(month(titulo.titdtven), 01, year(titulo.titdtven)).
            if titulo.titdtven <= vdtref
            then do:
                wf.vencido = wf.vencido + titulo.titvlcob.
            end.     
            else do:
                wf.vencer  = wf.vencer + titulo.titvlcob.
            end.          
            

            
        end.
        end.
        end.
        

    end.
    else do:
         for each tt-cli,
             each tt-modalidade-selec,
             each titulo 
                 where titulo.empcod = WEMPRE.EMPCOD and
                       titulo.titnat = no and
                       titulo.clifor = tt-cli.clicod and
                       titulo.modcod = tt-modalidade-selec.modcod and
                       (titulo.titsit = "LIB" or
                        (titulo.titsit = "PAG" and
                        titulo.titdtpag > vdtref))
                         no-lock:

            if vetbcod <> 0
            then if titulo.etbcod <> vetbcod
                 then next.
            
            
            if ptela
            then do:
                 disp "2 Processando... Filial : " etb-tit with 1 down.
                pause 0.
            end.

            if titulo.titdtemi > vdtref
            then next.


            if avail titulo
                    and titulo.tpcontrato = "L"
                then assign v-parcela-lp = yes.
                else assign v-parcela-lp = no.

                if v-consulta-parcelas-LP = no
                    and v-parcela-lp = yes
                then next.
                                                   
                if v-consulta-parcelas-LP = yes
                   and v-parcela-lp = no
                then next.

                {filtro-feiraonl.i}

            if vclinovos 
            then do:
                run cli-novo.
            end.

            find first tt-clinovo where 
                       tt-clinovo.clicod = titulo.clifor
                       no-error.
            if not avail tt-clinovo 
                and vclinovos
            then next.  

            if titulo.tpcontrato = "L"
            then assign v-parcela-lp = yes.
            else assign v-parcela-lp = no.
            
            if v-consulta-parcelas-LP = yes
            then do:
                 if v-parcela-lp = yes 
                 then. 
                 else next.
            end.     
            else do:
                 if v-parcela-lp
                 then next.
                 if v-feirao-nome-limpo 
                 then do:
                        if acha("FEIRAO-NOME-LIMPO",titulo.titobs[1]) <> ? and
                           acha("FEIRAO-NOME-LIMPO",titulo.titobs[1]) = "SIM"
                        then .
                        else next.
                 end.    
                 else if acha("FEIRAO-NOME-LIMPO",titulo.titobs[1]) <> ? and
                         acha("FEIRAO-NOME-LIMPO",titulo.titobs[1]) = "SIM"
                      then next.  
            end.    

            
            find first wf where wf.vdt = 
                    date(month(titulo.titdtven), 01,
                    year(titulo.titdtven)) no-error.
            if not available wf
            then create wf.
            assign wf.vdt = 
              date(month(titulo.titdtven), 01, year(titulo.titdtven)).

            if titulo.titdtven <= vdtref
            then wf.vencido = wf.vencido + titulo.titvlcob.
            else wf.vencer  = wf.vencer + titulo.titvlcob.
        end.
    end.
        
end.
else if vporestab = no
then do:
    if vcre
    then do:
        vtime = time.
        for each tt-modalidade-selec,
            each titulo 
                 where titulo.empcod = WEMPRE.EMPCOD and
                       titulo.titnat = no and
                       titulo.modcod = tt-modalidade-selec.modcod and
                       (titulo.titsit = "LIB" or
                        (titulo.titsit = "PAG" and
                         titulo.titdtpag > vdtref)) and
                       titulo.etbcod = vetbcod no-lock:
    
           if titulo.titdtemi > vdtref
           then next.
                       if titulo.titdtven = ? then next.
                                                
           if titulo.etbcod = 17 and
              vindex = 2 and
              titulo.titdtemi >= 10/20/2010
            then next.  
            else if titulo.etbcod = 17 and
                vindex = 1 and
                titulo.titdtemi < 10/20/2010
            then next.

            etb-tit = titulo.etbcod.
        
            run muda-etb-tit.

            if titulo.etbcod = 10 and
                etb-tit = 23
            then next.

            if avail titulo
                    and titulo.tpcontrato = "L"
                then assign v-parcela-lp = yes.
                else assign v-parcela-lp = no.

                if v-consulta-parcelas-LP = no
                    and v-parcela-lp = yes
                then next.
                                                   
                if v-consulta-parcelas-LP = yes
                   and v-parcela-lp = no
                then next.

                {filtro-feiraonl.i}

            if ptela
            then do:
                disp "3 Processando... Filial : " etb-tit 
                    string(time - vtime ,"HH:MM:SS") with 1 down.
                pause 0.
            end.

            if vclinovos 
            then do:
                run cli-novo.
            end.

            find first tt-clinovo where 
                       tt-clinovo.clicod = titulo.clifor
                       no-error.
            if not avail tt-clinovo 
                and vclinovos
            then next.  
            
            find first wf where 
                        wf.vdt = date(month(titulo.titdtven), 01,
                                  year(titulo.titdtven)) no-error.
            if not available wf
            then create wf.
            assign wf.vdt = 
              date(month(titulo.titdtven), 01, year(titulo.titdtven)).

            if titulo.titdtven <= vdtref
            then do:
                wf.vencido = wf.vencido + titulo.titvlcob.
            end.     
            else do:
                wf.vencer  = wf.vencer + titulo.titvlcob.
            end.          
        end.
        if vetbcod = 23
        then
        for each tt-modalidade-selec,
            each titulo 
                 where titulo.empcod = WEMPRE.EMPCOD and
                       titulo.titnat = no and
                       titulo.modcod = tt-modalidade-selec.modcod and
                       (titulo.titsit = "LIB" or
                        (titulo.titsit = "PAG" and
                        titulo.titdtpag > vdtref)) and 
                       titulo.etbcod = 10 no-lock:
    
            if titulo.titdtemi >= 01/01/14
            then next.
        
            if avail titulo
                    and titulo.tpcontrato = "L"
                then assign v-parcela-lp = yes.
                else assign v-parcela-lp = no.

                if v-consulta-parcelas-LP = no
                    and v-parcela-lp = yes
                then next.
                                                   
                if v-consulta-parcelas-LP = yes
                   and v-parcela-lp = no
                then next.

                {filtro-feiraonl.i}

            etb-tit = 23.

            if ptela
            then do:
                disp "4 Processando... Filial : " etb-tit with 1 down.
                pause 0.
            end.

            if titulo.titdtemi > vdtref
            then next.

            if vclinovos 
            then do:
                run cli-novo.
            end.

            find first tt-clinovo where 
                       tt-clinovo.clicod = titulo.clifor
                       no-error.
            if not avail tt-clinovo 
                and vclinovos
            then next.  
            
            find first wf where 
                        wf.vdt = date(month(titulo.titdtven), 01,
                                  year(titulo.titdtven)) no-error.
            if not available wf
            then create wf.
            assign wf.vdt = 
              date(month(titulo.titdtven), 01, year(titulo.titdtven)).

            if titulo.titdtven <= vdtref
            then wf.vencido = wf.vencido + titulo.titvlcob.
            else wf.vencer  = wf.vencer + titulo.titvlcob.
        end.

    end.
    else do:  
        for each tt-cli,
            each tt-modalidade-selec,
            each titulo 
                 where titulo.empcod = WEMPRE.EMPCOD and
                       titulo.titnat = no and
                       titulo.clifor = tt-cli.clicod and
                       titulo.modcod = tt-modalidade-selec.modcod and
                       (titulo.titsit = "LIB" or
                        (titulo.titsit = "PAG" and
                        titulo.titdtpag > vdtref)) and
                       titulo.etbcod = vetbcod no-lock:
    
            if titulo.etbcod = 17 and
              vindex = 2 and
              titulo.titdtemi >= 10/20/2010
            then next.  
            else if titulo.etbcod = 17 and
                vindex = 1 and
                titulo.titdtemi < 10/20/2010
            then next.

            etb-tit = titulo.etbcod.
            run muda-etb-tit.
            
            if titulo.etbcod = 10 and
                etb-tit = 23 then next.

            if avail titulo
                    and titulo.tpcontrato = "L"
                then assign v-parcela-lp = yes.
                else assign v-parcela-lp = no.

                if v-consulta-parcelas-LP = no
                    and v-parcela-lp = yes
                then next.
                                                   
                if v-consulta-parcelas-LP = yes
                   and v-parcela-lp = no
                then next.

                {filtro-feiraonl.i}

            
            
            if ptela
            then do:
                disp "5 Processando... Filial : " etb-tit with 1 down.
                pause 0.
            end.

            if titulo.titdtemi > vdtref
            then next.
            
            if vclinovos 
            then do:
                run cli-novo.
            end.

            find first tt-clinovo where 
                       tt-clinovo.clicod = titulo.clifor
                       no-error.
            if not avail tt-clinovo 
                and vclinovos
            then next.           

            find first wf where wf.vdt = date(month(titulo.titdtven), 01,
                                              year(titulo.titdtven)) no-error.
            if not available wf
            then create wf.
            assign wf.vdt = 
                    date(month(titulo.titdtven), 01, year(titulo.titdtven)).

            if titulo.titdtven <= vdtref
            then wf.vencido = wf.vencido + titulo.titvlcob.
            else wf.vencer  = wf.vencer + titulo.titvlcob.
        end.
        if vetbcod = 23
        then
        for each tt-cli,
            each tt-modalidade-selec,
            each titulo 
                 where titulo.empcod = WEMPRE.EMPCOD and
                       titulo.titnat = no and
                       titulo.clifor = tt-cli.clicod and
                       titulo.modcod = tt-modalidade-selec.modcod and
                       (titulo.titsit = "LIB" or
                        (titulo.titsit = "PAG" and
                        titulo.titdtpag > vdtref)) and
                       titulo.etbcod = 10 no-lock:
    
            if titulo.titdtemi >= 01/01/2014
            then next.

            etb-tit = 23.

            if titulo.tpcontrato = "L"
            then assign v-parcela-lp = yes.
            else assign v-parcela-lp = no.
            if ptela
            then do:
                disp "6 Processando... Filial : " etb-tit with 1 down.
                pause 0.
            end.
            if titulo.titdtemi > vdtref
            then next.

            if v-consulta-parcelas-LP = yes
            then do:
                 if v-parcela-lp = yes 
                 then. 
                 else next.
            end.     
            else do:
                 if v-parcela-lp
                 then next.
                 if v-feirao-nome-limpo 
                 then do:
                        if acha("FEIRAO-NOME-LIMPO",titulo.titobs[1]) <> ? and
                           acha("FEIRAO-NOME-LIMPO",titulo.titobs[1]) = "SIM"
                        then .
                        else next.
                 end.    
                 else if acha("FEIRAO-NOME-LIMPO",titulo.titobs[1]) <> ? and
                         acha("FEIRAO-NOME-LIMPO",titulo.titobs[1]) = "SIM"
                      then next.  
            end.    

            if vclinovos 
            then do:
                run cli-novo.
            end.

            find first tt-clinovo where 
                       tt-clinovo.clicod = titulo.clifor
                       no-error.
            if not avail tt-clinovo 
                and vclinovos
            then next.           

            find first wf where wf.vdt = date(month(titulo.titdtven), 01,
                                              year(titulo.titdtven)) no-err~or.
            if not available wf
            then create wf.
            assign wf.vdt = 
                    date(month(titulo.titdtven), 01, year(titulo.titdtv~en)).

            if titulo.titdtven <= vdtref
            then wf.vencido = wf.vencido + titulo.titvlcob.
            else wf.vencer  = wf.vencer + titulo.titvlcob.
        end.
    end.
end.
else if vporestab = yes
then do:
    if vcre
    then do:
        vtime = time.
        for each estab no-lock:
            find first tt-etbtit where
                tt-etbtit.etbcod = estab.etbcod no-error.
            if not avail tt-etbtit
            then do:
                create tt-etbtit.
                tt-etbtit.etbcod = estab.etbcod.
            end.    
           for each tt-modalidade-selec,
                each  titulo use-index titdtven
                where titulo.empcod = WEMPRE.EMPCOD and
                      titulo.titnat = no and
                      titulo.modcod = tt-modalidade-selec.modcod and
                      titulo.etbcod = estab.etbcod and
                      titulo.titdtven >= vdti and
                      titulo.titdtven <= vdtf
                      no-lock:
                                               
                etb-tit = titulo.etbcod.
                run muda-etb-tit.
                /* #2 */
                par-tpcontrato = titulo.tpcontrato.
                if ptela
                then do:
                    disp "7 Processando... Filial : " 
                            string(time - vtime ,"HH:MM:SS") 
                    titulo.etbcod with 1 down.
                    pause 0.
                end.
                if titulo.titsit <> "LIB" /*and
                   titulo.titsit <> "PAG" */
                then next.

                if vclinovos
                then do:
                    run cli-novo.
                end.
                    
                find first tt-clinovo where 
                       tt-clinovo.clicod = titulo.clifor
                       no-error.
                if not avail tt-clinovo 
                    and vclinovos
                then next.  
            
                find first tt-etbtit where
                    tt-etbtit.etbcod = etb-tit no-error.
                if not avail tt-etbtit
                then do:
                    create tt-etbtit.
                    tt-etbtit.etbcod = etb-tit.
                end. 
                tt-etbtit.titvlcob = tt-etbtit.titvlcob + titulo.titvlcob.
                    if acha("FEIRAO-NOME-LIMPO",titulo.titobs[1]) = "SIM" or
                       titulo.tpcontrato = "L" 
                    then do:
                        if acha("FEIRAO-NOME-LIMPO",titulo.titobs[1]) = "SIM"
                        then 
                          tt-etbtit.fei = tt-etbtit.fei + titulo.titvlcob.
                        else
                          tt-etbtit.lp  = tt-etbtit.lp  + titulo.titvlcob.
                    end.
                    else do:

                        if titulo.tpcontrato = "N"
                        then do:
                            tt-etbtit.nov     = tt-etbtit.nov    + titulo.titvlcob.
                        end.                           
                        else do:
                           tt-etbtit.cre  = tt-etbtit.cre + titulo.titvlcob.
                           
                        end.     
                    end.                
                    if v-abreporanoemi
                    then do:
                        if acha("FEIRAO-NOVO",titulo.titobs[1]) = "SIM" or 
                           acha("FEIRAO-NOME-LIMPO",titulo.titobs[1]) = "SIM" or
                           titulo.tpcontrato = "N"
                        then do:
                            find first tt-etbtitfeirao where
                                tt-etbtitfeirao.etbcod  = tt-etbtit.etbcod and
                                tt-etbtitfeirao.anoemi = int(string(year (titulo.titdtemi),"9999")) 
                                       no-error.
                            if not avail tt-etbtitfeirao
                            then do:
                                create tt-etbtitfeirao.         
                                tt-etbtitfeirao.etbcod   = tt-etbtit.etbcod.
                                tt-etbtitfeirao.anoemi = int(string(year (titulo.titdtemi),"9999")). 
                            end.
                        
                            if acha("FEIRAO-NOME-LIMPO",titulo.titobs[1]) = "SIM"
                            then tt-etbtitfeirao.fei = tt-etbtitfeirao.fei + titulo.titvlcob.
                            else
                            tt-etbtitfeirao.nov    = tt-etbtitfeirao.nov    + titulo.titvlcob.
                        end.    
                    end.


            end.
        end.
    end.
    else do:
        for each estab no-lock:
            find first tt-etbtit where
                tt-etbtit.etbcod = estab.etbcod no-error.
            if not avail tt-etbtit
            then do:
                create tt-etbtit.
                tt-etbtit.etbcod = estab.etbcod.
            end. 
            for each tt-cli:
                for each tt-modalidade-selec,
                    each titulo use-index titdtven
                 where titulo.empcod = WEMPRE.EMPCOD and
                       titulo.titnat = no and
                       titulo.modcod = tt-modalidade-selec.modcod and
                       titulo.etbcod = estab.etbcod and
                       titulo.titdtven >= vdti and
                       titulo.titdtven <= vdtf and
                       titulo.clifor = tt-cli.clicod 
                       no-lock:

                etb-tit = titulo.etbcod.
                run muda-etb-tit.                

                if titulo.tpcontrato = "L"
                then assign v-parcela-lp = yes.
                else assign v-parcela-lp = no.
                if ptela then do:
                    disp "8 Processando... Filial : " titulo.etbcod with 1 down.
                    pause 0.

                end.
                if titulo.titsit = "PAG"
                then next.

            if v-consulta-parcelas-LP = yes
            then do:
                 if v-parcela-lp = yes 
                 then. 
                 else next.
            end.     
            else do:
                 if v-parcela-lp
                 then next.
                 if v-feirao-nome-limpo 
                 then do:
                        if acha("FEIRAO-NOME-LIMPO",titulo.titobs[1]) <> ? and
                           acha("FEIRAO-NOME-LIMPO",titulo.titobs[1]) = "SIM"
                        then .
                        else next.
                 end.    
                 else if acha("FEIRAO-NOME-LIMPO",titulo.titobs[1]) <> ? and
                         acha("FEIRAO-NOME-LIMPO",titulo.titobs[1]) = "SIM"
                      then next.  
            end.    

                    
                find first tt-clinovo where 
                       tt-clinovo.clicod = titulo.clifor
                       no-error.
                if not avail tt-clinovo 
                    and vclinovos
                then next.  
                find first tt-etbtit where
                    tt-etbtit.etbcod = etb-tit no-error.
                if not avail tt-etbtit
                then do:
                    create tt-etbtit.
                    tt-etbtit.etbcod = etb-tit.
                end. 
                tt-etbtit.titvlcob = tt-etbtit.titvlcob + titulo.titvlcob.
                end.
            end.                 
        end.
    end.
end.


vtotal = 0.

    
for each wf where year(wf.vdt) < (year(vdtref) - 1) break by wf.vdt
                                                       by year(wf.vdt):

    find first wfano where wfano.vano = year(wf.vdt) no-error.
    if not avail wfano
    then do:
        create wfano.
        assign wfano.vano = year(wf.vdt).
    end.

    wfano.vencidoano = wfano.vencidoano + wf.vencido.
    wfano.vencerano  = wfano.vencerano  + wf.vencer.
 
    for each tt-modalidade-selec,
        each carteira
        where carteira.carano = year(wf.vdt) and
              carteira.titnat = no and
              carteira.modcod = tt-modalidade-selec.modcod and
              carteira.etbcod = vetbcod no-lock.

        wcartano = wcartano + carteira.carval[month(wf.vdt)].
        
    end.
end.

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
    
    for each tt-modalidade-selec,
        each carteira
        where carteira.carano = year(wf.vdt) and
              carteira.titnat = no and
              carteira.modcod = tt-modalidade-selec.modcod and
              carteira.etbcod = vetbcod
                    no-lock.
                    
        wcartano = wcartano + carteira.carval[month(wf.vdt)].
    end.
end.

for each wf:
    find first wfano where wfano.vano = year(wf.vdt) no-error.
    if avail wfano
    then delete wf.
end.
if ptela then do:
    hide message no-pause.
    message "Gerando o Relatorio ".

end.
def buffer bestab for estab.
    if vdtref = ?
    then vdtref = vdtf.
    

        if AVAIL tsrelat then do:
            varquivo = replace(tsrelat.nomerel," ","") +
            "-ID" + STRING(tsrelat.idrelat) + "-" +  
             STRING(TODAY,"99999999") +
             replace(STRING(TIME,"HH:MM:SS"),":","").
        end.
        ELSE DO:
            varquivo = "frsalcart-" + STRING(TODAY,"99999999") +
                            replace(STRING(TIME,"HH:MM:SS"),":","").
        END.

        {mdad.i
            &Saida     = "VALUE(vdir + varquivo + """.txt""")"
            &Page-Size = "0"
            &Cond-Var  = "140"
            &Page-Line = "0"
            &Nom-Rel   = ""frsalcart2002""
            &Nom-Sis   = """SISTEMA DE CREDIARIO"""
            &Tit-Rel   = """ POSICAO  VENCIDAS/A VENCER - FILIAL "" + 
            string(vetbcod) + "" DATA BASE: "" + 
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
 if vporestab = no
 then do:

for each wfano where vano < (year(vdtref) - 1) break by vano:

    vdisp = string(vano,"9999") .

    disp vdisp          column-label "Ano"
         wfano.cartano  column-label "Carteira"
         wfano.vencidoano     column-label "Vencido" (TOTAL)
         wfano.vencidoano / wfano.cartano * 100 format "->>9.99"
                column-label "%"
         wfano.vencerano      column-label "A Vencer" (TOTAL)

         with centered width 240.

        vtot1  = vtot1  +  wfano.vencidoano.
        vtot2  = vtot2  +  wfano.vencerano.
        vtotal = vtotal + (wfano.vencerano + wfano.vencidoano).
end.

for each wf break by vdt.

    vdisp = trim(string(vmes[int(month(wf.vdt))]) + "/" +
                 string(year(wf.vdt),"9999") ) .

    assign vval-carteira = 0.

    for each tt-modalidade-selec,
        each carteira where carteira.carano = year(wf.vdt) and
                            carteira.titnat = no and
                            carteira.modcod = tt-modalidade-selec.modcod and
                            carteira.etbcod = vetbcod
                                no-lock.

        vval-carteira = vval-carteira + carteira.carval[month(wf.vdt)].

    end.
    disp vdisp          column-label "Mes/Ano"
         vval-carteira  column-label "Carteira" when wf.vencido > 0
         wf.vencido     column-label "Vencido" (TOTAL)
         wf.vencido / vval-carteira * 100 format "->>9.99" column-label "%"
            when wf.vencido > 0 
         wf.vencer      column-label "A Vencer" (TOTAL)
         
         with centered  width 240.

        vtot1  = vtot1  +  wf.vencido.
        vtot2  = vtot2  +  wf.vencer.
        vtotal = vtotal + (wf.vencer + wf.vencido).
end.

for each wfano where vano > (year(vdtref) + 1) break by vano:

    vdisp = string(vano,"9999") .

    disp vdisp          column-label "Ano"
         wfano.cartano  column-label "Carteira"
         wfano.vencidoano     column-label "Vencido" (TOTAL)
         wfano.vencidoano / wfano.cartano * 100 format "->>9.99" 
                        column-label "%"
         wfano.vencerano      column-label "A Vencer" (TOTAL)

         with centered width 240.

        vtot1  = vtot1  +  wfano.vencidoano.
        vtot2  = vtot2  +  wfano.vencerano.
        vtotal = vtotal + (wfano.vencerano + wfano.vencidoano).
        
end.

    display ((vtot1 / vtotal) * 100) format ">>9.99 %" at 39
            ((vtot2 / vtotal) * 100) format ">>9.99 %" at 64 skip(1)
            with frame fsub.

    display vtot1 label  "Total Vencido"  skip
            vtot2 label  " Total Vencer"   skip
            vtotal label "  Total Geral"   skip(2)
            with side-labels frame ftot.
end.
else do:
    for each tt-etbtit where tt-etbtit.titvlcob <> 0:
        find bestab where bestab.etbcod = tt-etbtit.etbcod no-lock no-error.

        wcrenov = tt-etbtit.nov /*+ tt-etbtit.feinov*/ + tt-etbtit.cre. /* #1 */
        def var wfeirao as char.        
        disp tt-etbtit.etbcod
             bestab.etbnom no-label  when avail bestab format "x(15)"
             tt-etbtit.titvlcob(total) column-label "(1+2+3+4)!Total"
              /* #1 */
             wfeirao  format "x(04)" column-label "Ano"
             tt-etbtit.fei (total) column-label "(1)!Feirao"
             tt-etbtit.lp  (total) column-label "(2)!LP" 
             tt-etbtit.nov (total) column-label "(3)!Novacao"
             tt-etbtit.cre (total) column-label "(4)!Venda"
             wcrenov (total) column-label "(3+4)!Crediario"
             
             with frame f-dispp down width 260.
             
             
        find first tt-etbtitfeirao
            where tt-etbtitfeirao.etbcod = tt-etbtit.etbcod
            no-lock no-error.
        if avail tt-etbtitfeirao
        then do:
            
            for each tt-etbtitfeirao where tt-etbtitfeirao.etbcod = tt-etbtit.etbcod no-lock.
                down with frame f-dispp.
                disp
                    tt-etbtitfeirao.anoemi @ wfeirao
                    tt-etbtitfeirao.fei    @ tt-etbtit.fei
                    tt-etbtitfeirao.nov    @ tt-etbtit.nov
                    with frame f-dispp.
            end.
        end.     
             
             
    end.             
end.
output close.

run pdfout.p (INPUT vdir + varquivo + ".txt",
    input vdir,
    input varquivo + ".pdf",
    input "Landscape", /* Landscape/Portrait */
    input 7,
    input 1,
    output vpdf).
varquivo1 = vdir + varquivo + ".txt".    

procedure muda-etb-tit.

    if etb-tit = 10 and
       titulo.titdtemi < 01/01/2014
    then etb-tit = 23.
    
end procedure.

procedure cli-novo:
    find first tt-clinovo where
               tt-clinovo.clicod = titulo.clifor
               no-error.
    if not avail tt-clinovo
    then do:
        par-paga = 0.
        pag-atraso = no.

        for each ctitulo where
                 ctitulo.clifor = titulo.clifor 
                 no-lock:
            if ctitulo.titpar = 0 then next.
            if ctitulo.modcod = "DEV" or
                ctitulo.modcod = "BON" or
                ctitulo.modcod = "CHP"
            then next.
 
            if ctitulo.titsit = "LIB"
            then next.

            par-paga = par-paga + 1.
            if par-paga = 31
            then leave.
            if ctitulo.titdtpag > ctitulo.titdtven
            then pag-atraso = yes.   
            
        end.
        find first posicli where posicli.clicod = titulo.clifor
               no-lock no-error.
        if avail posicli
        then par-paga = par-paga + posicli.qtdparpg.
            
        find first credscor where credscor.clicod = titulo.clifor
                        no-lock no-error.
        if avail credscor
        then  par-paga = par-paga + credscor.numpcp.
        
        if par-paga <= 30 and pag-atraso = yes
        then do:   
            create tt-clinovo.
            tt-clinovo.clicod = titulo.clifor.
        end.
    end. 
end procedure.



