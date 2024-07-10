def var vdata like plani.pladat.
def var vnum7 like plani.numero.
def var vcod7 like plani.placod.
def var vnum8 like plani.numero.
def var vcod8 like plani.placod.
def var vnumero like plani.numero.
def var vplacod like plani.placod.
def buffer cplani for plani.
def buffer bplani for plani.
def var vetbcod like estab.etbcod.
vetbcod = int(SESSION:PARAMETER).

def temp-table tt-arq
    field arquivo as char.
    
def var varquivo as char.

varquivo = "/admcom/relat/atuinvadm.txt".

unix silent value(" ls /admcom/inventario/INV-" + 
                    string(vetbcod,"999") + "* > " + varquivo +
                  " ls /admcom/inventario/inv-" +
                    string(vetbcod,"999") + "* >> " + varquivo).
                    
input from value(varquivo).
repeat:
    create tt-arq.
    import tt-arq.
end.
input close.

def temp-table tt-arquivo
        field etbcod like estab.etbcod
        field data as date
        field procod like produ.procod
        field qtdest as dec
        field qtdcon as dec
        index i1 procod
        .
    
def var vregistro as int.
def var vqtdest   as int.
def var vqtdcon   as int.     
def var vmovseq-a   as int.
def var vmovseq-d   as int.
def var varqmail as char.
def var v-assunto as char.
def var v-mail as char.
def var vmais as int.
def var vmenos as int.
def var vdiverg as int.
def var vvalmais as dec.
def var vvalmenos as dec.
def var vvaldiverg as dec.
def var vvalqtdest as dec.
def var vvalqtdcon as dec.
def var vblocok as log.
def new shared temp-table tt-plani like plani.
def new shared temp-table tt-movim like movim.

