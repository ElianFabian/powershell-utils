# From the Kotlin standard library
class XorWowRandom {
    hidden [int] $x
    hidden [int] $y
    hidden [int] $z
    hidden [int] $w
    hidden [int] $v
    hidden [int] $addend

    XorWowRandom([int] $seed1, [int] $seed2) {
        $this.x = $seed1
        $this.y = $seed2
        $this.z = 0
        $this.w = 0
        $this.v = -bnot $seed1
        $this.addend = ($seed1 -shl 10) -bxor [int]::CreateTruncating(
            [uint]::CreateTruncating($seed2) -shr 4
        )

        if (($this.x -bor $this.y -bor $this.z -bor $this.w -bor $this.v) -eq 0) {
            throw "Initial state must have at least one non-zero element."
        }

        # some trivial seeds can produce several values with zeroes in upper bits, so we discard first 64
        for ($i = 0; $i -lt 64; $i++) {
            $this.NextInt() > $null
        }
    }

    static [XorWowRandom] FromSeed([int] $seed) {
        return [XorWowRandom]::new($seed, $seed -shr 31)
    }

    static [XorWowRandom] FromSeed([long] $seed) {
        return [XorWowRandom]::new([int]::CreateTruncating($seed), [int]::CreateTruncating($seed -shr 31))
    }


    [int] NextBits([int] $bitCount) {
        return [int]::CreateTruncating(
            [uint]::CreateTruncating($this.NextInt()) -shr (32 - $bitCount)
        ) -band (-$bitCount -shr 31)
    }


    [int] NextInt() {
        # Equivalent to the xorxow algorithm
        # From Marsaglia, G. 2003. Xorshift RNGs. J. Statis. Soft. 8, 14, p. 5
        $t = $this.x
        $t = $t -bxor [int]::CreateTruncating([uint]::CreateTruncating($t) -shr 2)
        $this.x = $this.y
        $this.y = $this.z
        $this.z = $this.w
        $v0 = $this.v
        $this.w = $v0
        $t = ($t -bxor ($t -shl 1)) -bxor $v0 -bxor ($v0 -shl 4)
        $this.v = $t
        $this.addend += 362437
        return $t + $this.addend
    }

    [int] NextInt([int] $until) {
        return $this.NextInt(0, $until)
    }
    
    [int] NextInt([int] $from, [int] $until) {
        if ($until -le $from) {
            throw "Random range is empty: [$from, $until)."
        }

        $n = $until - $from
        if ($n -gt 0 -or $n -eq [int]::MinValue) {
            if (($n -band - $n) -eq $n) {
                $bitCount = [Math]::ILogB($n)
                $rnd = $this.NextBits($bitCount)
            }
            else {
                $value = 0
                do {
                    $bits = [int]::CreateTruncating(
                        [uint]::CreateTruncating($this.NextInt()) -shr 1
                    )
                    $value = $bits % $n
                } while ($bits - $value + ($n - 1) -lt 0)
                $rnd = $value
            }
            return $from + $rnd
        }
        else {
            while ($true) {
                $rnd = $this.NextInt()
                if ($rnd -ge $from -and $rnd -lt $until) {
                    return $rnd
                }
            }
        }

        throw "This should never happen"
    }

    [long] NextLong() {
        return (([long] $this.NextInt()) -shl 32) + $this.NextInt()
    }

    [long] NextLong([long] $until) {
        return $this.NextLong(0, $until)
    }

