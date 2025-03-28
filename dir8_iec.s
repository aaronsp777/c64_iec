// Shows the directory on device 8

* = $C000

.label OPEN_CHANNEL = $F0
.label REOPEN_CHANNEL = $60
.label CLOSE_CHANNEL = $E0

.label DISK = 8
    // open _,8,0,"$"
    lda #0
    sta STATUS
    lda #DISK
    jsr LISTEN
    lda #OPEN_CHANNEL + 0
    jsr SECOND

    // check for device not present
    ldx #5
    bit STATUS
    bmi error
    lda #'$'
    jsr CIOUT
    jsr UNLSN

    // open done, start reading
    lda #DISK
    jsr TALK
    lda #REOPEN_CHANNEL + 0
    jsr TALKSA

    jsr read2  // program load address
    beq nextline
    ldx #4  // file not found
    bne error  // always jump
 
nextline:
    jsr read2  // next line address
    bne end  // end of file

    // Read & print line number
    lda #'\r'
    jsr CHROUT
    jsr read2
    jsr LINPRT
    lda #' '
    jsr CHROUT

nextchar:
    jsr ACPTR
    beq nextline
    jsr CHROUT
    bne nextchar  // always branch

read2:
    // Reads a 16 bit, little endian value from disk
    // A=high byte, X=low byte, Y&SR=Status code
    jsr ACPTR
    tax
    jsr ACPTR
    ldy STATUS
    rts

end:
    jsr UNTLK 
    lda #DISK
    jsr LISTEN
    lda #CLOSE_CHANNEL + 0
    jsr SECOND
    jmp UNLSN

error:
    jmp ($0300)

.label STATUS = $90
.label LINPRT = $BDCD
.label SECOND = $FF93
.label TALKSA = $FF96
.label ACPTR = $FFA5
.label CIOUT = $FFA8
.label UNLSN = $FFAE
.label LISTEN = $FFB1
.label TALK = $FFB4
.label UNTLK = $FFBA
.label CHROUT = $FFD2
