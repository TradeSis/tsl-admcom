{admcab.i}

def temp-table tp-titulo like fin.titulo
    index dt-ven titdtven
    index titnum /*is primary unique*/ empcod
          titnat
          modcod
          etbcod
          clifor
          titnum
          titpar.
                                                            
def var v-arquivo as char.
def var v-conecta   as log.

def input parameter vetbcod like estab.etbcod.
def input parameter rec-cli as recid.

find clien where recid(clien) = rec-cli no-lock.

def var vtitnum  like fin.titulo.titnum.
def var vparcela as int. 

def var vinicio         as log initial no.
def var recatu1         as recid.
def var recatu2         as recid.
def var esqpos1         as int.
def var esqpos2         as int.
def var esqregua        as log.
def buffer btitulo      for fin.titulo.
def buffer ctitulo      for fin.titulo.
def var vtitnat         like fin.titulo.titnat.
def var vclicodlab      as char format "x(12)".
def var vclicodnom      as char format "x(30)".
def var vclicod         like fin.titulo.clifor.
def var wperdes         as dec format ">9.99 %" label "Perc. Desc.".
def var wperjur         as dec format ">9.99 %" label "Perc. Juros".
def var vtitvlpag      like fin.titulo.titvlpag.
def var vtitvlcob      like fin.titulo.titvlcob.

def var esqcom1         as char format "x(15)" extent 5
    initial [" Consulta "," Produtos "," Procura ","",""].

form
    esqcom1
    with frame f-com1
                 row 3 no-box no-labels side-labels column 1 centered.
FORM
    tp-titulo.modcod   colon 15 fin.modal.modnom     no-label
    tp-titulo.titnum     colon 15
    tp-titulo.titpar     label "Parc" colon 15
    tp-titulo.titdtemi   colon 15
    tp-titulo.titdtven   colon 15
    tp-titulo.titvlcob   colon 15
    tp-titulo.cobcod     colon 15
    with frame ftitulo
        overlay row 5 color
        white/cyan side-label width 39.

form tp-titulo.bancod colon 15
    banco.bandesc no-label
    tp-titulo.agecod colon 15
    agenc.agedesc no-label
    tp-titulo.titche colon 15
    with frame fbancpg centered
         side-labels 1 down overlay
         color white/cyan row 16
         title " Banco Pago " width 80.

form tp-titulo.bancod   colon 20
    banco.bandesc           no-label
    tp-titulo.agecod   colon 20
    agenc.agedesc         no-label
    ccor.ccornum    colon 20
    with frame fbanco centered
         side-labels 1 down
         color white/cyan row 16 .

form wperjur           colon 16
    tp-titulo.titvljur colon 16
    tp-titulo.titjur   colon 16 /* skip(1)*/
    tp-titulo.titdtpag colon 16
    tp-titulo.titvlpag colon 16
    tp-titulo.etbcob   colon 16
    with frame fjurdes
         overlay row 5 column 41 side-label
         color white/cyan  width 40.

form
    tp-titulo.titobs[1] at 1
    tp-titulo.titobs[2] at 1
    with no-labels width 80 row 16
         title " Observacoes " frame fobs overlay
         color white/cyan .

form
    tp-titulo.titdtpag colon 13 label "Dt.Pagam"
    tp-titulo.titvlpag  colon 13
    tp-titulo.cobcod    colon 13
    with frame fpag1 side-label
         row 10 color white/cyan
         overlay column 42 width 39 title " Pagamento " .
vclicod = clien.clicod.
/*conecta-ok = no.
run agil4_WG.p (input "rtitulos", 
                input (string(setbcod,"999") +
                       string(vclicod,"9999999999"))
                ).*/
            
run p-titulos-filial(input vclicod).

/**
if conecta-ok = no
then return.
**/


find first tp-titulo no-lock no-error.         
         
repeat:
    clear frame ff1 all.
    assign
        esqregua = yes
        esqpos1  = 1
        esqpos2  = 1
        recatu1  = ?.

    find estab where estab.etbcod = vetbcod no-lock.
    vtitnat = no.
    vclicodlab = if vtitnat
                 then "Fornecedor:"
                 else "   Cliente:".

    find clien where recid(clien) = rec-cli no-lock.
    vclicod = clien.clicod .
    vclicodnom = clien.clinom + " - " + string(clien.clicod).

