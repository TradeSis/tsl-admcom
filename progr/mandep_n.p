{admcab.i}
{setbrw.i}
def var vv-tpche as char.

def var v-ok as logical .

def var vretorno as logical init no.
def var j      as int.
def var v-kont as int.
def var vetbcod like estab.etbcod.
def var vdata   like plani.pladat.
def var vsenha  like func.senha.
def var v-descri as char format "x(50)".
def var v-vlote-che as dec format ">,>>>,>>9.99" .
def var v-vbate-che  as dec format ">,>>>,>>9.99" initial 0.
def var v-ind-consulta as logical initial no.
def var v-s as char format "x(1)".


def var esqcom1         as char format "x(15)" extent 5
    initial ["  MARCA ", "DESMARCA", "  INVERTE TUDO ", "   ","   "].
def var esqcom2         as char format "x(15)" extent 5
            initial ["F4- Retorna","F1- Confirma","","",""].
def var esqhel1         as char format "x(80)" extent 5
    initial ["",
             "",
             "",
             "",
             ""].
def var esqhel2         as char format "x(12)" extent 5
   initial [" ",
            " ",
            " ",
            " ",
            " "].
def var esqpos1         as int.
def var esqpos2         as int.
def var esqregua        as log.
def var esqvazio        as log.
def var esqascend     as log initial yes.


form
    esqcom1
    with frame f-com1
                 row 6 no-box no-labels side-labels column 1 centered.
form
    esqcom2
    with frame f-com2   
                 row 18 no-box no-labels side-labels column 1
                 centered.
assign
    esqregua = yes
    esqpos1  = 1
    esqpos2  = 1.


form " " 
     " "                
     with frame f-linha 5 down color with/cyan /*no-box*/
     centered.                              
                                                                         
                                                 
disp " " with frame f2 1 down width 80 color message 
        no-box no-label                row 20.             

def temp-table tw-chqlote like chq
    field sequencia  as int
    field tipo       as char
    field data-con  as date    format "99/99/9999" label "Dt.Conf."
    field data-apre  as date    format "99/99/9999" label "Dt.Apres."
    field marca-cheq as logical format "*/" label "Conf."
    field valconf    as dec.

repeat:
    vetbcod = 0.
    vdata = today.
    hide frame f1 no-pause.
    hide frame f2 no-pause.
    vsenha = "".
    update vsenha label "Senha"
        blank with frame f-senha side-label centered row 4.
        
    if vsenha <> "32940" and
       vsenha <> "1079"  and 
       vsenha <> "fim99" and
       vsenha <> "4041"
    then do:
        message "Senha Invalida".
        undo, retry.
    end.
    hide frame f-com1 no-pause.
    hide frame f-com2 no-pause.
    hide frame f-linha no-pause.
    update vetbcod label "Filial" with frame f1 side-label width 80.
    find estab where estab.etbcod = vetbcod no-lock no-error.
    display estab.etbnom format "x(25)" no-label with frame f1 row 7.
    update vdata label "Data Mov." format "99/99/9999" with frame f1.
    assign v-kont = 0.
    
    if vetbcod = 999
    then do:
        find deposito where deposito.etbcod = estab.etbcod and
                            deposito.datmov = vdata
                            no-lock no-error.
        if not avail deposito
        then do:
            create deposito.
            assign
                deposito.etbcod = estab.etbcod 
                deposito.datmov = vdata.
            update deposito.
        end.
    end.
    hide frame f1 no-pause.

    for each deposito where deposito.etbcod = estab.etbcod and
                            deposito.datmov = vdata.
       disp deposito with frame f-dep 1 column centered row 4 overlay.
       /* antonio */
       if deposito.datcon <> ? and
          sfuncod <> 29 and
          sfuncod <> 30 and
          sfuncod <> 404 
       then v-ind-consulta = yes.
       else v-ind-consulta = no.
       /**/
       if v-ind-consulta = no 
       then do:
            if vsenha = "1079"
            then update deposito with frame f-dep.
            else do:
                update deposito.datcon 
                validate(deposito.datcon = today,"Data Invalida")
                with frame f-dep.
                update  depsit
                with frame f-dep.
            end.
        end.    
        find lotdep where lotdep.etbcod = deposito.etbcod and
                          lotdep.datcon = deposito.datmov no-error.
        if not avail lotdep
        then do:
            create lotdep.
            assign lotdep.etbcod = deposito.etbcod
                   lotdep.datcon = deposito.datmov.
        end.
        if v-ind-consulta = no     /* antonio */
        then 
        update lotdep.lote with frame f-dep.
        else                                
        update "Tecle enter p/cheques -> " v-s no-label 
         with frame f-segue no-box centered.        
        hide frame f-segue no-pause.
        hide frame f-senha no-pause.
        hide frame f-dep no-pause.
        assign v-vlote-che = deposito.chedia.
        assign vv-tpche = "V".
        run pi-cheques( input "V", input deposito.chedia).
        if vretorno = yes 
        then do:
            view frame f-senha.
            undo, retry.    
        end.
        hide frame f11 no-pause.
        assign v-vlote-che = deposito.chedre.
        assign vv-tpche = "P".
        run pi-cheques( input "P", input deposito.chedre).
        if vretorno = yes
        then do:
              view frame f-senha.
              undo, retry.
        end.
        else do:
            find current chqconf no-lock no-error.
            if not avail chqconf
            then do:
                run Pi-Atualiz-chq.
                message " Lote de cheques Confirmados ok !"
                view-as alert-box. 
            end.               
        end.
    end.
 
