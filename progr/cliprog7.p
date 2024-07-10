{admcab.i}
def shared var vdti as date.
def shared var vdtf as date.
def var vtotal as dec format ">>,>>>,>>9.99".
def temp-table tt-ctcartcl like ctcartcl.

def var tot-tot as dec format ">>,>>>,>>>,>>9.99".

def temp-table tt-contrato
    field contnum like contrato.contnum
    field dtinicial like contrato.dtinicial
    .
    
def buffer bestab for estab.

def var vdinheiro as dec.
def var vcartao as dec.
def var vcheque as dec.

form with frame f1 down row 7.
form with frame f2 down row 7.
form with frame f3 down row 7.
form with frame f11 down row 7.
form with frame f22 down row 7.
form with frame f33 down row 7.



def var vdd as date.
def var vtotal-avista as dec format ">>,>>>,>>9.99".
def var vtotal-finan as dec format ">>,>>>,>>9.99".
  
def var tt-acrescimo as dec.

def temp-table tt-finan
    field data as date
    field valor as dec format ">,>>>,>>9.99"
    field ok as log init no
    index i1 data
    .

def temp-table tt-recfinan
    field recdata as date
    field recvalor as dec format ">,>>>,>>9.99"
    field recok as log init no
    index i1 recdata
    .

def var vtotal-recebimento as dec.
    
def var vlpraz like plani.platot.
def var vlvist like plani.platot.
def var totecf like plani.platot.
def var vlentr like plani.platot.
def var vlpres like plani.platot.
def var vljuro like plani.platot.
def var acr-252 as dec.
def var acr-363 as dec.
def var acr-364 as dec.
def var acr-365 as dec.
def var acr-252-1 as dec.
def var acr-363-1 as dec.
def var acr-364-1 as dec.
def var acr-365-1 as dec.

def var vindex as int.
def var vnomarq as char.
def var vlote as char.
def var vesc as char format "x(15)" extent 8
        init["Venda Vista",
             "Venda Prazo",
             "Acrescimo",
             "Recebimento",
             "Devolucao",
             "Cartao",
             "E/C Financeira",
             "Novacoes"].
         
def var vmes as int.
def var vano as int.
def var data_mes like plani.pladat.
def var v-seq as int.
def var vseq as int.
def var qtd_lote as int.
def var cod_lote as char.
def var cd_batch as char.
def stream stela.
def var vetbcod like estab.etbcod.
def var vdata       like titulo.titdtemi.
def stream tela.
def temp-table tt-cab
    field data   like fiscal.plarec
    field qtdlot as int
    field totval like fiscal.platot
    field codlot as char.
    
def temp-table tt-lanca
    field etbcod like estab.etbcod
    field etbcre as char
    field etbdeb as char
    field subdeb as char
    field subcre as char
    field cre  as char
    field deb  as char
    field val  as dec format ">,>>>,>>9.99" 
    field cod  as int format "999"
    field his  as char format "x(50)"
    field data like fiscal.plarec
    field total_lote as int
    field seq  as int. 
        

form vesc with frame f-esc 1 down no-label 
        row 4.

def var t-total as dec.

def var vbanri as dec.  
def var vvisa as dec .
def var vmaster as dec.
def var vdevvista as dec.
def var vdevprazo as dec.
def var vestorno as dec.
def var vendafinanceira as dec.
def var recebfinanceira as dec.
 
def var vacrescimo as dec.

def temp-table tt-total
    field banri as dec
    field visa  as dec
    field acrescimo as dec
    field master as dec
    field recebimento as dec
    field devolucaov  as dec
    field devolucaop as dec
    field juro as dec
    field avista as dec
    field aprazo as dec
    field estorno as dec
    .

def var varquivo as char.

form with frame ff.
        

create tt-total.        
/*sresp = no.
message "Confirma exportar vendas? " update sresp.
if not sresp then return.
*/

