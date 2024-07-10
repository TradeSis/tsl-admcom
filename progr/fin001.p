/***************************************************************************
**
** Programa        : fin001.p
** Objetivo        : Demonstrativo de Notas Fiscais
** Ultima Alteracao: 08/08/2017
**
****************************************************************************/

{admcab.i}

def var vpdf as char no-undo.

def temp-table tt-cartpre
    field seq    as int
    field numero as int
    field valor as dec.

def var vqtdcart as int.
def var vconta as int.
def var vachatextonum as char.
def var vachatextoval as char.

def var vlcartpres as dec.
def var vvalor-cartpre as dec.
def var varq as char.
def workfile wnotas
    field tipo          as   int format ">>9"
    field serie         like plani.serie
    field numer         like plani.numero
    field frete         like plani.frete
    field acfprod       like plani.acfprod
    field vlserv        like plani.vlserv
    field protot        like plani.protot
    field valor         like plani.platot
    field dtincl        like plani.dtincl
    field cartpres      like plani.platot.
    
def var wper as dec decimals 10.
def var     dadtini  like plani.pladat init today label "Data Inicial" no-undo.
def var     dadtfin  like plani.pladat init today label "Data Final"   no-undo.
def var     deult    as inte format ">>>>>9"                     no-undo.
def var     deval    as deci                                     no-undo.
def var     vetbcod  like estab.etbcod                           no-undo.
def var     vvltotal like contrato.vltotal.
def var     vvlcont  like contrato.vltotal.
def var     wacr     like plani.acfprod.
def var     valortot like plani.platot.

def buffer bcontnf for contnf.
def buffer bplani for plani.

vetbcod = setbcod.

disp setbcod with frame fsele.

form with down frame fdet.
form
     /*vetbcod skip*/
     dadtini
     dadtfin
     with overlay row 5 centered 2 column width 80 color blue/cyan
     title " DEMOSTRATIVO DE NOTAS " frame fsele.

