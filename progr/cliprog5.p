{admcab.i}

def shared var vdti as date.
def shared var vdtf as date.

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

def temp-table per-estab
    field etbcod like estab.etbcod
    field data as date
    field indice as dec
    field valor as dec
    index i1 etbcod data.

def  shared temp-table tt-estab
    field etbcod like estab.etbcod
    .
find first ctcartcl where
           ctcartcl.datref >= vdti and
           ctcartcl.datref <= vdtf and
           ctcartcl.ecfprazo > 0 and
           ctcartcl.etbcod > 0
           no-lock no-error.
if not avail ctcartcl                                             
then do:
    message "PROCESSAR VENDAS." .
    PAUSE.
    return.               
end.
find first ctcartcl where
           ctcartcl.datref >= vdti and
           ctcartcl.datref <= vdtf and
           ctcartcl.acrescimo > 0 and
           ctcartcl.etbcod > 0
           no-lock no-error.
if not avail ctcartcl                                             
then do:
    message "PROCESSAR ACRESCIMOS." .
    PAUSE.
    return.               
end.

find first ctcartcl where
           ctcartcl.datref >= vdti and
           ctcartcl.datref <= vdtf and
           ctcartcl.dif-ecf-contrato > 0 and
           ctcartcl.etbcod > 0
           no-lock no-error.
if avail ctcartcl                                             
then do:
    message "JA PROCESSADO." .
    PAUSE.
    return.               
end.

def var tot-sel as dec.
def var vcobcod like cobra.cobcod.
do on error undo :
        vcobcod = 9.
        update vcobcod label "Cobranca"
            with frame fxz row 12 column 30 side-label overlay.
        if vcobcod > 0
        then do:
            find first cobra where cobra.cobcod = vcobcod no-lock no-error.
            if not avail cobra then undo.
            sresp = no.
            message "Confirma enviar Contratos selecionados ".
            message "Para " cobra.cobnom " ?" update sresp.
            if sresp = no
            then undo.
        end.
end.

sresp = no.
message "Confirma processamento? "  update sresp.
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
        
        def var vtotal-sel as dec.
        def var vdata as date.
        def var v1 as int.
        def var v2 as int.
        def var v3 as int.
        def var v4 as int.
        def var vtitnum like titulo.titnum.

        for each tt-estab no-lock:
            vpra-z = 0.
            vecf-z = 0.
            vacr-z = 0.
            do vdata1 = vdti to vdtf:
                for each ctcartcl where 
                           ctcartcl.etbcod = tt-estab.etbcod and
                           ctcartcl.datref = vdata1
                            no-lock :
                        vpra-z = vpra-z + ctcartcl.aprazo.
                        vecf-z = vecf-z + ctcartcl.ecfpraz.
                        vacr-z = vacr-z + ctcartcl.acrescimo.
                end.            
                if vpra-z > vecf-z 
                then  val-total = vpra-z - vecf-z.
                else next. 
                
                vemissao = 0.
                valsel-total = 0.

                for each contrato where 
                                 contrato.etbcod = tt-estab.etbcod and
                                 contrato.dtinicial = vdata1
                                 no-lock:
                    find first contnf where 
                            contnf.etbcod = contrato.etbcod and
                            contnf.contnum = contrato.contnum
                        no-lock no-error.
                    if not avail contnf
                    then next.
                    find first plani where plani.etbcod = contnf.etbcod and
                                 plani.placod = contnf.placod and
                                 plani.serie  = "V"
                                 no-lock no-error.
                    if avail plani and
                        plani.notped <> "C"
                    then next.           
                        
                    find first envfinan where 
                                       envfinan.empcod = 19
                                    and envfinan.titnat = no
                                    and envfinan.modcod = "CRE"
                                    and envfinan.etbcod = contrato.etbcod
                                    and envfinan.clifor = contrato.clicod
                                  and envfinan.titnum = string(contrato.contnum)
                                    no-lock no-error.
                    if  avail envfinan
                    then next.

                    find cpcontrato where 
                                cpcontrato.contnum = contrato.contnum
                                no-error.
                        
                    if not avail cpcontrato or
                            cpcontrato.indecf = no 
                    then next.
                
                    if cpcontrato.financeira <> 0
                    then next.
                
                    if cpcontrato.indacr = yes
                    then.
                    else do:
                        if vemissao + contrato.vltotal <= val-total
                        then do:
                                vemissao = vemissao + contrato.vltotal.
                                cpcontrato.financeira = vcobcod.
                        end.
                    end.
                end.
                create per-estab.
                assign
                    per-estab.etbcod = tt-estab.etbcod
                    per-estab.data   = vdata1
                    per-estab.valor = vemissao
                    .
 
            end.
        end.


message "ATUALIZANDO DADOS......   AGUARDE!".
PAUSE 0.

for each per-estab no-lock:
    find first ctcartcl where
                    ctcartcl.etbcod = per-estab.etbcod and
                    ctcartcl.datref = per-estab.data
                  no-error.
    ctcartcl.aprazo = ctcartcl.aprazo - per-estab.valor.        
end.


