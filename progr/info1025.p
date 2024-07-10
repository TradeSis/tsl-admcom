{/admcom/progr/cntgendf.i}
find first tbcntgen where tbcntgen.etbcod = 1025 no-lock no-error.
if not avail tbcntgen  or 
    (tbcntgen.validade <> ? and
     tbcntgen.validade < today)
then do:
    message "Controle para INFORMATIVO nao cadastrado ou desativado".
    pause 0.
    return.
end.


def var varquivo    as char.
def var venvmail    as log.

def var vtem-produ  as log.

def var varq-sup-sup  as char.
def var varq-sup      as char.
def var varq-loja     as char.

def var vcont       as integer.

def var vsp         as character.

def var vdti       as date.
def var vdtf       as date.

def var vdti-ant     as date.
def var vdtf-ant     as date.

def var varqdg     as character.

def var varq-text  as character.

def buffer bclase for clase.

def buffer cclase for clase.
def buffer dclase for clase.
def buffer eclase for clase.

def var vcha-email     as char.
def var vcha-assunto   as char.
def var vcha-texto     as char.
                           
define temp-table tt-cla
        field cla-cod       as integer
        field clasup        as integer
        index idx01 cla-cod.

def temp-table tt-ano
    field ano as integer
    index idx01 ano.    

def temp-table tt-titluc
    field etbcod      like titluc.etbcod
    field titnum      like titluc.titnum
    field clifor      like titluc.clifor
    field fornom      like foraut.fornom
    field titdtven    as char           format "99/99/9999"
    field titvlcob    as char             format ">>>,>>9.99"
    field titsit      like titluc.titsit
    field autlp       like foraut.autlp
           index idx01 etbcod.

def temp-table tt-tbmeta like tbmeta
     field rowid            as rowid
     field catcod           as integer
     field venda-ant        as dec
     field venda-atu        as dec
     field venda-met        as dec 
     field perc-atual       as dec  format "->>,>>9.99"
     index idx-perc perc-atual asc.

def temp-table tt-loja
    field etbcod      as integer
    field cla-cod     as integer
    field cla-des     as char
    field acaocod     as integer
    field acaodes     as char
    field meta        as decimal 
    field atual       as decimal
    field datcad      as date
        index idx01 etbcod cla-cod.

def buffer btt-loja for tt-loja.     
     
def temp-table tt-sup
    field supcod      as integer
    field supnom      as char
    field etbcod      as integer
    field cla-cod     as integer
    field cla-des     as char
    field acaocod     as integer
    field acaodes     as char
    field meta        as decimal 
    field atual       as decimal
    field datcad      as date
        index idx01 etbcod cla-cod.
                         
def temp-table tt-sup-sup
    field supcod      as integer
    field supnom      as char
    field etbcod      as integer
    field cla-cod     as integer
    field cla-des     as char
    field acaocod     as integer
    field acaodes     as char
    field meta        as decimal 
    field atual       as decimal
    field datcad      as date
        index idx01 etbcod cla-cod.
                                                
create tt-ano.
assign tt-ano.ano = integer(year(today)).

assign vdti      = date(01,01,year(today))
       vdtf      = today - 1     
       vdti-ant  = date(01,01,year(today) - 1)
       vdtf-ant  = date(month(vdtf) + 1,01,year(today) - 1) - 1.

assign vsp = "&nbsp;". 

venvmail = no.

for each tt-ano no-lock,
    
    each estab no-lock,

    each tbmeta where tbmeta.etbcod = estab.etbcod
                  and tbmeta.ano    = tt-ano.ano no-lock,
                   
    first clase where clase.clacod = tbmeta.cla-cod
                  and clase.clasup = 0  no-lock.

    create tt-tbmeta.
    
    buffer-copy tbmeta to tt-tbmeta.

    assign tt-tbmeta.rowid = rowid(tbmeta)
           tt-tbmeta.catcod = integer(clase.claper).

    find first tt-cla where tt-cla.cla-cod = tbmeta.cla-cod no-lock no-error.
    if not avail tt-cla
    then do:
        create tt-cla.
        assign tt-cla.cla-cod = tbmeta.cla-cod
               tt-cla.clasup  = tbmeta.cla-cod.
    end.

    for each cclase where cclase.clasup = tbmeta.cla-cod no-lock.
    
        find first tt-cla where tt-cla.cla-cod = cclase.clacod
                                                 no-lock no-error.
        if not avail tt-cla
        then do:
            create tt-cla.
            assign tt-cla.cla-cod = cclase.clacod
                   tt-cla.clasup  = tbmeta.cla-cod.
        end.
        
        for each dclase where dclase.clasup = cclase.clacod no-lock.
        
            find first tt-cla where tt-cla.cla-cod = dclase.clacod
                                                      no-lock no-error.
            if not avail tt-cla
            then do:
                create tt-cla.
                assign tt-cla.cla-cod = dclase.clacod
                       tt-cla.clasup  = tbmeta.cla-cod.
            end.
            
            for each eclase where eclase.clasup = dclase.clacod no-lock.
                
                find first tt-cla where tt-cla.cla-cod = eclase.clacod
                                                    no-lock no-error.
                if not avail tt-cla
                then do:
                    create tt-cla.
                    assign tt-cla.cla-cod = eclase.clacod
                           tt-cla.clasup  = tbmeta.cla-cod.
                end.
            end.                       
        end.
    end.
