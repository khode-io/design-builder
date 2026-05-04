// @ts-check
import { defineConfig } from "astro/config";
import starlight from "@astrojs/starlight";

// https://astro.build/config
export default defineConfig({
  site: "https://khode-io.github.io/design_builder",
  base: "/design_builder",
  integrations: [
    starlight({
      title: "Design Builder Flutter",
      description:
        "A build tool that generates Flutter ThemeExtension code from W3C Design Tokens",
      logo: {
        src: "./src/assets/houston.webp",
      },
      social: [
        {
          icon: "github",
          label: "GitHub",
          href: "https://github.com/khode-io/design_builder",
        },
      ],
      sidebar: [
        {
          label: "Getting Started",
          items: [
            { label: "Installation", slug: "guides/installation" },
            { label: "Quick Start", slug: "guides/getting-started" },
          ],
        },
        {
          label: "Guides",
          items: [
            { label: "Configuration", slug: "guides/configuration" },
            { label: "Token Format", slug: "guides/token-format" },
          ],
        },
        {
          label: "API Reference",
          items: [
            { label: "AppTheme API", slug: "reference/app-theme" },
            { label: "Build Options", slug: "reference/build-options" },
            { label: "Examples", slug: "reference/example" },
          ],
        },
      ],
      editLink: {
        baseUrl: "https://github.com/khode-io/design_builder/edit/main/docs/",
      },
    }),
  ],
});
