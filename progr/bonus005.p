{admcab.i}

def new shared temp-table tt-nota
    field flag as log format "*/ "
    field nota as char format "XXX"
    field rec  as int 
    field fre  as int 
    field val  as int 
    index inota is primary unique nota desc.

 
def var vmes as int format ">9".
def var vbonmin as dec.
def var vbonmax as dec.
def var val-bonus as dec.
def var vperbon as dec format ">>9.99 %".
def var vdtini as date format "99/99/9999" init 02/18/2006.
def var vdtfin as date format "99/99/9999" init 08/16/2006.
def var vnota1 as char format "x(3)" init "555".
def var vval-comp as dec.

def var vcont as int format ">>>>>>>>>>>>9".

def var vqtd-cli as int format ">>>>>>>>>>>>>>>9" .
def var vqtd-tot as dec format ">>>,>>>,>>9.99".
def var vcomprou as log init no.

def var vval-cli as dec format ">>>,>>>,>>9.99".

def new shared temp-table tt-cli
    field clicod like clien.clicod
    field clinom like clien.clinom
    field bonus as dec
    field conjuge as char
    field dtaniconj  as date format "99/99/9999"
    field recencia like rfvcli.recencia
    field frequencia like rfvcli.frequencia
    field valor-rfv like rfvcli.valor
        
    index icli is primary unique clicod.

def var vetbcod as int.
def var vnumacao as int.


/*def temp-table tt-nota
    field nota as char format "XXX"
    index inota is primary unique nota.*/

def var vnota as char format "XXX".
def var vnotas as char format "x(50)".

form tt-nota.nota
     with frame f-mostra-nota centered 8 down row 8
                        title " Notas Selecionadas " overlay.

def temp-table tt-estab like estab.
do on error undo:
    vetbcod = 0.
    update vetbcod label "Filial..........."
           with frame f-dados centered side-labels overlay row 4
                      width 80 title " Aniversario do Conjuge ".
    if vetbcod > 0
    then do:
        find estab where estab.etbcod = vetbcod no-lock no-error. 
        if not avail estab
        then do:
            if vetbcod = 0
            then do:
                message "Informe o codigo de uma filial.".
                undo, retry.
            end.
            else do:
                message "Filial nao cadastrada.".
                undo, retry.
            end.
        end.
        else disp estab.etbnom no-label with frame f-dados.
            create tt-estab.
            buffer-copy estab to tt-estab.
    end.
    else do:
        for each estab where estab.etbnom begins "DREBES-FIL" NO-LOCK:
            create tt-estab.
            buffer-copy estab to tt-estab.
        END.
    end.
end.

/**
repeat:

    update skip
           vnota label "Nota............."
           help "Informe as notas e F4 para Confirmar"
           with frame f-dados centered side-labels overlay row 3.

    find tt-nota where tt-nota.nota = vnota no-error.
    if not avail tt-nota
    then do:
        create tt-nota.
        assign tt-nota.nota = vnota.
    end.

    clear frame f-mostra-nota all.
    hide frame f-mostra-nota no-pause.

    for each tt-nota:
        disp tt-nota.nota column-label "Nota"
             with frame f-mostra-nota centered 8 down row 10
                        title " Notas Selecionadas ".
        down with frame f-mostra-nota.                
    end.
    
end.

hide frame f-mostra-nota no-pause.

vnotas = "".
for each tt-nota:
    vnotas = vnotas + tt-nota.nota + "/".
end.

vnota = "".
disp vnota
     vnotas no-label
     with frame f-dados.
**/
     
    
pause 0. 
if vetbcod = 0
then sparam = "0".
run escnota.p.
sparam = "".

find first tt-nota where tt-nota.flag = yes no-error.
if not avail tt-nota
then do:
    message "Nenhuma nota selecionada".
    pause 2 no-message. undo.
end.
 
update val-bonus label "Valor do Bonus..."
       with frame f-dados.
       
update skip vmes      label "Mes Aniv. Conjuge"       
       with frame f-dados.
       
/****       vnumacao label "Numero Acao......"****/

