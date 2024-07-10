/* ---------------------------------------------------------------------------
*  Nome.....: etqmal1a.p
*  Funcao...: Monta etiquetas mala-direta em 3 colunas
*  Data.....: 05/05/2006
*  Autor....: Gerson Mathias
--------------------------------------------------------------------------- */

def var varqbat     as char form "x(100)"      init ""        no-undo.
def var vcaminho    as char form "x(80)"       init ""        no-undo.
def var vporta      as char form "x(80)"       init ""        no-undo.
def var pag01       as logi                    init yes       no-undo.

def var lEtiqueta   as logi form "Sim/Nao"     init no        no-undo.
def var lEntrada    as logi                    init yes       no-undo.
def var cexten      as char form "x(03)"       init ""        no-undo.
def var cpath       as char form "x(30)"       init ""        no-undo.


def var iquant      as inte   form ">>>>>9"    init 0         no-undo.
def var itot        as inte   form ">>>>>9"    init 0         no-undo.
def var ietiqueta   as inte   form ">>>>>9"    init 0         no-undo.
def var icol        as inte   form "9"         init 0         no-undo.

def var i-col1      as inte   form "999"       init 006       no-undo.
def var i-col2      as inte   form "999"       init 049       no-undo.
def var i-col3      as inte   form "999"       init 060       no-undo.
def var ct-cont     as inte                                   no-undo.

def var varquivo    as char.
def var varqsai     as char   form "x(78)"     init ""        no-undo.

 
def temp-table tt-etiqueta                                    no-undo
    field xrecid    as recid
    field codigo    as inte   form ">>>>>>>>>>999"
    field seq as int
    field cep as int format "99999999"
    field local as char.

def temp-table tt-impr                                        no-undo
    field codi      as inte   form ">>>>>>>>>>999" extent 2
    field nome      as char   form "x(40)"  extent 2
    field logr      as char   form "x(40)"  extent 2 /* Tipo e logradouro */
    field comp      as char   form "x(40)"  extent 2 /* Complemento numero */
    field outr      as char   form "x(40)"  extent 2 /* Bairro Cidade UF CEP*/
    field local     as char   form "x(40)".    

def input param table for tt-etiqueta.
def input param p-nomarq  as char. 

/* -------------------------------------------------------------------------- */
for each tt-impr:
    delete tt-impr.
end.    

assign cexten    = ".rp"
       cpath     = "c:~\temp~\". 

/* DREBES */
if opsys = "UNIX"
then do:
        assign varqsai   = "/admcom/relat/" + trim(p-nomarq) + ".rp"
               varqbat   = "/admcom/relat/etique"
               vcaminho  = "type /admcom/relat/" + trim(p-nomarq) + ".rp >"
               vporta    = "//192.168.0.93/laser".
end. 
else do:
        assign varqsai   = trim(cpath) + trim(p-nomarq) + trim(cexten)
               varqbat   = trim(cpath) + "etique.bat"
               vcaminho  = "type " + trim(cpath) + trim(p-nomarq) + ".rp > "
               vporta    = "\\ws-mat-crm-01\HPLaserJ".
end.

/* -------------------------------------------------------------------------- */
for each tt-impr:
    delete tt-impr.
end.

assign icol      = 1
       ietiqueta = 1.
  
for each tt-etiqueta no-lock ,
          first clien where
                      clien.clicod = tt-etiqueta.codigo no-lock 
                      break by seq:
           /*if avail clien
           then*/ do:
           
                disp clien.clicod label "Cliente" 
                     ietiqueta    label "Etiqueta"
                     icol         label "Coluna"
                     with side-label 1 down 3 col
                          row 12 col 15 title "MALA DIRETA"
                          frame f-mal.
                pause 0 no-message.
                
                if ietiqueta = 1 
                then create tt-impr.
                if first-of(tt-etiqueta.seq)
                then tt-impr.local = tt-etiqueta.local.
                
                assign tt-impr.codi[icol] = clien.clicod
                       tt-impr.nome[icol] = clien.clinom 
                       tt-impr.logr[icol] = clien.endereco[1]
                       
                       tt-impr.comp[icol] = "No. " +
                                            (if (string(clien.numero[1])) <> ?
                                             then (string(clien.numero[1]))
                                             else "" ) +
                                            " / " +
                                            (if (string(clien.compl[1])) <> ?
                                             then (string(clien.compl[1]))
                                             else "" ) +
                                            " - " +
                                            (if (string(clien.bairro[1])) <> ?
                                             then (string(clien.bairro[1]))
                                             else "" ) 

                       tt-impr.outr[icol] = 
                                string(tt-etiqueta.cep,"99999999") + 
                                            " " +
                                            clien.cidade[1] +
                                            " " +
                                            clien.ufecod[1].

                assign ietiqueta = ietiqueta + 1.
                if ietiqueta  = 2
                then assign icol = icol + 1.

                if ietiqueta = 3
                then do:
                        assign icol      = 1
                               ietiqueta = 1.
                end.
                if last-of(tt-etiqueta.seq)
                then assign
                        icol = 1
                        ietiqueta = 1.

           end.
