/* lipedpai.p manutencao no lipedpai */

{admcab.i}

def input parameter par-recid-pedid    as recid no-undo.
def input parameter par-recid-lipedpai as recid no-undo.
def input parameter par-opc            as char.

def buffer          blipedpai      for lipedpai.

def var vpaccod     like pack.paccod.
def var vlipqtd     like liped.lipqtd.
def var vperc       as   dec.
def var vtotal      like lipedpai.lippreco label "Total".
def var vlippreco   like lipedpai.lippreco.
/***
def var vlipdes     like lipedpai.lipdes.
def var vlipacf     like lipedpai.lipacf.
def var valiqipi    like produpai.aliqipi.
def var vlipipi     like lipedpai.lipipi.
def var vlipsubst   like lipedpai.lipsubst.
def var vlipoutros  like lipedpai.lipout.
def var vlipfrete   like lipedpai.lipfrete.
def var valifrete   as dec format ">>9.99%".
def var vlippercpub as dec format ">>9.99%".
def var vlippercdes as dec format ">>9.99%".
def var vi          as int.
def var vtipos      as char.
***/
def buffer destoq for estoq.

find pedid where recid(pedid) = par-recid-pedid no-lock.
/***
find tipped of pedid  no-lock.
find clifor of pedid  no-lock.
***/

    form           
                  /***produpai.refer          colon 12***/
                  produpai.itecod    colon 12 /***no-label***/ 
                  produpai.pronom     no-label format "x(26)"
                  /*
                  produpai.refer      no-label
                    */                   
                  skip /*(1)*/
                  pack.paccod      colon 12
                  pack.pacnom      no-label
                  pack.qtde        colon 70
                  pack.modpcod     colon 12
                  modpack.modpnom  no-label
                  modpack.cores    colon 70
                  skip(1)
                  vlipqtd          colon 12 validate (vlipqtd > 0, "")
                  vlippreco        colon 36
/***
                  vlippercdes      colon 19 label "Perc.Desc"
                  vlipdes          colon 40
***/
                  vtotal           colon 61
/***
                  skip(1)
                  valifrete        colon 12 label "Aliq.Frete"
                  vlipfrete        colon 36
                  vlipacf          colon 61 label "Acr Fin"
                  vtotal           colon 61
                  skip(1)
                  /***valiqipi         colon 12
                  vlipipi          colon 61
                  vlipoutros       colon 12
                  vlipsubst        colon 61
                  ***/
***/
       with frame f-lipedpai centered row 10
                         width 78 down side-labels overlay.

if par-recid-lipedpai = ? /* Inclusao */
then do:
    hide frame f-lipedpai no-pause.
    do with frame f-lipedpai on error undo.
        prompt-for produpai.itecod /***refer        ***/
                with frame f-lipedpai.

        find first produpai where
                    produpai.itecod = input frame f-lipedpai produpai.itecod
                    no-lock no-error.
        if not avail produpai
        then do:
            message "Produto PAI nao encontrado".
            undo.
        end.

        vpaccod = 0.
        find first pack of produpai no-lock no-error.
        if avail pack
        then do.
            run cad_pack.p (recid(produpai), "Zoom").
            if sretorno = ""
            then undo.
            find pack where paccod = int(sretorno) no-lock.
            find modpack of pack no-lock.
            disp
                pack.paccod
                pack.pacnom
                pack.modpcod
                modpack.modpnom
                modpack.cores
                pack.qtde.
            vpaccod = pack.paccod.
            vlipqtd:label  = "Qtde.Packs".
            vlipqtd:format = ">>9".
        end.
        
        disp produpai.itecod 
             produpai.pronom.
        
        find first blipedpai of pedid
                             where blipedpai.itecod = produpai.itecod
                               and blipedpai.paccod = vpaccod
                no-lock no-error.
        if avail blipedpai
        then do:
            message "Ja Consta na Ordem".
            undo.
        end.

        do:
            update vlipqtd validate(vlipqtd <> ?,
                            "Quantidade digitada nao pode ser ZERO").

            assign
               vtotal = vlipqtd * vlippreco            
