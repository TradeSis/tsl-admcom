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
def var vtitnum    like d.titulo.titnum.
def input param rec-lotcre as recid.
def output param vgertot as dec.
def output param vtotcomissao as dec.


find lotcre where recid(lotcre) = rec-lotcre no-lock.
find lotcretp of lotcre no-lock.

/* BUSCA OS TITULOS LP */
for each lotcretit where lotcretit.ltcrecod = lotcre.ltcrecod 
                   no-lock
                   break by lotcretit.clfcod.



find d.titulo where d.titulo.empcod = 19
                  and d.titulo.titnat = no
                  and d.titulo.modcod = lotcretit.modcod
                  and d.titulo.etbcod = lotcretit.etbcod
                  and d.titulo.clifor = lotcretit.clfcod
                  and d.titulo.titnum = lotcretit.titnum
                  and d.titulo.titpar = lotcretit.titpar
                no-lock no-error.
if not avail d.titulo then next.
run clifor.
find lotcreag of lotcretit no-lock.
    

vsaldo = d.titulo.titvlcob - d.titulo.titvlpag.
vsituacao = lotcreag.ltsituacao = yes /* clifor marcado */ and
                lotcreag.ltvalida   = ""  /* valido */   and
                lotcretit.ltsituacao      /* titulo marcado */.

vdiasatraso = today - d.titulo.titdtven.
run calcula-comissao(input vdiasatraso, 
    output vcomissao, output vlrcomissao).

vtitnum = trim(d.titulo.titnum + 
            (if d.titulo.titpar > 0 then "/" + string(d.titulo.titpar)                       else "")).


disp     vsituacao no-label format "*/"
         space(0)
         lotcretit.clfcod   format "9999999999"
         vclfnom            column-label "Cliente" format "x(20)"
         vtitnum            column-label "Titulo"
         d.titulo.etbcod
         d.titulo.titdtemi    format "99/99/99"
         d.titulo.titdtven    format "99/99/99"             
         vsaldo             format "->>>>,>>9.99"
         vdiasatraso        column-label "Dias Atraso" 
         vcomissao          column-label "Comissao"
         vlrcomissao        column-label "Valor Com."
         "LP"               column-label "Tipo"
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
        vcomissao = 8
        vlrcomissao = vsaldo * (vcomissao / 100).

if par-dias > 61 and par-dias <= 90
then 
    assign 
        vcomissao   = 11
        vlrcomissao = vsaldo * (vcomissao / 100).

if par-dias > 91 and par-dias <= 120
then 
    assign
        vcomissao   = 14
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
        vcomissao = 23
        vlrcomissao = vsaldo * (vcomissao / 100).

end.
