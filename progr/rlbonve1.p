/* **************************************************************************
*  Programa...: rlbonve1.p
*  Funcao.....: Ranking de vendedores 
*  Data.......: 14/03/2007
************************************************************************** */
{admcab.i}

def var p-valor-bonus like plani.platot.
def var d-dtini       as date label "Data inicial" form "99/99/9999".
def var d-dtfin       as date label "Final"        form "99/99/9999".
def var i-etbcod      like estab.etbcod.
def var i-etbcodi     like estab.etbcod.
def var i-etbcodf     like estab.etbcod.
def var c-etbcod      as char form "x(03)"   init "".
def var c-etbnom      like estab.etbnom.
def var i-qtdbon      as inte form ">>>9"  init 0.
def var c-funnom      like func.funnom.
def var varquivo      as char.
def var e-totalvd     like plani.platot.
def var e-percvlr     as deci form ">>9.99 %".

def temp-table tt-estab
    field etbcod like estab.etbcod
    field etbnom like estab.etbnom
    index ch-etbcod is unique etbcod.

def temp-table tt-proces
    field  etbcod  like estab.etbcod
    field  etbnom  like estab.etbnom
    field  vencod  like plani.vencod
    field  funnom  like func.funnom
    field  qtdbon  as inte form ">>>9"
    field  vlrbon  like plani.platot
    field  liquido like plani.platot
    field  total   like plani.platot
    field  perc    like e-percvlr
    index ch-prim etbcod perc descending.
    
for each tt-estab:
    delete tt-estab.
end.    
for each tt-proces:
    delete tt-proces.
end.    
form 
     d-dtini             
     d-dtfin            
     skip
     with frame f-upd 2 col 1 down side-labels width 80
          title "Ranking de Vendedores".

assign d-dtini  = today - 30
       d-dtfin  = today.

if opsys = "UNIX"
then assign varquivo = "/admcom/relat/rlbonve1.txt".
else assign varquivo = "l:~\relat~\rlbonve1.txt".

/* *********************************************************************** */

update d-dtini
       d-dtfin
       with frame f-upd.

repeat:
   
    update c-etbcod column-label "Estab" 
           with frame f-nupd 
                width 35 col 15 row 13
                5 down title "<T> Todas - <S> Sair - <F> Faixa"
                overlay.

    if c-etbcod = "F" or
       c-etbcod = "f"
    then do:
            update i-etbcodi label "Estab. inicial"
                   i-etbcodf label "Final"
                   with frame f-nwupd width 35 col 15 row 13
                        overlay title "ESTAB FAIXA" side-labels.
            
            for each estab where
                     estab.etbcod >= input i-etbcodi and
                     estab.etbcod <= input i-etbcodf no-lock:
           
                create tt-estab.
                assign tt-estab.etbcod = estab.etbcod
                       tt-estab.etbnom = estab.etbnom.            
              
            end.
            hide frame f-nupd.
            hide frame f-nwupd.
            leave.
    end.
     
    if c-etbcod = "T" or
       c-etbcod = "t"
    then do:
            assign c-etbnom = "Todas".
            disp c-etbnom with frame f-nupd.
            pause 0 no-message.
            for each estab no-lock:
           
                create tt-estab.
                assign tt-estab.etbcod = estab.etbcod
                       tt-estab.etbnom = estab.etbnom.            
              
            end.
            hide frame f-nupd.
            leave.
    end.
         
    if c-etbcod = "S" or
       c-etbcod = "s"
    then do:
          leave.                    
    end.

    if c-etbcod >= "0" and
       c-etbcod <= "999"
    then do:
        assign i-etbcod = int(c-etbcod).
        find first estab where
                   estab.etbcod = i-etbcod no-lock no-error.
        if not avail estab
        then do:
                 message "Estabelecimento nao encontrado!" view-as alert-box.
                 undo, retry.     
        end.
        else do:
                find first tt-estab where
                           tt-estab.etbcod = i-etbcod exclusive-lock no-error.
                if not avail tt-estab
                then do:           
                        assign c-etbnom = estab.etbnom.
                        disp   c-etbnom  column-label "Nome"
                               with frame f-nupd.
                        pause 0 no-message.
                        create tt-estab.
                        assign tt-estab.etbcod = i-etbcod
                               tt-estab.etbnom = estab.etbnom.
                end.
                else do:
                    message "Estabelecimento já informado!" view-as alert-box.
                    undo, retry.
                end.               
        end.
    end.   
       
