#hey
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
    oddBetMsg BYTE "You bet on ODD numbers", 0dh, 0ah, 0
    
    ; Coin Flip strings
    coinFlipTitle BYTE 0dh, 0ah, "=== COIN FLIP ===", 0dh, 0ah, 0
    pickHeadsOrTails BYTE "Press 1 for Heads, Press 2 for Tails: ", 0
    flippingMsg BYTE "Flipping the coin...", 0dh, 0ah, 0
    headsMsg BYTE "Result: HEADS", 0dh, 0ah, 0
    tailsMsg BYTE "Result: TAILS", 0dh, 0ah, 0
    
    ; Slots strings
    slotsTitle BYTE 0dh, 0ah, "=== SLOT MACHINE ===", 0dh, 0ah, 0
    spinningMsg BYTE "Spinning the reels...", 0dh, 0ah, 0
    jackpotMsg BYTE 0dh, 0ah, "JACKPOT!!! All 3 match! +$60", 0dh, 0ah, 0
    twoMatchMsg BYTE 0dh, 0ah, "Two match! +$10", 0dh, 0ah, 0
    noMatchMsg BYTE 0dh, 0ah, "No match. -$20", 0dh, 0ah, 0

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
    call CoinFlip
    jmp GameLoop
    
PlaySlots:
    call Slots
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
    ; Validate bet type (1, 2, or 3)
    cmp eax, 1
    jl InvalidPick
    cmp eax, 3
    jg InvalidPick
    
    mov betType, eax
    
    ; If specific number, get the number
    cmp betType, 1
    jne SpinWheel
    
    mov edx, OFFSET pickNumberMsg
    call WriteString
    call ReadInt
    
    ; Validate input (0-36)
    cmp eax, 0
    jl InvalidPick
    cmp eax, 36
    jg InvalidPick
    
    mov userPick, eax
    jmp SpinWheel
    
SpinWheel:
    ; Display bet type if even/odd
    cmp betType, 2
    jne CheckOddBet
    mov edx, OFFSET evenBetMsg
    call WriteString
    jmp DoSpin
    
CheckOddBet:
    cmp betType, 3
    jne DoSpin
    mov edx, OFFSET oddBetMsg
    call WriteString
    
DoSpin:
    ; Spin the wheel
    mov edx, OFFSET spinMsg
    call WriteString
    
    mov eax, 37
    call RandomRange
    mov ballNumber, eax
    
    ; Display result
    mov edx, OFFSET ballLandedMsg
    call WriteString
    mov eax, ballNumber
    call WriteDec
    call Crlf
    
    ; Check bet type and determine win
    cmp betType, 1
    je CheckSpecificNumber
    cmp betType, 2
    je CheckEven
    cmp betType, 3
    je CheckOdd
    ret
    
CheckEven:
    ; Check if ball is 0 (loses on 0)
    cmp ballNumber, 0
    je RouletteLose
    
    ; Check if even (divide by 2, check remainder)
    mov eax, ballNumber
    mov edx, 0
    mov ecx, 2
    div ecx
    cmp edx, 0
    je RouletteWin
    jmp RouletteLose
    
CheckOdd:
    ; Check if ball is 0 (loses on 0)
    cmp ballNumber, 0
    je RouletteLose
    
    ; Check if odd (divide by 2, check remainder)
    mov eax, ballNumber
    mov edx, 0
    mov ecx, 2
    div ecx
    cmp edx, 1
    je RouletteWin
    jmp RouletteLose
    
CheckSpecificNumber:
    mov eax, userPick
    cmp eax, ballNumber
    je RouletteWin
    jmp RouletteLose
    
RouletteWin:
    mov edx, OFFSET winMsg
    call WriteString
    mov eax, wager
    add balance, eax
    ret
    
RouletteLose:
    mov edx, OFFSET loseMsg
    call WriteString
    mov eax, wager
    sub balance, eax
    ret
    
InvalidPick:
    mov edx, OFFSET invalidMsg
    call WriteString
    ret
Roulette ENDP

