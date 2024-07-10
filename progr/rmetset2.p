{admcab.i}

def var vint-cla-cod     as integer format ">>>>>>>>>9".
def var vint-supervisor as integer.
def var vint-filial     as integer.
def var v-ano           as integer.
def var v-mes           as integer.

def var vmostra-sep     as logical.

def var varquivo    as char.
def var vcha-label-aux as char.

def var vcha-situacao as char.

def buffer bclase for clase.
def buffer cclase for clase.
def buffer dclase for clase.
def buffer eclase for clase.

def var vdti         as date.
def var vdtf         as date.

def var vcha-filial-aux  as char.
def var vcha-clase-aux   as char.

/*
def var vcha-label-aux as char.
*/

def var vdti-ant     as date.
def var vdtf-ant     as date.
                           
define temp-table tt-cla
     field cla-cod       as integer
     field clasup        as integer
         index idx01 cla-cod.

def temp-table tt-tbmeta like tbmeta
     field rowid            as rowid
     field catcod           as integer
     field venda-ant        as dec
     field venda-atu        as dec
     field venda-met        as dec 
     field percent-dif      as dec
     field perc-atual            as dec
         index idx-perc percent-dif asc.

def buffer btbmeta       for tbmeta.

assign v-ano = year(today)
       v-mes = month(today).

form
   v-ano            format "9999"   label "Ano"          skip 
   v-mes            format "99"     label "Mes"          skip
   vint-cla-cod                     label "Setor"        skip
   vint-supervisor                  label "Supervisor"   skip
   vint-filial                      label "Filial"       skip
        with frame f01 centered overlay row 5 side-labels 2 column.

repeat.
    
update v-ano
       v-mes
       vint-cla-cod 
       vint-supervisor
       vint-filial 
            with frame f01 .

                            find first clase where clase.clacod = vint-cla-cod
                  /*and clase.clasup = 0*/            
                  no-lock no-error.
/*
if not avail clase then do:
    message "Setor nao cadastrado." view-as alert-box.
    undo.
end.
*/
if v-ano = year(today)
then do:

    if v-mes = 0
    then
    assign vdti      = date(01,01,year(today))
           vdtf      = today - 1
           vdti-ant  = date(01,01,year(today) - 1)
           vdtf-ant  = date(month(vdtf) + 1,01,year(today) - 1) - 1.
    else 
    assign vdti      = date(v-mes,01,year(today))
           vdtf      = today - 1
           vdti-ant  = date(v-mes,01,year(today) - 1)
           vdtf-ant  = date(month(vdtf) + 1,01,year(today) - 1) - 1.

end.

for each btbmeta where btbmeta.ano = v-ano 
                   and btbmeta.mes = if v-mes > 0
                                     then v-mes
                                     else btbmeta.mes
                                         no-lock,
                                                  
    first clase where clase.clacod = btbmeta.cla-cod
                  /*and clase.clasup = 0*/  no-lock,
                  
    first filialsup where filialsup.etbcod = btbmeta.etbcod no-lock.

    if vint-cla-cod <> 0 and btbmeta.cla-cod <> vint-cla-cod
    then next.
    
    if vint-supervisor <> 0 and filialsup.supcod <> vint-supervisor
    then next.
    
    if vint-filial <> 0 and btbmeta.etbcod <> vint-filial
    then next.

    create tt-tbmeta.
    
    buffer-copy btbmeta to tt-tbmeta.

    assign tt-tbmeta.rowid = rowid(btbmeta)
           tt-tbmeta.catcod = integer(clase.claper).

    find first tt-cla where tt-cla.cla-cod = btbmeta.cla-cod no-lock no-error.
    if not avail tt-cla
    then do:
        create tt-cla.
        assign tt-cla.cla-cod = btbmeta.cla-cod
               tt-cla.clasup  = btbmeta.cla-cod.
    end.

    for each cclase where cclase.clasup = btbmeta.cla-cod no-lock.
    
        find first tt-cla where tt-cla.cla-cod = cclase.clacod
                                                 no-lock no-error.
        if not avail tt-cla
        then do:
            create tt-cla.
            assign tt-cla.cla-cod = cclase.clacod
                   tt-cla.clasup  = btbmeta.cla-cod.
        end.
        
        for each dclase where dclase.clasup = cclase.clacod no-lock.
        
            find first tt-cla where tt-cla.cla-cod = dclase.clacod
                                                      no-lock no-error.
            if not avail tt-cla
            then do:
                create tt-cla.
                assign tt-cla.cla-cod = dclase.clacod
                       tt-cla.clasup  = btbmeta.cla-cod.
            end.
            
            for each eclase where eclase.clasup = dclase.clacod no-lock.
                
                find first tt-cla where tt-cla.cla-cod = eclase.clacod
                                                    no-lock no-error.
                if not avail tt-cla
                then do:
                    create tt-cla.
                    assign tt-cla.cla-cod = eclase.clacod
                           tt-cla.clasup  = btbmeta.cla-cod.
                end.
            end.                       
        end.
    end.
end.

message "Gerando a estrutura de classes e Calculando as vendas...  ".

for each estab no-lock.

if vint-filial <> 0 and estab.etbcod <> vint-filial
then next.

