{admcab.i}
def input parameter p-recid as recid.

def var vproc_imp as char init "123".
def var varq_imp as char  .
def var vforcod like forne.forcod.

find tpimport where recid(tpimport) = p-recid NO-LOCK.
vproc_imp = tpimport.numeropi.
vforcod   = tpimport.forcod.

varq_imp = tpimport.numeropi + ".csv".

disp vproc_imp label "Numero do Processo  " format "x(12)"
      help "Informe o Numero do processo de Importacao."
        with frame f1 1 down width 80 side-label.

find first tbimport where tbimport.numeroPI = vproc_imp no-lock no-error.
if not avail tbimport 
then do:           
    disp vproc_imp label "Numero do Processo  " format "x(12)"
            help "Informe o Numero do processo de Importacao."
                    with frame f1 1 down width 80 side-label.
                    
    disp vforcod at 1 label "Fornecedor/Remetente"
           with frame f1.
    find forne where forne.forcod = vforcod no-lock no-error.
    if not avail forne
    then do:
        message color red/with "Fonecedor nao cadastrado."
        view-as alert-box.
        undo, retry.
    end.
    disp forne.fornom no-label with frame f1.
    
    update varq_imp label "Nome do Arquivo     " format "x(30)"
        help "Informe o arquivo contendo as informacoes para emissao da nota."
        with frame f1.

    def var vdir_arq as char.
    vdir_arq = "/admcom/nfe/importacao/" + varq_imp.
    if search(vdir_arq) = ?
    then do:
        message color red/with "Arquivo nao encontrado."
        view-as alert-box.
        undo, retry.
    end.
    def var vlinha as int.
    def temp-table tt-tbimp no-undo
        field linha as int
        field valor as char extent 53 format "x(20)"
        index i1 linha
        .
    sresp = no.
    message "Confirma importar arquivo?"
    update sresp.
    if not sresp then undo.
    input from value(vdir_arq).
    repeat:
        vlinha = vlinha + 1. 
        create tt-tbimp.
        tt-tbimp.linha = vlinha.
        import delimiter ";" tt-tbimp.valor.
    end.
    input close.
    /*
    for each tt-tbimp.
        disp tt-tbimp with 3 column side-label.
    end.
        */
    def var vi as int.
    for each tt-tbimp:
        do vi = 1 to 53:
            if vi = 25
            then tt-tbimp.valor[vi] =
                            replace(tt-tbimp.valor[vi],"%","").
            if vi = 30
            then tt-tbimp.valor[vi] =
                            replace(tt-tbimp.valor[vi],"%","").
            if vi = 35
            then tt-tbimp.valor[vi] =
                            replace(tt-tbimp.valor[vi],"%","").
            if vi = 39
            then tt-tbimp.valor[vi] =
                            replace(tt-tbimp.valor[vi],"%","").
            if vi = 42
            then tt-tbimp.valor[vi] =
                            replace(tt-tbimp.valor[vi],"%","").
            if vi = 2
            then assign
                    tt-tbimp.valor[vi] = replace(tt-tbimp.valor[vi],"/","")
                    tt-tbimp.valor[vi] = replace(tt-tbimp.valor[vi],"-","")
                    .
            if num-entries(tt-tbimp.valor[vi],",") = 2
            then do:
                tt-tbimp.valor[vi] = replace(tt-tbimp.valor[vi],".","").
                tt-tbimp.valor[vi] = replace(tt-tbimp.valor[vi],",",".").
            end.
        end.
    end.
    def var vnumerodi as char.
    find first tt-tbimp where tt-tbimp.linha > 0 no-error.
    if avail tt-tbimp
    then vnumerodi = tt-tbimp.valor[2].
    else do:
        message color red/with "Arquivo com problema favor revisar o layout."
        view-as alert-box.
        return.
    end.
    vnumerodi = replace(vnumerodi,"/","").
    vnumerodi = replace(vnumerodi,"-","").
    if vnumerodi <> tpimport.nrdi
    then do:
        message color red/with 
        "Numero da DI do arquivo difere do numro informado."
        view-as alert-box.
        return.
    end.
    def var varq_out as char.
    varq_out = vdir_arq + ".out".
    output to value(varq_out).
    for each tt-tbimp where tt-tbimp.linha > 0 and
                        tt-tbimp.valor[1] <> "":
        export tt-tbimp.valor.
    end.
    output close.    
    vlinha = 0.
    input from value(varq_out).
    repeat:
        create tbimport.
        import tbimport.numero
               tbimport.nrdi
               tbimport.datadi
               tbimport.pednum
               tbimport.procod
               tbimport.prodes
               tbimport.adicao
               tbimport.seqitemdi
               tbimport.ncm
               tbimport.fobtotal
               tbimport.freteinter
               tbimport.seguro
               tbimport.acrescimo
               tbimport.deducao
               tbimport.movqtm
               tbimport.unidade
               tbimport.cifunitario
               tbimport.ciftotal
               tbimport.aliqii
               tbimport.iirecolhido
               tbimport.baseipi
               tbimport.aliqipi
               tbimport.ipirecolhido
               tbimport.baseicms
               tbimport.basefiscalicms
               tbimport.aliqicms
               tbimport.valoricms
               tbimport.basepiscofins
               tbimport.aliqpis
               tbimport.pisrecolhido
               tbimport.aliqcofins
               tbimport.cofinsrecolhido
               tbimport.antidumping
               tbimport.pesoliquido
               tbimport.pesobruto
               tbimport.nrli
               tbimport.txsiscomex
               tbimport.marinhamercante.
        tbimport.numeroPI = vproc_imp.
        tbimport.forcod   = vforcod.
        tbimport.movpc = tbimport.CifUnitario.
        tbimport.movtot = tbimport.cifunitario * tbimport.movqtm.
        vlinha = vlinha + 1.
        tbimport.movseq = vlinha.    
        if tbimport.seqitemdi = 0 then seqitemdi = 1.         
    end.
    input close.
