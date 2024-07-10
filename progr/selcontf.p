
{admcab.i}
    
disable triggers for load of titulo.

def new shared temp-table tt-estab
       field etbcod as int
       index ind1 etbcod.

def var varquivo as char.
def var varqexp  as char.

def new shared temp-table tt-venda
        field etbcod like estab.etbcod
        field data as date
        field vl-prazo as dec 
        field vl-vista as dec
        index i1 etbcod data.
 
def new shared temp-table tt-titulo
      field data      as date
      field etbcod like estab.etbcod
      field tipo      as char format "X(15)"  Label "Tipo"
      field titvlcob  like titulo.titvlcob label "Valor"
      field titvlpag  like titulo.titvlpag
      index ix is primary unique
                  tipo
                  etbcod
                  .
def new shared temp-table tt-index
    field etbcod like estab.etbcod
    field data as date
    field indx as dec 
    field venda as dec 
    field titulo as dec
    field vl-prazo as dec  decimals 2
    field vl-titulo as dec decimals 2
    index i1 etbcod data.
    
def var vetbcod  like estab.etbcod.
def new shared var vdti     like plani.pladat.
def new shared var vdtf     like plani.pladat.
def var vclicod  like clien.clicod.
def var vclinom  like clien.clinom.

def var tot-prazo as dec.
def var dvalorcet as dec decimals 6 format "->,>>9.999999". 
def var dvalorcetanual as dec decimals 6 format "->,>>9.999999".  
def var viof as dec.
def var vjuro as dec.
def var txjuro as dec.
def var vhist  as char.
  
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
def var val-contrato as dec.
def var val-total as dec.
def var vpla-cre as int.
def temp-table tt-contrato like contrato.
def var valsel-total as dec.
def var vtipvalor as char.
def var vdestip as char.
repeat:
    /*
    update vetbi label "Filial inicio"  at 3
           vetbf label "Filial fim"
                with frame f1 side-label width 80.
    */
    update vetbi label "Filial" colon 20
                with frame f1 side-label width 80.
 
    do on error undo, retry:
          update vdti label "Periodo" colon 20
                 vdtf label "A"  with frame f1.
          if  vdti > vdtf
          then do:
                message "Data inválida".
                undo.
            end.
     end. 
     update vpla-cre colon 20 label "Plano de Pagamento"
        with frame f1.
    def var tit-valor like titulo.titvlcob.
    def var tit-juro  like titulo.titjuro.
    def var tt-indexvenda as dec.
    def var val-acrescimo as dec.
    def var vndx as dec.
    
    vtipvalor = ">".
    vdestip = "Maior".
    val-contrato = 0.
    disp vtipvalor label "Valor dos Contratos" colon 20
         vdestip 
         val-contrato with frame f1.
    update vtipvalor auto-return format "X"
            help "Informe >Maior <Menor =Igual"
             with frame f1.
    if vtipvalor = "=" then vdestip = "Igual".
    if vtipvalor = ">" then vdestip = "Maior".
    if vtipvalor = "<" then vdestip = "Menor".
    disp vdestip no-label with frame f1.
    
    update val-contrato no-label format ">>>,>>>,>>9.99"
        with frame f1.
 
    update val-total colon 20
        label "Valor acumulado de" format ">>>,>>>,>>9.99"
        with frame f1.
    for each tt-estab: delete tt-estab. end.

    for each estab where (if vetbi > 0
                        then estab.etbcod = vetbi else true)
                     no-lock:
        create tt-estab.
        assign tt-estab.etbcod = estab.etbcod.             
    end.

    if vetbi = 0
    then  do:
        run difvetit.p.
    end.

    valsel-total = 0.
    for each tt-contrato:
        delete tt-contrato.
    end.    
    if val-total = 0 and vetbi > 0
    then do:
    for each tt-estab no-lock:
        do vdata1 = vdti to vdtf:
            disp "Processando ... " tt-estab.etbcod label "Filial"  
                with frame fxy  1 down centered no-box
                color message .
             pause 0.                                               
 
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
                
                if vpla-cre > 0 and
                   vpla-cre <> contrato.crecod
                then next.   
                
                if val-contrato > 0 
                then do:
                    if vtipvalor = "=" and
                        val-contrato <> contrato.vltotal
                    then next.
                    else if vtipvalor = ">" and
                        val-contrato >= contrato.vltotal
                    then next.
                    else if vtipvalor = "<" and
                        val-contrato <= contrato.vltotal
                    then next.    
                end.    
                create tt-contrato.
                buffer-copy contrato to tt-contrato.
                valsel-total = valsel-total + contrato.vltotal.
                disp valsel-total label "Valor total" 
                    format ">>,>>>,>>>,>>9.99" with frame fxy.
                pause 0.
            end. 
        end.
    end.
    end.
    else do:
        
        def var vtotal-sel as dec.
        def var vdata as date.
        def var v1 as int.
        def var v2 as int.
        def var v3 as int.
        def var v4 as int.
        def var vtitnum like titulo.titnum.

        v2 = 0.
        v3 = 0.
        repeat:
            do vdata1 = vdti to vdtf:
                for each tt-estab  no-lock.
                    find first tt-venda where 
                            tt-venda.etbcod = tt-estab.etbcod
                            no-lock no-error.
                    find first tt-titulo where
                            tt-titulo.etbcod = tt-estab.etbcod
                            no-lock no-error.
                    val-total = tt-titulo.titvlcob - tt-venda.vl-prazo.
                    v2 = v2 + 1.
                    v3 = v3 + 1.
                    do v1 = 1 to v2:
                        for each contrato where 
                                 contrato.etbcod = tt-estab.etbcod and
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

                            find first tt-contrato where 
                                       tt-contrato.contnum = contrato.contnum
                                       no-lock no-error.
                            if avail tt-contrato
                            then next.           
                            if vpla-cre > 0 and
                                vpla-cre <> contrato.crecod
                            then next.   
                
                            if val-contrato > 0 and 
                                val-contrato <> contrato.vltotal
                            then next.
                    
                            if v2 >= 3 
                            then do:
                                if v3 >= 10
                                then do:
                                    v3 = 0.
                                    v2 = 3.
                                end.
                                else v2 = 0. 
                            end.
                            if val-total + 50 >= valsel-total
                            then do:
                            create tt-contrato.
                            buffer-copy contrato to tt-contrato.
                            valsel-total = valsel-total + contrato.vltotal.
                            end.
                            
                            disp "Processando ... " 
                                tt-estab.etbcod label "Filial"  
                                with frame fxw  1 down centered no-box
                                color message .
                            pause 0.       
                            disp valsel-total label "Valor total" 
                                format ">>,>>>,>>>,>>9.99" with frame fxw.
                            pause 0.
                            leave.
                        end.
                        if valsel-total >= val-total
                        then leave.
                    end.
                    if valsel-total >= val-total
                    then leave.
                end.
                if valsel-total >= val-total
                then leave.
            end.
            if valsel-total >= val-total
            then leave.
        end.
    end.
    disp valsel-total label "Valor total selecionado"
                        format ">>,>>>,>>>,>>9.99" with frame fxz
                        side-label row 10 centered.
                        
    pause 0.
    def var vcobcod like cobra.cobcod.
    repeat on error undo :
        update vcobcod with frame fxz.
        if vcobcod > 0
        then do:
            find first cobra where cobra.cobcod = vcobcod no-lock no-error.
            if not avail cobra then undo.
            sresp = no.
            message "Confirma enviar Contratos selecionados ".
            message "Para " cobra.cobnom " ?" update sresp.
            if sresp = no
            then undo.
            for each tt-contrato no-lock:
                disp "Enviando contratos ... " 
                                tt-contrato.contnum 
                                with frame fxa  1 down centered no-box
                                color message row 18.
                            pause 0.       
 
                for each titulo where 
                         titulo.empcod = 19 and
                         titulo.titnat = no and
                         titulo.modcod = "CRE" and
                         titulo.etbcod = tt-contrato.etbcod and
                         titulo.clifor = tt-contrato.clicod and
                         titulo.titnum = string(tt-contrato.contnum)
                         :
                    titulo.cobcod = vcobcod.
                end.
            end. 
            message "CONTRATOS ENVIADOS...". 
            PAUSE.
        end.        
    end.    
end.    
