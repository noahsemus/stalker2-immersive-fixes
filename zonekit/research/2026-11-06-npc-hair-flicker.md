# NPC hair flicker on entering dialogue / cinematic -> dialogue (research 2026-11-06, game 2.1.0)

Tester report: an NPC's hair flickers when a conversation starts, and when a cutscene hands over to dialogue.
Tester setup: Ultra+ Extensions (Ray Reconstruction via `Denoiser=rayreconstruction_temporalgihigh`, `FGCutscenes=on`),
DLSS DLAA, DLSS-G 4x (`GSCReXFrameGeneration.ini`), `sg.HairQuality=3`.

## How NPC hair is rendered: Groom (HairStrands)
- Every hairstyle = a strands groom (`_STR`) plus a cards groom (`_CAR`) in `AdditionalGrooms`
  (`GroomGeneratorPrototypes.cfg:95-114`, `Fac_30_08_Groom`; 595 `AdditionalGrooms` blocks). Faces get them through
  `AttachMeshPrototypes.cfg` `GroomPrototypeSID` (e.g. :6998). `mg.HairQuality` picks HR / MR / LR copies (3 = original).
- Materials `M_Groom_Alembic_base`, `M_HairGrooming_EyeAdaptation`: `MSM_Hair`, `bUsedWithHairStrands`, no dither.
- LOD tables (uncooked assets): head hair STR LOD0 strands 1.45/1.0, LOD1 strands 50 % 0.7, LOD2 invisible 0.35;
  CAR LOD0 invisible, LOD1-5 cards 0.7/0.45/0.25/0.15. Brows / lashes strands only, invisible below ~0.72.
  Engine (stock 5.5 `GroomManager.cpp:2179-2208, 2498, 2511`): screen size clamped to 1, no hysteresis, LOD0 only when
  forced. So: cards in gameplay, strands + cards in close-ups (dialogue, cutscenes), switching at a threshold.

## What changes at dialogue start
- FOV 90 -> 70 (`CoreVariables.cfg:332-333`) and the look-at camera: the groom's screen size jumps ~1.4x.
- Dialogue DOF f/32, max focus 10000 (`CoreVariables.cfg:334-336`): almost no blur.
- `ai.AgentLODBiasForCinematicsAndDialogs` (GSC, default -1 from the exe): NPC mesh LOD changes at dialogue start.
  Stock 5.5: strands root data per mesh LOD loads async; until ready a Skinning groom draws nothing
  (`GroomManager.cpp:2733, 2786, 3040-3073`). Not verified: LODSync driving the groom components.
- `r.HairStrands.Strands.TransferPrevPos` default 0: stale motion vectors on a LOD switch (`GroomManager.cpp:1484-1497`).
- Hair writes dummy GBuffer data (`r.HairStrands.WriteGBufferData` 1): RR guides on hair are not real hair data.
- Ultra+ `FGCutscenes=on` keeps DLSS-G running through cutscene -> dialogue cuts (`stalker2/frame_generation.lua:2-5`).
- Ultra+'s SetCinematicMode hook sets no cvars; `gsc.Cutscene.*.Override` cvars are shadows / visibility only.

## Ranked causes and console tests (all cvars verified in the retail exe)
1. Strands switching on / off with no hysteresis, or sub-pixel strands aliasing: `r.HairStrands.ForceLOD 2` (cards
   only), `1` (no switching), `-1` back. Fix candidates: `r.HairStrands.MinLOD 2` (cards like gameplay; loses brows /
   lashes in close-ups), `r.HairStrands.RasterizationScale 1`-`1.3` (default 0.5, steadier strands).
2. Ray Reconstruction on hair: `r.NGX.DLSS.DenoiserMode 0` then `1`; fix candidate `r.HairStrands.WriteGBufferData 2`.
3. DLSS-G 4x across cuts: frame generation off in the menu / Ultra+ `FGCutscenes=off` (not ours to ship).
4. Face LOD change at dialogue start: `ai.AgentLODBiasForCinematicsAndDialogs 0` before a new conversation.
5. Stale motion vectors: `r.HairStrands.Strands.TransferPrevPos 1`.
6. Sample buffer overflow in cutscene close-ups: `r.HairStrands.Visibility.MSAA.MeanSamplePerPixel 1` (retail 0.5,
   `DefaultEngine.ini:102`).
Scalability cvars (MinLOD, RasterizationScale) may be reset by a graphics settings change: re-apply on change.
Agent working files (UE 5.5 sources, extracted assets): session scratchpad `hair\`.
