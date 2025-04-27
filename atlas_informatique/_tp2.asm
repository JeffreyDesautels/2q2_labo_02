; VOTRE NOM ICI : Les Singes Savants (EMILE SIROIS + JEFFREY DESAUTELS)
; Template version 1.3
; 1) Définition d'étiquette              -> 1
; 2) Nom de l'instruction                -> 11
; 3) Opérandes des instructions          -> 16
; 4) Commentaires et C++ en fin de ligne -> 35
;
;
;         2    3                  4
;         |    |                  |
;=============================================================================

          .MODEL small            ;
          .STACK 512              ; Taille de la pile

;=============================================================================
                                 
          .DATA                   ; DB pour Define Byte (8 bits)
                                  ; DW pour Define Word (16 bits)
          ;-------------------------------------------------------------------
          ; Déclaration des variables
          ;-------------------------------------------------------------------
;enter        DB 0Ah, 0Dh, '$'                  ; Retour à la ligne                     
atlas          DB "ATLAS INFORMATIQUE$"           ;
code_produit   DB "Code de produit : $"           ;
produit_erreur DB "Produit non trouvé !$"         ;
buffer_code    DB 6, ?, 6 DUP('$')                ;
nom_fichier    DB "products.dat", 0               ;
file_handle    DW ?                               
buffer_read    DB 6, ?, 6 DUP('$')

;struct Produit {
     buffer_compagnie   DB 20, ?, 20 DUP('$')     ;
     buffer_objet       DB 50, ?, 50 DUP('$')     ;
     buffer_commentaire DB 100, ?, 100 DUP('$')   ;
     buffer_prix        DB 10, ?, 10 DUP('$')     ;
;};
;=============================================================================

          .CODE
           
          MOV  AX, @DATA
          MOV  DS, AX
               
               
main      PROC        
          ;-------------------------------------------------------------------
          ; Debut de votre code principal (main)
          ;-------------------------------------------------------------------
 ; ouvre fichier         
          MOV  AH, 3Dh
          MOV  AL, 00h
          MOV  DX, OFFSET nom_fichier
          INT  21h
          
          MOV  file_handle, AX
                                                                                                          
          MOV  AH, 09h
          LEA  DX, atlas
          INT  21h
          
while_main:
          CALL enter
          CALL enter
          
          MOV  AH, 09h
          LEA  DX, code_produit
          INT  21h
          
          CALL input_number
          CALL file_search  
                                  
end_while_main:
;fermer le fichier
          MOV  AH, 3Eh
          MOV  BX, file_handle
          INT  21h
          
          ;-------------------------------------------------------------------
          ; Fin du code principal
          ;-------------------------------------------------------------------

eop:      MOV  AX, 4C00h
          INT  21h

main      ENDP

          ;-------------------------------------------------------------------
          ; Debut des PROCÉDURES
          ;-------------------------------------------------------------------

input_number     PROC
          
          PUSH AX
          PUSH CX
          PUSH DX
          PUSH DI
          
          LEA  DI, buffer_code
          MOV  CX, 6     
for:
          MOV  AH, 07h
          INT  21h
          
          ; faire condition confirmation
          CMP  AL, 30h
          JL   cancel_input
          CMP  AL, 39h
          JG   cancel_input
          
          MOV  AH, 02h
          MOV  DL, AL
          INT  21h
          
          MOV  [DI], AL
          INC  DI
          
          LOOP for
          
          POP  DI
          POP  DX
          POP  CX
          POP  AX
          
          RET
          
cancel_input:
          JMP  for           
               
input_number     ENDP

          
fct_confirmation PROC
     
fct_confirmation ENDP


file_search      PROC
                 
          CALL enter
          CALL enter
           
while_file:
          MOV  AH, 3Fh
          MOV  BX, file_handle
          MOV  CX, 6
          MOV  DX, OFFSET buffer_read
          INT  21h
          
          JC   end_of_file          
          CMP  AX, 0               
          JE   end_of_file
          
          MOV  CX, 6
          LEA  SI, buffer_code
          LEA  DI, buffer_read
for_file:
          MOV  AL, [SI]
          MOV  BL, [DI]
          CMP  AL, BL
          JNE  not_found  
                        
          INC  SI
          INC  DI              
          LOOP for_file
          
          MOV  AH, 02h
          MOV  DL, '!'
          INT  21h
          JMP  fin
                    
not_found:

;          MOV  AH, 42h
;          MOV  AL, 01h     
;          MOV  CX, 0000h
;          MOV  DX, 0000h   
;          MOV  BX, file_handle
;          INT  21h
          JMP  while_file                

end_of_file:
          CALL display_error
          RET
fin:          
          RET                    
                 
file_search      ENDP


display_error    PROC
          CALL enter
          CALL enter
          
          PUSH AX
          PUSH DX
          
          MOV  AH, 09h
          LEA  DX, produit_erreur
          INT  21h
          
          POP  DX
          POP  AX
          
          RET
display_error    ENDP


display_product  PROC
          PUSH AX
          PUSH DX
          
          CALL enter
          CALL enter
          
          MOV  AH, 09h
          LEA  DX, buffer_compagnie
          INT  21h
          
          MOV  AH, 02h
          MOV  DL, '-'
          INT  21h
          
          MOV  AH, 09h
          LEA  DX, buffer_objet
          INT  21h
          
          CALL enter
          
          MOV  AH, 09h
          LEA  DX, buffer_commentaire
          INT  21h
          
          CALL enter
          
          MOV  AH, 09h
          LEA  DX, buffer_prix
          INT  21h
          
          MOV  AH, 02h
          MOV  DL, '$'
          INT  21h
          
          POP DX
          POP AX
          
          RET
display_product  ENDP

enter            PROC

          PUSH DX
          PUSH AX

          MOV  AH, 02h
          MOV  DL, 0Ah
          INT  21h

          MOV  DL, 0Dh
          INT  21h 

          POP  AX
          POP  DX

          RET

enter            ENDP
         
          ;-------------------------------------------------------------------
          ; Fin des PROCÉDURES
          ;-------------------------------------------------------------------
;============================================================================= 