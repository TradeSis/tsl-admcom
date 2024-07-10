/******************************************************************************
*  Programa.....: icrmcl1a.i
*  Função.......: Calcula Estatistica Historico
*  Empresa......: CUSTOM BS
*  Data.........: Fevereiro - 2006
*  Autor........: Gerson Mathias
*  Sistema......: ADMCOM
*  Parametros...: (iClieSeg recebe cliente)(lInterface interface sim ou nao)   
*******************************************************************************
*  Modificacao..:
*  Tecnico......:
*  Data.........:
**************************************************************************** */
def var varquivo            as char form "x(80)"      init ""       no-undo.  
def var vdata               as date form "99/99/9999" init today    no-undo.
/* ------------------------------------------------------------------------- */

if opsys = "UNIX"
then do:
        assign varquivo = "/admcom/relat-crm/crm" + 
                          string(day(vdata)) +
                          string(month(vdata)) +
                          string(year(vdata)).
end.
else do:
        assign varquivo = "c:\temp\crm" + 
                          string(day(vdata)) +
                          string(month(vdata)) +
                          string(year(vdata)).
end.

/* ------------------------------------------------------------------------- */
           
def var de-qtd-contrato             as  deci                        no-undo.
def var e-ult-compra                as  date                        no-undo.
def var de-cheque_devolvido         like plani.platot               no-undo.
def var i-parcela-paga              as int format ">>>>9"           no-undo.
def var i-parcela-aberta            as int format ">>>>9"           no-undo.
def var i-vencidas                  like clien.limcrd               no-undo.
def var i-maior-atraso              like plani.pladat               no-undo.
def var i-qtd-15                    as int format ">>>>9"           no-undo.
def var i-qtd-45                    as int format ">>>>9"           no-undo.
def var i-qtd-46                    as int format ">>>>9"           no-undo.
def var d-media                     like clien.limcrd               no-undo.
def var d-sal-aberto                like clien.limcrd               no-undo.
def var e-data1                     like plani.pladat               no-undo.
def var e-data2                     like plani.pladat               no-undo.
def var d-proximo-mes               like clien.limcrd               no-undo.
def var l-repar                     as log format "Sim/Nao"         no-undo.
def var i-mes                       as int format "99"              no-undo.
def var i-ano                       as int format "9999"            no-undo.
def var d-acum                      like clien.limcrd               no-undo.
def var d-total                     like plani.platot               no-undo.
def var i-qtd                       as int                          no-undo.
def var d-lim-calculado             like clien.limcrd format "->>,>>9.99"
                                                                    no-undo.
def var i-qtd-contrato              as int format ">>>9"            no-undo.
def var d-cheque_devolvido          like plani.platot               no-undo.

/* ------------------------------------------------------------------------- */

def temp-table tp-titulo like fin.titulo
    index dt-ven titdtven
    index titnum empcod
                 titnat
                 modcod
                 etbcod
                 clifor
                 titnum
                 titpar.

def temp-table tp-cheque like fin.cheque.

def temp-table wacum
    field mes  as int format "99"
    field ano  as int format "9999"
    field acum like plani.platot.

/* ------------------------------------------------------------------------- */

for each tp-titulo:
    delete tp-titulo.
end.
for each tp-cheque:
    delete tp-cheque.
end.
for each wacum:
    delete wacum.
end.     

find first clien where
           clien.clicod = iClieSeg no-lock no-error.
if not avail clien
then do:
        if search(varquivo) = ?
        then do:
                output to value(varquivo).
                   put "CRM-Calculo Historico"
                       skip
                       "====================="
                       skip.
                output close.        
        end.
        output to value(varquivo) append.
          put "Cliente nao encontrado: "
              iClieSeg
              " - Data: "
              vdata
              skip.
       output close.
 
       return no-apply.
end.

    for each titulo where 
             titulo.clifor = iClieSeg no-lock:

            find first tp-titulo where tp-titulo.empcod = 19
                                   and tp-titulo.titnat = no
                                   and tp-titulo.modcod = titulo.modcod
                                   and tp-titulo.etbcod = titulo.etbcod
                                   and tp-titulo.clifor = titulo.clifor
                                   and tp-titulo.titnum = titulo.titnum
                                   and tp-titulo.titpar = titulo.titpar
                                   no-error.
            if not avail tp-titulo
            then do :
                    create tp-titulo.
                    assign  tp-titulo.empcod    = titulo.empcod
                            tp-titulo.modcod    = titulo.modcod
                            tp-titulo.Clifor    = titulo.clifor
                            tp-titulo.titnum    = titulo.titnum
                            tp-titulo.titpar    = titulo.titpar
                            tp-titulo.titnat    = titulo.titnat
                            tp-titulo.etbcod    = titulo.etbcod
                            tp-titulo.titdtemi  = titulo.titdtemi
                            tp-titulo.titdtven  = titulo.titdtven
                            tp-titulo.titvlcob  = titulo.titvlcob
                            tp-titulo.titsit    = titulo.titsit.
            end.
            else do:
                if titulo.titsit = "PAG"
                then do:
                        assign tp-titulo.titsit   = titulo.titsit
                               tp-titulo.titdtpag = titulo.titdtpag
                               tp-titulo.titvlpag = titulo.titvlpag
                               tp-titulo.titvlcob = titulo.titvlcob
                               tp-titulo.titvldes = titulo.titvldes
                               tp-titulo.titjuro  = titulo.titjuro
                               tp-titulo.titvljur = titulo.titvljur
                               tp-titulo.cxacod   = titulo.cxacod
                               tp-titulo.cxmdata  = titulo.cxmdata
                               tp-titulo.etbcobra = titulo.etbcobra
                               tp-titulo.datexp   = titulo.datexp.
                end.
            end.
    end.

    for each tp-titulo where tp-titulo.modcod <> "CHQ" break
                             by tp-titulo.titnum
                             by tp-titulo.titdtemi:

        if last-of(tp-titulo.titnum)
        then do: 
                assign de-qtd-contrato = de-qtd-contrato + 1.
        end.
                
        assign e-ult-compra   = if e-ult-compra = ?
                                then tp-titulo.titdtemi
                                else max(e-ult-compra,tp-titulo.titdtemi).

    end.

