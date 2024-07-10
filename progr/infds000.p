/* #1 - 30052017 - Moda no Ecommerce */
/* programa original: titforst.p Implantado em 10/04/2013 */

{admcab.i}

/*
sfuncod = 309.
*/
def new shared var vsetcod like setaut.setcod.
def new shared var vprocimp as char format "x(20)".
find first func where func.funcod = sfuncod and
                      func.etbcod = setbcod no-lock no-error.
do on error undo, return:
    update vsetcod with frame f-set 1 down no-box color message
            side-label width 80.
    if vsetcod > 0
    then do:   
    find setaut where setaut.setcod = vsetcod no-lock no-error.
    if not avail setaut
    then do:
        message "Setor nao cadastrado".
        undo, retry.
    end.
    disp setaut.setnom no-label with frame f-set .
    pause 0.
    if not avail func or 
        (func.aplicod <> string(setaut.setcod) and
         (func.aplicod <> "1" or   
          (vsetcod <> 15 and
          vsetcod <> 19 and
          vsetcod <> 44 and
          vsetcod <> 34 and
          vsetcod <> 39)))
    then do:
        message "Operacao nao permitida fil:" setbcod "Func.:" sfuncod. 
        undo.
    end.
    end.
    else do:
        update vprocimp label "Processo IMPORTACAO"
                validate(can-find(first tpimport where
                tpimport.numeropi = vprocimp),"Favor cadastrar processo de IMPORTACAO")
            with frame f-proc side-label row 3 overlay no-box
            color message.
        
    end.
end.

def var v-cnpj as char format "x(14)".
def new shared var vtipo-documento as int.
def new shared var vsel-sit1 as char format "x(15)" extent 10
          init["Nota Fiscal",
               "Folha Pagamento",
               "Drebes Financeira",
               "Drebes Promotora",
               "Aluguel",
               "DARF",
               "RPA",
               "Recibo Completo",
               "Recibo Comum",
               "Nenhum"].
def new shared var vempcod         like titulo.empcod.
def new shared var vetbcod         like titulo.etbcod.
def new shared var vmodcod         like modal.modcod.
def new shared var vtitnat         like titulo.titnat.
def new shared var vclifor         like titulo.clifor.
def var vforcod like forne.forcod.
def var vqtd-lj as int.

def buffer bmodclasf for modclasf.

def buffer bmodal for modal.
def new shared var vmod-ctb like modal.modcod.

form vetbcod colon 17
     with frame ff1 side-labels row 4 width 80 color white/cyan.