repeat with 1 down side-label width 80 row 7 color blue/white:

    for each tt-lanca:
        delete tt-lanca.
    end.
    
    for each tt-cab:
        delete tt-cab.
    end. 

    for each tt-lanca:
        delete tt-lanca.
    end.
    disp vesc with frame f-esc 1 down side-label no-label row 8
        1 column overlay column 40
        .
    choose field vesc with frame f-esc.
    vindex = frame-index.
    t-total = 0.    
    hide frame f-esc.
    if vindex = 1
    then do:
        run venda-vis-finan.
        if keyfunction(lastkey) = "END-ERROR"
        then undo.
        sresp = no.
        message "Confirma os Valores Informados?" update sresp.
        if not sresp then leave.
        run exporta-valor-finan.
        run calcula-valor.
    end.
    if vindex = 3
    then do:
        run separa-acrescimo.
        if keyfunction(lastkey) = "end-error"
        then leave.
        sresp = no.
        message "Confirma os Valores Informados?" update sresp.
        if not sresp then leave.
    end.
    if vindex = 4
    then do:
        run recebimento-financeira.
        /*
        if keyfunction(lastkey) = "END-ERROR"
        then undo.
        */
        sresp = no.
        message "Confirma os Valores Informados?" update sresp.
        if not sresp then leave.
        
        run exporta-recebimento-finan.
        
    end.

    if keyfunction(lastkey) = "end-error"
    then leave.
    
    output stream stela to terminal.
    do vdata = vdti to vdtf:

        if vindex = 1
        then do:

        for each tt-ctcartcl where tt-ctcartcl.etbcod > 0 and
                 tt-ctcartcl.datref = vdata no-lock
                     by tt-ctcartcl.datref:

            if tt-ctcartcl.etbcod <> 999
            then find estab where estab.etbcod = tt-ctcartcl.etbcod no-lock.
            else find estab where estab.etbcod = 1 no-lock.
            
            assign 
                   vlvist  = 0
                   vendafinanceira = 0
                   .

            if vindex = 1
            then assign
                        vlvist  = tt-ctcartcl.ecfvista
                        vendafinanceira = tt-ctcartcl.dif-ecf-contrato
                        t-total = t-total + tt-ctcartcl.ecfvista.
                  
                        
             display stream stela "Processando... " vdata  label "Data"
                        estab.etbcod 
                      with frame ff side-label 1 down. pause 0.
            if vlvist > 0 or
               vendafinanceira > 0 
            then do:  
                if vindex = 1 then vlote = "60".
                else if vindex = 2 then vlote = "80".
                else if vindex = 3 then vlote = "90".
                else if vindex = 4 then vlote = "70".
                else if vindex = 5 then vlote = "75".
                
                find first tt-cab where tt-cab.data = vdata no-error.
                if not avail tt-cab
                then do:
                    create tt-cab.
                    assign tt-cab.data   = vdata
                           tt-cab.codlot = vlote + string(day(vdata),"99").

                end.
            end. 
            
            if vlvist > 0 
            then do:

                find first tt-lanca 
                           where tt-lanca.etbcre = "01" + 
                                                 string(estab.etbcod,"999") and
                                 tt-lanca.data   = vdata and
                                 tt-lanca.cre    = "161" and
                                 tt-lanca.deb    = "1" no-error.
                   
                if not avail tt-lanca
                then do:
                    create tt-lanca.
                    assign tt-lanca.etbcod  = 01001
                           tt-lanca.etbdeb  = "01001"
                           tt-lanca.etbcre  = "01" + string(estab.etbcod,"999")
                           tt-lanca.data    = vdata
                           tt-lanca.deb     = "1"  
                           tt-lanca.subcre  = ""
                           tt-lanca.subdeb  = ""
                           tt-lanca.cre     = "161"
                           tt-lanca.cod     = 0   
                           tt-lanca.his = "*LIVRE@VENDAS A VISTA N/DATA"
                           tt-cab.qtdlot = tt-cab.qtdlot + 1.
                end.
                assign tt-lanca.val  = tt-lanca.val + vlvist
                       tt-cab.totval = tt-cab.totval + vlvist.
            end.
            if vendafinanceira > 0
            then do:

                create tt-lanca.
                assign tt-lanca.etbcod  = 01001
                       tt-lanca.etbdeb  = "01001"
                       tt-lanca.etbcre  = "01" + string(estab.etbcod,"999")
                       tt-lanca.data    = vdata
                       tt-lanca.deb     = "345"   
                       tt-lanca.subcre  = "" 
                       tt-lanca.subdeb  = "" 
                       tt-lanca.cre     = "161" 
                       tt-lanca.cod     = 0    
                       tt-lanca.his = "*LIVRE@VENDAS A VISTA N/DATA"
                       tt-cab.qtdlot = tt-cab.qtdlot + 1
                       tt-lanca.val  = vendafinanceira
                       tt-cab.totval = tt-cab.totval + vendafinanceira.
            end.
        end.
        end.
        else if vindex = 7
        then do:
            run ec-financeira.
        end.
        else if vindex = 8
        then do:
            run ctb-novacoes.
        end.
        else do:
        for each ctcartcl where ctcartcl.etbcod > 0 and
                 ctcartcl.datref = vdata no-lock
                     by ctcartcl.datref:
            if ctcartcl.etbcod <> 999
            then find estab where estab.etbcod = ctcartcl.etbcod no-lock.
            else find estab where estab.etbcod = 1 no-lock.
            
            if ctcartcl.etbcod = 990
            then next.
            /*
            display stream stela estab.etbcod vdata 
                with frame ff side-label 1 down. pause 0.
            */
            
            assign vlpraz  = 0
                   vlvist  = 0
                   totecf  = 0
                   vlpres  = 0
                   vljuro  = 0
                   vlentr  = 0
                   vacrescimo = 0
                   vbanri = 0
                   vvisa = 0
                   vmaster = 0
                   vdevvista = 0
                   vdevprazo = 0
                   vestorno = 0
                   vendafinanceira = 0
                   recebfinanceira = 0
                   acr-252-1 = 0
                   acr-363-1 = 0
                   acr-364-1 = 0
                   acr-365-1 = 0
                   .

            if vindex = 1
            then assign
                        vlvist  = ctcartcl.ecfvista
                        vendafinanceira = ctcartcl.dif-ecf-contrato
                        t-total = t-total + ctcartcl.ecfvista.
            else if vindex = 2
            then assign 
                    vlpraz  = ctcartcl.ecfprazo
                    vacrescimo  = ctcartcl.acrescimo
                    t-total = t-total + ctcartcl.ecfprazo.
            else if vindex = 3
            then do:
                assign
                    vacrescimo  = ctcartcl.acrescimo
                    t-total = t-total + ctcartcl.acrescimo.
                if ctcartcl.acrescimo > 0
                then do:
                    if ctcartcl.acrescimo >= 1
                    then do:
                    if acr-252 > 0 then
                    acr-252-1 = ctcartcl.acrescimo * (acr-252 / tt-acrescimo).
                    if acr-363 > 0 then
                    acr-363-1 = ctcartcl.acrescimo * (acr-363 / tt-acrescimo).
                    if acr-364 > 0 then
                    acr-364-1 = ctcartcl.acrescimo * (acr-364 / tt-acrescimo).
                    if acr-365 > 0 then
                    acr-365-1 = ctcartcl.acrescimo * (acr-365 / tt-acrescimo).
                    end.
                    else do:
                        /*
                        disp ctcartcl.etbcod
                             ctcartcl.datref.
                             pause.
                        end.
                        */
                        assign
                        /*acr-252 = ctcartcl.acrescimo*/
                        acr-252-1 = ctcartcl.acrescimo.
                    end.
                end.   
            end.
            else if vindex = 4
            then do:
                assign
                        vlpres  = ctcartcl.recebimento
                        t-total = t-total + ctcartcl.recebimento
                        vljuro  = ctcartcl.juro
                        .
                assign vdinheiro = 0  vcartao = 0 vcheque = 0.
                for each ctbreceb where 
                         ctbreceb.etbcod = estab.etbcod and
                         ctbreceb.datref = vdata
                         no-lock:
                    if ctbreceb.moecod = "" or
                       ctbreceb.moecod = "REA"
                    then vdinheiro = vdinheiro + ctbreceb.valor1.
                    if ctbreceb.moecod = "CAR"
                    then vcartao = vcartao + ctbreceb.valor1.
                    if ctbreceb.moecod = "PRE" or
                       ctbreceb.moecod = "CHV"
                    then vcheque = vcheque + ctbreceb.valor1.
                end.         
                recebfinanceira = 0 .
                if estab.etbcod = 1
                then do:
                    find first tt-recfinan where
                           tt-recfinan.recdata = vdata and
                           tt-recfinan.recok = no
                            no-error.
                    if avail tt-recfinan
                    then do:
                        assign
                            recebfinanceira = tt-recfinan.recvalor
                            t-total = t-total + tt-recfinan.recvalor
                            tt-recfinan.recok = yes.
                    end.        
                end.             
             end.
             else if vindex = 5
             then do:
                
                assign
                        vdevvista  = ctcartcl.devolucao
                        t-total = t-total + ctcartcl.devolucao.

                for each contarqm where contarqm.datexp = vdata and
                        contarqm.etbcod = ctcartcl.etbcod and
                        contarqm.situacao = 4
                        .
                 if contarqm.vltotal - contarqm.vlfrete < 0
                 then next.
                 
                 vdevprazo = vdevprazo + contarqm.vltotal.
                 vestorno = vestorno + (contarqm.vltotal - contarqm.vlfrete).
                 
                end.
                /*
                for each arqclien where
                    arqclien.mes = month(vdata) and
                    arqclien.ano = year(vdata) and
                    arqclien.tipo = "DEVOLUCAO" and
                    arqclien.etbcod = estab.etbcod and
                    arqclien.data   = vdata
                    
                    no-lock:
                    vdevprazo = vdevprazo + dec(arqclien.campo8).
                end.
                for each arqclien where
                    arqclien.mes = month(vdata) and
                    arqclien.ano = year(vdata) and
                    arqclien.tipo = "ESTORNO" and
                    arqclien.etbcod = estab.etbcod and
                    arqclien.data   = vdata
                    no-lock:
                    vestorno = vestorno + dec(arqclien.campo8).
                end.    
                */
                t-total = t-total + vdevprazo.    
             end.
             else if vindex = 6
             then do:
                 vbanri = ctcartcl.avista     .
                 vvisa = ctcartcl.aprazo       .
                 vmaster = ctcartcl.emissao     .
 
             end.

             display stream stela "Processando... " vdata  label "Data"
                        estab.etbcod 
                      with frame ff side-label 1 down. pause 0.

            
            if vlvist > 0 or
               vlpraz > 0 or
               vljuro > 0 or
               vlentr > 0 or
               vlpres > 0 or
               vacrescimo > 0 or
               vdevvista > 0  or
               vdevprazo > 0 or
               vestorno > 0 or
               vbanri > 0 or
               vvisa > 0 or
               vmaster > 0 or
               vendafinanceira > 0 or
               recebfinanceira > 0
            then do:  
                if vindex = 1 then vlote = "60".
                else if vindex = 2 then vlote = "80".
                else if vindex = 3 then vlote = "90".
                else if vindex = 4 then vlote = "70".
                else if vindex = 5 then vlote = "75".
                else if vindex = 6 then vlote = "95".
                
                find first tt-cab where tt-cab.data = vdata no-error.
                if not avail tt-cab
                then do:
                    create tt-cab.
                    assign tt-cab.data   = vdata
                           tt-cab.codlot = vlote + string(day(vdata),"99").

                end.
            end. 
            
            if vlvist > 0 
            then do:

                find first tt-lanca 
                           where tt-lanca.etbcre = "01" + 
                                                 string(estab.etbcod,"999") and
                                 tt-lanca.data   = vdata and
                                 tt-lanca.cre    = "161" no-error.
                   
                if not avail tt-lanca
                then do:
                    create tt-lanca.
                    assign tt-lanca.etbcod  = 01001
                           tt-lanca.etbdeb  = "01001"
                           tt-lanca.etbcre  = "01" + string(estab.etbcod,"999")
                           tt-lanca.data    = vdata
                           tt-lanca.deb     = "1"  
                           tt-lanca.subcre  = ""
                           tt-lanca.subdeb  = ""
                           tt-lanca.cre     = "161"
                           tt-lanca.cod     = 0   
                           tt-lanca.his = "*LIVRE@VENDAS A VISTA N/DATA"
                           tt-cab.qtdlot = tt-cab.qtdlot + 1.
                end.
                assign tt-lanca.val  = tt-lanca.val + vlvist
                       tt-cab.totval = tt-cab.totval + vlvist.
            end.
            if vendafinanceira > 0
            then do:
                create tt-lanca.
                assign tt-lanca.etbcod  = 01001
                       tt-lanca.etbdeb  = "01001"
                       tt-lanca.etbcre  = "01" + string(estab.etbcod,"999")
                       tt-lanca.data    = vdata
                       tt-lanca.deb     = "345"   
                       tt-lanca.subcre  = "" 
                       tt-lanca.subdeb  = "" 
                       tt-lanca.cre     = "161" 
                       tt-lanca.cod     = 0    
                       tt-lanca.his = "*LIVRE@VENDAS A VISTA N/DATA"
                       tt-cab.qtdlot = tt-cab.qtdlot + 1
                       tt-lanca.val  = vendafinanceira
                       tt-cab.totval = tt-cab.totval + vendafinanceira.
            end.
            if vljuro > 0
            then do:
                find first tt-lanca 
                     where tt-lanca.etbcre = "01" + 
                                             string(estab.etbcod,"999") and
                           tt-lanca.data   = vdata and
                           tt-lanca.cre    = "234" no-error.
                   
                if not avail tt-lanca 
                then do: 
                    create tt-lanca.
                    assign tt-lanca.etbcod  = 01001
                           tt-lanca.etbdeb  = "01001"
                           tt-lanca.etbcre  = "01001"
                                    /*"01" + string(estab.etbcod,"999")*/
                           tt-lanca.data    = vdata
                           tt-lanca.deb     = "1"  
                           tt-lanca.subcre  = ""
                           tt-lanca.subdeb  = ""
                           tt-lanca.cre     = "234"
                           tt-lanca.cod     = 0   
                           tt-lanca.his     = 
                                    "*LIVRE@REC.DE JUROS DIVS.CLIENTES N/DATA"
                           tt-cab.qtdlot = tt-cab.qtdlot + 1.
                end.
                assign tt-lanca.val  = tt-lanca.val + vljuro
                       tt-cab.totval = tt-cab.totval + vljuro.
            end.
            
            
            if vlpres > 0
            then do:
                if vdinheiro > 0
                then do:
                create tt-lanca.
                assign tt-lanca.etbcod  = 01001
                       tt-lanca.etbdeb  = "01001"
                       tt-lanca.etbcre  = "01001" 
                                    /*"01" + string(estab.etbcod,"999") */
                       tt-lanca.data    = vdata
                       tt-lanca.deb     = "1"   
                       tt-lanca.subcre  = "" 
                       tt-lanca.subdeb  = "" 
                       tt-lanca.cre     = "15" 
                       tt-lanca.cod     = 0    
                       tt-lanca.his = "*LIVRE@REC.DE DIVS.CLIENTES N/DATA" 
                       tt-cab.qtdlot = tt-cab.qtdlot + 1
                       tt-lanca.val  = vdinheiro /*vlpres*/
                       tt-cab.totval = tt-cab.totval + vdinheiro /*vlpres*/.
                end.
                if vcartao > 0
                then do:
                create tt-lanca.
                assign tt-lanca.etbcod  = 01001
                       tt-lanca.etbdeb  = "01001"
                       tt-lanca.etbcre  = "01001" 
                                    /*"01" + string(estab.etbcod,"999") */
                       tt-lanca.data    = vdata
                       tt-lanca.deb     = "443"   
                       tt-lanca.subcre  = "" 
                       tt-lanca.subdeb  = "" 
                       tt-lanca.cre     = "15" 
                       tt-lanca.cod     = 0    
                       tt-lanca.his = "*LIVRE@REC.DE DIVS.CLIENTES N/DATA" 
                       tt-cab.qtdlot = tt-cab.qtdlot + 1
                       tt-lanca.val  = vcartao /*vlpres*/
                       tt-cab.totval = tt-cab.totval + vcartao /*vlpres*/.
                end.
                if vcheque > 0
                then do:
                create tt-lanca.
                assign tt-lanca.etbcod  = 01001
                       tt-lanca.etbdeb  = "01001"
                       tt-lanca.etbcre  = "01001" 
                                    /*"01" + string(estab.etbcod,"999") */
                       tt-lanca.data    = vdata
                       tt-lanca.deb     = "400"   
                       tt-lanca.subcre  = "" 
                       tt-lanca.subdeb  = "" 
                       tt-lanca.cre     = "15" 
                       tt-lanca.cod     = 0    
                       tt-lanca.his = "*LIVRE@REC.DE DIVS.CLIENTES N/DATA" 
                       tt-cab.qtdlot = tt-cab.qtdlot + 1
                       tt-lanca.val  = vcheque /*vlpres*/
                       tt-cab.totval = tt-cab.totval + vcheque /*vlpres*/.
                end.

            end.
            
            
            if vlentr > 0
            then do:
                create tt-lanca.
                assign tt-lanca.etbcod  = 01001
                       tt-lanca.etbdeb  = "01001"
                       tt-lanca.etbcre  = "01001" 
                                        /*"01" + string(estab.etbcod,"999")*/
                       tt-lanca.data    = vdata
                       tt-lanca.deb     = "1"   
                       tt-lanca.subcre  = "" 
                       tt-lanca.subdeb  = "" 
                       tt-lanca.cre     = "15" 
                       tt-lanca.cod     = 0    
                       tt-lanca.his = "*LIVRE@REC.DE DIVS.CLIENTES N/DATA" 
                       tt-cab.qtdlot = tt-cab.qtdlot + 1
                       tt-lanca.val  = vlentr
                       tt-cab.totval = tt-cab.totval + vlentr.
            end.
            
            if vlpraz > 0
            then do:
                create tt-lanca.
                assign tt-lanca.etbcod  = 01001
                       tt-lanca.etbdeb  = "01001"
                       tt-lanca.etbcre  = "01" + string(estab.etbcod,"999")
                       tt-lanca.data    = vdata
                       tt-lanca.deb     = "15"   
                       tt-lanca.subcre  = "" 
                       tt-lanca.subdeb  = "" 
                       tt-lanca.cre     = "162" 
                       tt-lanca.cod     = 0    
                       tt-lanca.his = "*LIVRE@VENDAS A PRAZO CF REG SAIDAS" 
                       tt-cab.qtdlot = tt-cab.qtdlot + 1
                       tt-lanca.val  = vlpraz
                       tt-cab.totval = tt-cab.totval + vlpraz.
            end.
            if vacrescimo  > 0
            then do:
                if int(acr-252-1 * 100) > 0
                then do:
                create tt-lanca.
                assign tt-lanca.etbcod  = 01001
                       tt-lanca.etbdeb  = "01001"
                       tt-lanca.etbcre  = "01" + string(estab.etbcod,"999")
                       tt-lanca.data    = vdata
                       tt-lanca.deb     = "15"   
                       tt-lanca.subcre  = "" 
                       tt-lanca.subdeb  = "" 
                       tt-lanca.cre     = "252" 
                       tt-lanca.cod     = 0    
                       tt-lanca.his = "*LIVRE@VENDAS A PRAZO CF REG SAIDAS" 
                       tt-cab.qtdlot = tt-cab.qtdlot + 1
                       tt-lanca.val  = acr-252-1
                       tt-cab.totval = tt-cab.totval + acr-252-1.
                end.
                if int(acr-363-1 * 100) > 0
                then do:
                create tt-lanca.
                assign tt-lanca.etbcod  = 01001
                       tt-lanca.etbdeb  = "01001"
                       tt-lanca.etbcre  = "01" + string(estab.etbcod,"999")
                       tt-lanca.data    = vdata
                       tt-lanca.deb     = "15"   
                       tt-lanca.subcre  = "" 
                       tt-lanca.subdeb  = "" 
                       tt-lanca.cre     = "363" 
                       tt-lanca.cod     = 0    
                       tt-lanca.his = "*LIVRE@VENDAS A PRAZO CF REG SAIDAS" 
                       tt-cab.qtdlot = tt-cab.qtdlot + 1
                       tt-lanca.val  = acr-363-1
                       tt-cab.totval = tt-cab.totval + acr-363-1.
                end.
                if int(acr-364-1 * 100) > 0
                then do:
                create tt-lanca.
                assign tt-lanca.etbcod  = 01001
                       tt-lanca.etbdeb  = "01001"
                       tt-lanca.etbcre  = "01" + string(estab.etbcod,"999")
                       tt-lanca.data    = vdata
                       tt-lanca.deb     = "15"   
                       tt-lanca.subcre  = "" 
                       tt-lanca.subdeb  = "" 
                       tt-lanca.cre     = "364" 
                       tt-lanca.cod     = 0    
                       tt-lanca.his = "*LIVRE@VENDAS A PRAZO CF REG SAIDAS" 
                       tt-cab.qtdlot = tt-cab.qtdlot + 1
                       tt-lanca.val  = acr-364-1
                       tt-cab.totval = tt-cab.totval + acr-364-1.
                end.
                if int(acr-365-1 * 100) > 0
                then do:
                create tt-lanca.
                assign tt-lanca.etbcod  = 01001
                       tt-lanca.etbdeb  = "01001"
                       tt-lanca.etbcre  = "01" + string(estab.etbcod,"999")
                       tt-lanca.data    = vdata
                       tt-lanca.deb     = "15"   
                       tt-lanca.subcre  = "" 
                       tt-lanca.subdeb  = "" 
                       tt-lanca.cre     = "365" 
                       tt-lanca.cod     = 0    
                       tt-lanca.his = "*LIVRE@VENDAS A PRAZO CF REG SAIDAS" 
                       tt-cab.qtdlot = tt-cab.qtdlot + 1
                       tt-lanca.val  = acr-365-1
                       tt-cab.totval = tt-cab.totval + acr-365-1.
                end.
            end.
            if vbanri  > 0
            then do:
                create tt-lanca.
                assign tt-lanca.etbcod  = 01001
                       tt-lanca.etbdeb  = "01001"
                       tt-lanca.etbcre  = "01" + string(estab.etbcod,"999")
                       tt-lanca.data    = vdata
                       tt-lanca.deb     = "332"   
                       tt-lanca.subcre  = "" 
                       tt-lanca.subdeb  = "" 
                       tt-lanca.cre     = "162" 
                       tt-lanca.cod     = 0    
                       tt-lanca.his = "*LIVRE@VENDAS A PRAZO CF REG SAIDAS" 
                       tt-cab.qtdlot = tt-cab.qtdlot + 1
                       tt-lanca.val  = vbanri
                       tt-cab.totval = tt-cab.totval + vbanri.
            end.
            if vvisa  > 0
            then do:
                create tt-lanca.
                assign tt-lanca.etbcod  = 01001
                       tt-lanca.etbdeb  = "01001"
                       tt-lanca.etbcre  = "01" + string(estab.etbcod,"999")
                       tt-lanca.data    = vdata
                       tt-lanca.deb     = "333"   
                       tt-lanca.subcre  = "" 
                       tt-lanca.subdeb  = "" 
                       tt-lanca.cre     = "162" 
                       tt-lanca.cod     = 0    
                       tt-lanca.his = "*LIVRE@VENDAS A PRAZO CF REG SAIDAS" 
                       tt-cab.qtdlot = tt-cab.qtdlot + 1
                       tt-lanca.val  = vvisa
                       tt-cab.totval = tt-cab.totval + vvisa.
            end.
            if vmaster  > 0
            then do:
                create tt-lanca.
                assign tt-lanca.etbcod  = 01001
                       tt-lanca.etbdeb  = "01001"
                       tt-lanca.etbcre  = "01" + string(estab.etbcod,"999")
                       tt-lanca.data    = vdata
                       tt-lanca.deb     = "334"   
                       tt-lanca.subcre  = "" 
                       tt-lanca.subdeb  = "" 
                       tt-lanca.cre     = "162" 
                       tt-lanca.cod     = 0    
                       tt-lanca.his = "*LIVRE@VENDAS A PRAZO CF REG SAIDAS" 
                       tt-cab.qtdlot = tt-cab.qtdlot + 1
                       tt-lanca.val  = vmaster
                       tt-cab.totval = tt-cab.totval + vmaster.
            end.
            if vdevprazo  > 0
            then do:
                create tt-lanca.
                assign tt-lanca.etbcod  = 01001
                       tt-lanca.etbdeb  = "01001"
                       tt-lanca.etbcre  = "01" + string(estab.etbcod,"999")
                       tt-lanca.data    = vdata
                       tt-lanca.deb     = "163"   
                       tt-lanca.subcre  = "" 
                       tt-lanca.subdeb  = "" 
                       tt-lanca.cre     = "15" 
                       tt-lanca.cod     = 0    
                       tt-lanca.his = "*LIVRE@DEV.N/DATA CF REG.ENTRADAS" 
                       tt-cab.qtdlot = tt-cab.qtdlot + 1
                       tt-lanca.val  = vdevprazo
                       tt-cab.totval = tt-cab.totval + vdevprazo.
            end.
            if vdevvista  > 0
            then do:
                create tt-lanca.
                assign tt-lanca.etbcod  = 01001
                       tt-lanca.etbdeb  = "01001"
                       tt-lanca.etbcre  = "01" + string(estab.etbcod,"999")
                       tt-lanca.data    = vdata
                       tt-lanca.deb     = "293"   
                       tt-lanca.subcre  = "" 
                       tt-lanca.subdeb  = "" 
                       tt-lanca.cre     = "1" 
                       tt-lanca.cod     = 0    
                       tt-lanca.his = "*LIVRE@DEV.N/DATA CF REG.ENTRADAS" 
                       tt-cab.qtdlot = tt-cab.qtdlot + 1
                       tt-lanca.val  = vdevvista
                       tt-cab.totval = tt-cab.totval + vdevvista.
            end.
            if vestorno  > 0
            then do:
                create tt-lanca.
                assign tt-lanca.etbcod  = 01001
                       tt-lanca.etbdeb  = "01001"
                       tt-lanca.etbcre  = "01" + string(estab.etbcod,"999")
                       tt-lanca.data    = vdata
                       tt-lanca.deb     = "15"   
                       tt-lanca.subcre  = "" 
                       tt-lanca.subdeb  = "" 
                       tt-lanca.cre     = "1" 
                       tt-lanca.cod     = 0    
                       tt-lanca.his = "*LIVRE@VENDAS A PRAZO CF REG SAIDAS" 
                       tt-cab.qtdlot = tt-cab.qtdlot + 1
                       tt-lanca.val  = vestorno
                       tt-cab.totval = tt-cab.totval + vestorno.
            end.
            if recebfinanceira  > 0
            then do:
                create tt-lanca.
                assign tt-lanca.etbcod  = 01001
                       tt-lanca.etbdeb  = "01001"
                       tt-lanca.etbcre  = "01" + string(estab.etbcod,"999")
                       tt-lanca.data    = vdata
                       tt-lanca.deb     = "1"   
                       tt-lanca.subcre  = "" 
                       tt-lanca.subdeb  = "" 
                       tt-lanca.cre     = "361" 
                       tt-lanca.cod     = 0    
                       tt-lanca.his = "*LIVRE@REC.DE DIVS.CLIENTES N/DATA" 
                       tt-cab.qtdlot = tt-cab.qtdlot + 1
                       tt-lanca.val  = recebfinanceira
                       tt-cab.totval = tt-cab.totval + recebfinanceira.
            end.
        end.
        end.
    end.
    output stream stela close.

    vseq = 0.
    for each tt-lanca break by tt-lanca.data:
        
        vseq = vseq + 1.
        tt-lanca.seq = vseq.
         
        if last-of(tt-lanca.data)
        then vseq = 0.
        
    end.
    vnomarq = "".
    if vindex = 1
    then vnomarq = "venda_vista".
    else if vindex = 2
    then vnomarq = "venda_prazo".
    else if vindex = 3
    then vnomarq = "acrescimo".
    else if vindex = 4
    then vnomarq = "recebimento".
    else if vindex = 5
    then vnomarq = "devolucao".
    else if vindex = 6
    then vnomarq = "cartao".
    else if vindex = 7
    then vnomarq = "financeira".
    else if vindex = 8
    then vnomarq = "novacao".

    /*
    for each tt-cab where qtdlot > 0.
        vtotal = 0.
        for each tt-lanca where tt-lanca.data   = tt-cab.data:   
            vtotal = vtotal + tt-lanca.val.
        end.    
        if tt-cab.totval <> vtotal
        then tt-cab.totval = vtotal.
    end.
    */
    output to ./teste.clacr.
    for each tt-lanca.
        if tt-lanca.val = 0
        then disp tt-lanca.    
    end.    
    output close.
    
    output to ./ttcab.txt.
    for each tt-cab:
        export tt-cab.
    end.
    output close.
    output to ./ttlanca.txt.
    for each tt-lanca:
        export tt-lanca.
    end.
    output close.
     

    if opsys = "UNIX"
    then varquivo = "/admcom/sispro/vendas/"  + vnomarq +
                         string(day(vdti),"99") + 
                         "a" + 
                         string(day(vdtf),"99")  + 
                         string(month(vdtf),"99") + 
                         string(year(vdtf),"9999") + ".txt".
    else varquivo = "l:~\sispro~\vendas~\" + vnomarq +
                        string(day(vdti),"99") + 
                        "a" +  
                        string(day(vdtf),"99") + 
                        string(month(vdtf),"99") +
                        string(year(vdtf),"9999") + ".txt".                     
    

    update varquivo label "Arquivo" format "x(65)".
    
    output to value(varquivo).
    

    v-seq = 1000.

    for each tt-cab where tt-cab.totval > 0:
    
        find first tt-lanca where tt-lanca.data   = tt-cab.data
                    no-lock no-error.
        if not avail tt-lanca then next.            
                    


    /********************* HEADER ********************/
    cd_batch = "VENDAS" +
               string(day(today),"99") +  
               string(month(today),"99") +    
               string(year(today),"9999") +   
               string(time,"HH:MM").
    
    
    put unformatted 
    /* 01 */       "FISCAL         "
    /* 02 */       " " format "x(01)" 
    /* 03 */       "01001" format "x(20)"
    /* 04 */       " " format "x(01)" 
    /* 05 */       cd_batch   format "x(30)" 
    /* 06 */       " " format "x(01)" 
    /* 07 */       "VENDAS" format "x(15)" 
    /* 08 */       " " format "x(01)" 
    /* 09 */       tt-cab.codlot   format "x(10)" 
    /* 10 */       " " format "x(01)"  
    /* 11 */       "HEADER    " 
    /* 12 */       " " format "x(01)"  
    /* 13 */       tt-cab.qtdlot  format "999999"  
    /* 14 */       " " format "x(01)"  
    /* 15 */       string(day(tt-cab.data),"99") format "99"  
                   string(month(tt-cab.data),"99") format "99"  
                   string(year(tt-cab.data),"9999") format "9999" 
    /* 16 */       " " format "x(01)"  
    /* 17 */       (tt-cab.totval * 100) format "999999999999999999"  
    /* 18 */       " " format "x(01)"  
    /* 19 */       (tt-cab.totval * 100) format "999999999999999999"  
    /* 20 */       " " format "x(01)"  
    /* 21 */       string(day(tt-cab.data),"99") format "99"  
                   string(month(tt-cab.data),"99") format "99"  
                   string(year(tt-cab.data),"9999") format "9999" 
    /* 22 */       " " format "x(01)"  
    /* 23 */       " " format "x(721)"  
    /* 24 */       " " format "x(01)"  
    /* 25 */       "000000"   
    /* 26 */       " " format "x(01)" skip.

    

    
    for each tt-lanca where tt-lanca.data   = tt-cab.data:

/*************************** LANCAMENTOS *************************/
    
    
        v-seq = v-seq + 1.
        put unformatted
    /* 01 */       "FISCAL         "
                   " " format "x(01)"
                   "01001" format "x(20)"
                   " " format "x(01)" 
                   cd_batch   format "x(30)" 
                   " " format "x(01)"
                   "VENDAS" format "x(15)"  
                   " " format "x(01)" 
                   tt-cab.codlot   format "x(10)" 
     /* 10 */      " " format "x(01)"
                   "LANCTO    "  
                   " " format "x(01)"
                   string(day(tt-lanca.data),"99") format "99"  
                   string(month(tt-lanca.data),"99") format "99"  
                   string(year(tt-lanca.data),"9999") format "9999" 
                   " " format "x(01)" 
      /* 15 */     tt-lanca.deb format "x(30)" 
      /* 16 */             " " format "x(01)" 
      /* 17 */     tt-lanca.subdeb format "x(22)" 
      /* 18 */     " " format "x(01)" 
      /* 19 */     tt-lanca.cre format "x(30)"
      /* 20 */      " " format "x(01)" 
      /* 21 */      tt-lanca.subcre format "x(22)" 
                   " " format "x(01)" 
                   tt-lanca.etbdeb format "x(20)" 
                   " " format "x(01)"
                   tt-lanca.etbcre   format "x(20)" 
                   " " format "x(01)" 
                   " " format "x(06)" 
                   " " format "x(01)" 
                   " " format "x(15)"  
     /* 30 */      " " format "x(01)"  
                   " " format "x(06)"  
                   " " format "x(01)"  
                   " " format "x(15)"  
                   " " format "x(01)"  
                   " " format "x(06)" 
                   " " format "x(01)" 
                   " " format "x(15)"  
                   " " format "x(01)" 
                   " " format "x(06)"
     /* 40 */      " " format "x(01)" 
                   " " format "x(15)"  
                   " " format "x(01)" 
                   " " format "x(06)" 
                   " " format "x(01)" 
                   " " format "x(15)"  
                   " " format "x(01)" 
                   " " format "x(06)" 
                   " " format "x(01)" 
                   " " format "x(15)" 
     /* 50 */      " " format "x(01)" 
                   " " format "x(06)" 
                   " " format "x(01)" 
                   " " format "x(15)"  
                   " " format "x(01)" 
                   " " format "x(06)" 
                   " " format "x(01)" 
                   " " format "x(15)"  
                   " " format "x(01)" 
                   " " format "x(06)"
     /* 60 */      " " format "x(01)" 
                   " " format "x(15)"   
                   " " format "x(01)" 
                   " " format "x(06)" 
                   " " format "x(01)" 
                   " " format "x(15)"  
                   " " format "x(01)" 
                   " " format "x(06)" 
                   " " format "x(01)" 
                   " " format "x(15)" 
     /* 70 */      " " format "x(01)" 
                   " " format "x(06)" 
                   " " format "x(01)" 
                   " " format "x(15)"  
                   " " format "x(01)" 
                   (tt-lanca.val * 100) format "999999999999999999" 
                   " " format "x(01)" 
                   "0    " format "x(05)" 
                   " " format "x(01)" 
                   tt-lanca.his format "x(119)"
     /* 80 */      " " format "x(01)" 
                   " " format "x(15)" 
                   " " format "x(01)" 
                   " " format "x(120)" 
                   " " format "x(01)" 
                   " " format "x(05)" 
                   " " format "x(01)" 
                   " " format "x(01)"   
                   " " format "x(01)"   
                   "EXC" format "x(03)"  
     /* 90 */      " " format "x(01)"   
                   " " format "x(10)"    
                   " " format "x(01)"   
                   " " format "x(10)"   
                   " " format "x(34)"   
                   " " format "x(01)"   
                   v-seq format "999999"
     /* 97 */      " " format "x(01)"  skip.
        /*
        if tt-lanca.data = 04/19/11
        then
        */
        tot-tot = tot-tot + tt-lanca.val.
    end.
    
