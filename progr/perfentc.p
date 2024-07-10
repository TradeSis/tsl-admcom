/*************************INFORMA€OES DO PROGRAMA******************************
***** Nome do Programa             : convgenw.p
*******************************************************************************/

/*{cabec.i}*/
{admcab.i}
{anset.i}.

def input parameter par-recid as recid.
def input parameter vrow        as int.

def var p-vencod     like func.funcod.
def shared var p-loja      like estab.etbcod.

def shared      var vdti        as date format "99/99/9999" no-undo.
def shared      var vdtf        as date format "99/99/9999" no-undo.



def shared temp-table ttloja
    field etbcod    like estab.etbcod
    field nome      like estab.etbnom 
    field qtdmerca  as int column-label "Total"
    field qtdmercaent   as int column-label "Entregue"
    field qtdsaldo  as int column-label "Saldo"
    field qtdatrasado   as int column-label "Atrasado"
    field qtdposterior    as int column-label "Posterior"
    field vlrsaldo     as dec 
    field vlratrasado     as dec 
    
    index loja     is unique etbcod asc
    index totalqtd is primary qtdsaldo desc etbcod desc.

def  shared temp-table ttvendedor
    field vencod    like plani.vencod
    field etbcod    like estab.etbcod
    field nome      like estab.etbnom 
    field qtdmerca  as int column-label "Total"
    field qtdmercaent   as int column-label "Entregue"
    field qtdsaldo  as int column-label "Saldo"
    field qtdatrasado   as int column-label "Atrasado"
    field qtdposterior    as int column-label "Posterior"
    field vlrsaldo     as dec 
    field vlratrasado     as dec 
 
    index loja     is unique etbcod asc vencod asc 
    index platot   is primary qtdsaldo desc.



form
    ttloja.nome  column-label "Estabel." 
        format "x(22)"
        help "ENTER=Seleciona F4=Encerra F8=Imprime F9-Detalhe" 
    ttloja.qtdmerca    column-label "Total"  format ">>>>>>9" 
    ttloja.qtdmercaent column-label "Entr"  format ">>>>9"
    ttloja.qtdsaldo column-label     "!Qtd"  format ">>>>,>>9" 
        ttloja.vlrsaldo column-label " !Valor"
                format ">>>>>>9.99"

    ttloja.qtdatrasado column-label  "Atraso!Qtd" format ">>>>>9"
    ttloja.vlratrasado column-label  "      !Valor" format ">>>>>9,99"
    
    ttloja.qtdposterior column-label "Futuro!Qtd" format ">>>>>9"

    with frame f-lojas
        width 80
        centered
        1 down 
        row 5
        no-box
        overlay.

form header "COMPRADORES"
     with frame f-vendedor.


form
    ttvendedor.nome  column-label "Comprador." 
        format "x(22)"
        help "ENTER=Seleciona F4=Encerra F8=Imprime F9-Detalhe" 
    ttvendedor.qtdmerca    column-label "Total"  format ">>>>>>9" 
    ttvendedor.qtdmercaent column-label "Entr"  format ">>>>9"
    ttvendedor.qtdsaldo column-label     "!Qtd"  format ">>>>,>>9" 
        ttvendedor.vlrsaldo column-label " !Valor"
                format ">>>>>>9.99"

    ttvendedor.qtdatrasado column-label  "Atraso!Qtd" format ">>>>>9"
    ttvendedor.vlratrasado column-label  "      !Valor" format ">>>>>9,99"
    
    ttvendedor.qtdposterior column-label "Futuro!Qtd" format ">>>>>9"

    with frame f-vendedor
        width 80
        centered
        no-labels
        13 down 
        row vrow
        no-box
        overlay.

find ttloja where recid(ttloja) = par-recid.
repeat.
            assign  an-seeid = -1 an-recid = -1 
                    an-seerec = ?.

            {anbrowse.i
                &File   = ttvendedor
                &CField = ttvendedor.nome
                &color  = write/cyan
                &Ofield = "     ttvendedor.qtdmerca 
    ttvendedor.qtdmercaent
    ttvendedor.qtdsaldo
    ttvendedor.vlrsaldo 
    ttvendedor.qtdatrasado
    ttvendedor.vlratrasado
    ttvendedor.qtdposterior"
                &Where = "ttvendedor.etbcod  = p-loja"
                &NonCharacter = /*
                &Aftfnd = "
                "
                &AftSelect1 = "p-loja = ttvendedor.etbcod. 
                               p-vencod = ttvendedor.vencod.
                       leave keys-loop. "
                &LockType = "use-index platot" 
                &Form = " frame f-vendedor" 
            }.

            if keyfunction(lastkey) = "END-ERROR"
            then leave.
            
            clear frame f-vendedor all no-pause.
            disp
              ttvendedor.nome
                  ttvendedor.qtdmerca 
    ttvendedor.qtdmercaent
    ttvendedor.qtdsaldo
    ttvendedor.vlrsaldo
    ttvendedor.qtdatrasado
    ttvendedor.vlratrasado
    ttvendedor.qtdposterior
              with frame f-vendedor.
            
            run perfentp.p (input ttloja.etbcod, p-vencod).
    end.