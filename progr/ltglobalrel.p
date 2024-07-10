/* Relatorio Lote GLOBAL */
{admcab.i}

def input parameter par-reclotcre  as recid.
def var vgertot as dec.
def var vtotcomissao as dec.
def var vdiasatraso   as int.
def var vclfnom     as char format "x(30)".
def var vcgccpf     as char.
def var vclfcod     as int.
def var vsaldo      as dec.
def var vok         as int.
def var vnok        as int.
def var vgerven     as dec.
def var vvencido    as dec.
def var vsituacao   as log.
def var varquivo    as char.
def var vlrcomissao as dec.
def var vcomissao   as int.
def var vtotcli    as int.
def var vokcli     as int.
def var vnokcli    as int.
def var vtottit    as int.

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

run conecta_d.p.
if connected ("d")
then do:

    run ltaccessrellp.p (input recid(lotcre), 
                            output vgertot, 
                            output vtotcomissao).

disconnect d.
end. 

disp skip(3).
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
    find lotcreag of lotcretit no-lock.
    

    vsaldo = titulo.titvlcob - titulo.titvlpag.
    vsituacao = lotcreag.ltsituacao = yes /* clifor marcado */ and
                lotcreag.ltvalida   = ""  /* valido */   and
                lotcretit.ltsituacao      /* titulo marcado */.

    vdiasatraso = today - titulo.titdtven.
    run calcula-comissao(input vdiasatraso, 
    output vcomissao, output vlrcomissao).

    disp vsituacao no-label format "*/"
         space(0)
         lotcretit.clfcod   format "9999999999"
         vclfnom            column-label "Cliente" format "x(20)"
         {titnum.i}
         titulo.etbcod
         titulo.titdtemi    format "99/99/99"
         titulo.titdtven    format "99/99/99"             
         vsaldo             format "->>>>,>>9.99"
         /*
         vvencido           column-label "Vencido" format ">>>>,>>9.99"
         lotcreag.ltvalida  column-label "Erros"   format "x(18)"
         */
         vdiasatraso        column-label "Dias Atraso" 
         vcomissao          column-label "Comissao"
         vlrcomissao        column-label "Valor Com."
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

for each lotcretit of lotcre no-lock.
        vtottit = vtottit + 1. 
end.        


    down 1 with frame f-linc.
    
    disp "Total Clientes" @ vclfnom 
         "Ok = " + string(vokcli, "zzzz9")               @ titulo.titnum
         with frame f-linc.
    
    down 1 with frame f-linc.
    
    disp "Total Titulos" @ vclfnom
         "Ok = " + string(vtottit, "zzzz9")             @ titulo.titnum
         vgertot                                        @ vsaldo
         vtotcomissao                                   @ vlrcomissao
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

hide message no-pause.
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

procedure calcula-comissao.
def input  parameter par-dias as int.
def output parameter vcomissao as dec.
def output parameter vlrcomissao as dec.

vcomissao   = 0.
vlrcomissao = 0.

if par-dias > 0 and par-dias <= 30
then
    assign 
        vcomissao   = 6
        vlrcomissao = vsaldo * (vcomissao / 100).

if par-dias > 31 and par-dias <= 60
then 
    assign 
        vcomissao = 9
        vlrcomissao = vsaldo * (vcomissao / 100).

if par-dias > 61 and par-dias <= 90
then 
    assign 
        vcomissao   = 12
        vlrcomissao = vsaldo * (vcomissao / 100).

if par-dias > 91 and par-dias <= 120
then 
    assign
        vcomissao   = 15
        vlrcomissao = vsaldo * (vcomissao / 100).

if par-dias > 121 and par-dias <= 180
then
    assign 
        vcomissao = 18
        vlrcomissao = vsaldo * (vcomissao / 100).

if par-dias > 181 and par-dias <= 360
then 
    assign 
    vcomissao = 20
    vlrcomissao = vsaldo * (vcomissao / 100).

if par-dias > 361
then 
    assign 
        vcomissao = 25
        vlrcomissao = vsaldo * (vcomissao / 100).



end.
