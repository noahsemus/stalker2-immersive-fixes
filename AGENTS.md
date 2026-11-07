# ImmersiveFixes — mod context for the agent

**First read `harness/AGENTS.md`**: the shared rules, tester workflow, pipeline and game knowledge for every
Stalker 2 mod. They apply here. This file holds only what is specific to this mod.

Purpose: Small visual fixes for S.T.A.L.K.E.R. 2: sharper reflections and more.

Repo `noahsemus/stalker2-immersive-fixes`, Zone Kit plugin `ImmersiveFixes` (`/ImmersiveFixes/`), asset prefix `ImmFix`. Created from the
harness on 2026-11-06.

## Current state (one line per checkpoint / release: date, what changed, what the tester confirmed in game)
- 2026-11-06: repo created (Noah: "bundle it in with sharper reflections in a new mod we will call immersive fixes").
  Feature 1 = reflections: the tester's own UE4SS prototype `SharperReflections` (`zonekit/research/prototype/`,
  installed in his Vortex; sets 3 cvars ~10 s after every ClientRestart; log line "applied 3 settings") is liked in
  game. It must become a pak (UE4SS never ships): a NewContent runtime host actor calling `ExecuteConsoleCommand`.
  Feature 2 = NPC hair flicker on entering dialogue and on cinematic -> dialogue: research done
  (`zonekit/research/2026-11-06-npc-hair-flicker.md`), console A/B test with the tester next.
  Next: the tester picks `ImmersiveFixes` in the editor's toolbar mod selector once (GameFeatureData).

## Key facts (verified; cite file:line in the kit)
- Reflection cvars liked by the tester (2026-11-06, on top of his Ultra+ Extensions setup):
  `r.Lumen.Reflections.TraceMeshSDFs 1`, `r.Lumen.TraceMeshSDFs.TraceDistance 180`,
  `r.Lumen.Reflections.SurfaceCacheFeedback 1`. Ultra+ never sets these three (it resets TraceDistance to 90 only on its
  "reset to game" key). Research and dead ends (hardware ray tracing, planar reflections, characters occluding
  reflections): `harness/docs/game-facts.md` § Rendering.
- NPC hair is Groom: strands (`_STR`) + cards (`_CAR`) per hairstyle; strands only in close-ups (dialogue,
  cutscenes), no LOD hysteresis (`zonekit/research/2026-11-06-npc-hair-flicker.md`).

## Assets this mod may override
- _(none yet; see harness/docs/compatibility.md before adding any)_

## Files
- `PLAN.md` plan and test matrix · `BUILD.md` every edit asset by asset · `zonekit/README.md` engineering log
  (what each test showed, dead ends) · `zonekit/ImmersiveFixes/` plugin mirror · `zonekit/tools/` mod-specific generators
  and classifier lists · `zonekit/builds/` checkpoint and release paks · `mod.json` names and pak suffixes.
- `CLAUDE.md` / `GEMINI.md` only import `harness/AGENTS.md` and this file, for tools that don't read `AGENTS.md`.

## Release (only when the tester says "cut a release")
Follow `harness/docs/pipeline.md` § Release. Nexus page: _(record the mod id here once it exists)_.
