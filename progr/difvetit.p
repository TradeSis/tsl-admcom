{admcab.i}
    
disable triggers for load of titulo.

def shared temp-table tt-estab
       field etbcod as int
       index ind1 etbcod.

def var varquivo as char.
def var varqexp  as char.

def new shared temp-table tt-index
    field etbcod like estab.etbcod
    field data as date
    field indx as dec 
    field venda as dec 
    field titulo as dec
    field vl-prazo as dec  decimals 2
    field vl-titulo as dec decimals 2
    index i1 etbcod data.
    
def shared temp-table tt-venda
        field etbcod like estab.etbcod
        field data as date
        field vl-prazo as dec 
        field vl-vista as dec
        index i1 etbcod data.
                                    
def var vetbcod  like estab.etbcod.
def shared var vdti     like plani.pladat.
def shared var vdtf     like plani.pladat.
def var vclicod  like clien.clicod.
def var vclinom  like clien.clinom.

def var tot-prazo as dec.
def var dvalorcet as dec decimals 6 format "->,>>9.999999". 
def var dvalorcetanual as dec decimals 6 format "->,>>9.999999".  
def var viof as dec.
def var vjuro as dec.
def var txjuro as dec.
def var vhist  as char.
  
def shared temp-table tt-titulo
      field data      as date
      field etbcod like estab.etbcod
      field tipo      as char format "X(15)"  Label "Tipo"
      field titvlcob  like titulo.titvlcob label "Valor"
      field titvlpag  like titulo.titvlpag
      index ix is primary unique
                  tipo
                  etbcod
                  .
def new shared temp-table in-titulo
    field titvlrec as recid
    field titvlcob as dec
    field titvlpag as dec
    field titvlacr as dec
    field titvldev as dec
    field titvlnov as dec
    field titvljur as dec
    field marca    as int
    index i1 titvlrec
    index i2 marca.

def buffer bin-titulo for in-titulo.

FUNCTION f-troca returns character
    (input cpo as char).
    def var v-i as int.
    def var v-lst as char extent 60
       init ["@",":",";",".",",","*","/","-",">","!","'",'"',"[","]"].
         
    if cpo = ?
    then cpo = "".
    else do v-i = 1 to 30:
         cpo = replace(cpo,v-lst[v-i],"").
    end.
    return cpo. 
end FUNCTION.
if search("/admcom/progr/diauxcli.ndx") <> ?
then do:
input from /admcom/progr/diauxcli.ndx .
repeat:
    create tt-index.
    import tt-index.
end.
input close.
end.    
def var tot-titulo as dec.
def var vetbi like estab.etbcod.
def var vetbf like estab.etbcod.
def var vdata1 as date.
def buffer bplani for plani.
def buffer bmovim for movim.

def temp-table tt-dev
    field numero like plani.numero
    field numdev like plani.numero
    field pladat like plani.pladat
    field datdev as date
    field clicod like clien.clicod
    field val-dev as dec
    field val-atu as dec
    index i1 clicod numero
    .

def var vprazo as dec.
def var vvista as dec.

repeat:
    def var tit-valor like titulo.titvlcob.
    def var tit-juro  like titulo.titjuro.
    def var tt-indexvenda as dec.
    def var val-acrescimo as dec.
    def var vndx as dec.
    for each tt-estab: delete tt-estab. end.
   
    for each estab where
             estab.etbnom begins "DREBES-FIL" no-lock:
        create tt-estab.
        tt-estab.etbcod = estab.etbcod.             
    end.
    run gera-index.

    for each tt-estab no-lock:
        do vdata1 = vdti to vdtf:
            disp "Processando Emissao... " tt-estab.etbcod vdata1 
                with frame fxy no-label 1 down centered no-box
                color message .
             pause 0.
            for each tt-dev: delete tt-dev. end.
            for each contrato where contrato.etbcod = tt-estab.etbcod and
                                    contrato.dtinicial = vdata1
                                    no-lock:
                find first titulo where 
                           titulo.empcod = 19 and
                           titulo.titnat = no and
                           titulo.modcod = "CRE" and
                           titulo.etbcod = contrato.etbcod and
                           titulo.clifor = contrato.clicod and
                           titulo.titnum = string(contrato.contnum) and
                           titulo.titpar = 1
                           no-lock no-error.
                if not avail titulo then next.
                if titulo.cobcod <> 2
                then next.

                vhist = "1-EMISSAO".
                run p-registro ("C",contrato.dtinicial,
                                    contrato.vltotal,
                                    0,
                                  "+").
                
            end. 
            for each fiscal where fiscal.movtdc = 12           and
                          fiscal.emite  = tt-estab.etbcod and
                          fiscal.opfcod = 1202         and
                          fiscal.plarec = vdata1     
                          no-lock: 
                          
        
                vprazo = 0.
                vvista = fiscal.platot.
                run devol-vp.
                vvista = vvista - vprazo.

                if vvista < 0
                then vvista = 0.

                if fiscal.platot < vvista + vprazo
                then do:
                    if vvista > 0
                    then vvista = fiscal.platot - vprazo.
                    else vprazo = fiscal.platot.
                end.
            end.
            for each tt-dev:
                vhist = "1-EMISSAO".
                run p-registro ("B",tt-dev.pladat,
                                    tt-dev.val-dev,
                                    0,
                                  "+").

                vhist = "2-DEVOLUCAO".
                run p-registro ("B",tt-dev.datdev,
                                    tt-dev.val-dev,
                                    0,
                                  "+").
  
            end.
        end.
    end.    

    leave.