/* ------------------------------------------------------------------------- */
    
    for each tp-titulo where 
             tp-titulo.modcod <> "CHQ" break by tp-titulo.titnum.
        if tp-titulo.titpar <> 0
        then do:
            if tp-titulo.titsit = "LIB"
            then do:
                    assign i-parcela-aberta  = i-parcela-aberta + 1.

                    if tp-titulo.titdtven < today
                    then do:
                            assign i-vencidas = i-vencidas + tp-titulo.titvlcob.
                        if tp-titulo.titdtven < i-maior-atraso
                        then assign i-maior-atraso = tp-titulo.titdtven.
                    end.
            end.
            else assign i-parcela-paga = i-parcela-paga + 1.
        end.

        if tp-titulo.titpar <> 0 and tp-titulo.titdtpag <> ?
        then do:

            if (tp-titulo.titdtpag - tp-titulo.titdtven) <= 15
            then assign i-qtd-15 = i-qtd-15 + 1.

            if (tp-titulo.titdtpag - tp-titulo.titdtven) >= 16 and
               (tp-titulo.titdtpag - tp-titulo.titdtven) <= 45
            then i-qtd-45 = i-qtd-45 + 1.

            if (tp-titulo.titdtpag - tp-titulo.titdtven) >= 46
            then i-qtd-46 = i-qtd-46 + 1.

            d-media = d-media + tp-titulo.titvlcob.

            find first wacum where wacum.mes = month(tp-titulo.titdtpag) and
                                   wacum.ano = year(tp-titulo.titdtpag)
                         no-error.
            if not avail wacum
            then do:
                create wacum.
                assign wacum.mes = month(tp-titulo.titdtpag)
                       wacum.ano = year(tp-titulo.titdtpag).
            end.
            wacum.acum = wacum.acum + tp-titulo.titvlcob.
        end.

        if tp-titulo.titsit = "LIB"
        then do:
                assign d-sal-aberto = d-sal-aberto + tp-titulo.titvlcob.
                if tp-titulo.titdtven >= e-data1 and
                   tp-titulo.titdtven <= e-data2
                then assign d-proximo-mes = d-proximo-mes + tp-titulo.titvlcob.
        end.
    end.

    find first flag where flag.clicod = clien.clicod no-lock no-error.
    if avail flag and flag.flag1 = yes
    then l-repar = yes.
    
    for each wacum by wacum.acum:
        assign i-mes = wacum.mes
               i-ano = wacum.ano
               d-acum = wacum.acum.
        assign d-total = d-total + wacum.acum.
        i-qtd   = i-qtd + 1.
    end.

    assign d-lim-calculado = (clien.limcrd - d-sal-aberto).
    
    /*******************SOMA CREDSCOR******************/
    
    find first credscor where credscor.clicod = clien.clicod no-lock no-error.
    if avail credscor
    then do:
    
        if credscor.dtultc > e-ult-compra
        then e-ult-compra = credscor.dtultc.
        
        i-qtd-contrato = i-qtd-contrato + credscor.numcon.
        i-parcela-paga = i-parcela-paga + credscor.numpcp.
        i-qtd-15 = i-qtd-15 + credscor.numa15.
        i-qtd-45 = i-qtd-45 + credscor.numa16.
        i-qtd-46 = i-qtd-46 + credscor.numa45.
        d-total = (vala15 + vala16 + vala45).
        i-qtd = credscor.numcon.
        if credscor.valacu > d-acum
        then do:
            i-mes = credscor.mesacu.
            i-ano = credscor.anoacu.
            d-acum = credscor.valacu.
        end.    
    
        d-media = d-media + (vala15 + vala16 + vala45).
    
    end.    

    assign d-media = d-media / (i-qtd-15 + i-qtd-45 + i-qtd-46).

    if lInterface = yes
    then do: 
            run pi-interface.
    end.        

/* -----FINAL PROGRAMA------------------------------------------------------ */


procedure pi-interface:

    disp de-qtd-contrato  label "Contratos"         form ">>>9"
         d-lim-calculado  label "Lim. Calculado"
         with frame f-2 width 80
              side-labels 2 col three-d.
         
end procedure.         