end.              

hide frame f-mal.
/*
output to value(varqbat).
       put "net use lpt1:" + trim(vporta) form "x(60)"
           skip.
       put trim(vcaminho) + " " + trim(vporta) form "x(60)" 
           skip.
       put "net use lpt1:/delete"
           skip.
output close.
*/ 

output to value(varqbat).
       put "net use lpt1:" + trim(vporta) form "x(60)"
           skip.
       put trim(vcaminho) + " " + trim(vporta) form "x(60)" 
           skip.
       put "net use lpt1:/delete"
           skip.
output close.
 
     
/* ------------------------------------------------------------------------ */
run pi-geraarq.  /* Gera o arquivo */
/* ------------------------------------------------------------------------ */

assign lEtiqueta = no.

disp varqsai no-label form "x(60)"
     with frame f-2 side-labels 1 col width 80
          row 15 title "CONFIRMA IMPRESSAO".
          
update lEtiqueta label "Imprime Etiqueta "
       with frame f-2 side-labels 1 col width 80
            row 15 title "CONFIRMA IMPRESSAO".
                
if lEtiqueta = yes
then do:
        dos silent value(varqbat).
end. 

/* TESTE CUSTOM */ 
/*run visurel.p (input trim(varqsai),"").*/

/* ------------------------------------------------------------------------ */

procedure pi-geraarq:

/* teste tela
for each tt-impr:
    disp tt-impr.nome[1] form "x(20)"
         tt-impr.nome[2] form "x(20)" with 2 col frame fff.
         
end.
*/

output to value(varqsai).
           
assign ct-cont    = 0.

     for each tt-impr no-lock:
                
                assign ct-cont = ct-cont + 1.
                
                if ct-cont = 1
                then do:
                        if pag01 = yes
                        then do:
                                put skip(2).
                                assign pag01 = no.
                        end.
                        else do:
                                put skip(2).
                        end.            
                end.
                /*
                put control chr(027) + chr(040) + chr(115) + chr(15) + chr(072).
                */
                if tt-impr.local <> ""
                then do:
                    put tt-impr.local format "x(40)" at i-col1 skip(5).
                    ct-cont = ct-cont + 2.
                end.
                
                put 
                    tt-impr.nome[1]  form "x(37)"     at i-col1
                    tt-impr.nome[2]  form "x(37)"     at i-col2
                    tt-impr.logr[1]  form "x(37)"     at i-col1
                    tt-impr.logr[2]  form "x(37)"     at i-col2
                    tt-impr.comp[1]  form "x(37)"     at i-col1
                    tt-impr.comp[2]  form "x(37)"     at i-col2
                    tt-impr.outr[1]  form "x(37)"     at i-col1
                    tt-impr.outr[2]  form "x(37)"     at i-col2
                    skip(2).
                
                if ct-cont = 10
                then do:
                        assign ct-cont = 0.
                        page.
                        put control chr(27) + 'E'.
                end.
      end.
     
    output close.

end procedure.

/* ------------------------------------------------------------------------ */
/*  ANTIGO *******************
****************************************************************************    

def var varqbat     as char form "x(100)"      init ""        no-undo.
def var vcaminho    as char form "x(80)"       init ""        no-undo.
def var vporta      as char form "x(80)"       init ""        no-undo.
def var pag01       as logi                    init yes       no-undo.

def var lEtiqueta   as logi form "Sim/Nao"     init no        no-undo.
def var lEntrada    as logi                    init yes       no-undo.
def var cexten      as char form "x(03)"       init ""        no-undo.
def var cpath       as char form "x(30)"       init ""        no-undo.


def var iquant      as inte   form ">>>>>9"    init 0         no-undo.
def var itot        as inte   form ">>>>>9"    init 0         no-undo.
def var ietiqueta   as inte   form ">>>>>9"    init 0         no-undo.
def var icol        as inte   form "9"         init 0         no-undo.

def var i-col1      as inte   form "999"       init 005       no-undo.
def var i-col2      as inte   form "999"       init 032       no-undo.
def var i-col3      as inte   form "999"       init 060       no-undo.
def var ct-cont     as inte                                   no-undo.

def var varquivo    as char.
def var varqsai     as char   form "x(78)"     init ""        no-undo.

 
def temp-table tt-etiqueta                                    no-undo
    field xrecid    as recid
    field codigo    as inte   form ">>>>>>>>>>999"
    field seq as int
    field cep as int format "99999999".

def temp-table tt-impr                                        no-undo
    field codi      as inte   form ">>>>>>>>>>999" extent 3
    field nome      as char   form "x(40)"  extent 3
    field logr      as char   form "x(40)"  extent 3 /* Tipo e logradouro */
    field comp      as char   form "x(40)"  extent 3 /* Complemento numero */
    field outr      as char   form "x(40)"  extent 3 /* Bairro Cidade UF CEP*/.
