{admcab.i}

def temp-table tt-pro
    field etbcod as int
    field clicod as int
    field procod as int.
def var vlista-pro as log format "Sim/Nao".
    
def var totcon like plani.platot.
def var vtip as char format "x(20)" extent 2 
        initial ["Analitico","Sintetico"].
        
def var vv as char.
def var varquivo    as char.
def var vdtini      like plani.pladat.
def var vdtfin      like plani.pladat.
def var vetbcod     like estab.etbcod.

def var t-entrada as dec.
def var t-parcela as dec.
def var t-qtdpar as int.

def var vetbcod-aux as integer.

def temp-table wcli
    field wcli  like clien.clicod
    field wetb  like estab.etbcod
    field wnom  like clien.clinom
    field wcad  like clien.dtcad
    field wcom  like titulo.titvlcob
    field wvent  like titulo.titvlcob
    field wvpar  like titulo.titvlcob
    field wqpar  like titulo.titpar
    index i1 wcli.
    
def temp-table wfil
    field etbcod like estab.etbcod
    field totcli as int
    field totven like plani.platot
    field totent like plani.platot
    field totpar like plani.platot .

repeat:
    
    for each wcli:
        delete wcli.
    end.

    for each wfil:
        delete wfil.
    end.
    for each tt-pro. delete tt-pro. end.
    
    update vetbcod colon 20 with frame f1.
    if vetbcod = 0
    then display "GERAL" @ estab.etbnom with frame f1.
    else do:
        find estab where estab.etbcod = vetbcod no-lock no-error.
        if not avail estab
        then do:
            message "Estabelecimento Invalido".
            undo.
        end.
    
        display estab.etbnom no-label with frame f1.
    end.
    
    update vdtini  colon 20 label "Periodo"
           vdtfin  no-label with frame f1 centered side-label width 80.

    for each clien where clien.dtcad >= vdtini and
                         clien.dtcad <= vdtfin no-lock.
                         
    
        
        display clien.clicod
                substring(string(clien.clicod),7,2) 
                        with frame f3 1 down centered. 
        pause 0.                
                        
                
        
        if vetbcod = 0
        then.
        else do:
        
            if length(string(clien.clicod)) < 10
            then do:
                if int(substring(string(clien.clicod),
                        length(string(clien.clicod)) - 1,2)) <> vetbcod 
                then next.
            end.
            else do:
                if int(substring(string(clien.clicod),2,3)) <> vetbcod
                then next.
            end.
            
        end.
        
        assign
            totcon = 0
            t-entrada = 0
            t-parcela = 0
            t-qtdpar = 0.
        for each contrato where contrato.clicod = clien.clicod no-lock:
            totcon = totcon + contrato.vltotal.
        end.
            
        if totcon = 0
        then next.
            
        if totcon <> 0
        then do:
            for each contrato where contrato.clicod = clien.clicod no-lock:
                for each contnf where 
                         contnf.etbcod  = contrato.etbcod and
                         contnf.contnum = contrato.contnum no-lock:
                    find first plani where 
                               plani.etbcod = contnf.etbcod
                           and plani.placod = contnf.placod
                           and plani.desti  = clien.clicod
                           and plani.movtdc = 5 no-lock no-error.
                    if avail plani
                    then do: 
                        for each movim where movim.etbcod = plani.etbcod
                                        and movim.placod = plani.placod
                                        and movim.movtdc = plani.movtdc
                                        and movim.movdat = plani.pladat no-lock:
                            find tt-pro where tt-pro.etbcod = plani.etbcod
                                          and tt-pro.clicod = plani.desti
                                          and tt-pro.procod = movim.procod
                                          no-error.
                            if not avail tt-pro
                            then do:
                                create tt-pro.
                                assign tt-pro.etbcod = plani.etbcod
                                       tt-pro.clicod = plani.desti
                                       tt-pro.procod = movim.procod.
                            end.
                            
                        end.
                    end.
                end.
                for each titulo where titulo.empcod = 19 and
                                      titulo.titnat = no and
                                      titulo.modcod = "CRE" and
                                      titulo.etbcod = contrato.etbcod and
                                      titulo.clifor = contrato.clicod and
                                      titulo.titnum = string(contrato.contnum)
                                       no-lock:
                    if titulo.titpar = 0
                    then t-entrada = t-entrada + titulo.titvlcob.
                    else do:
                        t-parcela = t-parcela + titulo.titvlcob.
                        if titulo.titpar > t-qtdpar
                        then t-qtdpar = titulo.titpar.              
                    end.
                end.                
            end.
        end.

        if length(string(clien.clicod)) < 10
        then do:
            assign vetbcod-aux = int(substring(string(clien.clicod),
                                   length(string(clien.clicod)) - 1,2)).
        end.
        else do:
            assign vetbcod-aux = int(substring(string(clien.clicod),2,3)).
        end.

        find first wcli where wcli.wcli = clien.clicod no-error.
        if not avail wcli
        then do:
           
            create wcli.
            assign wcli.wcli  = clien.clicod
                   wcli.wetb  = vetbcod-aux
                   wcli.wcad  = clien.dtcad
                   wcli.wnom  = clien.clinom
                   wcli.wcom  = totcon
                   wcli.wvent = t-entrada
                   wcli.wvpar = t-parcela
                   wcli.wqpar = t-qtdpar.
                   
        end.
        
        find first wfil where 
                wfil.etbcod = vetbcod-aux
                        no-error. 
        if not avail wfil
        then do:
            create wfil.
            assign wfil.etbcod = vetbcod-aux.
        end.

        assign wfil.totcli = wfil.totcli + 1
               wfil.totven = wfil.totven + totcon
               wfil.totent = wfil.totent + t-entrada
               wfil.totpar = wfil.totpar + t-parcela
               .
    
    end.
    leave.
