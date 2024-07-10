/***
connect ninja -H 10.2.0.29 -S 60002 -N tcp.
connect sensei -H 10.2.0.29 -S 60000 -N tcp.
connect nissei -H 10.2.0.29 -S 60001 -N tcp.
****/

{admcab.i new}
{retorna-pacnv.i new} 

message "v0119". pause.

def temp-table tt-movim like movim.
def temp-table tt-plani
    field emite like plani.emite
        field numero like plani.numero
            field serie like plani.serie
                field valor as dec
                    field cfop as char
                        field marca as char
                            index i1 emite serie numero
                                 .
     
def var vtotal-plani as dec format ">>>,>>>,>>9.99".
def var vtotal-pag like titulo.titvlpag.
def var vtit-vlpag like titulo.titvlpag.
def var vtit-vljur like titulo.titjuro.
def var vpaga-principal like titulo.titvlpag.
def var vpaga-acrescimo like titulo.titvlpag.
def var vpaga-juro like titulo.titvlpag.

def temp-table tt-contrato no-undo
    field etbcod  like estab.etbcod
    field contnum like contrato.contnum
    field dtinicial like contrato.dtinicial
    field vltotal like contrato.vltotal
    field vlentra like contrato.vlentra
    field vlvenda like contrato.vltotal
    field srvenda like contrato.vlseguro
    field emite   like plani.emite
    field serie   like plani.serie
    field numero  like plani.numero
    field certifi like vndseguro.certifi
    index i1 etbcod contnum.

def temp-table tt-moetit
    field moecod like moeda.moecod
    field moenom like moeda.moenom
    field valor  like titulo.titvlpag
    .

def var vt as dec format ">>>,>>>,>>9.99".
def temp-table fc-contrato like fin.contrato.
def temp-table tt-valores like opctbval /*opctbvt19*/.
def temp-table tt-titpag like titulo.
def temp-table tt-titdev like titulo.

def temp-table pag-titulo no-undo
    field clifor like titulo.clifor
    field titnum like titulo.titnum
    field titpar like titulo.titpar
    field titvlcob like titulo.titvlcob
    field titvlpag like titulo.titvlpag
    index i1 clifor titnum titpar
    .              
def temp-table pag-titmoe no-undo
    field clifor like titulo.clifor
    field titnum like titulo.titnum
    field titpar like titulo.titpar
    field moecod like titulo.moecod
    field titvlpag like titulo.titvlpag
    index i1 clifor titnum titpar
    .


def var p-1 as char.
def var p-2 as char.
def var p-3 as char.
def var p-4 as char.
def var p-5 as char.
def var p-6 as char.
def var p-7 as char.
def var p-8 as char.
def var p-9 as char.
def var p-0 as char.

def var venda-total as dec format ">>>,>>>,>>9.99".
def var vtotal as dec format ">>>,>>>,>>9.99".
def var ventra as dec format ">>>,>>>,>>9.99".
def var vtotal-contrato as dec format ">>>,>>>,>>9.99".
def var ventra-contrato as dec format ">>>,>>>,>>9.99".
def var vtotal-venda as dec format ">>>,>>>,>>9.99".

def var vcobcod as int.

def var vdata as date.
def new shared var vdti as date .
def new shared var vdtf as date .
def var vetbcod like estab.etbcod.

def var vendap-fiscal as dec.

def buffer ctitulo for titulo.

def temp-table tt-datap
    field pladat as date
    field conta  as int
    field contrato as dec
    field nfvenda as int
    field dtvenda as date
    field nfdevol as int
    field valquitado as dec
    field valdevolvido as dec.
    
def var ventrada as dec.
def var vsaida as dec.
def var vorigem as dec.
def buffer bplani for plani.
def buffer cplani for plani.
def buffer bmovim for movim.
def buffer cmovim for movim.
def var vtitdev as dec.
def var vtitpag as dec.
def var vvista as dec.
def var vprazo as dec.
def var vclifor as int.
def var vcontrato like contnf.contnum.
def var vconta-plani as integer.
def var tot-qtd-plani as integer.

def temp-table tt-plaqtd
    field placod like plani.placod.

def var vok-moveis as log .

/*************************/

procedure reinicia-variaveis:
    assign
        p-1 = ""
        p-2 = ""
        p-3 = ""
        p-4 = ""
        p-5 = ""
        p-6 = ""
        p-7 = ""
        p-8 = ""
        p-9 = ""
        p-0 = ""
        .
end procedure.

def var val-fal as dec.
def var vendap-outras as dec.
def var vendap-servico as dec. 
def var vendap-seguro as dec.

update vetbcod at 7 label "Filial"
       with frame f1 width 80 side-label
       title " GERA BASE DE DADOS " .
if vetbcod > 0
then do:
    find estab where estab.etbcod = vetbcod no-lock no-error.
    if avail estab
    then disp estab.etbnom no-label with frame f1.
    else undo.
end.
else disp "Todas as filiais" @ estab.etbnom with frame f1.
       
update vdti at 1 label "Data inicial"
       vdtf label "Data final"
       with frame f1.
  
def var varquivo-pl as char.
varquivo-pl = "/admcom/TI/claudir/tt-plani-marca"
                   + string(vdti,"99999999") + string(vdtf,"99999999")
                               + ".d".
                            
if search(varquivo-pl) <> ?
then do:                               
input from value(varquivo-pl).
repeat:
    create tt-plani.
    import tt-plani.
end.
input close.
   
for each tt-plani where tt-plani.marca = "".
    delete tt-plani.
end. 
end.

def var vtotal-cnt as dec format ">>>,>>>,>>9.99".
def var vemite like plani.emite.

def temp-table ctb-venda like ctbvenda .
def temp-table ctb-contrato like ctbcontrato .
def temp-table ctb-recebe like ctbrecebe .

def var vcrecod like plani.crecod.
def var vdif-mais as dec.
def var vdif-menos as dec.
def var vchave as char.
def var vindex as int.
def var vesco as char extent 4 format "x(20)".
vesco[1] = "GERAL".
vesco[2] = "VENDAS/CONTRATOS".
vesco[3] = "RECEBIMENTO".

disp vesco with frame f-esco 1 down no-label side-label
        centered width 80 title " escolha a tipo de processamento "
        1 column.
choose field vesco with frame f-esco.
vindex = frame-index.

def var vtipo-venda as char.

sresp = no.
message "Confirma processamento " vesco[vindex] "?" update sresp.
if not sresp then undo.

