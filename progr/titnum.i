            trim(titulo.titnum + (if titulo.titpar > 0
                                  then "/" + string(titulo.titpar)
                                  else "")) @ titulo.titnum
