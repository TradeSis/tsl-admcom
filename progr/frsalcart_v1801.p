/* #1 06.06.17 Helio - Alteracao incluindo colunas por tipo de carteira */
/* #2 16.06.17 Helio - Procedure que retorno rpcontrato vlnominla e saldo */
/* #3 12.07.17 Ricardo - Acesso remoto nao selecionar estab */
/* #4 31.08.17 - Nova novacao - novo filtro de modaildades */
/* #5 Helio 04.04.18 - Versionamento v1801 com Regra definida 
    TITOBS[1] contem FEIRAO = YES - NAO PERTENCE A CARTEIRA 
    ou
    TPCONTRATO = "L" - NAO PERTENCE A CARTEIRA
*/

{admcab.i}

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

def var vclinovos as log format "Sim/Nao".
def var v-cont as integer.
def var v-cod as char.
def var vmod-sel as char.

def buffer btitulo   for titulo.
def buffer bf-titulo for titulo.

def temp-table tt-clien
    field clicod like clien.clicod
    field mostra as log init no
    index ind01 clicod.

def temp-table tt-clinovo
    field clicod like clien.clicod
    index i1 clicod.

def NEW SHARED temp-table tt-modalidade-selec /* #4 */
    field modcod as char.
    
def var par-paga as int.
def var pag-atraso as log.
def buffer ctitulo for titulo.

def var varquivo as char format "x(20)".
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

def temp-table wf no-undo /* #1 */
    field vdt   as date
    field vencido like titulo.titvlcob label "Vencido"
    field vencer  like titulo.titvlcob label "Vencer".

def temp-table wfano no-undo /* #1 */
    field vano    as i format "9999"
    field vencidoano like titulo.titvlcob label "Vencido"
    field vencerano  like titulo.titvlcob label "Vencer"
    field cartano    like titulo.titvlcob label "Carteira".

def var v-fil17 as char extent 2 format "x(15)"
    init ["Nova","Antiga"].
def var vindex as int. 
def var etb-tit like titulo.etbcod.

def temp-table tt-cli
    field clicod like clien.clicod.

def var wvencidoano like titulo.titvlcob label "Vencido".
def var wvencerano  like titulo.titvlcob label "Vencer".
def var wcartano    like titulo.titvlcob label "Carteira".

def var wcrenov  like titulo.titvlcob. /* #1 */
def temp-table tt-etbtit
    field etbcod like estab.etbcod
    field titvlcob like titulo.titvlcob
    /* #1 */
    field fei    like titulo.titvlcob
    field lp     like titulo.titvlcob
    field nov    like titulo.titvlcob
    field cre    like titulo.titvlcob
    /* #1 */
    
    index i1 etbcod.

def var vval-carteira as dec.

update vcre label "Cliente" colon 25 with side-label width 80.

assign sresp = false.
update sresp label "Seleciona Modalidades?" colon 25
help "Não = Modalidade CRE Padrão / Sim = Seleciona Modalidades"
 with side-label width 80.

if sresp
then run selec-modal.p ("REC"). /* #4 */
else do:
    create tt-modalidade-selec.
    assign tt-modalidade-selec.modcod = "CRE".
end.

assign vmod-sel = "  ".
for each tt-modalidade-selec.
    assign vmod-sel = vmod-sel + tt-modalidade-selec.modcod + "  ".
end.
display vmod-sel format "x(40)" no-label.

if sremoto /* #3 */
then disp setbcod @ estab.etbcod.
else prompt-for estab.etbcod label "Estabelecimento"  colon 25.
if input estab.etbcod <> ""
then do:
    find estab where estab.etbcod = input estab.etbcod no-lock no-error.
    if not avail estab
    then do:
        message "Estabelecimento Invalido".
        undo.
    end.
    display estab.etbnom no-label .
    pause 0.
    /*
    if estab.etbcod = 12
    then update vtipo label "Periodo".
    */

    vindex = 0.
    if estab.etbcod = 17
    then do:
         disp v-fil17 with frame f-17 1 down centered row 10 
            no-label.
         choose field v-fil17 with frame f-17.
         vindex = frame-index.   
    end.
