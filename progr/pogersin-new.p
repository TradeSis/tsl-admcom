{admcab.i new}
{setbrw.i}

def var vclinovos as log format "Sim/Nao".

def var v-cont as integer.
def var v-cod as char.
def var vmod-sel as char.

def buffer btitulo   for fin.titulo.
def buffer bf-titulo for fin.titulo.

def temp-table tt-clien
    field clicod like clien.clicod
    field mostra as log init no
    index ind01 clicod.

def temp-table tt-clinovo
    field clicod like clien.clicod
    index i1 clicod.

def temp-table tt-modalidade-padrao
    field modcod as char
    index pk modcod.
    
def temp-table tt-modalidade-selec
    field modcod as char
    index pk modcod.
    
def var par-paga as int.
def var pag-atraso as log.
def buffer ctitulo for fin.titulo.

def var varquivo as char format "x(20)".
def var vdti as date.
def var vdtf as date.
def var vporestab as log format "Sim/Nao".
def var vcre as log format "Geral/Facil" initial yes.
def var vtipo as log format "Nova/Antiga".
def var vdtref  as   date format "99/99/9999" .
def var vetbcod     like estab.etbcod.
def var vdisp   as   char format "x(8)".
def var vtotal  like fin.titulo.titvlcob.
def var vmes    as   char format "x(3)" extent 12 initial
                        ["JAN","FEV","MAR","ABR","MAI","JUN",
                         "JUL","AGO","SET","OUT","NOV","DEZ"] .

def var vtot1   like fin.titulo.titvlcob.
def var vtot2   like fin.titulo.titvlcob.

def var v-consulta-parcelas-LP as logical format "Sim/Nao" initial no.
def var v-parcela-lp as log.
def var v-feirao-nome-limpo as log format "Sim/Nao" initial no.

def temp-table wf
    field vdt   as date
    field vencido like fin.titulo.titvlcob label "Vencido"
    field vencer  like fin.titulo.titvlcob label "Vencer".

def temp-table wfano
    field vano    as i format "9999"
    field vencidoano like fin.titulo.titvlcob label "Vencido"
    field vencerano  like fin.titulo.titvlcob label "Vencer"
    field cartano    like fin.titulo.titvlcob label "Carteira".

def var v-fil17 as char extent 2 format "x(15)"
    init ["Nova","Antiga"].
def var vindex as int. 

def var etb-tit like fin.titulo.etbcod.

def temp-table tt-cli
    field clicod like clien.clicod.

def var wvencidoano like fin.titulo.titvlcob label "Vencido".
def var wvencerano  like fin.titulo.titvlcob label "Vencer".
def var wcartano    like fin.titulo.titvlcob label "Carteira".

def temp-table tt-etbtit
    field etbcod like estab.etbcod
    field titvlcob like fin.titulo.titvlcob
    index i1 etbcod.

def var vval-carteira as dec.                                
                                
form
   a-seelst format "x" column-label "*"
   tt-modalidade-padrao.modcod no-label
   with frame f-nome
      centered down title "Modalidades"
      color withe/red overlay.    
                                                  
    
create tt-modalidade-padrao.
assign tt-modalidade-padrao.modcod = "CRE".

for each profin no-lock.

    create tt-modalidade-padrao.
    assign tt-modalidade-padrao.modcod = profin.modcod.

end.

update vcre label "Cliente" colon 25 with side-label
width 80.


assign sresp = false.

update sresp label "Seleciona Modalidades?" colon 25
help "Não = Modalidade CRE Padrão / Sim = Seleciona Modalidades"
 with side-label width 80.

if sresp
then do:
    bl_sel_filiais:
    repeat:

        run p-seleciona-filiais.
                        
        if keyfunction(lastkey) = "end-error"
        then leave bl_sel_filiais.
                                        
    end.

end.
else do:

    create tt-modalidade-selec.
    assign tt-modalidade-selec.modcod = "CRE".

end.

assign vmod-sel = "  ".
for each tt-modalidade-selec.
    assign vmod-sel = vmod-sel + tt-modalidade-selec.modcod + "  ".
