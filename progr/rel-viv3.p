{admcab.i new}

{setbrw.i}

def temp-table tt-relat
field etbcod      as integer   
field opecod      as integer
field openom      as char
field tipviv      as integer
field provivnom   as char
field codviv      as integer
field planomviv   as char
field fincod      as integer
field finnom      as char
field procod      as integer
field pronom      as char      
field movtot      as dec      
field planum like plani.numero
field imei        as char
index idx01 etbcod.

def var vopecod as integer.
def var vtipviv as integer.
def var vcodviv as integer.
def var vfincod as integer.
def var vdti as date.
def var vdtf as date.
def var vtotal-filial as dec.
def var vtotal-geral  as dec.

def var varquivo as char.

def temp-table tt-planos
    field codviv as int format ">>>9"
    index ch-codviv codviv.

form
    a-seelst format "x" column-label "*"
    estab.etbcod
    estab.etbnom
        with frame f-nome
             centered down title "LOJAS"
             color withe/red overlay.

def var v-cod as int.
def var v-cont as int.
def buffer bestab for estab.

def temp-table tt-lj  like estab.
def var vdata as date.

assign sresp = false.
                
update sresp label "Seleciona Filiais?" with frame f-plaviv.

if sresp
then do:
                
    bl_sel_filiais:
    repeat:
                    
        hide frame f-inclui. 

        run p-seleciona-filiais.

        if keyfunction(lastkey) = "end-error"
        then leave bl_sel_filiais.
                                     
    end.

end.

display "*** Gerando todas as Filiais ***" skip
                with frame f-plaviv.

pause.                    
                    
update vopecod with frame f-plaviv.
                                       
find operadoras where
     operadoras.opecod = vopecod no-lock no-error.
                        
disp vopecod label "Operadora........." format ">>>9"
                    operadoras.openom format "x(10)"  no-label 
                              when avail operadoras  skip
                                  with frame f-plaviv.
                              pause 0.

update vtipviv with frame f-plaviv.

disp
   vtipviv label "Serviço..........." format ">>>9"
               with frame f-plaviv.

if vtipviv > 0
then do:
                        
    find promoviv where promoviv.opecod = vopecod
                    and promoviv.tipviv = vtipviv
                                no-lock no-error.
    if not avail promoviv
    then do:
           message "Serviço não encontrado.".    pause.
           undo.
    end.
end.
                                            
disp promoviv.provivnom no-label when avail promoviv
               with frame f-plaviv.

pause 0.

update vcodviv with frame f-plaviv.
                                                       
disp vcodviv label "Plano............."  format ">>>9"
         with frame f-plaviv centered side-labels.


find planoviv where
     planoviv.codviv = vcodviv no-lock no-error.

if not avail planoviv
then do:
    message "Plano nao encontrado.". pause.
    undo.
end.
disp planoviv.planomviv no-label skip with frame f-plaviv .

update vfincod with frame f-plaviv.

display vfincod label "Plano de Pagamento" format ">>>>9"
          with frame f-plaviv centered side-labels.
                 
find first finan where finan.fincod = vfincod no-lock no-error.
if not avail finan
then do:
    message "Plano de pagamento nao encontrado.". pause.
    undo.
end.
display finan.finnom no-label skip with frame f-plaviv .        


update vdti label "Periodo de........" format "99/99/9999"  with frame f-plaviv.
    
display " a " with frame f-plaviv.

update  vdtf no-label format "99/99/9999"  with frame f-plaviv.
    
    for each estab no-lock:

        release tt-lj.
        if can-find (first tt-lj)
        then do:
         
            find first tt-lj where tt-lj.etbcod = estab.etbcod no-lock no-error.
            if not avail tt-lj
            then next.

        end.
        
        disp estab.etbcod label "Loja"
             with frame f-mostra centered side-labels. pause 0.
             
        do vdata = vdti to vdtf:
            disp vdata no-label
                 with frame f-mostra. pause 0.
        
            for each plani where plani.movtdc = 5
                             and plani.etbcod = estab.etbcod
                             and plani.pladat = vdata no-lock:
                
                if acha("TIPVIV",plani.notobs[3]) = "" then next.             
                             
                release finan. 
                find first finan where finan.fincod = plani.pedcod
                            no-lock no-error. 
  
                if vfincod <> 0 and plani.pedcod <> vfincod
                then next.
                             