end.
else do on error undo:
    display "Geral" @ estab.etbnom.
    update vporestab label "Por Filial" colon 25.
    
    if vporestab
    then do on error undo:
        update vdti label "Periodo de"
               vdtf label "Ate" 
        with frame ff row 6 no-box side-label overlay column 40.
        if vdti = ? or vdtf = ?
        then undo.
    end.
end.        

vetbcod = input estab.etbcod.

if vporestab = no
then update vdtref   label "Data Referencia" colon 25
    with  side-label .
            
if (vcre and vporestab = no) or vcre = no
then
update v-consulta-parcelas-LP label " Considera apenas LP"
 help "'Sim' = Parcelas acima de 51 / 'Nao' = Parcelas abaixo de 51"  colon 25
    with  side-label .

if (vcre and vporestab = no) or vcre = no
then
update v-feirao-nome-limpo label "Considerar apenas feirao"
        colon 25 with side-label.
            
update 
vclinovos label "Somente clientes novos(até 30 pagas) que atrasaram parcela(s)"
with frame fff111 1 down no-box overlay side-label.

if vcre = no
then do:    
    for each tt-cli:
        delete tt-cli.
    end.      
      
    for each clien where clien.classe = 1 no-lock:
        display clien.clicod
                clien.clinom
                clien.datexp format "99/99/9999" with 1 down. pause 0.
    
        create tt-cli.
        assign tt-cli.clicod = clien.clicod.
    end.
end.

