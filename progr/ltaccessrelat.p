/* Programa de relatorio das atualizacoes cadastrais da Lebes para Access*/
{admcab.i}

def input parameter par-reclotcre  as recid.
def var vdiasatraso   as int.
def var vclfnom     as char format "x(30)".
def var vcgccpf     as char.
def var vclfcod     as int.
def var vsaldo      like titulo.titvlcob.
def var vok         as int.
def var vnok        as int.
def var vgertot     as dec.
def var vgerven     as dec.
def var vvencido    as dec.
def var vsituacao   as log.
def var varquivo    as char.
def var vlrcomissao as dec.
def var vcomissao   as int.
def var vtotcomissao as dec.
def buffer btitulo for titulo.
def var vtotcli    as int.
def var vokcli     as int.
def var vnokcli    as int.
def var vcob as char format "x(12)".

form with frame f-linc down no-box.

find lotcre where recid(lotcre) = par-reclotcre no-lock.
find lotcretp of lotcre no-lock.

varquivo = "../relat/ltaccessrel" + string(time).
{mdadmcab.i
    &Saida     = "value(varquivo)"
    &Page-Size = "64"
    &Cond-Var  = "121"
    &Page-Line = "66"
    &Nom-Rel   = ""CERRELINC""
    &Nom-Sis   = """BS"""
    &Tit-Rel   = "lotcretp.LtCreTNom + "" - LOTE "" +
                  string(lotcre.ltcrecod) + "" - "" + lotcre.ltselecao"
    &Width     = "121"
    &Form      = "frame f-cabcab"}

for each lotcretit where lotcretit.ltcrecod = lotcre.ltcrecod 
                   no-lock
                   break by lotcretit.clfcod.
    find titulo where titulo.empcod = wempre.empcod
                  and titulo.titnat = lotcretp.titnat
                  and titulo.modcod = lotcretit.modcod
                  and titulo.etbcod = lotcretit.etbcod
                  and titulo.clifor = lotcretit.clfcod
                  and titulo.titnum = lotcretit.titnum
                  and titulo.titpar = lotcretit.titpar
                no-lock no-error.
    if not avail titulo then next.
    run clifor.
    find cpclien where cpclien.clicod = vclfcod no-lock no-error.
    if not avail cpclien then next.
    
    find lotcreag of lotcretit no-lock.
    

    vsaldo = titulo.titvlcob - titulo.titvlpag.
    vsituacao = lotcreag.ltsituacao = yes /* clifor marcado */ and
                lotcreag.ltvalida   = ""  /* valido */   and
                lotcretit.ltsituacao      /* titulo marcado */.

    if titulo.cobcod = 11 then vcob = "atualizacao cadastral".
    else vcob = "sem retorno".
    
    disp vsituacao no-label format "*/"
         space(0)
         lotcretit.clfcod   format "9999999999"
         vclfnom            column-label "Cliente" format "x(20)"
         {titnum.i}
         titulo.etbcod
         titulo.titdtemi    format "99/99/99"
         titulo.titdtven    format "99/99/99"             
         /*
         titulo.titdtpag    format "99/99/99"
         */
         titulo.titvlcob
         /*
         titulo.titvlpag
         */
         cpclien.datalt     column-label "Dt.Alteracao"
         lotcretit.ltcrecod column-label "Lote" format "999999999"
         vcob               column-label "ACCESS"
         /*
         vvencido           column-label "Vencido" format ">>>>,>>9.99"
         lotcreag.ltvalida  column-label "Erros"   format "x(18)"
         */
         with frame f-linc no-box width 141 down.
    down with frame f-linc.

    if vsituacao
    then assign
            vok     = vok + 1
            vgertot = vgertot + vsaldo
            vgerven = vgerven + vvencido
            vtotcomissao = vtotcomissao + vlrcomissao.
    else assign
            vnok    = vnok + 1.
end.
for each lotcreag of lotcre no-lock.
        vtotcli = vtotcli + 1.
        if lotcreag.ltsituacao = yes /* clifor marcado */ and
        lotcreag.ltvalida   = ""  /* valido */ 
        then do:
            vokcli = vokcli + 1.
        end.
        else do:
            vnokcli = vnokcli + 1.
        end.
end.        


    down 1 with frame f-linc.
    
    disp "Total Clientes" @ vclfnom 
         "Ok = " + string(vokcli, "zzz9")              @ titulo.titnum
         "Nao ok ="                                    @ titulo.titdtemi
         string(vnokcli, "zzz9")                       @ titulo.titdtven
         with frame f-linc.
    
    down 1 with frame f-linc.
    
    disp "TOTAL GERAL" @ vclfnom
         "Ok = " + string(vok, "zzzz9")              @ titulo.titnum
         "Nao ok ="                                 @ titulo.titdtemi
         string(vnok, "zzzz9")                       @ titulo.titdtven
         with frame f-linc down.
    down 1 with frame f-linc.

    if opsys = "UNIX"
    then do:
        output close.
        run visurel.p (varquivo,"").
    end.
    else do:
        {mrod.i}
    end.    


procedure clifor.
    if lotcretp.titnat
    then do.
        find forne where forne.forcod = lotcretit.clfcod no-lock.
        assign
            vclfcod = forne.forcod
            vcgccpf = forne.forcgc
            vclfnom = forne.fornom.
    end.
    else do.
        find clien where clien.clicod = lotcretit.clfcod no-lock no-error.
        if avail clien then
        assign
            vclfcod = clien.clicod
            vcgccpf = clien.ciinsc
            vclfnom = clien.clinom.
    end.
end.

