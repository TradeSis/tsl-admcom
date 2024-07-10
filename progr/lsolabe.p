{admcab.i}
def var i as int.
find wempre 1 no-lock.
def buffer pfunc for func.
def var sresp as log format "Sim/Nao".
def new global shared var sfuncod   as int.
def new global shared var stty      as   char format "x(15)".
def var vModulo like suporte.solic.solicitante.
def var vlocal      as char extent 13 format "x(15)"
       init [" GERAL ",
             " Informatica "," Contabilidade "," C.Pagar ",
             " C.Receber "," Crediario "," Estoque "," Compras ", " Vendas " ,
                        " USACON ",""
             ].
def var vtipo      as char extent 13
        init [" ",
              " Informatica "," Contabilidade "," C.Pagar ",
             " C.Receber "," Crediario "," Estoque "," Compras ", " Vendas " ,
                        " USACON ","" ].
 
pause 0.         
display vlocal  
        with frame fescolha 1 column 
                    column 6 row 4 overlay no-label title " Local ". 
choose field vlocal with frame fescolha.      
hide frame feScolha no-pause. 
vmodulo = caps(trim(vtipo[frame-index])).
{achaimp.i}
simpress = vimp.

find segur where segur.cntcod = 9999      and
                 segur.usucod = sfuncod       no-lock no-error.

varqsai = "../impress/solic" + string(time).
{mdserv.i &Saida     = "value(varqsai)"
          &Page-Size = "64"
          &Cond-Var  = "134"
          &Page-Line = "66"
          &Nom-Rel   = ""LSOLABE""
          &nom-sis   = """SISTEMA DE SUPORTE - "" + 
                                        wempre.emprazsoc "
          &Tit-Rel   = """SOLICITACOES DE SERVICO ABERTAS "" + vModulo "
          &Width     = "134"
          &Form      = "frame f-cabcab"}

for each suporte.solic where    solic.cliente = wempre.emprazsoc and
                                dtfim = ? and if vModulo = ""
                                   then true
                                   else solic.modsis = vModulo,
    func where 
               func.funcod = solic.funcod no-lock
                                   break
                                   by solic.modsis
                                   by solic.servcod
                                   by solic.dtpro by solic.servcod:

    form solic.servcod               column-label "Num"
         solic.data                  format "99/99/9999"
         solic.modsis           column-label "Local"
         suporte.solic.solicitante column-label "Solicitante"
         solic.descricao[1]          column-label "Descricao do Servico"
         with frame flinha down  no-box width 250.
    display solic.servcod  (count)
            solic.data
            suporte.solic.solicitante
            solic.modsis
            with frame flinha.
    if solic.dtpro <> ?
    then do:  /*
        disp
            "PROMETIDO PARA DIA " + string(solic.dtpro,"99/99/9999")
                @ solic.descricao[1]
                with frame flinha.
        down with frame flinha. */
    end.
    disp solic.assunto @ solic.descricao[1]
            with frame flinha.
    down with frame flinha.
    do i = 1 to 10:
        if solic.descricao[i] <> ""
        then 
        display solic.descricao[i] @ solic.descricao[1]
                with frame flinha.
        down with frame flinha.
    end.
      
    find first solmov of solic no-lock no-error.
    if avail solmov
    then put skip "ACOMPANHAMENTOS" at 57 skip.
    for each solmov of solic no-lock.
        display string(solmov.dtmov) @ solic.descricao[1]
                with frame flinha.
        down with frame flinha.
        do i = 1 to 10:
            if solmov.descricao[i] <> ""
            then 
            display solmov.descricao[i] @ solic.descricao[1]
                    with frame flinha.
            down with frame flinha.
        end.
    end.
    /*
    put skip
        "Interfere no fluxo do Trabalho ? ( ) Sim  ( ) Nao "    at 10
        "Tempo Maximo Espera ( ) 1 dia"                         at 70
        "                    ( ) 2 dias"                        at 70
        "                    ( ) 1 Semana"                      at 70
        "                    ( ) 2 Semanas"                     at 70
        "                    ( ) 1 Mes "                        at 70
        "                    ( ) + 1 Mes"                       at 70
        "Prioridade  ______"                                    at 10.
        */
    put skip fill("=",134) format "x(134)" skip.
    /*
    if last-of(solic.modsis) and
       not last(solic.modsis)
    then page.*/
end.                            
{mdadmrod.i
    &Saida     = "value(varqsai)"
    &NomRel    = """LSOLABE"""
    &Page-Size = "64"
    &Width     = "80"
    &Traco     = "30"
    &Form      = "frame f-rod3"}.