for each estab where (if vetbcod > 0 then estab.etbcod = vetbcod
                       else true) no-lock:
    disp estab.etbcod with frame ff side-label 1 down.
    pause 0.
    for each tt-valores: delete tt-valores. end.

    do vdata = vdti to vdtf:
        disp vdata label "Data" 
             string(time,"hh:mm:ss") no-label
        with frame fff down side-label column 30. pause 0.
        down with fram fff.
          
        for each tt-contrato: delete tt-contrato. end.
        
        for each ctb-venda: delete ctb-venda. end.
        for each ctb-contrato: delete ctb-contrato. end.
        for each ctb-recebe: delete ctb-recebe. end.
        
        assign
            vtotal-contrato = 0
            ventra-contrato = 0
            .
        
        
        if vindex = 1 or vindex = 2
        then do:

        for each plani where plani.etbcod  = estab.etbcod and
                             plani.movtdc  = 5 and
                             plani.pladat  = vdata 
                             no-lock:
        
            if plani.modcod = "CAN" then next.
            
            if  month(plani.pladat) <> month(plani.datexp) and
                plani.datexp - plani.pladat > 10
            then next.
            
            assign
                vendap-fiscal  = 0
                vendap-outras  = 0
                vendap-servico = 0
                vendap-seguro  = 0
                vchave = ""
                vemite = plani.emite
                .
            
            if plani.serie = "PEDO"
            then vtipo-venda = "VENDA OUTRA LOJA".
            else vtipo-venda = "VENDA LOJA".
             
            find first tt-plani where
                       tt-plani.emite = plani.emite and
                       tt-plani.serie = plani.serie and
                       tt-plani.numero = plani.numero
                       no-error.
                       
            for each movim where movim.etbcod = plani.etbcod and
                                 movim.placod = plani.placod and
                                 movim.movtdc = plani.movtdc and
                                 movim.movdat = plani.pladat
                                 no-lock:
                find produ where produ.procod = movim.procod
                                            no-lock no-error.
                
                if not avail produ then next.
                
                if produ.proipiper = 98 
                then do:
                    run cria-temp-venda(input "VENDA",
                                        input 35,
                                        input ?, /*opfcod*/
                                        input ?, /*emite*/
                                        input ?, /*serie*/
                                        input ?, /*numero*/
                                        input plani.crecod, /*crecod*/
                                        input ?, /*chave*/
                                        input produ.pronom,
                                        input 0,
                                        input (movim.movpc * movim.movqtm),
                                        input 0,
                                        input vtipo-venda).
                    vendap-servico = vendap-servico +
                                     (movim.movpc * movim.movqtm).

                    if produ.procod = 8011 or
                       produ.procod = 8012 or
                       produ.procod = 8013 or
                       produ.procod = 8014 or
                       produ.procod = 8015 or
                       produ.procod = 559910 or
                       produ.procod = 559911 or
                       produ.procod = 569131 or
                       produ.procod = 578790 or
                       produ.procod = 579359 
                    then vendap-seguro  = vendap-seguro +
                                     (movim.movpc * movim.movqtm).

                end.
                else if produ.pronom matches "*RECARGA*" 
                then do:
                    run cria-temp-venda(input "VENDA",
                                        input 35,
                                        input ?, /*opfcod*/
                                        input ?, /*emite*/
                                        input ?, /*serie*/
                                        input ?, /*numero*/
                                        input plani.crecod, /*crecod*/
                                        input ?, /*chave*/
                                        input "RECARGA",
                                        input 0,
                                        input (movim.movpc * movim.movqtm),
                                        input 0,
                                        input vtipo-venda).
                    vendap-servico = vendap-servico +
                            (movim.movpc * movim.movqtm).
                                    
                end.
                else if produ.pronom matches "*CARTAO PRESENTE*"
                then do:
                    run cria-temp-venda(input "VENDA",
                                        input 35,
                                        input ?, /*opfcod*/
                                        input ?, /*emite*/
                                        input ?, /*serie*/
                                        input ?, /*numero*/
                                        input plani.crecod, /*crecod*/
                                        input ?, /*chave*/
                                        input produ.pronom,
                                        input 0,
                                        input (movim.movpc * movim.movqtm),
                                        input 0,
                                        input vtipo-venda).
                    vendap-servico = vendap-servico +
                            (movim.movpc * movim.movqtm).
                end.
                else if produ.pronom matches "*FRETEIRO*" 
                    and avail tt-plani
                then do:
                    run cria-temp-venda(input "VENDA",
                                        input 35,
                                        input ?, /*opfcod*/
                                        input ?, /*emite*/
                                        input ?, /*serie*/
                                        input ?, /*numero*/
                                        input plani.crecod, /*crecod*/
                                        input ?, /*chave*/
                                        input "FRETEIRO",
                                        input 0,
                                        input (movim.movpc * movim.movqtm),
                                        input 0,
                                        input vtipo-venda).
                    vendap-servico = vendap-servico +
                            (movim.movpc * movim.movqtm).
                end.
                else do:
                    if (substr(plani.notped,1,1) = "C" and
                       (plani.ufemi <> "" or
                        (plani.ufdes <> "" and
                         plani.ufdes <> "C"))) or
                         plani.etbcod = 200
                    then do: 
                        if plani.ufdes = "" or
                           length(plani.ufdes) <> 44
                        then do:
                            find a01_infnfe where 
                                 a01_infnfe.emite = vemite and
                                 a01_infnfe.serie = plani.serie and
                                 a01_infnfe.numero = plani.numero
                                 no-lock no-error.
                            if avail a01_infnfe and
                               length(a01_infnfe.id) = 44
                            then do:
                                vendap-fiscal = vendap-fiscal +
                                        (movim.movpc * movim.movqtm).
                                vchave = a01_infnfe.id.
                            end.
                            else if length(plani.ufemi) = 20
                            then do:
                                vendap-fiscal = vendap-fiscal +
                                        (movim.movpc * movim.movqtm).
                            end. 
                            else vendap-outras = vendap-outras +
                                            (movim.movpc * movim.movqtm).
                        end.
                        else if plani.ufdes <> "" and
                            length(plani.ufdes) = 44
                            then do:
                            /*find a01_infnfe where 
                                 a01_infnfe.emite = vemite and
                                 a01_infnfe.serie = plani.serie and
                                 a01_infnfe.numero = plani.numero
                                 no-lock no-error.
                            if avail a01_infnfe or plani.etbcod = 200
                            then do: */
                                vendap-fiscal = vendap-fiscal +
                                        (movim.movpc * movim.movqtm).
                                vchave = plani.ufdes.
                            
                            end.
                            else vendap-outras = vendap-outras +
                                        (movim.movpc * movim.movqtm).
                    end.
                    else do:
                        vendap-outras = vendap-outras +
                                        (movim.movpc * movim.movqtm).
                    end.                    
                end. 
            end.
            if plani.frete > 0 or plani.outras > 0
            then vendap-fiscal = vendap-fiscal + plani.frete + plani.outras.   
            vdif-mais = 0.
            vdif-menos = 0.
            if  vendap-servico > 0 and
                (vendap-fiscal + vendap-servico + vendap-outras) > plani.platot 
            then do:
                assign
                    vdif-menos = 
              ((vendap-fiscal + vendap-servico + vendap-outras) - plani.platot)
                vendap-servico = vendap-servico - vdif-menos.

                find first ctb-venda where ctb-venda.tipo = "VENDA" and
                        ctb-venda.tipovenda = "VENDA LOJA" and
                        ctb-venda.datref = vdata and
                        ctb-venda.etbcod = estab.etbcod and
                        ctb-venda.movseq = 35 and
                        ctb-venda.crecod = plani.crecod
                        no-error.
                if avail ctb-venda 
                then ctb-venda.servico = ctb-venda.servico - vdif-menos.
            end.
            else if  vendap-servico > 0 and
                (vendap-fiscal + vendap-servico + vendap-outras) < plani.platot 
            then do:
                assign
                vdif-mais = 
              (plani.platot - (vendap-fiscal + vendap-servico + vendap-outras))
                vendap-servico = vendap-servico + vdif-mais.
                find first ctb-venda where ctb-venda.tipo = "VENDA" and
                        ctb-venda.tipovenda = "VENDA LOJA" and
                        ctb-venda.datref = vdata and
                        ctb-venda.etbcod = estab.etbcod and
                        ctb-venda.movseq = 35 and
                        ctb-venda.crecod = plani.crecod
                        no-error.
                if avail ctb-venda 
                then ctb-venda.servico = ctb-venda.servico + vdif-mais.
            end.

            run cria-temp-venda(input "VENDA",
                                input 20,
                                input ?, /*opfcod*/
                                input ?, /*emite*/
                                input ?, /*serie*/
                                input ?, /*numero*/
                                input ?, /*crecod*/
                                input ?, /*chave*/
                                input "VENDA TOTAL",
                                input vendap-fiscal,
                                input vendap-servico,
                                input vendap-outras,
                                input vtipo-venda).
            run cria-temp-venda(input "VENDA",
                                input 30,
                                input ?, /*opfcod*/
                                input ?, /*emite*/
                                input ?, /*serie*/
                                input ?, /*numero*/
                                input plani.crecod, /*crecod*/
                                input ?, /*chave*/
                                input "VENDA TOTAL",
                                input vendap-fiscal,
                                input vendap-servico,
                                input vendap-outras,
                                input vtipo-venda).
            run cria-temp-venda(input "VENDA",
                                input 40,
                                input ?, /*opfcod*/
                                input plani.emite, /*emite*/
                                input plani.serie, /*serie*/
                                input plani.numero, /*numero*/
                                input plani.crecod, /*crecod*/
                                input vchave, /*chave*/
                                input "VENDA TOTAL",
                                input vendap-fiscal,
                                input vendap-servico,
                                input vendap-outras,
                                input vtipo-venda).

        end.
        for each plani where plani.etbcod  = estab.etbcod and
                             plani.movtdc  = 81 and
                             plani.pladat  = vdata 
                             no-lock:
        
            if plani.modcod = "CAN" then next.

            assign
                vendap-fiscal  = 0
                vendap-outras  = 0
                vendap-servico = 0
                vchave = ""
                vemite = plani.emite
                vtipo-venda = "VENDA RETIRADA"
                .
                
            find first tt-plani where
                       tt-plani.emite = plani.emite and
                       tt-plani.serie = plani.serie and
                       tt-plani.numero = plani.numero
                       no-error.

            vcrecod = plani.crecod.
            find last bplani where bplani.movtdc = 5 and
                            bplani.desti = plani.desti and
                            bplani.pladat <= plani.pladat and
                            bplani.etbcod <> plani.etbcod and
                            bplani.serie = "PEDO"
                            no-lock no-error.
            if avail bplani
            then vcrecod = bplani.crecod.

            for each movim where movim.etbcod = plani.etbcod and
                                 movim.placod = plani.placod and
                                 movim.movtdc = plani.movtdc and
                                 movim.movdat = plani.pladat
                                 no-lock:
                find produ where produ.procod = movim.procod
                                            no-lock no-error.
                
                if not avail produ then next.
                
                if produ.proipiper = 98 
                then do:
                    run cria-temp-venda(input "VENDA",
                                        input 35,
                                        input ?, /*opfcod*/
                                        input ?, /*emite*/
                                        input ?, /*serie*/
                                        input ?, /*numero*/
                                        input vcrecod, /*crecod*/
                                        input ?, /*chave*/
                                        input produ.pronom,
                                        input 0,
                                        input (movim.movpc * movim.movqtm),
                                        input 0,
                                        input vtipo-venda).
                    vendap-servico = vendap-servico +
                                     (movim.movpc * movim.movqtm).
                end.
                else if produ.pronom matches "*RECARGA*" 
                then do:
                    run cria-temp-venda(input "VENDA",
                                        input 35,
                                        input ?, /*opfcod*/
                                        input ?, /*emite*/
                                        input ?, /*serie*/
                                        input ?, /*numero*/
                                        input vcrecod, /*crecod*/
                                        input ?, /*chave*/
                                        input "RECARGA",
                                        input 0,
                                        input (movim.movpc * movim.movqtm),
                                        input 0,
                                        input vtipo-venda).
                    vendap-servico = vendap-servico +
                            (movim.movpc * movim.movqtm).
                                    
                end.
                else if produ.pronom matches "*CARTAO PRESENTE*"
                then do:
                    run cria-temp-venda(input "VENDA",
                                        input 35,
                                        input ?, /*opfcod*/
                                        input ?, /*emite*/
                                        input ?, /*serie*/
                                        input ?, /*numero*/
                                        input vcrecod, /*crecod*/
                                        input ?, /*chave*/
                                        input produ.pronom,
                                        input 0,
                                        input (movim.movpc * movim.movqtm),
                                        input 0,
                                        input vtipo-venda).
                    vendap-servico = vendap-servico +
                            (movim.movpc * movim.movqtm).
                end.
                else if produ.pronom matches "*FRETEIRO*"
                        and avail tt-plani
                then do:
                    run cria-temp-venda(input "VENDA",
                                        input 35,
                                        input ?, /*opfcod*/
                                        input ?, /*emite*/
                                        input ?, /*serie*/
                                        input ?, /*numero*/
                                        input vcrecod, /*crecod*/
                                        input ?, /*chave*/
                                        input "FRETEIRO",
                                        input 0,
                                        input (movim.movpc * movim.movqtm),
                                        input 0,
                                        input vtipo-venda).
                    vendap-servico = vendap-servico +
                            (movim.movpc * movim.movqtm).
                end.
                else do:
                    if (substr(plani.notped,1,1) = "C" and
                       (plani.ufemi <> "" or
                        (plani.ufdes <> "" and
                         plani.ufdes <> "C"))) or
                         plani.etbcod = 200
                    then do: 
                        if plani.ufdes = "" or 
                            length(plani.ufdes) <> 44
                        then do:
                            find a01_infnfe where 
                                 a01_infnfe.emite = vemite and
                                 a01_infnfe.serie = plani.serie and
                                 a01_infnfe.numero = plani.numero
                                 no-lock no-error.
                            if avail a01_infnfe and
                               length(a01_infnfe.id) = 44
                            then do:
                                vendap-fiscal = vendap-fiscal +
                                        (movim.movpc * movim.movqtm).
                                vchave = a01_infnfe.id.
                            end.
                            else if avail a01_infnfe
                                then vendap-outras = vendap-outras +
                                            (movim.movpc * movim.movqtm).
                        end.
                        else do: 
                                vendap-fiscal = vendap-fiscal +
                                        (movim.movpc * movim.movqtm).
                                vchave = plani.ufdes.
                        end.
                    end.
                    else do:
                        vendap-outras = vendap-outras +
                                        (movim.movpc * movim.movqtm).
                    end.                    
                end. 
            end.
            if plani.frete > 0 or plani.outras > 0
            then vendap-fiscal = vendap-fiscal + plani.frete + plani.outras.
             
            run cria-temp-venda(input "VENDA",
                                input 20,
                                input ?, /*opfcod*/
                                input ?, /*emite*/
                                input ?, /*serie*/
                                input ?, /*numero*/
                                input ?, /*crecod*/
                                input ?, /*chave*/
                                input "VENDA TOTAL",
                                input vendap-fiscal,
                                input vendap-servico,
                                input vendap-outras,
                                input vtipo-venda).
            
            run cria-temp-venda(input "VENDA",
                                input 30,
                                input ?, /*opfcod*/
                                input ?, /*emite*/
                                input ?, /*serie*/
                                input ?, /*numero*/
                                input vcrecod, /*crecod*/
                                input ?, /*chave*/
                                input "VENDA TOTAL",
                                input vendap-fiscal,
                                input vendap-servico,
                                input vendap-outras,
                                input vtipo-venda).
            
            run cria-temp-venda(input "VENDA",
                                input 40,
                                input ?, /*opfcod*/
                                input plani.emite, /*emite*/
                                input plani.serie, /*serie*/
                                input plani.numero, /*numero*/
                                input vcrecod, /*crecod*/
                                input vchave, /*chave*/
                                input "VENDA TOTAL",
                                input vendap-fiscal,
                                input vendap-servico,
                                input vendap-outras,
                                input vtipo-venda).

        end.
        for each plani where plani.etbcod  = estab.etbcod and
                             plani.movtdc  = 46 and
                             plani.pladat  = vdata 
                             no-lock:
        
            if plani.modcod = "CAN" then next.

            if plani.etbcod = 998 
            then vemite = 993.
            else vemite = plani.emite. 
 
            assign
                vendap-fiscal  = 0
                vendap-outras  = 0
                vendap-servico = 0
                vchave = ""
                vtipo-venda = "VENDA LOJA"
                .
            
            for each movim where movim.etbcod = plani.etbcod and
                                 movim.placod = plani.placod and
                                 movim.movtdc = plani.movtdc and
                                 movim.movdat = plani.pladat
                                 no-lock:
                find produ where produ.procod = movim.procod
                                            no-lock no-error.
                
                if not avail produ then next.
                
                if produ.proipiper = 98 
                then do:
                    run cria-temp-venda(input "VENDA",
                                        input 35,
                                        input ?, /*opfcod*/
                                        input ?, /*emite*/
                                        input ?, /*serie*/
                                        input ?, /*numero*/
                                        input plani.crecod, /*crecod*/
                                        input ?, /*chave*/
                                        input produ.pronom,
                                        input 0,
                                        input (movim.movpc * movim.movqtm),
                                        input 0,
                                        input vtipo-venda).
                    vendap-servico = vendap-servico +
                                     (movim.movpc * movim.movqtm).
                end.
                else if produ.pronom matches "*RECARGA*" 
                then do:
                    run cria-temp-venda(input "VENDA",
                                        input 35,
                                        input ?, /*opfcod*/
                                        input ?, /*emite*/
                                        input ?, /*serie*/
                                        input ?, /*numero*/
                                        input plani.crecod, /*crecod*/
                                        input ?, /*chave*/
                                        input "RECARGA",
                                        input 0,
                                        input (movim.movpc * movim.movqtm),
                                        input 0,
                                        input vtipo-venda).
                    vendap-servico = vendap-servico +
                            (movim.movpc * movim.movqtm).
                                    
                end.
                else if produ.pronom matches "*CARTAO PRESENTE*"
                then do:
                    run cria-temp-venda(input "VENDA",
                                        input 35,
                                        input ?, /*opfcod*/
                                        input ?, /*emite*/
                                        input ?, /*serie*/
                                        input ?, /*numero*/
                                        input plani.crecod, /*crecod*/
                                        input ?, /*chave*/
                                        input produ.pronom,
                                        input 0,
                                        input (movim.movpc * movim.movqtm),
                                        input 0,
                                        input vtipo-venda).
                    vendap-servico = vendap-servico +
                            (movim.movpc * movim.movqtm).
                end.
                else do:
                    if (substr(plani.notped,1,1) = "C" and
                       (plani.ufemi <> "" or
                        (plani.ufdes <> "" and
                         plani.ufdes <> "C"))) 
                         or plani.etbcod = 200
                         or plani.movtdc = 46
                    then do: 
                        if plani.ufdes = "" or
                           length(plani.ufdes) <> 44
                        then do:
                            find a01_infnfe where 
                                 a01_infnfe.emite = vemite and
                                 a01_infnfe.serie = plani.serie and
                                 a01_infnfe.numero = plani.numero
                                 no-lock no-error.
                            if avail a01_infnfe and
                               length(a01_infnfe.id) = 44
                            then do:
                                vendap-fiscal = vendap-fiscal +
                                        (movim.movpc * movim.movqtm).
                                vchave = a01_infnfe.id.
                            end.
                            else if avail a01_infnfe
                                then vendap-outras = vendap-outras +
                                            (movim.movpc * movim.movqtm).
                        end.
                        else do: 
                            /*find a01_infnfe where 
                                 a01_infnfe.emite = vemite and
                                 a01_infnfe.serie = plani.serie and
                                 a01_infnfe.numero = plani.numero
                                 no-lock no-error.
                            if avail a01_infnfe
                            then do:*/
                                vendap-fiscal = vendap-fiscal +
                                        (movim.movpc * movim.movqtm).
                                vchave = plani.ufdes.
                            /*end.
                            else vendap-outras = vendap-outras +
                                        (movim.movpc * movim.movqtm).
                            */
                        end.
                    end.
                    else do:
                        vendap-outras = vendap-outras +
                                        (movim.movpc * movim.movqtm).
                    end.                    
                end. 
            end.
            if plani.frete > 0 or plani.outras > 0
            then vendap-fiscal = vendap-fiscal + plani.frete + plani.outras. 
            
            run cria-temp-venda(input "VENDA",    
                                input 20,
                                input ?, /*opfcod*/
                                input ?, /*emite*/
                                input ?, /*serie*/
                                input ?, /*numero*/
                                input ?, /*crecod*/
                                input ?, /*chave*/
                                input "VENDA TOTAL",
                                input vendap-fiscal,
                                input vendap-servico,
                                input vendap-outras,
                                input vtipo-venda).
            run cria-temp-venda(input "VENDA",    
                                input 30,
                                input ?, /*opfcod*/
                                input ?, /*emite*/
                                input ?, /*serie*/
                                input ?, /*numero*/
                                input plani.crecod, /*crecod*/
                                input ?, /*chave*/
                                input "VENDA TOTAL",
                                input vendap-fiscal,
                                input vendap-servico,
                                input vendap-outras,
                                input vtipo-venda).
            run cria-temp-venda(input "VENDA",
                                input 40,
                                input ?, /*opfcod*/
                                input vemite, /*emite*/
                                input plani.serie, /*serie*/
                                input plani.numero, /*numero*/
                                input plani.crecod, /*crecod*/
                                input vchave, /*chave*/
                                input "VENDA TOTAL",
                                input vendap-fiscal,
                                input vendap-servico,
                                input vendap-outras,
                                input vtipo-venda).

        end.
        for each plani where plani.etbcod  = estab.etbcod and
                             plani.movtdc  = 26 and
                             plani.pladat  = vdata 
                             no-lock:
        
            if plani.modcod = "CAN" then next.

            if plani.etbcod = 998 
            then vemite = 993.
            else vemite = plani.emite. 
 
            assign
                vendap-fiscal  = 0
                vendap-outras  = 0
                vendap-servico = 0
                vchave = ""
                vtipo-venda = "VENDA LOJA"
                .
            
            for each movim where movim.etbcod = plani.etbcod and
                                 movim.placod = plani.placod and
                                 movim.movtdc = plani.movtdc and
                                 movim.movdat = plani.pladat and
                                 movim.opfcod = 5101
                                 no-lock:
                find produ where produ.procod = movim.procod
                                            no-lock no-error.
                
                if not avail produ then next.
                
                if produ.proipiper = 98 
                then do:
                    run cria-temp-venda(input "VENDA",
                                        input 35,
                                        input ?, /*opfcod*/
                                        input ?, /*emite*/
                                        input ?, /*serie*/
                                        input ?, /*numero*/
                                        input plani.crecod, /*crecod*/
                                        input ?, /*chave*/
                                        input produ.pronom,
                                        input 0,
                                        input (movim.movpc * movim.movqtm),
                                        input 0,
                                        input vtipo-venda).
                    vendap-servico = vendap-servico +
                                     (movim.movpc * movim.movqtm).
                end.
                else if produ.pronom matches "*RECARGA*" 
                then do:
                    run cria-temp-venda(input "VENDA",
                                        input 35,
                                        input ?, /*opfcod*/
                                        input ?, /*emite*/
                                        input ?, /*serie*/
                                        input ?, /*numero*/
                                        input plani.crecod, /*crecod*/
                                        input ?, /*chave*/
                                        input "RECARGA",
                                        input 0,
                                        input (movim.movpc * movim.movqtm),
                                        input 0,
                                        input vtipo-venda).
                    vendap-servico = vendap-servico +
                            (movim.movpc * movim.movqtm).
                                    
                end.
                else if produ.pronom matches "*CARTAO PRESENTE*"
                then do:
                    run cria-temp-venda(input "VENDA",
                                        input 35,
                                        input ?, /*opfcod*/
                                        input ?, /*emite*/
                                        input ?, /*serie*/
                                        input ?, /*numero*/
                                        input plani.crecod, /*crecod*/
                                        input ?, /*chave*/
                                        input produ.pronom,
                                        input 0,
                                        input (movim.movpc * movim.movqtm),
                                        input 0,
                                        input vtipo-venda).
                    vendap-servico = vendap-servico +
                            (movim.movpc * movim.movqtm).
                end.
                else do:
                    if (substr(plani.notped,1,1) = "C" and
                       (plani.ufemi <> "" or
                        (plani.ufdes <> "" and
                         plani.ufdes <> "C"))) 
                         or plani.etbcod = 200
                         or plani.movtdc = 26
                    then do: 
                        if plani.ufdes = "" or
                           length(plani.ufdes) <> 44
                        then do:
                            find a01_infnfe where 
                                 a01_infnfe.emite = vemite and
                                 a01_infnfe.serie = plani.serie and
                                 a01_infnfe.numero = plani.numero
                                 no-lock no-error.
                            if avail a01_infnfe and
                               length(a01_infnfe.id) = 44
                            then do:
                                vendap-fiscal = vendap-fiscal +
                                        (movim.movpc * movim.movqtm).
                                vchave = a01_infnfe.id.
                            end.
                            else if avail a01_infnfe
                                then vendap-outras = vendap-outras +
                                            (movim.movpc * movim.movqtm).
                        end.
                        else do: 
                            /*find a01_infnfe where 
                                 a01_infnfe.emite = vemite and
                                 a01_infnfe.serie = plani.serie and
                                 a01_infnfe.numero = plani.numero
                                 no-lock no-error.
                            if avail a01_infnfe
                            then do:*/
                                vendap-fiscal = vendap-fiscal +
                                        (movim.movpc * movim.movqtm).
                                vchave = plani.ufdes.
                            /*end.
                            else vendap-outras = vendap-outras +
                                        (movim.movpc * movim.movqtm).
                            */
                        end.
                    end.
                    else do:
                        vendap-outras = vendap-outras +
                                        (movim.movpc * movim.movqtm).
                    end.                    
                end. 
            end.
            if plani.frete > 0 or plani.outras > 0
            then vendap-fiscal = vendap-fiscal + plani.frete + plani.outras. 
            
            run cria-temp-venda(input "VENDA",    
                                input 20,
                                input ?, /*opfcod*/
                                input ?, /*emite*/
                                input ?, /*serie*/
                                input ?, /*numero*/
                                input ?, /*crecod*/
                                input ?, /*chave*/
                                input "VENDA TOTAL",
                                input vendap-fiscal,
                                input vendap-servico,
                                input vendap-outras,
                                input vtipo-venda).
            run cria-temp-venda(input "VENDA",    
                                input 30,
                                input ?, /*opfcod*/
                                input ?, /*emite*/
                                input ?, /*serie*/
                                input ?, /*numero*/
                                input plani.crecod, /*crecod*/
                                input ?, /*chave*/
                                input "VENDA TOTAL",
                                input vendap-fiscal,
                                input vendap-servico,
                                input vendap-outras,
                                input vtipo-venda).
            run cria-temp-venda(input "VENDA",
                                input 40,
                                input ?, /*opfcod*/
                                input vemite, /*emite*/
                                input plani.serie, /*serie*/
                                input plani.numero, /*numero*/
                                input plani.crecod, /*crecod*/
                                input vchave, /*chave*/
                                input "VENDA TOTAL",
                                input vendap-fiscal,
                                input vendap-servico,
                                input vendap-outras,
                                input vtipo-venda).

        end.
    
        run devolucao-venda.
        
        end.
        /*
        output to /admcom/relat/teste.cl.
        for each tt-contrato.
        export tt-contrato.
        end.
        output close.
        */
        
        if vindex = 1 or vindex = 2
        then do:
            for each tt-contrato where tt-contrato.contnum > 0 no-lock,
                first   contrato where 
                        contrato.contnum = tt-contrato.contnum no-lock:
                if contrato.banco = 10
                then do:
                    find last envfinan where
                      envfinan.empcod = 19 and
                      envfinan.titnat = no and
                      envfinan.modcod = contrato.modcod and
                      envfinan.etbcod = contrato.etbcod and
                      envfinan.clifor = contrato.clicod and
                      envfinan.titnum = string(contrato.contnum)
                      no-lock no-error.
                    if avail envfinan and (envfinan.envsit = "INC" or
                                   envfinan.envsit = "PAG")
                    then vcobcod = 10.
                    else vcobcod = 2.
                end. 
                else if contrato.banco = 13
                then vcobcod = 10.
                else vcobcod = 2.
                     
                run /admcom/progr/retorna-pacnv-valores-contrato.p 
                    (input ?, 
                     input recid(contrato), 
                     input ?).
            
                if pacnv-seguro = ? then pacnv-seguro = 0.
                if pacnv-entrada = ? then pacnv-entrada = 0.
                if pacnv-principal = ? then pacnv-principal = 0.
                if pacnv-acrescimo = ? then pacnv-acrescimo = 0.
                if pacnv-orinf = ? then pacnv-orinf = 0.
                if pacnv-orinl = ? then pacnv-orinl = 0.
                if pacnv-abate = ? then pacnv-abate = 0.
            
                /*if contrato.vltotal <>
                    pacnv-entrada + pacnv-principal + pacnv-acrescimo
                then do:
                    disp contrato.contnum format ">>>,>>>,>>9.99".
                    pause.
                end.*/   
                
                if (pacnv-entrada + pacnv-principal + pacnv-acrescimo)
                    > contrato.vltotal
                then assign
                        pacnv-abate =
                        (pacnv-entrada + pacnv-principal + pacnv-acrescimo)
                        - contrato.vltotal
                        pacnv-principal = pacnv-principal - pacnv-abate
                        pacnv-acrescimo = 0
                        .      
                
                if pacnv-seguro <> tt-contrato.srvenda
                then pacnv-seguro = tt-contrato.srvenda.
                
                run cria-temp-contrato(input "CONTRATO",
                                input 0,
                                input ?, /*modcod*/
                                input ?, /*cobcod*/
                                input ?, /*contnum*/
                                input contrato.vltotal, 
                                input pacnv-entrada, 
                                input pacnv-principal, 
                                input pacnv-acrescimo,
                                input pacnv-seguro,
                                input pacnv-orinf + pacnv-orinl,
                                input pacnv-orinf,
                                input pacnv-orinl,
                                input pacnv-abate).
            
                    vtotal-contrato = vtotal-contrato +
                        (pacnv-principal + pacnv-entrada).
                    
                    run cria-temp-contrato(input "CONTRATO",
                                input 10,
                                input ?, /*modcod*/
                                input ?, /*cobcod*/
                                input ?, /*contnum*/
                                input contrato.vltotal, 
                                input pacnv-entrada, 
                                input pacnv-principal, 
                                input pacnv-acrescimo,
                                input pacnv-seguro,
                                input pacnv-orinf + pacnv-orinl,
                                input pacnv-orinf,
                                input pacnv-orinl,
                                input pacnv-abate).

                    run cria-temp-contrato(input "CONTRATO",
                                input 20,
                                input contrato.modcod, /*modcod*/
                                input ?, /*cobcod*/
                                input ?, /*contnum*/
                                input contrato.vltotal, 
                                input pacnv-entrada, 
                                input pacnv-principal, 
                                input pacnv-acrescimo,
                                input pacnv-seguro,
                                input pacnv-orinf + pacnv-orinl,
                                input pacnv-orinf,
                                input pacnv-orinl,
                                input pacnv-abate).
                    run cria-temp-contrato(input "CONTRATO",
                                input 30,
                                input contrato.modcod, /*modcod*/
                                input vcobcod, /*cobcod*/
                                input ?, /*contnum*/
                                input contrato.vltotal, 
                                input pacnv-entrada, 
                                input pacnv-principal, 
                                input pacnv-acrescimo,
                                input pacnv-seguro,
                                input pacnv-orinf + pacnv-orinl,
                                input pacnv-orinf,
                                input pacnv-orinl,
                                input pacnv-abate).
                    run cria-temp-contrato(input "CONTRATO",
                                input 40,
                                input contrato.modcod, /*modcod*/
                                input vcobcod, /*cobcod*/
                                input contrato.contnum, /*contnum*/
                                input contrato.vltotal, 
                                input pacnv-entrada, 
                                input pacnv-principal, 
                                input pacnv-acrescimo,
                                input pacnv-seguro,
                                input pacnv-orinf + pacnv-orinl,
                                input pacnv-orinf,
                                input pacnv-orinl,
                                input pacnv-abate).
            
            end.
            for each contrato where contrato.etbcod = estab.etbcod and
                                contrato.dtinicial = vdata
                                no-lock:
                find first tt-contrato where
                           tt-contrato.contnum = contrato.contnum
                           no-error.
                if avail tt-contrato then next.
                if contrato.banco = 10
                then do:
                    find last envfinan where
                      envfinan.empcod = 19 and
                      envfinan.titnat = no and
                      envfinan.modcod = contrato.modcod and
                      envfinan.etbcod = contrato.etbcod and
                      envfinan.clifor = contrato.clicod and
                      envfinan.titnum = string(contrato.contnum)
                      no-lock no-error.
                    if avail envfinan and (envfinan.envsit = "INC" or
                                   envfinan.envsit = "PAG")
                    then vcobcod = 10.
                    else vcobcod = 2.
                end. 
                else if contrato.banco = 13
                then vcobcod = 10.
                else vcobcod = 2.
                     
                run /admcom/progr/retorna-pacnv-valores-contrato.p 
                    (input ?, 
                     input recid(contrato), 
                     input ?).
            
                if pacnv-seguro = ? then pacnv-seguro = 0.
                if pacnv-entrada = ? then pacnv-entrada = 0.
                if pacnv-principal = ? then pacnv-principal = 0.
                if pacnv-acrescimo = ? then pacnv-acrescimo = 0.
                if pacnv-orinf = ? then pacnv-orinf = 0.
                if pacnv-orinl = ? then pacnv-orinl = 0.
                if pacnv-abate = ? then pacnv-abate = 0.
            
                /*if contrato.vltotal <>
                    pacnv-entrada + pacnv-principal + pacnv-acrescimo
                then do:
                    disp contrato.contnum format ">>>,>>>,>>9.99".
                    message contrato.vltotal
                    pacnv-entrada + pacnv-principal + pacnv-acrescimo.
                    pause.
                end.*/ 
                
                if (pacnv-entrada + pacnv-principal + pacnv-acrescimo)
                    > contrato.vltotal
                then assign
                        pacnv-abate =
                        (pacnv-entrada + pacnv-principal + pacnv-acrescimo)
                        - contrato.vltotal
                        pacnv-principal = pacnv-principal - pacnv-abate
                        pacnv-acrescimo = 0
                        .    
                
                run cria-temp-contrato(input "CONTRATO",
                                input 0,
                                input ?, /*modcod*/
                                input ?, /*cobcod*/
                                input ?, /*contnum*/
                                input contrato.vltotal, 
                                input pacnv-entrada, 
                                input pacnv-principal, 
                                input pacnv-acrescimo,
                                input pacnv-seguro,
                                input pacnv-orinf + pacnv-orinl,
                                input pacnv-orinf,
                                input pacnv-orinl,
                                input pacnv-abate).
            
                if pacnv-novacao or pacnv-renovacao
                then do: 
                    run cria-temp-contrato(input "CONTRATO",
                                input 15,
                                input ?, /*modcod*/
                                input ?, /*cobcod*/
                                input ?, /*contnum*/
                                input contrato.vltotal, 
                                input pacnv-entrada, 
                                input pacnv-principal, 
                                input pacnv-acrescimo,
                                input pacnv-seguro,
                                input pacnv-orinf + pacnv-orinl,
                                input pacnv-orinf,
                                input pacnv-orinl,
                                input pacnv-abate).
                    run cria-temp-contrato(input "CONTRATO",
                                input 25,
                                input contrato.modcod, /*modcod*/
                                input ?, /*cobcod*/
                                input ?, /*contnum*/
                                input contrato.vltotal, 
                                input pacnv-entrada, 
                                input pacnv-principal, 
                                input pacnv-acrescimo,
                                input pacnv-seguro,
                                input pacnv-orinf + pacnv-orinl,
                                input pacnv-orinf,
                                input pacnv-orinl,
                                input pacnv-abate).
                    run cria-temp-contrato(input "CONTRATO",
                                input 35,
                                input contrato.modcod, /*modcod*/
                                input vcobcod, /*cobcod*/
                                input ?, /*contnum*/
                                input contrato.vltotal, 
                                input pacnv-entrada, 
                                input pacnv-principal, 
                                input pacnv-acrescimo,
                                input pacnv-seguro,
                                input pacnv-orinf + pacnv-orinl,
                                input pacnv-orinf,
                                input pacnv-orinl,
                                input pacnv-abate).
                    run cria-temp-contrato(input "CONTRATO",
                                input 45,
                                input contrato.modcod, /*modcod*/
                                input vcobcod, /*cobcod*/
                                input contrato.contnum, /*contnum*/
                                input contrato.vltotal, 
                                input pacnv-entrada, 
                                input pacnv-principal, 
                                input pacnv-acrescimo,
                                input pacnv-seguro,
                                input pacnv-orinf + pacnv-orinl,
                                input pacnv-orinf,
                                input pacnv-orinl,
                                input pacnv-abate).
 
                end.
                else do:                           
                    run cria-temp-contrato(input "CONTRATO",
                                input 16,
                                input ?, /*modcod*/
                                input ?, /*cobcod*/
                                input ?, /*contnum*/
                                input contrato.vltotal, 
                                input pacnv-entrada, 
                                input pacnv-principal, 
                                input pacnv-acrescimo,
                                input pacnv-seguro,
                                input pacnv-orinf + pacnv-orinl,
                                input pacnv-orinf,
                                input pacnv-orinl,
                                input pacnv-abate).

                    run cria-temp-contrato(input "CONTRATO",
                                input 26,
                                input contrato.modcod, /*modcod*/
                                input ?, /*cobcod*/
                                input ?, /*contnum*/
                                input contrato.vltotal, 
                                input pacnv-entrada, 
                                input pacnv-principal, 
                                input pacnv-acrescimo,
                                input pacnv-seguro,
                                input pacnv-orinf + pacnv-orinl,
                                input pacnv-orinf,
                                input pacnv-orinl,
                                input pacnv-abate).
                    run cria-temp-contrato(input "CONTRATO",
                                input 36,
                                input contrato.modcod, /*modcod*/
                                input vcobcod, /*cobcod*/
                                input ?, /*contnum*/
                                input contrato.vltotal, 
                                input pacnv-entrada, 
                                input pacnv-principal, 
                                input pacnv-acrescimo,
                                input pacnv-seguro,
                                input pacnv-orinf + pacnv-orinl,
                                input pacnv-orinf,
                                input pacnv-orinl,
                                input pacnv-abate).
                    run cria-temp-contrato(input "CONTRATO",
                                input 46,
                                input contrato.modcod, /*modcod*/
                                input vcobcod, /*cobcod*/
                                input contrato.contnum, /*contnum*/
                                input contrato.vltotal, 
                                input pacnv-entrada, 
                                input pacnv-principal, 
                                input pacnv-acrescimo,
                                input pacnv-seguro,
                                input pacnv-orinf + pacnv-orinl,
                                input pacnv-orinf,
                                input pacnv-orinl,
                                input pacnv-abate).
 
                end.
            end.

        end.
            
        run estorno-cancelamento-financeira.
                
        /*RECEBIMENTO**********/

        def var vpaga as dec.
        vpaga = 0.
        
        if vindex = 1 or vindex = 3
        then
        for each titulo where
                 titulo.titnat = no and
                 titulo.titdtpag = vdata and
                 titulo.etbcobra = estab.etbcod 
                 no-lock:
        
            assign
                vtit-vlpag = 0
                vtit-vljur = 0.
            
            run titulo-moeda.
          
            release plani.
            run /admcom/progr/ctb/retorna-pacnv-valores-contrato.p 
                    (input ?, 
                     input ?, 
                     input recid(titulo)).
            
            if pacnv-seguro = ? then pacnv-seguro = 0.
            if pacnv-entrada = ? then pacnv-entrada = 0.
            if pacnv-principal = ? then pacnv-principal = 0.
            if pacnv-acrescimo = ? then pacnv-acrescimo = 0.
            if pacnv-orinf = ? then pacnv-orinf = 0.
            if pacnv-orinl = ? then pacnv-orinl = 0.
            if pacnv-abate = ? then pacnv-abate = 0.

            run cria-temp-recebimento(input "RECEBIMENTO",
                                      input 0,
                                      input ?, /*modcod*/
                                      input ?, /*cobcod*/
                                      input ?, /*moeda*/
                                      input ?, /*CPF*/
                                      input ?, /*titnum*/
                                      input ?, /*titpar*/
                                      input titulo.titvlcob,
                                      input titulo.titvlpag,
                                      input pacnv-principal,
                                      input pacnv-acrescimo,
                                      input vtit-vljur,
                                      input pacnv-seguro).

            if titulo.modcod <> "VVI" 
            then do:
                if clifor = 1 then next.                      
                
                run cria-temp-recebimento(input "RECEBIMENTO",
                                      input 10,
                                      input titulo.modcod, /*modcod*/
                                      input ?, /*cobcod*/
                                      input ?, /*moeda*/
                                      input ?, /*CPF*/
                                      input ?, /*titnum*/
                                      input ?, /*titpar*/
                                      input titulo.titvlcob,
                                      input titulo.titvlpag,
                                      input pacnv-principal,
                                      input pacnv-acrescimo,
                                      input vtit-vljur,
                                      input pacnv-seguro).
            
                
                if titulo.titpar = 0
                then do:
                    run cria-temp-recebimento(input "RECEBIMENTO",
                                      input 20,
                                      input titulo.modcod, /*modcod*/
                                      input ?, /*cobcod*/
                                      input ?, /*moeda*/
                                      input ?, /*CPF*/
                                      input ?, /*titnum*/
                                      input ?, /*titpar*/
                                      input titulo.titvlcob,
                                      input titulo.titvlpag,
                                      input pacnv-principal,
                                      input pacnv-acrescimo,
                                      input vtit-vljur,
                                      input pacnv-seguro).
                    
                    for each tt-moetit where tt-moetit.valor > 0:
                        vpaga = (tt-moetit.valor / vtit-vlpag).
                        p-6 = tt-moetit.moecod + "-" + 
                              tt-moetit.moenom.
                        run cria-temp-recebimento(input "RECEBIMENTO",
                                      input 20,
                                      input titulo.modcod, /*modcod*/
                                      input ?, /*cobcod*/
                                      input p-6, /*moeda*/
                                      input ?, /*CPF*/
                                      input ?, /*titnum*/
                                      input ?, /*titpar*/
                                      input titulo.titvlcob * vpaga,
                                      input titulo.titvlpag * vpaga,
                                      input pacnv-principal * vpaga,
                                      input pacnv-acrescimo * vpaga,
                                      input vtit-vljur * vpaga,
                                      input pacnv-seguro * vpaga).
                        run cria-temp-recebimento(input "RECEBIMENTO",
                                      input 21,
                                      input titulo.modcod, /*modcod*/
                                      input 2, /*cobcod*/
                                      input p-6, /*moeda*/
                                      input ?, /*CPF*/
                                      input titulo.titnum, /*titnum*/
                                      input titulo.titpar, /*titpar*/
                                      input titulo.titvlcob * vpaga,
                                      input titulo.titvlpag * vpaga,
                                      input pacnv-principal * vpaga,
                                      input pacnv-acrescimo * vpaga,
                                      input vtit-vljur * vpaga,
                                      input pacnv-seguro * vpaga).
 
                    end.            
                end.
                else do:
                    
                    if titulo.modcod <> "CRE"
                    then p-4 = "10".
                    else do:
                        find first envfinan where 
                                            envfinan.empcod = titulo.empcod and
                                            envfinan.titnat = titulo.titnat and
                                            envfinan.modcod = titulo.modcod and
                                            envfinan.etbcod = titulo.etbcod and
                                            envfinan.clifor = titulo.clifor and
                                            envfinan.titnum = titulo.titnum
                                            no-lock no-error.
                        if avail envfinan and
                                (envfinan.envsit = "INC" or
                                 envfinan.envsit = "PAG")
                        then p-4 = "10".
                        else p-4 = "2".
                    end.
                    run cria-temp-recebimento(input "RECEBIMENTO",
                                      input 30,
                                      input titulo.modcod, /*modcod*/
                                      input int(p-4), /*cobcod*/
                                      input ?, /*moeda*/
                                      input ?, /*CPF*/
                                      input ?, /*titnum*/
                                      input ?, /*titpar*/
                                      input titulo.titvlcob,
                                      input titulo.titvlpag,
                                      input pacnv-principal,
                                      input pacnv-acrescimo,
                                      input vtit-vljur,
                                      input pacnv-seguro).

                        
                    for each tt-moetit where tt-moetit.valor > 0:
                            vpaga = (tt-moetit.valor / vtit-vlpag).
                            p-6 = tt-moetit.moecod + "-" + 
                                      tt-moetit.moenom.
                            run cria-temp-recebimento(input "RECEBIMENTO",
                                      input 30,
                                      input titulo.modcod, /*modcod*/
                                      input p-4, /*cobcod*/
                                      input p-6, /*moeda*/
                                      input ?, /*CPF*/
                                      input ?, /*titnum*/
                                      input ?, /*titpar*/
                                      input titulo.titvlcob * vpaga,
                                      input titulo.titvlpag * vpaga,
                                      input pacnv-principal * vpaga,
                                      input pacnv-acrescimo * vpaga,
                                      input vtit-vljur * vpaga,
                                      input pacnv-seguro * vpaga).
                                
                            run cria-temp-recebimento(input "RECEBIMENTO",
                                      input 31,
                                      input titulo.modcod, /*modcod*/
                                      input p-4, /*cobcod*/
                                      input p-6, /*moeda*/
                                      input ?, /*CPF*/
                                      input titulo.titnum, /*titnum*/
                                      input titulo.titpar, /*titpar*/
                                      input titulo.titvlcob * vpaga,
                                      input titulo.titvlpag * vpaga,
                                      input pacnv-principal * vpaga,
                                      input pacnv-acrescimo * vpaga,
                                      input vtit-vljur * vpaga,
                                      input pacnv-seguro * vpaga).

                    end.
                end.
                
                run cria-temp-recebimento(input "RECEBIMENTO",
                                      input 15,
                                      input titulo.modcod, /*modcod*/
                                      input titulo.cobcod, /*cobcod*/
                                      input ?, /*moeda*/
                                      input ?, /*CPF*/
                                      input int(titulo.titnum), /*titnum*/
                                      input titulo.titpar, /*titpar*/
                                      input titulo.titvlcob,
                                      input titulo.titvlpag,
                                      input pacnv-principal,
                                      input pacnv-acrescimo,
                                      input vtit-vljur,
                                      input pacnv-seguro).
                
            end.
            else do:
                run reinicia-variaveis.
                
                vtit-vlpag = titulo.titvlpag.
                if titulo.moecod = "NOV"
                then vtit-vlpag = titulo.titvlcob.
 
                run cria-temp-recebimento(input "RECEBIMENTO",
                                      input 50,
                                      input "VVI", /*modcod*/
                                      input 2, /*cobcod*/
                                      input ?, /*moeda*/
                                      input ?, /*CPF*/
                                      input ?, /*titnum*/
                                      input ?, /*titpar*/
                                      input titulo.titvlcob,
                                      input titulo.titvlpag,
                                      input pacnv-principal,
                                      input pacnv-acrescimo,
                                      input vtit-vljur,
                                      input pacnv-seguro).
                
                for each tt-moetit where tt-moetit.valor > 0:
                            vpaga = (tt-moetit.valor / vtit-vlpag).
                            p-6 = tt-moetit.moecod + "-" + 
                                      tt-moetit.moenom.
                    run cria-temp-recebimento(input "RECEBIMENTO",
                                      input 51,
                                      input "VVI", /*modcod*/
                                      input 2, /*cobcod*/
                                      input p-6, /*moeda*/
                                      input ?, /*CPF*/
                                      input ?, /*titnum*/
                                      input ?, /*titpar*/
                                      input titulo.titvlcob * vpaga,
                                      input titulo.titvlpag * vpaga,
                                      input pacnv-principal * vpaga,
                                      input pacnv-acrescimo * vpaga,
                                      input vtit-vljur * vpaga,
                                      input pacnv-seguro * vpaga).
                    run cria-temp-recebimento(input "RECEBIMENTO",
                                      input 52,
                                      input "VVI", /*modcod*/
                                      input 2, /*cobcod*/
                                      input p-6, /*moeda*/
                                      input ?, /*CPF*/
                                      input titulo.titnum, /*titnum*/
                                      input titulo.titpar, /*titpar*/
                                      input titulo.titvlcob * vpaga,
                                      input titulo.titvlpag * vpaga,
                                      input pacnv-principal * vpaga,
                                      input pacnv-acrescimo * vpaga,
                                      input vtit-vljur * vpaga,
                                      input pacnv-seguro * vpaga).


                end. 

            end.

        end.
        
        if vindex = 1 or vindex = 2
        then do:
            
        for each ctbvenda where ctbvenda.tipo = "VENDA" and
                                ctbvenda.datref = vdata and 
                                ctbvenda.etbcod = estab.etbcod
                                :
            delete ctbvenda. 
        end.
        for each ctbvenda where ctbvenda.tipo = "DEVOLUCAO VENDA" and
                                ctbvenda.datref = vdata and 
                                ctbvenda.etbcod = estab.etbcod
                                :
            delete ctbvenda. 
        end.

        for each ctb-venda where ctb-venda.tipo <> "":
            create ctbvenda.
            buffer-copy ctb-venda to ctbvenda.
        end.
        end.
        
        if vindex = 1 or vindex = 2
        then do:
        
        for each ctbcontrato where ctbcontrato.tipo = "CONTRATO" and
                                  ctbcontrato.datref = vdata and 
                                  ctbcontrato.etbcod = estab.etbcod
                                    :
            delete ctbcontrato. 
        end.
        
        for each ctbcontrato where ctbcontrato.tipo = "ESTORNO FINANCEIRA" and
                                  ctbcontrato.datref = vdata and 
                                  ctbcontrato.etbcod = estab.etbcod
                                    :
            delete ctbcontrato. 
        end.

        for each ctb-contrato where tipo <> "".
            create ctbcontrato.
            buffer-copy ctb-contrato to ctbcontrato.
        end. 
        end.
        if vindex = 1 or vindex = 3
        then do:
        for each ctbrecebe where ctbrecebe.tipo = "RECEBIMENTO" and
                                 ctbrecebe.datref = vdata and 
                                 ctbrecebe.etbcod = estab.etbcod
                                 :
            delete ctbrecebe. 
        end.
        for each ctb-recebe where tipo <> "".
            create ctbrecebe.
            buffer-copy ctb-recebe to ctbreceb.
        end. 
        end.
    end.
