 {admcab.i}

def var par-dtini as date.
def var vindex as int.
def new shared workfile wfcmonope
    field data          as date format "99/99/9999"
    field modcod        like modal.modcod
    field rec-cmonope   as recid
    field tipo          as char.

def buffer xcmon    for cmon.
def buffer bcmon for cmon.
def var vcont as int.
def var par-data like cmon.cxadt.
def var par-normal as log.
def var par-cmocod as int.
par-normal = yes.
if num-entries(sretorno,"=") = 2
then do:
    if entry(1,sretorno,"=") = "CMOCOD"
    then do:
        par-cmocod = int(entry(2,sretorno,"=")).
        sretorno = "".
        find cmon where cmon.cmocod = par-cmocod no-lock no-error.
        if avail cmon
        then par-normal = no.
        else par-normal = yes.
    end.
    else par-normal = yes.
end.
else par-normal = yes.
repeat:
def var vtipo as char format "x(15)" extent 4 initial
        ["PDV","CAIXA","BANCO","EXTRA-CAIXA"].

if false and par-normal
then do:
    disp vtipo with frame ftipo.
    choose field vtipo with frame ftipo
            with row 3 centered no-labels.
end.
            
        hide frame ftipo no-pause.
def new shared frame f-cmon.
    form cmon.etbcod    label "Etb" format ">>9"
         CMon.cxacod    label "PDV" format ">>9"
         CMon.cxanom    no-label
         par-dtini          label "Dt Ini"
         CMon.cxadt         colon 65 format "99/99/9999" label "Data"
         with frame f-CMon row 3 width 81
                         side-labels no-box.
def new shared frame f-banco.
    form
        CMon.bancod    colon 12    label "Bco/Age/Cta"
        CMon.agecod             no-label
        CMon.ccornum            no-label format "x(15)"
        CMon.cxanom             format "x(16)" no-label
        func.funape             format "x(10)" no-label
        CMon.cxadt          format "99/99/9999" no-label
         with frame f-banco row 3 width 81 /*color messages*/
                         side-labels no-box.
    if true or par-normal
    then do:
    if true or frame-index = 1
    then do:
        disp setbcod @ cmon.etbcod 
                0 @ cmon.cxacod with frame f-cmon.
        prompt-for cmon.etbcod /*when estab.etbcat <> "LOJA"*/ cmon.cxacod
            with frame f-cmon.
        find first cmon where
                    cmon.etbcod = input frame f-cmon cmon.etbcod and
                    cmon.cmtcod = "PDV" and
                    cmon.cxacod = input frame f-cmon cmon.cxacod
                                    no-lock no-error.
        if not avail cmon and 
            input frame f-cmon cmon.cxacod <> 0
        then do:
            message "PDV" input cmon.cxacod "Nao Cadastrado".
            undo.
        end.
        find estab where /*estab.empcod = 1 and*/ 
                 estab.etbcod = input frame f-cmon cmon.etbcod no-lock
                    no-error.
        disp cmon.cxanom when avail cmon
                with frame f-cmon.
    end.
    else
    
    if frame-index = 2
    then do:
        disp setbcod @ cmon.etbcod with frame f-cmon.
        prompt-for cmon.etbcod /*when westab.etbcat <> "LOJA"*/ cmon.cxacod
            with frame f-cmon.
        find first cmon where
                    cmon.etbcod = input frame f-cmon cmon.etbcod and
                    cmon.cmtcod = "CAI" and
                    cmon.cxacod = input frame f-cmon cmon.cxacod
                                    no-lock no-error.
        if not avail cmon
        then do:
            message "CAIXA" input cmon.cxacod "Nao Cadastrada".
            undo.
        end.
        find estab where /*estab.empcod = 1 and*/ estab.etbcod = cmon.etbcod no-lock.
        disp cmon.cxanom
                with frame f-cmon.
    end.
    else
        if frame-index = 4
        then do:
            disp setbcod @ cmon.etbcod with frame f-cmon.
            prompt-for cmon.cxacod with frame f-cmon.
            find first cmon where
                    cmon.etbcod = setbcod and
                    cmon.cmtcod = "EXT" and
                    cmon.cxacod = input frame f-cmon cmon.cxacod
                                    no-lock no-error.
            if not avail cmon
            then do:
                message "EXTRA-CAIXA" input cmon.cxacod "Nao Cadastrada".
                undo.
            end.
            disp cmon.cxanom with frame f-cmon.
                   
