def output parameter vtitnum like titulo.titnum.                   
                    do for numaut on error undo on endkey undo:
                       
                        find numaut where numaut.etbcod = 999 no-error.
                        if not avail numaut
                        then create numaut.
                        numaut.titnum = numaut.titnum + 1.
                        find current numaut no-lock.
                        vtitnum = string(numaut.titnum).
                        
                        release numaut.
                         
                    end. 