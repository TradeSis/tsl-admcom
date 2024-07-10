def shared var vdti as date.
def shared var vdtf as date.
/*
update vdti vdtf.
*/
def var vesc as char format "x(20)" extent 9
        init["venda_vista",
             "venda_prazo",
             "venda_devolucao",
             "cotrato_novacao",
             "contrato_outros",
             "contrato_acrescimo",
             "contrato_seguro",
             "E/C Financeira",
             "contrato_recebimento"].
                                     
def var vdata as date. 
def stream tela.

def temp-table tt-clilanca like clilanca.
def buffer btt-clilanca for tt-clilanca.

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
    field seq  as int
    field tiplan as char
    field tipval as char. 

def temp-table tt-vendavista
    field etbcod like estab.etbcod
    field datref as date
    field valvenda as dec
    field valservi as dec
    field valoutra as dec
    field valtotal as dec
    index i1 etbcod datref
    .
def temp-table tt-vendaprazo
    field etbcod like estab.etbcod
    field datref as date
    field valvenda as dec
    field valservi as dec
    field valoutra as dec
    field valtotal as dec
    index i1 etbcod datref
    .
def temp-table tt-vendadevol
    field etbcod like estab.etbcod
    field datref as date
    field valvista as dec
    field valprazo as dec
    field valquitado as dec
    field valdevolvido as dec
    field valtotal as dec
    index i1 etbcod datref
    .
    
def temp-table tt-novalebes
    field etbcod like estab.etbcod
    field datref as date
    field vlcontrato as dec
    field vlentrada as dec
    field vlseguro as dec
    field principal as dec
    field acrescimo as dec
    field orilebes as dec
    field orifinan as dec
    index i1 etbcod datref
    . 
    
def temp-table tt-novafinan
    field etbcod like estab.etbcod
    field datref as date
    field vlcontrato as dec
    field vlentrada as dec
    field vlseguro as dec
    field principal as dec
    field acrescimo as dec
    field orilebes as dec
    field orifinan as dec
    index i1 etbcod datref
    .

def temp-table tt-contnormal
    field etbcod like estab.etbcod
    field datref as date
    field vlcontrato as dec
    field vlentrada as dec
    field vlseguro as dec
    field principal as dec
    field acrescimo as dec
    field orilebes as dec
    field orifinan as dec
    index i1 etbcod datref
    . 

def temp-table tt-contoutros 
    field etbcod like estab.etbcod
    field datref as date
    field vlcontrato as dec
    field vlentrada as dec
    field vlseguro as dec
    field principal as dec
    field acrescimo as dec
    field orilebes as dec
    field orifinan as dec
    index i1 etbcod datref
    . 

def temp-table tt-ecfinanceira 
    field etbcod like estab.etbcod
    field datref as date
    field vlcontrato as dec
    field vlentrada as dec
    field vlseguro as dec
    field principal as dec
    field acrescimo as dec
    field orilebes as dec
    field orifinan as dec
    index i1 etbcod datref
    .           

def temp-table tt-recebe
    field tipo as char
    field etbcod like estab.etbcod
    field datref as date
    field moeda as char
    field vlparcela as dec
    field vlpago as dec
    field vlprincipal as dec
    field vlacrescimo as dec
    field vlseguro as dec
    field vljuro as dec
    index i1 etbcod datref tipo moeda
    .
    
         
def var vindex as int.
def var vlote as char.

form vesc with frame f-esc 1 down no-label 
        row 4.

