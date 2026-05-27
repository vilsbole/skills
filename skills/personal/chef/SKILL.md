---
name: chef
description: Generate recipes and render them as "Cooking for Engineers" style tabular diagrams — ingredients down the left, operations merging across columns, final dish at the right. Use this skill whenever the user asks for a recipe, meal idea, cooking instructions, or wants to visualize a recipe as a chart/Gantt-style diagram. Also use when the user mentions specific styles (Italian, Japanese, French, etc.), constraints (quick, beginner, vegan), or substitution-based cooking ("what can I make with..."). Trigger even when the user doesn't explicitly say "Cooking for Engineers" — any recipe request should produce this tabular output by default.
---

# Chef — Cooking for Engineers Recipe Skill

This skill does two things in one flow:

1. **Generate** a recipe adapted to the user's request (cuisine, skill level / time budget, or available ingredients).
2. **Format** that recipe as a Cooking for Engineers-style HTML table, where ingredients are rows on the left and operations span/merge across columns to the right, ending in the final dish.

The output is always a self-contained HTML file written to the working directory and opened in the user's browser so they can view the rendered table.

---

## When to use this skill

Use this skill for any recipe request, even casual phrasing like:

- "What should I cook tonight?"
- "Give me a quick pasta recipe"
- "I have chicken, lemons, and rosemary — what can I make?"
- "Show me how to make a Japanese omelet"
- "Beginner-friendly French dessert"

Default to producing the tabular HTML output even if the user didn't ask for a chart. The visual format *is* the value of this skill. If the user explicitly wants only prose instructions, give those instead — but mention the tabular view is available.

---

## Workflow

### Step 1: Understand the request

Parse what the user is asking for along three axes. Most requests touch one or two; fill in sensible defaults for the rest:

- **Cuisine / style**: Italian, Japanese, French, Mexican, etc. Default: pick something that fits other constraints, or ask if truly ambiguous.
- **Skill level / time**: "quick" / "30 minutes" / "beginner" / "weekend project". Default: ~45 minutes, intermediate.
- **Constraints**: dietary (vegan, GF), available ingredients ("what's in my fridge"), serving size. Default: 4 servings, no restrictions.

If the user gives an ingredient list and asks "what can I make," do substitution-based generation: pick a dish those ingredients can realistically produce, supplementing with common pantry items (salt, oil, pepper, basic aromatics) — and note any pantry items you're assuming. Don't invent exotic additions.

Only ask a clarifying question if a critical constraint is genuinely unclear (e.g., "Italian dinner" with no other context is fine — pick something; but "I want a thing" needs clarification).

### Step 2: Design the recipe as a tree

The tabular format requires the recipe to be structured as an **operation tree**: leaves are ingredients, internal nodes are operations that combine inputs into intermediates. The root is the finished dish.

Think of it like this:

```
                              ┌─ pasta ─────┐
                              │             │
                              │             ├─ boil ──┐
                              │ salt ───────┘         │
                              │ water ──────┘         ├─ toss ── plate
                              │                       │
                              │ guanciale ─ render ──┐│
                              │ egg yolks ─┐         ├┘
                              │ pecorino ──┼─ whisk ─┘
                              │ pepper ────┘
```

Flattened, that becomes the table: 7 ingredient rows, operations as merged cells columnar to the right, final "plate" cell spanning everything.

**Design rules:**

- Keep the tree clean. Each ingredient appears once. Sub-recipes (e.g., a sauce used in two places) need their final intermediate referenced twice — note this in prose if it happens, since the table can't draw it cleanly.
- Operations should be specific and short: "whisk", "render 5 min", "boil 8 min", "fold in", "rest 10 min", "bake 350°F 25 min". Include times/temps inline when relevant — that's the engineering aspect.
- Order ingredients so that things combined together are adjacent rows. This is what lets the merged cells render cleanly. Reorder freely as you design — the user reads top-to-bottom but order doesn't imply sequence.
- Aim for 5–12 ingredients and 3–6 operations deep. Bigger recipes get hard to read.

### Step 3: Express the recipe as JSON, then render

Read `references/data-format.md` for the exact JSON schema and `references/rendering.md` for the rendering algorithm. The script `scripts/render.py` takes recipe JSON and produces the HTML.

Workflow:

1. Write the recipe as JSON matching the schema (see `references/data-format.md`) to a temp file, e.g. `/tmp/<dish-name>.json`.
2. Run the renderer to produce the HTML in the working directory:
   ```bash
   uv run --no-project python skills/personal/chef/scripts/render.py /tmp/<dish-name>.json ./<dish-name>.html
   ```
   (`render.py` is pure stdlib — plain `python3 .../render.py ...` works too if `uv` isn't available. Adjust the script path to wherever the skill is installed.)
3. Open the result in the user's browser: `open ./<dish-name>.html` on macOS (`xdg-open` on Linux, `start` on Windows).
4. In the chat, give a one-paragraph note describing the dish and any substitutions/assumptions you made, and state the file path. Don't restate the recipe in prose — the table is the recipe.

### Step 4: Pantry-staple handling

When a user gives an ingredient list, assume these are available unless told otherwise: salt, black pepper, neutral cooking oil, olive oil, water, butter (if not vegan), one onion, garlic. Anything beyond that you assume → mention in the note. If the user's list is incompatible with anything coherent, say so honestly and ask for one or two more items rather than inventing a dish.

---

## Style variations

### Cuisine

Match conventions of the cuisine — Italian recipes shouldn't have soy sauce, Japanese recipes shouldn't have parmesan, etc. When you pick a dish, pick something representative but not exhausted (skip spaghetti bolognese, butter chicken, etc. unless asked).

### Skill level / time

- **Quick / beginner (≤30 min)**: ≤8 ingredients, tree depth ≤3, no specialty equipment.
- **Intermediate (~45 min)**: standard scope.
- **Weekend project**: can include resting/marinating steps, multiple sub-techniques. Note total elapsed time vs. active time in your chat message.

### Substitution-based

Lead with what the user has. Build the dish around it. If their ingredients suggest multiple options, pick one and briefly mention the alternative in the chat message ("could also do X with the same base").

---

## Output format

Always produce an HTML file. The HTML must be self-contained (inline CSS, no external dependencies) so it renders correctly when opened directly in a browser.

After writing it, open it in the user's browser and state the file path in the chat. Keep the chat message brief: name the dish, note any assumptions (substitutions, pantry items), mention time if relevant. Don't duplicate the recipe content in prose.

---

## Reference files

- `references/data-format.md` — JSON schema for recipes, with examples.
- `references/rendering.md` — How the tabular layout algorithm works and styling conventions.
- `scripts/render.py` — Takes a recipe JSON file and produces standalone HTML (`python render.py <recipe.json> <output.html>`).
