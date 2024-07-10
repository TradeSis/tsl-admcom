
{cabec.i}
def var vformato    as log format "Err/" label "FMT".
def var v2formato   as char format "x(05)" label "FMT".

def shared temp-table tt-clien no-undo
    field cpf like neuclien.cpf
    field NOVOCPF as char format "x(14)"  
    field CLICOD  like neuclien.clicod    init ?
    field DATEXP like clien.datexp format "99/99/9999"
    field reg as int    format ">>9"
    field regabe as int format ">>9"
    field regtit as int format ">>9"
    field zerar as log column-label "ZERAR"
    field duplo as log column-label "DUP"
    field caracter as log column-label "CARAC"
    field tamanho  as log column-label "TAM"
    field marca    as log column-label "*" format "*/ " init yes
    index cpf is unique primary cpf asc
    index regabe regabe asc.

def shared temp-table tt-clicods no-undo
    field cpf like neuclien.cpf
    field clicod as int format ">>>>>>>>>>9" 
    field datexp like clien.datexp format "99/99/9999"
    field NOVOCPF as char format "x(14)"  
    field zerar as log column-label "ZERAR"
    field duplo as log column-label "DUP"
    field caracter as log column-label "CARAC"
    field tamanho  as log column-label "TAM"
    field sittit   as char format "x(03)" label "Tit"
    index cpf is unique primary cpf asc clicod asc.

def input-output parameter par-rec as recid.

def var vopcao as char extent 3.
def var copcao as int.
def var vi as int.
def var vmensagem as char.

form with frame flinha 
                     row 9 5 down
                     no-box.

def var esqpos2 as int .
def var esqcom2         as char format "x(10)" extent 6
            initial ["Formato",
                     "Contratos",
                     "",
                     "",
                     "",
                     ""].

form
    esqcom2                        
    with frame f-com2 row screen-lines no-labels no-box column 2 overlay.



form

        tt-clien.NOVOCPF column-label "CPF"
        tt-clien.marca
        tt-clien.CLICOD  column-label "CODIGO"
        clien.clinom     format "x(30)" 
        tt-clien.REG     column-label "Regs"
        tt-clien.regtit column-label "Parc"
        tt-clien.REGABE  column-label "Abe"
        vformato
    with frame frame-cab overlay row 3 width 80 1 down
         title " CONTA PRINCIPAL do CPF ".
         
if par-rec = ? /* Inclusao */
then do on error undo.
    return.
end.


if par-rec <> ?
then do with frame frame-cab on error undo.

    find tt-clien where recid(tt-clien) = par-rec no-lock.

    repeat:
        run fcab.    
        run mostra-origem.
        run mostra-parcelas.

        disp esqcom2 with frame f-com2.
        choose field esqcom2 
            with frame f-com2. 


        esqpos2 = frame-index.


 
        if esqcom2[esqpos2] = "Altera"
        then run altera.
        
    end.
    hide frame f-com2 no-pause.
end.

hide frame frame-cab no-pause.

procedure fcab.

    find tt-clien where recid(tt-clien) = par-rec no-lock.

    vformato = tt-clien.zerar or
               tt-clien.caracter or
               tt-clien.tamanho. 
    find clien where clien.clicod = tt-clien.clicod no-lock no-error.

    disp 
        tt-clien.NOVOCPF 
        tt-clien.marca
        tt-clien.CLICOD 
        clien.clinom when avail clien 
        tt-clien.REG    
        tt-clien.regtit
        tt-clien.REGABE 
        vformato
 
    with frame frame-cab.

    color disp messages
                tt-clien.novocpf
                with frame frame-cab.

    
end procedure.
 
procedure altera.

    do on error undo with frame frame-cab.
    end.

end procedure.

procedure mostra-origem.

            for each tt-clicods where tt-clicods.cpf =  tt-clien.cpf
                break by tt-clicods.datexp desc
                with frame flinha.
                
                find clien where clien.clicod = tt-clicods.clicod no-lock.
        
                disp clien.ciccgc format "x(14)"
                     clien.clicod column-label "CODIGO"
                     clien.clinom format  "x(15)"
                     clien.etbcad format ">>9" column-label "Etb"
                     clien.dtcad format "99/99/9999".
        
                disp tt-clicods.datexp column-label "Alter" .
                v2formato = if tt-clicods.zerar
                            then "ZERAR"
                            else if tt-clicods.caracter
                                 then "CARACTER"
                                 else if tt-clicods.tamanho
                                      then "TAMANHO"
                                      else "".
                disp v2formato
                     tt-clicods.sittit.
                down.                     
           end.

end procedure.

procedure mostra-parcelas.
end procedure.