if input estab.etbcod = "" and vporestab = no
then do:
    if vcre
    then do:
        for each tt-modalidade-selec no-lock,
            each titulo 
                 where titulo.empcod = WEMPRE.EMPCOD and
                       titulo.titnat = no and
                       titulo.modcod = tt-modalidade-selec.modcod and
                       (titulo.titsit = "LIB" or
                        (titulo.titsit = "PAG" and
                        titulo.titdtpag > vdtref)) no-lock:

            if titulo.etbcod = 17 and
               vindex = 2 and
               titulo.titdtemi >= 10/20/2010
            then next.  
            else if titulo.etbcod = 17 and
                vindex = 1 and
                titulo.titdtemi < 10/20/2010
            then next.            
            
           /***if acha("RENOVACAO",titulo.titobs[1]) = "SIM"***/
           
            /* #3 - regra esta correta */
            if titulo.tpcontrato = "L"
            then assign v-parcela-lp = yes.
            else assign v-parcela-lp = no.

            if v-consulta-parcelas-LP = no
                and v-parcela-lp = yes
            then next.
            
            if v-consulta-parcelas-LP = yes
                and v-parcela-lp = no
            then next.

            {filtro-feiraonl.i}

            disp "Processando... Filial : " titulo.etbcod with 1 down.
            pause 0.

            if titulo.titdtemi > vdtref
            then next.
         
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
                        titulo.titdtpag > vdtref))
                         no-lock:

            disp "Processando... Filial : " etb-tit with 1 down.
            pause 0.
 
            if titulo.titdtemi > vdtref
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

            if /* #3 acha("RENOVACAO",titulo.titobs[1]) = "SIM" or */
               titulo.tpcontrato = "L"
            then assign v-parcela-lp = yes.
            else assign v-parcela-lp = no.

            if v-consulta-parcelas-LP = no
                and v-parcela-lp = yes
            then next.
            
            if v-consulta-parcelas-LP = yes
                and v-parcela-lp = no
            then next.            
            
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
        for each tt-modalidade-selec,
            each titulo 
                 where titulo.empcod = WEMPRE.EMPCOD and
                       titulo.titnat = no and
                       titulo.modcod = tt-modalidade-selec.modcod and
                       (titulo.titsit = "LIB" or
                        (titulo.titsit = "PAG" and
                         titulo.titdtpag > vdtref)) and
                       titulo.etbcod = input estab.etbcod no-lock:
    
           if titulo.titdtemi > vdtref
           then next.

           if titulo.etbcod = 17 and
              vindex = 2 and
              titulo.titdtemi >= 10/20/2010
            then next.  
            else if titulo.etbcod = 17 and
                vindex = 1 and
                titulo.titdtemi < 10/20/2010
            then next.

            {filtro-feiraonl.i}

            etb-tit = titulo.etbcod.
        
            run muda-etb-tit.

            if titulo.etbcod = 10 and
                etb-tit = 23
            then next.

            if /* #3 acha("RENOVACAO",titulo.titobs[1]) = "SIM" or */
               titulo.tpcontrato = "L"
            then assign v-parcela-lp = yes.
            else assign v-parcela-lp = no.

            if v-consulta-parcelas-LP = no
                and v-parcela-lp = yes
            then next.
            
            if v-consulta-parcelas-LP = yes
                and v-parcela-lp = no
            then next.

            disp "Processando... Filial : " etb-tit with 1 down.
            pause 0.

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
        if input estab.etbcod = 23
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
            
            if acha("RENOVACAO",titulo.titobs[1]) = "SIM" or 
               titulo.tpcontrato = "L"
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

            disp "Processando... Filial : " etb-tit with 1 down.
            pause 0.

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
                       titulo.etbcod = input estab.etbcod no-lock:
    
            if titulo.etbcod = 17 and
              vindex = 2 and
              titulo.titdtemi >= 10/20/2010
            then next.  
            else if titulo.etbcod = 17 and
                vindex = 1 and
                titulo.titdtemi < 10/20/2010
            then next.

            {filtro-feiraonl.i}

            etb-tit = titulo.etbcod.
            run muda-etb-tit.
            
            if titulo.etbcod = 10 and
                etb-tit = 23 then next.

            if /* #3 acha("RENOVACAO",titulo.titobs[1]) = "SIM" or */
               titulo.tpcontrato = "L"
            then assign v-parcela-lp = yes.
            else assign v-parcela-lp = no.

            if v-consulta-parcelas-LP = no
                and v-parcela-lp = yes
            then next.
            
            if v-consulta-parcelas-LP = yes
                and v-parcela-lp = no
            then next.
            
            disp "Processando... Filial : " etb-tit with 1 down.
            pause 0.

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
        if input estab.etbcod = 23
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

            if acha("RENOVACAO",titulo.titobs[1]) = "SIM" or titulo.tpcontrato = "L"
            then assign v-parcela-lp = yes.
            else assign v-parcela-lp = no.

            if v-consulta-parcelas-LP = no
                and v-parcela-lp = yes
            then next.
            
            if v-consulta-parcelas-LP = yes
                and v-parcela-lp = no
            then next.

            disp "Processando... Filial : " etb-tit with 1 down.
            pause 0.

            if titulo.titdtemi > vdtref
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
                /** #2
                    run fbtituloposicao.p 
                        (recid(titulo), 
                         vdtf,
                         output par-parcial,
                         output par-parorigem,
                         output par-titdtemi,
                         output par-tpcontrato,
                         output par-titvlcob,
                         output par-titdtpag,
                         output par-titvlpag ,
                         output par-titdesc ,
                         output par-titjuro,
                         output par-saldo).
                **/

                 
                /* #1
                if acha("RENOVACAO",titulo.titobs[1]) = "SIM" or 
                titulo.tpcontrato = "L"
                then assign v-parcela-lp = yes.
                else assign v-parcela-lp = no.

                if v-consulta-parcelas-LP = no
                    and v-parcela-lp = yes
                then next.
            
                if v-consulta-parcelas-LP = yes
                    and v-parcela-lp = no
                then next.
                **/
                
                disp "Processando... Filial : " titulo.etbcod with 1 down.
                pause 0.

                if titulo.titsit <> "LIB" /*and
                   titulo.titsit <> "PAG" */
                then next.
                /*
                if  (titulo.titsit = "PAG" and
                     titulo.titdtpag > vdtf)
                then.
                else if titulo.titsit <> "LIB" 
                     then next.  */

                /* #1 {filtro-feiraonl.i} */

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
                /* #1 */
                /* #3 - regra esta correta */                    
                    /* #1 */
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
                        then
                           tt-etbtit.nov  = tt-etbtit.nov + titulo.titvlcob.
                        else
                           tt-etbtit.cre  = tt-etbtit.cre + titulo.titvlcob.
                    end.                
                    /* #1 */


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

                if /* #3 acha("RENOVACAO",titulo.titobs[1]) = "SIM" or */
                   titulo.tpcontrato = "L"
                then assign v-parcela-lp = yes.
                else assign v-parcela-lp = no.

                if v-consulta-parcelas-LP = no
                    and v-parcela-lp = yes
                then next.
            
                if v-consulta-parcelas-LP = yes
                    and v-parcela-lp = no
                then next.

                disp "Processando... Filial : " titulo.etbcod with 1 down.
                pause 0.
                
                if titulo.titsit = "PAG"
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

