# Pokémon Cards CSS Holo Breakdown

A detailed overview of the holofoil subcategories used in [poke-holo.simey.me](https://poke-holo.simey.me/) and how each effect is achieved.

## Table of Contents

- [Overview](#overview)
- [How the effect system works](#how-the-effect-system-works)
- [Non-holo baseline](#non-holo-baseline)
- [Holo subcategories](#holo-subcategories)
  - [Reverse Holo](#reverse-holo)
  - [Holofoil Rare](#holofoil-rare)
  - [Galaxy / Cosmos Holofoil](#galaxy--cosmos-holofoil)
  - [Amazing Rare](#amazing-rare)
  - [Radiant Holo](#radiant-holo)
  - [Trainer Gallery Holofoil](#trainer-gallery-holofoil)
  - [Pokémon V](#pokémon-v)
  - [Pokémon V Full Art](#pokémon-v-full-art)
  - [Pokémon V Alternate Art](#pokémon-v-alternate-art)
  - [VMAX](#vmax)
  - [VMAX Alternate / Rainbow](#vmax-alternate--rainbow)
  - [VSTAR](#vstar)
  - [Trainer Full Art Holo](#trainer-full-art-holo)
  - [Rainbow Rare](#rainbow-rare)
  - [Secret Rare Gold](#secret-rare-gold)
  - [Trainer Gallery V / VMAX](#trainer-gallery-v--vmax)
  - [Shiny Vault](#shiny-vault)
- [Shared techniques across all holo types](#shared-techniques-across-all-holo-types)
- [Important notes](#important-notes)
- [Summary](#summary)

---

## Overview

This project is a showcase of advanced CSS effects used to simulate Pokémon card holofoil finishes.  
It combines:

- 3D transforms
- animated gradients
- blend modes
- foil masks
- glare layers
- shine layers
- texture overlays
- cursor-reactive lighting

The result is an interactive set of card styles that imitate many modern Pokémon TCG foil treatments, especially Sword & Shield era rarities.

This is not just one holo effect reused everywhere. Each rarity or card family has its own visual recipe, tuned to feel closer to the real card finish.

---

## How the effect system works

At the core of the project is a shared interaction system.

When the user moves the mouse over a card, the app updates CSS custom properties such as:

- pointer position
- rotation angle
- background offset
- glare intensity
- shine position
- scale and translation

These variables are then used by the card CSS to drive:

- 3D tilt
- moving glare
- animated shine
- foil texture motion
- masked holo regions

So the illusion is built in two parts:

1. **A shared motion engine**  
   All cards respond to movement in a similar physical way.

2. **A rarity-specific material layer**  
   Each holo subtype changes the gradients, textures, masks, and blend behavior to create a unique finish.

That is why all cards feel consistent, while still looking different from one another.

---

## Non-holo baseline

### Common / Uncommon

These cards are useful as the baseline.

They still use the same tilt and pointer-tracking system, so they feel interactive, but they do **not** include a full holofoil treatment.

Instead, they mostly rely on:

- 3D rotation
- subtle glare
- light reflection movement

This makes them look glossy rather than holographic.

---

## Holo subcategories

## Reverse Holo

Reverse holo cards are one of the more layout-dependent styles.

### How it is achieved

The effect is built using:

- a foil layer
- a mask layer
- a glare layer

The important part is that the foil is **masked differently** depending on the card layout.  
For example, Trainers, Energy cards, and Pokémon cards do not all expose the same regions.

### Visual goal

The artwork window and the holo area behave differently, just like on real reverse holos.  
Instead of flooding the whole card with one effect, the CSS carefully clips the foil so only the correct region reflects light.

---

## Holofoil Rare

This is the standard holo rare look.

### How it is achieved

The effect uses:

- repeating linear gradients
- filters
- glare overlay
- clipping for holo regions
- animated background positions tied to cursor movement

### Visual goal

The card gets a stronger vertical beam or streak-like holo treatment than a non-holo card.  
As the cursor moves, the gradients shift, creating the impression of foil catching light at different angles.

---

## Galaxy / Cosmos Holofoil

This style recreates the classic “cosmos” or “galaxy” sparkle look.

### How it is achieved

Instead of using only gradients, this effect adds:

- a galaxy-style image texture
- a rainbow overlay
- strong blend modes such as color dodge / color burn
- cursor-driven background movement

### Visual goal

The card looks more speckled and nostalgic than a regular holo rare.  
It feels less like smooth foil bands and more like a starry reflective sheet.

---

## Amazing Rare

Amazing Rare cards have a much louder, more colorful holo finish.

### How it is achieved

This effect uses:

- foil masking
- glitter or sparkle texture
- bright lightening behavior
- enhanced shine beyond the normal frame boundaries

### Visual goal

Compared with regular holo, this effect is shinier, noisier, and more energetic.  
It is meant to feel like the card is glowing and textured at the same time.

---

## Radiant Holo

Radiant cards have a very specific foil pattern in real life, which is difficult to reproduce exactly in CSS.

### How it is achieved

Instead of recreating the physical print pattern mathematically, the project uses:

- a criss-cross gradient structure
- moving linear highlights
- strong reactive lighting

### Visual goal

The result is an approximation rather than a perfect one-to-one copy.  
It still captures the radiant feeling by using intersecting light bands that sweep across the surface.

---

## Trainer Gallery Holofoil

Trainer Gallery holo cards lean more metallic and iridescent than standard holo rares.

### How it is achieved

The effect is built from:

- a large color-dodge linear gradient
- a radial highlight following the cursor
- hard-light / high-contrast blending
- metallic-looking shine behavior

### Visual goal

This produces a foil that feels more like polished metal or reflective laminate than traditional holo stripes.

---

## Pokémon V

Pokémon V introduces the premium diagonal holo style.

### How it is achieved

The V effect uses:

- multiple diagonal gradients
- opposing directional movement
- color-dodge style blending
- subtle texture/noise overlays
- pointer-based background shifting

### Visual goal

The diagonal light bands seem to slide across the card as it tilts.  
This makes V cards feel more animated and expensive than regular holo rares.

---

## Pokémon V Full Art

Full Art V cards take the V holo system and push it further.

### How it is achieved

This variation adds:

- stronger texture overlays
- more visible metallic patterning
- richer color interaction
- diagonal gradient motion similar to regular V cards

### Visual goal

The finish looks denser and more premium than normal V.  
The texture becomes more noticeable and gives the card a more “manufactured foil surface” appearance.

---

## Pokémon V Alternate Art

Alternate Art V cards are close to Full Art V in behavior.

### How it is achieved

They mostly reuse the same core approach:

- diagonal premium gradients
- texture overlays
- cursor-driven foil movement

The biggest change is usually the **texture character** and how it complements the artwork.

### Visual goal

The holo is not fundamentally different from Full Art V, but the altered texture and artwork composition make it feel distinct.

---

## VMAX

VMAX is a heavier, broader version of the V-style foil.

### How it is achieved

This version keeps the layered gradient system, but changes the balance:

- broader gradients
- slower-feeling motion
- stronger texture presence
- thicker premium foil look

### Visual goal

VMAX feels fuller and more saturated than standard V cards.  
The texture contributes more to the final look, while the gradients feel less narrow and sharp.

---

## VMAX Alternate / Rainbow

This is where the rainbow-style layering becomes much more prominent.

### How it is achieved

The effect combines:

- linear rainbow gradients
- glitter or sparkle image layers
- texture-pattern overlays
- layered blending between all of the above

### Visual goal

Rather than relying only on moving color bands, this style adds visible glitter and pattern depth, creating a flashy premium rare appearance.

---

## VSTAR

VSTAR keeps the premium diagonal style but softens it.

### How it is achieved

It uses:

- diagonal gradients
- texture overlays
- lighter, softer color treatment
- less aggressive foil contrast

### Visual goal

VSTAR cards feel brighter and more pastel than V or VMAX.  
The finish is still premium, but not as harsh or intense.

---

## Trainer Full Art Holo

Trainer full art cards are treated as their own tuned foil family.

### How it is achieved

They appear to use a similar framework to other premium rarities:

- textured foil
- directional gradients
- glare layers
- pointer-based lighting

### Visual goal

The intent is to give Trainer full arts a distinct premium finish rather than just reusing another rarity unchanged.

> Note: in the original page text, this section appears to share wording with another category, so the displayed explanation may be partially duplicated. The separate styling file suggests it was still intended as its own holo group.

---

## Rainbow Rare

Rainbow Rare turns glitter into the star of the show.

### How it is achieved

This effect layers:

- pastel gradients
- glitter or sparkle textures
- strong blend interactions
- bright reflective highlights

### Visual goal

The card looks extremely glittery and luminous, with the rainbow tone spread across the whole finish rather than appearing as a small accent.

---

## Secret Rare Gold

Gold Secret Rares are one of the most distinctive styles in the project.

### How it is achieved

The effect uses:

- two glitter layers
- overlay-style stacking
- opposite-direction motion
- gradient masking to separate foil and glitter regions

### Visual goal

The separation of layers is important.  
Instead of collapsing into visual noise, the card keeps foil reflection and glitter sparkle distinct, which helps create a convincing gold-metal look.

---

## Trainer Gallery V / VMAX

These are modified versions of the standard V and VMAX holo systems.

### How it is achieved

The project appears to reuse the existing V-family logic while adjusting:

- effect strength
- values and timing
- texture or background choice
- overall finish emphasis

### Visual goal

This creates cards that feel familiar to V / VMAX, but still unique enough to match the Trainer Gallery identity.

---

## Shiny Vault

Shiny Vault cards are designed to feel more silver than rainbow.

### How it is achieved

The effect uses:

- foil imagery
- radial gradients
- brightness control against a white card base
- silver-toned reflective tuning

### Visual goal

The aim is a cool, silvery foil finish rather than a colorful rainbow one.  
This is especially important because white card backgrounds can easily wash out reflective effects if not darkened carefully.

---

## Shared techniques across all holo types

Although each holo subtype looks different, most of them are built from the same visual toolkit.

### 1. Pointer-driven 3D transform
Every card responds to cursor movement using rotation and perspective transforms.

### 2. Shine layer
A moving light band or reflective zone that slides across the surface.

### 3. Glare layer
A brighter, more focused light reflection usually tied closely to pointer position.

### 4. Gradient animation
Many foil types use linear or radial gradients whose positions shift with user movement.

### 5. Masking
Some cards only allow foil in specific regions, so masks or clipping are essential.

### 6. Texture overlays
Glitter, galaxy textures, metallic patterns, and noise layers prevent the foil from looking flat.

### 7. Blend modes and filters
Effects such as dodge, burn, overlay, hard light, and brightness tuning help simulate reflective materials.

Together, these techniques make the cards feel like they are made of different foil materials rather than just using different colors.

---

## Important notes

- This project is primarily a **showcase/demo**, not a ready-made reusable package.
- The visual effects are **heavy** and can be expensive in terms of browser performance.
- The CSS, assets, and interaction logic are tightly connected.
- Some effects depend on masks and texture assets, not just pure gradients.
- Several categories are best understood as **variations of shared families**, rather than completely independent rendering systems.

In other words, the project is best viewed as a collection of handcrafted holo recipes built on top of one shared interaction engine.

---

## Summary

The easiest way to understand the holo categories is this:

- **Reverse Holo** uses masking and separated foil regions.
- **Regular Holo Rare** uses moving gradient beams.
- **Cosmos** adds galaxy-style texture.
- **Amazing Rare** emphasizes bright glitter and texture.
- **Radiant** approximates a criss-cross radiant pattern.
- **Trainer Gallery Holo** looks more metallic and iridescent.
- **V / V Full Art / Alt Art** use premium diagonal gradients and texture.
- **VMAX** pushes texture and depth further.
- **VSTAR** softens the premium foil into a brighter pastel finish.
- **Rainbow Rare** makes glitter dominant.
- **Gold Secret Rare** uses layered glitter and masked separation.
- **Shiny Vault** shifts the finish toward silver reflection.

Overall, the project succeeds because it does not treat holofoil as one single effect.  
Instead, it changes the material response of each card family through different combinations of gradients, textures, masks, and blend behavior.

---