end.

procedure p-registro.
    def input parameter voper as char.
    def input parameter vdtoper as date.
    def input parameter vtitvlcob as dec.
    def input parameter vtitvlpag as dec.
    def input parameter vsinal   as char.

    find first tt-titulo where 
                       tt-titulo.tipo = vhist 
                   and tt-titulo.etbcod = tt-estab.etbcod no-lock no-error.
    if not avail tt-titulo
    then do:
       create tt-titulo.
       assign tt-titulo.data = vdtoper
              tt-titulo.etbcod = tt-estab.etbcod
              tt-titulo.tipo = vhist.
    end.
    assign tt-titulo.titvlpag = tt-titulo.titvlpag + vtitvlpag
         tt-titulo.titvlcob = tt-titulo.titvlcob + 
                              (if voper = "j" then vtitvlpag else vtitvlcob).

    find first tt-titulo where 
                       tt-titulo.tipo = vhist 
                   and tt-titulo.etbcod = 0 no-error.
    if not avail tt-titulo
    then do:
       create tt-titulo.
       assign tt-titulo.data = vdtoper
              tt-titulo.etbcod = 0
              tt-titulo.tipo = vhist.
    end.
    assign tt-titulo.titvlpag = tt-titulo.titvlpag + vtitvlpag
         tt-titulo.titvlcob = tt-titulo.titvlcob + 
                              (if voper = "j" then vtitvlpag else vtitvlcob).

    
end.

procedure gera-index:
    def var vdata as date.
    def var vlvist as dec.
    def var vlpraz as dec.
    def var totecf as dec.
    def var vtottit as dec.

    for each tt-estab no-lock:
        find estab where estab.etbcod = tt-estab.etbcod no-lock.
        disp "Processando INDEX-VENDAS...       "
        estab.etbcod with frame f-ndx 1 down no-label
            centered color  message no-box.
        pause 0.
        tot-prazo = 0.
        tot-titulo = 0.
        do vdata = vdti to vdtf:
            disp vdata with frame f-ndx.
            pause 0.
            assign vlvist = 0. vlpraz = 0. totecf = 0. vtottit = 0.
            for each tt-index where tt-index.etbcod = estab.etbcod and
                                    tt-index.data   = vdata
                                    :
                delete tt-index.
            end.                        
            for each plani use-index pladat 
                                     where plani.movtdc = 5 and
                                           plani.etbcod = estab.etbcod and
                                           plani.pladat = vdata no-lock.
                if plani.crecod = 1
                then vlvist = vlvist + plani.platot.
                if plani.crecod = 2
                then do:
                    vlpraz = vlpraz + plani.platot.
                    find first contnf where contnf.etbcod = plani.etbcod
                           and contnf.placod = plani.placod no-lock
                           no-error.
                    if  avail contnf then 
                    for each  titulo where 
                           titulo.empcod = 19  and 
                           titulo.titnat = no   and
                           titulo.modcod = "CRE" and      
                           titulo.etbcod = plani.etbcod and
                           titulo.clifor = plani.desti and
                           titulo.titnum = string(contnf.contnum) 
                           no-lock.
                        if titulo.clifor = 1 or
                            titulo.titnat = yes or
                            titulo.titpar = 0 or
                            titulo.modcod <> "CRE" 
                        then next.
                        /*
                        if titulo.titdtemi <> plani.pladat
                        then next. */
                        vtottit = vtottit + titulo.titvlcob.
                    end.       
                end.
            end.
            for each mapctb where mapctb.etbcod = estab.etbcod and
                                  mapctb.datmov = vdata no-lock.

                if mapctb.ch2 = "E"                 
                then next.
                 
                totecf = totecf + 
                        (mapctb.t01 + 
                         mapctb.t02 + 
                         mapctb.t03 +
                         mapctb.vlsub).
            
            end.

            if vlpraz > 0
            then do:
                if vlvist < vlpraz
                then do:
                    vlvist = (vlvist / vlpraz) * totecf.
                    vlpraz = totecf - vlvist.
                end.
                else do:
                    vlpraz = (vlpraz / vlvist) * totecf.
                    vlvist = totecf - vlpraz.
                end.
            end.
            else vlvist = totecf.
            find first tt-venda where
                       tt-venda.etbcod = estab.etbcod no-error.
            if not avail tt-venda
            then do:
                create tt-venda.
                tt-venda.etbcod = estab.etbcod.
            end.
            assign
                tt-venda.vl-vista = tt-venda.vl-vista + vlvist
                tt-venda.vl-prazo = tt-venda.vl-prazo + vlpraz.
                        
            find first tt-index where
                       tt-index.etbcod = estab.etbcod and
                       tt-index.data   = vdata
                       no-error.
            if not avail tt-index
            then do:
                create tt-index.
                assign
                    tt-index.etbcod = estab.etbcod
                    tt-index.data = vdata.
            end.     

            tot-prazo = tot-prazo + vlpraz.
            tot-titulo = tot-titulo + vtottit.
            if vlpraz > 0 and
               vtottit > 0
            then tt-index.indx = vlpraz / vtottit.
            else tt-index.indx = 0.
            tt-index.vl-prazo = vlpraz.
            tt-index.vl-titulo = vtottit.
        end.
        for each tt-index where tt-index.etbcod = estab.etbcod and
                    tt-index.data >= vdti and
                    tt-index.data <= vdtf:
            tt-index.venda = tot-prazo.
            tt-index.titulo = tot-titulo.
        end.
    end.