end.

procedure pi-cheques.

def input parameter p-tp-data as char. /* V- A vista  P- Pré */
def input parameter p-valor   as dec.

def var cQuery      as Char          No-undo.
def var qh          as  Widget-handle    No-undo.
def var bh-tabela   as  Widget-handle    No-undo.
def var fh          as  Widget-handle    No-undo Extent 7.


for each tw-chqlote :
    delete tw-chqlote.
end.

    
assign cQuery = "for each chq where chq.datemi = "
       cQuery = cQuery + string(vdata) +  " no-lock ".
create buffer bh-tabela for table 'chq'. 
create Query qh.
qh:set-buffers(bh-tabela).
qh:Query-prepare(cQuery).
qh:Query-open.

Assign  fh[1] =  bh-tabela:Buffer-field('banco')
        fh[2] =  bh-tabela:buffer-field('agencia')
        fh[3] =  bh-tabela:buffer-field('conta')
        fh[4] =  bh-tabela:buffer-field('numero') 
        fh[5] =  bh-tabela:Buffer-field('datemi')
        fh[6] =  bh-tabela:Buffer-field('data')
        fh[7] = bh-tabela:buffer-field('valor').
/* Cria temp de Lotes de cheques */

assign  v-vbate-che = 0
        vretorno = yes.

Repeat:
    
    qh:Get-next().
    if qh:Query-off-end then leave.
    
    find first chqtit where chqtit.banco   =  fh[1]:buffer-value and
                            chqtit.agencia =  fh[2]:buffer-value and 
                            chqtit.conta   =  fh[3]:buffer-value and
                            chqtit.numero  =  fh[4]:buffer-value 
                            no-lock no-error.
    if not avail chqtit then next.
    if chqtit.etbcod <> vetbcod then next.
    if p-tp-data = "V" and fh[5]:buffer-value <> fh[6]:buffer-value then next.
    if p-tp-data = "P" and fh[6]:buffer-value <= fh[5]:buffer-value then next.
 
   
    find first chqconf where chqconf.banco   = fh[1]:buffer-value  and
                             chqconf.agencia = fh[2]:buffer-value  and
                             chqconf.conta   = fh[3]:buffer-value  and
                             chqconf.numero  = fh[4]:buffer-value 
                             no-lock no-error.

     find first tw-chqlote where tw-chqlote.tipo    = p-tp-data and
                                tw-chqlote.banco   = fh[1]:buffer-value and
                                tw-chqlote.agencia = fh[2]:buffer-value and
                                tw-chqlote.conta   = fh[3]:buffer-value and
                                tw-chqlote.numero  = fh[4]:buffer-value
                                no-lock no-error.
    if not avail tw-chqlote 
    then do:
        create tw-chqlote.
    end.
    assign v-vbate-che = v-vbate-che + fh[7]:buffer-value.
    assign v-kont = v-kont + 1
           tw-chqlote.sequencia   = v-kont
           tw-chqlote.banco       = fh[1]:buffer-value                       
           tw-chqlote.agencia     = fh[2]:buffer-value 
           tw-chqlote.conta       = fh[3]:buffer-value
           tw-chqlote.numero      = fh[4]:buffer-value
           tw-chqlote.valor       = fh[7]:buffer-value 
           tw-chqlote.marca       = no.

    if avail chqconf then assign tw-chqlote.marca = yes
                                 tw-chqlote.data-con = chqconf.data-con.

    assign tw-chqlote.data-apre = fh[5]:buffer-value.
    if p-tp-data = "V" 
    then fh[5]:handle:label = " " + "Data a Vista".
    else fh[5]:handle:label = " " + "Data Pre'".
                   
