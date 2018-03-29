<#

Conway's Game of life

Inputs: square grid size, number of iterations, delay between iterations (in milliseconds)

#>

[cmdletbinding()]

Param()

Class Cell {
    [bool]$isAlive
    [int]$neighbors = 0

    # Constructor
    Cell([bool]$state) {
        $this.ChangeState($state)
    }

    # Method to change state to $true/$false:Alive/Dead
    ChangeState([bool]$state) {
        $this.isAlive = [bool]$state
    }

    [string]ToString() {
        If ($this.isAlive) {
            return 'x'
        } Else {
            return '.'
        }
    }
}

Class GameBoard {
    $board = @()
    [int]$size

    # Standard Constructor
    GameBoard([int]$s) {
        Write-Verbose "Setting up $s`x$s board"
        $this.size = $s
        $this.board = New-Object 'object[,]' $s,$s

        For ($row=0; $row -lt $s; $row++) {
            For ($col=0; $col -lt $s; $col++) {
                $this.board[$row,$col] += [Cell]::new($false)
            }
        }

        # Create an initial pattern, minimum 3x3. Oscillates.
        ForEach ($row in 0..2) {
            $this.board[$row,1].ChangeState($true)
        }
    }

    # Print board to screen
    [void]Display([int]$delay) {
        For ($row=0; $row -lt $this.size; $row++) {
            For ($col=0; $col -lt $this.size; $col++) {
                Write-Host -NoNewLine $this.board[$row,$col]
            }
            Write-Host
        }
        Write-Host
        Start-Sleep -m $delay
    }

    [GameBoard]Clone() {
        #Create a new board with the same dimensions as the one we're copying
        $newBoard = [GameBoard]::new($this.size)

        For ($row=0; $row -lt $this.size; $row++) {
            For ($col=0; $col -lt $this.size; $col++) {
                If ($this.board[$row,$col].isAlive) {
                    $newBoard.board[$row,$col].ChangeState($true)
                } Else {
                    $newBoard.board[$row,$col].ChangeState($false)
                }
            }
        }

        return $newBoard
    }
}

Class Life {
    [int]$size = 10
    [int]$iterations = 10
    [int]$delay = 400
    [int]$currentGeneration = $null
    [GameBoard]$GameBoard

    Life() {
        Write-Verbose "Creating new Life object with defaults"
        $this.runGame()
    }

    # Constructor, takes size
    Life([int]$s) {
        Write-Verbose "Creating new Life object"
        $this.size = $s
        $this.runGame()
    }

    # Constructor, takes size, iterations
    Life([int]$s,[int]$i) {
        Write-Verbose "Creating new Life object"
        $this.size = $s
        $this.iterations = $i
        $this.runGame()
    }

    # Constructor, takes size, iterations, delay
    Life([int]$s,[int]$i,[int]$d) {
        Write-Verbose "Creating new Life object"
        $this.size = $s
        $this.iterations = $i
        $this.delay = $d
        $this.runGame()
    }

    # runGame method, main loop
    [void]runGame() {
        Write-Verbose "Starting game loop..."

        $this.GameBoard = [GameBoard]::new($this.size)

        For ($generation=0; $generation -lt $this.iterations; $generation++) {
            $this.currentGeneration = $generation

            Write-Host "Generation $($this.displayCurrentGeneration())"
            
            $this.evolve()

            $this.GameBoard.Display($this.delay)
        }
    }

    # evolve method, game logic is here
    [void]evolve() {
        Write-Verbose "Attempting evolution of generation $($this.displayCurrentGeneration())"
        $old_board = $this.GameBoard.Clone()

        For ($row=0; $row -lt $this.size; $row++) {
            For ($col=0; $col -lt $this.size; $col++) {
                $this.GameBoard.board[$row,$col].neighbors = 0

                # Check the old board. Set neighbor counts and Alive/Dead state on primary GameBoard object

                # Up & left
                If ($row -gt 0 -and $col -gt 0) {
                    If ($old_board.board[($row-1),($col-1)].isAlive) { # Seems dangerous, potential index out-of-bounds, but hasn't been an issue...
                        $this.GameBoard.board[$row,$col].neighbors++
                    }
                }
                # Up & right
                If ($row -gt 0 -and $col -lt $this.size - 1) {
                    If ($old_board.board[($row-1),($col+1)].isAlive) {
                        $this.GameBoard.board[$row,$col].neighbors++
                    }
                }
                # Down & left
                If ($row -lt $this.size - 1 -and $col -gt 0) {
                    If ($old_board.board[($row+1),($col-1)].isAlive) {
                        $this.GameBoard.board[$row,$col].neighbors++
                    }
                }
                # Down & right
                If ($row -lt $this.size - 1 -and $col -lt $this.size - 1) {
                    If ($old_board.board[($row+1),($col+1)].isAlive) {
                        $this.GameBoard.board[$row,$col].neighbors++
                    }
                }
                # Left
                If ($col -gt 0) {
                    If ($old_board.board[($row),($col-1)].isAlive) {
                        $this.GameBoard.board[$row,$col].neighbors++
                    }
                }
                # Right
                If ($col -lt $this.size - 1) {
                    If ($old_board.board[($row),($col+1)].isAlive) {
                        $this.GameBoard.board[$row,$col].neighbors++
                    }
                }
                # Up
                If ($row -gt 0) {
                    If ($old_board.board[($row-1),($col)].isAlive) {
                        $this.GameBoard.board[$row,$col].neighbors++
                    }
                }
                # Down
                If ($row -lt $this.size - 1) {
                    If ($old_board.board[($row+1),($col)].isAlive) {
                        $this.GameBoard.board[$row,$col].neighbors++
                    }
                }

                # Check alive/dead status of old board, versus neighbors on new board
                If ($old_board.board[$row,$col].isAlive) {
                    If ($this.GameBoard.board[$row,$col].neighbors -eq 2 -or $this.GameBoard.board[$row,$col].neighbors -eq 3) {
                        Write-Verbose "Flipped ($row,$col) to $true"
                        $this.GameBoard.board[$row,$col].ChangeState($true) # Ahh-ahh-ahh-ahh, stayin alive, stayin alive
                    } Else {
                        Write-Verbose "Flipped ($row,$col) to $false"
                        $this.GameBoard.board[$row,$col].ChangeState($false)
                    }
                } Else {
                    If ($this.GameBoard.board[$row,$col].neighbors -eq 3) {
                        Write-Verbose "Flipped ($row,$col) to $true"
                        $this.GameBoard.board[$row,$col].ChangeState($true)
                    }
                }

                #Write-Verbose "OLD BOARD"
                #$old_board.Display(100)

                #Write-Verbose "NEW BOARD"
                #$this.GameBoard.Display(100)

                # Debug only
                If ($this.GameBoard.board[$row,$col].neighbors -gt 0) {
                    If ($this.GameBoard.board[$row,$col].isAlive) {
                        $status = 'Alive'
                    } Else {
                        $status = 'Dead'
                    }
                    Write-Verbose "($row,$col) is $status with $($this.GameBoard.board[$row,$col].neighbors) neighbors"
                }
            }
        }
    }

    [string]displayCurrentGeneration() {
        return ($this.currentGeneration + 1)
    }
}

#$game = [Life]::new(50) # Large size values are very slow to render!!

#$game2 = [Life]::new(4,5)

$game3 = [Life]::new(3,10,0)