for each tt-arq where tt-arq.arquivo <> "":

    varquivo = tt-arq.arquivo.
    if search(varquivo) = ?
    then next.
    
    for each tt-arquivo:
        delete tt-arquivo.
    end.
    
    assign
        vregistro = 0
        vqtdest = 0
        vqtdcon = 0
        vvalqtdest = 0
        vvalqtdcon = 0.
        
    input from value(varquivo).
    repeat:
        create tt-arquivo.
        import tt-arquivo.
       
        find produ where produ.procod = tt-arquivo.procod no-lock no-error.
        if avail produ
        then do:
        find estoq where estoq.procod = produ.procod and
                         estoq.etbcod = tt-arquivo.etbcod
                         no-lock no-error.
        find coletor where
             coletor.etbcod = tt-arquivo.etbcod and
             coletor.procod = tt-arquivo.procod and
             coletor.coldat = tt-arquivo.data
             no-error.
        if not avail coletor
        then do:
             create coletor.
             assign
                coletor.etbcod = tt-arquivo.etbcod
                coletor.procod = tt-arquivo.procod
                coletor.coldat = tt-arquivo.data.
        end.
        assign
            coletor.colqtd = tt-arquivo.qtdcon
            coletor.coldec = 0
            coletor.colacr = 0
            .
        if tt-arquivo.qtdcon > tt-arquivo.qtdest
        then coletor.colacr = tt-arquivo.qtdcon - tt-arquivo.qtdest.
        else if tt-arquivo.qtdest > tt-arquivo.qtdcon
            then coletor.coldec = tt-arquivo.qtdest - tt-arquivo.qtdcon.
 
        assign
            vregistro = vregistro + 1
            vqtdest   = vqtdest + tt-arquivo.qtdest
            vqtdcon   = vqtdcon + tt-arquivo.qtdcon.
        if estoq.estcusto <> ? and
            estoq.estcusto > 0
        then assign    
            vvalqtdest = vvalqtdest + (estoq.estcusto * tt-arquivo.qtdest)
            vvalqtdcon = vvalqtdcon + (estoq.estcusto * tt-arquivo.qtdcon).
        end.
    end.
    input close.

    for each tt-plani: delete tt-plani. end.
    for each tt-movim: delete tt-movim. end.
    vblocok = no.
    
    find first tt-arquivo where tt-arquivo.etbcod > 0 no-error. 
    if avail tt-arquivo
    then do:
        vdata = tt-arquivo.data.
        find estab where estab.etbcod = tt-arquivo.etbcod no-lock.
        
        find tabaux where 
                 tabaux.tabela = "ESTAB-" + string(estab.etbcod,"999") and
                 tabaux.nome_campo = "BLOCOK" no-error.
        if avail tabaux and tabaux.valor_campo = "SIM"
        then vblocok = yes.
        else vblocok = no.

        /*************/
        find last cplani where cplani.etbcod = estab.etbcod and
                           cplani.placod <= 500000  no-error.
        if avail cplani
        then vplacod = cplani.placod + 1.
        else vplacod = 1.
        find last bplani use-index nota where bplani.movtdc = 7 and
                                          bplani.etbcod = estab.etbcod and 
                                          bplani.emite  = estab.etbcod and
                                          bplani.serie  = "B"
                                 no-error.
        if not avail bplani
        then vnumero = 1.
        else vnumero = bplani.numero + 1.

        find tipmov where tipmov.movtdc = 7 no-lock.

        vcod7 = vplacod.
        vnum7 = vnumero.

        do transaction:
            create plani.
            assign plani.etbcod   = estab.etbcod
               plani.placod   = vcod7
               plani.emite    = estab.etbcod
               plani.serie    = "B"
               plani.numero   = vnum7
               plani.movtdc   = tipmov.movtdc
               plani.desti    = estab.etbcod
               plani.pladat   = vdata
               plani.modcod   = tipmov.modcod
               plani.opccod   = 4
               plani.dtinclu  = today
               plani.horincl  = time
               plani.notsit   = no
               plani.datexp   = today
               plani.usercod = "NAO".
        end.

        find last cplani where cplani.etbcod = estab.etbcod and
                               cplani.placod <= 500000
                                    no-error.
        if avail cplani
        then vplacod = cplani.placod + 1.
        else vplacod = 1.
        find last bplani use-index nota where bplani.movtdc = 8 and
                               bplani.etbcod = estab.etbcod and
                               bplani.emite  = estab.etbcod and
                               bplani.serie  = "B"  no-error.
        if not avail bplani
        then vnumero = 1.
        else vnumero = bplani.numero + 1.

        find tipmov where tipmov.movtdc = 8 no-lock.

        vcod8 = vplacod.
        vnum8 = vnumero.

        if not vblocok
        then do transaction:
            create plani.
            assign plani.etbcod   = estab.etbcod
               plani.placod   = vcod8
               plani.emite    = estab.etbcod
               plani.serie    = "B"
               plani.numero   = vnum8
               plani.movtdc   = tipmov.movtdc
               plani.desti    = estab.etbcod
               plani.pladat   = vdata
               plani.modcod   = tipmov.modcod
               plani.opccod   = 4
               plani.dtinclu  = today
               plani.datexp   = today
               plani.horincl  = time
               plani.notsit   = no
               plani.usercod = "NAO".

        end.
        else do:
            create tt-plani.
            assign tt-plani.etbcod   = estab.etbcod
               tt-plani.placod   = ?
               tt-plani.emite    = estab.etbcod
               tt-plani.serie    = ?
               tt-plani.numero   = ?
               tt-plani.movtdc   = tipmov.movtdc
               tt-plani.desti    = estab.etbcod
               tt-plani.pladat   = vdata
               tt-plani.modcod   = tipmov.modcod
               tt-plani.opccod   = 5927
               tt-plani.hiccod   = 5927
               tt-plani.dtinclu  = today
               tt-plani.datexp   = today
               tt-plani.horincl  = time
               tt-plani.notsit   = no
               tt-plani.usercod = "NAO".

        end.
        assign
        vmovseq-a = 0
        vmovseq-d = 0
        vmais = 0 vvalmais = 0
        vmenos = 0 vvalmenos = 0
        vdiverg = 0 vvaldiverg = 0.
        for each coletor where coletor.etbcod = estab.etbcod and
                           coletor.coldat >= vdata - 1 no-lock:
            find produ where 
                produ.procod = coletor.procod no-lock no-error.
            if not avail produ
            then next.
            find estoq where estoq.etbcod = estab.etbcod and
                         estoq.procod = produ.procod no-lock no-error.
            if not avail estoq
            then next.

            if coletor.colacr = 0 and
               coletor.coldec = 0
            then next.

            if coletor.colacr > 0
            then do transaction:
                vmovseq-a = vmovseq-a + 1.
                vmais = vmais + coletor.colacr.
                vvalmais = vvalmais + (estoq.estcusto * coletor.colacr).
                create movim.
                ASSIGN movim.movtdc = 7
                   movim.PlaCod = vcod7
                   movim.etbcod = estab.etbcod
                   movim.movseq = vmovseq-a
                   movim.procod = estoq.procod
                   movim.movqtm = coletor.colacr
                   movim.movpc  = estoq.estcusto
                   movim.movdat = vdata
                   movim.datexp = today
                   movim.MovHr  = int(time)
                   movim.emite  = estab.etbcod
                   movim.desti  = estab.etbcod.
                run /admcom/progr/atuest.p (input recid(movim),
                          input "I",
                          input 0).
            end.
            if coletor.coldec > 0
            then do transaction:
                 vmovseq-d = vmovseq-d + 1.
                vmenos = vmenos + coletor.coldec.
                vvalmenos = vvalmenos + (estoq.estcusto * coletor.coldec).
                                
                if not vblocok
                then do:
                create movim.
                ASSIGN movim.movtdc = 8
                   movim.PlaCod = vcod8
                   movim.etbcod = estab.etbcod
                   movim.movseq = vmovseq-d
                   movim.procod = estoq.procod
                   movim.movqtm = coletor.coldec
                   movim.movpc  = estoq.estcusto
                   movim.movdat = vdata
                   movim.datexp = today
                   movim.MovHr  = int(time)
                   movim.emite  = estab.etbcod
                   movim.desti  = estab.etbcod.
                run /admcom/progr/atuest.p (input recid(movim),
                          input "I",
                          input 0).
                end.
                else do:
                create tt-movim.
                ASSIGN tt-movim.movtdc = 8
                   tt-movim.PlaCod = ?
                   tt-movim.etbcod = estab.etbcod
                   tt-movim.movseq = vmovseq-d
                   tt-movim.procod = estoq.procod
                   tt-movim.movqtm = coletor.coldec
                   tt-movim.movpc  = estoq.estcusto
                   tt-movim.movdat = vdata
                   tt-movim.datexp = today
                   tt-movim.MovHr  = int(time)
                   tt-movim.emite  = estab.etbcod
                   tt-movim.desti  = estab.etbcod
                   tt-movim.movcsticms = "51"
                   tt-movim.movcstpiscof = 49
                   tt-movim.emite = estab.etbcod
                   tt-movim.desti = estab.etbcod
                   .
                end.
            end.
        end.        
        /*************/
        
        vdiverg = vqtdest - vqtdcon.
        vvaldiverg = vvalqtdest - vvalqtdcon.
        
        unix silent value(" mv " + varquivo + " /admcom/inventario/bkp/").
        /**
        varqmail = "/admcom/relat/atuinvmail" + string(time).
        output to value(varqmail).
        put  "INVENTARIO FILIAL " estab.etbcod format "999" " <br>" skip
             "RESUMO DA ATUALIZAÇÃO EM " today     " <br><br>" skip
         "Arquivo da contagem: " varquivo format "x(50)"  " <br><br>" skip
         "Quantidade registros : " vregistro  " <br><br>" skip
         "Quantidade estoque   : " vqtdest    " <br><br>" skip
         "Quantidade contagem  : " vqtdcon    " <br><br>" skip
           .
        output close.
        **/
        v-assunto = "Adm Processo Matriz Controller OK !- Filial " + string(estab.etbcod,"999").
        /**
        v-mail    = "inventario@lebes.com.br".
        unix silent value("/usr/bin/metasend -b -s " 
                    + "~"" + v-assunto + "~"" 
                    + " -F inventario@lebes.com.br -f " + varqmail  
                    + " -m text/html -t " + v-mail).
                    
        pause 5 no-message.
        **/
        
        varqmail = "/admcom/relat/atuinvmail" + string(time).
        output to value(varqmail).
        put  "INVENTARIO FILIAL " estab.etbcod format "999" " <br>" skip
             "RESUMO DA ATUALIZAÇÃO EM " today     " <br><br>" skip
         "Arquivo da contagem: " varquivo format "x(50)"  " <br><br>" skip
         "Quantidade registros : " vregistro  " <br><br>" skip
         "Quantidade estoque   : " vqtdest    " <br><br>" skip
         "Quantidade contagem  : " vqtdcon    " <br><br>" skip
         "Divergencia : " vdiverg space(3) "Valor: " vvaldiverg "<br>" skip
         "Acrescimo   : " vmais space(3)   "Valor: " vvalmais "<br>" skip
         "Decrescimo  : " vmenos space(3)  "Valor: " vvalmenos "<br>" skip
           .
        output close.
        /*v-mail    = "claudir@custombs.com.br".
        */
        v-mail    = "inventario@lebes.com.br".

        /***** Servico antigo 
        unix silent value("/usr/bin/metasend -b -s " 
                    + "~"" + v-assunto + "~"" 
                    + " -F inventario@lebes.com.br -f " + varqmail  
                    + " -m text/html -t " + v-mail).
        ******/
       
        /* Antonio - Servico Novo */
        unix silent value("/admcom/progr/mail.sh " 
            + "~"" + v-assunto + "~"" + " ~"" 
            + varqmail + "~"" + " ~"" 
            + v-mail + "~"" 
            + " ~"inventario@lebes.com.br>~"" 
            + " ~"text/html~""). 
        /**/
        
        pause 5 no-message.
    end.                        
    find first tt-movim where tt-movim.procod > 0 no-lock no-error.
    if avail tt-movim and vblocok
    then run emite-NFe-ajuste-estoque.
end.

procedure emite-NFe-ajuste-estoque:
    
    def var p-ok as log init no.
    def var p-valor as char.
    p-valor = "".
    def var nfe-emite like plani.emite.
    if estab.etbcod = 998
    then nfe-emite = 993.
    else nfe-emite = estab.etbcod.
    run le_tabini.p (nfe-emite, 0,
            "NFE - TIPO DOCUMENTO", OUTPUT p-valor) .
    if p-valor = "NFE"
    then
        run manager_nfe.p (input "5927",
                           input ?,
                           output p-ok).
    else message "Erro: Verifique os registros TAB_INI do emitente."    
            view-as alert-box.            

end procedure.  
