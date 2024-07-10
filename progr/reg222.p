/*****************************************************************************
 Programa           : Coloca todos os clientes que estao atrazados no SPC
 Programador        : Cristiano Borges Brasil
 Nome do Programa   : RegSPC.p
 Criacao            : 31/10/1996
 Ultima Alteracao   : 31/10/1996
 ***************************************************************************/

 {admcab.i }

 def var i as i.

 def var vachou     as log.
 def var vv         as integer.
 def var vcidade    as char     format "x(30)".
 def var vdata      as date     initial today.
 def stream tela.

 update vdata label "Data Referencia"
 help "Registro de SPC dos vencimentos 50 dias antes da Data de Referencia"
                with width 80 color white/cyan row 4 side-label.

 def temp-table wf-lis
             field etbcod   like estab.etbcod
             field clicod   like clien.clicod
             field munic    like estab.munic
             field contnum  like contrato.contnum
             field vltotal  like contrato.vltotal
             field titdtven like titulo.titdtven
             field titdtemi like titulo.titdtemi.

do i = 50 to 2000:

 output stream tela to terminal.

 vachou = no.
 for each estab no-lock :
            for each titulo where titulo.empcod     = wempre.empcod and
                                  titulo.titnat     = no            and
                                  titulo.modcod     = "CRE"         and
                                  titulo.titdtven   = (vdata - i)  and
                                  titulo.etbcod     = estab.etbcod  and
                                  titulo.titsit     = "LIB" no-lock:

                    find clien where clien.clicod = titulo.clifor.
                    display vv      label "Registrados"
                            with centered color white/cyan row 9 1 down 1 column
                            title " SPC ".
                    display "Analizando Cliente"
                        clien.clicod
                        estab.etbcod
                        titulo.titdtven
                        titulo.titsit
                        with no-label side-label
                        color red/white centered row 13 1 down frame sds.
                    pause 0.

                    vachou = yes.

                    find clispc where clispc.clicod  = clien.clicod       and
                                      clispc.dtcanc  = ? no-error.
                    if not avail clispc
                    then do:
                        vv = vv + 1.

                        create clispc.
                        assign clispc.clicod    = clien.clicod
                               clispc.contnum   = int(titulo.titnum)
                               clispc.datexp    = today
                               clispc.dtneg     = today
                               clispc.dtcanc    = ?.
                        assign clien.dtspc[1]   = ?.

                        find contrato where contrato.contnum =
                                            int(titulo.titnum) no-lock no-error.
                        if avail contrato
                        then do:
                             create wf-lis.
                             assign wf-lis.etbcod   = estab.etbcod
                                    wf-lis.clicod   = clien.clicod
                                    wf-lis.munic    = estab.munic
                                    wf-lis.contnum  = contrato.contnum
                                    wf-lis.vltotal  = contrato.vltotal
                                    wf-lis.titdtemi = titulo.titdtemi
                                    wf-lis.titdtven = titulo.titdtven.
                        end.

                    end.

            end.
 end.
/*
 message "Lista Relatorio para S.P.C. ? " update sresp.
 if not sresp
 then return.
*/

find first wf-lis no-error.
if avail wf-lis then do:

 {mdadmcab.i &Saida = "printer"
             &Page-Size = "64"
             &Cond-Var  = "160"
             &Page-Line = "66"
             &Nom-Rel   = """"
             &Nom-Sis   = """SISTEMA CREDIARIO""  +
                          ""                                                "" +
                          ""                    AO SPC DE SAO JERONIMO      """
             &Tit-Rel   = """ LISTAGEM DE CLIENTES PARA INCLUSAO""  +
                          "" EM "" + string(vdata) + "" - CODIGO : 160 "" "
             &Width     = "160"
             &Form      = "with frame f-cab1"}




 for each wf-lis break by wf-lis.munic
                       by wf-lis.clicod:
    find clien      where clien.clicod     = wf-lis.clicod  no-lock.
    find estab      where estab.etbcod     = wf-lis.etbcod  no-lock.
    find contrato   where contrato.contnum = wf-lis.contnum no-lock.

        if first-of(wf-lis.munic)
        then do:
            vcidade = wf-lis.munic + " / SAO JERONIMO".
            put "CIDADE : " trim(vcidade) format "x(40)"
            skip(1).
        end.

        if avail contrato
        then
        display estab.etbcod
                clien.clicod                        label "Codigo"
                contrato.contnum
                clien.clinom        format "x(40)"
                clien.endereco[1]   format "x(30)"  label "Endereco"
                wf-lis.titdtemi
                clien.dtnasc
                clien.bairro[1]     format "x(20)"  label "Bairro"
                contrato.vltotal
                clien.mae           format "x(40)"  label "Mae"
                clien.cep[1]                        label "CEP"
                wf-lis.titdtven
                clien.pai           format "x(40)"  label "Pai"
                clien.ciccgc                        label "CPF"
                clien.ciinsc                        label "CI"
                skip
                fill("-",140)      format "x(140)" with width 160 3 column.

        if last-of(wf-lis.munic)
        then page.
