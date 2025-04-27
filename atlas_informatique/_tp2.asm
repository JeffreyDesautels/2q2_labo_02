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
atlas          DB "ATLAS INFORMATIQUE$"           ; string atlas = "ATLAS INFORMATIQUE";
prod_code_msg  DB "Code de produit : $"           ; string code = "Code de produit : ";
prod_erro_msg DB "Produit non trouvé !$"          ; string prod_erro_msg = "Produit non trouvé !";
buffer_code    DB 6, ?, 6 DUP('$')                ; string buffer;
file_name      DB "products.dat", 0               ; const string NOM_FICHIER = "products.dat";
file_handle    DW ?                               ;
buffer_read    DB 6, ?, 6 DUP('$')                ;
buffer_char    DB 1, ?, '$'                       ;

;struct Produit {    
     buffer_compagnie   DB 20, ?, 20 DUP('$')     ; string compagnie;
     buffer_objet       DB 50, ?, 50 DUP('$')     ; string objet;
     buffer_commentaire DB 100, ?, 100 DUP('$')   ; string commentaire;
     buffer_prix        DB 10, ?, 10 DUP('$')     ; float prix;
;};
;=============================================================================

          .CODE
           
          MOV  AX, @DATA
          MOV  DS, AX
               
               
main      PROC        
          ;-------------------------------------------------------------------
          ; Debut de votre code principal (main)
          ;-------------------------------------------------------------------
          
          PUSH AX
          PUSH BX
          PUSH DX
          
          MOV  AH, 3Dh                 ;
          MOV  AL, 00h                 ;
          MOV  DX, OFFSET file_name    ;
          INT  21h                     ; ifstream fichier(NOM_FICHIER);
          
          MOV  file_handle, AX         
                                                                                                          
          MOV  AH, 09h                 ;
          LEA  DX, atlas               ;
          INT  21h                     ; cout << atlas;
          
while_main:

          CALL enter                   ;
          CALL enter                   ; cout << endl << endl;
          
          MOV  AH, 09h                 ;
          LEA  DX, prod_code_msg       ;
          INT  21h                     ; cout << code;
          
          CALL input_number            ; input_number(buffer);
          CALL file_search             ; file_search(buffer);
                                  
end_while_main:

          MOV  AH, 3Eh                 ;
          MOV  BX, file_handle         ;
          INT  21h                     ; fichier.close();
          
          POP  DX
          POP  BX
          POP  AX
          
          ;-------------------------------------------------------------------
          ; Fin du code principal
          ;-------------------------------------------------------------------

eop:      MOV  AX, 4C00h
          INT  21h                     ; return 0;

main      ENDP

          ;-------------------------------------------------------------------
          ; Debut des PROCÉDURES
          ;-------------------------------------------------------------------

input_number     PROC                  ; void input_number(string& buffer) {
                                       ;     char input;
          PUSH AX
          PUSH CX
          PUSH DX
          PUSH DI
          
          LEA  DI, buffer_code         
          MOV  CX, 6                   
for:                                   ;     for (int i = 0; i < 6; i++) {
          MOV  AH, 07h                 ;          input = _getch();     
          INT  21h                     ;
                                       ;
          CMP  AL, 30h                 ;          if (input < 0x30 || input > 0x39) {
          JL   cancel_input            ;               i--;
          CMP  AL, 39h                 ;
          JG   cancel_input            ;
                                       ;          }
          MOV  AH, 02h                 ;          else {
          MOV  DL, AL                  ;               
          INT  21h                     ;               cout << input;
                                       ;
          MOV  [DI], AL                ;               buffer+= input;
          INC  DI                      ;          }
                                       ;
          LOOP for                     ;     }
                                       
          POP  DI
          POP  DX
          POP  CX
          POP  AX
          
          RET
          
cancel_input:

          JMP  for                     ;               code pour le if (i--)
               
input_number     ENDP                  ; }

 
 
