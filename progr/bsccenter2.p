/* Luciane - 29/12/2006 - 8741 */

/* Felipe - 25/07/2007 - 14603 - inserida coluna "Valor Saldo" */
{cabec.i}
 
def var vmensagem as char no-undo.
def var vconta as int.

def var vetbcod         like estab.etbcod.
def var vetbnom         like estab.etbnom.
def var vdtini          as date.
def var vdtfim          as date.
def var vvalini         like titulo.titvlcob initial 0.
def var vvalfim         like titulo.titvlcob format  ">>>>,>>9.99"
                                            init 9999999.
def var vcodcont        like tipcont.codcont.

def var vdesccont       like tipcont.desccont.

def temp-table tt-cobra
    field titcod    like clitel.titcod
    field funcod    like clitel.funcod
    field teldat    like clitel.teldat
    field telhor    like clitel.telhor
    field clfcod    like clitel.clfcod
    field codcont   like tipcont.codcont
    field hist      as char.

def temp-table tt-dados no-undo
    field codcont like tipcont.codcont
    field etbcod   like estab.etbcod
    field clfcod   like clifor.clfcod
    field clfnom   like clifor.clfnom
    field titnum   like titulo.titnum
    field titpar   like titulo.titpar
    field qtdparc  as int
    field totparc  like titulo.titvlcob
    field totsaldo like titulo.titvlcob
    field hist     as char.

def buffer btitulo for titulo. 
 
form
    vetbcod colon 20 label "Estabelecimento"
    vetbnom no-label format "x(40)"
    skip
    vdtini colon 20   label "Periodo........"
    "a"
    vdtfim no-label
    vvalini colon 20  label "Valor.........."
    "a"
    vvalfim no-label
    vcodcont colon 20 label "Motivo........."
    vdesccont no-label format "x(40)"
    skip
    with frame fperiodo
        row 3 width 80
        side-label
                    title " Selecao de Periodo "
                    /*no-box overlay*/ .

form
    tt-dados.clfcod    column-label "Cliente"
    tt-dados.clfnom    column-label "Nome" format "x(20)"
    tt-dados.etbcod    column-label "Estab."
    tt-dados.titnum    column-label "Titulo"
    /*
    space(0) "/" space(0)
    tt-dados.titpar    column-label "Parcela" */
    tt-dados.qtdparc   column-label "Qtd.Parc.Atr."
    tt-dados.totparc   column-label "Vl.Parc.Atr."
    tt-dados.totsaldo  column-label "Valor Saldo"
    tt-dados.hist      column-label "Historico" format "x(35)"
    with frame f-linha down width 130 centered no-box.

do on error undo.

    update vetbcod
           with frame fperiodo.
           
    if vetbcod <> 0
    then do:
        find estab where estab.etbcod = vetbcod no-lock no-error.
        if not avail estab
        then do:
            message "Estabelecimento não Cadastrado" view-as alert-box.
            undo.                        
        end.
        else assign vetbnom = estab.etbnom.
    end.
    else assign vetbnom = "Geral".
    
    disp vetbcod label "Estabelecimento" vetbnom no-label 
         with frame fperiodo.
    
    update  vdtini
            vdtfim
            with frame fperiodo.
            
    if vdtini = ? or vdtfim = ?
    then do:
        message "O periodo deve ser informado." view-as alert-box.
        undo.
    end.

    if vdtfim < vdtini
    then do:
        message "Periodo incorreto. Favor verificar." view-as alert-box.
        undo.
    end.

    update vvalini
           vvalfim
           with frame fperiodo.
           
    if vvalfim < vvalini
    then do:
        message "Valor Inicial Maior que Final!" view-as alert-box.
        undo.                        
    end.

    update vcodcont
           with frame fperiodo.
           
   if vcodcont <> 0
   then do:      
        for first tipcont where 
                  tipcont.codcont = vcodcont 
                  no-lock: end.
                  
        if not avail tipcont
        then do:
            message "Tipo de Contato não Cadastrado." view-as alert-box.
            undo.                        
        end.
        else assign vdesccont = tipcont.desccont.
    end.
    else assign vdesccont = "Geral".
    
    disp vcodcont colon 20 label "Motivo........." vdesccont no-label
         with frame fperiodo.
    
end.

assign vconta    = 0
       vmensagem = "AGUARDE... PROCESSANDO...".
       
disp vmensagem no-label format "x(60)" vconta no-label
     with frame f-tela row 21 no-box.
     
pause 0.

for each clitel where clitel.teldat  >= vdtini
                  and clitel.teldat  <= vdtfim
                  and (clitel.codcont = vcodcont or
                       vcodcont       = 0)   
                      no-lock:     

    assign vconta = vconta + 1.
    
    for first tt-cobra where 
              tt-cobra.clfcod = clitel.clfcod
              no-lock: end.
              
    if not avail tt-cobra
    then do:
        create tt-cobra.
        assign tt-cobra.titcod  = clitel.titcod
               tt-cobra.funcod  = clitel.funcod
               tt-cobra.teldat  = clitel.teldat
               tt-cobra.clfcod  = clitel.clfcod
               tt-cobra.hist    = clitel.telobs[1]
               tt-cobra.codcont = clitel.codcont.
    end.
    else do:
        if clitel.teldat   > tt-cobra.teldat and 
           clitel.codcont <> tt-cobra.codcont
        then do:
            assign tt-cobra.teldat  = clitel.teldat
                   tt-cobra.funcod  = clitel.funcod
                   tt-cobra.titcod  = clitel.titcod
                   tt-cobra.codcont = clitel.codcont
                   tt-cobra.hist    = clitel.telobs[1].
        end.
    end.

    disp vmensagem no-label format "x(60)" vconta no-label 
         with frame f-tela row 21 no-box.
    pause 0.
    
