{admcab.i}
{setbrw.i}                                                                      

def var recatu1         as recid.
def var recatu2         as recid.
def var reccont         as int.
def var esqpos1         as int.
def var esqpos2         as int.
def var esqregua        as log.
def var esqvazio        as log.
def var esqascend     as log initial yes.
def var esqcom1         as char format "x(15)" extent 5
    initial ["","  Inclui","  Altera","  Emissao","  Exclui"].
def var esqcom2         as char format "x(15)" extent 5
            initial ["","  Financeiro","","",""].
def var esqhel1         as char format "x(80)" extent 5
    initial ["teste teste",
             "",
             "",
             "",
             ""].
def var esqhel2         as char format "x(12)" extent 5
   initial ["teste teste  ",
            " ",
            " ",
            " ",
            " "].

form
    esqcom1
    with frame f-com1
                 row 4 no-box no-labels side-labels column 1 centered.
form
    esqcom2
    with frame f-com2
                 row screen-lines no-box no-labels side-labels column 1
                 centered.
assign
    esqregua = yes
    esqpos1  = 1
    esqpos2  = 1.


form  tpimport.numeropi column-label "Numero Processo"
      tpimport.nrdi     column-label "Numero DI"
      tpimport.datadi   column-label "Data DI"
      tpimport.etbcod   column-label "Filial"
      tpimport.forcod   column-label "Fornecedor"
      forne.fornom      no-label   format "x(15)"
            with frame f-linha 10 down  width 80 row 5.
                                                                                
def buffer btbcntgen for tbcntgen.                            
def var i as int.

