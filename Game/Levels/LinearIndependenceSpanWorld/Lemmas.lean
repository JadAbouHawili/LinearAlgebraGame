import Game.Metadata.Metadata

namespace LinearAlgebraGame

open Set Finset
variable (K V : Type) [Field K] [AddCommGroup V] [Module K V] [DecidableEq V]

/--
**Helper Lemma: Sum of difference functions equals zero**

When we have two linear combinations that are equal, the sum of their 
difference over the union of their supports equals zero.

This technical lemma supports the proof of linear combination uniqueness.
-/
lemma sum_diff_eq_zero_of_equal_combinations 
  (s t : Finset V) (f g : V → K) 
  (hf0 : ∀ v ∉ s, f v = 0) (hg0 : ∀ v ∉ t, g v = 0)
  (heq : Finset.sum s (fun v => f v • v) = Finset.sum t (fun v => g v • v)) :
  (Finset.sum (s ∪ t) fun v => (f - g) v • v) = 0 := by
  -- Use the distributive property of subtraction over scalar multiplication
  simp only [Pi.sub_apply, sub_smul]
  
  -- Split the sum in two
  rw[sum_sub_distrib]
  
  -- Use subset properties to convert the sums back to the original sets
  have hs_sub : s ⊆ s ∪ t := by simp
  have ht_sub : t ⊆ s ∪ t := by simp
  rw [(sum_subset hs_sub (fun v _ h => by rw[hf0 v h]; simp [zero_smul])).symm]
  rw [(sum_subset ht_sub (fun v _ h => by rw[hg0 v h]; simp [zero_smul])).symm]
  
  -- Use the fact that the two sums are equal to finish the proof
  rw[heq]
  simp

/--
**Helper Lemma: Subset property for set difference**

When we have a set s that's a subset of S ∪ {v}, then s \ {v} is a subset of S.
This technical lemma handles the case analysis needed for linear independence proofs.
-/
lemma subset_diff_singleton (S : Set V) (s : Finset V) (v : V)
  (hs : ↑s ⊆ S ∪ {v}) :
  ↑(s.erase v) ⊆ S := by
  intros x hx
  simp [mem_coe, mem_erase] at hx
  obtain ⟨xs, xNev⟩ := hx
  have xInUnion := hs (mem_coe.mpr xs)
  simp at xInUnion
  cases' xInUnion with xEqv xInS
  · contradiction
  · exact xInS

/--
**Helper Lemma: Subset property for linear independence context**

In the context of linear independence proofs, when we have s ⊆ S ∪ {v} and need 
to show s \ {v} ⊆ S, this handles the required case analysis.
-/
lemma subset_for_linear_independence {S : Set V} {s : Finset V} {v : V}
  (hs : ↑s ⊆ S ∪ {v}) :
  ↑(s.erase v) ⊆ S := by
  intros x hx
  simp [mem_coe, mem_erase] at hx
  obtain ⟨xs, xNev⟩ := hx
  have xInUnion := hs (mem_coe.mpr xs)
  simp at xInUnion
  cases' xInUnion with xEqv xInS
  · contradiction
  · exact xInS

-- The following lemma is commented out due to compatibility issues with Lean 4.21.0
-- It may need to be reimplemented if required by future levels

end LinearAlgebraGame