end.
/*
output to /admcom/relat/teste.cl.
        for each tt-contrato.
        export tt-contrato.
        end.
        output close.
*/
disp vtotal-plani vtotal-contrato.


def var varquivo as char.

/*****************
procedure grava-tt-valores :

    def input parameter p-valor as dec.
    def input parameter p-tipo as char.
    
    if p-valor <> 0
    then do:
        find first tt-valores where
               tt-valores.etbcod = estab.etbcod and
               tt-valores.datref = vdata and
               tt-valores.t1 = p-1 and
               tt-valores.t2 = p-2 and
               tt-valores.t3 = p-3 and
               tt-valores.t4 = p-4 and
               tt-valores.t5 = p-5 and
               tt-valores.t6 = p-6 and
               tt-valores.t7 = p-7 and
               tt-valores.t8 = p-8 and
               tt-valores.t9 = p-9 and
               tt-valores.t0 = p-0 
                               no-error.
        if not avail tt-valores
        then do:
            create tt-valores.
            assign
                tt-valores.etbcod = estab.etbcod
                tt-valores.datref = vdata 
                tt-valores.t1 = p-1
                tt-valores.t2 = p-2
                tt-valores.t3 = p-3
                tt-valores.t4 = p-4
                tt-valores.t5 = p-5
                tt-valores.t6 = p-6
                tt-valores.t7 = p-7
                tt-valores.t8 = p-8
                tt-valores.t9 = p-9
                tt-valores.t0 = p-0
                tt-valores.tipo = p-tipo
                .
        end. 
        tt-valores.valor = tt-valores.valor + p-valor.
    end.     
    
    assign p-9 = "" p-0 = "" .

end procedure.
*******************/
/****************
procedure principal-renda:

    def input parameter log-limpa    as log.
    def input parameter rec-plani    as recid.
    def input parameter rec-contrato as recid.
    def input parameter rec-titulo   as recid.
    
    assign
        pacnv-avista     = 0
        pacnv-aprazo     = 0
        pacnv-principal  = 0
        pacnv-acrescimo  = 0
        pacnv-entrada    = 0
        pacnv-seguro     = 0
        pacnv-crepes     = 0
        pacnv-troca      = 0
        pacnv-voucher    = 0
        pacnv-black      = 0
        pacnv-chepres    = 0
        pacnv-combo      = 0
        pacnv-abate      = 0
        pacnv-novacao    = no
        pacnv-renovacao  = no
        pacnv-feiraonl   = no
        pacnv-cpfautoriza = ""
        pacnv-juroatu     = 0
        pacnv-juroacr     = 0
        .
        
    if not log-limpa
    then do:
    if rec-titulo = ?
    then do:
        run retorna-pacnv-valores-contrato.p 
                    (input rec-plani, 
                     input rec-contrato, 
                     input rec-titulo).
    end.
    else do on error undo:
        find first titpacnv where
               titpacnv.modcod   = titulo.modcod and
               titpacnv.etbcod   = titulo.etbcod and 
               titpacnv.clifor   = titulo.clifor and
               titpacnv.titnum   = titulo.titnum and
               titpacnv.titdtemi = titulo.titdtemi
                        no-error.
        if not avail titpacnv
        then do:
            create titpacnv.
            assign
                titpacnv.modcod   = titulo.modcod
                titpacnv.etbcod   = titulo.etbcod
                titpacnv.clifor   = titulo.clifor
                titpacnv.titnum   = titulo.titnum
                titpacnv.titdtemi = titulo.titdtemi
                titpacnv.titvlcob = titulo.titvlcob
                titpacnv.titdes   = titulo.titdes
                .
          
            run retorna-pacnv-valores-contrato.p 
                    (input rec-plani, 
                     input rec-contrato, 
                     input rec-titulo).

            if  pacnv-principal <= 0 or
                pacnv-acrescimo <= 0
            then assign
                 pacnv-principal = titulo.titvlcob
                 pacnv-acrescimo = 0
                 .

            assign
                titpacnv.principal = pacnv-principal
                titpacnv.acrescimo = pacnv-acrescimo
                .
        end.
        else do:
            if titpacnv.principal = 0 or
               titpacnv.principal > titulo.titvlcob or
               titpacnv.principal + titpacnv.acrescimo <> titulo.titvlcob
            then do:
                run retorna-pacnv-valores-contrato.p 
                             (input rec-plani, 
                              input rec-contrato, 
                              input rec-titulo).

                if  pacnv-principal <= 0 or
                    pacnv-acrescimo <= 0
                then assign
                     pacnv-principal = titulo.titvlcob
                     pacnv-acrescimo = 0
                     .

                assign
                    titpacnv.principal = pacnv-principal
                    titpacnv.acrescimo = pacnv-acrescimo
                    .

            end.
            else assign
                pacnv-principal = titpacnv.principal
                pacnv-acrescimo = titpacnv.acrescimo
                pacnv-seguro    = titpacnv.titdes
                .

            if pacnv-principal = 0
            then assign
                    pacnv-principal = titulo.titvlcob
                    pacnv-acrescimo = 0.
            else if pacnv-principal = titulo.titvlcob
            then pacnv-acrescimo = 0.
            else if pacnv-principal > titulo.titvlcob
            then assign
                     pacnv-principal = titulo.titvlcob
                     pacnv-acrescimo = 0.
            else if pacnv-principal + pacnv-acrescimo > titulo.titvlcob
            then assign
                     pacnv-principal = titulo.titvlcob
                     pacnv-acrescimo = 0.
            else if pacnv-principal + pacnv-acrescimo < titulo.titvlcob
            then assign    
                    pacnv-principal = titulo.titvlcob
                    pacnv-acrescimo = 0.


        end.            
    
        find current titpacnv no-lock.
        
    end.
    end.
end procedure.
*************************/

