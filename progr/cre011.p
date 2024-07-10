/*
#1 TP 24027197
*/

{admcab.i}
{admcom_funcoes.i}
{setbrw.i}

def var v-cont as integer.
def var v-cod as char.
def var vmod-sel as char.

def temp-table tt-modalidade-padrao
    field modcod as char
    index pk modcod.
            
def temp-table tt-modalidade-selec
    field modcod as char
    index pk modcod.

def var vval-carteira as dec.                                
                                
form
   a-seelst format "x" column-label "*"
   tt-modalidade-padrao.modcod no-label
   with frame f-nome
       centered down title "Modalidades"
       color withe/red overlay.    
                                                        
create tt-modalidade-padrao.
assign tt-modalidade-padrao.modcod = "CRE".

for each profin no-lock.

    create tt-modalidade-padrao.
    assign tt-modalidade-padrao.modcod = profin.modcod.
        
end.

def temp-table tt-pro
    field etbcod as int
    field clicod as int
    field procod as int.
def var vlista-pro as log format "Sim/Nao".
    
def var totcon like plani.platot.
def var vtip as char format "x(20)" extent 2 
        initial ["Analitico","Sintetico"].
def var notaclien like cpclien.var-int3.
        
def var vv as char.
def var varquivo    as char.
def var vdtini      like plani.pladat.
def var vdtfin      like plani.pladat.
def var vetbcod     like estab.etbcod.

def var t-entrada as dec.
def var t-parcela as dec.
def var t-qtdpar as int.
def var vfilcli as int .
def temp-table wcli
    field wcli  like clien.clicod
    field wetb  like estab.etbcod
    field wnom  like clien.clinom
    field wcad  like clien.dtcad
        field wprof like clien.proprof
        field wrenda like clien.prorenda
        field wlimite like clien.limite
        field widade as int init 0
        field wnota like cpclien.var-int3
    field wcom  like titulo.titvlcob
    field wvent  like titulo.titvlcob
    field wvpar  like titulo.titvlcob
    field wqpar  as int format ">>9".
    
def temp-table wfil
    field etbcod like estab.etbcod
    field totcli as int
    field totven like plani.platot
    field totent like plani.platot
    field totpar like plani.platot .