def var vspc as log.

def buffer cli-conj for clien.

for each tt-nota where tt-nota.flag = yes use-index inota no-lock:
    for each tt-estab no-lock:
    for each rfvcli where rfvcli.setor  = 0
                      and rfvcli.etbcod = tt-estab.etbcod
                      and rfvcli.nota   = tt-nota.nota no-lock:

        find clien where clien.clicod = rfvcli.clicod no-lock no-error.
        if not avail clien then next.
        
        if clien.estciv <> 2 then next.
        if clien.conjuge = ? then next.
        if clien.nascon  = ? then next.
        if month(clien.nascon) <> vmes then next.
 
        find first cli-conj where
                   cli-conj.clinom = clien.conjuge and
                   cli-conj.conjuge = clien.clinom
                    no-lock no-error.
        if avail cli-conj and
           cli-conj.estciv <> 2
        then next.
                    
        vcont = vcont + 1.
        disp vcont 
             with frame fcont centered side-labels no-labels 1 down. pause 0.
        
        /***Exclui da selecao clientes que estao no SPC***/

        find ncrm where ncrm.clicod = rfvcli.clicod no-lock no-error.
        if ncrm.spc then next.
 
        find first fin.clispc where fin.clispc.clicod = rfvcli.clicod
                            and fin.clispc.dtcanc = ? no-lock no-error.
        if avail fin.clispc then next.
    
        vspc = no.
        run ver-lp-chq.
        if vspc = yes then next.
        /*********/                                                       
        /*
        disp "Processando...>>> " clien.clicod clien.clinom
            with frame f-disp 1 down row 10 no-box
            no-label.
        pause 0. 
        */
        find tt-cli where tt-cli.clicod = rfvcli.clicod no-error.
        if not avail tt-cli 
        then do: 
            create tt-cli. 
            assign tt-cli.clicod     = rfvcli.clicod 
                   tt-cli.clinom     = clien.clinom 
                   tt-cli.recencia   = rfvcli.recencia 
                   tt-cli.frequencia = rfvcli.frequencia 
                   tt-cli.valor-rfv  = rfvcli.valor
                   tt-cli.conjuge    = clien.conjuge
                   tt-cli.dtaniconj  = clien.nascon
                   tt-cli.bonus      = val-bonus.
        end.    
    end.
    end.
end.
hide frame f-cont no-pause.

/**
def new shared temp-table tt-clispc
    field clicod like clien.clicod
    index i1 is primary unique clicod.

for each tt-cli:
    create tt-clispc.
    tt-clispc.clicod = tt-cli.clicod.
end.

run ver_spc0.p.

for each tt-cli:
    find first tt-clispc where
               tt-clispc.clicod = tt-cli.clicod no-error.
    if avail tt-clispc
    then delete tt-cli.           
end.
**/

run bonus006.p.

procedure ver-lp-chq:
    vspc = no.
        for each  fin.clispc where 
                           fin.clispc.clicod = clien.clicod /*and 
                           fin.clispc.dtcanc = ?*/ no-lock .
            if clispc.dtcanc = ?
            then do:
                vspc = yes.
                leave.
            end.
        end.        
        if vspc = yes
        then.
        else do:
            for each estab no-lock:
                find first d.titulo where
                               d.titulo.empcod = 19 and
                               d.titulo.titnat = no and
                               d.titulo.modcod = "CRE" and
                               /*d.titulo.titdtven < today - 60 and*/
                               d.titulo.etbcod = estab.etbcod and
                               d.titulo.clifor = clien.clicod and
                               d.titulo.titsit = "LIB"
                               no-lock no-error.
                if avail d.titulo
                then do:
                    vspc = yes.
                    leave.
                end.
            end.
            if vspc = yes
            then.
            else do:
                for each fin.cheque where 
                                   fin.cheque.clicod = clien.clicod /*and
                                   fin.cheque.chesit = "LIB"          */
                                   no-lock .
                    if cheque.chesit = "LIB"
                    then do:
                        vspc = yes.
                        leave.
                    end.
                end. 
            end.
        end.
end procedure.