end.

for each tt-ano no-lock,

    each estab no-lock,

    each tt-cla no-lock.

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

end.

for each tt-tbmeta exclusive-lock.

    assign tt-tbmeta.venda-met   =  tt-tbmeta.venda-ant
                                 +(tt-tbmeta.venda-ant * tt-tbmeta.perc / 100).
    
    assign tt-tbmeta.perc-atual = ((tt-tbmeta.venda-atu * 100)
                                        / tt-tbmeta.venda-ant) - 100.

end.

pause 0 no-message.

for each tt-tbmeta no-lock,

    each estab where estab.etbcod = tt-tbmeta.etbcod no-lock:

    find last clase where clase.clacod = tt-tbmeta.cla-cod
                      and clase.clasup = 0 no-lock no-error.

    find last filialsup where filialsup.etbcod = estab.etbcod
                                                    no-lock no-error.
    
    find last supervisor where supervisor.supcod = filialsup.supcod
                                                    no-lock no-error.

    if tt-tbmeta.perc-atual < tt-tbmeta.perc
    then do:

        for each tbacao where tbacao.cla-cod = tt-tbmeta.cla-cod
                          and tbacao.ano     = tt-tbmeta.ano    
                          and tbacao.mes     = tt-tbmeta.mes    
                                        no-lock:

            release tbacao-fil.
            
            find first tbacao-fil where tbacao-fil.ano     = tt-tbmeta.ano
                                    and tbacao-fil.mes     = tt-tbmeta.mes
                                    and tbacao-fil.cla-cod = tbacao.cla-cod
                                    and tbacao-fil.etbcod = tt-tbmeta.etbcod
                                            no-lock no-error.
            
            if not avail tbacao-fil or tbacao-fil.situacao <> "REALIZADA"
            then do:
            
                if tbacao.datcad <= today - 21
                then do:
                
                    create tt-sup-sup.
                    assign tt-sup-sup.supcod  = filialsup.supcod
                           tt-sup-sup.supnom  = supervisor.supnom
                           tt-sup-sup.etbcod  = estab.etbcod
                           tt-sup-sup.cla-cod = tbacao.cla-cod
                           tt-sup-sup.cla-des = clase.clanom
                           tt-sup-sup.acaocod = tbacao.acaocod
                           tt-sup-sup.acaodes = tbacao.acaodes
                           tt-sup-sup.datcad  = tbacao.datcad
                           tt-sup-sup.meta    = tt-tbmeta.perc
                           tt-sup-sup.atual   = tt-tbmeta.perc-atual
                           .

                end.
                
                if tbacao.datcad <= today - 14
                then do:
                
                    create tt-sup.
                    assign tt-sup.supcod  = filialsup.supcod
                           tt-sup.supnom  = supervisor.supnom
                           tt-sup.etbcod  = estab.etbcod
                           tt-sup.cla-cod = tbacao.cla-cod
                           tt-sup.cla-des = clase.clanom
                           tt-sup.acaocod = tbacao.acaocod
                           tt-sup.acaodes = tbacao.acaodes
                           tt-sup.datcad  = tbacao.datcad
                           tt-sup.meta    = tt-tbmeta.perc
                           tt-sup.atual   = tt-tbmeta.perc-atual
                           .

                end.
                
                if tbacao.datcad <= today - 7
                then do:
                                                
                    create tt-loja.
                    assign tt-loja.etbcod  = estab.etbcod
                           tt-loja.cla-cod = tbacao.cla-cod
                           tt-loja.cla-des = clase.clanom
                           tt-loja.acaocod = tbacao.acaocod
                           tt-loja.acaodes = tbacao.acaodes
                           tt-loja.datcad  = tbacao.datcad
                           tt-loja.meta    = tt-tbmeta.perc
                           tt-loja.atual   = tt-tbmeta.perc-atual
                           .
                
                end.
                 
            end.
         
        end. 
         
    end.

end.


/************** Émerson - Supervisor dos Supervisores **********/

assign varq-sup-sup = "/admcom/work/info1025-sup-sup.html".
    
output to value(varq-sup-sup).
        
put unformatted
    "<html>" skip
    "<body>" skip
    "<table border='3' cellpadding='3' cellspacing='3' borderColor=black>" skip
    "<tr><td colspan='8'><center><b>LOJAS COM ACÕES ATRASADAS PARA"
    " SETORES ABAIXO DA META</b></center></td></tr>"
    skip(1).

assign vcha-email   = "emerson@lebes.com.br"
       vcha-assunto = "info1025 - Lojas com Ações atrasadas para setores abaixo da meta".                         
