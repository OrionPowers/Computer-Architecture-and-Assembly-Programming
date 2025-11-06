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
    
    ; Blackjack strings
    bjTitle BYTE 0dh, 0ah, "=== BLACKJACK ===", 0dh, 0ah, 0
    youDrawMsg BYTE "You draw: ", 0
    dealerDrawsMsg BYTE "Dealer draws: ", 0
    yourTotalMsg BYTE "Your total: ", 0
    dealerTotalMsg BYTE "Dealer total: ", 0
    hitStandMsg BYTE 0dh, 0ah, "Press 1 to Hit, Press 2 to Stand: ", 0
    bustMsg BYTE 0dh, 0ah, "BUST! You lose ", 0dh, 0ah, 0
    winMsg BYTE 0dh, 0ah, "You WIN! +", 0dh, 0ah, 0
    loseMsg BYTE 0dh, 0ah, "You LOSE! -", 0dh, 0ah, 0
    pushMsg BYTE 0dh, 0ah, "PUSH! No money exchanged", 0dh, 0ah, 0
    dealerTurnMsg BYTE 0dh, 0ah, "--- Dealer's Turn ---", 0dh, 0ah, 0
    
    ; Roulette strings
    rouletteTitle BYTE 0dh, 0ah, "=== ROULETTE ===", 0dh, 0ah, 0
    betTypeMsg BYTE "Press 1 for Specific Number, Press 2 for Even, Press 3 for Odd: ", 0
    pickNumberMsg BYTE "Pick a number (0-36): ", 0
    spinMsg BYTE "Spinning the wheel...", 0dh, 0ah, 0
    ballLandedMsg BYTE "Ball landed on: ", 0
    evenBetMsg BYTE "You bet on EVEN numbers", 0dh, 0ah, 0
    oddBetMsg BYTE "You bet on ODD numbers", 0dh, 0ah, 0dh, 0ah, "--- Dealer's Turn ---", 0dh, 0ah, 0

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
    
    ; Display balance
    call DisplayBalance
    
    ; Display separator and menu
    mov edx, OFFSET separator
    call WriteString
    mov edx, OFFSET menuMsg
    call WriteString
    call ReadInt
    
    ; Check choice
    cmp eax, 1
    je PlayBlackjack
    cmp eax, 2
    je PlayRoulette
    cmp eax, 3
    je PlayCoinFlip
    cmp eax, 4
    je PlaySlots
    
    ; Invalid choice
    mov edx, OFFSET invalidMsg
    call WriteString
    jmp GameLoop
    
PlayBlackjack:
    call Blackjack
    jmp GameLoop
    
PlayRoulette:
    call Roulette
    jmp GameLoop
    
PlayCoinFlip:
    ; TODO: Implement Coin Flip
    jmp GameLoop
    
PlaySlots:
    ; TODO: Implement Slots
    jmp GameLoop
    
GameOver:
    mov edx, OFFSET gameOverMsg
    call WriteString
    exit
main ENDP

;---------------------------------------
DisplayBalance PROC
;---------------------------------------
    mov edx, OFFSET balanceMsg
    call WriteString
    mov eax, balance
    call WriteDec
    call Crlf
    
    ; Deal first card to dealer (shown)
    mov edx, OFFSET dealerDrawsMsg
    call WriteString
    mov eax, 11
    call RandomRange
    add eax, 1
    mov currentCard, eax
    call WriteDec
    call Crlf
    add dealerTotal, eax
    
    ; Deal second card to dealer (hidden - we just add it)
    mov eax, 11
    call RandomRange
    add eax, 1
    add dealerTotal, eax
    
PlayerTurn:
    ; Check if bust
    cmp playerTotal, 21
    jg PlayerBust
    
    ; Hit or stand?
    mov edx, OFFSET hitStandMsg
    call WriteString
    call ReadInt
    mov choice, eax
    
    cmp choice, 1
    jne DealerTurn
    
    ; Hit: deal another card
    mov edx, OFFSET youDrawMsg
    call WriteString
    mov eax, 11
    call RandomRange
    add eax, 1
    mov currentCard, eax
    call WriteDec
    call Crlf
    add playerTotal, eax
    
    ; Show updated total
    mov edx, OFFSET yourTotalMsg
    call WriteString
    mov eax, playerTotal
    call WriteDec
    call Crlf
    
    jmp PlayerTurn
    
PlayerBust:
    mov edx, OFFSET bustMsg
    call WriteString
    mov eax, wager
    sub balance, eax
    ret
    
DealerTurn:
    mov edx, OFFSET dealerTurnMsg
    call WriteString
    
    ; Reveal dealer's hidden card by showing total
    mov edx, OFFSET dealerTotalMsg
    call WriteString
    mov eax, dealerTotal
    call WriteDec
    call Crlf
    
DealerHit:
    cmp dealerTotal, 17
    jge CompareHands
    
    ; Dealer hits
    mov edx, OFFSET dealerDrawsMsg
    call WriteString
    mov eax, 11
    call RandomRange
    add eax, 1
    mov currentCard, eax
    call WriteDec
    call Crlf
    add dealerTotal, eax
    
    ; Show dealer's new total
    mov edx, OFFSET dealerTotalMsg
    call WriteString
    mov eax, dealerTotal
    call WriteDec
    call Crlf
    
    jmp DealerHit
    