/***
            find cmon where cmon.cmocod = 99 no-lock.
            display cmon.etbcod
                    cmon.cxanom
                    cmon.cxacod
                    with frame f-cmon.
***/
        end.
        else do on error undo.
            /*
            {busbanco.i &frame = "f-banco"
                        &cmon  = "cmon"}
            */
            /*
            prompt-for cmon.bancod
                       with frame f-banco.
            vcont = 0.
            for each bcmon where bcmon.bancod = input frame f-banco cmon.bancod
                                        no-lock.
                vcont = vcont + 1.
            end.
            if vcont = 0
            then do:
                message "Banco nao possui Conta Corrente".
                undo.
            end.
            if vcont > 1
            then do on error undo:
                prompt-for cmon.agecod
                           with frame f-banco.
                vcont = 0.
                for each bcmon where
                         bcmon.bancod = input frame f-banco cmon.bancod and
                         bcmon.agecod = input frame f-banco cmon.agecod
                                        no-lock.
                    vcont = vcont + 1.
                end.
                if vcont = 0
                then do:
                    message "Agencia nao possui Conta Corrente".
                    undo.
                end.
                if vcont > 1
                then do on error undo.
                    prompt-for cmon.ccornum
                               with frame f-banco.
                    find cmon where cmon.cmtcod  = "BAN"
                         and cmon.bancod  = input frame f-banco cmon.bancod
                         and cmon.agecod  = input frame f-banco cmon.agecod
                         and cmon.ccornum = input frame f-banco cmon.ccornum
                                            no-lock no-error.
                    if not avail cmon
                    then do:
                        message "Banco Nao Cadastrada".
                        undo.
                    end.
                end.
                else
                    find first cmon where cmon.bancod = input frame f-banco
                                                               cmon.bancod
                              and cmon.agecod  = input frame f-banco cmon.agecod
                                                         no-lock.
            end.
            else
                find first cmon where cmon.bancod = input frame f-banco
                                                    cmon.bancod no-lock.
            display cmon.bancod
                    cmon.agecod
                    cmon.ccornum
                    cmon.cxanom
                    with frame f-banco.
            */
        end.
    end.
    else do:
        if cmon.cmtcod = "BAN"
        then do:
            display cmon.bancod
                cmon.agecod
                cmon.ccornum
                 cmon.cxanom
                with frame f-banco.
        end.
    end.

        
def var pdvConsultas     as char format "x(35)" extent 9 initial
           ["1. Consulta Movimento ",
            "2. Vendas",
            "3. Recebimentos  ",
            "4. Moedas",
            "5. Totais",
            "6. Formas",
            " ",
            " ",
            " "
            ].
 
def var cConsultas     as char format "x(35)" extent 9 initial
           ["1. Consulta Todas Movimentacoes ",
            "2. Movimentacoes A Confirmar ",
            "3. Movimentos Externos ",
            "4. Vendas ",
            "",
            "6. Totais por Modalidades ",
            "7. Totais por Moedas ",
            "8. Totais por Operacoes ",
            "9. Operacoes de Vendas "
            ].
            



def var crelatorios     as char format "x(30)" extent 8 initial
           ["Relatorio Contabil ",
            "Boletim de Caixa Completo ",
            "Boletim de Caixa Parcial ",
            "Boletim por Modalidade ",
            "Bolet. Modali. Por Periodo",
            "Recibo",
            "Boletim por Moeda",
            "Sintetico Saldo de Caixa"].


def var esqcom1         as char format "x(15)" extent 5 initial
    [
     " Consultas ",
     "  ",
     "    "
     ].