/************************
procedure pdv-moeda:
    def input parameter p-etbcod like estab.etbcod.
    def input parameter p-data as date.
    def var vtroco as dec.
    for each pag-titulo. delete pag-titulo. end.
    for each pag-titmoe. delete pag-titmoe. end.
    for each pdvmov where
                 pdvmov.etbcod  = p-etbcod and
                 pdvmov.datamov = p-data no-lock:
        find first pdvmoeda of pdvmov
            where pdvmoeda.moecod = "CRE"
            no-lock no-error.
        if avail pdvmoeda then next.    
        for each pdvdoc of pdvmov where
            pdvdoc.clifor <> 1 and
            pdvdoc.titpar >= 0 
            no-lock:
            create pag-titulo.
            assign
                pag-titulo.clifor = pdvdoc.clifor
                pag-titulo.titnum = pdvdoc.contnum
                pag-titulo.titpar  = pdvdoc.titpar
                pag-titulo.titvlcob = pdvdoc.titvlcob
                pag-titulo.titvlpag = pdvdoc.valor
                .
             vtroco = 0.
             for each pdvmoeda of pdvmov no-lock:
                create pag-titmoe.
                assign
                    pag-titmoe.clifor = pdvdoc.clifor
                    pag-titmoe.titnum = pdvdoc.contnum
                    pag-titmoe.titpar  = pdvdoc.titpar
                    vtroco = pdvmov.valortroco *
                             (pdvmoe.valor / 
                             (pdvmov.valortot + pdvmov.valortroco))
                    pag-titmoe.moecod = pdvmoe.moecod.
                    pag-titmoe.titvlpag = (pdvmoe.valor - vtroco) *
                            (pdvdoc.valor  / pdvmov.valortot)
                    .
            end.
        end.
    end.
end procedure.
************************/