end.

assign vconta    = 0
       vmensagem = "Verificando titulos...".
       
disp vmensagem no-label format "x(60)" vconta no-label
     with frame f-tela row 21 no-box.
pause 0.

for each tt-cobra 
    no-lock:
    
    assign vconta = vconta + 1.
    
    for first titulo where 
              titulo.titcod = tt-cobra.titcod
              no-lock: end.
   
    for first tt-dados where 
              tt-dados.codcont = tt-cobra.codcont
          and tt-dados.clfcod  = tt-cobra.clfcod 
              no-lock: end.
                    
    if not avail tt-dados
    then do:
        for first clifor where 
                  clifor.clfcod = tt-cobra.clfcod 
                  no-lock: end.
                  
        create tt-dados.
        assign tt-dados.codcont = tt-cobra.codcont
               tt-dados.clfcod  = tt-cobra.clfcod
               tt-dados.clfnom  = (if avail clifor
                                   then clifor.clfnom
                                   else "").
    end.
    
    if avail titulo
    then assign tt-dados.titnum  = titulo.titnum
                tt-dados.titpar  = titulo.titpar
                tt-dados.etbcod  = titulo.etbcod.
                
    else assign tt-dados.titnum  = ""
                tt-dados.titpar  = 0
                tt-dados.etbcod  = 0
                tt-dados.totparc = 0.                         
                
    for each btitulo where btitulo.titnat    = titulo.titnat
                       and btitulo.clfcod    = titulo.clfcod
                       and btitulo.titnum    = titulo.titnum
                       and btitulo.titdtpag  = ?
                   /*   and btitulo.titdtven  < today */ 
                       and btitulo.modcod    = "CLI" 
                           no-lock.                       
                                                 
            if  btitulo.titdtven < today 
            then do:
            
              assign tt-dados.totparc  = tt-dados.totparc + 
                                         (btitulo.titvlcob - btitulo.titvlpag).   
              assign tt-dados.qtdparc  = tt-dados.qtdparc  + 1.
                                                
            end. 
                  
            assign tt-dados.totsaldo = tt-dados.totsaldo + btitulo.titvlcob.
                                       
     end.
     
    assign tt-dados.hist = tt-cobra.hist.
        
    disp vmensagem no-label format "x(60)" vconta no-label
         with frame f-tela row 21 no-box.
    pause 0.
     
end.                       

assign varqsai = "../impress/ccenter2." + string(time).

{mdadmcab.i
        &Saida     = "value(varqsai)"
        &Page-Size = "64"
        &Cond-Var  = "120"
        &Page-Line = "66"
        &Nom-Rel   = ""CCENTER2""
        &Nom-Sis   = """SISTEMA DE COBRANCA"""
        &Tit-Rel   = """ RELATORIO POR ATRASO """
        &Width     = "130"
        &Form      = "frame f-cabcab"}.

put unformatted
    " PARAMETROS SOLICITADOS: " 
    skip
    "Periodo: " vdtini " a " vdtfim
    skip
    "Filial.: " vetbcod " " vetbnom format "x(30)"
    skip
    "Valor..: " vvalini " a " vvalfim
    skip
    "Motivo.: " vcodcont " " trim(vdesccont)
    skip.
    
put skip(1).

 def var tot-saldo like tt-dados.totsaldo no-undo.
 def var tot-parc like tt-dados.totparc no-undo.
 
for each tt-dados where (if vetbcod <> 0
                         then tt-dados.etbcod = vetbcod
                         else true)
                    and tt-dados.totparc >= vvalini
                    and tt-dados.totparc <= vvalfim no-lock
    break by tt-dados.codcont
          by tt-dados.clfcod.
    if first-of(tt-dados.codcont)
    then do:
        find tipcont where tipcont.codcont = tt-dados.codcont no-lock no-error.
        if avail tipcont
        then
          disp tt-dados.codcont label "Contato: "
               tipcont.desccont no-label with frame f-cont side-labels.
        else 
          disp tt-dados.codcont label "Contato"
               "Nao informado" @ tipcont.desccont no-label 
                with frame f-cont side-labels.
        put skip(1).             
    end.
          
    assign tot-saldo = tot-saldo + tt-dados.totsaldo
           tot-parc = tot-parc + tt-dados.totparc.

    disp tt-dados.clfcod
         tt-dados.clfnom
         tt-dados.etbcod
         trim(tt-dados.titnum + "/" + string(tt-dados.titpar)) @ tt-dados.titnum
         tt-dados.qtdparc
         tt-dados.totparc
         tt-dados.hist
         tt-dados.totsaldo
         with frame f-linha.
    down with frame f-linha.     

     if last-of(tt-dados.codcont)
     then put skip(1). 

end.

underline tt-dados.clfnom
          tt-dados.totparc
          tt-dados.totsaldo
          with frame f-linha.
          
disp "Total"   @ tt-dados.clfnom
     tot-saldo @ tt-dados.totsaldo
     tot-parc  @ tt-dados.totparc
          with frame f-linha.
{mdadmrod.i
         &Saida     = " value(varqsai) "
         &NomRel    = """ccenter2"""
         &Page-Size = "63"
         &Width     = "130"
         &Traco     = "65"
         &Form      = "frame f-rod3"}.
 