end.
else do:
    vforcod = tbimport.forcod.
    disp vforcod 
               with frame f1.
    find forne where forne.forcod = vforcod  no-lock no-error.
    if not avail forne
    then do:
        message color red/with "Fonecedor nao cadastrado."
        view-as alert-box.
        undo, retry.
    end.
    disp forne.fornom no-label with frame f1.
end.               

{setbrw.i}                                                                      

def var recatu1         as recid.
def var recatu2         as recid.
def var reccont         as int.
def var esqpos1         as int.
def var esqpos2         as int.
def var esqregua        as log.
def var esqvazio        as log.
def var esqascend     as log initial yes.
def var esqcom1         as char format "x(15)" extent 5
    initial ["","  Totais","  Altera ","  Relatorio","  Exclui"].
def var esqcom2         as char format "x(15)" extent 5
            initial ["","  NF Entrada","  NF Transf","",""].
def var esqhel1         as char format "x(80)" extent 5
    initial ["teste teste",
             "",
             "",
             "",
             ""].
def var esqhel2         as char format "x(12)" extent 5
   initial ["teste teste  ",
            " ",
            " ",
            " ",
            " "].

form
    esqcom1
    with frame f-com1
                 row 8 no-box no-labels side-labels column 1 centered.
form
    esqcom2
    with frame f-com2
                 row screen-lines no-box no-labels side-labels column 1
                 centered.
assign
    esqregua = yes
    esqpos1  = 1
    esqpos2  = 1.

def new shared temp-table tt-plani like plani.
def new shared temp-table tt-movim like movim.
def new shared temp-table tt-movimimp like movimimp.
def temp-table btt-plani like plani.
def temp-table btt-movim like movim.

def var vtotalmov as dec.

form tbimport.prodes  column-label "Produto" format "x(30)"
     btt-movim.vuncom        format ">>9.999999"    column-label "Unitario"
     btt-movim.qcom          format ">>>>>9.9999"   column-label "Quantidade"
     vtotalmov              format ">>>,>>9.99"    column-label "Total"
     btt-movim.movbicms      format ">>>,>>9.99"    column-label "Base ICMS"
     btt-movim.movicms       format ">>,>>9.99"     column-label "Val ICMS" 
     btt-movim.movii         format ">>,>>9.99"     column-label "Val II"
     btt-movim.movpis        format ">>,>>9.99"     column-label "Val PIS"
     btt-movim.movcofins     format ">>,>>9.99"     column-label "Val Cofins"
     with frame f-linha 3 down color with/cyan /*no-box*/
     centered row 9.
                                                                         
                                                                                
def buffer btbcntgen for tbcntgen.                            
def var i as int.

