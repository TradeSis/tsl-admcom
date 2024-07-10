def var varquivo as char. 
{/admcom/progr/cntgendf.i}

find first tbcntgen where tbcntgen.etbcod = 5 no-lock no-error.
if not avail tbcntgen  or 
    (tbcntgen.validade <> ? and
     tbcntgen.validade < today)
then do:
    message "Controle para DG nao cadastrado ou desativado".
    pause 0.
    return.
end.

def var vaspas as char format "x(1)".
vaspas = chr(34).

def temp-table ttlj 
    field etbcod like estab.etbcod
    field valor as dec format "->>>,>>>,>>9.99"
    field data as date.
    
def temp-table ttloja
    field etbcod like estab.etbcod
    field etbnom like estab.etbnom
    field platot as dec format "->>>,>>>,>>9.99"
    field data as date.
    
def var vtotal as dec.
def var d as date .
def var vi as date.
def var vf as date.

def var vdia as char extent 7 initial ["DOMINGO","SEGUNDA","TERCA","QUARTA","QUINTA","SEXTA","SABADO"].

assign vi = today - 1 
       vf = today - 1.

def var vdata as date.
vdata = vi.

for each recorde where recorde.vencod = 0 no-lock:

    create ttlj.
    assign ttlj.etbcod = recorde.etbcod
           ttlj.valor  = recorde.vlreco
           ttlj.data   = recorde.dtreco.

end.

for each estab where estab.etbcod <= 900:
   if {conv_igual.i estab.etbcod} then next.

    find first ttlj where ttlj.etbcod = estab.etbcod no-lock no-error.
    if not avail ttlj
    then do :
        create ttlj.
        ttlj.etbcod = estab.etbcod.
        ttlj.valor = 0.
    end.
end.

output to /admcom/work/dg005.log append.
    put "Criou as Lojas " skip.
output close.

run calc.
/****
for each ttlj,
    each ttloja where ttloja.etbcod = ttlj.etbcod break by ttloja.platot desc:

    output to /admcom/work/dg005.log append.
        put "Verificando Loja " ttloja.etbcod
            skip.
    output close.

    if first-of(ttloja.platot) 
    then do :
        if ttloja.platot > ttlj.valor
        then do :
            
            varquivo = "/admcom/work/arquivodg005.htm".
            output to value(varquivo).

                put "<html>" skip
                    "<body>" skip
                   skip
                   "<table border=" vaspas "0" vaspas "summary=>" skip
                   "<tr>" skip
               "<td width=766 align=center><b><h2>RECORDE MAIOR VENDA DA LOJA"
                   "</h2></b></td>" skip
                   "</tr>" skip
                   "</table>" skip
                   "<table border=" vaspas "3
                   " vaspas "borderColor=green summary=>"
                   "<tr>"
                   "<td width=766 align=center><b>RECORDE</b></td>" skip
                   "</tr>" skip
                   "</table>" skip
                   "<table border=" vaspas "3" 
                   vaspas " borderColor=green>" skip.

                put "<tr>" skip
                    "<td width=140 align=left><b>Data Recorde :</b></td>"  skip
                    "<td width=620 align=left>" ttloja.data format "99/99/9999"
                    "</td>" skip
                    "</tr>" skip.
                
                put "<tr>" skip
                    "<td width=140 align=left><b>Valor Vendido :</b></td>" skip
                    "<td width=620 align=left>" ttloja.platot
                    "</td>" skip
                    "</tr>" skip.

                put "<tr>" skip
                  "<td width=140 align=left><b>Data Recorde Anterior:</b></td>"
                    skip
                    "<td width=620 align=left>" ttlj.data format "99/99/9999"
                    "</td>" skip
                    "</tr>" skip.

                put "<tr>" skip
                    "<td width=140 align=left><b>Recorde Anterior :</b></td>"
                    skip 
                    "<td width=620 align=left>" ttlj.valor 
                    "</td>" skip 
                    "</tr>" skip.

                put "<tr>" skip
                    "<td width=140 align=left><b>Loja :</b></td>"  skip
                    "<td width=620 align=left>" ttloja.etbcod
                    "</td>" skip
                    "</tr>" skip
                    "</table>" skip
                    "</body>" skip
                    "</html>".

            output close.
            
            /*
            run recorde-in.
            */

            ttlj.valor = ttloja.platot.
            ttlj.data = ttloja.data.
            
            run /admcom/progr/envia_dg.p("5",varquivo).
 
            /*
            if ttlj.etbcod = 0
            then do:
                run /admcom/progr/envia_dg.p("5",varquivo).
            end.
            else do:
                run /admcom/progr/envia_dg.p("5",varquivo).
            end.
            */
        end.
    end.
end.    
***/
varquivo = "/admcom/work/arquivodg005b.htm".

