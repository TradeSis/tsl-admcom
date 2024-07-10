{admcab.i}
{setbrw.i}                                                                      

def input parameter p-codmix like tabmix.codmix. 

def var recatu1         as recid.
def var recatu2         as recid.
def var reccont         as int.
def var esqpos1         as int.
def var esqpos2         as int.
def var esqregua        as log.
def var esqvazio        as log.
def var esqascend     as log initial yes.
def var esqcom1         as char format "x(15)" extent 5
    initial ["","  CONSULTA","  ALTERA","  INCLUI",""].
def var esqcom2         as char format "x(15)" extent 5
            initial ["","","  RELATORIO","  EXCLUI",""].
def var esqhel1         as char format "x(80)" extent 5
    initial [" ",
             " ",
             " ",
             " ",
             " "].
def var esqhel2         as char format "x(12)" extent 5
   initial [" ",
            " ",
            " ",
            " ",
            " "].

{segregua.i}

form
    esqcom1
    with frame f-com1
                 row 3 no-box no-labels side-labels column 1 centered.
form
    esqcom2
    with frame f-com2
                 row screen-lines no-box no-labels side-labels column 1
                 centered.
assign
    esqregua = yes
    esqpos1  = 1
    esqpos2  = 1.

def var vpronom like produ.pronom.
def var vclacod like clase.clacod.

form " "
    /*tabmix.tipomix column-label "Tp" format "!"
    */
    tabmix.promix column-label "Classe" format ">>>>>>>9"
    vpronom       column-label "Descricao" format "x(50)"
    tabmix.qtdmix column-label "Quant"  format ">>>9"
    /*
    tabmix.mostruario column-label "Mos" 
    tabmix.sazonal column-label "Saz"
    tabmix.dtsazonali column-label "Dtsazi"
    tabmix.dtsazonalf column-label "Dtsazf"
    */
     " "
     with frame f-linha 10 down color with/cyan /*no-box*/
       centered.                                        

find first tabmix where tabmix.tipomix = "M" and
                        tabmix.codmix = p-codmix
                        no-lock no-error.

def var vdesmix as char.
vdesmix = "CLASSES -  MIX " + tabmix.descmix.                        
disp "                     CLASSES -  MIX " tabmix.descmix
            with frame f1 1 down width 80                                       
            color message no-box no-label row 4.
                                                  
disp " " with frame f2 1 down width 80 color message no-box no-label            
    row 20.                                                                     
def buffer btbcntgen for tbcntgen.                            
def var i as int.