repeat:
    for each wnotas:
        delete wnotas.
    end.

    /*update vetbcod with frame fsele.*/
    update dadtini validate(input dadtini <> ?, "Data deve ser Informada")
           dadtfin validate(input dadtfin >= input dadtini, "Data Invalida")
           with frame fsele.
    {confir.i 1 "Demonstrativo"}

    /*varq = "../relat/fin001.rel".*/

    if setbcod > 0 and setbcod < 10 
    then varq = "/admcom/relat-loja/filial00" + string(setbcod) + "/fin001-rel-fl00" + string(setbcod) + "-" + string(time).

    if setbcod > 9 and setbcod < 100 
    then varq = "/admcom/relat-loja/filial0" + string(setbcod) + "/fin001-rel-fl0" + string(setbcod) + "-" + string(time).

    if setbcod > 99 
    then varq = "/admcom/relat-loja/filial" + string(setbcod) + "/fin001-rel-fl" + string(setbcod) + "-" + string(time).

    {mdadmcab.i
        &Saida     = "value(varq)"
        &Page-Size = "0"
        &Page-Line = "0"
        &Cond-Var  = "105"
        &Width     = "105"
        &Nom-Rel   = ""FIN001""
        &Nom-Sis   = """SISTEMA FINANCEIRO"""
        &Tit-Rel   =
           """DEMONSTRATIVO DE NOTAS: "" +
                     string(dadtini) + "" ate "" + string(dadtfin) +
                     "" - Loja "" + string(vetbcod) "
        &Form      = "frame f-cabcab"}

   /* for each crepl no-lock: */
        for each plani where plani.movtdc = 5 and
                             plani.etbcod = vetbcod and
                             plani.pladat >= dadtini and
                             plani.pladat <= dadtfin no-lock:
             if /* plani.crecod   = crepl.crecod  and */
                plani.dtinclu >= dadtini       and
                plani.dtinclu <= dadtfin       and
                plani.notsit   = no
             then do:
                find first wnotas where
                       wnotas.tipo  = plani.crecod  and
                       wnotas.serie = plani.serie   and
                       wnotas.numer = plani.numero  and
                       wnotas.valor = plani.platot no-lock no-error.
                if not avail wnotas 
                then do:

                    vvltotal = 0.
                    vvlcont = 0.
                    if plani.crecod > 1
                    then do:
                        vvltotal = vvltotal + plani.platot - plani.vlserv -
                                   plani.descprod + plani.acfprod.
                        if plani.biss > 0
                        then do:
                            vvlcont = plani.biss.
                            valortot = plani.biss.
                        end.
                        else assign vvlcont = plani.platot - plani.vlserv
                                    valortot = plani.platot - plani.vlserv. 

                        wacr = vvlcont - vvltotal.  
                        wper = plani.platot / vvltotal.

                    end.
                    else do:
                        wacr = plani.acfprod.
                        valortot = plani.platot.
                    end.

                    valortot = plani.platot + wacr - plani.vlserv.

                    if wacr < 0
                    then wacr = 0.


                    for each tt-cartpre. delete tt-cartpre. end.

                    assign vqtdcart = 0
                           vconta   = 0
                           vachatextonum = ""
                           vachatextoval = "".
                
                    if plani.notobs[3] <> ""
                    then do:
                        if acha("QTDCHQUTILIZADO",plani.notobs[3]) <> ? 
                        then vqtdcart =
                             int(acha("QTDCHQUTILIZADO",plani.notobs[3])).
                    
                        if vqtdcart > 0 
                        then do: 
                            do vconta = 1 to vqtdcart:  
                                vachatextonum = "". 
                                vachatextonum = "NUMCHQPRESENTEUTILIZACAO" 
                                              + string(vconta).
        
                                vachatextoval = "". 
                                vachatextoval = "VALCHQPRESENTEUTILIZACAO" 
                                              + string(vconta).

                                if acha(vachatextonum,plani.notobs[3]) <> ? and
                                   acha(vachatextoval,plani.notobs[3]) <> ?
                                then do: 
                                    find tt-cartpre where tt-cartpre.numero = 
                                     int(acha(vachatextonum,plani.notobs[3]))
                                         no-error. 
                                    if not avail tt-cartpre 
                                    then do:  
                                        create tt-cartpre. 
                                        assign tt-cartpre.numero =
                                        int(acha(vachatextonum,plani.notobs[3]))
                                           tt-cartpre.valor  =
                                       dec(acha(vachatextoval,plani.notobs[3])).
                                    end.
                                end.
                            end.
                        end.
                    end.

                    vvalor-cartpre = 0.
                    find first tt-cartpre no-lock no-error.
                    if avail tt-cartpre 
                    then do:
                        for each tt-cartpre.
                            vvalor-cartpre = vvalor-cartpre + tt-cartpre.valor.
                        end.
                    end.
                    
                    create wnotas.
                    assign wnotas.tipo    = plani.crecod
                           wnotas.serie   = plani.serie
                           wnotas.numer   = plani.numero
                           wnotas.valor   = valortot /*contrato.vltotal*/
                                    - plani.descprod - vvalor-cartpre
                           wnotas.protot  = plani.protot - plani.descprod
                           wnotas.frete   = plani.frete
                           wnotas.vlserv  = plani.vlserv
                           wnotas.acfprod = wacr
                           wnotas.dtincl  = plani.dtincl
                           wnotas.cartpres = vvalor-cartpre.
                
                end.
             
             
             
             end.
        
        end.

    
    /* end. */
    
    view frame fcab.

    for each wnotas break by wnotas.tipo
                          by wnotas.numer:
        find crepl where crepl.crecod = wnotas.tipo no-lock no-error.
        assign deult = wnotas.numer
               deval = deval + wnotas.valor.

        if  first-of(wnotas.tipo)
        then do:
            put skip(1)
                crepl.crenom                        skip(1).
        end.

        display wnotas.serie column-label "Ser" format "x(03)" 
                wnotas.numer    format "9999999"
                wnotas.dtincl   format "99/99/9999"
                wnotas.frete    (total by wnotas.tipo) format "->,>>9.99"
                wnotas.acfprod  (total by wnotas.tipo) format "->>>,>>9.9"
                wnotas.protot   column-label "Produto" format "->>>,>>9.9"
                                (total by wnotas.tipo)
                wnotas.vlserv   column-label "Devol." format "->>,>>9.9"
                                (total by wnotas.tipo)
                wnotas.cartpres column-label "Cartao!Presente" 

                                format "->>,>>9.99"
                                (total by wnotas.tipo)

                wnotas.valor    (total by wnotas.tipo) format "->>>,>>9.9"
                with down no-box frame fnota width 200.
        down with frame fnota.
    end.
    output close.
    
    /* geracao de PDF */    
    run pdfout.p (input varq,
                  input varq,
                  input ".pdf",
                  input "Portrait",
                  input 9.4,
                  input 1,
                  output vpdf).
              
    message ("Arquivo gerado com sucesso!") view-as alert-box.
    
    /* substituido pela geracao de PDF
    os-command silent /fiscal/lp value(varq).
    */
end.

procedure p-cartao-presente:

    def output parameter p-vlcartpres as dec.

    p-vlcartpres = 0.
    
    for each titulo where titulo.empcod   = 19 
                      and titulo.titnat   = yes 
                      and titulo.modcod   = "CHP" 
                      and titulo.etbcobra = vetbcod
                      and titulo.titdtpag >= dadtini
                      and titulo.titdtpag <= dadtfin no-lock:

        if acha("ETBCODUTILIZACHP",titulo.titobs[2]) <> ? and
           acha("PLACODUTILIZACHP",titulo.titobs[2]) <> ?
        then do: 
          if int(acha("ETBCODUTILIZACHP",titulo.titobs[2])) = vetbcod and
             int(acha("PLACODUTILIZACHP",titulo.titobs[2])) = plani.placod
          then do:
              p-vlcartpres = p-vlcartpres + titulo.titvlpag.          
          end.        
        end.

    end.

end procedure.