/**
                if vtipviv <> 0
                then if int(acha("TIPVIV",plani.notobs[3])) <> vtipviv
                     then next.
                
                if vcodviv <> 0
                then if int(acha("CODVIV",plani.notobs[3])) <> vcodviv
                     then next.
                 
                if not v-pula4-18
                then do:
                    if int(acha("TIPVIV",plani.notobs[3])) = 4 and
                       int(acha("CODVIV",plani.notobs[3])) = 18
                    then next.
                end.

                if vopecod <> 0
                then do:
                    find promoviv where promoviv.opecod = vopecod
                                    and promoviv.tipviv =
                                     int(acha("TIPVIV",plani.notobs[3]))
                                    no-lock no-error.
                    if not avail promoviv
                    then next.
                end.
**/                
                for each movim where movim.etbcod = plani.etbcod
                                 and movim.placod = plani.placod
                                 and movim.movdat = plani.pladat
                                 and movim.movtdc = plani.movtdc no-lock:

                    
                    if movim.ocnum[8] = 0
                        and movim.ocnum[9] = 0 
                    then next.    
                    
                    release promoviv.
                    find first promoviv where promoviv.tipviv = movim.ocnum[8]
                                     no-lock no-error.
                    if not avail promoviv
                    then next.

                    release planoviv.
                    find first plaviv where plaviv.tipviv = movim.ocnum[8]
                                        and plaviv.codviv = movim.ocnum[9]
                                                    no-lock no-error.
                    
                    if not avail plaviv then next.                    
                    
                    
                    find operadoras where
                         operadoras.opecod = promoviv.opecod no-lock no-error.
                    if not avail operadoras 
                    then next.
                    
                    /****/
                    find produ where produ.procod = movim.procod no-lock no-err~or.
                    
                    if vtipviv <> 0
                    then if movim.ocnum[8] <> vtipviv
                         then next.
                         
                    release planoviv.
                    find first planoviv where
                               planoviv.codviv = movim.ocnum[9]
                                    no-lock no-error.
                              
                    if not avail planoviv
                    then next.
                         
                 
                    find first tt-planos no-error.
                    if not avail tt-planos
                    then do:  
                        if vcodviv <> 0 
                        then if movim.ocnum[9] <> vcodviv 
                             then next.
                    end.
                    else do:
                        find first tt-planos where
                                   tt-planos.codviv = movim.ocnum[9] no-error.
                        if not avail tt-planos
                        then next. 
                    end.
                    
                    if vopecod <> 0
                    then do: 
                        if vopecod = 2 
                        then do:
                        
                            if produ.fabcod <> 104655
                            then next.
                        
                        end.
                        else do:
                        find promoviv where promoviv.opecod = vopecod
                                        and promoviv.tipviv = movim.ocnum[8]
                                     no-lock no-error.
                        if not avail promoviv
                        then next.
                    end. end.
                     
                     
                    /****/
                    
                    find produ where
                         produ.procod = movim.procod no-lock no-error.
                         
                    if not avail produ
                    then next.
                    
                    
                    
                    /*
                    display produ.clacod. pause 0.
                    
                    if produ.clacod <> 100 and
                       produ.clacod <> 101 and
                       produ.clacod <> 102 and 
                       produ.clacod <> 103 and
                       produ.clacod <> 106 and
                       produ.clacod <> 107 and
                       produ.clacod <> 191 and
                       produ.clacod <> 104 and
                       produ.clacod <> 192 and
                       produ.clacod <> 193 and
                       produ.clacod <> 108 and
                       produ.clacod <> 109 and
                       produ.clacod <> 201
                    then next.
                      */
                    /*
                    
                    find first tt-cel where
                               tt-cel.etbcod = movim.etbcod
                           and tt-cel.procod = movim.procod
                           and tt-cel.placod = movim.placod
                           no-error.
                    if not avail tt-cel
                    then do:
                        find plaviv where 
                             plaviv.tipviv = movim.ocnum[8]
                         and plaviv.codviv = movim.ocnum[9]
                         and plaviv.procod = produ.procod no-lock no-error.
                         
                        create tt-cel.
                        assign tt-cel.etbcod = movim.etbcod
                               tt-cel.etbnom = estab.etbnom
                               tt-cel.placod = movim.placod
                               tt-cel.procod = movim.procod
                               tt-cel.pronom = produ.pronom
                               tt-cel.tipviv = movim.ocnum[8]
                               tt-cel.codviv = movim.ocnum[9]
                               tt-cel.numero = plani.numero
                               tt-cel.pladat = plani.pladat
                               tt-cel.movpc  = movim.movpc
                               tt-cel.movqtm  = movim.movqtm
                               tt-cel.pretab = 
                              (if int(acha("PRETAB",plani.notobs[3])) <> ?
                               then int(acha("PRETAB",plani.notobs[3]))
                               else (if avail plaviv
                                     then plaviv.pretab
                                     else 0 ))
                               tt-cel.prepro =
                              (if int(acha("PREPRO",plani.notobs[3])) <> ?
                               then int(acha("PREPRO",plani.notobs[3]))
                               else (if avail plaviv
                                     then plaviv.prepro
                                     else 0)).

                            tt-cel.vencod = plani.vencod.
                             
                            if tt-cel.tipviv <> ? and tt-cel.codviv <> ?
                            then do:
                               if produ.clacod = 102
                               then tt-cel.tipo = "PRE".
                               else do:
                                   if produ.clacod = 101
                                   then do:
                                       if tt-cel.tipviv = 4 and
                                          tt-cel.codviv = 18
                                       then tt-cel.tipo = "POS".
                                       else tt-cel.tipo = "POS->PRE".
                                   end.
                               end.
                               
                               if tt-cel.codviv = 1001 or
                                  tt-cel.codviv = 1002
                               then tt-cel.tipo = "PRE".
                               if tt-cel.codviv = 1003 or
                                  tt-cel.codviv = 1004 or
                                  tt-cel.codviv = 1005
                               then tt-cel.tipo = "POS".

                               
                               find first tbprice where 
                                          tbprice.etb_venda  = movim.etbcod
                                      and tbprice.data_venda = plani.pladat
                                      and tbprice.nota_venda = plani.numero  
                                          no-lock no-error.
                               if avail tbprice then    
                assign tt-cel.numhab = if acha("CEL-NUMERO",tbprice.char2) = ? ~then "" else acha("CEL-NUMERO",tbprice.char2).
                               else 
                                     tt-cel.numhab = "".
                               
                            end. 
                               
                               
                               
                    end.
                    
                    */
                    
                   
                    create tt-relat.
                    assign tt-relat.etbcod = plani.etbcod
                           tt-relat.opecod = promoviv.opecod
                           tt-relat.openom = operadoras.openom
                           tt-relat.tipviv = movim.ocnum[8]
                           tt-relat.provivnom = promoviv.provivnom
                           tt-relat.codviv = movim.ocnum[9] 
                           tt-relat.planomviv = planoviv.planomviv
                           tt-relat.fincod = plani.pedcod
                           tt-relat.procod = movim.procod
                           tt-relat.pronom = produ.pronom
                           tt-relat.movtot =
                                (movim.movqtm * movim.movpc) - movim.movdes
                           tt-relat.planum = plani.numero.
                     
                     if avail finan
                     then do:
                     
                         assign tt-relat.finnom = finan.finnom.
                     
                     end.
                           
                     find first tbprice where tbprice.etb_venda = plani.etbcod
                                          and tbprice.nota_venda = plani.numero
                                          and tbprice.data_venda = plani.pladat
                                             no-lock no-error.
                     if available tbprice
                     then do:
                   
                         assign tt-relat.imei = tbprice.serial.

                     end.
                     
                     
                     
                end.
            end.
        end.             
    end.
        
    if opsys = "UNIX"
    then varquivo = "../relat/rel-viv3." + string(time).
    else varquivo = "..\relat\rel-viv3." + string(time).
 
    {mdadmcab.i 
        &Saida     = "value(varquivo)"
        &Page-Size = "63"
        &Cond-Var  = "130"
        &Page-Line = "66"
        &Nom-Rel   = ""rel-vivo""
        &Nom-Sis   = """SISTEMA ADMINISTRATIVO  SAO JERONIMO"""  
        &Tit-Rel   = """LISTAGEM DE CELULARES VENDIDOS - DE "" 
                   + string(vdti,""99/99/9999"") + "" A ""
                   + string(vdtf,""99/99/9999"")"
        &Width     = "225"
        &Form      = "frame f-cabcab"}

        assign vtotal-filial = 0
               vtotal-geral = 0.
        
        
        for each tt-relat use-index idx01 break by tt-relat.etbcod:
                 
            assign vtotal-filial = vtotal-filial + tt-relat.movtot
                   vtotal-geral = vtotal-geral + tt-relat.movtot.

            display
            tt-relat.etbcod format ">>>9" label "Filial"
            tt-relat.opecod format ">9"   label "Cod"
            tt-relat.openom format "x(15)" label "Operadora"
            tt-relat.tipviv format ">>>>9" label "Cod"
            tt-relat.provivnom format "x(20)" label "Serviço"
            tt-relat.codviv format ">>>>>>>>>9" label "Cod"
            tt-relat.planomviv format "x(20)"   label "Plano"
            tt-relat.fincod format ">>>>>9" label "Cod"
            tt-relat.finnom format "x(30)"  label "Plano de Pagamento"
            tt-relat.procod format ">>>>>>>>9"  label "Cod"
            tt-relat.pronom format "x(40)"      label "Produto"
            tt-relat.movtot format "->>>,>>>,>>>,>>9.99" Label "Valor Venda"
            tt-relat.planum format ">>>>>>>>>>>>>>>>9" label "NF Venda"
            tt-relat.imei                              label "IMEI"    
             skip with width 225.
            
            if last-of(tt-relat.etbcod)
            then do:
                    
                put fill ("-",225) format "x(225)" skip
                    "Total Filial " tt-relat.etbcod format ">>>>9"
                    ": "
                    vtotal-filial format "->>>,>>>,>>9.99" skip
                    fill ("-",225) format "x(225)"  skip
                  skip.    
                  
                assign vtotal-filial = 0.  
                    
            end.        
                   
        end.

                    
        put fill ("-",225) format "x(225)" skip
            "Total Geral:        "
            vtotal-geral format "->>>,>>>,>>9.99" skip
            fill ("-",225) format "x(225)"  skip
            fill ("-",225) format "x(225)" skip
                  skip.    

    output close.
        
    if opsys = "UNIX"
    then do:
        run visurel.p (input varquivo,
                       input "").
    end.                       
    else do:
        {mrod.i}.
    end.

procedure p-seleciona-filiais:
            
{sklcls.i
    &File   = estab
    &help   = "                ENTER=Marca F4=Retorna F8=Marca Tudo"
    &CField = estab.etbnom    
    &Ofield = " estab.etbcod"
    &Where  = " estab.etbcod <= 200"
    &noncharacter = /*
    &LockType = "NO-LOCK"
    &UsePick = "*"          
    &PickFld = "estab.etbcod" 
    &PickFrm = "99999" 
    &otherkeys1 = "
        if keyfunction(lastkey) = ""CLEAR""
        then do:
            V-CONT = 0.
            for each bestab where bestab.etbcod <= 200 no-lock:
                a-seelst = a-seelst + "","" + string(bestab.etbcod,""99999"").
                v-cont = v-cont + 1.
            end.
            message ""                         SELECIONADAS "" 
            V-CONT ""FILIAIS                                   ""
            .
                         a-seeid = -1.
            a-recid = -1.
            next keys-loop.
        end. "
    &Form = " frame f-nome" 
}. 

hide frame f-nome.
v-cont = 2.             
repeat :
    v-cod = 0.
    v-cod = int(substr(a-seelst,v-cont,5)).
    v-cont = v-cont + 6.
    if v-cod = 0
    then leave.
    create tt-lj.
    tt-lj.etbcod = v-cod.
end.


end.