end.

if v-ind-consulta = yes
then do:
    assign esqcom1[1] = " CONSULTA "
           esqcom1[2] = "RELATORIO"
           esqcom1[3] = " "
           esqcom1[4] = " "
           esqcom1[5] = " "
           esqcom2[1] = "F4- Retorna"
           esqcom2[2] = " ".
end.
else do:
    assign esqcom1[1] = "  MARCA "
           esqcom1[2] = "DESMARCA"
           esqcom1[3] = "  INVERTE TUDO "
           esqcom1[4] = "RELATORIO"
           esqcom1[5] = "   "
           esqcom2[1] = "F4- Retorna"
           esqcom2[2] = "F1- Confirma".
end.

do j = 1 to 5:
   color display normal esqcom1[j] with frame f-com1.
end.

assign esqpos1 = 1.
disp esqcom1 with frame f-com1 overlay.
color display message esqcom1[1] with frame f-com1.
disp esqcom2 with frame f-com2 overlay.   


    assign
        a-seeid = -1 a-recid = -1 a-seerec = ?
        esqpos1 = 1 esqpos2 = 1. 
  
find first tw-chqlote no-error.

if avail tw-chqlote
then do:
 l1: repeat:

   disp esqcom1 with frame f-com1 overlay.
   disp esqcom2 with frame f-com2 overlay.
   clear frame f-linha all.
   hide frame f-linha no-pause.
 
   pause 0.
   assign v-descri = " CHEQUES RECEBIDOS " +
           (if p-tp-data = "V"  then "A VISTA" else " DREBES  " )
           v-descri = v-descri + " - R$ " + string(p-valor,">,>>>,>>9.99").         
    disp v-descri with frame f10 width 60                                             color message no-box no-label row 7 centered.
    {sklclstb.i  
        &color = with/cyan
        &file  =  tw-chqlote 
        &cfield = tw-chqlote.numero
        &noncharacter = /* 
        &ofield = "tw-chqlote.banco tw-chqlote.agencia 
        tw-chqlote.conta tw-chqlote.data-apre tw-chqlote.valor 
        tw-chqlote.marca tw-chqlote.data-con"  
        &aftfnd1 = " "
        &where   = " "
        &aftselect1 = " run aftselect.
                       a-seeid = -1.
                       /*
                       if esqcom1[esqpos1] = ""  MARCA "" or
                          esqcom1[esqpos1] = ""DESMARCA"" or
                          esqcom1[esqpos1] = ""  INVERTE TUDO "" or
                          esqcom1[esqpos1] = ""RELATORIO"" or
                       then next l1.
                       else */
                       next keys-loop. "
        &go-on = TAB 
        &naoexiste1 = "  " 
        &otherkeys1 = " run controle. if keyfunction(lastkey) = ""GO"" then leave." 
        &locktype = " "
        &form   = " frame f-linha overlay"
    }   
    if keyfunction(lastkey) = "end-error"  or keyfunction(lastkey) = "GO"
    then DO:
        if v-ind-consulta = yes then vretorno = no. /* Consulta */
        leave l1.       
    END.
 end.
end.
else assign vretorno = no. /* caso nao exista retorna sem erro */

hide frame f-com1 no-pause.
hide frame f-com2 no-pause.
hide frame f10 no-pause.
hide frame f11 no-pause.
hide frame ff2 no-pause.
hide frame f-linha no-pause.

end procedure.

procedure Aftselect.

  clear frame f-linha1 all.
    if esqcom1[esqpos1] = "RELATORIO"
    then do:
        run Pi-Relatorio (input vv-tpche).
    end.
    if esqcom1[esqpos1] = "  MARCA   "
    then do on error undo:
       find current tw-chqlote no-error. 
       assign tw-chqlote.data-con = deposito.datcon
              tw-chqlote.marca = yes.
       run Pi-Exibe-Total (output v-ok).
    end.
    if esqcom1[esqpos1] = "DESMARCA"
    then do on error undo:
       find current tw-chqlote no-error.
       assign tw-chqlote.data-con = ?
              tw-chqlote.marca = no.
       run Pi-Exibe-Total (output v-ok).       
    end.
    if esqcom1[esqpos1] = "  INVERTE TUDO "
    then do on error undo:
        for each tw-chqlote :
           if tw-chqlote.marca = yes 
           then do:

                assign tw-chqlote.marca = no
                       tw-chqlote.data-con = ?.
           end.
           else do:
                assign tw-chqlote.marca = yes
                       tw-chqlote.data-con = deposito.datcon.
           end. 
        end.
        run Pi-Exibe-Total (output v-ok).
    end.
    