procedure titulo-moeda:
    def var vmoecod like moeda.moecod.
    def var vmoenom like moeda.moenom.
    def var vpaga as dec init 0.
    
    vtit-vlpag = titulo.titvlpag.
    if titulo.titpar <> 0 
    then vtit-vljur = titulo.titjuro.
    
    /***        
    if (acha("PAGAMENTO-PARCIAL",titulo.titobs[1]) = "SIM" or
              acha("PARCIAL",titulo.titobs[1]) = "SIM") and
              titulo.moecod <> "NOV"
    then do:
        assign
             vtit-vlpag - titulo.titjuro
                            pacnv-acrescimo = 0
                            pacnv-seguro = 0
                            .   
                    end.
             
    if titulo.moecod = "NOV" or
       titulo.moecod = ""  or
       titulo.cxacod = 99
    then assign
             vtit-vlpag = titulo.titvlcob
             vtit-vljur = 0.
    ***/            
             
    for each tt-moetit: delete tt-moetit. end.
    if titulo.moecod = "PDM"
    then do:
        vpaga = 0.
        for each titpag where
                      titpag.empcod = titulo.empcod and
                      titpag.titnat = titulo.titnat and
                      titpag.modcod = titulo.modcod and
                      titpag.etbcod = titulo.etbcod and
                       titpag.clifor = titulo.clifor and
                      titpag.titnum = titulo.titnum and
                      titpag.titpar = titulo.titpar
                      no-lock:
                 
            vmoecod = titpag.moecod.

            find first moeda where  moeda.moecod = vmoecod
                               no-lock no-error.
            if avail moeda
            then vmoenom = moeda.moenom.
            else vmoenom = "".
            
            find first tt-moetit where tt-moetit.moecod = vmoecod
                                no-lock no-error.
            if not avail tt-moetit
            then do:                    
                create tt-moetit.
                assign
                    tt-moetit.moecod = vmoecod
                    tt-moetit.moenom = vmoenom .
                if tt-moetit.moecod = "NOV"
                then tt-moetit.moenom = "NOVACAO".
                if tt-moetit.moecod = "DEV"
                then tt-moetit.moenom = "DEV-DEVOLUCAO".
            end.
            assign
                tt-moetit.valor = tt-moetit.valor + titpag.titvlpag
                vpaga = vpaga + tt-moetit.valor.
 
        end.
        if vpaga = 0
        then do:
            if titulo.moecod = "" and
               titulo.etbcobra <> ? and
               titulo.etbcobra > 900
            then vmoecod = string(titulo.etbcobra).   
            else vmoecod = titulo.moecod.

            find first moeda where  moeda.moecod = vmoecod
                               no-lock no-error.
            if avail moeda
            then vmoenom = moeda.moenom.
            else vmoenom = "".
            
            find first tt-moetit where tt-moetit.moecod = vmoecod
                                no-lock no-error.
            if not avail tt-moetit
            then do:                    
                create tt-moetit.
                assign
                    tt-moetit.moecod = vmoecod
                    tt-moetit.moenom = vmoenom .
                if tt-moetit.moecod = "NOV"
                then tt-moetit.moenom = "NOVACAO".
                if tt-moetit.moecod = "DEV"
                then tt-moetit.moenom = "DEV-DEVOLUCAO".
            end.
            assign
                tt-moetit.valor = tt-moetit.valor + vtit-vlpag
                vpaga = vpaga + tt-moetit.valor.
        end.
    end.
    else do: 
        if titulo.moecod = "" and
               titulo.etbcobra <> ? and
               titulo.etbcobra > 900
        then vmoecod = string(titulo.etbcobra).   
        else vmoecod = titulo.moecod.

        find first moeda where  moeda.moecod = vmoecod
                               no-lock no-error.
        if avail moeda
            then vmoenom = moeda.moenom.
            else vmoenom = "".
            
        find first tt-moetit where tt-moetit.moecod = vmoecod
                                no-lock no-error.
        if not avail tt-moetit
        then do:                    
                create tt-moetit.
                assign
                    tt-moetit.moecod = vmoecod
                    tt-moetit.moenom = vmoenom .
                if tt-moetit.moecod = "NOV"
                then tt-moetit.moenom = "NOVACAO".
                if tt-moetit.moecod = "DEV"
                then tt-moetit.moenom = "DEV-DEVOLUCAO".
        end.
        assign
                tt-moetit.valor = tt-moetit.valor + vtit-vlpag
                vpaga = vpaga + tt-moetit.valor.
    end.

end procedure.


procedure cria-temp-venda:
    def input parameter p-tipo as char.
    def input parameter p-seq as int.
    def input parameter p-opfcod like movim.opfcod.
    def input parameter p-emite like plani.emite.
    def input parameter p-serie like plani.serie.
    def input parameter p-numero like plani.numero.
    def input parameter p-crecod like plani.crecod.
    def input parameter p-chave as char.
    def input parameter p-produto as char.
    def input parameter p-mercadoria as dec.
    def input parameter p-servico as dec.
    def input parameter p-outras as dec.
    def input parameter p-tipovenda as char.
     
    find first ctb-venda where  ctb-venda.tipo   = p-tipo and
                                ctb-venda.datref = vdata  and
                                ctb-venda.etbcod = estab.etbcod and
                                ctb-venda.movseq  = p-seq and
                                ctb-venda.opfcod  = p-opfcod and
                                ctb-venda.crecod  = p-crecod and
                                ctb-venda.produto = p-produto and
                                ctb-venda.emite   = p-emite and
                                ctb-venda.serie   = p-serie and
                                ctb-venda.numero  = p-numero and
                                ctb-venda.tipovend = p-tipovenda
                                no-error.
    if not avail ctb-venda
    then do:
        create ctb-venda.
        assign
            ctb-venda.tipo   = p-tipo
            ctb-venda.datref = vdata
            ctb-venda.etbcod = estab.etbcod
            ctb-venda.movseq = p-seq
            ctb-venda.opfcod = p-opfcod
            ctb-venda.crecod = p-crecod
            ctb-venda.emite  = p-emite
            ctb-venda.serie  = p-serie
            ctb-venda.numero = p-numero
            ctb-venda.chave  = p-chave
            ctb-venda.produto = p-produto
            ctb-venda.tipovenda = p-tipovenda
            .
    end.
    assign
        ctb-venda.mercadoria = ctb-venda.mercadoria + p-mercadoria
        ctb-venda.servico = ctb-venda.servico + p-servico
        ctb-venda.outras = ctb-venda.outras + p-outras
        .
    if p-seq = 40 and p-crecod = 2 and plani.movtdc = 5
    then do:
        find first contnf where
               contnf.etbcod = plani.etbcod and
               contnf.placod = plani.placod and
               contnf.notaser = plani.serie 
               no-lock no-error.
        if avail contnf
        then do:
            find contrato where 
                contrato.contnum = contnf.contnum no-lock no-error.
            create tt-contrato.
            assign
                tt-contrato.etbcod    = contrato.etbcod 
                tt-contrato.contnum   = contrato.contnum
                tt-contrato.dtinicial = contrato.dtinicial
                tt-contrato.vlvenda   = (p-mercadoria +
                                     p-servico + p-outras)
                tt-contrato.srvenda   = vendap-seguro
                tt-contrato.emite = plani.emite
                tt-contrato.serie = plani.serie
                tt-contrato.numero = plani.numero
                ctb-venda.contrato = contrato.contnum
                .
            find first vndseguro where
                       vndseguro.contnum = contrato.contnum no-lock no-error.
            if avail vndseguro
            then assign
                    tt-contrato.certifi = vndseguro.certifi
                    ctb-venda.certifi = vndseguro.certifi.
                
            if contrato.banco > 9 and 
               contrato.banco < 20
            then ctb-venda.cobcod = 10.
            else ctb-venda.cobcod = 2.   
                       
            /*
            run /admcom/progr/ctb/retorna-pacnv-valores-contrato.p 
                    (input ?, 
                     input recid(contrato), 
                     input ?).
            if (p-mercadoria + 
                p-servico +
                p-outras) <> (pacnv-principal + pacnv-entrada)
            then do:
                disp contrato.vltotal contrato.vlentra
                (p-mercadoria + p-servico + p-outras)
                (pacnv-principal + pacnv-entrada).
                pause.
            end.    
            vtotal-plani = vtotal-plani + 
                    (p-mercadoria + p-servico + p-outras).
            vtotal-contrato = vtotal-contrato + 
                    (pacnv-principal + pacnv-entrada).
            */
        end.
        else ctb-venda.cobcod = 2.
    end.
    else ctb-venda.cobcod = 2.
end procedure.

procedure cria-temp-devolucao-venda:
    def input parameter p-tipo as char.
    def input parameter p-seq as int.
    def input parameter p-opfcod like movim.opfcod.
    def input parameter p-emite like plani.emite.
    def input parameter p-serie like plani.serie.
    def input parameter p-numero like plani.numero.
    def input parameter p-crecod like plani.crecod.
    def input parameter p-chave as char.
    def input parameter p-produto as char.
    def input parameter p-mercadoria as dec.
    def input parameter p-servico as dec.
    def input parameter p-outras as dec.
    def input parameter p-valcontrato as dec.
    def input parameter p-valquitado  as dec.
    def input parameter p-valdevolvido as dec.
     
    find first ctb-venda where  ctb-venda.tipo   = p-tipo and
                                ctb-venda.datref = vdata  and
                                ctb-venda.etbcod = estab.etbcod and
                                ctb-venda.movseq  = p-seq and
                                ctb-venda.opfcod  = p-opfcod and
                                ctb-venda.crecod  = p-crecod and
                                ctb-venda.produto = p-produto and
                                ctb-venda.emite   = p-emite and
                                ctb-venda.serie   = p-serie and
                                ctb-venda.numero  = p-numero 
                                no-error.
    if not avail ctb-venda
    then do:
        create ctb-venda.
        assign
            ctb-venda.tipo   = p-tipo
            ctb-venda.datref = vdata
            ctb-venda.etbcod = estab.etbcod
            ctb-venda.movseq = p-seq
            ctb-venda.opfcod = p-opfcod
            ctb-venda.crecod = p-crecod
            ctb-venda.emite  = p-emite
            ctb-venda.serie  = p-serie
            ctb-venda.numero = p-numero
            ctb-venda.chave  = p-chave
            ctb-venda.produto = p-produto
            .
    end.
    assign
        ctb-venda.mercadoria = ctb-venda.mercadoria + p-mercadoria
        ctb-venda.servico = ctb-venda.servico + p-servico
        ctb-venda.outras = ctb-venda.outras + p-outras
        ctb-venda.valcontrato = ctb-venda.valcontrato + p-valcontrato
        ctb-venda.valquitado = ctb-venda.valquitado + p-valquitado
        ctb-venda.valdevolvido = ctb-venda.valdevolvido + p-valdevolvido
        .