end.       

hide frame f-nupd.

message "GERANDO RELATORIO".

run pi-processa.

{mdadmcab.i
    &Saida     = "value(varquivo)"
    &Page-Size = "63"
    &Cond-Var  = "130"
    &Page-Line = "66"
    &Nom-Rel   = ""rlbonve1""
    &Nom-Sis   = """SISTEMA ADMINISTRATIVO"""
    &Tit-Rel   = """RANKING DE VENDAS BONUS - DE ""
                 + string(d-dtini,""99/99/9999"") + "" A ""
                 + string(d-dtfin,""99/99/9999"")"
    &Width     = "90"
    &Form      = "frame f-cabcab"}

    for each tt-proces no-lock
             break by tt-proces.etbcod
                   by tt-proces.perc:
                    
        if first-of(tt-proces.etbcod)
        then do:
                put skip(1)
                    "Estab.: "
                    tt-proces.etbcod
                    space(01)
                    tt-proces.etbnom
                    skip(1).
        end.
               
        disp tt-proces.vencod   form ">>9"
             tt-proces.funnom   form "x(25)"
             tt-proces.qtdbon   (total) form ">>>9"      column-label "Qt Bonus"
             tt-proces.vlrbon   (total) form "->>,>>9.99" 
             column-label "Vlr Bonus"
             tt-proces.liquido  (total) form "->>,>>9.99" column-label "Liquido"
             tt-proces.total    (total) form "->>,>>9.99" column-label "Total"
             tt-proces.perc     form ">>9.99 %"  column-label "%"
             with frame f-disp centered down width 95.
             down with frame f-disp.
    end.

output close.
pause 2 no-message.
if opsys = "UNIX"
then run visurel.p (input varquivo, input "").
else {mrod.i}.


procedure pi-processa:

for each tt-estab no-lock:
    for each plani where
             plani.movtdc  = 5                   and
             plani.etbcod  = tt-estab.etbcod     and
             plani.pladat  >= d-dtini            and
             plani.pladat  <= d-dtfin            no-lock
             break by plani.etbcod
                   by plani.vencod:

        find first titulo where titulo.empcod   = 19           and 
                                titulo.titnat   = yes          and 
                                titulo.clifor   = plani.desti  and 
                                titulo.modcod   = "BON"        and 
                                titulo.titdtpag = plani.pladat and 
                                titulo.titvlpag = plani.descprod 
                                no-lock no-error.
        if avail titulo
        then do:
                assign p-valor-bonus = p-valor-bonus + titulo.titvlpag.
                assign i-qtdbon      = i-qtdbon + 1.
                assign e-totalvd     = e-totalvd + plani.platot. 
        end.

        if last-of(plani.vencod)
        then do:
                if i-qtdbon = 0
                then next.
    
                find first func where
                           func.etbcod = plani.etbcod  and
                           func.funcod = plani.vencod  no-lock no-error.
                if avail func 
                then assign c-funnom = func.funnom.
                else assign c-funnom = "".          
            
                assign e-percvlr = (p-valor-bonus / (e-totalvd + p-valor-bonus)
                                   ) * 100.

                find first tt-proces where
                           tt-proces.etbcod = plani.etbcod   and
                           tt-proces.vencod = plani.vencod   
                           exclusive-lock no-error.
                if not avail tt-proces
                then do:
                    create tt-proces.
                    assign tt-proces.etbcod  = plani.etbcod
                           tt-proces.etbnom  = tt-estab.etbnom
                           tt-proces.vencod  = plani.vencod
                           tt-proces.funnom  = c-funnom
                           tt-proces.qtdbon  = i-qtdbon
                           tt-proces.vlrbon  = p-valor-bonus
                           tt-proces.liquido = (e-totalvd - p-valor-bonus)
                           tt-proces.total   = (e-totalvd)
                           tt-proces.perc    = e-percvlr.
                end.
                     
                assign i-qtdbon      = 0
                       p-valor-bonus = 0
                       e-totalvd     = 0.
        end.
    end.
end.

end procedure.