def var vtotal  as dec format ">>>,>>>,>>9.99".
def var t-bicms as dec format ">>>,>>>,>>9.99".
def var t-icms  as dec format ">>>,>>>,>>9.99".
def var t-bicmssubst as dec format ">>>,>>>,>>9.99".
def var t-icmssubst  as dec format ">>>,>>>,>>9.99".
def var t-produtos   as dec format ">>>,>>>,>>9.99".
def var t-frete      as dec format ">>>,>>>,>>9.99".
def var t-seguro     as dec format ">>>,>>>,>>9.99".
def var t-odaces     as dec format ">>>,>>>,>>9.99".
def var t-ipi        as dec format ">>>,>>>,>>9.99".
def var t-nota       as dec format ">>>,>>>,>>9.99".
def var t-pbruto     as dec format ">>>,>>>.999".
def var t-pliquido   as dec format ">>>,>>>.999".
def var t-ii         as dec format ">>>,>>>,>>9.99".
def var t-pis        as dec format ">>>,>>>,>>9.99".
def var t-cofins     as dec format ">>>,>>>,>>9.99".

vtotal = 0.

run cal-plamov.

l1: repeat:
    disp esqcom1 with frame f-com1.
    disp esqcom2 with frame f-com2.
    assign
        a-seeid = -1 a-recid = -1 a-seerec = ?
        esqpos1 = 1 esqpos2 = 1. 
    hide frame f-linha no-pause.
    clear frame f-linha all.
    {sklclstb.i  
        &color = with/cyan
        &file = tbimport  
        &cfield = tbimport.prodes
        &noncharacter = /* 
        &ofield = " btt-movim.vuncom
                    btt-movim.qcom
                    vtotalmov
                    btt-movim.movbicms 
                    btt-movim.movicms
                    btt-movim.movii
                    btt-movim.movpis
                    btt-movim.movcofins
                    "  
        &aftfnd1 = " find btt-movim where 
                          btt-movim.procod = tbimport.procod
                          no-error. 
                     vtotalmov = btt-movim.vuncom * btt-movim.qcom.     
                          "
        &where  = " tbimport.numeropi = vproc_imp use-index indx5 "
        &aftselect1 = " run aftselect.
                        a-seeid = -1.
                        if esqcom1[esqpos1] = ""  EXCLUI"" or
                           esqcom2[esqpos2] = ""  CLASSE""
                        then do:
                            next l1.
                        end.
                        else next keys-loop. "
        &go-on = TAB 
        &naoexiste1 = " leave l1. " 
        &otherkeys1 = " run controle. "
        &locktype = " "
        &form   = " frame f-linha "
    }   
    if keyfunction(lastkey) = "end-error"
    then DO:
        leave l1.       
    END.
end.
hide frame f1 no-pause.
hide frame f2 no-pause.
hide frame ff2 no-pause.
hide frame f-linha no-pause.

procedure aftselect:
    clear frame f-linha1 all.

    if esqcom1[esqpos1] = "  altera"
    then do:
        update
         btt-movim.vuncom        format ">>9.999999"    label "Unitario"
         btt-movim.qcom          format ">>>>>9.9999"   label "Quantidade"
         with frame f-altera.
         vtotal = btt-movim.vuncom * btt-movim.qcom.
    disp vtotal                 format ">>>,>>9.99"    label "Total"     
         with frame f-altera.
         
    update btt-movim.movbicms      format ">>>,>>9.99"    label "Base ICMS"
         btt-movim.movicms       format ">>,>>9.99"     label "Val ICMS" 
         btt-movim.movii         format ">>,>>9.99"     label "Val II"
         btt-movim.movpis        format ">>,>>9.99"     label "Val PIS"
         btt-movim.movcofins     format ">>,>>9.99"     label "Val Cofins"
        with frame f-altera 1 column
        centered overlay.

    end.
    
    if esqcom1[esqpos1] = "  totais"
    THEN DO on error undo:

        for each tt-plani: delete tt-plani. end.
        for each tt-movim: delete tt-movim. end.
        find first btt-plani no-error.
        if avail btt-plani
        then do: 
            create tt-plani.
            buffer-copy btt-plani to tt-plani.
            for each btt-movim:
                create tt-movim.
                buffer-copy btt-movim to tt-movim.
            end.
            run total.
            for each tt-plani: delete tt-plani. end.
            for each tt-movim: delete tt-movim. end.
        end.
    END.
    if esqcom1[esqpos1] = "  relatorio"
    THEN DO on error undo:
        run relatorio.
    end.
    if esqcom1[esqpos1] = "  exclui"
    THEN DO on error undo:
        if tpimport.numnfe <> 0 and
           tpimport.numnfe <> ?
        then do:
            message color red/with
            "Nota Fical de ENTRADA ja foi emitida." skip
            "Numero NFE: " tpimport.numnfe
            view-as alert-box.
        end.  
        else do:
        sresp = no.
        message "Confirma excluir?" update sresp.
        if sresp
        then do on error undo:
            for each tbimport where tbimport.numeropi = vproc_imp  :
                delete tbimport.
            end.         
        end.
        end.
    end.
    if esqcom2[esqpos2] = "  NF Transf"
    THEN DO:
        if tpimport.numnft <> 0 and
           tpimport.numnft <> ?
        then do:
            message color red/with
            "Nota Fical de TRANSFERENCIA ja foi emitida." skip
            "Numero NFE: " tpimport.numnft
            view-as alert-box.
        end.   
        else run emite-transf.
    END.
    if esqcom2[esqpos2] = "  NF Entrada"
    THEN DO:
        if tpimport.numnfe <> 0 and
           tpimport.numnfe <> ?
        then do:
            message color red/with
            "Nota Fical de ENTRADA ja foi emitida." skip
            "Numero NFE: " tpimport.numnfe
            view-as alert-box.
        end.   
        else run emite-entrada.
    END.
    if esqcom2[esqpos2] = "    "
    THEN DO on error undo:
    
    END.

end procedure.

procedure controle:
        def var ve as int.
            if keyfunction(lastkey) = "TAB"
            then do:
                if esqregua
                then do:
                    esqpos1 = 1.
                    do ve = 1 to 5:
                    color display normal esqcom1[ve] with frame f-com1.
                    end.
                    color display message esqcom2[esqpos2] with frame f-com2.
                end.
                else do:
                    do ve = 1 to 5:
                    color display normal esqcom2[ve] with frame f-com2.
                    end.
                    esqpos2 = 1.
                    color display message esqcom1[esqpos1] with frame f-com1.
                end.
                esqregua = not esqregua.
            end.
            if keyfunction(lastkey) = "cursor-right"
            then do:
                if esqregua
                then do:
                    color display normal esqcom1[esqpos1] with frame f-com1.
                    esqpos1 = if esqpos1 = 5 then 5 else esqpos1 + 1.
                    color display messages esqcom1[esqpos1] with frame f-com1.
                end.
                else do:
                    color display normal esqcom2[esqpos2] with frame f-com2.
                    esqpos2 = if esqpos2 = 5 then 5 else esqpos2 + 1.
                    color display messages esqcom2[esqpos2] with frame f-com2.
                end.
                next.
            end.
            if keyfunction(lastkey) = "cursor-left"
            then do:
                if esqregua
                then do:
                    color display normal esqcom1[esqpos1] with frame f-com1.
                    esqpos1 = if esqpos1 = 1 then 1 else esqpos1 - 1.
                    color display messages esqcom1[esqpos1] with frame f-com1.
                end.
                else do:
                    color display normal esqcom2[esqpos2] with frame f-com2.
                    esqpos2 = if esqpos2 = 1 then 1 else esqpos2 - 1.
                    color display messages esqcom2[esqpos2] with frame f-com2.
                end.
                next.
            end.
end procedure.

procedure relatorio:

    def var varquivo as char.
    
    if opsys = "UNIX"
    then varquivo = "/admcom/relat/" + string(setbcod) + "."
                    + string(time).
    else varquivo = "..~\relat~\" + string(setbcod) + "."
                    + string(time).
    
    {mdadmcab.i &Saida     = "value(varquivo)"   
                &Page-Size = "64"  
                &Cond-Var  = "170" 
                &Page-Line = "66" 
                &Nom-Rel   = ""imortacao_01"" 
                &Nom-Sis   = """ FISCAL """ 
                &Tit-Rel   = """ RELATORIO ARQUIVO IMPORTACAO """ 
                &Width     = "170"
                &Form      = "frame f-cabcab"}

    for each btt-movim by movseq:
        find first tbimport where
                   tbimport.procod = tt-movim.procod
                   no-lock no-error.
        vtotal = btt-movim.vuncom * btt-movim.qcom.
        disp tbimport.prodes format "x(40)"
         btt-movim.vuncom      format ">>9.999999"    column-label "Unitario"
         btt-movim.qcom        format ">>>>>9.9999"   column-label "Quantidade"
         vtotal     (total)          
                    format ">>,>>>,>>9.99"    column-label "Total"     
         btt-movim.movbicms (total)
                    format ">>,>>>,>>9.99"    column-label "Base ICMS"
         btt-movim.movicms (total)    
                    format ">,>>>,>>9.99"     column-label "Val ICMS" 
         btt-movim.movii  (total)     
                    format ">,>>>,>>9.99"     column-label "Val II"
         btt-movim.movpis (total)     
                    format ">,>>>,>>9.99"     column-label "Val PIS"
         btt-movim.movcofins (total)  
                    format ">,>>>,>>9.99"     column-label "Val Cofins"
        with frame f-disp down width 170.
      
    end.
    
    output close.

    if opsys = "UNIX"
    then do:
        run visurel.p(varquivo,"").
    end.
    else do:
        {mrod.i}
    end.
end procedure.

procedure emite-entrada:
    def var vmovseq   like movim.movseq.
    def var vmovtot   as dec.
    def var vmovbicms as dec.
    def var vali      like movim.movalicms.
    def var vok as log.

    def var vobs as char extent 6 format "x(78)".

    for each tt-plani: delete tt-plani. end.
    for each tt-movim: delete tt-movim. end.
    
    find first btt-plani no-error.
    if not avail btt-plani then return.
    
    create tt-plani.
    buffer-copy btt-plani to tt-plani.

    for each btt-movim:
        create tt-movim.
        buffer-copy btt-movim to tt-movim.
    end.
        
    run total.
    
    update vobs with frame f-obs width 80 no-label
    title " informacoes complementares " overlay color message
    row 12.

    find first tt-plani.
    
    tt-plani.notobs[1] = vobs[1] + " " + vobs[2].
    tt-plani.notobs[2] = vobs[3] + " " + vobs[4].
    tt-plani.notobs[3] = vobs[5] + " " + vobs[6].
    
    sresp = no.
    message "Comfirma emitir NF Entrada Importacao?"
    update sresp.
    if sresp
    then run manager_nfe.p (input "3102", input ?, output vok).

    for each tt-plani: delete tt-plani. end.
    for each tt-movim: delete tt-movim. end.
    for each tt-movimimp. delete tt-movimimp. end.

end procedure.

procedure cal-plamov:
    def var vmovseq   like movim.movseq.
    def var vmovtot   as dec decimals 2.
    def var vmovbicms as dec.
    def var vicms     as dec decimals 2.
    def var vmovicms  as dec decimals 2.
    def var vmovii    as dec decimals 2.
    def var vmovpis   as dec decimals 2.
    def var vmovcof   as dec decimals 2.
    def var vfreteinter as dec decimals 2.
    def var vseguro as dec decimals 2.
    def var vali      like movim.movalicms.

    for each btt-plani:
        delete btt-plani.
    end.
    for each btt-movim:
        delete btt-movim.
    end. 

    create btt-plani.
    assign 
            btt-plani.etbcod   = estab.etbcod
            btt-plani.placod   = ?
            btt-plani.cxacod   = scxacod
            btt-plani.protot   = 0
            btt-plani.emite    = estab.etbcod
            btt-plani.platot   = 0
            btt-plani.serie    = "1"
            btt-plani.numero   = ?
            btt-plani.movtdc   = 4
            btt-plani.desti    = vforcod
            btt-plani.pladat   = today
            btt-plani.modcod   = "IMP"
            btt-plani.opccod   = 3102
            btt-plani.vencod   = 0
            btt-plani.notfat   = vforcod
            btt-plani.dtinclu  = today
            btt-plani.horincl  = time
            btt-plani.notsit   = no
            btt-plani.hiccod   = 3102
            btt-plani.numprocimp = vproc_imp
            .
    def var vctotransf as dec.
    vmovtot = 0.
    vmovbicms = 0.
    for each tbimport where
             tbimport.numeroPI = vproc_imp no-lock:
             
            vmovseq = tbimport.movseq.
            vfreteinter = tbimport.freteinter.
            vseguro = tbimport.seguro.

            find produ where produ.procod = tbimport.procod no-lock.

            vali = 18.

            create btt-movim.
            assign
                btt-movim.movtdc    = 4
                btt-movim.datexp    = today
                btt-movim.PlaCod    = ?
                btt-movim.etbcod    = estab.etbcod
                btt-movim.emite     = vforcod
                btt-movim.desti     = estab.etbcod
                btt-movim.movseq    = vmovseq
                btt-movim.movctm    = 0
                btt-movim.procod    = tbimport.procod
                btt-movim.movqtm    = tbimport.movqtm
                btt-movim.movpc     = (tbimport.fobtotal + vfreteinter
                                        + vseguro +
                                        tbimport.acrescimo -
                                        tbimport.deducao) / tbimport.movqtm
                btt-movim.MovAlICMS = vali
                btt-movim.movdat    = today
                btt-movim.MovHr     = btt-plani.horincl
                btt-movim.ocnum[7]  = tbimport.pednum
                btt-movim.movcsticms = "00"
                btt-movim.movbicms   = tbimport.basefiscalicms
                vicms = tbimport.basefiscalicms * (tbimport.aliqicms / 100)
                btt-movim.movicms    = btt-movim.movbicms *
                                        (btt-movim.MovAlICMS / 100)
                btt-movim.opfcod     = 3102
                btt-movim.movbpiscof = tbimport.basepiscofins
                btt-movim.movalpis  = tbimport.aliqpis
                btt-movim.movpis    = tbimport.basepiscofins *
                            (tbimport.aliqpis / 100)
                btt-movim.movalcofins  = tbimport.aliqcofins
                btt-movim.movcofins    = 
                         (tbimport.basepiscofins * (tbimport.aliqcofins / 100))
                btt-movim.movcstpiscof = 56
                btt-movim.movbii = tbimport.fobtotal + vfreteinter + vseguro
                              + tbimport.acrescimo + tbimport.deducao
                btt-movim.movii  = (tbimport.fobtotal + vfreteinter + vseguro
                              + tbimport.acrescimo - tbimport.deducao) *
                              (tbimport.aliqii / 100)
                btt-movim.movalii = tbimport.aliqii
                btt-movim.numprocimp = vproc_imp
                btt-movim.movacfin = (tbimport.marinhamercante +  
                                        tbimport.txsiscomex) 
                btt-movim.movbipi = tbimport.baseipi
                btt-movim.movalipi = tbimport.aliqipi
                btt-movim.movipi = tbimport.ipirecolhido 
                btt-movim.qCom   = tbimport.movqtm
                btt-movim.VUnCom = tbimport.cifunitario
                .
            
            btt-movim.VUnCom = (tbimport.fobtotal + vfreteinter + vseguro
                    + tbimport.acrescimo - tbimport.deducao)
                                / tbimport.movqtm .
            vmovtot = vmovtot + (btt-movim.VUnCom * btt-movim.qCom).
            vmovbicms = vmovbicms + btt-movim.movbicms.
            vmovicms = vmovicms + btt-movim.movicms.
            btt-movim.movpc = 
            dec(substr(string(btt-movim.VUnCom,">>>>>>>>9.999999"),1,14)).
            vmovii = vmovii + btt-movim.movii.
            vmovpis = vmovpis  +
                    (tbimport.basepiscofins * (tbimport.aliqcofins / 100)).
            vmovcof = vmovcof +
                      (tbimport.basepiscofins * (tbimport.aliqcofins / 100)).

            assign
                btt-plani.bicms  = btt-plani.bicms + btt-movim.movbicms 
                btt-plani.icms   = btt-plani.icms   + 
                          (tbimport.basefiscalicms * (tbimport.aliqicms / 100))
                btt-plani.platot = btt-plani.platot + btt-movim.movbicms
                btt-plani.protot = btt-plani.protot + vmovtot 
                btt-plani.notpis     = btt-plani.notpis + btt-movim.movpis
                btt-plani.notcofins  = btt-plani.notcofins + btt-movim.movcofins
                btt-plani.baseii = btt-plani.baseii + btt-movim.movbii
                btt-plani.ii  = btt-plani.ii + btt-movim.movii
                btt-plani.desacess = btt-plani.desacess +
                        (tbimport.marinhamercante + tbimport.txsiscomex) 
                btt-plani.bipi = btt-plani.bipi + btt-movim.movbipi
                btt-plani.ipi     = btt-plani.ipi + btt-movim.movipi
                        .
    end.
    btt-plani.notpis = vmovpis.
    btt-plani.notcofins = vmovcof.
    btt-plani.ii    = vmovii /*truncate(vmovii,3)*/.
    btt-plani.bicms = vmovbicms.
    btt-plani.icms = vmovicms /*truncate(vmovicms,3)*/.
    btt-plani.protot = vmovtot.
    btt-plani.platot = 0.
    btt-plani.platot = btt-plani.protot + 
                      btt-plani.desacess + 
                      btt-plani.ii + 
                      btt-plani.ipi +
                      btt-plani.notpis + 
                      btt-plani.notcofins + 
                      btt-plani.icms
                      .
end procedure.

procedure total:          

    def var vmovseq   like movim.movseq.
    def var vmovtot   as dec decimals 2.
    def var vmovbicms as dec.
    def var vmovicms  as dec decimals 2.
    def var vmovii    as dec decimals 2.
    def var vmovpis   as dec decimals 2.
    def var vmovcof   as dec decimals 2.
    def var vali      like movim.movalicms.


    vmovtot = 0.
    vmovbicms = 0.
    vmovicms = 0.
    vmovii = 0 .
    vmovpis = 0.
    vmovpis = 0.
    vmovcof = 0. 
    for each tt-movim:
                .
            
            vmovtot = vmovtot + (tt-movim.VUnCom * tt-movim.qCom).
            vmovbicms = vmovbicms + tt-movim.movbicms.
            vmovicms = vmovicms + tt-movim.movicms.
            /*
                    (tbimport.basefinalicms * (tbimport.aliqicms / 100)).
            */
            vmovii = vmovii + tt-movim.movii.
                    /*(tbimport.baseii * (tbimport.aliqii / 100)).*/
            vmovpis = vmovpis + tt-movim.movpis.
                    /*
                      (tbimport.basepiscofins * (tbimport.aliqpis / 100)).
                      */
            vmovcof = vmovcof + tt-movim.movcofins.
            /*
                      (tbimport.basepiscofins * (tbimport.aliqcofins / 100)).
              */
                        .
    end.
    find first tt-plani.
    tt-plani.notpis = vmovpis.
    tt-plani.notcofins = vmovcof.
    tt-plani.ii    = vmovii /*truncate(vmovii,3)*/.
    tt-plani.bicms = vmovbicms.
    tt-plani.icms = vmovicms /*truncate(vmovicms,3)*/.
    tt-plani.protot = vmovtot.
    tt-plani.platot = 0.
    tt-plani.platot = tt-plani.protot + 
                      tt-plani.desacess + 
                      tt-plani.ii +
                      tt-plani.ipi + 
                      tt-plani.notpis + 
                      tt-plani.notcofins + 
                      tt-plani.icms
                      .
        disp tt-plani.protot      label "Total produtos" 
             tt-plani.bicms       label "Base ICMS"
             tt-plani.icms        label "ICMS"
             tt-plani.notpis      label "PIS"
             tt-plani.notcofins   label "COFINS"
             tt-plani.ipi         label "IPI"
             tt-plani.desacess    label "Despesas"
             tt-plani.ii          label "II"     
             tt-plani.platot      label "Total da NF"
             with frame f-tott overlay color message
             1 column centered row 9
             .

    pause.
    hide frame f-tott.
end procedure.

procedure emite-transf:
    def var vmovseq   like movim.movseq.
    def var vmovtot   as dec.
    def var vmovbicms as dec.
    def var vali      like movim.movalicms.
    def var vok as log.
    def var vctotransf as dec.
    def var vobs as char extent 6 format "x(78)".

    for each tt-plani:
        delete tt-plani.
    end.
    for each tt-movim:
        delete tt-movim.
    end. 
    
    create tt-plani.
    assign 
            tt-plani.etbcod   = estab.etbcod
            tt-plani.placod   = ?
            tt-plani.cxacod   = scxacod
            tt-plani.protot   = 0
            tt-plani.emite    = estab.etbcod
            tt-plani.platot   = 0
            tt-plani.serie    = "1"
            tt-plani.numero   = ?
            tt-plani.movtdc   = 6
            tt-plani.desti    = 900
            tt-plani.pladat   = today
            tt-plani.modcod   = "IMP"
            tt-plani.opccod   = 5152
            tt-plani.vencod   = 0
            tt-plani.notfat   = 900
            tt-plani.dtinclu  = today
            tt-plani.horincl  = time
            tt-plani.notsit   = no
            tt-plani.hiccod   = 5152
            tt-plani.numprocimp = vproc_imp
            tt-plani.plaufemi = "RS"
            tt-plani.plaufdes = "RS"
            .

    vmovtot = 0.
    vmovbicms = 0.
    for each tbimport where
             tbimport.numeroPI = vproc_imp no-lock:
             
            vmovseq = tbimport.movseq.

            find produ where produ.procod = tbimport.procod no-lock.

            vali = 18.
            find estoq where estoq.etbcod = estab.etbcod and
                             estoq.procod = produ.procod
                             no-lock no-error.
            /*find last mvcusto where mvcusto.procod = produ.procod
                            no-lock no-error.
            if avail mvcusto and
                     mvcusto.valctotransf > 0
            then vctotransf = mvcusto.valctotransf.
            else*/ vctotransf = estoq.estcusto.
            
            vctotransf = tbimport.BaseFiscalICMS / tbimport.movqtm.
            
            create tt-movim.
            assign
                tt-movim.movtdc    = 6
                tt-movim.datexp    = today
                tt-movim.PlaCod    = ?
                tt-movim.etbcod    = estab.etbcod
                tt-movim.emite     = estab.etbcod
                tt-movim.desti     = 900
                tt-movim.movseq    = vmovseq
                tt-movim.movctm    = 0
                tt-movim.procod    = tbimport.procod
                tt-movim.movqtm    = tbimport.movqtm
                tt-movim.movpc     = vctotransf
                tt-movim.MovAlICMS = 0
                tt-movim.movdat    = today
                tt-movim.MovHr     = tt-plani.horincl
                tt-movim.ocnum[7]  = tbimport.pednum
                tt-movim.movcsticms = ""
                tt-movim.movbicms   = 0
                tt-movim.movicms    = 0
                tt-movim.opfcod     = 5152
                tt-movim.movbpiscof = 0
                tt-movim.movalpis  = 0
                tt-movim.movpis     = 0
                tt-movim.movalcofins  = 0
                tt-movim.movcofins     = 0
                tt-movim.movcstpiscof = 0
                tt-movim.movbii = 0
                tt-movim.movii  = 0
                tt-movim.movalii = 0
                tt-movim.numprocimp = vproc_imp
                tt-movim.movacfin = 0 
                tt-movim.movbipi = 0
                tt-movim.movalipi = 0
                tt-movim.movipi = 0. 
                .
                                          
            vmovtot = vmovtot + (tt-movim.movpc * tt-movim.movqtm).
            vmovbicms = 0.
            
            assign
                tt-plani.bicms  = 0
                tt-plani.icms   = 0
                tt-plani.platot = 0
                tt-plani.protot = 0
                tt-plani.notpis     = 0
                tt-plani.notcofins  = 0
                tt-plani.baseii = 0
                tt-plani.ii  = 0
                tt-plani.desacess = 0 
                tt-plani.bipi = 0
                tt-plani.ipi  = 0 .
    end.
    tt-plani.protot = vmovtot.
    tt-plani.platot = 0.
    tt-plani.platot = tt-plani.protot + 
                      tt-plani.desacess + 
                      tt-plani.ii + 
                      tt-plani.ipi +
                      tt-plani.notpis + 
                      tt-plani.notcofins + 
                      tt-plani.icms
                      .
          
    tt-plani.notobs[1] = vobs[1] + " " + vobs[2].
    tt-plani.notobs[2] = vobs[3] + " " + vobs[4].
    tt-plani.notobs[3] = vobs[5] + " " + vobs[6].
    
    find first tt-plani no-lock no-error.
    if avail tt-plani
    then
        disp tt-plani.protot      label "Total produtos" 
             tt-plani.bicms       label "Base ICMS"
             tt-plani.icms        label "ICMS"
             tt-plani.notpis      label "PIS"
             tt-plani.notcofins   label "COFINS"
             tt-plani.ipi         label "IPI"
             tt-plani.desacess    label "Despesas"
             tt-plani.ii          label "II"     
             tt-plani.platot      label "Total da NF"
             with frame f-nft overlay color message
             1 column centered row 9
             .
    else return.
    pause.
    hide frame f-nft.

    update vobs with frame f-obs width 80 no-label
    title " informacoes complementares " overlay color message
    row 12.

    tt-plani.notobs[1] = vobs[1] + " " + vobs[2].
    tt-plani.notobs[2] = vobs[3] + " " + vobs[4].
    tt-plani.notobs[3] = vobs[5] + " " + vobs[6].

    sresp = no.
    message "Comfirma emitir NF Transferencia?"
    update sresp.
    if sresp
    then run manager_nfe.p (input "5152", input ?, output vok).

    for each tt-plani:
        delete tt-plani.
    end.
    for each tt-movim:
        delete tt-movim.
    end.        

end procedure.