end procedure.


procedure cria-temp-contrato:
    def input parameter p-tipo as char.
    def input parameter p-seq as int.
    def input parameter p-modcod like titulo.modcod.
    def input parameter p-cobcod like titulo.cobcod.
    def input parameter p-contnum like contrato.contnum.
    def input parameter p-vlcontrato as dec.
    def input parameter p-vlentrada as dec.
    def input parameter p-vlprincipal as dec.
    def input parameter p-vlacrescimo as dec.
    def input parameter p-vlseguro as dec.
    def input parameter p-vlorigem as dec.
    def input parameter p-vlorifin as dec.
    def input parameter p-vloridre as dec.
    def input parameter p-vlabate as dec.
     
    find first ctb-contrato where ctb-contrato.tipo = p-tipo and
                                  ctb-contrato.datref = vdata and
                                  ctb-contrato.etbcod = estab.etbcod and
                                  ctb-contrato.movseq = p-seq and
                                  ctb-contrato.cobcod = p-cobcod and
                                  ctb-contrato.modcod = p-modcod and
                                  ctb-contrato.contnum = p-contnum
                                  no-error.
    if not avail ctb-contrato
    then do:
        create ctb-contrato.
        assign
            ctb-contrato.tipo = p-tipo
            ctb-contrato.datref = vdata
            ctb-contrato.etbcod = estab.etbcod
            ctb-contrato.movseq = p-seq
            ctb-contrato.cobcod = p-cobcod
            ctb-contrato.modcod = p-modcod
            ctb-contrato.contnum = p-contnum
            .
    end.
    assign
        ctb-contrato.vlcontrato = ctb-contrato.vlcontrato + p-vlcontrato
        ctb-contrato.vlentrada  = ctb-contrato.vlentrada  + p-vlentrada
        ctb-contrato.vlprincipal = ctb-contrato.vlprincipal + p-vlprincipal
        ctb-contrato.vlacrescimo = ctb-contrato.vlacrescimo + p-vlacrescimo
        ctb-contrato.vlseguro    = ctb-contrato.vlseguro + p-vlseguro
        ctb-contrato.vlorigem    = ctb-contrato.vlorigem + p-vlorigem
        ctb-contrato.vlorifin    = ctb-contrato.vlorifin + p-vlorifin
        ctb-contrato.vlorileb    = ctb-contrato.vlorileb + p-vloridre
        ctb-contrato.vlabate     = ctb-contrato.vlabate + p-vlabate 
        .
end procedure. 

procedure cria-temp-recebimento:
    def input parameter p-tipo as char.
    def input parameter p-seq as int.
    def input parameter p-modcod like titulo.modcod.
    def input parameter p-cobcod like titulo.cobcod.
    def input parameter p-moeda  as char.
    def input parameter p-cpf as char.
    def input parameter p-titnum like titulo.titnum.
    def input parameter p-titpar like titulo.titpar.
    def input parameter p-vlparcela as dec.
    def input parameter p-vlpago as dec.
    def input parameter p-vlprincipal as dec.
    def input parameter p-vlacrescimo as dec.
    def input parameter p-vljuro as dec.
    def input parameter p-vlseguro as dec.
     
    find first ctb-recebe where ctb-recebe.tipo = p-tipo and
                                  ctb-recebe.datref = vdata and
                                  ctb-recebe.etbcod = estab.etbcod and
                                  ctb-recebe.movseq = p-seq and
                                  ctb-recebe.cobcod = p-cobcod and
                                  ctb-recebe.modcod = p-modcod and
                                  ctb-recebe.moeda  = p-moeda  and
                                  ctb-recebe.cpf    = p-cpf   and
                                  ctb-recebe.titnum = p-titnum and
                                  ctb-recebe.titpar = p-titpar                                  no-error.
    if not avail ctb-recebe
    then do:
        create ctb-recebe.
        assign
            ctb-recebe.tipo = p-tipo
            ctb-recebe.datref = vdata
            ctb-recebe.etbcod = estab.etbcod
            ctb-recebe.movseq = p-seq
            ctb-recebe.cobcod = p-cobcod
            ctb-recebe.modcod = p-modcod
            ctb-recebe.moeda  = p-moeda 
            ctb-recebe.cpf    = p-cpf
            ctb-recebe.titnum = p-titnum
            ctb-recebe.titpar = p-titpar
            .
    end.
    assign
        ctb-recebe.vlparcela = ctb-recebe.vlparcela + p-vlparcela
        ctb-recebe.vlpago    = ctb-recebe.vlpago  + p-vlpago
        ctb-recebe.vlprincipal = ctb-recebe.vlprincipal + p-vlprincipal
        ctb-recebe.vlacrescimo = ctb-recebe.vlacrescimo + p-vlacrescimo
        ctb-recebe.vljuro      = ctb-recebe.vljuro + p-vljuro
        ctb-recebe.vlseguro    = ctb-recebe.vlseguro + p-vlseguro
        .
         
end procedure. 

procedure devolucao-venda:

    def var vtotal as dec.
    def buffer ctitulo for titulo.
    def buffer bplani for plani.
    def buffer bmovim for movim.
    def var dev-avista as dec.
    def var dev-aprazo as dec.
    def var val-contrato as dec.
    def var val-quitado as dec.
    def var val-devolvido as dec.
    def var val-avdevolvido as dec.
    def var vclifor like titulo.clifor.
    def var vcontrato like contrato.contnum.
    def var vok-categoria as log.
    def var vvaldevolvido_av as dec.
    
    for each plani where plani.movtdc = 12 and
         plani.pladat = vdata and
         plani.etbcod = estab.etbcod
         no-lock:
        /*
        if  month(plani.pladat) <> month(plani.datexp) and
                plani.datexp - plani.pladat > 10
        then do:
            disp plani.etbcod plani.numero.
            pause.
        end.    
        */        
        val-contrato = 0.
        val-quitado = 0.
        val-devolvido = 0.
        val-avdevolvido = 0.
        vvaldevolvido_av = 0.
        vtitdev = 0.
        vtitpag = 0.
        vtotal = 0. 

        if plani.etbcod <> 200
        then do:
        for each ctdevven where ctdevven.movtdc  = plani.movtdc and
                                ctdevven.etbcod = plani.etbcod and
                                ctdevven.placod = plani.placod and  
                                ctdevven.pladat = plani.pladat 
                                no-lock:
                              
            if ctdevven.placod-ven = 0
            then do:
            
                for each movim where movim.movtdc = plani.movtdc and
                                 movim.etbcod = plani.etbcod and
                                 movim.placod = plani.placod
                             no-lock:
                    vclifor = movim.ocnum[7].
                    ventrada = ventrada + (movim.movpc * movim.movqtm).
                end.
        
                find first bplani where 
                           bplani.movtdc = ctdevven.movtdc-ven and
                           bplani.etbcod = ctdevven.etbcod-ven and
                           bplani.placod = ctdevven.placod-ven 
                           no-lock no-error.        
                if avail bplani
                then
                for each bmovim where bmovim.movtdc = bplani.movtdc and
                                  bmovim.etbcod = bplani.etbcod and
                                  bmovim.placod = bplani.placod
                             no-lock:
                    vsaida = vsaida + (bmovim.movpc * bmovim.movqtm).
                end.

                find first cplani where 
                           cplani.movtdc = ctdevven.movtdc-ori and
                           cplani.etbcod = ctdevven.etbcod-ori and
                           cplani.placod = ctdevven.placod-ori
                           no-lock no-error.
                if avail cplani
                then do:
                    for each cmovim where cmovim.movtdc = cplani.movtdc and
                                  cmovim.etbcod = cplani.etbcod and
                                  cmovim.placod = cplani.placod
                             no-lock:
                        vorigem = vorigem + (cmovim.movpc * cmovim.movqtm).
                    end.              
                    vclifor = cplani.desti.
                    find first contnf where contnf.etbcod = cplani.etbcod and
                                    contnf.placod = cplani.placod
                              no-lock no-error.
                    if avail contnf
                    then vcontrato = contnf.contnum.
                    else vcontrato = cplani.numero.

                    if avail contnf
                    then do:
                        find contrato where contrato.contnum = vcontrato
                                            no-lock no-error.
                        if avail contrato
                        then val-contrato = contrato.vltotal.                  
                    for each titulo where titulo.empcod = 19 and
                                  titulo.titnat = no and
                                  titulo.modcod = "CRE" and
                                  titulo.etbcod = cplani.etbcod and
                                  titulo.clifor = cplani.desti  and
                                  titulo.titnum = string(vcontrato) 
                                  no-lock:
                        if titulo.titdtemi = cplani.pladat and
                            titulo.moecod = "DEV" and
                            titulo.etbcob = ?
                        then assign
                            vtitpag = vtitpag + titulo.titvlcob.
                        else if titulo.etbcob = cplani.etbcod and
                            titulo.moecod <> "DEV" and
                            (titulo.titdtpag < plani.pladat
                             or (titulo.titdtpag = plani.pladat and
                                 titulo.titpar = 0))
                        then assign
                             vtitdev = vtitdev + titulo.titvlpag.
                    end.
                    end.
                    else do:
                        find first ctitulo where ctitulo.empcod = 19 and
                                         ctitulo.titnat = yes and
                                         ctitulo.modcod = "DEV" and
                                         ctitulo.etbcod = cplani.etbcod and
                                         ctitulo.clifor = cplani.desti  and
                                         ctitulo.titnum = string(vcontrato) and
                                  /*#2*/ ctitulo.titdtemi = cplani.pladat
                                        no-lock no-error.
                        if avail ctitulo
                        then do:
                            for each titulo where titulo.empcod = 19 and
                                  titulo.titnat = yes and
                                  titulo.modcod = "DEV" and
                                  titulo.etbcod = cplani.etbcod and
                                /*titulo.clifor = cplani.desti  and*/
                                  titulo.titnum = string(vcontrato) and
                           /*#2*/ titulo.titdtemi = cplani.pladat and
                                  titulo.titdtpag <> ? 
                                  no-lock:
                                assign
                                vtitdev = vtitdev + titulo.titvlpag.
 
                            end.
                        end.
                        else do:
                            find first titulo where titulo.empcod = 19 and
                                  titulo.titnat = yes and
                                  titulo.modcod = "DEV" and
                                  titulo.etbcod = cplani.etbcod and
                                  titulo.titnum = string(vcontrato) and
                           /*#2*/ titulo.titdtemi = cplani.pladat
                                  no-lock no-error.
                            if avail titulo
                            then do:
                                for each titulo where titulo.empcod = 19 and
                                  titulo.titnat = yes and
                                  titulo.modcod = "DEV" and
                                  titulo.etbcod = cplani.etbcod and
                                  /*titulo.clifor = cplani.desti  and*/
                                  titulo.titnum = string(vcontrato) and
                           /*#2*/ titulo.titdtemi = cplani.pladat
                                  no-lock:
                                 vtitdev = vtitdev + titulo.titvlpag.
                                end.
                            end.
                            else do:
                                for each titulo where titulo.empcod = 19 and
                                  titulo.titnat = yes and
                                  titulo.modcod = "DEV" and
                                  titulo.etbcod = cplani.etbcod and
                                  /*titulo.clifor = cplani.desti  and*/
                                  titulo.titnum = string(ctdevven.numero) and
                           /*#2*/ titulo.titdtemi = cplani.pladat
                                  no-lock:
                                 vtitdev = vtitdev + titulo.titvlpag.
                                end.
                            end.
                        end.
                    end.
                    if cplani.crecod = 1
                    then do.
                        vvista = vvista + cplani.platot.

                        for each titulo where titulo.empcod = 19
                            and titulo.titnat = no
                            and titulo.modcod = cplani.modcod
                            and titulo.etbcod = cplani.etbcod
                            and titulo.clifor = cplani.desti
                            and titulo.titnum = 
                                cplani.serie + string(cplani.numero)
                            no-lock.
                            if titulo.moecod = "REA"
                            then assign
                                vvaldevolvido_av = 
                                vvaldevolvido_av + titulo.titvlcob.
                            else if titulo.moecod = "PDM"
                            then
                            for each titpag where
                                titpag.empcod = titulo.empcod and
                                titpag.titnat = titulo.titnat and
                                titpag.modcod = titulo.modcod and
                                titpag.etbcod = titulo.etbcod and
                                titpag.clifor = titulo.clifor and
                                titpag.titnum = titulo.titnum and
                                titpag.titpar = titulo.titpar and
                                titpag.moecod = "REA"
                                no-lock:
                                vvaldevolvido_av = 
                                vvaldevolvido_av + titpag.titvlpag.
                            end.
                        end.

                        run cria-temp-devolucao-venda(input "DEVOLUCAO VENDA",
                        input 200,
                        input ?, /*opfcod*/
                        input ?, /*emite*/
                        input ?, /*serie*/
                        input ?, /*numero*/
                        input 1, /*crecod*/
                        input ?, /*chave*/
                        input ?,
                        input plani.protot,
                        input plani.frete,
                        input plani.outras,
                        input val-contrato,
                        input 0,
                        input vvaldevolvido_av).
                        vtotal = vtotal + plani.protot.
                        val-devolvido = val-devolvido + vvaldevolvido_av.
                    end.
                    else do:
                        vprazo = vprazo + cplani.platot. 
                        run cria-temp-devolucao-venda(input "DEVOLUCAO VENDA",
                        input 200,
                        input ?, /*opfcod*/
                        input ?, /*emite*/
                        input ?, /*serie*/
                        input ?, /*numero*/
                        input 2, /*crecod*/
                        input ?, /*chave*/
                        input ?,
                        input plani.protot,
                        input plani.frete,
                        input plani.outras,
                        input val-contrato,
                        input vtitpag,
                        input vtitdev).

                        vtotal = vtotal + plani.platot.
                        val-quitado = val-quitado + vtitpag.
                        val-devolvido = val-devolvido + vtitdev.
                        
                    end.
                end.
                else do:
                    disp plani.etbcod plani.numero. pause.
                end.
            end.
            else do:
                find first cplani where 
                           cplani.movtdc = ctdevven.movtdc-ori and
                           cplani.etbcod = ctdevven.etbcod-ori and
                           cplani.placod = ctdevven.placod-ori
                           no-lock no-error.
                if avail cplani
                then do:
                    if cplani.crecod = 1
                    then do:
                        run cria-temp-devolucao-venda(input "DEVOLUCAO VENDA",
                        input 200,
                        input ?, /*opfcod*/
                        input ?, /*emite*/
                        input ?, /*serie*/
                        input ?, /*numero*/
                        input 1, /*crecod*/
                        input ?, /*chave*/
                        input ?,
                        input plani.protot,
                        input plani.frete,
                        input plani.outras,
                        input val-contrato,
                        input val-quitado,
                        input val-devolvido).
                        
                        vtotal = vtotal + plani.platot.

                    end.
                    else do:
                        run cria-temp-devolucao-venda(input "DEVOLUCAO VENDA",
                        input 200,
                        input ?, /*opfcod*/
                        input ?, /*emite*/
                        input ?, /*serie*/
                        input ?, /*numero*/
                        input 2, /*crecod*/
                        input ?, /*chave*/
                        input ?,
                        input plani.protot,
                        input plani.frete,
                        input plani.outras,
                        input val-contrato,
                        input val-quitado,
                        input val-devolvido).

                        vtotal = vtotal + plani.platot.
                    end.
                end.
                else do:
                    run cria-temp-devolucao-venda(input "DEVOLUCAO VENDA",
                        input 200,
                        input ?, /*opfcod*/
                        input ?, /*emite*/
                        input ?, /*serie*/
                        input ?, /*numero*/
                        input 1, /*crecod*/
                        input ?, /*chave*/
                        input ?,
                        input plani.protot,
                        input plani.frete,
                        input plani.outras,
                        input val-contrato,
                        input val-quitado,
                        input val-devolvido).

                        vtotal = vtotal + plani.platot.
                end.    
            end.
        end.
        end.
        else do:
            run cria-temp-devolucao-venda(input "DEVOLUCAO VENDA",
                        input 200,
                        input ?, /*opfcod*/
                        input ?, /*emite*/
                        input ?, /*serie*/
                        input ?, /*numero*/
                        input 1, /*crecod*/
                        input ?, /*chave*/
                        input ?,
                        input plani.protot,
                        input plani.frete,
                        input plani.outras,
                        input val-contrato,
                        input val-quitado,
                        input val-avdevolvido).
                   vtotal = vtotal + plani.protot + plani.frete + plani.outras.

        end.
        run cria-temp-devolucao-venda(input "DEVOLUCAO VENDA",
                        input 100,
                        input ?, /*opfcod*/
                        input ?, /*emite*/
                        input ?, /*serie*/
                        input ?, /*numero*/
                        input ?, /*crecod*/
                        input ?, /*chave*/
                        input ?,
                        input plani.protot,
                        input plani.frete,
                        input plani.outras,
                        input val-contrato,
                        input val-quitado,
                        input val-devolvido ).

        run cria-temp-devolucao-venda(input "DEVOLUCAO VENDA",
                        input 400,
                        input ?, /*opfcod*/
                        input plani.emite, /*emite*/
                        input plani.serie, /*serie*/
                        input plani.numero, /*numero*/
                        input ?, /*crecod*/
                        input plani.ufdes, /*chave*/
                        input ?,
                        input plani.protot,
                        input plani.frete,
                        input plani.outras,
                        input val-contrato,
                        input val-quitado,
                        input val-devolvido ).

        /**
        if plani.platot <> vtotal
        then do:
            disp plani.etbcod plani.numero plani.platot vtotal. 
            pause.
        end.    
        **/
     end.
