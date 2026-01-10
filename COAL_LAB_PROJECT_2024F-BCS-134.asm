DISPLAY MACRO msg
    MOV AH,09h
    MOV DX,OFFSET msg
    INT 21h
ENDM

NEWLINE MACRO 
    MOV AH,2
    MOV DL,0AH
    INT 21H 
    
     MOV AH,2
    MOV DL,0DH
    INT 21H
NEWLINE ENDM

; Macro to display attendance for a student index in BX
DISPLAY_ATT MACRO studentIndex
    MOV AX,studentIndex
    MOV CX,ATT_LEN
    MUL CX                  ; offset = index * ATT_LEN
    LEA DI,studentAtt
    ADD DI,AX
    MOV CX,ATT_LEN
A_ATT:  
    MOV DL,[DI]
    MOV AH,02h
    INT 21h
    INC DI
    LOOP A_ATT  
    DISPLAY nl 
ENDM   

DISPLAY_BATCH MACRO studentIndex
    MOV AX,studentIndex
    MOV CX,BATCH_LEN
    MUL CX                  ; offset = index * ATT_LEN
    LEA DI,studentBatch
    ADD DI,AX
    MOV CX,BATCH_LEN
A_BATCH:  
    MOV DL,[DI]
    MOV AH,02h
    INT 21h
    INC DI
    LOOP A_BATCH  
    DISPLAY nl 
ENDM


.MODEL SMALL
.STACK 100h

.DATA
MENUMSG DB 13,10,"===== Student Information System =====",13,10
        DB "1. Add Student",13,10
        DB "2. Search Student",13,10
        DB "3. Check Attendance",13,10
        DB "4. Check Batch",13,10
        DB "5. Check Marks",13,10
        DB "6. Exit",13,10
        DB "Enter choice: $"


nameMsg     DB 13,10,"Enter Name: $"
rollMsg     DB 13,10,"Enter Roll No: $"
batchMsg    DB 13,10,"Enter Batch: $"
sectionMsg  DB 13,10,"Enter Section: $"
semMsg      DB 13,10,"Enter Semester: $"
gpaMsg      DB 13,10,"Enter GPA: $"
attMsg      DB 13,10,"Enter Attendance: $"
courseMsg   DB 13,10,"Enter Course Name: $"
marksMsg DB 13,10,"Enter Marks for this course: $"

foundMsg    DB 13,10,"--- Student Record ---",13,10,"$"
notFoundMsg DB 13,10,"Student Not Found!",13,10,"$"
nl          DB 13,10,"$"

nameLabel   DB "Name: $"
rollLabel   DB "Roll: $"
batchLabel  DB "Batch: $"
sectionLabel DB "Section: $"
semLabel    DB "Semester: $"
gpaLabel    DB "GPA: $"
attLabel    DB "Attendance: $"
courseLabel DB "Course: $"

MAX_STUDENTS EQU 5
NAME_LEN  EQU 20
ROLL_LEN  EQU 15
BATCH_LEN EQU 6
GPA_LEN   EQU 5
ATT_LEN   EQU 3
COURSE_LEN EQU 50
COURSES_PER EQU 5


studentNames   DB MAX_STUDENTS*NAME_LEN DUP('$')
studentRolls   DB MAX_STUDENTS*ROLL_LEN DUP('$')
studentBatch   DB MAX_STUDENTS*BATCH_LEN DUP('$')
studentSection DB MAX_STUDENTS DUP('$')
studentSem     DB MAX_STUDENTS DUP('$')
studentGPA     DB MAX_STUDENTS*GPA_LEN DUP('$')
studentAtt     DB MAX_STUDENTS*ATT_LEN DUP('$')
studentCourses DB MAX_STUDENTS*COURSES_PER*COURSE_LEN DUP('$')
studentMarks DB MAX_STUDENTS*COURSES_PER DUP(0)  ; each course has one mark 
digitsBuf DB 3 DUP(0)

count DB 0

; -------- BUFFERS --------
nameBuf   DB NAME_LEN,0,NAME_LEN DUP(0)
rollBuf   DB ROLL_LEN,0,ROLL_LEN DUP(0)
batchBuf  DB BATCH_LEN,0,BATCH_LEN DUP(0)
gpaBuf    DB GPA_LEN,0,GPA_LEN DUP(0)
attBuf    DB ATT_LEN,0,ATT_LEN DUP(0)
courseBuf DB COURSE_LEN,0,COURSE_LEN DUP(0)
marksBuf     DB COURSES_PER,0,COURSES_PER DUP(0) ; input buffer for marks

.CODE

READ_BUFFER PROC
    MOV AH,0Ah
    INT 21h
    RET
READ_BUFFER ENDP

MAIN PROC
    MOV AX,@DATA
    MOV DS,AX
    MOV ES,AX