l1: repeat:
    disp esqcom1 with frame f-com1.
    disp esqcom2 with frame f-com2.
    assign
        a-seeid = -1 a-recid = -1 a-seerec = ?
        esqpos1 = 1 esqpos2 = 1. 
    hide frame f-linha no-pause.
    clear frame f-linha all.
    {sklclstb.i  
        &color = with/cyan
        &file = tabmix  
        &cfield = tabmix.promix
        &noncharacter = /* 
        &ofield = " tabmix.qtdmix
                    vpronom
                     "  
        &aftfnd1 = "
            vpronom = "" "".
            if tabmix.tipomix = ""P""
            then do:
                find produ where 
                     produ.procod = tabmix.promix no-lock no-error.
                if avail produ
                then vpronom = produ.pronom.     
            end.
            else if tabmix.tipomix = ""C""
                then do:
                    find clase where 
                         clase.clacod = tabmix.promix no-lock no-error.
                    if avail clase
                    then vpronom = clase.clanom.       
                end.
            "
        &where  = " tabmix.codmix = p-codmix and
                    tabmix.tipomix = ""C"" "
        &aftselect1 = " run aftselect.
                        a-seeid = -1.
                        if esqcom2[esqpos2] = ""  EXCLUI"" 
                        then do:
                            next l1.
                        end.
                        else next keys-loop. "
        &go-on = TAB 
        &naoexiste1 = " 
            do on error undo, retry with frame f-inclui 
                              side-label centered color message
                              row 8 :
                prompt-for    
                    vclacod  at 5 label ""Classe"" format "">>>>>>>9""
                        .
                    
                vpronom = "" "".    
                find clase where 
                             clase.clacod = input vclacod 
                             no-lock no-error.
                if avail clase
                then vpronom = clase.clanom.  

                disp vpronom at 1 label ""Descricao"".
                
                create tabmix.
                assign
                    tabmix.codmix = p-codmix
                    tabmix.tipomix = ""C""
                    tabmix.promix  = input vclacod
                    tabmix.etbcod  = 0.
                update tabmix.qtdmix      at 1 label ""Quantidade""
                       /*tabmix.mostruario  at 1 label ""Mostruario""
                       tabmix.sazonal     at 1 label ""   Sazonal""    .
                       */.
                run ver-produtos(input clase.clacod).
                /*
                if tabmix.sazonal
                then do on error undo, retry:
                    update     
                       tabmix.dtsazonali  label ""Inicio"" when sazonal
                       tabmix.dtsazonalf  label ""Fim""
                       .
                    if dtsazonali = ? or
                       dtsazonalf = ? or
                       dtsazonali > dtsazonalf
                    then undo.   
                end.
                else assign
                        dtsazonali = ?
                        dtsazonalf = ?.
                */
            end.
            next l1.
            " 
        &otherkeys1 = " run controle. "
        &locktype = " "
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
    def buffer btabmix for tabmix.
    if esqcom1[esqpos1] = "  INCLUI"
    THEN DO on error undo, retry with frame f-inclui 
                              side-label centered color message
                              row 8 :
                prompt-for    
                    vclacod  at 5 label "Classe" format ">>>>>>>9"
                        .
                    
                vpronom = " ".    
                find clase where 
                             clase.clacod = input vclacod 
                             no-lock no-error.
                if avail clase
                then vpronom = clase.clanom.  
                disp vpronom at 2 label "Descricao".
                
                create tabmix.
                assign
                    tabmix.codmix = p-codmix
                    tabmix.tipomix = "C"
                    tabmix.promix  = input vclacod
                    tabmix.etbcod  = 0.
                update tabmix.qtdmix      at 1 label "Quantidade"
                      /* tabmix.mostruario  at 1 label "Mostruario"
                       tabmix.sazonal     at 1 label "   Sazonal" .
                       */.
                run ver-produtos(input clase.clacod).
                /*
                if tabmix.sazonal
                then do on error undo, retry:
                    update     
                       tabmix.dtsazonali  label "Inicio" when sazonal
                       tabmix.dtsazonalf  label "Fim"
                       .
                    if dtsazonali = ? or
                       dtsazonalf = ? or
                       dtsazonali > dtsazonalf
                    then undo.   
                end.
                else assign
                        dtsazonali = ?
                        dtsazonalf = ?.
            */
    END.
    if esqcom1[esqpos1] = "  ALTERA"
    THEN DO on error undo, retry with frame f-inclui 
                              side-label centered color message
                              row 8 :
                vclacod = tabmix.promix.
                disp   vclacod  at 5 label "Classe" format ">>>>>>>9"
                        .
                    
                vpronom = " ".    
                find clase where 
                             clase.clacod =  vclacod 
                             no-lock no-error.
                if avail clase
                then vpronom = clase.clanom.  
                disp vpronom at 2 label "Descricao".
                
                update tabmix.qtdmix      at 1 label "Quantidade"
                       /*tabmix.mostruario  at 1 label "Mostruario"
                       tabmix.sazonal     at 1 label "   Sazonal" 
                       tabmix.dtsazonali  label "Inicio" when sazonal
                       tabmix.dtsazonalf  label "Fim"
                        */.
                run ver-produtos(input clase.clacod).
                
 
    end.
     
    if esqcom1[esqpos1] = "  ALTERA"
    THEN DO on error undo, retry with frame f-inclui 
                              side-label centered color message
                              row 8 :
                vclacod = tabmix.promix.
                disp vclacod  at 5 label "Classe" format ">>>>>>>9"
                        .
                    
                vpronom = " ".    
                find clase where 
                             clase.clacod =  vclacod 
                             no-lock no-error.
                if avail clase
                then vpronom = clase.clanom.  
                disp vpronom at 2 label "Descricao".
                
                update tabmix.qtdmix      at 1 label "Quantidade"
                       /*tabmix.mostruario  at 1 label "Mostruario"
                       tabmix.sazonal     at 1 label "   Sazonal" .
                        */ .
                run ver-produtos(input clase.clacod).
                /*        
                if tabmix.sazonal
                then do on error undo, retry:
                    update     
                       tabmix.dtsazonali  label "Inicio" when sazonal
                       tabmix.dtsazonalf  label "Fim"
                       .
                    if dtsazonali = ? or
                       dtsazonalf = ? or
                       dtsazonali > dtsazonalf
                    then undo.   
                end.
                else assign
                        dtsazonali = ?
                        dtsazonalf = ?.
                */
    END.
    if esqcom2[esqpos2] = "  EXCLUI"
    THEN DO:
        sresp = no.
        message "Confirma excluir " tabmix.promix "?" update sresp.
        if sresp
        then do:
            delete tabmix.
            recatu1 = ?.
        end.
    END.
    if esqcom2[esqpos2] = "  RELATORIO"
    THEN DO:
        sresp = no.
        message "Confirma relatorio ?" update sresp.
        if sresp
        then do:
            run relatorio.
        end.
    END.

end procedure.

procedure ver-produtos:
    def input parameter p-clacod like clase.clacod.
    def buffer b-tabmix for tabmix.
    def buffer b-produ  for produ.
    def var qtd-cla as int.
    def var qtd-pro as int.

    find clase where clase.clacod = p-clacod no-lock.

    qtd-cla = 0.
    find b-tabmix where b-tabmix.tipomix = "C" and
                        b-tabmix.codmix  = p-codmix and
                        b-tabmix.promix  = clase.clacod
                        no-lock no-error.
    if avail b-tabmix 
    then qtd-cla = qtd-cla + b-tabmix.qtdmix.

    qtd-pro = 0.
    for each b-produ where b-produ.clacod = clase.clacod no-lock.
        find b-tabmix where b-tabmix.tipomix = "P" and
                        b-tabmix.codmix  = p-codmix and
                        b-tabmix.promix  = b-produ.procod
                        no-lock no-error.
        if avail b-tabmix
        then qtd-pro = qtd-pro + b-tabmix.qtdmix.
    end.
    if qtd-cla > 0 and
       qtd-pro > qtd-cla
    then do:
        message color red/with   skip(1)
        "    A soma das qauntidades dos produtos ja informados    " 
        qtd-pro skip
        "    esta maior que a quantidade informada para classe    " 
        qtd-cla skip(1)
        view-as alert-box.
    end.   
end procedure.

procedure relatorio:
    def var vestoq as log.
    def var vetbcod like estab.etbcod.
    def var varqsai as char.
    def buffer r-tabmix for tabmix.
    def buffer r-produ  for produ.
    def buffer r-classe for clase.
    def buffer r-estoq  for estoq.
    def buffer r-estab for estab.
    
    if opsys = "UNIX"
    then varqsai = "/admcom/relat/clamix." + string(time).
    else varqsai = "..\relat\clamix." + string(time).
    
    {mdadmcab.i &Saida     = "value(varqsai)"   
                &Page-Size = "64"  
                &Cond-Var  = "80" 
                &Page-Line = "66" 
                &Nom-Rel   = ""clamix01"" 
                &Nom-Sis   = """SISTEMA COMERCIAL""" 
                &Tit-Rel   = " vdesmix " 
                &Width     = "80"
                &Form      = "frame f-cabcab"}

    for each r-tabmix where
             r-tabmix.tipomix = "C" and
             r-tabmix.codmix  = p-codmix
             no-lock: 
             
        find r-classe where r-classe.clacod = r-tabmix.promix no-lock.
        
        disp r-classe.clacod       column-label "Classe" format ">>>>>>>9"
             r-classe.clanom       column-label "Descricao" format "x(40)"
             r-tabmix.qtdmix       column-label "QtdMix" format ">>>9"
             with frame f-relat down width 120.
        down with frame f-relat.                         
    end.
    output close.
    if opsys = "UNIX"
    then do:
        run visurel.p(varqsai,"").
    end.
    else do:
        def var varquivo as char.
        varquivo = varqsai.
        {mrod.i}
    end.    
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