end procedure.

/*************************
procedure devolucao-venda:

    def var vtotal as dec.
    def buffer ctitulo for titulo.
    def buffer bplani for plani.
    def buffer bmovim for movim.
    def var dev-avista as dec.
    def var dev-aprazo as dec.
    def var val-contrato as dec.
    def var val-quitado as dec.
    def var val-devolvido as dec.
    def var val-avdevolvido as dec.
    def var vclifor like titulo.clifor.
    def var vcontrato like contrato.contnum.
    def var vok-categoria as log.
    def var vvaldevolvido_av as dec.

    
d    
    
    for each plani where plani.movtdc = 12 and
         plani.pladat = vdata and
         plani.etbcod = estab.etbcod
         no-lock:
    
        if  month(plani.pladat) <> month(plani.datexp) and
                plani.datexp - plani.pladat > 10
        then next.
        val-contrato = 0.
        val-quitado = 0.
        val-devolvido = 0.
        val-avdevolvido = 0.
        vvaldevolvido_av = 0.
        vtitdev = 0.
        vtitpag = 0.
        vtotal = 0. 

    for each ctdevven where ctdevven.etbcod = estab.etbcod and
                            ctdevven.pladat = vdata and
                            ctdevven.placod-ven = 0
                      no-lock break by ctdevven.placod :

        if first-of(ctdevven.placod)
        then do: 
            find first plani where plani.movtdc = ctdevven.movtdc and
                                   plani.etbcod = ctdevven.etbcod and
                                   plani.placod = ctdevven.placod
                          no-lock no-error.
            if not avail plani
            then next.
            for each movim where movim.movtdc = plani.movtdc and
                                 movim.etbcod = plani.etbcod and
                                 movim.placod = plani.placod
                             no-lock:
                vclifor = movim.ocnum[7].
                ventrada = ventrada + (movim.movpc * movim.movqtm).
            end.

        end.
        
        find first bplani where bplani.movtdc = ctdevven.movtdc-ven and
                                bplani.etbcod = ctdevven.etbcod-ven and
                                bplani.placod = ctdevven.placod-ven 
                          no-lock no-error.        
        if avail bplani
        then
            for each bmovim where bmovim.movtdc = bplani.movtdc and
                                  bmovim.etbcod = bplani.etbcod and
                                  bmovim.placod = bplani.placod
                             no-lock:
                vsaida = vsaida + (bmovim.movpc * bmovim.movqtm).
            end.

        find first cplani where cplani.movtdc = ctdevven.movtdc-ori and
                                cplani.etbcod = ctdevven.etbcod-ori and
                                cplani.placod = ctdevven.placod-ori
                          no-lock no-error.
        if avail cplani
        then do:
            for each cmovim where cmovim.movtdc = cplani.movtdc and
                                  cmovim.etbcod = cplani.etbcod and
                                  cmovim.placod = cplani.placod
                             no-lock:
                vorigem = vorigem + (cmovim.movpc * cmovim.movqtm).
            end.              
            find first contnf where contnf.etbcod = cplani.etbcod and
                                    contnf.placod = cplani.placod
                              no-lock no-error.
            vclifor = cplani.desti.
            if avail contnf
            then vcontrato = contnf.contnum.
            else vcontrato = cplani.numero.

            if avail contnf
            then                    
            for each titulo where titulo.empcod = 19 and
                                  titulo.titnat = no and
                                  titulo.modcod = "CRE" and
                                  titulo.etbcod = cplani.etbcod and
                                  titulo.clifor = cplani.desti  and
                                  titulo.titnum = string(vcontrato) 
                                  no-lock:
                if titulo.titdtemi = cplani.pladat and
                   titulo.moecod = "DEV" and
                   titulo.etbcob = ?
                then assign
                   vtitpag = vtitpag + titulo.titvlcob.
                else if titulo.etbcob = cplani.etbcod and
                        titulo.moecod <> "DEV" and
                        (titulo.titdtpag < plani.pladat
                             or (titulo.titdtpag = plani.pladat and
                                 titulo.titpar = 0))
                then assign
                 vtitdev = vtitdev + titulo.titvlpag.
            end.
            else do:
                find first ctitulo where ctitulo.empcod = 19 and
                                         ctitulo.titnat = yes and
                                         ctitulo.modcod = "DEV" and
                                         ctitulo.etbcod = cplani.etbcod and
                                         ctitulo.clifor = cplani.desti  and
                                         ctitulo.titnum = string(vcontrato) and
                                  /*#2*/ ctitulo.titdtemi = cplani.pladat
                                        no-lock no-error.
                if avail ctitulo
                then do:
                    for each titulo where titulo.empcod = 19 and
                                  titulo.titnat = yes and
                                  titulo.modcod = "DEV" and
                                  titulo.etbcod = cplani.etbcod and
                                /*titulo.clifor = cplani.desti  and*/
                                  titulo.titnum = string(vcontrato) and
                           /*#2*/ titulo.titdtemi = cplani.pladat and
                                  titulo.titdtpag <> ? 
                                  no-lock:
                        assign
                 vtitdev = vtitdev + titulo.titvlpag.
 
                    end.
                end.
                else do:
                    find first titulo where titulo.empcod = 19 and
                                  titulo.titnat = yes and
                                  titulo.modcod = "DEV" and
                                  titulo.etbcod = cplani.etbcod and
                                  titulo.titnum = string(vcontrato) and
                           /*#2*/ titulo.titdtemi = cplani.pladat
                                  no-lock no-error.
                    if avail titulo
                    then do:
                        for each titulo where titulo.empcod = 19 and
                                  titulo.titnat = yes and
                                  titulo.modcod = "DEV" and
                                  titulo.etbcod = cplani.etbcod and
                                  /*titulo.clifor = cplani.desti  and*/
                                  titulo.titnum = string(vcontrato) and
                           /*#2*/ titulo.titdtemi = cplani.pladat
                                  no-lock:
                        assign
                 vtitdev = vtitdev + titulo.titvlpag.
                        end.
                    end.
                    else do:
                        for each titulo where titulo.empcod = 19 and
                                  titulo.titnat = yes and
                                  titulo.modcod = "DEV" and
                                  titulo.etbcod = cplani.etbcod and
                                  /*titulo.clifor = cplani.desti  and*/
                                  titulo.titnum = string(ctdevven.numero) and
                           /*#2*/ titulo.titdtemi = cplani.pladat
                                  no-lock:
                           assign
                 vtitdev = vtitdev + titulo.titvlpag.
                        end.
                     end.
                end.
            end.
            if cplani.crecod = 1
            then do.
                vvista = vvista + cplani.platot.

                /* #2 Valor devolvido a vista */                
                for each titulo where titulo.empcod = 19
                      and titulo.titnat = no
                      and titulo.modcod = cplani.modcod
                      and titulo.etbcod = cplani.etbcod
                      and titulo.clifor = cplani.desti
                      and titulo.titnum = cplani.serie + string(cplani.numero)
                    no-lock.
                    if titulo.moecod = "REA"
                    then assign
                          vvaldevolvido_av = vvaldevolvido_av + titulo.titvlcob.
                    else if titulo.moecod = "PDM"
                    then
                        for each titpag where
                          titpag.empcod = titulo.empcod and
                          titpag.titnat = titulo.titnat and
                          titpag.modcod = titulo.modcod and
                          titpag.etbcod = titulo.etbcod and
                          titpag.clifor = titulo.clifor and
                          titpag.titnum = titulo.titnum and
                          titpag.titpar = titulo.titpar and
                          titpag.moecod = "REA"
                        no-lock:
                          vvaldevolvido_av = vvaldevolvido_av + titpag.titvlpag.
                        end.
                end.
                run cria-temp-devolucao-venda(input "DEVOLUCAO VENDA",
                        input 200,
                        input ?, /*opfcod*/
                        input ?, /*emite*/
                        input ?, /*serie*/
                        input ?, /*numero*/
                        input 1, /*crecod*/
                        input ?, /*chave*/
                        input ?,
                        input plani.protot,
                        input plani.frete,
                        input plani.outras,
                        input val-contrato,
                        input 0,
                        input vvaldevolvido_av).
                        vtotal = vtotal + plani.protot.
                        val-devolvido = val-devolvido + vvaldevolvido_av.

            end.
            else do:
                vprazo = vprazo + cplani.platot.
                run cria-temp-devolucao-venda(input "DEVOLUCAO VENDA",
                        input 200,
                        input ?, /*opfcod*/
                        input ?, /*emite*/
                        input ?, /*serie*/
                        input ?, /*numero*/
                        input 2, /*crecod*/
                        input ?, /*chave*/
                        input ?,
                        input plani.protot,
                        input plani.frete,
                        input plani.outras,
                        input val-contrato,
                        input vtitpag,
                        input vtitdev).

                        vtotal = vtotal + plani.platot.
                        val-quitado = val-quitado + vtitpag.
                        val-devolvido = val-devolvido + vtitdev.
             end.     
        
        end.

        run cria-temp-devolucao-venda(input "DEVOLUCAO VENDA",
                        input 100,
                        input ?, /*opfcod*/
                        input ?, /*emite*/
                        input ?, /*serie*/
                        input ?, /*numero*/
                        input ?, /*crecod*/
                        input ?, /*chave*/
                        input ?,
                        input plani.protot,
                        input plani.frete,
                        input plani.outras,
                        input val-contrato,
                        input val-quitado,
                        input val-devolvido ).

        run cria-temp-devolucao-venda(input "DEVOLUCAO VENDA",
                        input 400,
                        input ?, /*opfcod*/
                        input plani.emite, /*emite*/
                        input plani.serie, /*serie*/
                        input plani.numero, /*numero*/
                        input ?, /*crecod*/
                        input plani.ufdes, /*chave*/
                        input ?,
                        input plani.protot,
                        input plani.frete,
                        input plani.outras,
                        input val-contrato,
                        input val-quitado,
                        input val-devolvido ).


    end.
    
    for each plani where plani.movtdc = 12 and
         plani.pladat = vdata and
         plani.etbcod = estab.etbcod
         no-lock:
    
        if  month(plani.pladat) <> month(plani.datexp) and
                plani.datexp - plani.pladat > 10
        then next.
        val-contrato = 0.
        val-quitado = 0.
        val-devolvido = 0.
        val-avdevolvido = 0.
        vvaldevolvido_av = 0.
        vtitdev = 0.
        vtitpag = 0.
        vtotal = 0. 

 
        
        if plani.etbcod <> 200
        then do:
        for each ctdevven where ctdevven.mvtdc  = plani.movtdc and
                                ctdevven.etbcod = plani.etbcod and
                                ctdevven.placod = plani.placod and  
                                ctdevven.pladat = plani.pladat 
                                no-lock:
                              
            if ctdevven.placod-ven = 0
            then do:
            
                for each movim where movim.movtdc = plani.movtdc and
                                 movim.etbcod = plani.etbcod and
                                 movim.placod = plani.placod
                             no-lock:
                    vclifor = movim.ocnum[7].
                    ventrada = ventrada + (movim.movpc * movim.movqtm).
                end.
        
                find first bplani where 
                           bplani.movtdc = ctdevven.movtdc-ven and
                           bplani.etbcod = ctdevven.etbcod-ven and
                           bplani.placod = ctdevven.placod-ven 
                           no-lock no-error.        
                if avail bplani
                then
                for each bmovim where bmovim.movtdc = bplani.movtdc and
                                  bmovim.etbcod = bplani.etbcod and
                                  bmovim.placod = bplani.placod
                             no-lock:
                    vsaida = vsaida + (bmovim.movpc * bmovim.movqtm).
                end.

                find first cplani where 
                           cplani.movtdc = ctdevven.movtdc-ori and
                           cplani.etbcod = ctdevven.etbcod-ori and
                           cplani.placod = ctdevven.placod-ori
                           no-lock no-error.
                if avail cplani
                then do:
                    for each cmovim where cmovim.movtdc = cplani.movtdc and
                                  cmovim.etbcod = cplani.etbcod and
                                  cmovim.placod = cplani.placod
                             no-lock:
                        vorigem = vorigem + (cmovim.movpc * cmovim.movqtm).
                    end.              
                    vclifor = cplani.desti.
                    find first contnf where contnf.etbcod = cplani.etbcod and
                                    contnf.placod = cplani.placod
                              no-lock no-error.
                    if avail contnf
                    then vcontrato = contnf.contnum.
                    else vcontrato = cplani.numero.

                    if avail contnf
                    then do:
                        find contrato where contrato.contnum = vcontrato
                                            no-lock no-error.
                        if avail contrato
                        then val-contrato = contrato.vltotal.                  
                    for each titulo where titulo.empcod = 19 and
                                  titulo.titnat = no and
                                  titulo.modcod = "CRE" and
                                  titulo.etbcod = cplani.etbcod and
                                  titulo.clifor = cplani.desti  and
                                  titulo.titnum = string(vcontrato) 
                                  no-lock:
                        if titulo.titdtemi = cplani.pladat and
                            titulo.moecod = "DEV" and
                            titulo.etbcob = ?
                        then assign
                            vtitpag = vtitpag + titulo.titvlcob.
                        else if titulo.etbcob = cplani.etbcod and
                            titulo.moecod <> "DEV" and
                            (titulo.titdtpag < plani.pladat
                             or (titulo.titdtpag = plani.pladat and
                                 titulo.titpar = 0))
                        then assign
                             vtitdev = vtitdev + titulo.titvlpag.
                    end.
                    end.
                    else do:
                        find first ctitulo where ctitulo.empcod = 19 and
                                         ctitulo.titnat = yes and
                                         ctitulo.modcod = "DEV" and
                                         ctitulo.etbcod = cplani.etbcod and
                                         ctitulo.clifor = cplani.desti  and
                                         ctitulo.titnum = string(vcontrato) and
                                  /*#2*/ ctitulo.titdtemi = cplani.pladat
                                        no-lock no-error.
                        if avail ctitulo
                        then do:
                            for each titulo where titulo.empcod = 19 and
                                  titulo.titnat = yes and
                                  titulo.modcod = "DEV" and
                                  titulo.etbcod = cplani.etbcod and
                                /*titulo.clifor = cplani.desti  and*/
                                  titulo.titnum = string(vcontrato) and
                           /*#2*/ titulo.titdtemi = cplani.pladat and
                                  titulo.titdtpag <> ? 
                                  no-lock:
                                assign
                                vtitdev = vtitdev + titulo.titvlpag.
 
                            end.
                        end.
                        else do:
                            find first titulo where titulo.empcod = 19 and
                                  titulo.titnat = yes and
                                  titulo.modcod = "DEV" and
                                  titulo.etbcod = cplani.etbcod and
                                  titulo.titnum = string(vcontrato) and
                           /*#2*/ titulo.titdtemi = cplani.pladat
                                  no-lock no-error.
                            if avail titulo
                            then do:
                                for each titulo where titulo.empcod = 19 and
                                  titulo.titnat = yes and
                                  titulo.modcod = "DEV" and
                                  titulo.etbcod = cplani.etbcod and
                                  /*titulo.clifor = cplani.desti  and*/
                                  titulo.titnum = string(vcontrato) and
                           /*#2*/ titulo.titdtemi = cplani.pladat
                                  no-lock:
                                 vtitdev = vtitdev + titulo.titvlpag.
                                end.
                            end.
                            else do:
                                for each titulo where titulo.empcod = 19 and
                                  titulo.titnat = yes and
                                  titulo.modcod = "DEV" and
                                  titulo.etbcod = cplani.etbcod and
                                  /*titulo.clifor = cplani.desti  and*/
                                  titulo.titnum = string(ctdevven.numero) and
                           /*#2*/ titulo.titdtemi = cplani.pladat
                                  no-lock:
                                 vtitdev = vtitdev + titulo.titvlpag.
                                end.
                            end.
                        end.
                    end.
                    if cplani.crecod = 1
                    then do.
                        vvista = vvista + cplani.platot.

                        for each titulo where titulo.empcod = 19
                            and titulo.titnat = no
                            and titulo.modcod = cplani.modcod
                            and titulo.etbcod = cplani.etbcod
                            and titulo.clifor = cplani.desti
                            and titulo.titnum = 
                                cplani.serie + string(cplani.numero)
                            no-lock.
                            if titulo.moecod = "REA"
                            then assign
                                vvaldevolvido_av = 
                                vvaldevolvido_av + titulo.titvlcob.
                            else if titulo.moecod = "PDM"
                            then
                            for each titpag where
                                titpag.empcod = titulo.empcod and
                                titpag.titnat = titulo.titnat and
                                titpag.modcod = titulo.modcod and
                                titpag.etbcod = titulo.etbcod and
                                titpag.clifor = titulo.clifor and
                                titpag.titnum = titulo.titnum and
                                titpag.titpar = titulo.titpar and
                                titpag.moecod = "REA"
                                no-lock:
                                vvaldevolvido_av = 
                                vvaldevolvido_av + titpag.titvlpag.
                            end.
                        end.

                        run cria-temp-devolucao-venda(input "DEVOLUCAO VENDA",
                        input 200,
                        input ?, /*opfcod*/
                        input ?, /*emite*/
                        input ?, /*serie*/
                        input ?, /*numero*/
                        input 1, /*crecod*/
                        input ?, /*chave*/
                        input ?,
                        input plani.protot,
                        input plani.frete,
                        input plani.outras,
                        input val-contrato,
                        input 0,
                        input vvaldevolvido_av).
                        vtotal = vtotal + plani.protot.
                        val-devolvido = val-devolvido + vvaldevolvido_av.
                    end.
                    else do:
                        vprazo = vprazo + cplani.platot. 
                        run cria-temp-devolucao-venda(input "DEVOLUCAO VENDA",
                        input 200,
                        input ?, /*opfcod*/
                        input ?, /*emite*/
                        input ?, /*serie*/
                        input ?, /*numero*/
                        input 2, /*crecod*/
                        input ?, /*chave*/
                        input ?,
                        input plani.protot,
                        input plani.frete,
                        input plani.outras,
                        input val-contrato,
                        input vtitpag,
                        input vtitdev).

                        vtotal = vtotal + plani.platot.
                        val-quitado = val-quitado + vtitpag.
                        val-devolvido = val-devolvido + vtitdev.
                        
                    end.
                end.
                else do:
                    disp plani.etbcod plani.numero. pause.
                end.
            end.
            else do:
                find first cplani where 
                           cplani.movtdc = ctdevven.movtdc-ori and
                           cplani.etbcod = ctdevven.etbcod-ori and
                           cplani.placod = ctdevven.placod-ori
                           no-lock no-error.
                if avail cplani
                then do:
                    if cplani.crecod = 1
                    then do:
                        run cria-temp-devolucao-venda(input "DEVOLUCAO VENDA",
                        input 200,
                        input ?, /*opfcod*/
                        input ?, /*emite*/
                        input ?, /*serie*/
                        input ?, /*numero*/
                        input 1, /*crecod*/
                        input ?, /*chave*/
                        input ?,
                        input plani.protot,
                        input plani.frete,
                        input plani.outras,
                        input val-contrato,
                        input val-quitado,
                        input val-devolvido).
                        
                        vtotal = vtotal + plani.platot.

                    end.
                    else do:
                        run cria-temp-devolucao-venda(input "DEVOLUCAO VENDA",
                        input 200,
                        input ?, /*opfcod*/
                        input ?, /*emite*/
                        input ?, /*serie*/
                        input ?, /*numero*/
                        input 2, /*crecod*/
                        input ?, /*chave*/
                        input ?,
                        input plani.protot,
                        input plani.frete,
                        input plani.outras,
                        input val-contrato,
                        input val-quitado,
                        input val-devolvido).

                        vtotal = vtotal + plani.platot.
                    end.
                end.
                else do:
                    run cria-temp-devolucao-venda(input "DEVOLUCAO VENDA",
                        input 200,
                        input ?, /*opfcod*/
                        input ?, /*emite*/
                        input ?, /*serie*/
                        input ?, /*numero*/
                        input 1, /*crecod*/
                        input ?, /*chave*/
                        input ?,
                        input plani.protot,
                        input plani.frete,
                        input plani.outras,
                        input val-contrato,
                        input val-quitado,
                        input val-devolvido).

                        vtotal = vtotal + plani.platot.
                end.    
            end.
        end.
        end.
        else do:
            run cria-temp-devolucao-venda(input "DEVOLUCAO VENDA",
                        input 200,
                        input ?, /*opfcod*/
                        input ?, /*emite*/
                        input ?, /*serie*/
                        input ?, /*numero*/
                        input 1, /*crecod*/
                        input ?, /*chave*/
                        input ?,
                        input plani.protot,
                        input plani.frete,
                        input plani.outras,
                        input val-contrato,
                        input val-quitado,
                        input val-avdevolvido).
                   vtotal = vtotal + plani.protot + plani.frete + plani.outras.

        end.
        run cria-temp-devolucao-venda(input "DEVOLUCAO VENDA",
                        input 100,
                        input ?, /*opfcod*/
                        input ?, /*emite*/
                        input ?, /*serie*/
                        input ?, /*numero*/
                        input ?, /*crecod*/
                        input ?, /*chave*/
                        input ?,
                        input plani.protot,
                        input plani.frete,
                        input plani.outras,
                        input val-contrato,
                        input val-quitado,
                        input val-devolvido ).

        run cria-temp-devolucao-venda(input "DEVOLUCAO VENDA",
                        input 400,
                        input ?, /*opfcod*/
                        input plani.emite, /*emite*/
                        input plani.serie, /*serie*/
                        input plani.numero, /*numero*/
                        input ?, /*crecod*/
                        input plani.ufdes, /*chave*/
                        input ?,
                        input plani.protot,
                        input plani.frete,
                        input plani.outras,
                        input val-contrato,
                        input val-quitado,
                        input val-devolvido ).

        if plani.platot <> vtotal
        then do:
            disp plani.etbcod plani.numero plani.platot vtotal. 
            pause.
        end.    
        
     end.