def var i as int.

bl-princ:
repeat :
    esqpos1 = 1.
    disp esqcom1 with frame f-com1.

    if recatu1 = ?
    then
        find first tp-titulo use-index  dt-ven where
            tp-titulo.empcod   = wempre.empcod and
            tp-titulo.titnat   = vtitnat       and
/*            tp-titulo.modcod   = "CRE"         and*/
            tp-titulo.clifor   = vclicod  no-error.
    else
        find tp-titulo where recid(tp-titulo) = recatu1.
    vinicio = no.
    if not available tp-titulo
    then do:
        message "Cliente sem prestacoes". pause.
        /*scli = clien.clicod.*/
        /* frame-value = scli. */
        return.
    end.

    if esqregua
    then color display message esqcom1[esqpos1] with frame f-com1.
    
    clear frame frame-a all no-pause.
    
    display
        tp-titulo.titnum format "x(10)"
        tp-titulo.titpar
        tp-titulo.titdtemi format "99/99/9999"   column-label "Dt.Emis"
        tp-titulo.titvlcob format ">>>,>>9.99" column-label "Vl Cobrado"
        tp-titulo.titdtven format "99/99/9999"   column-label "Dt.Vecto"
        tp-titulo.titdtpag format "99/99/9999"   column-label "Dt.Pagto"
        tp-titulo.titvlpag when tp-titulo.titvlpag > 0 format ">>>,>>9.99"
                                            column-label "Valor Pago"
        tp-titulo.modcod
        tp-titulo.titsit
            with frame frame-a 13 down centered color white/red
            title " " + vclicodlab + " " + vclicodnom + " " width 80.

    recatu1 = recid(tp-titulo).
    repeat:
        find next tp-titulo use-index dt-ven where
            tp-titulo.empcod   = wempre.empcod and
            tp-titulo.titnat   = vtitnat       and
/*            tp-titulo.modcod   = "CRE"         and*/
            tp-titulo.clifor   = vclicod no-error.
  
        if not available tp-titulo
        then leave.
        
        if frame-line(frame-a) = frame-down(frame-a)
        then leave.
        
        if not vinicio
        then down with frame frame-a.
        
        display
            tp-titulo.titnum
            tp-titulo.titpar
            tp-titulo.titdtemi
            tp-titulo.titvlcob
            tp-titulo.titdtven
            tp-titulo.titdtpag
            tp-titulo.titvlpag when tp-titulo.titvlpag > 0
            tp-titulo.modcod
            tp-titulo.titsit
                with frame frame-a.
    end.

    up frame-line(frame-a) - 1 with frame frame-a.

    repeat with frame frame-a:

        find tp-titulo where recid(tp-titulo) = recatu1.

        color display messages tp-titulo.titnum tp-titulo.titpar.
        choose field tp-titulo.titnum tp-titulo.titpar
            go-on(cursor-down cursor-up cursor-left cursor-right
                  tab PF4 F4 ESC return).
                  
        if keyfunction(lastkey) = "cursor-down"
        then do:
            find next tp-titulo use-index dt-ven where
                        tp-titulo.empcod   = wempre.empcod and
                        tp-titulo.titnat   = vtitnat       and
/*                        tp-titulo.modcod   = "CRE"         and*/
                        tp-titulo.clifor   = vclicod no-error.
     
            if not avail tp-titulo
            then next.
            
            color display normal
                tp-titulo.titnum tp-titulo.titpar.
            
            if frame-line(frame-a) = frame-down(frame-a)
            then scroll with frame frame-a.
            else down with frame frame-a.
        end.

            if keyfunction(lastkey) = "cursor-right"
            then do:
                if esqregua
                then do:
                    color display normal esqcom1[esqpos1] with frame f-com1.
                    esqpos1 = if esqpos1 = 5 then 5 else esqpos1 + 1.
                    color display messages esqcom1[esqpos1] with frame f-com1.
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
                next.
            end.
        
        if keyfunction(lastkey) = "cursor-up"
        then do:
            find prev tp-titulo use-index dt-ven where 
                                   tp-titulo.empcod   = wempre.empcod and
                                   tp-titulo.titnat   = vtitnat       and
