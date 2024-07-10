/* #1 - 17.12.2018 helio.neto - Alterado para tambem demonstrar os valores do FEIRAO-NOVO */
{admcab.i}
def var vetbcod like estab.etbcod.
def var vdti as date.
def var vdtf as date.
def var vanalitico as log format "Sim/Nao".
update vetbcod label "Filial      " with frame f1 1 down width 80
        side-label.
if vetbcod > 0
then do:
    find estab where estab.etbcod = vetbcod no-lock no-error.
    if not avail estab
    then do:
        bell.
        message color red/with
        "Filial não cadastrada."
        view-as alert-box.
        undo.
    end.
    disp estab.etbnom no-label with frame f1.
end.
else disp "Todas as filiais" @ estab.etbnom with frame f1.
 
update vdti at 1 label "Data inicial"
       vdtf at 1 label "Data final  "
       with frame f1.
       
if vdti = ? or vdtf = ? or vdti > vdtf
then do:
    bell.
    message color red/with
    "Favor verificar periodo informado."
    view-as alert-box.
    undo, retry.
end.

update vanalitico at 1 label "Analitico?  "
        with frame f1.
        
def var vdata as date.
def temp-table tt-dd no-undo
    field etbcod like estab.etbcod  
    field data as date
    field clifor like clien.clicod
    field titnum like titulo.titnum
    field vnova as dec
    field vpago as dec
    field vorig as dec
    field nparc as int

    field nnova as dec
    field npago as dec
    field norig as dec
    
    index i1 is unique primary etbcod data clifor .
if vanalitico
then
for each estab where (if vetbcod > 0
                      then estab.etbcod = vetbcod else true)
                      no-lock:
    disp "Aguarde processamento...  "
         estab.etbcod no-label
         with frame f-r 1 down no-box color message row 10.
    pause 0.     
    do vdata = vdti to vdtf:
        disp vdata no-label with frame f-r.
        pause 0.
        for each titulo where
             titulo.empcod   = 19 and
             titulo.titnat   = no and
             titulo.modcod   = "CRE" and
             titulo.etbcod   = estab.etbcod and
             titulo.titdtemi = vdata 
             no-lock:
            if acha("FEIRAO-NOME-LIMPO",titulo.titobs[1]) <> ? and
               acha("FEIRAO-NOME-LIMPO",titulo.titobs[1]) = "SIM"
            then do:
                find first tt-dd where
                       tt-dd.etbcod = titulo.etbcod and
                       tt-dd.data   = titulo.titdtemi and
                       tt-dd.clifor = titulo.clifor and
                       tt-dd.titnum = titulo.titnum 
                       no-error.
                if not avail tt-dd
                then do:
                    create tt-dd.
                    assign
                        tt-dd.etbcod = titulo.etbcod
                        tt-dd.data   = titulo.titdtemi
                        tt-dd.clifor = titulo.clifor
                        tt-dd.titnum = titulo.titnum
                        .
                    for each tit_novacao where
                         tit_novacao.ger_contnum = int(titulo.titnum)
                         no-lock:
                        tt-dd.vori = tt-dd.vori + tit_novacao.ori_titvlcob.
                    end.         
                end.
                tt-dd.vnova = tt-dd.vnova + titulo.titvlcob.
                if titulo.titsit = "PAG"
                then tt-dd.vpag = tt-dd.vpag + titulo.titvlcob.
                if titulo.titpar - 30 > 0 and
                   titulo.titpar - 30 > tt-dd.nparc
                then tt-dd.nparc = titulo.titpar - 30.
            end.
            if  acha("FEIRAO-NOVO",titulo.titobs[1]) = "SIM"
            then do:
                find first tt-dd where
                       tt-dd.etbcod = titulo.etbcod and
                       tt-dd.data   = titulo.titdtemi and
                       tt-dd.clifor = titulo.clifor and
                       tt-dd.titnum = titulo.titnum 
                       no-error.
                if not avail tt-dd
                then do:
                    create tt-dd.
                    assign
                        tt-dd.etbcod = titulo.etbcod
                        tt-dd.data   = titulo.titdtemi
                        tt-dd.clifor = titulo.clifor
                        tt-dd.titnum = titulo.titnum
                        .
                    for each tit_novacao where
                         tit_novacao.ger_contnum = int(titulo.titnum)
                         no-lock:
                        tt-dd.nori = tt-dd.nori + tit_novacao.ori_titvlcob.
                    end.         
                end.
                tt-dd.nnova = tt-dd.nnova + titulo.titvlcob.
                if titulo.titsit = "PAG"
                then tt-dd.npag = tt-dd.npag + titulo.titvlcob.
                
                if titulo.titpar - 30 > 0 and
                   titulo.titpar - 30 > tt-dd.nparc
                then tt-dd.nparc = titulo.titpar - 30.
            end.
            

        end.
    end.
