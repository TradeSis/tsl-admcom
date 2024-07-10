{admcab.i}

def shared var vdti as date.
def shared var vdtf as date.

def  var vnomes as char extent 12 
    init["JAN",
         "FEV",
         "MAR",
         "ABR",
         "MAI",
         "JUN",
         "JUL",
         "AGO",
         "SET",
         "OUT",
         "NOV",
         "DEZ"].
         
def  shared temp-table tt-venda
        field etbcod like estab.etbcod
        field data as date
        field vl-prazo as dec 
        field vl-vista as dec
        field avista as dec
        field aprazo as dec
        index i1 etbcod data.
 
def  shared temp-table tt-index
    field etbcod like estab.etbcod
    field data as date
    field indx as dec 
    field venda as dec 
    field titulo as dec
    field vl-prazo as dec  decimals 2
    field vl-titulo as dec decimals 2
    index i1 etbcod data.

def  shared temp-table tt-acretb
    field etbcod like estab.etbcod
    field valor as dec
    field valpr as dec.

def  shared temp-table tt-estab
    field etbcod like estab.etbcod
    .

def temp-table per-estab
    field etbcod like estab.etbcod
    field data as date
    field indice as dec
    field valor as dec
    index i1 etbcod data.

def var rec-atual as dec.

find first ctcartcl where
           ctcartcl.datref >= vdti and
           ctcartcl.datref <= vdtf and
           ctcartcl.recebimento > 0 and
           ctcartcl.etbcod > 0
           no-lock no-error.
if not avail ctcartcl  
then do:
    message "PROCESSAR RECEBIMENTOS" .
    PAUSE.
    return.               
end.

def var vtotal-sel as dec format "->>,>>>,>>9.99".
def var tot-sel as dec.
def var vcobcod like cobra.cobcod.
do on error undo :
        vcobcod = 0.
        update vcobcod label "Cobranca"
            vtotal-sel label "Valor enviar" format "->>,>>>,>>9.99"
            with frame fxz row 12 column 30 side-label overlay.
        if vtotal-sel = 0 or
           vtotal-sel = ?
        then return.   
        if vcobcod > 0
        then do:
            find first cobra where cobra.cobcod = vcobcod no-lock no-error.
            if not avail cobra then undo.
            sresp = no.
            message "Confirma enviar RECEBIMENTOS no valor de " 
                    string(vtotal-sel,">>,>>>,>>9.99").
            message "Para " cobra.cobnom " ?" update sresp.
            if sresp = no
            then undo.
        end.
end.

sresp = no.
message "Confirma processamento? " update sresp.
if not sresp then return.
        
def var vpra-z as dec.
def var vecf-z as dec.
def var vacr-z as dec.
def var vdata1 as date.
def var val-contrato as dec.
def var val-total as dec.
def var vpla-cre as int.
def temp-table tt-contrato like contrato.
def var valsel-total as dec.
def var vtipvalor as char.
def var vdestip as char.
def var vemissao as dec.
def var vtttt as dec.
def var tot-tot as dec.

def shared temp-table tt-titulo
      field data      as date
      field etbcod like estab.etbcod
      field tipo      as char format "X(15)"  Label "Tipo"
      field titvlcob  like titulo.titvlcob label "Valor"
      field titvlpag  like titulo.titvlpag
      field entrada   as dec
      index ix is primary unique
                  tipo
                  etbcod
                  data
                  .
        
def temp-table tt-tituarqm like tituarqm.

        def var vdata as date.
        def var v1 as int.
        def var v2 as int.
        def var v3 as int.
        def var v4 as int.
        def var vtitnum like titulo.titnum.

def var tot-rec as dec.
def var tot-mes as dec.
def var tot-ger as dec.
def var tot-per as dec.
def var vok as log.
def var vql as int.
for each tt-estab no-lock:
    vok = no.
    for each ctcartcl where
                    ctcartcl.etbcod = tt-estab.etbcod and
                    ctcartcl.datref >= vdti and
                    ctcartcl.datref <= vdtf 
                    no-lock:
        tot-ger = tot-ger + ctcartcl.recebimento.        
        vok = yes.
    end.
    if vok = yes
    then vql = vql + 1.
end.
rec-atual = 0.
    
def temp-table tt-cl
    field etbcod like estab.etbcod
    field data   as date
    field valor as dec
    index i1 etbcod.
    
