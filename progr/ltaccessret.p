/* Arquivo de retorno Lote Access */
{admcab.i}

form with frame f-proc.

def input parameter par-reclotcre  as recid.
def new shared buffer lotcretp for lotcretp. 

def temp-table tt-retorno
    field clicod    as int  format "9999999999"
    field titnum    as char format "x(25)"
    field titpar    as int.

def var vdir        as char.
def var varq        as char.
def var vlinha      as char.
def var vtime       as int.
def var vct         as int.
def var vretorno    as char.
def var vcodbarras  as char.
def var vok         as int.
def var verro       as int.
def var vestab      as int.
def buffer blotcretit for lotcretit.

def var vdataacordo  as char.
def var vdescri      as char format "x(60)".
def var vdataagenda  as char.
def var vclicod      as int.
def var vtitnum      as int format "9999999999".
def var vtitpar      as int.

if opsys = "unix"
then vdir = "/admcom/custom/nede/arquivos/".
else vdir = "l:~\access~\titulos~\".

do on error undo with frame f-filtro side-label
            title " Retorno Access ".
    disp vdir label "Diretorio" colon 15 format "x(45)".
    update vdir.
    update varq label "Arquivo" colon 15 format "x(45)".
end.

if search(vdir + varq) = ?
then do.
    message "Arquivo nao encontrado:" vdir + varq view-as alert-box.
    return.
end.

sresp = no.
message "Processar o retorno  ?" update sresp.
if sresp <> yes
then return.

find lotcre where recid(lotcre) = par-reclotcre no-lock.
find lotcretp where lotcretp.ltcretcod = "ACCESS" no-lock.

vtime = time.

/*TITULOS LP*/
run conecta_d.p.
if connected ("d")
then do:
input from value(vdir + varq).
    repeat on error undo, next.
        import unformatted vlinha.

        /* REGISTRO DO ACORDO TIPO 5I */
        if substr(vlinha, 1, 1) = "5" and substr(vlinha,2,1) = "I"                       then do.
        
            vtitnum = int(substring(vlinha,7,11)).
            vestab = int(substring(vlinha,4,3)).
            vdataacordo = substring(vlinha,28,8).
            vdescri     = substring(vlinha,36,60).
            vdataagenda = substring(vlinha,436,8).

            find first blotcretit where 
                int(blotcretit.titnum) = vtitnum and
                blotcretit.etbcod = vestab no-lock no-error.
            if not avail blotcretit
            then do:
                verro = verro + 1. 
                next.
            end. 

            vct = vct + 1.
            disp "LP " vct with frame f-proc no-label centered.
            pause 0.

                /* Percorre todos os lotes da ACCESS */
                for each lotcre of lotcretp no-lock.
                    run ltaccessretlp.p (input recid(lotcre),
                                         input vtitnum,
                                         input-output vok,
                                         input vestab,
                                         input vdataacordo,
                                         input vdescri,
                                         input vdataagenda
                                         )).
                end.
            /*end.
            disconnect d.
            hide message no-pause.
            */
        end.

end. /*input*/
input close.
end.
disconnect d.
hide message no-pause.
            

vct = 0.
input from value(vdir + varq).
    repeat on error undo, next.
        import unformatted vlinha.

        /* REGISTRO DO ACORDO TIPO 5I */
        if substr(vlinha, 1, 1) = "5" and substr(vlinha,2,1) = "I"                      then do.
        
            vtitnum = int(substring(vlinha,7,11)).
            vestab = int(substring(vlinha,4,3)).
            vdataacordo = substring(vlinha,28,8).
            vdescri     = substring(vlinha,36,400).
            vdataagenda = substring(vlinha,436,8).

            find first blotcretit where 
                int(blotcretit.titnum) = vtitnum and
                blotcretit.etbcod = vestab no-lock no-error.
            if not avail blotcretit
            then do:
                verro = verro + 1. 
                next.
            end. 

            vct = vct + 1.
            disp "FIN" vct with frame f-proc no-label centered.
            pause 0.

            /* Percorre todos os lotes da ACCESS */
            for each lotcre of lotcretp no-lock.

                /* Percorre os titulos do lote banco FIN */
                for each lotcretit 
                where int(lotcretit.titnum) = vtitnum and
                          lotcretit.etbcod  = vestab  and
                          lotcretit.ltcrecod = lotcre.ltcrecod
                exclusive break by lotcretit.titnum.

                        find titulo where titulo.empcod = wempre.empcod
                                  and titulo.titnat = lotcretp.titnat
                                  and titulo.modcod = lotcretit.modcod
                                  and titulo.etbcod = lotcretit.etbcod
                                  and titulo.clifor = lotcretit.clfcod
                                  and titulo.titnum = lotcretit.titnum
                                  and titulo.titpar = lotcretit.titpar
                                  exclusive no-error.  
                        
                        if not avail titulo then next.
                        
                        if avail titulo 
                        then do:
                            find cobra where cobra.cobnom = "ACCESS" no-lock.
                            assign
                            titulo.cobcod = cobra.cobcod
                            lotcretit.spcretorno = "acionamento de cobranca".
                        
                            
                            if first-of(lotcretit.titnum)
                            then do:
                                    create acordocob.
                                    assign  
                                    acordocob.clfcod   = titulo.clifor
                                    acordocob.titnum   = string(vtitnum)
                                    acordocob.etbcod   = vestab
                                    acordocob.dtacordo = date(vdataacordo) 
                                    acordocob.descr    = vdescri
                                    acordocob.dtagend  = date(vdataagenda).
                                    vok = vok + 1.
                            end.
                        end.    
                end. /*lotcretit FIN*/
            
            
            end. /*lotcre*/
        end.
end. /*input*/
input close.


/*
do on error undo.
    find lotcre where recid(lotcre) = par-reclotcre exclusive.
    assign
        lotcre.ltdtretorno = today
        lotcre.lthrretorno = vtime
        lotcre.ltfnretorno = sfuncod
        lotcre.arqretorno  = vdir + varq.
end.
find current lotcre no-lock.
*/

hide frame f-proc.
message "Arquivo " + varq + " processado. Corretos=" vok "Com erro=" verro
        view-as alert-box.

