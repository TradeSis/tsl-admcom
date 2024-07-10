
{admcab.i}
    
disable triggers for load of titulo.

def temp-table tt-estab
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
    
def var vetbcod  like estab.etbcod.
def var vdti     like plani.pladat.
def var vdtf     like plani.pladat.
def var vclicod  like clien.clicod.
def var vclinom  like clien.clinom.

def var tot-prazo as dec.
def var dvalorcet as dec decimals 6 format "->,>>9.999999". 
def var dvalorcetanual as dec decimals 6 format "->,>>9.999999".  
def var viof as dec.
def var vjuro as dec.
def var txjuro as dec.
def var vhist  as char.
  
def temp-table tt-titulo
      field data      as date
      field etbcod like estab.etbcod
      field tipo      as char format "X(15)"  Label "Tipo"
      field titvlcob  like titulo.titvlcob
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
repeat:
    
    update vetbi label "Filial inicio"  at 3
           vetbf label "Filial fim"
                with frame f1 side-label width 80.

    do on error undo, retry:
          update vdti label "Data Inicial" colon 16
                 vdtf label "Data Final" colon 16 with frame f1.
          if  vdti > vdtf
          then do:
                message "Data inválida".
                undo.
            end.
     end. 
    def var tit-valor like titulo.titvlcob.
    def var tit-juro  like titulo.titjuro.
    def var tt-indexvenda as dec.
    def var val-acrescimo as dec.
    def var vndx as dec.
    if opsys = "unix"
    then varqexp = "/admcom/audit/tit_" + trim(string(vetbcod,"999")) + "_" +
                string(day(vdti),"99") +  
                string(month(vdti),"99") +  
                string(year(vdti),"9999") + "_" + 
                string(day(vdtf),"99") +  
                string(month(vdtf),"99") +  
                string(year(vdtf),"9999") + ".txt".
    else varqexp = "l:\audit\tit_" + trim(string(vetbcod,"999")) + "_" + 
                string(day(vdti),"99") +   
                string(month(vdti),"99") +   
                string(year(vdti),"9999") + "_" +  
                string(day(vdtf),"99") +   
                string(month(vdtf),"99") +   
                string(year(vdtf),"9999") + ".txt".
                
    update val-acrescimo label "Acrescimo"   at 7 format ">>,>>>,>>9.99"
                    with frame f1.

    for each tt-estab: delete tt-estab. end.
   
    for each estab where estab.etbcod >= vetbi and
                         estab.etbcod <= vetbf
                     no-lock:
        create tt-estab.
        assign tt-estab.etbcod = estab.etbcod.             
    end.

    run gera-index.
    
    if val-acrescimo > 0
    then do:
        for each tt-estab no-lock:
            find first     titulo where 
                           titulo.empcod = 19  and 
                           titulo.titnat = no   and
                           titulo.modcod = "CRE" and      
                           titulo.etbcod = tt-estab.etbcod and
                           titulo.titdtven >= vdti and
                           titulo.titdtven <= vdtf and
                           titulo.titbanpag = 999
                       no-lock no-error.
            if avail titulo
            then do:
                bell.
                message color red/with
                 "Ja exite acrescimo informado no periodo ."
                view-as alert-box.
                pause 0.
                leave.
            end.    
        end.

        sresp = no.
        message "Confirma Acrescimo?" update sresp.
        if sresp
        then do:
            run /admcom/work/dilui_acr.p ( input vetbi, input vetbf,
                      input vdti, input vdtf,
                      input val-acrescimo).
        end.
    end.                  

    for each tt-estab no-lock:
        do vdata1 = vdti to vdtf:
            disp "Processando VENDA... " tt-estab.etbcod vdata1 
                with frame fxy no-label 1 down centered no-box
                color message .
             pause 0.
 
            for each plani where plani.movtdc = 5
                         and plani.etbcod = tt-estab.etbcod
                         and plani.pladat = vdata1
                         and plani.crecod = 2
                      /*   and plani.notped = "C" */ no-lock:
                find first contnf where contnf.etbcod = plani.etbcod
                           and contnf.placod = plani.placod no-lock
                           no-error.
                if not avail contnf
                then next.          
                for each titulo where 
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
                    then next.
                    */
                    find first tt-index use-index i1 where
                        tt-index.etbcod = titulo.etbcod and
                        tt-index.data = vdata1 no-lock no-error.
                    if avail tt-index and tt-index.indx = 0
                    then next.
                    if not avail tt-index 
                    then vndx = 1.
                    else vndx = tt-index.indx. 

                    if titulo.titbanpag = 888
                    then tit-valor = (titulo.titvlcob * vndx) + 1.
                    else tit-valor = (titulo.titvlcob * vndx).

                    vhist = "1-VENDA PRAZO".
                    run p-registro ("C",titulo.titdtemi,
                                  tit-valor,
                                  tit-valor,
                                  "+").
                
                    if titulo.titbanpag = 999
                    then do:
                        vhist = "2-ACRESCIMO".
                        run p-registro ("A",titulo.titdtemi,
                                  titulo.titvlcob - (titulo.titvlcob * vndx),
                                  titulo.titvlcob - (titulo.titvlcob * vndx),
                                  "+").
                    end.
                end.  
            end. 
        end.
    end.    
    
    run ch-ven.
    
    for each bin-titulo where
             bin-titulo.marca = 888 no-lock:
        find titulo where recid(titulo) = bin-titulo.titvlrec
            no-lock no-error.
        if avail titulo and titulo.titbanpag = 888
        then do:  
            find first tt-estab where 
                       tt-estab.etbcod = titulo.etbcod 
                       no-lock no-error.
            vhist = "1-VENDA PRAZO".
            run p-registro ("C",titulo.titdtemi,
                            1,
                            1,
                             "+").
        end.
    end.
    
    for each tt-estab no-lock:
        do vdata1 = vdti to vdtf:
            disp "Processando RECEB... " tt-estab.etbcod vdata1 
                with frame fxy1 no-label 1 down centered no-box
                color message .
             pause 0.
     
            for each titulo use-index etbcod where
                 titulo.etbcobra = tt-estab.etbcod and
                 titulo.titdtpag = vdata1 no-lock:

                if titulo.clifor = 1 or
                   titulo.titnat = yes or
                   titulo.titpar = 0 or
                   titulo.modcod <> "CRE" 
                then next.
                /*
                if titulo.etbcod = tt-estab.etbcod and
                   titulo.titpar = 0
                then next .
                */

                find first tt-index use-index i1 where
                   tt-index.etbcod = titulo.etbcod and
                   tt-index.data = titulo.titdtemi no-lock no-error.

                if not avail tt-index or tt-index.indx = 0
                then vndx = 1.
                else vndx = tt-index.indx .
                if titulo.titdtemi < 01/01/09
                then vndx = 1.

                if titulo.titbanpag = 999
                then tit-valor = titulo.titvlcob.
                else tit-valor = titulo.titvlcob * vndx.
                if titulo.titbanpag = 888
                then tit-valor = tit-valor + 1.
                
                if titulo.moecod = "DEV"
                then do:
                    vhist = "5-DEVOLUCAO".
                    run p-registro ("D",titulo.titdtpag,
                                   tit-valor,
                                   tit-valor,
                                   "-").
                end.
                else if titulo.moecod = "NOV"
                then do:
                    vhist = "6-NOVACAO".
                    run p-registro ("N",titulo.titdtpag,
                                   tit-valor,
                                   tit-valor,
                                   "-").
 
                end.
                else do:   
                    vhist = "3-RECEBIMENTOS".
                    run p-registro ("R",titulo.titdtpag,
                                   tit-valor,
                                   tit-valor,
                                   "-").
                                   
                    if titulo.titjuro > 0
                    then do:
                        if titulo.titbanpag = 999
                        then tit-juro = titulo.titjuro.
                        else tit-juro = titulo.titjuro * vndx.
                        vhist = "4-JUROS".
                        run p-registro ("J",titulo.titdtpag,
                                        tit-juro, 
                                        tit-juro,
                                        "+").
                    end.
                end.       
            end.
        end.
        /*
        for each tt-titulo where
                tt-titulo.etbcod = tt-estab.etbcod.
            disp tt-titulo.
        end.        
        pause.
        */
    end.
    
    put unformat skip.

    output close.

    if opsys = "UNIX"
    then varquivo = "../relat/tit_aud" + string(time).
    else varquivo = "l:\relat\tit_aud" + string(time).

    {mdad.i
            &Saida     = "value(varquivo)"
            &Page-Size = "64"
            &Cond-Var  = "90"
            &Page-Line = "66"
            &Nom-Rel   = ""TIT_AUD""
            &Nom-Sis   = """SISTEMA DE CONTABILIDADE"""
            &Tit-Rel   = """ CARTEIRA DE CLIENTES - "" 
                            + string(vdti,""99/99/9999"") + "" a ""
                            + string(vdtf,""99/99/9999"")
                            "
            &Width     = "90"
            &Form      = "frame f-cabcab"}


    view frame f-cabcab.
    if vetbcod = 0
    then put unformat skip "Estabelecimento: - 0 GERAL" SKIP.
    else do:
      find estab where estab.etbcod = vetbcod no-lock no-error.
      put unformat skip "Estabelecimento: " estab.etbcod " - " estab.etbnom
            skip.
    end.       

    for each tt-titulo 
             where tt-titulo.etbcod = 0  no-lock:
        disp tt-titulo except tt-titulo.data.
    end.
    put skip (2).
     
    output close.     

    if opsys = "UNIX"
    then do:
     run visurel.p(input varquivo, input "").
    end.
    else do:
     {mrod.i} 
    end. 
     
    def var vx as char.
    input from value(varqexp).
    repeat:
        import unformat vx.
        disp  length(vx) 
         vx format "x(5)"
         substring(vx,24) format "x(10)"
         substring(vx,44) format "x(10)"
         substring(vx,71) format "x(10)"
         substring(vx,104) format "x(5)"
         substring(vx,144) format "x(5)"
         .
    end.


    if opsys = "unix"
    then do.
        unix silent chmod 777 value(varqexp).
    end.
    leave.
end.

procedure p-registro.
    def input parameter voper as char.
    def input parameter vdtoper as date.
    def input parameter vtitvlcob as dec.
    def input parameter vtitvlpag as dec.
    def input parameter vsinal   as char.

    find first in-titulo where
               in-titulo.titvlrec = recid(titulo) no-error.
    if not avail in-titulo
    then do:
        create in-titulo.
        in-titulo.titvlrec = recid(titulo).
    end.
    if voper = "C"
    then in-titulo.titvlcob = in-titulo.titvlcob + vtitvlcob.
    else if voper = "A"
    then in-titulo.titvlacr = vtitvlcob.
    else if voper = "D"
    then in-titulo.titvldev = vtitvlcob.
    else if voper = "N"
    then in-titulo.titvlnov = vtitvlcob.
    else if voper = "R"
    then in-titulo.titvlpag = vtitvlcob.
    else if voper = "J"
    then in-titulo.titvljur = vtitvlcob.
               
    /*** teste relatório 
    */

    put unformat skip
     titulo.etbcod format ">>9"           /* 01-03 */
     string(titulo.clifor) format "x(18)" /* 04-21 */
     "TIT "  format "x(5)"                /* 22-26 */
     " " format "X(5)"                    /* 27-31 */ 
     titulo.titnum format "999999999999"  /* 32-43 */
     year(vdtoper) format "9999"          /* 44-51 */
     month(vdtoper) format "99"          
     day(vdtoper)   format "99"
     voper     format "x(3)"             /* 52-54 */
     vtitvlpag              format "9999999999999.99" /* 55-70 */
     vsinal                 format "x(1)"             /* 71 */
     year(titulo.titdtemi)  format "9999" /* 72-79 */
     month(titulo.titdtemi) format "99"  
     day(titulo.titdtemi)   format "99"
     Vtitvlcob format "9999999999999.99"  /* 80-95 */
     year(titulo.titdtven) format "9999"  /* 96-103 */
     month(titulo.titdtven) format "99"  
     day(titulo.titdtven) format "99"
     titulo.titnum        format "x(12)" /* 104-115 nro arquivamento */   
     " " format "x(28)"                  /* 116-143 cod.contabil */
     vhist format "x(250)"               /* 144-393  Histórico */ .
     
    /***/

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
        disp "Processando INDEX...       "
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
    output to /admcom/progr/diauxcli.ndx .
    for each tt-index no-lock:
        export tt-index.
    end.
    output close.    
end procedure.
procedure ch-ven:
    find first tt-titulo where
               tt-titulo.etbcod = 0 and
               tt-titulo.tipo = "1-VENDA PRAZO"
               no-lock no-error.
 
    tt-indexvenda = 0.
    for each tt-estab no-lock:
        find first tt-index where
                   tt-index.etbcod = tt-estab.etbcod and
                   tt-index.data  >= vdti and
                   tt-index.data  <= vdtf no-lock.
        tt-indexvenda = tt-indexvenda + tt-index.venda.
    end.        
    
    if tt-titulo.titvlcob <> tt-indexvenda  and
       (tt-indexvenda - tt-titulo.titvlcob) >= 1  
    then do:
        run /admcom/work/chega_venda.p(input vetbi, input vetbf,
                      input vdti, input vdtf,
                      input (tt-indexvenda - tt-titulo.titvlcob)).
    end.

end procedure.