repeat with 1 down side-label width 80 row 7 color blue/white:

    for each tt-lanca: delete tt-lanca. end.
    for each tt-cab: delete tt-cab. end. 
    for each tt-lanca: delete tt-lanca. end.
    disp vesc with frame f-esc 1 down side-label no-label row 7
        1 column overlay column 40
        .
    choose field vesc with frame f-esc.
    vindex = frame-index.
    if vindex > 9 then next.
    
    /*hide frame f-esc.
      */
    
    /*if vindex = 11
    then do:
        message "Informe o numero do lote "
        update vlote.
        if vlote = ""
        then return.
    end.
    if vindex = 12
    then vlote = "63".
    */
    
    message "AGUARDE PROCESSAMENTO...".
 
    for each tt-vendavista: delete tt-vendavista. end.
    for each tt-vendaprazo: delete tt-vendaprazo. end.
    for each tt-vendadevol: delete tt-vendadevol. end.
    for each tt-novalebes: delete tt-novalebes. end.
    for each tt-novafinan: delete tt-novafinan. end.
    for each tt-ecfinanceira: delete tt-ecfinanceira. end.
    for each tt-contoutros:   delete tt-contoutros.   end.
    for each tt-contnormal:   delete tt-contnormal.   end.
    for each tt-recebe:  delete tt-recebe.  end.
    
    if vindex = 1 
    then do:
        run venda-vista.
        vlote = "60".
             
        for each tt-vendavista where
                 tt-vendavista.etbcod > 0 and
                 tt-vendavista.valtotal > 0:
                 
            find first tt-cab where 
                       tt-cab.data = tt-vendavista.datref no-error.
            
            if not avail tt-cab
            then do:
                create tt-cab.
                assign tt-cab.data   = tt-vendavista.datref
                           tt-cab.codlot = vlote + 
                           string(day(tt-vendavista.datref),"99").

            end.

            find first tt-lanca 
                           where tt-lanca.etbcre = "01" + 
                                      string(tt-vendavista.etbcod,"999") and
                                 tt-lanca.data   = tt-vendavista.datref and
                                 tt-lanca.cre    = "161" and
                                 tt-lanca.deb    = "1" no-error.
                   
            if not avail tt-lanca
            then do:
                create tt-lanca.
                assign tt-lanca.etbcod  = 01001
                           tt-lanca.etbdeb  = "01001"
                           tt-lanca.etbcre  = "01" + 
                                            string(tt-vendavista.etbcod,"999")
                           tt-lanca.data    = tt-vendavista.datref
                           tt-lanca.deb     = "1"  
                           tt-lanca.subcre  = ""
                           tt-lanca.subdeb  = ""
                           tt-lanca.cre     = "161"
                           tt-lanca.cod     = 0   
                           tt-lanca.his = "*LIVRE@VENDAS A VISTA N/DATA"
                           tt-cab.qtdlot = tt-cab.qtdlot + 1
                           tt-lanca.tipval = vesc[vindex]
                           .
            end.
            assign tt-lanca.val  = tt-lanca.val + tt-vendavista.valtotal
                   tt-cab.totval = tt-cab.totval + tt-vendavista.valtotal.
        end.
    end.
    else if vindex = 2 
    then do:
        run venda-prazo.
        vlote = "80".
             
        for each tt-vendaprazo where
                 tt-vendaprazo.etbcod > 0 and
                 tt-vendaprazo.valtotal > 0:
                 
            find first tt-cab where 
                       tt-cab.data = tt-vendaprazo.datref no-error.
            
            if not avail tt-cab
            then do:
                create tt-cab.
                assign tt-cab.data   = tt-vendaprazo.datref
                           tt-cab.codlot = vlote + 
                           string(day(tt-vendaprazo.datref),"99").

            end.

            find first tt-lanca 
                           where tt-lanca.etbcre = "01" + 
                                      string(tt-vendaprazo.etbcod,"999") and
                                 tt-lanca.data   = tt-vendaprazo.datref and
                                 tt-lanca.cre    = "162" and
                                 tt-lanca.deb    = "15" no-error.
                   
            if not avail tt-lanca
            then do:
                create tt-lanca.
                assign tt-lanca.etbcod  = 01001
                       tt-lanca.etbdeb  = "01001"
                       tt-lanca.etbcre  = "01" + 
                                string(tt-vendaprazo.etbcod,"999")
                       tt-lanca.data    = tt-vendaprazo.datref
                       tt-lanca.deb     = "15"   
                       tt-lanca.subcre  = "" 
                       tt-lanca.subdeb  = "" 
                       tt-lanca.cre     = "162" 
                       tt-lanca.cod     = 0    
                       tt-lanca.his = "*LIVRE@VENDAS A PRAZO CF REG SAIDAS" 
                       tt-cab.qtdlot = tt-cab.qtdlot + 1
                       tt-lanca.tipval = vesc[vindex]
                       .
 
            end.
            assign tt-lanca.val  = tt-lanca.val + tt-vendaprazo.valtotal
                   tt-cab.totval = tt-cab.totval + tt-vendaprazo.valtotal.
        end.
    end.
    else if vindex = 3 
    then do:
        run venda-devolucao.
        vlote = "75".
             
        for each tt-vendadevol where
                 tt-vendadevol.etbcod > 0:
                 

            find first tt-cab where 
                       tt-cab.data = tt-vendadevol.datref no-error.
            
            if not avail tt-cab
            then do:
                create tt-cab.
                assign tt-cab.data   = tt-vendadevol.datref
                           tt-cab.codlot = vlote + 
                           string(day(tt-vendadevol.datref),"99").

            end.

            find first tt-lanca 
                           where tt-lanca.etbcre = "01" + 
                                      string(tt-vendadevol.etbcod,"999") and
                                 tt-lanca.data   = tt-vendadevol.datref and
                                 tt-lanca.cre    = "15" and
                                 tt-lanca.deb    = "163" no-error.
                   
            if not avail tt-lanca and tt-vendadevol.valprazo > 0
            then do:
                create tt-lanca.
                assign tt-lanca.etbcod  = 01001
                       tt-lanca.etbdeb  = "01001"
                       tt-lanca.etbcre  = "01" + 
                                    string(tt-vendadevol.etbcod,"999")
                       tt-lanca.data    = tt-vendadevol.datref
                       tt-lanca.deb     = "163"   
                       tt-lanca.subcre  = "" 
                       tt-lanca.subdeb  = "" 
                       tt-lanca.cre     = "15" 
                       tt-lanca.cod     = 0    
                       tt-lanca.his = "*LIVRE@DEV.N/DATA CF REG.ENTRADAS" 
                       tt-cab.qtdlot = tt-cab.qtdlot + 1
                       tt-lanca.val  = tt-vendadevol.valprazo
                       tt-cab.totval = tt-cab.totval + tt-vendadevol.valprazo
                       tt-lanca.tipval = vesc[vindex]
                       .
            end.
            else if avail tt-lanca and tt-vendadevol.valprazo > 0
            then assign
                tt-lanca.val = tt-lanca.val + tt-vendadevol.valprazo
                tt-cab.totval = tt-cab.totval + tt-vendadevol.valprazo
                .

            find first tt-lanca 
                           where tt-lanca.etbcre = "01" + 
                                      string(tt-vendadevol.etbcod,"999") and
                                 tt-lanca.data   = tt-vendadevol.datref and
                                 tt-lanca.cre    = "1" and
                                 tt-lanca.deb    = "293" no-error.

            if not avail tt-lanca and tt-vendadevol.valvista > 0
            then do:
                create tt-lanca.
                assign tt-lanca.etbcod  = 01001
                       tt-lanca.etbdeb  = "01001"
                       tt-lanca.etbcre  = "01" + 
                                    string(tt-vendadevol.etbcod,"999")
                       tt-lanca.data    = tt-vendadevol.datref
                       tt-lanca.deb     = "293"   
                       tt-lanca.subcre  = "" 
                       tt-lanca.subdeb  = "" 
                       tt-lanca.cre     = "1" 
                       tt-lanca.cod     = 0    
                       tt-lanca.his = "*LIVRE@DEV.N/DATA CF REG.ENTRADAS" 
                       tt-cab.qtdlot = tt-cab.qtdlot + 1
                       tt-lanca.val  = tt-vendadevol.valvista
                       tt-cab.totval = tt-cab.totval + tt-vendadevol.valvista
                       tt-lanca.tipval = vesc[vindex]
                       .
            end.
            else if avail tt-lanca and tt-vendadevol.valvista > 0
            then assign
                tt-lanca.val = tt-lanca.val + tt-vendadevol.valvista
                tt-cab.totval = tt-cab.totval + tt-vendadevol.valvista
                .


            find first tt-lanca 
                           where tt-lanca.etbcre = "01" + 
                                      string(tt-vendadevol.etbcod,"999") and
                                 tt-lanca.data   = tt-vendadevol.datref and
                                 tt-lanca.cre    = "15" and
                                 tt-lanca.deb    = "1" no-error.


            if not avail tt-lanca and tt-vendadevol.valdevolvido > 0
            then do:
                create tt-lanca.
                assign tt-lanca.etbcod  = 01001
                       tt-lanca.etbdeb  = "01001"
                       tt-lanca.etbcre  = "01" + 
                                    string(tt-vendadevol.etbcod,"999")
                       tt-lanca.data    = tt-vendadevol.datref
                       tt-lanca.deb     = "1"   
                       tt-lanca.subcre  = "" 
                       tt-lanca.subdeb  = "" 
                       tt-lanca.cre     = "15" 
                       tt-lanca.cod     = 0    
                       tt-lanca.his = "*LIVRE@DEV.N/DATA CF REG.ENTRADAS" 
                       tt-cab.qtdlot = tt-cab.qtdlot + 1
                       tt-lanca.val  = tt-vendadevol.valdevolvido
                       tt-cab.totval = tt-cab.totval +                                         tt-vendadevol.valdevolvido
                       tt-lanca.tipval = vesc[vindex]
                       .
            end.
            else if avail tt-lanca and tt-vendadevol.valdevolvido > 0
            then assign
                tt-lanca.val = tt-lanca.val + tt-vendadevol.valdevolvido
                tt-cab.totval = tt-cab.totval + tt-vendadevol.valdevolvido
                .

        end.
    end.
    else if vindex = 4
    then do:
        run contrato-novacao.
        vlote = "71".
             
        def var new-lebes as dec init 0.
                
        for each tt-novalebes where
                 tt-novalebes.etbcod > 0:
        
            new-lebes = tt-novalebes.orilebes +
                        tt-novalebes.orifinan +
                        tt-novalebes.acrescimo.

            if new-lebes = 0
            then next.
                        
            find first tt-cab where 
                       tt-cab.data = tt-novalebes.datref no-error.
            
            if not avail tt-cab
            then do:
                create tt-cab.
                assign tt-cab.data   = tt-novalebes.datref
                           tt-cab.codlot = vlote + 
                           string(day(tt-novalebes.datref),"99").

            end.
            /**********
            if tt-novalebes.vlcontrato > 0
            then do:
                find first tt-lanca 
                           where tt-lanca.etbcre = "01" + 
                                      string(tt-novalebes.etbcod,"999") and
                                 tt-lanca.data   = tt-novalebes.datref and
                                 tt-lanca.cre    = "" and
                                 tt-lanca.deb    = "15" no-error.
                   
                if not avail tt-lanca
                then do:
                    create tt-lanca.
                    assign tt-lanca.etbcod  = 01001
                       tt-lanca.etbdeb  = "01001"
                       tt-lanca.etbcre  = "01" +                                     string(tt-novalebes.etbcod,"999")
                       tt-lanca.data    = tt-novalebes.datref
                       tt-lanca.deb     = "15"   
                       tt-lanca.subcre  = "" 
                       tt-lanca.subdeb  = "" 
                       tt-lanca.cre     = "" 
                       tt-lanca.cod     = 0    
                       tt-lanca.his = "*LIVRE@VALOR REF NOVACAO DE CONTRATO"
                       tt-cab.qtdlot = tt-cab.qtdlot + 1
                       tt-lanca.val  = tt-novalebes.vlcontrato
                       /*tt-cab.totval = tt-cab.totval +                                             tt-novalebes.vlcontrato
                       */
                       tt-lanca.tiplan = "DIV"
                       tt-lanca.tipval = vesc[vindex]
                       .
                end.
                else assign
                    tt-lanca.val = tt-lanca.val + tt-novalebes.vlcontrato
                    /*tt-cab.totval = tt-cab.totval + tt-novalebes.vlcontrato
                    */
                    .
            end.
            *************/

            if tt-novalebes.orifinan > 0
            then do:
                find first tt-lanca 
                           where tt-lanca.etbcre = "01" + 
                                      string(tt-novalebes.etbcod,"999") and
                                 tt-lanca.data   = tt-novalebes.datref and
                                 tt-lanca.cre    = "1" and
                                 tt-lanca.deb    = "361" no-error.
                if not avail tt-lanca
                then do:
                    create tt-lanca.
                    assign tt-lanca.etbcod  = 01001
                    tt-lanca.etbdeb  = "01001"
                    tt-lanca.etbcre  = "01" + string(tt-novalebes.etbcod,"999")
                    tt-lanca.data    = tt-novalebes.datref
                    tt-lanca.deb     = "361"   
                    tt-lanca.subcre  = "" 
                    tt-lanca.subdeb  = "" 
                    tt-lanca.cre     = "1" 
                    tt-lanca.cod     = 0    
                    tt-lanca.his = "*LIVRE@VALOR REF NOVACAO DE CONTRATO"
                    tt-cab.qtdlot = tt-cab.qtdlot + 1
                    tt-lanca.val  = tt-novalebes.orifinan
                    tt-cab.totval = tt-cab.totval + tt-novalebes.orifinan
                    tt-lanca.tiplan = "EXC" 
                    tt-lanca.tipval = vesc[vindex]
                    .
                end.
                else assign
                    tt-lanca.val  = tt-lanca.val + tt-novalebes.orifinan
                    tt-cab.totval = tt-cab.totval + tt-novalebes.orifinan
                    .
 
            end.

            if tt-novalebes.orilebes > 0
            then do:
                find first tt-lanca 
                           where tt-lanca.etbcre = "01" + 
                                      string(tt-novalebes.etbcod,"999") and
                                 tt-lanca.data   = tt-novalebes.datref and
                                 tt-lanca.cre    = "15" and
                                 tt-lanca.deb    = "" no-error.
                if not avail tt-lanca
                then do:
                    create tt-lanca.
                    assign tt-lanca.etbcod  = 01001
                    tt-lanca.etbdeb  = "01001"
                    tt-lanca.etbcre  = "01" + string(tt-novalebes.etbcod,"999")
                    tt-lanca.data    = tt-novalebes.datref
                    tt-lanca.deb     = ""   
                    tt-lanca.subcre  = "" 
                    tt-lanca.subdeb  = "" 
                    tt-lanca.cre     = "15" 
                    tt-lanca.cod     = 0    
                    tt-lanca.his = "*LIVRE@VALOR REF NOVACAO DE CONTRATO"
                    tt-cab.qtdlot = tt-cab.qtdlot + 1
                    tt-lanca.val  = tt-novalebes.orilebes
                    tt-cab.totval = tt-cab.totval + tt-novalebes.orilebes
                    tt-lanca.tiplan = "DIV" 
                    tt-lanca.tipval = vesc[vindex]
                    .
                end.
                else assign
                        tt-lanca.val  = tt-lanca.val + tt-novalebes.orilebes
                        tt-cab.totval = tt-cab.totval + tt-novalebes.orilebes
                        .
            end.
            if tt-novalebes.orifinan > 0
            then do:
                find first tt-lanca 
                           where tt-lanca.etbcre = "01" + 
                                      string(tt-novalebes.etbcod,"999") and
                                 tt-lanca.data   = tt-novalebes.datref and
                                 tt-lanca.cre    = "361" and
                                 tt-lanca.deb    = "" no-error.
                if not avail tt-lanca
                then do:
                    create tt-lanca.
                    assign tt-lanca.etbcod  = 01001
                    tt-lanca.etbdeb  = "01001"
                    tt-lanca.etbcre  = "01" + string(tt-novalebes.etbcod,"999")
                    tt-lanca.data    = tt-novalebes.datref
                    tt-lanca.deb     = ""   
                    tt-lanca.subcre  = "" 
                    tt-lanca.subdeb  = "" 
                    tt-lanca.cre     = "361" 
                    tt-lanca.cod     = 0    
                    tt-lanca.his = "*LIVRE@VALOR REF NOVACAO DE CONTRATO"
                    tt-cab.qtdlot = tt-cab.qtdlot + 1
                    tt-lanca.val  = tt-novalebes.orifinan
                    tt-cab.totval = tt-cab.totval + tt-novalebes.orifinan
                    tt-lanca.tiplan = "DIV" 
                    tt-lanca.tipval = vesc[vindex]
                    .
                end.
                else assign
                    tt-lanca.val  = tt-lanca.val + tt-novalebes.orifinan
                    tt-cab.totval = tt-cab.totval + tt-novalebes.orifinan
                    .
 
            end.
            if tt-novalebes.acrescimo > 0
            then do:
                find first tt-lanca 
                           where tt-lanca.etbcre = "01" + 
                                      string(tt-novalebes.etbcod,"999") and
                                 tt-lanca.data   = tt-novalebes.datref and
                                 tt-lanca.cre    = "669" and
                                 tt-lanca.deb    = "" no-error.
                if not avail tt-lanca
                then do:
                    create tt-lanca.
                    assign tt-lanca.etbcod  = 01001
                    tt-lanca.etbdeb  = "01001"
                    tt-lanca.etbcre  = "01" + string(tt-novalebes.etbcod,"999")
                    tt-lanca.data    = tt-novalebes.datref
                    tt-lanca.deb     = ""   
                    tt-lanca.subcre  = "" 
                    tt-lanca.subdeb  = "" 
                    tt-lanca.cre     = "669" 
                    tt-lanca.cod     = 0   
                    tt-lanca.his = "*LIVRE@VALOR REF NOVACAO DE CONTRATO"
                    tt-cab.qtdlot = tt-cab.qtdlot + 1
                    tt-lanca.val  = tt-novalebes.acrescimo
                    tt-cab.totval = tt-cab.totval + tt-novalebes.acrescimo
                    tt-lanca.tiplan = "DIV" 
                    tt-lanca.tipval = vesc[vindex]
                    .
                end.
                else assign
                    tt-lanca.val  = tt-lanca.val + tt-novalebes.acrescimo
                    tt-cab.totval = tt-cab.totval + tt-novalebes.acrescimo
                    .        
            end.
            if new-lebes > 0
            then do:
                find first tt-lanca 
                           where tt-lanca.etbcre = "01" + 
                                      string(tt-novalebes.etbcod,"999") and
                                 tt-lanca.data   = tt-novalebes.datref and
                                 tt-lanca.cre    = "" and
                                 tt-lanca.deb    = "15" no-error.
                if not avail tt-lanca
                then do:
                    create tt-lanca.
                    assign tt-lanca.etbcod  = 01001
                    tt-lanca.etbdeb  = "01001"
                    tt-lanca.etbcre  = "01" + string(tt-novalebes.etbcod,"999")
                    tt-lanca.data    = tt-novalebes.datref
                    tt-lanca.deb     = "15"   
                    tt-lanca.subcre  = "" 
                    tt-lanca.subdeb  = "" 
                    tt-lanca.cre     = "" 
                    tt-lanca.cod     = 0   
                    tt-lanca.his = "*LIVRE@VALOR REF NOVACAO DE CONTRATO"
                    tt-cab.qtdlot = tt-cab.qtdlot + 1
                    tt-lanca.val  = new-lebes
                    tt-lanca.tiplan = "DIV" 
                    tt-lanca.tipval = vesc[vindex]
                    .
                end.
                else assign
                    tt-lanca.val  = tt-lanca.val + new-lebes
                    . 
            end.
            /***********
            if tt-novalebes.vlseguro > 0
            then do:
                find first tt-lanca 
                           where tt-lanca.etbcre = "01" + 
                                      string(tt-novalebes.etbcod,"999") and
                                 tt-lanca.data   = tt-novalebes.datref and
                                 tt-lanca.cre    = "564" and
                                 tt-lanca.deb    = "15" no-error.
                if not avail tt-lanca
                then do:
                    create tt-lanca.
                    assign tt-lanca.etbcod  = 01001
                       tt-lanca.etbdeb  = "01001"
                       tt-lanca.etbcre  = "01" +                                     string(tt-novalebes.etbcod,"999")
                       tt-lanca.data    = tt-novalebes.datref
                       tt-lanca.deb     = "15"   
                       tt-lanca.subcre  = "" 
                       tt-lanca.subdeb  = "" 
                       tt-lanca.cre     = "564" 
                       tt-lanca.cod     = 0    
                       tt-lanca.his = "*LIVRE@VALOR REF SEGURO"
                       tt-cab.qtdlot = tt-cab.qtdlot + 1 
                       tt-lanca.val  = tt-novalebes.vlseguro 
                       tt-cab.totval = tt-cab.totval + tt-novalebes.vlseguro
                       tt-lanca.tiplan = "EXC"
                       tt-lanca.tipval = vesc[vindex]
                       .
                end.
                else assign
                        tt-lanca.val  = tt-lanca.val + tt-novalebes.vlseguro
                        tt-cab.totval = tt-cab.totval + tt-novalebes.vlseguro
                        .
            end.
            **********/
        end.
        
        /*************
        for each tt-novafinan where
                 tt-novafinan.etbcod > 0:
        
            find first tt-cab where 
                       tt-cab.data = tt-novafinan.datref no-error.
            
            if not avail tt-cab
            then do:
                create tt-cab.
                assign tt-cab.data   = tt-novafinan.datref
                           tt-cab.codlot = vlote + 
                           string(day(tt-novafinan.datref),"99").

            end.

            if tt-novafinan.vlcontrato > 0
            then do:
                find first tt-lanca 
                           where tt-lanca.etbcre = "01" + 
                                      string(tt-novafinan.etbcod,"999") and
                                 tt-lanca.data   = tt-novafinan.datref and
                                 tt-lanca.cre    = "" and
                                 tt-lanca.deb    = "15" no-error.
                   
                if not avail tt-lanca
                then do:
                    create tt-lanca.
                    assign tt-lanca.etbcod  = 01001
                       tt-lanca.etbdeb  = "01001"
                       tt-lanca.etbcre  = "01" +                                     string(tt-novafinan.etbcod,"999")
                       tt-lanca.data    = tt-novafinan.datref
                       tt-lanca.deb     = "15"   
                       tt-lanca.subcre  = "" 
                       tt-lanca.subdeb  = "" 
                       tt-lanca.cre     = "" 
                       tt-lanca.cod     = 0    
                       tt-lanca.his = "*LIVRE@VALOR REF NOVACAO DE CONTRATO"
                       tt-cab.qtdlot = tt-cab.qtdlot + 1
                       tt-lanca.val  = tt-novafinan.vlcontrato
                       /*tt-cab.totval = tt-cab.totval + 
                                            tt-novafinan.vlcontrato
                       */
                       tt-lanca.tiplan = "DIV"
                       tt-lanca.tipval = vesc[vindex]
                       .
                end.
                else assign
                    tt-lanca.val = tt-lanca.val + tt-novafinan.vlcontrato
                    /*tt-cab.totval = tt-cab.totval + tt-novafinan.vlcontrato
                    */
                    .
            end.
            if tt-novafinan.orilebes > 0
            then do:
                find first tt-lanca 
                           where tt-lanca.etbcre = "01" + 
                                      string(tt-novafinan.etbcod,"999") and
                                 tt-lanca.data   = tt-novafinan.datref and
                                 tt-lanca.cre    = "15" and
                                 tt-lanca.deb    = "" no-error.
                if not avail tt-lanca
                then do:
                    create tt-lanca.
                    assign tt-lanca.etbcod  = 01001
                    tt-lanca.etbdeb  = "01001"
                    tt-lanca.etbcre  = "01" + string(tt-novafinan.etbcod,"999")
                    tt-lanca.data    = tt-novafinan.datref
                    tt-lanca.deb     = ""   
                    tt-lanca.subcre  = "" 
                    tt-lanca.subdeb  = "" 
                    tt-lanca.cre     = "15" 
                    tt-lanca.cod     = 0    
                    tt-lanca.his = "*LIVRE@VALOR REF NOVACAO DE CONTRATO"
                    tt-cab.qtdlot = tt-cab.qtdlot + 1
                    tt-lanca.val  = tt-novafinan.orilebes
                    tt-cab.totval = tt-cab.totval + tt-novafinan.orilebes
                    tt-lanca.tiplan = "DIV" 
                    tt-lanca.tipval = vesc[vindex]
                    .
                end.
                else assign
                        tt-lanca.val  = tt-lanca.val + tt-novafinan.orilebes
                        tt-cab.totval = tt-cab.totval + tt-novafinan.orilebes
                        .
            end.
            if tt-novafinan.orifinan > 0
            then do:
                find first tt-lanca 
                           where tt-lanca.etbcre = "01" + 
                                      string(tt-novafinan.etbcod,"999") and
                                 tt-lanca.data   = tt-novafinan.datref and
                                 tt-lanca.cre    = "361" and
                                 tt-lanca.deb    = "" no-error.
                if not avail tt-lanca
                then do:
                    create tt-lanca.
                    assign tt-lanca.etbcod  = 01001
                    tt-lanca.etbdeb  = "01001"
                    tt-lanca.etbcre  = "01" + string(tt-novafinan.etbcod,"999")
                    tt-lanca.data    = tt-novafinan.datref
                    tt-lanca.deb     = ""   
                    tt-lanca.subcre  = "" 
                    tt-lanca.subdeb  = "" 
                    tt-lanca.cre     = "361" 
                    tt-lanca.cod     = 0    
                    tt-lanca.his = "*LIVRE@VALOR REF NOVACAO DE CONTRATO"
                    tt-cab.qtdlot = tt-cab.qtdlot + 1
                    tt-lanca.val  = tt-novafinan.orifinan
                    tt-cab.totval = tt-cab.totval + tt-novafinan.orifinan
                    tt-lanca.tiplan = "DIV" 
                    tt-lanca.tipval = vesc[vindex]
                    .
                end.
                else assign
                    tt-lanca.val  = tt-lanca.val + tt-novafinan.orifinan
                    tt-cab.totval = tt-cab.totval + tt-novafinan.orifinan
                    .
 
            end.
            if tt-novafinan.acrescimo > 0
            then do:
                find first tt-lanca 
                           where tt-lanca.etbcre = "01" + 
                                      string(tt-novafinan.etbcod,"999") and
                                 tt-lanca.data   = tt-novafinan.datref and
                                 tt-lanca.cre    = "669" and
                                 tt-lanca.deb    = "" no-error.
                if not avail tt-lanca
                then do:
                    create tt-lanca.
                    assign tt-lanca.etbcod  = 01001
                    tt-lanca.etbdeb  = "01001"
                    tt-lanca.etbcre  = "01" + string(tt-novafinan.etbcod,"999")
                    tt-lanca.data    = tt-novafinan.datref
                    tt-lanca.deb     = ""   
                    tt-lanca.subcre  = "" 
                    tt-lanca.subdeb  = "" 
                    tt-lanca.cre     = "669" 
                    tt-lanca.cod     = 0   
                    tt-lanca.his = "*LIVRE@VALOR REF NOVACAO DE CONTRATO"
                    tt-cab.qtdlot = tt-cab.qtdlot + 1
                    tt-lanca.val  = tt-novafinan.acrescimo
                    tt-cab.totval = tt-cab.totval + tt-novafinan.acrescimo
                    tt-lanca.tiplan = "DIV" 
                    tt-lanca.tipval = vesc[vindex]
                    .
                end.
                else assign
                    tt-lanca.val  = tt-lanca.val + tt-novafinan.acrescimo
                    tt-cab.totval = tt-cab.totval + tt-novafinan.acrescimo
                    .        
            end.
            if tt-novafinan.vlseguro > 0
            then do:
                find first tt-lanca 
                           where tt-lanca.etbcre = "01" + 
                                      string(tt-novafinan.etbcod,"999") and
                                 tt-lanca.data   = tt-novafinan.datref and
                                 tt-lanca.cre    = "564" and
                                 tt-lanca.deb    = "15" no-error.
                if not avail tt-lanca
                then do:
                    create tt-lanca.
                    assign tt-lanca.etbcod  = 01001
                       tt-lanca.etbdeb  = "01001"
                       tt-lanca.etbcre  = "01" +           
                                       string(tt-novafinan.etbcod,"999")
                       tt-lanca.data    = tt-novafinan.datref
                       tt-lanca.deb     = "15"   
                       tt-lanca.subcre  = "" 
                       tt-lanca.subdeb  = "" 
                       tt-lanca.cre     = "564" 
                       tt-lanca.cod     = 0    
                       tt-lanca.his = "*LIVRE@VALOR REF SEGURO"
                       tt-cab.qtdlot = tt-cab.qtdlot + 1 
                       tt-lanca.val  = tt-novafinan.vlseguro 
                       tt-cab.totval = tt-cab.totval + tt-novafinan.vlseguro
                       tt-lanca.tiplan = "EXC"
                       tt-lanca.tipval = vesc[vindex]
                       .
                end.
                else assign
                        tt-lanca.val  = tt-lanca.val + tt-novafinan.vlseguro
                        tt-cab.totval = tt-cab.totval + tt-novafinan.vlseguro
                        .
            end.
        end.
        *********/
    end.
    else if vindex = 5
    then do:
        run contrato-outros.
        vlote = "".
        
        message "Informe o numero do lote "
        update vlote.
        if vlote = ""
        then return.

        for each tt-contoutros where
                 tt-contoutros.etbcod > 0:
        
            find first tt-cab where 
                       tt-cab.data = tt-contoutros.datref no-error.
            
            if not avail tt-cab
            then do:
                create tt-cab.
                assign tt-cab.data   = tt-contoutros.datref
                           tt-cab.codlot = vlote + 
                           string(day(tt-contoutros.datref),"99").

            end.

            if tt-contoutros.principal - tt-contoutros.vlseguro > 0
            then do:
                find first tt-lanca 
                           where tt-lanca.etbcre = "01" + 
                                      string(tt-contoutros.etbcod,"999") and
                                 tt-lanca.data   = tt-contoutros.datref and
                                 tt-lanca.cre    = "162" and
                                 tt-lanca.deb    = "15" no-error.
                if not avail tt-lanca
                then do:
                    create tt-lanca.
                    assign tt-lanca.etbcod  = 01001
                       tt-lanca.etbdeb  = "01001"
                       tt-lanca.etbcre  = "01" +
                                string(tt-contoutros.etbcod,"999")
                       tt-lanca.data    = tt-contoutros.datref
                       tt-lanca.deb     = "15"   
                       tt-lanca.subcre  = "" 
                       tt-lanca.subdeb  = "" 
                       tt-lanca.cre     = "162" 
                       tt-lanca.cod     = 0    
                       tt-lanca.his = "*LIVRE@VENDAS A PRAZO CF REG SAIDAS" 
                       tt-cab.qtdlot = tt-cab.qtdlot + 1
                       tt-lanca.val  = tt-contoutros.principal -
                                       tt-contoutros.vlseguro
                       tt-cab.totval = tt-cab.totval + 
                               tt-contoutros.principal - tt-contoutros.vlseguro
                       tt-lanca.tipval = vesc[vindex]
                       .
                end.
                else assign
                    tt-lanca.val  = tt-lanca.val + 
                            tt-contoutros.principal - tt-contoutros.vlseguro
                    tt-cab.totval = tt-cab.totval + 
                            tt-contoutros.principal - tt-contoutros.vlseguro
                    .
            end.
            if tt-contoutros.acrescimo > 0
            then do:
                find first tt-lanca 
                           where tt-lanca.etbcre = "01" + 
                                      string(tt-contoutros.etbcod,"999") and
                                 tt-lanca.data   = tt-contoutros.datref and
                                 tt-lanca.cre    = "669" and
                                 tt-lanca.deb    = "15" no-error.
                if not avail tt-lanca
                then do:
                    create tt-lanca.
                    assign tt-lanca.etbcod  = 01001
                       tt-lanca.etbdeb  = "01001"
                       tt-lanca.etbcre  = "01" +
                                            string(tt-contoutros.etbcod,"999")
                       tt-lanca.data    = tt-contoutros.datref
                       tt-lanca.deb     = "15"   
                       tt-lanca.subcre  = "" 
                       tt-lanca.subdeb  = "" 
                       tt-lanca.cre     = "669" 
                       tt-lanca.cod     = 0    
                       tt-lanca.his = "*LIVRE@VLR ACRESCIMO FINANCEIRO N/DATA" 
                       tt-cab.qtdlot = tt-cab.qtdlot + 1
                       tt-lanca.val  = tt-contoutros.acrescimo
                       tt-cab.totval = tt-cab.totval +
                                    tt-contoutros.acrescimo
                       tt-lanca.tipval = vesc[vindex]
                       .
                end.
                else assign
                    tt-lanca.val  = tt-lanca.val + tt-contoutros.acrescimo
                    tt-cab.totval = tt-cab.totval + tt-contoutros.acrescimo
                    .
 
            end.
            if tt-contoutros.vlseguro > 0
            then do:
                find first tt-lanca 
                           where tt-lanca.etbcre = "01" + 
                                      string(tt-contoutros.etbcod,"999") and
                                 tt-lanca.data   = tt-contoutros.datref and
                                 tt-lanca.cre    = "564" and
                                 tt-lanca.deb    = "15" no-error.
                if not avail tt-lanca
                then do:
                    create tt-lanca.
                    assign tt-lanca.etbcod  = 01001
                       tt-lanca.etbdeb  = "01001"
                       tt-lanca.etbcre  = "01" +
                                    string(tt-contoutros.etbcod,"999")
                       tt-lanca.data    = tt-contoutros.datref
                       tt-lanca.deb     = "15"   
                       tt-lanca.subcre  = "" 
                       tt-lanca.subdeb  = "" 
                       tt-lanca.cre     = "564" 
                       tt-lanca.cod     = 0    
                       tt-lanca.his = "*LIVRE@VALOR REF SEGURO"
                       tt-cab.qtdlot = tt-cab.qtdlot + 1 
                       tt-lanca.val  = tt-contoutros.vlseguro 
                       tt-cab.totval = tt-cab.totval + tt-contoutros.vlseguro
                       tt-lanca.tiplan = "EXC"
                       tt-lanca.tipval = vesc[vindex]
                       .
                end.
                else assign
                    tt-lanca.val  = tt-lanca.val + tt-contoutros.vlseguro
                    tt-cab.totval = tt-cab.totval + tt-contoutros.vlseguro
                    .
            end.
        end.
    end.
    else if vindex = 6 or vindex = 7
    then do:
        run contrato-normal.
        vlote = "".
 
        message "Informe o numero do lote "
        update vlote.
        if vlote = ""
        then return.

        for each tt-contnormal where
                 tt-contnormal.etbcod > 0:
        
            find first tt-cab where 
                       tt-cab.data = tt-contnormal.datref no-error.
            
            if not avail tt-cab
            then do:
                create tt-cab.
                assign tt-cab.data   = tt-contnormal.datref
                           tt-cab.codlot = vlote + 
                           string(day(tt-contnormal.datref),"99").

            end.
            if tt-contnormal.acrescimo  > 0 and vindex = 6
            then do:
                find first tt-lanca 
                           where tt-lanca.etbcre = "01" + 
                                      string(tt-contnormal.etbcod,"999") and
                                 tt-lanca.data   = tt-contnormal.datref and
                                 tt-lanca.cre    = "669" and
                                 tt-lanca.deb    = "15" no-error.
                if not avail tt-lanca
                then do:
                    create tt-lanca.
                    assign tt-lanca.etbcod  = 01001
                       tt-lanca.etbdeb  = "01001"
                       tt-lanca.etbcre  = "01" +
                                        string(tt-contnormal.etbcod,"999")
                       tt-lanca.data    = tt-contnormal.datref
                       tt-lanca.deb     = "15"   
                       tt-lanca.subcre  = "" 
                       tt-lanca.subdeb  = "" 
                       tt-lanca.cre     = "669" /*"252"*/ 
                       tt-lanca.cod     = 0    
                       tt-lanca.his = "*LIVRE@VLR ACRESCIMO FINANCEIRO N/DATA" 
                       tt-cab.qtdlot = tt-cab.qtdlot + 1
                       tt-lanca.val  = tt-contnormal.acrescimo
                       tt-cab.totval = tt-cab.totval + tt-contnormal.acrescimo
                       tt-lanca.tipval = vesc[vindex]
                       .
                end.
                else assign
                    tt-lanca.val  = tt-lanca.val + tt-contnormal.acrescimo
                    tt-cab.totval = tt-cab.totval + tt-contnormal.acrescimo
                    .
            end.
            if tt-contnormal.vlseguro  > 0 and vindex = 7
            then do:
                find first tt-lanca 
                           where tt-lanca.etbcre = "01" + 
                                      string(tt-contnormal.etbcod,"999") and
                                 tt-lanca.data   = tt-contnormal.datref and
                                 tt-lanca.cre    = "564" and
                                 tt-lanca.deb    = "15" no-error.
                if not avail tt-lanca
                then do:
                    create tt-lanca.
                    assign tt-lanca.etbcod  = 01001
                       tt-lanca.etbdeb  = "01001"
                       tt-lanca.etbcre  = "01" +
                                        string(tt-contnormal.etbcod,"999")
                       tt-lanca.data    = tt-contnormal.datref
                       tt-lanca.deb     = "15"   
                       tt-lanca.subcre  = "" 
                       tt-lanca.subdeb  = "" 
                       tt-lanca.cre     = "564" 
                       tt-lanca.cod     = 0    
                       tt-lanca.his = "*LIVRE@VALOR REF SEGURO"
                       tt-cab.qtdlot = tt-cab.qtdlot + 1 
                       tt-lanca.val  = tt-contnormal.vlseguro 
                       tt-cab.totval = tt-cab.totval + tt-contnormal.vlseguro
                       tt-lanca.tiplan = "EXC"
                       tt-lanca.tipval = vesc[vindex]
                       .
 
                end.
                else assign
                    tt-lanca.val  = tt-lanca.val + tt-contnormal.vlseguro
                    tt-cab.totval = tt-cab.totval + tt-contnormal.vlseguro
                    .
            end.
        end.            
    end.
    else if vindex = 8
    then do:
        run ec-financeira.
        vlote = "85".

        for each tt-ecfinanceira where
                 tt-ecfinanceira.etbcod > 0  and
                 tt-ecfinanceira.principal > 0 
                 by tt-ecfinanceira.datref:
        
            find first tt-cab where 
                       tt-cab.data = tt-ecfinanceira.datref no-error.
            
            if not avail tt-cab
            then do:
                create tt-cab.
                assign tt-cab.data   = tt-ecfinanceira.datref
                           tt-cab.codlot = vlote + 
                           string(day(tt-ecfinanceira.datref),"99").

            end.
            if tt-ecfinanceira.principal > 0
            then do:
                find first tt-lanca 
                           where tt-lanca.etbcre = "01" + 
                                      string(tt-ecfinanceira.etbcod,"999") and
                                 tt-lanca.data   = tt-ecfinanceira.datref and
                                 tt-lanca.cre    = "15" and
                                 tt-lanca.deb    = "361" no-error.
                if not avail tt-lanca
                then do:
                    create tt-lanca.
                    assign tt-lanca.etbcod  = 01001
                       tt-lanca.etbdeb  = "01001"
                       tt-lanca.etbcre  = "01" +
                                    string(tt-ecfinanceira.etbcod,"999")
                       tt-lanca.data    = tt-ecfinanceira.datref
                       tt-lanca.deb     = "361"   
                       tt-lanca.subcre  = "" 
                       tt-lanca.subdeb  = "" 
                       tt-lanca.cre     = "15" 
                       tt-lanca.cod     = 0    
                       tt-lanca.his = "*LIVRE@ESTORNO CONTRATO N/DATA"
                       tt-cab.qtdlot = tt-cab.qtdlot + 1
                       tt-lanca.val  = tt-ecfinanceira.principal
                       tt-cab.totval = tt-cab.totval +
                                        tt-ecfinanceira.principal
                       tt-lanca.tipval = vesc[vindex]
                       .
                end.
                else assign
                    tt-lanca.val  = tt-lanca.val + tt-ecfinanceira.principal
                    tt-cab.totval = tt-cab.totval + tt-ecfinanceira.principal
                    .
            end.
            /*********
            if tt-ecfinanceira.acrescimo > 0
            then do:
                find first tt-lanca 
                           where tt-lanca.etbcre = "01" + 
                                      string(tt-ecfinanceira.etbcod,"999") and
                                 tt-lanca.data   = tt-ecfinanceira.datref and
                                 tt-lanca.cre    = "669" and
                                 tt-lanca.deb    = "15" no-error.
                if not avail tt-lanca
                then do:
 
                    create tt-lanca.
                    assign tt-lanca.etbcod  = 01001
                       tt-lanca.etbdeb  = "01001"
                       tt-lanca.etbcre  = "01" +
                                string(tt-ecfinanceira.etbcod,"999")
                       tt-lanca.data    = tt-ecfinanceira.datref
                       tt-lanca.deb     = "15"   
                       tt-lanca.subcre  = "" 
                       tt-lanca.subdeb  = "" 
                       tt-lanca.cre     = "669" /*"252"*/ 
                       tt-lanca.cod     = 0    
                       tt-lanca.his = "*LIVRE@CANCELAMENTO CONTRATO N/DATA"
                       tt-cab.qtdlot = tt-cab.qtdlot + 1
                       tt-lanca.val  = tt-ecfinanceira.acrescimo
                       tt-cab.totval = tt-cab.totval +
                                        tt-ecfinanceira.acrescimo
                       tt-lanca.tipval = vesc[vindex]
                       .
                end.
                else assign
                    tt-lanca.val  = tt-lanca.val + tt-ecfinanceira.acrescimo
                    tt-cab.totval = tt-cab.totval + tt-ecfinanceira.acrescimo
                    .
            end.            
            ************/
        end.
    end.
    else if vindex = 9
    then do:
        run recebimento.
        vlote = "70".
        
        for each tt-recebe where tt-recebe.tipo <> "":
            find first tt-cab where 
                       tt-cab.data = tt-recebe.datref no-error.
            
            if not avail tt-cab
            then do:
                create tt-cab.
                assign tt-cab.data   = tt-recebe.datref
                           tt-cab.codlot = vlote + 
                           string(day(tt-recebe.datref),"99").

            end.
            if tt-recebe.moeda = "REAL"
            then do:
                find first tt-lanca 
                           where tt-lanca.etbcre = "01001" and
                                 tt-lanca.data   = tt-recebe.datref and
                                 tt-lanca.cre    = "15" and
                                 tt-lanca.deb    = "1" no-error.
                if not avail tt-lanca
                then do:
                    create tt-lanca.
                    assign tt-lanca.etbcod  = 01001
                       tt-lanca.etbdeb  = "01001"
                       tt-lanca.etbcre  = "01001"
                       tt-lanca.data    = tt-recebe.datref
                       tt-lanca.deb     = "1"   
                       tt-lanca.subcre  = "" 
                       tt-lanca.subdeb  = "" 
                       tt-lanca.cre     = "15" 
                       tt-lanca.cod     = 0    
                       tt-lanca.his = "*LIVRE@REC.DE DIVS.CLIENTES N/DATA" 
                       tt-cab.qtdlot = tt-cab.qtdlot + 1
                       tt-lanca.val  = tt-recebe.vlparcela
                       tt-cab.totval = tt-cab.totval + tt-recebe.vlparcela
                       tt-lanca.tipval = vesc[vindex]
                       .

                end.
                else assign
                    tt-lanca.val  = tt-lanca.val + tt-recebe.vlparcela
                    tt-cab.totval = tt-cab.totval + tt-recebe.vlparcela
                    .
            end.
            if tt-recebe.moeda = "CARTAO"
            then do:
                find first tt-lanca 
                           where tt-lanca.etbcre = "01001" and
                                 tt-lanca.data   = tt-recebe.datref and
                                 tt-lanca.cre    = "15" and
                                 tt-lanca.deb    = "443" no-error.
                if not avail tt-lanca
                then do:
                    create tt-lanca.
                    assign tt-lanca.etbcod  = 01001
                       tt-lanca.etbdeb  = "01001"
                       tt-lanca.etbcre  = "01001"
                       tt-lanca.data    = tt-recebe.datref
                       tt-lanca.deb     = "443"   
                       tt-lanca.subcre  = "" 
                       tt-lanca.subdeb  = "" 
                       tt-lanca.cre     = "15" 
                       tt-lanca.cod     = 0    
                       tt-lanca.his = "*LIVRE@REC.DE DIVS.CLIENTES N/DATA" 
                       tt-cab.qtdlot = tt-cab.qtdlot + 1
                       tt-lanca.val  = tt-recebe.vlparcela
                       tt-cab.totval = tt-cab.totval + tt-recebe.vlparcela
                       tt-lanca.tipval = vesc[vindex]
                       .
                end.
                else assign
                    tt-lanca.val  = tt-lanca.val + tt-recebe.vlparcela
                    tt-cab.totval = tt-cab.totval + tt-recebe.vlparcela
                    .

            end.
            if tt-recebe.moeda = "BONUS"
            then do:
                find first tt-lanca 
                           where tt-lanca.etbcre = "01001" and
                                 tt-lanca.data   = tt-recebe.datref and
                                 tt-lanca.cre    = "15" and
                                 tt-lanca.deb    = "229" no-error.
                if not avail tt-lanca
                then do:
                    create tt-lanca.
                    assign tt-lanca.etbcod  = 01001
                       tt-lanca.etbdeb  = "01001"
                       tt-lanca.etbcre  = "01001" 
                       tt-lanca.data    = tt-recebe.datref
                       tt-lanca.deb     = "229"   
                       tt-lanca.subcre  = "" 
                       tt-lanca.subdeb  = "" 
                       tt-lanca.cre     = "15" 
                       tt-lanca.cod     = 0    
                       tt-lanca.his = "*LIVRE@REC.DE DIVS.CLIENTES N/DATA" 
                       tt-cab.qtdlot = tt-cab.qtdlot + 1
                       tt-lanca.val  = tt-recebe.vlparcela
                       tt-cab.totval = tt-cab.totval + tt-recebe.vlparcela
                       tt-lanca.tipval = vesc[vindex]
                       .
                end.
                else assign
                    tt-lanca.val  = tt-lanca.val + tt-recebe.vlparcela
                    tt-cab.totval = tt-cab.totval + tt-recebe.vlparcela
                    .

            end.
            if tt-recebe.moeda = "CHEQUE"
            then do:
                find first tt-lanca 
                           where tt-lanca.etbcre = "01001" and
                                 tt-lanca.data   = tt-recebe.datref and
                                 tt-lanca.cre    = "15" and
                                 tt-lanca.deb    = "400" no-error.
                if not avail tt-lanca
                then do:
                    create tt-lanca.
                    assign tt-lanca.etbcod  = 01001
                       tt-lanca.etbdeb  = "01001"
                       tt-lanca.etbcre  = "01001"
                       tt-lanca.data    = tt-recebe.datref
                       tt-lanca.deb     = "400"   
                       tt-lanca.subcre  = "" 
                       tt-lanca.subdeb  = "" 
                       tt-lanca.cre     = "15" 
                       tt-lanca.cod     = 0    
                       tt-lanca.his = "*LIVRE@REC.DE DIVS.CLIENTES N/DATA" 
                       tt-cab.qtdlot = tt-cab.qtdlot + 1
                       tt-lanca.val  = tt-recebe.vlparcela
                       tt-cab.totval = tt-cab.totval + tt-recebe.vlparcela
                       tt-lanca.tipval = vesc[vindex]
                       .
                end.
                else assign
                    tt-lanca.val  = tt-lanca.val + tt-recebe.vlparcela
                    tt-cab.totval = tt-cab.totval + tt-recebe.vlparcela
                    .

            end.
            if tt-recebe.moeda = "PRESENTE"
            then do:
                if tt-recebe.tipo = "VISTA"
                then do:
                    /****
                    find first tt-lanca 
                           where tt-lanca.etbcre = "01001" and
                                 tt-lanca.data   = tt-recebe.datref and
                                 tt-lanca.cre    = "659" and
                                 tt-lanca.deb    = "1" no-error.
                    if not avail tt-lanca
                    then do:
                        create tt-lanca.
                        assign tt-lanca.etbcod  = 01001
                            tt-lanca.etbdeb  = "01001"
                            tt-lanca.etbcre  = "01001"
                            tt-lanca.data    = tt-recebe.datref
                            tt-lanca.deb     = "1"   
                            tt-lanca.subcre  = "" 
                            tt-lanca.subdeb  = "" 
                            tt-lanca.cre     = "659" 
                            tt-lanca.cod     = 0    
                            tt-lanca.his = "*LIVRE@CARGA DE CARTAO PRESENTE" 
                            tt-cab.qtdlot = tt-cab.qtdlot + 1
                            tt-lanca.val  = tt-recebe.vlparcela
                            tt-cab.totval = tt-cab.totval + tt-recebe.vlparcela
                            tt-lanca.tipval = vesc[vindex]
                            .
                    end.
                    else assign
                        tt-lanca.val  = tt-lanca.val + tt-recebe.vlparcela
                        tt-cab.totval = tt-cab.totval + tt-recebe.vlparcela
                        .
                    ****/
                    
                    find first tt-lanca 
                           where tt-lanca.etbcre = "01001" and
                                 tt-lanca.data   = tt-recebe.datref and
                                 tt-lanca.cre    = "161" and
                                 tt-lanca.deb    = "659" no-error.
                    if not avail tt-lanca
                    then do:
                        create tt-lanca.
                        assign tt-lanca.etbcod  = 01001
                       tt-lanca.etbdeb  = "01001"
                       tt-lanca.etbcre  = "01001"
                       tt-lanca.data    = tt-recebe.datref
                       tt-lanca.deb     = "659"   
                       tt-lanca.subcre  = "" 
                       tt-lanca.subdeb  = "" 
                       tt-lanca.cre     = "161" 
                       tt-lanca.cod     = 0    
                       tt-lanca.his = "*LIVRE@RESGATE DE CARTAO PRESENTE" 
                       tt-cab.qtdlot = tt-cab.qtdlot + 1
                       tt-lanca.val  = tt-recebe.vlparcela
                       tt-cab.totval = tt-cab.totval + tt-recebe.vlparcela
                       tt-lanca.tipval = vesc[vindex]
                       .
                    end.
                    else assign
                        tt-lanca.val  = tt-lanca.val + tt-recebe.vlparcela
                        tt-cab.totval = tt-cab.totval + tt-recebe.vlparcela
                        .        
                end.
                else do:
                    /****
                    find first tt-lanca 
                           where tt-lanca.etbcre = "01001"
                                 tt-lanca.data   = tt-recebe.datref and
                                 tt-lanca.cre    = "659" and
                                 tt-lanca.deb    = "15" no-error.
                    if not avail tt-lanca
                    then do:
                        create tt-lanca.
                        assign tt-lanca.etbcod  = 01001
                        tt-lanca.etbdeb  = "01001"
                        tt-lanca.etbcre  = "01001"
                        tt-lanca.data    = tt-recebe.datref
                       tt-lanca.deb     = "15"   
                       tt-lanca.subcre  = "" 
                       tt-lanca.subdeb  = "" 
                       tt-lanca.cre     = "659" 
                       tt-lanca.cod     = 0    
                       tt-lanca.his = "*LIVRE@CARGA DE CARTAO PRESENTE" 
                       tt-cab.qtdlot = tt-cab.qtdlot + 1
                       tt-lanca.val  = tt-recebe.vlparcela
                       tt-cab.totval = tt-cab.totval + tt-recebe.vlparcela
                       tt-lanca.tipval = vesc[vindex]
                       .
                    else assign
                        tt-lanca.val  = tt-lanca.val + tt-recebe.vlparcela
                        tt-cab.totval = tt-cab.totval + tt-recebe.vlparcela
                        .
                    ****/

                    find first tt-lanca 
                           where tt-lanca.etbcre = "01001" and
                                 tt-lanca.data   = tt-recebe.datref and
                                 tt-lanca.cre    = "15" and
                                 tt-lanca.deb    = "656" no-error.
                    if not avail tt-lanca
                    then do:
                        create tt-lanca.
                        assign tt-lanca.etbcod  = 01001
                       tt-lanca.etbdeb  = "01001"
                       tt-lanca.etbcre  = "01001"
                       tt-lanca.data    = tt-recebe.datref
                       tt-lanca.deb     = "659"   
                       tt-lanca.subcre  = "" 
                       tt-lanca.subdeb  = "" 
                       tt-lanca.cre     = "15" 
                       tt-lanca.cod     = 0    
                       tt-lanca.his = "*LIVRE@RESGATE DE CARTAO PRESENTE" 
                       tt-cab.qtdlot = tt-cab.qtdlot + 1
                       tt-lanca.val  = tt-recebe.vlparcela
                       tt-cab.totval = tt-cab.totval + tt-recebe.vlparcela
                       tt-lanca.tipval = vesc[vindex]
                       .
                    end.
                    else assign
                        tt-lanca.val  = tt-lanca.val + tt-recebe.vlparcela
                        tt-cab.totval = tt-cab.totval + tt-recebe.vlparcela
                        .
                end.
            end.
         end.
    end.
    run gera-arquivo-ctb.    