repeat:
    
    assign
        a-seeid = -1
        a-recid = -1
        a-seerec = ?
        a-seelst = ""
        .
        
    for each wcli: delete wcli. end.
    for each wfil: delete wfil. end.
    for each tt-pro. delete tt-pro. end.
    for each tt-modalidade-selec. delete tt-modalidade-selec. end.
    
    update vetbcod colon 25 with frame f1.
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
    
    update vdtini  colon 25 label "Periodo"
           vdtfin  no-label with frame f1 centered side-label width 80.

    assign sresp = false.
           
    update sresp label "Seleciona Modalidades?" colon 25
           help "Não = Modalidade CRE Padrão / Sim = Seleciona Modalidades"
           with side-label
           width 80 frame f1.
              
    if sresp
    then do:
              
        bl_sel_filiais:
        repeat:
                      
            run p-seleciona-modal.
                                                      
            if keyfunction(lastkey) = "end-error"
            then do: 
                pause 0.
                leave bl_sel_filiais.
             end.   
                                                
        end.
        message "Tecle enter para contitnuar.".
        pause.
    end.
    else do:
        /*
        create tt-modalidade-selec.
        assign tt-modalidade-selec.modcod = "CRE".
        */
        for each tt-modalidade-padrao:
            create tt-modalidade-selec.
            buffer-copy tt-modalidade-padrao to tt-modalidade-selec.
        end.    
    end.
    
    assign vmod-sel = "  ".
    for each tt-modalidade-selec.
        assign vmod-sel = vmod-sel + tt-modalidade-selec.modcod + "  ".
    end.
      
    display vmod-sel format "x(40)" no-label with frame f1.
    pause 0.
    
    for each clien where clien.dtcad >= vdtini and
                         clien.dtcad <= vdtfin no-lock.
        
        display clien.clicod
                substring(string(clien.clicod),7,2) 
                        with frame f3 1 down centered. 
        pause 0.                
        
        if vetbcod = 0
        then.
        else do:
            if clien.etbcad > 0
            then do:
                if clien.etbcad <> vetbcod
                then next.
            end.
            else if length(string(clien.clicod)) < 10
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
        for each tt-modalidade-selec,
            each contrato where contrato.clicod = clien.clicod
                            and contrato.modcod = tt-modalidade-selec.modcod
                          no-lock:
            totcon = totcon + contrato.vltotal.

        end.
                
        for each cpclien where cpclien.clicod = clien.clicod no-lock:
            notaclien = cpclien.var-int3.
        end.
                
        /* PEGAR LIMITE DO CLIENTE */       
        def var limite-cred-scor as dec.                    
        limite-cred-scor = limite-cred-scor(recid(clien)). 
        /**************************/
        
        if totcon = 0
        then next.
        
        find first plani where plani.movtdc = 5 and
                               plani.desti = clien.clicod and
                               plani.pladat < vdtini no-lock no-error.
        if avail plani
        then next.                       
            
        if totcon <> 0
        then do:
            for each tt-modalidade-selec,
            each contrato where contrato.clicod = clien.clicod
                            and contrato.modcod = tt-modalidade-selec.modcod
                          no-lock:
            /*for each contrato where contrato.clicod = clien.clicod no-lock:
                */
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
                                      titulo.modcod = contrato.modcod and
                                      titulo.etbcod = contrato.etbcod and
                                      titulo.clifor = contrato.clicod and
                                      titulo.titnum = string(contrato.contnum)
                                       no-lock:
                    if titulo.titpar = 0
                    then t-entrada = t-entrada + titulo.titvlcob.
                    else do:
                        t-parcela = t-parcela + titulo.titvlcob.
                        /*if titulo.titpar > t-qtdpar
                        then t-qtdpar = titulo.titpar.    
                        */
                        t-qtdpar = t-qtdpar + 1.          
                    end.
                end.                
            end.
        end.
        
        if clien.etbcad > 0
        then do:
            if vetbcod > 0 /* #1 */ and
               clien.etbcad <> vetbcod
            then next.
            vfilcli = clien.etbcad. /* #1 */
        end.
        else if length(string(clien.clicod)) < 10
        then do:
            assign vfilcli = int(substring(string(clien.clicod),
                                    length(string(clien.clicod)) - 1,2)). 
        end.
        else do:
            assign vfilcli = int(substring(string(clien.clicod),2,3)).
        end.
                
        find first wcli where wcli.wcli = clien.clicod no-error.
        if not avail wcli
        then do:                        
            create wcli.
            assign wcli.wcli  = clien.clicod
                   wcli.wetb  = vfilcli
                   wcli.wcad  = clien.dtcad
                   wcli.wnom  = clien.clinom
                   wcli.wprof = clien.proprof[1]
                   wcli.wrenda = clien.prorenda[1]
                   wcli.wlimite = limite-cred-scor
                   wcli.widade = YEAR(today) - YEAR(clien.dtnasc)
                   wcli.wnota = notaclien
                   wcli.wcom  = totcon
                   wcli.wvent = t-entrada
                   wcli.wvpar = t-parcela
                   wcli.wqpar = t-qtdpar.
        end.
        
        find first wfil where wfil.etbcod = vfilcli no-error. 
        if not avail wfil
        then do:
            create wfil.
            assign wfil.etbcod = vfilcli.
        end.

        assign wfil.totcli = wfil.totcli + 1
               wfil.totven = wfil.totven + totcon
               wfil.totent = wfil.totent + t-entrada
               wfil.totpar = wfil.totpar + t-parcela.
    end.

    display vtip with frame f-tip no-label.
    choose field vtip with frame f-tip centered row 4.
    if frame-index = 1
    then do:
        vv = "A".
        message "Listar produtos?" update vlista-pro.
    end.        
    else vv = "S".

    if opsys = "UNIX"
    then varquivo = "/admcom/relat/cre011." + string(mtime).
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
                    wcli.wprof[1] column-label "Profissao"
                    wcli.wrenda[1] column-label "Renda"
                    wcli.wlimite  column-label "Limite"
                    wcli.widade column-label "Idade"
                    wcli.wnota column-label "Nota"
                    wcli.wcad  column-label "Data!Cadastro" format "99/99/9999" 
                    wcli.wcom(total)  column-label "Valor!Compra"
                    wcli.wvent(total) column-label "Valor!Entrada"
                    /*
                    wcli.wvpar(total) column-label "Valor!Parcelas"
                    */
                    wcli.wqpar column-label "Parcelas"
                    with frame f2 down width 200.
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


procedure p-seleciona-modal:

            
{sklcls.i
    &File   = tt-modalidade-padrao
    &help   = "                ENTER=Marca F4=Retorna F8=Marca Tudo"
    &CField = tt-modalidade-padrao.modcod    
    &Ofield = " tt-modalidade-padrao.modcod"
    &Where  = " true"
    &noncharacter = /*
    &LockType = "NO-LOCK"
    &UsePick = "*"          
    &PickFld = "tt-modalidade-padrao.modcod" 
    &PickFrm = "x(4)" 
    &otherkeys1 = "
        if keyfunction(lastkey) = ""CLEAR""
        then do:
            V-CONT = 0.
            for each tt-modalidade-padrao no-lock:
                a-seelst = a-seelst + "","" + tt-modalidade-padrao.modcod.
                v-cont = v-cont + 1.
            end.
            message ""                         SELECIONADAS "" 
            V-CONT ""FILIAIS                                   ""
            .
                         a-seeid = -1.
            a-recid = -1.
            next keys-loop.
        end. "
    &Form = " frame f-nome" 
}. 

hide frame f-nome.
v-cont = 2.
repeat :
    v-cod = "".
    if num-entries(a-seelst) >= v-cont
    then v-cod = entry(v-cont,a-seelst).

    v-cont = v-cont + 1.

    if v-cod = ""
    then leave.
    create tt-modalidade-selec.
    assign tt-modalidade-selec.modcod = v-cod.
end.


end.

