{admcab.i}
{admcom_funcoes.i}

def var dti-compra as date format "99/99/9999".
def var dtf-compra as date format "99/99/9999".
def var dpc-inativo as int format ">>>9".
def var vetbcod like estab.etbcod.
def var vmes as int format ">9".
def var vano as int format "9999".
form vetbcod label " Filial compra"
     estab.etbnom no-label
     dti-compra at 1 label "Periodo compra"
     dtf-compra label "a"
     "Inativo a " at 1 
     dpc-inativo no-label
     "dias       "
     vmes label "Mes"
     vano label "Ano"
     with frame f01 side-label width 80.
      
update vetbcod with frame f01.
      
if vetbcod > 0
then do:
    find estab where estab.etbcod = vetbcod no-lock no-error.
    if not avail estab
    then do:
        bell.
        message color red/with
        "Filial nao cadastrada."
        view-as alert-box.  
        undo. 
    end.
    else disp estab.etbnom with frame f01.
end.       

update dti-compra
       dtf-compra 
       with frame f01.

if dti-compra = ? or
   dtf-compra = ? or
   dti-compra > dtf-compra  
then do:
    bell.
    message color red/with
    "Periodo invalido para processamento."
    view-as alert-box.
end.

update dpc-inativo with frame f01.

def var vdata-aux as date.

if dpc-inativo = 0
then update vmes vano with frame f01.
else do:
    vdata-aux = dti-compra - dpc-inativo.
    vmes = month(vdata-aux).
    vano = year(vdata-aux).
    disp vmes vano with frame f01.
end.
if dpc-inativo = 0
   and (vmes = 0 or vano = 0)
then undo.

vdata-aux = date(if vmes = 12 then 1 else vmes + 1, 01,
                 if vmes = 12 then vano + 1 else vano) .

def var vtip as char format "x(20)" extent 2 
        initial ["Analitico","Sintetico"].
def var vv as char.
def var vlista-pro as log format "Sim/Nao".
display vtip with frame f-tip no-label.
    choose field vtip with frame f-tip centered .
    if frame-index = 1
    then do:
        vv = "A".
        /*
        message "Listar produtos?" update vlista-pro.
        */
    end.        
    else vv = "S".

 
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
    field wqpar  like titulo.titpar
    index i1 wetb wcli.
    
def temp-table wfil
    field etbcod like estab.etbcod
    field totcli as int
    field totven like plani.platot
    field totent like plani.platot
    field totpar like plani.platot 
    index i1 etbcod.

def temp-table tt-pro
    field etbcod as int
    field clicod as int
    field procod as int.
 
def var vdata as date.
disp "Aguarde processamento... " with frame f-f 1 down row 10
        width 80 color message.
pause 0.        
for each estab where
            (if vetbcod > 0 then estab.etbcod = vetbcod else true) 
            no-lock:
     
    disp estab.etbcod column-label "Filial" with frame f-f.
    pause 0.

    do vdata = dti-compra to dtf-compra:
    disp vdata no-label with frame f-f.
    pause 0.
    for each plani where plani.etbcod = estab.etbcod and
                         plani.movtdc = 5 and
                         plani.pladat = vdata
                         no-lock:
        if plani.crecod = 1 then next.
        
        if plani.desti = 1 then next.
        
        find clien where clien.clicod = plani.desti no-lock no-error.
        if not avail clien then next.
        find first wcli where   wcli.wetb = estab.etbcod and
                                wcli.wcli = clien.clicod no-error.
        if not avail wcli
        then do:

            create wcli.
            assign
                wcli.wcli  = clien.clicod
                wcli.wetb  = estab.etbcod
                wcli.wcad  = clien.dtcad
                wcli.wnom  = clien.clinom
                wcli.wprof = clien.proprof[1]
                wcli.wrenda = clien.prorenda[1]
                wcli.widade = YEAR(today) - YEAR(clien.dtnasc)
                .
                   
        end.
    end.    
    end.