end.  

procedure venda-vista:
    
    for each estab no-lock:
         do vdata = vdti to vdtf:
            for each ctbvenda where ctbvenda.tipo = "VENDA" and
                        ctbvenda.tipovenda = "VENDA LOJA" and
                        ctbvenda.datref = vdata and
                        ctbvenda.etbcod = estab.etbcod and
                        ctbvenda.movseq = 30 and
                        ctbvenda.crecod = 1
                        no-lock:
                find first tt-vendavista where
                           tt-vendavista.etbcod = ctbvenda.etbcod and
                           tt-vendavista.datref = ctbvenda.datref 
                           no-lock no-error.
                if not avail tt-vendavista
                then do:
                    create tt-vendavista.
                    assign
                        tt-vendavista.etbcod = ctbvenda.etbcod 
                        tt-vendavista.datref = ctbvenda.datref
                        .
                end. 
                assign
                    tt-vendavista.valvenda = tt-vendavista.valvenda +
                                    ctbvenda.mercadoria
                    tt-vendavista.valservi = tt-vendavista.valservi +
                                    ctbvenda.servico
                    tt-vendavista.valoutra = tt-vendavista.valoutra +
                                    ctbvenda.outras
                    tt-vendavista.valtotal = tt-vendavista.valtotal +
                                ctbvenda.mercadoria +
                                ctbvenda.servico + 
                                ctbvenda.outras
                     .               
            end.
            for each ctbvenda where ctbvenda.tipo = "VENDA" and
                        ctbvenda.tipovenda = "VENDA OUTRA LOJA" and
                        ctbvenda.datref = vdata and
                        ctbvenda.etbcod = estab.etbcod and
                        ctbvenda.movseq = 30  and
                        ctbvenda.crecod = 1
                        no-lock:
                find first tt-vendavista where
                           tt-vendavista.etbcod = ctbvenda.etbcod and
                           tt-vendavista.datref = ctbvenda.datref 
                           no-lock no-error.
                if not avail tt-vendavista
                then do:
                    create tt-vendavista.
                    assign
                        tt-vendavista.etbcod = ctbvenda.etbcod 
                        tt-vendavista.datref = ctbvenda.datref
                        .
                end. 
                assign
                    tt-vendavista.valvenda = tt-vendavista.valvenda +
                                    ctbvenda.mercadoria
                    tt-vendavista.valservi = tt-vendavista.valservi +
                                    ctbvenda.servico
                    tt-vendavista.valoutra = tt-vendavista.valoutra +
                                    ctbvenda.outras
                    tt-vendavista.valtotal = tt-vendavista.valtotal +
                                ctbvenda.mercadoria +
                                ctbvenda.servico + 
                                ctbvenda.outras
                     . 
            end.
        end.
    end.    