end.
def var vrelat as log format "Sim/Nao".
def var vacao as log format "Sim/Nao".

def new shared temp-table tt-cli
    
    field clicod like clien.clicod
    field clinom like clien.clinom
    
    index iclicod is primary unique clicod.

repeat:
    vrelat = no . vacao = no.
    
    update vrelat label "Relatorio"
               vacao   label "Acao"
               with frame f-tipo 1 down centered row 7 side-label.
    if vrelat = no and vacao = no
    then leave.
    for each tt-cli:
      delete tt-cli.
    end.  
    if vrelat
    then do:
    display vtip with frame f-tip no-label.
    choose field vtip with frame f-tip centered row 11.
    if frame-index = 1
    then do:
        vv = "A".
        message "Listar produtos?" update vlista-pro.
    end.        
    else vv = "S".


    if opsys = "UNIX"
    then varquivo = "/admcom/relat/cre011." + string(time).
    else varquivo = "..\relat\cre011." + string(time).
    
    {mdad.i
        &Saida     = "value(varquivo)"
        &Page-Size = "64"
        &Cond-Var  = "130"
        &Page-Line = "66"
        &Nom-Rel   = """CRE011"""
        &Nom-Sis   = """SISTEMA CREDIARIO"""
        &Tit-Rel   = """CLIENTES NOVOS - PERIODO DE "" +
                        string(vdtini) + "" A "" + string(vdtfin) + 
                        "" FILIAL:  "" + string(vetbcod,"">>9"")"
        &Width     = "130"
        &Form      = "frame f-cab"}

    
    
    if vv = "A"
    then do:
        for each wcli by wcli.wetb
                      by wcli.wnom:
        
            display wcli.wetb column-label "Fl"
                    wcli.wcli(count) 
                    wcli.wnom
                    wcli.wcad column-label "Data!Cadastro" format "99/99/9999" 
                    wcli.wcom(total)  column-label "Valor!Compra"
                    /*wcli.wvent(total) column-label "Valor!Entrada"
                    wcli.wvpar(total) column-label "Valor!Parcelas"
                    */
                    wcli.wqpar column-label "Parcelas"
                        with frame f2 down width 130.
            if vlista-pro
            then do:
                for each tt-pro where tt-pro.etbcod = wcli.wetb
                                  and tt-pro.clicod = wcli.wcli:
                    find produ where 
                         produ.procod = tt-pro.procod no-lock no-error.

                    disp space(5)
                         tt-pro.procod format ">>>>>>>9" label "Produto"
                         produ.pronom label "Descricao".
                end.
            end.                              
        end.
    end.
    else do:
        for each wfil by wfil.etbcod:
        
            display wfil.etbcod        column-label "Filial"
                    wfil.totcli(total) column-label "Total!Cliente"
                    wfil.totven(total) column-label "Total!Venda"
                    wfil.totent(total) column-label "Total!Entradas"
                    wfil.totpar(total) column-label "Total!Parcelas"
                        with frame f4 down width 130.
        end.                
                        
    end.
        
    output close.

    if opsys = "UNIX"
    then run visurel.p(input varquivo, input "").
    else do:
        {mrod.i}
    end. 
    end.
    else if vacao
    then do: 
        if connected ("crm")
        then disconnect crm.

        /*** Conectando Banco CRM no server CRM ***/
        connect crm -H "erp.lebes.com.br" -S sdrebcrm -N tcp -ld crm no-error.

               
        if not connected ("crm")
        then do:
            message "Nao foi possivel conectar o banco CRM. Avise o CPD.".
            pause.
            leave.
        end.

        for each wcli :
            find clien where clien.clicod = wcli.wcli no-lock.
            create tt-cli.
            tt-cli.clicod = clien.clicod.
            tt-cli.clinom = clien.clinom.
        end.   
        sresp = no.
        message "Confirma GERAR ACAO ?   " update sresp.
        if sresp
        then do:
            
            run rfv000-brw.p.
                                            
            message color red/with
                 "       ACAO GERADA      " view-as alert-box.

        end.
        if connected ("crm")
        then disconnect crm.
        
    end.
    leave.
end.