/******************** TRAILLER ******************************/
    
    
    put unformatted 
         /* 01 */       "FISCAL         "
         /* 02 */       " " format "x(01)"  
         /* 03 */       "01001" format "x(20)" 
         /* 04 */       " " format "x(01)"  
         /* 05 */       cd_batch   format "x(30)"  
         /* 06 */       " " format "x(01)"  
         /* 07 */       "VENDAS" format "x(15)"  
         /* 08 */       " " format "x(01)"  
         /* 09 */       tt-cab.codlot   format "x(10)"  
         /* 10 */       " " format "x(01)"   
         /* 11 */       "TRAILLER  "  
         /* 12 */       " " format "x(01)"  
         /* 13 */       " " format "x(785)"  
         /* 14 */       "000000" format "x(06)"  
         /* 15 */       " " format "x(01)" skip.

    end.    
    output close.

    unix silent value("chmod 777 " + varquivo).

    unix silent value("unix2dos " + varquivo).
    
    /**
    disp tt-total.acrescimo format ">>>,>>>,>>9.99" label "ACRESCIMO"
         tt-total.avista    format ">>>,>>>,>>9.99" label "VENDA VISTA"
         tt-total.banri     format ">>>,>>>,>>9.99" label "VENDA BANRI"
         tt-total.visa      format ">>>,>>>,>>9.99" label "VENDA VISA"
         tt-total.master    format ">>>,>>>,>>9.99" label "VENDA MASTER"
         tt-total.aprazo    format ">>>,>>>,>>9.99" label "VENDA PRAZO"
         /*fill("-",40) format "x(40)"
         tt-total.acrescimo + tt-total.avista + tt-total.banri +
         tt-total.visa + tt-total.master + tt-total.aprazo
                        format ">>>,>>>,>>9.99" label "TOTAL DA VENDA"
         fill("-",40) format "x(40)" */      
         tt-total.devolucaop format ">>>,>>>,>>9.99" label "DEVOLUCAO PRAZO"
         tt-total.devolucaov format ">>>,>>>,>>9.99" label "DEVOLUCAO VISTA"
         /*fill("-",40) format "x(40)"
         tt-total.devolucaop + tt-total.devolucaov
                        format ">>>,>>>,>>9.99" label "TOTAL DEVOLUCAO"
         fill("-",40) format "x(40)" */
         tt-total.recebimento format ">>>,>>>,>>9.99" label "RECEBIMENTOS"
         tt-total.juro   format ">>>,>>>,>>9.99" label "JUROS RECEBIDOS"
         /*fill("-",40) format "x(40)"
         tt-total.recebimento + tt-total.juro
                    format ">>>,>>>,>>9.99" label "TOTAL RECEBIMENTOS"
         fill("-",40) format "x(40)" */        
                  with frame f-totf centered row 10 1 column
                  side-label title " Totais exportado ".
    **/
    disp skip tot-tot label "Total gerado". pause.
      
    pause 0.
    leave.
