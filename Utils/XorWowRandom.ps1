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
        $this.addend = ($seed1 -shl 10) -bxor [int]::CreateTruncating([uint]::CreateTruncating($seed2) -shr 4)

        if (($this.x -bor $this.y -bor $this.z -bor $this.w -bor $this.v) -eq 0) {
            throw "Initial state must have at least one non-zero element."
        }

        # some trivial seeds can produce several values with zeroes in upper bits, so we discard first 64
        for ($i = 0; $i -lt 64; $i++) {
            $this.NextInt() > $null
        }
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

    [int] NextBits([int] $bitCount) {
        return [int]::CreateTruncating(
            [uint]::CreateTruncating($this.NextInt()) -shr (32 - $bitCount)
        ) -band (-$bitCount -shr 31)
    }
}


function New-XorWowRandom([int] $Seed) {
    return [XorWowRandom]::new($Seed, $Seed -shr 31)
}