end procedure.

procedure devol-vp:
    def var vtotpla as dec.
    def var vtotpro as dec.
    def var vqtmpro as dec.
    def buffer bplani for plani.
    def buffer cplani for plani.
    def buffer cmovim for movim.
    find plani where plani.etbcod = tt-estab.etbcod 
                     and plani.emite  = fiscal.emite  
                     and plani.movtdc = fiscal.movtdc  
                     and plani.serie  = fiscal.serie  
                     and plani.numero = fiscal.numero 
                                   no-lock no-error.
    if avail plani
    then do:
        vtotpro = 0.
        for each movim where movim.etbcod = plani.etbcod and
                         movim.placod = plani.placod and
                         movim.movtdc = plani.movtdc and
                         movim.movdat = plani.pladat
                         no-lock: 
            vtotpro = vtotpro + movim.movpc * movim.movqtm.   
            vqtmpro = movim.movqtm.                              
            for each ctdevven where 
                    ctdevven.movtdc = plani.movtdc and
                    ctdevven.etbcod = plani.etbcod and
                    ctdevven.placod = plani.placod
                    no-lock:
                find first  cplani where 
                            cplani.movtdc = ctdevven.movtdc-ori and
                            cplani.etbcod = ctdevven.etbcod-ori and
                            cplani.placod = ctdevven.placod-ori
                            no-lock no-error.
                if avail cplani and cplani.crecod = 2
                then do:
                    for each cmovim where cmovim.movtdc = cplani.movtdc and
                             cmovim.etbcod = cplani.etbcod and
                             cmovim.placod = cplani.placod and
                             cmovim.movdat = cplani.pladat and
                             cmovim.procod = movim.procod
                             no-lock:
                        find first tt-dev where
                                   tt-dev.clicod = cplani.desti  and
                                   tt-dev.numero = cplani.numero
                                   no-lock no-error.
                        if not avail tt-dev
                        then do:
                                create tt-dev.
                                assign
                                tt-dev.clicod = cplani.desti 
                                tt-dev.numero = cplani.numero
                                tt-dev.numdev = plani.numero
                                tt-dev.pladat = cplani.pladat
                                tt-dev.datdev = plani.pladat.
                            
                        end.    
                        if cmovim.movqtm <= vqtmpro
                        then tt-dev.val-dev = tt-dev.val-dev +
                                (movim.movpc * cmovim.movqtm).
                        else tt-dev.val-dev = tt-dev.val-dev +
                                (movim.movpc * vqtmpro).
                        if cmovim.movqtm <= vqtmpro
                        then vprazo = vprazo + 
                                (movim.movpc * cmovim.movqtm).
                        else vprazo = vprazo +
                                (movim.movpc * vqtmpro).

                    end.
                end.
            end.                                             
        end.
    end.
end procedure.