    [long] NextLong([long] $from, [long] $until) {
        if ($until -le $from) {
            throw "Random range is empty: [$from, $until)."
        }
    
        $n = $until - $from
        if ($n -gt 0) {
            $rnd = 0L
            if (($n -band - $n) -eq $n) {
                $nLow = [int]::CreateTruncating($n)
                $nHigh = [int]::CreateTruncating(
                    [uint]::CreateTruncating($n) -shr 32
                )

                if ($nLow -ne 0) {
                    $bitCount = [Math]::ILogB($nLow)
                    $rnd = [long] $this.NextBits($bitCount) -band 0xFFFFFFFFL
                }
                elseif ($nHigh -eq 1) {
                    $rnd = [long] $this.NextInt() -band 0xFFFFFFFFL
                }
                else {
                    $bitCount = [Math]::ILogB($nHigh)
                    $rnd = ([long] $this.NextBits($bitCount) -shl 32) + ([long] $this.NextInt() -band 0xFFFFFFFFL)
                }
            }
            else {
                $value = 0L
                do {
                    $bits = [long]::CreateTruncating(
                        [ulong]::CreateTruncating($this.NextLong()) -shr 1
                    )
                    $value = $bits % $n
                } while ($bits - $value + ($n - 1) -lt 0)

                $rnd = $value
            }
            return $from + $rnd
        }
        else {
            while ($true) {
                $rnd = $this.NextLong()
                if ($rnd -ge $from -and $rnd -lt $until) {
                    return $rnd
                }
            }
        }
    
        throw "This should never happen"
    }

    [bool] NextBoolean() {
        return $this.NextBits(1) -ne 0
    }

    [double] NextDouble() {
        $hi26 = [long] $this.NextBits(26)
        $low27 = $this.NextBits(27)

        return ((($hi26 -shl 27L) + $low27) / [double] (1L -shl 53))
    }

    [double] NextDouble([double] $until) {
        return $this.NextDouble(0.0, $until)
    }

    [double] NextDouble([double] $from, [double] $until) {
        if ($until -le $from) {
            throw "Random range is empty: [$from, $until)."
        }

        $size = $until - $from
        if ([double]::IsInfinity($size) -and [double]::IsFinite($from) -and [double]::IsFinite($until)) {
            $r1 = $this.NextDouble() * ($until / 2 - $from / 2)
            $r = $from + $r1 + $r1
        }
        else {
            $r = $from + $this.NextDouble() * $size
        }
        if ($r -ge $until) {
            return [math]::NextDown($until)
        }
        else {
            return $r
        }
    }

    [float] NextFloat() {
        return $this.NextBits(24) / [float] (1 -shl 24)
    }


    [sbyte[]] NextBytes([sbyte[]] $array, [int] $fromIndex = 0, [int] $toIndex = $array.Length) {
        if ($fromIndex -lt 0 -or $toIndex -gt $array.Length) {
            throw "fromIndex ($fromIndex) or toIndex ($toIndex) are out of range: 0..$($array.Length)."
        }
        if ($fromIndex -gt $toIndex) {
            throw "fromIndex ($fromIndex) must be not greater than toIndex ($toIndex)."
        }
    
        $steps = [math]::Floor(($toIndex - $fromIndex) / 4)
    
        $position = $fromIndex
        for ($i = 0; $i -lt $steps; $i++) {
            $value = $this.NextInt()
            $array[$position] = [sbyte]::CreateTruncating($value)
            $array[$position + 1] = [sbyte]::CreateTruncating(
                [uint]::CreateTruncating($value) -shr 8
            )
            $array[$position + 2] = [sbyte]::CreateTruncating(
                [uint]::CreateTruncating($value) -shr 16
            )
            $array[$position + 3] = [sbyte]::CreateTruncating(
                [uint]::CreateTruncating($value) -shr 24
            )
            $position += 4
        }
    
        $remainder = $toIndex - $position
        $vr = $this.NextBits($remainder * 8)
        for ($i = 0; $i -lt $remainder; $i++) {
            $array[$position + $i] = [sbyte]::CreateTruncating(
                [uint]::CreateTruncating($vr) -shr ($i * 8)
            )
        }
    
        return $array
    }

    [sbyte[]] NextBytes([sbyte[]] $array) {
        return $this.NextBytes($array, 0, $array.Length)
    }
    
    [sbyte[]] NextBytes([int] $size) {
        $array = New-Object sbyte[]($size)
        return $this.NextBytes($array)
    }
}