/***               vlippreco = produpai.ctonota
               valiqipi = produpai.aliqipi***/.

            if avail pack
            then vtotal = vtotal * pack.qtde.
            disp vtotal .

        /* pedcomin.p */
        find first produ of produpai no-lock.
        find last estoq where estoq.procod = produ.procod no-lock no-error.
        if avail estoq /*and produ-novo = no*/
        then do.
            assign
                vlippreco = estoq.estcusto - (estoq.estcusto * (pedid.nfdes / 100))
                vlippreco = estoq.estcusto - (estoq.estcusto * (pedid.dupdes / 100))
                vlippreco = vlippreco + (estoq.estcusto * (pedid.acrfin / 100)).
            vlippreco = vlippreco + (estoq.estcusto * (pedid.condes / 100)).
        end.
            
            update vlippreco validate(vlippreco <> 0,
                        "Preco digitado nao pode ser ZERO ").
            
            hide message no-pause.
            /*
            run gerprom.p (input recid(produpai),
                           input 26,
                           input today,
                           output vperc).
            */

/***
            do on error undo. 
                update  vlippercdes 
                        validate(vlippercdes < 100,"Percentual Invalido"). 
                vlipdes = ((vlippreco * vlipqtd)) * 
                              (vlippercdes / 100).                
                update vlipdes validate(if vlipqtd <> 0
                                        then vlipdes < vlipqtd * vlippreco
                                        else true,
                "Desconto deve ser menor que " + string(vlipqtd * vlippreco,
                                ">>>,>>9.99") ). 
            end.
***/
            vtotal = (vlipqtd * vlippreco) /*- vlipdes*/.
            disp vtotal.
 
/***
            do.
               update valifrete.
               if valifrete entered then
                  vlipfrete = ((vlippreco * vlipqtd) - vlipdes) * 
                              (valifrete / 100).

                update vlipfrete vlipacf valiqipi.
                if valiqipi > 0 and vlipipi = 0 or valiqipi entered
                then
                    vlipipi = ((vlippreco * vlipqtd) - vlipdes) *
                                    (valiqipi / 100).
                update vlipipi
                       vlipoutros
                       vlipsubst.
            end.
***/
        end.

        do transaction.
            create lipedpai.
            assign
                lipedpai.etbcod    = pedid.etbcod
                lipedpai.pedtdc    = pedid.pedtdc
                lipedpai.itecod    = produpai.itecod
                lipedpai.lipsit    = "A"
                lipedpai.pednum    = pedid.pednum
                lipedpai.lipqtd    = vlipqtd
                lipedpai.lipqtdtot = vlipqtd
                lipedpai.lippreco  = vlippreco.
/***    
                lipedpai.lipipi    = valiqipi
                lipedpai.lipdes    = vlippercdes
                lipedpai.lipacfin  = vlipacf
                lipedpai.lipsubst  = vlipsubst
                lipedpai.lipout    = vlipoutros
                lipedpai.lipfrete  = valifrete
***/
            if avail pack
            then do.
                assign
                    lipedpai.paccod    = pack.paccod
                    lipedpai.lipqtdtot = vlipqtd * pack.qtde.

                for each packprod of pack no-lock.
                    find produ of packprod no-lock.

                    run grava-liped (string(pack.paccod),
                                     vlippreco,
                                     vlipqtd * packprod.qtde).
                end. /* packprod */
            end. /* pack */
            else
                for each produ of produpai no-lock.
                    run grava-liped ("",
                                     vlippreco,
                                     vlipqtd * packprod.qtde).

                end.
        end.
    end.
    hide frame f-lipedpai no-pause.
end.

procedure grava-liped.

    def input parameter par-paccod as char.
    def input parameter par-preco  as dec.
    def input parameter par-qtde   as dec.

                    /*** pedcomin.p */
                    find first simil where simil.procod = produ.procod
                               no-error.
                    if avail simil
                    then delete simil.

                    find clase where clase.clacod = produ.clacod no-lock.
                    find liped where liped.etbcod = pedid.etbcod and
                                     liped.pedtdc = pedid.pedtdc and
                                     liped.pednum = pedid.pednum and
                                     liped.procod = produ.procod and
                                     liped.lipcor = par-paccod and
                                     liped.predt  = pedid.peddat no-error.
                    if not avail liped
                    then do.
                        create liped.
                        assign liped.pednum = pedid.pednum
                               liped.pedtdc = pedid.pedtdc
                               liped.predt  = pedid.peddat
                               liped.predtf = pedid.peddtf
                               liped.etbcod = pedid.etbcod
                               liped.procod = produ.procod
                               liped.lipsit = "A"
                               liped.lipcor = par-paccod
                               liped.protip = if clase.claordem
                                              then "M"
                                              else "C".
                        find first destoq where
                             destoq.procod = liped.procod  and
                             destoq.etbcod = 93
                             no-lock no-error.
                        if avail destoq
                        then liped.lipsep = destoq.estvenda.
                    end.
                    assign liped.lipqtd   = par-qtde
                           liped.lippreco = par-preco.