def var esqpos1 as int.
repeat:
/*
display esqcom1
        with frame f-com1 no-label no-box row 5.
choose field esqcom1 with frame f-com1.
*/
esqpos1 = 1. /*frame-index.*/
            if (esqcom1[esqpos1] = " Consultas " or
                esqcom1[esqpos1] = " Consultas ")
            then do:
                if true /*cmon.cmtcod = "PDV"*/
                then do:
                    
                    pause 0.
                    /*
                    if not avail cmon
                    then do:
                        pdvconsultas[1] = "".
                        pdvconsultas[2] = "".
                        pdvconsultas[3] = "".
                        pdvconsultas[4] = "".
                    end.
                    else do:
                        pdvconsultas[1] = "1. Consulta Movimento ".
                        pdvconsultas[2] = "2. Vendas".
                        pdvconsultas[3] = "3. Recebimentos  ".
                        pdvconsultas[4] = "4. Moedas".
                     end.
                     */
                     
                    if avail cmon
                    then do:
                     
                     /**   disp skip(1) pdvconsultas skip(1)
                            with frame pdvconsultas 
                            no-labels 1 col row 7 overlay
                            col 4 width 50
                            title " Consultas " .
                        choose field pdvConsultas
                             with frame pdvconsultas.
                        hide frame pdvconsultas no-pause.
                        vindex = frame-index.
                    end.
                    else vindex = 5.
                    
                    if vindex = 1                  /* Movimentacoes    */
                    then*/
                     do:
                        display today @ cmon.cxadt
                                    with frame f-cmon.
                        prompt-for cmon.cxadt
                                       with frame f-cmon.
                        par-data = input frame f-cmon cmon.cxadt.

                        run dpdv/pdvcmov.p (input recid(cmon),
                                            input par-data)
                                            no-error.
                                            
     
                    end.
                    end.
                    /*
                    if vindex = 2 /* Documentos */
                    then do:
                        display today @ cmon.cxadt
                                    with frame f-cmon.
                        prompt-for cmon.cxadt
                                       with frame f-cmon.
                        par-data = input frame f-cmon cmon.cxadt.

                        run dpdv/pdvcdoc.p (recid(cmon),
                                       par-data,
                                       "VEN").
                    end.
                    if vindex = 3 /* Documentos */
                    then do:
                        display today @ cmon.cxadt
                                    with frame f-cmon.
                        prompt-for cmon.cxadt
                                       with frame f-cmon.
                        par-data = input frame f-cmon cmon.cxadt.

                        run dpdv/pdvcdoc.p (recid(cmon),
                                       par-data,
                                       "REC"). 
                    end.
                    if vindex = 4 /* Documentos */
                    then do:
                        display today @ cmon.cxadt
                                    with frame f-cmon.
                        prompt-for cmon.cxadt
                                       with frame f-cmon.
                        par-data = input frame f-cmon cmon.cxadt.

                        run dpdv/pdvcmoe.p (recid(cmon),
                                       par-data,
                                       "",
                                       "").
                    end.
                    
                    
                    if vindex = 5                  /* Total p/Operacao */
                    then do:
                    */
                    else do:
                            display cmon.cxadt when avail cmon
                                    with frame f-cmon.
                            if not avail cmon
                            then update par-dtini
                                        with frame f-cmon.
                            
                            prompt-for cmon.cxadt
                                       with frame f-cmon.
                            par-data = input frame f-cmon cmon.cxadt.
                            if avail cmon
                            then par-dtini = par-data.

                        run dpdv/pdvtmov.p (input frame f-cmon cmon.etbcod,
                                       if avail cmon
                                       then recid(cmon)
                                       else ?,
                                       par-dtini,
                                       par-data,
                                       "").
                        
                    end.    

                    if vindex = 6                  /* Total p/Operacao */
                    then do:
                            display cmon.cxadt when avail cmon
                                    with frame f-cmon.
                            if not avail cmon
                            then update par-dtini
                                        with frame f-cmon.
                            
                            prompt-for cmon.cxadt
                                       with frame f-cmon.
                            par-data = input frame f-cmon cmon.cxadt.
                            if avail cmon
                            then par-dtini = par-data.

                        run dpdv/pdvtforma.p (input frame f-cmon cmon.etbcod,
                                       if avail cmon
                                       then recid(cmon)
                                       else ?,
                                       par-dtini,
                                       par-data,
                                       "").
                        
                    end.    

                     
                end.
                else do:
                    pause 0.
                    disp skip(1) cconsultas skip(1)
                            with frame fconsultas no-labels 1 col row 7 overlay
                            col 4 width 50
                            title " Consultas " .
                    choose field cConsultas
                         with frame fconsultas.
                    hide frame fconsultas no-pause.
                    if frame-index = 1                  /* Movimentacoes    */
                    then do:
                        if cmon.cmtcod = "BAN"
                        then do:
                            display cmon.cxadt
                                    with frame f-banco.
                            prompt-for cmon.cxadt
                                       with frame f-banco.
                            par-data = input frame f-banco cmon.cxadt.
                        end.
                        else do:
                            display cmon.cxadt
                                    with frame f-cmon.
                            prompt-for cmon.cxadt
                                       with frame f-cmon.
                            par-data = input frame f-cmon cmon.cxadt.
                        end.
                            run cmdalt.p ( input recid(CMon),
                                           input "CON",
                                           input "TODOS",
                                           input ?,
                                           input par-data,
                                           input ?,
                                           input ?,
                                           input ?).
                    end.
                    if frame-index = 2                  /* A Confirmar      */
                    then do:
                         run cmdalt.p ( input recid(CMon),
                                        input "CON",
                                        input "ABERTOS",
                                        input ?,
                                        input ?,
                                           input ?,
                                           input ?,
                                        input ?).
                    end.
                    if frame-index = 3                  /* A Confirmar      */
                    then do:
                         run cmdalt.p ( input recid(CMon),
                                        input "CON",
                                        input "externos",
                                        input ?,
                                        input ?,
                                           input ?,
                                           input ?,
                                        input ?).
                    end.
                    if frame-index = 4                  /* Total p/Operacao */
                    then do:
                            display cmon.cxadt
                                    with frame f-cmon.
                            prompt-for cmon.cxadt
                                       with frame f-cmon.
                            par-data = input frame f-cmon cmon.cxadt.
                            
                        run nfpcmon.p ( input recid(CMon), par-data).
                        
                    end.    
                    if frame-index = 55                  /* Saldo por Moeda  */
                    then run cmcosld.p ( input recid(CMon)). 
                    if frame-index = 6
                    then do: 
                        prompt-for cmon.cxadt 
                                   with frame f-cmon. 
                        run ancmope.p (input input frame f-cmon cmon.cxadt, 
                                       input recid(cmon)). 
                    end. 
                    if frame-index = 8 
                    then run cmcoope.p ( input recid(CMon)).  
                    if frame-index = 9 
                    then run cmcoopeven.p ( "VENDAS",
                                            input recid(CMon)). 
                
                    if frame-index = 7 
                    then  run cmcosld.p ( input recid(CMon)).
                
                end.
            end.
            if (esqcom1[esqpos1] = " Relatorios ")
            then do:
                pause 0.
                disp skip(1) crelatorios skip(1)
                        with frame frelatorios no-labels 1 col row 7 overlay
                        col 10 width 32
                        title " Relatorios " .
                choose field crelatorios
                     with frame frelatorios.
                hide frame frelatorios no-pause.

                if frame-index = 1          /* relator io contabil   */ 
                then run liscmd.p (input recid(cmon)).
                if frame-index = 2          /* boletin de caixa     */
                then run cmbol.p (input recid(cmon),
                                 "Completo").
                if frame-index = 3
                then run cmbol.p (input recid(cmon),
                                 "Incompleto").
                if frame-index = 4
                then do:
                    def var vmodcod like modal.modcod.
                    update vmodcod 
                        with frame fmodcod
                        overlay row 15 side-labels
                        title "Modalidade".
                    find modal where
                            modal.modcod = vmodcod
                            no-lock no-error.
                    if not avail modal
                    then do:
                        message "Modalidade Invalida".
                        undo.
                    end.
                    disp modal.modnom no-label with frame fmodcod.
                    run cmbol.p (input recid(cmon),
                                 vmodcod).
                end.              
                      if frame-index = 5 then
                      run cmbolmoe.p (recid(cmon)).
                if frame-index = 6          /* Recibo    */
                then run cmdrecib.p (input ?).
                if frame-index = 7
                then run cmbolmoeda.p (recid(cmon)).
                if frame-index =  8                            
                then run fcmsldger.p (input recid(cmon)).
            end.
end. 
if not par-normal then leave.           
           
           end.