end procedure.

procedure venda-prazo:
    
    for each estab no-lock:
         do vdata = vdti to vdtf:
            for each ctbvenda where ctbvenda.tipo = "VENDA" and
                        ctbvenda.tipovenda = "VENDA LOJA" and
                        ctbvenda.datref = vdata and
                        ctbvenda.etbcod = estab.etbcod and
                        ctbvenda.movseq = 30 and
                        ctbvenda.crecod = 2
                        no-lock:
                find first tt-vendaprazo where
                           tt-vendaprazo.etbcod = ctbvenda.etbcod and
                           tt-vendaprazo.datref = ctbvenda.datref 
                           no-lock no-error.
                if not avail tt-vendaprazo
                then do:
                    create tt-vendaprazo.
                    assign
                        tt-vendaprazo.etbcod = ctbvenda.etbcod 
                        tt-vendaprazo.datref = ctbvenda.datref
                        .
                end. 
                assign
                    tt-vendaprazo.valvenda = tt-vendaprazo.valvenda +
                                    ctbvenda.mercadoria
                    tt-vendaprazo.valservi = tt-vendaprazo.valservi +
                                    ctbvenda.servico
                    tt-vendaprazo.valoutra = tt-vendaprazo.valoutra +
                                    ctbvenda.outras
                    tt-vendaprazo.valtotal = tt-vendaprazo.valtotal +
                                ctbvenda.mercadoria +
                                ctbvenda.servico + 
                                ctbvenda.outras
                     .               
            end.
            for each ctbvenda where ctbvenda.tipo = "VENDA" and
                        ctbvenda.tipovenda = "VENDA OUTRA LOJA" and
                        ctbvenda.datref = vdata and
                        ctbvenda.etbcod = estab.etbcod and
                        ctbvenda.movseq = 30  and
                        ctbvenda.crecod = 2
                        no-lock:
                find first tt-vendaprazo where
                           tt-vendaprazo.etbcod = ctbvenda.etbcod and
                           tt-vendaprazo.datref = ctbvenda.datref 
                           no-lock no-error.
                if not avail tt-vendaprazo
                then do:
                    create tt-vendaprazo.
                    assign
                        tt-vendaprazo.etbcod = ctbvenda.etbcod 
                        tt-vendaprazo.datref = ctbvenda.datref
                        .
                end. 
                assign
                    tt-vendaprazo.valvenda = tt-vendaprazo.valvenda +
                                    ctbvenda.mercadoria
                    tt-vendaprazo.valservi = tt-vendaprazo.valservi +
                                    ctbvenda.servico
                    tt-vendaprazo.valoutra = tt-vendaprazo.valoutra +
                                    ctbvenda.outras
                    tt-vendaprazo.valtotal = tt-vendaprazo.valtotal +
                                ctbvenda.mercadoria +
                                ctbvenda.servico + 
                                ctbvenda.outras
                     . 
            end.
        end.
    end.    
