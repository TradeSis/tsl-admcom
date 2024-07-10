/* ---------------------------------------------------------------------------
*  Nome.....: reldifca.p
*  Funcao...: Relatorio de valor vendido a maior que CHP presente - Sol 15586
*  Data.....: 19/06/2007
*  Autor....: Virgínia Alencastro
--------------------------------------------------------------------------- */
{admcab.i}

def var vchar     as char  format "x(20)" no-undo.
def var iconta    as int                    no-undo.
def var varqsai   as char                   no-undo.
def var vfunc     like titulo.titvlcob      no-undo.
def var vetbcod   like estab.etbcod         no-undo.
def var vfuncod   like func.funcod          no-undo.

def var varquivo    as     char.
                                        
def var vdti      as date format "99/99/9999".  
def var vdtf      as date format "99/99/9999".   
                            
def var vnota-util    as int  format ">>>>>>9" . 
def var vvalornf      as      dec.                     
def var vvencod       like    plani.vencod.
def var vtotparvlpag  as  dec format "->>>,>>9.99". 
def var vtotparnf     as  dec format "->>>,>>9.99".
def var vtotpardif    as  dec format "->>>,>>9.99".
def var vtotpar2vlpag as  dec format "->>>,>>9.99".
def var vtotpar2nf    as  dec format "->>>,>>9.99".
def var vtotpar2dif   as  dec format "->>>,>>9.99".
def var vtotgevlpag   as  dec format "->>>,>>9.99".
def var vtotgenf      as  dec format "->>>,>>9.99".
def var vtotgedif     as  dec format "->>>,>>9.99".
                                               
def temp-table tt-cartpre 
   field seq    as int   
   field numero as int   
   field valor as dec.   
                 
                           
def temp-table  tt-titulo
        field   empcod    like    titulo.empcod 
        field   titnat    like    titulo.titnat
        field   modcod    like    titulo.modcod
        field   etbcod    like    titulo.etbcod
        field   titdtpag  like    titulo.titdtpag
        field   titnum    like    titulo.titnum
        field   titvlpag  like    titulo.titvlpag
        field   vencod    like    plani.vencod
        field   nota      like    plani.numero
        field   valornf   as      dec
        field   diferenca as      dec format "->>>,>>9.99"
        index i1
               empcod
               titnat 
               modcod
               etbcod 
               titnum 
        .
                           

 for each tt-titulo:  
   delete tt-titulo.   
 end.                 
                          
update vetbcod colon 18 with frame f1 centered side-label  
       color blue/cyan row 4 width 80.                     
       
if vetbcod = 0                                               
then display "GERAL" @ estab.etbnom no-label with frame f1.  
else do:                                                     
    find estab where estab.etbcod = vetbcod no-lock no-error.
    if not avail estab
    then do:
           message "Filial nao Cadastrada!" view-as alert-box.   
           undo.                                                   
    end.
        display estab.etbnom no-label with frame f1.             
end.                                                         