MENU:
    DISPLAY MENUMSG
    MOV AH,01h
    INT 21h

    CMP AL,'1'
    JE ADD_STUDENT
    CMP AL,'2'
    JE SEARCH_STUDENT
     CMP AL,'3'
    JE SEARCH_ATTENDANCE
    CMP AL,'4'
     JE SEARCH_BATCH
     CMP AL,'5'
     JE VIEW_MARKS
    CMP AL,'6'
    JE EXIT
    JMP MENU

; ================= ADD STUDENT =================
ADD_STUDENT:
    MOV AL,count
    CMP AL,MAX_STUDENTS
    JAE MENU

    MOV BL,count
    XOR BH,BH

    ; ---- NAME ----
    DISPLAY nameMsg
    LEA DX,nameBuf
    CALL READ_BUFFER

    MOV AX,BX
    MOV CX,NAME_LEN
    MUL CX
    LEA DI,studentNames
    ADD DI,AX
    LEA SI,nameBuf+2
    MOV CL,nameBuf+1
    XOR CH,CH
    REP MOVSB

    ; ---- ROLL ----
    DISPLAY rollMsg
    LEA DX,rollBuf
    CALL READ_BUFFER

    MOV AX,BX
    MOV CX,ROLL_LEN
    MUL CX
    LEA DI,studentRolls
    ADD DI,AX
    LEA SI,rollBuf+2
    MOV CL,rollBuf+1
    XOR CH,CH
    REP MOVSB

    ; ---- BATCH ----
    DISPLAY batchMsg
    LEA DX,batchBuf
    CALL READ_BUFFER

    MOV AX,BX
    MOV CX,BATCH_LEN
    MUL CX
    LEA DI,studentBatch
    ADD DI,AX
    LEA SI,batchBuf+2
    MOV CL,batchBuf+1
    XOR CH,CH
    REP MOVSB

    ; ---- SECTION (single char) ----
    DISPLAY sectionMsg
    MOV AH,01h
    INT 21h
    MOV studentSection[BX],AL

    ; ---- SEMESTER (single char) ----
    DISPLAY semMsg
    MOV AH,01h
    INT 21h
    MOV studentSem[BX],AL

    ; ---- GPA ----
    DISPLAY gpaMsg
    LEA DX,gpaBuf
    CALL READ_BUFFER

    MOV AX,BX
    MOV CX,GPA_LEN
    MUL CX
    LEA DI,studentGPA
    ADD DI,AX
    LEA SI,gpaBuf+2
    MOV CL,gpaBuf+1
    XOR CH,CH
    REP MOVSB

    ; ---- ATTENDANCE ----
    DISPLAY attMsg
    LEA DX,attBuf
    CALL READ_BUFFER

    MOV AX,BX
    MOV CX,ATT_LEN
    MUL CX
    LEA DI,studentAtt
    ADD DI,AX
    LEA SI,attBuf+2
    MOV CL,attBuf+1
    XOR CH,CH
    REP MOVSB

    ; ---- COURSES ----
    MOV BP,0
COURSE_LOOP:
    CMP BP,COURSES_PER
    JAE DONE_ADD

    DISPLAY courseMsg
    LEA DX,courseBuf
    CALL READ_BUFFER

    MOV AX,BX
    MOV CX,COURSES_PER
    MUL CX
    ADD AX,BP
    MOV CX,COURSE_LEN
    MUL CX
    LEA DI,studentCourses
    ADD DI,AX
    LEA SI,courseBuf+2
    MOV CL,courseBuf+1
    XOR CH,CH
    REP MOVSB
    
     ; --- marks for this course ---
   ; --- marks for this course ---
    DISPLAY marksMsg
    LEA DX,marksBuf
    CALL READ_BUFFER

; calculate mark storage address
    MOV AX,BX              ; BX = student index (safe now)
    MOV CX,COURSES_PER
    MUL CX
    ADD AX,BP
    LEA DI,studentMarks
    ADD DI,AX

; ===== ASCII to number conversion =====
    MOV AL,marksBuf+2
    SUB AL,'0'
    MOV DL,10
    MUL DL                 ; AL = tens * 10

    MOV DL,marksBuf+3
    SUB DL,'0'
    ADD AL,DL              ; AL = full mark (0–99)

    MOV [DI],AL




    INC BP
    JMP COURSE_LOOP

DONE_ADD:
    INC count
    JMP MENU

; ================= SEARCH =================
SEARCH_STUDENT:
    DISPLAY rollMsg
    LEA DX,rollBuf
    CALL READ_BUFFER

    XOR SI,SI
