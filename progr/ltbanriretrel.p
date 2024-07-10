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

varquivo = "../relat/ltbanriretrel" + string(time).

    {mdadmcab.i
        &Saida     = "value(varquivo)"
        &Page-Size = "64"
        &Cond-Var  = "96"
        &Page-Line = "66"
        &Nom-Rel   = ""LTBANRIVAL""
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

    find forne where forne.forcod = lotcretit.clfcod no-lock.
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

    if lotcretit.spcretorno = "BD"
    then vok = vok + 1.
    else verro = verro + 1.

    disp titulo.clifor
         forne.fornom
         titulo.etbcod   column-label "Etb"
         {titnum.i}
         titulo.titdtemi format "99/99/99"
         titulo.titdtven
         lotcretit.spcretorno
         with frame f-lin down no-box width 132.
end.
put skip(1) "Corretos = " vok " Com erro = " verro skip(1).

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
                                                      