put unformatted
    "<tr><td>SUPERVISOR</td><td>LOJA</td><td>SETOR</td>"
    "<td>META</td><td>ATUAL</td>"
    "<td>ACAO</td><td>DIAS EM ATRASO</td></tr>"         
               skip.


for each tt-sup-sup no-lock:
    
    put unformatted
        "<tr><td>"  tt-sup-sup.supnom 
        "</td><td>Filial: " tt-sup-sup.etbcod
        "</td><td>" tt-sup-sup.cla-cod " - " tt-sup-sup.cla-des
        "</td><td>" tt-sup-sup.meta format "->,>>9.99%"
        "</td><td>" tt-sup-sup.atual format "->,>>9.99%"
        "</td><td>" tt-sup-sup.acaocod " - " tt-sup-sup.acaodes
        "</td><td>" today - tt-sup-sup.datcad   
        "</td></tr>"
        ""skip.
    
end.

output close.

assign vcha-texto = varq-sup-sup.

if can-find (first tt-sup-sup)
then run p-comum.


/****** SUPERVISORES **************/

for each supervisor no-lock:                    

    if not can-find(first tt-sup where tt-sup.supcod = supervisor.supcod)
    then next.
    
    assign varq-sup = "/admcom/work/info1025-sup-"
                            + string(supervisor.supcod)
                            + ".html".                
                    
    assign vcha-email = supervisor.email.
    
    output to value(varq-sup).
        
    put unformatted
        "<html>" skip
        "<body>" skip
        "<table border='3' cellpadding='3' cellspacing='3' borderColor=black>"
                                            skip
        "<tr><td colspan='8'><center><b>LOJAS COM ACÕES ATRASADAS PARA"
        " SETORES ABAIXO DA META</b></center></td></tr>"
                    skip(1).
                    
    assign
    vcha-assunto = "info1025 - Lojas com Ações atrasadas para setores abaixo da meta".                          
    put unformatted
        "<tr><td>LOJA</td><td>SETOR</td>"
        "<td>META</td><td>ATUAL</td>"
        "<td>ACAO</td><td>DIAS EM ATRASO</td></tr>"         
                   skip.

    for each tt-sup where tt-sup.supcod = supervisor.supcod no-lock:
    
        put unformatted
            "<tr><td>Filial: " tt-sup.etbcod
            "</td><td>" tt-sup.cla-cod " - " tt-sup.cla-des
            "</td><td>" tt-sup.meta format "->,>>9.99%"
            "</td><td>" tt-sup.atual format "->,>>9.99%"
            "</td><td>" tt-sup.acaocod " - " tt-sup.acaodes
            "</td><td>" today - tt-sup.datcad
            "</td></tr>"
            ""skip.
    
    end.
    
    output close.
    
    assign vcha-texto = varq-sup.
    
    run p-comum.

end.





/************** filiais **************/

for each estab no-lock:                    
    
    if not can-find (first btt-loja where btt-loja.etbcod = estab.etbcod)
    then next.
        
    assign varq-loja = "/admcom/work/info1025-filial-"
                            + string(estab.etbcod)
                            + ".html".                
                    
    if estab.etbcod <= 9
    then assign vcha-email = "filial0"
                                + trim(string(estab.etbcod))
                                + "@lebes.com.br".
    else assign vcha-email = "filial"
                                + trim(string(estab.etbcod))
                                + "@lebes.com.br".
    
    
    output to value(varq-loja).

    put unformatted
        "<html>" skip
        "<body>" skip
        "<table border='3' cellpadding='3' cellspacing='3' borderColor=black>"
                                            skip
        "<tr><td colspan='8'><center><b>ACÕES ATRASADAS PARA"
        " SETORES ABAIXO DA META</b></center></td></tr>"
                    skip(1).
                    
    assign
    vcha-assunto = "info1025 - Ações atrasadas para setores abaixo da meta".                          
    put unformatted
        "<tr><td>SETOR</td>"
        "<td>META</td><td>ATUAL</td>"
        "<td>ACAO</td><td>DIAS EM ATRASO</td></tr>"         
                   skip.

    for each tt-loja where tt-loja.etbcod = estab.etbcod no-lock:
    
        put unformatted
            "<tr><td>" tt-loja.cla-cod " - " tt-loja.cla-des
            "</td><td>" tt-loja.meta format "->,>>9.99%"
            "</td><td>" tt-loja.atual format "->,>>9.99%"
            "</td><td>" tt-loja.acaocod " - " tt-loja.acaodes
            "</td><td>" today - tt-loja.datcad
            "</td></tr>"
            ""skip.
    
    end.
    
    output close.
    
    assign vcha-texto = varq-loja.
    
    run p-comum.

end.








procedure p-comum:

    varqdg = "/admcom/progr/mail.sh "
               + "~"" + vcha-assunto + "~"" + " ~""
               + vcha-texto + "~"" + " ~""
               + vcha-email + "~""
               + " ~"informativo@lebes.com.br~""
               + " ~"text/html~"".
    unix silent value(varqdg).

end.
     /*
if venvmail = yes
then do:
    run /admcom/progr/envia_info.p("1025", varquivo).
end.
       */