SEARCH_LOOP:
    MOV AL,count
    XOR AH,AH
    CMP SI,AX
    JAE NOT_FOUND

    MOV AX,SI
    MOV CX,ROLL_LEN
    MUL CX
    LEA DI,studentRolls
    ADD DI,AX

    LEA BX,rollBuf+2
    MOV CL,rollBuf+1
    XOR CH,CH
CMP_LOOP:
    MOV AL,[DI]
    CMP AL,[BX]
    JNE NEXT_STUDENT
    INC DI
    INC BX
    LOOP CMP_LOOP

    JMP SHOW

NEXT_STUDENT:
    INC SI
    JMP SEARCH_LOOP
    
;---------------------CHECK ATTENDANCE------------------------
SEARCH_ATTENDANCE:
    DISPLAY rollMsg
    LEA DX,rollBuf
    CALL READ_BUFFER       ; read roll number input
    
    MOV AH,2
    MOV DL,0AH
    INT 21H 
    
    MOV AH,2
    MOV DL,0DH
    INT 21H


    XOR SI,SI
ATT_LOOP:
    MOV AL,count
    XOR AH,AH
    CMP SI,AX
    JAE NOT_FOUND

    ; Calculate student roll address
    MOV AX,SI
    MOV CX,ROLL_LEN
    MUL CX
    LEA DI,studentRolls
    ADD DI,AX

    ; Set BX to input buffer start
    LEA BX,rollBuf+2
    MOV CL,[rollBuf+1]    ; input length
    XOR CH,CH

    ; Compare student roll with input
CMP_ATT:
    MOV AL,[DI]
    CMP AL,[BX]
    JNE NEXT_ATT
    INC DI
    INC BX
    DEC CX
    JNZ CMP_ATT            ; continue until all chars match

    ; If match, display attendance
    DISPLAY attLabel
    MOV BX,SI
    DISPLAY_ATT BX
    JMP MENU

NEXT_ATT:
    INC SI
    JMP ATT_LOOP
    
    ;---------------------CHECK BATCH------------------------
SEARCH_BATCH:
    DISPLAY rollMsg
    LEA DX,rollBuf
    CALL READ_BUFFER       ; read roll number input
    
    MOV AH,2
    MOV DL,0AH
    INT 21H 
    
    MOV AH,2
    MOV DL,0DH
    INT 21H


    XOR SI,SI
BATCH_LOOP:
    MOV AL,count
    XOR AH,AH
    CMP SI,AX
    JAE NOT_FOUND

    ; Calculate student roll address
    MOV AX,SI
    MOV CX,ROLL_LEN
    MUL CX
    LEA DI,studentRolls
    ADD DI,AX

    ; Set BX to input buffer start
    LEA BX,rollBuf+2
    MOV CL,[rollBuf+1]    ; input length
    XOR CH,CH

    ; Compare student roll with input
CMP_BATCH:
    MOV AL,[DI]
    CMP AL,[BX]
    JNE NEXT_BATCH
    INC DI
    INC BX
    DEC CX
    JNZ CMP_BATCH            ; continue until all chars match

    ; If match, display attendance
    DISPLAY batchMsg
    MOV BX,SI
    DISPLAY_BATCH BX
    JMP MENU

NEXT_BATCH:
    INC SI
    JMP BATCH_LOOP


; ================= SHOW =================
SHOW:
    DISPLAY foundMsg

    DISPLAY nameLabel
    MOV AX,SI
    MOV CX,NAME_LEN
    MUL CX
    LEA DI,studentNames
    ADD DI,AX
PRINT_NAME:
    MOV DL,[DI]
    CMP DL,'$'
    JE NL1
    MOV AH,02h
    INT 21h
    INC DI
    JMP PRINT_NAME
NL1:
    DISPLAY nl

    DISPLAY rollLabel
    MOV AX,SI
    MOV CX,ROLL_LEN
    MUL CX
    LEA DI,studentRolls
    ADD DI,AX
    MOV CX,ROLL_LEN
PR:
    MOV DL,[DI]
    MOV AH,02h
    INT 21h
    INC DI
    LOOP PR
    DISPLAY nl

    DISPLAY batchLabel
    MOV AX,SI
    MOV CX,BATCH_LEN
    MUL CX
    LEA DI,studentBatch
    ADD DI,AX
    MOV CX,BATCH_LEN
PB:
    MOV DL,[DI]
    MOV AH,02h
    INT 21h
    INC DI
    LOOP PB
    DISPLAY nl

    DISPLAY sectionLabel
    MOV DL,studentSection[SI]
    MOV AH,02h
    INT 21h
    DISPLAY nl

    DISPLAY semLabel
    MOV DL,studentSem[SI]
    MOV AH,02h
    INT 21h
    DISPLAY nl

    DISPLAY gpaLabel
    MOV AX,SI
    MOV CX,GPA_LEN
    MUL CX
    LEA DI,studentGPA
    ADD DI,AX
    MOV CX,GPA_LEN