update vfuncod label "Vendedor" colon 18  with frame f1.

 if vfuncod = 0                                              
 then display "GERAL" @ func.funnom with frame f1.
 else do:                                                     
     find func where func.etbcod = vetbcod and                
          func.funcod = vfuncod no-lock no-error.  
  
     if not avail func                                        
     then do:                                                 
            message "Vendedor nao Cadastrado!" view-as alert-box.
            undo.                                                            
     end.                                                                 
     else disp func.funnom no-label with frame f1.                        
 end.                                                                     
 
 update  vdti label "Dt.Inicial"                                          
         vdtf label "Dt.Final"                                            
   with frame f-dat centered row 10 color blue/cyan side-label 
   title ("Periodo").                               
   
 /* DREBES */                                                             
    if opsys = "UNIX"                                                        
    then do:       
         assign varquivo   = "/admcom/relat/reldifchp" + string(time).
         end.                                                                     
    else do:                              
         assign varquivo   = "l:\relat\reldifchp." + string(time).         
         end.   
 
    message "Gerando Relatorio....".                             

   assign
       vtotparvlpag    = 0
       vtotparnf       = 0
       vtotpardif      = 0
       vtotpar2vlpag   = 0 
       vtotpar2nf      = 0 
       vtotpar2dif     = 0 
       vtotgevlpag     = 0
       vtotgenf        = 0
       vtotgedif       = 0
       iconta          = 0.
  
   {mdadmcab.i                                                              
   &Saida     = "value(varquivo)"                          
   &Page-Size = "64"                                                    
   &Cond-Var  = "118"                                                   
   &Page-Line = "66"                                                    
   &Nom-Rel   = ""RELDIFCA""                                             
   &Nom-Sis   = """ADMINISTRACAO"""                                     
   &Tit-Rel   = """VENDAS A MAIS QUE CH PRESENTE - PERIODO DE "" +             
                    string(vdti,""99/99/9999"") + "" A "" +      
                    string(vdtf,""99/99/9999"") "                
                 &Width     = "120"                                                               &Form      = "frame f-cabcab"}                                    form with frame flin down.                                                 
                          
   disp space "Loja:" space(2)                                                         estab.etbnom no-label with frame f-est side-label.                            put fill ("-",120) format "x(120)".                            
def var vdata as date.
for each estab where
        (if vetbcod > 0
         then estab.etbcod = vetbcod else true) no-lock:
do vdata = input vdti to input vdtf: 
for each titulo where titulo.etbcobra = estab.etbcod and
                      titulo.titdtpag >= vdata  and
                      titulo.titnat = yes and
                      titulo.modcod = "CHP" and
                      titulo.titsit = "PAG" and
                      titulo.titpar = 1
                      no-lock:
    if titulo.clifor = 0
    then next.
    if titulo.titnum = "0"
    then next.
/**                          
for each titulo use-index titnum where                       
         titulo.empcod = 19      and   
         titulo.titnat = yes     and      
         titulo.modcod = "CHP"   and        
         titulo.etbcobra = estab.etbcod and
         titulo.clifor > 0 and
         titulo.titnum > "0" and
         titulo.titpar = 1  and
         titdtpag >= input vdti and
         titdtpag <= input vdtf and
         titulo.titsit = "PAG" no-lock.
   **/
         assign vnota-util = 0.
                    
                     run p-venota-ant ( input  int(titulo.titnum),  
                                        input  titulo.etbcobra,  
                                        input  titulo.titdtpag,  
                                        output vnota-util,
                                        output vvalornf).
                    
                    
                    if vnota-util = 0 or vnota-util = ?
                    then run p-venota-new ( input  int(titulo.titnum), 
                                            input  titulo.etbcobra,
                                            input  titulo.titdtpag,
                                            output vnota-util,
                                            output vvalornf,
                                            output vvencod).

    assign iconta = iconta + 1.  
    
    find first tt-titulo where
               tt-titulo.empcod = 19      and    
               tt-titulo.titnat = yes     and    
               tt-titulo.modcod = "CHP"   and    
               tt-titulo.etbcod = titulo.etbcobra and
               tt-titulo.titnum = titulo.titnum 
               no-lock no-error.
    if not avail tt-titulo
    then do:
    assign iconta = iconta + 1.
           create tt-titulo.
           assign 
                tt-titulo.empcod = 19
                tt-titulo.titnat = yes       
                tt-titulo.modcod = "CHP"     
                tt-titulo.etbcod = titulo.etbcobra
                tt-titulo.titnum = titulo.titnum.
    end.
    assign                      
            tt-titulo.titdtpag  =  titulo.titdtpag     
            tt-titulo.titvlpag  =  titulo.titvlpag            
            tt-titulo.vencod    =  vvencod             
            tt-titulo.nota      =  vnota-util          
            tt-titulo.valornf   =  vvalornf            
            tt-titulo.diferenca =  vvalornf - tt-titulo.titvlpag.

 put screen  "Registros Processados :" + string(iconta)
             
               row 15 col 30.
 
end.
end.
end.

/******** Impressão da Temp-Table **********/

for each tt-titulo  where 
         if vfuncod = 0                      
         then true                           
         else 
              tt-titulo.vencod = vfuncod  no-lock
                break  by tt-titulo.etbcod
                       by tt-titulo.vencod 
                       by tt-titulo.titdtpag:
    
    if first-of(tt-titulo.etbcod)
    then do:
         disp 
          "Loja:"
           tt-titulo.etbcod  no-label 
           estab.etbnom no-label
          with frame f-rel1.
           
    end.
    
    if first-of(tt-titulo.vencod)
    then do:
          find func where func.etbcod = tt-titulo.etbcod and   
                func.funcod = tt-titulo.vencod no-lock no-error.
          disp
          "Vendedor:"
          tt-titulo.vencod    no-label
          func.funnom  no-label  when avail func
          with frame f-rel2.
          down with frame f-rel2.
    end.
    
          
    disp tt-titulo.titdtpag            column-label  "Data"                  
         tt-titulo.titnum              column-label  "Cartão/CH.!Presente"   
         tt-titulo.modcod              column-label  "Mod"                   
         tt-titulo.titvlpag            column-label  "Valor"                 
         tt-titulo.vencod              column-label  "Vendedor"              
         tt-titulo.nota                column-label  "Nota"   format ">>>>>>9"          tt-titulo.valornf             column-label  "Valor!Nota"            
         tt-titulo.diferenca           column-label  "Diferença"             
         with frame fa down no-box width 110.                             
           down with frame fa.                                     
                    
        assign
            vtotparvlpag    =   vtotparvlpag + tt-titulo.titvlpag 
            vtotparnf       =   vtotparnf    + tt-titulo.valornf
            vtotpardif      =   vtotpardif   + tt-titulo.diferenca
            vtotpar2vlpag   =   vtotpar2vlpag + tt-titulo.titvlpag  
            vtotpar2nf      =   vtotpar2nf   + tt-titulo.valornf   
            vtotpar2dif     =   vtotpar2dif  + tt-titulo.diferenca 
            vtotgevlpag     =   vtotgevlpag  + tt-titulo.titvlpag 
            vtotgenf        =   vtotgenf     + tt-titulo.valornf 
            vtotgedif       =   vtotgedif    + tt-titulo.diferenca.

       
        if last-of(tt-titulo.vencod)
        then do:
            vchar = "".
            disp
               vchar           at 10                                       
               "-----------"   @ vtotparvlpag   at 34                                           "-----------"   @ vtotparnf      at 62                                          "-----------"   @ vtotpardif     at 74                                          with frame ftotal-par-vend down no-box no-labels width 110.
              down with frame ftotal-par-vend.                         
       
              vchar  = "TOTAL VENDEDOR".    
            disp             
              vchar          at 10                
              vtotparvlpag   at 34                             
              vtotparnf      at 62                           
              vtotpardif     at 74                           
              with frame ftotal-par-vend down no-box no-labels width 110. 
             down with frame ftotal-par-vend.
      
             assign 
               vtotparvlpag  = 0
               vtotparnf     = 0
               vtotpardif    = 0.
         end.  

        if last-of(tt-titulo.vencod) and
           last-of (tt-titulo.etbcod)                                   
        then do:                                                          
              vchar = "".                                                   
              disp                                                          
                vchar           at 10                                      
                "-----------"   @ vtotpar2vlpag   at 34                    
                "-----------"   @ vtotpar2nf      at 62                     
                "-----------"   @ vtotpar2dif     at 74                     
                with frame ftotal-par2-vend down no-box no-labels width 110.
               down with frame ftotal-par2-vend.                  
          
               vchar  = "TOTAL LOJA".                          
               disp                                                         
                   vchar          at 10                                       
                   vtotpar2vlpag   at 34                                       
                   vtotpar2nf      at 62                                       
                   vtotpar2dif     at 74                                       
                   with frame ftotal-par2-vend down no-box no-labels width 110.
                  down with frame ftotal-par2-vend.                            
               
               assign                                                      
                 vtotpar2vlpag  = 0                                         
                 vtotpar2nf     = 0                                         
                 vtotpar2dif    = 0.                                        
        end.                                                           
end.

        vchar = "".                                
        disp                                       
            vchar           at 10                 
            "-----------"   @ vtotgevlpag   at 34
            "-----------"   @ vtotgenf      at 62
            "-----------"   @ vtotgedif     at 74 
        with frame ftotal-ger down no-box no-labels width 110.
            down with frame ftotal-ger.                         


     vchar  = "TOTAL GERAL".                                      
     disp
         vchar          at 10
         vtotgevlpag    at 34
         vtotgenf       at 62
         vtotgedif      at 74
     with frame ftotal-ger down no-box no-labels width 110. 
       down with frame ftotal-ger.
                                      
output close.
 
if opsys = "UNIX"                                         
then do:
          run visurel.p (input varquivo, input "").
end.

if opsys <> "UNIX"                                         
then do:
        {mrod.i}. 
end.

/************ Procedures *************/
/*************************************/

procedure p-venota-new:

    def input  parameter p-numerocart as int.
    def input  parameter p-etbcobra   as int.  
    def input  parameter p-data       as date format "99/99/9999".
    def output parameter p-nota-util  like plani.numero.
    def output parameter p-valor-nf   like plani.platot.
    def output parameter p-vencod     like plani.vencod.

    def var vqtdcart       as int.
    def var vconta         as int.
    def var vachatextonum  as char.
    def var vachatextoval  as char.
    def var vvalor-cartpre as dec.
    def var vlcartpres     as dec.

    for each tt-cartpre. 
       delete tt-cartpre. 
    end.

    assign vqtdcart = 0 
           vconta   = 0 
           vachatextonum = "" 
           vachatextoval = "" 
           vvalor-cartpre = 0
           p-valor-nf = 0 
           p-nota-util = 0. 
           
    for each plani use-index pladat where plani.movtdc = 5
                     and plani.etbcod = p-etbcobra
                     and plani.pladat = p-data no-lock:
                     
        if plani.notobs[3] <> "" 
        then do: 
            if acha("QTDCHQUTILIZADO",plani.notobs[3]) <> ?  
            then vqtdcart = int(acha("QTDCHQUTILIZADO",plani.notobs[3])).
                    
            if vqtdcart > 0  
            then do:  
                do vconta = 1 to vqtdcart:   
                    vachatextonum = "".  
                    vachatextonum = "NUMCHQPRESENTEUTILIZACAO"  
                                  + string(vconta).
        
                    vachatextoval = "".  
                    vachatextoval = "VALCHQPRESENTEUTILIZACAO"  
                                  + string(vconta).

                    if acha(vachatextonum,plani.notobs[3]) <> ? and
                       acha(vachatextoval,plani.notobs[3]) <> ? 
                    then do:  
                        if int(acha(vachatextonum,plani.notobs[3])) =
                           p-numerocart
                        then assign
                             p-nota-util = plani.numero
                             p-valor-nf = /***(if plani.biss > 0
                                           then plani.biss
                                           else plani.platot)***/
                                           plani.platot
                             p-vencod = plani.vencod.
                    end.
                end. 
            end.
        end.
    end.
end procedure.

procedure p-venota-ant:
    def input  parameter p-numerocart as int.
    def input  parameter p-etbcobra   as int.
    def input  parameter p-data       as date format "99/99/9999".
    def output parameter p-nota-util  like plani.numero.
    def output parameter p-valor-nf    like plani.platot.
    
    def var vqtdcart       as int.
    
    def var vconta         as int.
    def var vachatextonum  as char.
    def var vachatextoval  as char.
    def var vvalor-cartpre as dec.
    def var vlcartpres     as dec.

    for each tt-cartpre. delete tt-cartpre. end.

    assign vqtdcart = 0 
           vconta   = 0 
           vachatextonum = "" 
           vachatextoval = "" 
           vvalor-cartpre = 0
           p-valor-nf = 0
           p-nota-util = 0. 
           
    for each plani use-index pladat where plani.movtdc = 5
                     and plani.etbcod = p-etbcobra
                     and plani.pladat = p-data no-lock:
                     
        if plani.notobs[3] <> "" 
        then do:  
            vachatextonum = "".   
            vachatextonum = "NUMCHQPRESENTEUTILIZACAO".
        
            if acha(vachatextonum,plani.notobs[3]) <> ?
            then do:   
                if int(acha(vachatextonum,plani.notobs[3])) = p-numerocart
                then assign 
                        p-nota-util = plani.numero 
                        p-valor-nf = /***(if plani.biss > 0
                                      then plani.biss
                                      else plani.platot)***/ plani.platot.

            end.
        end.
    end.
end procedure.





