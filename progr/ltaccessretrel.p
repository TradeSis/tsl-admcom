/* Programa Relatorio de retorno Access */
{admcab.i}

def input parameter par-reclotcre   as recid.
def new shared var vok              as int.
def new shared var verro            as int.
def var varquivo                    as char.
def new shared var vcli             as int.
def new shared var vtit             as int.
def new shared var vcontrato        as int.

def new shared temp-table tt-erro
    field mensagem  like lotcretit.spcretorno
    field qtde      as int init 0
    index erro mensagem.

find lotcre where recid(lotcre) = par-reclotcre no-lock.
find lotcretp where lotcretp.ltcretcod = "ACCESS" no-lock.

varquivo = "../relat/ltaccessretrel" + string(time).

    {mdadmcab.i
        &Saida     = "value(varquivo)"
        &Page-Size = "64"
        &Cond-Var  = "96"
        &Page-Line = "66"
        &Nom-Rel   = ""LTACCESSVAL""
        &Nom-Sis   = """BS"""
        &Tit-Rel   = "lotcretp.ltcretnom" 
                     /*+ "" - LOTE "" + 
                      string(lotcre.ltcrecod) + "" - "" + lotcre.ltselecao"*/
        &Width     = "96"
        &Form      = "frame f-cabcab"}

/*
/*TITULOS LP*/
run conecta_d.p.
if connected ("d")
then do:

    run ltaccessretrellp.p.

end.
disconnect d.
hide message no-pause.
*/ 

for each lotcretit where lotcretit.spcretorno = "acionamento de cobranca"
        no-lock break by lotcretit.clfcod 
                by lotcretit.titnum 
                by lotcretit.titpar.

    find lotcreag of lotcretit no-lock.
    if lotcreag.ltsituacao <> yes /* desmarcado */ or
       lotcreag.ltvalida   <> ""  /* invalido */
    then next.

    find clien where clien.clicod = lotcretit.clfcod no-lock.
    find titulo where titulo.empcod = wempre.empcod
                                  and titulo.titnat = lotcretp.titnat
                                  and titulo.modcod = lotcretit.modcod
                                  and titulo.etbcod = lotcretit.etbcod
                                  and titulo.clifor = lotcretit.clfcod
                                  and titulo.titnum = lotcretit.titnum
                                  and titulo.titpar = lotcretit.titpar
                                  and titulo.cobcod = 11 /* ACCESS */ 
                                  no-lock no-error.
    
    if not avail titulo then next.   
    
    if first-of(lotcretit.titnum) then vcontrato = vcontrato + 1.                    
    find tt-erro where tt-erro.mensagem = lotcretit.spcretorno no-error.
    if not avail tt-erro
    then do.
        create tt-erro.
        tt-erro.mensagem = lotcretit.spcretorno.
    end.
    tt-erro.qtde = tt-erro.qtde + 1.

    if lotcretit.spcretorno = "acionamento de cobranca"
    then vok = vok + 1.
    else verro = verro + 1.
    
    if first-of(lotcretit.clfcod)
    then do:
        disp lotcretit.clfcod format "9999999999"
            clien.clinom     
            with frame f-lin down no-box width 160.
            vcli = vcli + 1.

    end.
    
    
    disp
         titulo.etbcod   column-label "Etb"
         {titnum.i}
         titulo.titdtemi format "99/99/99"
         titulo.titdtven
         lotcretit.ltcrecod column-label "Lote"
         lotcretit.spcretorno
         with frame f-lin down no-box width 160.
         vtit = vtit + 1.

    if last-of(lotcretit.titnum)
    then do:         
        for each acordocob where acordocob.clfcod = lotcretit.clfcod and
                                     acordocob.titnum = lotcretit.titnum and
                                     acordocob.etbcod = lotcretit.etbcod
                                     no-lock.
            
                disp    
                        acordocob.titnum   label "Contrato "
                        acordocob.dtacordo label "Dt.acordo"
                        acordocob.descr    label "Descricao"
                        format "x(200)"
                        acordocob.dtagend  label "Dt.Agenda"
                        "" no-label
                with frame f-descricao 1 col width 250 down.
        end.
        down with frame fdesc.    
    end.

end.

hide message no-pause.


disp skip(1).
disp "Total de Clientes " colon 10 vcli colon 30 no-label.
disp "Total de Titulos " colon 10 vtit colon 30 no-label.
disp "Total de contratos" colon 10 vcontrato colon 30 no-label.


/*
for each tt-erro no-lock.
    disp tt-erro.mensagem
         tt-erro.qtde
         with frame f-erro down.
end.
*/
    if opsys = "UNIX"
    then do:
        output close.
        run visurel.p (varquivo,"").
    end.
    else do:
        {mrod.i}
    end.    




/*
{admcab.i}

def input parameter par-reclotcre  as recid.
def var vok      as int.
def var verro    as int.
def var varquivo as char.

def temp-table tt-erro
    field mensagem  like lotcretit.spcretorno
    field qtde      as int init 0
    
    index erro mensagem.

find lotcre where recid(lotcre) = par-reclotcre no-lock.
find lotcretp of lotcre no-lock.

varquivo = "../relat/ltaccessretrel" + string(time).

    {mdadmcab.i
        &Saida     = "value(varquivo)"
        &Page-Size = "64"
        &Cond-Var  = "96"
        &Page-Line = "66"
        &Nom-Rel   = ""LTACCESSVAL""
        &Nom-Sis   = """BS"""
        &Tit-Rel   = "lotcretp.ltcretnom + "" - LOTE "" + 
                      string(lotcre.ltcrecod) + "" - "" + lotcre.ltselecao"
        &Width     = "96"
        &Form      = "frame f-cabcab"}


for each lotcretit of lotcre no-lock.

    find lotcreag of lotcretit no-lock.
    if lotcreag.ltsituacao <> yes /* desmarcado */ or
       lotcreag.ltvalida   <> ""  /* invalido */
    then next.

    find clien where clien.clicod = lotcretit.clfcod no-lock.
                    find titulo where titulo.empcod = wempre.empcod
                                  and titulo.titnat = lotcretp.titnat
                                  and titulo.modcod = lotcretit.modcod
                                  and titulo.etbcod = lotcretit.etbcod
                                  and titulo.clifor = lotcretit.clfcod
                                  and titulo.titnum = lotcretit.titnum
                                  and titulo.titpar = lotcretit.titpar
                                no-lock no-error.
         if not avail titulo then next.                       
                                 
    find tt-erro where tt-erro.mensagem = lotcretit.spcretorno no-error.
    if not avail tt-erro
    then do.
        create tt-erro.
        tt-erro.mensagem = lotcretit.spcretorno.
    end.
    tt-erro.qtde = tt-erro.qtde + 1.

    if lotcretit.spcretorno = "acionamento de cobranca"
    then vok = vok + 1.
    else verro = verro + 1.

    disp titulo.clifor
         clien.clinom
         titulo.etbcod   column-label "Etb"
         {titnum.i}
         titulo.titdtemi format "99/99/99"
         titulo.titdtven
         lotcretit.ltcrecod column-label "Lote"
         lotcretit.spcretorno
         with frame f-lin down no-box width 160
         .
end.
put skip(1) "Corretos = " vok " Sem retorno = " verro skip(1).

for each tt-erro no-lock.
    disp tt-erro.mensagem
         tt-erro.qtde
         with frame f-erro down.
end.

    if opsys = "UNIX"
    then do:
        output close.
        run visurel.p (varquivo,"").
    end.
    else do:
        {mrod.i}
    end.    
*/ 
