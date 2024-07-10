{admcab.i}

define variable vdti         as date      no-undo.
define variable vdtf         as date      no-undo.
define variable varquivo     as character no-undo.
define variable recimp       as recid     no-undo.
define variable fila         as character no-undo.
define variable vdias-atraso  as integer   no-undo.
define variable vdias-transp  as integer   no-undo.
define variable vdias-antecip as integer   no-undo.
define variable v-prazo       as integer   no-undo.
define variable v-prazo-aux   as character no-undo.
define variable vok           as logical   no-undo.
define variable totped         like plani.platot no-undo.
define variable frete_unitario like plani.platot no-undo.
define variable qtd_total     as integer   no-undo.
define variable div-perc-aux  like movim.movpc no-undo.

define temp-table tt-cabec no-undo
    field nf            like plani.numero
    field ped           like pedid.pednum
    field pladat        as date
    field peddti        as date
    field peddtf        as date
    field dtinclu       as date
    field dias-atraso   as integer
    field dias-transp   as integer
    field dias-antecip  as integer
    field prazo-pagto   as integer
    field frete         like plani.frete
    index tt-01 dtinclu. 

def temp-table wprodu
    field nf     like plani.numero
    field wcod   like produ.procod
    field qent   like movim.movqtm
    field qped   like movim.movqtm
    field pent     like movim.movpc  format ">>,>>9.99"
    field pped     like movim.movpc  format ">>,>>9.99"
    field div-val  like movim.movpc  format "->>,>>9.99"
    field div-perc as character.