for each tt-cla no-lock.

    find first tt-tbmeta where tt-tbmeta.cla-cod = tt-cla.clasup
                                    exclusive-lock no-error.

    for each produ where produ.catcod = tt-tbmeta.catcod
                     and produ.clacod = tt-cla.cla-cod no-lock,
    
        each movim where movim.etbcod = estab.etbcod
                     and movim.movtdc = 5
                     and movim.procod = produ.procod
                     and movim.movdat >= vdti-ant
                     and movim.movdat <= vdtf-ant no-lock:
                     
        assign tt-tbmeta.venda-ant = tt-tbmeta.venda-ant
                                        + (movim.movpc * movim.movqtm).
    
    end.

    for each produ where produ.catcod = tt-tbmeta.catcod
                     and produ.clacod = tt-cla.cla-cod no-lock,
    
        each movim where movim.etbcod = estab.etbcod
                     and movim.movtdc = 5
                     and movim.procod = produ.procod
                     and movim.movdat >= vdti
                     and movim.movdat <= vdtf no-lock:
                     
        assign tt-tbmeta.venda-atu = tt-tbmeta.venda-atu
                                        + (movim.movpc * movim.movqtm).
    
    end.
    /*
    message "tt-tbmeta.venda-atu " tt-tbmeta.venda-atu.
    pause.
    */
end.

end.

for each tt-tbmeta exclusive-lock.

    assign tt-tbmeta.venda-met   =  tt-tbmeta.venda-ant
                                 + (tt-tbmeta.venda-ant * tt-tbmeta.perc / 100).
    
    assign tt-tbmeta.percent-dif = (tt-tbmeta.venda-atu * 100)
                                        / tt-tbmeta.venda-met.

    assign tt-tbmeta.perc-atual = ((tt-tbmeta.venda-atu * 100)
                                        / tt-tbmeta.venda-ant) - 100.

end.

if opsys = "UNIX"
then varquivo = "/admcom/relat/relat_acoes_setor_" + string(time).
else varquivo = "l:\relat\relat_acoes_setor_" + string(time).

{mdad.i
      &Saida     = "value(varquivo)"
      &Page-Size = "64"
      &Cond-Var  = "120"
      &Page-Line = "64"
      &Nom-Rel   = ""rmetset1.p""
      &Nom-Sis   = """SISTEMA GERENCIAL"""
      &Tit-Rel   = """RELATORIO DE METAS POR SETOR DE "" +
                             string(vdti,""99/99/9999"") + "" ATE "" +
                             string(vdtf,""99/99/9999"") "
      &Width     = "132"
      &Form      = "frame f-cabcab"}

      
for each estab no-lock.

    assign vmostra-sep = no.
    
    if not can-find (first tt-tbmeta where tt-tbmeta.etbcod = estab.etbcod)
    then next.
    
   assign vcha-filial-aux = "Filial " + string(estab.etbcod)     
                               + " - "
                               + string(estab.munic) .        


    display
    vcha-filial-aux     format "x(30)" no-label
        with frame f03 width 120 down centered.

for each tt-tbmeta where tt-tbmeta.etbcod = estab.etbcod no-lock,

    first filialsup where filialsup.etbcod = tt-tbmeta.etbcod no-lock,
    
    first clase where clase.clacod = tt-tbmeta.cla-cod
                  /*and clase.clasup = 0*/ no-lock.

    assign vmostra-sep = yes.
                           
    assign vcha-clase-aux = string(tt-tbmeta.cla-cod)
                                + " - "    
                                + string(clase.clanom). 
                             
    display vcha-clase-aux        format "x(42)"     column-label ""
            tt-tbmeta.perc        format "->,>>9.99%" column-label "Meta"
            tt-tbmeta.perc-atual  format "->,>>9.99%" column-label "Atual"
            tt-tbmeta.venda-met   format "->>,>>>,>>>,>>9.99"
                                column-label "Meta de Venda"
            tt-tbmeta.venda-atu   format "->>>,>>>,>>9.99"
                with frame f02 down width 132.

    assign vcha-label-aux = "Venda " + string(tt-tbmeta.ano).      
    
    run troca-label(input tt-tbmeta.venda-atu:handle,            
                    input vcha-label-aux).                         

    for each tbacao where tbacao.cla-cod = tt-tbmeta.cla-cod                                           and tbacao.ano     = 0
                      and tbacao.mes     = 0                                                                        no-lock:
       
        release tbacao-fil.
        
        find first tbacao-fil where tbacao-fil.acaocod = tbacao.acaocod
                                and tbacao-fil.etbcod = tt-tbmeta.etbcod
                                and tbacao-fil.cla-cod = tbacao.cla-cod
                                and tbacao-fil.ano = tt-tbmeta.ano
                                and tbacao-fil.mes = tt-tbmeta.mes
                                                         no-lock no-error.


         if avail tbacao-fil
             and tbacao-fil.situacao = "REALIZADA"
         then assign vcha-situacao = tbacao-fil.situacao.
         else assign vcha-situacao = "PENDENTE".
            
         display tbacao.acaocod column-label ""
                 " - "          column-label ""
                 tbacao.acaodes format "x(100)" column-label "Acao"
                 vcha-situacao   format "x(10)"             label "Situacao"
                        with frame f05 width 132 down.
         
         assign vcha-situacao = "".

    end.
    
    
end.

if vmostra-sep
then display 
        fill("-",130) format "x(130)"
              with frame f04 down width 132. 

end.

output close.    
    
if opsys = "UNIX"
then do:

    message "Arquivo gerado: " varquivo. pause 0.
               
    run visurel.p (input varquivo, input "").
                        
end.
else do:
    {mrod.i}
end.
end. 

procedure troca-label:

    def input parameter par-handle as handle.
    def input parameter par-label as char.
        
    if par-label = "NO-LABEL"
    then par-handle:label = ?.
    else par-handle:label = par-label.
           
end procedure.




