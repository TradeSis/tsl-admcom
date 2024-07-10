{admcab.i}
def var vetbcod like estab.etbcod.
def var vdti as date.
def var vdtf as date.
def var vanalitico as log format "Sim/Nao".
def var vtipo-feirao as char format "x(20)"
    extent 3 init ["TODOS","ANTIGO (Fora Carteira)","NOVO (Carteira)"] .
def var vindex-feirao      as int.
def var vfeirao-antigo as log.
def var vfeirao-novo   as log.


update vetbcod colon 11 label "Filial" with frame f1 1 down width 80
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
 
update vdti colon 11 label "De"
       vdtf label "Ate"
       with frame f1.
       
if vdti = ? or vdtf = ? or vdti > vdtf
then do:
    bell.
    message color red/with
    "Favor verificar periodo informado."
    view-as alert-box.
    undo, retry.
end.

disp skip "   FEIRAO?:" vtipo-feirao no-label
    with frame f1.
choose field vtipo-feirao 
    with frame f1.

vindex-feirao = frame-index.


update vanalitico colon 11 label "Analitico?"
        with frame f1.
        
def var vdata as date.
def temp-table tt-dd  no-undo
    field etbcod like estab.etbcod  
    field data as date
    field clifor like clien.clicod
    field titnum like titulo.titnum
    field tipofeirao as char format "x(03)"
    field vnova as dec
    field vpago as dec
    field vorig as dec
    field nparc as int
    index i1 etbcod data clifor
    .
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
            vfeirao-antigo = acha("FEIRAO-NOME-LIMPO",titulo.titobs[1]) = "SIM".
            vfeirao-novo   = acha("FEIRAO-NOVO",titulo.titobs[1])       = "SIM". 

            if  vfeirao-antigo or
                vfeirao-novo 
            then do:
                if  vindex-feirao = 1 or
                   (vindex-feirao = 2 and vfeirao-antigo) or
                   (vindex-feirao = 3 and vfeirao-novo)
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
                            tt-dd.tipofeirao = if vfeirao-antigo
                                               then "ANT"
                                               else "NOV".
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
            vfeirao-antigo = acha("FEIRAO-NOME-LIMPO",titulo.titobs[1]) = "SIM".
            vfeirao-novo   = acha("FEIRAO-NOVO",titulo.titobs[1])       = "SIM". 

            if  vfeirao-antigo or
                vfeirao-novo 
            then do:
                if  vindex-feirao = 1 or
                   (vindex-feirao = 2 and vfeirao-antigo) or
                   (vindex-feirao = 3 and vfeirao-novo)
                then do:
                    find first tt-dd where
                       tt-dd.etbcod = titulo.etbcod 
                       no-error.
                    if not avail tt-dd
                    then do:
                        create tt-dd.
                        assign
                            tt-dd.etbcod = titulo.etbcod .
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
                &Tit-Rel   = """NOVACOES FEIRAO "" + vtipo-feirao[vindex-feirao] " 
                &Width     = "100"
                &Form      = "frame f-cabcab"}

if vanalitico
then
for each tt-dd where tt-dd.etbcod > 0.
    disp tt-dd.etbcod column-label "Filial"  
         tt-dd.data   column-label "Emissao"
         tt-dd.clifor column-label "Cliente"
         tt-dd.titnum column-label "Contrato"
         tt-dd.tipofeirao column-label "Tip"
         tt-dd.vnova(total)  column-label "Valor!Novacao"
         tt-dd.vpago(total)  column-label "Valor!Pago"
         tt-dd.vorig(total)  column-label "Valor!Original"
         tt-dd.nparc  column-label "Parcelas"
         with frame f-disp  down width 100.
end.
else
for each tt-dd where tt-dd.etbcod > 0.
    disp tt-dd.etbcod column-label "Filial"  
         tt-dd.vnova(total)  column-label "Valor!Novacao"
         tt-dd.vpago(total)  column-label "Valor!Pago"
         tt-dd.vorig(total)  column-label "Valor!Original"
         with frame f-disp1  down width 100.
end.

    
output close.

if opsys = "UNIX"
then do:
    run visurel.p(varquivo,"").
end.
else do:
    {mrod.i}
end.

 