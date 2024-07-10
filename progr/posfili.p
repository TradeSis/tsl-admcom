/*----------------------------------------------------------------------------*/
/* finan/posfili.p                               Posicao Financeira Listagem  */
/*----------------------------------------------------------------------------*/

{admcab.i}

def var varquivo as char format "x(20)".
def var vnome like clien.clinom.
def var wetbcod      like estab.etbcod initial 0.
def var wmodcod     like titulo.modcod initial "".
def var wtitnat     like titulo.titnat initial yes.
def var waccod      like titulo.clifor.
def var wforcod     like titulo.clifor initial 0.
def var wclicod     like clien.clicod.
def var wdti        like titulo.titdtven label "Periodo" initial today.
def var wdtf        like titulo.titdtven.
def var wtitdat     as   date format "99/99/9999" column-label "Cob/Pag".
def var wtitvlcob   like titulo.titvlcob format ">,>>>,>>9.99".
def var wtotcob     like titulo.titvlcob format ">,>>>,>>9.99".
def var wtotpag     like titulo.titvlcob format ">,>>>,>>>,>>9.99".
def var wtotjur     like titulo.titvlcob format ">>,>>>,>>9.99".
def var wtotdes     like titulo.titvlcob format ">,>>>,>>9.99".
def var wgercob     like titulo.titvlcob format ">,>>>,>>9.99".
def var wgerpag     like titulo.titvlcob format ">,>>>,>>>,>>9.99".
def var wgerjur     like titulo.titvlcob format ">>,>>>,>>9.99".
def var wgerdes     like titulo.titvlcob format ">,>>>,>>9.99".
def var wgerabe     like titulo.titvlcob format ">,>>>,>>9.99".
def var wseq        as   i extent 2.
def var i           as   i.
def var wopcao      as   char.
def var wforcli     as   i format "999999" label "For/Cli".
def var wnome       as   c format "x(30)"  label "Nome" .
wdtf = wdti + 30.
def stream log.

def buffer bplani for plani.
def var i-serie as int.