end procedure.

procedure venda-devolucao:
    for each estab no-lock:
        do vdata = vdti to vdtf:
            for each ctbvenda where ctbvenda.tipo = "DEVOLUCAO VENDA" and
                        ctbvenda.datref = vdata and
                        ctbvenda.etbcod = estab.etbcod and
                        ctbvenda.movseq = 200 
                        no-lock:
                        .                              
                find first tt-vendadevol where
                           tt-vendadevol.etbcod = ctbvenda.etbcod and
                           tt-vendadevol.datref = ctbvenda.datref 
                           no-lock no-error.
                if not avail tt-vendadevol
                then do:
                    create tt-vendadevol.
                    assign
                        tt-vendadevol.etbcod = ctbvenda.etbcod 
                        tt-vendadevol.datref = ctbvenda.datref
                        .
                end. 
                if ctbvenda.crecod = 1
                then tt-vendadevol.valvista   = tt-vendadevol.valvista +
                            ctbvenda.mercadoria + ctbvenda.servico +
                                                       ctbvenda.outras.
                else tt-vendadevol.valprazo   = tt-vendadevol.valprazo +
                            ctbvenda.mercadoria + ctbvenda.servico +
                                                       ctbvenda.outras.
                assign
                    tt-vendadevol.valquitado = tt-vendadevol.valquitado +
                                    ctbvenda.valquitado
                    tt-vendadevol.valdevolvido = tt-vendadevol.valdevolvido +
                                    ctbvenda.valdevolvido
                    .             
            end.
        end.
    end.