end.

display vmod-sel format "x(40)" no-label.

prompt-for estab.etbcod label "Estabelecimento"  colon 25.
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
            
update v-consulta-parcelas-LP label " Considera apenas LP"
 help "'Sim' = Parcelas acima de 51 / 'Nao' = Parcelas abaixo de 51"  colon 25
    with  side-label .

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
        
            each fin.titulo 
                 where fin.titulo.empcod = WEMPRE.EMPCOD and
                       fin.titulo.titnat = no and
                       fin.titulo.modcod = tt-modalidade-selec.modcod and
                       (fin.titulo.titsit = "LIB" or
                        (fin.titulo.titsit = "PAG" and
                        fin.titulo.titdtpag > vdtref)) no-lock:

            if fin.titulo.etbcod = 17 and
               vindex = 2 and
               fin.titulo.titdtemi >= 10/20/2010
            then next.  
            else if fin.titulo.etbcod = 17 and
                vindex = 1 and
                fin.titulo.titdtemi < 10/20/2010
            then next.            
            
            if acha("RENOVACAO",fin.titulo.titobs[1]) = "SIM" or fin.titulo.tpcontrato = "L"
            then assign v-parcela-lp = yes.
            else assign v-parcela-lp = no.

            if v-consulta-parcelas-LP = no
                and v-parcela-lp = yes
            then next.
            
            if v-consulta-parcelas-LP = yes
                and v-parcela-lp = no
            then next.

            {filtro-feiraonl.i}

            disp "Processando... Filial : " fin.titulo.etbcod with 1 down.
            pause 0.

            if fin.titulo.titdtemi > vdtref
            then next.
         
            etb-tit = fin.titulo.etbcod.
            run muda-etb-tit.

            if vclinovos 
            then do:
                run cli-novo.
            end.

            find first tt-clinovo where 
                       tt-clinovo.clicod = fin.titulo.clifor
                       no-error.
            if not avail tt-clinovo 
                and vclinovos
            then next.  
            
            find first wf where 
                    wf.vdt = date(month(fin.titulo.titdtven), 01,
                             year(fin.titulo.titdtven)) no-error.
            if not available wf
            then create wf.
            assign wf.vdt = 
                date(month(fin.titulo.titdtven), 01, year(fin.titulo.titdtven)).

            if fin.titulo.titdtven <= vdtref
            then wf.vencido = wf.vencido + fin.titulo.titvlcob.
            else wf.vencer  = wf.vencer + fin.titulo.titvlcob.
        end.
    end.
    else do:
         for each tt-cli,
             each tt-modalidade-selec,
             each fin.titulo 
                 where fin.titulo.empcod = WEMPRE.EMPCOD and
                       fin.titulo.titnat = no and
                       fin.titulo.clifor = tt-cli.clicod and
                       fin.titulo.modcod = tt-modalidade-selec.modcod and
                       (fin.titulo.titsit = "LIB" or
                        (fin.titulo.titsit = "PAG" and
                        fin.titulo.titdtpag > vdtref))
                         no-lock:

            disp "Processando... Filial : " etb-tit with 1 down.
            pause 0.
 
            if fin.titulo.titdtemi > vdtref
            then next.

            {filtro-feiraonl.i}

            if vclinovos 
            then do:
                run cli-novo.
            end.

            find first tt-clinovo where 
                       tt-clinovo.clicod = fin.titulo.clifor
                       no-error.
            if not avail tt-clinovo 
                and vclinovos
            then next.  

            if acha("RENOVACAO",fin.titulo.titobs[1]) = "SIM" or fin.titulo.tpcontrato = "L"
            then assign v-parcela-lp = yes.
            else assign v-parcela-lp = no.

            if v-consulta-parcelas-LP = no
                and v-parcela-lp = yes
            then next.
            
            if v-consulta-parcelas-LP = yes
                and v-parcela-lp = no
            then next.            
            
            find first wf where wf.vdt = 
                    date(month(fin.titulo.titdtven), 01,
                    year(fin.titulo.titdtven)) no-error.
            if not available wf
            then create wf.
            assign wf.vdt = 
              date(month(fin.titulo.titdtven), 01, year(fin.titulo.titdtven)).

            if fin.titulo.titdtven <= vdtref
            then wf.vencido = wf.vencido + fin.titulo.titvlcob.
            else wf.vencer  = wf.vencer + fin.titulo.titvlcob.
        end.
    end.
        