end procedure.

if par-recid-lipedpai <> ? /* alteracao/consulta */
then do:
    do with frame f-lipedpai on error undo.
        find lipedpai where recid(lipedpai) = par-recid-lipedpai no-lock.
        find produpai of lipedpai no-lock.
        find pack of lipedpai no-lock.
        find modpack of pack no-lock.
        disp produpai.itecod 
             produpai.pronom
             pack.paccod
             pack.pacnom
             pack.modpcod
             modpack.modpnom
             modpack.cores
             pack.qtde.
        assign
           vlipqtd    = lipedpai.lipqtd
           vlippreco  = lipedpai.lippreco
           vlippreco  = lipedpai.lippreco
           /*vlipipi    = lipedpai.lipipi
           vlipdes    = lipedpai.lipdes */
           vtotal     = (vlipqtd * vlippreco) /*- vlipdes*/  * pack.qtde
           /*vlipacf    = lipedpai.lipacfin
           vlipsubst  = lipedpai.lipsubst
           vlipoutros = lipedpai.lipout
           valifrete  = if lipedpai.lipfrete > 0
                        then lipedpai.lipfrete * 100 / 
                             ((vlippreco * vlipqtd) - vlipdes)
                        else 0*/
/***
/* perc desc */
           vlippercdes = if liped.lipdes > 0
                         then liped.lipdes * 100 / 
                              ((vlippreco * vlipqtd))
                         else 0
/**/
/* perc vb publi */                       
/**/
           vlipfrete  = lipedpai.lipfrete
              
        valiqipi = vlipipi / vtotal * 100.
***/
        .
        disp vlipqtd
             vlippreco
/***
             valiqipi
             vlipipi
             vlipdes    vlippercdes
             vlipacf
             vlipsubst
             vlipoutros
             valifrete
             vlipfrete
***/
             vtotal.

        if lipedpai.funcod-can > 0 then do.
            find func where func.funcod = lipedpai.funcod-can no-lock no-error.
            pause 0.
            disp lipedpai.funcod-can colon 13 func.funape no-label 
                 lipedpai.data-can  
                 string(lipedpai.hora-can, "hh:mm") no-label
                 with frame f-canc width 78 no-box row 21 side-labels 
                            overlay  centered.
        end.

        if par-opc = "Con"
        then do:
            pause.
            leave.
        end.

        update vlippreco validate(vlippreco <> 0,
                        "Preco digitado nao pode ser ZERO ").
            
        hide message no-pause.
         
/***
            do on error undo.
                update  vlippercdes
                        validate(vlippercdes < 100,"Percentual Invalido"). 
                vlipdes = ((vlippreco * vlipqtd)) * 
                              (vlippercdes / 100).                
                update  vlipdes validate(vlipdes < vlipqtd * vlippreco,
                   "Desconto deve ser menor que " + string(vlipqtd * vlippreco,
                                ">>>,>>9.99") ). 
            end.
***/
            vtotal = (vlipqtd * vlippreco) /***- vlipdes***/.
            disp vtotal.
 
/***
            do.
               update valifrete.
               if valifrete entered then
                  vlipfrete = ((vlippreco * vlipqtd) - vlipdes) * 
                              (valifrete / 100).

                update vlipfrete vlipacf valiqipi.
                if valiqipi entered
                then
                    vlipipi = ((vlippreco * vlipqtd) - vlipdes) *
                                    (valiqipi / 100).
                update vlipipi
                       vlipoutros
                       vlipsubst.
            end.
***/
         find lipedpai where recid(lipedpai) = par-recid-lipedpai exclusive.
         assign
            lipedpai.lippreco  = vlippreco
            /*lipedpai.lipipi    = vlipipi
            lipedpai.lipdes    = vlipdes  */
            /*lipedpai.lipacfin  = vlipacf
            lipedpai.lipsubst  = vlipsubst
            lipedpai.lipout    = vlipoutros
            lipedpai.lipfrete  = vlipfrete
            */.
         for each produ where produ.itecod = lipedpai.itecod no-lock.
         for each liped of pedid where
            liped.procod = produ.procod
            exclusive.
         assign
            liped.lippreco  = vlippreco.
/***
            liped.lipipi    = vlipipi
            liped.lipdes    = vlipdes
            liped.lipacfin  = vlipacf
            liped.lipsubst  = vlipsubst
            liped.lipout    = vlipoutros
            liped.lipfrete  = vlipfrete
            .
***/
         end.
         end.   
    end.
end.
hide frame f-lipedpai  no-pause.