/*                                   tp-titulo.modcod   = "CRE" and*/
                                   tp-titulo.clifor   = vclicod no-error.
            if not avail tp-titulo
            then next.
            color display normal
                tp-titulo.titnum tp-titulo.titpar.
            if frame-line(frame-a) = 1
            then scroll down with frame frame-a.
            else up with frame frame-a.
        end.
        if keyfunction(lastkey) = "end-error"
        then do:
            /*scli = clien.clicod.*/
            /* frame-value = scli. */
            return.
        end.

        if keyfunction(lastkey) = "return"
        then do on error undo, retry on endkey undo, leave.
          clear frame ftitulo all.
          clear frame fbancpg all.
          clear frame fbanco all.
          clear frame fjurdes all.
          clear frame fpag1 all.

          if esqcom1[esqpos1] = " Procura "
          then do on error undo:
               
               vtitnum = "". vparcela = 0. 
               
               update vtitnum    label "Contrato." 
                      vparcela   label "Parcela.."
                      with frame f-procura overlay side-labels centered 
                                    row 7
                                title "* Procura *".
                           
                find first tp-titulo use-index dt-ven where
                           tp-titulo.empcod   = wempre.empcod and
                           tp-titulo.titnat   = vtitnat       and
/*                           tp-titulo.modcod   = "CRE"         and*/
                           tp-titulo.clifor   = vclicod       and
                           tp-titulo.titnum   = vtitnum       and
                           tp-titulo.titpar   = vparcela no-lock no-error.
               if not avail tp-titulo 
               then do: 
                   message "Contrato nao encontrado.". pause 1 no-message.
                   undo.
               end.  
               
               hide frame f-procura no-pause. 
          
               recatu1 = recid(tp-titulo).
               leave.
                                        
          
          end.
          
          if esqcom1[esqpos1] = " Produtos "
          then do:
               run connfpro.p (input tp-titulo.clifor,
                               input tp-titulo.titnum,
                               input tp-titulo.modcod).
          end.   
             
          if esqcom1[esqpos1] = " Consulta "
          then do:
                find fin.modal where modal.modcod = tp-titulo.modcod
                                 no-lock no-error.
                disp
                    tp-titulo.modcod
                    modal.modnom when available modal
                    tp-titulo.titnum
                    tp-titulo.titpar
                    tp-titulo.titdtemi
                    tp-titulo.titdtven
                    tp-titulo.titvlcob
                    tp-titulo.cobcod
                    skip(2)
                        with frame ftitulo.

                disp
                    tp-titulo.titvljur
                    tp-titulo.titjuro
                    tp-titulo.titdtpag
                    tp-titulo.titvlpag
                    tp-titulo.etbcob
                    tp-titulo.datexp  colon 16
                    tp-titulo.cxmdat  colon 16
                    tp-TITULO.CXACOD  colon 16
                        with frame fjurdes.

                disp
                    tp-titulo.titobs[1] at 1
                    tp-titulo.titobs[2] at 1
                    with frame fobs.
          end.
          
          
          view frame frame-a.
          view frame f-com2 .
        end.
        
        if keyfunction(lastkey) = "end-error"
        then view frame frame-a.
        display
            tp-titulo.titnum
            tp-titulo.titpar
            tp-titulo.titdtemi
            tp-titulo.titvlcob
            tp-titulo.titdtven
            tp-titulo.titdtpag
            tp-titulo.titvlpag when tp-titulo.titvlpag > 0
            tp-titulo.modcod
            tp-titulo.titsit
                    with frame frame-a.
        recatu1 = recid(tp-titulo).
   end.
end.
end.