CompareHands:
    ; Check dealer bust
    cmp dealerTotal, 21
    jg PlayerWins
    
    ; Compare totals
    mov eax, playerTotal
    cmp eax, dealerTotal
    jg PlayerWins
    jl PlayerLoses
    
    ; Push (tie)
    mov edx, OFFSET pushMsg
    call WriteString
    ret
    
PlayerLoses:
    mov edx, OFFSET loseMsg
    call WriteString
    mov eax, wager
    sub balance, eax
    ret
    
PlayerWins:
    mov edx, OFFSET winMsg
    call WriteString
    mov eax, wager
    add balance, eax
    ret
DisplayBalance ENDP



;---------------------------------------
Blackjack PROC
; Simple blackjack: player and dealer start with 2 cards
; Player can hit (get another card) or stand
; Cards are 1-11 in value
;---------------------------------------
    mov edx, OFFSET bjTitle
    call WriteString
    
    ; Initialize totals to 0
    mov playerTotal, 0
    mov dealerTotal, 0
    
    ; Deal first card to player
    mov edx, OFFSET youDrawMsg
    call WriteString
    mov eax, 11
    call RandomRange
    add eax, 1
    mov currentCard, eax
    call WriteDec
    call Crlf
    add playerTotal, eax
    
    ; Deal second card to player
    mov edx, OFFSET youDrawMsg
    call WriteString
    mov eax, 11
    call RandomRange
    add eax, 1
    mov currentCard, eax
    call WriteDec
    call Crlf
    add playerTotal, eax
    
    ; Show player total
    mov edx, OFFSET yourTotalMsg
    call WriteString
    mov eax, playerTotal
    call WriteDec
    call Crlf
    
    ; Deal first card to dealer (shown)
    mov edx, OFFSET dealerDrawsMsg
    call WriteString
    mov eax, 11
    call RandomRange
    add eax, 1
    mov currentCard, eax
    call WriteDec
    call Crlf
    add dealerTotal, eax
    
    ; Deal second card to dealer (hidden - we just add it)
    mov eax, 11
    call RandomRange
    add eax, 1
    add dealerTotal, eax
    
PlayerTurn:
    ; Check if bust
    cmp playerTotal, 21
    jg PlayerBust
    
    ; Hit or stand?
    mov edx, OFFSET hitStandMsg
    call WriteString
    call ReadInt
    mov choice, eax
    
    cmp choice, 1
    jne DealerTurn
    
    ; Hit: deal another card
    mov edx, OFFSET youDrawMsg
    call WriteString
    mov eax, 11
    call RandomRange
    add eax, 1
    mov currentCard, eax
    call WriteDec
    call Crlf
    add playerTotal, eax
    
    ; Show updated total
    mov edx, OFFSET yourTotalMsg
    call WriteString
    mov eax, playerTotal
    call WriteDec
    call Crlf
    
    jmp PlayerTurn
    
PlayerBust:
    mov edx, OFFSET bustMsg
    call WriteString
    mov eax, wager
    sub balance, eax
    ret
    
DealerTurn:
    mov edx, OFFSET dealerTurnMsg
    call WriteString
    
    ; Reveal dealer's hidden card by showing total
    mov edx, OFFSET dealerTotalMsg
    call WriteString
    mov eax, dealerTotal
    call WriteDec
    call Crlf
    
DealerHit:
    cmp dealerTotal, 17
    jge CompareHands
    
    ; Dealer hits
    mov edx, OFFSET dealerDrawsMsg
    call WriteString
    mov eax, 11
    call RandomRange
    add eax, 1
    mov currentCard, eax
    call WriteDec
    call Crlf
    add dealerTotal, eax
    
    ; Show dealer's new total
    mov edx, OFFSET dealerTotalMsg
    call WriteString
    mov eax, dealerTotal
    call WriteDec
    call Crlf
    
    jmp DealerHit
    
CompareHands:
    ; Check dealer bust
    cmp dealerTotal, 21
    jg PlayerWins
    
    ; Compare totals
    mov eax, playerTotal
    cmp eax, dealerTotal
    jg PlayerWins
    jl PlayerLoses
    
    ; Push (tie)
    mov edx, OFFSET pushMsg
    call WriteString
    ret
    
PlayerLoses:
    mov edx, OFFSET loseMsg
    call WriteString
    mov eax, wager
    sub balance, eax
    ret
    
PlayerWins:
    mov edx, OFFSET winMsg
    call WriteString
    mov eax, wager
    add balance, eax
    ret
Blackjack ENDP

;---------------------------------------
Roulette PROC
; Roulette: pick specific number (0-36), even, or odd
; Ball lands on random 0-36
; Specific number match = win, even/odd match = win
;---------------------------------------
    mov edx, OFFSET rouletteTitle
    call WriteString
    
    ; Get bet type
    mov edx, OFFSET betTypeMsg
    call WriteString
    call ReadInt
    mov betType, eax
    ret
Roulette ENDPEND main
















