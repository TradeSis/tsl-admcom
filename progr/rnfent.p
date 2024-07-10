/* Lista produto - rnfent.p */

{admcab.i }
def var varquivo as char.
def var vdti    as date format "99/99/9999".
def var vdtf    as date format "99/99/9999".
def var vcatcod     like produ.catcod init 0.
def var vpronom     like produ.pronom.
def var v-desc as char.

def var v-i as int.

def temp-table tt-produ
    field procod like produ.procod
    index cod is primary unique
          procod.

def stream stela.        

form                   
    skip(1)
    vcatcod  label   "Departamento"  colon 15
    v-desc format "x(30)" no-label 
    vpronom   label "Nome Produto" colon 15
    vdti label "Data Inicial" colon 15
    vdtf label "Data Final" colon 15
    with frame f-x centered 1 down side-labels title "Dados Iniciais" 
                     color white/bronw row 3  width 70.
    
vdti = date (month(today),1,year(today)).
vdtf = today.
repeat:

    vpronom = replace(vpronom,"*","").
    
    do on error undo: 
        update vcatcod  with frame f-x.
        if vcatcod = 0
        then v-desc = "Geral".
        else do: 
             find categoria where categoria.catcod = vcatcod no-lock no-error.
             if avail categoria
             then v-desc = categoria.catnom.
             else undo, retry.
        end.
        disp v-desc with frame f-x.
    end.

    update vpronom
           vdti
           vdtf
         with frame f-x.
    if vdti = ? or vdtf = ? or
       vdti > vdtf
    then do:
         message "Data invalida" . 
         next.
    end.

   output stream stela to terminal.

   if opsys = "UNIX"
   then varquivo = "../relat/rnfent" + string(time) + ".xls".
   else varquivo = "l:\relat\rnfent" + string(time) + ".xls".
/*
        {mdad.i
            &Saida     = "value(varquivo)"
            &Page-Size = "64"
            &Cond-Var  = "154"
            &Page-Line = "66"
            &Nom-Rel   = ""RNFENT""
            &Nom-Sis   = """SISTEMA DE CONTABILIDADE"""
            &Tit-Rel   = """NOTA FISCAL DE ENTRADA P/ PRODUTO  "" 
                            + ""   -  PERIODO "" 
                            + string(vdti,""99/99/9999"") + "" A ""
                            + string(vdtf,""99/99/9999"")"
            &Width     = "154"
            &Form      = "frame f-cabcab"}
       */

     v-i = 0.
    output to value(varquivo) page-size 0.
    put unformat skip(1)
        "PRODUTO;DESCRICAO;EMITENTE;DATA ENTRADA;N° NOTA;CFOP;"
        "TOTAL NOTA;BASE DE CALCULO;VALOR ICMS;IPI;VLR SUBS.TRIB;"
        "VALOR OUTROS;RAZAO SOCIAL;UF;"
        skip.

    for each tt-produ: delete tt-produ. end.

    vpronom = "*" + trim(vpronom) + "*".

    for each movim use-index movdat
                   where movim.movdat >= vdti
                     and movim.movdat <= vdtf
                     and movim.movtdc = 4 no-lock,
        first produ where produ.procod = movim.procod
                     and produ.pronom matches vpronom no-lock.
                     .
        find tt-produ where tt-produ.procod = movim.procod 
                      no-lock  no-error.
        if not avail tt-produ
        then do:
             create tt-produ.
             tt-produ.procod = movim.procod.
        end.     
    end.
        
    V-I = 0.

    for each tt-produ,
        each produ where produ.procod = tt-produ.procod
                no-lock
               by produ.pronom:
 
        if vcatcod >  0 and produ.catcod <> vcatcod
        then next.
        V-I = V-I + 1.
        if v-i modulo 100 = 0
        then do: 
             disp stream stela produ.procod  format ">>>>>>>>>>9" 
                  v-i format ">>>>>>9" Label "Lidos"
                    with frame fffpla 
                 centered color white/red.
            pause 0.

        end. 
      
        for each movim where movim.procod = produ.procod 
                         and movim.movtdc = 4
                         and movim.movdat >= vdti 
                         and movim.movdat <= vdtf
                            no-lock,
                 first plani where plani.etbcod = movim.etbcod
                               and plani.placod = movim.placod
                               and plani.movtdc = movim.movtdc
                                       no-lock:

                 find first forne where forne.forcod = plani.emit
                                       no-lock no-error.
                                       
                 put unformat
                     produ.procod at 1 ";"
                     produ.pronom ";"
                     plani.emit ";"
                     plani.pladat ";"
                     plani.numero ";"
                     plani.opccod ";" /* fop? */
                     plani.platot ";"
                     plani.bicms ";"
                     plani.icms ";"
                     plani.ipi ";"
                     plani.icmssubst ";"
                     plani.outras ";"
                    (if avail forne then forne.fornom else "") ";"
                    (if avail forne then forne.ufecod else "") ";"
                    skip.
                            
       end. 
       
   end.
   hide frame fffpla no-pause.
   put skip (2).

   output stream stela close.
   output close.     

   if opsys = "UNIX"
   then do:
        run visurel.p(input varquivo, input "").
   end.
   else do:
        os-command silent start value(varquivo).
   end.        

end.