end.
output close.


 {mdadmcab.i &Saida = "PRINTER"
             &Page-Size = "64"
             &Cond-Var  = "80"
             &Page-Line = "66"
             &Nom-Rel   = """"
             &Nom-Sis   = """SISTEMA CREDIARIO"""
             &Tit-Rel   = """ PROTOCOLO DE NEGATIVACAO ""  +
                          "" EM "" + string(TODAY) "
             &Width     = "80"
             &Form      = "with frame f-cab2"}

 for each wf-lis break by wf-lis.clicod:
    find clien      where clien.clicod     = wf-lis.clicod  no-lock.
    find estab      where estab.etbcod     = wf-lis.etbcod  no-lock.
    find contrato   where contrato.contnum = wf-lis.contnum no-lock.

    display clien.clicod
            clien.clinom
            contrato.contnum
            wf-lis.titdtven
            contrato.etbcod with width 80.
 end.

 display skip(3)
         "___________________________" colon 50
         skip(1)
         "RECEBIDO: _____/_____/_____" colon 50 with frame ffim width 80.

 output close.
 /*
 message "Lista Relatorio para S.P.C. - INTERCAMBIO ? " update sresp.
 if not sresp
 then return.
 */
 {mdadmcab.i &Saida = "printer"
             &Page-Size = "64"
             &Cond-Var  = "160"
             &Page-Line = "66"
             &Nom-Rel   = """"
             &Nom-Sis   = """SISTEMA CREDIARIO""  +
                          ""                                                "" +
                          ""                    AO SPC DE "" + estab.munic "
     &Tit-Rel   = """ LISTAGEM DE CLIENTES PARA INCLUSAO POR INTERCAMBIO""  +
                          "" EM "" + string(vdata) + "" - CODIGO : 160 """
             &Width     = "160"
             &Form      = "with frame f-cab3"}

 for each wf-lis where (wf-lis.etbcod = 10 or
                        wf-lis.etbcod = 16 or
                        wf-lis.etbcod = 18 or
                        wf-lis.etbcod = 19 or
                        wf-lis.etbcod = 21 or
                        wf-lis.etbcod = 23)
                 break by wf-lis.munic
                       by wf-lis.clicod:
    find clien      where clien.clicod     = wf-lis.clicod  no-lock.
    find estab      where estab.etbcod     = wf-lis.etbcod  no-lock.
    find contrato   where contrato.contnum = wf-lis.contnum no-lock.

        if first-of(wf-lis.munic)
        then do:
            vcidade = wf-lis.munic.
            put "CIDADE : " trim(vcidade) format "x(40)"
            skip(1).
        end.

        if avail contrato
        then
        display estab.etbcod
                clien.clicod                        label "Codigo"
                contrato.contnum
                clien.clinom        format "x(40)"
                clien.endereco[1]   format "x(30)"  label "Endereco"
                wf-lis.titdtemi
                clien.dtnasc
                clien.bairro[1]     format "x(20)"  label "Bairro"
                contrato.vltotal
                clien.mae           format "x(40)"  label "Mae"
                clien.cep[1]                        label "CEP"
                wf-lis.titdtven
                clien.pai           format "x(40)"  label "Pai"
                clien.ciccgc                        label "CPF"
                clien.ciinsc                        label "CI"
                skip
                fill("-",140)      format "x(140)" with width 160 3 column.

        if last-of(wf-lis.munic)
        then page.
end.
output close.

for each wf-lis:
    delete wf-lis.
end.

end.

end.