end.
else if vporestab = no
then do:
    if vcre
    then do:
    
        for each tt-modalidade-selec,
            each fin.titulo 
                 where fin.titulo.empcod = WEMPRE.EMPCOD and
                       fin.titulo.titnat = no and
                       fin.titulo.modcod = tt-modalidade-selec.modcod and
                       (fin.titulo.titsit = "LIB" or
                        (fin.titulo.titsit = "PAG" and
                         fin.titulo.titdtpag > vdtref)) and
                       fin.titulo.etbcod = input estab.etbcod no-lock:
    
           if fin.titulo.titdtemi > vdtref
           then next.

           if fin.titulo.etbcod = 17 and
              vindex = 2 and
              fin.titulo.titdtemi >= 10/20/2010
            then next.  
            else if fin.titulo.etbcod = 17 and
                vindex = 1 and
                fin.titulo.titdtemi < 10/20/2010
            then next.

            {filtro-feiraonl.i}

            etb-tit = fin.titulo.etbcod.
        
            run muda-etb-tit.

            if fin.titulo.etbcod = 10 and
                etb-tit = 23
            then next.

            if acha("RENOVACAO",fin.titulo.titobs[1]) = "SIM" or fin.titulo.tpcontrato = "L"
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
                       tt-clinovo.clicod = fin.titulo.clifor
                       no-error.
            if not avail tt-clinovo 
                and vclinovos
            then next.  
            
            find first wf where 
                        wf.vdt = date(month(fin.titulo.titdtven), 01,
                                  year(fin.titulo.titdtven)) no-error.
            if not available wf
            then create wf.
            assign wf.vdt = 
              date(month(fin.titulo.titdtven), 01, year(fin.titulo.titdtven)).

            if fin.titulo.titdtven <= vdtref
            then wf.vencido = wf.vencido + fin.titulo.titvlcob.
            else wf.vencer  = wf.vencer + fin.titulo.titvlcob.
        end.
        if input estab.etbcod = 23
        then
        for each tt-modalidade-selec,
            each fin.titulo 
                 where fin.titulo.empcod = WEMPRE.EMPCOD and
                       fin.titulo.titnat = no and
                       fin.titulo.modcod = tt-modalidade-selec.modcod and
                       (fin.titulo.titsit = "LIB" or
                        (fin.titulo.titsit = "PAG" and
                        fin.titulo.titdtpag > vdtref)) and 
                       fin.titulo.etbcod = 10 no-lock:
    
            if fin.titulo.titdtemi >= 01/01/14
            then next.
            
            if acha("RENOVACAO",fin.titulo.titobs[1]) = "SIM" or fin.titulo.tpcontrato = "L"
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

            if fin.titulo.titdtemi > vdtref
            then next.

            if vclinovos 
            then do:
                run cli-novo.
            end.

            find first tt-clinovo where 
                       tt-clinovo.clicod = fin.titulo.clifor
                       no-error.
            if not avail tt-clinovo 
                and vclinovos
            then next.  
            
            find first wf where 
                        wf.vdt = date(month(fin.titulo.titdtven), 01,
                                  year(fin.titulo.titdtven)) no-error.
            if not available wf
            then create wf.
            assign wf.vdt = 
              date(month(fin.titulo.titdtven), 01, year(fin.titulo.titdtven)).

            if fin.titulo.titdtven <= vdtref
            then wf.vencido = wf.vencido + fin.titulo.titvlcob.
            else wf.vencer  = wf.vencer + fin.titulo.titvlcob.
        end.

    end.
    else do:  
        for each tt-cli,
            each tt-modalidade-selec,
            each fin.titulo 
                 where fin.titulo.empcod = WEMPRE.EMPCOD and
                       fin.titulo.titnat = no and
                       fin.titulo.clifor = tt-cli.clicod and
                       fin.titulo.modcod = tt-modalidade-selec.modcod and
                       (fin.titulo.titsit = "LIB" or
                        (fin.titulo.titsit = "PAG" and
                        fin.titulo.titdtpag > vdtref)) and
                       fin.titulo.etbcod = input estab.etbcod no-lock:
    
            if fin.titulo.etbcod = 17 and
              vindex = 2 and
              fin.titulo.titdtemi >= 10/20/2010
            then next.  
            else if fin.titulo.etbcod = 17 and
                vindex = 1 and
                fin.titulo.titdtemi < 10/20/2010
            then next.

            {filtro-feiraonl.i}

            etb-tit = fin.titulo.etbcod.
            run muda-etb-tit.
            
            if fin.titulo.etbcod = 10 and
                etb-tit = 23 then next.

            if acha("RENOVACAO",fin.titulo.titobs[1]) = "SIM" or fin.titulo.tpcontrato = "L"
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

            if fin.titulo.titdtemi > vdtref
            then next.
            
            if vclinovos 
            then do:
                run cli-novo.
            end.

            find first tt-clinovo where 
                       tt-clinovo.clicod = fin.titulo.clifor
                       no-error.
            if not avail tt-clinovo 
                and vclinovos
            then next.           

            find first wf where wf.vdt = date(month(fin.titulo.titdtven), 01,
                                              year(fin.titulo.titdtven)) no-error.
            if not available wf
            then create wf.
            assign wf.vdt = 
                    date(month(fin.titulo.titdtven), 01, year(fin.titulo.titdtven)).

            if fin.titulo.titdtven <= vdtref
            then wf.vencido = wf.vencido + fin.titulo.titvlcob.
            else wf.vencer  = wf.vencer + fin.titulo.titvlcob.
        end.
        if input estab.etbcod = 23
        then
        for each tt-cli,
            each tt-modalidade-selec,
            each fin.titulo 
                 where fin.titulo.empcod = WEMPRE.EMPCOD and
                       fin.titulo.titnat = no and
                       fin.titulo.clifor = tt-cli.clicod and
                       fin.titulo.modcod = tt-modalidade-selec.modcod and
                       (fin.titulo.titsit = "LIB" or
                        (fin.titulo.titsit = "PAG" and
                        fin.titulo.titdtpag > vdtref)) and
                       fin.titulo.etbcod = 10 no-lock:
    
            if fin.titulo.titdtemi >= 01/01/2014
            then next.

            etb-tit = 23.

            if acha("RENOVACAO",fin.titulo.titobs[1]) = "SIM" or fin.titulo.tpcontrato = "L"
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

            if fin.titulo.titdtemi > vdtref
            then next.

            {filtro-feiraonl.i}

            if vclinovos 
            then do:
                run cli-novo.
            end.

            find first tt-clinovo where 
                       tt-clinovo.clicod = fin.titulo.clifor
                       no-error.
            if not avail tt-clinovo 
                and vclinovos
            then next.           

            find first wf where wf.vdt = date(month(fin.titulo.titdtven), 01,
                                              year(fin.titulo.titdtven)) no-err~or.
            if not available wf
            then create wf.
            assign wf.vdt = 
                    date(month(fin.titulo.titdtven), 01, year(fin.titulo.titdtv~en)).

            if fin.titulo.titdtven <= vdtref
            then wf.vencido = wf.vencido + fin.titulo.titvlcob.
            else wf.vencer  = wf.vencer + fin.titulo.titvlcob.
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
                each  fin.titulo use-index titdtven
                where fin.titulo.empcod = WEMPRE.EMPCOD and
                      fin.titulo.titnat = no and
                      fin.titulo.modcod = tt-modalidade-selec.modcod and
                      fin.titulo.etbcod = estab.etbcod and
                      fin.titulo.titdtven >= vdti and
                      fin.titulo.titdtven <= vdtf
                      no-lock:

                etb-tit = fin.titulo.etbcod.
                run muda-etb-tit.
                
                if acha("RENOVACAO",fin.titulo.titobs[1]) = "SIM" or fin.titulo.tpcontrato = "L"
                then assign v-parcela-lp = yes.
                else assign v-parcela-lp = no.

                if v-consulta-parcelas-LP = no
                    and v-parcela-lp = yes
                then next.
            
                if v-consulta-parcelas-LP = yes
                    and v-parcela-lp = no
                then next.
            
                disp "Processando... Filial : " fin.titulo.etbcod with 1 down.
                pause 0.

                if fin.titulo.titsit <> "LIB" /*and
                   fin.titulo.titsit <> "PAG" */
                then next.
                /*
                if  (fin.titulo.titsit = "PAG" and
                     fin.titulo.titdtpag > vdtf)
                then.
                else if fin.titulo.titsit <> "LIB" 
                     then next.  */

                {filtro-feiraonl.i}

                if vclinovos
                then do:
                    run cli-novo.
                end.
                    
                find first tt-clinovo where 
                       tt-clinovo.clicod = fin.titulo.clifor
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
                tt-etbtit.titvlcob = tt-etbtit.titvlcob + fin.titulo.titvlcob.
            
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
                    each fin.titulo use-index titdtven
                 where fin.titulo.empcod = WEMPRE.EMPCOD and
                       fin.titulo.titnat = no and
                       fin.titulo.modcod = tt-modalidade-selec.modcod and
                       fin.titulo.etbcod = estab.etbcod and
                       fin.titulo.titdtven >= vdti and
                       fin.titulo.titdtven <= vdtf and
                       fin.titulo.clifor = tt-cli.clicod 
                       no-lock:

                etb-tit = fin.titulo.etbcod.
                run muda-etb-tit.                

                if acha("RENOVACAO",fin.titulo.titobs[1]) = "SIM" or fin.titulo.tpcontrato = "L"
                then assign v-parcela-lp = yes.
                else assign v-parcela-lp = no.

                if v-consulta-parcelas-LP = no
                    and v-parcela-lp = yes
                then next.
            
                if v-consulta-parcelas-LP = yes
                    and v-parcela-lp = no
                then next.

                disp "Processando... Filial : " fin.titulo.etbcod with 1 down.
                pause 0.
                
                if fin.titulo.titsit = "PAG"
                then next.

                {filtro-feiraonl.i}

                if vclinovos
                then do:
                    run cli-novo.
                end.
                    
                find first tt-clinovo where 
                       tt-clinovo.clicod = fin.titulo.clifor
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
                tt-etbtit.titvlcob = tt-etbtit.titvlcob + fin.titulo.titvlcob.
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
        each fin.carteira
        where fin.carteira.carano = year(wf.vdt) and
              fin.carteira.titnat = no and
              fin.carteira.modcod = tt-modalidade-selec.modcod and
              fin.carteira.etbcod = vetbcod no-lock.

        wcartano = wcartano + fin.carteira.carval[month(wf.vdt)].
        
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
        each fin.carteira
        where fin.carteira.carano = year(wf.vdt) and
              fin.carteira.titnat = no and
              fin.carteira.modcod = tt-modalidade-selec.modcod and
              fin.carteira.etbcod = vetbcod
                    no-lock.
                    
        wcartano = wcartano + fin.carteira.carval[month(wf.vdt)].

    end.