repeat with frame ff1:
    clear frame ff1 all.
    find first estab no-lock.
    {selestab.i vetbcod "ff1"}
    vqtd-lj = 0.
    for each tt-lj where tt-lj.etbcod > 0 no-lock:
        vqtd-lj = vqtd-lj + 1.
    end.        
    if vqtd-lj = 1
    then do:
        find first tt-lj where tt-lj.etbcod > 0 no-error.
        vetbcod = tt-lj.etbcod.
        disp vetbcod with frame ff1.
        find estab where estab.etbcod = vetbcod NO-LOCK.
        display estab.etbnom no-label with frame ff1.
    end.
    else do:
        disp "SELECIONADAS " + STRING(VQTD-LJ,">>9") + 
                " FILIAIS PARA RATEIO" FORMAT "X(50)"
                @ ESTAB.ETBNOM 
                with frame ff1.
        vetbcod = setbcod.
    end.    
    
    do on error undo:
        vmodcod = "".
        update vmodcod validate(can-find(modal where modal.modcod = vmodcod),
                                "Modalidade Invalida") colon 17 with frame ff1.
        find modal where modal.modcod = vmodcod NO-LOCK.
        display modal.modnom no-label with frame ff1.
        if modal.modcod = "CRE"
        then do:
            message "modalidade invalida".
            undo, retry.
        end.
        find first modgru where modgru.modcod = modal.modcod and
                                modgru.mogsup <> 0
                          no-lock no-error.
        if not avail modgru
        then do:
            message "MODALIDADE precisa estar associada a um GRUPO ." skip
                "Verificar com SETOR FINANCEIRO." .
            undo,retry.
        end.
        do on error undo:
        vmod-ctb = "".
        update vmod-ctb label "Mod.CTB"
                    validate(can-find(modal where modal.modcod = vmod-ctb),
                                "Modalidade Invalida") with frame ff1.
        find bmodal where bmodal.modcod = vmod-ctb NO-LOCK.
        display bmodal.modnom no-label with frame ff1.
        if bmodal.modcod = "CRE"
        then do:
            message "modalidade nao cadatrada".
            pause.
            undo, retry.
        end.

        find first lancactb where
                   lancactb.id = 0  and
                   lancactb.etbcod = 0 and
                   lancactb.forcod = 0 and
                   lancactb.modcod = bmodal.modcod
                   no-lock no-error.
        if not avail lancactb or lancactb.contadeb = 0
        then do:
            message
                "Modalidade" vmod-ctb 
                "deve estar associada a uma conta contabil." skip
                "Favor entrar em contato com o SETOR DE CONTABILIDADE."
                 view-as alert-box.
            undo, retry.         
        end.
        end.                       
    end.

    do on error undo:
        vtitnat = yes.
        update vtitnat colon 17
               with frame ff1 side-labels row 4 width 80 color white/cyan.
    end.
    vforcod = 0.
    vtipo-documento = 0.
    run tipo-documento.
    if vtipo-documento = 0
    then undo.
    disp vsel-sit1[vtipo-documento] no-label.

    lclifor = if vtitnat
              then no
              else yes .

    display vforcod label "Fornecedor" colon 17.

    do on error undo.
        if (vtipo-documento <> 1 and
           vtipo-documento <> 5 and
           vtipo-documento <> 7) or
            vprocimp <> ""
        then do.
            update vforcod label "Fornecedor" with frame ff1.
            if vforcod = 0 
            then do:
                update v-cnpj colon 35 label "CNPJ/CPF" with frame ff1.
                if v-cnpj = "" then undo.
                find first forne where forne.forcgc = v-cnpj and
                            forne.ativo no-lock no-error.
            end.                
            find first forne where forne.forcod = vforcod and
                                   forne.ativo NO-LOCK no-error.
        end.
        else do.
            update v-cnpj colon 35 label "CNPJ/CPF" with frame ff1.
            if v-cnpj = "" then undo.
            find first forne where forne.forcgc = v-cnpj and
                                   forne.ativo no-lock no-error.
        end.
        if not avail forne
        then do:
            message "Fornecedor nao cadastrado." view-as alert-box.
            undo.
        end.

        find first modclasf where modclasf.tipo = 2 and
                                  modclasf.modcod = vmodcod 
                                  no-lock no-error.
        if avail modclasf
        then do:
            find first bmodclasf where bmodclasf.tipo = 2 and
                                       bmodclasf.modcod = vmodcod and
                                       bmodclasf.forcod = forne.forcod
                                      no-lock no-error.
            if not avail bmodclasf
            then do:
                bell.
                message color red/with
                "Divergencia entre fornecedor " forne.forcod 
                "e modalidade " vmodcod "." skip
                "Comunicar o setor FINANCEIRO."
                view-as alert-box.
                undo.
            end.                      
        end.                          
        disp forne.fornom format "x(25)" no-label.
        vforcod = forne.forcod.
        vclifor = forne.forcod.
    end.    

    if vtipo-documento > 8 or
        vtipo-documento = 3 or
        vtipo-documento = 4
    then do:
        if connected("banfin")
        then disconnect banfin.
        connect banfin -H erp.lebes.com.br -S sbanfin -N tcp -ld banfin.
        if connected("banfin")
        then do.
            run infds010-c.p. /*titforstl.p.*/
            disconnect banfin.
        end.
    end.                                    
    else do: /* #1 */
        if vtipo-documento = 6 /* #1 */
        then do:
            sresp = yes.
            message "Importar Arquivo? Sim/Nao" update sresp. 
            if sresp
            then run infdsinx.p.
        end.
        run infds010.p.
    end.    
end. 


procedure tipo-documento:
    /*
    def var vsel-sit1 as char format "x(15)" extent 6
          init["Nota Fiscal",
               "DARF",
               "RPA",
               "Recibo Completo",
               "Recibo Comum",
               "Nenhum"].
    */
    format skip(1)
          vsel-sit1
          with frame f-sel-sit1
                   1 down  centered no-label row 08 overlay
                    width 30 title " Tipo de Documento ".

    disp vsel-sit1 with frame f-sel-sit1.
    choose field vsel-sit1 with frame f-sel-sit1.
    vtipo-documento = frame-index.
    hide frame f-sel-sit1 no-pause.
    hide message no-pause.
    
end procedure.