end procedure.
procedure contrato-novacao:
    for each estab no-lock:
         do vdata = vdti to vdtf:
    
    for each ctbcontrato where ctbcontrato.tipo = "CONTRATO" and
                           ctbcontrato.datref = vdata and
                           ctbcontrato.etbcod = estab.etbcod and
                           ctbcontrato.movseq = 35
                           no-lock:
        
        if ctbcontrato.cobcod = 2
        then do:
            find first tt-novalebes where
                   tt-novalebes.etbcod = ctbcontrato.etbcod and
                   tt-novalebes.datref = ctbcontrato.datref
                   no-error.
            if not avail tt-novalebes
            then do:
                create tt-novalebes.
                assign
                    tt-novalebes.etbcod = ctbcontrato.etbcod
                    tt-novalebes.datref = ctbcontrato.datref
                    .
            end.
            assign
                tt-novalebes.vlcontrato = tt-novalebes.vlcontrato +
                                        ctbcontrato.vlcontrato
                tt-novalebes.vlentra = tt-novalebes.vlentra +
                                        ctbcontrato.vlentra
                tt-novalebes.principal = tt-novalebes.principal +
                                        ctbcontrato.vlprincipal
                tt-novalebes.acrescimo = tt-novalebes.acrescimo +
                                        ctbcontrato.vlacrescimo
                tt-novalebes.vlseguro    = tt-novalebes.vlseguro +
                                        ctbcontrato.vlseguro
                tt-novalebes.orilebes  = tt-novalebes.orilebes +
                                        ctbcontrato.vlorileb
                tt-novalebes.orifinan  = tt-novalebes.orifinan +
                                        ctbcontrato.vlorifin
                .
        end.
        else do:
            find first tt-novafinan where
                   tt-novafinan.etbcod = ctbcontrato.etbcod and
                   tt-novafinan.datref = ctbcontrato.datref
                   no-error.
            if not avail tt-novafinan
            then do:
                create tt-novafinan.
                assign
                    tt-novafinan.etbcod = ctbcontrato.etbcod
                    tt-novafinan.datref = ctbcontrato.datref
                    .
            end.
            assign
                tt-novafinan.vlcontrato = tt-novafinan.vlcontrato + 
                                        ctbcontrato.vlcontrato
                tt-novafinan.vlentra = tt-novafinan.vlentra +                                         ctbcontrato.vlentra
                tt-novafinan.principal = tt-novafinan.principal +
                                        ctbcontrato.vlprincipal
                tt-novafinan.acrescimo = tt-novafinan.acrescimo +
                                        ctbcontrato.vlacrescimo
                tt-novafinan.vlseguro    = tt-novafinan.vlseguro +
                                        ctbcontrato.vlseguro
                tt-novafinan.orilebes  = tt-novafinan.orilebes +
                                        ctbcontrato.vlorileb
                tt-novafinan.orifinan  = tt-novafinan.orifinan +
                                        ctbcontrato.vlorifin
                .
        end.
    end.
    end. 
    end.