file_search      PROC                  ; void file_search(string& buffer) { 
     
          PUSH AX
          PUSH BX
          PUSH CX
          PUSH DX
          PUSH DI
          PUSH SI
                 
          CALL enter                   ;     // pour display_error et product
          CALL enter                   ;     // cout << endl << endl;
           
while_file:                            ;     while (getline(fichier, donnees, ',')) {
          MOV  AH, 3Fh
          MOV  BX, file_handle
          MOV  CX, 6
          MOV  DX, OFFSET buffer_read
          INT  21h 
          
          MOV  CX, 6
          LEA  SI, buffer_code
          LEA  DI, buffer_read
          
for_file:

          MOV  AL, [SI]                ;     if (!flag) {
          MOV  BL, [DI]                ;         display_error();
          CMP  AL, BL                  ;
          JNE  not_found               ;     }
                        
          INC  SI
          INC  DI              
          LOOP for_file 
            
          CALL fill_buffers            ;          if (donnees == buffer) { // suite dans PROC fill_buffers }
          CALL display_product         ;          display_product(produit);
                                       
          JMP  fin
                    
not_found:
next_char: 

          MOV  AH, 3Fh
          MOV  BX, file_handle
          MOV  CX, 1
          LEA  DX, buffer_char
          INT  21h

          JC   end_of_file          
          CMP  AX, 00h              
          JE   end_of_file
          
          MOV  AL, buffer_char
          CMP  AL, 0Ah
          JE   while_file 
          
          JMP  next_char           

end_of_file:    

          CALL display_error 
          
end_FS:
      
          POP  SI
          POP  DI
          POP  DX
          POP  CX
          POP  BX
          POP  AX    
          RET                    
                 
file_search      ENDP                  



fill_buffers     PROC
     
          PUSH AX
          PUSH BX
          PUSH CX
          PUSH DX
          PUSH DI
                                       
          MOV  AH, 3Fh                 
          MOV  BX, file_handle
          MOV  CX, 1
          MOV  DX, OFFSET buffer_char
          INT  21h 
        
          LEA  DI, buffer_compagnie    ;               getline(fichier donnees, ',');
          CALL fill_until_sep          ;               produit.compagnie = donnees;

          LEA  DI, buffer_objet        ;               getline(fichier, donnees, ',');
          CALL fill_until_sep          ;               produit.objet = donnees;

          LEA  DI, buffer_commentaire  ;               getline(fichier, donnees, ',');
          CALL fill_until_sep          ;               produit.commentaire = donnees; 
          
          LEA  DI, buffer_prix         ;               getline(fichier, donnees);
          CALL fill_until_sep          ;               produit.prix = stof(donnees);
          
          POP  DI
          POP  DX
          POP  CX
          POP  BX
          POP  AX
          RET
    
fill_buffers     ENDP    



fill_until_sep   PROC
             
          PUSH AX
          PUSH BX
          PUSH CX
          PUSH DX
          PUSH DI
             
read_while:

          MOV  AH, 3Fh
          MOV  BX, file_handle
          MOV  CX, 1
          MOV  DX, OFFSET buffer_char
          INT  21h
          
          CMP  AX, 00h
          JE   end_read_while  
          
          MOV  AL, [buffer_char]  
          
          CMP  AL, 2Ch
          JE   end_read_while
          CMP  AL, 0Ah
          JE   end_read_while
          
          MOV  [DI], AL
          INC  DI                                        
          JMP  read_while
     
end_read_while:

          POP  DI
          POP  DX
          POP  CX
          POP  BX
          POP  AX
          RET     
     
fill_until_sep   ENDP                  ; } // fin de l'equivalent de file_search() en asm



display_error    PROC                  ; void display_error() {
          
          PUSH AX
          PUSH DX
          
          MOV  AH, 09h                 ;
          LEA  DX, prod_erro_msg       ;
          INT  21h                     ;     cout << prod_erro_msg; 
          
          POP  DX
          POP  AX
          
          RET
          
display_error    ENDP                  ; }



display_product  PROC                  ; void display_product(Produit produit) {
     
          PUSH AX
          PUSH DX
          
          MOV  AH, 09h                 ;
          LEA  DX, buffer_compagnie    ;
          INT  21h                     ;
                                       ;
          MOV  AH, 02h                 ;
          MOV  DL, '-'                 ;
          INT  21h                     ;     cout << produit.compagnie << " - ";
          
          MOV  AH, 09h                 ;
          LEA  DX, buffer_objet        ;
          INT  21h                     ;
                                       ;
          CALL enter                   ;     cout << produit.objet << endl;
          
          MOV  AH, 09h                 ;
          LEA  DX, buffer_commentaire  ;
          INT  21h                     ;
                                       ;
          CALL enter                   ;     cout << produit.commentaire << endl;
          
          MOV  AH, 09h                 ;
          LEA  DX, buffer_prix         ;
          INT  21h                     ;
                                       ;
          MOV  AH, 02h                 ;
          MOV  DL, '$'                 ;
          INT  21h                     ;     cout << produit.prix << "$";
          
          POP DX
          POP AX
          
          RET
          
display_product  ENDP                  ; }



enter            PROC                  ; == endl

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