{admcab.i new}
    

def var vetb-cod like estab.etbcod.
def var vcli-for like clien.clicod.
def var vtotal as dec.

def var vtipo as char.
def var data-ori as date.
def var data-des as date.
def var valor-tr as dec format ">>>,>>>,>>9.99".
def var valor-ux as dec format ">>>,>>>,>>9.99".
def var valor-tb as dec format ">>>,>>>,>>9.99".
def var valor-tb1 as dec format ">>>,>>>,>>9.99".

def var vest as dec.
def var vrec1 as dec.
def var vrec2 as dec.

def var vemissao as dec.
def var vrecebimento as dec.
def var vjuro as dec.
def var vtitvlcob as dec.

def var v-finestemi as dec.
def var v-finestacr as dec.
def var v-reneg as dec.
def var v-devol as dec.
def var v-estorno as dec.
def var v-recnovacao as dec.
def var vacrescimo as dec.
def var vemiacre as dec.
def var v-emicanfin as dec.
def var v-recestfin as dec.

def var varqexp as char.
def stream tl .
def var vdata1 as date. 
def var vhist as char.
def var vetbcod like estab.etbcod.
 
def var vatu as log format "Sim/Nao".

update data-ori Label "Data origem"
       data-des label "Data destino"
       valor-tr label "Valor transferir" format ">>,>>>,>>9.99"
       vatu     label "Atualizar"
       with frame f-dt 1 down
       1 column.

def buffer barqclien for arqclien.
def buffer ctitulo for titulo.

def var vclifor like titulo.clifor.
def var vtitnum like titulo.titnum.
def var vtitdtpag like titulo.titdtpag.
def var vtitpar like titulo.titpar.
def buffer btitulo for titulo.

for each estab where estab.etbcod < 200 no-lock:

    disp "Processando... " estab.etbcod valor-tr valor-ux
    with frame f-dd 1 down no-box no-label
    row 10 centere color message.
    pause 0.
    
    if valor-ux < valor-tr and
       valor-tr - valor-ux > 2
    then do:
        valor-tb = 0.
        for each arqclien where   
             arqclien.mes  = month(data-ori) and
             arqclien.ano  = year(data-ori)  and
             arqclien.tipo begins "RECEBIMENTO"  and
             arqclien.etbcod = estab.etbcod and
             arqclien.data = data-ori
                      no-lock:
            vclifor = int(substr(string(campo2),2,10)).
            vtitnum = campo5.
            vtitdtpag   = data.
            vtitpar = 0.
            /*disp vtitnum with frame f-tit.
            pause 0.
            */
            find first ctitulo where
                       ctitulo.clifor = vclifor and
                       ctitulo.titnum   = vtitnum
                       no-lock no-error.
            if avail ctitulo and ctitulo.titdtemi < data-des
            then.
            else next.
            /*disp ctitulo.titdtemi with frame f-tit.
            pause 0.            
            */
            for each titulo where
                 titulo.empcod   = ctitulo.empcod and
                 titulo.titnat   = ctitulo.titnat   and
                 titulo.modcod   = ctitulo.modcod and
                 titulo.etbcod   = ctitulo.etbcod and
                 titulo.clifor   = vclifor and
                 titulo.titnum   = vtitnum and
                 titulo.titdtpag = vtitdtpag and
                 titulo.titvlcob = dec(campo8) and
                 (titulo.moecod = "REA" /* or
                  titulo.moecod = "" or
                  titulo.moecod = "CHV"*/)
                 no-lock:
                 valor-tb = valor-tb + titulo.titvlcob.
            end.
        end.
        if valor-tb = 0 then next.
        valor-tb = valor-tb * .80.
        valor-tb1 = 0.
        for each arqclien where 
             arqclien.mes  = month(data-ori) and
             arqclien.ano  = year(data-ori)  and
             arqclien.tipo begins "RECEBIMENTO"  and
             arqclien.etbcod = estab.etbcod and
             arqclien.data = data-ori
             :
                
            vclifor = int(substr(string(campo2),2,10)).
            vtitnum = campo5.
            vtitdtpag   = data.
            vtitpar = 0.

            find first ctitulo where
                       ctitulo.clifor = vclifor and
                       ctitulo.titnum   = vtitnum
                       no-lock no-error.
            if avail ctitulo and ctitulo.titdtemi < data-des
            then.
            else next.

            for each titulo where
                 titulo.empcod   = ctitulo.empcod and
                 titulo.titnat   = ctitulo.titnat   and
                 titulo.modcod   = ctitulo.modcod and
                 titulo.etbcod   = ctitulo.etbcod and
                 titulo.clifor   = vclifor and
                 titulo.titnum   = vtitnum and
                 titulo.titdtpag = vtitdtpag and
                 titulo.titvlcob = dec(campo8) and
                 (titulo.moecod = "REA" /*or
                  titulo.moecod = "" or
                  titulo.moecod = "CHV"*/)
                 no-lock:
                if titulo.titpar > vtitpar 
                then vtitpar = titulo.titpar.
            end.
            find first btitulo where
                 btitulo.empcod   = ctitulo.empcod and
                 btitulo.titnat   = ctitulo.titnat   and
                 btitulo.modcod   = ctitulo.modcod and
                 btitulo.etbcod   = ctitulo.etbcod and
                 btitulo.clifor   = vclifor and
                 btitulo.titnum   = vtitnum and
                 btitulo.titdtpag = vtitdtpag and
                 btitulo.titvlcob = dec(campo8) and
                 btitulo.titpar = vtitpar 
                 no-lock no-error.
            if avail btitulo
            then do:
                if (btitulo.titvlcob + valor-tb1) <= valor-tb and
                   (btitulo.titvlcob + valor-ux)  <= valor-tr
                then do:
                    valor-tb1 = valor-tb1 + btitulo.titvlcob.
                    valor-ux = valor-ux + btitulo.titvlcob.
                    if vatu
                    then do:

                        assign
                            arqclien.mes = month(data-des)
                            arqclien.ano = year(data-des)
                            arqclien.data = data-des
                            arqclien.campo6 = (string(year(data-des),"9999") +
                                string(month(data-des),"99") +
                                string(day(data-des),"99"))
                                .

                        run ajusta-ctbreceb.
                    end.
                end.   
            end.
        end.         
    end.