end.
procedure contrato-outros:
    for each estab no-lock:
         do vdata = vdti to vdtf:
    
            for each ctbcontrato where ctbcontrato.tipo = "CONTRATO" and
                           ctbcontrato.datref = vdata and
                           ctbcontrato.etbcod = estab.etbcod and
                           ctbcontrato.movseq = 36
                           no-lock:
                find first tt-contoutros where
                           tt-contoutros.etbcod = ctbcontrato.etbcod and
                           tt-contoutros.datref = ctbcontrato.datref
                           no-error.
                if not avail tt-contoutros
                then do:
                    create tt-contoutros.
                    assign
                        tt-contoutros.etbcod = ctbcontrato.etbcod
                        tt-contoutros.datref = ctbcontrato.datref
                        .
                end.
                assign
                    tt-contoutros.vlcontrato = tt-contoutros.vlcontrato +
                                        ctbcontrato.vlcontrato
                    tt-contoutros.vlentra = tt-contoutros.vlentra +
                                        ctbcontrato.vlentra
                    tt-contoutros.principal = tt-contoutros.principal +
                                        ctbcontrato.vlprincipal
                    tt-contoutros.acrescimo = tt-contoutros.acrescimo +
                                        ctbcontrato.vlacrescimo
                    tt-contoutros.vlseguro  = tt-contoutros.vlseguro +
                                        ctbcontrato.vlseguro
                    tt-contoutros.orilebes  = tt-contoutros.orilebes +
                                        ctbcontrato.vlorileb
                    tt-contoutros.orifinan  = tt-contoutros.orifinan +
                                        ctbcontrato.vlorifin
                .
            end.
        end.
    end.
end procedure.
procedure contrato-normal:
    for each estab no-lock:
         do vdata = vdti to vdtf:
    
            for each ctbcontrato where ctbcontrato.tipo = "CONTRATO" and
                           ctbcontrato.datref = vdata and
                           ctbcontrato.etbcod = estab.etbcod and
                           ctbcontrato.movseq = 30
                           no-lock:
                find first tt-contnormal where
                           tt-contnormal.etbcod = ctbcontrato.etbcod and
                           tt-contnormal.datref = ctbcontrato.datref
                           no-error.
                if not avail tt-contnormal
                then do:
                    create tt-contnormal.
                    assign
                        tt-contnormal.etbcod = ctbcontrato.etbcod
                        tt-contnormal.datref = ctbcontrato.datref
                        .
                end.
                assign
                    tt-contnormal.vlcontrato = tt-contnormal.vlcontrato +
                                        ctbcontrato.vlcontrato
                    tt-contnormal.vlentra = tt-contnormal.vlentra +
                                        ctbcontrato.vlentra
                    tt-contnormal.principal = tt-contnormal.principal +
                                        ctbcontrato.vlprincipal
                    /*tt-contnormal.acrescimo = tt-contnormal.acrescimo +
                                        ctbcontrato.vlacrescimo
                    */                    
                    tt-contnormal.vlseguro  = tt-contnormal.vlseguro +
                                        ctbcontrato.vlseguro
                    tt-contnormal.orilebes  = tt-contnormal.orilebes +
                                        ctbcontrato.vlorileb
                    tt-contnormal.orifinan  = tt-contnormal.orifinan +
                                        ctbcontrato.vlorifin
                .
                if ctbcontrato.cobcod = 2
                then tt-contnormal.acrescimo = tt-contnormal.acrescimo +
                            ctbcontrato.vlacrescimo.
                            
            end.
        end.
    end.
end procedure.
procedure ec-financeira:
    for each estab no-lock:
        do vdata = vdti to vdtf:
            for each ctbcontrato where 
                           ctbcontrato.tipo = "ESTORNO FINANCEIRA" and
                           ctbcontrato.datref = vdata and
                           ctbcontrato.etbcod = estab.etbcod and
                           ctbcontrato.movseq = 30
                           no-lock:
                find first tt-ecfinanceira where
                           tt-ecfinanceira.etbcod = 1 and
                           tt-ecfinanceira.datref = ctbcontrato.datref
                           no-error.
                if not avail tt-contnormal
                then do:
                    create tt-ecfinanceira.
                    assign
                        tt-ecfinanceira.etbcod = 1
                        tt-ecfinanceira.datref = ctbcontrato.datref
                        .
                end.
                assign
                    tt-ecfinanceira.vlcontrato = tt-ecfinanceira.vlcontrato +
                                        ctbcontrato.vlcontrato
                    tt-ecfinanceira.vlentra = tt-ecfinanceira.vlentra +
                                        ctbcontrato.vlentra
                    tt-ecfinanceira.principal = tt-ecfinanceira.principal +
                                        ctbcontrato.vlprincipal
                    tt-ecfinanceira.acrescimo = tt-ecfinanceira.acrescimo +
                                        ctbcontrato.vlacrescimo
                    tt-ecfinanceira.vlseguro  = tt-ecfinanceira.vlseguro +
                                        ctbcontrato.vlseguro
                    tt-ecfinanceira.orilebes  = tt-ecfinanceira.orilebes +
                                        ctbcontrato.vlorileb
                    tt-ecfinanceira.orifinan  = tt-ecfinanceira.orifinan +
                                        ctbcontrato.vlorifin
                .
            end.
        end.
    end.
end procedure.

