/*************************INFORMA€OES DO PROGRAMA******************************
***** Nome do Programa             : lancxa2.p
*******************************************************************************/

{admcab.i}.
{setbrw.i}.

def buffer blancxa  for lancxa.
def var vlivre      like lancxa.livre1.
def var vnumlan     as int.
def var i           as int.
def var vtotallote  as dec format ">,>>>,>>9.99".
def var vtot        as dec.

def var vopfcod like fiscal.opfcod.
def var vmovtdc like tipmov.movtdc.
def var vbicms like fiscal.bicms format ">>>,>>>,>>9.99".
def var valicms like fiscal.alicms format ">>>,>>>,>>9.99".
def var vipi like fiscal.ipi   format ">>>,>>>,>>9.99".
def var vicms like fiscal.icms format ">>>,>>>,>>9.99".
def var vobs like fiscal.plaobs[1].
def var vetbcod like fiscal.desti.

form
    vetbcod   colon 20
    skip
    vopfcod   format ">>>9" colon 20
    skip 
    vmovtdc   colon 20
    skip 
    vbicms    colon 20
    skip
    valicms   colon 20
    skip
    vicms     colon 20
    skip
    vipi      colon 20
    skip
    vobs      colon 20
    with frame f-altera1 
        overlay side-labels 1 down title "DADOS CREDITO".

def var vdti as date.
def var vdtf as date.

form
    vlivre label "Lote"
    vtotallote label "Valor"
    with frame f-livre
        centered 1 down side-labels title "Lote".

form
    lancxa.datlan
        help "ENTER=Altera F8=Procura F9=Inclui F10=Exclui"
    lancxa.cxacod  label "Deb"   format ">>>>>9"
    lancxa.lancod  label "Cred"  format ">>>>>9"
    lancxa.vallan  format ">>>,>>9.99"
    lancxa.lanhis  label "Hst" format ">>9"
    lancxa.comhis  format "x(35)"
    lancxa.lansit  format "x" column-label "S" 
    with frame f-linha
        centered
        color white/cyan
        down.

form
    lancxa.datlan  colon 15
    skip
    lancxa.cxacod  colon 15 format ">>>>>9"  label "Deb"
    skip
    lancxa.lancod  colon 15 format ">>>>>9"  label "Cred"
    skip
    lancxa.vallan  colon 15  format ">>>,>>9.99" 
    skip
    lancxa.forcod  colon 15
    skip
    lancxa.titnum  colon 15 format "x(25)" 
    skip
    lancxa.comhis  colon 15  format "x(50)"
    with frame f-linha3 
        centered row 10 
        color white/red overlay side-labels 1 down title "Alterando ...".

form
    lancxa.datlan  colon 15
    skip
    lancxa.cxacod  colon 15 label "Deb"   format ">>>>>9"
    skip
    lancxa.lancod  colon 15 label "Cred"  format ">>>>>9"
    skip
    lancxa.vallan  colon 15 format ">>>,>>9.99"
    skip
    lancxa.lanhis  colon 15 label "Hst" format ">>9"
    skip
    lancxa.forcod  colon 15 label "Fornec"
    forne.fornom   no-label
    skip
    lancxa.titnum  colon 15 label "No.Titulo" format "x(25)"
    skip
    lancxa.comhis  colon 15 format "x(50)"
    with frame f-linha2
        centered  side-labels overlay row 12
        color white/cyan title " LANCAMENTOS ".

def var vselec as int.
def var vtitnum like lancxa.titnum format "x(12)".
def var vforcod like lancxa.forcod.
def var vvallan like lancxa.vallan.

