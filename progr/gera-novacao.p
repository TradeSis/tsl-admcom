{admcab.i}

def input parameter p-clicod like clien.clicod.
def input parameter vtot as dec.
def input parameter ventrada as dec.
def input parameter vezes as int.
def input parameter vbanco as int.
def input parameter p-tipnova as int.
def input parameter vdata as date.

def var nov31 as log init yes.

if p-tipnova = 51
then nov31 = no.

def var i as int.
def var wcon as int.
def var vday as int.
def var vmes as int.
def var vano as int.
def var recid-contrato as recid.

find first clien where clien.clicod = p-clicod no-lock.

def temp-table wf-tit like fin.titulo.
def temp-table wf-contrato like contrato.
def temp-table wf-titulo like titulo.

def shared temp-table tp-contrato like contrato
    field exportado as log
    field atraso as int
    field vlpago as dec
    field vlpendente as dec
    .
    
def shared temp-table tp-titulo like fin.titulo
    index dt-ven titdtven
    index titnum empcod titnat modcod etbcod clifor titnum titpar.

def new shared temp-table tt-recib
        field rectit as recid
        field titnum like titulo.titnum
        field ordpre as int.
 
def var vgera like contrato.contnum.

    do on error undo:        
        for each tp-titulo:     
          

            assign tp-titulo.titdtpag = today
                   tp-titulo.etbcobra = setbcod 
                   tp-titulo.datexp   = today 
                   tp-titulo.cxmdata  = today 
                   tp-titulo.cxacod   = scxacod 
                   tp-titulo.moecod   = "NOV" 
                   tp-titulo.titsit   = "PAG" 
                   tp-titulo.titvlpag = tp-titulo.titvlcob.
               
            create wf-tit.
            {tt-titulo.i wf-tit tp-titulo}.
    
        end. 

        /********************* GERA TITULOS DE NOVACAO ***********************/
    
        run p-geraclicod.p (input setbcod,
                        output vgera).

        create wf-contrato.

        if setbcod >= 100
        then wf-contrato.contnum =  int("1" + string(setbcod,"999") +
                                          string(vgera,"999999")).
        else wf-contrato.contnum = int(string(string(vgera,"99999999") +
                                   string(setbcod,"99"))).

        assign wf-contrato.clicod    = clien.clicod
           wf-contrato.dtinicial = today 
           wf-contrato.etbcod    = setbcod 
           wf-contrato.datexp    = today 
           wf-contrato.vltotal   = vtot 
           wf-contrato.vlentra   = ventrada
           wf-contrato.banco = vbanco.
    
     
        /*******************************  ENTRADA *************************/
        do on error undo: 
            create wf-titulo.
            assign wf-titulo.empcod = wempre.empcod
               wf-titulo.modcod = "CRE"
               wf-titulo.cxacod = scxacod
               wf-titulo.cliFOR = clien.clicod
               wf-titulo.titnum = string(wf-contrato.contnum) 
               wf-titulo.titpar = 0
               wf-titulo.titnat = no
               wf-titulo.etbcod = setbcod
               wf-titulo.titdtemi = today
               wf-titulo.titdtven = today
               /*wf-titulo.titdtpag = today*/
               wf-titulo.titvlpag = 0 /*ventrada*/
               wf-titulo.titvlcob = ventrada
               wf-titulo.cobcod = 2
               wf-titulo.titsit = /*"PAG"*/ "LIB"
               /*wf-titulo.etbcobra = setbcod*/
               
               wf-titulo.datexp = today
               /*wf-titulo.moecod = "NOV"*/ .

            down with frame f4.
            display  wf-titulo.titpar column-label "PC"
                 wf-titulo.titnum column-label "Contrato"
                 wf-titulo.titdtemi column-label "Emissao"
                 wf-titulo.titdtven column-label "Vencimento"
                 wf-titulo.titvlcob format ">,>>>,>>9.99"
                 wf-titulo.titsit 
                        column-label "Vl.Cob" with frame f4 down centered
                 title " Pagar Entrada na tela de Caixa ".
            down with frame f4.
        
        end.
        
        /******************************************************************/
    
        vdata = today + 30.

        if nov31
        then wcon = 30.
        else wcon = 50.
        vday = day(vdata).


        vtot = vtot - ventrada.
    
        vmes = month(vdata).
        vano = year(vdata).
    
        if vmes = 1
        then assign vmes = 12
                vano = year(vdata) - 1.
                
        else assign vmes = month(vdata) - 1
                vano = year(vdata).
    
        vdata = date(vmes,day(vdata),vano). 
    
        
        vdata = date(vmes,day(vdata),vano). 

        vano = year(vdata).
    
        do i = 1 to vezes - 1:
                      
    
            assign wcon = wcon + 1
               vmes = vmes + 1.
                 
            if vmes > 12 
            then assign vano = vano + 1
                    vmes = 1.
        
            do on error undo: 
                create wf-titulo.
                assign wf-titulo.empcod = wempre.empcod
                   wf-titulo.modcod = "CRE"
                   wf-titulo.cxacod = scxacod
                   wf-titulo.cliFOR = clien.clicod
                   wf-titulo.titnum = string(wf-contrato.contnum) 
                   wf-titulo.titpar = wcon
                   wf-titulo.titnat = no
                   wf-titulo.etbcod = setbcod
                   wf-titulo.titdtemi = today
                   wf-titulo.titdtven = date(vmes,
                                        IF VMES = 2
                                        THEN IF VDAY > 28
                                             THEN 28
                                             ELSE VDAY
                                        ELSE if VDAY > 30
                                             then 30
                                             else vday,
                                        vano)

                   wf-titulo.titvlcob = vtot / ( vezes - 1)
                   wf-titulo.cobcod = 2
                   wf-titulo.titsit = "LIB"
                   wf-titulo.datexp = today.

            end.
        
            down with frame f4.
        
            display  wf-titulo.titpar column-label "PC"
                 wf-titulo.titnum column-label "Contrato"
                 wf-titulo.titdtemi column-label "Emissao"
                 wf-titulo.titdtven column-label "Vencimento"
                 wf-titulo.titvlcob format ">,>>>,>>9.99"
                 wf-titulo.titsit
                        column-label "Vl.Cob" with frame f4 down centered.
        
            down with frame f4.
        
        end.

    
        for each tp-titulo:
            delete tp-titulo.
        end.
    
        find first wf-titulo where wf-titulo.titpar = 0 no-error.
        if avail wf-titulo
        then do:
            create tp-titulo.
            {tt-titulo.i tp-titulo wf-titulo}.
        end.
    
    
        for each tp-titulo:
              
            find titulo where titulo.empcod = tp-titulo.empcod
                          and titulo.titnat = tp-titulo.titnat
                          and titulo.modcod = tp-titulo.modcod
                          and titulo.clifor = tp-titulo.clifor
                          and titulo.etbcod = tp-titulo.etbcod
                          and titulo.titnum = tp-titulo.titnum
                          and titulo.titpar = tp-titulo.titpar no-error.
            if avail titulo
            then do transaction:
                assign titulo.titsit   = tp-titulo.titsit
                   titulo.titdtpag = tp-titulo.titdtpag
                   titulo.titvlpag = tp-titulo.titvlpag
                   titulo.titvlcob = tp-titulo.titvlcob
                   titulo.titjuro  = tp-titulo.titjuro
                   titulo.titdesc  = tp-titulo.titdesc
                   titulo.titvljur = tp-titulo.titvljur
                   titulo.cxacod   = tp-titulo.cxacod
                   titulo.cxmdata  = tp-titulo.cxmdata
                   titulo.etbcobra = tp-titulo.etbcobra
                   titulo.datexp   = tp-titulo.datexp
                   titulo.moecod   = tp-titulo.moecod.
            end.
            else do transaction:
                create titulo.
                assign titulo.empcod   = tp-titulo.empcod
                   titulo.modcod   = tp-titulo.modcod
                   titulo.clifor   = tp-titulo.clifor
                   titulo.titnum   = tp-titulo.titnum 
                   titulo.titpar   = tp-titulo.titpar 
                   titulo.titsit   = tp-titulo.titsit 
                   titulo.titnat   = tp-titulo.titnat 
                   titulo.etbcod   = tp-titulo.etbcod 
                   titulo.titdtemi = tp-titulo.titdtemi 
                   titulo.titdtven = tp-titulo.titdtven 
                   titulo.titdtpag = today 
                   titulo.titvlcob = tp-titulo.titvlcob 
                   titulo.cobcod   = tp-titulo.cobcod 
                   titulo.titvlpag = tp-titulo.titvlpag 
                   titulo.titvljur = tp-titulo.titvljur 
                   titulo.etbcobra = tp-titulo.etbcobra 
                   titulo.titjuro  = tp-titulo.titjuro 
                   titulo.titdesc  = tp-titulo.titdesc 
                   titulo.cxacod   = tp-titulo.cxacod 
                   titulo.cxmdata  = tp-titulo.cxmdata 
                   titulo.datexp   = tp-titulo.datexp
                   titulo.moecod   = tp-titulo.moecod.
            end.

            find first tt-recib where tt-recib.titnum = tp-titulo.titnum and
                                  tt-recib.ordpre = tp-titulo.titpar
                            no-error.
            if not avail tt-recib /* and tp-titulo.titpar <> 0 */
            then do:
                 create tt-recib.
                assign tt-recib.rectit = recid(tp-titulo)
                    tt-recib.ordpre = tp-titulo.titpar
                    tt-recib.titnum = tp-titulo.titnum.
            end.

        end.    
    
        find first tt-recib no-error.
        if avail tt-recib
        then do:
             run value(srecibo) (input tt-recib.rectit,
                            input tt-recib.titnum).
        end.

        if nov31
        then run novfil-novacao.p(output recid-contrato).
        else do:
    
            repeat:
        
                message "Conectando.....D .".
            connect dragao -H erp.lebes.com.br -S sdragao -N tcp -ld d no-error.
        
                if not connected ("d")
                then do:  
                    if i = 1  
                    then leave.  
                    i = i + 1.  
                    next.  
                end.   
                else leave.
        
            end.
    
            run novdrag-novacao.p(output recid-contrato).

            disconnect d.
            hide message no-pause.
    
        end.            
    
        /************ PAGAMENTO DE PRESTACOES ANTIGAS *************/
    
        for each wf-tit:
        
            find titulo where titulo.empcod = wf-tit.empcod
                          and titulo.titnat = wf-tit.titnat
                          and titulo.modcod = wf-tit.modcod
                          and titulo.clifor = wf-tit.clifor
                          and titulo.etbcod = wf-tit.etbcod
                          and titulo.titnum = wf-tit.titnum
                          and titulo.titpar = wf-tit.titpar
                                use-index titnum no-error.
            if avail titulo
            then do transaction:
                assign titulo.titsit   = wf-tit.titsit
                   titulo.titdtpag = wf-tit.titdtpag
                   titulo.titvlpag = wf-tit.titvlpag
                   titulo.moecod   = wf-tit.moecod
                   titulo.titvlcob = wf-tit.titvlcob
                   titulo.titjuro  = wf-tit.titjuro
                   titulo.titdesc  = wf-tit.titdesc
                   titulo.titvljur = wf-tit.titvljur
                   titulo.cxacod   = wf-tit.cxacod
                   titulo.cxmdata  = wf-tit.cxmdata
                   titulo.etbcobra = wf-tit.etbcobra
                   titulo.datexp   = wf-tit.datexp.
            end.
            else do transaction:
                create titulo.
                assign titulo.empcod   = wf-tit.empcod
                   titulo.modcod   = wf-tit.modcod
                   titulo.clifor   = wf-tit.clifor
                   titulo.titnum   = wf-tit.titnum 
                   titulo.titpar   = wf-tit.titpar 
                   titulo.titsit   = wf-tit.titsit
                   titulo.moecod   = wf-tit.moecod
                   titulo.titnat   = wf-tit.titnat 
                   titulo.etbcod   = wf-tit.etbcod 
                   titulo.titdtemi = wf-tit.titdtemi 
                   titulo.titdtven = wf-tit.titdtven 
                   titulo.titdtpag = today 
                   titulo.titvlcob = wf-tit.titvlcob 
                   titulo.cobcod   = wf-tit.cobcod 
                   titulo.titvlpag = wf-tit.titvlpag 
                   titulo.titvljur = wf-tit.titvljur 
                   titulo.etbcobra = wf-tit.etbcobra 
                   titulo.titjuro  = wf-tit.titjuro 
                   titulo.titdesc  = wf-tit.titdesc 
                   titulo.cxacod   = wf-tit.cxacod 
                   titulo.cxmdata  = wf-tit.cxmdata 
                   titulo.datexp   = wf-tit.datexp.
            end.
            do on error undo:
                create tit_novacao.
                assign
                 tit_novacao.ger_contnum = wf-contrato.contnum
                 tit_novacao.id_acordo = ""
                 tit_novacao.ori_empcod = wf-titulo.empcod
                 tit_novacao.ori_titnat = wf-titulo.titnat
                 tit_novacao.ori_modcod = wf-titulo.modcod
                 tit_novacao.ori_etbcod = wf-titulo.etbcod
                 tit_novacao.ori_clifor = wf-titulo.clifor
                 tit_novacao.ori_titnum = wf-titulo.titnum
                 tit_novacao.ori_titpar = wf-titulo.titpar
                 tit_novacao.ori_titdtemi = wf-titulo.titdtemi
                 tit_novacao.dtnovacao = today
                 tit_novacao.hrnovacao = time
                 tit_novacao.etbnovacao = setbcod
                 tit_novacao.funcod = sfuncod       
                 .
            end.
        end.    
    
        find first wf-contrato no-error.
        if avail wf-contrato
        then do:
            message "Vc Confirma a Emissao do Controle de Vencimentos ?" 
            update sresp.
            hide message. 
            if sresp 
            then do:
   
                find caixa where caixa.etbcod = setbcod and
                             caixa.cxacod = scxacod no-lock no-error.
                if caixa.moecod = "bar"
                then run carne_n.p.
    
                if wf-contrato.banco = 10
                then run contratoimp-novacao.p(recid-contrato).

                
            end.  
        end.
    
    end. 