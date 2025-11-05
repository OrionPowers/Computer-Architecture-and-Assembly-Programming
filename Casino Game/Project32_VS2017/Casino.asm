INCLUDE Irvine32.inc

.data
    balance DWORD 100
    wager DWORD 20
    welcomeMsg BYTE "Welcome to the Casino!", 0dh, 0ah, 0
    
    ; Game variables
    playerTotal DWORD ?
    dealerTotal DWORD ?
    choice DWORD ?
    userPick DWORD ?
    ballNumber DWORD ?
    currentCard DWORD ?
    betType DWORD ?
    coinResult DWORD ?
    reel1 DWORD ?
    reel2 DWORD ?
    reel3 DWORD ?

.code
main PROC
    call Randomize
    
    ; Display welcome message
    mov edx, OFFSET welcomeMsg
    call WriteString
    
    exit
main ENDP

END main