PG:
    MOV DL,[DI]
    MOV AH,02h
    INT 21h
    INC DI
    LOOP PG
    DISPLAY nl

    DISPLAY attLabel
    MOV AX,SI
    MOV CX,ATT_LEN
    MUL CX
    LEA DI,studentAtt
    ADD DI,AX
    MOV CX,ATT_LEN
PA:
    MOV DL,[DI]
    MOV AH,02h
    INT 21h
    INC DI
    LOOP PA
    DISPLAY nl

    MOV BP,0
PC:
    CMP BP,COURSES_PER
    JAE MENU
    DISPLAY courseLabel

    MOV AX,SI
    MOV CX,COURSES_PER
    MUL CX
    ADD AX,BP
    MOV CX,COURSE_LEN
    MUL CX
    LEA DI,studentCourses
    ADD DI,AX
    MOV CX,COURSE_LEN
PC2:
    MOV DL,[DI]
    CMP DL,'$'
    JE NL2
    MOV AH,02h
    INT 21h
    INC DI
    LOOP PC2
NL2:
    DISPLAY nl
    INC BP
    JMP PC

NOT_FOUND:
    DISPLAY notFoundMsg
    JMP MENU
            
;-----------------VIEW MARKS-------------------------
VIEW_MARKS:
    DISPLAY rollMsg
    LEA DX,rollBuf
    CALL READ_BUFFER

    XOR SI,SI             ; student index
MARK_LOOP:
    MOV AL,count
    XOR AH,AH
    CMP SI,AX
    JAE NOT_FOUND

    ; calculate student roll address
    MOV AX,SI
    MOV CX,ROLL_LEN
    MUL CX
    LEA DI,studentRolls
    ADD DI,AX

    ; set BX = input buffer start
    LEA BX,rollBuf+2
    MOV CL,[rollBuf+1]
    XOR CH,CH

CMP_MARK:
    MOV AL,[DI]
    CMP AL,[BX]
    JNE NEXT_MARK
    INC DI
    INC BX
    DEC CL
    JNZ CMP_MARK

    NEWLINE
    DISPLAY nameLabel

    ; print student name
    MOV AX,SI
    MOV CX,NAME_LEN
    MUL CX
    LEA DI,studentNames
    ADD DI,AX

PRINT_MARK_NAME:
    MOV DL,[DI]
    CMP DL,'$'
    JE NL_MARK1
    MOV AH,02h
    INT 21h
    INC DI
    JMP PRINT_MARK_NAME
NL_MARK1:
    DISPLAY nl

    MOV BP,0              ; course index
PRINT_MARKS:
    CMP BP,COURSES_PER
    JAE MENU

    ; ===== calculate address of course name =====
    MOV AX,SI          ; student index
    MOV CX,COURSES_PER
    MUL CX
    ADD AX,BP          ; add course offset
    MOV CX,COURSE_LEN
    MUL CX
    LEA DI,studentCourses
    ADD DI,AX

    ; ===== display course name =====
PRINT_COURSE_NAME:
    MOV DL,[DI]
    CMP DL,'$'
    JE COURSE_NAME_DONE
    MOV AH,02h
    INT 21h
    INC DI
    JMP PRINT_COURSE_NAME
COURSE_NAME_DONE:

    ; ===== display ": " =====
    MOV AH,2
    MOV DL,':'
    INT 21H
    MOV DL,' '
    INT 21H

    ; ===== print corresponding mark =====
    MOV AX,SI
    MOV CX,COURSES_PER
    MUL CX
    ADD AX,BP
    LEA DI,studentMarks
    ADD DI,AX

    MOV AL,[DI]        ; load mark
    MOV AH,0           ; zero extend AL -> AX
    MOV BX,10
    XOR CX,CX          ; digit counter
    PUSH_MARKES:
    CMP AX,0
    JE PRINT_ZERO

CONVERT_LOOP:
    XOR DX,DX
    DIV BX            ; AX / 10 -> AL = quotient, AH = remainder
    PUSH DX           ; store remainder
    INC CX
    CMP AX,0
    JNZ CONVERT_LOOP

PRINT_DIGITS:
    POP DX
    ADD DL,'0'
    MOV AH,2
    INT 21h
    DEC CX
    JNZ PRINT_DIGITS
    JMP MARK_DONE

PRINT_ZERO:
    MOV DL,'0'
    MOV AH,2
    INT 21h

MARK_DONE:
    NEWLINE
    INC BP            ; next course
    JMP PRINT_MARKS

NEXT_MARK:
    INC SI            ; next student
    JMP MARK_LOOP



EXIT:
    MOV AH,4Ch
    INT 21h
MAIN ENDP
END MAIN