{admcab.i}


def temp-table tt-conf
   field etbcod   like  estab.etbcod
   field data-mov like  plani.pladat
   field che-dia  like  plani.iss
   field che-dre  like  plani.notpis
   field che-glo  like  plani.cusmed
   field pagam    like  plani.notcofins.


def var varquivo as char format "x(30)".
def var vdata   as date format "99/99/9999".
def stream stela.

    for each tt-conf:
        delete tt-conf.
    end.
    update vdata label "Data"
            with frame f-data centered color blue/cyan side-label width 80.
    
    for each estab no-lock:
        for each plani where plani.movtdc = 5             and
                             plani.etbcod = estab.etbcod  and
                             plani.pladat >= vdata - 20   and
                             plani.pladat <= vdata + 20   and
                             plani.tmovdev = yes no-lock.
            
            if plani.dtinclu = vdata
            then do:
                find first tt-conf where tt-conf.etbcod = estab.etbcod and
                                         tt-conf.data-mov = plani.pladat
                                                    no-error.
                if not avail tt-conf
                then do:
                    create tt-conf.
                    assign tt-conf.etbcod   = estab.etbcod
                           tt-conf.data-mov = plani.pladat
                           tt-conf.che-dia  = plani.iss
                           tt-conf.che-dre  = plani.notpis
                           tt-conf.che-glo  = plani.cusmed
                           tt-conf.pagam    = plani.notcofins.
                end.
            end.
        end.
    end.
       
    {mdadmcab.i
         &Saida     = "i:\admcom\relat\conf1.txt"
         &Page-Size = "64"
         &Cond-Var  = "130"
         &Page-Line = "66"
         &Nom-Rel   = ""CONF1.P""
         &Nom-Sis   = """SISTEMA DE CREDIARIO"""
         &Tit-Rel   = """RELATORIO DE CONFIRMACOES  "" + 
                          string(vdata,""99/99/9999"")"
         &Width     = "130"
         &Form      = "frame dep1"}

    for each tt-conf by tt-conf.etbcod:
        display tt-conf.etbcod      column-label "Filial"
                tt-conf.data-mov    column-label "Data!Movimento"
                tt-conf.che-dia(total)     column-label "Cheq Dia"
                tt-conf.che-dre(total)     column-label "Cheq Pre"
                tt-conf.che-glo(total)     column-label "Cheq Glo"
                tt-conf.pagam  (total)     column-label "Pgtos"
                    with frame f2 down width 200.
    end.
    
    output close.

    message "Confirma listagem" update sresp.
    if sresp
    then dos silent type i:\admcom\relat\conf1.txt > prn.