end.




procedure separa-acrescimo:

    def var tt-novo as dec format ">>,>>>,>>9.99".
    def var v1 as dec.
    def var v2 as dec.
    
    disp "Aguarde..."
        with frame f-disp 1 down.
    do vdata = vdti to vdtf:
        for each estab no-lock:
        if etbcod = 0 or etbcod > 200 then next.
        for each ctcartcl where ctcartcl.etbcod = estab.etbcod and
                 ctcartcl.datref = vdata no-lock:

            tt-acrescimo = tt-acrescimo + ctcartcl.acrescimo.
        end.
        end.
    end.        
    hide frame f-disp no-pause.
    disp tt-acrescimo at 1 label "Total Acrescimo" format ">>,>>>,>>9.99"
        with frame f-acr.

    do on error undo, retry:
        update acr-252 at 1 label "D=15|C=252|Valor"   format ">>,>>>,>>9.99"
               acr-363 at 1 label "D=15|C=363|Valor"   format ">>,>>>,>>9.99"
               acr-364 at 1 label "D=15|C=364|Valor"   format ">>,>>>,>>9.99"
               acr-365 at 1 label "D=15|C=365|Valor"   format ">>,>>>,>>9.99"
               with frame f-acr side-label 1 down.
        if tt-acrescimo <> (acr-252 + acr-363 + acr-364 + acr-365)
        then do:
            message "Diferenca: " 
                    tt-acrescimo - (acr-252 + acr-363 + acr-364 + acr-365)
            . pause.
            undo.
        end.
    end.