if tot-ger = 0
then return.

/*  
run valor-atual.
message tot-ger rec-atual. pause.
  */
def var dt-auxi as date.
def var dt-auxf as date.
def var vm-aux as int.
def var vd-aux as int.
def var va-aux as int.
vd-aux = 1.
vm-aux = month(vdti).
va-aux = year(vdti).

if vm-aux = 1
then assign
        va-aux = va-aux - 1
        vm-aux = 12.
else vm-aux = vm-aux - 1.
         
dt-auxi = date(vm-aux,vd-aux,va-aux).
dt-auxf = vdti - 1.
def var tot-anterior as dec init 0.
/* 
message vdti vdtf. pause.

for each tituarqm where
        tituarqm.datexp >= vdti and
        tituarqm.datexp <= vdtf
        no-lock:
    tot-anterior = tot-anterior + tituarqm.titvlcob.
end. 
message tot-ger rec-atual.   
message "Ant " tot-anterior. pause.

vtotal-sel = vtotal-sel + tot-anterior.

message vtotal-sel tot-ger - rec-atual. pause.

/* */
vtotal-sel = vtotal-sel - ( tot-ger - rec-atual ).
 */

message "Atu " vtotal-sel. pause.
    do:
        for each tt-estab no-lock:

            tot-rec = vtotal-sel / vql.
            tot-rec = tot-rec / 20.
            do vdata1 = vdti to vdtf:
                
                disp "Processando ... " tt-estab.etbcod vdata1 
                    with frame fxy1 no-label 1 down centered no-box
                    color message .
                    pause 0.
     
                if tot-tot + tot-rec > vtotal-sel
                then tot-rec = vtotal-sel - tot-tot.
                if tot-rec <= 0
                then leave.
                        
                if tot-rec <= 0 or
                   tot-rec = ?
                then next.
                vemissao = 0.
                   
                for each titulo use-index etbcod where
                         titulo.etbcobra = tt-estab.etbcod and
                         titulo.titdtpag = vdata1 no-lock :
                    if titulo.titvlcob = 0
                    then next.
                    if titulo.clifor = 1 
                    then next.
                    if titulo.titnat = yes 
                    then next.
                    if titulo.modcod <> "CRE" 
                    then next.
                    if titulo.titpar = 0
                    then next.
   
                    find tituarqm of titulo no-lock no-error.
                    if avail tituarqm and
                        tituarqm.etbcobra = tt-estab.etbcod and
                        tituarqm.titdtpag = vdata1
                    then next.                        
                
                    find first envfinan where 
                                       envfinan.empcod = 19
                                    and envfinan.titnat = no
                                    and envfinan.modcod = "CRE"
                                    and envfinan.etbcod = titulo.etbcod
                                    and envfinan.clifor = titulo.clifor
                                  and envfinan.titnum = titulo.titnum
                                    no-lock no-error.
                    if  avail envfinan
                    then next.

                    find cpcontrato where 
                         cpcontrato.contnum = int(titulo.titnum)
                         no-lock no-error.

                    if titulo.titdtemi >= 01/01/2009 and
                       not avail cpcontrato
                    then next.

                    if avail cpcontrato and
                        cpcontrato.indecf = no 
                    then next.

                    if avail cpcontrato and
                       cpcontrato.financeira <> 0
                    then next.

                    if vemissao + titulo.titvlcob <= tot-rec
                    then do:
                        vemissao = vemissao + titulo.titvlcob.
                        create tt-tituarqm.
                        buffer-copy titulo to tt-tituarqm.
                    end.
                end.
                /*    
                create per-estab.
                assign
                    per-estab.etbcod = tt-estab.etbcod
                    per-estab.data   = vdata1
                    per-estab.valor = vemissao
                    .
                */    
                tot-tot = tot-tot + vemissao.
                
                if tot-tot >= vtotal-sel
                then leave. 
            end.
            if tot-tot >= vtotal-sel
            then leave. 
        end.
    end.

def var vmes as int.
def var vdia as int.
def var vano as int.

def var vdt-prox as date.

vm-aux = month(vdtf).
va-aux = year(vdtf).

if vm-aux = 11
then assign
        vm-aux = 1
        va-aux = va-aux + 1.