l1:
repeat :
    clear frame f-livre all.
    clear frame f-linha all.
    hide frame f-linha.
    vlivre = "".
    vtotallote = 0.
    /*
    update 
        vlivre 
        vtotallote 
        with frame f-livre.
    */
    do on error undo:
        update vdti label "Periodo de" format "99/99/9999"
               vdtf label "Ate"        format "99/99/9999"
               with frame f-dat 1 down centered side-label.
        if vdtf = ? and vdti <> ?
        then vdtf = vdti.
        if vdti = ? or
           vdtf = ? or
           vdti > vdtf
        then undo.       
    end.
    repeat :
        assign
            a-seeid = -1
            a-recid = -1
            a-seerec = ?.
    
        {sklcls.i
            &color  = withe
            &color1 = red
            &File   = lancxa
            &CField = lancxa.datlan    
            &Ofield = "lancxa.lancod lancxa.cxacod lancxa.comhis
                    lancxa.lanhis lancxa.vallan lancxa.lansit"
            &Color = "white/red"   
            &NonCharacter = /*        
            &Where = "lancxa.datlan >= vdti and
                      lancxa.datlan <= vdtf and
                      lancxa.lantip = ""X"" 
                      "
            &AftSelect1 =    "
                if keyfunction(lastkey) = ""RETURN"" 
                then do : 
                    update lancxa.datlan 
                    lancxa.cxacod lancxa.lancod
                            lancxa.vallan lancxa.forcod lancxa.titnum 
                            lancxa.comhis 
                            lancxa.etbcod format "">>>>9""
                            with frame f-linha3.
                    disp   lancxa.datlan lancxa.cxacod lancxa.lancod
                           lancxa.vallan lancxa.lansit 
                           lancxa.comhis with frame f-linha. 
                          next keys-loop.
                end. "
            &Otherkeys  = " lancxa2.ok "
            &naoexiste1  = " bell.
                        message color red/with
                        ""Nenhum registro encontrado""
                        view-as alert-box.
                        leave l1.
                        "
            &abrelinha  = " lancxa2.in "
            &procura1 = "  assign vtitnum = "" "" vforcod = 0 vvallan = 0.
                           update vtitnum vforcod vvallan
                            with frame f-procura 1 down centered row 10
                            side-label overlay.
                          find first blancxa where
                                     blancxa.datlan >= vdti and
                                     blancxa.datlan <= vdtf and
                                     blancxa.lantip  = ""X"" and
                                     (if vtitnum <> """"
                                      then blancxa.titnum  = vtitnum else true)
                                 and (if vforcod > 0
                                      then blancxa.forcod = vforcod else true)
                                 and (if vvallan > 0
                                      then blancxa.vallan = vvallan else true)
                                     no-lock no-error.
                          if not avail blancxa
                          then do:
                              bell.
                              message color red/with
                              ""Nenhum registro encontrado""
                              view-as alert-box .
                              next keys-loop.
                          end.           
                          do:
                          a-seeid = -1.
                          a-recid = recid(blancxa).
                          next keys-loop.
                          end.  
                         "    
            &Form = " frame f-linha "
        }.

        if keyfunction(lastkey) = "END-ERROR" 
        then do :
            /**
            message "Confirma Desistencia da Digitacao do Lote" update sresp.
            if sresp = yes
            then do :
                for each lancxa where lancxa.livre1 = vlivre
                                  and lancxa.etbcod = 996 :
                    lancxa.lansit = "A".              
                end.
                leave.
            end.
            else next.
            **/
            leave l1.
        end.        
        /***
        if keyfunction(lastkey) = "GO" 
        then do :
            vtot = 0.
            for each lancxa where lancxa.livre1 = vlivre 
                              and lancxa.etbcod = 996 :
                vtot  = vtot + lancxa.vallan.
                lancxa.lansit = "F". 
            end.
            if vtotallote <> vtot 
            then do :
                bell. bell.
                disp 
                    "Informado: R$ " vtotallote format ">>>,>>9.99"  
                    skip(1)
                    "Digitado : R$ " vtot       format ">>>,>>9.99"
                    with frame f-div centered overlay row 10
                        color yellow/red no-labels title "Divergencia".
                pause.
                next.
            end.
            else leave. 
        end.
        ***/
    end.
end.                  
 