repeat with column 45 side-labels 1 down width 35 row 4 frame f1:
    wetbcod = 0.
    disp "" @ wetbcod colon 12.
    prompt-for wetbcod label "Estab." .
    if input wetbcod <> ""
       then do:
               find estab where estab.etbcod  = input wetbcod no-lock.
               display etbnom no-label format "x(10)".
               wetbcod = estab.etbcod.
       end.
       else disp "TODOS" @ etbnom.
    wmodcod = "".
    update wmodcod validate(wmodcod = "" or
                            can-find(modal where modal.modcod = wmodcod),
                            "Modalidade nao cadastrada")
                            label "Modal/Natur" colon 12.
    display " - ".
    if wmodcod = "CRE"
       then wtitnat = no.
    update wtitnat no-label.
    repeat:
        clear frame ff.
        clear frame fc.
        if wtitnat
           then do with column 1 side-labels 1 down width 48 row 4 frame ff:
             disp "" @ wforcod.
             update wforcod label "Fornecedor"
                help "Informe o codigo do Fornecedor ou <ENTER> para todos".
             if input wforcod <> 0
                then do:
                        find forne where forne.forcod = input wforcod.
                        display fornom format "x(32)" no-label at 10.
                end.
                else disp "RELATORIO DE TODOS OS FORNECEDORES" @ fornom.
           end.
           else do with column 1 side-labels 1 down width 48 row 4 frame fc:
             disp "" @ wclicod.
             update wclicod label "Cliente"
                help "Informe o codigo do Cliente ou <ENTER> para todos".
             if input wclicod <> 0
                then do:
                        find clien where clien.clicod = input wclicod.
                        display clinom format "x(32)" no-label at 10.
                end.
                else disp "RELATORIO DE TODOS OS CLIENTES" @ clinom.
           end.
        if not wtitnat
        then wforcod = wclicod.
        else wforcod = wforcod.
        form wdti colon 12
             " A"
             wdtf colon 29 no-label with frame fdat width 80 side-label.

        update wdti
               wdtf with frame fdat.

    if opsys = "UNIX"
    then varquivo = "/admcom/relat/res" + string(time).
    else varquivo = "..\relat\res" + string(time).

    {mdadmcab.i 
        &Saida     = "value(varquivo)" 
        &Page-Size = "62" 
        &Cond-Var  = "150"  
        &Page-Line = "66"
        &Nom-Rel   = ""POSFILI""
        &Nom-Sis   = """SISTEMA FINANCEIRO - CONTAS A "" 
                   + caps(string(wtitnat,""pagar/receber"")) "
        &Tit-Rel   = """POSICAO FINANCEIRA - PERIODO DE "" 
                   + string(wdti) + "" A "" + string(wdtf) "
        &Width     = "150"
        &Form      = "frame f-cabcab"}
        
        form 
             plani.pladat    column-label "EmissaoNF"
             titulo.titdtemi 
             titulo.titdtven
             wtitdat        column-label "Ven/Pag"
             titulo.clifor  format ">>>>>9"
             vnome   format "X(22)" column-label "Agente Comercial"
             titulo.titnum  format "x(08)"
             titulo.titpar
             titulo.etbcod
             titulo.modcod
             titulo.titvlcob
             titulo.titvlpag
             titulo.titvljur column-label "Juros   " format ">>>,>>9.99"
             titulo.titvldes column-label "Desconto" format ">>>,>>9.99"
             titulo.titsit
             with frame fdet width 160 no-box down.


        form wgerabe label "Total A Pagar" at 20
             wgercob label "Total Cobrado" at 20
             wgerpag label "total Pago"    at 20
             wgerjur label "Total Juros"   at 20
             wgerdes label "Total Desconto" at 20
             with frame ftotger width 160 side-label.

        wtotpag = 0.
        wtotcob = 0.
        wtotjur = 0.
        wtotdes = 0.
        wgerpag = 0.
        wgercob = 0.
        wgerjur = 0.
        wgerdes = 0.
        wgerabe = 0.

        for each titulo use-index iclicod where
                              titulo.empcod = wempre.empcod   and
                              titnat   =   wtitnat            and
                              ( if wmodcod = ""
                                then true 
                                else titulo.modcod = wmodcod) and
                              titulo.titdtven >=  wdti        and
                              titulo.titdtven <=  wdtf        and
                              ( if wetbcod = 0
                                then true
                                else titulo.etbcod = wetbcod)  and
                              titulo.clifor = wforcod  and
                              titulo.titsit <> "BLO"  no-lock
                                by titulo.titdtven: 
             
                                
             if titulo.titsit = "PAG"
                then assign wtitdat = titdtpag
                            wtotpag = wtotpag + titvlpag.
                else assign wtitdat = titulo.titdtven
                            wtotcob = wtotcob + titvlcob
                            wtotdes = wtotdes + titvldes
                            wtotjur = wtotjur + titvljur.

             if titulo.titnat
             then do:
                find forne where forne.forcod = titulo.clifor  no-lock.
                vnome = forne.fornom.
             end.
             else do:
                find clien where clien.clicod  = titulo.clifor  no-lock.
                vnome = clien.clinom.
             end.
             
             find last bplani use-index pladat where bplani.movtdc = 4 and
                               bplani.emite = titulo.clifor  and
                               bplani.etbcod = titulo.etbcod and
                               bplani.pladat <= titulo.titdtemi
                               no-lock no-error.
            if avail bplani
            then do:
                find last plani where  plani.movtdc = 4 and
                                    plani.etbcod = titulo.etbcod and
                                    plani.emite  = titulo.clifor and
                                    plani.serie  = bplani.serie and
                                    plani.numero = int(titnum)
                                    no-lock no-error.
                                
            end. 
            if not avail plani 
            then do i-serie = 1 to 50:
                find last plani where  plani.movtdc = 4 and
                          plani.etbcod = titulo.etbcod and
                          plani.emite  = titulo.clifor and
                          plani.serie  = string(i-serie) and
                          plani.numero = int(titnum)
                          no-lock no-error.
                if avail plani
                then do:
                    leave.
                end.
            end.
            display plani.pladat when avail plani
                     titulo.titdtemi
                     titulo.titdtven
                     wtitdat
                     titulo.clifor
                     vnome
                     titulo.titnum
                     titulo.titpar
                     titulo.etbcod
                     titulo.modcod
                     (titulo.titvlcob + titulo.titvljur - titulo.titvldes)
                      when titvlcob <> 0 @ titulo.titvlcob
                      format "->,>>>,>>9.99"
                     titulo.titvlpag when titvlpag <> 0
                     titulo.titvljur
                     titulo.titvldes
                     titulo.titsit with frame fdet.
                     
             down with frame fdet.
             
             
             
             assign  wgercob = wgercob + titulo.titvlcob
                     wgerpag = wgerpag + titulo.titvlpag
                     wgerjur = wgerjur + titulo.titvljur
                     wgerdes = wgerdes + titulo.titvldes.
             
             if titulo.titsit = "LIB" or
                titulo.titsit = "CON"
             then wgerabe = wgerabe +  (titulo.titvlcob +  
                                        titulo.titvljur -  
                                        titulo.titvldes).

        end.


        display wgerabe  format "->,>>>,>>9.99"
                wgercob
                wgerpag
                wgerjur
                wgerdes
                with frame ftotger.
        output close.
        if opsys = "UNIX"
        then do:
            run visurel.p(varquivo,"").
        end.
        else do:
            {mrod.i}
        end.
    end.
end.
