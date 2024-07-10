def shared var vcontrato as int.
def shared var vok as int.
def shared var verro as int.
def shared var vcli as int.
def shared var vtit as int.
def var vnumtitulo as char.

def new shared temp-table tt-erro
    field mensagem  like lotcretit.spcretorno
    field qtde      as int init 0
    index erro mensagem.


/* Relatorio de retorno Access busca os titulos lp */
for each lotcretit where lotcretit.spcretorno = "acionamento de cobranca"
        no-lock break by lotcretit.clfcod 
                by lotcretit.titnum 
                by lotcretit.titpar.

    find lotcreag of lotcretit no-lock.
    if lotcreag.ltsituacao <> yes /* desmarcado */ or
       lotcreag.ltvalida   <> ""  /* invalido */
    then next.

    find clien where clien.clicod = lotcretit.clfcod no-lock.
    find d.titulo where d.titulo.empcod = 19
                                  and d.titulo.titnat = no
                                  and d.titulo.modcod = lotcretit.modcod
                                  and d.titulo.etbcod = lotcretit.etbcod
                                  and d.titulo.clifor = lotcretit.clfcod
                                  and d.titulo.titnum = lotcretit.titnum
                                  and d.titulo.titpar = lotcretit.titpar
                                  and d.titulo.cobcod = 11 /* ACCESS */ 
                                  no-lock no-error.
    
    if not avail d.titulo then next.   
    
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
        disp lotcretit.clfcod 
            clien.clinom     
            with frame f-lin down no-box width 160.
            vcli = vcli + 1.

    end.
    
    
    vnumtitulo = trim(titulo.titnum + (if titulo.titpar > 0
                                  then "/" + string(titulo.titpar)
                                  else "")). 
    
    disp
         d.titulo.etbcod   column-label "Etb"
         vnumtitulo column-label "Titulo"
         /*{titnum.i}*/
         d.titulo.titdtemi format "99/99/99"
         d.titulo.titdtven
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