hide message no-pause.
message "Gerando o Relatorio ".

def buffer bestab for estab.
def var varq as char format "x(20)".
    if opsys = "UNIX"
    then varquivo = "../relat/frsalcart_" + string(mtime) + ".txt".
    else varquivo = "l:~\relat~\relw" + string(time).

    if vdtref = ?
    then vdtref = vdtf.
    
    {mdad.i
            &Saida     = "value(varquivo)" 
            &Page-Size = "64"
            &Cond-Var  = "140"
            &Page-Line = "66"
            &Nom-Rel   = ""frsalcart1801""
            &Nom-Sis   = """SISTEMA DE CREDIARIO"""
            &Tit-Rel   = """ POSICAO  VENCIDAS/A VENCER - FILIAL "" + 
                              string(vetbcod) + "" DATA BASE: "" + 
                              string(vdtref,""99/99/9999"")" 
            &Width     = "140"
            &Form      = "frame f-cabcab"}
 
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
         with centered .

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
         with centered .

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
         with centered .

        vtot1  = vtot1  +  wfano.vencidoano.
        vtot2  = vtot2  +  wfano.vencerano.
        vtotal = vtotal + (wfano.vencerano + wfano.vencidoano).
end.

    display ((vtot1 / vtotal) * 100) format ">>9.99 %" at 39
            ((vtot2 / vtotal) * 100) format ">>9.99 %" at 64 skip(1)
            with frame fsub.

    display vtot1 label "Total Vencido" 
        skip
            vtot2 label "Total Vencer"  
            skip
            vtotal label "Total Geral"   with side-labels frame ftot.
end.
else do:
    for each tt-etbtit where tt-etbtit.titvlcob <> 0:
        find bestab where bestab.etbcod = tt-etbtit.etbcod no-lock no-error.

        wcrenov = tt-etbtit.nov + tt-etbtit.cre. /* #1 */

        disp tt-etbtit.etbcod
             bestab.etbnom no-label  when avail bestab format "x(15)"
             tt-etbtit.titvlcob(total) column-label "(1+2+3+4) Total"
              /* #1 */
             tt-etbtit.fei (total) column-label "(1) Feirao"
             tt-etbtit.lp  (total) column-label "(2) LP" 
             tt-etbtit.nov (total) column-label "(3) Novacao"
             tt-etbtit.cre (total) column-label "(4) Venda"
             wcrenov (total) column-label "(3+4) Crediario"
            /* #1 */
             with frame f-dispp down width 140.
    end.             
end.
output close.

if sremoto /* #3 */
then run pdfout.p (input varquivo,
                  input "/admcom/kbase/pdfout/",
                  input "frsalcart" + string(mtime) + ".pdf",
                  input "Portrait",
                  input 8.2,
                  input 1,
                  output vpdf).
else if opsys = "UNIX"
then do:
    run visurel.p(varquivo, "").
    varquivo = "l:~\relat~\" + substr(varquivo,10,15).
    message skip "Arquivo gerado: " varquivo view-as alert-box.
end.
else do:    
    {mrod.i}.
end.

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

