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
    
    ; Menu strings
    balanceMsg BYTE "Current Balance: $", 0
    separator BYTE 0dh, 0ah, "======================", 0dh, 0ah, 0
    menuMsg BYTE "1-Blackjack | 2-Roulette | 3-Coin Flip | 4-Slots: ", 0
    invalidMsg BYTE "Invalid choice! Try again.", 0dh, 0ah, 0
    gameOverMsg BYTE 0dh, 0ah, "Game Over! You're out of money!", 0dh, 0ah, 0

.code
main PROC
    call Randomize
    
    ; Display welcome message
    mov edx, OFFSET welcomeMsg
    call WriteString
    
GameLoop:
    ; Check if player is broke
    cmp balance, 0
    jle GameOver
    
    ; Display menu
    mov edx, OFFSET menuMsg
    call WriteString
    call ReadInt
    
    ; Invalid choice for now
    mov edx, OFFSET invalidMsg
    call WriteString
    jmp GameLoop
    
GameOver:
    mov edx, OFFSET gameOverMsg
    call WriteString
    exit
main ENDP

END main
