/* Programa que busca os d.titulos LP para o relatorio de retorno 
assessoria global */

{admcab.i}

def shared temp-table tt-erro
    field mensagem  like lotcretit.spcretorno
    field qtde      as int init 0
    index erro mensagem.

def var vok      as int.
def var verro    as int.
def var vdtitulo like lotcretit.titnum.

DISP "TITULOS LP".
for each lotcretit no-lock.

    find lotcre of lotcretit no-lock.
    find lotcretp of lotcre no-lock.
    if lotcretp.ltcretcod <> "GLOBAL" then next.


    find lotcreag of lotcretit no-lock.
    if lotcreag.ltsituacao <> yes /* desmarcado */ or
       lotcreag.ltvalida   <> ""  /* invalido */
    then next.

    find clien where clien.clicod = lotcretit.clfcod no-lock no-error.

    find d.titulo where d.titulo.empcod = wempre.empcod
                  and d.titulo.titnat = lotcretp.titnat
                  and d.titulo.modcod = lotcretit.modcod
                  and d.titulo.etbcod = lotcretit.etbcod
                  and d.titulo.clifor = lotcretit.clfcod
                  and d.titulo.titnum = lotcretit.titnum
                  and d.titulo.titpar = lotcretit.titpar
                  and d.titulo.cobcod = 12 /* GLOBAL */
                  no-lock no-error.
    
    
    if not avail d.titulo then next.                       
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

    vdtitulo = trim(titulo.titnum + (if titulo.titpar > 0            
                          then "/" + string(titulo.titpar)
                                                else "")).       
                                                      
    
    
    disp d.titulo.clifor
         clien.clinom
         d.titulo.etbcod   column-label "Etb"
         vdtitulo
         /*{titnum.i}*/
         d.titulo.titdtemi format "99/99/99"
         d.titulo.titdtven
         lotcretit.spcretorno
         with frame f-lin down no-box width 132.
end.
put skip(1) "Corretos = " vok " Com erro = " verro skip(1).

for each tt-erro no-lock.
    disp tt-erro.mensagem
         tt-erro.qtde
         with frame f-erro down.
end.