end procedure.
***************************/



procedure estorno-cancelamento-financeira:
       
        vcobcod = 2.
        
        for each fc-contrato: delete fc-contrato. end.
        
        for each envfinan where 
                     envfinan.etbcod = estab.etbcod and
                     envfinan.envsit = "CAN" and
                     envfinan.dt1 = vdata
                     no-lock.
                     
                find first fin.titulo where
                           titulo.empcod = envfinan.empcod and
                           titulo.titnat = envfinan.titnat and
                           titulo.modcod = envfinan.modcod and
                           titulo.etbcod = envfinan.etbcod and
                           titulo.clifor = envfinan.clifor and
                           titulo.titnum = envfinan.titnum and
                           titulo.titpar = envfinan.titpar
                           no-lock no-error.
                if not avail titulo then next.
                           
                find first fc-contrato where
                          fc-contrato.contnum = int(envfinan.titnum)
                          no-error.
                if not avail fc-contrato
                then do:
                    create fc-contrato.
                    assign
                        fc-contrato.contnum   = int(envfinan.titnum)
                        fc-contrato.etbcod    = envfinan.etbcod 
                        fc-contrato.clicod    = envfinan.clifor 
                        fc-contrato.dtinicial = envfinan.dt1 
                        .
                end.
                fc-contrato.vltotal = 
                    fc-contrato.vltotal + titulo.titvlcob.
        end.

        for each envfinan where 
                     envfinan.etbcod = estab.etbcod and
                     envfinan.envsit = "EST" and
                     envfinan.dt1 = vdata
                     no-lock.
                     
            find first fin.titulo where
                           titulo.empcod = envfinan.empcod and
                           titulo.titnat = envfinan.titnat and
                           titulo.modcod = envfinan.modcod and
                           titulo.etbcod = envfinan.etbcod and
                           titulo.clifor = envfinan.clifor and
                           titulo.titnum = envfinan.titnum and
                           titulo.titpar = envfinan.titpar
                           no-lock no-error.
            if not avail titulo then next.
                           
            find first fc-contrato where
                          fc-contrato.contnum = int(envfinan.titnum)
                          no-error.
            if not avail fc-contrato
            then do:
                    create fc-contrato.
                    assign
                        fc-contrato.contnum   = int(envfinan.titnum)
                        fc-contrato.etbcod    = envfinan.etbcod 
                        fc-contrato.clicod    = envfinan.clifor 
                        fc-contrato.dtinicial = envfinan.dt1 
                        .
            end.
            fc-contrato.vltotal = 
                    fc-contrato.vltotal + titulo.titvlcob.
                
        end.
        
        for each fc-contrato no-lock:
     
                find fin.contrato where contrato.contnum =
                            fc-contrato.contnum no-lock no-error.
                if not avail contrato then next.            
                
                
            run /admcom/progr/ctb/retorna-pacnv-valores-contrato.p 
                    (input ?, 
                     input recid(contrato), 
                     input ?).
            
            if pacnv-seguro = ? then pacnv-seguro = 0.
            if pacnv-entrada = ? then pacnv-entrada = 0.
            if pacnv-principal = ? then pacnv-principal = 0.
            if pacnv-acrescimo = ? then pacnv-acrescimo = 0.
            if pacnv-orinf = ? then pacnv-orinf = 0.
            if pacnv-orinl = ? then pacnv-orinl = 0.
            if pacnv-abate = ? then pacnv-abate = 0.

            run cria-temp-contrato(input "ESTORNO FINANCEIRA",
                                input 0,
                                input ?, /*modcod*/
                                input ?, /*cobcod*/
                                input ?, /*contnum*/
                                input contrato.vltotal, 
                                input pacnv-entrada, 
                                input pacnv-principal, 
                                input pacnv-acrescimo,
                                input pacnv-seguro,
                                input pacnv-orinf + pacnv-orinl,
                                input pacnv-orinf,
                                input pacnv-orinl,
                                input pacnv-abate).

            run cria-temp-contrato(input "ESTORNO FINANCEIRA",
                                input 10,
                                input ?, /*modcod*/
                                input ?, /*cobcod*/
                                input ?, /*contnum*/
                                input contrato.vltotal, 
                                input pacnv-entrada, 
                                input pacnv-principal, 
                                input pacnv-acrescimo,
                                input pacnv-seguro,
                                input pacnv-orinf + pacnv-orinl,
                                input pacnv-orinf,
                                input pacnv-orinl,
                                input pacnv-abate).

                run cria-temp-contrato(input "ESTORNO FINANCEIRA",
                                input 20,
                                input contrato.modcod, /*modcod*/
                                input ?, /*cobcod*/
                                input ?, /*contnum*/
                                input contrato.vltotal, 
                                input pacnv-entrada, 
                                input pacnv-principal, 
                                input pacnv-acrescimo,
                                input pacnv-seguro,
                                input pacnv-orinf + pacnv-orinl,
                                input pacnv-orinf,
                                input pacnv-orinl,
                                input pacnv-abate).
                run cria-temp-contrato(input "ESTORNO FINANCEIRA",
                                input 30,
                                input contrato.modcod, /*modcod*/
                                input vcobcod, /*cobcod*/
                                input ?, /*contnum*/
                                input contrato.vltotal, 
                                input pacnv-entrada, 
                                input pacnv-principal, 
                                input pacnv-acrescimo,
                                input pacnv-seguro,
                                input pacnv-orinf + pacnv-orinl,
                                input pacnv-orinf,
                                input pacnv-orinl,
                                input pacnv-abate).
                run cria-temp-contrato(input "ESTORNO FINANCEIRA",
                                input 40,
                                input contrato.modcod, /*modcod*/
                                input vcobcod, /*cobcod*/
                                input contrato.contnum, /*contnum*/
                                input contrato.vltotal, 
                                input pacnv-entrada, 
                                input pacnv-principal, 
                                input pacnv-acrescimo,
                                input pacnv-seguro,
                                input pacnv-orinf + pacnv-orinl,
                                input pacnv-orinf,
                                input pacnv-orinl,
                                input pacnv-abate).
         
        end.
end procedure.