;---------------------------------------
CoinFlip PROC
; Simple coin flip: pick heads (1) or tails (2)
; Coin flips randomly
; Match = win
;---------------------------------------
    mov edx, OFFSET coinFlipTitle
    call WriteString
    
    ; Get user's choice
    mov edx, OFFSET pickHeadsOrTails
    call WriteString
    call ReadInt
    ; Validate input (1 or 2)
    cmp eax, 1
    jl InvalidChoice
    cmp eax, 2
    jg InvalidChoice
    
    mov userPick, eax
    
    ; Flip the coin
    mov edx, OFFSET flippingMsg
    call WriteString
    
    mov eax, 2
    call RandomRange
    add eax, 1  ; Result is 1 or 2
    mov coinResult, eax
    
    ; Display result
    cmp coinResult, 1
    je ShowHeads
    
    mov edx, OFFSET tailsMsg
    call WriteString
    jmp CheckWin
    
ShowHeads:
    mov edx, OFFSET headsMsg
    call WriteString
    
CheckWin:
    ; Check if won
    mov eax, userPick
    cmp eax, coinResult
    je CoinWin
    
    ; Lost
    mov edx, OFFSET loseMsg
    call WriteString
    mov eax, wager
    sub balance, eax
    ret
    
CoinWin:
    mov edx, OFFSET winMsg
    call WriteString
    mov eax, wager
    add balance, eax
    ret
    
InvalidChoice:
    mov edx, OFFSET invalidMsg
    call WriteString
    ret
CoinFlip ENDP

;---------------------------------------
Slots PROC
; Slot machine: 3 reels spin (1-7)
; All 3 match = jackpot (+)
; 2 match = small win (+)
; Otherwise = lose (-)
;---------------------------------------
    mov edx, OFFSET slotsTitle
    call WriteString
    
    mov edx, OFFSET spinningMsg
    call WriteString
    
    ; Spin reel 1
    mov eax, 7
    call RandomRange
    add eax, 1
    mov reel1, eax
    
    ; Spin reel 2
    mov eax, 7
    call RandomRange
    add eax, 1
    mov reel2, eax
    
    ; Spin reel 3
    mov eax, 7
    call RandomRange
    add eax, 1
    mov reel3, eax
    
    ; Display reels: [ 1 ] [ 2 ] [ 3 ]
    mov al, '['
    call WriteChar
    mov al, ' '
    call WriteChar
    mov eax, reel1
    call WriteDec
    mov al, ' '
    call WriteChar
    mov al, ']'
    call WriteChar
    mov al, ' '
    call WriteChar
    mov al, '['
    call WriteChar
    mov al, ' '
    call WriteChar
    mov eax, reel2
    call WriteDec
    mov al, ' '
    call WriteChar
    mov al, ']'
    call WriteChar
    mov al, ' '
    call WriteChar
    mov al, '['
    call WriteChar
    mov al, ' '
    call WriteChar
    mov eax, reel3
    call WriteDec
    mov al, ' '
    call WriteChar
    mov al, ']'
    call WriteChar
    call Crlf
    
    ; Check for wins - All 3 match = jackpot
    mov eax, reel1
    cmp eax, reel2
    jne CheckTwoMatch
    cmp eax, reel3
    jne CheckTwoMatch
    
    ; Jackpot!
    mov edx, OFFSET jackpotMsg
    call WriteString
    mov eax, 60
    add balance, eax
    ret
    
CheckTwoMatch:
    ; Check if any 2 match
    mov eax, reel1
    cmp eax, reel2
    je TwoMatch
    mov eax, reel1
    cmp eax, reel3
    je TwoMatch
    mov eax, reel2
    cmp eax, reel3
    je TwoMatch
    
    ; No match
    mov edx, OFFSET noMatchMsg
    call WriteString
    mov eax, wager
    sub balance, eax
    ret
    
TwoMatch:
    mov edx, OFFSET twoMatchMsg
    call WriteString
    mov eax, 10
    add balance, eax
    ret
Slots ENDP

END main






























