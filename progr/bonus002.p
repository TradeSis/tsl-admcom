{admcab.i}

def var vbonmin as dec.
def var vbonmax as dec.

def var vperbon as dec format ">>9.99 %".
def var vdtini as date format "99/99/9999".
def var vdtfin as date format "99/99/9999".
def var vnota1 as char format "x(3)".
def var vval-comp as dec.

def var vcont as int format ">>>>>>>>>>>>9".

def var vqtd-cli as int format ">>>>>>>>>>>>>>>9" .
def var vqtd-tot as dec format ">>>,>>>,>>9.99".
def var vcomprou as log init no.

def var vval-cli as dec format ">>>,>>>,>>9.99".

def new shared temp-table tt-cli
    field clicod like clien.clicod
    field clinom like clien.clinom
    field valor  as dec
    field bonus as dec
    field recencia like rfvcli.recencia
    field frequencia like rfvcli.frequencia
    field valor-rfv like rfvcli.valor
    index icli is primary unique clicod.

def var vetbcod as int.
def var vnumacao as int.


/*def temp-table tt-nota
    field nota as char format "XXX"
    index inota is primary unique nota.*/
    
def new shared temp-table tt-nota
    field flag as log format "*/ "
    field nota as char format "XXX"
    field rec  as int 
    field fre  as int 
    field val  as int 
    index inota is primary unique nota desc.
    
def var vnota as char format "XXX".
def var vnotas as char format "x(50)".

form tt-nota.nota
     with frame f-mostra-nota centered 8 down row 8
                        title " Notas Selecionadas " overlay.

def temp-table tt-estab like estab.

do on error undo:
    vetbcod = 0.
    /****************************
     antonio 
    update vetbcod label "Filial..........."
           with frame f-dados centered side-labels overlay row 4
                      width 80 title " Bonus Presente ".
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
       for each estab where estab.etbnom begins "DRBES-FIL" NO-LOCK:
            create tt-estab.
            buffer-copy estab to tt-estab.
       end.
    end.
    ***********************************************/
 
    display vetbcod label "Filial..........."
            "" @ estab.etbnom
           with frame f-dados centered side-labels overlay row 4
                      width 80 title " Bonus Presente ".
 
    {selestab.i vetbcod f-dados}
    /*
    for each estab where estab.etbnom begins "DRBES-FIL" NO-LOCK:
            create tt-estab.
            buffer-copy estab to tt-estab.
    end.
    */
    for each tt-lj:
        find first estab where estab.etbcod = tt-lj.etbcod NO-LOCK NO-ERROR.
        if estab.etbnom begins "DREBES-FIL" 
        then do:
            create tt-estab.
            buffer-copy estab to tt-estab.
        end.
    end.

end.

/***
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
***/

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
     
update skip
       vdtini  label "Dt.Compra Inicial"
       vdtfin  label "Dt.Compra Final...." skip
       with frame f-dados.

update vval-comp label "Val.Minimo Compra"
       with frame f-dados.
       
update vperbon   label "Percentual de Bonus"       
       with frame f-dados.
       
update vbonmin   label "Val.Minimo Bonus."
       vbonmax   label "Val.Maximo Bonus..."
       with frame f-dados.

/****       vnumacao label "Numero Acao......"****/

def var vspc as log.

for each tt-nota where tt-nota.flag = yes use-index inota no-lock:
    for each tt-estab no-lock:
    for each rfvcli where rfvcli.setor  = 0
                      and rfvcli.etbcod = tt-estab.etbcod
                      and rfvcli.nota   = tt-nota.nota no-lock:

        find clien where clien.clicod = rfvcli.clicod no-lock no-error.
        if not avail clien then next.
        
        if clien.estciv = 6 then next.
        
        vcont = vcont + 1.
        
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

        disp "Processando...>>> " clien.clicod clien.clinom
            with frame f-disp 1 down row 10 no-box
            no-label.
        pause 0.    
        vval-cli = 0.
        vcomprou = no.
    
        for each plani where plani.movtdc = 5
                         and plani.desti  = rfvcli.clicod
                         and plani.pladat >= vdtini
                         and plani.pladat <= vdtfin no-lock:
            
            vqtd-tot = vqtd-tot + (if plani.biss > 0
                                   then plani.biss
                                   else plani.platot).

            vval-cli = vval-cli + (if plani.biss > 0
                                   then plani.biss
                                   else plani.platot).
    
            vcomprou = yes.
        
        
        end.

        if vval-cli >= vval-comp
        then do:
        
            find tt-cli where tt-cli.clicod = rfvcli.clicod no-error.
            if not avail tt-cli
            then do:
                create tt-cli.
                assign tt-cli.clicod     = rfvcli.clicod
                       tt-cli.clinom     = clien.clinom
                       tt-cli.recencia   = rfvcli.recencia
                       tt-cli.frequencia = rfvcli.frequencia
                       tt-cli.valor-rfv  = rfvcli.valor.
            end.    

            tt-cli.valor = vval-cli.
              
            tt-cli.bonus = tt-cli.valor * (vperbon / 100).
        
            if tt-cli.bonus < vbonmin
            then tt-cli.bonus = vbonmin.
        
            if tt-cli.bonus > vbonmax
            then tt-cli.bonus = vbonmax.
        
        end.
    end.
    end.
end.

disconnect "d".

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


run bonus003.p.

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
                               d.titulo.titdtven < today - 60 and
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