end procedure.


procedure venda-vis-finan:

    vtotal-avista = 0.
    vtotal-finan = 0.
    for each ctcartcl where ctcartcl.etbcod > 0 and
                 ctcartcl.datref >= vdti and
                 ctcartcl.datref <= vdtf no-lock:
        vtotal-avista = vtotal-avista + ctcartcl.ecfvista.
    end.

    update vtotal-avista label "Total a vista"
        with frame f5 1 down side-label row 4.
                                       
    disp vtotal-finan label "Total Financeira" with frame f5.
    
    for each tt-finan: delete tt-finan. end.
    
    def var varquivo as char.
    
    if opsys = "UNIX"
    then  varquivo = "/admcom/sispro/vendas/valfinan." +
        string(day(vdtf),"99") + string(month(vdtf),"99") +
        string(year(vdtf),"9999").
    else varquivo = "l:~\sispro~\vendas~\~\valfinan." +
        string(day(vdtf),"99") + string(month(vdtf),"99") +
        string(year(vdtf),"9999").
 
    if search(varquivo) <> ?
    then do:
        input from value(varquivo).
        repeat:
            create tt-finan.
            import tt-finan.
        end.
        input close.
        for each tt-finan where data = ?:
            delete tt-finan.
        end.    
    end.
    else do:
    do vdd = vdti to vdtf:
        create tt-finan.
        tt-finan.data = vdd.
    end.
    end.

    for each tt-finan.
        if day(data) < 12
        then do with frame f1 column 1 down overlay:  
            disp tt-finan.data.
            update tt-finan.valor.
            vtotal-finan = vtotal-finan + tt-finan.valor.
            down with frame f1. 
        end.
        else if day(data) < 23
        then do with frame f2 column 25 down overlay:
            disp tt-finan.data.
            update tt-finan.valor.
            vtotal-finan = vtotal-finan + tt-finan.valor.
            down.
        end.
        else if day(data) < 32
        then do with frame f3 column 50 down overlay:
            disp tt-finan.data.
            update valor.
            vtotal-finan = vtotal-finan + tt-finan.valor.
            down.
        end.
        disp vtotal-finan with frame f5.
    end.
end procedure.
    
procedure calcula-valor:    
        
    def var vtotal-finan as dec format ">>,>>>,>>9.99" .
    def var vnovo-vista as dec format ">>,>>>,>>9.99".
    def var vnovo-finan as dec format ">>,>>>,>>9.99".    
    def var v1 as dec.
    def var v2 as dec.
    def var d1 as dec.
    def var d2 as dec.
    def var s1 as char format "x".
    def var s2 as char format "x".
    v1 = 0.
    v2 = 0.
    
    for each tt-ctcartcl.
        delete tt-ctcartcl.
    end.    


    for each ctcartcl where ctcartcl.etbcod > 0 and
                 ctcartcl.datref >= vdti and
                 ctcartcl.datref <= vdtf no-lock:
        v1 = v1 + ctcartcl.ecfvista.
        create tt-ctcartcl.
        buffer-copy ctcartcl to tt-ctcartcl.
        /*
        tt-ctcartcl.dif-ecf-contrato = 0.
        */
    end.
    
    if v1 > vtotal-avista
    then assign
             s1 = "-"
             d1 = v1 - vtotal-avista.
    else assign
             s1 = "+"
             d1 = vtotal-avista - v1.
                
    for each tt-ctcartcl where tt-ctcartcl.etbcod > 0 and
             tt-ctcartcl.datref >= vdti and
             tt-ctcartcl.datref <= vdtf  :

        if tt-ctcartcl.ecfvista = 0
        then next.
        
        if s1 = "-"
        then tt-ctcartcl.ecfvista = tt-ctcartcl.ecfvista -
                        (d1 * (tt-ctcartcl.ecfvista / v1)).
        else if s1 = "+"
        then tt-ctcartcl.ecfvista = tt-ctcartcl.ecfvista +
                        (d1 * (tt-ctcartcl.ecfvista / v1)).
 
        vnovo-vista = vnovo-vista + tt-ctcartcl.ecfvista.
    end.

    do vdd = vdti to vdtf:

        find first tt-finan where
                   tt-finan.data = vdd  
                   no-error.
        if not avail tt-finan 
        then next.
        v2 = 0. 
        d2 = 0. 
        if tt-finan.valor > 0
        then do:        
            for each tt-ctcartcl where tt-ctcartcl.etbcod > 0 and
                 tt-ctcartcl.datref = vdd no-lock:
                v2 = v2 + tt-ctcartcl.dif-ecf-contrato.
            end.
        end.
        else do:
            for each tt-ctcartcl where tt-ctcartcl.etbcod > 0 and
                 tt-ctcartcl.datref = vdd :
                tt-ctcartcl.dif-ecf-contrato = 0.
            end.
            next.
        end.
        if v2 = 0
        then do:
            find tt-ctcartcl where tt-ctcartcl.etbcod = 1 and
                 tt-ctcartcl.datref = vdd .

            tt-ctcartcl.dif-ecf-contrato = tt-finan.valor.

            vnovo-finan = vnovo-finan + tt-ctcartcl.dif-ecf-contrato .
        end.
        else do: 
        if v2 > tt-finan.valor
        then assign
                s2 = "-"
                d2 = v2 - tt-finan.valor.
        else assign
                s2 = "+"
                d2 = tt-finan.valor - v2.
        
        vtotal-finan = 0.
        for each tt-ctcartcl where tt-ctcartcl.etbcod > 0 and
                 tt-ctcartcl.datref = vdd :

            if tt-ctcartcl.dif-ecf-contrato = 0
            then next.
            
            if s2 = "-"
            then tt-ctcartcl.dif-ecf-contrato = tt-ctcartcl.dif-ecf-contrato -
                        (d2 * (tt-ctcartcl.dif-ecf-contrato / v2)).
            else if s2 = "+"
            then tt-ctcartcl.dif-ecf-contrato = tt-ctcartcl.dif-ecf-contrato +
                        (d2 * (tt-ctcartcl.dif-ecf-contrato / v2)).
              
            vnovo-finan = vnovo-finan + tt-ctcartcl.dif-ecf-contrato .
            vtotal-finan = vtotal-finan + tt-ctcartcl.dif-ecf-contrato .
            /*
            disp tt-ctcartcl.etbcod tt-ctcartcl.datref
                    tt-ctcartcl.dif-ecf-contrato vnovo-finan 
                    .
            pause. */  

        end.
        /*
        message tt-finan.valor vtotal-finan  tt-finan.valor - vtotal-finan.
        pause.
        */
        if tt-finan.valor > 0 and
           tt-finan.valor <> vtotal-finan
        then do:
            find first tt-ctcartcl where tt-ctcartcl.etbcod > 0 and
                 tt-ctcartcl.datref = vdd and
                 tt-ctcartcl.dif-ecf-contrato > 0
                 no-error.
            if avail tt-ctcartcl
            then do:     
                assign
                    tt-ctcartcl.dif-ecf-contrato =
                            tt-ctcartcl.dif-ecf-contrato +
                                (tt-finan.valor - vtotal-finan)
                    vnovo-finan = vnovo-finan + 
                                (tt-finan.valor - vtotal-finan)         
                                .
            end.            
        end.
        end.
    end.
    run exporta-valor-finan.
    def var varquivo as char.
    
    /*
    if opsys = "UNIX"
    then  varquivo = "/admcom/sispro/vendas/valfinan." +
        string(day(vdtf),"99") + string(month(vdtf),"99") +
        string(year(vdtf),"9999").
    else varquivo = "l:~\sispro~\vendas~\~\valfinan." +
        string(day(vdtf),"99") + string(month(vdtf),"99") +
        string(year(vdtf),"9999").
        
    output to value(varquivo).
    for each tt-finan:
        export tt-finan.
    end.
    output close.       
    **/
    
    message  vnovo-vista vnovo-finan. pause.
    
    if opsys = "UNIX"
    then varquivo = "/admcom/sispro/vendas/ctcartcl." +
        string(day(vdtf),"99") + string(month(vdtf),"99") +
        string(year(vdtf),"9999").
    else varquivo = "l:~\sispro~\vendas~\ctcartcl." +
        string(day(vdtf),"99") + string(month(vdtf),"99") +
        string(year(vdtf),"9999").
    output to value(varquivo).
    for each tt-ctcartcl:
        export tt-ctcartcl.
    end.
    output close.    