end.
else
for each estab where (if vetbcod > 0
                      then estab.etbcod = vetbcod else true)
                      no-lock:
    disp "Aguarde processamento...  "
         estab.etbcod no-label
         with frame f-r1 1 down no-box color message row 10.
    pause 0.     
    do vdata = vdti to vdtf:
        disp vdata no-label with frame f-r1.
        pause 0.
        for each titulo where
             titulo.empcod   = 19 and
             titulo.titnat   = no and
             titulo.modcod   = "CRE" and
             titulo.etbcod   = estab.etbcod and
             titulo.titdtemi = vdata 
             no-lock:
            if acha("FEIRAO-NOME-LIMPO",titulo.titobs[1]) <> ? and
               acha("FEIRAO-NOME-LIMPO",titulo.titobs[1]) = "SIM"
            then do:
                find first tt-dd where
                       tt-dd.etbcod = titulo.etbcod 
                       no-error.
                if not avail tt-dd
                then do:
                    create tt-dd.
                    assign
                        tt-dd.etbcod = titulo.etbcod
                        .
                end.
                if titulo.titpar = 0 
                then
                    for each tit_novacao where
                         tit_novacao.ger_contnum = int(titulo.titnum)
                         no-lock:
                        tt-dd.vori = tt-dd.vori + tit_novacao.ori_titvlcob.
                    end.         

                tt-dd.vnova = tt-dd.vnova + titulo.titvlcob.
                if titulo.titsit = "PAG"
                then tt-dd.vpag = tt-dd.vpag + titulo.titvlcob.
            end.
            if acha("FEIRAO-NOVO",titulo.titobs[1]) = "SIM"
            then do:
                find first tt-dd where
                       tt-dd.etbcod = titulo.etbcod 
                       no-error.
                if not avail tt-dd
                then do:
                    create tt-dd.
                    assign
                        tt-dd.etbcod = titulo.etbcod
                        .
                end.
                if titulo.titpar = 0 
                then
                    for each tit_novacao where
                         tit_novacao.ger_contnum = int(titulo.titnum)
                         no-lock:
                        tt-dd.nori = tt-dd.nori + tit_novacao.ori_titvlcob.
                    end.         

                tt-dd.nnova = tt-dd.nnova + titulo.titvlcob.
                if titulo.titsit = "PAG"
                then tt-dd.npag = tt-dd.npag + titulo.titvlcob.
            end.
            
        end.
    end.
end.

            
def var varquivo as char.
    
varquivo = "/admcom/relat/relfeicre" + string(setbcod) + "."
                    + string(time).
    
{mdadmcab.i &Saida     = "value(varquivo)"   
                &Page-Size = "64"  
                &Cond-Var  = "100" 
                &Page-Line = "66" 
                &Nom-Rel   = ""relfeicre"" 
                &Nom-Sis   = """CREDIARIO""" 
                &Tit-Rel   = """NOVACOES FEIRAO""" 
                &Width     = "100"
                &Form      = "frame f-cabcab"}

if vanalitico
then
for each tt-dd where tt-dd.etbcod > 0.
    disp tt-dd.etbcod column-label "Filial"  
         tt-dd.data   column-label "Emissao"
         tt-dd.clifor column-label "Cliente"
         tt-dd.titnum column-label "Contrato"
         tt-dd.vnova(total)  column-label "Feirao!Valor!Novacao"
         tt-dd.vpago(total)  column-label "Nome!Valor!Pago"
         tt-dd.vorig(total)  column-label "Limpo!Valor!Original"
         "|"
         tt-dd.nnova(total)  column-label "Feirao!Valor!Novacao"
         tt-dd.npago(total)  column-label "Novo!Valor!Pago"
         tt-dd.norig(total)  column-label "!Valor!Original"

         tt-dd.nparc  column-label "Parcelas"
         with frame f-disp  down width 130.
end.
else
for each tt-dd where tt-dd.etbcod > 0.
    disp tt-dd.etbcod column-label "Filial"  
         tt-dd.vnova(total)  column-label "Feirao!Valor!Novacao"
         tt-dd.vpago(total)  column-label "Nome!Valor!Pago"
         tt-dd.vorig(total)  column-label "Limpo!Valor!Original"
         "|"
         tt-dd.nnova(total)  column-label "Feirao!Valor!Novacao"
         tt-dd.npago(total)  column-label "Novo!Valor!Pago"
         tt-dd.norig(total)  column-label "!Valor!Original"
         
         with frame f-disp1  down width 130.
end.

    
output close.

if opsys = "UNIX"
then do:
    run visurel.p(varquivo,"").
end.
else do:
    {mrod.i}
end.

 