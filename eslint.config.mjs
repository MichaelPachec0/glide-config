// @ts-nocheck — JS tooling config (not part of the typed glide surface); keeps
// tsserver from nagging about untyped deps like eslint-config-prettier.
//
// Division of labour: tsserver/tsc owns type-checking (against glide.d.ts);
// ESLint here is lint-only (the non-type-checked ruleset, so it stays fast and
// doesn't duplicate tsc). Prettier owns formatting — eslint-config-prettier
// (last) disables stylistic rules that would fight the formatter.
import js from "@eslint/js";
import tseslint from "typescript-eslint";
import prettier from "eslint-config-prettier";

export default [
  {
    // Global ignores (an ignores-only object applies repo-wide in flat config).
    ignores: [
      "glide.d.ts", // generated ambient declarations (~500 KB) — not ours to lint
      "glide/**", // live browser profile data
      "node_modules/**",
      ".direnv/**",
    ],
  },

  // Base JS rules for every linted file (including this config and glide.ts).
  js.configs.recommended,

  // TypeScript rules apply to real .ts files only, so JS tooling configs like
  // this one aren't linted with TS-specific rules (e.g. ban-ts-comment).
  ...tseslint.configs.recommended.map((config) => ({
    ...config,
    files: ["**/*.ts"],
  })),

  // Must be last: disables rules that would conflict with Prettier.
  prettier,
];
