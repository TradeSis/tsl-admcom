/* Luciane - 29/12/2006 - 8672 */
{cabec.i}

def var vmensagem as char no-undo.
def var vconta as int.

def var vetbcod         like estab.etbcod.
def var vfuncod         like func.funcod.
def var vdtini          as date.
def var vdtfim          as date.

def var vetbnom         as char.
def var vfunnom         as char.

def temp-table tt-dados
    field funcod    like clitel.funcod
    field funnom    as char format "x(20)"
    field vltitab   like titulo.titvlcob
    field vltitatr  like titulo.titvlcob
    field vlcobratr like titulo.titvlcob
    field vlpago    like titulo.titvlcob
    field vlpagoger like titulo.titvlcob.
    
def temp-table tt-cobra
    field titcod    like clitel.titcod
    field funcod    like clitel.funcod
    field teldat    like clitel.teldat
    field telhor    like clitel.telhor
    field clfcod    like clitel.clfcod.

    def temp-table tt-func
        field codigo    like func.funcod
        field apelido    like func.funape
        index funape    is primary unique apelido asc
        index funcod    codigo asc.

         
form
    vetbcod colon 20 label "Estabelecimento"
    vetbnom no-label format "x(40)"
    skip
/*    vfuncod colon 20 label "Atendente......"
    vfunnom no-label format "x(40)"
    skip*/
    vdtini colon 20 label  "Periodo........"
    "a"
    vdtfim no-label
    skip
    with frame fperiodo
        row 3 width 80
        side-label
                    title " Selecao de Periodo "
                    /*no-box overlay*/ .

form
    tt-dados.funcod    column-label "Atendente"
    tt-dados.funnom    column-label "Nome" format "x(18)"
    tt-dados.vltitab   column-label "Vl.Tit. Aberto"
    tt-dados.vltitatr  column-label "Vl.Tit. Atraso"
    tt-dados.vlcobratr column-label "Atr. Periodo"
    tt-dados.vlpago    column-label "Vl.Pago Atr.Per."
    tt-dados.vlpagoger column-label "Vl. Pago"
    with frame f-linha down width 100 centered no-box.

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
    disp vetbcod label "Estabelecimento" vetbnom no-label with frame fperiodo.

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
    
/*    update vfuncod
           with frame fperiodo.
           */
     for each tt-func.
           delete tt-func.
     end.
    create tt-func.
    tt-func.codigo = 0.
    tt-func.apelido = "Todos".
           
    for each clitel where clitel.teldat >= vdtini and
                      clitel.teldat <= vdtfim  no-lock.
        if clitel.codcont = 0  
        then next.
        find tt-func where tt-func.codigo = clitel.funcod no-error.
        find func of clitel no-lock.
        if not avail tt-func
        then create tt-func.
        assign tt-func.codigo  = clitel.funcod
               tt-func.apelido = func.funape.
    end.               
    {zoomesq.i tt-func codigo apelido 30 Funcionarios.na.Data true}
    vfuncod = int(sretorno).
             
    if vfuncod <> 0
    then do:
        find func where func.funcod = vfuncod no-lock no-error.
        if not avail func
        then do:
            message "Atendente não Cadastrado" view-as alert-box.
            undo.                        
        end.
        else assign vfunnom = func.funnom.
    end.
    else assign vfunnom = "Geral".
    disp vfuncod colon 20 label "Atendente......"
         vfunnom no-label format "x(40)"
    with frame fperiodo.
    
end.

vconta = 0.
vmensagem = "AGUARDE... PROCESSANDO LIGACOES...".
disp vmensagem no-label format "x(60)" vconta no-label with frame f-tela row 21 no-box.
pause 0.

for each clitel where clitel.teldat >= vdtini
                  and clitel.teldat <= vdtfim
                  and (if vfuncod <> 0
                       then clitel.funcod = vfuncod
                       else true) no-lock
    break by clitel.funcod
          by clitel.clfcod.

    vconta = vconta + 1.
    
    find tt-cobra where tt-cobra.clfcod = clitel.clfcod  no-error.
    if not avail tt-cobra
    then do:
        create tt-cobra.
        assign tt-cobra.titcod = clitel.titcod
               tt-cobra.funcod = clitel.funcod
               tt-cobra.teldat = clitel.teldat
               tt-cobra.clfcod = clitel.clfcod.
    end.
    else do:
        if clitel.teldat > tt-cobra.teldat and 
           clitel.funcod <> tt-cobra.funcod
        then do:
            assign tt-cobra.teldat = clitel.teldat
                   tt-cobra.funcod = clitel.funcod
                   tt-cobra.titcod = clitel.titcod.
        end.
    end.
    
