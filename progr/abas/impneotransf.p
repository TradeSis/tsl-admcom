/* #1 helio.neto - 07102019 - nao importar pedidos com data < today */
{/admcom/progr/admbatch.i}

def var pabtcod like abastransf.abtcod.

def shared temp-table ttarq no-undo
    field arq as char format "x(50)"
    field interface     as char 
    field Arquivo       as char initial ?
    field diretorio     as char
    index idx is unique primary interface asc Arquivo asc.


def temp-table tt-transf no-undo
    field pedido as char    format "x(20)"
    field procod as char    format "x(10)"
    field etbcod as char    format "x(10)"
    field dttransf as char    format "x(10)"
    field qtd    as char    format "x(12)"

    field procodorigem as char    format "x(10)"

    field etbCD  as char    format "x(10)"
    field dtmov  as char    format "x(10)"

    field forne  as char    format "x(18)"
    field dtprog as char    format "x(10)".


def temp-table tt-wms no-undo
    field wms       like abastransf.wms
    field qtd       like abastransf.abtqtd format ">>>>>>>>>>9"
    field reg       as   int               format ">>>>>>>>>>9" 
    index idx is unique primary wms asc.
       
def temp-table tt-abastransf no-undo
    field wms       like abastransf.wms
    field etbcod    like abastransf.etbcod
    field abtcod    like abastransf.abtcod
            index idx is unique primary wms asc etbcod asc abtcod asc.



    
def var vconta as int.
def var vlinha as char.

def var vhora as int.
def var vminu as int.
def var vdeletaarquivo as log.

    for each tt-abastransf.
        delete tt-abastransf.
    end.
        
    find abastipo where abastipo.abatipo = "NEO" no-lock.

    for each ttarq where ttarq.interface = "XD*lin_ped_liberado" and /* Esta interface */
                         ttarq.arq <> "".

        vDeletaArquivo = yes.

            vconta = 0. 
            input from value(ttarq.arq) no-echo.
            repeat.
                vconta = vconta + 1.
                
                create tt-transf.
                import delimiter ";" tt-transf.

                find first abastransf where
                        abastransf.abatipo      = abastipo.abatipo and
                        abastransf.pedexterno   = tt-transf.pedido
                        no-lock no-error.
                if avail abastransf
                then do:
                    delete tt-transf.
                    next.
                end.
                /*#1*/
                if date(int(substring(tt-transf.dtprog,5,2)),
                        int(substring(tt-transf.dtprog,7,2)),
                        int(substring(tt-transf.dtprog,1,4))) < today
                then do:
                    delete tt-transf.
                    next.
                end.                        

                run abas/transfcreate.p (abastipo.abatipo, 
                             int(tt-transf.etbcod),
                             int(tt-transf.procod),
                             int(replace(tt-transf.qtd,",",".")),
                             "",
                             date(int(substring(tt-transf.dtprog,5,2)),
                                        int(substring(tt-transf.dtprog,7,2)),
                                        int(substring(tt-transf.dtprog,1,4))),
                             "EXTERNO=" + tt-transf.pedido,  /* ORIGEM DIGITADO,MOVIM,EXTERNO*/
                             "Importacao Neogrid",
                             output pabtcod).
                find abastransf where 
                        abastransf.etbcod = int(tt-transf.etbcod) and
                        abastransf.abtcod = pabtcod
                    no-lock no-error.
                if avail abastransf
                then do:
                    create tt-abastransf.
                    tt-abastransf.wms = abastransf.wms. 
                    tt-abastransf.etbcod = abastransf.etbcod. 
                    tt-abastransf.abtcod = abastransf.abtcod.
                end.
                           
                                    
                delete tt-transf.                                
            end.
            input close.

        if vDeletaArquivo
        then do:
            unix silent value("mv -f " + ttarq.arq + " " + 
                                ttarq.diretorio + "/" + "OK_" + ttarq.arquivo).
            
            run gera-email.
        end.
    end.              


procedure gera-email.
    def var varqmail as char.
    def var vassunto as char.
    def var varquivo as char.
    def var vdestino as char format "x(50)".

    pause 0 before-hide.

     
    for each tt-wms.
        delete tt-wms.
    end.

    for each tt-abastransf no-lock.
        find abastransf where abastransf.etbcod = tt-abastransf.etbcod and
                abastransf.abtcod = tt-abastransf.abtcod 
                no-lock.
        find first tt-wms where tt-wms.wms = abastransf.wms no-error. 
        if not avail tt-wms
        then do:
            create tt-wms.
            tt-wms.wms = abastransf.wms.
        end.
        tt-wms.qtd = tt-wms.qtd + abastransf.abtqtd.
        tt-wms.reg = tt-wms.reg + 1.
    end.
    
    for each tt-wms:
 
        vdestino = "michele.michelsen@lebes.com.br;helio.alves@lebes.com.br".
    
        if tt-wms.wms = "ALCIS_MODA"
        then vdestino = "transferencias.moda@lebes.com.br;" + vdestino.
        if tt-wms.wms = "ALCIS_MOVEIS"
        then vdestino = "transferencias.moveis@lebes.com.br;" + vdestino.
        
        vassunto = "IMPORTACAO NEOGRID - TRANSFERENCIAS " + tt-wms.wms +
                   "      ..." 
                + string(today,"999999") + replace(string(time,"HH:MM:SS"),":","").

        varquivo = "/admcom/relat/impneogridtransf_" +  trim(tt-wms.wms) +
                    string(today,"999999") + 
                    replace(string(time,"HH:MM"),":","") + ".txt".

        output to value(varquivo).
    
        put unformatted skip 
        "<HTML>" skip
        "    <meta charset=\"utf-8\">" skip
        "<h1>" vassunto "</h1>" skip.
 
        put unformatted
            "<h2>" " Quantidade de Produtos Importada = " string(tt-wms.qtd,">>>>>>>>") "</h2>" skip
            "<h2>" " Quantidade de registros          = " string(tt-wms.reg,">>>>>>>>") "</h2>" skip.

        put unformatted
            "<PRE>" skip.

        for each tt-abastransf where tt-abastransf.wms = tt-wms.wms no-lock
            break by tt-abastransf.etbcod
                with width 200.

            find abastransf where abastransf.etbcod = tt-abastransf.etbcod and
                    abastransf.abtcod = tt-abastransf.abtcod 
                    no-lock.
            find produ of abastransf no-lock.

            disp  
                abastransf.etbcod .
            disp abastransf.pedexterno when abastransf.pedexterno <> ?. 
            disp  abastransf.procod produ.pronom.
        
            disp "|". 
            disp   abastransf.dttransf format "999999"
                abastransf.abatipo 
                abastransf.abtcod column-label "Pedido"
                abastransf.abtsit.      .
            disp abastransf.abtqtd column-label "QTD!PEDIDO" format ">>>>>9"
                (total count by tt-abastransf.etbcod).
            disp "|".
        end.
    
        put skip fill("_",120) format "x(120)" skip.

        put unformatted 
            "</HTML>".
    
        output close.

                assign
                    varqmail = "/admcom/progr/mail.sh " +
                        " ~"" + vassunto + "~"" +
                        " ~"" + varquivo + "~"" +
                        " ~"" + vdestino + "~"" +
                        " ~"" + vdestino + "~"" +
                        " ~"text/html~" 2>&1 " +
                        " >" + varquivo + "x.txt". 
                    unix silent value(varqmail).
    
    end.
    

end procedure.