l1: repeat:
    disp esqcom1 with frame f-com1.
    disp esqcom2 with frame f-com2.
    assign
        a-seeid = -1 a-recid = -1 a-seerec = ?
        esqpos1 = 1 esqpos2 = 1. 
    hide frame f-linha no-pause.
    color disp normal esqcom1 with frame f-com1.  
    clear frame f-linha all.
    {sklclstb.i  
        &color = with/cyan
        &file = tpimport  
        &cfie
        ld = tpimport.numeropi
        &noncharacter = /* 
        &ofield = " tpimport.nrdi
                    tpimport.datadi
                    tpimport.etbcod
                    tpimport.forcod
                    forne.fornom when avail forne
                    "  
        &aftfnd1 = " find forne where forne.forcod = tpimport.forcod 
                        no-lock no-error. "
        &where  = " true "
        &aftselect1 = " run aftselect.
                        a-seeid = -1.
                        if esqcom1[esqpos1] = ""  EXCLUI"" or
                           esqcom2[esqpos2] = ""  emissao""
                        then do:
                            next l1.
                        end.
                        else next keys-loop. "
        &go-on = TAB 
        &naoexiste1 = " esqcom1[esqpos1] = ""  INCLUI"". 
                            run aftselect. " 
        &otherkeys1 = " run controle. "
        &locktype = " no-lock "
        &form   = " frame f-linha "
    }   
    if keyfunction(lastkey) = "end-error"
    then DO:
        leave l1.       
    END.
end.
hide frame f1 no-pause.
hide frame f2 no-pause.
hide frame ff2 no-pause.
hide frame f-linha no-pause.

procedure aftselect:
    clear frame f-linha1 all.
    if esqcom1[esqpos1] = "  INCLUI"
    THEN DO on error undo:
        prompt-for /*tpimport.etbcod      label "Filial            "
                    validate(can-find(first estab where 
                    estab.etbcod = input frame f-inlcui tpimport.etbcod)
                    ,"Filial nao cadastrada")*/
                   tpimport.numeropi    label "Numero processo   "
                   tpimport.nrdi        label "Numero DI         "
                   tpimport.datadi      label "Data DI           "
                   tpimport.forcod      label "Fornecedor        "
                   validate(can-find(first forne where
                     forne.forcod = input frame f-inclui tpimport.forcod)
                                    ,"Fornecedor nao cadastrado")
                   tpimport.localdesemb label "Local desemb      "
                   tpimport.ufdesemb    label "UF desemb         "
                   tpimport.ddesemb     label "Data Desemb       "
                   with frame f-inclui 1 down centered 1 column
                   row 8 overlay.
        create tpimport.
        assign
            /*tpimport.etbcod   = input frame f-inclui tpimport.etbcod

            */
            tpimport.numeropi = input frame f-inclui tpimport.numeropi
            tpimport.nrdi     = input frame f-inclui tpimport.nrdi
            tpimport.datadi   = input frame f-inclui tpimport.datadi
            tpimport.forcod   = input frame f-inclui tpimport.forcod
            tpimport.localdesemb = 
            caps(input frame f-inclui tpimport.localdesemb)
            tpimport.ufdesemb = 
            caps(input frame f-inclui tpimport.ufdesemb)
            tpimport.ddesemb  = input frame f-inclui tpimport.ddesemb
            tpimport.dtinclu = today
            tpimport.etbcod  = setbcod
            . 
    end.
    if esqcom1[esqpos1] = "  ALTERA"
    THEN DO on error undo:
        find current tpimport exclusive .
        disp tpimport.numeropi    label "Numero processo   "
            with frame f-altera.
        
        update     tpimport.etbcod      label "Filial            "
                   validate(can-find(first estab where 
                    estab.etbcod = tpimport.etbcod),"Filial nao cadastrada")
                   tpimport.nrdi        label "Numero DI         "
                   tpimport.datadi      label "Data DI           "
                   tpimport.forcod      label "Fornecedor        "
                   validate(can-find(first forne where
                                    forne.forcod = tpimport.forcod)
                                    ,"Fornecedor nao cadastrado")
                   tpimport.localdesemb label "Local desemb      "
                   tpimport.ufdesemb    label "UF desemb         "
                   tpimport.ddesemb     label "Data Desemb       "
                   with frame f-altera 1 down centered 1 column
                   row 8 overlay.
         
         tpimport.localdesemb = caps(tpimport.localdesemb).
         tpimport.ufdesemb = caps(tpimport.ufdesemb).

         if tpimport.numnfe > 0
         then do:
             find first A01_infnfe where
                        A01_infnfe.emite  = tpimport.etbcod and
                        A01_infnfe.serie  = tpimport.sernfe and
                        A01_infnfe.numero = tpimport.numnfe
                        no-lock no-error.
             if not avail A01_infnfe or
                A01_infnfe.sitnfe = 12 or
                A01_infnfe.sitnfe = 14
             then update tpimport.numnfe      label "NF Entrada emitida"
                         with frame f-altera.
         end.
    end.
    if esqcom1[esqpos1] = "  EMISSAO"
    THEN DO on error undo:
        hide frame f-com1.
        run importacao_01.p(recid(tpimport)).
        view frame f-com1.
        color disp normal esqcom1[esqpos1] with frame f-com1.
    END.
    if esqcom1[esqpos1] = "  Arquivo"
    THEN DO:
    
    END.
    if esqcom1[esqpos1] = "  EXCLUI"
    THEN DO:
        find first tbimport where
                   tbimport.numeropi = tpimport.numeropi
                   no-lock no-error.
        if avail tbimport
        then do:
            bell.
            message color red/with
            "Processo com informações de mercadoria." skip
            "Impossivel excluir."
            view-as alert-box.
        end.
        else do:
            sresp = no.
            message "Confirma excluir processo " tpimpor.numeropi
             update sresp.
            if sresp
            then do on error undo:
                find current tpimport exclusive.
                delete tpimport.
            end.
        end.               
    END.
    if esqcom2[esqpos2] = "  Financeiro"
    THEN DO:
        run importacao_r01.p(recid(tpimport)).
    END.

end procedure.

procedure controle:
        def var ve as int.
            if keyfunction(lastkey) = "TAB"
            then do:
                if esqregua
                then do:
                    esqpos1 = 1.
                    do ve = 1 to 5:
                    color display normal esqcom1[ve] with frame f-com1.
                    end.
                    color display message esqcom2[esqpos2] with frame f-com2.
                end.
                else do:
                    do ve = 1 to 5:
                    color display normal esqcom2[ve] with frame f-com2.
                    end.
                    esqpos2 = 1.
                    color display message esqcom1[esqpos1] with frame f-com1.
                end.
                esqregua = not esqregua.
            end.
            if keyfunction(lastkey) = "cursor-right"
            then do:
                if esqregua
                then do:
                    color display normal esqcom1[esqpos1] with frame f-com1.
                    esqpos1 = if esqpos1 = 5 then 5 else esqpos1 + 1.
                    color display messages esqcom1[esqpos1] with frame f-com1.
                end.
                else do:
                    color display normal esqcom2[esqpos2] with frame f-com2.
                    esqpos2 = if esqpos2 = 5 then 5 else esqpos2 + 1.
                    color display messages esqcom2[esqpos2] with frame f-com2.
                end.
                next.
            end.
            if keyfunction(lastkey) = "cursor-left"
            then do:
                if esqregua
                then do:
                    color display normal esqcom1[esqpos1] with frame f-com1.
                    esqpos1 = if esqpos1 = 1 then 1 else esqpos1 - 1.
                    color display messages esqcom1[esqpos1] with frame f-com1.
                end.
                else do:
                    color display normal esqcom2[esqpos2] with frame f-com2.
                    esqpos2 = if esqpos2 = 1 then 1 else esqpos2 - 1.
                    color display messages esqcom2[esqpos2] with frame f-com2.
                end.
                next.
            end.
end procedure.

procedure relatorio:

    def var varquivo as char.
    
    varquivo = "/admcom/relat/nfeimportacao" + string(setbcod) + "."
                    + string(time).
    
    {mdadmcab.i &Saida     = "value(varquivo)"   
                &Page-Size = "64"  
                &Cond-Var  = "80" 
                &Page-Line = "66" 
                &Nom-Rel   = ""programa"" 
                &Nom-Sis   = """SISTEMA""" 
                &Tit-Rel   = """TITULO""" 
                &Width     = "80"
                &Form      = "frame f-cabcab"}

    run total.
    
    output close.

    if opsys = "UNIX"
    then do:
        run visurel.p(varquivo,"").
    end.
    else do:
        {mrod.i}
    end.
end procedure.

