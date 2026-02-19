# Bounce Logic

A 2D physics puzzle platformer in the vein of Angry Birds and Mario Maker. Guide your ball from start to goal by adjusting surface properties—bounciness, friction, and angle—to solve each level.

## The Concept

Instead of precise platforming, players experiment with physics. "What if I increase the bounce? What if I angle this platform?" This curiosity-driven approach rewards creative thinking over trial-and-error frustration.

## What We're Going For

- **Curiosity over frustration** – Encourage exploration, not grinding
- **Eureka moments** – That satisfying "aha" when a solution clicks
- **Anticipation rush** – Players feel the dopamine hit waiting to see if their setup works
- **Relaxed vibes** – No timers, no enemies, just you and the puzzle
- **Ego-driven replayability** – Optimize and find cleaner solutions

## Tech

- **Engine:** Godot
- **Platform:** Android & iOS
- **Team:** 5 people (Stephen Dunne, Ryan Holloway, Olawole Abayomi-Owodunni, Jordan, Dylan Crimmings)

## Project Structure

```
fwb/
├── scripts/           # Game logic
│   ├── Ball.gd       # Ball physics and rendering
│   ├── platforms/    # Platform behaviors
│   └── modifiers/    # Level modifiers
├── scenes/
│   ├── objects/      # Ball and platform templates
│   └── levels/       # Level layouts
├── assets/
│   ├── audio/        # Sound effects
│   └── sprites/      # Art assets
└── ui/               # Menu and HUD
```