end procedure.

Procedure Pi-Atualiz-chq.

for each tw-chqlote:
   
    find first chqconf where chqconf.banco = tw-chqlote.banco
                   and   chqconf.agencia = tw-chqlote.agencia
                   and   chqconf.conta   = tw-chqlote.conta 
                   and   chqconf.numero  = tw-chqlote.numero exclusive no-error.

    if not avail chqconf then do:
        create chqconf.
        assign chqconf.banco   = tw-chqlote.banco
               chqconf.agencia = tw-chqlote.agencia
               chqconf.conta   = tw-chqlote.conta 
               chqconf.numero  = tw-chqlote.numero
               chqconf.funcod  = sfuncod
               chqconf.v-int1  = lotdep.lote
               chqconf.data-con = tw-chqlote.data-con
               chqconf.valconf   = tw-chqlote.valor.
    end.

end.

end procedure.

Procedure Pi-Exibe-Total.

def output parameter p-ok as logical.
def buffer btw-chqlote for tw-chqlote.
def var v-soma-cheque as dec format ">,>>>,>>9.99".

    assign v-soma-cheque = 0
           p-ok = no.
                         
    for each btw-chqlote where btw-chqlote.marca = yes:
         assign v-soma-cheque = v-soma-cheque + btw-chqlote.valor.        
    end.
        
    if v-soma-cheque > 0
    then do:
        v-descri = "Total Cheques Selecionados R$" +
                    string(v-soma-cheque,">,>>>,>>9.99").
        disp v-descri with frame f11 width 60                                            color message no-box no-label row 17 centered.

        if v-soma-cheque = v-vlote-che then assign p-ok = yes.
    end.   
    else do:
        hide frame f11 no-pause.
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
                    do ve = 1 to 5:
                    color display normal esqcom1[ve] with frame f-com1.
                    end.
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
            if keyfunction(lastkey) = "GO"
            then do:
                run Pi-Exibe-Total(output v-ok).
                if v-ok = no
                then do:
                    vretorno = yes . /* Volta com erro */
                    message  "Total Selecionado nao bate com Informado !!" 
                             view-as alert-box.
                    leave.
                end. 
                else do:
                    assign vretorno = no.
                    leave.
                end.
            end.

 end procedure.

Procedure Pi-Relatorio.

def input parameter ptipo   as char format "x(1)".

def var vtotal_m    as dec.
def var vtotal_n    as dec.
def var varquivo as char.
def var vpcab    as char.

if ptipo = "V" then assign vpcab = " A VISTA ".
else assign VPCAB = " PRE-DREBES".  
 
    if opsys = "UNIX"
    then varquivo = "../relat/rmandep" + string(time).
    else varquivo = "..\relat\rmandep" + string(time).
            
    {mdadmcab.i &Saida     = "value(varquivo)"
                &Page-Size = "64"
                &Cond-Var  = "120"
                &Page-Line = "66"
                &Nom-Rel   = ""MANDEP""
                &Nom-Sis   = """SISTEMA FINANCEIRO"""
                &Tit-Rel   = """RELACAO CHEQUES "" + string(vpcab) + "" EM "" + ~ string(vdata)"
                &Width     = "120"
                &Form      = "frame f-cabcab"}

            for each tw-chqlote :

              if ptipo = "V" and tw-chqlote.datemi <> tw-chqlote.data
              then next.
              if ptipo = "P" and tw-chqlote.data <= tw-chqlote.datemi
              then next.

              if tw-chqlote.marca = yes 
              then assign vtotal_m = vtotal_m + tw-chqlote.valor.
              if tw-chqlote.marca = no 
              then assign vtotal_n = vtotal_n + tw-chqlote.valor.
 
              disp tw-chqlote.banco
                   tw-chqlote.agencia
                   tw-chqlote.conta 
                   tw-chqlote.numero (count)
                   tw-chqlote.data
                   tw-chqlote.datemi 
                   tw-chqlote.valor (total)
                   tw-chqlote.marca
                   with frame f-dispchq centered down.
              down with frame f-dispchq.
                   
            end.

            put skip "Totais Cheques Selecionados     " vtotal_m  
                    format "->>>,>>>,>>9.99".    
            put skip(1) "Totais Cheques Nao Selecionados " vtotal_n  
                    format "->>>,>>>,>>9.99".
             /*           
             {mdadmrod.i 
             &Saida  = " value(varquivo) "}  
            */
            output close.
            if opsys = "UNIX"
            then do:
                run visurel.p(varquivo,"").
            end.
            else do:
                {mrod.i}
            end.
  
  end procedure.