end.                        
                
disp valor-tr valor-ux.

procedure ajusta-ctbreceb:

    find ctbreceb where
             ctbreceb.rectp  = "" and
             ctbreceb.etbcod =  estab.etbcod and
             ctbreceb.datref =  data-ori and
             ctbreceb.moecod = "REA"
             no-error.
    if avail ctbreceb
    then assign
            ctbreceb.valor1 = ctbreceb.valor1 - btitulo.titvlcob
            ctbreceb.valor2 = ctbreceb.valor2 + btitulo.titvlcob.
    find first ctcartcl where 
               ctcartcl.etbcod = estab.etbcod and
               ctcartcl.datref = data-ori 
               no-error
               .
    if avail ctcartcl
    then ctcartcl.recebimento = ctcartcl.recebimento - btitulo.titvlcob.
  
    find ctbreceb where
             ctbreceb.rectp  = "" and
             ctbreceb.etbcod =  estab.etbcod and
             ctbreceb.datref =  data-des and
             ctbreceb.moecod = "REA"
             no-error.
    if avail ctbreceb
    then assign
            ctbreceb.valor1 = ctbreceb.valor1 + btitulo.titvlcob
            ctbreceb.valor3 = ctbreceb.valor3 + btitulo.titvlcob.
    else do:
        create ctbreceb.
        assign
            ctbreceb.rectp  = ""
            ctbreceb.etbcod =  estab.etbcod
            ctbreceb.datref =  data-des
            ctbreceb.moecod = "REA"
            ctbreceb.valor1 = ctbreceb.valor1 + btitulo.titvlcob
            ctbreceb.valor3 = ctbreceb.valor3 + btitulo.titvlcob
            .
    end. 
    find first ctcartcl where 
               ctcartcl.etbcod = estab.etbcod and
               ctcartcl.datref = data-des 
               no-error
               .
    if avail ctcartcl
    then ctcartcl.recebimento = ctcartcl.recebimento + btitulo.titvlcob.
    else do:
        create ctcartcl.
        assign
            ctcartcl.etbcod = estab.etbcod 
            ctcartcl.datref = data-des
            ctcartcl.recebimento = btitulo.titvlcob
            .
    end.            
               
end procedure.