repeat:
    
    update vdti format "99/99/9999" label "Periodo de"
           "a"
           vdtf format "99/99/9999" no-label with frame f-dat centered color blue/cyan row 8 column 10 title " Periodo " side-labels.

           if opsys = "UNIX"
           then varquivo = "../relat/relcomp" + string(time).
           else varquivo = "..\relat\relcomp" + string(time).

    {mdad.i
            &Saida     = "value(varquivo)"
            &Page-Size = "64"
            &Cond-Var  = "130"
            &Page-Line = "66"
            &Nom-Rel   = ""relcomp""
            &Nom-Sis   = """SISTEMA DE ESTOQUE"""
            &Tit-Rel   = """LANCAMENTOS DE COMPRAS DE "" +
                                 string(vdti,""99/99/9999"") + "" A "" +
                                 string(vdtf,""99/99/9999"") "
            &Width     = "130"
            &Form      = "frame f-cabcab"}


    /*
    hide f-principal.
    */
    
    for each plani where plani.movtdc = 4
                     and plani.desti = 995
                     and plani.DtInclu >= vdti
                     and plani.DtInclu <= vdtf no-lock,
                         
        each plaped where plaped.forcod = plani.emite  and
                          plaped.plaetb = plani.etbcod and
                          plaped.serie  = plani.serie  and
                          plaped.placod = plani.placod and
                          plaped.numero = plani.numero no-lock,
                                  
        each pedid where pedid.pednum = plaped.pednum
                     and pedid.pedtdc = plaped.pedtdc
                     and pedid.etbcod = 996 no-lock:

        v-prazo = 0.
                                   
        for each titulo where titulo.empcod = wempre.empcod and
                              titulo.etbcod = plani.etbcod  and
                              titulo.titnat = yes           and
                              titulo.modcod = "DUP"         and
                              titulo.clifor = plani.emite   and
                              titulo.titnum = string(plani.numero) no-lock:
                                          
            v-prazo  =  v-prazo + titulo.titdtven - titulo.titdtemi.

        end.

        assign vdias-atraso  = (if pedid.peddtf < plani.DtInclu then                                     plani.DtInclu - pedid.peddtf else 0)
               vdias-transp  = plani.DtInclu - plani.pladat
               vdias-antecip = (if pedid.peddtf > plani.DtInclu then                                     pedid.peddtf - plani.DtInclu else 0).

        create tt-cabec.
        assign tt-cabec.nf           = plani.numero
               tt-cabec.ped          = pedid.pednum
               tt-cabec.pladat       = plani.pladat
               tt-cabec.peddti       = pedid.peddti 
               tt-cabec.peddtf       = pedid.peddtf 
               tt-cabec.dtinclu      = plani.DtInclu
               tt-cabec.dias-atraso  = vdias-atraso 
               tt-cabec.dias-transp  = vdias-transp 
               tt-cabec.dias-antecip = vdias-antecip
               tt-cabec.prazo-pagto  = v-prazo
               tt-cabec.frete        = plani.frete.

        qtd_total = 0.
        for each movim where movim.etbcod = plani.etbcod and
                             movim.placod = plani.placod and
                             movim.movtdc = plani.movtdc and
                             movim.movdat = plani.pladat no-lock:

            qtd_total = qtd_total + movim.movqtm.

        end.

        for each liped where liped.etbcod = pedid.etbcod and
                             liped.pedtdc = plaped.pedtdc and
                             liped.pednum = plaped.pednum no-lock:
            for each movim where movim.etbcod = plani.etbcod and
                                 movim.placod = plani.placod and
                                 movim.movtdc = plani.movtdc and
                                 movim.procod = liped.procod no-lock:
                                    

                find first wprodu where wprodu.wcod = movim.procod
                                    and wprodu.nf   = plani.numero no-error.
                if not avail wprodu
                then do:

                    create wprodu.
                    assign wprodu.wcod   = movim.procod
                           wprodu.nf = plani.numero.
                end.
                
                wprodu.qent = movim.movqtm.
                                                
                frete_unitario = plani.frete / qtd_total.

                if movim.movdev > 0
                then wprodu.pent = (movim.movpc + movim.movdev - movim.movdes)
                      /*+ ( (movim.movpc + movim.movdev - movim.movdes) *
                         (movim.movalipi / 100))*/.
                else wprodu.pent = (movim.movpc + frete_unitario - movim.movdes)                     /*+ ( (movim.movpc + frete_unitario - movim.movdes) *
                         (movim.movalipi / 100))*/.
                if movim.movipi > 0
                then wprodu.pent = wprodu.pent + (movim.movipi / movim.movqtm) .
                else wprodu.pent = wprodu.pent +
                                 ( (movim.movpc + frete_unitario - movim.movdes)                                    * (movim.movalipi / 100)).
                                   
                find first wprodu where wprodu.wcod = liped.procod no-error.
                wprodu.qped = wprodu.qped + liped.lipqtd.
                wprodu.pped = (liped.lippreco -
                                  (liped.lippreco * (pedid.nfdes / 100))).
                wprodu.pped = (wprodu.pped +
                                  (wprodu.pped * (pedid.ipides / 100))).
                wprodu.pped = (wprodu.pped +
                                  (wprodu.pped * (pedid.acrfin / 100))).
                wprodu.div-val = round(wprodu.pent,2) - round(wprodu.pped,2).

                div-perc-aux = 0.

                if wprodu.div-val <> 0 then do:

                    if wprodu.div-val < 0
                    then div-perc-aux = wprodu.div-val * ( - 1).
                    else div-perc-aux = wprodu.div-val.

                    wprodu.div-perc =
                          string(round(div-perc-aux * 100 / wprodu.pped ,2)).

                    wprodu.div-perc = (if wprodu.div-val < 0
                                       then "-" + wprodu.div-perc + "%"
                                       else "+" + wprodu.div-perc + "%").
                                       
                end.

                totped = totped + (wprodu.pped * liped.lipqtd).
                
            end.
        end.
    end.


    for each tt-cabec use-index tt-01 no-lock:

        assign v-prazo-aux   = string(tt-cabec.prazo-pagto).
        assign v-prazo-aux = trim(v-prazo-aux) + " dias".

        disp "NF:  "
             tt-cabec.nf          no-label
             "Pedido: "                                           at 32
             tt-cabec.ped         no-label                               skip
             "Dat.Emis.NF:  "
             tt-cabec.pladat      no-label   format "99/99/9999"
             "Prazo Entrega: "                                    at 32
             tt-cabec.peddti      no-label   format "99/99/9999"
             " A "
             tt-cabec.peddtf      no-label   format "99/99/9999"         skip
             "Data Entrega: "
             tt-cabec.dtinclu     no-label   format "99/99/9999" 
             "Dias de atraso: "                                   at 32
             string(tt-cabec.dias-atraso)  no-label                      skip  
             "Dias de transporte: "
             string(tt-cabec.dias-transp)  no-label
             "Dias antecipado: "                                  at 32 
             string(tt-cabec.dias-antecip) no-label                      skip
             "Prazo de pagamento: "
             v-prazo-aux                   no-label
             "Frete: "                                            at 32
             string(tt-cabec.frete)        no-label 
                         with frame f-cabec width 150 overlay .

       /*
        for each wprodu where wprodu.nf = tt-cabec.nf:
        
            if (wprodu.qent = wprodu.qped) and
                (wprodu.pent = wprodu.pped)
            then delete wprodu.
        end.
        */
       
        put skip fill("_",104) format "x(104)" skip
    "| Produto Nome Produto                         Qtd.Nf   Qtd.PE     Pr.NF"
    "     Pr.PE    Div. $   Div. %   | " skip
    "| ------- ------------                         ------   ------     -----"
    "     -----    ------   ------   | "    skip.
   
        vok = no.
        for each wprodu where wprodu.nf = tt-cabec.nf:

            find first produ where produ.procod = wprodu.wcod no-lock no-error.
            put "| " wprodu.wcod
                     produ.pronom       format "x(35)"      at 11
                     wprodu.qent                            at 47
                     wprodu.qped                            at 56
                     wprodu.pent        format ">,>>9.99"   at 66
                     wprodu.pped        format ">,>>9.99"   at 75
                     wprodu.div-val     format "->,>>9.99"  at 84
                     wprodu.div-perc                        at 96
                     " |" at 104 skip.
            vok = yes.
        end.
        if vok                                                                           then put skip "|" fill("_",103) format "x(103)" "|" at 105.
        hide frame f5 no-pause.
        hide frame f4 no-pause.
        hide frame f3 no-pause.
        hide frame f2 no-pause.
    
        /*
        for each wprodu.
            delete wprodu.
        end.
        */    
    end.
                                            
    output close.
    if opsys = "UNIX"
    then do:

        find first impress where impress.codimp = setbcod no-lock no-error.
        if avail impress
        then do:
            run acha_imp.p (input recid(impress),
            output recimp).
            find impress where recid(impress) = recimp no-lock no-error.
            assign fila = string(impress.dfimp).
        end.
        /*
        os-command silent lpr value(fila + " " + varquivo).
        */
        run visurel.p (input varquivo,
                       input "").
    end.
                                                   
end.


