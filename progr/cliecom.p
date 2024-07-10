def input parameter vrow-clien as rowid.

def var vlog-resp as logical.
def var esqcom3 as char format "x(12)" extent 2
                       initial ["Alteracao","Voltar"].
def var esqpos3 as int.

def buffer    clien   for clien.
def buffer bf-cliecom for cliecom.

def temp-table tt-cliecom like cliecom.

form
    tt-cliecom.clicod        format ">>>>>>>>>>9" colon 18     
    tt-cliecom.tippes   label "Pessoa"
     skip
    tt-cliecom.clinom        format "x(50)"       colon 18      skip
    tt-cliecom.RSocial       format "x(50)"       colon 18   
       label "Razao Social" skip
    tt-cliecom.cpfcgc        format "x(14)"             colon 18  skip   
    tt-cliecom.ciinsc        format "x(22)"             colon 18  skip 
    tt-cliecom.email         format "x(37)"             colon 18  skip
    tt-cliecom.dtnasc                                   colon 18  skip
    tt-cliecom.sexo                               colon 18   
    tt-cliecom.estciv                             colon 50      skip
    tt-cliecom.mae                                colon 18      skip
    tt-cliecom.conjuge                            colon 18      skip
    tt-cliecom.foneres                            colon 18     
    tt-cliecom.fonecom                            colon 50      skip
    tt-cliecom.cel                                colon 18      skip
    tt-cliecom.refnome                            colon 18      skip
    tt-cliecom.reftel                             colon 18      skip
    tt-cliecom.senhacartao                        colon 25      
    tt-cliecom.envpromo    label "Env. Promo/Novid"     colon 60  skip
            with frame f-cliente-01 width 80 row 5 1 down
            title "Informacoes Pessoais"
            OVERLAY side-labels color black/cyan.

form
    tt-cliecom.cep                                colon 15      skip
    tt-cliecom.endereco                           colon 15      skip
    tt-cliecom.numero                             colon 15      skip
    tt-cliecom.compl                              colon 15      skip
    tt-cliecom.bairro                             colon 15      skip
    tt-cliecom.cidade                             colon 15      
    tt-cliecom.ufecod                             colon 52      skip
            with frame f-cliente-02 width 60 row 5
            title "Endereco 1" 
            OVERLAY side-labels color black/cyan.

form
    tt-cliecom.cep2                               colon 15      skip
    tt-cliecom.endereco2                          colon 15      skip
    tt-cliecom.numero2                            colon 15      skip
    tt-cliecom.compl2                             colon 15      skip
    tt-cliecom.bairro2                            colon 15      skip
    tt-cliecom.cidade2                            colon 15 
    tt-cliecom.ufecod2                            colon 52      skip
            with frame f-cliente-03 width 60 row 14
            title "Endereco 2"
            side-labels color black/cyan.

form esqcom3
     with frame f-com3
     row 3 no-box no-labels side-labels column 1.

pause 0.

disp esqcom3 with frame f-com3.

pause 0.

find clien where rowid(clien) = vrow-clien no-lock no-error.

if not avail clien
then return.

find last cliecom where cliecom.clicod = clien.clicod no-lock no-error.
 
if not avail cliecom
then do:

    run mensagem.p (input-output vlog-resp,
                    input "   Este cliente não possui cadastro  " +
                          "      no E-Commerce.    " +
                          "                          " +
                          "                           " +
                          "         Deseja cadastra-lo? ",
                    input "",
                    input " Sim ",
                    input " Nao ").
                    
    if not vlog-resp
    then return.                
    else do:

        create tt-cliecom.
        
        run p-update-tt-cliecom.

        create cliecom.
        
        buffer-copy tt-cliecom to cliecom no-error.

    end.
 
end.
else do:

    create tt-cliecom.
    buffer-copy cliecom to tt-cliecom no-error.

end.

pause 0.

display
    tt-cliecom.clicod       
    tt-cliecom.tippes
    tt-cliecom.clinom 
    tt-cliecom.RSocial        
    tt-cliecom.cpfcgc 
    tt-cliecom.ciinsc      
    tt-cliecom.email        
    tt-cliecom.dtnasc       
    tt-cliecom.sexo         
    tt-cliecom.estciv
    tt-cliecom.mae          
    tt-cliecom.conjuge
    tt-cliecom.foneres
    tt-cliecom.fonecom
    tt-cliecom.cel
    tt-cliecom.refnome
    tt-cliecom.reftel 
   /* tt-cliecom.senhacartao */
    tt-cliecom.envpromo
        with frame f-cliente-01. 
                
display       
    tt-cliecom.cep          
    tt-cliecom.endereco     
    tt-cliecom.numero    
    tt-cliecom.compl        
    tt-cliecom.bairro       
    tt-cliecom.cidade       
    tt-cliecom.ufecod with frame f-cliente-02.
                          
  display                        
    tt-cliecom.cep2
    tt-cliecom.endereco2
    tt-cliecom.numero2
    tt-cliecom.compl2
    tt-cliecom.bairro2
    tt-cliecom.cidade2
    tt-cliecom.ufecod2
with frame f-cliente-03.
                                     
choose field esqcom3 with frame
                               f-com3.

if frame-index = 1
then do:
    
    run p-update-tt-cliecom.
    
    find bf-cliecom where rowid(bf-cliecom) = rowid(cliecom) exclusive-lock no-error.

    buffer-copy tt-cliecom to bf-cliecom no-error.

end.
else if frame-index = 2
then do:

   return .

end.

procedure p-update-tt-cliecom:
                 
    update tt-cliecom.clicod
           tt-cliecom.clinom
           tt-cliecom.RSocial
           tt-cliecom.cpfcgc
           tt-cliecom.ciinsc
           tt-cliecom.email
           tt-cliecom.dtnasc
           tt-cliecom.sexo
           tt-cliecom.estciv
           tt-cliecom.mae
           tt-cliecom.conjuge
           tt-cliecom.foneres
           tt-cliecom.fonecom
           tt-cliecom.cel
           tt-cliecom.refnome
           tt-cliecom.reftel
           tt-cliecom.senhacartao
           tt-cliecom.envpromo
                  with frame f-cliente-01.
                   
    update tt-cliecom.cep
           tt-cliecom.endereco
           tt-cliecom.numero
           tt-cliecom.compl
           tt-cliecom.bairro
           tt-cliecom.cidade
           tt-cliecom.ufecod
                  with frame f-cliente-02.

  update
    tt-cliecom.cep2
    tt-cliecom.endereco2
    tt-cliecom.numero2
    tt-cliecom.compl2
    tt-cliecom.bairro2
    tt-cliecom.cidade2
    tt-cliecom.ufecod2
                  with frame f-cliente-03.

end.
