/*****************************************************************************
 Programa           : Coloca todos os clientes que estao atrazados no SPC
 Programador        : Cristiano Borges Brasil
 Nome do Programa   : RegSPC.p
 Criacao            : 31/10/1996
 Ultima Alteracao   : 31/10/1996
 ***************************************************************************/

 {admcab.i }

 def var vachou     as log.
 def var vv         as integer.
 def var vcidade    as char     format "x(30)".
 def var vdata      as date     initial today.
 def stream tela.


 def temp-table wf-lis
             field etbcod   like estab.etbcod
             field clicod   like clien.clicod
             field munic    like estab.munic
             field contnum  like contrato.contnum
             field vltotal  like contrato.vltotal
             field titdtven like titulo.titdtven.

 output stream tela to terminal.


 for each clien:

    if clien.clicod = 1
    then next.

    display vv      label "Registrados"
            with centered color white/cyan row 9 1 down 1 column
            title " SPC ".
    pause 0.

    /*************************
    if clien.dtspc[1] <> ?
    then next.
    **************************/

    vachou = no.

    find first clispc where clispc.clicod  = clien.clicod       and
                            clispc.dtcanc  = ? no-lock no-error.
    if not avail clispc
    then do:
        vachou = no.
        display "Analizando Cliente"
                 clien.clicod
                 with no-label side-label
                 color red/white centered row 13 1 down frame sds.
        pause 0.

        for each estab no-lock,
                each titulo where titulo.empcod     = wempre.empcod and
                                  titulo.titnat     = no            and
                                  titulo.modcod     = "CRE"         and
                                  titulo.titdtven   = (vdata - 50)  and
                                  titulo.etbcod     = estab.etbcod  and
                                  titulo.clifor     = clien.clicod  and
                                  titulo.titsit     = "LIB" no-lock:
                    vachou = yes.
                    find clispc where clispc.clicod  = clien.clicod       and
                                      clispc.dtcanc  = ? no-error.
                    if not avail clispc
                    then do:
                        create clispc.
                        assign clispc.clicod    = clien.clicod
                               clispc.contnum   = int(titulo.titnum)
                               clispc.datexp    = today
                               clispc.dtneg     = today
                               clispc.dtcanc    = ?.
                        assign clien.dtspc[1]   = today.
                    end.

                    find contrato where contrato.contnum = int(titulo.titnum)
                                                              no-lock no-error.
                    if avail contrato
                    then do:
                        create wf-lis.
                        assign wf-lis.etbcod   = estab.etbcod
                               wf-lis.clicod   = clien.clicod
                               wf-lis.munic    = estab.munic
                               wf-lis.contnum  = contrato.contnum
                               wf-lis.vltotal  = contrato.vltotal
                               wf-lis.titdtven = titulo.titdtven.
                    end.
                    vv = vv + 1.
                    if vachou
                    then leave.
            end.
        end.
 end.

 {mdadmcab.i &Saida = "RELATO"
             &Page-Size = "64"
             &Cond-Var  = "160"
             &Page-Line = "66"
             &Nom-Rel   = ""DREB040""
             &Nom-Sis   = """SISTEMA CREDIARIO"""
             &Tit-Rel   = """ LISTAGEM DE CLIENTES PARA SPC""  +
                          "" EM "" + string(vdata) "
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
        display clien.clicod                        label "Codigo"
                clien.clinom        format "x(30)"
                clien.endereco[1]   format "x(30)"  label "Endereco"
                clien.bairro[1]     format "x(20)"  label "Bairro"
                clien.cep[1]                        label "CEP"
                clien.ciccgc                        label "CPF"
                clien.ciinsc                        label "CI"
                clien.mae           format "x(30)"  label "Mae"
                clien.pai           format "x(30)"  label "Pai"
                clien.dtnasc
                contrato.contnum
                wf-lis.titdtven
                contrato.vltotal
                skip
                fill("-",140)      format "x(140)" with width 160 3 column.

        if last-of(wf-lis.munic)
        then page.
end.