end procedure.         

procedure exporta-valor-finan:
    def var varquivo as char.
    
    if opsys = "UNIX"
    then  varquivo = "/admcom/sispro/vendas/valfinan." +
        string(day(vdtf),"99") + string(month(vdtf),"99") +
        string(year(vdtf),"9999").
    else varquivo = "l:~\sispro~\vendas~\~\valfinan." +
        string(day(vdtf),"99") + string(month(vdtf),"99") +
        string(year(vdtf),"9999").
        
    output to value(varquivo).
    for each tt-finan:
        export tt-finan.
    end.
    output close. 
end.    
procedure ec-financeira:

    def var te-financeira as dec.
    def var tcp-financeira as dec.
    def var tca-financeira as dec.
    def var p-acrescimo as dec.

    for each estab where estab.etbcod = 1 no-lock:
        assign
            te-financeira = 0
            tcp-financeira = 0
            tca-financeira = 0
            p-acrescimo = 0
            .

        for each financeiracc where
                 financeiracc.datest = vdata
                 no-lock:
            te-financeira = te-financeira + financeiracc.valest.
        end.
        /***             
        for each envfinan where
             envfinan.etbcod = estab.etbcod and
             envfinan.envsit = "EST" and
             envfinan.dt1 = vdata
             no-lock .
            find first titulo of envfinan no-lock no-error.
            if avail titulo
            then te-financeira = te-financeira + titulo.titvlcob.
        end.
        ****/
        
        for each tt-contrato: delete tt-contrato. end.
        
        for each financeiracc where
                 financeiracc.datcan = vdata
                 no-lock:
            tcp-financeira = tcp-financeira + financeiracc.valcan.
        end.
        /*
        for each envfinan where
             envfinan.etbcod = estab.etbcod and
             envfinan.envsit = "CAN" and
             envfinan.dt1 = vdata
             no-lock .
        
            find first tt-contrato where
                       tt-contrato.contnum = int(envfinan.titnum)
                       no-error.
            if not avail tt-contrato
            then do:
                create tt-contrato.
                tt-contrato.contnum = int(envfinan.titnum).
                tt-contrato.dtinicial = envfinan.dt1.
            end.           
        end.
        for each tt-contrato:

            p-acrescimo = 0.
            
            find first contrato where
                   contrato.contnum = tt-contrato.contnum
                   no-lock no-error.
            if avail contrato 
            then do:
                find contnf where contnf.etbcod = contrato.etbcod and
                              contnf.contnum = contrato.contnum
                              no-lock no-error.
                if avail contnf
                then do:
                    find first plani where 
                           plani.etbcod = contnf.etbcod and
                           plani.placod = contnf.placod and
                           plani.movtdc = 5
                           no-lock no-error.
                    if avail plani
                    then do:
                    
                        if plani.biss - (plani.platot - plani.vlserv) > 0
                        then do:
                            /*
                            if ((plani.biss - (plani.platot - plani.vlserv))
                           * ((titulo.titvlcob) / plani.biss)) <> ?
                            then p-acrescimo = 
                          ((plani.biss - (plani.platot - plani.vlserv))
                          * ((titulo.titvlcob) / plani.biss))
                            .
                            */
                            p-acrescimo = plani.biss - 
                                (plani.platot - plani.vlserv).
                        end.
                        /*
                        tcp-financeira = tcp-financeira + 
                            (titulo.titvlcob - p-acrescimo).
                        tca-financeira = tca-financeira + p-acrescimo.        
                        */
                        tcp-financeira = tcp-financeira + 
                            (plani.biss - p-acrescimo).
                        tca-financeira = tca-financeira + p-acrescimo.      
                    end.
                end.
            end.
        end.
        */
        
        vlote = "85".
                
        if te-financeira > 0 and
           te-financeira <> ?
        then do:   
            find first tt-cab where tt-cab.data = vdata no-error.
            if not avail tt-cab
            then do:
                create tt-cab.
                assign tt-cab.data   = vdata
                tt-cab.codlot = vlote + string(day(vdata),"99").
            end.
        
            create tt-lanca.
            assign tt-lanca.etbcod  = 01001
                       tt-lanca.etbdeb  = "01001"
                       tt-lanca.etbcre  = "01" + string(estab.etbcod,"999")
                       tt-lanca.data    = vdata
                       tt-lanca.deb     = "345"   
                       tt-lanca.subcre  = "" 
                       tt-lanca.subdeb  = "" 
                       tt-lanca.cre     = "15" 
                       tt-lanca.cod     = 0    
                       tt-lanca.his = "*LIVRE@ESTORNO CONTRATO N/DATA"
                       tt-cab.qtdlot = tt-cab.qtdlot + 1
                       tt-lanca.val  = te-financeira
                       tt-cab.totval = tt-cab.totval + te-financeira.
        end.
        if tcp-financeira > 0 and
           tcp-financeira <> ?
        then do:
            find first tt-cab where tt-cab.data = vdata no-error.
            if not avail tt-cab
            then do:
                create tt-cab.
                assign tt-cab.data   = vdata
                tt-cab.codlot = vlote + string(day(vdata),"99").
            end.
    
            create tt-lanca.
            assign tt-lanca.etbcod  = 01001
                       tt-lanca.etbdeb  = "01001"
                       tt-lanca.etbcre  = "01" + string(estab.etbcod,"999")
                       tt-lanca.data    = vdata
                       tt-lanca.deb     = "15"   
                       tt-lanca.subcre  = "" 
                       tt-lanca.subdeb  = "" 
                       tt-lanca.cre     = "361" 
                       tt-lanca.cod     = 0    
                       tt-lanca.his = "*LIVRE@CANCELAMENTO CONTRATO N/DATA"
                       tt-cab.qtdlot = tt-cab.qtdlot + 1
                       tt-lanca.val  = tcp-financeira
                       tt-cab.totval = tt-cab.totval + tcp-financeira.
 
        end.
        if tca-financeira > 0 and
           tca-financeira <> ?
        then do:    
            find first tt-cab where tt-cab.data = vdata no-error.
            if not avail tt-cab
            then do:
                create tt-cab.
                assign tt-cab.data   = vdata
                tt-cab.codlot = vlote + string(day(vdata),"99").
            end.
            create tt-lanca.
            assign tt-lanca.etbcod  = 01001
                       tt-lanca.etbdeb  = "01001"
                       tt-lanca.etbcre  = "01" + string(estab.etbcod,"999")
                       tt-lanca.data    = vdata
                       tt-lanca.deb     = "15"   
                       tt-lanca.subcre  = "" 
                       tt-lanca.subdeb  = "" 
                       tt-lanca.cre     = "363" 
                       tt-lanca.cod     = 0    
                       tt-lanca.his = "*LIVRE@CANCELAMENTO CONTRATO N/DATA"
                       tt-cab.qtdlot = tt-cab.qtdlot + 1
                       tt-lanca.val  = tca-financeira
                       tt-cab.totval = tt-cab.totval + tca-financeira.
        end. 
    end.   
