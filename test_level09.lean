import Game.Levels.LinearIndependenceSpanWorld.Level08

namespace LinearAlgebraGame

open VectorSpace Finset

variable (K V : Type) [Field K] [AddCommGroup V] [VectorSpace K V] [DecidableEq V]

-- Test the helper lemma compilation
lemma test_zero_coeff (S : Set V) (v : V) (s : Finset V) (f : V → K) 
  (hv_not_span : ∀ (t : Finset V), ↑t ⊆ S → ∀ (g : V → K), ¬v = t.sum (fun x => g x • x))
  (hvIns : v ∈ s) 
  (subset : ↑(s \ {v}) ⊆ S)
  (hf : (s \ {v}).sum (fun w => f w • w) + f v • v = 0) : 
  f v = 0 := by
  by_contra hfv_ne_zero
  -- Test basic operations
  apply hv_not_span (s \ {v}) subset (fun x => -(f v)⁻¹ * (f x))
  simp only [mul_smul]
  rw[← smul_sum]
  -- Test calc block
  have h1 : f v • v = - (s \ {v}).sum (fun w => f w • w) := by
    linarith [hf]
  calc v = (f v)⁻¹ • (f v • v) := by
      rw [← mul_smul, inv_mul_cancel₀ hfv_ne_zero, one_smul]
    _ = (f v)⁻¹ • (- (s \ {v}).sum (fun w => f w • w)) := by rw [h1]
    _ = -(f v)⁻¹ • (s \ {v}).sum (fun w => f w • w) := by rw [smul_neg]
    _ = ∑ x ∈ s \ {v}, -(f v)⁻¹ * f x • x := by simp only [smul_sum, mul_smul]

end LinearAlgebraGame