end.                             

for each wcli:
    find clien where clien.clicod = wcli.wcli no-lock no-error.
    
    disp wcli.wcli column-label "Cliente"  with frame f-f.
    pause 0.

    if avail clien and clien.dtcad >= dti-compra
    then delete wcli.
    else  
    /*find first plani where
                plani.movtdc = 5 and
                plani.desti  = wcli.wcli and
                plani.pladat < dti-compra
                no-lock no-error.
    if not avail plani 
    then delete wcli.
    else*/ do:           
        find first plani where
              plani.movtdc = 5 and
              plani.desti  = wcli.wcli and
              plani.pladat >= vdata-aux and
              plani.pladat < dti-compra
              no-lock no-error.
        if avail plani and plani.crecod = 2
        then delete wcli.
        else do:
            find first titulo where 
                    titulo.clifor = wcli.wcli and
                    /*titulo.titdtpag >= vdata-aux and
                    titulo.titdtpag < dti-compra and */
                    titulo.titdtemi < dti-compra and
                    titulo.modcod = "CRE" and
                    titulo.titsit = "LIB"
                    no-lock no-error.
            if avail titulo
            then delete wcli.
            else do:
                run cal-cli.
            end.
        end.
    end.                
end.

def var totcon as dec.
def var t-entrada as dec.
def var t-parcela as dec.
def var t-qtdpar as dec.
def var notaclien as int.

procedure cal-cli.
    find clien where clien.clicod = wcli.wcli no-lock.
    assign
            totcon = 0
            t-entrada = 0
            t-parcela = 0
            t-qtdpar = 0.

    for each cpclien where cpclien.clicod = clien.clicod no-lock:
            notaclien = cpclien.var-int3.
    end.
                
    /* PEGAR LIMITE DO CLIENTE */       
    def var limite-cred-scor as dec.                    
    limite-cred-scor = limite-cred-scor(recid(clien)). 
    /**************************/
        
    do:
        
        for each contrato where contrato.clicod = clien.clicod and
                                 contrato.dtinicial >= dti-compra and
                                 contrato.dtinicial <= dtf-compra and
                                 contrato.etbcod = wcli.wetb no-lock:
            
            totcon = totcon + contrato.vltotal.
            
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
    assign
        wcli.wlimite = limite-cred-scor
        wcli.wnota = notaclien
        wcli.wcom  = totcon
        wcli.wvent = t-entrada
        wcli.wvpar = t-parcela
        wcli.wqpar = t-qtdpar.
    
    find first wfil where  wfil.etbcod = wcli.wetb no-error. 
    if not avail wfil
    then do:
        create wfil.
        assign wfil.etbcod = wcli.wetb.
    end.
    assign wfil.totcli = wfil.totcli + 1
           wfil.totven = wfil.totven + totcon
           wfil.totent = wfil.totent + t-entrada
           wfil.totpar = wfil.totpar + t-parcela
           .
end.     

def var varquivo as char.

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
        &Tit-Rel   = """COMPRAS CLIENTES PERIODO DE "" +
                        string(dti-compra) + "" A "" + string(dtf-compra)
                        " 
        &Width     = "130"
        &Form      = "frame f-cab"}
    
    disp with frame f01.
    
    if vv = "A"
    then do:
        for each wcli by wcli.wetb
                      by wcli.wnom:
            display wcli.wetb column-label "Fl"
                    wcli.wcli(count) 
                    wcli.wnom
                                        wcli.wprof[1] column-label "Profissao"
                                        wcli.wrenda[1] column-label "Renda"
                                        wcli.wlimite column-label "Limite"
                                        wcli.widade column-label "Idade"
                                        wcli.wnota column-label "Nota"
                    wcli.wcad column-label "Data!Cadastro" format "99/99/9999" 
                    wcli.wcom(total)  column-label "Valor!Compra"
                    /*wcli.wvent(total) column-label "Valor!Entrada"
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



