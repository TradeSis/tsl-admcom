{admcab.i}
def var wacr     like plani.platot.
def var tot-mar  like plani.platot.
def var tot-acr  like plani.platot.
def var vvlmarg like plani.platot.
def var vvlperc like plani.platot.
def var varquivo as char format "x(30)".
def var xx as i format "99".
def var ii as i.
def var vv as date.
def var vdtimp      as date.
def temp-table tt-ven
    field   data     like plani.pladat
    field   venda    like plani.platot format ">>,>>>,>>9.99"
    field   desco    like plani.platot format ">>,>>9.99"
    field   acres    like plani.platot. 

def var dt     like plani.pladat.
def var vok as l.

def var vdti    as date format "99/99/9999" initial today.
def var vdtf    as date format "99/99/9999" initial today.
def var vetbi   like estab.etbcod.
def var vetbf   like estab.etbcod.
def var vvldesc     like plani.descprod column-label "Desconto".
def var vvlacre     like plani.acfprod column-label "Acrescimo".
def stream stela.

repeat:

    for each tt-ven:
        delete tt-ven.
    end.


    update vetbi label "Filial" at 1
           vetbf no-label
               with frame f1 side-label width 80.

    update vdti label "Periodo" at 1
           "a"
           vdtf no-label with frame f1.

    varquivo = "..\relat\geral" + string(time). 

    {mdad_l.i
            &Saida     = "value(varquivo)"
            &Page-Size = "0"
            &Cond-Var  = "130"
            &Page-Line = "66"
            &Nom-Rel   = ""geral_2""
            &Nom-Sis   = """SISTEMA COMERCIAL"""
            &Tit-Rel   = """MOVIMENTACAO GERAL FILIAL PERIODO DE "" +
                                  string(vdti,""99/99/9999"") + "" A "" +
                                  string(vdtf,""99/99/9999"") +
                                  ""  Fil. "" + string(vetbi,"">>9"") + 
                                  "" - ""     + string(vetbf,"">>9"")"
            &Width     = "130"
            &Form      = "frame f-cabcab"}


    for each estab where estab.etbcod >= vetbi and
                         estab.etbcod <= vetbf no-lock:

        do dt = vdti to vdtf:

            for each plani where plani.movtdc = 5             and
                                 plani.etbcod = estab.etbcod  and
                                 plani.pladat = dt no-lock:
                vvldesc  = 0.
                vvlacre = 0.

                output stream stela to terminal.
                disp stream stela plani.etbcod
                                  plani.pladat
                                    with frame fffpla centered color white/red.
                pause 0.
                output stream stela close.

                /************* Calculo do acrescimo *****************/

                wacr = 0.
                if plani.crecod > 1
                then do:
                    if plani.biss > (plani.platot - plani.vlserv)
                    then assign wacr = plani.biss - 
                                      (plani.platot - plani.vlserv).
                    else wacr = plani.acfprod.

                    if wacr < 0 or wacr = ?
                    then wacr = 0.

                    assign vvldesc  = vvldesc  + plani.descprod
                           vvlacre  = vvlacre  + wacr.
                end.


                find first tt-ven where tt-ven.data = plani.pladat no-error.
                if not avail tt-ven
                then do:
                    create tt-ven.
                    assign tt-ven.data = plani.pladat.
                end. 
                
                assign tt-ven.venda  = tt-ven.venda + plani.platot
                       tt-ven.desco  = tt-ven.desco + vvldesc 
                       tt-ven.acres  = tt-ven.acres + vvlacre. 

 
                
            
            end.

        end.

    end.

    for each tt-ven: 
        disp tt-ven.data column-label "Data Venda"
             tt-ven.venda(total) format "->,>>>,>>9.99" column-label "Vl.Venda" 
            with frame f-imp width 150 down.
    end.
    output close.
    {mrod.i} 
    
end.