disp vmensagem no-label format "x(60)" vconta no-label with frame f-tela row 21 no-box.
pause 0.
     
end.

vconta = 0.
vmensagem = "AGUARDE... PROCESSANDO TITULOS...".
disp vmensagem no-label format "x(60)" vconta no-label with frame f-tela row 21 no-box.
pause 0.
for each tt-cobra no-lock,
    each titulo where titulo.titnat = no
                  and titulo.clfcod = tt-cobra.clfcod
                  and (titulo.titdtpag >= tt-cobra.teldat or
                       titulo.titdtpag = ?)
                  and (if vetbcod <> 0
                       then titulo.etbcod = vetbcod
                       else true) no-lock
                       by titulo.etbcod.

    vconta = vconta + 1.
/*disp "Estab " titulo.etbcod no-label " Cliente " titulo.clfcod no-label " Titulo " trim(titulo.titnum) no-label " " trim(string(titulo.titpar)) no-label with frame f-tela row 21 no-box.*/
 
 vmensagem = "TITULOS... Estab " + trim(string(titulo.etbcod)) + " Cliente " + trim(string(titulo.clfcod)) + " Titulo " + trim(titulo.titnum) + " " + trim(string(titulo.titpar)) .
 
 disp vmensagem no-label format "x(60)" vconta no-label 
      with frame f-tela row 21 no-box.
    pause 0.
 
    pause 0.

    find tt-dados where tt-dados.funcod = tt-cobra.funcod no-error.
    if not avail tt-dados
    then do:
        find func where func.funcod = tt-cobra.funcod no-error.
        create tt-dados.
        assign tt-dados.funcod = tt-cobra.funcod
               tt-dados.funnom = (if avail func
                                  then func.funnom
                                  else "").
    end.
    
    if titulo.titdtpag = ?
    then do:
        /* Títulos em aberto dos clientes selecionados */
        assign tt-dados.vltitab = tt-dados.vltitab + titulo.titvlcob.
    
        /* Titulos em atraso */
        if titulo.titdtven <= tt-cobra.teldat     
        then do:
            assign tt-dados.vltitatr = tt-dados.vltitatr + titulo.titvlcob.
            find first clitel where clitel.teldat >= vdtini
                                and clitel.teldat <= vdtfim
                                and clitel.titcod  = titulo.titcod 
                                    no-lock no-error.
            if avail clitel
            then assign tt-dados.vlcobratr = tt-dados.vlcobratr
                                           + titulo.titvlcob.
        end.    
    end.
    else do:
        /* Titulos em atraso */
        if titulo.titdtven <= tt-cobra.teldat     
        then do:
            assign tt-dados.vltitatr = tt-dados.vltitatr + titulo.titvlcob.
            find first clitel where clitel.teldat >= vdtini
                                and clitel.teldat <= vdtfim
                                and clitel.titcod  = titulo.titcod 
                                    no-lock no-error.
            if avail clitel
            then assign tt-dados.vlpago = tt-dados.vlpago + titulo.titvlpag.
        end.    
                
        /*if titulo.titdtpag >= vdtini and
           titulo.titdtpag <= vdtfim
        then*/ assign tt-dados.vlpagoger = tt-dados.vlpagoger + titulo.titvlpag.
    end.
    
end.                       

 varqsai = "../impress/ccenter1.rel".
 
    Message "Gerando Arquivo" varqsai.

    {mdadmcab.i
        &Saida     = "value(varqsai)"
        &Page-Size = "64"
        &Cond-Var  = "100"
        &Page-Line = "66"
        &Nom-Rel   = ""CCENTER1""
        &Nom-Sis   = """FINANCEIRO"""
        &Tit-Rel   = """ RELATORIO POR ATRASO """
        &Width     = "100"
        &Form      = "frame f-cabcab"
    }.
 
 
put unformatted
    " PARAMETROS SOLICITADOS: " 
    skip
    "Periodo: " vdtini " a " vdtfim
    skip
    "Filial.: " vetbcod " " vetbnom format "x(30)".
    
put skip(2). 

for each tt-dados.
disp tt-dados
    with frame f-linha.
down with frame f-linha.    
end.

   {mdadmrod.i
         &Saida     = " value(varqsai) "
         &NomRel    = """ccenter1"""
         &Page-Size = "63"
         &Width     = "100"
         &Traco     = "65"
         &Form      = "frame f-rod3"}.
         