do d = vf to vi by -1:
    for each ttloja where ttloja.etbcod <> 0
                      and ttloja.data = d 
                      break by ttloja.platot desc:

        if first(ttloja.platot)
        then do:
            output to value(varquivo).
                
                put "<html>" skip
                    "<body>" skip
                   skip
                   "<table border=" vaspas "0" vaspas "summary=>" skip
                   "<tr>" skip
               "<td width=766 align=center><b><h2>RECORDE DE VENDA EM TODA REDE"
                   "</h2></b></td>" skip
                   "</tr>" skip
                   "</table>" skip
                   "<table border=" vaspas "3
                   " vaspas "borderColor=green summary=>"
                   "<tr>"
                   "<td width=766 align=center><b>RECORDE</b></td>" skip
                   "</tr>" skip
                   "</table>" skip
                   "<table border=" vaspas "3" 
                   vaspas " borderColor=green>" skip.

                put "<tr>" skip
                    "<td width=140 align=left><b>Data Recorde :</b></td>"  skip
                    "<td width=620 align=left>" ttloja.data format "99/99/9999"
                    "</td>" skip
                    "</tr>" skip.
                
                put "<tr>" skip
                    "<td width=140 align=left><b>Valor Vendido :</b></td>" skip
                    "<td width=620 align=left>" ttloja.platot
                    "</td>" skip
                    "</tr>" skip.

                put "<tr>" skip
                    "<td width=140 align=left><b>Filial:</b></td>"  skip
                    "<td width=620 align=left>" ttloja.etbcod
                    "</td>" skip
                    "</tr>" skip
                    "</table>" skip
                    "</body>" skip
                    "</html>".

            output close.
            /***07/04/2008***/
            
            run recorde-in .
            
            RUN /admcom/progr/envia_dg.p("5",varquivo).
            
        end.
    end.
end.

output to /admcom/dg/rankloj.ini.
for each ttlj :
    export ttlj.etbcod ttlj.valor ttlj.data.
end.
output close.

procedure recorde-in:
            find recorde where recorde.vencod = 0 and
                recorde.etbcod = ttlj.etbcod
                no-error.
            if not avail recorde
            then do:
                create recorde.
                assign
                    recorde.vencod = 0
                    recorde.etbcod = ttlj.etbcod
                    recorde.dtreco = vdata
                    recorde.vlreco = ttloja.platot
                    .
            end.
            else do:
                assign
                    recorde.dtrecoant = recorde.dtreco
                    recorde.vlrecoant = recorde.vlreco
                    recorde.dtreco = vdata
                    recorde.vlreco = ttloja.platot
                    .
            end. 
end procedure.
PROCEDURE calc.

    def var vvldesc as dec.
    def var vvlacre as dec.
    def var valtotal as dec.
    def var wacr as dec.

    for each ttloja.
        delete ttloja.
    end.
    
    do d = vi to vf :    
        for each estab where estab.etbcod < 900 no-lock :
            if {conv_igual.i estab.etbcod} then next.

            for each plani where plani.movtdc = 5
                            and  plani.etbcod = estab.etbcod
                            and plani.pladat = d 
                           no-lock :
                find first movim where movim.etbcod = plani.etbcod and
                                       movim.placod = plani.placod and
                                       movim.movtdc = plani.movtdc
                                       no-lock no-error.
                if not avail movim then next.                       
                  
                find first tipmov where tipmov.movtdc = 5 no-lock.  
                              
                find first ttloja where ttloja.etbcod = plani.etbcod 
                                and ttloja.data = d no-error.
                if not avail ttloja
                then do:
                    create ttloja.
                    assign ttloja.etbcod = plani.etbcod
                           ttloja.etbnom = estab.etbnom
                           ttloja.data = d.
                end.
                /*
                if plani.biss <> 0
                then do:
                    if plani.biss <> ?
                    then assign ttloja.platot = ttloja.platot + plani.biss.
                end.    
                else do:
                    if plani.platot <> ?
                    then assign ttloja.platot = ttloja.platot + plani.platot.
                end.
                */
                
                wacr = 0.
                vvldesc = 0.
                vvlacre = 0.
                valtotal = 0.
                if plani.crecod >= 1
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
                
                assign
                   valtotal = valtotal + (plani.platot - /* plani.vlserv -*/
                                  vvldesc + vvlacre) .
                
                assign ttloja.platot = ttloja.platot + valtotal.
                
            end.
        end.
    end.
    
    for each ttloja where ttloja.etbcod = 0:
        delete ttloja.
    end.

    vtotal = 0.
    do d = vi to vf : 
        for each ttloja where ttloja.data = d and ttloja.etbcod <> 0 :
            vtotal = vtotal + ttloja.platot.
        end.
        create ttloja.
        ttloja.etbcod = 0.
        ttloja.etbnom = "EMPRESA".
        ttloja.data = d.
        ttloja.platot = vtotal.
        vtotal = 0.
    end.
end.