end procedure.

procedure recebimento-financeira:

    vtotal-recebimento = 0.
    vtotal-finan = 0.
    for each ctcartcl where ctcartcl.etbcod > 0 and
                 ctcartcl.datref >= vdti and
                 ctcartcl.datref <= vdtf no-lock:
        vtotal-recebimento = vtotal-recebimento + ctcartcl.recebimento.
    end.

    disp /*update*/ vtotal-recebimento label "Total Recebimento"
        format ">>>,>>>,>>9.99"
        with frame f55 1 down side-label row 4.
                                       
    disp vtotal-finan label "Total Financeira" with frame f55.
    
    for each tt-recfinan: delete tt-recfinan. end.
    
    def var varquivo as char.
    
    if opsys = "UNIX"
    then  varquivo = "/admcom/sispro/vendas/valrecfinan." +
        string(day(vdtf),"99") + string(month(vdtf),"99") +
        string(year(vdtf),"9999").
    else varquivo = "l:~\sispro~\vendas~\~\valrecfinan." +
        string(day(vdtf),"99") + string(month(vdtf),"99") +
        string(year(vdtf),"9999").
 
    if search(varquivo) <> ?
    then do:
        input from value(varquivo).
        repeat:
            create tt-recfinan.
            import tt-recfinan.
        end.
        input close.
        /*
        for each tt-recfinan where recdata = ?:
            delete tt-recfinan.
        end. 
        */   
    end.
    else do:
    do vdd = vdti to vdtf:
        create tt-recfinan.
        tt-recfinan.recdata = vdd.
    end.
    end.

    for each tt-recfinan.
        if day(recdata) < 12
        then do with frame f11 column 1 down overlay:  
            disp tt-recfinan.recdata.
            update tt-recfinan.recvalor.
            vtotal-finan = vtotal-finan + tt-recfinan.recvalor.
            down with frame f11. 
        end.
        else if day(recdata) < 23
        then do with frame f22 column 25 down overlay:
            disp tt-recfinan.recdata.
            update tt-recfinan.recvalor.
            vtotal-finan = vtotal-finan + tt-recfinan.recvalor.
            down.
        end.
        else if day(recdata) < 32
        then do with frame f33 column 50 down overlay:
            disp tt-recfinan.recdata.
            update recvalor.      
            vtotal-finan = vtotal-finan + tt-recfinan.recvalor.
            down.
        end.
        disp vtotal-finan with frame f55.
    end.
    /*
    repeat with frame f100 column 1 down overlay title " Rec. Financeira ":  
            create tt-recfinan.
            update tt-recfinan.data format "99/99/9999"
                   tt-recfinan.valor format ">>>,>>>,>>9.99"
                   .
            down with frame f100.
            vtotal-finan = vtotal-finan + tt-recfinan.valor.       
        
            disp vtotal-finan with frame f5.
    end.
    */
end procedure.
procedure exporta-recebimento-finan:
    def var varquivo as char.
    
    if opsys = "UNIX"
    then  varquivo = "/admcom/sispro/vendas/valrecfinan." +
        string(day(vdtf),"99") + string(month(vdtf),"99") +
        string(year(vdtf),"9999").
    else varquivo = "l:~\sispro~\vendas~\~\valrecfinan." +
        string(day(vdtf),"99") + string(month(vdtf),"99") +
        string(year(vdtf),"9999").
        
    output to value(varquivo).
    for each tt-recfinan:
        export tt-recfinan.
    end.
    output close. 
end.   

procedure ctb-novacoes:

    def var new-novacao as dec.
    def var rec-novacao as dec.
    def var rcf-novacao as dec.

    assign
        new-novacao = 0
        rec-novacao = 0
        rcf-novacao = 0.
        
    for each bestab no-lock:
        display stream stela "Processando... " vdata  label "Data"
                        estab.etbcod 
                      with frame fff side-label 1 down. pause 0.
         for each ctbreceb where
             ctbreceb.etbcod = bestab.etbcod and 
             ctbreceb.datref = vdata and
             (ctbreceb.moecod = "NOV" or
              ctbreceb.moecod = "RNG") no-lock:
            if ctbreceb.moecod = "NOV"
            then rec-novacao = rec-novacao + valor1.
            else if ctbreceb.moecod = "RNG"
            then new-novacao = new-novacao + valor1.
        end.
    end.
    do:
        rcf-novacao = new-novacao - rec-novacao.
         
        find estab where estab.etbcod = 1 no-lock.
            
        vlote = "71".
                
        if rec-novacao > 0 and
           rec-novacao <> ?
        then do:   
            find first tt-cab where tt-cab.data = vdata no-error.
            if not avail tt-cab
            then do:
                create tt-cab.
                assign tt-cab.data   = vdata
                tt-cab.codlot = vlote + string(day(vdata),"99").
            end.
        
            create tt-lanca.
            assign tt-lanca.etbcod  = 01001
                       tt-lanca.etbdeb  = "01001"
                       tt-lanca.etbcre  = "01" + string(estab.etbcod,"999")
                       tt-lanca.data    = vdata
                       tt-lanca.deb     = "15"   
                       tt-lanca.subcre  = "" 
                       tt-lanca.subdeb  = "" 
                       tt-lanca.cre     = "15" 
                       tt-lanca.cod     = 0    
                       tt-lanca.his = "*LIVRE@VALOR REF NOVACAO DE CONTRATO"
                       tt-cab.qtdlot = tt-cab.qtdlot + 1
                       tt-lanca.val  = rec-novacao
                       tt-cab.totval = tt-cab.totval + rec-novacao.
        end.
        if new-novacao > 0 and
           new-novacao <> ?
        then do:
            find first tt-cab where tt-cab.data = vdata no-error.
            if not avail tt-cab
            then do:
                create tt-cab.
                assign tt-cab.data   = vdata
                tt-cab.codlot = vlote + string(day(vdata),"99").
            end.
    
            create tt-lanca.
            assign tt-lanca.etbcod  = 01001
                       tt-lanca.etbdeb  = "01001"
                       tt-lanca.etbcre  = "01" + string(estab.etbcod,"999")
                       tt-lanca.data    = vdata
                       tt-lanca.deb     = "15"   
                       tt-lanca.subcre  = "" 
                       tt-lanca.subdeb  = "" 
                       tt-lanca.cre     = "15" 
                       tt-lanca.cod     = 0    
                       tt-lanca.his = "*LIVRE@VALOR REF NOVACAO DE CONTRATO"
                       tt-cab.qtdlot = tt-cab.qtdlot + 1
                       tt-lanca.val  = new-novacao
                       tt-cab.totval = tt-cab.totval + new-novacao.
 
        end.
        if rcf-novacao > 0 and
           rcf-novacao <> ?
        then do:    
            find first tt-cab where tt-cab.data = vdata no-error.
            if not avail tt-cab
            then do:
                create tt-cab.
                assign tt-cab.data   = vdata
                tt-cab.codlot = vlote + string(day(vdata),"99").
            end.
            create tt-lanca.
            assign tt-lanca.etbcod  = 01001
                       tt-lanca.etbdeb  = "01001"
                       tt-lanca.etbcre  = "01" + string(estab.etbcod,"999")
                       tt-lanca.data    = vdata
                       tt-lanca.deb     = "15"   
                       tt-lanca.subcre  = "" 
                       tt-lanca.subdeb  = "" 
                       tt-lanca.cre     = "252" 
                       tt-lanca.cod     = 0    
                       tt-lanca.his = "*LIVRE@VALOR REF NOVACAO DE CONTRATO"
                       tt-cab.qtdlot = tt-cab.qtdlot + 1
                       tt-lanca.val  = rcf-novacao
                       tt-cab.totval = tt-cab.totval + rcf-novacao.
        end. 
    end.   
end procedure.