procedure p-titulos-filial:
    def input parameter p-clicod like clien.clicod.
    def buffer al-titulo for fin.titulo.      
    for each fin.titulo where titulo.clifor = p-clicod no-lock:
        if titulo.modcod = "BON" and titulo.titsit = "PAG" 
        then do: 
            find first tp-titulo where tp-titulo.empcod = 19
                                       and tp-titulo.titnat = yes
                                       and tp-titulo.modcod = titulo.modcod
                                       and tp-titulo.etbcod = titulo.etbcod
                                       and tp-titulo.clifor = titulo.clifor
                                       and tp-titulo.titnum = titulo.titnum
                                       and tp-titulo.titpar = titulo.titpar
                                       no-error.
            if avail tp-titulo
            then do : 
                assign tp-titulo.titsit   = titulo.titsit
                           tp-titulo.titdtpag = titulo.titdtpag
                           tp-titulo.titvlpag = titulo.titvlpag
                           tp-titulo.titvlcob = titulo.titvlcob 
                           tp-titulo.titvldes = titulo.titvldes
                           tp-titulo.titjuro  = titulo.titjuro 
                           tp-titulo.titvljur = titulo.titvljur 
                           tp-titulo.cxacod   = titulo.cxacod 
                           tp-titulo.cxmdata  = titulo.cxmdata 
                           tp-titulo.etbcobra = titulo.etbcobra 
                           tp-titulo.datexp   = titulo.datexp
                           tp-titulo.moecod   = titulo.moecod.

                
            end.
            next.
        end.  
        
        if titulo.titnat = no  
        then do:  
            find first tp-titulo where tp-titulo.empcod = 19
                                   and tp-titulo.titnat = no
                                   and tp-titulo.modcod = titulo.modcod
                                   and tp-titulo.etbcod = titulo.etbcod
                                   and tp-titulo.clifor = titulo.clifor
                                   and tp-titulo.titnum = titulo.titnum
                                   and tp-titulo.titpar = titulo.titpar
                                   no-error.
            if not avail tp-titulo
            then do : 
                if  (titulo.titdtpag <> ? and
                    titulo.titdtpag < today - 1100) or
                    titulo.titdtven < today - 1100
                then.
                else do:
                create tp-titulo.
                assign
                    tp-titulo.empcod    = titulo.empcod
                    tp-titulo.modcod    = titulo.modcod
                    tp-titulo.Clifor    = titulo.clifor
                    tp-titulo.titnum    = titulo.titnum
                    tp-titulo.titpar    = titulo.titpar
                    tp-titulo.titnat    = titulo.titnat
                    tp-titulo.etbcod    = titulo.etbcod
                    tp-titulo.titdtemi  = titulo.titdtemi
                    tp-titulo.titdtven  = titulo.titdtven
                    tp-titulo.titvlcob  = titulo.titvlcob
                    tp-titulo.titsit    = titulo.titsit
                    tp-titulo.moecod    = titulo.moecod.
                end.    
            end.
            else do:
                if titulo.titsit = "PAG" 
                then do:

                    assign tp-titulo.titsit   = titulo.titsit
                           tp-titulo.titdtpag = titulo.titdtpag
                           tp-titulo.titvlpag = titulo.titvlpag
                           tp-titulo.titvlcob = titulo.titvlcob 
                           tp-titulo.titvldes = titulo.titvldes
                           tp-titulo.titjuro  = titulo.titjuro 
                           tp-titulo.titvljur = titulo.titvljur 
                           tp-titulo.cxacod   = titulo.cxacod 
                           tp-titulo.cxmdata  = titulo.cxmdata 
                           tp-titulo.etbcobra = titulo.etbcobra 
                           tp-titulo.datexp   = titulo.datexp
                           tp-titulo.moecod   = titulo.moecod.
            
                    find first al-titulo where al-titulo.empcod = 19
                                       and al-titulo.titnat = yes
                                       and al-titulo.modcod = titulo.modcod
                                       and al-titulo.etbcod = titulo.etbcod
                                       and al-titulo.clifor = titulo.clifor
                                       and al-titulo.titnum = titulo.titnum
                                       and al-titulo.titpar = titulo.titpar
                                       no-error.
                    if avail al-titulo
                    then do : 
                        al-titulo.datexp = today.
                        al-titulo.exportado = no.
                    end.
                end.
                else if tp-titulo.titsit = "LIB"   and
                        tp-titulo.tpcontrato <> "" /*titpar > 30*/    and
                        tp-titulo.titdtven < titulo.titdtven
                    then tp-titulo.titdtven = titulo.titdtven.
            end.
            
        end. 
        else do:
            find first tp-titulo where tp-titulo.empcod = 19
                                   and tp-titulo.titnat = yes
                                   and tp-titulo.modcod = titulo.modcod
                                   and tp-titulo.etbcod = titulo.etbcod
                                   and tp-titulo.clifor = titulo.clifor
                                   and tp-titulo.titnum = titulo.titnum
                                   and tp-titulo.titpar = titulo.titpar
                                   no-error.
            if not avail tp-titulo
            then do : 
                create tp-titulo.
                assign
                    tp-titulo.empcod    = titulo.empcod
                    tp-titulo.modcod    = titulo.modcod
                    tp-titulo.Clifor    = titulo.clifor
                    tp-titulo.titnum    = titulo.titnum
                    tp-titulo.titpar    = titulo.titpar
                    tp-titulo.titnat    = titulo.titnat
                    tp-titulo.etbcod    = titulo.etbcod
                    tp-titulo.titdtemi  = titulo.titdtemi
                    tp-titulo.titdtven  = titulo.titdtven
                    tp-titulo.titvlcob  = titulo.titvlcob
                    tp-titulo.titsit    = titulo.titsit
                    tp-titulo.moecod    = titulo.moecod.
                    
            end.
            else do:
                if titulo.titsit = "PAG" 
                then do:

                    assign tp-titulo.titsit   = titulo.titsit
                           tp-titulo.titdtpag = titulo.titdtpag
                           tp-titulo.titvlpag = titulo.titvlpag
                           tp-titulo.titvlcob = titulo.titvlcob 
                           tp-titulo.titvldes = titulo.titvldes
                           tp-titulo.titjuro  = titulo.titjuro 
                           tp-titulo.titvljur = titulo.titvljur 
                           tp-titulo.cxacod   = titulo.cxacod 
                           tp-titulo.cxmdata  = titulo.cxmdata 
                           tp-titulo.etbcobra = titulo.etbcobra 
                           tp-titulo.datexp   = titulo.datexp
                           tp-titulo.moecod   = titulo.moecod.
            
                end.
            
            end.
        end.
    end.
    /***
    for each d.titulo where d.titulo.clifor = p-clicod no-lock:
        if d.titulo.modcod = "BON" and d.titulo.titsit = "PAG" 
        then do: 
            find first tp-titulo where tp-titulo.empcod = 19
                                       and tp-titulo.titnat = yes
                                       and tp-titulo.modcod = d.titulo.modcod
                                       and tp-titulo.etbcod = d.titulo.etbcod
                                       and tp-titulo.clifor = d.titulo.clifor
                                       and tp-titulo.titnum = d.titulo.titnum
                                       and tp-titulo.titpar = d.titulo.titpar
                                       no-error.
            if avail tp-titulo
            then do : 
                assign tp-titulo.titsit   = d.titulo.titsit
                           tp-titulo.titdtpag = d.titulo.titdtpag
                           tp-titulo.titvlpag = d.titulo.titvlpag
                           tp-titulo.titvlcob = d.titulo.titvlcob 
                           tp-titulo.titvldes = d.titulo.titvldes
                           tp-titulo.titjuro  = d.titulo.titjuro 
                           tp-titulo.titvljur = d.titulo.titvljur 
                           tp-titulo.cxacod   = d.titulo.cxacod 
                           tp-titulo.cxmdata  = d.titulo.cxmdata 
                           tp-titulo.etbcobra = d.titulo.etbcobra 
                           tp-titulo.datexp   = d.titulo.datexp
                           tp-titulo.moecod   = d.titulo.moecod.

                
            end.
            next.
        end.  
        
        if d.titulo.titnat = no  
        then do:  
            find first tp-titulo where tp-titulo.empcod = 19
                                   and tp-titulo.titnat = no
                                   and tp-titulo.modcod = d.titulo.modcod
                                   and tp-titulo.etbcod = d.titulo.etbcod
                                   and tp-titulo.clifor = d.titulo.clifor
                                   and tp-titulo.titnum = d.titulo.titnum
                                   and tp-titulo.titpar = d.titulo.titpar
                                   no-error.
            if not avail tp-titulo
            then do : 
                if  (d.titulo.titdtpag <> ? and
                    d.titulo.titdtpag < today - 1100) or
                    d.titulo.titdtven < today - 1100
                then.
                else do:
                create tp-titulo.
                assign
                    tp-titulo.empcod    = d.titulo.empcod
                    tp-titulo.modcod    = d.titulo.modcod
                    tp-titulo.Clifor    = d.titulo.clifor
                    tp-titulo.titnum    = d.titulo.titnum
                    tp-titulo.titpar    = d.titulo.titpar
                    tp-titulo.titnat    = d.titulo.titnat
                    tp-titulo.etbcod    = d.titulo.etbcod
                    tp-titulo.titdtemi  = d.titulo.titdtemi
                    tp-titulo.titdtven  = d.titulo.titdtven
                    tp-titulo.titvlcob  = d.titulo.titvlcob
                    tp-titulo.titsit    = d.titulo.titsit
                    tp-titulo.moecod    = d.titulo.moecod.
                end.    
            end.                            
            else do:
                if d.titulo.titsit = "PAG" 
                then do:

                    assign tp-titulo.titsit   = d.titulo.titsit
                           tp-titulo.titdtpag = d.titulo.titdtpag
                           tp-titulo.titvlpag = d.titulo.titvlpag
                           tp-titulo.titvlcob = d.titulo.titvlcob 
                           tp-titulo.titvldes = d.titulo.titvldes
                           tp-titulo.titjuro  = d.titulo.titjuro 
                           tp-titulo.titvljur = d.titulo.titvljur 
                           tp-titulo.cxacod   = d.titulo.cxacod 
                           tp-titulo.cxmdata  = d.titulo.cxmdata 
                           tp-titulo.etbcobra = d.titulo.etbcobra 
                           tp-titulo.datexp   = d.titulo.datexp
                           tp-titulo.moecod   = d.titulo.moecod.
            
                    find first al-titulo where al-titulo.empcod = 19
                                       and al-titulo.titnat = yes
                                       and al-titulo.modcod = d.titulo.modcod
                                       and al-titulo.etbcod = d.titulo.etbcod
                                       and al-titulo.clifor = d.titulo.clifor
                                       and al-titulo.titnum = d.titulo.titnum
                                       and al-titulo.titpar = d.titulo.titpar
                                       no-error.
                    if avail al-titulo
                    then do : 
                        al-titulo.datexp = today.
                        al-titulo.exportado = no.
                    end.
                end.
                else if tp-titulo.titsit = "LIB"   and
                        tp-titulo.titpar > 30      and
                        tp-titulo.titdtven < d.titulo.titdtven
                    then tp-titulo.titdtven = d.titulo.titdtven.
            end.
            
        end. 
        else do:
            find first tp-titulo where tp-titulo.empcod = 19
                                   and tp-titulo.titnat = yes
                                   and tp-titulo.modcod = d.titulo.modcod
                                   and tp-titulo.etbcod = d.titulo.etbcod
                                   and tp-titulo.clifor = d.titulo.clifor
                                   and tp-titulo.titnum = d.titulo.titnum
                                   and tp-titulo.titpar = d.titulo.titpar
                                   no-error.
            if not avail tp-titulo
            then do : 
                create tp-titulo.
                assign
                    tp-titulo.empcod    = d.titulo.empcod
                    tp-titulo.modcod    = d.titulo.modcod
                    tp-titulo.Clifor    = d.titulo.clifor
                    tp-titulo.titnum    = d.titulo.titnum
                    tp-titulo.titpar    = d.titulo.titpar
                    tp-titulo.titnat    = d.titulo.titnat
                    tp-titulo.etbcod    = d.titulo.etbcod
                    tp-titulo.titdtemi  = d.titulo.titdtemi
                    tp-titulo.titdtven  = d.titulo.titdtven
                    tp-titulo.titvlcob  = d.titulo.titvlcob
                    tp-titulo.titsit    = d.titulo.titsit
                    tp-titulo.moecod    = d.titulo.moecod.
                    
            end.
            else do:
                if d.titulo.titsit = "PAG" 
                then do:

                    assign tp-titulo.titsit   = d.titulo.titsit
                           tp-titulo.titdtpag = d.titulo.titdtpag
                           tp-titulo.titvlpag = d.titulo.titvlpag
                           tp-titulo.titvlcob = d.titulo.titvlcob 
                           tp-titulo.titvldes = d.titulo.titvldes
                           tp-titulo.titjuro  = d.titulo.titjuro 
                           tp-titulo.titvljur = d.titulo.titvljur 
                           tp-titulo.cxacod   = d.titulo.cxacod 
                           tp-titulo.cxmdata  = d.titulo.cxmdata 
                           tp-titulo.etbcobra = d.titulo.etbcobra 
                           tp-titulo.datexp   = d.titulo.datexp
                           tp-titulo.moecod   = d.titulo.moecod.
            
                end.
            
            end.
        end.
    end.  
    ***/
  
end procedure.