else if vm-aux = 12
    then assign
            vm-aux = 2
            va-aux = va-aux + 1.
    else vm-aux = vm-aux + 2.

vdt-prox = date(vm-aux,01,va-aux) - 1. 
vdia = day(vdt-prox).

message "ATUALIZANDO DADOS......  AGUARDE!".
PAUSE 0.
    
for each tt-tituarqm:

    tt-tituarqm.titsit = "PAGCTB".

    create tituarqm.
    buffer-copy tt-tituarqm to tituarqm.

    vmes = month(tt-tituarqm.titdtpag) .
    if vmes = 12
    then assign
            vmes = 1
            vano = year(tt-tituarqm.titdtpag) + 1.
    else assign
            vmes = vmes + 1
            vano = year(tt-tituarqm.titdtpag).
    vdia = day(tt-tituarqm.titdtpag).
    if vmes = 2 and vdia > 28
    then vdia = 28.
    if vdia = 31 and 
        (vmes = 4 or vmes = 6 or vmes = 9 or vmes = 11)
    then vdia = 30.    
      
    tituarqm.datexp = date(vmes,vdia,vano).

    find first per-estab where
               per-estab.etbcod = tituarqm.etbcobra and
               per-estab.data   = tituarqm.titdtpag
                no-error.
    if not avail per-estab
    then do:              
         create per-estab.
                assign
                    per-estab.etbcod = tituarqm.etbcobra
                    per-estab.data   = tituarqm.titdtpag
                    .
    end.
    per-estab.valor = per-estab.valor + tituarqm.titvlcob.
                    
end.
/*
for each per-estab:
    find first ctcartcl where
                    ctcartcl.etbcod = per-estab.etbcod and
                    ctcartcl.datref = per-estab.data
                    no-error.
    if avail ctcartcl
    then do:
        find first tt-cl where 
                   tt-cl.etbcod = per-estab.etbcod and
                   tt-cl.data = per-estab.data
                   no-error.
        if avail tt-cl
        then ctcartcl.recebimento = tt-cl.valor - per-estab.valor.        
        else ctcartcl.recebimento = 0.
    end.
end.
*/

procedure valor-atual:

    for each tt-estab:       
         do vdata1 = vdti to vdtf:
            disp  "Processando ... " tt-estab.etbcod vdata1 
                with frame fxy1 no-label 1 down centered no-box
                color message .
             pause 0.
             
            
            for each titulo use-index etbcod where
                 titulo.etbcobra = tt-estab.etbcod and
                 titulo.titdtpag = vdata1 no-lock:
                 if titulo.titvlcob <= 0
                 THEN NEXT.
                if titulo.clifor = 1 then next.
                if titulo.titnat = yes then next.
                if titulo.titpar = 0 then next. 
                if titulo.modcod <> "CRE" then next.
                
                find tituarqm of titulo no-lock no-error.
                if avail tituarqm and
                    tituarqm.etbcobra = tt-estab.etbcod and
                    tituarqm.titdtpag = vdata1
                then next. 
                
                find first envfinan where 
                                       envfinan.empcod = 19
                                    and envfinan.titnat = no
                                    and envfinan.modcod = "CRE"
                                    and envfinan.etbcod = titulo.etbcod
                                    and envfinan.clifor = titulo.clifor
                                    and envfinan.titnum = titulo.titnum
                                    no-lock no-error.
                if  avail envfinan
                then next.
                
                find cpcontrato where 
                     cpcontrato.contnum = int(titulo.titnum)
                     no-lock no-error.
                 
                if titulo.titdtemi >= 01/01/2009 and
                   not avail cpcontrato
                then next.
                
                if avail cpcontrato and
                   cpcontrato.indecf = no 
                then next.

                if avail cpcontrato and
                    cpcontrato.financeira <> 0 
                then next.
                    
                rec-atual = rec-atual + titulo.titvlcob.
                find first tt-cl where
                           tt-cl.etbcod = tt-estab.etbcod and
                           tt-cl.data   = vdata1
                           no-error.
                if not avail tt-cl
                then do:
                    create tt-cl.
                    tt-cl.etbcod = tt-estab.etbcod.
                    tt-cl.data = vdata1.
                end.
                tt-cl.valor = tt-cl.valor + titulo.titvlcob.            
            end.
        end.
    end.
end procedure.