procedure recebimento:
    def var vmoeda as char.
    def var vdest as char.
    for each estab no-lock:
        do vdata = vdti to vdtf:
            for each ctbrecebe where ctbrecebe.tipo = "RECEBIMENTO" and
                         ctbrecebe.datref = vdata  and
                         ctbrecebe.etbcod = estab.etbcod and
                         ctbrecebe.movseq = 20
                         no-lock:
                
                vdest = "ENTRADA".
                
                if ctbrecebe.moeda matches "*TEF*" or
                   ctbrecebe.moeda begins "CAR"
                then vmoeda = "CARTAO".
                else if ctbrecebe.moeda begins "BCO"
                then vmoeda = "BANCO".
                else if ctbrecebe.moeda begins "BON"
                then vmoeda = "BONUS".
                else if ctbrecebe.moeda begins "REA"
                then vmoeda = "REAL".
                else if ctbrecebe.moeda begins "CHV" or
                        ctbrecebe.moeda begins "PRE"
                then vmoeda = "CHEQUE".
                else if ctbrecebe.moeda begins "CHP"
                then vmoeda = "PRESENTE".
                else if ctbrecebe.moeda begins "NOV"
                then vmoeda = "NOVACAO".
                else vmoeda = "OUTROS".
                       
                find first tt-recebe where 
                           tt-recebe.tipo  = vdest and
                           tt-recebe.etbcod = ctbrecebe.etbcod and
                           tt-recebe.datref = ctbrecebe.datref and
                           tt-recebe.moeda  = vmoeda
                           no-error.
                if not avail tt-recebe
                then do:
                    create tt-recebe.
                    assign
                        tt-recebe.tipo  = "ENTRADA"
                        tt-recebe.etbcod = ctbrecebe.etbcod
                        tt-recebe.datref = ctbrecebe.datref
                        tt-recebe.moeda  = vmoeda
                        .
                end.        
                assign
                    tt-recebe.vlparcela = tt-recebe.vlparcela +
                                       ctbrecebe.vlparcela
                    tt-recebe.vlpago   = tt-recebe.vlpago +
                                      ctbrecebe.vlpago
                    tt-recebe.vlprincipal = tt-recebe.vlprincipal +
                                         ctbrecebe.vlprincipal
                    tt-recebe.vlacrescimo = tt-recebe.vlacrescimo +
                                         ctbrecebe.vlacrescimo
                    tt-recebe.vlseguro    = tt-recebe.vlseguro +
                                         ctbrecebe.vlseguro
                    tt-recebe.vljuro      = tt-recebe.vljuro +
                                         ctbrecebe.vljuro
                    .
                
            end.
            for each ctbrecebe where ctbrecebe.tipo = "RECEBIMENTO" and
                         ctbrecebe.datref = vdata  and
                         ctbrecebe.etbcod = estab.etbcod and
                         ctbrecebe.movseq = 30
                         no-lock:
                
                if ctbrecebe.cobcod = 2 
                then vdest = "LEBES".
                else vdest = "FINANCEIRA".
                
                if ctbrecebe.moeda matches "*TEF*" or
                   ctbrecebe.moeda begins "CAR"
                then vmoeda = "CARTAO".
                else if ctbrecebe.moeda begins "BCO"
                then vmoeda = "BANCO".
                else if ctbrecebe.moeda begins "BON"
                then vmoeda = "BONUS".
                else if ctbrecebe.moeda begins "REA"
                then vmoeda = "REAL".
                else if ctbrecebe.moeda begins "CHV" or
                        ctbrecebe.moeda begins "PRE"
                then vmoeda = "CHEQUE".
                else if ctbrecebe.moeda begins "CHP"
                then vmoeda = "PRESENTE".
                else if ctbrecebe.moeda begins "NOV"
                then vmoeda = "NOVACAO".
                else vmoeda = "OUTROS".
                       
                find first tt-recebe where 
                           tt-recebe.tipo  = vdest and
                           tt-recebe.etbcod = ctbrecebe.etbcod and
                           tt-recebe.datref = ctbrecebe.datref and
                           tt-recebe.moeda  = vmoeda
                           no-error.
                if not avail tt-recebe
                then do:
                    create tt-recebe.
                    assign
                        tt-recebe.tipo  = vdest
                        tt-recebe.etbcod = ctbrecebe.etbcod
                        tt-recebe.datref = ctbrecebe.datref
                        tt-recebe.moeda  = vmoeda
                        .
                end.        
                assign
                    tt-recebe.vlparcela = tt-recebe.vlparcela +
                                       ctbrecebe.vlparcela
                    tt-recebe.vlpago   = tt-recebe.vlpago +
                                      ctbrecebe.vlpago
                    tt-recebe.vlprincipal = tt-recebe.vlprincipal +
                                         ctbrecebe.vlprincipal
                    tt-recebe.vlacrescimo = tt-recebe.vlacrescimo +
                                         ctbrecebe.vlacrescimo
                    tt-recebe.vlseguro    = tt-recebe.vlseguro +
                                         ctbrecebe.vlseguro
                    tt-recebe.vljuro      = tt-recebe.vljuro +
                                         ctbrecebe.vljuro
                    .
            end. 
            for each ctbrecebe where ctbrecebe.tipo = "RECEBIMENTO" and
                         ctbrecebe.datref = vdata  and
                         ctbrecebe.etbcod = estab.etbcod and
                         ctbrecebe.movseq = 50
                         no-lock:
                
                vdest = "VISTA".
                
                if ctbrecebe.moeda matches "*TEF*" or
                   ctbrecebe.moeda begins "CAR"
                then vmoeda = "CARTAO".
                else if ctbrecebe.moeda begins "BCO"
                then vmoeda = "BANCO".
                else if ctbrecebe.moeda begins "BON"
                then vmoeda = "BONUS".
                else if ctbrecebe.moeda begins "REA"
                then vmoeda = "REAL".
                else if ctbrecebe.moeda begins "CHV" or
                        ctbrecebe.moeda begins "PRE"
                then vmoeda = "CHEQUE".
                else if ctbrecebe.moeda begins "CHP"
                then vmoeda = "PRESENTE".
                else if ctbrecebe.moeda begins "NOV"
                then vmoeda = "NOVACAO".
                else vmoeda = "OUTROS".
                       
                find first tt-recebe where 
                           tt-recebe.tipo  = vdest and
                           tt-recebe.etbcod = ctbrecebe.etbcod and
                           tt-recebe.datref = ctbrecebe.datref and
                           tt-recebe.moeda  = vmoeda
                           no-error.
                if not avail tt-recebe
                then do:
                    create tt-recebe.
                    assign
                        tt-recebe.tipo  = vdest
                        tt-recebe.etbcod = ctbrecebe.etbcod
                        tt-recebe.datref = ctbrecebe.datref
                        tt-recebe.moeda  = vmoeda
                        .
                end.        
                assign
                    tt-recebe.vlparcela = tt-recebe.vlparcela +
                                       ctbrecebe.vlparcela
                    tt-recebe.vlpago   = tt-recebe.vlpago +
                                      ctbrecebe.vlpago
                    tt-recebe.vlprincipal = tt-recebe.vlprincipal +
                                         ctbrecebe.vlprincipal
                    tt-recebe.vlacrescimo = tt-recebe.vlacrescimo +
                                         ctbrecebe.vlacrescimo
                    tt-recebe.vlseguro    = tt-recebe.vlseguro +
                                         ctbrecebe.vlseguro
                    tt-recebe.vljuro      = tt-recebe.vljuro +
                                         ctbrecebe.vljuro
                    .
            end.                 
        end.
    end.                        
end procedure.

procedure cria-tt-lanctbcl:
    
    find tt-clilanca where
         tt-clilanca.lanano = year(tt-lanca.data)  and
         tt-clilanca.lanmes = month(tt-lanca.data) and
         tt-clilanca.datlan = tt-lanca.data        and
         tt-clilanca.lancre = int(tt-lanca.cre)    and
         tt-clilanca.landeb = int(tt-lanca.deb)    and
         tt-clilanca.lansit = tt-lanca.tipval
          no-error.
    if not avail tt-clilanca
    then do:
        create tt-clilanca.
        assign
            tt-clilanca.lanano = year(tt-lanca.data)
            tt-clilanca.lanmes = month(tt-lanca.data)
            tt-clilanca.datlan = tt-lanca.data 
            tt-clilanca.lancre = int(tt-lanca.cre)
            tt-clilanca.landeb = int(tt-lanca.deb)
            tt-clilanca.comhis = tt-lanca.his
            tt-clilanca.lansit = tt-lanca.tipval
            .
    end.
    tt-clilanca.vallan = tt-clilanca.vallan + tt-lanca.val.
    
    find btt-clilanca where
         btt-clilanca.lanano = year(tt-lanca.data)  and
         btt-clilanca.lanmes = month(tt-lanca.data) and
         btt-clilanca.datlan = ?        and
         btt-clilanca.lancre = int(tt-lanca.cre)    and
         btt-clilanca.landeb = int(tt-lanca.deb)    and
         btt-clilanca.lansit = tt-lanca.tipval
          no-error.
    if not avail btt-clilanca
    then do:
        create btt-clilanca.
        assign
            btt-clilanca.lanano = year(tt-lanca.data)
            btt-clilanca.lanmes = month(tt-lanca.data)
            btt-clilanca.datlan = ? 
            btt-clilanca.lancre = int(tt-lanca.cre)
            btt-clilanca.landeb = int(tt-lanca.deb)
            btt-clilanca.comhis = tt-lanca.his
            btt-clilanca.lansit = tt-lanca.tipval
            .
    end.
    btt-clilanca.vallan = btt-clilanca.vallan + tt-lanca.val.
         
end procedure.

procedure cria-lanctbcl:
    
    for each tt-clilanca where lanano > 0:
        
        find clilanca where
             clilanca.lanano = tt-clilanca.lanano and
             clilanca.lanmes = tt-clilanca.lanmes and
             clilanca.datlan = tt-clilanca.datlan and
             clilanca.lancre = tt-clilanca.lancre and
             clilanca.landeb = tt-clilanca.landeb and
             clilanca.lansit = tt-clilanca.lansit
             no-error.
        if not avail clilanca
        then do:
            create clilanca.
            assign
                clilanca.lanano = tt-clilanca.lanano
                clilanca.lanmes = tt-clilanca.lanmes
                clilanca.datlan = tt-clilanca.datlan
                clilanca.lancre = tt-clilanca.lancre
                clilanca.landeb = tt-clilanca.landeb
                clilanca.comhis = tt-clilanca.comhis
                clilanca.lansit = tt-clilanca.lansit
                .

        end.
        clilanca.vallan = tt-clilanca.vallan .
    end.            
end procedure.

procedure gera-arquivo-ctb:
    def var vseq as int.
    def var vnomarq as char.
    def var varquivo as char.
    def var varquivo1 as char.
    def var v-seq as int.
    def var cd_batch as char.
    def var tot-tot as dec.
    
    vseq = 0.
    for each tt-lanca break by tt-lanca.data:
        
        vseq = vseq + 1.
        tt-lanca.seq = vseq.
         
        if last-of(tt-lanca.data)
        then vseq = 0.
        
        run cria-tt-lanctbcl.
        
    end.
    
    run cria-lanctbcl.
    
    vnomarq = replace(vesc[vindex],"/","").

    if opsys = "UNIX"
    then do:
        varquivo = "/admcom/sispro/vendas/"  + vnomarq +
                         string(day(vdti),"99") + 
                         "a" + 
                         string(day(vdtf),"99")  + 
                         string(month(vdtf),"99") + 
                         string(year(vdtf),"9999") + ".txt".
        varquivo1 = "l:~\sispro~\vendas~\" + vnomarq +
                        string(day(vdti),"99") + 
                        "a" +  
                        string(day(vdtf),"99") + 
                        string(month(vdtf),"99") +
                        string(year(vdtf),"9999") + ".txt".                     
    end.
    /*
    disp varquivo label "Arquivo" format "x(65)".
    */
    
    output to value(varquivo).
    

    v-seq = 1000.

    cd_batch = "VENDAS" +
               string(day(today),"99") +  
               string(month(today),"99") +    
               string(year(today),"9999") +   
               string(time,"HH:MM").

    for each tt-cab where tt-cab.totval > 0:
    
        find first tt-lanca where tt-lanca.data   = tt-cab.data
                    no-lock no-error.
        if not avail tt-lanca then next.            
                    


        /********************* HEADER ********************/
        /*cd_batch = "VENDAS" +
               string(day(today),"99") +  
               string(month(today),"99") +    
               string(year(today),"9999") +   
               string(time,"HH:MM").
        */
    
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
    
            if tt-lanca.tiplan = ""
            then tt-lanca.tiplan = "EXC".
        
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
                   tt-lanca.tiplan  format "x(03)"  
     /* 90 */      " " format "x(01)"   
                   " " format "x(10)"    
                   " " format "x(01)"   
                   " " format "x(10)"   
                   " " format "x(34)"   
                   " " format "x(01)"   
                   v-seq format "999999"
     /* 97 */      " " format "x(01)"  skip.

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

    def var varqlixo as char.
    varqlixo = "/admcom/relat/lixoctb." + string(time).
    output to value(varqlixo).
    unix silent value("chmod 777 " + varquivo).
    unix silent value("unix2dos " + varquivo).
    output close.

    message color red/with
    varquivo1 view-as alert-box.
    
end procedure.
