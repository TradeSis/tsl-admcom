{admcab.i}
    
def shared var vdti as date.
def shared var vdtf as date.

def temp-table tt-venda
        field etbcod like estab.etbcod
        field data as date
        field aprazo as dec
        field recebi as dec
        field juros  as dec
        index i1 etbcod data.
 
def shared temp-table tt-index
    field etbcod like estab.etbcod
    field data as date
    field indx as dec 
    field venda as dec 
    field titulo as dec
    field vl-prazo as dec  decimals 2
    field vl-titulo as dec decimals 2
    index i1 etbcod data.

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

def var vrec1 as dec.
def var vrec2 as dec.

def var vemissao as dec.
def var vrecebimento as dec.
def var vjuro as dec.
def var vtitvlcob as dec.

def var vacrescimo as dec.
def var vemiacre as dec.
def shared temp-table tt-estab
    field etbcod like estab.etbcod
    .
def var varqexp as char.
def stream tl .
def var vdata1 as date. 
def var vhist as char.
def var vetbcod like estab.etbcod.
def var vdec3 as dec format ">>,>>>,>>9.99".
def var vdif as dec format "->>,>>9.99".
def var vtipo as LOG FORMAT "Sim/Nao".
message "Acrescimo?" update vtipo.

L1:
    for each tt-estab:       
         do vdata1 = vdti to vdtf:

             for each contrato where contrato.etbcod = tt-estab.etbcod and
                                    contrato.dtinicial = vdata1 and
                                    contrato.vltotal > 1000
                                    no-lock:
                if contrato.vltotal <= 0
                then next.
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
                if vtipo 
                then do: 
                if cpcontrato.indacr = yes    and
                   contrato.vltotal > cpcontrato.dec3
                then do with frame f-altera down:
                    vacrescimo = contrato.vltotal - cpcontrato.dec3.
                    vdec3 = cpcontrato.dec3.
                    disp contrato.etbcod contrato.vltotal cpcontrato.dec3 vacrescimo
                    .
                    repeat with frame f-altera:
                    update vdif.
                    leave.
                    end.
                    if keyfunction(lastkey) = "end-error"
                    then leave l1.
                    vacrescimo = contrato.vltotal - (vdec3 + vdif).
                    disp vacrescimo.
                    pause.
                    cpcontrato.dec3 = vdec3 + vdif.
                    down with frame f-altera.
                end.
                end.
                else do:
                if cpcontrato.indacr = no    and
                   contrato.vltotal = cpcontrato.dec3
                then do with frame f-altera1 down:
                    vdec3 = cpcontrato.dec3.
                    disp contrato.etbcod contrato.vltotal cpcontrato.dec3 
                    .
                    repeat with frame f-altera1:
                    update vdif.
                    leave.
                    end.
                    
                    if keyfunction(lastkey) = "end-error"
                    then leave l1.
                    vdec3 = vdec3 + vdif.
                    
                    vdif = cpcontrato.dec3 - vdec3.
                    disp vdec3 vdif.
                    
                    pause.
                    
                    cpcontrato.dec3 = vdec3 .
                    cpcontrato.carteira = 77.
                    
                    down with frame f-altera1.
                end.
    
                end.
            end.
        end.
    end.                                    