end.

for each wf:
    find first wfano where wfano.vano = year(wf.vdt) no-error.
    if avail wfano
    then delete wf.
end.

message "Gerando o Relatorio ".

def buffer bestab for estab.
def var varq as char format "x(20)".
    if opsys = "UNIX"
    then varquivo = "../relat/relx" + string(time) .
    else varquivo = "l:~\relat~\relw" + string(time).

    if vdtref = ?
    then vdtref = vdtf.
    
    {mdad.i
            &Saida     = "value(varquivo)" 
            &Page-Size = "64"
            &Cond-Var  = "140"
            &Page-Line = "66"
            &Nom-Rel   = ""pogersin""
            &Nom-Sis   = """SISTEMA DE CREDIARIO"""
            &Tit-Rel   = """ POSICAO FIN. VENCIDAS/A VENCER - FILIAL "" + 
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
        each fin.carteira where carteira.carano = year(wf.vdt) and
                            carteira.titnat = no and
                            carteira.modcod = tt-modalidade-selec.modcod and
                            carteira.etbcod = vetbcod
                                no-lock.

        vval-carteira = vval-carteira + fin.carteira.carval[month(wf.vdt)].

    end.
    disp vdisp          column-label "Mes/Ano"
         vval-carteira  column-label "Carteira"
            when wf.vencido > 0
         wf.vencido     column-label "Vencido" (TOTAL)
         wf.vencido / vval-carteira * 100 format "->>9.99"
                column-label "%"
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
        disp tt-etbtit.etbcod
             bestab.etbnom no-label  when avail bestab
             tt-etbtit.titvlcob(total)
             with frame f-dispp down.
    end.             
end.
output close.

if opsys = "UNIX"
then do:
    run visurel.p(varquivo, "").
    varquivo = "l:~\relat~\" + substr(varquivo,10,15).
    message skip "Arquivo gerado: " varquivo
     view-as alert-box.
end.
else do:    
    {mrod.i} .
end.

procedure muda-etb-tit.

    if etb-tit = 10 and
        fin.titulo.titdtemi < 01/01/2014
    then etb-tit = 23.
    
end procedure.

procedure cli-novo:
    find first tt-clinovo where
               tt-clinovo.clicod = fin.titulo.clifor
               no-error.
    if not avail tt-clinovo
    then do:
        par-paga = 0.
        pag-atraso = no.

        for each ctitulo where
                 ctitulo.clifor = fin.titulo.clifor 
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
        find first posicli where posicli.clicod = fin.titulo.clifor
               no-lock no-error.
        if avail posicli
        then par-paga = par-paga + posicli.qtdparpg.
            
        find first credscor where credscor.clicod = fin.titulo.clifor
                        no-lock no-error.
        if avail credscor
        then  par-paga = par-paga + credscor.numpcp.
        
        if par-paga <= 30 and pag-atraso = yes
        then do:   
            create tt-clinovo.
            tt-clinovo.clicod = fin.titulo.clifor.
        end.
    end. 
end procedure.




procedure p-seleciona-filiais:
            
{sklcls.i
    &File   = tt-modalidade-padrao
    &help   = "                ENTER=Marca F4=Retorna F8=Marca Tudo"
    &CField = tt-modalidade-padrao.modcod    
    &Ofield = " tt-modalidade-padrao.modcod"
    &Where  = " true"
    &noncharacter = /*
    &LockType = "NO-LOCK"
    &UsePick = "*"          
    &PickFld = "tt-modalidade-padrao.modcod" 
    &PickFrm = "x(4)" 
    &otherkeys1 = "
        if keyfunction(lastkey) = ""CLEAR""
        then do:
            V-CONT = 0.
            for each tt-modalidade-padrao no-lock:
                a-seelst = a-seelst + "","" + tt-modalidade-padrao.modcod.
                v-cont = v-cont + 1.
            end.
            message ""                         SELECIONADAS "" 
            V-CONT ""FILIAIS                                   ""
            .
                         a-seeid = -1.
            a-recid = -1.
            next keys-loop.
        end. "
    &Form = " frame f-nome" 
}. 

hide frame f-nome.
v-cont = 2.
repeat :
    v-cod = "".
    if num-entries(a-seelst) >= v-cont
    then v-cod = entry(v-cont,a-seelst).

    v-cont = v-cont + 1.

    if v-cod = ""
    then leave.
    create tt-modalidade-selec.
    assign tt-modalidade-selec.modcod = v-cod.
end.


end.