def input param table for tt-etiqueta.
def input param p-nomarq  as char. 

/* -------------------------------------------------------------------------- */
assign cexten    = ".rp"
       cpath     = "c:~\temp~\". 

/* DREBES */
if opsys = "UNIX"
then do:
        assign varqsai   = "/admcom/relat/" + trim(p-nomarq) + ".rp"
               varqbat   = "/admcom/relat/etique"
               vcaminho  = "type /admcom/relat/" + trim(p-nomarq) + ".rp >"
               vporta    = "//192.168.0.2/laser".
end. 
else do:
        assign varqsai   = trim(cpath) + trim(p-nomarq) + trim(cexten)
               varqbat   = trim(cpath) + "etique.bat"
               vcaminho  = "type " + trim(cpath) + trim(p-nomarq) + ".rp > "
               vporta    = "\\ws-mat-crm-02\HPLaserJ".
end.

/* -------------------------------------------------------------------------- */
for each tt-impr:
    delete tt-impr.
end.

assign icol      = 1
       ietiqueta = 1.
  
for each tt-etiqueta no-lock by seq:

           find first clien where
                      clien.clicod = tt-etiqueta.codigo no-lock no-error.
           if avail clien
           then do:
           
                disp clien.clicod label "Cliente" 
                     ietiqueta    label "Etiqueta"
                     icol         label "Coluna"
                     with side-label 1 down 3 col
                          row 12 col 15 title "MALA DIRETA"
                          frame f-mal.
                pause 0 no-message.
                
                create tt-impr.
                assign tt-impr.codi[icol] = clien.clicod
                       tt-impr.nome[icol] = clien.clinom
                       tt-impr.logr[icol] = clien.endereco[1]
                       tt-impr.comp[icol] = clien.compl[1] +
                                            " " +
                                            string(clien.numero[1]) +
                                            " - " +
                                            clien.bairro[1]
                       tt-impr.outr[icol] = clien.cidade[1] +
                                            " " +
                                            clien.ufecod[1] +
                                            " " +  
                                            string(vcep,"99999999")
                                            .

                assign icol      = icol + 1
                       ietiqueta = ietiqueta + 1.

                if icol = 3
                then assign icol = 1.                             
           end.
end.              

hide frame f-mal.
/*
output to value(varqbat).
       put "net use lpt1:" + trim(vporta) form "x(60)"
           skip.
       put trim(vcaminho) + " " + trim(vporta) form "x(60)" 
           skip.
       put "net use lpt1:/delete"
           skip.
output close.
*/ 

output to value(varqbat).
       put "net use lpt1:" + trim(vporta) form "x(60)"
           skip.
       put trim(vcaminho) + " " + trim(vporta) form "x(60)" 
           skip.
       put "net use lpt1:/delete"
           skip.
output close.
 
     
/* ------------------------------------------------------------------------ */
run pi-geraarq.  /* Gera o arquivo */
/* ------------------------------------------------------------------------ */

assign lEtiqueta = no.

disp varqsai no-label form "x(60)"
     with frame f-2 side-labels 1 col width 80
          row 15 title "CONFIRMA IMPRESSAO".
          
update lEtiqueta label "Imprime Etiqueta "
       with frame f-2 side-labels 1 col width 80
            row 15 title "CONFIRMA IMPRESSAO".
                
if lEtiqueta = yes
then do:
        dos value(varqbat).
end. 

/* TESTE CUSTOM */ 
/*run visurel.p (input trim(varqsai),"").*/

/* ------------------------------------------------------------------------ */

procedure pi-geraarq:

output to value(varqsai).
           
assign ct-cont    = 0.

     for each tt-impr no-lock:
                
                assign ct-cont = ct-cont + 1.
                
                if ct-cont = 1
                then do:
                        if pag01 = yes
                        then do:
                                put skip(4).
                                assign pag01 = no.
                        end.
                        else do:
                                put skip(6).
                        end.            
                end.
                
                put control chr(027) + chr(040) + chr(115) + chr(15) + chr(072).
                
                put 
                    tt-impr.nome[1]       at i-col1
                    tt-impr.nome[2]       at i-col2
                    tt-impr.nome[3]       at i-col3
                    tt-impr.logr[1]       at i-col1
                    tt-impr.logr[2]       at i-col2
                    tt-impr.logr[3]       at i-col3
                    tt-impr.comp[1]       at i-col1
                    tt-impr.comp[2]       at i-col2
                    tt-impr.comp[3]       at i-col3     
                    tt-impr.outr[1]       at i-col1
                    tt-impr.outr[2]       at i-col2
                    tt-impr.outr[3]       at i-col3 
                    skip(2).
                
                if ct-cont = 10
                then do:
                        assign ct-cont = 0.
                        page.
                        put control chr(27) + 'E'.
                end.
      end.
     
    output close.

end procedure.

/* ------------------------------------------------------------------------ */

  
     
*/     
