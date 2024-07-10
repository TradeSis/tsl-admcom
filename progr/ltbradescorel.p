{admcab.i}

def input parameter par-reclotcre  as recid.

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
def var vgercob like titulo.titvlcob.
def var vgerjur like titulo.titvljur.
def var vgerdes like titulo.titvldes.
def buffer btitulo for titulo.

form with frame f-linc down no-box.

find lotcre where recid(lotcre) = par-reclotcre no-lock.
find lotcretp of lotcre no-lock.

def var for-cgc-cpf as char.

varquivo = "../relat/ltbanirel" + string(time).
{mdadmcab.i
    &Saida     = "value(varquivo)"
    &Page-Size = "64"
    &Cond-Var  = "170"
    &Page-Line = "66"
    &Nom-Rel   = ""CERRELINC""
    &Nom-Sis   = """BS"""
    &Tit-Rel   = "lotcretp.LtCreTNom + "" - LOTE "" +
                  string(lotcre.ltcrecod) + "" - "" + lotcre.ltselecao"
    &Width     = "121"
    &Form      = "frame f-cabcab"}

for each lotcretit of lotcre where 
                        lotcretit.ltsituacao = yes and
                        lotcretit.ltvalida   = ""
                   no-lock break by lotcretit.clfcod.
    find last titulo where titulo.empcod = wempre.empcod
                  and titulo.titnat = lotcretp.titnat
                  and titulo.modcod = lotcretit.modcod
                  and titulo.etbcod = lotcretit.etbcod
                  and titulo.clifor = lotcretit.clfcod
                  and titulo.titnum = lotcretit.titnum
                  and titulo.titpar = lotcretit.titpar
                no-lock no-error.
    if not avail titulo then next.
    find titulo2 of titulo no-lock no-error.
    
    run clifor.
    
    for-cgc-cpf = trim(vcgccpf).
    
    if length(for-cgc-cpf) = 14
    then. 
    else if length(for-cgc-cpf) = 11
    then. 
    else next.

    find lotcreag of lotcretit no-lock.

    vsaldo = (titulo.titvlcob + titulo.titvljur - titulo.titvldes)
                    - titulo.titvlpag.
    vsituacao = lotcreag.ltsituacao = yes /* clifor marcado */ and
                lotcreag.ltvalida   = ""  /* valido */   and
                lotcretit.ltsituacao      /* titulo marcado */.

    disp vsituacao no-label format "*/"
         space(0)
         lotcretit.clfcod
         vclfnom            format "x(30)"
         {titnum.i}
         titulo.etbcod
         titulo.titdtemi    format "99/99/99"
         titulo.titdtven    format "99/99/99"             
         titulo.titvlcob
         titulo.titvljur
         titulo.titvldes
         vsaldo column-label "Val. Pagar"
         titulo.titsit
         
/***
         vvencido           column-label "Vencido" format ">>>>,>>9.99"
***/
         lotcreag.ltvalida  column-label "Erros"   format "x(18)"
         with frame f-linc no-box width 170 down.
    down with frame f-linc.

    if vsituacao
    then assign
            vok     = vok + 1
            vgertot = vgertot + vsaldo
            vgerven = vgerven + vvencido
            vgercob = vgercob + titulo.titvlcob
            vgerjur = vgerjur + titulo.titvljur
            vgerdes = vgerdes + titulo.titvldes.
    else assign
            vnok    = vnok + 1.
end.

    down 1 with frame f-linc.
    disp "TOTAL GERAL" @ vclfnom
         "Ok = " + string(vok, "zzz9") @ titulo.titnum
         "Nao ok ="    @ titulo.titdtemi
         string(vnok, "zzz9")          @ titulo.titdtven
         vgercob       @ titulo.titvlcob
         vgerjur       @ titulo.titvljur
         vgerdes       @ titulo.titvldes
         vgertot       @ vsaldo
/***
         vgerven       @ vvencido
***/
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
        find clien where forne.forcod = lotcretit.clfcod no-lock.
        assign
            vclfcod = clien.clicod
            vcgccpf = clien.ciinsc
            vclfnom = clien.clinom.
    end.
end.

