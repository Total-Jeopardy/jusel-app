Dark theme migration quick guide
================================

- Prefer theme-aware helpers: use `JuselColors.background(context)`, `card(context)`, `border(context)`, `muted(context)`, and `mutedForeground(context)` instead of hard-coded colors.
- Use brand/status variants that adapt to dark mode: `primaryColor(context)`, `secondaryColor(context)`, `accentColor(context)`, `successColor(context)`, `warningColor(context)`, `destructiveColor(context)`.
- Always pass `context` to text styles: `JuselTextStyles.bodyMedium(context)` etc., then `.copyWith(...)` if needed.
- Avoid `const` on widgets when the color/style depends on `context` (e.g., icons/text using theme-aware colors).
- Surfaces: cards/containers should use `JuselColors.card(context)` or `JuselColors.cardElevated(context)` with `JuselColors.border(context)` for outlines instead of light-only fills (`Color(0xFFE5E7EB)`).
- Gradients and chips: ensure stops work on dark backgrounds; prefer alpha < 0.16 for overlays/highlights in dark.
- System UI: keep status/nav bars in sync with theme (via existing theme data).

Checklist for remaining screens
--------------------------------

- Replace hard-coded `Color(...)` values used as backgrounds/borders with theme tokens.
- Swap any light-only assets/illustrations for dark-friendly variants.
- Verify dialogs, sheets, inputs, and snackbars inherit the dark theme (no local overrides to light surfaces).
- Manually test: auth flows, dashboard cards/charts, reports drilldowns, product/sales modals, stock/restock forms.
